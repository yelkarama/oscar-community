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

<%@ taglib uri="/WEB-INF/security.tld" prefix="security"%>
<%
    String user = (String) session.getAttribute("user");
    if(session.getAttribute("userrole") == null )  response.sendRedirect("../logout.jsp");
    String roleName2$ = (String)session.getAttribute("userrole") + "," + user;
    boolean authed=true;
%>
<security:oscarSec roleName="<%=roleName2$%>" objectName="_form" rights="r" reverse="<%=true%>">
    <%authed=false; %>
    <%response.sendRedirect("../securityError.jsp?type=_form");%>
</security:oscarSec>
<%
    if(!authed) {
        return;
    }
%>

<%@ page import="oscar.util.*, oscar.form.*, oscar.form.data.*"%>
<%@ page import="org.oscarehr.common.web.PregnancyAction"%>
<%@ page import="java.util.List"%>
<%@ page import="org.apache.struts.util.LabelValueBean"%>
<%@ page import="org.apache.commons.lang.StringEscapeUtils" %>
<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean"%>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html"%>
<%@ taglib uri="/WEB-INF/struts-logic.tld" prefix="logic"%>
<%@page import="org.oscarehr.util.LoggedInInfo"%>
<%@ page import="java.util.HashMap" %>
<%@ page import="oscar.eform.EFormUtil" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="org.oscarehr.common.model.UserProperty" %>
<%@ page import="org.oscarehr.common.dao.UserPropertyDAO" %>
<%@ page import="org.oscarehr.util.SpringUtils" %>
<%@ page import="oscar.form.graphic.FrmGraphicAR" %>


<%
    String formClass = "ONAREnhanced";
    String formLink = "formonarenhancedForm.jsp";

    int demoNo = Integer.parseInt(request.getParameter("demographic_no"));
    int formId = Integer.parseInt(request.getParameter("formId"));
    int provNo = Integer.parseInt((String) session.getAttribute("user"));
    String section = request.getParameter("section")!=null?String.valueOf(request.getParameter("section")):null;

    String pageNo = "";

    String appointment = "";
    if(request.getParameter("appointmentNo")!=null){
        appointment = request.getParameter("appointmentNo");
    }
    FrmRecord rec = (new FrmRecordFactory()).factory(formClass);
    java.util.Properties props = rec.getFormRecord(LoggedInInfo.getLoggedInInfoFromSession(request),demoNo, formId);

    FrmData fd = new FrmData();
    String resource = fd.getResource();
    resource = resource + "../ob/riskinfo/";
    props.setProperty("c_lastVisited", "pg1");

    //get project_home
    String project_home = request.getContextPath().substring(1);

    if(props.getProperty("obxhx_num", "0").equals("")) {props.setProperty("obxhx_num","0");}

    String labReqVer = oscar.OscarProperties.getInstance().getProperty("onare_labreqver","07");
    if(labReqVer.equals("")) {labReqVer="07";}
%>
<%
    boolean bView = false;
    if (request.getParameter("view") != null && request.getParameter("view").equals("1")) bView = true;
%>

