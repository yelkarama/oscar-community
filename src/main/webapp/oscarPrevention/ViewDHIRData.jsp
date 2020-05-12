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
<%@page import="java.net.URLEncoder"%>
<%@page import="org.oscarehr.integration.TokenExpiredException"%>
<%@page import="org.oscarehr.integration.OneIDTokenUtils"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.Calendar"%>
<%@page import="org.apache.commons.lang3.StringUtils"%>
<%@page import="org.oscarehr.util.SpringUtils"%>
<%@page import="org.oscarehr.common.dao.DemographicDao"%>
<%@page import="org.oscarehr.common.model.Demographic"%>
<%@ taglib uri="/WEB-INF/security.tld" prefix="security"%>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html"%>
<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<security:oscarSec roleName='${ sessionScope[userrole] }, ${ sessionScope[user] }' rights="w" objectName="_prevention">
	<c:redirect url="securityError.jsp?type=_prevention" />
</security:oscarSec>

<%
	DemographicDao demographicDao = SpringUtils.getBean(DemographicDao.class);
	Demographic demographic = demographicDao.getDemographic(request.getParameter("demographic_no"));
	
	String startDate = request.getParameter("startDate");
	String endDate = request.getParameter("endDate");
	
	if(StringUtils.isEmpty(startDate)) {
		Calendar c = Calendar.getInstance();
		c.add(Calendar.DAY_OF_YEAR,-120);
		SimpleDateFormat fmt = new SimpleDateFormat("yyyy-MM-dd");
		startDate = fmt.format(c.getTime());
	}
	
	if(StringUtils.isEmpty(endDate)) {
		Calendar c = Calendar.getInstance();
		SimpleDateFormat fmt = new SimpleDateFormat("yyyy-MM-dd");
		endDate = fmt.format(c.getTime());
	}
	
	String emrStartDate = startDate;
	String emrEndDate = endDate;

	try  { 
		OneIDTokenUtils.getValidAccessToken(session);
	} catch(TokenExpiredException e) {
		response.sendRedirect(request.getContextPath() + "/eho/login2.jsp?alreadyLoggedIn=true&forwardURL=" + URLEncoder.encode(getCompleteURL(request),"UTF-8") );
		
	}
