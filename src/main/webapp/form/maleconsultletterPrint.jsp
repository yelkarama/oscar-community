<%--

    Copyright (c) 2001-2002. Department of Family Medicine, McMaster University. All Rights Reserved.
    This software is published under the GPL GNU General Public License.
    This program is free software; you can redistribute it and/or
    modify it under the terms of the GNU General Public License
    as published by the Free Software Foundation; either version 2
    of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.

    This software was written for the
    Department of Family Medicine
    McMaster University
    Hamilton
    Ontario, Canada

--%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
"http://www.w3.org/TR/html4/loose.dtd">
 
<%@page import="oscar.oscarDemographic.data.EctInformation"%>
<%@page import="oscar.oscarDemographic.data.RxInformation"%>
<%@page import="org.oscarehr.common.model.Demographic"%>
<%@page import="java.util.Vector"%>
<%@page import="java.util.StringTokenizer"%>
<%@page import="oscar.oscarClinic.ClinicData"%>
<%@page import="oscar.oscarProvider.data.ProSignatureData"%>
<%@page import="java.util.Iterator"%>
<%@page import="java.util.Map.Entry"%>
<%@page import="java.util.Set"%>
<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean"%>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html"%>
<%@ taglib uri="/WEB-INF/struts-logic.tld" prefix="logic"%>
<%@ taglib uri="/WEB-INF/rewrite-tag.tld" prefix="rewrite"%>

<%@page import="oscar.OscarProperties"%>
<%@page import="org.oscarehr.casemgmt.model.CaseManagementNote"%>
<%@page import="org.oscarehr.casemgmt.model.Issue"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Collections"%>
<%@page import="org.springframework.web.context.support.WebApplicationContextUtils"%>
<%@page import="org.oscarehr.casemgmt.service.CaseManagementManager"%>
<%@page import="org.springframework.web.context.WebApplicationContext"%>
<%@page import="java.util.ArrayList"%>
<%@page import="oscar.form.FrmRecordFactory"%>
<%@page import="oscar.form.FrmRecord"%>
<%@ page import="org.oscarehr.util.LoggedInInfo" %>
<HTML>
	<HEAD>
		<TITLE>OFC-Male Consult Print Preview</TITLE>
<script src="<%=request.getContextPath()%>/JavaScriptServlet" type="text/javascript"></script>
	</HEAD>

<style>
body{
	margin: 0;
	font-family: Arial,sans-serif;
	font-size: 12.5px;
}

.table_main{
	border: 1px solid #E5E5E5;
}

.tr_section_header{
background-color: #E5E5E5;
font-size: 14px !important;
color: #317CF0;
font-weight: bold;
height: 23px;
}

.tr_section_header td{
	padding-left: 4px;
	cursor: pointer;
}

.textarea_other{
	width: 100%;
	border: 1px solid #C6C4C4;
}

.cls_text{
	border: 1px solid #C6C4C4;
}

.div_form_header{
	font-weight: bold;
	color: white;
	background-color: #86A1C9;
	height: 80px;
}

.span_form_header1{
	font-size: 25px;
	padding-bottom: 3px;
}
.span_form_header2{
	font-size: 17px;
}

.tr_seperator{
	height: 10px;
}
.div_section_field{
	float: left;
	white-space: nowrap;
	margin-right: 7px;
}
</style>

<script type="text/javascript" src="../js/jquery-1.7.1.min.js"></script>
<link rel="stylesheet" type="text/css" media="all" href="../share/calendar/calendar.css" title="win2k-cold-1">
<script type="text/javascript" src="../share/calendar/calendar.js"></script>
<script type="text/javascript" src="../share/calendar/lang/calendar-en.js"></script>
<script type="text/javascript" src="../share/calendar/calendar-setup.js"></script>

<script>
function fn_enableDisableFields(chkObj, id1, id2, id3, id4, id5)
{	
	var flg = $(chkObj).attr("checked");
	enableDisabledField(flg, id1);
	enableDisabledField(flg, id2);
	enableDisabledField(flg, id3);
	enableDisabledField(flg, id4);
	enableDisabledField(flg, id5);

	if($("#"+id1))
	{
		$("#"+id1).focus();
	}
}

function enableDisabledField(flg, id)
{
	var obj = $("#"+id);
	if(obj)
	{
		if(flg)
		{
			$(obj).removeAttr("disabled");
		}
		else
		{
			$(obj).attr("disabled", true);
		}
	}
}

$(document).ready(function(){
	/*$(".tr_section_header").click(function(){
		$(this).next().toggle();
	});*/
	
	$(".tr_section_header").append('<td width="200px" align="right"> '  
			+'</td>');
	
	/*$(".tr_section_header").next().toggle();
	$(".first_section").next().toggle();*/
	
	/*$("[type=checkbox]").each(function(){
		var flg = $(this).attr("checked");
		if(flg){
			var txtObj = $(this).next("[type=text]");
			if(txtObj){
				$(txtObj).removeAttr("disabled");
			}
		}
	});*/
	
	/*Calendar.setup({
		inputField : "pci_date",
		ifFormat : "%Y/%m/%d",
		showsTime : false,
		button : "pci_date_cal",
		singleClick : true,
		step : 1
	});*/
});


</script>

<%!
protected String listNotes(CaseManagementManager cmgmtMgr, String code, String providerNo, String demoNo) {
    List<Issue> issues = cmgmtMgr.getIssueInfoByCode(providerNo, code);

    String[] issueIds = new String[issues.size()];
    int idx = 0;
    for(Issue issue: issues) {
        issueIds[idx] = String.valueOf(issue.getId());
    }

    // need to apply issue filter
    List<CaseManagementNote>notes = cmgmtMgr.getActiveNotes(demoNo, issueIds);
    StringBuffer noteStr = new StringBuffer();
    for(CaseManagementNote n: notes) {
        if( !n.isLocked() )
            noteStr.append(n.getNote() + "; ");
    } 

    String str = noteStr.toString();
    str = str.trim();
    if(str.endsWith(";") && str.length()>2)
    	str = str.substring(0, str.length()-1);
    return str;
}

protected String getData(String partnerType,String infoType,java.util.Properties prop){
	/*System.out.println(partnerType + "_" + infoType + "-->"+ prop.getProperty(partnerType + "_" + infoType, ""));*/
	return prop.getProperty(partnerType + "_" + infoType, "");
}

protected String getdisablestatus(java.util.Properties prop,String parentTag){
	if("".equals(prop.getProperty(parentTag, ""))){
		return " disabled ";
	}else{
		return " ";
	}
}

protected String getinchdisablestatus(java.util.Properties prop){
	if("".equals(prop.getProperty("pe_ht", ""))){
		return " disabled ";
	}else if(!"feet".equals(prop.getProperty("pe_ht_uom_t", ""))){
		return " disabled ";
	}else{
		return " ";
	}
}
%>

<%
System.out.println("int print jsp");
String formClass = "MaleConsultLetter";
String formLink = "maleconsultletter.jsp";

LoggedInInfo loggedInInfo = LoggedInInfo.getLoggedInInfoFromSession(request);

boolean readOnly = false;
String demographicNo = request.getParameter("demographic_no");
String formId = request.getParameter("formId");
String providerNo = (String) session.getAttribute("user");
FrmRecord rec = (new FrmRecordFactory()).factory(formClass);
java.util.Properties props = rec.getFormRecord(loggedInInfo, Integer.parseInt(demographicNo), Integer.parseInt(formId));

String demo = request.getParameter("demographic_no");
oscar.oscarDemographic.data.DemographicData demoData = null;
Demographic demographic = null;
demoData = new oscar.oscarDemographic.data.DemographicData();
demographic = demoData.getDemographic(loggedInInfo, demo);

ArrayList<String> users = (ArrayList<String>)session.getServletContext().getAttribute("CaseMgmtUsers");
boolean useNewCmgmt = false;
WebApplicationContext ctx = WebApplicationContextUtils.getRequiredWebApplicationContext(request.getSession().getServletContext());
CaseManagementManager cmgmtMgr = null;
if( users != null && users.size() > 0 && (users.get(0).equalsIgnoreCase("all") || Collections.binarySearch(users, providerNo)>=0)) {
useNewCmgmt = true;
cmgmtMgr = (CaseManagementManager)ctx.getBean("caseManagementManager");
}

String partner = props.getProperty("partner_no", "");
oscar.oscarDemographic.data.DemographicData partnerDemoData = null;
Demographic partnerDemographic = null;
if(partner != null && !"".equals(partner)){
partnerDemoData = new oscar.oscarDemographic.data.DemographicData();
partnerDemographic = partnerDemoData.getDemographic(loggedInInfo, partner);

RxInformation rxInfo = new RxInformation();

//partner medication and allergies
props.setProperty("partner_allergies",
	org.apache.commons.lang.StringEscapeUtils.escapeJavaScript(rxInfo.getAllergies(loggedInInfo, partner)));
props.setProperty("partner_medication",
	org.apache.commons.lang.StringEscapeUtils.escapeJavaScript(rxInfo.getCurrentMedication(partner)));
props.setProperty("partner_medhistory",
	org.apache.commons.lang.StringEscapeUtils.escapeJavaScript(listNotes(cmgmtMgr, "MedHistory", providerNo, partner)) );
props.setProperty("partner_familyhistory",
	org.apache.commons.lang.StringEscapeUtils.escapeJavaScript(listNotes(cmgmtMgr, "FamHistory", providerNo, partner)) );
props.setProperty("partner_OMeds",
	org.apache.commons.lang.StringEscapeUtils.escapeJavaScript(listNotes(cmgmtMgr, "OMeds", providerNo, partner)) );

}

String spouse = props.getProperty("spouse_no", "");
oscar.oscarDemographic.data.DemographicData spouseDemoData = null;
Demographic spouseDemographic = null;
if(spouse != null && !"".equals(spouse)){
spouseDemoData = new oscar.oscarDemographic.data.DemographicData();
spouseDemographic = spouseDemoData.getDemographic(loggedInInfo, spouse);

RxInformation rxInfo = new RxInformation();

//spouse medication and allergies
props.setProperty("spouse_allergies",
	org.apache.commons.lang.StringEscapeUtils.escapeJavaScript(rxInfo.getAllergies(loggedInInfo, spouse)));
props.setProperty("spouse_medication",
	org.apache.commons.lang.StringEscapeUtils.escapeJavaScript(rxInfo.getCurrentMedication(spouse)));
props.setProperty("spouse_medhistory",
	org.apache.commons.lang.StringEscapeUtils.escapeJavaScript(listNotes(cmgmtMgr, "MedHistory", providerNo, spouse)) );
props.setProperty("spouse_familyhistory",
	org.apache.commons.lang.StringEscapeUtils.escapeJavaScript(listNotes(cmgmtMgr, "FamHistory", providerNo, spouse)) );
props.setProperty("spouse_OMeds",
	org.apache.commons.lang.StringEscapeUtils.escapeJavaScript(listNotes(cmgmtMgr, "OMeds", providerNo, spouse)) );
}
String husband = props.getProperty("husband_no", "");
oscar.oscarDemographic.data.DemographicData husbandDemoData = null;
Demographic husbandDemographic = null;
if(husband != null && !"".equals(husband)){

husbandDemoData = new oscar.oscarDemographic.data.DemographicData();
husbandDemographic = husbandDemoData.getDemographic(loggedInInfo, husband);

RxInformation rxInfo = new RxInformation();

//husband medication and allergies
System.out.println("husband is:555" + rxInfo.getAllergies(loggedInInfo, husband));
props.setProperty("husband_allergies",
	org.apache.commons.lang.StringEscapeUtils.escapeJavaScript(rxInfo.getAllergies(loggedInInfo, husband)));
props.setProperty("husband_medication",
	org.apache.commons.lang.StringEscapeUtils.escapeJavaScript(rxInfo.getCurrentMedication(husband)));
props.setProperty("husband_medhistory",
	org.apache.commons.lang.StringEscapeUtils.escapeJavaScript(listNotes(cmgmtMgr, "MedHistory", providerNo, husband)) );
props.setProperty("husband_familyhistory",
	org.apache.commons.lang.StringEscapeUtils.escapeJavaScript(listNotes(cmgmtMgr, "FamHistory", providerNo, husband)) );
props.setProperty("husband_OMeds",
	org.apache.commons.lang.StringEscapeUtils.escapeJavaScript(listNotes(cmgmtMgr, "OMeds", providerNo, husband)) );
}

