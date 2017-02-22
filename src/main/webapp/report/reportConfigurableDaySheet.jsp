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

<%@ taglib uri="/WEB-INF/security.tld" prefix="security"%>
<%
      String roleName$ = (String)session.getAttribute("userrole") + "," + (String) session.getAttribute("user");
      boolean authed=true;
%>
<security:oscarSec roleName="<%=roleName$%>" objectName="_report,_admin.reporting" rights="r" reverse="<%=true%>">
	<%authed=false; %>
	<%response.sendRedirect("../securityError.jsp?type=_report&type=_admin.reporting");%>
</security:oscarSec>
<%
if(!authed) {
	return;
}
%>

<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean"%>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html"%>
<%@ taglib uri="/WEB-INF/security.tld" prefix="security"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="/WEB-INF/struts-logic.tld" prefix="logic"%>

<c:set var="ctx" value="${pageContext.request.contextPath}" />

<html:html locale="true">
<head>
<script type="text/javascript" src="<%= request.getContextPath() %>/share/javascript/Oscar.js"></script>
<script type="text/javascript" src="<%= request.getContextPath() %>/js/global.js"></script>
<script type="text/javascript" src="<%= request.getContextPath() %>/share/javascript/prototype.js"></script>
<script type="text/javascript" src="<%= request.getContextPath() %>/share/javascript/effects.js"></script>
<script type="text/javascript" src="<%= request.getContextPath() %>/share/lightwindow/javascript/lightwindow.js"></script>
<title><bean:message key="report.reportdaysheet.title" /></title>
<link rel="stylesheet" href="../web.css">
<link rel="stylesheet" href="<%= request.getContextPath() %>/share/lightwindow/css/lightwindow.css" type="text/css" media="screen">
<style>
td {font-size: 16px;}

@media print{    
    .no-print, .no-print *{
        display: none !important;
    }
	#lightwindow_overlay{
		display:none;
	}
}

</style>
<script>
	function viewDemographic(demo_no){
	myLightWindow.activateWindow({
		href: "<%= request.getContextPath() %>/demographic/demographiccontrol.jsp?demographic_no=" + demo_no + "&displaymode=edit",
		width: 1024,
		height: 1500
	});
}
</script>
<%  String deepColor = "#CCCCFF", weakColor = "#EEEEFF" ; %>
</head>
<body bgproperties="fixed" onLoad="setfocus()" topmargin="0" leftmargin="0" rightmargin="0">

<table border="0" cellspacing="0" cellpadding="0" width="100%">
	<tr bgcolor="<%=deepColor%>">
		<th width="10%" nowrap><bean:write name="createtime" /> <input type="button"
			name="Button"
			value="<bean:message key="report.reportdaysheet.btnPrint"/>"
			onClick="window.print()" class="no-print" /><input type="button" name="Button"
			value="<bean:message key="global.btnExit"/>" onClick="window.close()" class="no-print" />
		</th>
	</tr>
</table>
<bean:write name="heading" />
<table width="100%" border="1" bgcolor="#ffffff" cellspacing="0"
	cellpadding="1">
	<tr bgcolor="#CCCCFF" align="center">
		<logic:iterate id="dsItem" name="dsConfig" indexId="dsIndex">
			<th><bean:write name="dsItem" property="heading" /></th>
		</logic:iterate>
	</tr>

	<logic:iterate id="appt" name="appointments" indexId="apptIndex">
		<tr id="r<bean:write name="apptIndex" />" height="57px">
		<logic:iterate id="dsItem" name="dsConfig" indexId="dsIndex">
			<td>
				<logic:present name="appt" property="${dsItem.field}">
					<c:choose>
						<c:when test="${dsItem.field=='Patient'}">
							<a href="#" onclick="viewDemographic(<bean:write name="appt" property="Demographic Number" />);">
								<bean:write name="appt" property="${dsItem.field}" />
							</a>
						</c:when>    
						<c:otherwise>
							<bean:write name="appt" property="${dsItem.field}" />
						</c:otherwise>
					</c:choose>					
				</logic:present>
			</td>
		</logic:iterate>
		</tr>
	</logic:iterate>

</table>
</body>
</html:html>
