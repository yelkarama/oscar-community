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
	<script type="text/javascript" src="<%=request.getContextPath() %>/library/ui-bootstrap-tpls-0.11.0.js"></script>
	<script src="<%=request.getContextPath() %>/web/common/demographicServices.js"></script>	
	<script src="<%=request.getContextPath() %>/web/common/providerServices.js"></script>	
	<script src="<%=request.getContextPath() %>/web/common/dhdrServices.js"></script>	
	<script src="<%=request.getContextPath() %>/web/filters.js"></script>
	
</head>

<body vlink="#0000FF" class="BodyStyle">
	<div ng-controller="dhdrView">
	<div class="page-header" style="margin-top: 0px; margin-bottom: 0px;">
		<h1 class="patientHeaderName" style="margin-top: 0px;" ng-cloak>
			<b>{{demographic.lastName}}, {{demographic.firstName}}</b>  <span ng-show="demographic.hin">({{demographic.hin}})</span> 
			
			<small class="patientHeaderExt pull-right"> 
				<i><bean:message key="demographic.patient.context.born"/>: </i>
				<b>{{demographic.dobYear}}-{{demographic.dobMonth}}-{{demographic.dobDay}}</b> (<b>{{demographic.age | age}}</b>) &nbsp;&nbsp; <i><bean:message key="demographic.patient.context.sex"/>:</i> <b>{{demographic.sex}}</b>
				<i> &nbsp;&nbsp; <bean:message key="Appointment.msgTelephone"/>:</i> <b>{{demographic.phone}}</b> 
				<!-- <span class="glyphicon glyphicon-new-window"></span>-->
			</small>
		</h1>
	</div>
	<div class="container">
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
				  <button type="submit" class="btn btn-default" ng-click="callSearch();" style="vertical-align: bottom;">Search</button>
				</form>
		 		
		 	</div>
		 	<div class="col-xs-12" >
		 		<div ng-show="searching">
					Searching...  
				</div>
		 		
		 		
		 		<div ng-repeat="outs in outcomes" >
		 			<div ng-repeat="issue in outs.issues"  class="alert" ng-class="issueClass(issue)" role="alert">
		 				{{issue.details.text}}
		 				<button ng-if="issue.code === 'suppressed'" type="button" class="btn btn-danger" ng-click="callConsentBlock();">Temporary Consent Unblock</button>
		 			</div>
		 		</div>
				
		
		 		
		 		<table class="table table-condensed table-striped table-bordered" ng-show="meds.length > 0"> 
		 			<caption>
		 			<div><i>Warning: Limited to Drug and Pharmacy Service Information available in the Digital Health Drug Repository (DHDR) EHR Service. To ensure a Best Possible Medication History, please review this information with the patient/family and use other available sources of medication information in addition to the DHDR EHR Service. For more details on the information available in the DHDR EHR Service, please click <a href="http://www.forms.ssb.gov.on.ca/mbs/ssb/forms/ssbforms.nsf/GetFileAttach/014- 5056-87E~1/$File/5056-87E.pdf" target="_blank">http://www.forms.ssb.gov.on.ca/mbs/ssb/forms/ssbforms.nsf/GetFileAttach/014- 5056-87E~1/$File/5056-87E.pdf</a></i></div>
		 			</caption>
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
		 				<tr ng-repeat="med in meds" ng-hide="med.hide"> 
		 					<th scope="row">{{med.whenPrepared | date}}</th> 
		 					<td ng-click="getDetailView(med);">{{med.genericName}}</td>
		 					<td>{{med.brandName.display}}</td>
		 					<td>{{med.dispensedDrugStrength}}</td>
		 					<td>{{med.drugDosageForm}}</td>
		 					<td>{{med.dispensedQuantity}}</td>
		 					<td>{{med.estimatedDaysSupply}}</td>
		 					<td>{{med.prescriberLastname}}, {{med.prescriberFirstname}} ({{med.prescriberLicenceNumber.value}})</td>
		 					<td>{{med.prescriberPhoneNumber}}</td>
		 					<td>{{med.dispensingPharmacy}}</td>
		 					<td>{{med.dispensingPharmacyFaxNumber}}</td>
		 					<td ng-click="showGroupedMeds(med)">{{medsWithGroupedDups[med.getUniqVal()].length}}<!-- {{med | json}}  --></td> 
		 					
		 				</tr> 
		 			</tbody> 
		 		</table>
		 		

		 	</div>
	 	</div>
	 	
	 	
		</div> <!-- container -->
	</div>
	<script type="text/ng-template" id="myModalContent.html">
        <div class="modal-header">
            <h3 class="modal-title" id="modal-title">{{med.genericName}} - {{med.whenPrepared | date}}</h3>
        </div>
        <div class="modal-body" id="modal-body">
            <div class="md-dialog-content" id="dialogContentApptProvider">
            
            <div class="row">
                <div class="col-xs-11">



                    <table class="table table-bordered table striped" >
                       
						<tr> 
		 					<th>Dispense Date</th> 
							<th scope="row">{{med.whenPrepared | date}}</th>
						</tr>
						<tr>
		 					<th>Generic</th> 
							<td>{{med.genericName}}</td>
