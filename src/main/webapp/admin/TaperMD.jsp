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


<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean"%>

<html ng-app="taperConfig">
<head>
	<title><bean:message key="admin.admin.Know2ActConfig"/></title>
	<link href="<%=request.getContextPath() %>/library/bootstrap/3.0.0/css/bootstrap.css" rel="stylesheet">
	<link rel="stylesheet" href="<%=request.getContextPath() %>/css/font-awesome.min.css">
	<script type="text/javascript" src="<%=request.getContextPath() %>/library/angular.min.js"></script>	
	<script src="<%=request.getContextPath() %>/web/common/k2aServices.js"></script>	
</head>

<body vlink="#0000FF" class="BodyStyle">
	<div ng-controller="taperConfig">
		<div class="page-header">
			<h4><bean:message key="admin.admin.TaperConfig"/> </h4>
		</div>
	 	
		<div>
			<form action="Know2actConfiguration.jsp"  method="POST">
				<fieldset>
					<div class="form-group col-xs-5">
						<label><bean:message key="admin.admin.taperIdentifier"/></label>
						<div class="controls">
							<input class="form-control" name="clinicName" ng-model="institutionId" type="text" maxlength="255"/>  <br/>
						</div>
						<label><bean:message key="admin.admin.taperKey"/></label>
						<div class="controls">
							<input class="form-control" name="clinicName" ng-model="clinicKey" type="text" maxlength="255"/>  <br/>
						</div>
						<input type="button" class="btn btn-primary" ng-disabled="institutionId==null || institutionId==''" value="<bean:message key="admin.taper.initbtn"/>"  ng-click="initTaper()"/>
					</div>
				</fieldset>
			</form>
		</div>
	</div>
	
	<script>
		var app = angular.module("taperConfig", ['k2aServices']);
		
		app.controller("taperConfig", function($scope,$http,k2aService) {
			
		    
			$scope.initTaper = function(){
				console.log("initTaper",$scope.institutionId,$scope.clinicKey);
				taper = {}
				taper.institutionId  = $scope.institutionId;
				taper.clinicKey = $scope.clinicKey;
				
				$http.post('../ws/rs/app/initTaper',taper,{headers: {"Content-Type": "application/json","Accept":"application/json"}}).then(function(response){
					console.log("initTaper",response);
					alert("Saved");
				},function(){
					  console.log("error initializing taper");
				
				});
				
			}
		   
		       
		});
	
	</script>
</html>
