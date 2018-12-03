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
<%@ page import="org.oscarehr.olis.model.OlisLabResultListDisplay" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<script type="text/javascript" src="<%= request.getContextPath() %>/js/global.js"></script>
<script type="text/javascript" src="<%=request.getContextPath()%>/js/jquery.js"></script>
<script type="text/javascript" src="<%= request.getContextPath() %>/js/jquery.tablesorter.js"></script>
<script type="text/javascript">
    jQuery.noConflict();
</script>
<link rel="stylesheet" type="text/css" href="<%=request.getContextPath()%>/share/css/OscarStandardLayout.css">
<script type="text/javascript" src="<%=request.getContextPath()%>/share/javascript/Oscar.js"></script>
<script type="text/javascript" src="<%=request.getContextPath()%>/share/javascript/oscarMDSIndex.js"></script>
	
<script type="text/javascript">
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

var patientFilter = "";
var labFilter = "";
function filterResults(select) {
	if (select.name == "labFilter") {
		labFilter = select.value;
	} else if(select.name == "patientFilter") {
		patientFilter = select.value;
	}
	var performFilter = function() {
		var visible = (patientFilter == "" || jQuery(this).attr("patientName") == patientFilter)
				   && (labFilter == "" || jQuery(this).attr("reportingLaboratory") == labFilter);
		if (visible) { jQuery(this).show(); }
		else { jQuery(this).hide(); }
	};
	jQuery("#resultsSummaryTable tbody tr").each(performFilter);
}

function resetSorting() {
    jQuery("#resultsSummaryTable").trigger("sorton", [ [[11, 0],[12, 0]] ]);
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
#resultsSummaryTable {
	border-collapse: collapse;
}
#resultsSummaryTable thead tr th, #resultsSummaryTable tbody tr td {
	border-right: solid 1px #444444;
	border-left: solid 1px #444444;
	padding: 3px;
}
#resultsSummaryTable tbody tr:last-child td {
	border-bottom: solid 1px #444444;
}
#resultsSummaryTable thead tr {
	background-color: #9999CC;
}
#resultsSummaryTable tbody tr:nth-child(even) {
	background-color: #CCCCCC;
}
#resultsSummaryTable td.hidden, #resultsSummaryTable th.hidden {
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
</style>
	
<title>OLIS Search Results</title>
</head>
<body>
<%
	OlisLabResults olisLabResults = (OlisLabResults) request.getAttribute("olisLabResults");
%>
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
					<td class="info"><%=olisLabResults.getDemographicName()%></td>
					<td class="label">Health Card Number:</td>
					<td class="info"><%=olisLabResults.getDemographicHin()%></td>
				</tr>
				<tr>
					<td class="label">Sex:</td>
					<td class="info"><%=sex%></td>
					<td class="label">Date of Birth:</td>
					<td class="info"><%=olisLabResults.getDemographicDob()%></td>
				</tr>
				<tr>
					<td class="label">Medical Record Number:</td>
					<td colspan="3" class="info"><%=olisLabResults.getDemographicMrn()%></td>
				</tr>
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
			List<OLISError> errors = olisLabResults.getErrors();
			for (OLISError error : errors) {
			%>
				<div class="error"><%=error.getIndentifer()%>:<%=error.getText().replaceAll("\\n", "<br />")%></div>
			<%
			}
			if (olisLabResults.isHasBlockedContent()) { 
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
			List<OlisLabResultListDisplay> olisResultList = olisLabResults.getResultList();
			
			if (olisResultList.size() > 0) { %>
			<p style="margin: 0">Showing <%=olisResultList.size() %> result(s)</p>
			<div>
				Filter by reporting laboratory:
				<select name="labFilter" onChange="filterResults(this)">
					<option value="">All Labs</option>
					<%  List<String> labs = new ArrayList<String>();
						OLISHL7Handler result;
						String name;
						for (String resultUuid : resultList) {
							result = OLISResultsAction.searchResultsMap.get(resultUuid);
							name = oscar.Misc.getStr(result.getReportingFacilityName(), "").trim();
							if (!name.equals("")) { labs.add(name); }
						}
						for (String tmp: new HashSet<String>(labs)) {
					%>
					<option value="<%=tmp%>"><%=tmp%></option>
					<% } %>
				</select>
				<input type="button" onclick="resetSorting(); return false;" value="Reset Sorting">
			</div>
			<table style="min-width: 1200px;" id="resultsSummaryTable" class="tablesorter">
				<thead>
				<tr>
					<th style="min-width: 175px;">Actions</th>
					<th>Test Requst Name &#8597;</th>
					<th>Status &#8597;</th>
					<th>Specimen Type &#8597;</th>
					<th>Collection Date/Time &#8597;</th>
					<th>Results Indicator &#8597;</th>
					<th>Ordering Practitioner &#8597;</th>
					<th>Admitting Practitioner &#8597;</th>
					<th class="hidden">Placer Group</th>
					<th class="hidden">Test Request Sort Key</th>
				</tr>
				</thead>
				<tbody>
				<% for (OlisLabResultListDisplay resultDisplay : olisResultList) { 
					String resultUuid = resultDisplay.getLabUuid();%>
				<tr patientName="<%=resultDisplay.getPatientName()%>" reportingLaboratory="<%=resultDisplay.getReportingFacilityName()%>">
					<td>
						<div id="<%=resultUuid%>_result"></div>
						<input type="button" onClick="addToInbox('<%=resultUuid %>'); return false;" id="<%=resultUuid %>" value="Add to Inbox" />
						<input type="button" onClick="preview('<%=resultUuid %>', '<%=resultDisplay.getLabObrIndex()%>'); return false;" id="<%=resultUuid %>_preview" value="Preview" />
					</td>
					<td>
						<% if (resultDisplay.getTestRequestName().length() > 40) { %>
						<span title="<%=resultDisplay.getTestRequestName()%>">
							<%=resultDisplay.getTestRequestName().substring(0, 40)%>...
						</span>
						<% } else { %>
						<%=resultDisplay.getTestRequestName()%>
						<% } %>
					</td>
					<td><%=resultDisplay.getStatus()%></td>
					<td><%=resultDisplay.getSpecimentType()%></td>
					<td><%=resultDisplay.getCollectionDate()%></td>
					<td>
						<% if (resultDisplay.getResultsIndicator().length() > 40) { %>
						<span title="<%=resultDisplay.getResultsIndicator()%>">
							<%=resultDisplay.getResultsIndicator().substring(0, 40)%>...
						</span>
						<% } else { %>
						<%=resultDisplay.getResultsIndicator()%>
						<% } %>
					</td>
					<td><%=resultDisplay.getOrderingPractitioner()%></td>
					<td><%=resultDisplay.getAdmittingPractitioner()%></td>
					<td class="hidden"><%=resultDisplay.getPlacerGroupNo()%></td>
					<td class="hidden"><%=resultDisplay.getTestRequestSortKey()%></td>
				</tr>
				<% } %>
				</tbody>
			</table>
			<% } %>
		</td>
	</tr></tbody>
</table>
<script type="application/javascript">
    jQuery("#resultsSummaryTable").tablesorter({
        sortList:[]
    });
</script>
<!-- RAW HL7 ERP
<%=request.getAttribute("unsignedResponse") %>
-->
</body>
</html>