%>
<!DOCTYPE html > 
<html:html locale="true" >
<head>
<meta charset="utf-8">
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>
EMR / DHIR View
</title>
	<link rel="stylesheet" type="text/css" href="${ pageContext.request.contextPath }/library/bootstrap/3.0.0/css/bootstrap.min.css" />
 	<link rel="stylesheet" type="text/css" href="${ pageContext.request.contextPath }/library/DataTables-1.10.12/media/css/jquery.dataTables.min.css" /> 
	 <!-- <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css"> -->
	<link rel="stylesheet" href="<%=request.getContextPath() %>/css/all.min.css">
	
	<script>var ctx = "${pageContext.request.contextPath}"</script>
	<script type="text/javascript" src="${ pageContext.request.contextPath }/js/jquery-1.9.1.min.js"></script>	
	<script type="text/javascript" src="${ pageContext.request.contextPath }/library/bootstrap/3.0.0/js/bootstrap.min.js" ></script>	
	<script type="text/javascript" src="${ pageContext.request.contextPath }/library/DataTables-1.10.12/media/js/dataTables.bootstrap.min.js" ></script>
	<script type="text/javascript" src="${ pageContext.request.contextPath }/library/DataTables-1.10.12/media/js/jquery.dataTables.min.js" ></script>
	
	<script type="text/javascript" src="<%=request.getContextPath() %>/js/bootstrap-datepicker.js"></script>
	
	<link href="<%=request.getContextPath() %>/css/datepicker.css" rel="stylesheet" type="text/css">
	<link rel="stylesheet" href="<%=request.getContextPath() %>/css/font-awesome.min.css">

	<style>
	.recItem {border:2px solid black}
	#forecastByStatusTbl tbody tr {background-color:#ccffff}
	</style>
	
	<script>
	
		var hideDisclaimer = <%=(session.getAttribute("dhir.disclaimer.hide") != null && (Boolean)session.getAttribute("dhir.disclaimer.hide")) ? session.getAttribute("dhir.disclaimer.hide") : "false"  %>;

		function emptyIfNull(item) {
			if(item == null) {
				return {};
			}
			return item;
		}
		
		var renderFunc = function(data, type, row, meta) {
			//console.log("data=" +JSON.stringify(data));
			
			if(data.forecastStatus == null) {
				return "&nbsp;";
			}
			
			//console.log('cc=' + JSON.stringify(data.forecastStatus));
			var color = "";
			if(data.forecastStatus.display == "Overdue") {color = "#f2dede";};
			if(data.forecastStatus.display == "Due") {color = "#fff3cd";};
			if(data.forecastStatus.display == "Eligible but not due") {color = "#d4edda";};
			if(data.forecastStatus.display == "Up to date") {color = "#d1ecf1";};
			
			
			var renderedText = "<div class=\"recItem\" style=\"background-color:"+color+" \">";
			
			
			if(data.targetDisease != null && data.targetDisease.length>0) {
				renderedText += "<b>" + data.targetDisease + "</b>" ;
			}
			if(data.vaccineCodes != null && data.vaccineCodes.length>0) {
				renderedText += "<b>" + data.vaccineCodes[0].display + "</b>";
			}
			if(data.vaccineCodes != null && data.vaccineCodes.length>1) {
				renderedText += "<br/><b>" + data.vaccineCodes[1].display + "</b>";
			}
			if(data.date != null) {
				renderedText += "<br/>" + data.date ;
			}
			
			renderedText += "</div>";
			
			return renderedText;
		}
		
		
		$(document).ready(function(){
	
			$("#disclaimer").hide();
			
			$("#summaryTbl").DataTable({
				//orderCellsTop: true,
				//fixedHeader: true, 
				"order" : [[0,"desc"]],
				
				"columns" : [
					{"title": "Immunization Date", "data" : "immunizationDate"},
					{"title": "Valid Flag","data" : "validFlag"},
					{"title": "Agent","data" : "agent"},
					{"title": "Trade Name","data" : "tradeName"},
					{"title": "Lot Number","data" : "lotNumber"},
					{"title": "Expiration Date","data" : "expirationDate"},
					{"title": "Status","data" : "status"},
					{"title": "PHU","data" : "PHU"},
					{"title": "Performer","data" : "performerName"},
					
				],
				
				"language": {
				      "emptyTable": "No events found for the search time period."
				    }
				
			});
			
			$("#compTbl").DataTable({
				
				"columns" : [
					{"title": "Name", 			"data" : "name"},
					{"title": "Code",			"data" : "code"},
					{"title": "Type",			"data" : "type"},
					{"title": "Manufacturer",	"data" : "manufacturer"},
					{"title": "Lot Number",		"data" : "lotNumber"},
					{"title": "Route",			"data" : "route"},
					{"title": "Site",			"data" : "site"},
					{"title": "Dose",			"data" : "dose"},
					{"title": "Date",			"data" : "date"},
					{"title": "Refused",		"data" : "refused"},
					{"title": "Notes",			"data" : "notes"}
				],
				
				"language": {
				      "emptyTable": "No events found for the search time period."
				    }
				
			});
			
			
			
			
			$("#forecastByStatusTbl").DataTable({
				"columns" : [
					{"title": "Overdue","width": "25%", "render" : renderFunc },
					{"title": "Due" ,"width": "25%", "render" : renderFunc},
					{"title": "Eligible but not due","width": "25%", "render" : renderFunc},
					{"title": "Up to date","width": "25%", "render" : renderFunc }
				],
				
				"language": {
				      "emptyTable": "No forecast items."
				},
				paging: false,
				searching:false,
				info:false,
				
				"order": [],
			    "columnDefs": [ {
			      "targets"  : [0,1,2,3],
			      "orderable": false,
			    }]
				
			});
		 
			
			function getDHIRData() {
				var dt = $("#summaryTbl").DataTable();
		    	
				
				$("#dhir_loading").show();
				$("#dhirError").hide();
				$("#disclaimer").hide();
				dt.clear();
		    	$("#summaryPeriod").html("<b>Search period:</b>");
		    	
		    	var dtF = $("#forecastByStatusTbl").DataTable();
		    	dtF.clear();
		    	
				$.ajax({
					url: "<%=request.getContextPath()%>/dhir/summary.do?demographic_no=<%=demographic.getDemographicNo()%>&startDate=" + $("#startDate").val() + "&endDate=" + $("#endDate").val(),
				    type: 'GET',
				  	dataType: 'json',
				    success: function(data) {
				    	if(data.error != null) {
				    		$("#dhirError").html(data.error);
				    		$("#dhirError").show();
				    	} 
				    	if(data.immunizations != null) {
					    	var dt = $("#summaryTbl").DataTable();
					    	dt.rows.add(data.immunizations);
					    	dt.draw();
					    	
					    	$("#summaryPeriod").html("<b>Search period:</b>" + data.startDate + " - " + data.endDate);
					    	if(!hideDisclaimer) {
					    		$("#disclaimer").show();
					    	}
					    	
				    	}
				    	
				    	
				    	
				    	if(data.recommendationsByStatus != null) {
				    		var forecastByStatusTable = $("#forecastByStatusTbl").DataTable();
				    		var recs = data.recommendationsByStatus;
				    		
				    		var a1 = recs["Overdue"];
				    		var a2 = recs["Due"];
				    		var a3 = recs["Eligible but not due"];
				    		var a4 = recs["Up to date"];
				    		
				    		var maxSize = Math.max(a1.length,a2.length,a3.length,a4.length);
				    	
				    		for(var x=0;x<maxSize;x++) {
				    			var r = [emptyIfNull(a1[x]),emptyIfNull(a2[x]),emptyIfNull(a3[x]),emptyIfNull(a4[x])];
				    			console.log(r);
				    			
				    			forecastByStatusTable.rows.add([r]);
				    		}
				    		
				    		forecastByStatusTable.draw();
				    		
				    	}
				    	
				    	$("#dhir_loading").hide();
				    	
				    }, error: function() {
				    	$("#dhir_loading").hide();
				    	$("#dhirError").html("A system error occurred.");
				    }
				});
			}
			
			function getEMRData() {	
				$("#emr_loading").show();
				$("#emrError").hide();
				$("#compTbl").DataTable().clear();
				
				$.ajax({
					url: "<%=request.getContextPath()%>/dhir/summary.do?method=emrData&demographic_no=<%=demographic.getDemographicNo()%>&startDate=" + $("#emrStartDate").val() + "&endDate=" + $("#emrEndDate").val(),
				    type: 'GET',
				  //  data: param,
				  	dataType: 'json',
				    success: function(data) {
				    	var dt = $("#compTbl").DataTable();
				    	dt.clear();
				    	dt.rows.add(data.immunizations);
				    	dt.draw();
				    	
				    	$("#emr_loading").hide();
				    }
				});
			}
			
			
			
			getDHIRData();
			getEMRData();
	
			var startDate = $("#startDate").datepicker({
		        format : "yyyy-mm-dd"
		    });
		
			$("#startDate").bind('change',function(){
				getDHIRData();
			});
			$("#endDate").bind('change',function(){
				getDHIRData();
			});
			
			$("#emrStartDate").bind('change',function(){
				getEMRData();
			});
			$("#emrEndDate").bind('change',function(){
				getEMRData();
			});
		
			$('.btn').button();
			
			$('.showing').bind('change',function(){
				console.log('testing');
				if($("#showDHIR").is(":checked")) {
					$("#dhirDiv").show();
				} else {
					$("#dhirDiv").hide();
				}
				if($("#showEMR").is(":checked")) {
					$("#emrDiv").show();
				} else {
					$("#emrDiv").hide();
				}
				if($("#showForecast").is(":checked")) {
					$("#forecastDiv").show();
				} else {
					$("#forecastDiv").hide();
				}
			});
		
			$("#disclaimerDismiss").bind("click",function(){
				//update preference on server
				hideDisclaimer = true;
				
				$("#disclaimer").hide();
				
				$.ajax({
					url: "<%=request.getContextPath()%>/dhir/summary.do?method=hideDisclaimer",
				    type: 'GET',
				  	dataType: 'json',
				    success: function(data) {
				    	
				    }, error: function() {
				    	
				    }
				});
			})
		});
		
		
		function doPrint() {
			var includeEMR = $("#showEMR").is(":checked");
			var includeDHIR = $("#showDHIR").is(":checked");
			var includeForecast = $("#showForecast").is(":checked");
			
			window.location.href='<%=request.getContextPath()%>/dhir/printSummary.do?includeEMR='+includeEMR+'&includeDHIR='+includeDHIR+'&includeForecast='+includeForecast+'&demographicNo=<%=demographic.getDemographicNo()%>&startDate='+$("#startDate").val()+'&endDate='+$("#endDate").val()+'&emrStartDate='+$("#emrStartDate").val()+'&emrEndDate=' + $("#emrEndDate").val();
		}
	</script>
