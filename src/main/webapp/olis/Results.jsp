<%--

    Copyright (c) 2008-2012 Indivica Inc.

    This software is made available under the terms of the
    GNU General Public License, Version 2, 1991 (GPLv2).
    License details are available via "indivica.ca/gplv2"
    and "gnu.org/licenses/gpl-2.0.html".

--%>
<%@ page language="java" contentType="text/html;" %>
<%@page import="java.util.*,oscar.oscarLab.ca.all.parsers.OLISHL7Handler, oscar.oscarLab.ca.all.parsers.OLISHL7Handler.OLISError, org.oscarehr.olis.OLISResultsAction" %>
<%@ page import="org.oscarehr.olis.model.OlisLabResults" %>
<%@ page import="org.oscarehr.olis.model.OlisLabResultDisplay" %>
<%@ page import="org.oscarehr.olis.model.OlisMeasurementsResultDisplay" %>
<%@ page import="org.oscarehr.olis.OLISUtils" %>
<%@ page import="org.oscarehr.common.model.Demographic" %>
<%@ page import="org.oscarehr.common.dao.DemographicDao" %>
<%@ page import="org.oscarehr.util.SpringUtils" %>
<%@ page import="org.apache.commons.lang.StringUtils" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<script type="text/javascript" src="<%= request.getContextPath() %>/js/global.js"></script>
<script type="text/javascript" src="<%=request.getContextPath()%>/js/jquery.js"></script>
<script type="text/javascript" src="<%= request.getContextPath() %>/js/jquery.tablesorter.js"></script>
<script type="text/javascript" src="<%= request.getContextPath() %>/js/jquery.tablesorter.pager.js"></script>
<script type="text/javascript">
    jQuery.noConflict();
</script>
<link rel="stylesheet" type="text/css" href="<%=request.getContextPath()%>/share/css/OscarStandardLayout.css">
<link rel="stylesheet" type="text/css" href="<%=request.getContextPath()%>/css/tablesorter/jquery.tablesorter.pager.css"/>
<script type="text/javascript" src="<%=request.getContextPath()%>/share/javascript/Oscar.js"></script>
<script type="text/javascript" src="<%=request.getContextPath()%>/share/javascript/oscarMDSIndex.js"></script>
	
