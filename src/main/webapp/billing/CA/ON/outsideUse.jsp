
<%@ taglib uri="/WEB-INF/security.tld" prefix="security"%>
<%
    String roleName$ = (String)session.getAttribute("userrole") + "," + (String) session.getAttribute("user");
    boolean authed=true;
%>
<security:oscarSec roleName="<%=roleName$%>" objectName="_demographic" rights="r" reverse="<%=true%>">
    <%authed=false; %>
    <%response.sendRedirect(request.getContextPath() + "/securityError.jsp?type=_demographic");%>
</security:oscarSec>
<%
    if(!authed) {
        return;
    }
%>

<%@page import="org.springframework.web.context.support.WebApplicationContextUtils"%>

<%@ page import="java.util.*" errorPage="errorpage.jsp"%>

<%@page import="org.apache.commons.lang.StringUtils"%>
<%@page import="org.oscarehr.util.SpringUtils" %>

<%@page import="org.oscarehr.common.dao.SiteDao"%>
<%@page import="org.oscarehr.common.model.Site"%>

<%@page import="org.oscarehr.common.dao.OscarAppointmentDao" %>
<%@page import="org.oscarehr.common.dao.AppointmentStatusDao" %>

<%@ page import="org.oscarehr.common.model.ProviderData"%>
<%@ page import="org.oscarehr.common.dao.ProviderDataDao"%>

<%@ page import="org.oscarehr.common.dao.LookupListItemDao" %>
<%@ page import="org.oscarehr.common.dao.DemographicDao" %>
<%@ page import="org.oscarehr.common.model.Demographic" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="org.oscarehr.common.IsPropertiesOn" %>
<%@ page import="org.oscarehr.managers.AppointmentManager" %>
<%@ page import="org.oscarehr.common.model.BillingONOUReport" %>
<%@ page import="org.oscarehr.common.dao.BillingONOUReportDao" %>
<%@ page import="org.oscarehr.util.LoggedInInfo" %>
<%@ page import="java.text.SimpleDateFormat" %>


<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean" %>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html" %>
<%@ taglib uri="http://www.caisi.ca/plugin-tag" prefix="plugin" %>
<%@ taglib uri="/WEB-INF/caisi-tag.tld" prefix="caisi" %>
<%@ taglib uri="/WEB-INF/special_tag.tld" prefix="special" %>
<%@ taglib uri="/WEB-INF/struts-logic.tld" prefix="logic" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="/WEB-INF/oscar-tag.tld" prefix="oscar"%>


<%!
    private List<Site> sites = new ArrayList<Site>();
    private HashMap<String,String[]> siteBgColor = new HashMap<String,String[]>();
%>

<%
    SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
    LoggedInInfo loggedInInfo=LoggedInInfo.getLoggedInInfoFromSession(request);
    BillingONOUReportDao billingONOUReportDao = SpringUtils.getBean(BillingONOUReportDao.class);
    DemographicDao demographicDao = SpringUtils.getBean(DemographicDao.class);
    OscarAppointmentDao appointmentDao = (OscarAppointmentDao)SpringUtils.getBean("oscarAppointmentDao");
    AppointmentManager appointmentManager = SpringUtils.getBean(AppointmentManager.class);
    
    ProviderDataDao providerDao = SpringUtils.getBean(ProviderDataDao.class);
    AppointmentStatusDao appointmentStatusDao = SpringUtils.getBean(AppointmentStatusDao.class);
    LookupListItemDao lookupListItemDao = SpringUtils.getBean(LookupListItemDao.class);
    
    if (IsPropertiesOn.isMultisitesEnable()) {
        SiteDao siteDao = (SiteDao)WebApplicationContextUtils.getWebApplicationContext(application).getBean("siteDao");
        sites = siteDao.getAllActiveSites();
        //get all sites bgColors
        for (Site st : sites) {
            siteBgColor.put(st.getName(), new String[]{st.getBgColor(), st.getShortName()});
        }
    }

    String loggedInProviderNo = (String) session.getAttribute("user");
    String demographicNo = request.getParameter("demographic_no");
    String demoFirstName = "";
    String demoLastName = "";
    String hin = "";
    Demographic demographic = demographicDao.getDemographic(demographicNo);
    if (demographic != null) {
        demoFirstName = demographic.getFirstName();
        demoLastName = demographic.getLastName();
        hin = StringUtils.trimToEmpty(demographic.getHin());
    }
    
    
    String strLimit1="0";
    String strLimit2="50";
    if(request.getParameter("limit1")!=null) strLimit1 = request.getParameter("limit1");
    if(request.getParameter("limit2")!=null) strLimit2 = request.getParameter("limit2");
    
    String deepColor = "#CCCCFF" , weakColor = "#EEEEFF";
    String orderby="";
    if(request.getParameter("orderby")!=null) orderby=request.getParameter("orderby");

    Map<String,ProviderData> providerMap = new HashMap<String,ProviderData>();

