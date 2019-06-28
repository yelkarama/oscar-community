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

<%@include file="/casemgmt/taglibs.jsp"%>

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
<title><bean:message key="provider.btnBillPreference" /></title>
<script src="<%=request.getContextPath()%>/JavaScriptServlet" type="text/javascript"></script>

<script type="text/javascript" src="<%=request.getContextPath() %>/js/jquery-1.9.1.min.js"></script>
<script type="text/javascript" src="<%=request.getContextPath() %>/js/bootstrap.min.js"></script>
<script>
function hideItem(hideId){
	var $permiRow = $("#"+hideId).parent().parent();
	var permiActive = $permiRow.find("[name='permission']")[0];
	
	if(permiActive == null){
		var iter = hideId.replace("removeAll","");
		var $permiRows = $(".permList"+iter).children();
		for(var i = 0; i < $permiRows.length; i++){
			var pRow = $permiRows[i];
			var pActive = $(pRow).find("[name='permission']")[0];
			var pIcon = $(pRow).find("i")[0];
			
			if($permiRow.find("i").hasClass("icon-ok")){
				pActive.value = "false";
				$(pIcon).removeClass("icon-remove icon-ok");
				$(pIcon).addClass("icon-remove");
				
				$(pRow).addClass("inactive");
			}else{
				pActive.value = "true";
				$(pIcon).removeClass("icon-remove icon-ok");
				$(pIcon).addClass("icon-ok");
				
				$(pRow).removeClass("inactive");
			}
		}
		
		if($permiRow.find("i").hasClass("icon-ok")){
			$permiRow.find("i").removeClass("icon-ok")
			$permiRow.find("i").addClass("icon-remove")
		}else{
			pActive.value = "true";
			$permiRow.find("i").removeClass("icon-remove");
			$permiRow.find("i").addClass("icon-ok");
		}
		
	}else{
		if(permiActive.value == "true"){
			permiActive.value = "false";
			$("#"+hideId).removeClass("icon-ok");
			$("#"+hideId).addClass("icon-remove");
			
			$permiRow.addClass("inactive");
		}else{
			permiActive.value = "true";
			$("#"+hideId).removeClass("icon-remove");
			$("#"+hideId).addClass("icon-ok");
			
			$permiRow.removeClass("inactive");
		}	
	}
}

</script>

<link href="<%=request.getContextPath() %>/css/bootstrap.min.css" rel="stylesheet" />
<link href="<%=request.getContextPath() %>/css/panel.css" rel="stylesheet" />
<link href="<%=request.getContextPath() %>/css/list-group.css" rel="stylesheet" />
<style>
	body {
		padding: 0 16px;
	}
	
.inactive{
	background-color: #e3e3e3;
}
.controls{
	float: right;
	cursor: pointer;
}

ul, .panel-group{
	margin:0px;
}

#billingONPermissions .panel-group{
	width: 400px;
}

#billingONPermissions{
	margin-bottom: 60px;
}

#formControls{
	position: fixed;
    z-index: 100; 
    bottom: 0; 
    left: 0;
    width: 100%;
	background-color: #dddddd;
	padding: 5px;
}
</style>

</head>



<body>
<h3><bean:message key="provider.btnBillPreference" /></h3>
<logic:present name="successMsg">  
	<div class="alert alert-success">
	  <strong>Success!</strong> Billing Preferences saved.
	</div>
</logic:present>
<logic:present name="warningMsg">  
	<div class="alert alert-warning">
	  <strong>Warning!</strong> Billing Preferences save interrupted. Try again later or contact system administrator.
	</div>
</logic:present>

<html:form action="/billing/CA/ON/saveBillingPreferencesAction">
	<h4>Default Bill Form</h4>
	<input type="hidden" id="method" name="method" value="update" />
	<div id="billingONpref">
          <bean:message key="provider.labelDefaultBillForm"/>:
	  <html:select name="BillingPreferencesActionForm" property="default_servicetype">
	      <html:option value="no">-- no --</html:option>
		  <html:optionsCollection name="BillingPreferencesActionForm" property="ctlBillingServices" label="serviceTypeName" value="serviceType"/>
	  </html:select>
	  </div>
	  
	<h4>Manage Permissions</h4>	
	<div id="billingONPermissions">
		<logic:iterate id="provPermissions" name="providerPermissions" indexId="provPermIndex">
		  <div class="panel-group">
			  <div class="panel panel-default">
				<div class="panel-heading">
				  <h4 class="panel-title">
					<a data-toggle="collapse" href="#collapse<bean:write name="provPermIndex" />"><bean:write name="provPermissions"  property="provider_name" /></a>
					<span class="controls">
						<logic:equal name="provPermissions" property="has_disabled_permissions" value="false">
							<i id="removeAll<bean:write name="provPermIndex" />" class="icon-ok" onclick="hideItem(this.id)"></i>
						</logic:equal>
						<logic:equal name="provPermissions" property="has_disabled_permissions" value="true">
							<i id="removeAll<bean:write name="provPermIndex" />" class="icon-remove" onclick="hideItem(this.id)"></i>
						</logic:equal>
					</span>
				  </h4>
				</div>
				<div id="collapse<bean:write name="provPermIndex" />" class="panel-collapse collapse">
				  <ul class="list-group permList<bean:write name="provPermIndex" />">
				<logic:iterate id="permission" name="permissionList" indexId="permissionIndex">
					<li class="list-group-item
						<logic:present name="provPermissions" property="${permission}"> 
							<logic:equal name="provPermissions" property="${permission}" value="false">
							inactive
							</logic:equal>
						</logic:present>" >
						<bean:message key="admin.preference.billing.${permission}" />
						<html:hidden property="viewerNo" value="${provPermissions.provider_no}" />
						<input type="hidden" name="permissionNo" value="${permission}" />
						<logic:present name="provPermissions" property="${permission}">
							<input type="hidden" name="permission" value="<bean:write name="provPermissions" property="${permission}"/>" />
							<span class="controls">
								<logic:equal name="provPermissions" property="${permission}" value="false">
									<i id="remove<bean:write name="provPermIndex" />_<bean:write name="permissionIndex" />" class="icon-remove" onclick="hideItem(this.id)"></i>
								</logic:equal>
								<logic:notEqual name="provPermissions" property="${permission}" value="false">
									<i id="remove<bean:write name="provPermIndex" />_<bean:write name="permissionIndex" />" class="icon-ok" onclick="hideItem(this.id)"></i>
								</logic:notEqual>
							</span>
						</logic:present>
						<logic:notPresent name="provPermissions" property="${permission}">
							<input type="hidden" name="permission" value="true" />
							<span class="controls">
								<i id="remove<bean:write name="provPermIndex" />_<bean:write name="permissionIndex" />" class="icon-ok" onclick="hideItem(this.id)"></i>
							</span>
						</logic:notPresent>
					</li>
				</logic:iterate>
				  </ul>
				</div>
			  </div>
			</div>
		</logic:iterate>
	</div>
	<div id="formControls">
		<input type="submit" value="Save" />
	</div>
</html:form>
</body>
</html:html>