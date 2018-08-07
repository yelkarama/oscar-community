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
<%@ page import="org.apache.commons.lang.StringUtils" %>
<%@ page import="org.oscarehr.common.model.Provider" %>
<%@ page import="org.oscarehr.util.LoggedInInfo" %>
<%@ page import="org.oscarehr.common.dao.PropertyDao" %>
<%@ page import="org.oscarehr.common.model.Property" %>
<%@ page import="org.oscarehr.common.dao.SystemPreferencesDao" %>
<%@ page import="org.oscarehr.common.model.SystemPreferences" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.util.List" %>

<jsp:useBean id="dataBean" class="java.util.Properties"/>
<%
	SystemPreferencesDao systemPreferencesDao = SpringUtils.getBean(SystemPreferencesDao.class);
	PropertyDao propertyDao = SpringUtils.getBean(PropertyDao.class);
	
	Provider loggedInProvider = LoggedInInfo.getLoggedInInfoFromSession(request).getLoggedInProvider();
	StringBuilder errorMessage = new StringBuilder();
	
	Property masterfileShowReminderPreference = propertyDao.checkByName("masterfile_show_reminder_preference");
	if (masterfileShowReminderPreference == null) {
		masterfileShowReminderPreference = new Property();
		masterfileShowReminderPreference.setName("masterfile_show_reminder_preference");
		masterfileShowReminderPreference.setValue("false");
	}

	if (request.getParameter("dboperation") != null && !request.getParameter("dboperation").isEmpty() && request.getParameter("dboperation").equals("save")) {
		String masterfileShowReminderPreferenceStr = request.getParameter("masterfile_show_reminder_preference");
		masterfileShowReminderPreference.setValue(Boolean.valueOf(masterfileShowReminderPreferenceStr).toString());
		propertyDao.saveEntity(masterfileShowReminderPreference);

		for(String key : SystemPreferences.MASTER_FILE_PREFERENCE_KEYS) {
			SystemPreferences preference = systemPreferencesDao.findPreferenceByName(key);
			String newValue = request.getParameter(key) != null ? request.getParameter(key) : "false";

			if (preference != null) {
				if (!preference.getValueAsBoolean().equals(Boolean.parseBoolean(newValue))) {
					preference.setUpdateDate(new Date());
					preference.setValue(newValue);
					systemPreferencesDao.merge(preference);
				}
			} else {
				preference = new SystemPreferences();
				preference.setName(key);
				preference.setUpdateDate(new Date());
				preference.setValue(newValue);
				systemPreferencesDao.persist(preference);
			}
		}
	}
	
	Boolean masterfileShowReminderPreferenceActive = Boolean.valueOf(masterfileShowReminderPreference.getValue());

	List<SystemPreferences> preferences = systemPreferencesDao.findPreferencesByNames(SystemPreferences.MASTER_FILE_PREFERENCE_KEYS);
	for(SystemPreferences preference : preferences) {
		dataBean.setProperty(preference.getName(), preference.getValueAsBoolean().toString());
	}
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
	<form name="masterfileOptionsForm" method="post" action="customizeMasterfileFields.jsp">
		<% if (!StringUtils.isBlank(errorMessage.toString())) { %>
		<span style="color: red"><%=errorMessage.toString()%></span>
		<% } %>
		<input type="hidden" id="dboperation" name="dboperation" value="save">
		<h4>Customize Masterfile Fields</h4>
		<table class="table table-bordered table-striped table-hover table-condensed">
			<tr>
				<th>Name</th>
				<th>Enable/Disable</th>
			</tr>
			<tr>
				<td>Reminder Preference</td>
				<td style="width: 20px; text-align: center;"><input type="checkbox" name="masterfile_show_reminder_preference" value="true"<%=masterfileShowReminderPreferenceActive?" checked=\"checked\"":""%>></td>
			</tr>
			<tr>
				<td>Display Former Name</td>
				<td style="width: 20px; text-align: center;"><input type="checkbox" name="display_former_name" value="true"<%= dataBean.getProperty("display_former_name", "false").equals("true") ? " checked=\"checked\"":""%>></td>
			</tr>
		</table>
		<input class="btn btn-primary" type="submit" value="Save"/>
	</form>
	</body>
</html:html>
