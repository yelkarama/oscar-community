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
<%-- This JSP is the first page you see when you enter 'report by template' --%>
<%@page import="org.oscarehr.common.model.UserProperty"%>
<%@page import="org.oscarehr.common.dao.UserPropertyDAO"%>
<%@ taglib uri="/WEB-INF/security.tld" prefix="security"%>
<%
    String roleName$ = (String)session.getAttribute("userrole") + "," + (String) session.getAttribute("user");
	boolean authed=true;
%>
<security:oscarSec roleName="<%=roleName$%>" objectName="_admin.maintenance" rights="r" reverse="<%=true%>">
	<%authed=false; %>
	<%response.sendRedirect("../securityError.jsp?type=_admin.maintenance");%>
</security:oscarSec>
<%
	if(!authed) {
		return;
	}
%>


<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean"%>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html"%>
<%@ taglib uri="/WEB-INF/struts-logic.tld" prefix="logic"%>
<%@ page import="org.oscarehr.util.SpringUtils" %>
<%@ page import="org.oscarehr.util.LoggedInInfo" %>
<%@ page import="org.oscarehr.common.model.Provider" %>

<%
	LoggedInInfo loggedInInfo=LoggedInInfo.getLoggedInInfoFromSession(request);
	Provider provider = loggedInInfo.getLoggedInProvider();
%>
<html:html locale="true">
<head>
<script type="text/javascript" src="<%= request.getContextPath() %>/js/global.js"></script>
<title>OSCAR Jobs</title>
<link href="<%=request.getContextPath() %>/css/bootstrap.css" rel="stylesheet" type="text/css">
<link href="<%=request.getContextPath() %>/css/datepicker.css" rel="stylesheet" type="text/css">
<link href="<%=request.getContextPath() %>/css/DT_bootstrap.css" rel="stylesheet" type="text/css">
<link href="<%=request.getContextPath() %>/css/bootstrap-responsive.css" rel="stylesheet" type="text/css">
<link rel="stylesheet" href="<%=request.getContextPath() %>/css/font-awesome.min.css">
<link rel="stylesheet" href="<%=request.getContextPath()%>/css/cupertino/jquery-ui-1.8.18.custom.css">

<script type="text/javascript" src="<%=request.getContextPath() %>/js/jquery-1.7.1.min.js"></script>
<script type="text/javascript" src="<%=request.getContextPath() %>/js/jquery-ui-1.8.18.custom.min.js"></script>
<script type="text/javascript" src="<%=request.getContextPath() %>/js/bootstrap.js"></script>
<script type="text/javascript" src="<%=request.getContextPath() %>/js/bootstrap-datepicker.js"></script>
<script type="text/javascript" src="<%=request.getContextPath() %>/js/jquery.validate.js"></script>
<script type="text/javascript" src="<%=request.getContextPath() %>/js/jquery.dataTables.js"></script>
<script type="text/javascript" src="<%=request.getContextPath() %>/js/DT_bootstrap.js"></script>   
<script type="text/javascript" language="JavaScript" src="<%= request.getContextPath() %>/share/javascript/Oscar.js"></script>

<%
UserPropertyDAO upDao = SpringUtils.getBean(UserPropertyDAO.class);


if(request.getParameter("updateStatus") != null && "enable".equals(request.getParameter("updateStatus"))) {
	UserProperty up = upDao.getProp("maintenance_mode");
	if(up == null) {
		up = new UserProperty();
		up.setName("maintenance_mode");
		up.setValue("enabled");
	} else {
		up.setValue("enabled");
	}
	upDao.merge(up);
}

if(request.getParameter("updateStatus") != null && "disable".equals(request.getParameter("updateStatus"))) {
	UserProperty up = upDao.getProp("maintenance_mode");
	if(up == null) {
		up = new UserProperty();
		up.setName("maintenance_mode");
		up.setValue("disabled");
	} else {
		up.setValue("disabled");
	}
	upDao.merge(up);
}

String status = "Disabled";

UserProperty up = upDao.getProp("maintenance_mode");
if(up != null && "enabled".equals(up.getValue())) {
	status = "Enabled";
}
%>

<style>
.red{color:red}
</style>

<script>
function enable() {
	alert('enabling maintenance mode');
	window.location.href='maintenance.jsp?updateStatus=enable';
}

function disable() {
	alert('disabling maintenance mode');
	window.location.href='maintenance.jsp?updateStatus=disable';
}

</script>
</head>

<body vlink="#0000FF" class="BodyStyle">
<h4>Manage Maintenance Mode</h4>

<p>Maintenance mode is currently <%=status %>.</p>
<br/>
<%if("Disabled".equals(status)) { %>
<input type="button" value="Enable" onClick="enable()"/>
<% } else if("Enabled".equals(status)) {%>
<input type="button" value="Disable" onClick="disable()"/>
<% } %>

</body>
</html:html>
