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
<!DOCTYPE html>
<%@ taglib uri="/WEB-INF/security.tld" prefix="security"%>
<%
    String roleName$ = (String)session.getAttribute("userrole") + "," + (String) session.getAttribute("user");
    boolean authed=true;
%>
<security:oscarSec roleName="<%=roleName$%>" objectName="_admin,_admin.encounter" rights="w" reverse="true">
	<%authed=false; %>
	<%response.sendRedirect("../securityError.jsp?type=_admin,_admin.encounter");%>
</security:oscarSec>
<%
	if(!authed) {
		return;
	}
	String curUser_no = (String) session.getAttribute("user");
%>
<%@ page import="java.util.*"%>
<%@ page import="org.oscarehr.common.dao.AlertDao" %>
<%@ page import="org.oscarehr.util.SpringUtils" %>
<%@ page import="org.oscarehr.common.model.Alert" %>
<%@ page import="org.owasp.encoder.Encode" %>
<%@ page import="org.oscarehr.common.dao.SystemPreferencesDao" %>
<%@ page import="org.oscarehr.common.model.SystemPreferences" %>
<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean"%>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html"%>
<%
	SystemPreferencesDao systemPreferencesDao = SpringUtils.getBean(SystemPreferencesDao.class);
	SystemPreferences demographicEChartPopup = systemPreferencesDao.findPreferenceByName("demographicEChartPopup");
	if (demographicEChartPopup == null) {
	    demographicEChartPopup = new SystemPreferences("demographicEChartPopup", "false");
	}
	if (request.getParameter("enableDemographicEChartPopup") != null &&
			!request.getParameter("enableDemographicEChartPopup").equals(demographicEChartPopup.getValue())) {
		demographicEChartPopup.setValue(request.getParameter("enableDemographicEChartPopup"));
		demographicEChartPopup.setUpdateDate(new Date());
		systemPreferencesDao.saveEntity(demographicEChartPopup);
	}

	Boolean enableDemographicEChartPopup = "true".equals(demographicEChartPopup.getValue());
	
	AlertDao alertDao = SpringUtils.getBean(AlertDao.class);
	Alert latestAdminAlert = alertDao.findLatestAdminAlert();
	String adminAlertText = "";
	Boolean adminAlertEnabled = false;
	if (latestAdminAlert != null) {
		adminAlertText = latestAdminAlert.getMessage();
		adminAlertEnabled = latestAdminAlert.getEnabled();
	}

	if (request.getParameter("adminAlertText") != null && request.getParameter("adminAlertEnabled") != null) {
		adminAlertText = request.getParameter("adminAlertText");
		adminAlertEnabled = "true".equals(request.getParameter("adminAlertEnabled"));
				
		Boolean setEnabled = (adminAlertEnabled && !adminAlertText.isEmpty());
		if (latestAdminAlert != null && adminAlertText.equals(Encode.forHtmlContent(latestAdminAlert.getMessage()))
				&& latestAdminAlert.getEnabled() != setEnabled) {
			latestAdminAlert.setEnabled(setEnabled);
			latestAdminAlert.setDate(new Date());
			alertDao.merge(latestAdminAlert);
		} else if (latestAdminAlert != null && !adminAlertText.equals(Encode.forHtmlContent(latestAdminAlert.getMessage()))
				|| latestAdminAlert == null) {
			Alert newChartAlert = new Alert(null, Alert.AlertType.ADMIN, setEnabled, adminAlertText);
			alertDao.saveEntity(newChartAlert);
		}
	}
%>

<html:html locale="true">
	<head>
		<title><bean:message key="admin.providertemplate.title"/></title>
<script src="<%=request.getContextPath()%>/JavaScriptServlet" type="text/javascript"></script>
		<link href="<%=request.getContextPath() %>/library/bootstrap/3.0.0/css/bootstrap.css" rel="stylesheet">
		<link rel="stylesheet" href="<%=request.getContextPath() %>/css/font-awesome.min.css">
	</head>
	<body>
	<div class="container-fluid">
		<div class="row">
			<div class="col-sm-12">
				<!--Body content-->
				<h3><bean:message key="admin.eChartAlert.title"/></h3>
			</div>
			<div class="col-sm-12">
				<form class="well" name="adminAlertSettings" method="post" action="eChartAlert.jsp">
					<div class="row">
						<div class="col-sm-12">
							<bean:message key="admin.eChartAlert.enableDemographiceChart"/>:
							<label>On
								<input type="radio" name="enableDemographicEChartPopup" value="true" <%=enableDemographicEChartPopup?"checked=\"checked\"":""%>/>
							</label>
							<label>Off
								<input type="radio" name="enableDemographicEChartPopup" value="false" <%=!enableDemographicEChartPopup?"checked=\"checked\"":""%>/>
							</label>
							<small>(<bean:message key="admin.eChartAlert.enableDemographiceChartAbout"/>)</small>
							<br/>&nbsp;
						</div>
					</div>
					<div class="row">
						<div class="col-sm-12">
							<bean:message key="admin.eChartAlert.systemWideAlert"/>:
							<label>On
								<input type="radio" name="adminAlertEnabled" value="true" <%=adminAlertEnabled?"checked=\"checked\"":""%>/>
							</label>
							<label>Off
								<input type="radio" name="adminAlertEnabled" value="false" <%=!adminAlertEnabled?"checked=\"checked\"":""%>/>
							</label>
						</div>
					</div>
					<div class="row">
						<div class="col-sm-6">
							<textarea name="adminAlertText" rows="6" maxlength="200" class="form-control" style="max-width: 100%;" 
									  placeholder="<bean:message key="admin.eChartAlert.placeHolder"/>"><%=Encode.forHtmlContent(adminAlertText)%></textarea>
						</div>
					</div>
					<div class="row">
						<div class="col-sm-12">
							<input type="submit" class="btn btn-primary" value="<bean:message key="admin.eChartAlert.btnSave"/>"/>
						</div>
					</div>
					<div class="row">
						<div class="col-sm-12">
							<bean:message key="admin.eChartAlert.note1"/><br/>
							<bean:message key="admin.eChartAlert.note2"/>
						</div>
					</div>
				</form>
					
			</div>
		</div>
	</div>

	<script type="text/javascript" src="<%=request.getContextPath() %>/js/jquery-1.9.1.min.js"></script>
	<script type="text/javascript" src="<%=request.getContextPath() %>/library/bootstrap/3.0.0/js/bootstrap.min.js"></script>
	<script>
		
		var isInIFrame = (window.location != window.parent.location);
		if (isInIFrame == true) {
			$('#exit-btn').hide();
		}
	</script>
	</body>
</html:html>