request.removeAttribute("submit");

%>

<script>
function importPatient(lNameId, fNameId)
{
    $("#"+lNameId).val("<%=props.getProperty("patient_default_fname", "")%>");
    $("#"+fNameId).val("<%=props.getProperty("patient_default_lname", "")%>");
}
function importPatientAge(id)
{
    $("#"+id).val('<%=props.getProperty("patient_default_age", "")%>');
}
function importPartner(lNameId,fNameId)
{	
	var firstNameCtrl = document.getElementById(fNameId);
	var lastNameCtrl = document.getElementById(lNameId);
	<%if(
		!(props.getProperty("partner_default_fname", "") == null || "".equals(props.getProperty("partner_default_fname", "")) ||
		props.getProperty("partner_default_lname", "") == null || "".equals(props.getProperty("partner_default_lname", ""))
		)){%>
    firstNameCtrl.value = "<%=props.getProperty("partner_default_fname", "")%>";
	lastNameCtrl.value = "<%=props.getProperty("partner_default_lname", "")%>";
	<%} else if(
		!(props.getProperty("spouse_default_fname", "") == null || "".equals(props.getProperty("spouse_default_fname", "")) ||
		props.getProperty("spouse_default_lname", "") == null || "".equals(props.getProperty("spouse_default_lname", ""))
		)){%>
	firstNameCtrl.value = "<%=props.getProperty("spouse_default_fname", "")%>";
	lastNameCtrl.value = "<%=props.getProperty("spouse_default_lname", "")%>";
	<%} else if(
		!(props.getProperty("husband_default_fname", "") == null || "".equals(props.getProperty("husband_default_fname", "")) ||
		props.getProperty("husband_default_lname", "") == null || "".equals(props.getProperty("husband_default_lname", ""))
		)){%>
	firstNameCtrl.value = "<%=props.getProperty("husband_default_fname", "")%>";
	lastNameCtrl.value = "<%=props.getProperty("husband_default_lname", "")%>";
	<%}%>
}
function importPartnerAge(id)
{
	var ageCtrl = document.getElementById(id);
    <%if(
		!(
		props.getProperty("partner_default_age", "") == null || "".equals(props.getProperty("partner_default_age", ""))
		)){%>
    ageCtrl.value = '<%=props.getProperty("partner_default_age", "")%>';
	<%} else if(
		!(
		props.getProperty("spouse_default_age", "") == null || "".equals(props.getProperty("spouse_default_age", ""))
		)){%>
    ageCtrl.value = '<%=props.getProperty("spouse_default_age", "")%>';
	<%} else if(
		!(
		props.getProperty("husband_default_age", "") == null || "".equals(props.getProperty("husband_default_age", ""))
		)){%>
	ageCtrl.value = '<%=props.getProperty("husband_default_age", "")%>';
	<%}%>
}
function importDoctor(lNameId, fNameId)
{
	var lastNameCtrl = document.getElementById(lNameId);
	var firstNameCtrl = document.getElementById(fNameId);
	
    lastNameCtrl.value = "<%=props.getProperty("family_doctor_default_lname", "")%>";
	firstNameCtrl.value = "<%=props.getProperty("family_doctor_default_fname", "")%>";
}
function importFromEnct(reqInfo,txtAreaId)
{
	var txtArea = document.getElementById(txtAreaId);
    var info = "";
    switch( reqInfo )
    {
        case "Medical":
            <%
            String value = "";
                 if( demo != null )
                 {
                  if(OscarProperties.getInstance().getBooleanProperty("caisi","on")) {
                		 value = "";
                  }else{
					if( useNewCmgmt ) {
                        value = listNotes(cmgmtMgr, "MedHistory", providerNo, demo);
                    }
                    else {
                    //family history was used as bucket for Other Meds in old encounter
                    EctInformation ectInfo = new EctInformation(loggedInInfo, demo);
                        value = ectInfo.getFamilyHistory();
                    }
				  }
                    value = org.apache.commons.lang.StringEscapeUtils.escapeJavaScript(value);
                    out.println("info = '" + value + "'");

                }
              %>
             break;
          case "Family":
             <%
                 if( demo != null )
                 {
                  if(OscarProperties.getInstance().getBooleanProperty("caisi","on")) {
                		 value = "";
                  }else{
					if( useNewCmgmt ) {
                        value = listNotes(cmgmtMgr, "FamHistory", providerNo, demo);
                    }
                    else {
                    //family history was used as bucket for Other Meds in old encounter
                    EctInformation ectInfo = new EctInformation(loggedInInfo, demo);
                    value = ectInfo.getFamilyHistory();
                    }
				  }
                    value = org.apache.commons.lang.StringEscapeUtils.escapeJavaScript(value);
                    out.println("info = '" + value + "'");

                }
              %>
             break;
           case "Social":
              <%
                 if( demo != null )
                 {
                  if(OscarProperties.getInstance().getBooleanProperty("caisi","on")) {
                		 value = "";
                  }else{
					if( useNewCmgmt ) {
                        value = listNotes(cmgmtMgr, "SocHistory", providerNo, demo);
                    }
                    else {
                    //family history was used as bucket for Other Meds in old encounter
                    EctInformation ectInfo = new EctInformation(loggedInInfo, demo);
                        value = ectInfo.getFamilyHistory();
                    }
				  }
                    value = org.apache.commons.lang.StringEscapeUtils.escapeJavaScript(value);
                    out.println("info = '" + value + "'");

                }
              %>
             break;
			 case "Allergies":
              <%
				RxInformation rxInfo = new RxInformation();
              value = rxInfo.getAllergies(loggedInInfo, demo);
				value = org.apache.commons.lang.StringEscapeUtils.escapeJavaScript(value);
                out.println("info = '" + value + "'");
             %>
             break; 
			 case "OtherMeds":
              <%
                 if( demo != null )
                 {
                  if(OscarProperties.getInstance().getBooleanProperty("caisi","on")) {
                		 value = "";
                  }else{
					if( useNewCmgmt ) {
                        value = listNotes(cmgmtMgr, "OMeds", providerNo, demo);
                    }
                    else {
                    //family history was used as bucket for Other Meds in old encounter
                    EctInformation ectInfo = new EctInformation(loggedInInfo, demo);
                        value = ectInfo.getFamilyHistory();
                    }
				  }
                    value = org.apache.commons.lang.StringEscapeUtils.escapeJavaScript(value);
                    out.println("info = '" + value + "'");

                }
              %>
                break;
              case "Medication":
              <%
              RxInformation rxInfo1 = new RxInformation();
                value = rxInfo1.getCurrentMedication(demo);
				value = org.apache.commons.lang.StringEscapeUtils.escapeJavaScript(value);
                out.println("info = '" + value + "'");
             %>
             break; 
	} //end switch
	
    if( txtArea.value.length > 0 && info.length > 0 )
    {
    	//if(reqInfo=="Allergies")
        	txtArea.value += '; ';
    	/*else
    		txtArea.value += '\n';*/
    }

    txtArea.value += info;
    txtArea.scrollTop = txtArea.scrollHeight;
    txtArea.focus();
}

function onPrint()
{
	$("[type=button]").toggle();
	window.print();
	$("[type=button]").toggle();
}

function onExit()
{
	window.close();
}

function onBack()
{
	
}
</script>

<%!
public boolean isSectionFieldEmpty(java.util.Properties props, String fieldName)
{
	boolean flg = true;
	if(props!=null && fieldName!=null)
	{
		//fieldName = fieldName.toUpperCase();
		Object value = props.get(fieldName);
		if(value!=null && value.toString().trim().length()>0)
		{
			flg = false;			
		}
	}
	return flg;
}
public boolean isSectionEmpty(java.util.Properties props, String sectionPrefix)
{
	boolean flg = true;
	if(props!=null && sectionPrefix!=null)
	{
		sectionPrefix = sectionPrefix+"_";
		Set<Entry<Object, Object>> entrySet = props.entrySet();
		Iterator<Entry<Object, Object>> iter = entrySet.iterator();
		Entry<Object, Object> entry = null;
		String key = "", value = "";
		while(iter.hasNext())
		{
			entry = iter.next();
			if(entry.getKey()!=null && entry.getKey().toString().startsWith(sectionPrefix))
			{
				if(entry.getValue()!=null && entry.getValue().toString().trim().length()>0)
				{
					flg = false;
					break;
				}
			}			
		}
	}
	return flg;
}
%>

<%
Vector vecPhones = new Vector();
Vector vecFaxes  = new Vector();
ClinicData clinic = new ClinicData();
String strPhones = clinic.getClinicDelimPhone();
if (strPhones == null) { strPhones = ""; }
String strFaxes  = clinic.getClinicDelimFax();
if (strFaxes == null) { strFaxes = ""; }

StringTokenizer st = new StringTokenizer(strPhones,"|");
while (st.hasMoreTokens()) {
	vecPhones.add(st.nextToken());
}

st = new StringTokenizer(strFaxes,"|");
while (st.hasMoreTokens()) {
 vecFaxes.add(st.nextToken());
}

String curUser_no = (String) session.getAttribute("user");
ProSignatureData sig = new ProSignatureData();
String multiLineHeader = sig.getMultiLineHeader(curUser_no);
//String multiLineHeader = sig.getSignature(curUser_no);
System.out.println("multiLineHeader = "+multiLineHeader);
if(multiLineHeader!=null && multiLineHeader.trim().length()>0) {
	multiLineHeader = multiLineHeader.replaceAll("\n", "<br>");
}
%>

<BODY>
<html:form action="/form/formname">