</head>
<body>

	<div class="container">
		<div class="row" style="margin-bottom:8px;margin-top:8px">
			<div class="col-sm-6" style="border:1px black solid;background-color:lightgray">
				<h4><%=demographic.getFormattedName() %></h4>
				<h5><%=demographic.getFormattedDob() %></h5>
				<h5><%=demographic.getHin() %> , <%=demographic.getSex() %></h5>
			</div>
			<div class="col-sm-6">
				<div class="btn-group" data-toggle="buttons">
				  <label class="btn btn-primary active">
				    <input type="checkbox" checked class="showing" id="showEMR"> EMR Immunizations
				  </label>
				  <label class="btn btn-primary active">			  
				    <input type="checkbox" checked class="showing" id="showDHIR"> DHIR Immunizations
				  </label>
				  
				  <label class="btn btn-primary active">
				    <input type="checkbox" checked class="showing" id="showForecast">Immunization Forecast
				  </label>
				  
				   <label class="btn btn-primary" onClick="doPrint()">
				    <input type="checkbox" checked class="showing" id="printDHIR">Print
				  </label>
				</div>
			</div>
		</div>
		
		<div class="row">
			<div style="background-color:#ccffeb;border: 1px black solid" id="emrDiv">
			
				<div class="col-sm-12"  style="padding-top:10px; padding-left:10px;padding-bottom:5px">
					<span class="h4"><b><u>Immunization Event(s) in EMR</u></b><br/></span>
				</div>
				
				<div class="col-sm-12">
					<div class="alert alert-danger" id="emrError" role="alert">
					</div>
				</div>
				
				<div class="col-sm-12">
					<div>
						<b>Date Range:</b> From <input type="text" name="emrStartDate" id="emrStartDate" value="<%=emrStartDate %>" /> to <input type="text" name="emrEndDate" id="emrEndDate" value="<%=emrEndDate %>"/>
						<span id="emr_loading"><i style="color:blue" class="fa fa-circle-notch fa-spin" aria-hidden="true"></i></span>
					</div>
				</div>
				
				<div class="col-sm-12">
					<table id="compTbl" class="stripe">
					
					</table>
				</div>
				
			</div>
		</div>
		
		<div class="row">
			<div class="col-sm-12" style="height:40px"></div>
		</div>
		
		<div class="row">
		<div style="background-color:#ccffff;border: 1px black solid"  id="dhirDiv">
		
			<div class="col-sm-12"  style="padding-top:10px; padding-left:10px;padding-bottom:5px">
				<span class="h4"><b><u>Immunization Event(s) from DHIR</u></b><br/></span>
			</div>
			<div class="col-sm-12">
				<div class="alert alert-danger" id="dhirError" role="alert">
				</div>
			</div>
			
			<div class="col-sm-12">
				<div>
					<b>Date Range:</b> From <input type="text" name="startDate" id="startDate" value="<%=startDate %>" /> to <input type="text" name="endDate" id="endDate" value="<%=endDate %>"/>
					<span id="dhir_loading"><i style="color:blue" class="fa fa-circle-notch fa-spin" aria-hidden="true"></i></span>
				</div>
			</div>
		
			<div class="col-sm-12">
				<table id="summaryTbl" class="stripe">
				</table>
				<div id="summaryPeriod"></div>
				<div id="disclaimer" class="alert alert-warning alert-dismissible" >
				 <button type="button" class="close" id="disclaimerDismiss"><span aria-hidden="true">&times;</span></button>
				<b>Warning:</b> Limited to Immunization Information available in the
	Digital Health Immunization Repository (DHIR) EHR service. To
	ensure a Best Possible Immunization History, please review this
	information with the patient/family and use other available sources
	of Immunization information in addition to the DHIR EHR service.</div>
			</div>
		</div>
		
		
		<div class="col-sm-12" style="height:40px"></div>
		
		
		<div style="background-color:#ccffff;border: 1px black solid"  id="forecastDiv">
			
			
			<div class="col-sm-12"  style="padding-top:10px; padding-left:10px;padding-bottom:5px">
					<span class="h4"><b><u>Immunization Forecast</u></b><br/></span>
				</div>
			<div class="col-sm-12">
			
				<table id="forecastByStatusTbl">
				
				</table>
			</div>
		
			<div class="col-sm-12" style="height:5px"></div>
		
		</div>
		</div>
		
		
		
			<div class="col-sm-12" style="height:15px"></div>
		
	</div>
</body>
</html:html>
<%!
 String getCompleteURL(HttpServletRequest request) {
	StringBuffer requestURL = request.getRequestURL();
	if (request.getQueryString() != null) {
	    requestURL.append("?").append(request.getQueryString());
	}
	String completeURL = requestURL.toString();
	
	return completeURL;
}
%>