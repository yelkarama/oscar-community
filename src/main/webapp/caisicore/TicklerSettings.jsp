<%@ page import="org.oscarehr.common.dao.PropertyDao" %>
<%@ page import="org.oscarehr.util.SpringUtils" %>
<%@ page import="org.oscarehr.common.model.Property" %>
<%@ page import="oscar.log.LogAction" %>
<%@ page import="oscar.log.LogConst" %>
<%@ page import="org.oscarehr.util.LoggedInInfo" %><%--


    Copyright (c) 2005-2012. Centre for Research on Inner City Health, St. Michael's Hospital, Toronto. All Rights Reserved.
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

    This software was written for
    Centre for Research on Inner City Health, St. Michael's Hospital,
    Toronto, Ontario, Canada

--%>


<%@ include file="/taglibs.jsp" %>
<%
	String roleName$ = (String) session.getAttribute("userrole") + "," + (String) session.getAttribute("user");
	boolean authed = true;
%>
<security:oscarSec roleName="<%=roleName$%>" objectName="_admin" rights="w" reverse="<%=true%>">
	<%authed = false; %>
	<%response.sendRedirect(request.getContextPath() + "/securityError.jsp?type=_admin");%>
</security:oscarSec>
<%
	if (!authed) {
		return;
	}

	String checkedString = "checked=\"checked\"";
	
	PropertyDao propertyDao = SpringUtils.getBean(PropertyDao.class);
	Property ticklerShowOnlyProviderPrograms = propertyDao.checkByName("tickler_show_only_providers_programs");
	if (ticklerShowOnlyProviderPrograms == null) {
		ticklerShowOnlyProviderPrograms = new Property("tickler_show_only_providers_programs");
		ticklerShowOnlyProviderPrograms.setValue("false");
	}
	
	if (request.getParameter("show_only_providers_programs") != null) {
	    String propertyString = request.getParameter("show_only_providers_programs");
	    if ("true".equals(propertyString) || "false".equals(propertyString)) {
			ticklerShowOnlyProviderPrograms.setValue(propertyString);
			propertyDao.saveEntity(ticklerShowOnlyProviderPrograms);
			LogAction.addLog(LoggedInInfo.getLoggedInInfoFromSession(request), LogConst.UPDATE, "CAISI tickler setting", 
					"set " + ("true".equals(propertyString) ? "on" : "off"), "", "");
		}
	}
	
	
%>

<html>
<head>
	<script type="text/javascript" src="<%=request.getContextPath()%>/js/global.js"></script>
	<script type="text/javascript" src="<%=request.getContextPath()%>/js/jquery-3.1.0.min.js"></script>
	<script type="text/javascript" src="<%=request.getContextPath()%>/js/jquery-ui-1.8.18.custom.min.js"></script>
	<script type="text/javascript" src="<%=request.getContextPath()%>/js/fabric.js"></script>
	<script type="text/javascript" src="<%=request.getContextPath() %>/library/bootstrap/3.0.0/js/bootstrap.js"></script>
	<link href="<%=request.getContextPath() %>/library/bootstrap/3.0.0/css/bootstrap.min.css" rel="stylesheet" type="text/css">
	<link href="<%=request.getContextPath() %>/js/jquery_css/smoothness/jquery-ui-1.7.3.custom.css" rel="stylesheet" type="text/css">

	<title>Caisi Tickler Setting</title>
</head>
<body>
<h3>Caisi Tickler Setting</h3>
<div class="container form-inline" style="max-width: 100%;">
	<div class="well">
		<form action="<%=request.getContextPath()%>/caisicore/TicklerSettings.jsp">
			<div>
				Show only ticklers linked to programs assigned to provider:
				<label>
					On
					<input type="radio" name="show_only_providers_programs" value="true" 
							<%=ticklerShowOnlyProviderPrograms.getValue().equals("true")?checkedString:""%>/>
				</label>
				<label>
					Off
					<input type="radio" name="show_only_providers_programs" value="false"
							<%=ticklerShowOnlyProviderPrograms.getValue().equals("false")?checkedString:""%>/>
				</label>
			</div>
			<div>
				<button type="submit" class="btn btn-primary" value="Save">Save</button>
			</div>
		</form>
	</div>
</div>
</body>
</html>
