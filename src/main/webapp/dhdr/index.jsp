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

<html ng-app="dhdrView">
<head>
	<title><bean:message key="admin.admin.surveillanceConfig"/></title>
	<link href="<%=request.getContextPath() %>/library/bootstrap/3.0.0/css/bootstrap.css" rel="stylesheet">
	<link rel="stylesheet" href="<%=request.getContextPath() %>/css/font-awesome.min.css">
	<script type="text/javascript" src="<%=request.getContextPath() %>/library/angular.min.js"></script>	
	<script src="<%=request.getContextPath() %>/web/common/demographicServices.js"></script>	
	<script src="<%=request.getContextPath() %>/web/common/providerServices.js"></script>	
	<script src="<%=request.getContextPath() %>/web/common/dhdrServices.js"></script>	
	<script src="<%=request.getContextPath() %>/web/filters.js"></script>
	
</head>

<body vlink="#0000FF" class="BodyStyle">
	<div ng-controller="dhdrView">
	<div class="page-header" style="margin-top: 0px; margin-bottom: 0px;">
		<h1 class="patientHeaderName" style="margin-top: 0px;" ng-cloak>
			<b>{{demographic.lastName}}, {{demographic.firstName}}</b>  <span ng-show="demographic.alias">({{demographic.alias}})</span> 
			
			<small class="patientHeaderExt pull-right"> 
				<i><bean:message key="demographic.patient.context.born"/>: </i>
				<b>{{demographic.dobYear}}-{{demographic.dobMonth}}-{{demographic.dobDay}}</b> (<b>{{demographic.age | age}}</b>) &nbsp;&nbsp; <i><bean:message key="demographic.patient.context.sex"/>:</i> <b>{{demographic.sex}}</b>
				<i> &nbsp;&nbsp; <bean:message key="Appointment.msgTelephone"/>:</i> <b>{{demographic.phone}}</b> 
				<!-- <span class="glyphicon glyphicon-new-window"></span>-->
			</small>
		</h1>
	</div>
	
		<div class="row">
		 	
		 	<div class="col-xs-12" >
		 		<form class="form-inline">
				  <div class="form-group">
				    <label for="exampleInputName2">Start Date</label>
				    <input type="date" class="form-control" id="exampleInputName2" placeholder="2020-01-01" ng-model="searchConfig.startDate">
				  </div>
				  <div class="form-group">
				    <label for="exampleInputEmail2">End Date</label>
				    <input type="date" class="form-control" id="exampleInputEmail2" placeholder="2020-03-31" ng-model="searchConfig.endDate" >
				  </div>
				  <button type="submit" class="btn btn-default" ng-click="callSearch();">Search</button>
				</form>
		 		
		 		<div ng-show="searching">
					Searching...  
				</div>
		 		
		 		
		 		<div ng-repeat="outs in outcomes"  class="alert alert-warning" role="alert">{{outs.details}}</div>
				
		
		 		
		 		<table class="table table-condensed table-striped table-bordered" ng-show="meds.length > 0"> 
		 			<thead> 
		 				<tr> 
		 					<th>Dispense Date</th> 
		 					<th>Generic</th> 
		 					<th>Brand</th> 
		 					<th>Strength</th>
		 					<th>Dosage Form</th>
		 					<th>Quantity</th>
		 					<th>Est Days Supply</th>
		 					<th>Prescriber</th>
		 					<th>Prescriber #</th>
		 					<th>Pharmacy</th>
		 					<th>Pharmacy Fax</th>
		 					<th>Rx Count</th> 
						</tr> 
					</thead> 
		 			<tbody> 
		 				<tr ng-repeat="med in meds"> 
		 					<th scope="row">{{med.whenPrepared | date}}</th> 
		 					<td>{{med.genericName}}</td>
		 					<td>{{med.brandName.display}}</td>
		 					<td>{{med.dispensedDrugStrength}}</td>
		 					<td>{{med.drugDosageForm}}</td>
		 					<td>{{med.dispensedQuantity}}</td>
		 					<td>{{med.estimatedDaysSupply}}</td>
		 					<td>{{med.prescriberLastname}}, {{med.prescriberFirstname}} ({{med.prescriberLicenceNumber}})</td>
		 					<td>{{med.prescriberPhoneNumber}}</td>
		 					<td>{{med.dispensingPharmacy}}</td>
		 					<td>{{med.dispensingPharmacyFaxNumber}}</td>
		 					<td><!-- {{med | json}}  --></td> 
		 					
		 				</tr> 
		 			</tbody> 
		 		</table>
		 		

		 	</div>
	 	</div>
	 	
	 	
		
	</div>
	
	<script>
		var app = angular.module("dhdrView", ['demographicServices','providerServices','dhdrServices','oscarFilters']);
		
		app.controller("dhdrView", function($scope,demographicService,providerService,dhdrService,$location,$window) {

			console.log("$location.search()",$location.search().demographic_no);
			$scope.demographicNo = $location.search().demographic_no;
			$scope.demographic = {};
			$scope.meds = [];
			$scope.outcomes = [];
			defaultDaysToSearch = 120;
			$scope.searchConfig = {};
			$scope.searchConfig.endDate = new Date();
			$scope.searchConfig.startDate = new Date($scope.searchConfig.endDate);
			$scope.searchConfig.startDate.setDate($scope.searchConfig.endDate.getDate() - defaultDaysToSearch);
			$scope.searching = false;
			
			/*
			$scope.$watch('location.search()', function() {
				console.log("Watch called",$location.search());
		        $scope.demographicNo = ($location.search()).demographicNo;
		        getDemo();
		    }, true);
*/
			$scope.callSearch = function(){
				search($scope.demographicNo,$scope.searchConfig);
			}
		
			search = function(demographicNo,searchConfig){
				$scope.searching = true;
				dhdrService.searchByDemographicNo2(demographicNo,searchConfig).then(function(response){
					console.log("response.entry",response.entry);
					$scope.searching = false;
					$scope.meds = [];
					$scope.outcomes = [];
					for (x of  response.entry) {
						console.log("x",x);
						if(x.resource.resourceType === "OperationOutcome"){
							var o = new OperationOutcome(x);
							$scope.outcomes.push(o);
							console.log("$scope.outcomes",$scope.outcomes);
						}else if(x.resource.resourceType === "MedicationDispense"){
							var d = new MedicationDispense(x);
							console.log("d",d);
							$scope.meds.push(d);
						}
					}
					
				},function(reason){
					$scope.searching = false;
					alert(reason);
				});
			}
		
			getDemo = function(){
				demographicService.getDemographic($scope.demographicNo).then(function(response){
					$scope.demographic = response;
					search($scope.demographicNo,$scope.searchConfig);
				},function(reason){
					alert(reason);
				});
			};
			
			getDemo();
			
			
			
			
		});
		
		function OperationOutcome(operationOutcome){
			this.outcomme = operationOutcome;
			this.details = "";
			
			if(angular.isDefined(this.outcomme.resource) && angular.isDefined(this.outcomme.resource.issue)){
				this.details = this.outcomme.resource.issue[0].details.text;
			}
				
			
			
		}

		
		function MedicationDispense(medication){
			this.med = medication;
			
			this.whenPrepared = this.med.resource.whenPrepared;
			if(angular.isDefined(this.med.resource.quantity) && angular.isDefined(this.med.resource.quantity.value)){
				this.dispensedQuantity = this.med.resource.quantity.value;
			}
			if(angular.isDefined(this.med.resource.daysSupply) && angular.isDefined(this.med.resource.daysSupply.value)){
				this.estimatedDaysSupply = this.med.resource.daysSupply.value;
			}
			
			for (res of  this.med.resource.contained) {
				
				if(res.resourceType === "Medication") {
					
					if(res.code != null) {
						
						if(angular.isDefined(res.form) && angular.isDefined(res.form.text)){
							this.drugDosageForm = res.form.text	
						}
						
						if(angular.isDefined(res.extension)){
							for(ext of res.extension) {
								if("http://ehealthontario.ca/fhir/StructureDefinition/ca-on-medications-ext-medication-strength" === ext.url){
									this.dispensedDrugStrength = ext.valueString;
								}
							}
						}
				
						
						for(coding of res.code.coding) {
							//{"system": "http://hl7.org/fhir/NamingSystem/ca-hc-din","code": "01916580","display": "Hycodan"
							if("http://hl7.org/fhir/NamingSystem/ca-hc-din" === coding.system) {
								this.brandName = coding;
							}
							//"system": "http://ehealthontario.ca/fhir/NamingSystem/ca-drug-gen-name","display": "HYDROCODONE BITARTRATE"
							if("http://ehealthontario.ca/fhir/NamingSystem/ca-drug-gen-name" === coding.system) {
								this.genericName = coding.display;
							}
				            //"system": "http://ehealthontario.ca/fhir/NamingSystem/ca-on-drug-class-ahfs","code": "480000000","display": "COUGH PREPARATIONS"
				            if("http://ehealthontario.ca/fhir/NamingSystem/ca-on-drug-class-ahfs" === coding.system) {
								this.ahfsClass = coding;
							}
				            //"system": "http://ehealthontario.ca/fhir/NamingSystem/ca-on-drug-subclass-ahfs","code": "480400000","display": "ANTITUSSIVES"\
				            if("http://ehealthontario.ca/fhir/NamingSystem/ca-on-drug-subclass-ahfs" === coding.system) {
								this.ahfsSubClass = coding;
							}
				         
						}
					}else {
						logger.error("was null "+medication);
					}
				
				}else if(res.resourceType ===  "Organization") {
					this.dispensingPharmacy = res.name;
					for(tele of res.telecom){
						if("fax" === tele.system){
							this.dispensingPharmacyFaxNumber = tele.value;		
						}
					}
				}else if(res.resourceType ==="Practitioner") {
					
					for(identifier of res.identifier) {
						if("https://fhir.infoway-inforoute.ca/NamingSystem/ca-on-license-physician" === identifier.system) {
							
							this.prescriberLicenceNumber = identifier.value;
							for( humanName of res.name) {
								console.log("humanName",humanName);
								this.prescriberLastname = humanName.family;
								this.prescriberFirstname = humanName.given[0];
							}
							
							for(tele of res.telecom){
								if("phone" === tele.system){
									this.prescriberPhoneNumber = tele.value;		
								}
							}
							
							
							console.log("res for telecom ",res);
							//this.prescriberPhoneNumber = res.telecom[0].value);
						}
							
					}
				}else {
					console.log("resource.getResourceType()",res.resourceType);
				}
				
			}
			
		}
	
	</script>
	</body>
</html>	    			