%>


<html:html locale="true">

    <head>
        <c:set var="ctx" value="${pageContext.request.contextPath}" scope="request"/>
        <script type="text/javascript" src="<%= request.getContextPath() %>/js/global.js"></script>
        <script type="text/javascript" src="<%=request.getContextPath() %>/js/jquery-1.9.1.min.js"></script>
        <script src="<%=request.getContextPath()%>/library/bootstrap/3.0.0/js/bootstrap.min.js"></script>

        <script src="<%=request.getContextPath()%>/library/typeahead.js/typeahead.min.js"></script>
        <script src="<%=request.getContextPath()%>/library/typeahead.js/typeahead-0.11.1.js"></script>

        
        <!--I18n-->
        <link rel="stylesheet" href="<%=request.getContextPath() %>/library/bootstrap/3.0.0/css/bootstrap.min.css" />
        <link rel="stylesheet" type="text/css" href="<%=request.getContextPath()%>/share/css/OscarStandardLayout.css" />
        <link rel="stylesheet" type="text/css" href="<%=request.getContextPath()%>/css/main-kai.min.css" />
        <link rel="stylesheet" href="<%=request.getContextPath() %>/css/font-awesome.min.css" />
        <link rel="stylesheet" type="text/css" href="<%=request.getContextPath() %>/demographic/manageContacts.css" />
        <link rel="stylesheet" type="text/css" media="all" href="<%=request.getContextPath()%>/share/css/extractedFromPages.css" />
        <script type="text/javascript">
            jQuery.noConflict();
            var ctx = '<%=request.getContextPath()%>';
            function popupPageNew(vheight,vwidth,varpage) {
                var page = "" + varpage;
                windowprops = "height="+vheight+",width="+vwidth+",location=no,scrollbars=yes,menubars=no,toolbars=no,resizable=yes";
                var popup=window.open(page, "demographicprofile", windowprops);
                if (popup != null) {
                    if (popup.opener == null) {
                        popup.opener = self;
                    }
                }
            }

            function printVisit() {
                printVisit('');
            }

            function printVisit(cpp) {
                var sels = document.getElementsByName('sel');
                var ids = "";
                for(var x=0;x<sels.length;x++) {
                    if(sels[x].checked) {
                        if(ids.length>0)
                            ids+= ",";
                        ids += sels[x].value;
                    }
                }
                location.href=ctx+"/eyeform/Eyeform.do?method=print&apptNos="+ids+"&cpp="+cpp;
            }

            function selectAllCheckboxes() {
                jQuery("input[name='sel']").each(function(){
                    jQuery(this).attr('checked',true);
                });
            }

            function deselectAllCheckboxes() {
                jQuery("input[name='sel']").each(function(){
                    jQuery(this).attr('checked',false);
                });
            }
            
            function filterByProvider(s) {
                var providerNo = s.options[s.selectedIndex].value;
                jQuery("#apptHistoryTbl tbody tr").not(":first").each(function(){
                    if(!providerNo=='' && jQuery(this).attr('provider_no') != providerNo) {
                        jQuery(this).hide();
                    } else {
                        jQuery(this).show();
                    }
                });
            }
        </script>

        <title>Outside Use Report</title>
    </head>

    <body>
    
    <table class="MainTable" id="scrollNumber1" name="encounterTable">
        <tr class="MainTableTopRow">
            <td class="MainTableTopRowLeftColumn" style="font-size: medium">Outside Use Report</td>
            <td class="MainTableTopRowRightColumn">
                <table class="TopStatusBar">
                    <tr>
                        <td>
                            Results for Demographic: <%=demoLastName%>,<%=demoFirstName%>(<%=demographicNo%>)
                        </td>
                        <td>&nbsp;</td>
                        <td style="text-align: right">
                            <oscar:help keywords="appointment history" key="app.top1"/> | 
                            <a href="javascript:popupStart(300,400,'About.jsp')"><bean:message key="global.about" /></a> | 
                            <a href="javascript:popupStart(300,400,'License.jsp')"><bean:message key="global.license" /></a>
                        </td>
                    </tr>
                    <tr>
                        <td>HIN: <%=hin%></td>
                        <td>&nbsp;</td>
                        <td>&nbsp;</td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td class="MainTableLeftColumn" valign="top" style="font-size: small;">
                <ul class="nav nav-pills nav-stacked nav-list">
                   <%-- <li class="divider"><hr></li>--%>
                    <li>
                        <a href="<%=request.getContextPath()%>/demographic/demographiccontrol.jsp?demographic_no=<%=demographicNo%>&apptProvider=<%=loggedInProviderNo%>&displaymode=edit&dboperation=search_detail" onMouseOver="self.status=document.referrer;return true">Back</a>
                    </li>
                </ul>
                <br/>
            </td>
            <td class="MainTableRightColumn">
                <table class="table table-hover table-condensed" id="ouDemoTable">
                    <thead>
                        <th width="10%">Report Date</th>
                        <th width="15%">Report Period</th>
                        <th width="15%">Provider</th>
                        <th width="10%">Service Date</th>
                        <th width="10%">Code</th>
                        <th width="20%">Description</th>
                        <th width="10%">Amount</th>
                    </thead>
                    
                    <tbody>
                    <% 
                        List<BillingONOUReport> ouReports = billingONOUReportDao.findByHin(hin);
                        for (BillingONOUReport ouReport : ouReports) {
                            String reportDate = dateFormat.format(ouReport.getReportDate());
                            String periodStart = dateFormat.format(ouReport.getReportPeriodStart());
                            String periodEnd = dateFormat.format(ouReport.getReportPeriodEnd());
                            
                            String providerDisplay = ouReport.getProviderLast() + ", " + ouReport.getProviderFirst() + ouReport.getProviderMiddle();

                            String serviceDate = dateFormat.format(ouReport.getServiceDate());
                            String serviceAmount = ouReport.getServiceAmount().toString();
                    %>
                    <tr>
                        <td><%=reportDate%></td>
                        <td><%=periodStart%> to <%=periodEnd%></td>
                        <td><%=providerDisplay%></td>
                        <td><%=serviceDate%></td>
                        <td><%=ouReport.getServiceCode()%></td>
                        <td><%=ouReport.getServiceDescription()%></td>
                        <td>$ <%=serviceAmount%></td>
                    </tr>
                    <%
                            
                        }
                    %>
                    </tbody>
                </table>
                <br>
