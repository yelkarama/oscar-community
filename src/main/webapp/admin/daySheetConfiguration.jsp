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

<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean"%>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html"%>
<%@ taglib uri="/WEB-INF/security.tld" prefix="security"%>
<%@ taglib uri="/WEB-INF/struts-logic.tld" prefix="logic"%>


<%
    String curProvider_no = (String) session.getAttribute("user");
    String roleName$ = (String)session.getAttribute("userrole") + "," + (String) session.getAttribute("user");

    boolean isSiteAccessPrivacy=false;
%>

<security:oscarSec objectName="_admin,_admin.misc" roleName="<%=roleName$%>" rights="r" reverse="false">
	<%isSiteAccessPrivacy=true; %>
</security:oscarSec>

<!DOCTYPE html>
<html:html locale="true">
<head>
<title><bean:message key="admin.admin.daySheetConfiguration" /></title>

<script type="text/javascript" src="<%=request.getContextPath() %>/js/jquery-1.9.1.min.js"></script>
<script>
function hideItem(hideId){
	var $configRow = $("#"+hideId).parent().parent();
	var configActive = $configRow.find("[name='active']")[0];
	
	if(configActive.value == "true"){
		configActive.value = "false";
		$("#"+hideId).html("Show");
		
		$configRow.addClass("inactive");
	}else{
		configActive.value = "true";
		$("#"+hideId).html("Hide");
		
		$configRow.removeClass("inactive");
	}
}

function moveUp(upId){
	var $configRow = $("#"+upId).parent().parent();
	 $configRow.insertBefore($configRow.prev());
}

function moveDown(downId){
	var $configRow = $("#"+downId).parent().parent();
	 $configRow.insertAfter($configRow.next());
}
</script>

<link href="<%=request.getContextPath() %>/css/bootstrap.min.css" rel="stylesheet">
<style>
.action{
	width: 150px;
	text-align: center;
}
.inactive{
	background-color: #878787;
}
span{
	cursor: pointer;
	margin: 3px;
	padding: 3px;
	border: 1px solid #88AAee;
}
span:hover{
	background-color: #0088cc;
}
</style>

</head>



<body>
<h3><bean:message key="admin.admin.daySheetConfiguration" /></h3>
<logic:present name="successMsg">  
	<div class="alert alert-success">
	  <strong>Success!</strong> Day sheet Configuration saved.
	</div>
</logic:present>
<logic:present name="warningMsg">  
	<div class="alert alert-warning">
	  <strong>Warning!</strong> Day sheet configuration saved interrupted. Try again later or contact system administrator.
	</div>
</logic:present>

<html:form action="/admin/daySheetConfiguration">
	<input type="hidden" id="method" name="method" value="update" />
	<table>
		<thead>
			<th></th><th>Field</th><th>Heading</th>
		</thead>
		<tbody>
			<logic:iterate id="dsItem" name="dsConfigForm" property="dsConfig" indexId="dsIndex">
				<tr class="<logic:notEqual name="dsItem" property="active" value="true" >inactive</logic:notEqual>">
					<td class="action">
						<span id="hide<bean:write name="dsItem" property="id" />" onClick="hideItem(this.id);">
							<logic:equal name="dsItem" property="active" value="true" > Hide </logic:equal>
							<logic:notEqual name="dsItem" property="active" value="true" > Show </logic:notEqual>
						</span>
						<span id="up<bean:write name="dsItem" property="id" />" onClick="moveUp(this.id);">Up</span>
						<span id="down<bean:write name="dsItem" property="id" />" onClick="moveDown(this.id);">Down</span>
					</td>
					<td> 
						<bean:write name="dsItem" property="field" /> 
						<html:hidden name="dsItem" property="id" />
					</td>
					<td> 
						<html:text name="dsItem" property="heading" /> 
						<html:hidden name="dsItem" property="active" />
					</td>
				</tr>
			</logic:iterate>
		</tbody>
	</table>
	<input type="submit" value="Save" />
	<input type="submit" value="Reset" onClick="document.getElementById('method').value='view';" />
</html:form>
</body>
</html:html>
