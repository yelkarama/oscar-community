
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
<%@ page import="org.oscarehr.common.dao.MeasurementDao" %>
<%@ page import="org.oscarehr.common.model.Measurement" %>

<%
    String formClass = "ONPerinatal";
    Integer pageNo = 3;
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
    if(StringUtils.isNullOrEmpty(props.getProperty("pe_wt", ""))) {
        MeasurementDao measurementDao = SpringUtils.getBean(MeasurementDao.class);
        Measurement weight = measurementDao.findLatestByDemographicNoAndType(demoNo, "WT");
        props.setProperty("pe_wt", weight != null ? weight.getDataField() : "");
    }
    
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
    int rfNum = Integer.parseInt(props.getProperty("rf_num", "0"));
    int svNum = Integer.parseInt(props.getProperty("sv_num", "0"));
%>

<html:html locale="true">
    <head>
        <title>Ontario Perinatal Record 3</title>
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

                $.when($.ajax(initRiskFactors())).then(function () {
                    loadRiskFactors();
                });

                $.when($.ajax(initSubsequentVisits())).then(function () {
                    loadSubsequentVisits();
                });
                
                function loadRiskFactors() {
                    <% for(int i = 1; i <= rfNum ; i++) { %>
                    $("input[name='rf_issues<%=i%>']").val("<%= UtilMisc.htmlEscape(props.getProperty("rf_issues"+i, "")) %>");
                    $("input[name='rf_plan<%=i%>']").val("<%= UtilMisc.htmlEscape(props.getProperty("rf_plan"+i, "")) %>");
                    <% } %>
                }

                function loadSubsequentVisits() {
                    <% for(int i = 1; i <= svNum ; i++) { %>
                    $("input[name='sv_date<%=i%>']").val("<%= UtilMisc.htmlEscape(props.getProperty("sv_date"+i, "")) %>");
                    $("input[name='sv_ga<%=i%>']").val("<%= UtilMisc.htmlEscape(props.getProperty("sv_ga"+i, "")) %>");
                    $("input[name='sv_wt<%=i%>']").val("<%= UtilMisc.htmlEscape(props.getProperty("sv_wt"+i, "")) %>");
                    $("input[name='sv_bp<%=i%>']").val("<%= UtilMisc.htmlEscape(props.getProperty("sv_bp"+i, "")) %>");
                    $("input[name='sv_urine<%=i%>']").val("<%= UtilMisc.htmlEscape(props.getProperty("sv_urine"+i, "")) %>");
                    $("input[name='sv_sfh<%=i%>']").val("<%= UtilMisc.htmlEscape(props.getProperty("sv_sfh"+i, "")) %>");
                    $("input[name='sv_pres<%=i%>']").val("<%= UtilMisc.htmlEscape(props.getProperty("sv_pres"+i, "")) %>");
                    $("input[name='sv_fhr<%=i%>']").val("<%= UtilMisc.htmlEscape(props.getProperty("sv_fhr"+i, "")) %>");
                    $("input[name='sv_fm<%=i%>']").val("<%= UtilMisc.htmlEscape(props.getProperty("sv_fm"+i, "")) %>");
                    $("input[name='sv_comments<%=i%>']").val("<%= UtilMisc.htmlEscape(props.getProperty("sv_comments"+i, "")) %>");
                    $("input[name='sv_next<%=i%>']").val("<%= UtilMisc.htmlEscape(props.getProperty("sv_next"+i, "")) %>");
                    $("input[name='sv_initial<%=i%>']").val("<%= UtilMisc.htmlEscape(props.getProperty("sv_initial"+i, "")) %>");
                    <% } %>
                }

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

                            <b>Resources:</b>
                            <a href="javascript:void(0);" onclick="popupPage(960,700,'formONPerinatalResources.jsp?demographic_no=<%=demoNo%>&formId=<%=formId%>&provNo=<%=provNo+historyet%>&view=1');">View</a> &nbsp;&nbsp;&nbsp;</a>
                            <a href="javascript:void(0);" onclick="return onPageChange('4');">Edit</a>

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
                        <th><%=bView?"<span class='alert-warning'>VIEW PAGE: </span>" : ""%>ONTARIO PERINATAL RECORD 3</th>
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

                    <tr>
                        <td valign="top" colspan="7">
                            Planned Birth Attendant<br/>
                            <input type="text" name="c_ba" size="15" style="width: 100%" maxlength="25" value="<%= UtilMisc.htmlEscape(props.getProperty("c_ba", "")) %>" />
                        </td>
                        <td colspan="7">&nbsp;</td>
                    </tr>

                    <tr>
                        <td colspan="7">
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

                        <td colspan="7">
                            Allergies or Sensitivities (include reaction)
                            <a id="update_allergies_link" href="javascript:void(0)" onclick="updateAllergies();">Update from Chart</a><br/>
                            <div align="center">
                                <textarea id="c_allergies" name="c_allergies" style="width: 100%" cols="30" rows="1"><%= UtilMisc.htmlEscape(props.getProperty("c_allergies", "")) %></textarea>
                            </div>
                                
                            <span id="c_allergies_count" class="characterCount" style="display:<%=bView ? "none" : ""%>;text-align: right;">150 / 150</span>
                        </td>
                    </tr>
                    
                    <tr>
                        <td valign="top" colspan="7">
                            Family physician/Primary Care Provider<br/>
                            <input type="text" name="c_famPhys" size="30" maxlength="80" style="width: 100%" value="<%= UtilMisc.htmlEscape(props.getProperty("c_famPhys", "")) %>" />
                        </td>
                        
                        <td colspan="7" rowspan="2">
                            Medications&nbsp;<a id="update_meds_link" href="javascript:void(0)" onclick="updateMeds();">Update from Chart</a><br/>
                            <div align="center">
                                <textarea id="c_meds" name="c_meds" style="width: 100%" cols="30" rows="4"><%= UtilMisc.htmlEscape(props.getProperty("c_meds", "")) %></textarea>
                            </div>

                            <span id="c_meds_count" class="characterCount" style="display:<%=bView ? "none" : "block"%>;text-align: right;">150 / 150</span>
                        </td>
                    </tr>

                    <tr>
                        <td valign="top" width="5%">
                            G<br/>
                            <input type="text" name="c_gravida" size="2" style="width: 100%" maxlength="3" value="<%= UtilMisc.htmlEscape(props.getProperty("c_gravida", "")) %>" />
                        </td>
                        <td valign="top" width="5%">
                            T<br/>
                            <input type="text" name="c_term" size="2" style="width: 100%" maxlength="3" value="<%= UtilMisc.htmlEscape(props.getProperty("c_term", "")) %>" />
                        </td>
                        <td valign="top" width="5%">
                            P<br/>
                            <input type="text" name="c_prem" size="2" style="width: 100%" maxlength="3" value="<%= UtilMisc.htmlEscape(props.getProperty("c_prem", "")) %>" />
                        </td>
                        <td valign="top" width="5%">
                            A<br/>
                            <input type="text" name="c_abort" size="2" style="width: 100%" maxlength="3" value="<%= UtilMisc.htmlEscape(props.getProperty("c_abort", "")) %>" />
                        </td>
                        <td valign="top" width="5%">
                            L<br/>
                            <input type="text" name="c_living" size="2" style="width: 100%" maxlength="3" value="<%= UtilMisc.htmlEscape(props.getProperty("c_living", "")) %>" />
                        </td>
                        <td valign="top" width="5%">
                            S<br/>
                            <input type="text" name="c_stillbirth" size="2" style="width: 100%" maxlength="3" value="<%= UtilMisc.htmlEscape(props.getProperty("c_stillbirth", "")) %>" />
                        </td>

                        <td valign="top" width="15%">
                            <label for="ps_edb_final"><b>Final EDB</b>(yyyy/mm/dd)</label>
                            <input type="text" name="ps_edb_final" id="ps_edb_final" size="10" maxlength="10" value="<%= UtilMisc.htmlEscape(props.getProperty("ps_edb_final", "")) %>" />
                            <img src="../images/cal.gif" id="ps_edb_final_cal">
                            
                        </td>
                    </tr>
                    
                    
                </table>

                <input type="hidden" id="rf_num" name="rf_num" value="<%=rfNum%>"/>

                <!-- Risk Factors: Issues & Plan of Management / Medication Change / Consultations -->
                <table width="100%" border="1" cellspacing="0" cellpadding="0">
                    <thead>
                    <th class="sectionHeader"></th>
                    <th class="sectionHeader">
                        Issues (abnormal results, medical/social problems)
                    </th>
                    <th class="sectionHeader">
                        Plan of Management / Medication Change / Consultations
                    </th>
                    </thead>

                    <tbody id="rf_results"></tbody>

                    <tbody>
                    <tr>
                        <td colspan="3"><input id="rf_add" type="button" value="Add New" onclick="addRiskFactor();" /></td>
                    </tr>
                    </tbody>
                </table>

                <!-- Special Circumstances & GBS -->
                <table width="100%" border="1" cellspacing="0" cellpadding="0">
                    <thead>
                    <th class="sectionHeader">
                        Special Circumstances
                    </th>
                    <th class="sectionHeader" style="border-left: 2px solid;">
                        GBS
                    </th>
                    </thead>

                    <tbody>
                    <tr>
                        <td width="70%">
                            <label>&nbsp;Low dose ASA indicated <input type="checkbox" name="sc_lowASA" <%=props.getProperty("sc_lowASA", "") %> /> </label>
                            <label>&nbsp;&nbsp;&nbsp;Progesterone indicated (PTB Prevention) <input type="checkbox" name="sc_ptb" <%=props.getProperty("sc_ptb", "") %> /> </label>
                            <label>&nbsp;&nbsp;&nbsp;HSV suppression indicated <input type="checkbox" name="sc_hsv"  <%=props.getProperty("sc_hsv", "") %> /> </label>
                        </td>
                        
                        <td rowspan="2" style="border-left: 2px solid;">
                            Rectovaginal swab <span class="text-small">
                            <input type="radio" name="gbi_swab" value="pos" <%=UtilMisc.htmlEscape(props.getProperty("gbi_swab", "")).equals("pos") ? "checked=checked" : ""%> /> pos 
                            <input type="radio" name="gbi_swab" value="neg" <%=UtilMisc.htmlEscape(props.getProperty("gbi_swab", "")).equals("neg") ? "checked=checked" : ""%> /> neg </span><br/>
                            Other indications for prophylaxis <span class="text-small">
                            <input type="radio" name="gbi_other" value="Y" <%=UtilMisc.htmlEscape(props.getProperty("gbi_other", "")).equals("Y") ? "checked=checked" : ""%> /> Y 
                            <input type="radio" name="gbi_other" value="N" <%=UtilMisc.htmlEscape(props.getProperty("gbi_other", "")).equals("N") ? "checked=checked" : ""%> /> N</span>
                        </td>
                    </tr>
                    
                    <tr>
                        <td align="top">
                            <label for="sc_social">
                                Social (eg. child protection, adoption, surrogacy)
                            </label>
                            <input type="text" id="sc_social" name="sc_social" style="width: 100%" maxlength="255" value="<%= UtilMisc.htmlEscape(props.getProperty("sc_social", "")) %>" />
                        </td>
                    </tr>
                    </tbody>
                </table>

                <!-- Recommended Immunoprophylaxis -->
                <table width="100%" border="1" cellspacing="0" cellpadding="0">
                    <thead>
                    <tr class="subsection">
                        <th colspan="5">Recommended Immunoprophylaxis</th>
                    </tr>
                    </thead>

                    <tbody class="text-small">
                    <tr>
                        <td>
                            <label id="rhNegSpan" style="width: 100%;">
                                <label for="ri_rhNeg">Rh(D) neg.</label>
                                <input type="checkbox" id="ri_rhNeg" name="ri_rhNeg" <%=UtilMisc.htmlEscape(props.getProperty("ri_rhNeg", ""))%> />
                            </label>
                            <br/>
                            
                            <label for="ri_rh_given">Rh(D) IG given</label>
                            <input type="text" id="ri_rh_given" name="ri_rh_given" size="10" maxlength="10" placeholder="YYYY/MM/DD" value="<%=UtilMisc.htmlEscape(props.getProperty("ri_rh_given", ""))%>" />
                            <br/>

                            <label for="ri_rh_given2">Additional dose given</label>
                            <input type="text" id="ri_rh_given2" name="ri_rh_given2" size="10" maxlength="10" placeholder="YYYY/MM/DD" value="<%=UtilMisc.htmlEscape(props.getProperty("ri_rh_given2", ""))%>" />
                        </td>
                        
                        <td>
                            <label for="ri_flu_discussed">Influenza Discussed</label>
                            <input type="checkbox" id="ri_flu_discussed" name="ri_flu_discussed" <%=UtilMisc.htmlEscape(props.getProperty("ri_flu_discussed", ""))%> />
                            <br/>
                            
                            <input type="radio" id="ri_flu_r" name="ri_flu" <%=UtilMisc.htmlEscape(props.getProperty("ri_flu", "")).equals("r") ? "checked=checked" : ""%> /> <label for="ri_flu_r">Received</label>
                            <input type="radio" id="ri_flu_d" name="ri_flu" <%=UtilMisc.htmlEscape(props.getProperty("ri_flu", "")).equals("d") ? "checked=checked" : ""%> /> <label for="ri_flu_d">Declined</label>
                        </td>

                        <td>
                            <label for="ri_per_discussed">Pertussis Discussed</label>
                            <input type="checkbox" id="ri_per_discussed" name="ri_per_discussed" <%=UtilMisc.htmlEscape(props.getProperty("ri_per_discussed", ""))%> />
                            <br/>

                            <input type="radio" name="ri_per_utd" value="Y" <%=UtilMisc.htmlEscape(props.getProperty("ri_per_utd", "")).equals("Y") ? "checked=checked" : ""%> /> Y 
                            <input type="radio" name="ri_per_utd" value="N" <%=UtilMisc.htmlEscape(props.getProperty("ri_per_utd", "")).equals("N") ? "checked=checked" : ""%> /> N
                            Year &nbsp; <input type="text" name="ri_per_utdYear" maxlength="4" size="5" placeholder="YYYY" value="<%=UtilMisc.htmlEscape(props.getProperty("ri_per_utdYear", ""))%>" /> 
                            <br/>

                            <input type="radio" id="ri_per_r" name="ri_per" value="r" <%=UtilMisc.htmlEscape(props.getProperty("ri_per", "")).equals("r") ? "checked=checked" : ""%> />  <label for="ri_per_r">Received</label>
                            <input type="radio" id="ri_per_d" name="ri_per" value="d" <%=UtilMisc.htmlEscape(props.getProperty("ri_per", "")).equals("d") ? "checked=checked" : ""%> /> <label for="ri_per_d">Declined</label>
                        </td>

                        <td>
                            Post-partum vaccines discussed
                            <br/>
                            <input type="checkbox" id="ri_ppv_rub" name="ri_ppv_rub" <%=UtilMisc.htmlEscape(props.getProperty("ri_ppv_rub", ""))%> />  <label for="ri_ppv_rub">Rubella</label>
                            <br/>
                            <input type="checkbox" id="ri_ppv_other" name="ri_ppv_other" <%=UtilMisc.htmlEscape(props.getProperty("ri_ppv_other", ""))%> /> <label for="ri_ppv_other">Other</label> 
                            <input type="text" name="ri_ppv_other_name" maxlength="15" size="15" value="<%=UtilMisc.htmlEscape(props.getProperty("ri_ppv_other_name", ""))%>" />
                        </td>

                        <td>
                            Newborn Needs
                            <br/>
                            <input type="checkbox" id="ri_nn_hb" name="ri_nn_hb" <%=UtilMisc.htmlEscape(props.getProperty("ri_nn_hb", ""))%> />  <label for="ri_nn_hb">Hep B prophylaxis</label>
                            <br/>
                            <input type="checkbox" id="ri_nn_other" name="ri_nn_other" <%=UtilMisc.htmlEscape(props.getProperty("ri_nn_other", ""))%> />  <label for="ri_nn_hb">HIV prophylaxis</label>
                        </td>
                    </tr>
                    
                    </tbody>
                </table>
                
                <!-- Subsequent visits -->
                <table width="100%" border="1" cellspacing="0" cellpadding="0">
                    <thead>
                    <tr>
                    <th colspan="6">
                        Pre-pregnancy Wt
                        <input type="text" id="pe_wt" name="pe_wt" size="6" maxlength="6" value="<%= UtilMisc.htmlEscape(props.getProperty("pe_wt", "")) %>"
                               ondblclick="weightImperialToMetric(this)" title="Double click to calculate weight from pounds to kg" />
                        kg

                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;BP
                        <input type="text" name="pe_bp" size="6" maxlength="10" value="<%=UtilMisc.htmlEscape(props.getProperty("pe_bp", "")) %>" />
                    </th>
                    <th colspan="7" class="subsection" width="70%">Subsequent Visits</th>
                    </tr>

                    </thead>

                    <thead>
                    <tr>
                        <th>&nbsp;</th>
                        <th>Date</th>
                        <th>GA <br/> (wks/days)</th>
                        <th>Weight <br/> (kg)</th>
                        <th>BP</th>
                        <th>Urine <br/> Prot.</th>
                        <th>SFH</th>
                        <th>Pres.</th>
                        <th>FHR</th>
                        <th>FM</th>
                        <th>Comments</th>
                        <th>Next Visit</th>
                        <th>Initial(s)</th>
                    </tr>
                    <input type="hidden" id="sv_num" name="sv_num" value="<%=svNum%>"/>
                    </thead>
                    
                    
                    <tbody id="sv_results">
                    
                    </tbody>
                    <tbody>
                    <tr>
                        <td colspan="13"><input id="sv_add" type="button" value="Add New" onclick="addSubsequentVisit();" /></td>
                    </tr>
                    </tbody>
                </table>

                <!-- Discussion Topics: 1st / 2nd / 3rd Trimester -->
                <table width="100%" border="1" cellspacing="0" cellpadding="0">
                    <thead>
                    <tr class="sectionHeader">
                        <th colspan="5">Discussion Topics</th>
                    </tr>

                    <tr class="subsection">
                        <th colspan="2">1<sup>st</sup> Trimester</th>
                        <th>2<sup>nd</sup> Trimester</th>
                        <th colspan="2">3<sup>rd</sup> Trimester</th>
                    </tr>
                    </thead>

                    <tbody class="text-small" style="border-bottom:none;">
                    <tr>
                        <td colspan="2"><label><input type="checkbox" name="trim1_nausea" <%=UtilMisc.htmlEscape(props.getProperty("trim1_nausea", ""))%> /> Nausea / Vomiting</label></td>
                        <td><label><input type="checkbox" name="trim2_classes" <%=UtilMisc.htmlEscape(props.getProperty("trim2_classes", ""))%> /> Prenatal classes</label></td>
                        <td style="border-right:none;"><label><input type="checkbox" name="trim3_fetalMove" <%=UtilMisc.htmlEscape(props.getProperty("trim3_fetalMove", ""))%> /> Fetal movement</label></td>
                        <td style="border-left:none;"><label><input type="checkbox" name="trim3_workPlan" <%=UtilMisc.htmlEscape(props.getProperty("trim3_workPlan", ""))%> /> Work plan / Maternity leave</label></td>
                    </tr>

                    <tr>
                        <td colspan="2"><label><input type="checkbox" name="trim1_routineCare" <%=UtilMisc.htmlEscape(props.getProperty("trim1_routineCare", ""))%> /> Routine prenatal care / Emergency contact / On call providers </label></td>
                        <td><label><input type="checkbox" name="trim2_preterm" <%=UtilMisc.htmlEscape(props.getProperty("trim2_preterm", ""))%> /> Preterm labour</label></td>
                        <td colspan="2"><label><input type="checkbox" name="trim3_birthPlan" <%=UtilMisc.htmlEscape(props.getProperty("trim3_birthPlan", ""))%> /> Birth plan: pain management, labour support</label></td>
                    </tr>

                    <tr>
                        <td colspan="2"><label><input type="checkbox" name="trim1_safety" <%=UtilMisc.htmlEscape(props.getProperty("trim1_safety", ""))%> /> Safety: food, medication, environment, infections, pets</label></td>
                        <td><label><input type="checkbox" name="trim2_prom" <%=UtilMisc.htmlEscape(props.getProperty("trim2_prom", ""))%> /> PROM</label></td>
                        <td colspan="2"><label><input type="checkbox" name="trim3_tob" <%=UtilMisc.htmlEscape(props.getProperty("trim3_tob", ""))%> /> Type of birth, potential interventions, VBAC pain</label></td>
                    </tr>

                    <tr>
                        <td style="border-right:none;"><label><input type="checkbox" name="trim1_weightGain" <%=UtilMisc.htmlEscape(props.getProperty("trim1_weightGain", ""))%> /> Healthy weight gain </label></td>
                        <td style="border-left:none;"><label><input type="checkbox" name="trim1_bf" <%=UtilMisc.htmlEscape(props.getProperty("trim1_bf", ""))%> /> Breastfeeding </label></td>
                        <td><label><input type="checkbox" name="trim2_bleed" <%=UtilMisc.htmlEscape(props.getProperty("trim2_bleed", ""))%> /> Bleeding </label></td>
                        <td style="border-right:none;"><label><input type="checkbox" name="trim3_admission" <%=UtilMisc.htmlEscape(props.getProperty("trim3_admission", ""))%> /> Admission timing</label></td>
                        <td style="border-left:none;"><label><input type="checkbox" name="trim3_mental" <%=UtilMisc.htmlEscape(props.getProperty("trim3_mental", ""))%> /> Mental health</label></td>
                    </tr>

                    <tr>
                        <td style="border-right:none;"><label><input type="checkbox" name="trim1_activity" <%=UtilMisc.htmlEscape(props.getProperty("trim1_activity", ""))%> /> Physical activity </label></td>
                        <td style="border-left:none;"><label><input type="checkbox" name="trim1_travel" <%=UtilMisc.htmlEscape(props.getProperty("trim1_travel", ""))%> /> Travel </label></td>
                        <td><label><input type="checkbox" name="trim2_fetalMove" <%=UtilMisc.htmlEscape(props.getProperty("trim2_fetalMove", ""))%> /> Fetal movement </label></td>
                        <td style="border-right:none;"><label><input type="checkbox" name="trim3_bf" <%=UtilMisc.htmlEscape(props.getProperty("trim3_bf", ""))%> /> Breastfeeding and support</label></td>
                        <td style="border-left:none;"><label><input type="checkbox" name="trim3_contra" <%=UtilMisc.htmlEscape(props.getProperty("trim3_contra", ""))%> /> Contraception</label></td>
                    </tr>

                    <tr>
                        <td style="border-right:none;"><label><input type="checkbox" name="trim1_seatbelt" <%=UtilMisc.htmlEscape(props.getProperty("trim1_seatbelt", ""))%> /> Seatbelt use</label></td>
                        <td style="border-left:none;"><label><input type="checkbox" name="trim1_qis" <%=UtilMisc.htmlEscape(props.getProperty("trim1_qis", ""))%> /> Quality information sources </label></td>
                        <td><label><input type="checkbox" name="trim2_mental" <%=UtilMisc.htmlEscape(props.getProperty("trim2_mental", ""))%> /> Mental health</label></td>
                        <td colspan="2"><label><input type="checkbox" name="trim3_care" <%=UtilMisc.htmlEscape(props.getProperty("trim3_care", ""))%> />  Newborn care / Screening tests / Circumcision / Follow-up appt.</label></td>
                    </tr>

                    <tr>
                        <td style="border-right:none;"><label><input type="checkbox" name="trim1_sexualActi" <%=UtilMisc.htmlEscape(props.getProperty("trim1_sexualActi", ""))%> /> Sexual activity</label></td>
                        <td style="border-left:none;"><label><input type="checkbox" name="trim1_vbac" <%=UtilMisc.htmlEscape(props.getProperty("trim1_vbac", ""))%> /> VBAC counselling</label></td>
                        <td><label><input type="checkbox" name="trim2_vbac" <%=UtilMisc.htmlEscape(props.getProperty("trim2_vbac", ""))%> /> VBAC consent</label></td>
                        <td style="border-right:none;"><label><input type="checkbox" name="trim3_planning" <%=UtilMisc.htmlEscape(props.getProperty("trim3_planning", ""))%> /> Discharge planning / Car seat safety</label></td>
                        <td style="border-left:none;"><label><input type="checkbox" name="trim3_postpartum" <%=UtilMisc.htmlEscape(props.getProperty("trim3_postpartum", ""))%> /> Postpartum care</label></td>
                    </tr>

                    </tbody>
                </table>

                <table width="100%" border="1" cellspacing="0" cellpadding="0">
                    <thead>
                    <th colspan="5" class="sectionHeader" nowrap>
                        Comments
                    </th>
                    </thead>
                    
                    <tbody>
                    <tr>
                        <td colspan="5">
                            <textarea id="pg3_comments" name="pg3_comments" style="width: 100%" cols="80" rows="5"><%= UtilMisc.htmlEscape(props.getProperty("pg3_comments", "")) %></textarea>
                        </td>
                    </tr>

                    <tr>
                        <td colspan="5">
                            <span id="pg3_comments_count" class="characterCount" style="display:<%=bView ? "none" : "block"%>;">885 / 885</span>
                        </td>
                    </tr>

                    <tr>
                        <td colspan="3" width="60%">&nbsp;</td>
                        <td colspan="2" style="border:2px solid;">
                            <label>Approx 36 weeks: Copy of OPR 2 (updated) & OPR 3 to hospital <input type="checkbox" name="pg3_hospitalCopy" <%=UtilMisc.htmlEscape(props.getProperty("pg3_hospitalCopy", ""))%> /> </label> &nbsp;&nbsp;&nbsp;  
                            <label>and/or to pt/client <input type="checkbox" name="pg3_ptCopy" <%=UtilMisc.htmlEscape(props.getProperty("pg3_ptCopy", ""))%>/> </label>
                        </td>
                    </tr>

                    <tr>
                        <td valign="top">
                            <label style="width: 100%">
                                1. Name / Initials <br/>
                                <input type="text" name="pg3_name1" size="30" style="width: 100%" maxlength="50" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_name1", "")) %>" />
                            </label>
                        </td>

                        <td valign="top">
                            <label style="width: 100%">
                                2. Name / Initials <br/>
                                <input type="text" name="pg3_name2" size="30" style="width: 100%" maxlength="50" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_name2", "")) %>" />
                            </label>
                            
                        </td>

                        <td valign="top">
                            <label style="width: 100%">
                                3. Name / Initials <br/>
                                <input type="text" name="pg3_name3" size="30" style="width: 100%" maxlength="50" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_name3", "")) %>" />
                            </label>
                        </td>

                        <td valign="top">
                            <label style="width: 100%">
                                4. Name / Initials <br/>
                                <input type="text" name="pg3_name4" size="30" style="width: 100%" maxlength="50" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_name4", "")) %>" />
                            </label>
                        </td>

                        <td valign="top">
                            <label style="width: 100%">
                                5. Name / Initials <br/>
                                <input type="text" name="pg3_name5" size="30" style="width: 100%" maxlength="50" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_name5", "")) %>" />
                            </label>
                        </td>
                    </tr>

                    
                    </tbody>
                </table>
                
                <table class="sectionHeader hidePrint">
                    <tr>
                        <td align="left">
                            <%
                                if (!bView) {
                            %> <input type="submit" value="Save"
                                      onclick="return onSave();" /> <input type="submit"
                                                                                      value="Save and Exit" onclick="return onSaveExit();" /> <%
                            }
                        %> <input type="submit" value="Exit"
                                  onclick="return onExit();" /> <input type="submit"
                                                                                  value="Print" onclick="return onPrint();" />
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

                            <b>Resources:</b>
                            <a href="javascript:void(0);" onclick="popupPage(960,700,'formONPerinatalResources.jsp?demographic_no=<%=demoNo%>&formId=<%=formId%>&provNo=<%=provNo+historyet%>&view=1');">View</a> &nbsp;&nbsp;&nbsp;</a>
                            <a href="javascript:void(0);" onclick="return onPageChange('4');">Edit</a>

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