</tr>
						<tr>
		 					<th>Brand</th>
							<td>{{med.brandName.display}}</td>
 </tr>
						<tr>
		 					<th>DIN/PIN</th>
							<td>{{med.brandName.code}}</td>
 						</tr>
						<tr>
		 					<th>Therapeutic Class</th>
							<td>{{med.ahfsClass.display}}</td>
 						</tr>
						<tr>
		 					<th>Therapeutic Sub-Class</th>
							<td>{{med.ahfsSubClass.display}}</td>
 						</tr>
						<tr>
		 					<th>Rx Number</th>
							<td>{{med.rxNumber}}</td>
 						</tr>
						<tr>
							<th>Medical Condition/Reason for Use</th>
							<td>
								<div ng-repeat="rcode in med.reasonCode">
									<div ng-repeat="reason in rcode">({{reason.code}}) -- {{reason.display}}</div>
								</div>
							</td>
						</tr>

						<tr>
		 					<th>Strength</th>	
							<td>{{med.dispensedDrugStrength}}</td>
						</tr>
						<tr>
		 					<th>Dosage Form</th>
							<td>{{med.drugDosageForm}}</td>
						</tr>
						<tr>		 					

							<th>Quantity</th>
							<td>{{med.dispensedQuantity}}</td>
						</tr>
						<tr>
		 					<th>Est Days Supply</th>
							<td>{{med.estimatedDaysSupply}}</td>
						</tr>
						<tr>
		 					<th>Prescriber</th>
							<td>{{med.prescriberLastname}}, {{med.prescriberFirstname}} ({{med.prescriberLicenceNumber.value}})</td>
						</tr>
						<tr>
						<tr>
		 					<th>Prescriber ID</th>
							<td> {{med.prescriberLicenceNumber.system}} ({{med.prescriberLicenceNumber.value}})</td>
						</tr>
						<tr>
		 					<th>Prescriber #</th>
							<td>{{med.prescriberPhoneNumber}}</td>
						</tr>	
						<tr>
		 					<th>Pharmacy</th>
							<td>{{med.dispensingPharmacy}}</td>
						</tr>
						<tr>
		 					<th>Pharmacy Fax</th>
							<td>{{med.dispensingPharmacyFaxNumber}}</td>
						</tr> 
						<tr>
		 					<th>Pharmacy Phone</th>
							<td>{{med.dispensingPharmacyPhoneNumber}}</td> 
						</tr> 
						<tr>
							<th>Pharmacist</th>
							<td>{{med.pharmacistLastname}}, {{med.pharmacistFirstname}} ({{med.pharmacistLicenceNumber.value}})
						</tr>
					
<!-- tr>
<td colspan=2>
<pre>{{med}}</pre>
</td>
</tr -->
                        
                    </table>
                </div>
            </div>
        </div>
        </div>
        <div class="modal-footer">
            <button class="btn btn-primary" type="button" ng-click="saveManageApptProvider()">Save</button>
            <button class="btn btn-warning" type="button" ng-click="cancel()">Cancel</button>
        </div>
    </script>
    <script type="text/ng-template" id="pcoi.html">
<div class="modal-body" id="modal-body">
		<iframe id="pcoi-frame" src="{{pcoiUrl}}" sandbox="allow-forms allow-scripts allow-same-origin allow-modals"  width="540" height="600"></iframe>