<input type="hidden" name="demographic_no" value="<%= props.getProperty("demographic_no", "0") %>" />
<input type="hidden" name="ID" value="<%= formId %>" />
<input type="hidden" name="provider_no" value=<%=request.getParameter("provider_no")%> />
<input type="hidden" name="formCreated" value="<%= props.getProperty("formCreated", "") %>" />
<input type="hidden" name="form_class" value="<%=formClass%>" />
<input type="hidden" name="form_link" value="<%=formLink%>" />
<input type="hidden" name="submit" value="exit" />
<input type="hidden" name="formCreated" value="<%= props.getProperty("formCreated", "") %>" />
<input type="hidden" name="re_text" value="<%= props.getProperty("re_text", "") %>" />
		
<table class="table_main" width="80%" align="center" cellpadding="0" cellspacing="0">
<tbody>
	<tr>
		<td>
			<input type="button" value="Print" onclick="javascript:return onPrint();" />
			<input type="button" value="Exit" onclick="javascript:return onExit();" /> 			
		</td>
	</tr>
	<tr height="2px"><td></td></tr>
	
	<tr>
		<td class="div_form_header" colspan="2">
			<div>
			<div class="span_form_header1">Ottawa Fertility Centre</div>
			<div class="span_form_header2">Male Consult Template</div>
			</div>
		</td>
	</tr>
	
	<tr>
		<td colspan="2">
			<table width="100%">
				<tr> 
					<td>
						<img alt="OFC consult letter logo"
						src="../images/ofc_consult_letter_logo.png">
					</td>
					<td align="right" valign="bottom">
						<div style="padding-bottom: 3px;">
						<%if(multiLineHeader!=null && multiLineHeader.trim().length()>0) {%>
						<b><%=multiLineHeader %></b><br>
						<%} %>
						<%=clinic.getClinicName()%> <br>
						<%=clinic.getClinicAddress()%><br>
						<%=clinic.getClinicCity()%>, <%=clinic.getClinicProvince()%>&nbsp;&nbsp;<%=clinic.getClinicPostal()%> <br>
							Tel: <%=vecPhones.size()>=1?vecPhones.elementAt(0):clinic.getClinicPhone()%>
							&nbsp;&nbsp;Fax: <%=vecFaxes.size()>=1?vecFaxes.elementAt(0):clinic.getClinicFax()%>
						</div>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	
	<tr class="tr_section_header first_section">
		<td>Patient & Consultation Information</td>
		<!-- <td width="200px" align="right"> 
			<div><a href="#">Collapse All</a> <a href="#">Expand All</a>
			</div>
		</td> -->
	</tr>
	<tr>
		<td colspan="2">
			<!-- Patient & Consultation Information - pci -->
			<table id="table_pci" width="100%">
				<tr>
					<td width="100px">Date: </td>
					<td><%=props.getProperty("pci_date", "")%></td>
				</tr>
				<tr>
					<td>Patient Name: </td>
					<td><%=props.getProperty("pci_patient_lname", "")%><%if(!isSectionFieldEmpty(props, "pci_patient_fname")){ %>, <%=props.getProperty("pci_patient_fname", "")%>
					<%} %>(<%= props.getProperty("pci_patient_age", "")%> years old)
					</td>
				</tr>
				<%-- <tr>
					<td>Patient Age: </td>
					<td><%=props.getProperty("pci_patient_age", "")%>
					</td>
				</tr> --%>
				<tr>
					<td>Partner Name: </td>
					<td><%=props.getProperty("pci_partner_lname", "")%><%if(!isSectionFieldEmpty(props, "pci_partner_fname")){ %>, <%=props.getProperty("pci_partner_fname", "")%>
					<%} %>(<%= props.getProperty("pci_partner_age", "")%> years old)
					</td>
				</tr>
				<%-- <tr>
					<td>Partner Age: </td>
					<td><%=props.getProperty("pci_partner_age", "")%>
					</td>
				</tr>
				<tr>
					<td>Referring Physician Name: </td>
					<td><%=props.getProperty("pci_refer_physic_lname", "")%>
					<%if(!isSectionFieldEmpty(props, "pci_refer_physic_fname")){ %>, <%=props.getProperty("pci_refer_physic_fname", "")%>
					<%} %>
					</td>
				</tr> --%>
				
				<tr>
					<td>&nbsp;</td>
				</tr>
				
				<tr>
					<td colspan="2">Dear Dr.&nbsp;<%=props.getProperty("pci_refer_physic_lname", "")%>, <br>
					<%
					String patientPartnerStr = "patient";
					
					if((props.getProperty("patient_lname", "").trim().length()>0 || props.getProperty("patient_fname", "").trim().length()>0)
					&& (props.getProperty("partner_lname", "").trim().length()>0 || props.getProperty("partner_fname", "").trim().length()>0))
					{	patientPartnerStr = "couple"; }
					%>
					Thank you for referring this <%=patientPartnerStr %> to our facility. Here are the results of our initial consultation. If you have any questions, please feel free to contact our office. We would be pleased to offer any additional information.
					</td>
				</tr>
			</table>
		</td>
	</tr>
	
	<%if(!isSectionEmpty(props, "rfr")) {%>
	<tr class="tr_seperator"><td></td></tr>
	<tr class="tr_section_header">
		<td>Reason for Referral</td>
	</tr>
	<tr>
		<td colspan="2">
			<!-- reason for referrral - rfr-->
			<table id="table_reason_for_referral" width="100%">
				<tr>
					<td>
						<div>
						<%if(!isSectionFieldEmpty(props, "rfr_male_factor")){ %><div class="div_section_field" > 
						<input type="checkbox" id="rfr_male_factor" name="rfr_male_factor" <%=props.getProperty("rfr_male_factor", "")%>/>Male factor infertility
						</div> <%} %>  
						
						<%if(!isSectionFieldEmpty(props, "rfr_infertility")){ %><div class="div_section_field" >
						<input type="checkbox" id="rfr_infertility" name="rfr_infertility" 
						<%=props.getProperty("rfr_infertility", "")%>/>Infertility</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "rfr_oligospermia")){ %><div class="div_section_field" >
						<input type="checkbox" id="rfr_oligospermia" name="rfr_oligospermia" 
						<%=props.getProperty("rfr_oligospermia", "")%>/>Oligospermia
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "rfr_oligo_astheno")){ %><div class="div_section_field" >
						<input type="checkbox" id="rfr_oligo_astheno" name="rfr_oligo_astheno" 
						<%=props.getProperty("rfr_oligo_astheno", "")%>/>Oligo-asthenospermia
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "rfr_asthenospermia")){ %><div class="div_section_field" >
						<input type="checkbox" id="rfr_asthenospermia" name="rfr_asthenospermia"
						<%=props.getProperty("rfr_asthenospermia", "")%>/>Asthenospermia
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "rfr_teratospermia")){ %><div class="div_section_field" >						
						<input type="checkbox" id="rfr_teratospermia" name="rfr_teratospermia"
						<%=props.getProperty("rfr_teratospermia", "")%>/>Teratospermia
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "rfr_oligo_astheno_t")){ %><div class="div_section_field" >
						<input type="checkbox" id="rfr_oligo_astheno_t" name="pci_patient_fname"
						<%=props.getProperty("rfr_oligo_astheno_t", "")%>/>Oligo-astheno-teratospermia
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "rfr_azoospermia")){ %><div class="div_section_field" >
						<input type="checkbox" id="rfr_azoospermia" name="rfr_azoospermia"
						<%=props.getProperty("rfr_azoospermia", "")%>/>Azoospermia
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "rfr_testicular_failure")){ %><div class="div_section_field" >						
						<input type="checkbox" id="rfr_testicular_failure" name="rfr_testicular_failure"
						<%=props.getProperty("rfr_testicular_failure", "")%>/>Testicular failure
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "rfr_history_of_vas")){ %><div class="div_section_field" >
						<input type="checkbox" id="rfr_history_of_vas" name="rfr_history_of_vas"
						<%=props.getProperty("rfr_history_of_vas", "")%>/>History of vasectomy
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "rfr_history_of_vas")){ %><div class="div_section_field" >
						<input type="checkbox" id="rfr_history_of_vas" name="rfr_history_of_vas"
						<%=props.getProperty("rfr_history_of_vas", "")%>/>History of vasectomy
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "rfr_sperm_cryopre")){ %><div class="div_section_field" >
						<input type="checkbox" id="rfr_sperm_cryopre" name="rfr_sperm_cryopre"
						<%=props.getProperty("rfr_sperm_cryopre", "")%>/>Sperm cryopreservation
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "rfr_therapeutic_donor")){ %><div class="div_section_field" >
						<input type="checkbox" id="rfr_therapeutic_donor" name="rfr_therapeutic_donor"
						<%=props.getProperty("rfr_therapeutic_donor", "")%>/>Therapeutic donor insemination
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "rfr_erectile_dysfunct")){ %><div class="div_section_field" >
						<input type="checkbox" id="rfr_erectile_dysfunct" name="rfr_erectile_dysfunct"
						<%=props.getProperty("rfr_erectile_dysfunct", "")%>/>Erectile dysfunction
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "rfr_retrograde_ejacul")){ %><div class="div_section_field" >
						<input type="checkbox" id="rfr_retrograde_ejacul" name="rfr_retrograde_ejacul"
						<%=props.getProperty("rfr_retrograde_ejacul", "")%>/>Retrograde ejaculation
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "rfr_ejaculatory_dys")){ %><div class="div_section_field" >
						<input type="checkbox" id="rfr_ejaculatory_dys" name="rfr_ejaculatory_dys"
						<%=props.getProperty("rfr_ejaculatory_dys", "")%>/>Ejaculatory dysfunction
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "rfr_decreased_libi")){ %><div class="div_section_field" >
						<input type="checkbox" id="rfr_decreased_libi" name="rfr_decreased_libi"
						<%=props.getProperty("rfr_decreased_libi", "")%>/>Decreased libido
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "rfr_varicocele")){ %><div class="div_section_field" >
						<input type="checkbox" id="rfr_varicocele" name="rfr_varicocele"
						<%=props.getProperty("rfr_varicocele", "")%>/>Varicocele(s)
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "rfr_assessment_of_fert")){ %><div class="div_section_field" >
						<input type="checkbox" id="rfr_assessment_of_fert" name="rfr_assessment_of_fert"
						<%=props.getProperty("rfr_assessment_of_fert", "")%>/>Assessment of fertility potential
						</div><%} %>
						
						</div>
					</td>
				</tr>
				
				<%if(!isSectionFieldEmpty(props, "rfr_other")){ %>
				<tr>
					<td><%=props.getProperty("rfr_other", "")%></td>
				</tr>
				<%} %>
			</table>
		</td>
	</tr>
	<%} %>
	
	<%if(!isSectionEmpty(props, "rfh")) {%>
	<tr class="tr_seperator"><td></td></tr>
	<tr class="tr_section_header" >
		<td>Relevant Fertility History and Risk Factors</td>
	</tr>

	<tr>
		<td colspan="2">
			<!-- Relevant Fertility History and Risk Factors - rfh -->
			<table id="table_relevant_fertility_history" width="100%">
				<tr>
					<td>
						<div>
						<%if(!isSectionFieldEmpty(props, "rfh_duration_of_try")){ %><div class="div_section_field" >
						<input type="checkbox" id="rfh_duration_of_try" name="rfh_duration_of_try"
						<%=props.getProperty("rfh_duration_of_try", "")%>
						onclick="fn_enableDisableFields(this, 'rfh_duration_of_try_t');" />
						Duration of trying to conceive: <%=props.getProperty("rfh_duration_of_try_t", "")%>
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "rfh_frequency_of_inter")){ %><div class="div_section_field" >
						<input type="checkbox" id="rfh_frequency_of_inter" name="rfh_frequency_of_inter"
						<%=props.getProperty("rfh_frequency_of_inter", "")%>
						onclick="fn_enableDisableFields(this, 'rfh_frequency_of_inter_t');" />
						Frequency of intercourse: <%=props.getProperty("rfh_frequency_of_inter_t", "")%>
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "rfh_fathered_pregn")){ %><div class="div_section_field" >
						<input type="checkbox" id="rfh_fathered_pregn" name="rfh_fathered_pregn"
						<%=props.getProperty("rfh_fathered_pregn", "")%>
						onclick="fn_enableDisableFields(this, 'rfh_fathered_pregn_t');" />
						Fathered: <%=props.getProperty("rfh_fathered_pregn_t", "")%> pregnanc(ies)
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "rfh_longest_time_to")){ %><div class="div_section_field" >
						<input type="checkbox" id="rfh_longest_time_to" name="rfh_longest_time_to" 
						<%=props.getProperty("rfh_longest_time_to", "")%>
						onclick="fn_enableDisableFields(this, 'rfh_longest_time_to_t');" />
						Longest time to conception: <%=props.getProperty("rfh_longest_time_to_t", "")%>
						 </div><%} %>
						 
						 <%if(!isSectionFieldEmpty(props, "rfh_erectile_dys")){ %><div class="div_section_field" >
						 <input type="checkbox" id="rfh_erectile_dys" name="rfh_erectile_dys"
						<%=props.getProperty("rfh_erectile_dys", "")%>
						onclick="fn_enableDisableFields(this, 'rfh_erectile_dys_t');" />
						Erectile dysfunction: <%=props.getProperty("rfh_erectile_dys_t", "")%>
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "rfh_ejaculatory_dys")){ %><div class="div_section_field" >
						<input type="checkbox" id="rfh_ejaculatory_dys" name="rfh_ejaculatory_dys"
						<%=props.getProperty("rfh_ejaculatory_dys", "")%>
						onclick="fn_enableDisableFields(this, 'rfh_ejaculatory_dys_t');" />
						Ejaculatory dysfunction: <%=props.getProperty("rfh_ejaculatory_dys_t", "")%>
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "rfh_shaves")){ %><div class="div_section_field" >
						<input type="checkbox" id="rfh_shaves" name="rfh_shaves"
						<%=props.getProperty("rfh_shaves", "")%>
						onclick="fn_enableDisableFields(this, 'rfh_shaves_t');" />
						Shaves: <%=props.getProperty("rfh_shaves_t", "")%>
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "rfh_vasectomy_done")){ %><div class="div_section_field" >
						<input type="checkbox" id="rfh_vasectomy_done" name="rfh_vasectomy_done"
						<%=props.getProperty("rfh_vasectomy_done", "")%>
						onclick="fn_enableDisableFields(this, 'rfh_vasectomy_done_t');" />
						Vasectomy done in: <%=props.getProperty("rfh_vasectomy_done_t", "")%>
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "rfh_vasectomy_rev")){ %><div class="div_section_field" >
						<input type="checkbox" id="rfh_vasectomy_rev" name="rfh_vasectomy_rev"
						<%=props.getProperty("rfh_vasectomy_rev", "")%>
						onclick="fn_enableDisableFields(this, 'rfh_vasectomy_rev_t');" />
						Vasectomy reversal done in: <%=props.getProperty("rfh_vasectomy_rev_t", "")%>
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "rfh_history_of_unde")){ %><div class="div_section_field" >
						<input type="checkbox" id="rfh_history_of_unde" name="rfh_history_of_unde"
						<%=props.getProperty("rfh_history_of_unde", "")%>
						onclick="fn_enableDisableFields(this, 'rfh_history_of_unde_t');" />
						History of undescended: <%=props.getProperty("rfh_history_of_unde_t", "")%> testicle
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "rfh_orchipexy_at")){ %><div class="div_section_field" >
						 <input type="checkbox" id="rfh_orchipexy_at" name="rfh_orchipexy_at"
						<%=props.getProperty("rfh_orchipexy_at", "")%>
						onclick="fn_enableDisableFields(this, 'rfh_orchipexy_at_t');" />
						Orchipexy at: <%=props.getProperty("rfh_orchipexy_at_t", "")%>
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "rfh_history_of_orch")){ %><div class="div_section_field" >
						<input type="checkbox" id="rfh_history_of_orch" name="rfh_history_of_orch" 
						<%=props.getProperty("rfh_history_of_orch", "")%>/>
						History of orchitis
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "rfh_history_of_scr")){ %><div class="div_section_field" >
						<input type="checkbox" id="rfh_history_of_scr" name="rfh_history_of_scr"
						<%=props.getProperty("rfh_history_of_scr", "")%>
						onclick="fn_enableDisableFields(this, 'rfh_history_of_scr_t');" />
						History of scrotal trauma: <%=props.getProperty("rfh_history_of_scr_t", "")%>
						 </div><%} %>
						 
						<%if(!isSectionFieldEmpty(props, "rfh_history_of_pro")){ %><div class="div_section_field" > 
						 <input type="checkbox" id="rfh_history_of_pro" name="rfh_history_of_pro" 
						<%=props.getProperty("rfh_history_of_pro", "")%>/>
						History of prostatitis
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "rfh_history_of_epi")){ %><div class="div_section_field" >
						<input type="checkbox" id="rfh_history_of_epi" name="rfh_history_of_epi" 
						<%=props.getProperty("rfh_history_of_epi", "")%>/>
						History of epididymitis
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "rfh_history_of_ure")){ %><div class="div_section_field" >
						<input type="checkbox" id="rfh_history_of_ure" name="rfh_history_of_ure" 
						<%=props.getProperty("rfh_history_of_ure", "")%>/>
						History of urethral trauma
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "rfh_inguinal_hern")){ %><div class="div_section_field" >
						<input type="checkbox" id="rfh_inguinal_hern" 
						name="rfh_inguinal_hern" <%=props.getProperty("rfh_inguinal_hern", "")%>/>
						Inguinal hernia repair
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "rfh_gonadotoxic_exp")){ %><div class="div_section_field" >
						<input type="checkbox" id="rfh_gonadotoxic_exp" name="rfh_gonadotoxic_exp"
						<%=props.getProperty("rfh_gonadotoxic_exp", "")%>
						onclick="fn_enableDisableFields(this, 'rfh_gonadotoxic_exp_t');" />
						Gonadotoxic exposure(s): <%=props.getProperty("rfh_gonadotoxic_exp_t", "")%>
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "rfh_alcoholic_drinks")){ %><div class="div_section_field" >
						<input type="checkbox" id="rfh_alcoholic_drinks" name="rfh_alcoholic_drinks"
						<%=props.getProperty("rfh_alcoholic_drinks", "")%>
						onclick="fn_enableDisableFields(this, 'rfh_alcoholic_drinks_t');" />
						Alcoholic drinks per week: <%=props.getProperty("rfh_alcoholic_drinks_t", "")%>
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "rfh_marijuana")){ %><div class="div_section_field" >
						<input type="checkbox" id="rfh_marijuana" name="rfh_marijuana" 
						onclick="fn_enableDisableFields(this, 'rfh_marijuana_t');" <%=props.getProperty("rfh_marijuana", "")%>/>
						Marijuana: <%=props.getProperty("rfh_marijuana_t", "")%>
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "rfh_smoker")){ %><div class="div_section_field" >
						<input type="checkbox" id="rfh_smoker" name="rfh_smoker"
						<%=props.getProperty("rfh_smoker", "")%>
						onclick="fn_enableDisableFields(this, 'rfh_smoker_t');" />
						Smoker: <%=props.getProperty("rfh_smoker_t", "")%>
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "rfh_non_smoker")){ %><div class="div_section_field" >
						<input type="checkbox" id="rfh_non_smoker" name="rfh_non_smoker"
						<%=props.getProperty("rfh_non_smoker", "")%>/>
						Non-Smoker
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "rfh_hot_tubes_sauna")){ %><div class="div_section_field" >
						<input type="checkbox" id="rfh_hot_tubes_sauna" name="rfh_hot_tubes_sauna" 
						<%=props.getProperty("rfh_hot_tubes_sauna", "")%>/>
						Hot tubes / sauna
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "rfh_denies_hot_tubes")){ %><div class="div_section_field" >
						<input type="checkbox" id="rfh_denies_hot_tubes" name="rfh_denies_hot_tubes"
						<%=props.getProperty("rfh_denies_hot_tubes", "")%>/>
						Denies hot tubes / sauna use
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "rfh_degreasers")){ %><div class="div_section_field" >
						<input type="checkbox" id="rfh_degreasers" name="rfh_degreasers"
						<%=props.getProperty("rfh_degreasers", "")%>/>
						 Degreasers or solvents
						</div><%} %>
						 
						</div>
					</td>
				</tr>

				<%if(!isSectionFieldEmpty(props, "rfh_other")){ %>				
				<tr>
					<td><%=props.getProperty("rfh_other", "")%></td>
				</tr>
				<%} %>
				
			</table>
		</td>
	</tr>
	<%} %>
	
	<%if(!isSectionEmpty(props, "previ")) {%>
	<tr class="tr_seperator"><td></td></tr>
	<tr class="tr_section_header" >
		<td>Previous Investigations</td>
	</tr>

	<tr>
		<td colspan="2">
			<!-- Previous Investigations - previ -->
			<table id="table_previous_investigations" width="100%">
				<tr>
					<td>
						<div>
						<%if(!isSectionFieldEmpty(props, "previ_normal_semen")){ %><div class="div_section_field" >
						<input type="checkbox" id="previ_normal_semen" name="previ_normal_semen"
						<%=props.getProperty("previ_normal_semen", "")%>/>
						Normal semen analysis
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "previ_abnormal_semen")){ %><div class="div_section_field" >
						<input type="checkbox" id="previ_abnormal_semen" name="previ_abnormal_semen"
						<%=props.getProperty("previ_abnormal_semen", "")%>
						onclick="fn_enableDisableFields(this, 'previ_abnormal_semen_t');" />
						Abnormal semen analysis: <%=props.getProperty("previ_abnormal_semen_t", "")%>
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "previ_DNA_frag")){ %><div class="div_section_field" >
						<input type="checkbox" id="previ_DNA_frag" name="previ_DNA_frag"
						<%=props.getProperty("previ_DNA_frag", "")%>
						onclick="fn_enableDisableFields(this, 'previ_DNA_frag_t');" />
						DNA Fragmentation: <%=props.getProperty("previ_DNA_frag_t", "")%>
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "previ_azoospermia")){ %><div class="div_section_field" >
						<input type="checkbox" id="previ_azoospermia" name="previ_azoospermia"
						<%=props.getProperty("previ_azoospermia", "")%>/>
						Azoospermia
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "previ_scrotal_ultr")){ %><div class="div_section_field" >
						<input type="checkbox" id="previ_scrotal_ultr" name="previ_scrotal_ultr"
						<%=props.getProperty("previ_scrotal_ultr", "")%>
						onclick="fn_enableDisableFields(this, 'previ_scrotal_ultr_t');" />
						Scrotal ultrasound: <%=props.getProperty("previ_scrotal_ultr_t", "")%>
						 </div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "previ_transrectal_ult")){ %><div class="div_section_field" > 
						 <input type="checkbox" id="previ_transrectal_ult" name="previ_transrectal_ult"
						<%=props.getProperty("previ_transrectal_ult", "")%>
						onclick="fn_enableDisableFields(this, 'previ_transrectal_ult_t');" />
						Scrotal ultrasound: <%=props.getProperty("previ_transrectal_ult_t", "")%>
						  </div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "previ_hormones")){ %><div class="div_section_field" > 
						 <input type="checkbox" id="previ_hormones" name="previ_hormones"
						<%=props.getProperty("previ_hormones", "")%>
						onclick="fn_enableDisableFields(this, 'previ_hormones_t');" />
						Hormones: <%=props.getProperty("previ_hormones_t", "")%>
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "previ_y_micro")){ %><div class="div_section_field" >
						<input type="checkbox" id="previ_y_micro" name="previ_y_micro"
						<%=props.getProperty("previ_y_micro", "")%>/>
						Y microdeletion: <%=props.getProperty("previ_y_micro_t", "")%> 
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "previ_karyotype")){ %><div class="div_section_field" >
						<input type="checkbox" id="previ_karyotype" name="previ_karyotype"
						<%=props.getProperty("previ_karyotype", "")%>/>
						Karyotype: <%=props.getProperty("previ_karyotype_t", "")%>
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "previ_CFTR")){ %><div class="div_section_field" >
						<input type="checkbox" id="previ_CFTR" name="previ_CFTR"
						<%=props.getProperty("previ_CFTR", "")%>/>
						CFTR: <%=props.getProperty("previ_CFTR_t", "")%>
						</div><%} %>
						
						</div>
					</td>
				</tr>
				
				<%if(!isSectionFieldEmpty(props, "previ_other")){ %>
				<tr>
					<td><%=props.getProperty("previ_other", "")%></td>
				</tr>
				<%} %>
			</table>
		</td>
	</tr>
	<%} %>
	
	<%if(!isSectionEmpty(props, "msh")) {%>
	<tr class="tr_seperator"><td></td></tr>
	<tr class="tr_section_header" >
		<td>Medical and Surgical History 
		</td>
	</tr>
	
	<%if(!isSectionFieldEmpty(props, "msh_t")){ %>
	<tr>
		<td colspan="2">
			<!-- Medical and Surgical History - msh -->
			<table id="table_medical_and_surgical_history" width="100%">
				<tr>
					<td>
						<%=props.getProperty("msh_t", "")%>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	<%} %>
	<%} %>
	
	<%if(!isSectionEmpty(props, "pm")) {%>
	<tr class="tr_seperator"><td></td></tr>
	<tr class="tr_section_header" >
		<td>Prescriptions and Medications 
		</td>
	</tr>
	<%if(!isSectionFieldEmpty(props, "pm_t")){ %>
	<tr>
		<td colspan="2">
			<!-- Prescriptions and Medications - pm -->
			<table id="table_prescriptions_and_medications" width="100%">
				<tr>
					<td>
						<%=props.getProperty("pm_t", "")%>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	<%} %>
	<%} %>
	
	<%if(!isSectionEmpty(props, "alle")) {%>
	<tr class="tr_seperator"><td></td></tr>
	<tr class="tr_section_header" >
		<td>Allergies
		</td>
	</tr>
	<%if(!isSectionFieldEmpty(props, "alle_t")){ %>
	<tr>
		<td colspan="2">
			<!-- Allergies - alle -->
			<table id="table_allergies" width="100%">
				<tr>
					<td>
						<%=props.getProperty("alle_t", "")%>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	<%} %>
	<%} %>
	
	<%if(!isSectionEmpty(props, "fh")) {%>
	<tr class="tr_seperator"><td></td></tr>
	<tr class="tr_section_header" >
		<td>Family History
		<!-- &nbsp;<input type="button" value="Family History" 
		onclick="importFromEnct('Family', 'fh_t'); event.stopPropagation();"/> -->
		</td>
	</tr>
	<%if(!isSectionFieldEmpty(props, "fh_t")){ %>
	<tr>
		<td colspan="2">
			<!-- Family History - fh -->
			<table id="table_family_history" width="100%">
				<tr>
					<td>
						<%=props.getProperty("fh_t", "")%>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	<%} %>
	<%} %>
	
	<%if(!isSectionEmpty(props, "sh")) {%>
	<tr class="tr_seperator"><td></td></tr>
	<tr class="tr_section_header" >
		<td>Social History
		<!-- &nbsp;<input type="button" value="Social History" 
		onclick="importFromEnct('Social', 'sh_t'); event.stopPropagation();"/> -->
		</td>
	</tr>
	<tr>
		<td colspan="2">
			<!-- Social History - sh -->
			<table id="table_social_history" width="100%">
				<tr>
					<td>
						<div>
						<%if(!isSectionFieldEmpty(props, "sh_occupation")){ %><div class="div_section_field" >
						<input type="checkbox" id="sh_occupation" name="sh_occupation"
						<%=props.getProperty("sh_occupation", "")%>
						onclick="fn_enableDisableFields(this, 'sh_occupation_t');" />
						Occupation: <%=props.getProperty("sh_occupation_t", "")%>
						</div><%} %> 
						</div>
					</td>
				</tr>
				
				<%if(!isSectionFieldEmpty(props, "sh_t")){ %>
				<tr>
					<td>
						<%=props.getProperty("sh_t", "")%>
					</td>
				</tr>
				<%} %>
			</table>
		</td>
	</tr>
	<%} %>
	
	<%if(!isSectionEmpty(props, "fh")) {%>
	<tr class="tr_seperator"><td></td></tr>
	<tr class="tr_section_header" >
		<td>Female History
		</td>
	</tr>
	<tr>
		<td colspan="2">
			<!-- Female History - fh -->
			<table id="table_female_history" width="100%">
				<tr>
					<td>
						<div>
						<%if(!isSectionFieldEmpty(props, "fh_age")){ %><div class="div_section_field" >
						<input type="checkbox" id="fh_age" name="fh_age"
						<%=props.getProperty("fh_age", "")%>
						onclick="fn_enableDisableFields(this, 'fh_age_t');" />
						Age: <%=props.getProperty("fh_age_t", "")%>
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "fh_gpep")){ %><div class="div_section_field" >
						<input type="checkbox" id="fh_gpep" name="fh_gpep"
						<%=props.getProperty("fh_gpep", "")%>
						onclick="fn_enableDisableFields(this, 'fh_g_t', 'fh_p_t', 'fh_ep_t', 'fh_a_t', 'fh_l_t');" />
						G: <%=props.getProperty("fh_g_t", "")%> 
						P: <%=props.getProperty("fh_p_t", "")%>
						EP: <%=props.getProperty("fh_ep_t", "")%> 
						A: <%=props.getProperty("fh_a_t", "")%> 
						L: <%=props.getProperty("fh_l_t", "")%> 
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "fh_preg_with_cur")){ %><div class="div_section_field" >
						<input type="checkbox" id="fh_preg_with_cur" name="fh_preg_with_cur"
						<%=props.getProperty("fh_preg_with_cur", "")%>
						onclick="fn_enableDisableFields(this, 'fh_preg_with_cur_t');" />
						# Pregnancies with current partner: <%=props.getProperty("fh_preg_with_cur_t", "")%>
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "fh_preg_with_prev")){ %><div class="div_section_field" >
						<input type="checkbox" id="fh_preg_with_prev" name="fh_preg_with_prev"
						<%=props.getProperty("fh_preg_with_prev", "")%>
						onclick="fn_enableDisableFields(this, 'fh_preg_with_prev_t');" />
						# Pregnancies with previous partner: <%=props.getProperty("fh_preg_with_prev_t", "")%>
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "fh_female_factor")){ %><div class="div_section_field" >
						<input type="checkbox" id="fh_female_factor" name="fh_female_factor"
						<%=props.getProperty("fh_female_factor", "")%>
						onclick="fn_enableDisableFields(this, 'fh_female_factor_t');" />
						Female factor(s) identified: <%=props.getProperty("fh_female_factor_t", "")%>
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "fh_gynec")){ %><div class="div_section_field" >
						<input type="checkbox" id="fh_gynec" name="fh_gynec"
						<%=props.getProperty("fh_gynec", "")%>
						onclick="fn_enableDisableFields(this, 'fh_gynec_t');" />
						Gynecologist: <%=props.getProperty("fh_gynec_t", "")%>
						</div><%} %>
						
						</div>
					</td>
				</tr>
				
				<%if(!isSectionFieldEmpty(props, "fh_other")){ %>
				<tr>
					<td><%=props.getProperty("fh_other", "")%></td>
				</tr>
				<%} %>
			</table>
		</td>
	</tr>
	<%} %>
	
	<%if(!isSectionEmpty(props, "pft")) {%>
	<tr class="tr_seperator"><td></td></tr>
	<tr class="tr_section_header" >
		<td>Previous Fertility Treatments
		</td>
	</tr>
	<tr>
		<td colspan="2">
			<!-- Previous Fertility Treatments - pft -->
			<table id="table_female_history" width="100%">
				<tr>
					<td>
						<div>
						<%if(!isSectionFieldEmpty(props, "pft_ovul_induct")){ %><div class="div_section_field" >
						<input type="checkbox" id="pft_ovul_induct" name="pft_ovul_induct"
						<%=props.getProperty("pft_ovul_induct", "")%>
						onclick="fn_enableDisableFields(this, 'pft_ovul_induct_t');" />
						Ovulation induction: <%=props.getProperty("pft_ovul_induct_t", "")%>
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "pft_superov_IUI")){ %><div class="div_section_field" >
						<input type="checkbox" id="pft_superov_IUI" name="pft_superov_IUI"
						<%=props.getProperty("pft_superov_IUI", "")%>
						onclick="fn_enableDisableFields(this, 'pft_superov_IUI_t');" />
						Superovulation and IUI: <%=props.getProperty("pft_superov_IUI_t", "")%>
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "pft_IUI")){ %><div class="div_section_field" >
						<input type="checkbox" id="pft_IUI" name="pft_IUI"
						<%=props.getProperty("pft_IUI", "")%>
						onclick="fn_enableDisableFields(this, 'pft_IUI_t');" />
						IUI: <%=props.getProperty("pft_IUI_t", "")%>
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "pft_IVF")){ %><div class="div_section_field" >
						<input type="checkbox" id="pft_IVF" name="pft_IVF"
						<%=props.getProperty("pft_IVF", "")%>
						onclick="fn_enableDisableFields(this, 'pft_IVF_t');" />
						IVF: <%=props.getProperty("pft_IVF_t", "")%>
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "pft_IVF_ICSI")){ %><div class="div_section_field" >
						<input type="checkbox" id="pft_IVF_ICSI" name="pft_IVF_ICSI"
						<%=props.getProperty("pft_IVF_ICSI", "")%>
						onclick="fn_enableDisableFields(this, 'pft_IVF_ICSI_t');" />
						IVF with ICSI: <%=props.getProperty("pft_IVF_ICSI_t", "")%>
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "pft_donor_sperm_ins")){ %><div class="div_section_field" >
						<input type="checkbox" id="pft_donor_sperm_ins" name="pft_donor_sperm_ins"
						<%=props.getProperty("pft_donor_sperm_ins", "")%>/>
						Donor sperm insemination
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "pft_HMG")){ %><div class="div_section_field" >
						<input type="checkbox" id="pft_HMG" name="pft_HMG"
						<%=props.getProperty("pft_HMG", "")%>
						onclick="fn_enableDisableFields(this, 'pft_HMG_t');" />
						HMG: <%=props.getProperty("pft_HMG_t", "")%>
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "pft_HCG")){ %><div class="div_section_field" >
						<input type="checkbox" id="pft_HCG" name="pft_HCG"
						<%=props.getProperty("pft_HCG", "")%>
						onclick="fn_enableDisableFields(this, 'pft_HCG_t');" />
						HCG: <%=props.getProperty("pft_HCG_t", "")%>
						</div><%} %>
						
						</div>
					</td>
				</tr>
				
				<%if(!isSectionFieldEmpty(props, "pft_other")){ %>
				<tr>
					<td><%=props.getProperty("pft_other", "")%></td>
				</tr>
				<%} %>
				
			</table>
		</td>
	</tr>
	<%} %>
	
	<%if(!isSectionEmpty(props, "pem")) {%>
	<tr class="tr_seperator"><td></td></tr>
	<tr class="tr_section_header" >
		<td>Physical Exam - Male
		</td>
	</tr>
	<tr>
		<td colspan="2">
			<!-- Physical Exam - Male - pem -->
			<table id="table_female_history" width="100%">
				<tr>
					<td>
						<div>
						<%if(!isSectionFieldEmpty(props, "pem_ht")){ %><div class="div_section_field" >
						<input type="checkbox" id="pem_ht" name="pem_ht"
						<%=props.getProperty("pem_ht", "")%>
						onclick="fn_enableDisableFields(this, 'pem_ht_t');" />
						Ht: <%=props.getProperty("pem_ht_t", "")%> <%=props.getProperty("pem_ht_feet_inch", "")%> <%=props.getProperty("pem_ht_t_inch", "")%>
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "pem_wt")){ %><div class="div_section_field" >
						<input type="checkbox" id="pem_wt" name="pem_wt"
						<%=props.getProperty("pem_wt", "")%>
						onclick="fn_enableDisableFields(this, 'pem_wt_t');" />
						Wt: <%=props.getProperty("pem_wt_t", "")%> <%=props.getProperty("pem_wt_cmb", "")%>
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "pem_BMI")){ %><div class="div_section_field" >
						<input type="checkbox" id="pem_BMI" name="pem_BMI"
						<%=props.getProperty("pem_BMI", "")%>
						onclick="fn_enableDisableFields(this, 'pem_BMI_t');" />
						BMI: <%=props.getProperty("pem_BMI_t", "")%>
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "pem_BP")){ %><div class="div_section_field" >
						<input type="checkbox" id="pem_BP" name="pem_BP"
						<%=props.getProperty("pem_BP", "")%>
						onclick="fn_enableDisableFields(this, 'pem_BP_t');" />
						BP: <%=props.getProperty("pem_BP_t", "")%>
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "pem_normal_gen_phy")){ %><div class="div_section_field" >
						<input type="checkbox" id="pem_normal_gen_phy" name="pem_normal_gen_phy"
						<%=props.getProperty("pem_normal_gen_phy", "")%>/>
						Normal general physical exam  
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "pem_normal_gen_phy")){ %><div class="div_section_field" >
						<input type="checkbox" id="pem_normal_gen_phy" name="pem_normal_gen_phy"
						<%=props.getProperty("pem_normal_gen_phy", "")%>/>
						Normal general physical exam  
						 </div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "pem_normal_andro")){ %><div class="div_section_field" > 
						<input type="checkbox" id="pem_normal_andro" name="pem_normal_andro"
						<%=props.getProperty("pem_normal_andro", "")%>/>
						Normal androgenization 
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "pem_gen_phys_exam_fi")){ %><div class="div_section_field" >
						<input type="checkbox" id="pem_gen_phys_exam_fi" name="pem_gen_phys_exam_fi" 
						<%=props.getProperty("pem_gen_phys_exam_fi", "")%>
						onclick="fn_enableDisableFields(this, 'pem_gen_phys_exam_fi_t');" />
						General physical exam findings: <%=props.getProperty("pem_gen_phys_exam_fi_t", "")%>
						</div><%} %>
						
						</div>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	<%} %>
	
	<%if(!isSectionEmpty(props, "pemp")) {%>
	<!-- <tr class="tr_seperator"><td></td></tr>
	<tr class="tr_section_header" >
		<td>Physical Exam - Male Partner
		</td>
	</tr> -->
	<tr>
		<td colspan="2">
			<!-- Physical Exam - Male Partner - pemp -->
			<table id="table_pemp" width="100%">
				<!-- <thead>
					<tr>
						<td width="35%">Left Testicle</td>
						<td width="35%">Right Testicle</td>
						<td width="30">&nbsp;</td>
					</tr>
				</thead> -->
				
				<%if(!isSectionFieldEmpty(props, "pemp_l_size") || 
						!isSectionFieldEmpty(props, "pemp_l_vas") ||
						!isSectionFieldEmpty(props, "pemp_l_varic_grade")){ %>
				<tr>
					<td>Left Testicle</td>
				</tr>
				<tr>
					<td>
					<div>
						<%if(!isSectionFieldEmpty(props, "pemp_l_size")){ %>
							<div class="div_section_field" >
							<input type="checkbox" id="pemp_l_size" name="pemp_l_size"
							<%=props.getProperty("pemp_l_size", "")%>
							onclick="fn_enableDisableFields(this, 'pemp_l_size_t');" />
							Size: <%=props.getProperty("pemp_l_size_t", "")%>
							</div>
						<%} %>
							
						<%if(!isSectionFieldEmpty(props, "pemp_l_vas")){ %><div class="div_section_field" >
								<input type="checkbox" id="pemp_l_vas" name="pemp_l_vas"
								<%=props.getProperty("pemp_l_vas", "")%>
								onclick="fn_enableDisableFields(this, 'pemp_l_vas_t');" />
								Vas: <%=props.getProperty("pemp_l_vas_t", "")%></div>
						<%} %>
						
						<%if(!isSectionFieldEmpty(props, "pemp_l_varic_grade")){ %><div class="div_section_field" >
								<input type="checkbox" id="pemp_l_varic_grade" name="pemp_l_varic_grade"
								<%=props.getProperty("pemp_l_varic_grade", "")%>
								onclick="fn_enableDisableFields(this, 'pemp_l_varic_grade_t');" />
								Varicocele grade: <%=props.getProperty("pemp_l_varic_grade_t", "")%>
								</div>
						<%} %>
					</div>
					</td>
				</tr>
				<%} %>
				
				<%if(!isSectionFieldEmpty(props, "pemp_r_size") || 
						!isSectionFieldEmpty(props, "pemp_r_vas") ||
						!isSectionFieldEmpty(props, "pemp_r_varic_grade")){ %>
				<tr>
					<td>Right Testicle</td>
				</tr>
				<tr>
					<td>
					<div>
						<%if(!isSectionFieldEmpty(props, "pemp_r_size")){ %><div class="div_section_field" >
								<input type="checkbox" id="pemp_r_size" name="pemp_r_size"
								<%=props.getProperty("pemp_r_size", "")%>
								onclick="fn_enableDisableFields(this, 'pemp_r_size_t');" />
								Size: <%=props.getProperty("pemp_r_size_t", "")%></div>
						<%} %>
						<%if(!isSectionFieldEmpty(props, "pemp_r_vas")){ %><div class="div_section_field" >
								<input type="checkbox" id="pemp_r_vas" name="pemp_r_vas"
								<%=props.getProperty("pemp_r_vas", "")%>
								onclick="fn_enableDisableFields(this, 'pemp_r_vas_t');" />
								Vas: <%=props.getProperty("pemp_r_vas_t", "")%></div>
						<%} %>
						<%if(!isSectionFieldEmpty(props, "pemp_r_varic_grade")){ %><div class="div_section_field" >
								<input type="checkbox" id="pemp_r_varic_grade" name="pemp_r_varic_grade"
								<%=props.getProperty("pemp_r_varic_grade", "")%>
								onclick="fn_enableDisableFields(this, 'pemp_r_varic_grade_t');" />
								Varicocele grade: <%=props.getProperty("pemp_r_varic_grade_t", "")%></div>
						<%} %>
				</div>
				</td>
				</tr>
				<%} %>				
				
				<%if(!isSectionFieldEmpty(props, "pemp_other")){ %>
				<tr>
					<td><%=props.getProperty("pemp_other", "")%></td>
				</tr>
				<%} %>			
			</table>
		</td>
	</tr>
	<%} %>
	
	<%if(!isSectionEmpty(props, "impr")) {%>
	<tr class="tr_seperator"><td></td></tr>
	<tr class="tr_section_header" >
		<td>Impression
		</td>
	</tr>
	<tr>
		<td colspan="2">
			<!-- Impression - impr -->
			<table id="table_impr" width="100%">
				<tr>
					<td>
						<div>
						<%if(!isSectionFieldEmpty(props, "impr_prim_infer_eti")){ %><div class="div_section_field" >
						<input type="checkbox" id="impr_prim_infer_eti" name="impr_prim_infer_eti"
						<%=props.getProperty("impr_prim_infer_eti", "")%>/>
						Primary infertility, etiology not yet determined
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "impr_secon_infer_eti")){ %><div class="div_section_field" >
						<input type="checkbox" id="impr_secon_infer_eti" name="impr_secon_infer_eti"
						<%=props.getProperty("impr_secon_infer_eti", "")%>/>
						Secondary infertility, etiology not yet determined
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "impr_male_factor_inf")){ %><div class="div_section_field" >
						<input type="checkbox" id="impr_male_factor_inf" name="impr_male_factor_inf"
						<%=props.getProperty("impr_male_factor_inf", "")%>/>
						Male factor infertility caused by gonadotoxic exposures
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "impr_oligospe")){ %><div class="div_section_field" >
						<input type="checkbox" id="impr_oligospe" name="impr_oligospe"
						<%=props.getProperty("impr_oligospe", "")%>/>
						Oligospermia
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "impr_oligo_asth")){ %><div class="div_section_field" >
						<input type="checkbox" id="impr_oligo_asth" name="impr_oligo_asth"
						<%=props.getProperty("impr_oligo_asth", "")%>/>
						Oligo-asthenospermia
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "impr_astheno")){ %><div class="div_section_field" >
						<input type="checkbox" id="impr_astheno" name="impr_astheno"
						<%=props.getProperty("impr_astheno", "")%>/>
						Asthenospermia
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "impr_terato")){ %><div class="div_section_field" >
						<input type="checkbox" id="impr_terato" name="impr_terato"
						<%=props.getProperty("impr_terato", "")%>/>
						Teratospermia
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "impr_oligo_ast_tera")){ %><div class="div_section_field" >
						<input type="checkbox" id="impr_oligo_ast_tera" name="impr_oligo_ast_tera"
						<%=props.getProperty("impr_oligo_ast_tera", "")%>/>
						Oligo-astheno-teratospermia
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "impr_advan_pat_age")){ %><div class="div_section_field" >
						<input type="checkbox" id="impr_advan_pat_age" name="impr_advan_pat_age"
						<%=props.getProperty("impr_advan_pat_age", "")%>/>
						Advanced paternal age
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "impr_coital_fact_inf")){ %><div class="div_section_field" >
						<input type="checkbox" id="impr_coital_fact_inf" name="impr_coital_fact_inf"
						<%=props.getProperty("impr_coital_fact_inf", "")%>/>
						Coital factor infertility
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "impr_erectile_dys")){ %><div class="div_section_field" >
						<input type="checkbox" id="impr_erectile_dys" name="impr_erectile_dys"
						<%=props.getProperty("impr_erectile_dys", "")%>/>
						Erectile dysfunction
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "impr_retro_ejac")){ %><div class="div_section_field" >
						<input type="checkbox" id="impr_retro_ejac" name="impr_retro_ejac"
						<%=props.getProperty("impr_retro_ejac", "")%>/>
						Retrograde ejaculation
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "impr_varico")){ %><div class="div_section_field" >
						<input type="checkbox" id="impr_varico" name="impr_varico"
						<%=props.getProperty("impr_varico", "")%>/>
						Varicocele (s)
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "impr_hypot_dysf")){ %><div class="div_section_field" >
						<input type="checkbox" id="impr_hypot_dysf" name="impr_hypot_dysf"
						<%=props.getProperty("impr_hypot_dysf", "")%>/>
						Hypothalamic dysfunction
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "impr_test_fail")){ %><div class="div_section_field" >
						<input type="checkbox" id="impr_test_fail" name="impr_test_fail"
						<%=props.getProperty("impr_test_fail", "")%>/>
						Testicular failure
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "impr_y_microd")){ %><div class="div_section_field" >
						<input type="checkbox" id="impr_y_microd" name="impr_y_microd"
						<%=props.getProperty("impr_y_microd", "")%>/>
						Y microdeletion
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "impr_kline_syndr")){ %><div class="div_section_field" >
						<input type="checkbox" id="impr_kline_syndr" name="impr_kline_syndr"
						<%=props.getProperty("impr_kline_syndr", "")%>/>
						Klinefelter's syndrome
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "impr_cong_bil_abs")){ %><div class="div_section_field" >
						<input type="checkbox" id="impr_cong_bil_abs" name="impr_cong_bil_abs"
						<%=props.getProperty("impr_cong_bil_abs", "")%>/>
						Congenital bilateral absence of the vas
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "impr_azoospermia")){ %><div class="div_section_field" >
						<input type="checkbox" id="impr_azoospermia" name="impr_azoospermia"
						<%=props.getProperty("impr_azoospermia", "")%>/>
						Azoospermia
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "impr_obstr_azoo")){ %><div class="div_section_field" >
						<input type="checkbox" id="impr_obstr_azoo" name="impr_obstr_azoo"
						<%=props.getProperty("impr_obstr_azoo", "")%>/>
						Obstructive azoospermia
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "impr_non_obstr_azoo")){ %><div class="div_section_field" >
						<input type="checkbox" id="impr_non_obstr_azoo" name="impr_non_obstr_azoo"
						<%=props.getProperty("impr_non_obstr_azoo", "")%>/>
						Non-obstructive azoospermia
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "impr_epid_obstr")){ %><div class="div_section_field" >
						<input type="checkbox" id="impr_epid_obstr" name="impr_epid_obstr"
						<%=props.getProperty("impr_epid_obstr", "")%>/>
						Epididymal obstruction
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "impr_male_obe")){ %><div class="div_section_field" >
						<input type="checkbox" id="impr_male_obe" name="impr_male_obe"
						<%=props.getProperty("impr_male_obe", "")%>/>
						Male obesity
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "impr_hyperprola")){ %><div class="div_section_field" >
						<input type="checkbox" id="impr_hyperprola" name="impr_hyperprola"
						<%=props.getProperty("impr_hyperprola", "")%>/>
						Hyperprolactinemia
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "impr_req_sperm_cry")){ %><div class="div_section_field" >
						<input type="checkbox" id="impr_req_sperm_cry"  name="impr_req_sperm_cry"
						<%=props.getProperty("impr_req_sperm_cry", "")%>
						onclick="fn_enableDisableFields(this, 'impr_req_sperm_cry_t');" />
						Request for sperm cryopreservation: <%=props.getProperty("impr_req_sperm_cry_t", "")%>
						</div><%} %>
						
						</div>
					</td>
				</tr>
				
				<%if(!isSectionFieldEmpty(props, "impr_other")){ %>
				<tr>
					<td><%=props.getProperty("impr_other", "")%></td>
				</tr>
				<%} %>
			</table>
		</td>
	</tr>
	<%} %>
	
	<%if(!isSectionEmpty(props, "optd")) {%>
	<tr class="tr_seperator"><td></td></tr>
	<tr class="tr_section_header" >
		<td>Options Discussed
		</td>
	</tr>
	<tr>
		<td colspan="2">
			<!-- Options Discussed - optd -->
			<table id="table_optd" width="100%">
				<tr>
					<td>
						<div>
						<%if(!isSectionFieldEmpty(props, "optd_expec_manage")){ %><div class="div_section_field" >
						<input type="checkbox" id="optd_expec_manage" name="optd_expec_manage"
						<%=props.getProperty("optd_expec_manage", "")%>/>
						Expectant management
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "optd_superov_intr")){ %><div class="div_section_field" >
						<input type="checkbox" id="optd_superov_intr" name="optd_superov_intr"
						<%=props.getProperty("optd_superov_intr", "")%>/>
						Superovulation and intrauterine insemination
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "optd_IVF_ICSI")){ %><div class="div_section_field" >
						<input type="checkbox" id="optd_IVF_ICSI" name="optd_IVF_ICSI"
						<%=props.getProperty("optd_IVF_ICSI", "")%>/>
						IVF with ICSI
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "optd_IVF_ICSI_test")){ %><div class="div_section_field" >
						<input type="checkbox" id="optd_IVF_ICSI_test" name="optd_IVF_ICSI_test"
						<%=props.getProperty("optd_IVF_ICSI_test", "")%>/>
						IVF with ICSI and testicular sperm extraction
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "optd_IVF_ICSI_micro")){ %><div class="div_section_field" >
						<input type="checkbox" id="optd_IVF_ICSI_micro" name="optd_IVF_ICSI_micro"
						<%=props.getProperty("optd_IVF_ICSI_micro", "")%>/>
						IVF with ICSI and micro-testicular sperm extraction
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "optd_scrotal_exp_pos")){ %><div class="div_section_field" >
						<input type="checkbox" id="optd_scrotal_exp_pos" name="optd_scrotal_exp_pos"
						<%=props.getProperty("optd_scrotal_exp_pos", "")%>/>
						Scrotal exploration with possible vasoepididymostomy
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "optd_vasec_reve")){ %><div class="div_section_field" >
						<input type="checkbox" id="optd_vasec_reve" name="optd_vasec_reve"
						<%=props.getProperty("optd_vasec_reve", "")%>/>
						Vasectomy revearsal
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "optd_vari_rep")){ %><div class="div_section_field" >
						<input type="checkbox" id="optd_vari_rep" name="optd_vari_rep"
						<%=props.getProperty("optd_vari_rep", "")%>/>
						Varicocele repair
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "optd_gonado_ther")){ %><div class="div_section_field" >
						<input type="checkbox" id="optd_gonado_ther" name="optd_gonado_ther"
						<%=props.getProperty("optd_gonado_ther", "")%>/>
						Gonadotropin therapy
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "optd_clomi_ther")){ %><div class="div_section_field" >
						<input type="checkbox" id="optd_clomi_ther" name="optd_clomi_ther"
						<%=props.getProperty("optd_clomi_ther", "")%>/>
						Clomiphene therapy
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "optd_antic_ther")){ %><div class="div_section_field" >
						<input type="checkbox" id="optd_antic_ther"  name="optd_antic_ther"
						<%=props.getProperty("optd_antic_ther", "")%>
						onclick="fn_enableDisableFields(this, 'optd_antic_ther_t');" />
						Anticholinergic therapy with: <%=props.getProperty("optd_antic_ther_t", "")%>
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "optd_donor_sperm_ins")){ %><div class="div_section_field" >
						<input type="checkbox" id="optd_donor_sperm_ins" name="optd_donor_sperm_ins"
						<%=props.getProperty("optd_donor_sperm_ins", "")%>/>
						Donor sperm insemination
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "optd_lifestyle_ch")){ %><div class="div_section_field" >
						<input type="checkbox" id="optd_lifestyle_ch" name="optd_lifestyle_ch"
						<%=props.getProperty("optd_lifestyle_ch", "")%>/>
						Lifestyle changes
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "optd_weight_loss")){ %><div class="div_section_field" >
						<input type="checkbox" id="optd_weight_loss" name="optd_weight_loss"
						<%=props.getProperty("optd_weight_loss", "")%>/>
						Weight loss
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "optd_adoption")){ %><div class="div_section_field" >
						<input type="checkbox" id="optd_adoption" name="optd_adoption"
						<%=props.getProperty("optd_adoption", "")%>/>
						Adoption
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "optd_sperm_cryopr")){ %><div class="div_section_field" >
						<input type="checkbox" id="optd_sperm_cryopr" name="optd_sperm_cryopr"
						<%=props.getProperty("optd_sperm_cryopr", "")%>/>
						Sperm cryopreservation
						</div><%} %>
						</div>
					</td>
				</tr>
				
				<%if(!isSectionFieldEmpty(props, "optd_other")){ %>
				<tr>
					<td><%=props.getProperty("optd_other", "")%></td>
				</tr>
				<%} %>
			</table>
		</td>
	</tr>
	<%} %>
	
	<%if(!isSectionEmpty(props, "invo")) {%>
	<tr class="tr_seperator"><td></td></tr>
	<tr class="tr_section_header" >
		<td>Investigations Ordered
		</td>
	</tr>
	<tr>
		<td colspan="2">
			<!-- Investigations Ordered - invo -->
			<table id="table_invo" width="100%">
				<tr>
					<td>
						<div>
						<%if(!isSectionFieldEmpty(props, "invo_horm_prof")){ %><div class="div_section_field" >						
						<input type="checkbox" id="invo_horm_prof" name="invo_horm_prof"
						<%=props.getProperty("invo_horm_prof", "")%>/>
						Hormonal profile
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "invo_semen_analysis")){ %><div class="div_section_field" >
						<input type="checkbox" id="invo_semen_analysis" name="invo_semen_analysis"
						<%=props.getProperty("invo_semen_analysis", "")%>/>
						Semen analysis
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "invo_repeat_semen")){ %><div class="div_section_field" >
						<input type="checkbox" id="invo_repeat_semen" name="invo_repeat_semen"
						<%=props.getProperty("invo_repeat_semen", "")%>/>
						Repeat semen analysis
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "invo_kruger_semen")){ %><div class="div_section_field" >
						<input type="checkbox" id="invo_kruger_semen" name="invo_kruger_semen"
						<%=props.getProperty("invo_kruger_semen", "")%>/>
						Kruger semen analysis
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "invo_DNA_frag")){ %><div class="div_section_field" >
						<input type="checkbox" id="invo_DNA_frag" name="invo_DNA_frag"
						<%=props.getProperty("invo_DNA_frag", "")%>/>
						DNA Fragmentation
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "invo_scrotal_ultra")){ %><div class="div_section_field" >
						<input type="checkbox" id="invo_scrotal_ultra" name="invo_scrotal_ultra"
						<%=props.getProperty("invo_scrotal_ultra", "")%>/>
						Scrotal ultrasound
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "invo_trans_ultr")){ %><div class="div_section_field" >
						<input type="checkbox" id="invo_trans_ultr" name="invo_trans_ultr"
						<%=props.getProperty("invo_trans_ultr", "")%>/>
						Transrectal ultrasound
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "invo_male_CF")){ %><div class="div_section_field" >
						<input type="checkbox" id="invo_male_CF" name="invo_male_CF"
						<%=props.getProperty("invo_male_CF", "")%>/>
						Male CF testing
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "invo_y_micro")){ %><div class="div_section_field" >
						<input type="checkbox" id="invo_y_micro" name="invo_y_micro"
						<%=props.getProperty("invo_y_micro", "")%>/>
						Y microdeletion
						 </div><%} %>
						 
						<%if(!isSectionFieldEmpty(props, "invo_karyotype")){ %><div class="div_section_field" >
						<input type="checkbox" id="invo_karyotype" name="invo_karyotype"
						<%=props.getProperty("invo_karyotype", "")%>/>
						Karyotype
						 </div><%} %>
						 
						<%if(!isSectionFieldEmpty(props, "invo_head_MRI")){ %><div class="div_section_field" >
						<input type="checkbox" id="invo_head_MRI" name="invo_head_MRI"
						<%=props.getProperty("invo_head_MRI", "")%>/>
						Head MRI
						</div><%} %>
						
						</div>
					</td>
				</tr>
				<%if(!isSectionFieldEmpty(props, "invo_other")){ %>
				<tr>
					<td><%=props.getProperty("invo_other", "")%></td>
				</tr>
				<%} %>
			</table>
		</td>
	</tr>
	<%} %>
	
	<%if(!isSectionEmpty(props, "trtp")) {%>
	<tr class="tr_seperator"><td></td></tr>
	<tr class="tr_section_header" >
		<td>Treatment Plan
		</td>
	</tr>
	<tr>
		<td colspan="2">
			<!-- Treatment Plan - trtp -->
			<table id="table_trtp" width="100%">
				<tr>
					<td>
						<div>
						<%if(!isSectionFieldEmpty(props, "trtp_expe_manage")){ %><div class="div_section_field" >
						<input type="checkbox" id="trtp_expe_manage"  name="trtp_expe_manage"
						<%=props.getProperty("trtp_expe_manage", "")%>
						onclick="fn_enableDisableFields(this, 'trtp_expe_manage_t');" />
						Expectant management: <%=props.getProperty("trtp_expe_manage_t", "")%>
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "trtp_superov_intr")){ %><div class="div_section_field" >
						<input type="checkbox" id="trtp_superov_intr" name="trtp_superov_intr"
						<%=props.getProperty("trtp_superov_intr", "")%>/>
						Superovulation and intrauterine insemination
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "trtp_IVF_ICSI")){ %><div class="div_section_field" >
						<input type="checkbox" id="trtp_IVF_ICSI" name="trtp_IVF_ICSI"
						<%=props.getProperty("trtp_IVF_ICSI", "")%>/>
						IVF with ICSI
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "trtp_IVF_ICSI_test")){ %><div class="div_section_field" >
						<input type="checkbox" id="trtp_IVF_ICSI_test" name="trtp_IVF_ICSI_test"
						<%=props.getProperty("trtp_IVF_ICSI_test", "")%>/>
						IVF with ICSI and testicular sperm extraction
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "trtp_IVF_ICSI_micro")){ %><div class="div_section_field" >
						<input type="checkbox" id="trtp_IVF_ICSI_micro" name="trtp_IVF_ICSI_micro"
						<%=props.getProperty("trtp_IVF_ICSI_micro", "")%>/>
						IVF with ICSI and micro-testicular sperm extraction
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "trtp_donor_sperm_ins")){ %><div class="div_section_field" >
						<input type="checkbox" id="trtp_donor_sperm_ins" name="trtp_donor_sperm_ins"
						<%=props.getProperty("trtp_donor_sperm_ins", "")%>/>
						Donor sperm insemination
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "trtp_vasec_rev")){ %><div class="div_section_field" >
						<input type="checkbox" id="trtp_vasec_rev" name="trtp_vasec_rev"
						<%=props.getProperty("trtp_vasec_rev", "")%>/>
						Vasectomy reversal
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "trtp_lifestyle_ch")){ %><div class="div_section_field" >
						<input type="checkbox" id="trtp_lifestyle_ch" name="trtp_lifestyle_ch"
						<%=props.getProperty("trtp_lifestyle_ch", "")%>/>
						Lifestyle changes
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "trtp_weight_loss")){ %><div class="div_section_field" >
						<input type="checkbox" id="trtp_weight_loss" name="trtp_weight_loss"
						<%=props.getProperty("trtp_weight_loss", "")%>/>
						Weight loss
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "trtp_adoption")){ %><div class="div_section_field" >
						<input type="checkbox" id="trtp_adoption" name="trtp_adoption"
						<%=props.getProperty("trtp_adoption", "")%>/>
						Adoption
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "trtp_sperm_cry")){ %><div class="div_section_field" >
						<input type="checkbox" id="trtp_sperm_cry" name="trtp_sperm_cry"
						<%=props.getProperty("trtp_sperm_cry", "")%>/>
						Sperm cryopreservation
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "trtp_varic_rep")){ %><div class="div_section_field" >
						<input type="checkbox" id="trtp_varic_rep" name="trtp_varic_rep"
						<%=props.getProperty("trtp_varic_rep", "")%>/>
						Varicocele repair
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "trtp_clomi_ther")){ %><div class="div_section_field" >
						<input type="checkbox" id="trtp_clomi_ther"  name="trtp_clomi_ther"
						<%=props.getProperty("trtp_clomi_ther", "")%>
						onclick="fn_enableDisableFields(this, 'trtp_clomi_ther_t');" />
						Clomiphene therapy: <%=props.getProperty("trtp_clomi_ther_t", "")%>
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "trtp_gona_ther")){ %><div class="div_section_field" >
						<input type="checkbox" id="trtp_gona_ther"  name="trtp_gona_ther"
						<%=props.getProperty("trtp_gona_ther", "")%>
						onclick="fn_enableDisableFields(this, 'trtp_gona_ther_t');" />
						Gonadotropin therapy: <%=props.getProperty("trtp_gona_ther_t", "")%>
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "trtp_anticho_ther")){ %><div class="div_section_field" >
						<input type="checkbox" id="trtp_anticho_ther"  name="trtp_anticho_ther"
						<%=props.getProperty("trtp_anticho_ther", "")%>
						onclick="fn_enableDisableFields(this, 'trtp_anticho_ther_t');" />
						Anticholinergic therapy with: <%=props.getProperty("trtp_anticho_ther_t", "")%>
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "trtp_cialis")){ %><div class="div_section_field" >
						<input type="checkbox" id="trtp_cialis"  name="trtp_cialis"
						<%=props.getProperty("trtp_cialis", "")%>
						onclick="fn_enableDisableFields(this, 'trtp_cialis_t');" />
						Cialis: <%=props.getProperty("trtp_cialis_t", "")%>
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "trtp_viagra")){ %><div class="div_section_field" >
						<input type="checkbox" id="trtp_viagra"  name="trtp_viagra"
						<%=props.getProperty("trtp_viagra", "")%>
						onclick="fn_enableDisableFields(this, 'trtp_viagra_t');" />
						Viagra: <%=props.getProperty("trtp_viagra_t", "")%>
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "trtp_refer_dr")){ %><div class="div_section_field" >
						<input type="checkbox" id="trtp_refer_dr"  name="trtp_refer_dr"
						<%=props.getProperty("trtp_refer_dr", "")%>
						onclick="fn_enableDisableFields(this, 'trtp_refer_dr_t');" />
						Referral to Dr.: <%=props.getProperty("trtp_refer_dr_t", "")%>
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "trtp_refer_reprod")){ %><div class="div_section_field" >
						<input type="checkbox" id="trtp_refer_reprod" name="trtp_refer_reprod"
						<%=props.getProperty("trtp_refer_reprod", "")%>/>
						Referral to a Reproductive Endocrinologist
						</div><%} %>
						
						<%if(!isSectionFieldEmpty(props, "trtp_proceed_invest")){ %><div class="div_section_field" >
						<input type="checkbox" id="trtp_proceed_invest" name="trtp_proceed_invest"
						<%=props.getProperty("trtp_proceed_invest", "")%>/>
						Proceed with investigations and discuss results and potential treatments at follow-up appointment
						</div><%} %>
						
						</div>
					</td>
				</tr>
				
				<%if(!isSectionFieldEmpty(props, "trtp_other")){ %>
				<tr>
					<td><%=props.getProperty("trtp_other", "")%></td>
				</tr>
				<%} %>
			</table>
		</td>
	</tr>
	<%} %>
	
	<tr height="2px"><td colspan="2" style="border-bottom: 1px solid #E5E5E5 !important;"></td></tr>
	
	<%
         String multiLineSignStr = sig.getMultiLineSignature(curUser_no);
	//String multiLineSignStr = sig.getSignature(curUser_no);
         if(multiLineSignStr!=null && multiLineSignStr.trim().length()>0)
         {
        	 multiLineSignStr = multiLineSignStr.replaceAll("\n", "<br>");
        	 %>
        	 <tr>
                <td>
                <div>
                	<br><br>
                	Many thanks for your referral.
                	<br><br>
                	Yours sincerely,
                	<br><br>
                	<%
                	boolean flgElectronicSign = sig.hasElectronicSign(curUser_no);
                	//boolean flgElectronicSign = false;
                	if(flgElectronicSign){
                	%>
	                	<img border="0" src="../admin/signature.jsp?provider_no=<%=curUser_no%>">
	                	<br><br>
                	<%} %>
                	<%=multiLineSignStr %>
                </div>
                </td>
         	 </tr>
        	 <%
         }
         %>
    <tr height="2px"><td>&nbsp;</td></tr>
     
	<tr>
		<td>
			<input type="button" value="Print" onclick="javascript:return onPrint();" />
			<input type="button" value="Exit" onclick="javascript:return onExit();" />
		</td>
	</tr>
</tbody>

</table>
</html:form>
</BODY>
</HTML>