<%--                <%
                    int nPrevPage=0,nNextPage=0;
                    nNextPage=Integer.parseInt(strLimit2)+Integer.parseInt(strLimit1);
                    nPrevPage=Integer.parseInt(strLimit1)-Integer.parseInt(strLimit2);
                    if(nPrevPage>=0) {
                        String showRemoteStr;
                        if( nPrevPage == 0 ) {
                            showRemoteStr = "true";
                        }
                        else {
                            showRemoteStr = String.valueOf(showRemote);
                        }
                %>
                <a href="demographiccontrol.jsp?demographic_no=<%=demographicNo%>&last_name=<%=URLEncoder.encode(demoLastName,"UTF-8")%>&first_name=<%=URLEncoder.encode(demoFirstName,"UTF-8")%>&displaymode=<%=request.getParameter("displaymode")%>&dboperation=<%=request.getParameter("dboperation")%>&orderby=<%=request.getParameter("orderby")%>&limit1=<%=nPrevPage%>&limit2=<%=strLimit2%>&showRemote=<%=showRemoteStr%>">
                    <bean:message key="demographic.demographicappthistory.btnPrevPage" /></a>
                <%
                    }

                    if(nItems >=Integer.parseInt(strLimit2)) {
                %>
                <a href="demographiccontrol.jsp?demographic_no=<%=demographicNo%>&last_name=<%=URLEncoder.encode(demoLastName,"UTF-8")%>&first_name=<%=URLEncoder.encode(demoFirstName,"UTF-8")%>&displaymode=<%=request.getParameter("displaymode")%>&dboperation=<%=request.getParameter("dboperation")%>&orderby=<%=request.getParameter("orderby")%>&limit1=<%=nNextPage%>&limit2=<%=strLimit2%>&showRemote=<%=showRemote%>">
                    <bean:message key="demographic.demographicappthistory.btnNextPage" /></a>
                <%
                    }
                %>
                <p>--%>
            </td>
        </tr>
        <tr>
            <td class="MainTableBottomRowLeftColumn"></td>
            <td class="MainTableBottomRowRightColumn">
                <%--Filter results by provider:
                <select onChange="filterByProvider(this)">
                    <option value="">ALL</option>
                    <%
                        for(ProviderData prov:providerMap.values()) {
                    %>
                    <option value="<%=prov.getId()%>"><%=prov.getLastName() + ", " + prov.getFirstName() %></option>
                    <%
                        }
                    %>--%>
                </select>
            </td>
        </tr>
    </table>
    </body>
</html:html>
