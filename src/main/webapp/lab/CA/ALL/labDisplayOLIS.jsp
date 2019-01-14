<%--

    Copyright (c) 2008-2012 Indivica Inc.

    This software is made available under the terms of the
    GNU General Public License, Version 2, 1991 (GPLv2).
    License details are available via "indivica.ca/gplv2"
    and "gnu.org/licenses/gpl-2.0.html".

--%>
<%@ page language="java" errorPage="../../../provider/errorpage.jsp" %>
<%@ page import="java.util.*,java.sql.*,org.oscarehr.olis.*,org.oscarehr.common.dao.PatientLabRoutingDao, org.oscarehr.util.SpringUtils, org.oscarehr.common.model.PatientLabRouting,oscar.oscarLab.ca.all.*,oscar.oscarLab.ca.all.util.*,oscar.oscarLab.ca.all.parsers.*,oscar.oscarLab.LabRequestReportLink,oscar.oscarMDS.data.ReportStatus,oscar.log.*,org.apache.commons.codec.binary.Base64" %>
<%@page import="org.oscarehr.util.AppointmentUtil" %>
<%@ page import="oscar.OscarProperties" %>
<%@ page import="org.oscarehr.common.dao.DemographicDao" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="oscar.oscarEncounter.data.EctFormData" %>
<%@ page import="org.oscarehr.util.LoggedInInfo" %>
<%@ page import="oscar.OscarProperties" %>
<%@ page import="org.json.JSONObject" %>
<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean" %>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html" %>
<%@ taglib uri="/WEB-INF/struts-logic.tld" prefix="logic" %>
<%@ taglib uri="/WEB-INF/oscar-tag.tld" prefix="oscar" %>
<%@ taglib uri="/WEB-INF/oscarProperties-tag.tld" prefix="oscarProperties"%>
<%@ taglib uri="/WEB-INF/indivo-tag.tld" prefix="indivo"%>
<%@ taglib uri="/WEB-INF/security.tld" prefix="security"%>
<%
      String roleName$ = (String)session.getAttribute("userrole") + "," + (String) session.getAttribute("user");
	  boolean authed=true;
%>
<security:oscarSec roleName="<%=roleName$%>" objectName="_lab" rights="r" reverse="<%=true%>">
	<%authed=false; %>
	<%response.sendRedirect("../../../securityError.jsp?type=_lab");%>
</security:oscarSec>
<%
if(!authed) {
	return;
}
%>

<%
	String segmentID = request.getParameter("segmentID");
String originalSegmentID = segmentID;
String providerNo = request.getParameter("providerNo");
String searchProviderNo = request.getParameter("searchProviderNo");

boolean preview = oscar.Misc.getStr(request.getParameter("preview"), "").equals("true");
Long reqIDL = preview ? null : LabRequestReportLink.getIdByReport("hl7TextMessage",Long.valueOf(segmentID));
String reqID = reqIDL==null ? "" : reqIDL.toString();
reqIDL = preview ? null : LabRequestReportLink.getRequestTableIdByReport("hl7TextMessage",Long.valueOf(segmentID));
String reqTableID = reqIDL==null ? "" : reqIDL.toString();

boolean obgynShortcuts = OscarProperties.getInstance().getProperty("show_obgyn_shortcuts", "false").equalsIgnoreCase("true") ? true : false;
String formId = "0";

PatientLabRoutingDao plrDao = preview ? null : (PatientLabRoutingDao) SpringUtils.getBean("patientLabRoutingDao");
PatientLabRouting plr = preview ? null : plrDao.findDemographicByLabId(Integer.valueOf(segmentID));
String demographicID = preview || plr==null  || plr.getDemographicNo() == null ? "" : plr.getDemographicNo().toString();

GregorianCalendar cal = new GregorianCalendar();
int curYear = cal.get(Calendar.YEAR);
int curMonth = (cal.get(Calendar.MONTH)+1);
int curDay = cal.get(Calendar.DAY_OF_MONTH);

if(demographicID != null && !demographicID.equals("")){
    LogAction.addLog((String) session.getAttribute("user"), LogConst.READ, LogConst.CON_HL7_LAB, segmentID, request.getRemoteAddr(),demographicID);
}else{
    LogAction.addLog((String) session.getAttribute("user"), LogConst.READ, LogConst.CON_HL7_LAB, segmentID, request.getRemoteAddr());
}

if (oscar.util.StringUtils.isNullOrEmpty(demographicID)){
    obgynShortcuts = false;
}
if (obgynShortcuts){
    List<EctFormData.PatientForm> formsONAREnhanced = Arrays.asList(EctFormData.getPatientFormsFromLocalAndRemote(LoggedInInfo.getLoggedInInfoFromSession(request),demographicID,"formONAREnhancedRecord",true));
    if (formsONAREnhanced!=null && !formsONAREnhanced.isEmpty()){
        formId = formsONAREnhanced.get(0).getFormId();
    }
}

String billRegion=(OscarProperties.getInstance().getProperty("billregion","")).trim().toUpperCase();
String billForm=OscarProperties.getInstance().getProperty("default_view");
DemographicDao demographicDao = SpringUtils.getBean(DemographicDao.class);

boolean ackFlag = false;
ArrayList ackList = preview ? null : AcknowledgementData.getAcknowledgements(segmentID);
Factory f;
MessageHandler handlerMain;
String hl7 = "";
Integer resultObrIndex = null;

if (!preview) {

	if (ackList != null){
	    for (int i=0; i < ackList.size(); i++){
	        ReportStatus reportStatus = (ReportStatus) ackList.get(i);
	        if ( reportStatus.getProviderNo().equals(providerNo) && reportStatus.getStatus().equals("A") ){
	            ackFlag = true;
	            break;
	        }
	    }
	}
	handlerMain = Factory.getHandler(segmentID);
	hl7 = Factory.getHL7Body(segmentID);

} else {
	String resultUuid = oscar.Misc.getStr(request.getParameter("uuid"), "");
	if (request.getParameter("obrIndex") != null) {
		resultObrIndex = Integer.parseInt(request.getParameter("obrIndex"));
	}
	handlerMain = OLISResultsAction.searchResultsMap.get(resultUuid);
}




OLISHL7Handler handler = null;
if (handlerMain instanceof OLISHL7Handler) {
	handler = (OLISHL7Handler) handlerMain;
}
else {
%> <jsp:forward page="labDisplay.jsp" /> <%
}
if (!preview && "true".equals(request.getParameter("showLatest"))) {

	String multiLabId = Hl7textResultsData.getMatchingLabs(segmentID);
	segmentID = multiLabId.split(",")[multiLabId.split(",").length - 1];
}

String multiLabId = preview ? "" :  Hl7textResultsData.getMatchingLabs(segmentID);

for (String tempId : multiLabId.split(",")) {
	if (tempId.equals(segmentID) || tempId.equals("")) { continue; }
	else {
		try {
			handler.importSourceOrganizations((OLISHL7Handler)Factory.getHandler(tempId));
		} catch (Exception e) {
			org.oscarehr.util.MiscUtils.getLogger().error("error",e);
		}
	}
}

// check for errors printing
if (request.getAttribute("printError") != null && (Boolean) request.getAttribute("printError")){
%>
<script language="JavaScript">
    alert("The lab could not be printed due to an error. Please see the server logs for more detail.");
</script>
<%}
%>
<%!
public String strikeOutInvalidContent(String content, String status) {
     return status != null && status.startsWith("W") ? "<s>" + content + "</s>" : content;
}
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
"http://www.w3.org/TR/html4/loose.dtd">

<html>
	<!--  This is an OLIS lab display -->
    <head>
        <html:base/>
        <title><%=handler.getPatientName()+" Lab Results"%></title>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <script language="javascript" type="text/javascript" src="../../../share/javascript/Oscar.js" ></script>
        <link rel="stylesheet" type="text/css" href="../../../share/css/OscarStandardLayout.css">
        <style type="text/css">
            <!--
* { word-wrap: break-word; }
.RollRes     { font-weight: 700; font-size: 8pt; color: white; font-family:
               Verdana, Arial, Helvetica }
.RollRes a:link { color: white }
.RollRes a:hover { color: white }
.RollRes a:visited { color: white }
.RollRes a:active { color: white }
.AbnormalRollRes { font-weight: 700; font-size: 8pt; color: red; font-family:
               Verdana, Arial, Helvetica }
.AbnormalRollRes a:link { color: red }
.AbnormalRollRes a:hover { color: red }
.AbnormalRollRes a:visited { color: red }
.AbnormalRollRes a:active { color: red }
.CorrectedRollRes { font-weight: 700; font-size: 8pt; color: yellow; font-family:
               Verdana, Arial, Helvetica }
.CorrectedRollRes a:link { color: yellow }
.CorrectedRollRes a:hover { color: yellow }
.CorrectedRollRes a:visited { color: yellow }
.CorrectedRollRes a:active { color: yellow }
tr.AbnormalRes { font-weight: bold; }
tr.AbnormalRes td ~ td { color: red; }
tr.AbnormalRes td ~ td a:link { color: red }
tr.AbnormalRes td ~ td a:hover { color: red }
tr.AbnormalRes td ~ td a:visited { color: red }
tr.AbnormalRes td ~ td a:active { color: red }
.NormalRes   { font-weight: bold; font-size: 8pt; color: black; }
.NormalRes a:link { color: rgb(0, 0, 238); }
.NormalRes a:hover { color: rgb(0, 0, 238); }
.NormalRes a:visited { color: rgb(0, 0, 238); }
.NormalRes a:active { color: rgb(0, 0, 238); }
.CorrectedRes { font-weight: bold; font-size: 8pt; color: #E000D0; font-family:
               Verdana, Arial, Helvetica }
