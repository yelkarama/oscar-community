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

<div class="col-lg-3">		
	<ul class="nav nav-tabs nav-justified">
		<li ng-repeat="list in page.formlists" ng-class="getListClass(list.id)" class="hand-hover"><a ng-click="changeTo(list.id)">{{list.label}}</a></li>
		
		<li class="dropdown">
		    <a class="dropdown-toggle" data-toggle="dropdown" href="#">
		      <span class="glyphicon glyphicon-tasks"> </span>
		    </a>
		    <ul class="dropdown-menu">		
			  <li ng-show="hasAdminAccess"><a class="hand-hover" onclick="popup(600, 1200, '../administration/?show=Forms', 'manageeforms')" >Manage eForms</a></li>
		      <li ng-show="hasAdminAccess"><a class="hand-hover" onclick="popup(600, 1200, '../administration/?show=Forms&load=Groups', 'editGroups')" >Edit Groups</a></li>
		      <li ng-show="hasAdminAccess" class="divider"></li>
		    </ul>
		</li>
	</ul> 	
	<%--
	<fieldset >
	       		<legend style="margin-bottom:0px;">All Forms</legend>
	       		<input type="search" class="form-control" placeholder="Filter" ng-model="filterFormsQ">
	        	<ul style="padding-left:12px;">
	        	<li ng-repeat="item in page.currentFormList[page.currentlistId] | filter:filterFormsQ"   ><a ng-click="viewForm(item.id)">{{item.label}}<small ng-show="item.type">({{item.type}})</small></a> <span class="pull-right">{{item.date}}</span></li> 
	        	</ul>
	</fieldset>   
	 --%>
	<div class="panel panel-success"> 
	  	<!-- Default panel contents -->
	  	   <input type="search" class="form-control" placeholder="Filter" ng-model="filterFormsQ">
	  	   <ul class="list-group" tabindex="0" ng-keypress="keypress($event)">
   				<li class="list-group-item" ng-repeat="item in page.currentFormList[page.currentlistId] | filter:filterFormsQ" ng-class="getActiveFormClass(item)">
   					<div class="form-name-date"><a class="list-group-item-text hand-hover" title="{{item.subject}}" ng-click="viewFormState(item,1)">{{item.name}}</a> <br><span ng-show="item.date" ><small>{{item.date | date : 'd-MMM-y'}}</small></span></div>  <a class="list-group-item-text hand-hover pull-right" ng-click="viewFormState(item,2)"><span class="glyphicon glyphicon-new-window"></span></a>
   				</li>

   				<li class="list-group-item" ng-repeat="formItem2 in page.encounterFormlist[page.currentlistId] | filter:filterFormsQ" ng-hide="page.currentlistId==1">
   					<div class="form-name-date"><a class="list-group-item-text hand-hover" ng-click="viewFormState(formItem2,1)">{{formItem2.name}}</a></div> <a class="list-group-item-text hand-hover pull-right" ng-click="viewFormState(formItem2,2)"><span class="glyphicon glyphicon-new-window"></span></a>
   				</li>
   				
   				<li class="list-group-item" ng-repeat="formItem in page.encounterFormlist[page.currentlistId] | filter:filterFormsQ" ng-hide="page.currentlistId==0">
   					<div class="form-name-date"><a class="list-group-item-text hand-hover" ng-click="viewFormState(formItem,1)">{{formItem.formName}}</a> <br><span ng-show="formItem.date"><small>{{formItem.date | date : 'd-MMM-y'}}</small></span></div>  <a class="list-group-item-text hand-hover pull-right" ng-click="viewFormState(formItem,2)"><span class="glyphicon glyphicon-new-window"></span></a>
   				</li>
   				
   			</ul>
	</div>
</div>
<div class="col-lg-9">
	<div id="formInViewFrame"></div>
</div>