<script type="text/javascript">
let currentView = "labsView";
function addToInbox(uuid) {
	jQuery(uuid).attr("disabled", "disabled");
	jQuery.ajax({
		url: "<%=request.getContextPath() %>/olis/AddToInbox.do",
		data: 'uuid=' + uuid + '&requestingHic=<%=request.getParameter("requestingHic")%>',
		success: function(data) {
			jQuery("#" + uuid + "_result").html(data);
		}
	});
}
function preview(uuid, obrIndex) {
    let url = '<%=request.getContextPath()%>/lab/CA/ALL/labDisplayOLIS.jsp?segmentID=0&preview=true&uuid=' + uuid;
    if (typeof obrIndex !== 'undefined') {
        url += '&obrIndex=' + obrIndex;
    }
    reportWindow(url);
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

function updateFilter(select) {
	filter[select.name] = select.value;
	
	filterResults();
}

function filterResults() {
	if (currentView === "labsView") {
		jQuery("#resultsSummaryTable tbody tr").each(resultsFilter);
	} else {
		jQuery("#measurementsDetailTable tbody tr").each(resultsFilter);
	}
}

let filter = {
	firstName: "",
	lastName: "",
	hcn: "",
	labName: "",
	category: "",
	requestStatus: "",
	resultStatus: "",
	orderingPractitioner: "",
	ccPractitioner: "",
	admittingPractitioner: "",
	attendingPractitioner: "",
	abnormal: "",
	reportingLab: "",
	performingLab: ""
};

function resultsFilter() {
	let matches = true;
	let row = jQuery(this);
	if ((filter.firstName !== "" && !row.attr("firstName").toLowerCase().startsWith(filter.firstName.toLowerCase())) ||
			(filter.lastName !== "" && !row.attr("lastName").toLowerCase().startsWith(filter.lastName.toLowerCase())) ||
			(filter.hcn !== "" && !row.attr("hcn").toLowerCase().startsWith(filter.hcn.toLowerCase())) ||
			(filter.labName !== "" && row.attr("labName") !== filter.labName) ||
			(filter.category !== "" && row.attr("category") !== filter.category) ||
			(filter.requestStatus !== "" && row.attr("requestStatus") !== filter.requestStatus) ||
			(filter.resultStatus !== "" && row.attr("resultStatus") !== filter.resultStatus) ||
			(filter.orderingPractitioner !== "" && row.attr("orderingPractitioner") !== filter.orderingPractitioner) ||
			(filter.ccPractitioner !== "" && !row.attr("ccPractitioners").includes(filter.ccPractitioner)) ||
			(filter.admittingPractitioner !== "" && row.attr("admittingPractitioner") !== filter.admittingPractitioner) ||
			(filter.attendingPractitioner !== "" && row.attr("attendingPractitioner") !== filter.attendingPractitioner) ||
			(filter.abnormal !== "" && row.attr("abnormal") !== filter.abnormal) ||
			(filter.reportingLab !== "" && row.attr("reportingLab") !== filter.reportingLab) ||
			(filter.performingLab !== "" && row.attr("performingLab") !== filter.performingLab)) {
		matches = false;
	}

	if (matches) {
		jQuery(this).show();
	} else {
		jQuery(this).hide();
	}
}


function resetSorting() {
    jQuery("#resultsSummaryTable").trigger("sorton", [[[7, 1], [11, 0], [12, 0]]]);
	
	document.getElementById('firstNameFilter').value = "";
	document.getElementById('lastNameFilter').value = "";
	document.getElementById('hinFilter').value = "";
	document.getElementById('labNameFilter').value = "";
	document.getElementById('categoryFilter').value = "";
	document.getElementById('requestStatusFilter').value = "";
	document.getElementById('orderingPractitionerFilter').value = "";
	document.getElementById('ccPractitionerFilter').value = "";
	document.getElementById('admittingPractitionerFilter').value = "";
	document.getElementById('attendingPractitionerFilter').value = "";
	document.getElementById('labFilter').value = "";
	document.getElementById('performingLabFilter').value = "";
	document.getElementById('resultStatusFilter').value = "";
	document.getElementById('abnormalFilter').value = "";
    
	filter = {
		firstName: "",
		lastName: "",
		hcn: "",
		labName: "",
		category: "",
		requestStatus: "",
		resultStatus: "",
		orderingPractitioner: "",
		ccPractitioner: "",
		admittingPractitioner: "",
		attendingPractitioner: "",
		abnormal: "",
		reportingLab: "",
		performingLab: ""
	};
}

function showView(viewName) {
    let measurementsButton = document.getElementById('showMeasurementsView');
    let measurementsDisplay = document.getElementById('measurementsDisplay');
    let labsButton = document.getElementById('showLabsView');
    let labsDisplay = document.getElementById('labsDisplay');

    measurementsButton.style.display = 'none';
    measurementsDisplay.style.display = 'none';
    labsButton.style.display = 'none';
    labsDisplay.style.display = 'none';
    
	if (viewName === 'measurementsView') {
        labsButton.style.display = 'inline-block';
        measurementsDisplay.style.display = 'table-cell';
        
        
	} else if (viewName === 'labsView') {
        measurementsButton.style.display = 'inline-block';
        labsDisplay.style.display = 'table-cell';
        document.getElementById("resultStatusFilter").value = "";
        document.getElementById("abnormalFilter").value = "";
        filter.resultStatus = "";
		filter.abnormal = "";
	}

	document.getElementById("measurement-filters").classList.toggle("hidden");
	
	currentView = viewName;
	filterResults();
}
function popupNotesWindow(noteDiv) {
    let windowProps = "height=300,width=600,location=no,scrollbars=yes,menubars=no,toolbars=no,resizable=yes";
    let notesWindow = window.open("", "notes", windowProps);
    notesWindow.document.body.innerHTML = '';
    notesWindow.document.write(noteDiv.html());
}

/*
    Hides or shows the decision-maker-info div depending on if the user is submitted consent from a substitute decision
    maker or not
 */
function changeAuthorizedBy() {
	let consentTypeDropdown = document.getElementById("blockedInformationIndividual");
	let selectedConsentType = consentTypeDropdown[consentTypeDropdown.selectedIndex].value;
	let e = document.getElementById("decision-maker-info");
	if (selectedConsentType === "substitute") {
		e.classList.remove("hidden");
	} else {
		e.classList.add("hidden");
	}
}

/*
    Validates the input data if the consent type is Substitute Decision Maker. If it isn't then it displays the 
    confirmation
 */
function validateInput() {
	let validInput = true;
	let consentTypeDropdown = document.getElementById("blockedInformationIndividual");
	let selectedConsentType = consentTypeDropdown[consentTypeDropdown.selectedIndex].value;
	
	if (selectedConsentType === "substitute") {
		let firstName = document.getElementById("overrideFirstName");
		let lastName = document.getElementById("overrideLastName");
		let relationshipDropdown = document.getElementById("overrideRelationship");
		let selectedRelationshipType = relationshipDropdown[relationshipDropdown.selectedIndex].value;
		let errors = "";
		
		if (firstName.value.length === 0) {
			errors += "You must enter the first name for the SDM";
		}
		
		if (lastName.value.length === 0) {
			errors += "\nYou must enter the last name for the SDM";
		}
		
		if (selectedRelationshipType.length === 0) {
			errors += "\nYou must select a relationship type for the SDM";
		}
		
		if (errors.length > 0) {
			validInput = false;
			alert(errors.trim());
		}
	}

	if (validInput) {
		validInput = confirm('Are you sure you want to resubmit this query with a patient consent override?');
	}
	
	return validInput;
}

let isLoadingMoreResults = false;
function loadMoreResults() {
    if (!isLoadingMoreResults) {
        isLoadingMoreResults = true;
        document.getElementById('loadMoreResultsForm').submit();
	}
}

function toggleFilters() {
	let filters = document.getElementById("result-filters");
	let filterToggle = document.getElementById("toggle-filters");
	let isHidden = filters.classList.toggle("hidden");
	
	if (isHidden) {
		filterToggle.text = "Show Filters";
	} else {
		filterToggle.text = "Hide Filters";
	}
	
	return false;
}
</script>
<script type="text/javascript" src="<%=request.getContextPath()%>/share/javascript/sortable.js"></script>
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

.small-text {
	font-size: 10px;
}

.resultsTable {
	border-collapse: collapse;
}
.abnormal {
	color: red;
}
.line-through {
	text-decoration: line-through;
}
.resultsTable thead tr th, .resultsTable tbody tr td {
	border-right: solid 1px #444444;
	border-left: solid 1px #444444;
	padding: 3px;
}
.resultsTable tbody tr:last-child td {
	border-bottom: solid 1px #444444;
}
.resultsTable thead tr {
	background-color: #9999CC;
}
.resultsTable tbody tr:nth-child(even) {
	background-color: #CCCCCC;
}
.resultsTable td.hidden, .resultsTable th.hidden {
	display: none;
}

#patientInfoTable {
	width: 100%;
	border-collapse: collapse;
	border: solid 1px #444444;
}
#patientInfoTable tr td {
	padding: 3px;
}
#patientInfoTable tr td.label {
	text-align: right;
	width: 25%;
}
#patientInfoTable tr td.info {
	width: 25%;
}
	
