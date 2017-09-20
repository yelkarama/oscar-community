<%@ taglib uri="/WEB-INF/security.tld" prefix="security"%>
<%
    String roleName$ = (String)session.getAttribute("userrole") + "," + (String) session.getAttribute("user");
    boolean authed=true;
%>
<security:oscarSec roleName="<%=roleName$%>" objectName="_admin,_admin.misc" rights="r" reverse="<%=true%>">
    <%authed=false; %>
    <%response.sendRedirect("../securityError.jsp?type=_admin&type=_admin.misc");%>
</security:oscarSec>
<%
    if(!authed) {
        return;
    }
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<%@ page import="oscar.OscarProperties,org.oscarehr.util.SpringUtils, org.oscarehr.common.dao.UserPropertyDAO"%>
<%

    OscarProperties props = OscarProperties.getInstance();

    UserPropertyDAO userPropertyDao = SpringUtils.getBean(UserPropertyDAO.class);

    boolean autoValidateOnBooking = (userPropertyDao.getProp("auto_validate_hc")!=null && "true".equals(userPropertyDao.getProp("auto_validate_hc").getValue()));

%>

<%@ page import="java.util.*,oscar.oscarReport.reportByTemplate.*"%>
<%@ page import="oscar.util.StringUtils" %>
<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean"%>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html"%>
<%@ taglib uri="/WEB-INF/struts-logic.tld" prefix="logic"%>

<head>
    <title>Health Card Validation Settings</title>

    <script type="text/javascript" src="<%=request.getContextPath() %>/js/jquery-1.9.1.min.js"></script>
    <script src="<%=request.getContextPath() %>/js/bootstrap.min.js"></script>
    <script type="text/javascript" src="<%=request.getContextPath() %>/js/bootstrap-datepicker.js"></script>

    <link href="<%=request.getContextPath() %>/css/bootstrap.min.css" rel="stylesheet">
    <link href="<%=request.getContextPath() %>/library/bootstrap/3.0.0/css/bootstrap.min.css" rel="stylesheet">
    <link href="<%=request.getContextPath() %>/css/datepicker.css" rel="stylesheet" type="text/css">
    <link rel="stylesheet" href="<%=request.getContextPath() %>/css/font-awesome.min.css">

</head>

<body>

<h3>Health Card Validation Settings</h3>


<div class="container-fluid">
    <form action="<%=request.getContextPath()%>/billing/HealthCardValidationPreferences.do" method="post">
        <div class="row">
            <div class="col-sm-4">
                <label>Automatically Validate Health Cards During Booking</label>

            </div>
            <div class="col-sm-2">
                <label class="radio-inline"><input type="radio" value="true" name="autoValidateOnBooking" <%=autoValidateOnBooking ? "checked" : ""%>>Enabled</label>
                <label class="radio-inline"><input type="radio" value="false" name="autoValidateOnBooking" <%=!autoValidateOnBooking ? "checked" : ""%>>Disabled</label>
            </div>
        </div>

        <div class="row">
            <input type="submit" class="btn btn-primary" value="Submit" />
        </div>
    </form>
</div>

</body>
</html>