<html:html locale="true">
    <head>
        <script type="text/javascript" src="<%= request.getContextPath() %>/js/global.js"></script>
        <title>Antenatal Record 1</title>
        <link rel="stylesheet" type="text/css" href="<%=bView?"arStyleView.css" : "arStyle.css"%>">
        <link rel="stylesheet" type="text/css" media="all" href="../share/calendar/calendar.css" title="win2k-cold-1" />
        <script type="text/javascript" src="../share/calendar/calendar.js"></script>
        <script type="text/javascript" src="../share/calendar/lang/<bean:message key="global.javascript.calendar"/>"></script>
        <script type="text/javascript" src="../share/calendar/calendar-setup.js"></script>

        <script src="<%=request.getContextPath() %>/js/jquery-1.7.1.min.js" type="text/javascript"></script>
        <script src="<%=request.getContextPath()%>/js/jquery-ui-1.8.18.custom.min.js"></script>
        <script src="<%=request.getContextPath()%>/js/fg.menu.js"></script>
        <script type="text/javascript" src="<%=request.getContextPath()%>/js/formonarenhanced.js"></script>

        <link rel="stylesheet" href="<%=request.getContextPath()%>/css/cupertino/jquery-ui-1.8.18.custom.css">
        <link rel="stylesheet" href="<%=request.getContextPath()%>/css/fg.menu.css">
        <link rel="stylesheet" href="<%=request.getContextPath()%>/css/formonarenhanced.css">

        <script type="text/javascript">
            function calcWeek(source) {
                <%
                String fedb = props.getProperty("c_finalEDB", "");

                String sDate = "";
                if (!fedb.equals("") && fedb.length()==10 ) {
                    FrmGraphicAR arG = new FrmGraphicAR();
                    java.util.Date edbDate = arG.getStartDate(fedb);
                    sDate = UtilDateUtilities.DateToString(edbDate, "MMMMM dd, yyyy"); //"yy,MM,dd");
                %>
                var delta = 0;
                var str_date = getDateField(source.name);
                if (str_date.length < 10) return;
                var yyyy = str_date.substring(0, str_date.indexOf("/"));
                var mm = eval(str_date.substring(eval(str_date.indexOf("/")+1), str_date.lastIndexOf("/")) - 1);
                var dd = str_date.substring(eval(str_date.lastIndexOf("/")+1));
                var check_date=new Date(yyyy,mm,dd);
                var start=new Date("<%=sDate%>");

                if (check_date.getUTCHours() != start.getUTCHours()) {
                    if (check_date.getUTCHours() > start.getUTCHours()) {
                        delta = -1 * 60 * 60 * 1000;
                    } else {
                        delta = 1 * 60 * 60 * 1000;
                    }
                }

                var day = eval((check_date.getTime() - start.getTime() + delta) / (24*60*60*1000));
                var week = Math.floor(day/7);
                var weekday = day%7;
                source.value = week + "w+" + weekday;
                <% } %>
            }

            function onExit() {
                <%if(!bView) {%>
                if(confirm("Are you sure you wish to exit without saving your changes?")==true)
                {
                    refreshOpener();
                    window.close();
                }
                return(false);
                <% } else {%>
                window.close();
                return false;
                <% } %>
            }

            function reset() {
                document.forms[0].target = "";
                document.forms[0].action = "/<%=project_home%>/form/formname.do" ;
            }

            function bornResourcesDisplay(selected) {

                var url = '';
                if (selected.selectedIndex == 1) {
                    url = 'http://sogc.org/wp-content/uploads/2013/01/gui261CPG1107E.pdf';
                } else if (selected.selectedIndex == 2) {
                    url = 'http://sogc.org/wp-content/uploads/2013/01/gui217CPG0810.pdf';
                } else if (selected.selectedIndex == 3) {
                    url = 'http://sogc.org/wp-content/uploads/2013/01/gui239ECPG1002.pdf';
                }

                if (url != '') {
                    var win=window.open(url, '_blank');
                    win.focus();
                }
            }



         <%
            if(section!=null){
                if (section.split("-")[0].equals("AR2")){
                    pageNo = "2";
                }
                else {
                    pageNo = "1";
                }
         %>
            $(document).ready(function(){

                window.moveTo(0, 0);
                $("#formContent").load("formonarenhancedpg<%=pageNo%>.jsp?demographic_no=<%=demoNo%>&formId=<%=formId%> #<%=section.split("-")[0]%>", function(){
                    <%  if (section.contains("AR1")){
                            if(section.equalsIgnoreCase("AR1-ILI")){%>
                                $("#AR1-PGI").hide();

                            <%}
                            else if(section.equalsIgnoreCase("AR1-PGI")){%>
                                $("#AR1-ILI").hide();
                            <%}
                    %>
                        $("input[name='pg1_geneticD1']").bind('change',function(){
                            $("input[name='pg1_geneticD']").val($("input[name='pg1_geneticD1']").attr('checked') + "/" + $("input[name='pg1_geneticD2']").attr('checked'));
                        });
                        $("input[name='pg1_geneticD2']").bind('change',function(){
                            $("input[name='pg1_geneticD']").val($("input[name='pg1_geneticD1']").attr('checked') + "/" + $("input[name='pg1_geneticD2']").attr('checked'));
                        });
                        $("select[name='pg1_labHIV']").val('<%= UtilMisc.htmlEscape(props.getProperty("pg1_labHIV", "")) %>');
                        $("select[name='pg1_labABO']").val('<%= UtilMisc.htmlEscape(props.getProperty("pg1_labABO", "")) %>');
                        $("select[name='pg1_labRh']").val('<%= UtilMisc.htmlEscape(props.getProperty("pg1_labRh", "")) %>');
                        $("select[name='pg1_labGC']").val('<%= UtilMisc.htmlEscape(props.getProperty("pg1_labGC", "")) %>');
                        $("select[name='pg1_labChlamydia']").val('<%= UtilMisc.htmlEscape(props.getProperty("pg1_labChlamydia", "")) %>');
                        $("select[name='pg1_labHBsAg']").val('<%= UtilMisc.htmlEscape(props.getProperty("pg1_labHBsAg", "")) %>');
                        $("select[name='pg1_labVDRL']").val('<%= UtilMisc.htmlEscape(props.getProperty("pg1_labVDRL", "")) %>');
                        $("select[name='pg1_labSickle']").val('<%= UtilMisc.htmlEscape(props.getProperty("pg1_labSickle", "")) %>');
                        $("select[name='pg1_labRubella']").val('<%= UtilMisc.htmlEscape(props.getProperty("pg1_labRubella", "")) %>');
                        $("select[name='pg1_geneticA_riskLevel']").val('<%= UtilMisc.htmlEscape(props.getProperty("pg1_geneticA_riskLevel", "")) %>');
                        $("select[name='pg1_geneticB_riskLevel']").val('<%= UtilMisc.htmlEscape(props.getProperty("pg1_geneticB_riskLevel", "")) %>');
                        $("select[name='pg1_geneticC_riskLevel']").val('<%= UtilMisc.htmlEscape(props.getProperty("pg1_geneticC_riskLevel", "")) %>');
                        $("select[name='pg1_labCustom1Label']").val('<%= UtilMisc.htmlEscape(UtilMisc.htmlEscape(props.getProperty("pg1_labCustom1Label", ""))) %>');
                        $("select[name='pg1_labCustom3Result_riskLevel']").val('<%= UtilMisc.htmlEscape(props.getProperty("pg1_labCustom3Result_riskLevel", "")) %>');

                        Calendar.setup({ inputField : "pg1_labLastPapDate", ifFormat : "%Y/%m/%d", showsTime :false, button : "pg1_labLastPapDate_cal", singleClick : true, step : 1 });

                    <% } else {
                        //AR2
                        FrmAREnhancedBloodWorkTest ar1BloodWorkTest = new FrmAREnhancedBloodWorkTest(demoNo, formId);
                        java.util.Properties ar1Props = ar1BloodWorkTest.getAr1Props();
                        String abo = "";
                        String rh ="";
                        if(UtilMisc.htmlEscape(props.getProperty("ar2_bloodGroup", "")).equals("") ){
                            abo = UtilMisc.htmlEscape(ar1Props.getProperty("pg1_labABO", ""));
                        }else{
                            abo = UtilMisc.htmlEscape(props.getProperty("ar2_bloodGroup", ""));
                        }

                        if(section.equalsIgnoreCase("AR2-US")){%>
                            $("#AR2-ALI").hide();

                        <%}
                        else if(section.equalsIgnoreCase("AR2-ALI")){%>
                            $("#AR2-US").hide();
                        <%}

                            String us = props.getProperty("us_num", "0");
                            if(us.length() == 0)
                                us = "0";
                            int usNum = Integer.parseInt(us);
                            for(int x=1;x<usNum+1;x++) { %>
                            jQuery.ajax({url:'onarenhanced_us.jsp?n='+<%=x%>,async:false, success:function(data) {
                                jQuery("#us_container tbody").append(data);
                                setInput(<%=x%>,"ar2_uDate",'<%= StringEscapeUtils.escapeJavaScript(props.getProperty("ar2_uDate"+x, "")) %>');
                                setInput(<%=x%>,"ar2_uGA",'<%= StringEscapeUtils.escapeJavaScript(props.getProperty("ar2_uGA"+x, "")) %>');
                                setInput(<%=x%>,"ar2_uResults",'<%= StringEscapeUtils.escapeJavaScript(props.getProperty("ar2_uResults"+x, "")) %>');
                            }});
                            <% }
                            if(usNum == 0) {%>
                            addUltraSound();
                            <% } %>
                            createCalendarSetupOnLoad();
                        $("select[name='ar2_strep']").val('<%= StringEscapeUtils.escapeJavaScript(props.getProperty("ar2_strep", "")) %>');
                        $("select[name='ar2_bloodGroup']").val('<%= abo %>');
                        $("select[name='ar2_rh']").val('<%= StringEscapeUtils.escapeJavaScript(props.getProperty("ar2_rh", "")) %>');
                        $("select[name='ar2_labCustom1Label']").val('<%= StringEscapeUtils.escapeJavaScript(props.getProperty("ar2_labCustom1Label", "")) %>');
                        $("select[name='ar2_labCustom2Label']").val('<%= StringEscapeUtils.escapeJavaScript(props.getProperty("ar2_labCustom2Label", "")) %>');

                    $("input[name='ar2_lab2GTT1']").bind('keyup',function(){
                        $("input[name='ar2_lab2GTT']").val($("input[name='ar2_lab2GTT1']").val() + "/" + $("input[name='ar2_lab2GTT2']").val() + "/" + $("input[name='ar2_lab2GTT3']").val());
                    });
                    $("input[name='ar2_lab2GTT2']").bind('keyup',function(){
                        $("input[name='ar2_lab2GTT']").val($("input[name='ar2_lab2GTT1']").val() + "/" + $("input[name='ar2_lab2GTT2']").val() + "/" + $("input[name='ar2_lab2GTT3']").val());
                    });
                    $("input[name='ar2_lab2GTT3']").bind('keyup',function(){
                        $("input[name='ar2_lab2GTT']").val($("input[name='ar2_lab2GTT1']").val() + "/" + $("input[name='ar2_lab2GTT2']").val() + "/" + $("input[name='ar2_lab2GTT3']").val());
                    });
                        var gttVal = $("input[name='ar2_lab2GTT']").val();
                        if(gttVal.length > 0) {
                            var parts = gttVal.split("/");
                            $("input[name='ar2_lab2GTT1']").val(parts[0]);
                            $("input[name='ar2_lab2GTT2']").val(parts[1]);
                            $("input[name='ar2_lab2GTT3']").val(parts[2]);
                        }
                    <% }%>
                });
            });
         <% }  %>
        </script>
        <html:base />
    </head>

    <body bgproperties="fixed" topmargin="0" leftmargin="1" rightmargin="1">
    <div id="maincontent" style="left: 0px;">
        <div id="content_bar" class="innertube" style="background-color: #c4e9f6">
            <html:form action="/form/formname">
                <div id="formContent">

                </div>

                <input type="hidden" name="c_lastVisited" value=<%=props.getProperty("c_lastVisited", "pg1")%> />
                <input type="hidden" name="formCreated" value="<%= props.getProperty("formCreated", "") %>" />
                <input type="hidden" name="form_link" value="<%=formLink%>" />
                <input type="hidden" name="update" value="true"/>
                <input type="hidden" name="form_class" value="<%=formClass%>" />
                <input type="hidden" name="form_section" value="<%=section%>" />
                <input type="hidden" name="formId" value="<%=formId%>" />
                <input type="hidden" name="demographic_no" value="<%= props.getProperty("demographic_no", "0") %>" />
                <input type="hidden" name="provider_no" value=<%=request.getParameter("provNo")%> />
                <input type="hidden" name="provNo" value="<%= request.getParameter("provNo") %>" />
                <input type="hidden" name="submit" value="exit" />
                <input type="hidden" id="us_num" name="us_num" value="<%= props.getProperty("us_num", "0") %>"/>
                <%if (!bView) { %>
                <input type="submit" value="Save and Exit" onclick="javascript:return onSaveExit();" />
                <%} %>
                <input type="submit" value="Exit" onclick="javascript:return onExit();" />

            </html:form>

        </div>


    </div>
    </body>



</html:html>

<%!
    String getSelected(String a, String b) {
        if(a.trim().equalsIgnoreCase(b.trim())) {
            return " selected=\"selected\" ";
        }
        return "";
    }
%>
