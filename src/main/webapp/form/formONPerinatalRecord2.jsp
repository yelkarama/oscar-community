
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
<%@ page import="org.oscarehr.common.model.Measurement" %>
<%@ page import="org.oscarehr.common.dao.MeasurementDao" %>

<%
    String formClass = "ONPerinatal";
    Integer pageNo = 2;
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
    if(StringUtils.isNullOrEmpty(props.getProperty("pe_ht", "")) && StringUtils.isNullOrEmpty(props.getProperty("pe_wt", ""))){
        MeasurementDao measurementDao = SpringUtils.getBean(MeasurementDao.class);
        Measurement height = measurementDao.findLatestByDemographicNoAndType(demoNo,"HT");
        Measurement weight = measurementDao.findLatestByDemographicNoAndType(demoNo,"WT");
        if(weight != null && height != null) {
            props.setProperty("pe_ht", height.getDataField());
            props.setProperty("pe_wt", weight.getDataField());
            if (height.getMeasuringInstruction() != null && height.getMeasuringInstruction().toLowerCase().contains("cm") &&
                    weight.getMeasuringInstruction() != null && weight.getMeasuringInstruction().toLowerCase().contains("kg")) {
                try {
                    double height_db = Double.parseDouble(height.getDataField()) / 100; //convert to meters
                    double weight_db = Double.parseDouble(weight.getDataField());
                    double bmi = ((double) Math.round((weight_db / (height_db * height_db)) * 10)) / 10; //BMI = weight / height^2 (kg/m^2)
                    props.setProperty("pe_bmi", "" + bmi);
                } catch (Exception e) {/* couldn't parse height/weight to calculate BMI, no action */}
            }
        }
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
    int usNum = Integer.parseInt(props.getProperty("us_num", "0"));
%>

<html:html locale="true">
    <head>
        <title>Ontario Perinatal Record 2</title>
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

                $("select[name='lab_ABO']").val('<%= UtilMisc.htmlEscape(props.getProperty("lab_ABO", "NDONE")) %>');
                $("select[name='lab_rh']").val('<%= UtilMisc.htmlEscape(props.getProperty("lab_rh", "NDONE")) %>');
                $("select[name='lab_rubella']").val('<%= UtilMisc.htmlEscape(props.getProperty("lab_rubella", "NDONE")) %>');
                $("select[name='lab_Hbsag']").val('<%= UtilMisc.htmlEscape(props.getProperty("lab_Hbsag", "NDONE")) %>');
                $("select[name='lab_syphilis']").val('<%= UtilMisc.htmlEscape(props.getProperty("lab_syphilis", "NDONE")) %>');
                $("select[name='lab_hiv']").val('<%= UtilMisc.htmlEscape(props.getProperty("lab_hiv", "NDONE")) %>');
                $("select[name='lab_gc']").val('<%= UtilMisc.htmlEscape(props.getProperty("lab_gc", "NDONE")) %>');
                $("select[name='lab_chlamydia']").val('<%= UtilMisc.htmlEscape(props.getProperty("lab_chlamydia", "NDONE")) %>');
                $("select[name='lab_ABO2']").val('<%= UtilMisc.htmlEscape(props.getProperty("lab_ABO2", "NDONE")) %>');
                $("select[name='lab_rh2']").val('<%= UtilMisc.htmlEscape(props.getProperty("lab_rh2", "NDONE")) %>');

                $.when($.ajax(initUltrasounds())).then(function () {
                    loadUltrasoundValues();
                });

                function loadUltrasoundValues() {
                    <%  
                    for(int i = 1; i <= usNum ; i++) {
                    %>    
                    $("input[name='us_date<%=i%>']").val("<%= UtilMisc.htmlEscape(props.getProperty("us_date"+i, "")) %>");
                    $("input[name='us_ga<%=i%>']").val("<%= UtilMisc.htmlEscape(props.getProperty("us_ga"+i, "")) %>");
                    <%     
                        if (i == 3) {
                    %>
                    $("input[name='us_result<%=i%>_as']").val("<%= UtilMisc.htmlEscape(props.getProperty("us_result"+i+"_as", "")) %>");
                    $("input[name='us_result<%=i%>_pl']").val("<%= UtilMisc.htmlEscape(props.getProperty("us_result"+i+"_pl", "")) %>");
                    $("input[name='us_result<%=i%>_sm']").val("<%= UtilMisc.htmlEscape(props.getProperty("us_result"+i+"_sm", "")) %>");
                    <% 
                        } else {
                    %>
                    $("input[name='us_result<%=i%>']").val("<%= UtilMisc.htmlEscape(props.getProperty("us_result"+i, "")) %>");
                    <%
                        }
                    }
                    %>
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

                    <tr id="weight_warn" style="display:none">
                        <td onClick="$('#pe_wt').focus();">No Weight Entered</td>

                    </tr>

                    <tr id="height_warn" style="display:none">
                        <td onClick="$('#pe_ht').focus();">No Height Entered</td>
                    </tr>

                    <tr id="bmi_warn" style="display:none"></tr>
                    
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

                    <tr id="mcv_abn_prompt" style="display:none">
                        <td>Low MCV<span style="float:right"><img id="mcv_menu" src="../images/right-circle-arrow-Icon.png" border="0"></span></td>
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

                    <tr id="pull_vitals_prompt" >
                        <td>Vitals Integration<span style="float:right"><img id="vitals_pull_menu" src="../images/right-circle-arrow-Icon.png" border="0"></span></td>
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
                        <%
                            }
                        %>
                    </tr>
                </table>

                <table class="title" border="0" cellspacing="0" cellpadding="0" width="100%">
                    <tr>
                        <th><%=bView?"<span class='alert-warning'>VIEW PAGE: </span>" : ""%>ONTARIO PERINATAL RECORD 2</th>
                    </tr>
                </table>
                <!-- Demographic Info -->
                <table width="100%" border="1" cellspacing="0" cellpadding="0">
                    <tr>
                        <td valign="top">
                            Last Name<br/>
                            <input type="text" name="c_lastName" style="width: 100%" size="30" maxlength="60" value="<%= UtilMisc.htmlEscape(props.getProperty("c_lastName", "")) %>" />
                        </td>
                        <td valign="top">
                            First Name<br/>
                            <input type="text" name="c_firstName" style="width: 100%" size="30" maxlength="60" value="<%= UtilMisc.htmlEscape(props.getProperty("c_firstName", "")) %>" />
                        </td>
                        <td colspan="2" width="50%"></td>
                    </tr>

                    <tr>
                        <td valign="top" colspan="4">
                            Planned Birth Attendant<br/>
                            <input type="text" name="c_ba" size="15" style="width: 100%" maxlength="25" value="<%= UtilMisc.htmlEscape(props.getProperty("c_ba", "")) %>">
                        </td>
                    </tr>

                    <tr>
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
                        
                    </tr>
                </table>
                
                <table width="100%" border="1" cellspacing="0" cellpadding="0">
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
                        
                        <td valign="top">
                            Family physician/Primary Care Provider<br/>
                            <input type="text" name="c_famPhys" size="30" maxlength="80" style="width: 100%" value="<%= UtilMisc.htmlEscape(props.getProperty("c_famPhys", "")) %>" />
                        </td>
                    </tr>
                </table>

                <!-- Physical Exam / Initial Laboratory Investigations / Second and Third Trimester Lab Investigations -->
                <table width="100%" border="1" cellspacing="0" cellpadding="0">
                    <tr>
                        <td valign="top" width="33%" style="min-height: 386px;">
                            <!-- Physical Exam -->
                            <table width="100%" border="2" cellspacing="0" cellpadding="0" style="min-width: 450px;">
                                <thead>
                                <th class="sectionHeader" colspan="6">
                                    Physical Exam
                                </th>
                                </thead>
                                
                                <tbody class="text-small" style="border: transparent;">
                                <tr>
                                    <td colspan="3">
                                        <label>
                                            Ht.
                                            <input type="text" id="pe_ht" name="pe_ht"  size="6" maxlength="6" value="<%= UtilMisc.htmlEscape(props.getProperty("pe_ht", "")) %>"
                                                   ondblclick="heightImperialToMetric(this)" title="Double click to calculate height from inches to cm" /> cm
                                        </label>
                                    </td>
                                    <td colspan="3">
                                        <label>
                                            Pre-pregnancy Wt &nbsp;
                                            <input type="text" id="pe_wt" name="pe_wt" size="6" maxlength="6" value="<%= UtilMisc.htmlEscape(props.getProperty("pe_wt", "")) %>"
                                                   ondblclick="weightImperialToMetric(this)" title="Double click to calculate weight from pounds to kg" />
                                            kg
                                        </label>
                                    </td>
                                </tr>

                                <tr>
                                    <td colspan="3">
                                        <label>
                                            BP
                                            <input type="text" name="pe_bp" size="6" maxlength="10" value="<%=UtilMisc.htmlEscape(props.getProperty("pe_bp", "")) %>" />
                                        </label>
                                    </td>
                                    <td colspan="3">
                                        <label>
                                            Pre-pregnancy BMI
                                            <input type="text" id="pe_bmi" name="pe_bmi"  size="6" maxlength="6" value="<%= UtilMisc.htmlEscape(props.getProperty("pe_bmi", "")) %>"
                                                   ondblclick="calculateBmi(this);" title="Double click to calculate BMI from height and weight" />
                                        </label>
                                    </td>
                                </tr>

                                <!-- Physical Exam - Exam As Indicated -->
                                <tr class="subsection">
                                    <th colspan="6">Exam As Indicated</th>
                                </tr>
                                <tr>
                                    <td>
                                        Head & Neck
                                    </td>

                                    <td>
                                        N <input type="radio" name="pe_head_neck" value="N" <%=UtilMisc.htmlEscape(props.getProperty("pe_head_neck", "")).equals("N") ? "checked=checked" : "" %> />
                                    </td>

                                    <td>
                                        Abn <input type="radio" name="pe_head_neck" value="A" <%=UtilMisc.htmlEscape(props.getProperty("pe_head_neck", "")).equals("A") ? "checked=checked" : ""%> />
                                    </td>

                                    <td>
                                        MSK
                                    </td>

                                    <td>
                                        N <input type="radio" name="pe_msk" value="N" <%=UtilMisc.htmlEscape(props.getProperty("pe_msk", "")).equals("N") ? "checked=checked" : ""%> />
                                    </td>

                                    <td>
                                        Abn <input type="radio" name="pe_msk" value="A" <%=UtilMisc.htmlEscape(props.getProperty("pe_msk", "")).equals("A") ? "checked=checked" : ""%> />
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        Breast/nipples
                                    </td>

                                    <td>
                                        N <input type="radio" name="pe_breast" value="N" <%=UtilMisc.htmlEscape(props.getProperty("pe_breast", "")).equals("N") ? "checked=checked" : "" %> />
                                    </td>

                                    <td>
                                        Abn <input type="radio" name="pe_breast" value="A" <%=UtilMisc.htmlEscape(props.getProperty("pe_breast", "")).equals("A") ? "checked=checked" : ""%> />
                                    </td>

                                    <td>
                                        Pelvic
                                    </td>

                                    <td>
                                        N <input type="radio" name="pe_pelvic" value="N" <%=UtilMisc.htmlEscape(props.getProperty("pe_pelvic", "")).equals("N") ? "checked=checked" : ""%> />
                                    </td>

                                    <td>
                                        Abn <input type="radio" name="pe_pelvic" value="A" <%=UtilMisc.htmlEscape(props.getProperty("pe_pelvic", "")).equals("A") ? "checked=checked" : ""%> />
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        Heart/lungs
                                    </td>

                                    <td>
                                        N <input type="radio" name="pe_heart_lungs" value="N" <%=UtilMisc.htmlEscape(props.getProperty("pe_heart_lungs", "")).equals("N") ? "checked=checked" : ""%> />
                                    </td>

                                    <td>
                                        Abn <input type="radio" name="pe_heart_lungs" value="A"<%=UtilMisc.htmlEscape(props.getProperty("pe_heart_lungs", "")).equals("A") ? "checked=checked" : ""%> />
                                    </td>

                                    <td>
                                        Other
                                    </td>

                                    <td>
                                        N <input type="radio" name="pe_other" value="N" <%=UtilMisc.htmlEscape(props.getProperty("pe_other", "")).equals("N") ? "checked=checked" : ""%>  />
                                    </td>

                                    <td>
                                        Abn <input type="radio" name="pe_other" value="A" <%=UtilMisc.htmlEscape(props.getProperty("pe_other", "")).equals("A") ? "checked=checked" : ""%> />
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                       Abdomen
                                    </td>

                                    <td>
                                        N <input type="radio" name="pe_abdomen" value="N" <%=UtilMisc.htmlEscape(props.getProperty("pe_abdomen", "")).equals("N") ? "checked=checked" : ""%> />
                                    </td>

                                    <td>
                                        Abn <input type="radio" name="pe_abdomen" value="A" <%=UtilMisc.htmlEscape(props.getProperty("pe_abdomen", "")).equals("A") ? "checked=checked" : ""%> />
                                    </td>

                                    <td colspan="3"></td>
                                </tr>

                                <!-- Physical Exam - Exam Comments -->
                                <tr class="subsection">
                                    <th colspan="6">Exam Comments</th>
                                </tr>

                                <tr>
                                    <td colspan="6">
                                        <textarea name="pe_exam_comments" style="width: 100%" rows="4" maxlength="255"><%= UtilMisc.htmlEscape(props.getProperty("pe_exam_comments", ""))%></textarea>
                                    </td>
                                </tr>
                                
                                </tbody>
                            </table>
                            
                            <div style="vertical-align: inherit;">
                                <div style="width: 49%;display: inline-block;border-right: 1px solid;">
                                    <label style="vertical-align: inherit;">
                                        Last Pap<br/>
                                        <input type="text" name="lab_lastPapDate" id="lab_lastPapDate" size="10" maxlength="10" value="<%= UtilMisc.htmlEscape(props.getProperty("lab_lastPapDate", "")) %>" />
                                        <img src="../images/cal.gif" id="lab_lastPapDate_cal" />
                                    </label>
                                </div>
                                <div style="width: 50%;display: inline-block;">
                                    <label>
                                        Result<br/>
                                        <input type="text" name="lab_lastPap" size="20" maxlength="20" value="<%= UtilMisc.htmlEscape(props.getProperty("lab_lastPap", "")) %>" />
                                    </label>
                                </div>
                                
                                <div class="subsection" style="width: 100%;">
                                    Additional investigations as indicated
                                </div>
                                <div style="width: 100%;">
                                    TSH, Diabetes screen, Hb Electrophoresis/HPLC, 
                                    Ferritin, B12, Infectious diseases (e.g. Hep C, Parvo 
                                    B19, Varicella, Toxo,CMV), Drug screen, repeat STI 
                                    screen.
                                </div>
                            </div>
                        </td>
                        
                        <td valign="top" width="66%">
                            <!-- Initial Laboratory Investigations / Second and Third Trimester Lab Investigations -->
                            <table id="PR2_labs"  width="100%" border="1" cellspacing="0" cellpadding="0">
                                <thead>
                                <th colspan="2" class="sectionHeader">
                                    Initial Laboratory Investigations
                                </th>

                                <th colspan="2" width="50%" class="sectionHeader">
                                    Second and Third Trimester Laboratory Investigations
                                </th>
                                </thead>
                                
                                <tbody class="text-small" >

                                <tr class="subsection">
                                    <th>Test</th>
                                    <th>Result</th>

                                    <th>Test</th>
                                    <th>Result</th>
                                </tr>

                                <tr>
                                    <td>Hb</td>
                                    <td>
                                        <input type="text" name="lab_Hb" size="10" maxlength="20" value="<%= UtilMisc.htmlEscape(props.getProperty("lab_Hb", "")) %>">
                                    </td>

                                    <td>Hb</td>
                                    <td>
                                        <input type="text" name="lab_Hb2" size="10" maxlength="20" value="<%= UtilMisc.htmlEscape(props.getProperty("lab_Hb2", "")) %>">
                                    </td>
                                </tr>

                                <tr>
                                    <td>
                                        ABO/Rh(D)
                                    </td>
                                    <td>
                                        <select name="lab_ABO">
                                            <option value="NDONE">Not Done</option>
                                            <option value="A">A</option>
                                            <option value="B">B</option>
                                            <option value="AB">AB</option>
                                            <option value="O">O</option>
                                            <option value="UNK">Unknown</option>
                                        </select>
                                        /
                                        <select name="lab_rh">
                                            <option value="NDONE">Not Done</option>
                                            <option value="POS">Positive</option>
                                            <option value="WPOS">Weak Positive</option>
                                            <option value="NEG">Negative</option>
                                            <option value="UNK">Unknown</option>
                                        </select>
                                    </td>

                                    <td>Platelets</td>
                                    <td>
                                        <input type="text" name="lab_platelets2" size="10" maxlength="20" value="<%= UtilMisc.htmlEscape(props.getProperty("lab_platelets2", "")) %>" />
                                    </td>
                                </tr>

                                <tr>
                                    <td>MCV</td>
                                    <td>
                                        <input type="text" name="lab_MCV" size="10" maxlength="20" value="<%= UtilMisc.htmlEscape(props.getProperty("lab_MCV", "")) %>">
                                    </td>

                                    <td>
                                        ABO/Rh(D)
                                    </td>
                                    <td>
                                        <select name="lab_ABO2">
                                            <option value="NDONE">Not Done</option>
                                            <option value="A">A</option>
                                            <option value="B">B</option>
                                            <option value="AB">AB</option>
                                            <option value="O">O</option>
                                            <option value="UNK">Unknown</option>
                                        </select>
                                        /
                                        <select name="lab_rh2">
                                            <option value="NDONE">Not Done</option>
                                            <option value="POS">Positive</option>
                                            <option value="WPOS">Weak Positive</option>
                                            <option value="NEG">Negative</option>
                                            <option value="UNK">Unknown</option>
                                        </select>
                                    </td>
                                </tr>

                                <tr>
                                    <td>Antibody Screen</td>
                                    <td>
                                        <input type="text" name="lab_antiscr" size="10" maxlength="20" value="<%= UtilMisc.htmlEscape(props.getProperty("lab_antiscr", "")) %>" />
                                    </td>

                                    <td>Repeat Antibodies</td>
                                    <td>
                                        <input type="text" name="lab_antiscr2" size="10" maxlength="20" value="<%= UtilMisc.htmlEscape(props.getProperty("lab_antiscr2", "")) %>" />
                                    </td>
                                </tr>

                                <tr>
                                    <td>Platelets</td>
                                    <td>
                                        <input type="text" name="lab_platelets" size="10" maxlength="20" value="<%= UtilMisc.htmlEscape(props.getProperty("lab_platelets", "")) %>" />
                                    </td>

                                    <td>1hr GCT</td>
                                    <td>
                                        <input type="text" name="lab_GCT" size="10" maxlength="20" value="<%= UtilMisc.htmlEscape(props.getProperty("lab_GCT", "")) %>" />
                                    </td>
                                </tr>

                                <tr>
                                    <td>Rubella immune</td>
                                    <td>
                                        <select name="lab_rubella">
                                            <option value="NDONE">Not Done</option>
                                            <option value="Non-Immune">Non-Immune</option>
                                            <option value="Immune">Immune</option>
                                            <option value="Indeterminate">Indeterminate</option>
                                        </select>
                                    </td>

                                    <td>2hr GTT</td>
                                    <td>
                                        <input type="hidden" id="lab_gtt" name="lab_gtt" value="<%= UtilMisc.htmlEscape(props.getProperty("lab_gtt", "")) %>" />
                                        <input id="lab_gtt1" style="width:50px" type="text" size="4" maxlength="4" /> /
                                        <input id="lab_gtt2" style="width:50px" type="text" size="4" maxlength="4" /> /
                                        <input id="lab_gtt3" style="width:50px" type="text" size="4" maxlength="4" />
                                    </td>
                                </tr>

                                <tr>
                                    <td>HBsAg</td>
                                    <td>
                                        <select name="lab_Hbsag">
                                            <option value="NDONE">Not Done</option>
                                            <option value="POS">Positive</option>
                                            <option value="NEG">Negative</option>
                                            <option value="UNK">Unknown</option>
                                        </select>
                                    </td>

                                    <td>
                                        <input type="text" name="lab_custom1" size="10" maxlength="20" value="<%= UtilMisc.htmlEscape(props.getProperty("lab_custom1", "")) %>" />
                                    </td>
                                    <td>
                                        <input type="text" name="lab_custom1_value" size="10" maxlength="20" value="<%= UtilMisc.htmlEscape(props.getProperty("lab_custom1_value", "")) %>" />
                                    </td>
                                </tr>

                                <tr>
                                    <td>Syphilis</td>
                                    <td>
                                        <select name="lab_syphilis">
                                            <option value="NDONE">Not Done</option>
                                            <option value="POS">Positive</option>
                                            <option value="NEG">Negative</option>
                                            <option value="UNK">Unknown</option>
                                        </select>
                                    </td>

                                    <td>
                                        <input type="text" name="lab_custom2" size="10" maxlength="20" value="<%= UtilMisc.htmlEscape(props.getProperty("lab_custom2", "")) %>" />
                                    </td>
                                    <td>
                                        <input type="text" name="lab_custom2_value" size="10" maxlength="20" value="<%= UtilMisc.htmlEscape(props.getProperty("lab_custom2_value", "")) %>" />
                                    </td>
                                </tr>

                                <tr>
                                    <td>HIV</td>
                                    <td>
                                        <select name="lab_hiv">
                                            <option value="NDONE">Not Done</option>
                                            <option value="POS">Positive</option>
                                            <option value="NEG">Negative</option>
                                            <option value="IND">Indeterminate</option>
                                            <option value="UNK">Unknown</option>
                                        </select>
                                    </td>

                                    <td>
                                        <input type="text" name="lab_custom3" size="10" maxlength="20" value="<%= UtilMisc.htmlEscape(props.getProperty("lab_custom3", "")) %>" />
                                    </td>
                                    <td>
                                        <input type="text" name="lab_custom3_value" size="10" maxlength="20" value="<%= UtilMisc.htmlEscape(props.getProperty("lab_custom3_value", "")) %>" />
                                    </td>
                                </tr>

                                <tr>
                                    <td>GC</td>
                                    <td>
                                        <select name="lab_gc">
                                            <option value="NDONE">Not Done</option>
                                            <option value="POS">Positive</option>
                                            <option value="NEG">Negative</option>
                                            <option value="UNK">Unknown</option>
                                        </select>
                                    </td>

                                    <td>
                                        <input type="text" name="lab_custom4" size="10" maxlength="20" value="<%= UtilMisc.htmlEscape(props.getProperty("lab_custom4", "")) %>" />
                                    </td>
                                    <td>
                                        <input type="text" name="lab_custom4_value" size="10" maxlength="20" value="<%= UtilMisc.htmlEscape(props.getProperty("lab_custom4_value", "")) %>" />
                                    </td>
                                </tr>

                                <tr>
                                    <td>Chlamydia</td>
                                    <td>
                                        <select name="lab_chlamydia">
                                            <option value="NDONE">Not Done</option>
                                            <option value="POS">Positive</option>
                                            <option value="NEG">Negative</option>
                                            <option value="UNK">Unknown</option>
                                        </select>
                                    </td>

                                    <td>
                                        <input type="text" name="lab_custom5" size="10" maxlength="20" value="<%= UtilMisc.htmlEscape(props.getProperty("lab_custom5", "")) %>" />
                                    </td>
                                    <td>
                                        <input type="text" name="lab_custom5_value" size="10" maxlength="20" value="<%= UtilMisc.htmlEscape(props.getProperty("lab_custom5_value", "")) %>" />
                                    </td>

                                </tr>

                                <tr>
                                    <td>Urine C&S</td>
                                    <td>
                                        <input type="text" name="lab_urine" size="10" maxlength="20" value="<%= UtilMisc.htmlEscape(props.getProperty("lab_urine", "")) %>" />
                                    </td>

                                    <td>
                                        <input type="text" name="lab_custom6" size="10" maxlength="20" value="<%= UtilMisc.htmlEscape(props.getProperty("lab_custom6", "")) %>" />
                                    </td>
                                    <td>
                                        <input type="text" name="lab_custom6_value" size="10" maxlength="20" value="<%= UtilMisc.htmlEscape(props.getProperty("lab_custom6_value", "")) %>" />
                                    </td>
                                </tr>

                                <tr class="subsection">
                                    <th>Test</th>
                                    <th>Result</th>

                                    <th>Test</th>
                                    <th>Result</th>
                                </tr>

                                <tr>
                                    <td>
                                        TSH
                                    </td>
                                    <td>
                                        <input type="text" name="lab_tsh" size="10" maxlength="20" value="<%= UtilMisc.htmlEscape(props.getProperty("lab_tsh", "")) %>" />
                                    </td>

                                    <td>
                                        <input type="text" name="lab_custom7" size="10" maxlength="20" value="<%= UtilMisc.htmlEscape(props.getProperty("lab_custom7", "")) %>" />
                                    </td>
                                    <td>
                                        <input type="text" name="lab_custom7_value" size="10" maxlength="20" value="<%= UtilMisc.htmlEscape(props.getProperty("lab_custom7_value", "")) %>" />
                                    </td>
                                </tr>

                                <tr>
                                    <td>
                                        Diabetes screen 50g
                                    </td>
                                    <td>
                                        <input type="text" name="lab_diabetes50" size="10" maxlength="20" value="<%= UtilMisc.htmlEscape(props.getProperty("lab_diabetes50", "")) %>" />
                                    </td>

                                    <td>
                                        <input type="text" name="lab_custom8" size="10" maxlength="20" value="<%= UtilMisc.htmlEscape(props.getProperty("lab_custom8", "")) %>" />
                                    </td>
                                    <td>
                                        <input type="text" name="lab_custom8_value" size="10" maxlength="20" value="<%= UtilMisc.htmlEscape(props.getProperty("lab_custom8_value", "")) %>" />
                                    </td>
                                </tr>

                                <tr>
                                    <td>
                                        Diabetes screen 75g
                                    </td>
                                    <td>
                                        FPG <input type="text" name="lab_diabetes75_fpg" size="3" maxlength="20" value="<%= UtilMisc.htmlEscape(props.getProperty("lab_diabetes75_fpg", "")) %>" />
                                        1hPG <input type="text" name="lab_diabetes75_1hpg" size="3" maxlength="20" value="<%= UtilMisc.htmlEscape(props.getProperty("lab_diabetes75_1hpg", "")) %>" />
                                        2hPG <input type="text" name="lab_diabetes75_2hpg" size="3" maxlength="20" value="<%= UtilMisc.htmlEscape(props.getProperty("lab_diabetes75_2hpg", "")) %>" />
                                    </td>

                                    <td>
                                        <input type="text" name="lab_custom9" size="10" maxlength="20" value="<%= UtilMisc.htmlEscape(props.getProperty("lab_custom9", "")) %>" />
                                    </td>
                                    <td>
                                        <input type="text" name="lab_custom9_value" size="10" maxlength="20" value="<%= UtilMisc.htmlEscape(props.getProperty("lab_custom9_value", "")) %>" />
                                    </td>
                                </tr>

                                <tr>
                                    <td>
                                        Hb Electrophoresis/HPLC
                                    </td>
                                    <td>
                                        <input type="text" name="lab_Hb_elec" size="10" maxlength="20" value="<%= UtilMisc.htmlEscape(props.getProperty("lab_Hb_elec", "")) %>" />
                                    </td>

                                    <td>
                                        <input type="text" name="lab_custom10" size="10" maxlength="20" value="<%= UtilMisc.htmlEscape(props.getProperty("lab_custom10", "")) %>" />
                                    </td>
                                    <td>
                                        <input type="text" name="lab_custom10_value" size="10" maxlength="20" value="<%= UtilMisc.htmlEscape(props.getProperty("lab_custom10_value", "")) %>" />
                                    </td>
                                </tr>
                                </tbody>

                            </table>
                        </td>
                        
                    </tr>
                            
                </table>

                <!-- Prenatal Genetic Investigations -->
                <table width="100%" border="1" cellspacing="0" cellpadding="0">
                    <thead>
                    <tr class="sectionHeader" >
                        <th colspan="4">Prenatal Genetic Investigations</th>
                    </tr>
                    </thead>
                    
                    <tbody class="text-small">
                    <tr>
                        <td width="40%" style="font-weight: bold">
                            Screening Offered &nbsp; &nbsp;
                            <input type="radio" name="pgi_screening" value="Y" <%=UtilMisc.htmlEscape(props.getProperty("pgi_screening", "")).equals("Y") ? "checked=checked" : ""%> /> Yes &nbsp; &nbsp;
                            <input type="radio" name="pgi_screening" value="N" <%=UtilMisc.htmlEscape(props.getProperty("pgi_screening", "")).equals("N") ? "checked=checked" : ""%> /> No
                        </td>

                        <td class="subsection">
                            Result
                        </td>

                        <td width="40%"></td>

                        <td class="subsection">
                            Result
                        </td>
                    </tr>

                    <tr>
                        <td>
                            &nbsp; &nbsp;
                            <input type="checkbox" name="pgi_fts" <%=UtilMisc.htmlEscape(props.getProperty("pgi_fts", ""))%> /> FTS (between 11-13+6wks)
                        </td>

                        <td>
                            <input type="text" name="pgi_fts_result" maxlength="20" value="<%=UtilMisc.htmlEscape(props.getProperty("pgi_fts_result", ""))%>">
                        </td>

                        <td>
                            &nbsp; &nbsp;
                            CVS/Amino
                            <span style="float: right;">
                                Offered &nbsp; &nbsp;
                                <input type="radio" name="pgi_cvs" value="Y" <%=UtilMisc.htmlEscape(props.getProperty("pgi_cvs", "")).equals("Y") ? "checked=checked" : ""%> /> Y &nbsp; &nbsp;
                                <input type="radio" name="pgi_cvs" value="N" <%=UtilMisc.htmlEscape(props.getProperty("pgi_cvs", "")).equals("N") ? "checked=checked" : ""%> /> N &nbsp; &nbsp;
                            </span>
                        </td>

                        <td>
                            <input type="text" name="pgi_cvs_result" maxlength="20" value="<%=UtilMisc.htmlEscape(props.getProperty("pgi_cvs_result", ""))%>">
                        </td>
                    </tr>

                    <tr>
                        <td>
                            &nbsp; &nbsp;
                            <input type="checkbox" name="pgi_ips1" <%=UtilMisc.htmlEscape(props.getProperty("pgi_ips1", ""))%> /> IPS Part 1 (between 11-13+6wks)

                            &nbsp; &nbsp;
                            <input type="checkbox" name="pgi_ips2" <%=UtilMisc.htmlEscape(props.getProperty("pgi_ips2", ""))%> /> IPS Part 2 (between 15-20+6wks)
                        </td>

                        <td>
                            <input type="text" name="pgi_ips_result" maxlength="20" value="<%=UtilMisc.htmlEscape(props.getProperty("pgi_ips_result", ""))%>">
                        </td>

                        <td>
                            &nbsp; &nbsp;
                            Other genetic testing
                            <span style="float: right;">
                                Offered &nbsp; &nbsp;
                                <input type="radio" name="pgi_other" value="Y" <%=UtilMisc.htmlEscape(props.getProperty("pgi_other", "")).equals("Y") ? "checked=checked" : ""%> /> Y &nbsp; &nbsp;
                                <input type="radio" name="pgi_other" value="N" <%=UtilMisc.htmlEscape(props.getProperty("pgi_other", "")).equals("N") ? "checked=checked" : ""%> /> N &nbsp; &nbsp;
                            </span>
                        </td>

                        <td>
                            <input type="text" name="pgi_other_result" maxlength="20" value="<%=UtilMisc.htmlEscape(props.getProperty("pgi_other_result", ""))%>">
                        </td>
                    </tr>

                    <tr>
                        <td>
                            &nbsp; &nbsp;
                            <input type="checkbox" name="pgi_mss" <%=UtilMisc.htmlEscape(props.getProperty("pgi_mss", ""))%> /> MSS (between 11-13+6wks)

                            &nbsp; &nbsp;
                            <input type="checkbox" name="pgi_afp" <%=UtilMisc.htmlEscape(props.getProperty("pgi_afp", ""))%> /> AFP (between 15-20+6wks)
                        </td>

                        <td>
                            <input type="text" name="pgi_mss_afp_result" maxlength="20" value="<%=UtilMisc.htmlEscape(props.getProperty("pgi_mss_afp_result", ""))%>">
                        </td>

                        <td>
                            &nbsp; &nbsp;
                            NT Risk Assessment between 11-13+6wk (multiples)
                        </td>

                        <td>
                            <input type="text" name="pgi_ntra_result" maxlength="20" value="<%=UtilMisc.htmlEscape(props.getProperty("pgi_ntra_result", ""))%>">
                        </td>
                    </tr>

                    <tr>
                        <td>
                            &nbsp; &nbsp;
                            Cell-free fetal DNA (NIPT)
                            <span style="float: right;">
                                Offered &nbsp; &nbsp;
                                <input type="radio" name="pgi_nipt" value="Y" <%=UtilMisc.htmlEscape(props.getProperty("pgi_nipt", "")).equals("Y") ? "checked=checked" : ""%> /> Y &nbsp; &nbsp;
                                <input type="radio" name="pgi_nipt" value="N" <%=UtilMisc.htmlEscape(props.getProperty("pgi_nipt", "")).equals("N") ? "checked=checked" : ""%> /> N &nbsp; &nbsp;
                            </span>
                        </td>

                        <td>
                            <input type="text" name="pgi_nipt_result" maxlength="20" value="<%=UtilMisc.htmlEscape(props.getProperty("pgi_nipt_result", ""))%>">
                        </td>

                        <td>
                            &nbsp; &nbsp;
                            Abnormal Placenta Biomarkers
                        </td>

                        <td>
                            <input type="text" name="pgi_apb_result" maxlength="20" value="<%=UtilMisc.htmlEscape(props.getProperty("pgi_apb_result", ""))%>">
                        </td>
                    </tr>

                    <tr class="subsection">
                        <th colspan="4">No Screening Tests</th>
                    </tr>
                    
                    <tr>
                        <td>
                            &nbsp;
                            <input type="checkbox" name="pgi_declined" <%=UtilMisc.htmlEscape(props.getProperty("pgi_declined", ""))%> /> Counseled and declined
                        </td>

                        <td>
                            <input type="text" name="pgi_declinedDate" id="pgi_declinedDate" size="10" maxlength="10" value="<%= UtilMisc.htmlEscape(props.getProperty("pgi_declinedDate", "")) %>" />
                            <img src="../images/cal.gif" id="pgi_declinedDate_cal" />
                        </td>

                        <td>
                            &nbsp;
                            <input type="checkbox" name="pgi_presentation" <%=UtilMisc.htmlEscape(props.getProperty("pgi_presentation", ""))%> /> Presentation > 20+6wk
                            &nbsp;&nbsp;&nbsp;
                            NIPT Offered &nbsp;&nbsp;
                            <input type="radio" name="pgi_nipt_off" value="Y" <%=UtilMisc.htmlEscape(props.getProperty("pgi_nipt_off", "")).equals("Y") ? "checked=checked" : ""%> /> Y &nbsp; &nbsp;
                            <input type="radio" name="pgi_nipt_off" value="N" <%=UtilMisc.htmlEscape(props.getProperty("pgi_nipt_off", "")).equals("N") ? "checked=checked" : ""%> /> N
                        </td>

                        <td>
                            <input type="text" name="pgi_niptDate" id="pgi_niptDate" size="10" maxlength="10" value="<%= UtilMisc.htmlEscape(props.getProperty("pgi_niptDate", "")) %>" />
                            <img src="../images/cal.gif" id="pgi_niptDate_cal" />
                        </td>
                    </tr>
                    </tbody>
                </table>

                <!-- Ultrasound -->
                <table id="ultrasound" width="100%" border="1" cellspacing="0" cellpadding="0">
                    <input type="hidden" id="us_num" name="us_num" value="<%=usNum%>"/>
                    <thead>
                    <tr>
                        <th class="sectionHeader" colspan="3">
                            Ultrasound
                        </th>
                    </tr>
                    </thead>
                    
                    <tbody id="us_results">
                    <tr class="subsection">
                        <th>
                            Date
                        </th>

                        <th>
                            GA
                        </th>

                        <th width="80%">
                            Result
                        </th>
                    </tr>
                    </tbody>

                    <tr>
                        <td colspan="2" style="border-right: transparent">
                            <input id="us_add" type="button" value="Add New" onclick="addUltrasound();" />
                            <input id="us_remove" type="button" value="Remove Last Row" onclick="removeLastUltrasound();" />
                        </td>
                        <td style="border: 2px solid;float: right;">
                            Genetic screening result reviewed with pt/client &nbsp; <input type="checkbox" name="us_screenReview" <%=UtilMisc.htmlEscape(props.getProperty("us_screenReview", ""))%> /> <br/>
                            Approx 22 wks: Copy of OPR 1 & 2 to hospital &nbsp; <input type="checkbox" name="us_hospitalCopy" <%=UtilMisc.htmlEscape(props.getProperty("us_hospitalCopy", ""))%> /> &nbsp;&nbsp;
                            and/or to pt/client &nbsp; <input type="checkbox" name="us_clientCopy" <%=UtilMisc.htmlEscape(props.getProperty("us_clientCopy", ""))%> /> &nbsp;
                        </td>
                    </tr>
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

    <div id="pull-vitals-form" title="Vitals Tool">
        <p class="validateTips"></p>

        <form>
            <fieldset>
                <table>
                    <thead>
                    <tr>
                        <th></th>
                        <th>AR Form</th>
                        <th></th>
                        <th>E-Chart</th>
                        <th></th>
                    </tr>
                    </thead>
                    <tbody>
                    <tr>
                        <td style="text-align:left">Height</td>
                        <td><input readonly="readonly" type="text" size="5" id="height_form" name="height_form" class="text ui-widget-content ui-corner-all"/></td>
                        <td>
                            <a id="moveToForm_height" href="javascript:void(0)" title="Copy from Chart to Form"><img src="../images/icons/132.png"/></a>
                            &nbsp;
                            <a id="moveToChart_height" href="javascript:void(0)" onClick="moveToChart('height','HT');" title="Copy from Form to Chart"><img src="../images/icons/131.png"/></a>
                        </td>
                        <td><input readonly="readonly" type="text" size="5" id="height_chart" name="height_chart" class="text ui-widget-content ui-corner-all"/></td>
                        <td><a href="javascript:void(0);" onClick="popupPage(300,800,'<%=request.getContextPath()%>/oscarEncounter/GraphMeasurements.do?demographic_no=<%=demoNo%>&type=HT');return false;"><img border="0" src="<%=request.getContextPath()%>/oscarEncounter/oscarMeasurements/img/chart.gif"/></a></td>
                    </tr>
                    <tr>
                        <td style="text-align:left">Weight</td>
                        <td><input readonly="readonly" type="text" size="5" id="weight_form" name="weight_form" class="text ui-widget-content ui-corner-all"/></td>
                        <td>
                            <a id="moveToForm_weight" href="javascript:void(0)" title="Copy from Chart to Form"><img src="../images/icons/132.png"/></a>
                            &nbsp;
                            <a id="moveToChart_weight" href="javascript:void(0)" onClick="moveToChart('weight','WT');" title="Copy from Form to Chart"><img src="../images/icons/131.png"/></a>
                        </td>
                        <td><input readonly="readonly" type="text" size="5" id="weight_chart" name="weight_chart" class="text ui-widget-content ui-corner-all"/></td>
                        <td><a href="javascript:void(0);" onClick="popupPage(300,800,'<%=request.getContextPath()%>/oscarEncounter/GraphMeasurements.do?demographic_no=<%=demoNo%>&type=WT');return false;"><img border="0" src="<%=request.getContextPath()%>/oscarEncounter/oscarMeasurements/img/chart.gif"/></a></td>
                    </tr>
                    <tr>
                        <td style="text-align:left">BP</td>
                        <td><input readonly="readonly" type="text" size="5" id="bp_form" name="bp_form" class="text ui-widget-content ui-corner-all"/></td>
                        <td>
                            <a id="moveToForm_bp" href="javascript:void(0)" title="Copy from Chart to Form"><img src="../images/icons/132.png"/></a>
                            &nbsp;
                            <a id="moveToChart_bp" href="javascript:void(0)" onClick="moveToChart('bp','BP');" title="Copy from Form to Chart"><img src="../images/icons/131.png"/></a>
                        </td>
                        <td><input readonly="readonly" type="text" size="5" id="bp_chart" name="bp_chart" class="text ui-widget-content ui-corner-all"/></td>
                        <td><a href="javascript:void(0);" onClick="popupPage(300,800,'<%=request.getContextPath()%>/oscarEncounter/GraphMeasurements.do?demographic_no=<%=demoNo%>&type=BP');return false;"><img border="0" src="<%=request.getContextPath()%>/oscarEncounter/oscarMeasurements/img/chart.gif"/></a></td>
                    </tr>
                    </tbody>
                </table>
            </fieldset>
        </form>
    </div>
</html:html>
