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
<%@ taglib uri="/WEB-INF/security.tld" prefix="security"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>


<%
    String roleName$ = (String)session.getAttribute("userrole") + "," + (String) session.getAttribute("user");
	boolean authed=true;
%>
<security:oscarSec roleName="<%=roleName$%>"
	objectName="_admin,_admin.misc" rights="r" reverse="<%=true%>">
	<%authed=false; %>
	<%response.sendRedirect("../securityError.jsp?type=_admin&type=_admin.misc");%>
</security:oscarSec>
<%
if(!authed) {
	return;
}
%>

<%@ page import="java.util.*,oscar.oscarReport.reportByTemplate.*"%>
<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean"%>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html"%>
<%@ taglib uri="/WEB-INF/struts-logic.tld" prefix="logic"%>
<%@ taglib uri="http://displaytag.sf.net" prefix="display"%>
<html:html locale="true">
<head>
<script type="text/javascript" src="<%= request.getContextPath() %>/js/global.js"></script>
<title>Clinic</title>
<link rel="stylesheet" type="text/css"
	href="<%=request.getContextPath() %>/share/css/OscarStandardLayout.css">
<link rel="stylesheet" type="text/css"
	href='<html:rewrite page="/css/displaytag.css" />' />

<script type="text/javascript" language="JavaScript"
	src="<%=request.getContextPath() %>/share/javascript/prototype.js"></script>
<script type="text/javascript" language="JavaScript"
	src="<%=request.getContextPath() %>/share/javascript/Oscar.js"></script>

<style type="text/css">
table.outline {
	margin-top: 50px;
	border-bottom: 1pt solid #888888;
	border-left: 1pt solid #888888;
	border-top: 1pt solid #888888;
	border-right: 1pt solid #888888;
}

table.grid {
	border-bottom: 1pt solid #888888;
	border-left: 1pt solid #888888;
	border-top: 1pt solid #888888;
	border-right: 1pt solid #888888;
}

td.gridTitles {
	border-bottom: 2pt solid #888888;
	font-weight: bold;
	text-align: center;
}

td.gridTitlesWOBottom {
	font-weight: bold;
	text-align: center;
}

td.middleGrid {
	border-left: 1pt solid #888888;
	border-right: 1pt solid #888888;
	text-align: center;
}

label {
	float: left;
	width: 120px;
	font-weight: bold;
}

label.checkbox {
	float: left;
	width: 116px;
	font-weight: bold;
}

label.fields {
	float: left;
	width: 80px;
	font-weight: bold;
}

span.labelLook {
	font-weight: bold;
}

input,textarea,select { //
	margin-bottom: 5px;
}

textarea {
	width: 450px;
	height: 100px;
}

.boxes {
	width: 1em;
}

#submitbutton {
	margin-left: 120px;
	margin-top: 5px;
	width: 90px;
}

br {
	clear: left;
}
</style>
</head>

<body vlink="#0000FF" class="BodyStyle">

<table class="MainTable">
	<tr class="MainTableTopRow">
		<td class="MainTableTopRowRightColumn">
			<table class="TopStatusBar" style="width: 100%;">
				<tr>
					<td>Manage Functional Centres</td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		
		<td class="MainTableRightColumn" valign="top">
		
<html:form action="/FunctionalCentreManager.do">
	<display:table class="simple" cellspacing="2" cellpadding="3"
		id="functionalCentre" name="functionalCentres" export="false" pagesize="0"
		requestURI="/PMmodule/FunctionalCentreManager.do">
		<display:setProperty name="paging.banner.placement" value="bottom" />
		<display:setProperty name="paging.banner.item_name" value="agency" />
		<display:setProperty name="paging.banner.items_name"
			value="functionalCentres" />
		<display:setProperty name="basic.msg.empty_list"
			value="No Functional Centres found." />

		
		<display:column sortable="false" title="">
			<a
				href="<%=request.getContextPath() %>/FunctionalCentreManager.do?method=edit&id=<c:out value="${functionalCentre.accountId}" />">
			Edit </a>
		</display:column>
		
		<display:column property="accountId" sortable="false" title="Functional Centre ID" />
		<display:column property="description" sortable="false"
			title="Description" />
		<display:column property="enableCbiForm" sortable="false"
			title="CBI Form Enabled" />
	</display:table>
</html:form>
<div>
<p>
<input type="button" value="Add New" onClick="window.location.href='<html:rewrite action="/FunctionalCentreManager.do"/>?method=add'"/>
</p>
</div>
		
		</td>
	</tr>
	<tr>
		
		<td class="MainTableBottomRowRightColumn">&nbsp;</td>
	</tr>
</table>
</html:html>