.CorrectedRes a:link { color: #6da997 }
.CorrectedRes a:hover { color: #6da997 }
.CorrectedRes a:visited { color: #6da997 }
.CorrectedRes a:active { color: #6da997 }
.Field       { font-weight: bold; font-size: 8.5pt; color: black; font-family:
               Verdana, Arial, Helvetica }
div.Field a:link { color: black }
div.Field a:hover { color: black }
div.Field a:visited { color: black }
div.Field a:active { color: black }
.Field2      { font-weight: bold; font-size: 8pt; color: #ffffff; font-family:
               Verdana, Arial, Helvetica }
div.Field2   { font-weight: bold; font-size: 8pt; color: #ffffff; font-family:
               Verdana, Arial, Helvetica }
div.FieldData { font-weight: normal; font-size: 8pt; color: black; font-family:
               Verdana, Arial, Helvetica }
div.Field3   { font-weight: normal; font-size: 8pt; color: black; font-style: italic;
               font-family: Verdana, Arial, Helvetica }
div.Title    { font-weight: 800; font-size: 10pt; color: white; font-family:
               Verdana, Arial, Helvetica; padding-top: 4pt; padding-bottom:
               2pt }
div.Title a:link { color: white }
div.Title a:hover { color: white }
div.Title a:visited { color: white }
div.Title a:active { color: white }
div.Title2   { font-weight: bolder; font-size: 11pt; color: black; text-indent: 5pt;
	font-family: Courier, monospace !important; padding: 5px 15pt 5px 2pt}
div.Title2 a:link { color: black }
div.Title2 a:hover { color: black }
div.Title2 a:visited { color: black }
div.Title2 a:active { color: black }
.Cell        { background-color: #9999CC; border-left: thin solid #CCCCFF;
               border-right: thin solid #6666CC;
               border-top: thin solid #CCCCFF;
               border-bottom: thin solid #6666CC }
.Cell2       { background-color: #376c95; border-left-style: none; border-left-width: medium;
               border-right-style: none; border-right-width: medium;
               border-top: thin none #bfcbe3; border-bottom-style: none;
               border-bottom-width: medium }
.Cell3       { background-color: #add9c7; border-left: thin solid #dbfdeb;
               border-right: thin solid #5d9987;
               border-top: thin solid #dbfdeb;
               border-bottom: thin solid #5d9987 }
.CellHdr     { background-color: #cbe5d7; border-right-style: none; border-right-width:
               medium; border-bottom-style: none; border-bottom-width: medium }
.Nav         { font-weight: bold; font-size: 8pt; color: black; font-family:
               Verdana, Arial, Helvetica }
.PageLink a:link { font-size: 8pt; color: white }
.PageLink a:hover { color: red }
.PageLink a:visited { font-size: 9pt; color: yellow }
.PageLink a:active { font-size: 12pt; color: yellow }
.PageLink    { font-family: Verdana }
.text1       { font-size: 8pt; color: black; font-family: Verdana, Arial, Helvetica }
div.txt1     { font-size: 8pt; color: black; font-family: Verdana, Arial }
div.txt2     { font-weight: bolder; font-size: 6pt; color: black; font-family: Verdana, Arial }
div.Title3   { font-weight: bolder; font-size: 12pt; color: black; font-family:
               Verdana, Arial }
.red         { color: red }
.text2       { font-size: 7pt; color: black; font-family: Verdana, Arial }
.white       { color: white }
.title1      { font-size: 9pt; color: black; font-family: Verdana, Arial }
div.Title4   { font-weight: 600; font-size: 8pt; color: white; font-family:
               Verdana, Arial, Helvetica }
.monospaced {
	font-family: Courier, monospace !important;
}
            -->
        </style>
        <script type="text/javascript" src="<%=request.getContextPath()%>/js/jquery.js"></script>
		<script type="text/javascript">
		    jQuery.noConflict();
		</script>

<script type="text/javascript" src="<%= request.getContextPath() %>/share/jquery/jquery.form.js"></script>

        <script type="text/javaScript">
        function popupStart(vheight,vwidth,varpage,windowname) {
            var page = varpage;
            windowprops = "height="+vheight+",width="+vwidth+",location=no,scrollbars=yes,menubars=no,toolbars=no,resizable=yes";
            var popup=window.open(varpage, windowname, windowprops);
        }
        // open a new popup window
        function popupPage(vheight,vwidth,varpage) {
            var page = "" + varpage;
            windowprops = "height="+vheight+",width="+vwidth+",location=no,scrollbars=yes,menubars=no,toolbars=no,resizable=yes";
            var popup=window.open(page, "attachment", windowprops);
            if (popup != null) {
                if (popup.opener == null) {
                    popup.opener = self;
                }
            }
        }

        function popupONAREnhanced(vheight,vwidth,varpage) {
            var page = "" + varpage;
            windowprops = "height="+vheight+",width="+vwidth+",location=no,scrollbars=no,menubars=no,toolbars=no,resizable=yes";
            var popup=window.open(page, "attachment", windowprops);
            if (popup != null) {
                if (popup.opener == null) {
                    popup.opener = self;
                }
            }
        }
        function getComment() {
            var ret = true;
            var commentVal = prompt('<bean:message key="oscarMDS.segmentDisplay.msgComment"/>', '');

            if( commentVal == null )
                ret = false;
            else
                document.acknowledgeForm.comment.value = commentVal;

            return ret;
        }

        function printPDF(zipAttachments) {
            if (typeof zipAttachments !== 'undefined' && zipAttachments === true) {
                document.acknowledgeForm.action="PrintOLISLab.do?uuid=<%=request.getParameter("uuid")%>&includeAttachmentsInZip=true";
            } else {
                document.acknowledgeForm.action="PrintOLISLab.do?uuid=<%=request.getParameter("uuid")%>";
            }
            document.acknowledgeForm.submit();
        }

	function linkreq(rptId, reqId) {
	    var link = "../../LinkReq.jsp?table=hl7TextMessage&rptid="+rptId+"&reqid="+reqId;
	    window.open(link, "linkwin", "width=500, height=200");
	}

    function sendToPHR(labId, demographicNo) {
        popup(300, 600, "<%=request.getContextPath()%>/phr/SendToPhrPreview.jsp?labId=" + labId + "&demographic_no=" + demographicNo, "sendtophr");
    }

    window.ForwardSelectedRows = function() {
		var query = jQuery(document.reassignForm).formSerialize();
		jQuery.ajax({
			type: "POST",
			url:  "<%=request.getContextPath()%>/oscarMDS/ReportReassign.do",
			data: query,
			success: function (data) {
				self.close();
			}
		});
	}

        </script>

    </head>

    <body style="width:800px">
        <!-- form forwarding of the lab -->
        <form name="reassignForm_<%=segmentID%>" method="post" action="Forward.do">
            <input type="hidden" name="flaggedLabs" value="<%= segmentID %>" />
            <input type="hidden" name="selectedProviders" value="" />
            <input type="hidden" name="favorites" value="" />
            <input type="hidden" name="labType" value="HL7" />
            <input type="hidden" name="labType<%= segmentID %>HL7" value="imNotNull" />
            <input type="hidden" name="providerNo" value="<%= providerNo %>" />
        </form>
        <form name="acknowledgeForm" method="post" action="../../../oscarMDS/UpdateStatus.do">
            <input type="hidden" name="originalSegmentID" value="<%=originalSegmentID%>" />
            <table width="100%" height="100%" border="0" cellspacing="0" cellpadding="0">
                <tr>
                    <td valign="top">
                        <table width="100%" border="0" cellspacing="0" cellpadding="3">
                            <tr>
                                <td align="left" class="MainTableTopRowRightColumn" width="100%">
                                	<input type="hidden" name="labName" value="<%=handler.getAccessionNum() %>"/>
                                    <input type="hidden" name="segmentID" value="<%= segmentID %>"/>
                                    <input type="hidden" name="multiID" value="<%= multiLabId %>" />
                                    <input type="hidden" name="providerNo" value="<%= providerNo %>"/>
                                    <input type="hidden" name="status" value="A"/>
                                    <input type="hidden" name="comment" value=""/>
                                    <input type="hidden" name="labType" value="HL7"/>
                                    <% if ( !ackFlag ) { %>
                                    <input type="submit" value="<bean:message key="oscarMDS.segmentDisplay.btnAcknowledge"/>" onclick="return getComment();">
                                    <% } %>
                                    <input type="button" class="smallButton" value="<bean:message key="oscarMDS.index.btnForward"/>" onClick="popupStart(397, 700, '../../../oscarMDS/SelectProvider.jsp?docId=<%=segmentID%>&labDisplay=true', 'providerselect')">
                                    <input type="button" value=" <bean:message key="global.btnClose"/> " onClick="window.close()">
                                    <input type="button" value=" <bean:message key="global.btnPrint"/> " onClick="printPDF()">
									<input type="button" value="Print with Attachments" onClick="printPDF(true)">
                                    <% if ( demographicID != null && !demographicID.equals("") && !demographicID.equalsIgnoreCase("null")){
                                        String demographicName = demographicDao.getDemographic(demographicID).getFormattedName();
                                        String demographicProvider = demographicDao.getDemographic(demographicID).getProviderNo()!=null?demographicDao.getDemographic(demographicID).getProviderNo():"";
                                    %>
                                    <input type="button" value="Msg" onclick="popup(700,960,'../../../oscarMessenger/SendDemoMessage.do?demographic_no=<%=demographicID%>','msg')"/>
                                    <input type="button" value="Tickler" onclick="popup(450,600,'../../../tickler/ForwardDemographicTickler.do?updateParent=false&docType=HL7&docId=<%= segmentID %>&demographic_no=<%=demographicID%>','tickler')"/>
                                    <input type="button" value=" <bean:message key="oscarMDS.segmentDisplay.btnEChart"/> " onClick="popupStart(710,1024, '/oscar/oscarEncounter/IncomingEncounter.do?providerNo=<%=providerNo%>&appointmentNo=&demographicNo=<%=demographicID%>&curProviderNo=&reason=Lab%20Results&encType=&curDate=<%=curYear%>-<%=curMonth%>-<%=curDay%>&appointmentDate=&startTime=&status='
                                            +'&curDate=<%=curYear%>-<%=curMonth%>-<%=curDay%>&appointmentDate=&startTime=&status=')">
                                    <input type="button" value="Bill" onClick="popup(700, 1000, '<%=request.getContextPath()%>/billing.do?billRegion=<%=URLEncoder.encode(billRegion, "UTF-8")%>&billForm=<%=URLEncoder.encode(billForm, "UTF-8")%>&hotclick=&appointment_no=0&demographic_name=<%=URLEncoder.encode(demographicName, "UTF-8")%>&demographic_no=<%=demographicID%>&providerview=<%=demographicProvider%>&user_no=<%=providerNo%>&apptProvider_no=none&appointment_date=&start_time=00:00:00&bNewForm=1&status=t');return false;"/>
                                    <% } %>


				    <input type="button" value="Req# <%=reqTableID%>" title="Link to Requisition" onclick="linkreq('<%=segmentID%>','<%=reqID%>');" />
                                    <span class="Field2"><i>Next Appointment: <%=AppointmentUtil.getNextAppointment(demographicID) %></i></span>
                                </td>
                            </tr>
                            <% if (obgynShortcuts) {%>
                            <tr>
                                <td>
                                    <input type="button" value="AR1-ILI" onClick="popupONAREnhanced(290, 625, '<%=request.getContextPath()%>/form/formonarenhancedForm.jsp?demographic_no=<%=demographicID%>&formId=<%=formId%>&section='+this.value)" />
                                    <input type="button" value="AR1-PGI" onClick="popupONAREnhanced(225, 590,'<%=request.getContextPath()%>/form/formonarenhancedForm.jsp?demographic_no=<%=demographicID%>&formId=<%=formId%>&section='+this.value)" />
                                    <input type="button" value="AR2-US" onClick="popupONAREnhanced(395, 655, '<%=request.getContextPath()%>/form/formonarenhancedForm.jsp?demographic_no=<%=demographicID%>&formId=<%=formId%>&section='+this.value)" />
                                    <input type="button" value="AR2-ALI" onClick="popupONAREnhanced(375, 430, '<%=request.getContextPath()%>/form/formonarenhancedForm.jsp?demographic_no=<%=demographicID%>&formId=<%=formId%>&section='+this.value)" />
                                    <input type="button" value="AR2" onClick="popupPage(700, 1024, '<%=request.getContextPath()%>/form/formonarenhancedpg2.jsp?demographic_no=<%=demographicID%>&formId=<%=formId%>&update=true')" />

                                </td>
                            </tr>
                            <% } %>
                        </table>
                        <table width="100%" border="1" cellspacing="0" cellpadding="3" bgcolor="#9999CC" bordercolordark="#bfcbe3">
                            <%
                            if (multiLabId != null){
                                String[] multiID = multiLabId.split(",");
                                if (multiID.length > 1){
                                    %>
                                    <tr>
                                        <td class="Cell" colspan="2" align="middle">
                                            <div class="Field2">
                                                Version:&#160;&#160;
                                                <%
                                                for (int i=0; i < multiID.length; i++){
                                                    if (multiID[i].equals(segmentID)){
                                                        %>v<%= i+1 %>&#160;<%
                                                    }else{
                                                        if ( searchProviderNo != null ) { // null if we were called from e-chart
                                                            %><a href="labDisplay.jsp?segmentID=<%=multiID[i]%>&multiID=<%=multiLabId%>&providerNo=<%= providerNo %>&searchProviderNo=<%= searchProviderNo %>">v<%= i+1 %></a>&#160;<%
                                                        }else{
                                                            %><a href="labDisplay.jsp?segmentID=<%=multiID[i]%>&multiID=<%=multiLabId%>&providerNo=<%= providerNo %>">v<%= i+1 %></a>&#160;<%
                                                        }
                                                    }
                                                }
                                                %>
                                            </div>
                                        </td>
                                    </tr>
                                    <%
                                }
                            }
                            %>
                            <tr>
                                <td align="middle" class="Cell">
                                    <div class="Field2">
                                        <bean:message key="oscarMDS.segmentDisplay.olis.patientInfo"/>
                                    </div>
                                </td>
                                <td align="middle" class="Cell">
                                    <div class="Field2">
                                        <bean:message key="oscarMDS.segmentDisplay.olis.providerInfo"/>
                                    </div>
                                </td>
                                <td align="middle" class="Cell">
                                    <div class="Field2">
                                        <bean:message key="oscarMDS.segmentDisplay.olis.reportDetails"/>
                                    </div>
                                </td>
                            </tr>
                            <tr>
                                <td bgcolor="white" valign="top">
                                    <table valign="top" border="0" cellpadding="2" cellspacing="0" width="100%">
                                        <tr valign="top">
                                            <td valign="top" width="33%" align="left">
                                                <table width="100%" border="0" cellpadding="2" cellspacing="0" valign="top">
                                                    <tr>
                                                        <td valign="top" align="left">
                                                            <table valign="top" border="0" cellpadding="3" cellspacing="0" width="100%">
                                                                <tr>
                                                                    <td valign="top">
                                                                        <div class="FieldData">
                                                                            <strong>
                                                                                Ontario Health Number
                                                                            </strong>
                                                                        </div>
                                                                    </td>
                                                                    <td>
                                                                        <div class="FieldData">
                                                                            <%=handler.getFormattedHealthNumber()%>
                                                                        </div>
                                                                    </td>

                                                                </tr>


                                                                <%
                                                                Set<String> patientIdentifiers = handler.getPatientIdentifiers();
                                                                for (String ident : patientIdentifiers) {
                                                                	// The health number is displayed in a seperate location.
                                                                	if (ident.equals("JHN")) { continue; }
                                                                	String[] values = handler.getPatientIdentifier(ident);
                                                                	String value = values[0];
                                                                	String attrib = values[1];
                                                                	String attribName=  null;
                                                                	if (attrib != null) {
                                                                		attribName = handler.getSourceOrganization(attrib);
                                                                	}

                                                                %>
                                                                <tr>
                                                                    <td valign="top">
                                                                        <div class="FieldData">
                                                                            <strong><%=handler.getNameOfIdentifier(ident)%>: </strong>
                                                                        </div>
                                                                    </td>
                                                                    <td >
                                                                        <div class="FieldData">
                                                                            <%= value %>
                                                                             <% if (attribName != null) { %>
	                                                                             <span style="margin-left:15px; font-size:8px; color:#333333;">
	                                                                             <%= attribName %> (Lab <%=attrib %>)
	                                                                             </span>
                                                                             <% } %>
                                                                        </div>
                                                                    </td>
                                                                </tr>
                                                                <% } %>
                                                                <tr>
                                                                    <td valign="top">
                                                                        <div class="FieldData">
                                                                            <strong><bean:message key="oscarMDS.segmentDisplay.formPatientName"/>: </strong>
                                                                        </div>
                                                                    </td>
                                                                    <td>
                                                                        <div class="FieldData" >
                                                                            <% if ( searchProviderNo == null ) { // we were called from e-chart%>
                                                                            <a href="javascript:window.close()">
                                                                            <% } else { // we were called from lab module%>
                                                                            <a href="javascript:popupStart(360, 680, '../../../oscarMDS/SearchPatient.do?labType=HL7&segmentID=<%= segmentID %>&name=<%=java.net.URLEncoder.encode(handler.getLastName()+", "+handler.getFirstName())%>', 'searchPatientWindow')">
                                                                                <% } %>
                                                                                <%=handler.getPatientName()%>
                                                                            </a>
                                                                        </div>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td valign="top">
                                                                        <div class="FieldData">
                                                                            <strong><bean:message key="oscarMDS.segmentDisplay.formDateBirth"/>: </strong>
                                                                        </div>
                                                                    </td>
                                                                    <td >
                                                                        <div class="FieldData">
                                                                            <%=handler.getDOB()%>
                                                                        </div>
                                                                    </td>

                                                                </tr>
                                                                <tr>
                                                                    <td valign="top">
                                                                        <div class="FieldData">
                                                                            <strong><bean:message key="oscarMDS.segmentDisplay.formAge"/>: </strong>
                                                                        </div>
                                                                    </td>
                                                                    <td>
                                                                        <div class="FieldData">
                                                                            <%=handler.getAge()%>
                                                                        </div>
                                                                    </td>
                                                                 </tr>
                                                                 <tr>
                                                                    <td valign="top">
                                                                        <div class="FieldData">
                                                                            <strong><bean:message key="oscarMDS.segmentDisplay.formSex"/>: </strong>
                                                                        </div>
                                                                    </td>
                                                                    <td align="left">
                                                                        <div class="FieldData">
                                                                            <%=handler.getSex()%>
                                                                        </div>
                                                                    </td>
                                                                </tr>

                                                                <%!

                                                                public boolean stringIsNullOrEmpty(String s) {
                                                                	return s == null || s.trim().length() == 0;
                                                                }
                                                                public String displayAddressFieldIfNotNullOrEmpty(HashMap<String,String> address, String key) {
                                                                	return displayAddressFieldIfNotNullOrEmpty(address, key, true);
                                                                }
                                                                public String displayAddressFieldIfNotNullOrEmpty(HashMap<String,String> address, String key, boolean newLine) {
                                                                	String value = address.get(key);
                                                                	if (stringIsNullOrEmpty(value)) { return ""; }
                                                                	String result = value + (newLine ? "<br />" : "");
                                                                	return result;
                                                                }
                                                                %>
                                                                <%
                                                                ArrayList<HashMap<String,String>> addresses = handler.getPatientAddresses();
                                                                for(HashMap<String, String> address : addresses) {
                                                                	String city = displayAddressFieldIfNotNullOrEmpty(address, "City", false);
                                                                	String province = displayAddressFieldIfNotNullOrEmpty(address, "Province", false);
                                                                %>
                                                                <tr>
                                                                    <td valign="top">
                                                                        <div align="left" class="FieldData">
                                                                            <strong> <%=address.get("Address Type")%></strong>
                                                                        </div>
                                                                    </td>
                                                                    <td>
                                                                        <div align="left" class="FieldData">
                                                                            <%= displayAddressFieldIfNotNullOrEmpty(address, "Street Address") %>
                                                                            <%= displayAddressFieldIfNotNullOrEmpty(address, "Other Designation") %>
                                                                            <%= displayAddressFieldIfNotNullOrEmpty(address, "Postal Code") %>
                                                                            <%= city + ("".equals(city) || "".equals(province) ? "" : ", ") + province + ("".equals(city) && "".equals(province) ? "" : "<br/>") %>
                                                                            <%= displayAddressFieldIfNotNullOrEmpty(address, "Country") %>
                                                                        </div>
                                                                    </td>
                                                                </tr>
                                                                <% } %>
                                                                <%
                                                                ArrayList<HashMap<String,String>> homePhones = handler.getPatientHomeTelecom();
                                                                if (homePhones.size() > 0) {
                                                                %>
                                                                <tr><td colspan="2"><fieldset><legend>Home</legend><table>
                                                                <%
                                                                }
                                                                for(HashMap<String, String> homePhone : homePhones) {
                                                                %>
                                                                 <tr>
                                                                    <td valign="top">
                                                                        <div align="left" class="FieldData">
                                                                            <strong> <%=homePhone.get("equipType")%></strong>
                                                                        </div>
                                                                    </td>
                                                                    <td>
                                                                        <div align="left" class="FieldData">
                                                                        	<%
                                                                        	if (homePhone.get("email") != null) {
                                                                        	%>
                                                                        		<%=homePhone.get("email")%>
                                                                       		<%
                                                                       		} else {

                                                                       			String countryCode = homePhone.get("countryCode");
                                                                       			if (stringIsNullOrEmpty(countryCode)) {
                                                                       				countryCode = "";
                                                                       			}

                                                                       			String localNumber = homePhone.get("localNumber");
                                                                       			if (!stringIsNullOrEmpty(localNumber) && localNumber.length() > 4) {
                                                                       				localNumber = localNumber.substring(0,3) + "-" + localNumber.substring(3);
                                                                       			}
                                                                       			else { localNumber = ""; }
                                                                       			String areaCode = homePhone.get("areaCode");
                                                                       			if (!stringIsNullOrEmpty(areaCode)) {
                                                                       				areaCode = " ("+areaCode+") ";
                                                                       			}
                                                                       			else { areaCode = ""; }
                                                                       			String extension = homePhone.get("extension");
                                                                       			if (!stringIsNullOrEmpty(extension)) {
                                                                       				extension = " x" + extension;
                                                                       			}
                                                                       			else { extension = ""; }
                                                                    		%>
                                                                    			<%= countryCode + areaCode + localNumber + extension %>
                                                                    		<%
                                                                       		}
                                                                       		%>
                                                                            <span style="margin-left:15px; font-size:8px; color:#333333;">
						                                                    	<%=homePhone.get("useCode")%>
						                                                    </span>
                                                                        </div>
                                                                    </td>
                                                                </tr>
                                                                <% }
                                                                if (homePhones.size() > 0) {
                                                                %>
                                                                </table></fieldset></td></tr>
                                                                <%
                                                                }
                                                                %>
                                                                <%
                                                                ArrayList<HashMap<String,String>> workPhones = handler.getPatientWorkTelecom();
                                                                if (workPhones.size() > 0) {
                                                                %>
                                                                <tr><td colspan="2"><fieldset><legend>Work</legend><table>
                                                                <%
                                                                }
                                                                for(HashMap<String, String> workPhone : workPhones) {
                                                                %>
                                                                 <tr>
                                                                    <td valign="top">
                                                                        <div align="left" class="FieldData">
                                                                            <strong> <%=workPhone.get("equipType")%></strong>
                                                                        </div>
                                                                    </td>
                                                                    <td>
                                                                        <div align="left" class="FieldData">
                                                                        	<%
                                                                        	if (workPhone.get("email") != null) {
                                                                        	%>
                                                                        		<%=workPhone.get("email")%>
                                                                       		<%
                                                                       		} else {

                                                                       			String countryCode = workPhone.get("countryCode");
                                                                       			if (stringIsNullOrEmpty(countryCode)) {
                                                                       				countryCode = "";
                                                                       			}

                                                                       			String localNumber = workPhone.get("localNumber");
                                                                       			if (!stringIsNullOrEmpty(localNumber) && localNumber.length() > 4) {
                                                                       				localNumber = localNumber.substring(0,3) + "-" + localNumber.substring(3);
                                                                       			}
                                                                       			else { localNumber = ""; }
                                                                       			String areaCode = workPhone.get("areaCode");
                                                                       			if (!stringIsNullOrEmpty(areaCode)) {
                                                                       				areaCode = " ("+areaCode+") ";
                                                                       			}
                                                                       			else { areaCode = ""; }
                                                                       			String extension = workPhone.get("extension");
                                                                       			if (!stringIsNullOrEmpty(extension)) {
                                                                       				extension = " x" + extension;
                                                                       			}
                                                                       			else { extension = ""; }
                                                                    		%>
                                                                    			<%= countryCode + areaCode + localNumber + extension %>
                                                                    		<%
                                                                       		}
                                                                       		%>
                                                                            <span style="margin-left:15px; font-size:8px; color:#333333;">
						                                                    	<%=workPhone.get("useCode")%>
						                                                    </span>
                                                                        </div>
                                                                    </td>
                                                                </tr>
                                                                <% }
                                                                if (workPhones.size() > 0) {
                                                                %>
                                                                </table></fieldset></td></tr>
                                                                <%
                                                                }
                                                                %>
                                                            </table>
                                                        </td>
                                                    </tr>
                                                </table>
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                                <td bgcolor="white" valign="top">
                                    <table width="100%" border="0" cellspacing="0" cellpadding="2">
                                        <% HashMap<String, String> orderingProviderMap = handler.parseDoctor(handler.getDocName()); %>
                                        <tr>
                                            <td><div class="FieldData"><strong>Ordered By:</strong></div></td>
                                            <td><%=orderingProviderMap.get("name")%></td>
                                        </tr>
                                        <tr>
                                            <td><strong><%=orderingProviderMap.get("licenceType")%> #:</strong></td>
                                            <td><%=orderingProviderMap.get("licenceNumber")%></td>
                                        </tr>
                                        <%  HashMap<String,String> address = handler.getOrderingProviderAddress();
                                            if (address != null && address.size() > 0) {
                                                String formattedAddress = handler.getFormattedAddress(address, true);
                                        %>
                                        <tr>
                                            <td style="vertical-align: top">
                                                <div class="FieldData"><strong>Address:</strong></div>
                                            </td>
                                            <td>
                                                <%= formattedAddress %>
                                            </td>
                                        </tr>
                                        <%  } %>
                                        <%
                                            ArrayList<HashMap<String,String>> phones = handler.getOrderingProviderPhones();
                                            for(HashMap<String, String> phone : phones) {
                                        %>
                                        <tr>
                                            <td><div class="FieldData"><strong><%=phone.get("useCode")%>:</strong></div></td>
                                            <td><%= phone.get("telecom") %></td>
                                        </tr>
                                        <%
                                            }
                                        %>
                                    </table>
                                </td>
                                <td bgcolor="white" valign="top">
                                    <table width="100%" border="0" cellspacing="0" cellpadding="1">
                                        <tr>
                                            <td valign="top">
                                                <div class="FieldData">
                                                    <strong><bean:message key="oscarMDS.segmentDisplay.formReportStatus"/>:</strong>
                                                </div>
                                            </td>
                                            <td>
                                                <div class="FieldData" <%=handler.isReportNormal() ? "" : "style=\"color: red\""%>>
                                                    <%= handler.getReportStatusDescription()%>
                                                </div>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td></td>
                                        </tr>
                                        <tr>
                                            <td valign="top">
                                                <div class="FieldData">
                                                    <strong>Order Id:</strong>
                                                </div>
                                            </td>
                                            <td>
                                                <div class="FieldData">
                                                    <%= handler.getAccessionNum()%>
                                                    <span style="margin-left:15px; font-size:8px; color:#333333;">
                                                    <%= handler.getAccessionNumSourceOrganization() %>
                                                    </span>
                                                </div>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td valign="top">
                                                <div class="FieldData">
                                                    <strong>Order Date:</strong>
                                                </div>
                                            </td>
                                            <td>
                                                <div class="FieldData">
                                                    <%= handler.getOrderDate()%>
                                                </div>
                                            </td>
                                        </tr>
                                        <% String lastUpdate = handler.getLastUpdateInOLIS();
                                           if (!stringIsNullOrEmpty(lastUpdate)) {
                                        %>
                                        <tr>
                                            <td valign="top">
                                                <div class="FieldData">
                                                    <strong>Last Updated in OLIS:</strong>
                                                </div>
                                            </td>
                                            <td>
                                                <div class="FieldData">
                                                    <%= lastUpdate %>
                                                </div>
                                            </td>
                                        </tr>
                                        <% }
                                           String specimenReceived = handler.getSpecimenReceivedDateTime();
                                           if (!stringIsNullOrEmpty(specimenReceived)) {
                                        %>
                                         <tr>
                                            <td valign="top">
                                                <div class="FieldData">
                                                    <strong>Specimen Received:</strong>
                                                </div>
                                            </td>
                                            <td valign="top">
                                                <div class="FieldData">
                                                    <%= specimenReceived %>
                                                    <span style="font-size: 9px; color: #333333; display: block;">(unless otherwise specified)</span>
                                                </div>
                                            </td>
                                        </tr>
                                        <%
                                           }
                                           if (!"".equals(handler.getOrderingFacilityName())) {
                                        %>
                                        <tr>

                                            <td colspan="2">
                                                <div class="FieldData">
                                                    <strong>Ordering Facility:</strong>
                                                </div>
                                            </td>
                                            </tr>
                                        <tr>
                                            <td colspan="2">
                                                <div class="FieldData">
                                                    <%= handler.getOrderingFacilityName() %>
                                                    <%
                                                    address = handler.getOrderingFacilityAddress();
                                                    if (address != null && address.size() > 0) {
                                                    	String city = displayAddressFieldIfNotNullOrEmpty(address, "City", false);
                                                    	String province = displayAddressFieldIfNotNullOrEmpty(address, "Province", false);
                                                    %>
                                                    <br/>
                                                    <strong>Address:</strong><br/>
                                                    <%= displayAddressFieldIfNotNullOrEmpty(address, "Street Address") %>
                                                    <%= displayAddressFieldIfNotNullOrEmpty(address, "Other Designation") %>
                                                    <%= displayAddressFieldIfNotNullOrEmpty(address, "Postal Code") %>
                                                    <%= city + ("".equals(city) || "".equals(province) ? "" : ", ") + province + ("".equals(city) && "".equals(province) ? "" : "<br/>") %>
                                                    <%= displayAddressFieldIfNotNullOrEmpty(address, "Country") %>
                                                    <% } %>
                                                </div>
                                            </td>
                                        </tr>
                                        <% } %>
                                        <% if (!"".equals(handler.getAttendingProviderName())) { %>
                                        <tr>

                                            <td colspan="2">
                                                <div class="FieldData">
                                                    <strong>Attending Provider:</strong>
                                                </div>
                                            </td>
                                            </tr>
                                        <tr>
                                            <td colspan="2">
                                                <div class="FieldData">
                                                    <%= handler.getAttendingProviderName() %>
                                                </div>
                                            </td>
                                        </tr>
                                        <% }%>
                                        <% if (!"".equals(handler.getAdmittingProviderName())) { %>
                                        <tr>

                                            <td colspan="2">
                                                <div class="FieldData">
                                                    <strong>Admitting Provider:</strong>
                                                </div>
                                            </td>
                                            </tr>
                                        <tr>
                                            <td colspan="2">
                                                <div class="FieldData">
                                                    <%= handler.getAdmittingProviderName() %>
                                                </div>
                                            </td>
                                        </tr>
                                        <% }%>
                                         <%
                               String primaryFacility = handler.getPerformingFacilityName();
                               String reportingFacility = handler.getReportingFacilityName();
                               if (!stringIsNullOrEmpty(primaryFacility)) {
                            %>
                                        <tr>

                                            <td colspan="2">
                                                <div class="FieldData">
                                                    <strong>Performing <%=(primaryFacility.equals(reportingFacility) ? "and Reporting" : "")%> Facility:</strong>
                                                </div>
                                            </td>
                                            </tr>
                                        <tr>
                                            <td colspan="2">
                                                <div class="FieldData">
                                                    <%= handler.getPerformingFacilityName() %>
                                                    <%
                                                     address = handler.getPerformingFacilityAddress();
                                                    if (address != null && address.size() > 0) {
                                                    	String city = displayAddressFieldIfNotNullOrEmpty(address, "City", false);
                                                    	String province = displayAddressFieldIfNotNullOrEmpty(address, "Province", false);
                                                    %>
                                                    <br/>
                                                    <strong>Address:</strong><br/>
                                                    <%= displayAddressFieldIfNotNullOrEmpty(address, "Street Address") %>
                                                    <%= displayAddressFieldIfNotNullOrEmpty(address, "Other Designation") %>
                                                    <%= displayAddressFieldIfNotNullOrEmpty(address, "Postal Code") %>
                                                    <%= city + ("".equals(city) || "".equals(province) ? "" : ", ") + province + ("".equals(city) && "".equals(province) ? "" : "<br/>") %>
                                                    <%= displayAddressFieldIfNotNullOrEmpty(address, "Country") %>
                                                    <% } %>
                                                </div>
                                            </td>
                                        </tr>
                                        <% } %>

                                          <%

                               if (!stringIsNullOrEmpty(reportingFacility) && !reportingFacility.equals(primaryFacility)) {
                            %>
                                        <tr>

                                            <td colspan="2">
                                                <div class="FieldData">
                                                    <strong>Reporting Facility:</strong>
                                                </div>
                                            </td>
                                            </tr>
                                        <tr>
                                            <td colspan="2">
                                                <div class="FieldData">
                                                    <%= reportingFacility %>
                                                    <%
                                                     address = handler.getReportingFacilityAddress();
                                                    if (address != null && address.size() > 0) {
                                                    	String city = displayAddressFieldIfNotNullOrEmpty(address, "City", false);
                                                    	String province = displayAddressFieldIfNotNullOrEmpty(address, "Province", false);
                                                    %>
                                                    <br/>
                                                    <strong>Address:</strong><br/>
                                                    <%= displayAddressFieldIfNotNullOrEmpty(address, "Street Address") %>
                                                    <%= displayAddressFieldIfNotNullOrEmpty(address, "Other Designation") %>
                                                    <%= displayAddressFieldIfNotNullOrEmpty(address, "Postal Code") %>
                                                    <%= city + ("".equals(city) || "".equals(province) ? "" : ", ") + province + ("".equals(city) && "".equals(province) ? "" : "<br/>") %>
                                                    <%= displayAddressFieldIfNotNullOrEmpty(address, "Country") %>
                                                    <% } %>
                                                </div>
                                            </td>
                                        </tr>
                                        <% } %>
                                    </table>
                                </td>
                            </tr>
                            <tr>
                                <td align="center" bgcolor="white" colspan="3">
                                    <%String[] multiID = multiLabId.split(",");
                                    ReportStatus report;
                                    boolean startFlag = false;
                                    for (int j=multiID.length-1; j >=0; j--){
                                        ackList = AcknowledgementData.getAcknowledgements(multiID[j]);
                                        if (multiID[j].equals(segmentID))
                                            startFlag = true;
                                        if (startFlag)
                                            if (ackList.size() > 0){{%>
                                                <table width="100%" height="20" cellpadding="2" cellspacing="2">
                                                    <tr>
                                                        <% if (multiID.length > 1){ %>
                                                            <td align="center" bgcolor="white" width="20%" valign="top">
                                                                <div class="FieldData">
                                                                    <b>Version:</b> v<%= j+1 %>
                                                                </div>
                                                            </td>
                                                            <td align="left" bgcolor="white" width="80%" valign="top">
                                                        <% }else{ %>
                                                            <td align="center" bgcolor="white">
                                                        <% } %>
                                                            <div class="FieldData">
                                                                <!--center-->
                                                                    <% for (int i=0; i < ackList.size(); i++) {
                                                                        report = (ReportStatus) ackList.get(i); %>
                                                                        <%= report.getProviderName() %> :

                                                                        <% String ackStatus = report.getStatus();
                                                                            if(ackStatus.equals("A")){
                                                                                ackStatus = "Acknowledged";
                                                                            }else if(ackStatus.equals("F")){
                                                                                ackStatus = "Filed but not Acknowledged";
                                                                            }else{
                                                                                ackStatus = "Not Acknowledged";
                                                                            }
                                                                        %>
                                                                        <font color="red"><%= ackStatus %></font>
                                                                        <% if ( ackStatus.equals("Acknowledged") && report.getComment() != null) { %>
                                                                            <%= report.getTimestamp() %>,
                                                                            <%= ( report.getComment().equals("") ? "" : "comment : "+report.getComment() ) %>
                                                                        <% } %>
                                                                        <br>
                                                                    <% }
                                                                    if (ackList.size() == 0){
                                                                        %><font color="red">N/A</font><%
                                                                    }
                                                                    %>
                                                                <!--/center-->
                                                            </div>
                                                        </td>
                                                    </tr>
                                                </table>

                                            <%}
                                        }
                                    }%>
                                </td>
                            </tr>
                            <tr>
                                <td bgcolor="white" colspan="3">
                                    <table width="100%" border="0" cellpadding="0" cellspacing="0" bordercolor="#CCCCCC">
                                        <tr>
                                            <td bgcolor="white">
                                                <div class="FieldData monospaced">
                                                <% if (handler.isReportBlocked()) { %>
                                                <%
                                                boolean hasBlockedTest=false;
                                                for(int i=0;i<handler.getHeaders().size();i++) {
                                                	int obr = handler.getMappedOBR(i);
                                                	if(handler.isOBRBlocked(obr)) {
                                                		hasBlockedTest=true;
                                                		break;
                                                	}
                                                }
                                                if(hasBlockedTest) {
                                                %>
                                                	<span style="color:red; font-weight:bold">Do Not Disclose Without Explicit Patient Consent</span>
                                                	<br/>
                                                <% } } %>

                                                    <strong>Report Comments: </strong>
                                                </div>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td bgcolor="white" align="left">
                                                <div class="FieldData monospaced" style="width:700px;">

                                                    <% for (int i = 0, j = handler.getReportCommentCount(); i < j; i++) { %>
                                                    <span style="margin-left:15px; width: 700px; word-wrap: break-word;">
                                                    <%= (i > 0 ? "<br/>" : "") + handler.getReportComment(i).replaceAll("(?<=\\s)\\s", "&nbsp;") %>
                                                    </span>
                                                    <span style="margin-left:15px; font-size:8px; color:#333333;">
                                                    <%= handler.getReportSourceOrganization(i) %>
                                                    </span>
                                                    <% } %>
                                                </div>
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                        </table>


                        <% int i=0;

                        int obx = 0;
                        int l=0;
                        int linenum = 0;
                        String highlight = "#E0E0FF";
                        ArrayList headers = handler.getHeaders();
                        int OBRCount = handler.getOBRCount();
                        String category = "";
                        String newCategory = "";

                        int obr;
                        JSONObject obrHeader;
                        for(i=0;i<headers.size();i++) {
                        	obr = handler.getMappedOBR(i);
                        	// Gets the obrHeader JSON related to the current obr
                        	obrHeader = handler.getObrHeader(obr);
                            if (handler.isChildOBR(obr + 1) || (resultObrIndex != null && !resultObrIndex.equals(i))) {
                            	continue;
                            }
                        %>
                        <table style="page-break-inside:avoid;" bgcolor="#003399" border="0" cellpadding="0" cellspacing="0" width="100%" class="monospaced">
                            <%
                            	newCategory = handler.getOBRCategory(obr);
                            	if (!category.equals(newCategory)) {
                            		if (i > 0) {
                            		%>
                            <tr>
                                <td colspan="4" height="7">&nbsp;</td>
                            </tr>
                            <%
                            		}
                         	%>

                        	<tr>
                        		 <td colspan="4" align="center" bgcolor="#FFCC00"><span style="font-size: large;"><%=newCategory%></span><td>
                        	</tr>
                            		<%
                            	}
                            	category = newCategory;
                            %>
                            <tr>
                                <td colspan="4" height="7">&nbsp;</td>
                            </tr>
                            <tr>
                                <td bgcolor="#FFCC00" colspan="2">
                                    <%
                                        // Gets information needed for the specimen/collection table and prints it out in table format
                                        String collectionDateTime = handler.getCollectionDateTime(obr);
                                        String specimenCollectedBy = handler.getSpecimenCollectedBy(obr);
                                        String collectionVolume = handler.getCollectionVolume(obr);
                                        String noOfSampleContainers = handler.getNoOfSampleContainers(obr);
                                        String siteModifier = obrHeader.getString(OLISHL7Handler.OBR_SITE_MODIFIER);
                                        
                                        String specimenReceivedDate = obrHeader.getString(OLISHL7Handler.OBR_SPECIMEN_RECEIVED_DATETIME);
                                        specimenReceivedDate = specimenReceivedDate.equals(specimenReceived) ? "" : specimenReceivedDate;
                                    %>
                                    <table width="100%">
                                        <tr>
                                            <th width="30%"> Specimen Type: </th>
                                            <th width="30%"><%= !stringIsNullOrEmpty(collectionDateTime) ? "Collection Date/Time" : "" %></th>
                                            <th width="30%"><%= !stringIsNullOrEmpty(specimenCollectedBy) ? "Specimen Collected By" : "" %></th>
                                        </tr>
                                        <tr>
                                            <td align="center"><%= obrHeader.getString(OLISHL7Handler.OBR_SPECIMEN_TYPE) %></td>
                                            <td align="center"><%=collectionDateTime%></td>
                                            <td align="center"><%=specimenCollectedBy%></td>
                                        </tr>
                                        <% if (!siteModifier.isEmpty()) { %>
                                        <tr>
                                            <th width="33%">Site Modifier</th>
                                        </tr>
                                        <tr>
                                            <td align="center"><%= siteModifier %></td>
                                        </tr>
                                        <% } %>
                                        <tr>
                                            <th width="30%"><%= !stringIsNullOrEmpty(collectionVolume) ? "Collection Volume" : "" %></th>
                                            <th width="30%"><%= !stringIsNullOrEmpty(noOfSampleContainers) ? "No. of Sample Containers" : "" %></th>
                                            <th width="30%"><%= !specimenReceivedDate.isEmpty() ? "Specimen Received Date/Time" : "" %></th>
                                        </tr>
                                        <tr>
                                            <td align="center"><%=collectionVolume%></td>
                                            <td align="center"><%=noOfSampleContainers%></td>
                                            <td align="center"><%=specimenReceivedDate%></td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                            <%
                                String collectorsComment = handler.getCollectorsComment(obr);
                                if (collectorsComment != null && !collectorsComment.equals("")) {
                            %>
                            
                            <tr>
                                <td valign="top" bgcolor="#FFCC00" align="left" colspan="2">
                                    <table>
                                        <tr>
                                            <th style="text-align: left; padding-left: 10px">Collector's Comment</th>
                                        </tr>
                                        <tr>
                                            <td>
                                                <div style="margin-left: 15px; width:700px">
                                                    <%=handler.formatString(collectorsComment).replaceAll("(?<=\\s)\\s", "&nbsp;")%>
                                                </div>
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                            <% } 
                                
                                String performingFacility = handler.getOBRPerformingFacilityName(obr);
                                if (!primaryFacility.equals(performingFacility) && !performingFacility.equals("")) {

                            %>
                                        <tr>
                                            <td bgcolor="#FFCC00">
                                                <div class="FieldData">
                                                    <strong>Performing Facility:</strong>
                                                </div>
                                            </td>
                                            <td  bgcolor="#FFCC00">
                                                <div class="FieldData">
                                                  <strong>Address:</strong><br/>
                                                </div>
                                            </td>
                                        </tr>
                                        <tr>
                                        	<td bgcolor="#FFCC00" valign="top">
                                        		<div class="FieldData">
                                        			  <%= performingFacility %>
                                                </div>
                                            </td>
                                            <td bgcolor="#FFCC00" valign="top">
                                        		<div class="FieldData">
													<%
                                                    address = handler.getPerformingFacilityAddress(obr);
                                                    if (address != null && address.size() > 0) {
                                                    	String city = displayAddressFieldIfNotNullOrEmpty(address, "City", false);
                                                    	String province = displayAddressFieldIfNotNullOrEmpty(address, "Province", false);
                                                    %>
                                                    <%= displayAddressFieldIfNotNullOrEmpty(address, "Street Address") %>
                                                    <%= displayAddressFieldIfNotNullOrEmpty(address, "Other Designation") %>
                                                    <%= displayAddressFieldIfNotNullOrEmpty(address, "Postal Code") %>
                                                    <%= city + ("".equals(city) || "".equals(province) ? "" : ", ") + province + ("".equals(city) && "".equals(province) ? "" : "<br/>") %>
                                                    <%= displayAddressFieldIfNotNullOrEmpty(address, "Country") %>
                                                    <% } %>
                                                </div>
                                            </td>
                                        </tr>
                                        <% } %>
                        </table>

                        <table width="100%" border="0" cellspacing="0" cellpadding="2" 
							   bgcolor="#CCCCFF" bordercolor="#9966FF" bordercolordark="#bfcbe3" name="tblDiscs" id="tblDiscs"
								class="monospaced">
                            <tr class="Field2">
                                <td width="35%" align="middle" valign="bottom" class="Cell"><bean:message key="oscarMDS.segmentDisplay.formTestName"/></td>
                                <td width="30%" align="middle" valign="bottom" class="Cell"><bean:message key="oscarMDS.segmentDisplay.formResult"/></td>
                                <td width="5%" align="middle" valign="bottom" class="Cell"><bean:message key="oscarMDS.segmentDisplay.formAbn"/></td>
                                <td width="20%" align="middle" valign="bottom" class="Cell"><bean:message key="oscarMDS.segmentDisplay.formReferenceRange"/></td>
                                <td width="10%" align="middle" valign="bottom" class="Cell"><bean:message key="oscarMDS.segmentDisplay.formUnits"/></td>
                            </tr>
                            <tr bgcolor="<%=(linenum % 2 == 1 ? highlight : "")%>">
                                <td valign="top" colspan="5">
                                    <div class="Title2">
                                        <%=headers.get(obr)%> <span <%= !handler.isObrStatusFinal(obr) ? "style=\"color: red\"" : "" %>><%= " (" +handler.getObrStatus(obr) + ")"%></span>
                                        <%
                                            String poc = handler.getPointOfCare(obr);
                                            if (!stringIsNullOrEmpty(poc)) {
                                        %>
                                        <br/>
                                        <span style="font-size:9px; color:#333333;">(Test performed at point of care)</span>
                                        <% } %>
                                        <%
                                            boolean blocked = handler.isOBRBlocked(obr);
                                            if (blocked) {
                                        %>
                                        <span style="font-size:9px; color:red;">(Do Not Disclose Without Explicit Patient Consent)</span>
                                        <% } %>
                                    </div>
                                </td>
                            </tr>
                            <%
                                boolean obrFlag = false;
                                int obxCount = handler.getOBXCount(obr);

                                if (handler.getObservationHeader(obr, 0).equals(headers.get(obr))) {
                                	int cc = handler.getOBRCommentCount(obr);
                                	for (int comment = 0; comment < cc; comment++){
                                    // the obrName should only be set if it has not been
                                    // set already which will only have occured if the
                                    // obx name is "" or if it is the same as the obr name
                                    String obxNN = handler.getOBXName(obr,0);
                                    
                                    if(!obrFlag && obxNN.equals("")){
										linenum++; %>
                                        <tr bgcolor="<%=(linenum % 2 == 1 ? highlight : "")%>" >
                                            <td valign="top" align="left"><%=handler.getOBRName(comment)%></td>
                                            <td valign="top" align="left"><%=handler.getObrSpecimenSource(comment) %></td>
                                            <td colspan="3">&nbsp;</td>
                                        </tr>
                                        <%obrFlag = true;
                                    }

                                    String obrComment = handler.getOBRComment(obr, comment);
                                    String sourceOrg = handler.getOBRSourceOrganization(obr, comment);
                                    %>
                                <tr bgcolor="<%=(linenum % 2 == 1 ? highlight : "")%>" class="NormalRes">
                                    <td valign="top" align="left" colspan="5">
                                    <div  style="margin-left:15px;width: 700px;">
                                    	<%=obrComment.replaceAll("(?<=\\s)\\s", "&nbsp;")%>
                                    	<span style="margin-left:15px;font-size:8px; color:#333333;"><%=sourceOrg%></span>
                                   	</div>
                                    </td>
                                </tr>
                                <%

                                }//end for k=0
                            	}//end if handler.getObservation..
                                
                                String diagnosis = handler.getDiagnosis(obr);
                                if (!stringIsNullOrEmpty(diagnosis)) {
                                %>
                                <tr bgcolor="<%=(linenum % 2 == 1 ? highlight : "")%>">
                                    <td colspan="5" style="padding-top: 10px;">
                                        <div class="FieldData">
                                            <strong>Diagnosis:</strong> <%=diagnosis%>
                                        </div>
                                    </td>
                                </tr>
                            <% }

                                for (int k=0; k < obxCount; k++){
									linenum++;
                                	obx = handler.getMappedOBX(obr, k);
                                    String obxName = handler.getOBXName(obr, obx);
                                    boolean b1=false, b2=false, b3=false;

                                    boolean fail = true;
                                    try {
                                    b1 = !handler.getOBXResultStatus(obr, obx).equals("DNS");
                                    b2 = !obxName.equals("");
                                    String currheader = (String) headers.get(obr);
                                    String obsHeader = handler.getObservationHeader(obr, obx);
                                    b3 = handler.getObservationHeader(obr, obx).equals(headers.get(obr));
                                    fail = false;





                                    } catch (Exception e){
                                    	//logger.info("ERROR :"+e);
                                    }


                                    if (!fail && b1 && b2 && b3){ // <<--  DNS only needed for MDS messages
                                        String obrName = handler.getOBRName(obr);
                                    	b1 = !obrFlag && !obrName.equals("");
                                    	b2 = !(obxName.contains(obrName));
                                    	b3 = obxCount < 2;
                                        if( b1 && b2 && b3){
                                        %>
                                        	<%--
                                            <tr bgcolor="<%=(linenum % 2 == 1 ? highlight : "")%>" >
                                                <td valign="top" align="left"><%=obrName%></td>
                                                <td colspan="6">&nbsp;</td>
                                            </tr>
                                             --%>
                                            <%
                                            obrFlag = true;

                                        }

                                        String status = handler.getOBXResultStatus(obr, obx).trim();
                                        String statusMsg;
                                        try {
                                        	 statusMsg = handler.getTestResultStatusMessage(handler.getOBXResultStatus(obr, obx).charAt(0));
                                        }
                                        catch (Exception e) {
                                        	statusMsg = "";
                                        }
                                        boolean strikeout = status != null && status.startsWith("W");
                                        String pre = "<u>";
                                        String post = "</u>";
                                        String obxDisplayName = "";
                                        if (strikeout) {
											pre = "<s>" + pre;
											post = post + "</s>";
                                        }
                                        String abnormalNature = handler.getNatureOfAbnormalTest(obr, obx);
                                        if (!stringIsNullOrEmpty(abnormalNature)) {
                                        	abnormalNature = " <span style=\"font-size:8px; color:#333333;\">"+abnormalNature+"</span>";
                                        }
                                        obxDisplayName = pre + obxName + post + abnormalNature;

                                        String lineClass = "NormalRes";
                                        String abnormal = handler.getOBXAbnormalFlag(obr, obx);
                                        if ( abnormal != null && (abnormal.startsWith("L") ||  abnormal.equals("A") || abnormal.startsWith("H") || handler.isOBXAbnormal(obr, obx) ) ){
                                            lineClass = "AbnormalRes";
                                        }
                                        String obxValueType = handler.getOBXValueType(obr,obx).trim();

                                        if (obxValueType.equals("ST") &&  handler.renderAsFT(obr,obx)) {
                                        	obxValueType = "FT";
                                        } else if (obxValueType.equals("TX") && handler.renderAsNM(obr,obx)) {
                                        	obxValueType = "NM";
                                        } else if (obxValueType.equals("FT") && handler.renderAsNM(obr,obx)) {
                                        	obxValueType = "NM";
                                        }

                                        if (obxValueType.equals("NM") 		// Numeric
                                        	|| obxValueType.equals("ST")) { // String Data
                                        	if (handler.isAncillary(obr,obx)) { %>
                                            <tr bgcolor="<%=(linenum % 2 == 1 ? highlight : "")%>" class="<%=lineClass%>">
                                                <td><div class="FieldData"><strong>Patient Observation</strong></div></td>
                                                <td colspan="4">
                                                    <a href="javascript:popupStart('660','900','../ON/labValues.jsp?testName=<%=obxName%>&demo=<%=demographicID%>&labType=HL7&identifier='+encodeURIComponent('<%= handler.getOBXIdentifier(obr, obx)%>'))">
                                                        <%=obxDisplayName %>
                                                    </a>
                                                    <%= statusMsg.isEmpty() ? "" : "(<font color=\"red\">" + statusMsg + "</font>)" %>
                                                </td>
                                           	</tr>
                                            <tr bgcolor="<%=(linenum % 2 == 1 ? highlight : "")%>" class="<%=lineClass%>">
                                                <td><div class="FieldData"><strong>Result:</strong></div></td>
                                                <td align="left" colspan="4"><%= strikeOutInvalidContent(handler.getOBXResult(obr, obx), status) %></td>
                                            </tr>
                                            <tr bgcolor="<%=(linenum % 2 == 1 ? highlight : "")%>" class="<%=lineClass%>">
                                                <td><div class="FieldData"><strong>Flag:</strong></div></td>
                                                <td align="left" colspan="4"><%= strikeOutInvalidContent(handler.getOBXAbnormalFlag(obr, obx), status)%></td>
                                            </tr>
                                            <tr bgcolor="<%=(linenum % 2 == 1 ? highlight : "")%>" class="<%=lineClass%>">
                                                <td><div class="FieldData"><strong>Reference Range:</strong></div></td>
                                                <td align="left" colspan="4"><%=strikeOutInvalidContent(handler.getOBXReferenceRange(obr, obx), status)%></td>
                                            </tr>
                                            <tr bgcolor="<%=(linenum % 2 == 1 ? highlight : "")%>" class="<%=lineClass%>">
                                                <td><div class="FieldData"><strong>Units:</strong></div></td>
                                                <td align="left" colspan="4"><%=strikeOutInvalidContent(handler.formatString(handler.getOBXUnits(obr, obx)), status) %></td>
                                            </tr>
                                            <tr bgcolor="<%=(linenum % 2 == 1 ? highlight : "")%>" class="<%=lineClass%>">
                                                <td><div class="FieldData"><strong>Observation Date/Time:</strong></div></td>
                                                <td align="left" colspan="4"><%=strikeOutInvalidContent(handler.getOBXObservationDate(obr, obx), status) %></td>
                                            </tr>
                                            
                                            <% } else { %>
                                            <tr bgcolor="<%=(linenum % 2 == 1 ? highlight : "")%>" class="<%=lineClass%>">
                                                <td valign="top" align="leftZOR"><%= obrFlag ? "&nbsp; &nbsp; &nbsp;" : "&nbsp;" %><a href="javascript:popupStart('660','900','../ON/labValues.jsp?testName=<%=obxName%>&demo=<%=demographicID%>&labType=HL7&identifier='+encodeURIComponent('<%= handler.getOBXIdentifier(obr, obx)%>'))"><%=obxDisplayName %></a>
                                                    <%= statusMsg.isEmpty() ? "" : "(<font color=\"red\">" + statusMsg + "</font>)" %>
                                                </td>
                                                <td align="right"><%= strikeOutInvalidContent(handler.getOBXResult(obr, obx), status) %></td>
                                                <td align="center">
                                                        <%= strikeOutInvalidContent(handler.getOBXAbnormalFlag(obr, obx), status)%>
                                                </td>
                                                <td align="left"><%=strikeOutInvalidContent(handler.getOBXReferenceRange(obr, obx), status)%></td>
                                                <td align="left"><%=strikeOutInvalidContent(handler.formatString(handler.getOBXUnits(obr, obx)), status) %></td>
                                            </tr>
                                            <% }
                                        } else if (obxValueType.equals("SN")) { // or Structured Numeric
	                                              %>
	                                              <tr bgcolor="<%=(linenum % 2 == 1 ? highlight : "")%>" class="<%=lineClass%>">
	                                                  <td valign="top" align="leftZOR"><%= obrFlag ? "&nbsp; &nbsp; &nbsp;" : "&nbsp;" %><a href="javascript:popupStart('660','900','../ON/labValues.jsp?testName=<%=obxName%>&demo=<%=demographicID%>&labType=HL7&identifier='+encodeURIComponent('<%= handler.getOBXIdentifier(obr, obx)%>'))"><%=obxDisplayName %></a>
                                                          <%= statusMsg.isEmpty() ? "" : "(<font color=\"red\">" + statusMsg + "</font>)" %>
                                                      </td>
	                                                  <td align="right"><%= strikeOutInvalidContent(handler.getOBXSNResult(obr, obx), status) %></td>
	                                                  <td align="center">
	                                                          <%= strikeOutInvalidContent(handler.getOBXAbnormalFlag(obr, obx), status)%>
	                                                  </td>
	                                                  <td align="left"><%=strikeOutInvalidContent(handler.getOBXReferenceRange(obr, obx), status)%></td>
	                                                  <td align="left"><%=strikeOutInvalidContent(handler.getOBXUnits(obr, obx), status) %></td>
	                                              </tr>
	                                              <%
                                        } else if (obxValueType.equals("TX") // Text Data (Display)
		                                        || obxValueType.equals("FT")) {  // Formatted Text (Display)
                                        	%>
                                        	<tr  bgcolor="<%=(linenum % 2 == 1 ? highlight : "")%>" class="<%=lineClass%>">
                                        		<td align="left" colspan="5"><b><%= obxDisplayName %></b>
                                                    <%= statusMsg.isEmpty() ? "" : "(<font color=\"red\">" + statusMsg + "</font>)" %>
                                                </td>
                                        	</tr>
                                        	<tr  bgcolor="<%=(linenum % 2 == 1 ? highlight : "")%>" class="<%=lineClass%>">
                                                <td align="left" colspan="5">
                                                    <b><%= handler.formatString(handler.getOBXResult(obr, obx)).replaceAll("(?<=\\s)\\s", "&nbsp;") %></b>
                                                </td>
                                        	</tr>
                                        	<%

										} else if (obxValueType.equals("TM")) { // Time
											%>
                                            <tr bgcolor="<%=(linenum % 2 == 1 ? highlight : "")%>" class="<%=lineClass%>">
                                                <td valign="top" align="leftZOR"><%= obrFlag ? "&nbsp; &nbsp; &nbsp;" : "&nbsp;" %><a href="javascript:popupStart('660','900','../ON/labValues.jsp?testName=<%=obxName%>&demo=<%=demographicID%>&labType=HL7&identifier='+encodeURIComponent('<%= handler.getOBXIdentifier(obr, obx)%>'))"><%=obxDisplayName %></a>
                                                    <%= statusMsg.isEmpty() ? "" : "(<font color=\"red\">" + statusMsg + "</font>)" %>
                                                </td>
                                                <td align="right"><%= strikeOutInvalidContent(handler.getOBXTMResult(obr, obx), status) %></td>
                                                <td align="center" colspan="3"></td>
                                            </tr>
                                            <%
										} else if (obxValueType.equals("DT")) { // Date
											%>
                                            <tr bgcolor="<%=(linenum % 2 == 1 ? highlight : "")%>" class="<%=lineClass%>">
                                                <td valign="top" align="leftZOR"><%= obrFlag ? "&nbsp; &nbsp; &nbsp;" : "&nbsp;" %><a href="javascript:popupStart('660','900','../ON/labValues.jsp?testName=<%=obxName%>&demo=<%=demographicID%>&labType=HL7&identifier='+encodeURIComponent('<%= handler.getOBXIdentifier(obr, obx)%>'))"><%=obxDisplayName %></a>
                                                    <%= statusMsg.isEmpty() ? "" : "(<font color=\"red\">" + statusMsg + "</font>)" %>
                                                </td>
                                                <td align="right"><%= strikeOutInvalidContent(handler.getOBXDTResult(obr, obx), status) %></td>
                                                <td align="center" colspan="3"></td>
                                            </tr>
                                            <%
										} else if (obxValueType.equals("TS")) { // Time Stamp (Date & Time)
											%>
                                            <tr bgcolor="<%=(linenum % 2 == 1 ? highlight : "")%>" class="<%=lineClass%>">
                                                <td valign="top" align="leftZOR"><%= obrFlag ? "&nbsp; &nbsp; &nbsp;" : "&nbsp;" %><a href="javascript:popupStart('660','900','../ON/labValues.jsp?testName=<%=obxName%>&demo=<%=demographicID%>&labType=HL7&identifier='+encodeURIComponent('<%= handler.getOBXIdentifier(obr, obx)%>'))"><%=obxDisplayName %></a>
                                                    <%= statusMsg.isEmpty() ? "" : "(<font color=\"red\">" + statusMsg + "</font>)" %>
                                                </td>
                                                <td align="right"><%= strikeOutInvalidContent(handler.getOBXTSResult(obr, obx), status) %></td>
                                                <td align="center" colspan="3"></td>
                                            </tr>
                                            <%
   										} else if (obxValueType.equals("ED")) { // Encapsulated Data
   											%>
   											<tr bgcolor="<%=(linenum % 2 == 1 ? highlight : "")%>" class="<%=lineClass%>">
												<td colspan="5" valign="top" align="leftZOR"><%= obrFlag ? "&nbsp; &nbsp; &nbsp;" : "&nbsp;" %><a href="javascript:popupStart('660','900','../ON/labValues.jsp?testName=<%=obxName%>&demo=<%=demographicID%>&labType=HL7&identifier='+encodeURIComponent('<%= handler.getOBXIdentifier(obr, obx)%>'))"><%=obxDisplayName %></a>
                                                    <%= statusMsg.isEmpty() ? "" : "(<font color=\"red\">" + statusMsg + "</font>)" %>
                                                </td>
   											</tr>
   											<tr bgcolor="<%=(linenum % 2 == 1 ? highlight : "")%>" class="<%=lineClass%>">
   											<%if(!preview) { %>
   												<td colspan="3" valign="left"><a href="PrintOLIS.do?segmentID=<%=segmentID%>&obr=<%=obr%>&obx=<%=obx%>" style="margin-left: 30px;">Click to view attachment.</a>
   											<% } else { %>
   												<td colspan="3" valign="left"><a href="PrintOLIS.do?uuid=<%=oscar.Misc.getStr(request.getParameter("uuid"), "")%>&obr=<%=obr%>&obx=<%=obx%>" style="margin-left: 30px;">Click to view attachment.</a>   											
   											<% } %>
   												</td>
   												<td align="left" colspan="2"><%=strikeOutInvalidContent(handler.getOBXUnits(obr, obx), status) %></td>
   											</tr>
   											<%
   										} else if (obxValueType.equals("CE")) { // Coded Entry

   											%>
   											<tr bgcolor="<%=(linenum % 2 == 1 ? highlight : "")%>" class="<%=lineClass%>">
												<td colspan="5" valign="top" align="leftZOR"><%= obrFlag ? "&nbsp; &nbsp; &nbsp;" : "&nbsp;" %><a href="javascript:popupStart('660','900','../ON/labValues.jsp?testName=<%=obxName%>&demo=<%=demographicID%>&labType=HL7&identifier='+encodeURIComponent('<%= handler.getOBXIdentifier(obr, obx)%>'))"><%=obxDisplayName %></a>
                                                    <%= statusMsg.isEmpty() ? "" : "(<font color=\"red\">" + statusMsg + "</font>)" %>
                                                </td>
   											</tr>
   											<tr bgcolor="<%=(linenum % 2 == 1 ? highlight : "")%>" class="<%=lineClass%>">
   												<td colspan="5" valign="left"><span  style="margin-left:15px;"><%=handler.getOBXCEName(obr,obx) %></span></td>
   											</tr>
   											<%
   											if (handler.isStatusFinal(handler.getOBXResultStatus(obr, obx).charAt(0))) {
  												String parentId = handler.getOBXCEParentId(obr, obx);
  												if (!stringIsNullOrEmpty(parentId)) {
   											%>
   											<tr bgcolor="<%=(linenum % 2 == 1 ? highlight : "")%>" class="<%=lineClass%>">
   												<td colspan="5" align="center">
   													<table style="border: 1px solid black; margin-left 30px;">
   														<tr><th>Name</th><th>Result</th> </tr>
   												    <%

   												    int childOBR = handler.getChildOBR(parentId) - 1;
   												    if (childOBR != -1) {
	   												    int childLength = handler.getOBXCount(childOBR);
	   												    for (int ceIndex = 0; ceIndex < childLength; ceIndex++) {
	   												    	String ceStatus = handler.getOBXResultStatus(childOBR, ceIndex).trim();
	   	   			                                        boolean ceStrikeout = ceStatus != null && ceStatus.startsWith("W");
	   	   			                                        String ceName = handler.getOBXName(childOBR,ceIndex);
	   	   			                                        ceName = ceStrikeout ? "<s>" + ceName + "</s>" : ceName;
	   	   			                                        String ceSense = handler.getOBXCESensitivity(childOBR,ceIndex);
	   	   			                                        ceSense = ceStrikeout ? "<s>" + ceSense + "</s>" : ceSense;
	   												    	%><tr><td><%=ceName%></td><td align="center"><%=ceSense%></td></tr><%
	   													}
   												    }
   													%>
   													</table>
   												</td>
  											</tr>
   											<% 		if (category.toUpperCase().trim().equals("MICROBIOLOGY")) {%>
   											<tr bgcolor="<%=(linenum % 2 == 1 ? highlight : "")%>" class="<%=lineClass%>">
   												<td align="center" colspan="5">
   														S=Sensitive R=Resistant I=Intermediate MS=Moderately Sensitive VS=Very Sensitive

   												</td>
   											</tr>
											<%
													}
  												}
   											}
                                        } else {
                                        	%>
                                            <tr bgcolor="<%=(linenum % 2 == 1 ? highlight : "")%>" class="<%=lineClass%>">
                                                <td valign="top" align="leftZOR"><%= obrFlag ? "&nbsp; &nbsp; &nbsp;" : "&nbsp;" %><a href="javascript:popupStart('660','900','../ON/labValues.jsp?testName=<%=obxName%>&demo=<%=demographicID%>&labType=HL7&identifier='+encodeURIComponent('<%= handler.getOBXIdentifier(obr, obx)%>'))"><%=obxDisplayName %></a>
                                                    <%= statusMsg.isEmpty() ? "" : "(<font color=\"red\">" + statusMsg + "</font>)" %>
                                                </td>
                                                <td align="right"><%= strikeOutInvalidContent(handler.getOBXResult(obr, obx), status) %></td>
                                                <td align="center">
                                                        <%= strikeOutInvalidContent(handler.getOBXAbnormalFlag(obr, obx), status)%>
                                                </td>
                                                <td align="left"><%=strikeOutInvalidContent(handler.getOBXReferenceRange(obr, obx), status)%></td>
                                                <td align="left"><%=strikeOutInvalidContent(handler.getOBXUnits(obr, obx), status) %></td>
                                            </tr>
                                            <%
                                        }
                                        String obsMethod = handler.getOBXObservationMethod(obr, obx);
                                        if (obsMethod != null && (obsMethod = obsMethod.trim()).length() > 0) {
                                        	%>
                                        	<tr bgcolor="<%=(linenum % 2 == 1 ? highlight : "")%>" class="NormalRes">
                                                <td valign="top" align="left" colspan="5"><span style="margin-left:15px;">Observation Method: <%=obsMethod%></span></td>
                                            </tr>
                                        	<%
                                        }
                                        String obsDate = handler.getOBXObservationDate(obr, obx);
                                        if (obsDate != null && (obsDate = obsDate.trim()).length() > 0 && !handler.isAncillary(obr, obx)) {
                                        	%>
                                        	<tr bgcolor="<%=(linenum % 2 == 1 ? highlight : "")%>" class="NormalRes">
                                                <td valign="top" align="left" colspan="5"><span style="margin-left:15px;">Observation Date: <%=obsDate%></span></td>
                                            </tr>
                                        	<%
                                        }
                                        for (l=0; l < handler.getOBXCommentCount(obr, obx); l++){%>
                                            <tr bgcolor="<%=(linenum % 2 == 1 ? highlight : "")%>" class="NormalRes">
                                                <td valign="top" align="left" colspan="5" style="font-family:courier;">
                                                <div style="width:700px">
                                                	<%=handler.getOBXComment(obr, obx, l)%><span style="margin-left:15px;font-size:8px; color:#333333;word-break:normal;"><%=handler.getOBXSourceOrganization(obr, obx, l)%></span>
                                                </div>
                                                </td>
                                            </tr>
                                        <%}
                                    }
                                }
                            //}

                            String obsHeader = handler.getObservationHeader(obr, 0);
                            String headr = (String) headers.get(i);

                            //for ( j=0; j< OBRCount; j++){

                            //} //end for j=0; j<obrCount;
                            %>
                        </table>
                        <% // end for headers
                        }  // for i=0... (headers) line 625 %>

                        <% 
                            List<HashMap<String, String>> formattedDoctors = handler.getFormattedCcDocs();
                            int cellCount = 0;
                        %>
                <table style="width: 100%;">
                    <tr>
                        <td colspan="3" class="Cell"><div class="Field2">CC List</div></td>
                    </tr>
                    <tr>
                        <% for (HashMap<String, String> doctorMap : formattedDoctors) {
                            cellCount++;
                        %>
                        
                        <td bgcolor="white">
                            <table width="100%" border="0" cellpadding="0" cellspacing="0" bordercolor="#CCCCCC">
                                <tr>
                                    <td bgcolor="white" style="width:30%">
                                        <div class="FieldData" style="font-weight: bold">
                                            Name:
                                        </div>
                                    </td>
                                    <td bgcolor="white">
                                        <div class="FieldData">
                                            <%= doctorMap.get("name") %>
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td bgcolor="white" style="width:30%; padding-bottom:5px;" >
                                        <div class="FieldData" style="font-weight: bold">
                                            <%= doctorMap.get("licenceType") %> #:
                                        </div>
                                    </td>
                                    <td bgcolor="white" style="padding-bottom:5px;">
                                        <div class="FieldData">
                                            <%= doctorMap.get("licenceNumber") %>
                                        </div>
                                    </td>
                                </tr>
                            </table>
                        </td>
                            <% if (cellCount % 3 == 0) {%>
                    </tr>
                    <tr style="margin-top: 5px;">
                            <% } %>
                        <% } %>
                    </tr>
                    <tr>
                        <td class="Cell"><div class="Field2">Ordering Facility</div></td>
                        <td class="Cell"><div class="Field2">Admitting Provider</div></td>
                        <td class="Cell"><div class="Field2">Attending Provider</div></td>
                    </tr>
                    <tr>
                        <td>
                            <%=handler.getOrderingFacilityName()%> <span style="font-size: 8px; color: #333333;"><%= handler.getOrderingFacilityOrganization()%></span><br />
                            <%
                                address = handler.getOrderingFacilityAddress();
                                if (address != null && address.size() > 0) {
                                    String city = displayAddressFieldIfNotNullOrEmpty(address, "City", false);
                                    String province = displayAddressFieldIfNotNullOrEmpty(address, "Province", false);
                            %>
                            <br/>
                            <table>
                                <tr>
                                    <td style="vertical-align: top;">
                                        <strong>Address:</strong>
                                    </td>
                                    <td>
                                        <%= displayAddressFieldIfNotNullOrEmpty(address, "Street Address") %>
                                        <%= displayAddressFieldIfNotNullOrEmpty(address, "Other Designation") %>
                                        <%= displayAddressFieldIfNotNullOrEmpty(address, "Postal Code", false) %>
                                        <%= city + ("".equals(city) || "".equals(province) ? "" : ", ") + province %>
                                        <%= displayAddressFieldIfNotNullOrEmpty(address, "Country", false) %>
                                    </td>
                                </tr>
                            </table>
                            <%  } %>
                        </td>
                        <td style="vertical-align: top">
                            <% HashMap<String, String> doctorMap = handler.parseDoctor(handler.getAdmittingProviderName()); %>
                            <table>
                                <tr>
                                    <td><strong>Name:</strong></td>
                                    <td><%=doctorMap.get("name")%></td>
                                </tr>
                                <tr>
                                    <td><strong><%=doctorMap.get("licenceType")%> #:</strong></td>
                                    <td><%=doctorMap.get("licenceNumber")%></td>
                                </tr>
                            </table>
                        </td>
                        <td style="vertical-align: top">
                            <% doctorMap = handler.parseDoctor(handler.getAttendingProviderName()); %>
                            <table>
                                <tr>
                                    <td><strong>Name:</strong></td>
                                    <td><%=doctorMap.get("name")%></td>
                                </tr>
                                <tr>
                                    <td><strong><%=doctorMap.get("licenceType")%> #:</strong></td>
                                    <td><%=doctorMap.get("licenceNumber")%></td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                </table>
                        
                        <table width="100%" border="0" cellspacing="0" cellpadding="3" class="MainTableBottomRowRightColumn" bgcolor="#003399">
                            <tr>
                                <td align="left" width="50%">
                                    <% if ( providerNo != null /*&& ! mDSSegmentData.getAcknowledgedStatus(providerNo) */) { %>
                                    <input type="submit" value="<bean:message key="oscarMDS.segmentDisplay.btnAcknowledge"/>" onclick="getComment()">
                                    <% } %>
                                    <input type="button" class="smallButton" value="<bean:message key="oscarMDS.index.btnForward"/>" onClick="popupStart(397, 700, '../../../oscarMDS/SelectProvider.jsp?docId=<%=segmentID%>&labDisplay=true', 'providerselect')">
                                    <input type="button" value=" <bean:message key="global.btnClose"/> " onClick="window.close()">
                                    <input type="button" value=" <bean:message key="global.btnPrint"/> " onClick="printPDF()">
									<input type="button" value="Print with Attachments" onClick="printPDF(true)">
                                        <indivo:indivoRegistered demographic="<%=demographicID%>" provider="<%=providerNo%>">
                                        <input type="button" value="<bean:message key="global.btnSendToPHR"/>" onClick="sendToPHR('<%=segmentID%>', '<%=demographicID%>')">
                                        </indivo:indivoRegistered>
                                    <% if ( searchProviderNo != null && demographicID != null) { // we were called from e-chart %>
                                    <input type="button" value=" <bean:message key="oscarMDS.segmentDisplay.btnEChart"/> " onClick="popupStart(710,1024, '/oscar/oscarEncounter/IncomingEncounter.do?providerNo=<%=providerNo%>&appointmentNo=&demographicNo=<%=demographicID%>&curProviderNo=&reason=Lab%20Results&encType=&curDate=<%=curYear%>-<%=curMonth%>-<%=curDay%>&appointmentDate=&startTime=&status='
                                            +'&curDate=<%=curYear%>-<%=curMonth%>-<%=curDay%>&appointmentDate=&startTime=&status=')">
                                    <% } %>
                                </td>
                                <td width="50%" valign="center" align="left">
                                    <span class="Field2"><i><bean:message key="oscarMDS.segmentDisplay.msgReportEnd"/></i></span>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <% if (obgynShortcuts) {%>
                <tr>
                    <td>
                        <input type="button" value="AR1-ILI" onClick="popupONAREnhanced(290, 625, '<%=request.getContextPath()%>/form/formonarenhancedForm.jsp?demographic_no=<%=demographicID%>&formId=<%=formId%>&section='+this.value)" />
                        <input type="button" value="AR1-PGI" onClick="popupONAREnhanced(225, 590,'<%=request.getContextPath()%>/form/formonarenhancedForm.jsp?demographic_no=<%=demographicID%>&formId=<%=formId%>&section='+this.value)" />
                        <input type="button" value="AR2-US" onClick="popupONAREnhanced(395, 655, '<%=request.getContextPath()%>/form/formonarenhancedForm.jsp?demographic_no=<%=demographicID%>&formId=<%=formId%>&section='+this.value)" />
                        <input type="button" value="AR2-ALI" onClick="popupONAREnhanced(375, 430, '<%=request.getContextPath()%>/form/formonarenhancedForm.jsp?demographic_no=<%=demographicID%>&formId=<%=formId%>&section='+this.value)" />
                        <input type="button" value="AR2" onClick="popupPage(700, 1024, '<%=request.getContextPath()%>/form/formonarenhancedpg2.jsp?demographic_no=<%=demographicID%>&formId=<%=formId%>&update=true')" />

                    </td>
                </tr>
                <% } %>
            </table>

        </form>
    </body>
</html>
