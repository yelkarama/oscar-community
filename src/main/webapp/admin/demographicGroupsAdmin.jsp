<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<%@ include file="/taglibs.jsp"%>
<%@ taglib uri="/WEB-INF/security.tld" prefix="security"%>
<%
	if(session.getAttribute("userrole") == null )  response.sendRedirect("../logout.jsp");
	String roleName$ = (String)session.getAttribute("userrole") + "," + (String) session.getAttribute("user");
%>
<security:oscarSec roleName="<%=roleName$%>"
	objectName="_admin,_admin.misc" rights="r" reverse="<%=true%>">
	<%response.sendRedirect("../logout.jsp");%>
</security:oscarSec>

<%@page import="org.oscarehr.common.model.DemographicGroup"%>
<html:html locale="true">
<head>
<script src="<%= request.getContextPath() %>/js/global.js"></script>
<title>Demographic Groups</title>
<link rel="stylesheet" type="text/css" href="../share/css/OscarStandardLayout.css">

<script src="../share/javascript/Oscar.js"></script>
<link href="<html:rewrite page='/css/displaytag.css'/>" rel="stylesheet" ></link>
</head>

<body vlink="#0000FF" class="BodyStyle">

<table class="MainTable">
	<tr class="MainTableTopRow">
		<td class="MainTableTopRowLeftColumn">admin</td>
		<td class="MainTableTopRowRightColumn">
		<table class="TopStatusBar" style="width: 100%;">
			<tr>
				<td>Manage Demographic Group Details</td>
			</tr>
		</table>
		</td>
	</tr>
	<tr>
		<td class="MainTableLeftColumn" valign="top" width="160px;">
		&nbsp;</td>
		<td class="MainTableRightColumn" valign="top">
		
		<html:errors></html:errors>
		
		<html:messages id="message" message="true">
			<bean:write name="message" filter="false" />
		</html:messages>
		
<nested:form action="/admin/ManageDemographicGroups?method=add">
<nested:submit style="border:1px solid #666666;">Add New Demographic Group</nested:submit>
</nested:form>

<display-el:table name="groups" id="group" class="its" style="border:1px solid #666666; width:99%;margin-top:2px;">
	<display-el:column title="Group Name">
	<a href="<%= request.getContextPath() %>/admin/ManageDemographicGroups.do?method=update&id=<c:out value='${group.id}'/>" ><c:out value="${group.name}" /></a></display-el:column>
	<display-el:column property="description" title="Description" />
	<display-el:column title="">
	<a href="<%= request.getContextPath() %>/admin/ManageDemographicGroups.do?method=delete&id=<c:out value='${group.id}'/>" > Delete </a></display-el:column>
</display-el:table>
		

		</td>
	</tr>
	<tr>
		<td class="MainTableBottomRowLeftColumn">&nbsp;</td>

		<td class="MainTableBottomRowRightColumn">&nbsp;</td>
	</tr>
</table>

</html:html>