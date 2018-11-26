
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

<%@ page import="oscar.form.graphic.*, oscar.util.*, oscar.form.*, oscar.form.data.*"%>
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

<%

    String formClass = "ONPerinatal";
    Integer pageNo = 4;
    LoggedInInfo loggedInInfo = LoggedInInfo.getLoggedInInfoFromSession(request);
    int demoNo = Integer.parseInt(request.getParameter("demographic_no"));
    int formId = Integer.parseInt(request.getParameter("formId"));
    int provNo = Integer.parseInt((String) session.getAttribute("user"));
    boolean update = false;
    if (request.getParameter("update")!=null && request.getParameter("update").trim().equals("true")){
        update = true;
    }
    String providerNo = request.getParameter("provider_no") != null ? request.getParameter("provider_no") : loggedInInfo.getLoggedInProviderNo();
    String appointment = request.getParameter("appointmentNo") != null ? request.getParameter("appointmentNo") : "";

    FrmONPerinatalRecord rec = (FrmONPerinatalRecord)(new FrmRecordFactory()).factory(formClass);
    java.util.Properties props = rec.getFormRecord(LoggedInInfo.getLoggedInInfoFromSession(request),demoNo, formId, pageNo);

    FrmData fd = new FrmData();
    String resource = fd.getResource();
    resource = resource + "../ob/riskinfo/";

    //load eform groups
    List<LabelValueBean> cytologyForms = PregnancyAction.getEformsByGroup("Cytology");
    List<LabelValueBean> ultrasoundForms = PregnancyAction.getEformsByGroup("Ultrasound");
    List<LabelValueBean> ipsForms = PregnancyAction.getEformsByGroup("IPS");

    String labReqVer = oscar.OscarProperties.getInstance().getProperty("onare_labreqver", "10");
    if(labReqVer.equals("")) {
        labReqVer = "10";
    }

    String orderByRequest = request.getParameter("orderby");
    String orderBy = "";
    if (orderByRequest == null) orderBy = EFormUtil.NAME;
    else if (orderByRequest.equals("form_subject")) orderBy = EFormUtil.SUBJECT;
    else if (orderByRequest.equals("form_date")) orderBy = EFormUtil.DATE;

    String groupView = request.getParameter("group_view");
    if (groupView == null) {
        UserPropertyDAO userPropDAO = SpringUtils.getBean(UserPropertyDAO.class);
        UserProperty usrProp = userPropDAO.getProp(user, UserProperty.EFORM_FAVOURITE_GROUP);
        if( usrProp != null ) {
            groupView = usrProp.getValue();
        }
        else {
            groupView = "";
        }
    }

    boolean bView = "1".equals(request.getParameter("view"));
%>

