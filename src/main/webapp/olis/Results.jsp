<%--

    Copyright (c) 2008-2012 Indivica Inc.

    This software is made available under the terms of the
    GNU General Public License, Version 2, 1991 (GPLv2).
    License details are available via "indivica.ca/gplv2"
    and "gnu.org/licenses/gpl-2.0.html".

--%>
<%@page import="org.oscarehr.olis.model.OLISRequestNomenclature"%>
<%@page import="org.oscarehr.olis.dao.OLISRequestNomenclatureDao"%>
<%@ page language="java" contentType="text/html;" %>
<%@page import="com.indivica.olis.queries.*,org.oscarehr.olis.OLISSearchAction,java.util.*,oscar.oscarLab.ca.all.parsers.Factory, oscar.oscarLab.ca.all.parsers.OLISHL7Handler, oscar.oscarLab.ca.all.parsers.OLISHL7Handler.OLISError, org.oscarehr.olis.OLISResultsAction, org.oscarehr.util.SpringUtils" %>
<%@page import="org.oscarehr.util.MiscUtils" %>
	
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<script type="text/javascript" src="<%= request.getContextPath() %>/js/global.js"></script>
<script type="text/javascript" src="<%=request.getContextPath()%>/js/jquery.js"></script>
<script type="text/javascript">
    jQuery.noConflict();
</script>
<link rel="stylesheet" type="text/css" href="<%=request.getContextPath()%>/share/css/OscarStandardLayout.css">
<script type="text/javascript" src="<%=request.getContextPath()%>/share/javascript/Oscar.js"></script>
<script type="text/javascript" src="<%=request.getContextPath()%>/share/javascript/oscarMDSIndex.js"></script>
<script type="text/javascript" src="<%=request.getContextPath()%>/share/javascript/sortable.js"></script>
	
<script type="text/javascript">
image_path = '<%=request.getContextPath()%>/images/';
image_up = 'arrow_up.png';
image_down = 'arrow_down.png';
image_none = 'arrow_off.png';


function addToInbox(uuid) {
	jQuery(uuid).attr("disabled", "disabled");
	jQuery.ajax({
		url: "<%=request.getContextPath() %>/olis/AddToInbox.do",
		data: "uuid=" + uuid,
		success: function(data) {
			jQuery("#" + uuid + "_result").html(data);
		}
	});
}
function preview(uuid) {
	reportWindow('<%=request.getContextPath()%>/lab/CA/ALL/labDisplayOLIS.jsp?segmentID=0&preview=true&uuid=' + uuid);
}

function save(uuid) {
	jQuery(uuid).attr("disabled", "disabled");
	jQuery.ajax({
		url: "<%=request.getContextPath() %>/olis/AddToInbox.do",
		data: "uuid=" + uuid + "&file=true",
		success: function(data) {
			jQuery("#" + uuid + "_result").html(data);
		}
	});
}

function ack(uuid) {
	jQuery(uuid).attr("disabled", "disabled");
	jQuery.ajax({
		url: "<%=request.getContextPath() %>/olis/AddToInbox.do?ack=true",
		data: "uuid=" + uuid + "&ack=true",
		success: function(data) {
			jQuery("#" + uuid + "_result").html(data);
		}
	});
}

var patientFilter = "";
var labFilter = "";
var hcnFilter = "";
var categoryFilter = "";
var performingLabFilter = "";
var abnormalFilter = "";
var testRequestCodeFilter = "";
var testRequestStatusFilter = "";
var resultStatusFilter = "";

function filterResults(select) {
	if (select.name == "labFilter") {
		labFilter = select.value;
	} else if(select.name == "patientFilter") {
		patientFilter = select.value;
	} else if(select.name == "hcnFilter") {
		hcnFilter = select.value;
	} else if(select.name == "categoryFilter") {
		categoryFilter = select.value;
	} else if(select.name == "performingLabFilter") {
		performingLabFilter = select.value;
	} else if(select.name == "abnormalFilter") {
		abnormalFilter = select.value;
	}  else if(select.name == "testRequestCodeFilter") {
		testRequestCodeFilter = select.value;
	} else if(select.name == "testRequestStatusFilter") {
		testRequestStatusFilter = select.value;
	} else if(select.name == "resultStatusFilter") {
		resultStatusFilter = select.value;
	}
	
	var performFilter = function() {
		var visible = (patientFilter == "" || jQuery(this).attr("patientName") == patientFilter)
				   && (labFilter == "" || jQuery(this).attr("reportingLaboratory") == labFilter)
				    && (hcnFilter == "" || jQuery(this).attr("hcn") == hcnFilter)
				    && (categoryFilter == "" || jQuery(this).attr("category") == categoryFilter) 
				    && (performingLabFilter == "" || jQuery(this).attr("performingLaboratory") == performingLabFilter)
				    && (abnormalFilter == "" || jQuery(this).attr("abnormal") == abnormalFilter) 
				    && (testRequestCodeFilter == "" || jQuery(this).attr("testRequestCode") == testRequestCodeFilter)
				     && (testRequestStatusFilter == "" || jQuery(this).attr("testRequestStatus") == testRequestStatusFilter)
				     && (resultStatusFilter == "" || jQuery(this).attr("resultStatus").indexOf(resultStatusFilter) != -1);
		
		
		if (visible) { 
			jQuery(this).show(); 
		} else { 
			jQuery(this).hide(); 
		}
	};
	
	jQuery(".evenLine").each(performFilter);
	jQuery(".oddLine").each(performFilter);
}
</script>
<style type="text/css">
.oddLine { 
	background-color: #cccccc;
}
.evenLine { } 