.patient-consent-alert {
	color: #FF0000;
	text-align: center;
}

span.patient-consent-alert {
	display: block;
}
	
	.hidden {
		display: none;
	}
	
	.consent-form {
		margin-bottom: 10px;
	}
	
	#decision-maker-info {
		margin-top: 5px;
	}
	
	.monospaced {
		font-family: Courier, monospace !important;
	}
	
	
	#result-filters .filter-row select, 
	#result-filters .filter-row input {
		width: 100%;
		max-width: 100%;
	}

	#result-filters .filter-row {
		width: 75%;
		min-width: 75%;
		max-width: 75%;
		padding-top: 5px;
		white-space: nowrap;
	}
	
	#result-filters .filter-row div {
		display: inline-block;
		padding: 0 5px;
		white-space: normal;
		width: 25%;
	}
</style>
	
<title>OLIS Search Results</title>
</head>
<body>
<%
	OlisLabResults olisLabResults = (OlisLabResults) request.getAttribute("olisLabResults");
	if (olisLabResults == null) {
		olisLabResults = new OlisLabResults();
	}
	String olisResultFileUuid = (String) request.getAttribute("olisResultFileUuid");
	request.setAttribute("olisResultFileUuid", olisResultFileUuid);
	DemographicDao demographicDao = SpringUtils.getBean(DemographicDao.class);
	Demographic demographic = demographicDao.getDemographic(request.getParameter("demographic"));
	boolean resultsEmpty = olisLabResults.getResultList().isEmpty();
	boolean hasErrors = !olisLabResults.getErrors().isEmpty();

	
	List<String> labNames = new ArrayList<String>();
	List<String> categories = new ArrayList<String>();
	List<String> orderingPractitioners = new ArrayList<String>();
	List<String> ccPractitioners = new ArrayList<String>();
	List<String> admittingPractitioners = new ArrayList<String>();
	List<String> attendingPractitioners = new ArrayList<String>();
	List<String> reportingLabs = new ArrayList<String>();
	List<String> performingLabs = new ArrayList<String>();
	
	
	for (OlisLabResultDisplay resultDisplay : olisLabResults.getResultListSorted()) {
		
		if (!resultDisplay.getLabName().isEmpty() && !labNames.contains(resultDisplay.getLabName())) {
			labNames.add(resultDisplay.getLabName());
		}
		
		if (!resultDisplay.getCategory().isEmpty() && !categories.contains(resultDisplay.getCategory())) {
			categories.add(resultDisplay.getCategory());
		}

		if (!resultDisplay.getOrderingPractitioner().isEmpty() && !orderingPractitioners.contains(resultDisplay.getOrderingPractitioner())) {
			orderingPractitioners.add(resultDisplay.getOrderingPractitioner());
		}

		if (!resultDisplay.getCcPractitioners().isEmpty()) {
			for (String ccPractitioner : resultDisplay.getCcPractitioners().split(";")) {
				if (!ccPractitioners.contains(ccPractitioner)) {
					ccPractitioners.add(ccPractitioner);
				}
			}
		}

		if (!resultDisplay.getAdmittingPractitioner().isEmpty() && !admittingPractitioners.contains(resultDisplay.getAdmittingPractitioner())) {
			admittingPractitioners.add(resultDisplay.getAdmittingPractitioner());
		}

		if (!resultDisplay.getAttendingPractitioner().isEmpty() && !attendingPractitioners.contains(resultDisplay.getAttendingPractitioner())) {
			attendingPractitioners.add(resultDisplay.getAttendingPractitioner());
		}

		
		if (!resultDisplay.getReportingFacilityName().isEmpty() && !reportingLabs.contains(resultDisplay.getReportingFacilityName())) {
			reportingLabs.add(resultDisplay.getReportingFacilityName());
		}
		
		if (!resultDisplay.getPerformingFacilityName().isEmpty() && !performingLabs.contains(resultDisplay.getPerformingFacilityName())) {
			performingLabs.add(resultDisplay.getPerformingFacilityName());
		}
	}
