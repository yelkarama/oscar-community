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
<%@ taglib uri="/WEB-INF/security.tld" prefix="security"%>
<%
	String roleName$ = (String)session.getAttribute("userrole") + "," + (String) session.getAttribute("user");
	boolean authed=true;
%>
<security:oscarSec roleName="<%=roleName$%>" objectName="_admin" rights="r" reverse="<%=true%>">
	<%authed=false; %>
	<%response.sendRedirect("../securityError.jsp?type=_admin");%>
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
<%@ page import="org.oscarehr.common.dao.SystemPreferencesDao" %>
<%@ page import="org.oscarehr.common.model.SystemPreferences" %>
<%@ page import="java.util.Date" %>
<%@ page import="org.oscarehr.common.model.CustomHealthcardType" %>
<%@ page import="org.oscarehr.common.dao.CustomHealthcardTypeDao" %>
<%@ page import="java.util.List" %>
<%@ page import="org.oscarehr.util.MiscUtils" %>
<%@ page import="org.apache.commons.lang.StringUtils" %>
<%@ page import="org.oscarehr.common.model.Provider" %>
<%@ page import="org.oscarehr.util.LoggedInInfo" %>

<jsp:useBean id="dataBean" class="java.util.Properties"/>
<%
	SystemPreferencesDao systemPreferencesDao = SpringUtils.getBean(SystemPreferencesDao.class);
	CustomHealthcardTypeDao customHealthcardTypeDao = SpringUtils.getBean(CustomHealthcardTypeDao.class);
	Provider loggedInProvider = LoggedInInfo.getLoggedInInfoFromSession(request).getLoggedInProvider();
	StringBuilder errorMessage = new StringBuilder();

	if (request.getParameter("dboperation") != null && !request.getParameter("dboperation").isEmpty()) {
		if (request.getParameter("dboperation").equals("save")) {
			String[] healthCardTypeIds = request.getParameterValues("customHealthCardTypeId");
			if (healthCardTypeIds != null && healthCardTypeIds.length > 0) {
				for (String hcTypeId : healthCardTypeIds) {
					try {
						Boolean enabled = request.getParameter("enable_" + hcTypeId) != null;
						CustomHealthcardType healthcardType = customHealthcardTypeDao.find(Integer.parseInt(hcTypeId));
						if (healthcardType != null) {
							healthcardType.setEnabled(enabled);
							customHealthcardTypeDao.saveEntity(healthcardType);
						}
					} catch (NumberFormatException e) {
						MiscUtils.getLogger().error("Error updating custom healthcard type: " + hcTypeId, e);
					}
				}
			}
		} else if (request.getParameter("dboperation").startsWith("delete-hc-type-id-")) {
			String deleteHcTypeId = request.getParameter("dboperation").replace("delete-hc-type-id-", "");
			try {
				CustomHealthcardType healthcardType = customHealthcardTypeDao.find(Integer.parseInt(deleteHcTypeId));
				if (healthcardType != null) {
					healthcardType.setDeleted(true);
					customHealthcardTypeDao.saveEntity(healthcardType);
				}
			} catch (NumberFormatException e) {
				MiscUtils.getLogger().error("Error deleting custom healthcard type: " + deleteHcTypeId, e);
			}
		} else if (request.getParameter("dboperation").startsWith("add-new-hc-type")) {
			String newHcTypeName = request.getParameter("new-hc-type");
			if (!StringUtils.isBlank(newHcTypeName)) {
				newHcTypeName = newHcTypeName.trim();
				Boolean enabled = request.getParameter("new-hc-type-enable") != null;
				List<CustomHealthcardType> existingHealthcardTypes = customHealthcardTypeDao.findByName(newHcTypeName);
				if (existingHealthcardTypes.size() > 0) {
					errorMessage.append("Cannot create new healthcard type \"").append(newHcTypeName).append("\", a type with that name already exists");
				} else {
					CustomHealthcardType newHcType = new CustomHealthcardType(newHcTypeName, enabled, loggedInProvider.getProviderNo());
					customHealthcardTypeDao.saveEntity(newHcType);
				}
			}
		}
	}
	List<CustomHealthcardType> customHcTypes = customHealthcardTypeDao.findAllNotDeleted();

%>
<html:html locale="true">
	<head>
		<title>Mandatory Fields - Master File</title>
		<link href="<%=request.getContextPath() %>/css/bootstrap.css" rel="stylesheet" type="text/css">

		<script type="text/javascript" src="<%= request.getContextPath() %>/js/global.js"></script>
		<script type="text/javascript" src="<%=request.getContextPath() %>/js/jquery-1.7.1.min.js"></script>
		<script type="text/javascript" src="<%=request.getContextPath() %>/js/bootstrap.js"></script>
		<script type="text/javascript" language="JavaScript" src="<%= request.getContextPath() %>/share/javascript/Oscar.js"></script>
	</head>
	<body vlink="#0000FF" class="BodyStyle">
	<form name="masterfileOptionsForm" method="post" action="customHcTypes.jsp">
		<% if (!StringUtils.isBlank(errorMessage.toString())) { %>
		<span style="color: red"><%=errorMessage.toString()%></span>
		<% } %>
		<input type="hidden" id="dboperation" name="dboperation" value="save">
		<h4>Custom Healthcard Types</h4>
		<span>Note: Demographics with custom HC types will default to 3rd party while billing</span>
		<table class="table table-bordered table-striped table-hover table-condensed">
			<tr>
				<th>Name</th>
				<th>Enable/Disable</th>
				<th></th>
			</tr>
			<% for (CustomHealthcardType type : customHcTypes) { %>
			<tr>
				<td><%=type.getName()%><input type="hidden" name="customHealthCardTypeId" value="<%=type.getId()%>"></td>
				<td style="width: 20px; text-align: center;"><input type="checkbox" name="enable_<%=type.getId()%>"<%=type.getEnabled()?" checked=\"checked\"":""%>></td>
				<td style="width: 10px"><input class="btn btn-small btn-primary" type="submit" value="Delete" onclick="document.getElementById('dboperation').value = 'delete-hc-type-id-<%=type.getId()%>';"></td>
			</tr>
			<% } %>
			<tr>
				<td><input style="margin-bottom: 0;" type="text" name="new-hc-type" placeholder="Add new healthcard type" maxlength="20" minlength="3"></td>
				<td style="width: 20px; text-align: center;"><input type="checkbox" name="new-hc-type-enable" checked="checked"></td>
				<td style="width: 10px"><input class="btn btn-small btn-primary" type="submit" value="Add" onclick="document.getElementById('dboperation').value = 'add-new-hc-type';"></td>
			</tr>
		</table>
		<input class="btn btn-primary" type="submit" value="Save"/>
	</form>
	</body>
</html:html>