<html:html locale="true">
    <head>
        <title>Resources</title>
        <html:base />
        <script src="<%=request.getContextPath()%>/JavaScriptServlet" type="text/javascript"></script>
        <script type="text/javascript" src="<%= request.getContextPath() %>/js/global.js"></script>
        <link rel="stylesheet" type="text/css" href="arStyle.css">
        <link rel="stylesheet" type="text/css" media="all" href="../share/calendar/calendar.css" title="win2k-cold-1" />
        <script type="text/javascript" src="../share/calendar/calendar.js"></script>
        <script type="text/javascript" src="../share/calendar/lang/<bean:message key="global.javascript.calendar"/>"></script>
        <script type="text/javascript" src="../share/calendar/calendar-setup.js"></script>

        <script type="text/javascript" src="../js/jquery-1.7.1.min.js"></script>
        <script src="<%=request.getContextPath()%>/js/jquery-ui-1.8.18.custom.min.js"></script>
        <script src="<%=request.getContextPath()%>/js/fg.menu.js"></script>
        <script type="text/javascript" src="<%=request.getContextPath()%>/js/formONPerinatalRecord.js"></script>
        <script type="text/javascript" src="<%=request.getContextPath()%>/js/formONPerinatalSidebar.js"></script>

        <link rel="stylesheet" href="<%=request.getContextPath()%>/css/cupertino/jquery-ui-1.8.18.custom.css">
        <link rel="stylesheet" href="<%=request.getContextPath() %>/library/bootstrap/3.0.0/css/bootstrap.min.css" />
        <link rel="stylesheet" href="<%=request.getContextPath()%>/css/fg.menu.css">
        <link rel="stylesheet" href="<%=request.getContextPath()%>/css/formONPerinatalRecord.css">

        <script type="text/javascript">
            $(document).ready(function() {
                init(<%=pageNo%>, <%=bView%>);
                dialogs(<%=pageNo%>, <%=bView%>);

                $( "#gct-req-form" ).dialog({
                    autoOpen: false,
                    height: 275,
                    width: 450,
                    modal: true,
                    buttons: {
                        "Generate Requisition": function() {
                            $( this ).dialog( "close" );
                            var gct_hb = $("#gct_hb").attr('checked');
                            var gct_urine = $("#gct_urine").attr('checked');
                            var gct_ab = $("#gct_ab").attr('checked');
                            var gct_glu = $("#gct_glu").attr('checked');
                            var user = '<%=session.getAttribute("user")%>';
                            url = '<%=request.getContextPath()%>/form/formlabreq<%=labReqVer %>.jsp?demographic_no=<%=demoNo%>&formId=0&provNo='+user + '&fromSession=true';
                            var pregUrl = '<%=request.getContextPath()%>/Pregnancy.do?method=createGCTLabReq&demographicNo=<%=demoNo%>&hb='+gct_hb+'&urine='+gct_urine+'&antibody='+gct_ab+'&glucose='+gct_glu;
                            jQuery.ajax({url:pregUrl,async:false, success:function(data) {
                                    popupRequisitionPage(url);
                                }});
                        },
                        Cancel: function() {
                            $( this ).dialog( "close" );
                        }
                    },
                    close: function() {

                    }
                });

                $( "#gtt-req-form" ).dialog({
                    autoOpen: false,
                    height: 275,
                    width: 450,
                    modal: true,
                    buttons: {
                        "Generate Requisition": function() {
                            $( this ).dialog( "close" );
                            var gtt_glu = $("#gtt_glu").attr('checked');
                            var user = '<%=session.getAttribute("user")%>';
                            url = '<%=request.getContextPath()%>/form/formlabreq<%=labReqVer %>.jsp?demographic_no=<%=demoNo%>&formId=0&provNo='+user + '&fromSession=true';
                            var pregUrl = '<%=request.getContextPath()%>/Pregnancy.do?method=createGTTLabReq&demographicNo=<%=demoNo%>&glucose='+gtt_glu;
                            jQuery.ajax({url:pregUrl,async:false, success:function(data) {
                                    popupRequisitionPage(url);
                                }});
                        },
                        Cancel: function() {
                            $( this ).dialog( "close" );
                        }
                    },
                    close: function() {

                    }
                });

                $( "#gbs-req-form" ).dialog({
                    autoOpen: false,
                    height: 275,
                    width: 450,
                    modal: true,
                    buttons: {
                        "Generate Requisition": function() {
                            $( this ).dialog( "close" );
                            var penicillin = $("#penicillin").attr('checked');
                            var demographic = '<%=props.getProperty("demographic_no", "0")%>';
                            var user = '<%=session.getAttribute("user")%>';
                            url = '<%=request.getContextPath()%>/form/formlabreq<%=labReqVer %>.jsp?demographic_no='+demographic+'&formId=0&provNo='+user + '&fromSession=true';
                            jQuery.ajax({url:'<%=request.getContextPath()%>/Pregnancy.do?method=createGBSLabReq&demographicNo='+demographic + '&penicillin='+penicillin,async:false, success:function(data) {
                                    popupRequisitionPage(url);
                                }});
                        },
                        Cancel: function() {
                            $( this ).dialog( "close" );
                        }
                    },
                    close: function() {

                    }
                });

            });

            function loadIPSForms() {
                <%
                if(ipsForms != null && ipsForms.size() > 0) {
                    if(cytologyForms.size() == 1) {
                %>
                popPage('<%=request.getContextPath()%>/eform/efmformadd_data.jsp?fid=<%=ipsForms.get(0).getValue()%>&demographic_no=<%=demoNo%>&appointment=0','ipsform');
                <%
                    } else {
                %>
                $( "#ips-eform-form" ).dialog( "open" );
                <%
                    }
                 } else {
                %>
                alert('No IPS forms configured')
                <% } %>
            }

            function loadUltrasoundForms() {
                <%
                if(ultrasoundForms != null && ultrasoundForms.size() > 0) {
                    if(cytologyForms.size() == 1) {
                %>
                popPage('<%=request.getContextPath()%>/eform/efmformadd_data.jsp?fid=<%=ultrasoundForms.get(0).getValue()%>&demographic_no=<%=demoNo%>&appointment=0','ultrasound');
                <%
                    } else {
                %>
                $( "#ultrasound-eform-form" ).dialog( "open" );
                <%
                    }
                 } else {
                %>
                alert('No Ultrasound forms configured')
                <% } %>
            }

            function gctReq() {
                $( "#gct-req-form" ).dialog( "open" );
                return false;
            }

            function gttReq() {
                $( "#gtt-req-form" ).dialog( "open" );
                return false;
            }

            function gbsReq() {
                $( "#gbs-req-form" ).dialog( "open" );
                return false;
            }
        </script>

    </head>

    <body bgproperties="fixed" topmargin="0" leftmargin="0" rightmargin="0">
    <!-- Sidebar -->
    <div id="framecontent">
        <div class="innertube">
            <div style="text-align:center;font-weight:bold;">Antenatal Pathway</div>
            <br/>
            <div style="text-align:left;">Gest. Age: <span id="gest_age"></span></div>
            <br/>
            <div id="lock_notification">
                <span title="">Viewers: N/A</span>
            </div>
            <div id="lock_req">
                <input id="lock_req_btn" type="button" value="Request Lock" onclick="requestLock();"/>
                <input style="display:none" id="lock_rel_btn" type="button" value="Release Lock" onclick="releaseLock();"/>
            </div>


            <br/><br/>

            <div style="background-color:magenta;border:2px solid black;width:100%;color:black">
                <table style="width:100%" border="0">
                    <tr>
                        <td><b>Visit Checklist</b></td>
                    </tr>
                    <tr id="24wk_visit">
                        <td>24 week Visit<span style="float:right"><img id="24wk_visit_menu" src="../images/right-circle-arrow-Icon.png" border="0"></span></td>
                    </tr>
                    <tr id="35wk_visit">
                        <td>35 week Visit<span style="float:right"><img id="35wk_visit_menu" src="../images/right-circle-arrow-Icon.png" border="0"></span></td>
                    </tr>
                </table>
            </div>

            <div style="background-color:yellow;border:2px solid black;width:100%;color:black">
                <table style="width:100%" border="0">
                    <tr>
                        <td><b>Info</b></td>
                    </tr>
                    <tr>
                        <td>
                            Printing Log
                            <span style="float:right"><img id="print_log_menu" src="../images/right-circle-arrow-Icon.png" border="0"></span>
                        </td>
                    </tr>
                </table>
            </div>

            <div style="background-color:orange;border:2px solid black;width:100%;color:black">
                <table style="width:100%" border="0">
                    <tr>
                        <td><b>Warnings</b></td>
                    </tr>
                    <tr id="edb_warn" style="display:none">
                        <td>Update EDB<span style="float:right"><img id="edb_menu" src="../images/right-circle-arrow-Icon.png" border="0"></span></td>
                    </tr>
                    <tr id="rh_warn" style="display:none">
                        <td>RH Negative</td>
                    </tr>
                    <tr id="rhogam_warn" style="display:none">
                        <td title="Consider Rhogam for pt @ 28 wks. and sooner if bleeding">Consider Rhogam</td>
                    </tr>
                    <tr id="rubella_warn" style="display:none">
                        <td>Rubella Non-Immune</td>
                    </tr>

                    <tr id="hbsag_warn" style="display:none">
                        <td>HepB Surface Antigen</td>
                    </tr>

                    <tr id="hgb_warn" style="display:none">
                        <td>HGB Low</td>
                    </tr>

                    <tr id="gct_warn" style="display:none">
                        <td>Perform 1hr GCT<span style="float:right"><img id="gct_menu" src="../images/right-circle-arrow-Icon.png" border="0"></span></td>
                    </tr>

                    <tr id="gct_diabetes_warn" style="display:none">
                        <td>Gestational Diabetes<span style="float:right"><img id="gd_menu" src="../images/right-circle-arrow-Icon.png" border="0"></span></td>
                    </tr>

                    <tr id="2hrgtt_prompt" style="display:none">
                        <td>GTT Req<span style="float:right"><img id="gtt_menu" src="../images/right-circle-arrow-Icon.png" border="0"></span></td>
                    </tr>

                </table>
            </div>
            <div style="background-color:#00FF00;border:2px solid black;width:100%;color:black">
                <table style="width:100%" border="0">
                    <tr>
                        <td><b>Prompts</b></td>
                    </tr>

                    <tr id="lab_prompt">
                        <td>Labs<span style="float:right"><img id="lab_menu" src="../images/right-circle-arrow-Icon.png" border="0"></span></td>
                    </tr>

                    <tr id="forms_prompt" >
                        <td>Forms<span style="float:right"><img id="forms_menu" src="../images/right-circle-arrow-Icon.png" border="0"></span></td>
                    </tr>
                    <tr id="eforms_prompt" >
                        <td>eForms<span style="float:right"><img id="eforms_menu" src="../images/right-circle-arrow-Icon.png" border="0"></span></td>
                    </tr>

                    <tr id="strep_prompt" style="display:none">
                        <td>GBS<span style="float:right"><img id="gbs_menu" src="../images/right-circle-arrow-Icon.png" border="0"></span></td>
                    </tr>


                    <tr id="fetal_pos_prompt" style="display:none">
                        <td>Assess Fetal Position</td>
                    </tr>
                </table>
            </div>

        </div>
    </div>


    <!-- Form -->
    <div id="maincontent">
        <div id="content_bar" class="innertube">

            <html:form action="/form/ONPerinatal">
                <input type="hidden" id="demographicNo" name="demographicNo" value="<%=demoNo%>" />
                <input type="hidden" id="formId" name="formId" value="<%=formId%>" />
                <input type="hidden" name="provider_no" value=<%=providerNo%> />
                <input type="hidden" id="user" name="provNo" value=<%=provNo%> />
                <input type="hidden" name="update" value="<%=update%>" />
                <input type="hidden" name="method" value="exit" />

                <input type="hidden" name="forwardTo" value="<%=pageNo%>" />
                <input type="hidden" name="pageNo" value="<%=pageNo%>" />
                <input type="hidden" name="formCreated" value="<%= props.getProperty("formCreated", "") %>" />
                <input type="hidden" id="episodeId" name="episodeId" value="<%= props.getProperty("episodeId", "") %>" />

                <input type="hidden" id="printPg1" name="printPg1" value="" />
                <input type="hidden" id="printPg2" name="printPg2" value="" />
                <input type="hidden" id="printPg3" name="printPg3" value="" />
                <input type="hidden" id="printPg4" name="printPg4" value="" />
                <input type="hidden" id="printPg5" name="printPg5" value="" />
                
                <%
                    String historyet = "";
                    if (request.getParameter("historyet") != null) {
                        out.println("<input type=\"hidden\" name=\"historyet\" value=\"" + request.getParameter("historyet") + "\">" );
                        historyet = "&historyet=" + request.getParameter("historyet");
                    }
                %>

                <table class="sectionHeader hidePrint">
                    <tr>
                        <td align="left">
                            <%
                                if (!bView) {
                            %>
                            <input type="submit" value="Save" id="saveBtn" onclick="return onSave();" /> <input type="submit" value="Save and Exit" onclick="return onSaveExit();" />
                            <% } %>

                            <input type="submit" value="Exit" onclick="return onExit();" /> <input type="submit" value="Print" onclick="return onPrint();" />
                            <span style="display:none"><input id="printBtn" type="submit" value="PrintIt"/></span>
                            <%
                                if (!bView) {
                            %>
                            &nbsp;&nbsp;&nbsp;
                            <b>PR1:</b>
                            <a href="javascript:void(0);" onclick="popupPage(960,700,'formONPerinatalRecord1.jsp?demographic_no=<%=demoNo%>&formId=<%=formId%>&provNo=<%=provNo+historyet%>&view=1');">View</a> &nbsp;&nbsp;&nbsp;</a>
                            <a href="javascript:void(0);" onclick="return onPageChange('1');">Edit</a>

                            |

                            <b>PR2:</b>
                            <a href="javascript:void(0);" onclick="popupPage(960,700,'formONPerinatalRecord2.jsp?demographic_no=<%=demoNo%>&formId=<%=formId%>&provNo=<%=provNo+historyet%>&view=1');">View</a> &nbsp;&nbsp;&nbsp;</a>
                            <a href="javascript:void(0);" onclick="return onPageChange('2');">Edit</a>

                            |

                            <b>PR3:</b>
                            <a href="javascript:void(0);" onclick="popupPage(960,700,'formONPerinatalRecord3.jsp?demographic_no=<%=demoNo%>&formId=<%=formId%>&provNo=<%=provNo+historyet%>&view=1');">View</a> &nbsp;&nbsp;&nbsp;</a>
                            <a href="javascript:void(0);" onclick="return onPageChange('3');">Edit</a>

                            |

                            <b>Postnatal:</b>
                            <a href="javascript:void(0);" onclick="popupPage(960,700,'formONPerinatalPostnatal.jsp?demographic_no=<%=demoNo%>&formId=<%=formId%>&provNo=<%=provNo+historyet%>&view=1');">View</a> &nbsp;&nbsp;&nbsp;</a>
                            <a href="javascript:void(0);" onclick="return onPageChange('5');">Edit</a>
                        </td>
                        <%
                            }
                        %>
                    </tr>
                </table>

                <table class="title" border="0" cellspacing="0" cellpadding="0" width="100%">
                    <tr>
                        <th><%=bView?"<span class='alert-warning'>VIEW PAGE: </span>" : ""%>RESOURCES</th>
                    </tr>
                </table>

                <!-- Demographic Info -->
                <table width="100%" border="1" cellspacing="0" cellpadding="0">
                    <tr>
                        <td valign="top" colspan="4" width="25%">
                            Last Name<br/>
                            <input type="text" name="c_lastName" style="width: 100%" size="30" maxlength="60" value="<%= UtilMisc.htmlEscape(props.getProperty("c_lastName", "")) %>" />
                        </td>
                        <td valign="top" colspan="3" width="25%">
                            First Name<br/>
                            <input type="text" name="c_firstName" style="width: 100%" size="30" maxlength="60" value="<%= UtilMisc.htmlEscape(props.getProperty("c_firstName", "")) %>" />
                        </td>
                        <td colspan="7" width="50%"></td>
                    </tr>
                </table>

                <!-- Anxiety Screening / Depression Screening -->
                <table width="100%" border="1" cellspacing="0" cellpadding="0">
                    <thead>
                    <th width="50%" colspan="5" class="sectionHeader">Anxiety Screening</th>
                    <th width="50%"  colspan="5" class="sectionHeader">Depression Screening</th>
                    </thead>

                    <tbody class="text-small">
                    <tr>
                        <td width="50%" colspan="5">
                            <label><b>Generalized Anxiety Disorder scale (GAD-2)</b> &nbsp;&nbsp; <span class="text-small">Date </span> 
                                &nbsp;<input type="text" id="gad_date" name="gad_date" size="10" maxlength="10" placeholder="YYYY/MM/DD" value="<%= UtilMisc.htmlEscape(props.getProperty("gad_date", "")) %>"/></label>
                        </td>
                        <td width="50%" colspan="5">
                            <label><b>The Patient Health Questionnaire-2 (PHQ-2)</b> &nbsp;&nbsp; <span class="text-small">Date </span> 
                                &nbsp;<input type="text" id="phq_date" name="phq_date" size="10" maxlength="10" placeholder="YYYY/MM/DD" value="<%= UtilMisc.htmlEscape(props.getProperty("phq_date", "")) %>" /></label>
                        </td>
                    </tr>
                    
                    <tr>
                        <td>Over the last two weeks, how often have you<br/>been bothered by the following problems:</td>
                        <td>Not at all</td>
                        <td>Several days</td>
                        <td>More <br/> than half <br/> the days</td>
                        <td>Nearly every day</td>

                        <td>Over the last two weeks, how often have you<br/>been bothered by the following problems:</td>
                        <td>Not at all</td>
                        <td>Several days</td>
                        <td>More <br/> than half <br/> the days</td>
                        <td>Nearly every day</td>
                    </tr>
                    
                    <tr>
                        <td>1. Feeling nervous, anxious, or on edge.</td>
                        <td><label><input type="radio" name="gad_1" value="0" <%=UtilMisc.htmlEscape(props.getProperty("gad_1", "")).equals("0") ? "checked=checked" : ""%> onchange="updateResourcesCounts('gad')"/> 0</label></td>
                        <td><label><input type="radio" name="gad_1" value="1" <%=UtilMisc.htmlEscape(props.getProperty("gad_1", "")).equals("1") ? "checked=checked" : ""%> onchange="updateResourcesCounts('gad')"/> 1</label></td>
                        <td><label><input type="radio" name="gad_1" value="2" <%=UtilMisc.htmlEscape(props.getProperty("gad_1", "")).equals("2") ? "checked=checked" : ""%> onchange="updateResourcesCounts('gad')"/> 2</label></td>
                        <td><label><input type="radio" name="gad_1" value="3" <%=UtilMisc.htmlEscape(props.getProperty("gad_1", "")).equals("3") ? "checked=checked" : ""%> onchange="updateResourcesCounts('gad')"/> 3</label></td>

                        <td>1. Little interest or pleasure in doing things.</td>
                        <td><label><input type="radio" name="phq_1" value="0" <%=UtilMisc.htmlEscape(props.getProperty("phq_1", "")).equals("0") ? "checked=checked" : ""%> onchange="updateResourcesCounts('phq')"/> 0</label></td>
                        <td><label><input type="radio" name="phq_1" value="1" <%=UtilMisc.htmlEscape(props.getProperty("phq_1", "")).equals("1") ? "checked=checked" : ""%> onchange="updateResourcesCounts('phq')"/> 1</label></td>
                        <td><label><input type="radio" name="phq_1" value="2" <%=UtilMisc.htmlEscape(props.getProperty("phq_1", "")).equals("2") ? "checked=checked" : ""%> onchange="updateResourcesCounts('phq')"/> 2</label></td>
                        <td><label><input type="radio" name="phq_1" value="3" <%=UtilMisc.htmlEscape(props.getProperty("phq_1", "")).equals("3") ? "checked=checked" : ""%> onchange="updateResourcesCounts('phq')"/> 3</label></td>
                    </tr>

                    <tr>
                        <td>2. Not being able to stop or control worrying.</td>
                        <td><label><input type="radio" name="gad_2" value="0" <%=UtilMisc.htmlEscape(props.getProperty("gad_2", "")).equals("0") ? "checked=checked" : ""%> onchange="updateResourcesCounts('gad')"/> 0</label></td>
                        <td><label><input type="radio" name="gad_2" value="1" <%=UtilMisc.htmlEscape(props.getProperty("gad_2", "")).equals("1") ? "checked=checked" : ""%> onchange="updateResourcesCounts('gad')"/> 1</label></td>
                        <td><label><input type="radio" name="gad_2" value="2" <%=UtilMisc.htmlEscape(props.getProperty("gad_2", "")).equals("2") ? "checked=checked" : ""%> onchange="updateResourcesCounts('gad')"/> 2</label></td>
                        <td><label><input type="radio" name="gad_2" value="3" <%=UtilMisc.htmlEscape(props.getProperty("gad_2", "")).equals("3") ? "checked=checked" : ""%> onchange="updateResourcesCounts('gad')"/> 3</label></td>

                        <td>2. Feeling down, depressed, or hopeless.</td>
                        <td><label><input type="radio" name="phq_2" value="0" <%=UtilMisc.htmlEscape(props.getProperty("phq_2", "")).equals("0") ? "checked=checked" : ""%> onchange="updateResourcesCounts('phq')"/> 0</label></td>
                        <td><label><input type="radio" name="phq_2" value="1" <%=UtilMisc.htmlEscape(props.getProperty("phq_2", "")).equals("1") ? "checked=checked" : ""%> onchange="updateResourcesCounts('phq')"/> 1</label></td>
                        <td><label><input type="radio" name="phq_2" value="2" <%=UtilMisc.htmlEscape(props.getProperty("phq_2", "")).equals("2") ? "checked=checked" : ""%> onchange="updateResourcesCounts('phq')"/> 2</label></td>
                        <td><label><input type="radio" name="phq_2" value="3" <%=UtilMisc.htmlEscape(props.getProperty("phq_2", "")).equals("3") ? "checked=checked" : ""%> onchange="updateResourcesCounts('phq')"/> 3</label></td>
                    </tr>

                    <tr>
                        <td colspan="3">
                            <label>
                                <b>A total score of 3 or more warrants consideration of:</b> <br/>
                                Using the GAD-7 for further assessment or additional mental health follow up.
                            </label>
                        </td>
                        <td colspan="2">
                            <b>Total Score</b> <u id="gad_total">0</u>
                        </td>

                        <td colspan="3">
                            <label>
                                <b>A total score of 3 or more warrants consideration of:</b> <br/>
                                Using the Edinburgh Postnatal Depression Scale (EPDS) or the Patient Health Questionnaire (PHQ) 9 for further assessment or additional mental health follow up. 
                            </label>
                        </td>
                        <td colspan="2">
                            <b>Total Score</b> <u id="phq_total">0</u>
                        </td>
                    </tr>
                    </tbody>
                </table>

                <!-- T-ACE Screening Tool (Alcohol) -->
                <table width="100%" border="1" cellspacing="0" cellpadding="0">
                    <thead>
                    <th colspan="3" class="sectionHeader">T-ACE Screening Tool (Alcohol)</th>
                    </thead>
                    
                    <tbody>
                    <tr>
                        <td width="75%" rowspan="2">
                            <b>Response Key</b><br/>
                            <span class="text-small" style="font-weight: bold">1 Drink is equivalent to:</span><br/>
                            <ul class="inline-list">
                                <li>&bull; 12 oz of beer</li>
                                <li>&bull; 12 oz of cooler</li>
                                <li>&bull; 5 oz of wine</li>
                                <li>&bull; 1.5 oz of hard liquor (mixed drink)</li>
                            </ul>
                        </td>
                        
                        <td colspan="2"><span class="text-small">Date &nbsp;</span><input type="text" id="tace_date" name="tace_date" size="10" maxlength="10" placeholder="YYYY/MM/DD" value="<%= UtilMisc.htmlEscape(props.getProperty("tace_date", "")) %>"/></td>
                    </tr>
                    
                    <tr>
                        <th colspan="2" style="text-align: center">Response</th>
                    </tr>

                    <tr>
                        <td>1. How many drinks does it take you to feel high?</td>
                        <td><label><input type="radio" name="tace_1" value="0" <%=UtilMisc.htmlEscape(props.getProperty("tace_1", "")).equals("0") ? "checked=checked" : ""%> onchange="updateResourcesCounts('tace')"/> &le; 2 drinks <span style="font-weight: bold;"> = 0</span></label></td>
                        <td><label><input type="radio" name="tace_1" value="1" <%=UtilMisc.htmlEscape(props.getProperty("tace_1", "")).equals("1") ? "checked=checked" : ""%> onchange="updateResourcesCounts('tace')"/> &gt; 2 drinks <span style="font-weight: bold;"> = 1</span></label></td>
                    </tr>

                    <tr>
                        <td>2. Have people annoyed you by critizing your drinking?</td>
                        <td><label><input type="radio" name="tace_2" value="0" <%=UtilMisc.htmlEscape(props.getProperty("tace_2", "")).equals("0") ? "checked=checked" : ""%> onchange="updateResourcesCounts('tace')"/> No <span style="font-weight: bold;"> = 0</span></label></td>
                        <td><label><input type="radio" name="tace_2" value="1" <%=UtilMisc.htmlEscape(props.getProperty("tace_2", "")).equals("1") ? "checked=checked" : ""%> onchange="updateResourcesCounts('tace')"/> Yes <span style="font-weight: bold;"> = 1</span></label></td>
                    </tr>

                    <tr>
                        <td>3. Have you felt you ought to cut down your drinking?</td>
                        <td><label><input type="radio" name="tace_3" value="0" <%=UtilMisc.htmlEscape(props.getProperty("tace_3", "")).equals("0") ? "checked=checked" : ""%> onchange="updateResourcesCounts('tace')"/> No <span style="font-weight: bold;"> = 0</span></label></td>
                        <td><label><input type="radio" name="tace_3" value="1" <%=UtilMisc.htmlEscape(props.getProperty("tace_3", "")).equals("1") ? "checked=checked" : ""%> onchange="updateResourcesCounts('tace')"/> Yes <span style="font-weight: bold;"> = 1</span></label></td>
                    </tr>

                    <tr>
                        <td>4. Have you ever had a drink first thing in the morning to steady your nerves or to get rid of a hangover?</td>
                        <td><label><input type="radio" name="tace_4" value="0" <%=UtilMisc.htmlEscape(props.getProperty("tace_4", "")).equals("0") ? "checked=checked" : ""%> onchange="updateResourcesCounts('tace')"/> No <span style="font-weight: bold;"> = 0</span></label></td>
                        <td><label><input type="radio" name="tace_4" value="1" <%=UtilMisc.htmlEscape(props.getProperty("tace_4", "")).equals("1") ? "checked=checked" : ""%> onchange="updateResourcesCounts('tace')"/> Yes <span style="font-weight: bold;"> = 1</span></label></td>
                    </tr>
                    
                    <tr>
                        <th>A score of 2 or greater indicates potential prenatal risk and need for follow-up.</th>
                        <td colspan="2"><b>Total Score</b> <u id="tace_total">0</u></td>
                    </tr>
                    </tbody>
                </table>

                <!-- Edinburgh Perinatal / Postnatal Depression Scale (EPDS) -->
                <table width="100%" border="1" cellspacing="0" cellpadding="0">
                    <thead>
                    <th colspan="3" class="sectionHeader">Edinburgh Perinatal / Postnatal Depression Scale (EPDS) <span class="text-small">Cox, Holden, Sagovsky, (1987)</span> </th>
                    </thead>

                    <tbody class="no-border-sides">
                    <tr>
                        <td colspan="2" style="font-weight: bold;">In the past 7 days:</td>
                        <td style="border-left: solid 1px"> <span class="text-small">Date </span> &nbsp;<input type="text" id="epds_date" name="epds_date" size="10" maxlength="10" placeholder="YYYY/MM/DD" value="<%= UtilMisc.htmlEscape(props.getProperty("epds_date", "")) %>"/></td>
                    </tr>
                    
                    <tr>
                        <td style="font-weight: bold;">1. I have been able to laugh and see the funny side of things</td>
                        <td>
                            <label><input type="radio" name="epds_1" value="0" <%=UtilMisc.htmlEscape(props.getProperty("epds_1", "")).equals("0") ? "checked=checked" : ""%> onchange="updateResourcesCounts('epds')"/> As much as I always could <span style="font-weight: bold;"> = 0</span></label> <br/>
                            <label><input type="radio" name="epds_1" value="1" <%=UtilMisc.htmlEscape(props.getProperty("epds_1", "")).equals("1") ? "checked=checked" : ""%> onchange="updateResourcesCounts('epds')"/> Not quite so much now <span style="font-weight: bold;"> = 1</span></label>
                        </td>
                        <td>
                            <label><input type="radio" name="epds_1" value="2" <%=UtilMisc.htmlEscape(props.getProperty("epds_1", "")).equals("2") ? "checked=checked" : ""%> onchange="updateResourcesCounts('epds')"/> Definitely not so much now <span style="font-weight: bold;"> = 2</span></label> <br/>
                            <label><input type="radio" name="epds_1" value="3" <%=UtilMisc.htmlEscape(props.getProperty("epds_1", "")).equals("3") ? "checked=checked" : ""%> onchange="updateResourcesCounts('epds')"/> Not at all <span style="font-weight: bold;"> = 3</span></label>
                        </td>
                    </tr>

                    <tr>
                        <td style="font-weight: bold;">2. I have looked forward with enjoyment to things</td>
                        <td>
                            <label><input type="radio" name="epds_2" value="0" <%=UtilMisc.htmlEscape(props.getProperty("epds_2", "")).equals("0") ? "checked=checked" : ""%> onchange="updateResourcesCounts('epds')"/> As much as I ever did <span style="font-weight: bold;"> = 0</span></label> <br/>
                            <label><input type="radio" name="epds_2" value="1" <%=UtilMisc.htmlEscape(props.getProperty("epds_2", "")).equals("1") ? "checked=checked" : ""%> onchange="updateResourcesCounts('epds')"/> Rather less than I used to <span style="font-weight: bold;"> = 1</span></label>
                        </td>
                        <td>
                            <label><input type="radio" name="epds_2" value="2" <%=UtilMisc.htmlEscape(props.getProperty("epds_2", "")).equals("2") ? "checked=checked" : ""%> onchange="updateResourcesCounts('epds')"/> Definitely not so much now <span style="font-weight: bold;"> = 2</span></label> <br/>
                            <label><input type="radio" name="epds_2" value="3" <%=UtilMisc.htmlEscape(props.getProperty("epds_2", "")).equals("3") ? "checked=checked" : ""%> onchange="updateResourcesCounts('epds')"/> Hardly at all <span style="font-weight: bold;"> = 3</span></label>
                        </td>
                    </tr>

                    <tr>
                        <td style="font-weight: bold;">3. I have blamed myself unnecessarily when things went wrong</td>
                        <td>
                            <label><input type="radio" name="epds_3" value="0" <%=UtilMisc.htmlEscape(props.getProperty("epds_3", "")).equals("0") ? "checked=checked" : ""%> onchange="updateResourcesCounts('epds')"/> No, never <span style="font-weight: bold;"> = 0</span></label> <br/>
                            <label><input type="radio" name="epds_3" value="1" <%=UtilMisc.htmlEscape(props.getProperty("epds_3", "")).equals("1") ? "checked=checked" : ""%> onchange="updateResourcesCounts('epds')"/> No, not very often <span style="font-weight: bold;"> = 1</span></label>
                        </td>
                        <td>
                            <label><input type="radio" name="epds_3" value="2" <%=UtilMisc.htmlEscape(props.getProperty("epds_3", "")).equals("2") ? "checked=checked" : ""%> onchange="updateResourcesCounts('epds')"/> Yes, some of the time <span style="font-weight: bold;"> = 2</span></label> <br/>
                            <label><input type="radio" name="epds_3" value="3" <%=UtilMisc.htmlEscape(props.getProperty("epds_3", "")).equals("3") ? "checked=checked" : ""%> onchange="updateResourcesCounts('epds')"/> Yes, most of the time <span style="font-weight: bold;"> = 3</span></label>
                        </td>
                    </tr>

                    <tr>
                        <td style="font-weight: bold;">4. I have been anxious or worried for no good reason</td>
                        <td>
                            <label><input type="radio" name="epds_4" value="0" <%=UtilMisc.htmlEscape(props.getProperty("epds_4", "")).equals("0") ? "checked=checked" : ""%> onchange="updateResourcesCounts('epds')"/> No, not at all <span style="font-weight: bold;"> = 0</span></label> <br/>
                            <label><input type="radio" name="epds_4" value="1" <%=UtilMisc.htmlEscape(props.getProperty("epds_4", "")).equals("1") ? "checked=checked" : ""%> onchange="updateResourcesCounts('epds')"/> Hardly ever <span style="font-weight: bold;"> = 1</span></label>
                        </td>
                        <td>
                            <label><input type="radio" name="epds_4" value="2" <%=UtilMisc.htmlEscape(props.getProperty("epds_4", "")).equals("2") ? "checked=checked" : ""%> onchange="updateResourcesCounts('epds')"/> Yes, sometimes <span style="font-weight: bold;"> = 2</span></label> <br/>
                            <label><input type="radio" name="epds_4" value="3" <%=UtilMisc.htmlEscape(props.getProperty("epds_4", "")).equals("3") ? "checked=checked" : ""%> onchange="updateResourcesCounts('epds')"/> Yes, very often <span style="font-weight: bold;"> = 3</span></label>
                        </td>
                    </tr>


                    <tr>
                        <td style="font-weight: bold;">5. I have felt scared or panicky for no very good reason</td>
                        <td>
                            <label><input type="radio" name="epds_5" value="0" <%=UtilMisc.htmlEscape(props.getProperty("epds_5", "")).equals("0") ? "checked=checked" : ""%> onchange="updateResourcesCounts('epds')"/> No, not at all <span style="font-weight: bold;"> = 0</span></label> <br/>
                            <label><input type="radio" name="epds_5" value="1" <%=UtilMisc.htmlEscape(props.getProperty("epds_5", "")).equals("1") ? "checked=checked" : ""%> onchange="updateResourcesCounts('epds')"/> No, not much <span style="font-weight: bold;"> = 1</span></label>
                        </td>
                        <td>
                            <label><input type="radio" name="epds_5" value="2" <%=UtilMisc.htmlEscape(props.getProperty("epds_5", "")).equals("2") ? "checked=checked" : ""%> onchange="updateResourcesCounts('epds')"/> Yes, sometimes <span style="font-weight: bold;"> = 2</span></label> <br/>
                            <label><input type="radio" name="epds_5" value="3" <%=UtilMisc.htmlEscape(props.getProperty("epds_5", "")).equals("3") ? "checked=checked" : ""%> onchange="updateResourcesCounts('epds')"/> Yes, quite a lot <span style="font-weight: bold;"> = 3</span></label>
                        </td>
                    </tr>

                    <tr>
                        <td style="font-weight: bold;">6. Things have been getting on top of me</td>
                        <td>
                            <label><input type="radio" name="epds_6" value="0" <%=UtilMisc.htmlEscape(props.getProperty("epds_6", "")).equals("0") ? "checked=checked" : ""%> onchange="updateResourcesCounts('epds')"/> No, I have been coping as well as ever <span style="font-weight: bold;"> = 0</span></label> <br/>
                            <label><input type="radio" name="epds_6" value="1" <%=UtilMisc.htmlEscape(props.getProperty("epds_6", "")).equals("1") ? "checked=checked" : ""%> onchange="updateResourcesCounts('epds')"/> No, most of the time I have coped well <span style="font-weight: bold;"> = 1</span></label>
                        </td>
                        <td>
                            <label><input type="radio" name="epds_6" value="2" <%=UtilMisc.htmlEscape(props.getProperty("epds_6", "")).equals("2") ? "checked=checked" : ""%> onchange="updateResourcesCounts('epds')"/> Yes, sometimes I haven't been coping as well as usual <span style="font-weight: bold;"> = 2</span></label> <br/>
                            <label><input type="radio" name="epds_6" value="3" <%=UtilMisc.htmlEscape(props.getProperty("epds_6", "")).equals("3") ? "checked=checked" : ""%> onchange="updateResourcesCounts('epds')"/> Yes, most of the time I haven't been able to cope <span style="font-weight: bold;"> = 3</span></label>
                        </td>
                    </tr>

                    <tr>
                        <td style="font-weight: bold;">7. I have been so unhappy that I have had difficulty sleeping</td>
                        <td>
                            <label><input type="radio" name="epds_7" value="0" <%=UtilMisc.htmlEscape(props.getProperty("epds_7", "")).equals("0") ? "checked=checked" : ""%> onchange="updateResourcesCounts('epds')"/> No, not much <span style="font-weight: bold;"> = 0</span></label> <br/>
                            <label><input type="radio" name="epds_7" value="1" <%=UtilMisc.htmlEscape(props.getProperty("epds_7", "")).equals("1") ? "checked=checked" : ""%> onchange="updateResourcesCounts('epds')"/> Not very often <span style="font-weight: bold;"> = 1</span></label>
                        </td>
                        <td>
                            <label><input type="radio" name="epds_7" value="2" <%=UtilMisc.htmlEscape(props.getProperty("epds_7", "")).equals("2") ? "checked=checked" : ""%> onchange="updateResourcesCounts('epds')"/> Yes, quite often <span style="font-weight: bold;"> = 2</span></label> <br/>
                            <label><input type="radio" name="epds_7" value="3" <%=UtilMisc.htmlEscape(props.getProperty("epds_7", "")).equals("3") ? "checked=checked" : ""%> onchange="updateResourcesCounts('epds')"/> Yes, most of the time <span style="font-weight: bold;"> = 3</span></label>
                        </td>
                    </tr>

                    <tr>
                        <td style="font-weight: bold;">8. I have felt sad or miserable</td>
                        <td>
                            <label><input type="radio" name="epds_8" value="0" <%=UtilMisc.htmlEscape(props.getProperty("epds_8", "")).equals("0") ? "checked=checked" : ""%> onchange="updateResourcesCounts('epds')"/> No, not much <span style="font-weight: bold;"> = 0</span></label> <br/>
                            <label><input type="radio" name="epds_8" value="1" <%=UtilMisc.htmlEscape(props.getProperty("epds_8", "")).equals("1") ? "checked=checked" : ""%> onchange="updateResourcesCounts('epds')"/> Not very often <span style="font-weight: bold;"> = 1</span></label>
                        </td>
                        <td>
                            <label><input type="radio" name="epds_8" value="2" <%=UtilMisc.htmlEscape(props.getProperty("epds_8", "")).equals("2") ? "checked=checked" : ""%> onchange="updateResourcesCounts('epds')"/> Yes, quite often <span style="font-weight: bold;"> = 2</span></label> <br/>
                            <label><input type="radio" name="epds_8" value="3" <%=UtilMisc.htmlEscape(props.getProperty("epds_8", "")).equals("3") ? "checked=checked" : ""%> onchange="updateResourcesCounts('epds')"/> Yes, most of the time <span style="font-weight: bold;"> = 3</span></label>
                        </td>
                    </tr>

                    <tr>
                        <td style="font-weight: bold;">9. I have been so unhappy that I have been crying</td>
                        <td>
                            <label><input type="radio" name="epds_9" value="0" <%=UtilMisc.htmlEscape(props.getProperty("epds_9", "")).equals("0") ? "checked=checked" : ""%> onchange="updateResourcesCounts('epds')"/> No, never <span style="font-weight: bold;"> = 0</span></label> <br/>
                            <label><input type="radio" name="epds_9" value="1" <%=UtilMisc.htmlEscape(props.getProperty("epds_9", "")).equals("1") ? "checked=checked" : ""%> onchange="updateResourcesCounts('epds')"/> Only occasionally <span style="font-weight: bold;"> = 1</span></label>
                        </td>
                        <td>
                            <label><input type="radio" name="epds_9" value="2" <%=UtilMisc.htmlEscape(props.getProperty("epds_9", "")).equals("2") ? "checked=checked" : ""%> onchange="updateResourcesCounts('epds')"/> Yes, quite often <span style="font-weight: bold;"> = 2</span></label> <br/>
                            <label><input type="radio" name="epds_9" value="3" <%=UtilMisc.htmlEscape(props.getProperty("epds_9", "")).equals("3") ? "checked=checked" : ""%> onchange="updateResourcesCounts('epds')"/> Yes, most of the time <span style="font-weight: bold;"> = 3</span></label>
                        </td>
                    </tr>

                    <tr>
                        <td style="font-weight: bold;">10. The thought of harming myself has occured to me</td>
                        <td>
                            <label><input type="radio" name="epds_10" value="0" <%=UtilMisc.htmlEscape(props.getProperty("epds_10", "")).equals("0") ? "checked=checked" : ""%> onchange="updateResourcesCounts('epds')"/> No, never <span style="font-weight: bold;"> = 0</span></label> <br/>
                            <label><input type="radio" name="epds_10" value="1" <%=UtilMisc.htmlEscape(props.getProperty("epds_10", "")).equals("1") ? "checked=checked" : ""%> onchange="updateResourcesCounts('epds')"/> Only occasionally <span style="font-weight: bold;"> = 1</span></label>
                        </td>
                        <td>
                            <label><input type="radio" name="epds_10" value="2" <%=UtilMisc.htmlEscape(props.getProperty("epds_10", "")).equals("2") ? "checked=checked" : ""%> onchange="updateResourcesCounts('epds')"/> Yes, quite often <span style="font-weight: bold;"> = 2</span></label> <br/>
                            <label><input type="radio" name="epds_10" value="3" <%=UtilMisc.htmlEscape(props.getProperty("epds_10", "")).equals("3") ? "checked=checked" : ""%> onchange="updateResourcesCounts('epds')"/> Yes, most of the time <span style="font-weight: bold;"> = 3</span></label>
                        </td>
                    </tr>

                    <tr>
                        <td style="font-weight: bold;">Total Score: <u id="epds_total" style="font-weight: normal">0</u></td>
                        <td  colspan="2" style="border-left: solid 1px"> 
                            <span style="font-weight: bold;">Score of 1-3 on item 10 indicates a risk of self-harm. Patient requires immediate mental health assessment and intervention as appropriate.</span><br/>
                            <span style="font-weight: bold;">Score &gt; 9</span> Monitor, support, and offer education.<br/>
                            <span style="font-weight: bold;">Score &gt; 12</span> Follow up with comprehensive bio-psychosocial diagnostic assessment for depression.
                        </td>
                    </tr>
                    </tbody>
                </table>

                <!-- Institute of Medicine Weight Gain Recommendations for Pregnancy (2009) -->
                <table width="100%" border="1" cellspacing="0" cellpadding="0">
                    <thead>
                    <tr>
                        <th colspan="5" class="sectionHeader">Institute of Medicine Weight Gain Recommendations for Pregnancy (2009)</th>
                    </tr>
                    
                    <tr>
                        <th rowspan="2" class="subsection">Prepregnancy Weight Category</th>
                        <th rowspan="2" class="subsection">Body Mass Index</th>
                        <th rowspan="2" class="subsection">Recommended range of Total Weight in kg (lb)</th>
                        <th colspan="2" class="subsection">Rates of Weight Gain in Second and Third Trimesters</th>
                    </tr>

                    <tr>
                        <th class="subsection">kg/wk</th>
                        <th class="subsection">lb/wk (mean range)</th>
                    </tr>
                    
                    </thead>
                    
                    <tbody>
                    <tr>
                        <td>Underweight</td>
                        <td>Less than 18.5</td>
                        <td>12.5-18kg (28-40)</td>
                        <td>0.5</td>
                        <td>1 (1-1.3)</td>
                    </tr>

                    <tr>
                        <td>Normal Weight</td>
                        <td>18.5-24.9</td>
                        <td>11.5-16 kg (25-35)</td>
                        <td>0.4</td>
                        <td>1 (0.8-1)</td>
                    </tr>

                    <tr>
                        <td>Overweight</td>
                        <td>25-29.9</td>
                        <td>7-11.5 kg (15-25)</td>
                        <td>0.3</td>
                        <td>0.6 (0.5-0.7)</td>
                    </tr>

                    <tr>
                        <td>Obese (includes all classes)</td>
                        <td>30 and greater</td>
                        <td>5-9 kg (11-20)</td>
                        <td>0.2</td>
                        <td>0.5 (0.4-0.6)</td>
                    </tr>

                    <tr class="text-small">
                        <td colspan="5">&#10013;Calculations assume a 0.5 to 2 kg (1.1-4.4 lb) weight gain in the first trimester.</td>
                    </tr>
                    
                    </tbody>
                </table>


                <!-- Save / Exit / Print -->
                <table class="sectionHeader hidePrint">
                    <tr>
                        <td align="left">
                            <%
                                if (!bView) {
                            %> <input type="submit" value="Save"
                                      onclick="return onSave();" /> <input type="submit" value="Save and Exit" onclick="return onSaveExit();" /> <%
                            }
                        %> <input type="submit" value="Exit"
                                  onclick="return onExit();" /> <input type="submit" value="Print" onclick="return onPrint();" />
                            <%
                                if (!bView) {
                            %>
                            &nbsp;&nbsp;&nbsp;
                            <b>PR1:</b>
                            <a href="javascript:void(0);" onclick="popupPage(960,700,'formONPerinatalRecord1.jsp?demographic_no=<%=demoNo%>&formId=<%=formId%>&provNo=<%=provNo+historyet%>&view=1');">View</a> &nbsp;&nbsp;&nbsp;</a>
                            <a href="javascript:void(0);" onclick="return onPageChange('1');">Edit</a>

                            |

                            <b>PR2:</b>
                            <a href="javascript:void(0);" onclick="popupPage(960,700,'formONPerinatalRecord2.jsp?demographic_no=<%=demoNo%>&formId=<%=formId%>&provNo=<%=provNo+historyet%>&view=1');">View</a> &nbsp;&nbsp;&nbsp;</a>
                            <a href="javascript:void(0);" onclick="return onPageChange('2');">Edit</a>

                            |

                            <b>PR3:</b>
                            <a href="javascript:void(0);" onclick="popupPage(960,700,'formONPerinatalRecord3.jsp?demographic_no=<%=demoNo%>&formId=<%=formId%>&provNo=<%=provNo+historyet%>&view=1');">View</a> &nbsp;&nbsp;&nbsp;</a>
                            <a href="javascript:void(0);" onclick="return onPageChange('3');">Edit</a>

                            |

                            <b>Postnatal:</b>
                            <a href="javascript:void(0);" onclick="popupPage(960,700,'formONPerinatalPostnatal.jsp?demographic_no=<%=demoNo%>&formId=<%=formId%>&provNo=<%=provNo+historyet%>&view=1');">View</a> &nbsp;&nbsp;&nbsp;</a>
                            <a href="javascript:void(0);" onclick="return onPageChange('5');">Edit</a>
                        </td>
                        <%
                            }
                        %>
                    </tr>
                </table>

            </html:form>
        </div>
    </div>
    

    <!-- Forms and Checklists -->
    <div id="gbs-req-form" title="Create GBS Lab Requisition">
        <p class="validateTips"></p>
        <form>
            <fieldset>
                <input type="checkbox" name="penicillin" id="penicillin" class="text ui-widget-content ui-corner-all" />
                <label for="ferritin">Patient Penicillin Allergic</label>
            </fieldset>
        </form>
    </div>

    <div id="gct-req-form" title="Create Lab Requisition">
        <p class="validateTips"></p>

        <form>
            <fieldset>
                <input type="checkbox" name="gct_hb" id="gct_hb" checked="checked" class="text ui-widget-content ui-corner-all" />
                <label for="gct_hb">Hb</label>
                <br/>
                <input type="checkbox" name="gct_urine" id="gct_urine" checked="checked" value="" class="text ui-widget-content ui-corner-all" />
                <label for="gct_urine">Urine C&S</label>
                <br/>
                <input type="checkbox" name="gct_ab" id="gct_ab" checked="checked" value="" class="text ui-widget-content ui-corner-all" />
                <label for="gct_ab">Repeat antibody screen</label>
                <br/>
                <input type="checkbox" name="gct_glu" id="gct_glu" checked="checked" value="" class="text ui-widget-content ui-corner-all" />
                <label for="gct_glu">1 hour 50 gm glucose screen</label>
            </fieldset>
        </form>
    </div>

    <div id="gtt-req-form" title="Create Lab Requisition">
        <p class="validateTips"></p>

        <form>
            <fieldset>
                <input type="checkbox" name="gtt_glu" id="gtt_glu" checked="checked" class="text ui-widget-content ui-corner-all" />
                <label for="gtt_glu">2 hour 75m glucose screen</label>
            </fieldset>
        </form>
    </div>
    
    <div id="24wk-visit-form" title="24 week Visit">
        <form>
            <fieldset>
                <table>
                    <tbody>
                    <tr>
                        <td>
                            Order 1 Hour GCT
                            <a href="javascript:void(0);" onclick="return false;" title="Click on 'Labs' menu item under Prompts, and choose 1 Hour GCT"><img border="0" src="../images/icon_help_sml.gif"/></a>
                        </td>
                    </tr>
                    </tbody>
                </table>
            </fieldset>
        </form>
    </div>

    <div id="35wk-visit-form" title="35 week Visit">
        <form>
            <fieldset>
                <table>
                    <tbody>
                    <tr>
                        <td>
                            Order GBS Lab
                            <a href="javascript:void(0);" onclick="return false;" title="Click on 'Labs' menu item under Prompts, and choose GBS"><img border="0" src="../images/icon_help_sml.gif"/></a>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            Consider ultrasound for position
                            <a href="javascript:void(0);" onclick="return false;" title="Click on 'Forms' menu item under Prompts, and choose Ultrasound"><img border="0" src="../images/icon_help_sml.gif"/></a>
                        </td>
                    </tr>
                    </tbody>
                </table>
            </fieldset>
        </form>
    </div>

    <div id="dd-visit-form" title="Due Date Visit">
        <form>
            <fieldset>
                <table>
                    <tbody>

                    </tbody>
                </table>
            </fieldset>
        </form>
    </div>

    <div id="lab_menu_div" class="hidden">
        <ul>
            <li><a href="javascript:void(0)" onclick="popPage('formlabreq<%=labReqVer %>.jsp?demographic_no=<%=demoNo%>&formId=0&provNo=<%=provNo%>&labType=AnteNatal','LabReq')">Routine Prenatal</a></li>
            <li><a href="javascript:void(0)" onclick="gbsReq();return false;">GBS</a></li>
            <li><a href="javascript:void(0)" onclick="gctReq();return false;">1 Hour GCT</a></li>
            <li><a href="javascript:void(0)" onclick="gttReq();return false;">2 Hour GTT</a></li>
        </ul>
    </div>

    <div id="forms_menu_div" class="hidden">
        <ul>
            <li><a href="javascript:void(0)" onclick="loadUltrasoundForms();">Ultrasound</a></li>
            <li><a href="javascript:void(0)" onclick="loadIPSForms();">IPS</a></li></ul>
    </div>

    <div id="eforms_menu_div" class="hidden">
        <ul>
            <%
                ArrayList<HashMap<String, ? extends Object>> eForms;
                if (groupView.equals("") || groupView.equals("default")) {
                    eForms = EFormUtil.listEForms(orderBy, EFormUtil.CURRENT, roleName2$);
                } else {
                    eForms = EFormUtil.listEForms(orderBy, EFormUtil.CURRENT, groupView, roleName2$);
                }
                if (eForms.size() > 0) {
                    for (int i=0; i<eForms.size(); i++) {
                        HashMap<String, ? extends Object> curForm = eForms.get(i);
            %>
            <li><a href="javascript:void(0)" onclick ="popPage('<%=request.getContextPath()%>/eform/efmformadd_data.jsp?fid=<%=curForm.get("fid")%>&demographic_no=<%=demoNo%>&appointment=<%=appointment%>','<%=curForm.get("fid") + "_" + demoNo %>'); return true;">
                <%=curForm.get("formName")%></a></li>
            <%
                }
            } else {
            %>
            <li><bean:message key="eform.showmyform.msgNoData"/></li>
            <%}%>
        </ul>
    </div>

    <div id="ips-form" title="IPS Support Tool">
        <form>
            <fieldset>
                <table>
                    <tbody>
                    <tr>
                        <td><button id="credit_valley_genetic_btn">Lab Requisition</button></td>
                        <td>Credit Valley Hospital</td>
                    </tr>
                    <tr>
                        <td><button id="north_york_genetic_btn">Lab Requisition</button></td>
                        <td>North York Hospital</td>
                    </tr>
                    </tbody>
                </table>
            </fieldset>
        </form>
    </div>
    
    <div id="cytology-eform-form" title="Cytology Forms">
        <form>
            <fieldset>
                <table>
                    <tbody>
                    <%
                        if(cytologyForms != null) {
                            for(LabelValueBean bean:cytologyForms) {
                    %>
                    <tr>
                        <td><button onClick="popPage('<%=request.getContextPath()%>/eform/efmformadd_data.jsp?fid=<%=bean.getValue()%>&demographic_no=<%=demoNo%>&appointment=0','cytology');return false;">Open</button></td>
                        <td><%=bean.getLabel() %></td>
                    </tr>
                    <%
                            }
                        }
                    %>
                    </tbody>
                </table>
            </fieldset>
        </form>
    </div>

    <div id="ultrasound-eform-form" title="Ultrasound Forms">
        <form>
            <fieldset>
                <table>
                    <tbody>
                    <%
                        if(ultrasoundForms != null) {
                            for(LabelValueBean bean:ultrasoundForms) {
                    %>
                    <tr>
                        <td><button onClick="popPage('<%=request.getContextPath()%>/eform/efmformadd_data.jsp?fid=<%=bean.getValue()%>&demographic_no=<%=demoNo%>&appointment=0','ultrasound');return false;">Open</button></td>
                        <td><%=bean.getLabel() %></td>
                    </tr>
                    <%
                            }
                        }
                    %>
                    </tbody>
                </table>
            </fieldset>
        </form>
    </div>
    
    <div id="ips-eform-form" title="IPS Forms">
        <form>
            <fieldset>
                <table>
                    <tbody>
                    <%
                        if(ipsForms != null) {
                            for(LabelValueBean bean:ipsForms) {
                    %>
                    <tr>
                        <td><button onClick="popPage('<%=request.getContextPath()%>/eform/efmformadd_data.jsp?fid=<%=bean.getValue()%>&demographic_no=<%=demoNo%>&appointment=0','ipsform');return false;">Open</button></td>
                        <td><%=bean.getLabel() %></td>
                    </tr>
                    <%
                            }
                        }
                    %>
                    </tbody>
                </table>
            </fieldset>
        </form>
    </div>

    <div id="edb-update-form" title="EDB Update">
        <p>The EDB should be updated according to SOGC guideline (<a target="_sogc" href="http://sogc.org/guidelines/documents/gui214CPG0809.pdf">link</a>)</p>
        <form>
            <fieldset>
                <table id="edb_update_table">
                    <tbody>

                    </tbody>
                </table>
            </fieldset>
        </form>
    </div>

    <!-- Printing -->
    <div id="print-dialog" title="Print Perinatal Record">
        <p class="validateTips"></p>
        <form>
            <fieldset>
                <input type="checkbox" name="print_pr1" id="print_pr1" checked="checked" class="text ui-widget-content ui-corner-all" />
                <label for="print_pr1">PR1</label>
                <br/>
                <input type="checkbox" name="print_pr2" id="print_pr2" checked="checked" class="text ui-widget-content ui-corner-all" />
                <label for="print_pr2">PR2</label>
                <br/>
                <input type="checkbox" name="print_pr3" id="print_pr3" checked="checked" class="text ui-widget-content ui-corner-all" />
                <label for="print_pr3">PR3</label>
                <br/>
                <input type="checkbox" name="print_pr4" id="print_pr4" checked="checked" class="text ui-widget-content ui-corner-all" />
                <label for="print_pr4">Resources</label>
                <br/>
                <input type="checkbox" name="print_pr5" id="print_pr5" checked="checked" class="text ui-widget-content ui-corner-all" />
                <label for="print_pr5">Postnatal</label>
                <br/>
                <table>
                    <tr>
                        <td>External Location:</td>
                        <td>
                            <select name="print_location" id="print_location" class="text ui-widget-content ui-corner-all">
                                <option value="none">None</option>
                                <option value="hospital">Hospital</option>
                                <option value="patient">Patient</option>
                                <option value="other">Other</option>
                            </select>
                        </td>
                    </tr>
                    <tr>
                        <td>Method of Transfer:</td>
                        <td>
                            <select name="print_method" id="print_method" class="text ui-widget-content ui-corner-all">
                                <option value="none">None</option>
                                <option value="fax">Fax</option>
                                <option value="mail">Mail</option>
                                <option value="email">Email</option>
                            </select>
                        </td>
                    </tr>
                </table>
            </fieldset>
        </form>
    </div>

    <div id="print-log-dialog" title="Print Log" style="background-color:white">
        <table id="print_log_table" style="width:100%">
            <thead style="text-align:left">
            <tr>
                <th>Date</th>
                <th>Provider</th>
                <th>External Location</th>
                <th>Method of Transfer</th>
            </tr>
            </thead>
            <tbody>
            </tbody>
        </table>
    </div>

    </body>
</html:html>