%>
<table style="min-width:600px;" class="MainTable" align="left">
	<tbody><tr class="MainTableTopRow">
		<td class="MainTableTopRowLeftColumn" width="175">OLIS</td>
		<td class="MainTableTopRowRightColumn">
		<table class="TopStatusBar">
			<tbody><tr>
				<td>Results</td>
				<td>
					<input type="button" onclick="showView('measurementsView'); return false;" id="showMeasurementsView" value="Show Measurements View"/>
					<input type="button" onclick="showView('labsView'); return false;" id="showLabsView" value="Show Labs View" style="display: none;"/>
				</td>
				<td>&nbsp;</td>
				<td style="text-align: right"><a href="javascript:popupStart(300,400,'Help.jsp')"><u>H</u>elp</a> | <a href="javascript:popupStart(300,400,'About.jsp')">About</a> | <a href="javascript:popupStart(300,400,'License.jsp')">License</a></td>
			</tr>
			</tbody>
		</table>
		</td>
	</tr>
	<% if (demographic != null) { 
	    boolean hideDemographicInfo = olisLabResults.getErrors().size() > 0 && !(olisLabResults.hasErrorWithIdentifier("320") || olisLabResults.hasErrorWithIdentifier("920"));
	%>
	<tr <%=hideDemographicInfo ? "style=\"display: none;\"" : ""%>>
		<td colspan="2" id="patientInfo">
			<%
				String sex = olisLabResults.getDemographicSex();
				if (!("F".equals(sex) || "M".equals(sex))) {
				    sex = "U";
				}
			%>
			<table id="patientInfoTable">
				<tr>
					<td colspan="4" style="background-color: #9999CC; text-align: center; border: solid 1px #444444;">Patient Info</td>
				</tr>
				<tr>
					<td class="label">Name:</td>
					<td class="info"><%=resultsEmpty ? demographic.getFormattedName() : olisLabResults.getDemographicName()%></td>
					<td class="label">Ontario Health Number:</td>
					<td class="info"><%=resultsEmpty ? demographic.getHin() : olisLabResults.getDemographicHin()%></td>
				</tr>
				<tr>
					<td class="label">Sex:</td>
					<td class="info"><%=resultsEmpty ? demographic.getSex() : sex%></td>
					<td class="label">Date of Birth:</td>
					<td class="info"><%=resultsEmpty ? demographic.getFormattedDob() : olisLabResults.getDemographicDob()%></td>
				</tr>
				<% if (olisLabResults.getDemographicHin().isEmpty()) { %>
				<tr>
					<td class="label">Medical Record Number:</td>
					<td colspan="3" class="info"><%=olisLabResults.getDemographicMrn()%></td>
				</tr>
				<% } %>
			</table>
		</td>
	</tr>
    <%  }
		if (resultsEmpty && !hasErrors && request.getAttribute("searchException") == null) { 
	%>
    <tr>
        <td style="color: #a94442; font-weight: bold; padding: 10px;" colspan="3" align="center">No results have been found in OLIS.</td>
    </tr>
    <% } else if (olisLabResults.isHasPatientLevelBlock()) { %>
	<tr>
		<td colspan="2" class="patient-consent-alert">
			Do not disclose without express patient consent
		</td>
	</tr>
	<% } %>
	<tr>
		<td colspan="2">
			<%
				if (request.getAttribute("searchException") != null) {
			%>
			<div class="error">Could not perform the OLIS query due to the following exception:<hr/><br/>
				<%
					Exception searchException = (Exception) request.getAttribute("searchException");
					if (searchException.getLocalizedMessage() != null && searchException.getLocalizedMessage().equals("connect timed out")) {
				%>		
					<p>The request took too long due to your connection being unable to reach the endpoint.</p>
					<p>Please check your internet connection and try again.</p>
				<%
					} else {
				%>
					<%=searchException.getLocalizedMessage()%>
				<%	
					}
				%>
			</div>
			<%
				} %>

			<%
				if (request.getAttribute("errors") != null) {
					// Show the errors to the user				
					for (String error : (List<String>) request.getAttribute("errors")) { %>
			<div class="error"><%=error.replaceAll("\\n", "<br />") %></div>
			<% }
			}
				if (hasErrors) { %>
			<div class="error">
				<% if (!(olisLabResults.hasErrorWithIdentifier("320") || olisLabResults.hasErrorWithIdentifier("920"))) { %>
				The querying provider was not recognized by OLIS. Please verify and resubmit your query.
				<% }
				for (OLISError error : olisLabResults.getErrors()) {
						if (!error.getIndentifer().equals("320") || olisLabResults.isDisplay320Error()) {
						    String text = error.getText().replaceAll("\\n", "<br />");
							if (error.getErrorSegmentDisplayText() != null) {
								text += " (" + error.getErrorSegmentDisplayText() + ")";
							}
			%>
			<div><%=error.getIndentifer()%>:<%=text%></div>
			<%
						}
					} %>
			</div>
			<%  }
				if (olisLabResults.isHasBlockedContent() && !olisLabResults.isHasPatientConsent()) {
			%>
			<form class="consent-form" action="<%=request.getContextPath()%>/olis/Search.do" onsubmit="return validateInput()">
				<input type="hidden" name="method" value="loadResults" />
				<input type="hidden" name="redo" value="true" />
				<input type="hidden" name="uuid" value="<%=olisLabResults.getQueryUsedUuid()%>" />
				<input type="hidden" name="force" value="true" />
				
				<label for="blockedInformationIndividual">Authorized by:</label>
				<select id="blockedInformationIndividual" name="blockedInformationIndividual" onchange="changeAuthorizedBy()">
					<option value="patient">Patient</option>
					<option value="substitute">Substitute Decision Maker</option>
				</select>

				<input type="submit" value="Submit Override Consent" />
				
				<div id="decision-maker-info" class="hidden">
					<label for="overrideFirstName">First Name:</label>
					<input id="overrideFirstName" name="overrideFirstName" maxlength="20" />
					<label for="overrideLastName">Last Name:</label>
					<input id="overrideLastName" name="overrideLastName" maxlength="30" />
					<label for="overrideRelationship">Relationship:</label>
					<select id="overrideRelationship" name="overrideRelationship">
						<option value="">Select a type</option>
						<option value="A0">Guardian for the Person</option>
						<option value="A1">Attorney for Personal Care</option>
						<option value="A2">Representative appointed by Consent and Capacity Board</option>
						<option value="A3">Spouse/Partner</option>
						<option value="A4">Parent</option>
						<option value="A5">Child</option>
						<option value="A6">Sibling</option>
						<option value="A7">Other Sibling</option>
					</select>
				</div>
			</form>
			<% } %>
		</td>
	</tr>
	<% 
		List<OlisLabResultDisplay> olisResultList = olisLabResults.getResultListSorted(); 
		if (!olisResultList.isEmpty()) { 
	%>
	<tr>
		<td colspan="2">
			<a id="toggle-filters" href="javascript:void(0);" onClick="toggleFilters()">Show Filters</a>
		</td>
	</tr>
	<tr id="result-filters" class="hidden">
		<td colspan="2">
			<div class="filter-row">
				<% if (!olisLabResults.getSearchType().equals("Z01")) {%>
				<div>
					<label for="firstNameFilter">First Name:</label>
					<input id="firstNameFilter" name="firstName" onChange="updateFilter(this)" type="text" />
				</div>
				<div>
					<label for="lastNameFilter">Last Name:</label>
					<input id="lastNameFilter" name="lastName" onChange="updateFilter(this)" type="text" />
				</div>
				<div>
					<label for="hinFilter">HIN:</label>
					<input id="hinFilter" name="hin" onChange="updateFilter(this)" type="text" />
				</div>
				<% } %>
				<div>
					<label for="labNameFilter">Lab Name:</label>
					<select id="labNameFilter" name="labName" class="max-width-select" onChange="updateFilter(this)">
						<option value="">All Labs</option>
						<% for(String name : labNames) { %>
						<option value="<%=name%>"><%=name%></option>
						<% } %>
					</select>
				</div>
			</div>
			<div class="filter-row">
				
				<div>
					<label for="categoryFilter">Category:</label>
					<select id="categoryFilter" name="category" onChange="updateFilter(this)">
						<option value="">All Categories</option>
						<% for(String category : categories) { %>
						<option value="<%=category%>"><%=category%></option>
						<% } %>
					</select>
				</div>
				<div>
					<label for="requestStatusFilter">Request Status:</label>
					<select id="requestStatusFilter" name="requestStatus" onChange="updateFilter(this)">
						<option value="partial">Partial</option>
						<option value="amended">Amended</option>
						<option value="OLIS has expired the test request because no activity has occurred within a reasonable amount of time.">Expired</option>
						<option value="Final">Final</option>
						<option value="Collected">Collected</option>
						<option value="Ordered">Ordered</option>
						<option value="preliminary">Preliminary</option>
						<option value="Cancelled">Cancelled</option>
					</select>
				</div>
				<div>
					<label for="orderingPractitionerFilter">Ordering Practitioner:</label>
					<select id="orderingPractitionerFilter" name="orderingPractitioner" onChange="updateFilter(this)">
						<option value="">All Ordering</option>
						<% for(String orderingPractitioner : orderingPractitioners) { %>
						<option value="<%=orderingPractitioner%>"><%=orderingPractitioner%></option>
						<% } %>
					</select>
				</div>
				<div>
					<label for="ccPractitionerFilter">CC Practitioner:</label>
					<select id="ccPractitionerFilter" name="ccPractitioner" onChange="updateFilter(this)">
						<option value="">All CC</option>
						<% for(String ccPractitioner : ccPractitioners) { %>
						<option value="<%=ccPractitioner%>"><%=ccPractitioner%></option>
						<% } %>
					</select>
				</div>
			</div>
			<div class="filter-row">
				
				<div>
					<label for="admittingPractitionerFilter">Admitting Practitioner:</label>
					<select id="admittingPractitionerFilter" name="admittingPractitioner" onChange="updateFilter(this)">
						<option value="">All Admitting</option>
						<% for(String admittingPractitioner : admittingPractitioners) { %>
						<option value="<%=admittingPractitioner%>"><%=admittingPractitioner%></option>
						<% } %>
					</select>
				</div>
				<div>
					<label for="attendingPractitionerFilter">Attending Practitioner:</label>
					<select id="attendingPractitionerFilter" name="attendingPractitioner" onChange="updateFilter(this)">
						<option value="">All Attending</option>
						<% for(String attendingPractitioner : attendingPractitioners) { %>
						<option value="<%=attendingPractitioner%>"><%=attendingPractitioner%></option>
						<% } %>
					</select>
				</div>
				<div>
					<label for="labFilter">Reporting Laboratory:</label>
					<select id="labFilter" name="reportingLab" onChange="updateFilter(this)">
						<option value="">All Labs</option>
						<% for (String reportingLab : reportingLabs) { %>
						<option value="<%=reportingLab%>"><%=reportingLab%></option>
						<% } %>
					</select>
				</div>
				<div>
					<label for="performingLabFilter">Performing Lab:</label>
					<select id="performingLabFilter" name="performingLab" onChange="updateFilter(this)">
						<option value="">All Labs</option>
						<% for (String performingLab : performingLabs) { %>
						<option value="<%=performingLab%>"><%=performingLab%></option>
						<% } %>
					</select>
				</div>
			</div>
			<div id="measurement-filters" class="filter-row hidden">
				<div>
					<label for="resultStatusFilter" >Result Status:</label>
					<select id="resultStatusFilter" name="resultStatus" onChange="updateFilter(this)">
						<option value="Amended">Amended</option>
						<option value="Preliminary">Preliminary</option>
						<option value="Could not obtain result">Could not obtain result</option>
						<option value="Invalid result">Invalid result</option>
						<option value="Test not performed">Test not performed</option>
						<option value="Patient Observation">Patient Observation</option>
					</select>
				</div>
				<div>
					<label for="abnormalFilter">Abnormal:</label>
					<select id="abnormalFilter" name="abnormal" onChange="updateFilter(this)">
						<option value="">All</option>
						<option value="N">Normal</option>
						<option value="A">Abnormal</option>
					</select>
				</div>
			</div>
		</td>
	</tr>
	<% } %>
	<tr>
		<td colspan="2" id="labsDisplay">
			<% if (olisResultList.size() > 0) { %>
			<div class="resultsSummaryPager" style="padding: 0;">
				
				<input type="button" onclick="resetSorting(); return false;" value="Reset Sorting">
				<label>Jump to page
					<select class="gotoPage" title="Select page number"></select>
				</label>
				<label>Results per page
					<select class="pagesize" title="Select page size">
						<option value="10">10</option>
						<option selected="selected" value="25">25</option>
						<option value="50">50</option>
						<option value="100">100</option>
					</select>
				</label>
				<div style="float: right">
					<img src="<%=request.getContextPath()%>/css/tablesorter/icons/first.png" class="first"/>
					<img src="<%=request.getContextPath()%>/css/tablesorter/icons/prev.png" class="prev"/>
					<span class="pagedisplay"></span>
					<img src="<%=request.getContextPath()%>/css/tablesorter/icons/next.png" class="next"/>
					<img src="<%=request.getContextPath()%>/css/tablesorter/icons/last.png" class="last"/>
				</div>
				<% if (olisLabResults.getContinuationPointer() != null) { %>
				<label style="float: right">
					<button title="More results are available, click here to load" onclick="loadMoreResults()">Load More Results</button>
				</label>
				<% } %>
			</div>
			<table style="min-width: 1200px;" id="resultsSummaryTable" class="resultsTable tablesorter">
				<thead>
				<tr>
					<th style="min-width: 175px;">Actions</th>
					<th>Test Request Name &#8597;</th>
					<th>Specimen Type &#8597;</th>
					<th>Collection Date/Time &#8597;</th>
					<th>Last Updated in OLIS &#8597;</th>
					<th>Results Indicator &#8597;</th>
					<th>Ordering Practitioner &#8597;</th>
					<th>Admitting Practitioner &#8597;</th>
					<th class="hidden">Placer Group</th>
					<th class="hidden">ZBR.11</th>
					<th class="hidden">Sort Key</th>
					<th class="hidden">Alternate Name 1</th>
					<th class="hidden">Lab Obr Index</th>
				</tr>
				</thead>
				<tbody>
				<% for (OlisLabResultDisplay resultDisplay : olisResultList) { 
					String resultUuid = resultDisplay.getLabUuid();%>
				<tr firstName="<%=resultDisplay.getPatientFirstName()%>" lastName="<%=resultDisplay.getPatientLastName()%>" 
					hcn="<%=resultDisplay.getPatientHcn()%>" labName="<%=resultDisplay.getLabName()%>"
					category="<%=resultDisplay.getCategory()%>" requestStatus="<%=resultDisplay.getRequestStatus()%>"
					orderingPractitioner="<%=resultDisplay.getOrderingPractitioner()%>" ccPractitioners="<%=resultDisplay.getCcPractitioners()%>"
					admittingPractitioner="<%=resultDisplay.getAdmittingPractitioner()%>" attendingPractitioner="<%=resultDisplay.getAttendingPractitioner()%>"
					reportingLab="<%=resultDisplay.getReportingFacilityName()%>" performingLab="<%=resultDisplay.getPerformingFacilityName()%>">
					<td>
						<div id="<%=resultUuid%>_result"></div>
						<input type="button" onClick="addToInbox('<%=resultUuid %>'); return false;" id="<%=resultUuid %>" value="Add to Inbox" />
						<input type="button" onClick="preview('<%=resultUuid %>'); return false;" id="<%=resultUuid %>_preview" value="Preview" />
                        <% if (resultDisplay.isBlocked() && !olisLabResults.isHasPatientLevelBlock()) { %>
                        <span class="patient-consent-alert">Do not disclose without express patient consent</span>
                        <% } %>
					</td>
					<td>
						<% if (resultDisplay.getTestRequestName().length() > 30) { %>
						<span title="<%=resultDisplay.getTestRequestName()%>">
							<%=resultDisplay.getTestRequestName().substring(0, 30)%>...
						</span>
						<% } else { %>
						<%=resultDisplay.getTestRequestName()%>
						<% } %>
					</td>
					<td><%=resultDisplay.getSpecimenType()%></td>
					<td><%=resultDisplay.getCollectionDate()%></td>
					<td><%=resultDisplay.getOlisLastUpdated()%></td>
					<td>
						<%=resultDisplay.getRequestStatus()%>
					</td>
					<td><%=resultDisplay.getOrderingPractitioner()%></td>
					<td><%=resultDisplay.getAdmittingPractitioner()%></td>
					<td class="hidden"><%=resultDisplay.getPlacerGroupNo()%></td>
					<td class="hidden"><%=resultDisplay.getTestRequestZbr11()%></td>
					<td class="hidden"><%=resultDisplay.getNomenclature().getSortKey()%></td>
					<td class="hidden"><%=resultDisplay.getNomenclature().getRequestAlternateName1()%></td>
					<td class="hidden"><%=resultDisplay.getLabObrIndex()%></td>
				</tr>
				<% } %>
				</tbody>
			</table>
			<div class="resultsSummaryPager" style="float: right;">
				<img src="<%=request.getContextPath()%>/css/tablesorter/icons/first.png" class="first"/>
				<img src="<%=request.getContextPath()%>/css/tablesorter/icons/prev.png" class="prev"/>
				<span class="pagedisplay"></span>
				<img src="<%=request.getContextPath()%>/css/tablesorter/icons/next.png" class="next"/>
				<img src="<%=request.getContextPath()%>/css/tablesorter/icons/last.png" class="last"/>
			</div>
			<% } %>
			<% if (olisLabResults.getContinuationPointer() != null) { %>
			<label style="float: right">
				<button title="More results are available, click here to load" onclick="loadMoreResults()">Load More Results</button>
			</label>
			<% } %>
		</td>
	</tr>
	<tr>
		<td colspan="2" id="measurementsDisplay" style="display: none;">
			<div class="measurementsDisplayPager" style="padding: 0;">
				<input type="button" onclick="resetSorting(); return false;" value="Reset Sorting">
				<label>Jump to page
					<select class="gotoPage" title="Select page number"></select>
				</label>
				<label>Results per page
					<select class="pagesize" title="Select page size">
						<option value="10">10</option>
						<option selected="selected" value="25">25</option>
						<option value="50">50</option>
						<option value="100">100</option>
					</select>
				</label>
				<div style="float: right">
					<img src="<%=request.getContextPath()%>/css/tablesorter/icons/first.png" class="first"/>
					<img src="<%=request.getContextPath()%>/css/tablesorter/icons/prev.png" class="prev"/>
					<span class="pagedisplay"></span>
					<img src="<%=request.getContextPath()%>/css/tablesorter/icons/next.png" class="next"/>
					<img src="<%=request.getContextPath()%>/css/tablesorter/icons/last.png" class="last"/>
				</div>
				<% if (olisLabResults.getContinuationPointer() != null) { %>
				<label style="float: right">
					<button title="More results are available, click here to load" onclick="loadMoreResults()">Load More Results</button>
				</label>
				<% } %>
			</div>
			<table style="min-width: 1200px;"  id="measurementsDetailTable" class="resultsTable tablesorter">
				<thead>
				<tr>
					<th class="small-text" style="min-width: 75px;">Last Updated In OLIS &#8597;</th>
					<th class="small-text">Test Request Name &#8597;</th>
					<th class="small-text">Test Request Status &#8597;</th>
					<th class="small-text">Specimen Type &#8597;</th>
					<th class="small-text" style="min-width: 75px;">Collection Date/Time &#8597;</th>
					<th class="small-text">Collector's Comments &#8597;</th>
					<th class="small-text">Test Result Name &#8597;</th>
					<th class="small-text">Test Result Status &#8597;</th>
					<th class="small-text">Result Value &#8597;</th>
					<th class="small-text">Flag &#8597;</th>
					<th class="small-text">Reference Range &#8597;</th>
					<th class="small-text">Units &#8597;</th>
					<th class="small-text">Nature of Abnormal Test &#8597;</th>
					<th class="small-text">Notes &#8597;</th>
					<th class="small-text">Attachments &#8597;</th>
					<th class="small-text">Full Report &#8597;</th>
					<th class="small-text">Ordering Provider &#8597;</th>
					<th class="hidden">Placer Group</th>
					<th class="hidden">ZBR.11</th>
					<th class="hidden">Request Sort Key</th>
					<th class="hidden">Request Alternate Name</th>
					<th class="hidden">ZBX.2</th>
					<th class="hidden">Result Sort Key</th>
					<th class="hidden">Alternate Name</th>
					<th class="hidden">Set Id</th>
					<th class="hidden">Sub Id</th>

				</tr>
				</thead>
				<tbody>
				<% for (OlisMeasurementsResultDisplay measurementDisplay : olisLabResults.getAllMeasurements()) {
					OlisLabResultDisplay parentLab = measurementDisplay.getParentLab();
					String valueDisplayClass = "";
					if (measurementDisplay.isAbnormal()) {
					    valueDisplayClass = "abnormal";
					}
					String statusDisplayClass = "";
					if (measurementDisplay.isInvalid() || measurementDisplay.getStatus().equalsIgnoreCase("Amended")) {
						statusDisplayClass = "abnormal";
					}
					String lineThroughCss = measurementDisplay.isInvalid() ? "line-through" : "";
				%>
				<tr firstName="<%=parentLab.getPatientFirstName()%>" lastName="<%=parentLab.getPatientLastName()%>"
					hcn="<%=parentLab.getPatientHcn()%>" labName="<%=parentLab.getLabName()%>"
					category="<%=parentLab.getCategory()%>" requestStatus="<%=parentLab.getRequestStatus()%>"
					orderingPractitioner="<%=parentLab.getOrderingPractitioner()%>" ccPractitioners="<%=parentLab.getCcPractitioners()%>"
					admittingPractitioner="<%=parentLab.getAdmittingPractitioner()%>" attendingPractitioner="<%=parentLab.getAttendingPractitioner()%>"
					reportingLab="<%=parentLab.getReportingFacilityName()%>" performingLab="<%=parentLab.getPerformingFacilityName()%>"
					resultStatus="<%=measurementDisplay.getStatus()%>" abnormal="<%=measurementDisplay.isAbnormal() ? "A" : "N"%>">
					<td>
                        <%=parentLab.getOlisLastUpdated()%>
                        <% if (measurementDisplay.isBlocked() && !olisLabResults.isHasPatientLevelBlock()) { %>
                        <span class="patient-consent-alert">Do not disclose without express patient consent</span>
                        <% } %>
                    </td>
					<td>
						<% if (parentLab.getTestRequestName().length() > 40) { %>
						<span title="<%=parentLab.getTestRequestName()%>">
							<%=parentLab.getTestRequestName().substring(0, 40)%>...
						</span>
						<% } else { %>
						<%=parentLab.getTestRequestName()%>
						<% } %>
					</td>
					<td><%=parentLab.getRequestStatus()%></td>
					<td><%=parentLab.getSpecimenType()%></td>
					<td><%=parentLab.getCollectionDate()%></td>
					<td class="monospaced">
						<%=parentLab.getCollectorsComment()%>
					</td>
					<td class="<%=lineThroughCss%>"><%=measurementDisplay.getTestResultName()%></td>
					<td class="<%=statusDisplayClass%>"><%=measurementDisplay.getStatus() != null && measurementDisplay.getStatus().isEmpty() ? "Final" : measurementDisplay.getStatus()%></td>
					<td class="<%=valueDisplayClass%> <%=lineThroughCss%>">
						<%=OLISUtils.Hl7EncodedRepeatableCharacter.performReplacement(measurementDisplay.getResultValue(), true)%>
						<% if(measurementDisplay.isAttachment()) { %>
							** Test result has an attachment **
						<% } %>
					</td>
					<td class="<%=valueDisplayClass%> <%=lineThroughCss%>"><%=measurementDisplay.getFlag()%></td>
					<td class="<%=valueDisplayClass%> <%=lineThroughCss%>"><%=measurementDisplay.getReferenceRange()%></td>
					<td class="<%=valueDisplayClass%> <%=lineThroughCss%>"><%=measurementDisplay.getUnits()%></td>
					<td class="<%=valueDisplayClass%> <%=lineThroughCss%>"><%=measurementDisplay.getNatureOfAbnormalText()%></td>
					<td>
						<%
							StringBuilder comments = new StringBuilder();
							for (String comment : measurementDisplay.getComments()) {
								comments.append(comment).append("<br/>");
							}
							if (!comments.toString().isEmpty()) { %>

						<a href="#" onclick="popupNotesWindow(jQuery('#measurementNotes<%=parentLab.getLabUuid()%>_<%=parentLab.getLabObrIndex()%>_<%=measurementDisplay.getMeasurementObxIndex()%>'));">view notes</a>
						<div style="display: none" id="measurementNotes<%=parentLab.getLabUuid()%>_<%=parentLab.getLabObrIndex()%>_<%=measurementDisplay.getMeasurementObxIndex()%>"><%=comments.toString()%></div>
						<%  } %>
					</td>
					<td>
						<% if (measurementDisplay.isAttachment()) { %>
						<a href="../lab/CA/ALL/PrintOLIS.do?uuid=<%=parentLab.getLabUuid()%>&obr=<%=parentLab.getLabObrIndex()%>&obx=<%=measurementDisplay.getMeasurementObxIndex()%>">
							View
						</a>
						<% } %>
					</td>
					<td>
						<input type="button" onClick="preview('<%=parentLab.getLabUuid()%>'); return false;" id="<%=parentLab.getLabUuid()%>_preview" value="View" />
					</td>
					<td><%=parentLab.getOrderingPractitionerFull()%></td>
					<td class="hidden"><%=parentLab.getPlacerGroupNo()%></td>
					<td class="hidden"><%=parentLab.getTestRequestZbr11()%></td>
					<td class="hidden"><%=parentLab.getNomenclature().getSortKey()%></td>
					<td class="hidden"><%=parentLab.getNomenclature().getRequestAlternateName1()%></td>
					<td class="hidden"><%=measurementDisplay.getResultSortable().getZbxSortKey()%></td>
					<td class="hidden"><%=measurementDisplay.getResultSortable().getNomenclatureSortKey()%></td>
					<td class="hidden"><%=measurementDisplay.getResultSortable().getAlternateName()%></td>
					<td class="hidden"><%=measurementDisplay.getResultSortable().getSetId()%></td>
					<td class="hidden"><%=measurementDisplay.getResultSortable().getSubId()%></td>
				</tr>
				<% } %>
				</tbody>
			</table>
			<div class="measurementsDisplayPager" style="float: right;">
				<img src="<%=request.getContextPath()%>/css/tablesorter/icons/first.png" class="first"/>
				<img src="<%=request.getContextPath()%>/css/tablesorter/icons/prev.png" class="prev"/>
				<span class="pagedisplay"></span>
				<img src="<%=request.getContextPath()%>/css/tablesorter/icons/next.png" class="next"/>
				<img src="<%=request.getContextPath()%>/css/tablesorter/icons/last.png" class="last"/>
			</div>
			<% if (olisLabResults.getContinuationPointer() != null) { %>
			<label style="float: right">
				<button title="More results are available, click here to load" onclick="loadMoreResults()">Load More Results</button>
			</label>
			<% } %>
		</td>
	</tr>
	<tr>
		<td colspan="3" align="center">
			<input type="button" value="Back" onclick="window.location = 'Search.jsp'"/>
		</td>
	</tr>
	</tbody>