.error {
	border: 1px solid red;
	color: red;
	font-weight: bold;
	margin: 10px;
	padding: 10px;
}
</style>
	
<%
	OLISRequestNomenclatureDao olisRequestNomenclatureDao = SpringUtils.getBean(OLISRequestNomenclatureDao.class);

%>
<title>OLIS Search Results</title>
</head>
<body>

<table style="width:600px;" class="MainTable" align="left">
	<tbody><tr class="MainTableTopRow">
		<td class="MainTableTopRowLeftColumn" width="175">OLIS</td>
		<td class="MainTableTopRowRightColumn">
		<table class="TopStatusBar">
			<tbody><tr>
				<td>Results</td>
				<td>&nbsp;</td>
				<td style="text-align: right"><a href="javascript:popupStart(300,400,'Help.jsp')"><u>H</u>elp</a> | <a href="javascript:popupStart(300,400,'About.jsp')">About</a> | <a href="javascript:popupStart(300,400,'License.jsp')">License</a></td>
			</tr>
			</tbody>
		</table>
		</td>
	</tr>
	<tr>
		<td colspan="2">
			<%
			if (request.getAttribute("searchException") != null) {
			%>
				<div class="error">Could not perform the OLIS query due to the following exception:<br /><%=((Exception) request.getAttribute("searchException")).getLocalizedMessage() %></div>
			<%
			} %>
			
			<%
			if (request.getAttribute("errors") != null) {
				// Show the errors to the user				
				for (String error : (List<String>) request.getAttribute("errors")) { %>
					<div class="error"><%=error.replaceAll("\\n", "<br />") %></div>
				<% }
			}
			String resp = (String) request.getAttribute("olisResponseContent");
			if(resp == null) { resp = ""; }
			%>
			<!--  RAW HL7
				<%=resp%>
			-->
			<%
			boolean hasBlockedContent = false;
			try {
				if(resp != null && resp.length()>0) {
					OLISHL7Handler reportHandler = (OLISHL7Handler) Factory.getHandler("OLIS_HL7", resp);
					if(reportHandler != null) {
						List<OLISError> errors = reportHandler.getReportErrors();
						if (errors.size() > 0) {
							for (OLISError error : errors) {
							%>
								<div class="error"><%=error.getIndentifer()%>:<%=error.getText().replaceAll("\\n", "<br />")%></div>
							<%
							}
						}
						hasBlockedContent = reportHandler.isReportBlocked();
					}
				}
			} catch (Exception e) {
				MiscUtils.getLogger().error("error",e);
			}
			if (hasBlockedContent) { 
			%>
			<form  action="<%=request.getContextPath()%>/olis/Search.do" onsubmit="return confirm('Are you sure you want to resubmit this query with a patient consent override?')">
				<input type="hidden" name="redo" value="true" />
				<input type="hidden" name="uuid" value="<%=(String)request.getAttribute("searchUuid")%>" />
				<input type="hidden" name="force" value="true" />				
				<input type="submit" value="Submit Override Consent" /> 
				Authorized by: 
				<select id="blockedInformationIndividual" name="blockedInformationIndividual">
					<option value="patient">Patient</option>
					<option value="substitute">Substitute Decision Maker</option>					
				</select>
			</form>
			<%
			}
			List<String> resultList = (List<String>) request.getAttribute("resultList");
			
			
			if (resultList != null) {
			%>
			<table>
				<tr>
					<td colspan="6"><%=resultList.size() %> result(s) found</td>
				</tr>
				<tr>
					<td colspan="6" style="height:10px"></td>
				</tr>
				<% if (resultList.size() > 0) { 
					List<String> names = new ArrayList<String>();
					List<String> hcns = new ArrayList<String>();
					List<String> labs = new ArrayList<String>();
					List<String> categories = new ArrayList<String>();
					
					List<String> performingLabs = new ArrayList<String>();
					List<String> resultStatuses = new ArrayList<String>();
					List<String> abnormals = new ArrayList<String>();
					List<String> testRequestCodes = new ArrayList<String>();
					List<String> testRequestStatuses = new ArrayList<String>();
					
					OLISHL7Handler result;
					
					for (String resultUuid : resultList) {
						 result = OLISResultsAction.searchResultsMap.get(resultUuid);
						String hcn = oscar.Misc.getStr(result.getHealthNum(), "").trim();
						if (!hcn.equals("")) { hcns.add(hcn);}
						String name = oscar.Misc.getStr(result.getPatientName(), "").trim();
						if (!name.equals("")) { names.add(name); }
						String reportingLab = oscar.Misc.getStr(result.getReportingFacilityName(), "").trim();
						if (!reportingLab.equals("")) { labs.add(reportingLab); }
						String category = oscar.Misc.getStr(result.getCategoryList(), "").trim();
						if (!category.equals("")) { categories.add(category); }
						String performingLab = oscar.Misc.getStr(result.getPerformingFacilityNameOnly(), "").trim();
						if (!performingLab.equals("")) { performingLabs.add(performingLab); }
						String testRequestCode = oscar.Misc.getStr(result.getTestRequestCode(), "").trim();
						if (!testRequestCode.equals("")) { testRequestCodes.add(testRequestCode); }
						String abnormal = oscar.Misc.getStr(result.hasAbnormalResult() ? "true" : "false", "").trim();
						if (!abnormal.equals("")) { abnormals.add(abnormal); }
						
						String resultStatus = oscar.Misc.getStr(result.getTestResultStatuses(),"").trim();
						for(String rs:resultStatus.split(",")) {
							if (!rs.equals("")) { resultStatuses.add(rs); }
						}
						
						String orderStatus = oscar.Misc.getStr(result.getOrderStatus(), "").trim();
						for(String rs:orderStatus.split(",")) {
							if (!rs.equals("")) { testRequestStatuses.add(rs); }
						}
					//	if (!orderStatus.equals("")) { testRequestStatuses.add(orderStatus); }
						
						
						
					}
				
				%>
					<tr>
						<td style="text-align:right"><b>Patient:</b></td>
						<td>
							<select name="patientFilter" onChange="filterResults(this)">
								<option value="">All Patients</option>
								<%  
									for (String tmp: new HashSet<String>(names)) {
								%>
									<option value="<%=tmp%>"><%=tmp%></option>
								<% } %>
							</select>
						</td>
						<td style="text-align:right"><b>HCN:</b></td>
						<td>
							<select name="hcnFilter" onChange="filterResults(this)">
								<option value="">All HCNs</option>
								<% 
									for (String tmp: new HashSet<String>(hcns)) {
								%>
									<option value="<%=tmp%>"><%=tmp%></option>
								<% } %>
							</select>
						</td>
						<td style="text-align:right"><b>Category:</b></td>
						<td>
							<select name="categoryFilter" onChange="filterResults(this)">
								<option value="">All Categories</option>
								<% 
									for (String tmp: new HashSet<String>(categories)) {
								%>
									<option value="<%=tmp%>"><%=tmp%></option>
								<% } %>
							</select>
						</td>
					</tr>
					
					<tr>
						<td style="text-align:right"><b>Reporting Lab:</b></td>
						<td>	
							<select name="labFilter" onChange="filterResults(this)">
								<option value="">All Reporting Labs</option>
								<% 
									for (String tmp: new HashSet<String>(labs)) {
								%>
									<option value="<%=tmp%>"><%=tmp%></option>
								<% } %>
							</select>
						</td>
						<td style="text-align:right"><b>Performing Lab:</b></td>
						<td>
							<select name="performingLabFilter" onChange="filterResults(this)">
								<option value="">All Performing Labs</option>
								<% 
									for (String tmp: new HashSet<String>(performingLabs)) {
								%>
									<option value="<%=tmp%>"><%=tmp%></option>
								<% } %>
							</select>
						</td>
						<td style="text-align:right"><b>Result Status:</b></td>
						<td>
							<select name="resultStatusFilter" onChange="filterResults(this)">
								<option value="">All Result Statuses</option>
								<% 
									for (String tmp: new HashSet<String>(resultStatuses)) {
								%>
									<option value="<%=tmp%>">
									<%=	OLISHL7Handler.getTestResultStatusMessage(tmp.charAt(0))%>
									</option>
								<% } %>
							</select>
						</td>
					</tr>
					<tr>
						<td style="text-align:right"><b>Abnormal:</b></td>
						<td>
							
							<select name="abnormalFilter" onChange="filterResults(this)">
								<option value="">All Normal and Abnormal</option>
								<% 
									for (String tmp: new HashSet<String>(abnormals)) {
								%>
									<option value="<%=tmp%>">
									<%if("true".equals(tmp)) { out.print("Abnormal"); } if("false".equals(tmp)) { out.print("Normal"); } %>
									</option>
								<% } %>
							</select>
						</td>
						<td style="text-align:right"><b>Test Request Code:</b></td>
						<td>
							
							<select name="testRequestCodeFilter" onChange="filterResults(this)">
								<option value="">All Test Request Codes</option>
								<% 
									for (String tmp: new HashSet<String>(testRequestCodes)) {
										OLISRequestNomenclature item =  olisRequestNomenclatureDao.findByNameId(tmp);
										
										
								%>
									<option value="<%=tmp%>"><%=item!=null?item.getName():tmp%></option>
								<% } %>
							</select>
						</td>
						<td style="text-align:right"><b>Test Request Status:</b></td>
						<td>
							
							<select name="testRequestStatusFilter" onChange="filterResults(this)">
								<option value="">All Test Request Statuses</option>
								<% 
									for (String tmp: new HashSet<String>(testRequestStatuses)) {
								%>
									<option value="<%=tmp%>"><%=OLISHL7Handler.getTestRequestStatusMessage(tmp.charAt(0))%></option>
								<% } %>
							</select>
						</td>
					</tr>
					<tr><td colspan="6">
					<table class="sortable" id="resultsTable">
					<tr><th class="unsortable" style="white-space: nowrap;"></th>
						<th class="unsortable" style="white-space: nowrap;"></th>
						<th class="unsortable" style="white-space: nowrap;"></th>
						<th class="unsortable" style="white-space: nowrap;"></th>
						<th style="white-space: nowrap;">Health Number</th>
						<th style="white-space: nowrap;">Patient Name</th>
						<th style="white-space: nowrap;">Sex</th>
						<th style="white-space: nowrap;">Date of Test</th>
						<th style="white-space: nowrap;">Discipline</th>
						<th style="white-space: nowrap;">Tests</th>
						<th style="white-space: nowrap;">Status</th>
						<th style="white-space: nowrap;">Abnormal</th>
						<th style="white-space: nowrap;">Ordering Practitioner</th>
						<th style="white-space: nowrap;">Admitting Practitioner</th>
					</tr>
					
					<%  int lineNum = 0;
						for (String resultUuid : resultList) {
						result = OLISResultsAction.searchResultsMap.get(resultUuid);
					%>
					<tr class="<%=++lineNum % 2 == 1 ? "oddLine" : "evenLine"%>" patientName="<%=result.getPatientName()%>" reportingLaboratory="<%=result.getReportingFacilityName()%>" 
						hcn="<%=result.getHealthNum()%>" category="<%=result.getCategoryList()%>" performingLaboratory="<%=result.getPerformingFacilityNameOnly()%>"
						abnormal="<%=result.hasAbnormalResult()%>" testRequestCode="<%=result.getTestRequestCode()%>" testRequestStatus="<%=result.getOrderStatus()%>"
						resultStatus="<%=result.getTestResultStatuses()%>">
						<td>
							<div id="<%=resultUuid %>_result"></div>
							<input type="button" onClick="addToInbox('<%=resultUuid %>'); return false;" id="<%=resultUuid %>" value="Add to Inbox" />
						</td>
						<td>
							
							<input type="button" onClick="preview('<%=resultUuid %>'); return false;" id="<%=resultUuid %>_preview" value="Preview" />
						</td>
						
						<td>							
							<input type="button" onClick="save('<%=resultUuid %>'); return false;" id="<%=resultUuid %>_save" value="Save/File" />
						</td>
						
						<td>							
							<input type="button" onClick="ack('<%=resultUuid %>'); return false;" id="<%=resultUuid %>_ack" value="Acknowledge" />
						</td>
						
						<td><%=result.getHealthNum() %></td>
						<td><%=result.getPatientName() %></td>
						<td align="center"><%=result.getSex() %></td>
						<td><%=result.getSpecimenReceivedDateTime() %></td>
						<td style="width:200px;"><%=result.getCategoryList() %></td>
						<td style="width:200px;"><%=result.getTestList() %></td>
						<td><%= ( (String) ( result.getOrderStatus().equals("F") ? "Final" : result.getOrderStatus().equals("C") ? "Corrected" : "Partial") )%></td>
						<td><%=result.hasAbnormalResult() ?  "<span style='color:red'>Abnormal</span>" : "" %></td>
						<td> <%=result.getShortDocName() %> </td>
						<td> <%=result.getAdmittingProviderNameShort()%></td>
						 
					</tr>					
					<% } %>
					</table></td></tr>
				<% } %>
			</table>
			<%
			}
			%>
		</td>
	</tr></tbody>
</table>
<!-- RAW HL7 ERP
<%=request.getAttribute("unsignedResponse") %>
-->
</body>
</html>
