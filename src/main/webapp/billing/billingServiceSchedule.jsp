<%@ taglib uri="/WEB-INF/security.tld" prefix="security"%>
<%
    String roleName$ = (String)session.getAttribute("userrole") + "," + (String) session.getAttribute("user");
    boolean authed = true;
    LoggedInInfo loggedInInfo = LoggedInInfo.getLoggedInInfoFromSession(request);

    Boolean providerView = request.getAttribute("providerView") != null && Boolean.valueOf(request.getAttribute("providerView").toString());
    
    if (providerView) {
%>
<security:oscarSec roleName="<%=roleName$%>" objectName="_billing" rights="r" reverse="<%=true%>">
    <%authed=false; %>
    <%response.sendRedirect("../securityError.jsp?type=_admin&type=_billing");%>
</security:oscarSec>
<% } else { %>
<security:oscarSec roleName="<%=roleName$%>" objectName="_admin,_admin.misc" rights="r" reverse="<%=true%>">
    <%authed=false; %>
    <%response.sendRedirect("../securityError.jsp?type=_admin&type=_admin.misc");%>
</security:oscarSec>
<%
    }
    
    if(!authed) {
        return;
    }
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<%@ page import="java.util.*"%>
<%@ page import="oscar.util.StringUtils" %>
<%@ page import="org.oscarehr.util.LoggedInInfo" %>
<%@ page import="org.oscarehr.common.model.BillingServiceSchedule" %>
<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean"%>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html"%>
<%@ taglib uri="/WEB-INF/struts-logic.tld" prefix="logic"%>
<%
    List<BillingServiceSchedule> billingServiceSchedule = new ArrayList<BillingServiceSchedule>();
    if (request.getAttribute("schedule") != null) {
        billingServiceSchedule = (List<BillingServiceSchedule>) request.getAttribute("schedule");
    }
%>
<head>
    <title>Scheduled Premium Billing Services</title>

    <link href="<%=request.getContextPath() %>/css/bootstrap.css" rel="stylesheet" type="text/css">
    <link rel="stylesheet" type="text/css" href="../share/yui/css/fonts-min.css"/>
    <link rel="stylesheet" type="text/css" href="../share/yui/css/autocomplete.css"/>
    <link rel="stylesheet" type="text/css" media="all" href="<%=request.getContextPath()%>/js/jquery_css/smoothness/jquery-ui-1.10.2.custom.min.css"  />
    <link rel="stylesheet" href="../css/alertify.core.css" type="text/css">
    <link rel="stylesheet" href="../css/alertify.default.css" type="text/css">
    
    <script type="text/javascript" src="<%= request.getContextPath() %>/js/global.js"></script>
    <script type="text/javascript" src="<%= request.getContextPath() %>/js/jquery-1.9.1.js"></script>
    <script type="text/javascript" src="<%= request.getContextPath() %>/js/jquery-ui-1.10.2.custom.min.js"></script>

    <script type="text/javascript" src="<%= request.getContextPath() %>/share/javascript/Oscar.js"></script>
    <script type="text/javascript" src="<%=request.getContextPath()%>/js/alertify.js"></script>
    <script type="text/javascript" src="<%=request.getContextPath()%>/js/billingServiceAutocomplete.js"></script>
    <script type="text/javascript" src="<%= request.getContextPath() %>/billing/billingServiceSchedule.js"></script>
</head>

<body class="BodyStyle">

<h3>Scheduled Premium Billing Services <%=providerView ? "" : "(Clinic Wide)"%></h3>

<div class="container-fluid">
    <div class="row">
        <div class="col-sm-12">
            Setup service codes that will automatically populate into an invoices when billing from the schedule after a designated time for the clinic. <br/>
        </div>

        <div class="col-sm-12">
            <table class="table table-bordered table-striped table-hover table-condensed">
            <thead style="background-color: #eeeeee">
            <tr>
                <th>Code</th>
                <th style="width: 750px;">Description</th>
                <th style="width: 100px;">For Appointments After</th>
                <th colspan="2" style="width: 20px">&nbsp;</th>
            </tr>
            </thead>
            
            <tbody id="services">
            <% 
                for (BillingServiceSchedule serviceSchedule : billingServiceSchedule) {
                    Integer id = serviceSchedule.getId();
                    String serviceCode = StringUtils.noNull(serviceSchedule.getServiceCode());
                    String description = StringUtils.noNull(serviceSchedule.getServiceDescription());
            %>
            
            <tr id="<%=id%>">
                <td><span id="service_code_<%=id%>"><%=serviceCode%></span></td>
                <td><%=description%></td>
                <td><input id="billing_time_<%=id%>" type="time" name="billing_time_<%=id%>" value="<%=serviceSchedule.getBillingTime()%>"/></td>
                <td><input class="btn btn-small btn-primary" type="submit" value="Update" onclick="return save('<%=id%>');"></td>
                <td><input class="btn btn-small btn-danger" type="submit" value="Delete" onclick="return remove('<%=id%>');"></td>
            </tr>
            <% } %>
            </tbody>
            <tbody>
                <tr>
                    <td>
                        <input id="searchService" class="typeahead" style="margin-bottom: 0;" type="text" name="service_code_search" placeholder="Search service codes" maxlength="20" onchange="checkSave()"/>
                        <div id="autocomplete_choices" class="autocomplete"></div>
                    </td>
                    <td><span id="searchServiceDescription"></span></td>
                    <td><input type="time" id="billingTime" name="billing_time" onchange="checkSave()" /></td>
                    <td style="text-align: right;" colspan="2"><input id="addBtn" class="btn btn-small btn-primary" type="submit" value="Add" disabled="disabled" onclick="return save();r"></td>
                    
                    <input id="providerView" type="hidden" name="providerView" maxlength="6" value="<%=providerView%>"/>
                   
                </tr>
            </tbody>

        </table>
        </div>
        
        <%
            if (providerView && request.getAttribute("scheduleClinic") != null) {
                List<BillingServiceSchedule> clinicServiceSchedule = (List<BillingServiceSchedule>) request.getAttribute("scheduleClinic");
        %>
        <div class="col-sm-12">
            <h4><a href="javascript:void(0)" onclick="$('#clinicSchedule').toggle();">Current Clinic Wide Values</a></h4>
            <table id="clinicSchedule" class="table table-bordered table-striped table-hover table-condensed" style="display: none">
            <thead style="background-color: #eeeeee">
            <tr>
                <th>Code</th>
                <th style="width: 750px;">Description</th>
                <th style="width: 100px;">For Appointments After</th>
            </tr>
            </thead>

            <tbody id="clinicServices">
            <%
                for (BillingServiceSchedule serviceSchedule : clinicServiceSchedule) {
                    String serviceCode = StringUtils.noNull(serviceSchedule.getServiceCode());
                    String description = StringUtils.noNull(serviceSchedule.getServiceDescription());
            %>

            <tr>
                <td><%=serviceCode%></td>
                <td><%=description%></td>
                <td><input type="time" value="<%=serviceSchedule.getBillingTime()%>" disabled="disabled" style="background:none;border:none;cursor:default;box-shadow:none;"/></td>
            </tr>
            <% } %>
            </tbody>

        </table>
        </div>
            
        <%}%>
    </div>
</div>

<script type="text/javascript">
    jQuery(setupBillingServiceAutocomplete());
</script>
</body>
</html>
