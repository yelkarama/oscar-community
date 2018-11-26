
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
    Integer pageNo = 5;
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
        <title>Ontario Perinatal Record - Postnatal Visit</title>
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

                            <b>Resources:</b>
                            <a href="javascript:void(0);" onclick="popupPage(960,700,'formONPerinatalResources.jsp?demographic_no=<%=demoNo%>&formId=<%=formId%>&provNo=<%=provNo+historyet%>&view=1');">View</a> &nbsp;&nbsp;&nbsp;</a>
                            <a href="javascript:void(0);" onclick="return onPageChange('4');">Edit</a>
                        </td>
                        <%
                            }
                        %>
                    </tr>
                </table>

                <table class="title" border="0" cellspacing="0" cellpadding="0" width="100%">
                    <tr>
                        <th><%=bView?"<span class='alert-warning'>VIEW PAGE: </span>" : ""%>ONTARIO PERINATAL RECORD<br/>POSTNATAL VISIT</th>
                    </tr>
                </table>

                <!-- Demographic Info -->
                <table width="100%" border="1" cellspacing="0" cellpadding="0">
                    <tr>
                        <td valign="top" colspan="3" width="25%">
                            Last Name<br/>
                            <input type="text" name="c_lastName" style="width: 100%" size="30" maxlength="60" value="<%= UtilMisc.htmlEscape(props.getProperty("c_lastName", "")) %>" />
                        </td>
                        <td valign="top" colspan="2" width="25%">
                            First Name<br/>
                            <input type="text" name="c_firstName" style="width: 100%" size="30" maxlength="60" value="<%= UtilMisc.htmlEscape(props.getProperty("c_firstName", "")) %>" />
                        </td>
                        <td colspan="5" width="50%"></td>
                    </tr>
                    
                    <tr>
                        <td valign="top" colspan="2">
                            Date of First Visit<br/>
                            <input type="text" name="visit_date" style="width: 100%" maxlength="10"  placeholder="YYYY/MM/DD" value="<%= UtilMisc.htmlEscape(props.getProperty("visit_date", "")) %>" />
                        </td>
                        <td valign="top" colspan="2">
                            Date of Delivery<br/>
                            <input type="text" name="delivery_date" style="width: 100%" maxlength="10"  placeholder="YYYY/MM/DD" value="<%= UtilMisc.htmlEscape(props.getProperty("delivery_date", "")) %>" />
                        </td>

                        <td valign="top" colspan="2">
                            Number of weeks postpartum<br/>
                            <input type="text" name="num_weeks_pp" style="width: 100%" maxlength="10" value="<%= UtilMisc.htmlEscape(props.getProperty("num_weeks_pp", "")) %>" />
                        </td>

                        <td valign="top" colspan="2">
                            GA at  birth<br/>
                            <input type="text" name="birth_ga" style="width: 100%" maxlength="10" value="<%= UtilMisc.htmlEscape(props.getProperty("birth_ga", "")) %>" />
                        </td>

                        <td valign="top" colspan="2">
                            Primary Care Provider<br/>
                            <input type="text" name="c_famPhys" size="30" maxlength="80" style="width: 100%" value="<%= UtilMisc.htmlEscape(props.getProperty("c_famPhys", "")) %>" />
                        </td>
                    </tr>
                    
                </table>
                

                <!-- History  -->
                <table width="100%" border="1" cellspacing="0" cellpadding="0">
                    <thead>
                    <th colspan="8" class="sectionHeader">History</th>
                    </thead>
                    
                    <tbody>
                    <tr class="no-border-sides">
                        <td>Review of Birth</td>
                        <td>Vaginal: </td>
                        <td width="10%"><label class="text-small"><input type="checkbox" name="rb_vaginal_spontaneous" <%= UtilMisc.htmlEscape(props.getProperty("rb_vaginal_spontaneous", "")) %> />Spontaneous</label> </td>
                        <td width="10%"><label class="text-small"><input type="checkbox" name="rb_vaginal_vacuum" <%= UtilMisc.htmlEscape(props.getProperty("rb_vaginal_vacuum", "")) %> /> Vacuum</label></td>
                        <td><label class="text-small"><input type="checkbox" name="rb_vaginal_forceps" <%= UtilMisc.htmlEscape(props.getProperty("rb_vaginal_forceps", "")) %> /> Forceps</label></td>
                        <td><label class="text-small"><input type="checkbox" name="rb_vaginal_vbac" <%= UtilMisc.htmlEscape(props.getProperty("rb_vaginal_vbac", "")) %> /> VBAC</label></td>
                        <td width="10%"><label class="text-small"><input type="checkbox" name="rb_vaginal_el" <%= UtilMisc.htmlEscape(props.getProperty("rb_vaginal_el", "")) %> /> Episiotomy / Lacerations</label></td>
                        <td><label class="text-small"><input type="checkbox" name="rb_vaginal_oasis" <%= UtilMisc.htmlEscape(props.getProperty("rb_vaginal_oasis", "")) %>/> OASIS</label></td>
                    </tr>
                    
                    <tr class="no-border-sides">
                        <td>&nbsp;</td>
                        <td>Caesarean: </td>
                        <td><label class="text-small"><input type="radio" name="rb_caesarean" value="planned" <%=UtilMisc.htmlEscape(props.getProperty("rb_caesarean", "")).equals("planned") ? "checked=checked" : ""%> /> Planned</label></td>
                        <td colspan="2"><label class="text-small"><input type="radio" name="rb_caesarean" value="unplanned" <%=UtilMisc.htmlEscape(props.getProperty("rb_caesarean", "")).equals("unplanned") ? "checked=checked" : ""%> /> Unplanned</label></td>
                        <td colspan="3" width="50%">&nbsp;</td>
                    </tr>
                    
                    <tr>
                        <td colspan="5">
                            <label for="historyDetails">Details</label><br/>
                            <textarea id="historyDetails" name="details" width="100%" cols="80"><%=UtilMisc.htmlEscape(props.getProperty("details", ""))%></textarea>
                        </td>
                        
                        <td colspan="3">
                            <label style="width: 100%">Birth Attendant
                            <input type="text" name="c_ba" style="width: 100%" maxlength="25" value="<%= UtilMisc.htmlEscape(props.getProperty("c_ba", "")) %>" />
                            </label>
                        </td>
                    </tr>

                    <tr>
                        <td colspan="8">
                            <label> Pregnancy/birth issues requiring follow up (eg. diabetes, hypertension, thyroid)
                                <input type="text" name="h_birth_issues" size="80" style="width: 100%" maxlength="225" value="<%= UtilMisc.htmlEscape(props.getProperty("h_birth_issues", "")) %>" /></label>
                        </td>
                    </tr>

                    <tr>
                        <td colspan="3">
                            <label style="width: 100%">Baby's name <input type="text" name="h_baby_name" style="width: 100%" maxlength="60" value="<%= UtilMisc.htmlEscape(props.getProperty("h_baby_name", "")) %>" /></label>
                        </td>

                        <td colspan="5">
                            <label style="width: 100%">Baby's Care Provider <input type="text" name="h_baby_cp" maxlength="80" style="width: 100%" value="<%= UtilMisc.htmlEscape(props.getProperty("c_famPhys", "")) %>" /></label>
                        </td>
                    </tr>
                    
                    <tr>
                        <td>
                            <label>Birth Weight (g) <input type="text" name="h_baby_weight" size="6" style="width: 100%" maxlength="10" value="<%= UtilMisc.htmlEscape(props.getProperty("h_baby_weight", "")) %>" /> </label>
                        </td>
                        <td colspan="7">
                            <label style="width: 100%">Baby's Health/Concerns<input type="text" name="h_baby_health" style="width: 100%" maxlength="225" value="<%= UtilMisc.htmlEscape(props.getProperty("h_baby_health", "")) %>" /> </label>
                        </td>
                    </tr>

                    <tr class="no-border-sides">
                        <td colspan="8">Infant feeding &nbsp;&nbsp;
                            <label class="text-small"><input type="radio" name="h_feeding" value="milk" <%=UtilMisc.htmlEscape(props.getProperty("h_feeding", "")).equals("milk") ? "checked=checked" : ""%> />Breast milk only</label> &nbsp;&nbsp;
                            <label class="text-small"><input type="radio" name="h_feeding" value="combination" <%=UtilMisc.htmlEscape(props.getProperty("h_feeding", "")).equals("combination") ? "checked=checked" : ""%> /> Combination of breast milk and milk substitute</label> &nbsp;&nbsp;
                            <label class="text-small"><input type="radio" name="h_feeding" value="substitute" <%=UtilMisc.htmlEscape(props.getProperty("h_feeding", "")).equals("substitute") ? "checked=checked" : ""%> /> Breast milk substitute only</label>
                        </td>
                    </tr>
                    
                    <tr>
                        <td colspan="8">
                            <label style="width: 100%">
                                Feeding concerns<br/>
                                <textarea id="h_feeding_concerns" name="h_feeding_concerns" width="100%" cols="125"><%=UtilMisc.htmlEscape(props.getProperty("h_feeding_concerns", ""))%></textarea>
                            </label>
                        </td>
                    </tr>

                    <tr>
                        <td colspan="8">
                            <label style="width: 100%">
                                Current Medications<br/>
                                <textarea id="h_meds" name="h_meds" style="width: 100%" cols="125"><%= UtilMisc.htmlEscape(props.getProperty("c_meds", "")) %><%=UtilMisc.htmlEscape(props.getProperty("h_meds", ""))%></textarea>
                            </label>
                        </td>
                    </tr>
                    
                    <tr>
                        <td colspan="4" width="50%">
                            <label>Bladder function<br/>
                                <input type="text" name="h_bladder" size="80" style="width: 100%" maxlength="225" value="<%= UtilMisc.htmlEscape(props.getProperty("h_bladder", "")) %>" />
                            </label>
                        </td>
                        <td colspan="4">
                            <label>Emotional wellbeing<br/>
                                <input type="text" name="h_wellbeing" size="80" style="width: 100%" maxlength="225" value="<%= UtilMisc.htmlEscape(props.getProperty("h_wellbeing", "")) %>" />
                            </label>
                        </td>
                    </tr>

                    <tr>
                        <td colspan="4" width="50%">
                            <label>Bowel function<br/>
                                <input type="text" name="h_bowel" size="80" style="width: 100%" maxlength="225" value="<%= UtilMisc.htmlEscape(props.getProperty("h_bowel", "")) %>" />
                            </label>
                        </td>
                        
                        <td colspan="4">
                            <label>Relationship<br/>
                                <input type="text" name="h_relation" size="80" style="width: 100%" maxlength="225" value="<%= UtilMisc.htmlEscape(props.getProperty("h_relation", "")) %>" />
                            </label>
                        </td>
                    </tr>

                    <tr>
                        <td colspan="4" width="50%">
                            <label>Sexual function<br/>
                                <input type="text" name="h_sf" size="80" style="width: 100%" maxlength="225" value="<%= UtilMisc.htmlEscape(props.getProperty("h_sf", "")) %>" />
                            </label>
                        </td>

                        <td colspan="4">
                            <label>Postpartum Depression Screen (EPDS or other)<br/>
                                <input type="text" name="h_ppd" size="80" style="width: 100%" maxlength="225" value="<%= UtilMisc.htmlEscape(props.getProperty("h_ppd", "")) %>" />
                            </label>
                        </td>
                    </tr>

                    <tr>
                        <td colspan="4" width="50%">
                            <label>Lochia / Menses<br/>
                                <input type="text" name="h_lm" size="80" style="width: 100%" maxlength="225" value="<%= UtilMisc.htmlEscape(props.getProperty("h_lm", "")) %>" />
                            </label>
                        </td>

                        <td colspan="4">
                            <label>Family Support / Community Resources<br/>
                                <input type="text" name="h_support" size="80" style="width: 100%" maxlength="225" value="<%= UtilMisc.htmlEscape(props.getProperty("h_support", "")) %>" />
                            </label>
                        </td>
                    </tr>

                    <tr>
                        <td colspan="4" width="50%">
                            <label>Perineum / Incision<br/>
                                <input type="text" name="h_pi" size="80" style="width: 100%" maxlength="225" value="<%= UtilMisc.htmlEscape(props.getProperty("h_pi", "")) %>"/>
                            </label>
                        </td>

                        <td colspan="4">&nbsp;</td>
                    </tr>

                    <tr>
                        <td colspan="4" width="50%">
                            <label>Smoking</label> &nbsp;&nbsp;&nbsp;
                            <label class="text-small"><input type="radio" name="h_smoke" value="N" <%=UtilMisc.htmlEscape(props.getProperty("h_smoke", "")).equals("N") ? "checked=checked" : ""%> /> No</label> &nbsp;
                            <label class="text-small"><input type="radio" name="h_smoke" value="Y" <%=UtilMisc.htmlEscape(props.getProperty("h_smoke", "")).equals("Y") ? "checked=checked" : ""%> /> Yes</label> &nbsp;
                            <label class="text-small"><input type="text" name="h_cigDay" size="2" maxlength="3" value="<%= UtilMisc.htmlEscape(props.getProperty("h_cigDay", "")) %>" />cig/day</label>
                        </td>

                        <td colspan="4">
                            <label>Alcohol</label> &nbsp;&nbsp;&nbsp;
                            <label class="text-small"><input type="radio" name="h_alc" value="N" <%=UtilMisc.htmlEscape(props.getProperty("h_alc", "")).equals("N") ? "checked=checked" : ""%> /> No</label> &nbsp;
                            <label class="text-small"><input type="radio" name="h_alc" value="Y" <%=UtilMisc.htmlEscape(props.getProperty("h_alc", "")).equals("Y") ? "checked=checked" : ""%> /> Yes</label> &nbsp;
                            <span class="text-small">
                                If yes: Drinks/wk <input type="text" name="h_drinkswk" size="2" maxlength="3" value="<%= UtilMisc.htmlEscape(props.getProperty("h_drinkswk", "")) %>" />
                                and if yes: T-ACE score <input type="text" name="h_tace" size="2" maxlength="3" value="<%= UtilMisc.htmlEscape(props.getProperty("h_tace", "")) %>" />
                            </span>
                        </td>
                    </tr>
                    
                    <tr>
                        <td colspan="8">
                            <label>Non-prescribed substances / drugs (eg. opioids, cocaine, marijuana, party drugs, other)</label> &nbsp;&nbsp;&nbsp;
                            <label class="text-small"><input type="radio" name="h_drug" value="N" <%=UtilMisc.htmlEscape(props.getProperty("h_drug", "")).equals("N") ? "checked=checked" : ""%> /> No</label> &nbsp;
                            <label class="text-small"><input type="radio" name="h_drug" value="Y" <%=UtilMisc.htmlEscape(props.getProperty("h_drug", "")).equals("Y") ? "checked=checked" : ""%> /> Yes</label>&nbsp;
                        </td>
                    </tr>

                    <tr>
                        <td colspan="4">
                            <label>Rubella Immune</label> &nbsp;&nbsp;&nbsp;
                            <label class="text-small"><input type="radio" name="h_rubella" value="Y" <%=UtilMisc.htmlEscape(props.getProperty("h_rubella", "")).equals("Y") ? "checked=checked" : ""%> /> Yes</label>&nbsp;
                            <label class="text-small"><input type="radio" name="h_rubella" value="N" <%=UtilMisc.htmlEscape(props.getProperty("h_rubella", "")).equals("N") ? "checked=checked" : ""%> /> No</label> &nbsp;
                            <label class="text-small"><input type="checkbox" name="h_rubella_discussed" <%=UtilMisc.htmlEscape(props.getProperty("h_rubella_discussed", ""))%> /> Discussed</label> &nbsp;
                            <label class="text-small"><input type="checkbox" name="h_rubella_declined" <%=UtilMisc.htmlEscape(props.getProperty("h_rubella_declined", ""))%> /> Declined</label> &nbsp;
                            <label class="text-small"><input type="checkbox" name="h_rubella_received" <%=UtilMisc.htmlEscape(props.getProperty("h_rubella_received", ""))%> /> Received</label> &nbsp;
                        </td>

                        <td colspan="4">
                            <label>Influenzea</label> &nbsp;&nbsp;&nbsp;
                            <label class="text-small"><input type="checkbox" name="h_flu_discussed" <%=UtilMisc.htmlEscape(props.getProperty("h_flu_discussed", ""))%> /> Discussed</label> &nbsp;
                            <label class="text-small"><input type="checkbox" name="h_flu_declined" <%=UtilMisc.htmlEscape(props.getProperty("h_flu_declined", ""))%> /> Declined</label> &nbsp;
                            <label class="text-small"><input type="checkbox" name="h_flu_received" <%=UtilMisc.htmlEscape(props.getProperty("h_flu_received", ""))%> /> Received</label>  
                            <span class="text-small">&nbsp; <input type="text" name="h_flu_date" maxlength="10" size="10" placeholder="YYYY/MM/DD" value="<%= UtilMisc.htmlEscape(props.getProperty("h_flu_date", "")) %>" /></span>
                        </td>
                    </tr>
                    
                    <tr>
                        <td colspan="4">
                            <label>Pertussis (TdAP) Up-to-date</label> &nbsp;&nbsp;&nbsp;
                            <label class="text-small"><input type="radio" name="h_tdap" value="Y" <%=UtilMisc.htmlEscape(props.getProperty("h_tdap_yes", "")).equals("Y") ? "checked=checked" : ""%> /> Yes</label>&nbsp;
                            <label class="text-small"><input type="radio" name="h_tdap" value="N" <%=UtilMisc.htmlEscape(props.getProperty("h_tdap_no", "")).equals("N") ? "checked=checked" : ""%> /> No</label> &nbsp;
                            <label class="text-small"><input type="checkbox" name="h_tdap_discussed" <%=UtilMisc.htmlEscape(props.getProperty("h_tdap_discussed", ""))%> /> Discussed</label> &nbsp;
                            <label class="text-small"><input type="checkbox" name="h_tdap_declined" <%=UtilMisc.htmlEscape(props.getProperty("h_tdap_declined", ""))%> /> Declined</label> &nbsp;
                            <label class="text-small"><input type="checkbox" name="h_tdap_received" <%=UtilMisc.htmlEscape(props.getProperty("h_tdap_received", ""))%> /> Received</label> &nbsp;
                        </td>

                        <td colspan="4">
                            <label>Other immunizations</label> &nbsp;&nbsp;&nbsp;
                            <input type="text" name="h_immun" size="80" style="width: 100%" maxlength="225" value="<%=UtilMisc.htmlEscape(props.getProperty("h_immun", ""))%>" />
                        </td>
                    </tr>
                    
                    <tr class="no-border-sides">
                        <td>
                            Last Pap <input type="text" name="h_pap_date" maxlength="10" size="10" placeholder="YYYY/MM/DD" value="<%=UtilMisc.htmlEscape(props.getProperty("h_pap_date", ""))%>" />
                        </td>

                        <td colspan="7">
                            Result <input type="text" name="h_pap_result" maxlength="255" size="80" value="<%=UtilMisc.htmlEscape(props.getProperty("h_pap_result", ""))%>" />
                        </td>
                    </tr>
                    
                    </tbody>
                </table>

                <!-- Physical Exam As Indicated -->
                <table width="100%" border="1" cellspacing="0" cellpadding="0">
                    <thead>
                    <th colspan="4" class="sectionHeader">Physical Exam As Indicated</th>
                    </thead>
                    
                    <tbody>
                    <tr>
                        <td>
                            <label>
                                Weight Today
                                <input type="text" id="peai_wt" name="peai_wt" size="6" maxlength="6" value="<%= UtilMisc.htmlEscape(props.getProperty("peai_wt", "")) %>"
                                       ondblclick="weightImperialToMetric(this)" title="Double click to calculate weight from pounds to kg" /> kg
                            </label>
                        </td>
                        
                        <td>
                            <label>
                                Pre-Delivery Wt
                                <input type="text" id="peai_pd_wt" name="peai_pd_wt" size="6" maxlength="6" value="<%= UtilMisc.htmlEscape(props.getProperty("peai_pd_wt", "")) %>"
                                       ondblclick="weightImperialToMetric(this)" title="Double click to calculate weight from pounds to kg" /> kg
                            </label>
                        </td>
                        
                        <td>
                            <label>
                                Pre-Pregnancy Wt
                                <input type="text" id="peai_pp_wt" name="peai_pp_wt" size="6" maxlength="6" value="<%= UtilMisc.htmlEscape(props.getProperty("peai_pp_wt", "")) %>"
                                   ondblclick="weightImperialToMetric(this)" title="Double click to calculate weight from pounds to kg" /> kg
                            </label>
                        </td>
                        
                        <td>
                            <label>
                                BP
                                <input type="text" name="peai_bp" size="6" maxlength="10" value="<%=UtilMisc.htmlEscape(props.getProperty("peai_bp", "")) %>" /> mm Hg
                            </label>
                        </td>
                    </tr>
                    
                    <tr>
                        <td colspan="2">
                            <table width="100%" cellspacing="0" cellpadding="0" >
                                <tbody class="text-small">
                                <tr>
                                    <td>Affect</td>
                                    <td><input type="radio" name="peai_affect" value="N" <%=UtilMisc.htmlEscape(props.getProperty("peai_affect", "")).equals("N") ? "checked=checked" : ""%> />N</td>
                                    <td><input type="radio" name="peai_affect" value="A" <%=UtilMisc.htmlEscape(props.getProperty("peai_affect", "")).equals("A") ? "checked=checked" : ""%> />Abn</td>

                                    <td>Abdomen</td>
                                    <td><input type="radio" name="peai_ab" value="N" <%=UtilMisc.htmlEscape(props.getProperty("peai_ab", "")).equals("N") ? "checked=checked" : ""%> />N</td>
                                    <td><input type="radio" name="peai_ab" value="A" <%=UtilMisc.htmlEscape(props.getProperty("peai_ab", "")).equals("A") ? "checked=checked" : ""%> />Abn</td>
                                </tr>

                                <tr>
                                    <td>Thyroid</td>
                                    <td><input type="radio" name="peai_thyroid" value="N" <%=UtilMisc.htmlEscape(props.getProperty("peai_thyroid", "")).equals("N") ? "checked=checked" : ""%> />N</td>
                                    <td><input type="radio" name="peai_thyroid" value="A" <%=UtilMisc.htmlEscape(props.getProperty("peai_thyroid", "")).equals("A") ? "checked=checked" : ""%> />Abn</td>

                                    <td>Perineum</td>
                                    <td><input type="radio" name="peai_peri" value="N" <%=UtilMisc.htmlEscape(props.getProperty("peai_peri", "")).equals("N") ? "checked=checked" : ""%> />N</td>
                                    <td><input type="radio" name="peai_peri" value="A" <%=UtilMisc.htmlEscape(props.getProperty("peai_peri", "")).equals("A") ? "checked=checked" : ""%> />Abn</td>
                                </tr>

                                <tr>
                                    <td>Breasts</td>
                                    <td><input type="radio" name="peai_breasts" value="N" <%=UtilMisc.htmlEscape(props.getProperty("peai_breasts", "")).equals("N") ? "checked=checked" : ""%> />N</td>
                                    <td><input type="radio" name="peai_breats" value="A" <%=UtilMisc.htmlEscape(props.getProperty("peai_breats", "")).equals("A") ? "checked=checked" : ""%> />Abn</td>

                                    <td>Pelvic</td>
                                    <td><input type="radio" name="peai_pelvic" value="N" <%=UtilMisc.htmlEscape(props.getProperty("peai_pelvic", "")).equals("N") ? "checked=checked" : ""%> />N</td>
                                    <td><input type="radio" name="peai_pelvic" value="A" <%=UtilMisc.htmlEscape(props.getProperty("peai_pelvic", "")).equals("A") ? "checked=checked" : ""%> />Abn</td>
                                </tr>
                                </tbody>

                            </table>
                        </td>
                        
                        <td colspan="2">
                            <label style="width: 100%">
                                Comments<br/>
                                <textarea id="peai_comments" name="peai_comments" style="width: 100%" rows="3" cols="80"><%=UtilMisc.htmlEscape(props.getProperty("peai_comments", ""))%><%=UtilMisc.htmlEscape(props.getProperty("peai_comments", ""))%></textarea>
                            </label>
                        </td>
                    </tr>
                    
                    
                    </tbody>
                </table>

                <!-- Discussion Topics -->
                <table width="100%" border="1" cellspacing="0" cellpadding="0">
                    <thead>
                    <th class="sectionHeader">Discussion Topics</th>
                    <th class="sectionHeader">Comments</th>
                    </thead>
                    
                    <tbody class="text-small">
                    <tr>
                        <td><label><input type="checkbox" name="dt_adjust" <%=UtilMisc.htmlEscape(props.getProperty("dt_adjust", ""))%> /> Transition to parenthoood/partner's adjustment</label></td>
                        <td width="60%"><input type="text" name="dt_adjust_c" style="width:100%;" maxlength="255" value="<%=UtilMisc.htmlEscape(props.getProperty("dt_adjust_c", ""))%>" /></td>
                    </tr>

                    <tr>
                        <td><label><input type="checkbox" name="dt_safety" <%=UtilMisc.htmlEscape(props.getProperty("dt_safety", ""))%> /> Family violence and safety</label></td>
                        <td width="60%"><input type="text" name="dt_safety_c" style="width:100%;" maxlength="255" value="<%=UtilMisc.htmlEscape(props.getProperty("dt_safety_c", ""))%>" /></td>
                    </tr>

                    <tr>
                        <td><label><input type="checkbox" name="dt_health" <%=UtilMisc.htmlEscape(props.getProperty("dt_health", ""))%> /> Nutrition/physical activity/healthy weight</label></td>
                        <td width="60%"><input type="text" name="dt_health_c" style="width:100%;" maxlength="255" value="<%=UtilMisc.htmlEscape(props.getProperty("dt_health_c", ""))%>" /></td>
                    </tr>


                    <tr>
                        <td><label><input type="checkbox" name="dt_substance" <%=UtilMisc.htmlEscape(props.getProperty("dt_substance", ""))%> /> Plan for management of alcohol/tobacco/substance use</label></td>
                        <td width="60%"><input type="text" name="dt_substance_c" style="width:100%;" maxlength="255" value="<%=UtilMisc.htmlEscape(props.getProperty("dt_substance_c", ""))%>" /></td>
                    </tr>

                    <tr>
                        <td><label><input type="checkbox" name="dt_contra" <%=UtilMisc.htmlEscape(props.getProperty("dt_contra", ""))%> /> Contraception</label></td>
                        <td width="60%"><input type="text" name="dt_contra_c" style="width:100%;" maxlength="255" value="<%=UtilMisc.htmlEscape(props.getProperty("dt_contra_c", ""))%>" /></td>
                    </tr>

                    <tr>
                        <td><label><input type="checkbox" name="dt_pelvic" <%=UtilMisc.htmlEscape(props.getProperty("dt_pelvic", ""))%> /> Pelvic floor excercises</label></td>
                        <td width="60%"><input type="text" name="dt_pelvic_c" style="width:100%;" maxlength="255" value="<%=UtilMisc.htmlEscape(props.getProperty("dt_pelvic_c", ""))%>" /></td>
                    </tr>


                    <tr>
                        <td><label><input type="checkbox" name="dt_resources" <%=UtilMisc.htmlEscape(props.getProperty("dt_resources", ""))%> /> Community resources (eg Healthy Babies Healthy Children)</label></td>
                        <td width="60%"><input type="text" name="dt_resources_c" style="width:100%;" maxlength="255" value="<%=UtilMisc.htmlEscape(props.getProperty("dt_resources_c", ""))%>" /></td>
                    </tr>

                    <tr>
                        <td><label><input type="checkbox" name="dt_advice" <%=UtilMisc.htmlEscape(props.getProperty("dt_advice", ""))%> /> Advice regarding future pregnancies and risks</label></td>
                        <td width="60%"><input type="text" name="dt_advice_c" style="width:100%;" maxlength="255" value="<%=UtilMisc.htmlEscape(props.getProperty("dt_advice_c", ""))%>" /></td>
                    </tr>


                    <tr>
                        <td><label><input type="checkbox" name="dt_preconcep" <%=UtilMisc.htmlEscape(props.getProperty("dt_preconcep", ""))%> /> Preconception planning</label></td>
                        <td width="60%"><input type="text" name="dt_preconcep_c" style="width:100%;" maxlength="255" value="<%=UtilMisc.htmlEscape(props.getProperty("dt_preconcep_c", ""))%>" /></td>
                    </tr>

                    <tr>
                        <td><label><input type="checkbox" name="dt_future_birth" <%=UtilMisc.htmlEscape(props.getProperty("dt_future_birth", ""))%> /> If CS, future mode of birth and pregnancy spacing</label></td>
                        <td width="60%"><input type="text" name="dt_future_birth_c" style="width:100%;" maxlength="255" value="<%=UtilMisc.htmlEscape(props.getProperty("dt_future_birth_c", ""))%>" /></td>
                    </tr>
                    <tr>
                        <td><label><input type="checkbox" name="dt_other" <%=UtilMisc.htmlEscape(props.getProperty("dt_other", ""))%> /> Other comments / concerns</label></td>
                        <td width="60%"><input type="text" name="dt_other_c" style="width:100%;" maxlength="255" value="<%=UtilMisc.htmlEscape(props.getProperty("dt_other_c", ""))%>" /></td>
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

                            <b>PR3:</b>
                            <a href="javascript:void(0);" onclick="popupPage(960,700,'formONPerinatalRecord3.jsp?demographic_no=<%=demoNo%>&formId=<%=formId%>&provNo=<%=provNo+historyet%>&view=1');">View</a> &nbsp;&nbsp;&nbsp;</a>
                            <a href="javascript:void(0);" onclick="return onPageChange('3');">Edit</a>

                            |

                            <b>Resources:</b>
                            <a href="javascript:void(0);" onclick="popupPage(960,700,'formONPerinatalResources.jsp?demographic_no=<%=demoNo%>&formId=<%=formId%>&provNo=<%=provNo+historyet%>&view=1');">View</a> &nbsp;&nbsp;&nbsp;</a>
                            <a href="javascript:void(0);" onclick="return onPageChange('4');">Edit</a>
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
