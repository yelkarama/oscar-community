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


<%
    String formClass = "ONPerinatal";
    String pageNo = "1";
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

    FrmRecord rec = (new FrmRecordFactory()).factory(formClass);
    java.util.Properties props = rec.getFormRecord(LoggedInInfo.getLoggedInInfoFromSession(request),demoNo, formId);

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
    int ohNum = Integer.parseInt(props.getProperty("oh_num", "0"));
%>

<html:html locale="true">
    <head>
        <script type="text/javascript" src="<%= request.getContextPath() %>/js/global.js"></script>
        <title>Ontario Perinatal Record 1</title>
        <script src="<%=request.getContextPath()%>/JavaScriptServlet" type="text/javascript"></script>
        <link rel="stylesheet" type="text/css" href="arStyle.css">
        <link rel="stylesheet" type="text/css" media="all" href="../share/calendar/calendar.css" title="win2k-cold-1" />
        <script type="text/javascript" src="../share/calendar/calendar.js"></script>
        <script type="text/javascript" src="../share/calendar/lang/<bean:message key="global.javascript.calendar"/>"></script>
        <script type="text/javascript" src="../share/calendar/calendar-setup.js"></script>

        <script src="<%=request.getContextPath() %>/js/jquery-1.7.1.min.js" type="text/javascript"></script>
        <script src="<%=request.getContextPath()%>/js/jquery-ui-1.8.18.custom.min.js"></script>
        <script src="<%=request.getContextPath()%>/js/fg.menu.js"></script>
        <script type="text/javascript" src="<%=request.getContextPath()%>/js/formONPerinatalRecord.js"></script>
        <script type="text/javascript" src="<%=request.getContextPath()%>/js/formONPerinatalSidebar.js"></script>

        <link rel="stylesheet" href="<%=request.getContextPath()%>/css/cupertino/jquery-ui-1.8.18.custom.css">
        <link rel="stylesheet" href="<%=request.getContextPath() %>/library/bootstrap/3.0.0/css/bootstrap.min.css" />
        <link rel="stylesheet" href="<%=request.getContextPath()%>/css/fg.menu.css">
        <link rel="stylesheet" href="<%=request.getContextPath()%>/css/formONPerinatalRecord.css">

        <script type="text/javascript">
            $(document).ready(function(){
                init(1, <%=bView%>);
                dialogs(1, <%=bView%>);
                
                $("select[name='c_province']").val('<%= UtilMisc.htmlEscape(props.getProperty("c_province", "OT")) %>');
                $("select[name='c_maritalStatus']").val('<%= UtilMisc.htmlEscape(props.getProperty("c_maritalStatus", "UN")) %>');
                $("select[name='c_language']").val('<%= UtilMisc.htmlEscape(props.getProperty("c_language", "")) %>');
                $("select[name='c_partnerEduLevel']").val('<%= UtilMisc.htmlEscape(props.getProperty("c_partnerEduLevel", "UN")) %>');
                $("select[name='c_eduLevel']").val('<%= UtilMisc.htmlEscape(props.getProperty("c_eduLevel", "UN")) %>');
                $("select[name='c_hinType']").val('<%= UtilMisc.htmlEscape(props.getProperty("c_hinType", "OTHER")) %>');
                $("select[name='mh_26_egg']").val('<%= UtilMisc.htmlEscape(props.getProperty("mh_26_egg", "UN")) %>');

                $.when($.ajax(initObstetricalHistory(<%=ohNum%>))).then(function () {
                    loadObstetricalHistoryValues();
                });
                
                function loadObstetricalHistoryValues() {
                    <% for(int i = 1; i <= ohNum ; i++) { %>
                    $("input[name='oh_yearMonth<%=i%>']").val("<%= UtilMisc.htmlEscape(props.getProperty("oh_yearMonth"+i, "")) %>");
                    $("input[name='oh_place<%=i%>']").val("<%= UtilMisc.htmlEscape(props.getProperty("oh_place"+i, "")) %>");
                    $("input[name='oh_gest<%=i%>']").val("<%= UtilMisc.htmlEscape(props.getProperty("oh_gest"+i, "")) %>");
                    $("input[name='oh_length<%=i%>']").val("<%= UtilMisc.htmlEscape(props.getProperty("oh_length"+i, "")) %>");
                    $("input[name='oh_birth_type<%=i%>'][value='<%=props.getProperty("oh_birth_type" + i, "")%>'").prop("checked", true);
                    /*setCheckbox("oh_svb<%=i%>", "<%=UtilMisc.htmlEscape(props.getProperty("oh_svb"+i, ""))%>");
                    setCheckbox("oh_cs<%=i%>", "<%=UtilMisc.htmlEscape(props.getProperty("oh_cs"+i, ""))%>");
                    setCheckbox("oh_ass<%=i%>", "<%=UtilMisc.htmlEscape(props.getProperty("oh_ass"+i, ""))%>");*/
                    $("input[name='oh_comments<%=i%>']").val("<%= UtilMisc.htmlEscape(props.getProperty("oh_comments"+i, "")) %>");
                    $("input[name='oh_sex<%=i%>']").val("<%= UtilMisc.htmlEscape(props.getProperty("oh_sex"+i, "")) %>");
                    $("input[name='oh_weight<%=i%>']").val("<%= UtilMisc.htmlEscape(props.getProperty("oh_weight"+i, "")) %>");
                    $("input[name='oh_breastfed<%=i%>']").val("<%= UtilMisc.htmlEscape(props.getProperty("oh_breastfed"+i, "")) %>");
                    $("input[name='oh_health<%=i%>']").val("<%= UtilMisc.htmlEscape(props.getProperty("oh_health"+i, "")) %>");
                    <%}%>
                }
            });

            function loadCytologyForms() {
                <%
                if(cytologyForms != null && cytologyForms.size() > 0) {
                    if(cytologyForms.size() == 1) {
                %>
                popPage('<%=request.getContextPath()%>/eform/efmformadd_data.jsp?fid=<%=cytologyForms.get(0).getValue()%>&demographic_no=<%=demoNo%>&appointment=0','cytology');
                <%
                    } else {
                %>
                $("#cytology-eform-form").dialog("open");
                <%
                    }
                 } else {
                %>
                alert('No Cytology forms configured');
                <% } %>
            }

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

            window.onunload = refreshOpener;
        </script>
        <html:base />
    </head>
    <body bgproperties="fixed" topmargin="0" leftmargin="1" rightmargin="1">
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
            <div id="outdated_warn">
                <span title="The form you are viewing is no longer the latest version, please refresh.">Warning: Not latest version</span>
            </div>

            <br/>

            <div style="background-color:magenta;border:2px solid black;width:100%;color:black">
                <table style="width:100%" border="0">
                    <tr>
                        <td><b>Visit Checklist</b></td>
                    </tr>
                    <tr id="first_visit">
                        <td>First Visit<span style="float:right"><img id="1st_visit_menu" src="../images/right-circle-arrow-Icon.png" border="0"></span></td>
                    </tr>
                    <tr id="16wk_visit">
                        <td>16 week Visit<span style="float:right"><img id="16wk_visit_menu" src="../images/right-circle-arrow-Icon.png" border="0"></span></td>
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

                    <tr id="hgb_warn" style="display:none">
                        <td>HGB low</td>
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

                    
                    <tr id="smoking_warn" style="display:none">
                        <td>Goal: Smoking Cessation</td>
                    </tr>
                    <tr id="sickle_cell_warn" style="display:none">
                        <td>Risk: Sickle Cell</td>
                    </tr>
                    <tr id="thalassemia_warn" style="display:none">
                        <td>Risk: Thalassemia</td>
                    </tr>
                    <tr id="genetic_prompt" style="display:none">
                        <td>Genetics Referral<span style="float:right"><img id="genetics_menu"  src="../images/right-circle-arrow-Icon.png" border="0" ></span></td>
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
                </table>
            </div>
        </div>
    </div>


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
                            <input type="submit" value="Save" onclick="return onSave();" />
                            <input type="submit" value="Save and Exit" onclick="return onSaveExit();" />
                            <% } %>

                            <input type="submit" value="Exit" onclick="return onExit(<%=bView%>);" />
                            <input type="submit" value="Print" onclick="return onPrint();" />
                            <span style="display:none"><input id="printBtn" type="submit" value="PrintIt"/></span>


                            <%
                                if (!bView) {
                            %>
                            &nbsp;&nbsp;&nbsp;
                            <b>PR2:</b>
                            <a href="javascript:void(0)" onclick="popupPage(960,700,'formONPerinatalRecord2.jsp?demographic_no=<%=demoNo%>&formId=<%=formId%>&provNo=<%=provNo%>&view=1');">View</a>
                            &nbsp;&nbsp;&nbsp;
                            <a href="javascript:void(0)" onclick="return onPageChange('2');">Edit</a>

                            |

                            <b>PR3:</b>
                            <a href="javascript:void(0);" onclick="popupPage(960,700,'formONPerinatalRecord3.jsp?demographic_no=<%=demoNo%>&formId=<%=formId%>&provNo=<%=provNo+historyet%>&view=1');">View</a> &nbsp;&nbsp;&nbsp;</a>
                            <a href="javascript:void(0);" onclick="return onPageChange('3');">Edit</a>

                            |

                            <b>Resources:</b>
                            <a href="javascript:void(0);" onclick="popupPage(960,700,'formONPerinatalResources.jsp?demographic_no=<%=demoNo%>&formId=<%=formId%>&provNo=<%=provNo+historyet%>&view=1');">View</a> &nbsp;&nbsp;&nbsp;</a>
                            <a href="javascript:void(0);" onclick="return onPageChange('4');">Edit</a>

                            |

                            <b>Postnatal:</b>
                            <a href="javascript:void(0);" onclick="popupPage(960,700,'formONPerinatalPostnatal.jsp?demographic_no=<%=demoNo%>&formId=<%=formId%>&provNo=<%=provNo+historyet%>&view=1');">View</a> &nbsp;&nbsp;&nbsp;</a>
                            <a href="javascript:void(0);" onclick="return onPageChange('5');">Edit</a>
                        </td>
                        <% } %>
                    </tr>
                </table>

                <table class="title" border="0" cellspacing="0" cellpadding="0" width="100%">
                    <tr>
                        <th><%=bView?"<span class='alert-warning'>VIEW PAGE: </span>" : ""%>ONTARIO PERINATAL RECORD 1</th>
                    </tr>
                </table>

                <!-- Demographic Info -->
                <table width="50%" border="1" cellspacing="0" cellpadding="0">
                    <tr>
                        <td valign="top" width="50%">
                            Last Name<br/>
                            <input type="text" name="c_lastName" style="width: 100%" size="30" maxlength="60" value="<%= UtilMisc.htmlEscape(props.getProperty("c_lastName", "")) %>" />
                        </td>
                        <td valign="top" colspan='2'>
                            First Name<br/>
                            <input type="text" name="c_firstName" style="width: 100%" size="30" maxlength="60" value="<%= UtilMisc.htmlEscape(props.getProperty("c_firstName", "")) %>" />
                        </td>
                    </tr>
                    <tr>
                        <td>
                            Address - number, street name<br/>
                            <input type="text" name="c_address" style="width: 100%" size="60" maxlength="80" value="<%= UtilMisc.htmlEscape(props.getProperty("c_address", "")) %>" />
                        </td>

                        <td width="25%">
                            Apt/Suite/Unit<br/>
                            <input type="text" name="c_apt" style="width: 100%" size="20" maxlength="10" value="<%= UtilMisc.htmlEscape(props.getProperty("c_apt", "")) %>" />
                        </td>
                        <td width="25%">
                            Buzzer No<br/>
                            <input type="text" name="c_buzzer" style="width: 100%" size="20" maxlength="10" value="<%=UtilMisc.htmlEscape(props.getProperty("c_buzzer", "")) %>" />
                        </td>
                    </tr>
                </table>

                <table width="100%" border="1" cellspacing="0" cellpadding="0">
                    <tr>
                        <td valign="top">
                            City/Town<br/>
                            <input type="text" name="c_city" style="width: 100%" size="60" maxlength="80" value="<%= UtilMisc.htmlEscape(props.getProperty("c_city", "")) %>" />
                        </td>
                        <td valign="top" width="8%">
                            Province<br/>
                            <select name="c_province" style="width: 100%">
                                <option value="AB" >AB-Alberta</option>
                                <option value="BC" >BC-British Columbia</option>
                                <option value="MB" >MB-Manitoba</option>
                                <option value="NB" >NB-New Brunswick</option>
                                <option value="NL" >NL-Newfoundland Labrador</option>
                                <option value="NT" >NT-Northwest Territory</option>
                                <option value="NS" >NS-Nova Scotia</option>
                                <option value="NU" >NU-Nunavut</option>
                                <option value="ON" >ON-Ontario</option>
                                <option value="PE" >PE-Prince Edward Island</option>
                                <option value="QC" >QC-Quebec</option>
                                <option value="SK" >SK-Saskatchewan</option>
                                <option value="YT" >YT-Yukon</option>
                                <option value="US" >US resident</option>
                                <option value="US-AK" >US-AK-Alaska</option>
                                <option value="US-AL" >US-AL-Alabama</option>
                                <option value="US-AR" >US-AR-Arkansas</option>
                                <option value="US-AZ" >US-AZ-Arizona</option>
                                <option value="US-CA" >US-CA-California</option>
                                <option value="US-CO" >US-CO-Colorado</option>
                                <option value="US-CT" >US-CT-Connecticut</option>
                                <option value="US-CZ" >US-CZ-Canal Zone</option>
                                <option value="US-DC" >US-DC-District Of Columbia</option>
                                <option value="US-DE" >US-DE-Delaware</option>
                                <option value="US-FL" >US-FL-Florida</option>
                                <option value="US-GA" >US-GA-Georgia</option>
                                <option value="US-GU" >US-GU-Guam</option>
                                <option value="US-HI" >US-HI-Hawaii</option>
                                <option value="US-IA" >US-IA-Iowa</option>
                                <option value="US-ID" >US-ID-Idaho</option>
                                <option value="US-IL" >US-IL-Illinois</option>
                                <option value="US-IN" >US-IN-Indiana</option>
                                <option value="US-KS" >US-KS-Kansas</option>
                                <option value="US-KY" >US-KY-Kentucky</option>
                                <option value="US-LA" >US-LA-Louisiana</option>
                                <option value="US-MA" >US-MA-Massachusetts</option>
                                <option value="US-MD" >US-MD-Maryland</option>
                                <option value="US-ME" >US-ME-Maine</option>
                                <option value="US-MI" >US-MI-Michigan</option>
                                <option value="US-MN" >US-MN-Minnesota</option>
                                <option value="US-MO" >US-MO-Missouri</option>
                                <option value="US-MS" >US-MS-Mississippi</option>
                                <option value="US-MT" >US-MT-Montana</option>
                                <option value="US-NC" >US-NC-North Carolina</option>
                                <option value="US-ND" >US-ND-North Dakota</option>
                                <option value="US-NE" >US-NE-Nebraska</option>
                                <option value="US-NH" >US-NH-New Hampshire</option>
                                <option value="US-NJ" >US-NJ-New Jersey</option>
                                <option value="US-NM" >US-NM-New Mexico</option>
                                <option value="US-NU" >US-NU-Nunavut</option>
                                <option value="US-NV" >US-NV-Nevada</option>
                                <option value="US-NY" >US-NY-New York</option>
                                <option value="US-OH" >US-OH-Ohio</option>
                                <option value="US-OK" >US-OK-Oklahoma</option>
                                <option value="US-OR" >US-OR-Oregon</option>
                                <option value="US-PA" >US-PA-Pennsylvania</option>
                                <option value="US-PR" >US-PR-Puerto Rico</option>
                                <option value="US-RI" >US-RI-Rhode Island</option>
                                <option value="US-SC" >US-SC-South Carolina</option>
                                <option value="US-SD" >US-SD-South Dakota</option>
                                <option value="US-TN" >US-TN-Tennessee</option>
                                <option value="US-TX" >US-TX-Texas</option>
                                <option value="US-UT" >US-UT-Utah</option>
                                <option value="US-VA" >US-VA-Virginia</option>
                                <option value="US-VI" >US-VI-Virgin Islands</option>
                                <option value="US-VT" >US-VT-Vermont</option>
                                <option value="US-WA" >US-WA-Washington</option>
                                <option value="US-WI" >US-WI-Wisconsin</option>
                                <option value="US-WV" >US-WV-West Virginia</option>
                                <option value="US-WY" >US-WY-Wyoming</option>
                                <option value="OT" >Other</option>
                            </select>
                        </td>
                        <td width="12%">
                            Postal Code<br/>
                            <input type="text" name="c_postal" style="width: 100%" size="7" maxlength="7" value="<%= UtilMisc.htmlEscape(props.getProperty("c_postal", "")) %>" />
                        </td>
                        <td colspan="2" width="25%">
                            Partner's Last Name<br/>
                            <input type="text" name="c_partnerLastName" style="width: 100%" size="30" maxlength="60" value="<%= UtilMisc.htmlEscape(props.getProperty("c_partnerLastName", "")) %>" />
                        </td>
                        <td colspan="2" width="25%">
                            Partner's First Name<br/>
                            <input type="text" name="c_partnerFirstName" style="width: 100%" size="30" maxlength="60" value="<%= UtilMisc.htmlEscape(props.getProperty("c_partnerFirstName", "")) %>" />
                        </td>
                    </tr>
                </table>

                <table width="100%" border="1" cellspacing="0" cellpadding="0">
                    <tr>
                        <td width="30%" valign="top">
                            Contact - Preferred<br/>
                            <input type="text" name="c_contactPreferred" size="15" style="width: 100%" maxlength="20" value="<%= UtilMisc.htmlEscape(props.getProperty("c_contactPreferred", "")) %>" />
                            Leave Message?
                            Yes <input type="radio" name="c_contactLeaveMessage" value="Y" <%=UtilMisc.htmlEscape(props.getProperty("c_contactLeaveMessage", "")).equals("Y") ? "checked=checked" : ""%> />
                            No <input type="radio" name="c_contactLeaveMessage" value="N" <%=UtilMisc.htmlEscape(props.getProperty("c_contactLeaveMessage", "")).equals("N") ? "checked=checked" : ""%> />
                        </td>
                        <td width="20%" valign="top">
                            Contact - Alternate/Email<br/>
                            <input type="text" name="c_contactAlt" size="15" style="width: 100%" maxlength="50" value="<%= UtilMisc.htmlEscape(props.getProperty("c_contactAlt", "")) %>" />
                        </td>
                        <td width="20%" valign="top">
                            Partner's Occupation<br/>
                            <input type="text" name="c_partnerOccupation" size="10" style="width: 100%" maxlength="20" value="<%= UtilMisc.htmlEscape(props.getProperty("c_partnerOccupation", "")) %>" />
                        </td>
                        <td colspan="2" valign="top">
                            Partner's Education level <br/>
                            <select name="c_partnerEduLevel" style="width: 100%" >
                                <option value="UN">Select</option>
                                <option value="ED001">College/University Completed</option>
                                <option value="ED002">College/University not Completed</option>
                                <option value="ED004">High School Completed</option>
                                <option value="ED005">High School not Completed</option>
                                <option value="ED003">Grade School Completed</option>
                                <option value="ED006">Grade School not Completed</option>
                            </select>
                        </td>
                        <td width="8%" valign="top">
                            Age<br/>
                            <input type="text" name="c_partnerAge" style="width: 100%" size="5" maxlength="5" value="<%= UtilMisc.htmlEscape(props.getProperty("c_partnerAge", "")) %>" />
                        </td>
                    </tr>
                </table>

                <table width="100%" border="1" cellspacing="0" cellpadding="0">
                    <tr>
                        <td valign="top" width="10%">
                            Date of birth<br/>
                            <input type="text" name="c_dateOfBirth" style="width: 100%" size="10" maxlength="10" value="<%= UtilMisc.htmlEscape(props.getProperty("c_dateOfBirth", "")) %>"/>
                        </td>
                        <td width="10%" valign="top">
                            Age at EDB<br/>
                            <input type="text" name="c_age" style="width: 100%" size="10" maxlength="10" value="<%= UtilMisc.htmlEscape(props.getProperty("c_age", "")) %>" />
                        </td>
                        <td valign="top" width="15%">
                            Language<br/>
                            <select name="c_language"  style="width: 100%">
                                <option value="ENG">English</option>
                                <option value="FRA">French</option>
                                <option value="AAR">Afar</option>
                                <option value="AFR">Afrikaans</option>
                                <option value="AKA">Akan</option>
                                <option value="SQI">Albanian</option>
                                <option value="ASE">American Sign Language (ASL)</option>
                                <option value="AMH">Amharic</option>
                                <option value="ARA">Arabic</option>
                                <option value="ARG">Aragonese</option>
                                <option value="HYE">Armenian</option>
                                <option value="ASM">Assamese</option>
                                <option value="AVA">Avaric</option>
                                <option value="AYM">Aymara</option>
                                <option value="AZE">Azerbaijani</option>
                                <option value="BAM">Bambara</option>
                                <option value="BAK">Bashkir</option>
                                <option value="EUS">Basque</option>
                                <option value="BEL">Belarusian</option>
                                <option value="BEN">Bengali</option>
                                <option value="BIS">Bislama</option>
                                <option value="BOS">Bosnian</option>
                                <option value="BRE">Breton</option>
                                <option value="BUL">Bulgarian</option>
                                <option value="MYA">Burmese</option>
                                <option value="CAT">Catalan</option>
                                <option value="KHM">Central Khmer</option>
                                <option value="CHA">Chamorro</option>
                                <option value="CHE">Chechen</option>
                                <option value="YUE">Chinese Cantonese</option>
                                <option value="CMN">Chinese Mandarin</option>
                                <option value="CHV">Chuvash</option>
                                <option value="COR">Cornish</option>
                                <option value="COS">Corsican</option>
                                <option value="CRE">Cree</option>
                                <option value="HRV">Croatian</option>
                                <option value="CES">Czech</option>
                                <option value="DAN">Danish</option>
                                <option value="DIV">Dhivehi</option>
                                <option value="NLD">Dutch</option>
                                <option value="DZO">Dzongkha</option>
                                <option value="EST">Estonian</option>
                                <option value="EWE">Ewe</option>
                                <option value="FAO">Faroese</option>
                                <option value="FIJ">Fijian</option>
                                <option value="FIL">Filipino</option>
                                <option value="FIN">Finnish</option>
                                <option value="FUL">Fulah</option>
                                <option value="GLG">Galician</option>
                                <option value="LUG">Ganda</option>
                                <option value="KAT">Georgian</option>
                                <option value="DEU">German</option>
                                <option value="GRN">Guarani</option>
                                <option value="GUJ">Gujarati</option>
                                <option value="HAT">Haitian</option>
                                <option value="HAU">Hausa</option>
                                <option value="HEB">Hebrew</option>
                                <option value="HER">Herero</option>
                                <option value="HIN">Hindi</option>
                                <option value="HMO">Hiri Motu</option>
                                <option value="HUN">Hungarian</option>
                                <option value="ISL">Icelandic</option>
                                <option value="IBO">Igbo</option>
                                <option value="IND">Indonesian</option>
                                <option value="IKU">Inuktitut</option>
                                <option value="IPK">Inupiaq</option>
                                <option value="GLE">Irish</option>
                                <option value="ITA">Italian</option>
                                <option value="JPN">Japanese</option>
                                <option value="JAV">Javanese</option>
                                <option value="KAL">Kalaallisut</option>
                                <option value="KAN">Kannada</option>
                                <option value="KAU">Kanuri</option>
                                <option value="KAS">Kashmiri</option>
                                <option value="KAZ">Kazakh</option>
                                <option value="KIK">Kikuyu</option>
                                <option value="KIN">Kinyarwanda</option>
                                <option value="KIR">Kirghiz</option>
                                <option value="KOM">Komi</option>
                                <option value="KON">Kongo</option>
                                <option value="KOR">Korean</option>
                                <option value="KUA">Kuanyama</option>
                                <option value="KUR">Kurdish</option>
                                <option value="LAO">Lao</option>
                                <option value="LAV">Latvian</option>
                                <option value="LIM">Limburgan</option>
                                <option value="LIN">Lingala</option>
                                <option value="LIT">Lithuanian</option>
                                <option value="LUB">Luba-Katanga</option>
                                <option value="LTZ">Luxembourgish</option>
                                <option value="MKD">Macedonian</option>
                                <option value="MLG">Malagasy</option>
                                <option value="MSA">Malay</option>
                                <option value="MAL">Malayalam</option>
                                <option value="MLT">Maltese</option>
                                <option value="GLV">Manx</option>
                                <option value="MRI">Maori</option>
                                <option value="MAR">Marathi</option>
                                <option value="MAH">Marshallese</option>
                                <option value="ELL">Greek</option>
                                <option value="MON">Mongolian</option>
                                <option value="NAU">Nauru</option>
                                <option value="NAV">Navajo</option>
                                <option value="NDO">Ndonga</option>
                                <option value="NEP">Nepali</option>
                                <option value="NDE">North Ndebele</option>
                                <option value="SME">Northern Sami</option>
                                <option value="NOR">Norwegian</option>
                                <option value="NOB">Norwegian Bokm�l</option>
                                <option value="NNO">Norwegian Nynorsk</option>
                                <option value="NYA">Nyanja</option>
                                <option value="OCI">Occitan (post 1500)</option>
                                <option value="OJI">Ojibwa</option>
                                <option value="OJC">Oji-cree</option>
                                <option value="ORI">Oriya</option>
                                <option value="ORM">Oromo</option>
                                <option value="OSS">Ossetian</option>
                                <option value="PAN">Panjabi</option>
                                <option value="FAS">Persian</option>
                                <option value="POL">Polish</option>
                                <option value="POR">Portuguese</option>
                                <option value="PUS">Pushto</option>
                                <option value="QUE">Quechua</option>
                                <option value="RON">Romanian</option>
                                <option value="ROH">Romansh</option>
                                <option value="RUN">Rundi</option>
                                <option value="RUS">Russian</option>
                                <option value="SMO">Samoan</option>
                                <option value="SAG">Sango</option>
                                <option value="SRD">Sardinian</option>
                                <option value="GLA">Scottish Gaelic</option>
                                <option value="SRP">Serbian</option>
                                <option value="SNA">Shona</option>
                                <option value="III">Sichuan Yi</option>
                                <option value="SND">Sindhi</option>
                                <option value="SIN">Sinhala</option>
                                <option value="SGN">Other Sign Language</option>
                                <option value="SLK">Slovak</option>
                                <option value="SLV">Slovenian</option>
                                <option value="SOM">Somali</option>
                                <option value="NBL">South Ndebele</option>
                                <option value="SOT">Southern Sotho</option>
                                <option value="SPA">Spanish</option>
                                <option value="SUN">Sundanese</option>
                                <option value="SWA">Swahili (macrolanguage)</option>
                                <option value="SSW">Swati</option>
                                <option value="SWE">Swedish</option>
                                <option value="TGL">Tagalog</option>
                                <option value="TAH">Tahitian</option>
                                <option value="TGK">Tajik</option>
                                <option value="TAM">Tamil</option>
                                <option value="TAT">Tatar</option>
                                <option value="TEL">Telugu</option>
                                <option value="THA">Thai</option>
                                <option value="BOD">Tibetan</option>
                                <option value="TIR">Tigrinya</option>
                                <option value="TON">Tonga (Tonga Islands)</option>
                                <option value="TSO">Tsonga</option>
                                <option value="TSN">Tswana</option>
                                <option value="TUR">Turkish</option>
                                <option value="TUK">Turkmen</option>
                                <option value="TWI">Twi</option>
                                <option value="UIG">Uighur</option>
                                <option value="UKR">Ukrainian</option>
                                <option value="URD">Urdu</option>
                                <option value="UZB">Uzbek</option>
                                <option value="VEN">Venda</option>
                                <option value="VIE">Vietnamese</option>
                                <option value="WLN">Walloon</option>
                                <option value="CYM">Welsh</option>
                                <option value="FRY">Western Frisian</option>
                                <option value="WOL">Wolof</option>
                                <option value="XHO">Xhosa</option>
                                <option value="YID">Yiddish</option>
                                <option value="YOR">Yoruba</option>
                                <option value="ZHA">Zhuang</option>
                                <option value="ZUL">Zulu</option>
                                <option value="OTH">Other</option>
                                <option value="UN">Unknown</option>
                            </select>
                        </td>
                        <td valign="top" width="5%">
                            Interpreter Required<br/>
                            Yes <input type="radio" name="c_interpreter" value="Y" <%=UtilMisc.htmlEscape(props.getProperty("c_interpreter", "")).equals("Y") ? "checked=checked" : ""%> />
                            No <input type="radio" name="c_interpreter" value="N" <%=UtilMisc.htmlEscape(props.getProperty("c_interpreter", "")).equals("N") ? "checked=checked" : ""%> />
                        </td>
                        <td width="20%" valign="top">
                            Occupation<br/>
                            <input type="text" name="c_occupation" size="10" style="width: 100%" maxlength="20" value="<%= UtilMisc.htmlEscape(props.getProperty("c_occupation", "")) %>" />
                        </td>
                        <td width="20%" valign="top">
                            Education level<br/>
                            <select name="c_eduLevel" style="width: 100%">
                                <option value="UN">Select</option>
                                <option value="ED001">College/University Completed</option>
                                <option value="ED002">College/University not Completed</option>
                                <option value="ED004">High School Completed</option>
                                <option value="ED005">High School not Completed</option>
                                <option value="ED003">Grade School Completed</option>
                                <option value="ED006">Grade School not Completed</option>
                            </select>
                        </td>
                        <td width="5%" valign="top" nowrap>
                            Relationship status <br/>
                            <select name="c_maritalStatus">
                                <option value="UN">Unknown</option>
                                <option value="M">Married</option>
                                <option value="CL">Common Law</option>
                                <option value="DS">Divorced/Separated</option>
                                <option value="S">Single</option>
                            </select>
                        </td>
                        <td width="5%" valign="top" nowrap>
                            Sexual Orientation <br/>
                            <input type="text" name="c_sexualOrientation" size="10" style="width: 100%" maxlength="20" value="<%= UtilMisc.htmlEscape(props.getProperty("c_sexualOrientation", "")) %>" />
                        </td>
                    </tr>
                    <tr>
                        <td colspan="2" width="20%" valign="bottom">
                            <select name="c_hinType">
                                <option value="OHIP">OHIP</option>
                                <option value="RAMQ">RAMQ</option>
                                <option value="OTHER">OTHER</option>
                            </select>
                            <input type="text" name="c_hin" size="10" style="width: 100%" maxlength="20" value="<%= UtilMisc.htmlEscape(props.getProperty("c_hin", "")) %>" />
                        </td>
                        <td width="15%" valign="bottom">
                            Patient File No. <br/>
                            <input type="text" name="c_fileNo" size="10" style="width: 100%" maxlength="10" value="<%= UtilMisc.htmlEscape(props.getProperty("c_fileNo", "")) %>" />
                        </td>
                        <td width="17%" style="font-size: small">
                            Disability Requiring Accommodation<br/>
                            Yes <input type="radio" name="c_disability" value="Y" <%=UtilMisc.htmlEscape(props.getProperty("c_disability", "")).equals("Y") ? "checked=checked" : ""%> />
                            No <input type="radio" name="c_disability" value="N" <%=UtilMisc.htmlEscape(props.getProperty("c_disability", "")).equals("N") ? "checked=checked" : ""%>  />
                        </td>
                        <td colspan="2" valign="bottom">
                            Planned Place of Birth<br/>
                            <input type="text" name="c_birthPlace" size="20" style="width: 100%" maxlength="25" value="<%= UtilMisc.htmlEscape(props.getProperty("c_birthPlace", "")) %>" />
                        </td>
                        <td colspan="2" style="font-size: small">
                            Planned Birth Attendants<br/>
                            <input type="checkbox" name="c_baObs" <%=props.getProperty("c_baObs", "") %> /> OBS
                            <input type="checkbox" name="c_baFP" <%= props.getProperty("c_baFP", "") %> /> FP
                            <input type="checkbox" name="c_baMidwife" <%= props.getProperty("c_baMidwife", "") %> />Midwife <br/>
                            <input type="text" name="c_ba" size="10" style="width: 100%" maxlength="25" value="<%= UtilMisc.htmlEscape(props.getProperty("c_ba", "")) %>" />
                        </td>
                    </tr>

                    <tr rowspan="8">
                        <td colspan="4">
                            Newborn Care Provider<br/>
                            <label style="width: 49%;">
                                <span style="font-size: small">In Hospital</span>
                                <input type="text" name="c_newbornCareHospital" size="10" maxlength="25" style="width: 100%" value="<%= UtilMisc.htmlEscape(props.getProperty("c_newbornCareHospital", "")) %>" />
                            </label>
                            
                            <label style="width: 49%">
                                <span style="font-size: small">In Community</span>
                                <input type="text" name="c_newbornCareCommunity" size="10" maxlength="25" style="width: 100%" value="<%= UtilMisc.htmlEscape(props.getProperty("c_newbornCareCommunity", "")) %>" />
                            </label>
                        </td>

                        <td colspan="4" valign="bottom">
                            Family physician/Primary Care Provider<br/>
                            <input type="text" name="c_famPhys" size="30" maxlength="80" style="width: 100%" value="<%= UtilMisc.htmlEscape(props.getProperty("c_famPhys", "")) %>" />
                        </td>
                    </tr>
                </table>

                <table width="100%" border="1" cellspacing="0" cellpadding="0">
                    <tr>
                        <td width="50%">
                            Allergies or Sensitivities &nbsp;<a id="update_allergies_link" href="javascript:void(0)" onclick="updateAllergies();">Update from Chart</a><br/>
                            <div align="center">
                                <textarea id="c_allergies" name="c_allergies" style="width: 100%" cols="30" rows="4"><%= UtilMisc.htmlEscape(props.getProperty("c_allergies", "")) %></textarea>
                            </div>

                            <span id="c_allergies_count" class="characterCount" style="display:<%=bView ? "none" : "block"%>;text-align: right;">150 / 150</span>
                        </td>

                        <td width="50%">
                            Medications/Herbals&nbsp;<a id="update_meds_link" href="javascript:void(0)" onclick="updateMeds();">Update from Chart</a><br/>
                            <div align="center">
                                <textarea id="c_meds" name="c_meds" style="width: 100%" cols="30" rows="4"><%= UtilMisc.htmlEscape(props.getProperty("c_meds", "")) %></textarea>
                            </div>

                            <span id="c_meds_count" class="characterCount" style="display:<%=bView ? "none" : "block"%>;text-align: right;">150 / 150</span>
                        </td>
                    </tr>
                </table>

                <!-- Pregnancy Summary -->
                <table width="100%" border="1" cellspacing="0" cellpadding="0" style="border-bottom: none;">
                    <thead>
                    <th class="sectionHeader" colspan="3">
                        Pregnancy Summary
                    </th>
                    </thead>
                    
                    <tbody>
                    <tr>
                        <td valign="top" nowrap>
                            <table width="100%" border="1" cellspacing="0" cellpadding="0">
                                <tr>
                                    <td valign="bottom" nowrap>
                                        LMP <input type="text" name="ps_lmp" id="ps_lmp" size="10" maxlength="10" value="<%= UtilMisc.htmlEscape(props.getProperty("ps_lmp", "")) %>" />
                                        <img src="../images/cal.gif" id="ps_lmp_cal">
                                    </td>
                                    <td valign="bottom">
                                        Cycle q__
                                        <input type="text" name="ps_menCycle" size="7" maxlength="7" value="<%= UtilMisc.htmlEscape(props.getProperty("ps_menCycle", "")) %>" />
                                    </td>
                                    <td>
                                        Certain<br/>
                                        Yes <input type="radio" name="ps_certain" value="Y" <%=UtilMisc.htmlEscape(props.getProperty("ps_certain", "")).equals("Y") ? "checked=checked" : ""%> />
                                        No <input type="radio" name="ps_certain" value="N" <%=UtilMisc.htmlEscape(props.getProperty("ps_certain", "")).equals("N") ? "checked=checked" : ""%> />
                                    </td>

                                    <td>
                                        Regular<br/>
                                        Yes <input type="radio" name="ps_regular" value="Y" <%=UtilMisc.htmlEscape(props.getProperty("ps_regular", "")).equals("Y") ? "checked=checked" : ""%> />
                                        No <input type="radio" name="ps_regular" value="N" <%=UtilMisc.htmlEscape(props.getProperty("ps_regular", "")).equals("N") ? "checked=checked" : ""%> />
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        Planned Pregnancy<br/>
                                        Yes <input type="radio" name="ps_planned" value="Y" <%=UtilMisc.htmlEscape(props.getProperty("ps_planned", "")).equals("Y") ? "checked=checked" : ""%> />
                                        No <input type="radio" name="ps_planned" value="N" <%=UtilMisc.htmlEscape(props.getProperty("ps_planned", "")).equals("N") ? "checked=checked" : ""%> />
                                    </td>
                                    <td colspan="2" valign="bottom">
                                        Contraceptive type
                                        <input type="text" name="ps_contracep" size="15" maxlength="25" value="<%= UtilMisc.htmlEscape(props.getProperty("ps_contracep", "")) %>" />
                                    </td>
                                    <td>
                                        Last used<br/>
                                        <input type="text" name="ps_lastUsed" id="ps_lastUsed" size="10" maxlength="10" value="<%= UtilMisc.htmlEscape(props.getProperty("ps_lastUsed", "")) %>" />
                                        <img src="../images/cal.gif" id="ps_lastUsed_cal">
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        Conception Assisted<br/>
                                        Yes <input type="radio" name="ps_concep_assist" value="Y" <%=UtilMisc.htmlEscape(props.getProperty("ps_concep_assist", "")).equals("Y") ? "checked=checked" : ""%>  />
                                        No <input type="radio" name="ps_concep_assist" value="N" <%=UtilMisc.htmlEscape(props.getProperty("ps_concep_assist", "")).equals("N") ? "checked=checked" : ""%>  />
                                    </td>
                                    <td colspan="3" valign="bottom">
                                        Details<br/>
                                        <input type="text" name="ps_concep_details" size="10" style="width: 100%" maxlength="100" value="<%= UtilMisc.htmlEscape(props.getProperty("ps_concep_details", "")) %>" />
                                    </td>
                                </tr>
                            </table>

                        </td>

                        <td valign="top" nowrap>
                            <p>
                                EDB by LMP</br>
                                <input type="text" name="ps_edb" id="ps_edb" class="spe" onDblClick="calculateByLMP(this);" size="10" maxlength="10" value="<%= UtilMisc.htmlEscape(props.getProperty("ps_edb", "")) %>" />
                                <img src="../images/cal.gif" id="ps_edb_cal">
                            </p>

                            <p>
                                Final EDB<br/>
                                <input type="text" name="ps_edb_final" id="ps_edb_final" size="10" maxlength="10" value="<%= UtilMisc.htmlEscape(props.getProperty("ps_edb_final", "")) %>" />
                                <img src="../images/cal.gif" id="ps_edb_final_cal">
                            </p>
                        </td>


                        <td valign="top" width="35%" rowspan="2">
                            <u>Dating Method</u></br>
                            <input type="checkbox" name="ps_edbByT1" <%= props.getProperty("ps_edbByT1", "") %> />T<sub>1</sub>US
                            <input type="checkbox" name="ps_edbByT2" <%= props.getProperty("ps_edbByT2", "") %> />T<sub>2</sub>US
                            <input type="checkbox" name="ps_edbByLMP" <%= props.getProperty("ps_edbByLMP", "") %> />LMP<br/>

                            <input type="checkbox" name="ps_edbByIUI" <%= props.getProperty("ps_edbByIUI", "") %> />IUI
                            <input type="text" name="ps_iuiDate" id="ps_iuiDate" size="10" maxlength="10" value="<%= UtilMisc.htmlEscape(props.getProperty("ps_iuiDate", "")) %>" />
                            <img src="../images/cal.gif" id="ps_iuiDate_cal">
                            <br/>

                            <input type="checkbox" name="ps_edbByEt" <%= props.getProperty("ps_edbByEt", "") %> />Embryo Transfer
                            <input type="text" name="ps_etDate" id="ps_etDate" size="10" maxlength="10" value="<%= UtilMisc.htmlEscape(props.getProperty("ps_etDate", "")) %>" />
                            <img src="../images/cal.gif" id="ps_etDate_cal">
                            <br/>

                            <input type="checkbox" name="ps_edbByOther" <%= props.getProperty("ps_edbByOther", "") %> />Other
                        </td>
                    </tr>
                    </tbody>
                </table>

                <table width="100%" border="1" cellspacing="0" cellpadding="0">
                    <tr>
                        <td>
                            Gravida <input type="text" name="c_gravida" size="1" maxlength="3" value="<%= UtilMisc.htmlEscape(props.getProperty("c_gravida", "")) %>" />
                        </td>
                        <td>
                            Term <input type="text" name="c_term" size="1" maxlength="3" value="<%= UtilMisc.htmlEscape(props.getProperty("c_term", "")) %>" />
                        </td>
                        <td>
                            Premterm <input type="text" name="c_prem" size="1" maxlength="3" value="<%= UtilMisc.htmlEscape(props.getProperty("c_prem", "")) %>" />
                        </td>
                        <td valign="top">
                            Abortus <input type="text" name="c_abort" size="1" maxlength="3" value="<%= UtilMisc.htmlEscape(props.getProperty("c_abort", "")) %>" />
                        </td>
                        <td>
                            Living Children <input type="text" name="c_living" size="1" maxlength="3" value="<%= UtilMisc.htmlEscape(props.getProperty("c_living", "")) %>" />
                        </td>
                        <td>
                            Stillbirth(s) <input type="text" name="c_stillbirth" size="1" maxlength="3" value="<%= UtilMisc.htmlEscape(props.getProperty("c_stillbirth", "")) %>" />
                        </td>
                        <td>
                            Neonatal/Child Death <input type="text" name="c_neonatal" size="1" maxlength="3" value="<%= UtilMisc.htmlEscape(props.getProperty("c_neonatal", "")) %>" />
                        </td>
                    </tr>
                </table>

                <!-- Obstetrical History -->
                <table width="100%" border="1">
                    <input type="hidden" id="oh_num" name="oh_num" value="<%=ohNum%>"/>
                    <thead>
                    <th colspan="11" class="sectionHeader">
                        Obstetrical History
                    </th>
                    </thead>
                    
                    <tbody id="oh_results">
                    <tr align="center">
                        <td width="20">&nbsp;</td>
                        <td width="40">Year/Month</td>
                        <td width="80">Place<br/>of Birth</td>
                        <td width="60">Gest. age<br/>(wks)</td>
                        <td width="60">Labour<br/>Length (hrs)</td>
                        <td width="90">Type of Birth<br/><span style="font-size: small">SVB CS Ass'd</span></td>
                        <td nowrap>Comments regarding abortus, pregnancy, birth, and newborn<br/>(eg. GDM, HTN, IUGR, shoulder dystocia, PPH, OASIS, neonatal jaundice)</td>
                        <td width="30">Sex<br/>M/F</td>
                        <td width="60">Birth<br/>Weight (grams)</td>
                        <td width="90">Breastfed /<br/>Duration (months)</td>
                        <td width="90">Child's Current<br/>Health</td>
                    </tr>
                    </tbody>
                    
                    <tbody>
                    <tr>
                        <td colspan="11">
                            <input id="oh_add" type="button" value="Add New" onclick="addObstetricalHistory();"/>
                        </td>
                    </tr>
                    </tbody>
                </table>



                <table class="text-small" width="100%" border="1" cellspacing="0" cellpadding="0">
                    <thead>
                    <th colspan="3" class="sectionHeader" nowrap>
                        Medical History (provide details in comments)
                    </th>
                    </thead>

                    <tbody>
                    <tr>
                        <td valign="top" width="30%" style="min-width: 250px;">
                            <table width="100%" cellspacing="0" cellpadding="0" >
                                <tr class="subsection">
                                    <td colspan="4" nowrap>Current Pregnancy</td>
                                </tr>
                                <tr>
                                    <td width="6%">1</td>
                                    <td>Bleeding</td>
                                    <td><input type="radio" name="mh_1" value="Y" <%=UtilMisc.htmlEscape(props.getProperty("mh_1", "")).equals("Y") ? "checked=checked" : ""%> />Y</td>
                                    <td><input type="radio" name="mh_1" value="N" <%=UtilMisc.htmlEscape(props.getProperty("mh_1", "")).equals("N") ? "checked=checked" : ""%> />N</td>
                                </tr>
                                <tr>
                                    <td>2</td>
                                    <td>Nausea/vomiting</td>
                                    <td><input type="radio" name="mh_2" value="Y" <%=UtilMisc.htmlEscape(props.getProperty("mh_2", "")).equals("Y") ? "checked=checked" : ""%> />Y</td>
                                    <td><input type="radio" name="mh_2" value="N" <%=UtilMisc.htmlEscape(props.getProperty("mh_2", "")).equals("N") ? "checked=checked" : ""%> />N</td>
                                </tr>
                                <tr>
                                    <td valign="top">3</td>
                                    <td>Rash/fever/illness</td>
                                    <td><input type="radio" name="mh_3" value="Y" <%=UtilMisc.htmlEscape(props.getProperty("mh_3", "")).equals("Y") ? "checked=checked" : ""%> />Y</td>
                                    <td><input type="radio" name="mh_3" value="N" <%=UtilMisc.htmlEscape(props.getProperty("mh_3", "")).equals("N") ? "checked=checked" : ""%> />N</td>
                                </tr>
                                <tr>
                                    <td colspan="4">&nbsp;</td>
                                </tr>
                                <tr class="subsection">
                                    <td colspan="4" nowrap>Nutrition</td>
                                </tr>
                                <tr>
                                    <td width="6%">4</td>
                                    <td>Calcium adequate</td>
                                    <td><input type="radio" name="mh_4" value="Y" <%=UtilMisc.htmlEscape(props.getProperty("mh_4", "")).equals("Y") ? "checked=checked" : ""%> />Y</td>
                                    <td><input type="radio" name="mh_4" value="N" <%=UtilMisc.htmlEscape(props.getProperty("mh_4", "")).equals("N") ? "checked=checked" : ""%> />N</td>
                                </tr>
                                <tr>
                                    <td>5</td>
                                    <td>Vitamin D adequate</td>
                                    <td><input type="radio" name="mh_5" value="Y" <%=UtilMisc.htmlEscape(props.getProperty("mh_5", "")).equals("Y") ? "checked=checked" : ""%> />Y</td>
                                    <td><input type="radio" name="mh_5" value="N" <%=UtilMisc.htmlEscape(props.getProperty("mh_5", "")).equals("N") ? "checked=checked" : ""%> />N</td>
                                </tr>
                                <tr>
                                    <td valign="top">6</td>
                                    <td>Folic acid preconception</td>
                                    <td><input type="radio" name="mh_6" value="Y" <%=UtilMisc.htmlEscape(props.getProperty("mh_6", "")).equals("Y") ? "checked=checked" : ""%> />Y</td>
                                    <td><input type="radio" name="mh_6" value="N" <%=UtilMisc.htmlEscape(props.getProperty("mh_6", "")).equals("N") ? "checked=checked" : ""%> />N</td>
                                </tr>
                                <tr>
                                    <td valign="top">7</td>
                                    <td>Prenatal vitamin</td>
                                    <td><input type="radio" name="mh_7" value="Y" <%=UtilMisc.htmlEscape(props.getProperty("mh_7", "")).equals("Y") ? "checked=checked" : ""%> />Y</td>
                                    <td><input type="radio" name="mh_7" value="N" <%=UtilMisc.htmlEscape(props.getProperty("mh_7", "")).equals("N") ? "checked=checked" : ""%> />N</td>
                                </tr>
                                <tr>
                                    <td valign="top">8</td>
                                    <td>Food Access/quality adequate</td>
                                    <td><input type="radio" name="mh_8" value="Y" <%=UtilMisc.htmlEscape(props.getProperty("mh_8", "")).equals("Y") ? "checked=checked" : ""%> />Y</td>
                                    <td><input type="radio" name="mh_8" value="N" <%=UtilMisc.htmlEscape(props.getProperty("mh_8", "")).equals("N") ? "checked=checked" : ""%> />N</td>
                                </tr>
                                <tr>
                                    <td valign="top">9</td>
                                    <td>Dietary restrictions</td>
                                    <td><input type="radio" name="mh_9" value="Y" <%=UtilMisc.htmlEscape(props.getProperty("mh_9", "")).equals("Y") ? "checked=checked" : ""%> />Y</td>
                                    <td><input type="radio" name="mh_9" value="N" <%=UtilMisc.htmlEscape(props.getProperty("mh_9", "")).equals("N") ? "checked=checked" : ""%> />N</td>
                                </tr>
                                <tr>
                                    <td colspan="4">&nbsp;</td>
                                </tr>
                                <tr class="subsection">
                                    <td colspan="4" nowrap>Surgical History</td>
                                </tr>
                                <tr>
                                    <td valign="top">10</td>
                                    <td>Surgery</td>
                                    <td><input type="radio" name="mh_10" value="Y" <%=UtilMisc.htmlEscape(props.getProperty("mh_10", "")).equals("Y") ? "checked=checked" : ""%> />Y</td>
                                    <td><input type="radio" name="mh_10" value="N" <%=UtilMisc.htmlEscape(props.getProperty("mh_10", "")).equals("N") ? "checked=checked" : ""%> />N</td>
                                </tr>
                                <tr>
                                    <td valign="top">11</td>
                                    <td>Anaesthetic complications</td>
                                    <td><input type="radio" name="mh_11" value="Y" <%=UtilMisc.htmlEscape(props.getProperty("mh_11", "")).equals("Y") ? "checked=checked" : ""%> />Y</td>
                                    <td><input type="radio" name="mh_11" value="N" <%=UtilMisc.htmlEscape(props.getProperty("mh_11", "")).equals("N") ? "checked=checked" : ""%> />N</td>
                                </tr>
                                <tr>
                                    <td colspan="4">&nbsp;</td>
                                </tr>
                                <tr class="subsection">
                                    <td colspan="4" nowrap>Medical History</td>
                                </tr>
                                <tr>
                                <tr>
                                    <td valign="top">12</td>
                                    <td>Hypertension</td>
                                    <td><input type="radio" name="mh_12" value="Y" <%=UtilMisc.htmlEscape(props.getProperty("mh_12", "")).equals("Y") ? "checked=checked" : ""%> />Y</td>
                                    <td><input type="radio" name="mh_12" value="N" <%=UtilMisc.htmlEscape(props.getProperty("mh_12", "")).equals("N") ? "checked=checked" : ""%> />N</td>
                                </tr>
                                <tr>
                                    <td valign="top">13</td>
                                    <td>Cardiac / Pulmonary</td>
                                    <td><input type="radio" name="mh_13" value="Y" <%=UtilMisc.htmlEscape(props.getProperty("mh_13", "")).equals("Y") ? "checked=checked" : ""%> />Y</td>
                                    <td><input type="radio" name="mh_13" value="N" <%=UtilMisc.htmlEscape(props.getProperty("mh_13", "")).equals("N") ? "checked=checked" : ""%> />N</td>
                                </tr>
                                <tr>
                                    <td>14</td>
                                    <td>Endocrine</td>
                                    <td><input type="radio" name="mh_14" value="Y" <%=UtilMisc.htmlEscape(props.getProperty("mh_14", "")).equals("Y") ? "checked=checked" : ""%> />Y</td>
                                    <td><input type="radio" name="mh_14" value="N" <%=UtilMisc.htmlEscape(props.getProperty("mh_14", "")).equals("N") ? "checked=checked" : ""%> />N</td>
                                </tr>
                                <tr>
                                    <td>15</td>
                                    <td>GI / Liver</td>
                                    <td><input type="radio" name="mh_15" value="Y" <%=UtilMisc.htmlEscape(props.getProperty("mh_15", "")).equals("Y") ? "checked=checked" : ""%> />Y</td>
                                    <td><input type="radio" name="mh_15" value="N" <%=UtilMisc.htmlEscape(props.getProperty("mh_15", "")).equals("N") ? "checked=checked" : ""%> />N</td>
                                </tr>
                                <tr>
                                    <td>16</td>
                                    <td>Breast (incl. surgery)</td>
                                    <td><input type="radio" name="mh_16" value="Y" <%=UtilMisc.htmlEscape(props.getProperty("mh_16", "")).equals("Y") ? "checked=checked" : ""%> />Y</td>
                                    <td><input type="radio" name="mh_16" value="N" <%=UtilMisc.htmlEscape(props.getProperty("mh_16", "")).equals("N") ? "checked=checked" : ""%> />N</td>
                                </tr>
                                <tr>
                                    <td>17</td>
                                    <td>Gynecological (incl. surgery)</td>
                                    <td><input type="radio" name="mh_17" value="Y" <%=UtilMisc.htmlEscape(props.getProperty("mh_17", "")).equals("Y") ? "checked=checked" : ""%> />Y</td>
                                    <td><input type="radio" name="mh_17" value="N" <%=UtilMisc.htmlEscape(props.getProperty("mh_17", "")).equals("N") ? "checked=checked" : ""%> />N</td>
                                </tr>
                                <tr>
                                    <td>18</td>
                                    <td>Urinary tract</td>
                                    <td><input type="radio" name="mh_18" value="Y" <%=UtilMisc.htmlEscape(props.getProperty("mh_18", "")).equals("Y") ? "checked=checked" : ""%> />Y</td>
                                    <td><input type="radio" name="mh_18" value="N" <%=UtilMisc.htmlEscape(props.getProperty("mh_18", "")).equals("N") ? "checked=checked" : ""%> />N</td>
                                </tr>
                                <tr>
                                    <td>19</td>
                                    <td>MSK/Rheumatology</td>
                                    <td><input type="radio" name="mh_19" value="Y" <%=UtilMisc.htmlEscape(props.getProperty("mh_19", "")).equals("Y") ? "checked=checked" : ""%> />Y</td>
                                    <td><input type="radio" name="mh_19" value="N" <%=UtilMisc.htmlEscape(props.getProperty("mh_19", "")).equals("N") ? "checked=checked" : ""%> />N</td>
                                </tr>
                                <tr>
                                    <td>20</td>
                                    <td>Hematological</td>
                                    <td><input type="radio" name="mh_20" value="Y" <%=UtilMisc.htmlEscape(props.getProperty("mh_20", "")).equals("Y") ? "checked=checked" : ""%> />Y</td>
                                    <td><input type="radio" name="mh_20" value="N" <%=UtilMisc.htmlEscape(props.getProperty("mh_20", "")).equals("N") ? "checked=checked" : ""%> />N</td>
                                </tr>
                                <tr>
                                    <td>21</td>
                                    <td>Thromboembolic/coag</td>
                                    <td><input type="radio" name="mh_21" value="Y" <%=UtilMisc.htmlEscape(props.getProperty("mh_21", "")).equals("Y") ? "checked=checked" : ""%> />Y</td>
                                    <td><input type="radio" name="mh_21" value="N" <%=UtilMisc.htmlEscape(props.getProperty("mh_21", "")).equals("N") ? "checked=checked" : ""%> />N</td>
                                </tr>
                                <tr>
                                    <td>22</td>
                                    <td>Blood transfusion</td>
                                    <td><input type="radio" name="mh_22" value="Y" <%=UtilMisc.htmlEscape(props.getProperty("mh_22", "")).equals("Y") ? "checked=checked" : ""%> />Y</td>
                                    <td><input type="radio" name="mh_22" value="N" <%=UtilMisc.htmlEscape(props.getProperty("mh_22", "")).equals("N") ? "checked=checked" : ""%> />N</td>
                                </tr>
                                <tr>
                                    <td>23</td>
                                    <td>Neurological</td>
                                    <td><input type="radio" name="mh_23" value="Y" <%=UtilMisc.htmlEscape(props.getProperty("mh_23", "")).equals("Y") ? "checked=checked" : ""%> />Y</td>
                                    <td><input type="radio" name="mh_23" value="N" <%=UtilMisc.htmlEscape(props.getProperty("mh_23", "")).equals("N") ? "checked=checked" : ""%> />N</td>
                                </tr>
                                <tr>
                                    <td>24</td>
                                    <td>Other <input type="text" name="mh_24_other" size="8" maxlength="25" value="<%= UtilMisc.htmlEscape(props.getProperty("mh_24_other", "")) %>"></td>
                                    <td><input type="radio" name="mh_24" value="Y" <%=UtilMisc.htmlEscape(props.getProperty("mh_24", "")).equals("Y") ? "checked=checked" : ""%> />Y</td>
                                    <td><input type="radio" name="mh_24" value="N" <%=UtilMisc.htmlEscape(props.getProperty("mh_24", "")).equals("N") ? "checked=checked" : ""%> />N</td>
                                </tr>
                            </table>
                        </td>
                        <td valign="top" style="min-width: 250px">
                            <table width="100%" border="0" cellspacing="0" cellpadding="0">

                                <tr class="subsection">
                                    <td colspan="4" nowrap>Family History</td>
                                </tr>
                                <tr>
                                    <td width="6%">25</td>
                                    <td>Medical Conditions</td>
                                    <td><input type="radio" name="mh_25" value="Y" <%=UtilMisc.htmlEscape(props.getProperty("mh_25", "")).equals("Y") ? "checked=checked" : ""%> />Y</td>
                                    <td><input type="radio" name="mh_25" value="N" <%=UtilMisc.htmlEscape(props.getProperty("mh_25", "")).equals("N") ? "checked=checked" : ""%> />N</td>
                                </tr>
                                <tr>
                                    <td>&nbsp;</td>
                                    <td colspan="3">(eg. diabetes, thyroid, hypertension, thromboembolic, anaesthetic, menthal health).</td>
                                </tr>
                                <tr>
                                    <td colspan="4">&nbsp;</td>
                                </tr>
                                <tr class="subsection">
                                    <td colspan="4" nowrap>Genetic History of Gametes</td>
                                </tr>
                                <tr>
                                    <td>26</td>
                                    <td>Ethnic/racial background</td>
                                    <td colspan="2">&nbsp;</td>
                                </tr>
                                <tr>
                                    <td>&nbsp;</td>
                                    <td colspan="3">
                                        Egg&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                        <select name="mh_26_egg">
                                            <option value="UN">Select</option>
                                            <option value="ANC001">Aboriginal</option>
                                            <option value="ANC002">Asian</option>
                                            <option value="ANC005">Black</option>
                                            <option value="ANC007">Caucasian</option>
                                            <option value="OTHER">Other</option>
                                        </select>

                                        Age <input type="text" name="mh_26_age" size="2" maxlength="3" value="<%= UtilMisc.htmlEscape(props.getProperty("mh_26_age", "")) %>"/> yrs. <br/>
                                    </td>
                                </tr>
                                <tr>
                                    <td>&nbsp;</td>
                                    <td colspan="3">
                                        Sperm&nbsp;
                                        <select name="mh_26_sperm">
                                            <option value="UN">Select</option>
                                            <option value="ANC001">Aboriginal</option>
                                            <option value="ANC002">Asian</option>
                                            <option value="ANC005">Black</option>
                                            <option value="ANC007">Caucasian</option>
                                            <option value="OTHER">Other</option>
                                        </select>
                                    </td>
                                </tr>
                                <tr>
                                    <td>27</td>
                                    <td>Carrier screening: at risk?</td>
                                    <td><input type="radio" name="mh_27" value="Y" <%=UtilMisc.htmlEscape(props.getProperty("mh_27", "")).equals("Y") ? "checked=checked" : ""%> />Y</td>
                                    <td><input type="radio" name="mh_27" value="N" <%=UtilMisc.htmlEscape(props.getProperty("mh_27", "")).equals("N") ? "checked=checked" : ""%> />N</td>
                                </tr>
                                <tr>
                                    <td>&nbsp;</td>
                                    <td><li>Hemoglobinopathy screening</li></td>
                                    <td><input type="radio" name="mh_27_2" value="Y" <%=UtilMisc.htmlEscape(props.getProperty("mh_27_2", "")).equals("Y") ? "checked=checked" : ""%> />Y</td>
                                    <td><input type="radio" name="mh_27_2" value="N" <%=UtilMisc.htmlEscape(props.getProperty("mh_27_2", "")).equals("N") ? "checked=checked" : ""%> />N</td>
                                </tr>
                                <tr>
                                    <td>&nbsp;</td>
                                    <td colspan="3">
                                        (Asian, African, Middle Eastern, Mediterranean, Hispanic, Caribbean)
                                    </td>
                                </tr>
                                <tr>
                                    <td>&nbsp;</td>
                                    <td><li>Tay-Sachs disease screening</li></td>
                                    <td><input type="radio" name="mh_27_3" value="Y" <%=UtilMisc.htmlEscape(props.getProperty("mh_27_3", "")).equals("Y") ? "checked=checked" : ""%> />Y</td>
                                    <td><input type="radio" name="mh_27_3" value="N" <%=UtilMisc.htmlEscape(props.getProperty("mh_27_3", "")).equals("N") ? "checked=checked" : ""%> />N</td>
                                </tr>
                                <tr>
                                    <td>&nbsp;</td>
                                    <td colspan="3">
                                        (Ashkenazi Jewish, French Canadian, Acadian, Cajun)
                                    </td>
                                </tr>
                                <tr>
                                    <td>&nbsp;</td>
                                    <td><li>Ashkenazi Jewish screening panel</li></td>
                                    <td><input type="radio" name="mh_27_4" value="Y" <%=UtilMisc.htmlEscape(props.getProperty("mh_27_4", "")).equals("Y") ? "checked=checked" : ""%> />Y</td>
                                    <td><input type="radio" name="mh_27_4" value="N" <%=UtilMisc.htmlEscape(props.getProperty("mh_27_4", "")).equals("N") ? "checked=checked" : ""%> />N</td>
                                </tr>
                                <tr>
                                    <td>28</td>
                                    <td>Genetic Family History</td>
                                    <td colspan="2">&nbsp;</td>
                                </tr>
                                <tr>
                                    <td>&nbsp;</td>
                                    <td><li>Genetic Conditions</li></td>
                                    <td><input type="radio" name="mh_28" value="Y" <%=UtilMisc.htmlEscape(props.getProperty("mh_28", "")).equals("Y") ? "checked=checked" : ""%> />Y</td>
                                    <td><input type="radio" name="mh_28" value="N" <%=UtilMisc.htmlEscape(props.getProperty("mh_28", "")).equals("N") ? "checked=checked" : ""%> />N</td>
                                </tr>
                                <tr>
                                    <td>&nbsp;</td>
                                    <td colspan="3">
                                        (eg. CF, muscular dystrophy, chromosomal disorder)
                                    </td>
                                </tr>
                                <tr>
                                    <td>&nbsp;</td>
                                    <td><li>Other</li></td>
                                    <td><input type="radio" name="mh_28_2" value="Y" <%=UtilMisc.htmlEscape(props.getProperty("mh_28_2", "")).equals("Y") ? "checked=checked" : ""%> />Y</td>
                                    <td><input type="radio" name="mh_28_2" value="N" <%=UtilMisc.htmlEscape(props.getProperty("mh_28_2", "")).equals("N") ? "checked=checked" : ""%> />N</td>
                                </tr>
                                <tr>
                                    <td>&nbsp;</td>
                                    <td colspan="3">
                                        (eg. intellectual, birth defect, congenital heart, developmental delay, recurrent pregnancy loss, stillbirth)
                                    </td>
                                </tr>
                                <tr>
                                    <td>&nbsp;</td>
                                    <td><li>Consanguinity</li></td>
                                    <td><input type="radio" name="mh_28_3" value="Y" <%=UtilMisc.htmlEscape(props.getProperty("mh_28_3", "")).equals("Y") ? "checked=checked" : ""%> />Y</td>
                                    <td><input type="radio" name="mh_28_3" value="N" <%=UtilMisc.htmlEscape(props.getProperty("mh_28_3", "")).equals("N") ? "checked=checked" : ""%> />N</td>
                                </tr>
                                <tr>
                                    <td colspan="4">&nbsp;</td>
                                </tr>
                                <tr class="subsection">
                                    <td colspan="4" nowrap><b>Infectious Disease</b></td>
                                </tr>
                                <tr>
                                    <td>29</td>
                                    <td>Varicella disease</td>
                                    <td><input type="radio" name="mh_29" value="Y" <%=UtilMisc.htmlEscape(props.getProperty("mh_29", "")).equals("Y") ? "checked=checked" : ""%> />Y</td>
                                    <td><input type="radio" name="mh_29" value="N" <%=UtilMisc.htmlEscape(props.getProperty("mh_29", "")).equals("N") ? "checked=checked" : ""%> />N</td>
                                </tr>
                                <tr>
                                    <td>30</td>
                                    <td>Varicella vaccine</td>
                                    <td><input type="radio" name="mh_30" value="Y" <%=UtilMisc.htmlEscape(props.getProperty("mh_30", "")).equals("Y") ? "checked=checked" : ""%> />Y</td>
                                    <td><input type="radio" name="mh_30" value="N" <%=UtilMisc.htmlEscape(props.getProperty("mh_30", "")).equals("N") ? "checked=checked" : ""%> />N</td>
                                </tr>
                                <tr>
                                    <td>31</td>
                                    <td>HIV</td>
                                    <td><input type="radio" name="mh_31" value="Y" <%=UtilMisc.htmlEscape(props.getProperty("mh_31", "")).equals("Y") ? "checked=checked" : ""%> />Y</td>
                                    <td><input type="radio" name="mh_31" value="N" <%=UtilMisc.htmlEscape(props.getProperty("mh_31", "")).equals("N") ? "checked=checked" : ""%> />N</td>
                                </tr>
                                <tr>
                                    <td>32</td>
                                    <td>HSV <span style="float:right;">Self&nbsp;</span></td>
                                    <td><input type="radio" name="mh_32" value="Y" <%=UtilMisc.htmlEscape(props.getProperty("mh_32", "")).equals("Y") ? "checked=checked" : ""%> />Y</td>
                                    <td><input type="radio" name="mh_32" value="N" <%=UtilMisc.htmlEscape(props.getProperty("mh_32", "")).equals("N") ? "checked=checked" : ""%> />N</td>
                                </tr>
                                <tr>
                                    <td colspan="2">&nbsp; <span style="float:right;">Partner&nbsp;</span></td>
                                    <td><input type="radio" name="mh_32_2" value="Y" <%=UtilMisc.htmlEscape(props.getProperty("mh_32_2", "")).equals("Y") ? "checked=checked" : ""%> />Y</td>
                                    <td><input type="radio" name="mh_32_2" value="N" <%=UtilMisc.htmlEscape(props.getProperty("mh_32_2", "")).equals("N") ? "checked=checked" : ""%> />N</td>
                                </tr>
                                <tr>
                                    <td>33</td>
                                    <td>STIs</td>
                                    <td><input type="radio" name="mh_33" value="Y" <%=UtilMisc.htmlEscape(props.getProperty("mh_33", "")).equals("Y") ? "checked=checked" : ""%> />Y</td>
                                    <td><input type="radio" name="mh_33" value="N" <%=UtilMisc.htmlEscape(props.getProperty("mh_33", "")).equals("N") ? "checked=checked" : ""%> />N</td>
                                </tr>
                                <tr>
                                    <td>34</td>
                                    <td>At risk population (Hep C, TB, Parvo, Toxo)</td>
                                    <td><input type="radio" name="mh_34" value="Y" <%=UtilMisc.htmlEscape(props.getProperty("mh_34", "")).equals("Y") ? "checked=checked" : ""%> />Y</td>
                                    <td><input type="radio" name="mh_34" value="N" <%=UtilMisc.htmlEscape(props.getProperty("mh_34", "")).equals("N") ? "checked=checked" : ""%> />N</td>
                                </tr>
                                <tr>
                                    <td>35</td>
                                    <td>Other <input type="text" name="mh_35_other" size="10" maxlength="20" value="<%= UtilMisc.htmlEscape(props.getProperty("mh_35_other", "")) %>"></td>
                                    <td><input type="radio" name="mh_35" value="Y" <%=UtilMisc.htmlEscape(props.getProperty("mh_35", "")).equals("Y") ? "checked=checked" : ""%> />Y</td>
                                    <td><input type="radio" name="mh_35" value="N" <%=UtilMisc.htmlEscape(props.getProperty("mh_35", "")).equals("N") ? "checked=checked" : ""%> />N</td>
                                </tr>
                                <tr>
                                    <td colspan="4">&nbsp;</td>
                                </tr>

                            </table>
                        </td>
                        <td valign="top" width="30%" style="min-width: 250px">
                            <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                <tr class="subsection">
                                    <td colspan="4" nowrap>Mental Health / Substance Abuse</td>
                                </tr>

                                <tr>
                                    <td width="6%">36</td>
                                    <td>Anxiety <span style="float:right;">Past&nbsp;</span></td>
                                    <td><input type="radio" name="mh_36" value="Y" <%=UtilMisc.htmlEscape(props.getProperty("mh_36", "")).equals("Y") ? "checked=checked" : ""%> />Y</td>
                                    <td><input type="radio" name="mh_36" value="N" <%=UtilMisc.htmlEscape(props.getProperty("mh_36", "")).equals("N") ? "checked=checked" : ""%> />N</td>
                                </tr>

                                <tr>
                                    <td colspan="2">&nbsp; <span style="float:right;">Present&nbsp;</span></td>
                                    <td><input type="radio" name="mh_36_2" value="Y" <%=UtilMisc.htmlEscape(props.getProperty("mh_36_2", "")).equals("Y") ? "checked=checked" : ""%> />Y</td>
                                    <td><input type="radio" name="mh_36_2" value="N" <%=UtilMisc.htmlEscape(props.getProperty("mh_36_2", "")).equals("N") ? "checked=checked" : ""%> />N</td>
                                </tr>

                                <tr>
                                    <td colspan="2">&nbsp; <span style="float:right;">GAD-2 Score&nbsp;</span></td>
                                    <td colspan="2"><input type="text" name="mh_36_gad" value="<%=UtilMisc.htmlEscape(props.getProperty("mh_36_gad", ""))%>" size="2"/></td>
                                </tr>

                                <tr>
                                    <td>37</td>
                                    <td>Depression <span style="float:right;">Past&nbsp;</span></td>
                                    <td><input type="radio" name="mh_37" value="Y" <%=UtilMisc.htmlEscape(props.getProperty("mh_37", "")).equals("Y") ? "checked=checked" : ""%> />Y</td>
                                    <td><input type="radio" name="mh_37" value="N" <%=UtilMisc.htmlEscape(props.getProperty("mh_37", "")).equals("N") ? "checked=checked" : ""%> />N</td>
                                </tr>
                                <tr>
                                    <td colspan="2">&nbsp; <span style="float:right;">Present&nbsp;</span></td>
                                    <td><input type="radio" name="mh_37_2" value="Y" <%=UtilMisc.htmlEscape(props.getProperty("mh_37_2", "")).equals("Y") ? "checked=checked" : ""%> />Y</td>
                                    <td><input type="radio" name="mh_37_2" value="N" <%=UtilMisc.htmlEscape(props.getProperty("mh_37_2", "")).equals("N") ? "checked=checked" : ""%> />N</td>
                                </tr>
                                <tr>
                                    <td colspan="2">&nbsp; <span style="float:right;">PHQ-2 Score&nbsp;</span></td>
                                    <td colspan="2"><input type="text" name="mh_37_phq" value="<%=UtilMisc.htmlEscape(props.getProperty("mh_37_phq", ""))%>" size="2" /></td>
                                </tr>

                                <tr>
                                    <td>38</td>
                                    <td>Eating Disorder</td>
                                    <td><input type="radio" name="mh_38" value="Y" <%=UtilMisc.htmlEscape(props.getProperty("mh_38", "")).equals("Y") ? "checked=checked" : ""%> />Y</td>
                                    <td><input type="radio" name="mh_38" value="N" <%=UtilMisc.htmlEscape(props.getProperty("mh_38", "")).equals("N") ? "checked=checked" : ""%> />N</td>
                                </tr>

                                <tr>
                                    <td>39</td>
                                    <td>Bipolar</td>
                                    <td><input type="radio" name="mh_39" value="Y" <%=UtilMisc.htmlEscape(props.getProperty("mh_39", "")).equals("Y") ? "checked=checked" : ""%> />Y</td>
                                    <td><input type="radio" name="mh_39" value="N" <%=UtilMisc.htmlEscape(props.getProperty("mh_39", "")).equals("N") ? "checked=checked" : ""%> />N</td>
                                </tr>

                                <tr>
                                    <td>40</td>
                                    <td>Schizophrenia</td>
                                    <td><input type="radio" name="mh_40" value="Y" <%=UtilMisc.htmlEscape(props.getProperty("mh_40", "")).equals("Y") ? "checked=checked" : ""%> />Y</td>
                                    <td><input type="radio" name="mh_40" value="N" <%=UtilMisc.htmlEscape(props.getProperty("mh_40", "")).equals("N") ? "checked=checked" : ""%> />N</td>
                                </tr>

                                <tr>
                                    <td>41</td>
                                    <td>Other</td>
                                    <td><input type="radio" name="mh_41" value="Y" <%=UtilMisc.htmlEscape(props.getProperty("mh_41", "")).equals("Y") ? "checked=checked" : ""%> />Y</td>
                                    <td><input type="radio" name="mh_41" value="N" <%=UtilMisc.htmlEscape(props.getProperty("mh_41", "")).equals("N") ? "checked=checked" : ""%> />N</td>
                                </tr>
                                <tr>
                                    <td>&nbsp;</td>
                                    <td colspan="3">(eg. PTSD, ADD, personality disorders).</td>
                                </tr>

                                <tr>
                                    <td>42</td>
                                    <td>Smoked cig within the past 6 months</td>
                                    <td><input type="radio" name="mh_42" value="Y" <%=UtilMisc.htmlEscape(props.getProperty("mh_42", "")).equals("Y") ? "checked=checked" : ""%> />Y</td>
                                    <td><input type="radio" name="mh_42" value="N" <%=UtilMisc.htmlEscape(props.getProperty("mh_42", "")).equals("N") ? "checked=checked" : ""%> />N</td>
                                </tr>
                                <tr>
                                    <td colspan="2">&nbsp; <span style="float:right;">Current smoking&nbsp;</span></td>
                                    <td colspan="2"><input type="text" name="mh_42_cigs" value="<%=UtilMisc.htmlEscape(props.getProperty("mh_42_cigs", ""))%>" size="2" maxlength="4"/>&nbsp;cig/day</td>
                                </tr>

                                <tr>
                                    <td>43</td>
                                    <td>Ever drink alcohol? </td>
                                    <td><input type="radio" name="mh_43" value="Y" <%=UtilMisc.htmlEscape(props.getProperty("mh_43", "")).equals("Y") ? "checked=checked" : ""%> />Y</td>
                                    <td><input type="radio" name="mh_43" value="N" <%=UtilMisc.htmlEscape(props.getProperty("mh_43", "")).equals("N") ? "checked=checked" : ""%> />N</td>
                                </tr>
                                <tr>
                                    <td>&nbsp;</td>
                                    <td>If Yes: <span style="float:right;">Last drink (when): </span></td>
                                    <td colspan="2"><input type="text" name="mh_43_2" value="<%=UtilMisc.htmlEscape(props.getProperty("mh_43_2", ""))%>" size="7" maxlength="10"/></td>
                                </tr>
                                <tr>
                                    <td colspan="2"><span style="float:right;">Current drinking&nbsp;</span></td>
                                    <td colspan="2"><input type="text" name="mh_43_3" value="<%=UtilMisc.htmlEscape(props.getProperty("mh_43_3", ""))%>" size="2" maxlength="4"/>&nbsp;drinks/wk</td>
                                </tr>
                                <tr>
                                    <td colspan="2"><span style="float:right;">T-ACE Score&nbsp;</span></td>
                                    <td colspan="2"><input type="text" name="mh_43_4" value="<%=UtilMisc.htmlEscape(props.getProperty("mh_43_4", ""))%>" size="2" maxlength="4"/></td>
                                </tr>

                                <tr>
                                    <td>44</td>
                                    <td>Marijuana</td>
                                    <td><input type="radio" name="mh_44" value="Y" <%=UtilMisc.htmlEscape(props.getProperty("mh_44", "")).equals("Y") ? "checked=checked" : ""%> />Y</td>
                                    <td><input type="radio" name="mh_44" value="N" <%=UtilMisc.htmlEscape(props.getProperty("mh_44", "")).equals("N") ? "checked=checked" : ""%> />N</td>
                                </tr>

                                <tr>
                                    <td>45</td>
                                    <td>Non-prescribed substances/drugs</td>
                                    <td><input type="radio" name="mh_45" value="Y" <%=UtilMisc.htmlEscape(props.getProperty("mh_45", "")).equals("Y") ? "checked=checked" : ""%> />Y</td>
                                    <td><input type="radio" name="mh_45" value="N" <%=UtilMisc.htmlEscape(props.getProperty("mh_45", "")).equals("N") ? "checked=checked" : ""%> />N</td>
                                </tr>

                                <tr>
                                    <td colspan="4">&nbsp;</td>
                                </tr>

                                <tr class="subsection">
                                    <td colspan="4" nowrap>Lifestyle/Social</td>
                                </tr>

                                <tr>
                                    <td>46</td>
                                    <td>Occupational risks</td>
                                    <td><input type="radio" name="mh_46" value="Y" <%=UtilMisc.htmlEscape(props.getProperty("mh_46", "")).equals("Y") ? "checked=checked" : ""%> />Y</td>
                                    <td><input type="radio" name="mh_46" value="N" <%=UtilMisc.htmlEscape(props.getProperty("mh_46", "")).equals("N") ? "checked=checked" : ""%> />N</td>
                                </tr>

                                <tr>
                                    <td>47</td>
                                    <td>Financial/housing issues</td>
                                    <td><input type="radio" name="mh_47" value="Y" <%=UtilMisc.htmlEscape(props.getProperty("mh_47", "")).equals("Y") ? "checked=checked" : ""%> />Y</td>
                                    <td><input type="radio" name="mh_47" value="N" <%=UtilMisc.htmlEscape(props.getProperty("mh_47", "")).equals("N") ? "checked=checked" : ""%> />N</td>
                                </tr>

                                <tr>
                                    <td>48</td>
                                    <td>Poor social support</td>
                                    <td><input type="radio" name="mh_48" value="Y" <%=UtilMisc.htmlEscape(props.getProperty("mh_48", "")).equals("Y") ? "checked=checked" : ""%> />Y</td>
                                    <td><input type="radio" name="mh_48" value="N" <%=UtilMisc.htmlEscape(props.getProperty("mh_48", "")).equals("N") ? "checked=checked" : ""%> />N</td>
                                </tr>

                                <tr>
                                    <td>49</td>
                                    <td>Beliefs/practices affecting care</td>
                                    <td><input type="radio" name="mh_49" value="Y" <%=UtilMisc.htmlEscape(props.getProperty("mh_49", "")).equals("Y") ? "checked=checked" : ""%> />Y</td>
                                    <td><input type="radio" name="mh_49" value="N" <%=UtilMisc.htmlEscape(props.getProperty("mh_49", "")).equals("N") ? "checked=checked" : ""%> />N</td>
                                </tr>

                                <tr>
                                    <td>50</td>
                                    <td>Relationship problems</td>
                                    <td><input type="radio" name="mh_50" value="Y" <%=UtilMisc.htmlEscape(props.getProperty("mh_50", "")).equals("Y") ? "checked=checked" : ""%> />Y</td>
                                    <td><input type="radio" name="mh_50" value="N" <%=UtilMisc.htmlEscape(props.getProperty("mh_50", "")).equals("N") ? "checked=checked" : ""%> />N</td>
                                </tr>

                                <tr>
                                    <td>51</td>
                                    <td>Intimate partner/family violence</td>
                                    <td><input type="radio" name="mh_51" value="Y" <%=UtilMisc.htmlEscape(props.getProperty("mh_51", "")).equals("Y") ? "checked=checked" : ""%> />Y</td>
                                    <td><input type="radio" name="mh_51" value="N" <%=UtilMisc.htmlEscape(props.getProperty("mh_51", "")).equals("N") ? "checked=checked" : ""%> />N</td>
                                </tr>

                                <tr>
                                    <td>52</td>
                                    <td>Parenting concerns</td>
                                    <td><input type="radio" name="mh_52" value="Y" <%=UtilMisc.htmlEscape(props.getProperty("mh_52", "")).equals("Y") ? "checked=checked" : ""%> />Y</td>
                                    <td><input type="radio" name="mh_52" value="N" <%=UtilMisc.htmlEscape(props.getProperty("mh_52", "")).equals("N") ? "checked=checked" : ""%> />N</td>
                                </tr>
                                <tr>
                                    <td>&nbsp;</td>
                                    <td colspan="3">(eg. developmental disability, family trauma)</td>
                                </tr>

                                <tr>
                                    <td>53</td>
                                    <td>Other <input type="text" name="mh_53_other" size="10" maxlength="20" value="<%= UtilMisc.htmlEscape(props.getProperty("mh_53_other", "")) %>"></td>
                                    <td><input type="radio" name="mh_53" value="Y" <%=UtilMisc.htmlEscape(props.getProperty("mh_53", "")).equals("Y") ? "checked=checked" : ""%> />Y</td>
                                    <td><input type="radio" name="mh_53" value="N" <%=UtilMisc.htmlEscape(props.getProperty("mh_53", "")).equals("N") ? "checked=checked" : ""%> />N</td>
                                </tr>

                                <tr>
                                    <td colspan="4">&nbsp;</td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                    <tr>
                        <td></td>
                    </tr>
                    </tbody>
                </table>


                <table width="100%" border="1" cellspacing="0" cellpadding="0">
                    <thead>
                    <th colspan="4" class="sectionHeader" nowrap>
                       Comments
                    </th>
                    </thead>
                    <tbody>
                    <tr>
                        <td colspan="4">
                            <textarea id="pg1_comments" name="pg1_comments" style="width: 100%" cols="80" rows="5"><%= UtilMisc.htmlEscape(props.getProperty("pg1_comments", "")) %></textarea>
                        </td>
                    </tr>

                    <tr>
                        <td colspan="4">
                            <span id="pg1_comments_count" class="characterCount" style="display:<%=bView ? "none" : "block"%>;">885 / 885</span>
                        </td>
                    </tr>

                    <tr>
                        <td colspan="2">
                            Completed By<br/>
                            <input type="text" name="pg1_completedBy" size="30" maxlength="50" style="width: 80%" value="<%= UtilMisc.htmlEscape(props.getProperty("pg1_completedBy", "")) %>">
                        </td>
                        <td colspan="2">
                            Reviewed By<br/>
                            <input type="text" name="pg1_reviewedBy" size="30" maxlength="50" style="width: 80%" value="<%= UtilMisc.htmlEscape(props.getProperty("pg1_reviewedBy", "")) %>">
                        </td>
                    </tr>
                    <tr>
                        <td width="30%">
                            Signature<br/>
                            <input type="text" name="pg1_signature" size="30" maxlength="50" style="width: 80%" value="<%= UtilMisc.htmlEscape(props.getProperty("pg1_signature", "")) %>">
                        </td>
                        <td width="20%">
                            Date (yyyy/mm/dd)<br/>
                            <input type="text" name="pg1_formDate" class="spe" onDblClick="calToday(this)" size="10" maxlength="10" style="width: 80%" value="<%= props.getProperty("pg1_formDate", "") %>"></td>
                        <td width="30%">
                            Signature<br/>
                            <input type="text" name="pg1_signature_mrp" size="30" maxlength="50" style="width: 80%" value="<%= UtilMisc.htmlEscape(props.getProperty("pg1_signature_mrp", "")) %>">
                        </td>
                        <td width="20%">
                            Date (yyyy/mm/dd)<br/>
                            <input type="text" name="pg1_formDate2" class="spe" onDblClick="calToday(this)" size="10" maxlength="10" style="width: 80%" value="<%= props.getProperty("pg1_formDate2", "") %>">
                        </td>
                    </tr>
                    </tbody>
                </table>

                <table class="sectionHeader hidePrint">
                    <tr>
                        <td align="left">
                            <%
                                if (!bView) {
                            %>
                            <input type="submit" value="Save" onclick="return onSave();" />
                            <input type="submit" value="Save and Exit" onclick="return onSaveExit();" />
                            <% } %>
                            <input type="submit" value="Exit" onclick="return onExit(<%=bView%>);" />
                            <input type="submit" value="Print" onclick="return onPrint();" />
                            <%
                                if (!bView) {
                            %>
                            &nbsp;&nbsp;&nbsp;
                            <b>PR2:</b>
                            <a href="javascript:void(0)" onclick="popupPage(960,700,'formONPerinatalRecord2.jsp?demographic_no=<%=demoNo%>&formId=<%=formId%>&provNo=<%=provNo%>&view=1');">View</a>
                            &nbsp;&nbsp;&nbsp;
                            <a href="javascript:void(0)" onclick="return onPageChange('2');">Edit</a>

                            |

                            <b>PR3:</b>
                            <a href="javascript:void(0);" onclick="popupPage(960,700,'formONPerinatalRecord3.jsp?demographic_no=<%=demoNo%>&formId=<%=formId%>&provNo=<%=provNo+historyet%>&view=1');">View</a> &nbsp;&nbsp;&nbsp;</a>
                            <a href="javascript:void(0);" onclick="return onPageChange('3');">Edit</a>

                            |

                            <b>Resources:</b>
                            <a href="javascript:void(0);" onclick="popupPage(960,700,'formONPerinatalResources.jsp?demographic_no=<%=demoNo%>&formId=<%=formId%>&provNo=<%=provNo+historyet%>&view=1');">View</a> &nbsp;&nbsp;&nbsp;</a>
                            <a href="javascript:void(0);" onclick="return onPageChange('4');">Edit</a>

                            |

                            <b>Postnatal:</b>
                            <a href="javascript:void(0);" onclick="popupPage(960,700,'formONPerinatalPostnatal.jsp?demographic_no=<%=demoNo%>&formId=<%=formId%>&provNo=<%=provNo+historyet%>&view=1');">View</a> &nbsp;&nbsp;&nbsp;</a>
                            <a href="javascript:void(0);" onclick="return onPageChange('5');">Edit</a> 
                        </td>
                        <% } %>
                    </tr>
                </table>

            </html:form>
        </div>
    </div>
    </body>


    <div id="mcv_menu_div" title="Create Lab Requisition">
        <p class="validateTips"></p>

        <form>
            <fieldset>
                <input type="checkbox" name="ferritin" id="ferritin" class="text ui-widget-content ui-corner-all" />
                <label for="ferritin">Ferritin</label>
                <a href="javascript:void(0);" onclick="return false;" title="Consider to rule out iron deficiency"><img border="0" src="../images/icon_help_sml.gif"/></a>

                <br/>
                <input type="checkbox" name="hbElectrophoresis" id="hbElectrophoresis" value="" class="text ui-widget-content ui-corner-all" />
                <label for="hbElectrophoresis">Hb electrophoresis</label>
                <a href="javascript:void(0);" onclick="return false;" title="Consider to rule out Thalassemia in at-risk populations"><img border="0" src="../images/icon_help_sml.gif"/></a>
            </fieldset>
        </form>
    </div>

    <div id="genetic-ref-form" title="IPS Support Tool">
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

    <div id="lab_menu_div" class="hidden">
        <ul>
            <li><a href="javascript:void(0)" onclick="popPage('formlabreq<%=labReqVer %>.jsp?demographic_no=<%=demoNo%>&formId=0&provNo=<%=provNo%>&labType=AnteNatal','LabReq')">Routine Prenatal</a></li>
            <li><a href="javascript:void(0)" onclick="loadCytologyForms();">Cytology</a></li>
        </ul>
    </div>

    <div id="forms_menu_div" class="hidden">
        <ul>
            <li><a href="javascript:void(0)" onclick="loadUltrasoundForms();">Ultrasound</a></li>
            <li><a href="javascript:void(0)" onclick="loadIPSForms();">IPS</a></li>
        </ul>
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
            <li>
                <a href="javascript:void(0)" onclick ="popPage('<%=request.getContextPath()%>/eform/efmformadd_data.jsp?fid=<%=curForm.get("fid")%>&demographic_no=<%=demoNo%>&appointment=<%=appointment%>','<%=curForm.get("fid") + "_" + demoNo %>'); return true;">
                <%=curForm.get("formName")%></a>
            </li>
            <%
                }
            } else {
            %>
            <li><bean:message key="eform.showmyform.msgNoData"/></li>
            <%}%>
        </ul>
    </div>

    <div id="sickle_cell_menu_div" class="hidden">
        <ul>
            <li><a href="javascript:void(0)" onclick="return false;">Guidelines</a></li>
            <li><a href="javascript:void(0)" onclick="return false;">Patient Handout</a></li>
            <li><a href="javascript:void(0)" onclick="return false;">Referral</a></li>
            <li><a href="javascript:void(0)" onclick="return false;">Hide</a></li>
        </ul>
    </div>

    <div id="thalassemia_menu_div" class="hidden">
        <ul>
            <li><a href="javascript:void(0)" onclick="return false;">Guidelines</a></li>
            <li><a href="javascript:void(0)" onclick="return false;">Patient Handout</a></li>
            <li><a href="javascript:void(0)" onclick="return false;">Referral</a></li>
            <li><a href="javascript:void(0)" onclick="return false;">Hide</a></li>
        </ul>
    </div>

    <div id="genetics_menu_div" class="hidden">
        <ul>
            <li><a href="http://www.sogc.org/guidelines/documents/gui217CPG0810.pdf" target="sogc">SOGC Guidelines</a></li>
            <li><a href="<%=request.getContextPath()%>/pregnancy/genetics-provider-guide-e.pdf" target="sogc">Guide</a></li>
            <li><a href="javascript:void(0)" onclick="loadIPSForms();">IPS Forms</a></li>
        </ul>
    </div>

    <div id="1st-visit-form" title="First Visit">
        <form>
            <fieldset>
                <table>
                    <tbody>
                    <tr>
                        <td>
                            Enter Height, Weight, and BMI
                            <a href="javascript:void(0);" onclick="return false;" title="Enter values in form under Physical Examination"><img border="0" src="../images/icon_help_sml.gif"/></a>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            Order routine Prenatal Labs
                            <a href="javascript:void(0);" onclick="return false;" title="Click on 'Labs' menu item under Prompts, and choose Routine Prenatal"><img border="0" src="../images/icon_help_sml.gif"/></a>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            Order Integrated Prenatal Screening (IPS)
                            <a href="javascript:void(0);" onclick="return false;" title="Click on 'Forms' menu item under Prompts, and choose IPS"><img border="0" src="../images/icon_help_sml.gif"/></a>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            Order Ultrasound (Dating,IPS, or 18wk)
                            <a href="javascript:void(0);" onclick="return false;" title="Click on 'Forms' menu item under Prompts, and choose Ultrasound"><img border="0" src="../images/icon_help_sml.gif"/></a>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            Order Pap Smear
                            <a href="javascript:void(0);" onclick="return false;" title="Click on 'Labs' menu item under Prompts, and choose Cytology"><img border="0" src="../images/icon_help_sml.gif"/></a>
                        </td>
                    </tr>
                    </tbody>
                </table>
            </fieldset>
        </form>
    </div>
    
    <div id="16wk-visit-form" title="16 week Visit">
        <form>
            <fieldset>
                <table>
                    <tbody>
                    <tr>
                        <td>
                            Order 18 week morphology ultrasound
                            <a href="javascript:void(0);" onclick="return false;" title="Click on 'Forms' menu item under Prompts, and choose Ultrasound"><img border="0" src="../images/icon_help_sml.gif"/></a>
                        </td>
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


    <div id="dating-us-form" title="Dating Ultrasound">
        <p>Do you want to arrange a dating ultrasound?</p>
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

    <div id="print-log-dialog" title="Print Log">
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

</html:html>
