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

<script src="../js/jquery.js"></script>
<script src="../share/javascript/Oscar.js"></script>

<script>
$( document ).ready( function() {
	var $input = $("[name='group.name']");
	$input.focus();
	
	var tmpStr = $input.val();
	$input.val('');
	$input.val(tmpStr);
});
</script>

<link href="<html:rewrite page='/css/displaytag.css'/>" rel="stylesheet" ></link>
<style>.button {border:1px solid #666666;} </style>

</head>

<body vlink="#0000FF" class="BodyStyle">
<nested:form action="/admin/ManageDemographicGroups">
<table class="MainTable">
	<tr class="MainTableTopRow">
		<td class="MainTableTopRowLeftColumn">admin</td>
		<td class="MainTableTopRowRightColumn">
		<table class="TopStatusBar" style="width: 100%;">
			<tr>
				<td>Add New Demographic Group</td>
			</tr>
		</table>
		</td>
	</tr>
	<tr>
		<td class="MainTableLeftColumn" valign="top" width="160px;">&nbsp;</td>
		<td class="MainTableRightColumn" valign="top">
			<html:errors></html:errors>

			<table>
			<tr>
				<td>Group Name:<sup style="color:red">*</sup></td><td><nested:text property="group.name" maxlength="100"></nested:text></td>
			</tr>
			<tr>
				<td>Description:</td><td><nested:text property="group.description" maxlength="255"></nested:text></td>
			</tr>
			</table>

			<nested:hidden property="group.id"/>
			<input name="method" type="hidden" value="save"></input>
			<nested:submit styleClass="button" >Save</nested:submit> <nested:submit styleClass="button" onclick="this.form.method.value='view'">Cancel</nested:submit>

  		</td>
	</tr>
	<tr>
		<td class="MainTableBottomRowLeftColumn">&nbsp;</td>

		<td class="MainTableBottomRowRightColumn">&nbsp;</td>
	</tr>
</table>
</nested:form>


</html:html>