</table>
<form style="display: none" id="loadMoreResultsForm" action="<%=request.getContextPath()%>/olis/Search.do">
	<input name="method" value="loadMoreResults"/>
	<input name="queryUsedUuid" value="<%=olisLabResults.getQueryUsedUuid()%>"/>
	<input name="currentViewUuid" value="<%=request.getAttribute("currentViewUuid")%>"/>
</form>
<script type="application/javascript">
    jQuery("#resultsSummaryTable").tablesorter({
        sortList:[]
    }).tablesorterPager({
        container: jQuery(".resultsSummaryPager"),
        ajaxUrl: null,
        ajaxProcessing: function(ajax) {
            if (ajax && ajax.hasOwnProperty('data')) {
                return [ajax.data, ajax.total_rows];
            }
        },
        output: '{startRow} - {endRow} of {totalRows} items',
        updateArrows: true,
        page: 0,
        size: 25,
        fixedHeight: false,
        removeRows: false,
        cssNext: '.next',
        cssPrev: '.prev',
        cssFirst: '.first',
        cssLast: '.last',
        cssGoto: '.gotoPage',
        cssPageDisplay: '.pagedisplay',
        cssPageSize: '.pagesize',
        cssDisabled: 'disabled'
    });
    jQuery("#measurementsDetailTable").tablesorter({
        sortList:[]
    }).tablesorterPager({
        container: jQuery(".measurementsDisplayPager"),
        ajaxUrl: null,
        ajaxProcessing: function(ajax) {
            if (ajax && ajax.hasOwnProperty('data')) {
                return [ajax.data, ajax.total_rows];
            }
        },
        output: '{startRow} - {endRow} of {totalRows} items',
        updateArrows: true,
        page: 0,
        size: 25,
        fixedHeight: false,
        removeRows: false,
        cssNext: '.next',
        cssPrev: '.prev',
        cssFirst: '.first',
        cssLast: '.last',
        cssGoto: '.gotoPage',
        cssPageDisplay: '.pagedisplay',
        cssPageSize: '.pagesize',
        cssDisabled: 'disabled'
    });
</script>
</body>
</html>