<div>
	</script>
	<script>
		var app = angular.module("dhdrView", ['demographicServices','providerServices','dhdrServices','oscarFilters','ui.bootstrap']);
		
		app.controller("dhdrView", function($scope,demographicService,providerService,dhdrService,$location,$window,$modal) {

			console.log("$location.search()",$location.search().demographic_no);
			$scope.demographicNo = $location.search().demographic_no;
			$scope.demographic = {};
			$scope.meds = [];
			$scope.outcomes = [];
			defaultDaysToSearch = 1420;
			$scope.searchConfig = {};
			$scope.searchConfig.endDate = new Date();
			$scope.searchConfig.startDate = new Date($scope.searchConfig.endDate);
			$scope.searchConfig.startDate.setDate($scope.searchConfig.endDate.getDate() - defaultDaysToSearch);
			$scope.searching = false;
			
			$scope.medsWithGroupedDups = [];
			
			
			$scope.issueClass = function(issue){
				if(issue.severity === "warning"){
					return "alert-danger";
				}
				return "alert-warning";
			}
			
			
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
			
			$scope.showGroupedMeds = function(med) {
				hiddenGroup = $scope.medsWithGroupedDups[med.getUniqVal()];
				console.log("hiddenGroup",hiddenGroup);
				for (x of  hiddenGroup) {
					x.hide = false;
				}
				console.log("hiddenGroup2",hiddenGroup);
			}
		
			search = function(demographicNo,searchConfig){
				$scope.searching = true;
				dhdrService.searchByDemographicNo2(demographicNo,searchConfig).then(function(response){
					console.log("response.entry",response.entry);
					$scope.searching = false;
					$scope.meds = [];
					$scope.outcomes = [];
					$scope.medsWithGroupedDups = [];
					for (x of  response.entry) {
						console.log("x",x);
						if(x.resource.resourceType === "OperationOutcome"){
							var o = new OperationOutcome(x);
							$scope.outcomes.push(o);
							console.log("$scope.outcomes",$scope.outcomes);
						}else if(x.resource.resourceType === "MedicationDispense"){
							var d = new MedicationDispense(x);
							console.log("d",d,d.getUniqVal());
							$scope.meds.push(d);
							console.log("d.getUniqVal()",d.getUniqVal(),$scope.medsWithGroupedDups[d.getUniqVal()]);
							
							//if ($scope.medsWithGroupedDups.indexOf(d.getUniqVal()) === -1) {
							if($scope.medsWithGroupedDups[d.getUniqVal()] === undefined){
								$scope.medsWithGroupedDups[d.getUniqVal()] = [];
								$scope.medsWithGroupedDups[d.getUniqVal()].push(d);
							}else{
								console.log("found ",d.getUniqVal(),$scope.medsWithGroupedDups[d.getUniqVal()]);
								d.hide = true;
								$scope.medsWithGroupedDups[d.getUniqVal()].push(d);
							}
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
			
			$scope.getDetailView = function(med,$event){
			    
	    		    var modalInstance = $modal.open({
	    		      
	    		      templateUrl: 'myModalContent.html',
	    		      controller: 'ModalInstanceCtrl',
	    		      controllerAs: 'mpa',
	    		      parent: angular.element(document.body),
	    		      size: 'lg',
	    		      appendTo: $event,
	    		      resolve: {
	    		    	  	
	    		    	  		med: function () {
	    		          		return med;
	    		        		}
	    		      }
	    		    });

	    		    modalInstance.result.then(function (selectedItem) {
	    		      selected = selectedItem;
	    		    }, function () {
	    		      console.log('Modal dismissed at: ' + new Date());
	    		    });
    		  };
	    	
			
    		  $scope.callConsentBlock = function($event){
    				console.log("callConsentBlock");	 
    				dhdrService.getConsentOveride($scope.demographicNo).then(function(response){
    					console.log("response.referenceURL",response);
    					var med = response;
    					var modalInstance = $modal.open({
    		    		      
    		    		      templateUrl: 'pcoi.html',
    		    		      controller: 'PcoiInstanceCtrl',
    		    		      controllerAs: 'mpcoi',
    		    		      parent: angular.element(document.body),
    		    		      size: 'lg',
    		    		      appendTo: $event,
    		    		      resolve: {
    		    		    	  	
    		    		    	  		med: function () {
    		    		          		return med;
    		    		        		}
    		    		      }
    		    		    });
    					//pcoi message back 
    					//message { target: Window, isTrusted: true, data: "{\"status\":\"completed\"}", origin: "https://pcoi-pst.apps.dev.ehealthontario.ca", lastEventId: "", source: Restricted https://pcoi-pst.apps.dev.ehealthontario.ca/main, ports: Restricted, srcElement: Window, currentTarget: Window, eventPhase: 2,  }
    					modalInstance.result.then(function (selectedItem) {
    						$scope.callSearch();
    		    		    }, function () {
    		    		      console.log('Modal dismissed at: ' + new Date());
    		    		    });
    					
    				},function(reason){
    					alert(reason);
    				});
    				
    		  }
	
			
			
			
		});
		
		function OperationOutcome(operationOutcome){
			this.outcomme = operationOutcome;
			this.issues = [];
			
			if(angular.isDefined(this.outcomme.resource) && angular.isDefined(this.outcomme.resource.issue)){
				this.issues = this.outcomme.resource.issue;
			}
				
			
			
		}

		
		function MedicationDispense(medication){
			this.med = medication;
			this.hide = false;
			
			/* uniq value
			 a) Generic name of the dispensed drug [Medication.code.coding[2].display]
			 b) Dispensed drug strength [Medication.extension[1].valueString]
			 c) Drug dosage form (e.g., tablet, capsule, injection) [Medication.form.coding.display]
			*/
			this.getUniqVal = function(){
				 return this.genericName+":"+this.dispensedDrugStrength+":"+this.drugDosageForm;
			 }
			 
			 /*
<pre>

Prescriber Information
g) Prescriber ID (e.g., practitioner license or CPSO number) [Practitioner.identifier.value]
h) ID Reference [Practitioner.identifier.system]
Pharmacy Information
i) Pharmacist Name [Practitioner.name.given] [Practitioner.name.family]
j) Pharmacy Phone Number [Organization.telecom[1].value]
</pre>
			 
			 */
			
			if(angular.isDefined(this.med.resource.identifier)){
				for (ident of  this.med.resource.identifier) {
					if(angular.isDefined(ident.value)){
						this.rxNumber = ident.value;			
					}
				}				
			} 
			 
			this.whenPrepared = this.med.resource.whenPrepared;
			if(angular.isDefined(this.med.resource.quantity) && angular.isDefined(this.med.resource.quantity.value)){
				this.dispensedQuantity = this.med.resource.quantity.value;
			}
			if(angular.isDefined(this.med.resource.daysSupply) && angular.isDefined(this.med.resource.daysSupply.value)){
				this.estimatedDaysSupply = this.med.resource.daysSupply.value;
			}
			if(angular.isDefined(this.med.resource.reasonCode)){
				this.reasonCode = this.med.resource.reasonCode;
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
						if("PHONE" === tele.system){
							this.dispensingPharmacyPhoneNumber = tele.value;		
						}

					}
				}else if(res.resourceType ===  "MedicationRequest") {
					this.reasonCode = [];
					console.log("reasonCode",res.reasonCode);
					if(angular.isDefined(res.reasonCode)){
						for(code of res.reasonCode){	
							this.reasonCode = code;
						}
					}	
				}else if(res.resourceType ==="Practitioner") {
					
					for(identifier of res.identifier) {
						if("https://fhir.infoway-inforoute.ca/NamingSystem/ca-on-license-physician" === identifier.system) {
							/* Does this have a different system value if it's a CPSO value?
							Prescriber Information
							g) Prescriber ID (e.g., practitioner license or CPSO number) [Practitioner.identifier.value]
				h) ID Reference [Practitioner.identifier.system]

							*/							
							this.prescriberLicenceNumber = identifier;
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
						}else if("https://fhir.infoway-inforoute.ca/NamingSystem/ca-on-license-pharmacist" === identifier.system) {
							this.pharmacistLicenceNumber = identifier;
							for( humanName of res.name) {
								console.log("humanName",humanName);
								this.pharmacistLastname = humanName.family;
								this.pharmacistFirstname = humanName.given[0];
							}
							
						}else{
							console.log(" not processing "+identifier,res);
						}
							
					}
				}else {
					console.log("resource.getResourceType()",res.resourceType);
				}
				
			}
			
		}
			
		app.controller('ModalInstanceCtrl', function ModalInstanceCtrl($scope, $modal, $modalInstance,med){
			$scope.med = med;
			console.log("ModalInstanceCtrl",med);
		});
		
		app.controller('PcoiInstanceCtrl', function ModalInstanceCtrl($scope, $modal, $modalInstance,med,$sce,$window){
			
			$window.addEventListener('message', function(e) {

		        console.log("pcoi message back",e);
		    		$modalInstance.close(e);	

		    });
			
			$scope.med = med;
			$scope.pcoiUrl = $sce.trustAsResourceUrl(med.referenceURL);
			console.log("PcoiInstanceCtrl",med);
		});
	
	</script>
	</body>
</html>	    			