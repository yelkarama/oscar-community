/*

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

*/

oscarApp.controller('RecordCtrl', function ($rootScope,$scope,$http,$location,$stateParams,demographicService,demo,user,$state,noteService,$timeout,$interval,uxService,securityService,scheduleService,billingService) {
	
	
	console.log("in patient Ctrl ",demo);
	console.log("in RecordCtrl state params ",$stateParams,$location.search());
	
	$scope.demographicNo = $stateParams.demographicNo;
	$scope.demographic= demo;
	$scope.page = {};
	$scope.page.assignedCMIssues = [];
	
	$scope.hideNote = false;
	
	//this doesn't actually work, hideNote is note showing up in the $stateParams
	if($stateParams.hideNote != null) {
		$scope.hideNote = $stateParams.hideNote;
	}
	/*
	$scope.recordtabs2 = [ 
	 {id : 0,name : 'Master',url : 'partials/master.html'},
	 {id : 1,name : 'Summary',url : 'partials/summary.html'},
	 {id : 2,name : 'Rx',url : 'partials/rx.jsp'},
	 {id : 3,name : 'Msg',url : 'partials/summary.html'},
	 {id : 4,name : 'Trackers',url : 'partials/tracker.jsp'},
	 {id : 5,name : 'Consults',url : 'partials/summary.html'},
	 {id : 6,name : 'Forms',url : 'partials/formview.html'},
	 {id : 7,name : 'Prevs/Measurements',url : 'partials/summary.html'},
	 {id : 8,name : 'Ticklers',url : 'partials/summary.html'},
	 {id : 9,name : 'MyOscar',url : 'partials/blank.jsp'},
	 {id : 10,name : 'Allergies',url : 'partials/summary.html'},
	 {id : 11,name : 'CPP',url : 'partials/cpp.html'},
	 {id : 12,name : 'Labs/Docs',url : 'partials/labview.html'},
	 {id : 13,name : 'Billing',url : 'partials/billing.jsp'}	
	*/
	$scope.recordtabs2 = [];
	/*
	                 	 {id : 0,displayName : 'Details'  ,path : 'record.details'},
	                 	 {id : 1,displayName : 'Summary'  ,path : 'record.summary'},
	                 	 {id : 2,displayName : 'Forms'    ,path : 'record.forms'},
	                 	 {id : 3,displayName : 'Labs/Docs',path : 'partials/eform.jsp'},
	                 	 {id : 4,displayName : 'Rx'       ,path : 'partials/eform.jsp'}];
	*/

	//get access rights
	securityService.hasRight("_eChart", "w", $scope.demographicNo).then(function(data){
		$scope.page.cannotChange = !data;
	});
	
	//disable click and keypress if user only has read-access
	$scope.checkAction = function(event){
		if ($scope.page.cannotChange) {
			event.preventDefault();
			event.stopPropagation();
		}
	}
	
	$scope.fillMenu = function(){
		uxService.menu($stateParams.demographicNo).then(function(data){
			$scope.recordtabs2 = data;
		});
	}
	
	$scope.fillMenu();
	
	//var transitionP = $state.transitionTo($scope.recordtabs2[0].path,$stateParams,{location:'replace',notify:true});
	//console.log("transition ",transitionP);
	
	$scope.changeTab = function(temp) {
		$scope.currenttab2 = $scope.recordtabs2[temp.id];
		
		if(angular.isDefined(temp.state)){
			if (/^record.consultRequests.[0-9]+$/.test(temp.state) || /^record.consultResponses.[0-9]+$/.test(temp.state)) {
				var recIdPos = temp.state.lastIndexOf(".");
				$state.go(temp.state.substring(0, recIdPos), {demographicNo:temp.state.substring(recIdPos+1)});
			} else {
				$state.go(temp.state);
			}
		}else if(angular.isDefined(temp.url)){
			if(temp.label=="Rx"){
				win = temp.label+$scope.demographicNo;
			}else{
				var rnd = Math.round(Math.random() * 1000);
				win = "win" + rnd;
			}
			window.open(temp.url,win,"scrollbars=yes, location=no, width=1000, height=600","");   
		}
		//console.log($scope.recordtabs2[temp].path);
		
		
	}
	
	$scope.isTabActive = function(tab){
		//console.log('current state '+$state.current.name.substring(0,tab.path.length)+" -- "+($state.current.name.substring(0,tab.path.length) == tab.path),$state.current.name,tab);
		//console.log('ddd '+$state.current.name.length+"  eee "+tab.path.length);
		//if($state.current.name.length < tab.path.length) return "";
	
		if(tab.dropdown){
			return "dropdown";
		}
		
		if(tab.state != null && ($state.current.name.substring(0,tab.state.length) == tab.state)){
			return "active";
		}
		
	}
	
	$scope.$on('$destroy', function(){
		console.log("save the last note!!",$scope.page.encounterNote,noteDirty);
		if(noteDirty){
			noteService.tmpSave($stateParams.demographicNo,$scope.page.encounterNote);
		}
		
	});
	
	//////AutoSave
	var saveIntervalSeconds = 2;

	var timeout = null;
	var saveUpdates = function() {
	    console.log("save",$scope.page.encounterNote);
	    noteService.tmpSave($stateParams.demographicNo,$scope.page.encounterNote); 
	};
	var skipTmpSave = false;
	var noteDirty = false;
	
	var delayTmpSave = function(newVal, oldVal) {
		console.log("whats the val ",(newVal != oldVal));
		if(!skipTmpSave){
		    if (newVal != oldVal) {
		    	noteDirty = true;
		      if (timeout) {
		        $timeout.cancel(timeout);
		      }
		      timeout = $timeout(saveUpdates, saveIntervalSeconds * 1000);
		    }else{
		    	noteDirty= false;
		    }
		}
		skipTmpSave = false; // only skip once
	  };
	$scope.$watch('page.encounterNote.note', delayTmpSave);
	
	//////
	
	
	
	
		
	// Note Input Logic
	$scope.toggleNote = function() {
		if ($scope.hideNote == true) {
			$scope.hideNote = false;
		} else {
			$scope.hideNote = true;
		}
	};

		
	$scope.saveNote = function(){
		console.log("This is the note"+$scope.page.encounterNote);
		$scope.page.encounterNote.observationDate = new Date(); 
		$scope.page.encounterNote.assignedIssues = $scope.page.assignedCMIssues;
		noteService.saveNote($stateParams.demographicNo,$scope.page.encounterNote).then(function(data) {
			$rootScope.$emit('noteSaved',data);
			skipTmpSave = true;
			$scope.page.encounterNote = data;
			console.debug('whats the index',data);
			if($scope.page.encounterNote.isSigned){
				$scope.hideNote = false;
				$scope.getCurrentNote(false);
			}
	    });
		$scope.removeEditingNoteFlag();
	};
	
	$scope.saveSignNote = function(){
		$scope.page.encounterNote.isSigned = true;
		$scope.saveNote() ;
	}
	
	$scope.saveSignVerifyNote = function(){
		$scope.page.encounterNote.isVerified = true;
		$scope.page.encounterNote.isSigned = true;
		$scope.saveNote() ;
	}
	
	billingService.getBillingRegion().then(function(response){
		$scope.page.billregion = response.message;
	});
	billingService.getDefaultView().then(function(response){
		$scope.page.defaultView = response.message;
	});
	if ($location.search().appointmentNo!=null){
		scheduleService.getAppointment($location.search().appointmentNo).then(function(data){
			$scope.page.appointment = data;
		});
	}
	
	$scope.saveSignBillNote = function(){
		$scope.page.encounterNote.isSigned = true;
		$scope.saveNote() ;

		noteService.getIssueNote($scope.page.encounterNote.noteId).then(function(data){
			var issues = toArray(data.assignedCMIssues);
			var dxCode = "";
			for (var i=0; i<issues.length; i++){
				dxCode += "&dxCode="+issues[i].issue.code.substring(0,3);
			}
			
			var apptNo = "", apptProvider = "", apptDate = "", apptStartTime = "";
			if ($scope.page.appointment!=null){
				apptNo = $scope.page.appointment.id;
				apptProvider = $scope.page.appointment.providerNo;
				
				var dt = new Date($scope.page.appointment.appointmentDate);
				apptDate = dt.getFullYear()+"-"+zero(dt.getMonth()+1)+"-"+zero(dt.getDate());
				dt = new Date($scope.page.appointment.startTime);
				apptStartTime = zero(dt.getHours())+":"+zero(dt.getMinutes())+":"+zero(dt.getSeconds());
			}
			
			var url = "../billing.do?billRegion="+$scope.page.billregion;
			url += "&billForm="+$scope.page.defaultView;
			url += "&demographic_name="+demo.firstName+"+"+demo.lastName;
			url += "&demographic_no="+demo.demographicNo;
			url += "&providerview="+user.providerNo+"&user_no="+user.providerNo;
			url += "&appointment_no="+apptNo+"&apptProvider_no="+apptProvider;
			url += "&appointment_date="+apptDate+"&start_time="+apptStartTime;
			url += "&hotclick=&status=t&bNewForm=1"+dxCode;

			window.open(url,"billingWin","scrollbars=yes, location=no, width=1000, height=600","");
		});
	}
	
	
	console.log('RecordCtrlEnd',$state);
	
	$scope.page.currentNoteConfig = {};


	$scope.getCurrentNote = function(showNoteAfterLoadingFlag) {
		noteService.getCurrentNote($stateParams.demographicNo,$location.search()).then(function(data) {
			$scope.page.encounterNote = data;
			console.log($scope.page.encounterNote );
			//$scope.hideNote = true;
			$scope.hideNote = showNoteAfterLoadingFlag;
			$rootScope.$emit('currentlyEditingNote',$scope.page.encounterNote);
	    });
	};
	
	$scope.getCurrentNote(true);
	
	
	
	 $scope.editNote = function(note){
	    	$rootScope.$emit('',note);
	 }
	 
	 $rootScope.$on('loadNoteForEdit', function(event,data) {
	    	console.log('loadNoteForEdit ',data);
	    	$scope.page.encounterNote = data;
	    	
	    	//Need to check if note has been saved yet.
	    	$scope.hideNote = true;
	    	$rootScope.$emit('currentlyEditingNote',$scope.page.encounterNote);
	    	
	    	$scope.removeEditingNoteFlag();
	 });
	
	 
	 /*
	  * handle concurrent note edit - EditingNoteFlag
	  */
	 var itvSet = null;
	 var itvCheck = null;
	 var editingNoteId = null;
	 
	 $rootScope.$on("$stateChangeStart", function(){
		 $scope.removeEditingNoteFlag();
	 });
	 
	 $scope.doSetEditingNoteFlag = function(){
		 noteService.setEditingNoteFlag(editingNoteId, user.providerNo).then(function(resp){
			 if (!resp.success) {
				 if (resp.message=="Parameter error") alert("Parameter Error: noteUUID["+editingNoteId+"] userId["+user.providerNo+"]");
				 else alert("Warning! Another user is editing this note now.");
			 }
		 });
	 }
	 
	 $scope.setEditingNoteFlag = function(){
		 if ($scope.page.encounterNote.uuid==null) return;
		 
		 editingNoteId = $scope.page.encounterNote.uuid;
		 if (itvSet==null) {
			 itvSet = $interval($scope.doSetEditingNoteFlag(), 30000); //set flag every 5 min until canceled
		 }
		 if (itvCheck==null) { //warn once only when the 1st time another user tries to edit this note
			 itvCheck = $interval(function(){
				 noteService.checkEditNoteNew(editingNoteId, user.providerNo).then(function(resp){
					 if (!resp.success) { //someone else wants to edit this note
						 alert("Warning! Another user tries to edit this note. Your update may be replaced by later revision(s).");
						 $interval.cancel(itvCheck);
						 itvCheck = null;
					 }
				 });
			 }, 10000); //check for new edit every 10 seconds
		 }
	 }
	 
	 $scope.removeEditingNoteFlag = function(){
		 if (editingNoteId!=null) {
			 noteService.removeEditingNoteFlag(editingNoteId, user.providerNo);
			 $interval.cancel(itvSet);
			 $interval.cancel(itvCheck);
			 itvSet = null;
			 itvCheck = null;
			 editingNoteId = null;
		 }
	 }

	 
	 $scope.searchTemplates  = function(term) {
	    	var search = {name:term};
	    	
	    	return uxService.searchTemplates(search,0,25).then(function(response){
	    		var resp = [];
	    		for(var x=0;x<response.templates.length;x++) {
	    			resp.push({encounterTemplateName:response.templates[x].encounterTemplateName});
	    		}
	    		return resp;
	    	});
	 }
	 
	 $scope.insertTemplate = function(item, model, label) {
		 
		 uxService.getTemplate({name:model}).then(function(data){
			 if(data.templates != null) {
//				 $scope.page.encounterNote.note = $scope.page.encounterNote.note + "\n\n" + data.templates.encounterTemplateValue;
				 $scope.page.encounterNote.note = $scope.page.encounterNote.note + data.templates.encounterTemplateValue;
				 $scope.options= {magicVal:''};
			 }
			
		 });
	 }
	 
	    $scope.searchIssues  = function(term) {
	    	var search = {'term':term};
	    	return noteService.searchIssues(search,0,100).then(function(response){
	    		var resp = [];
	    		for(var x=0;x<response.content.length;x++) {
	    			resp.push({issueId:response.content[x].id,code: response.content[x].description + '(' + response.content[x].code + ')'});
	    		}
	    		if(response.total > response.content.length) {
	    			//warn user there's more results somehow?
	    		}
	    		return resp;
	    	});
	    }
	    
	    $scope.assignIssue = function(item, model, label) {
	    	for(var x=0;x<$scope.page.assignedCMIssues.length;x++) {
	    		if($scope.page.assignedCMIssues[x].issue.id == model) {
	    			return;
	    		}
	    	}
	    	
	    	noteService.getIssue(model).then(function(response){
	    		var cmIssue = {acute:false,certain:false,issue:response,issue_id:item.issueId,major:false,resolved:false,unsaved:true};
	        	$scope.page.assignedCMIssues.push(cmIssue);
	    	});
	    }
	    
		$scope.removeIssue = function(i) {
			i.unchecked=true;
			var newList = [];
			for(var x=0;x<$scope.page.assignedCMIssues.length;x++) {
				if(!$scope.page.assignedCMIssues[x].issue_id == i.issue_id) {
					newList.push($scope.page.assignedCMIssues[x]);
				}
			}
			$scope.page.assignedCMIssues = newList;
		}
		

});

function toArray(obj){ //convert single object to array
	if (obj instanceof Array) return obj;
	if (obj==null) return [];
	return [obj];
}

function zero(n){
	if (n<10) n = "0"+n;
	return n;
}