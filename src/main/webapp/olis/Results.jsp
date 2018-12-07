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
	}
	var performFilter = function() {
		var visible = (labFilter == "" || jQuery(this).attr("reportingLaboratory") == labFilter);
		if (visible) { jQuery(this).show(); }
		else { jQuery(this).hide(); }
	};
	jQuery("#resultsSummaryTable tbody tr").each(performFilter);
}

function resetSorting() {
    jQuery("#resultsSummaryTable").trigger("sorton", [[[7, 1], [11, 0], [12, 0]]]);
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
	}
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
</style>
	
<title>OLIS Search Results</title>
</head>
<body>
<%
	OlisLabResults olisLabResults = (OlisLabResults) request.getAttribute("olisLabResults");
	String olisResultFileUuid = (String) request.getAttribute("olisResultFileUuid");
	request.setAttribute("olisResultFileUuid", olisResultFileUuid);
%>
<table style="width:600px;" class="MainTable" align="left">
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
		<td>
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
			<% } %>
		</td>
	</tr>
	<tr>
		<td colspan="2" id="labsDisplay">
			<% 
			List<String> resultList = (List<String>) request.getAttribute("resultList");
			List<OlisLabResultDisplay> olisResultList = olisLabResults.getResultList();
			
			if (olisResultList.size() > 0) { %>
			<div class="resultsSummaryPager" style="padding: 0;">
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
				<label>Jump to page
					<select class="gotoPage" title="Select page number"></select>
				</label>
				<label>Results per page
					<select class="pagesize" title="Select page size">
						<option value="10">10</option>
						<option selected="selected" value="20">20</option>
						<option value="30">30</option>
						<option value="40">40</option>
					</select>
				</label>
				<div style="float: right">
					<img src="<%=request.getContextPath()%>/css/tablesorter/icons/first.png" class="first"/>
					<img src="<%=request.getContextPath()%>/css/tablesorter/icons/prev.png" class="prev"/>
					<span class="pagedisplay"></span>
					<img src="<%=request.getContextPath()%>/css/tablesorter/icons/next.png" class="next"/>
					<img src="<%=request.getContextPath()%>/css/tablesorter/icons/last.png" class="last"/>
				</div>
			</div>
			<table style="min-width: 1200px;" id="resultsSummaryTable" class="resultsTable tablesorter">
				<thead>
				<tr>
					<th style="min-width: 175px;">Actions</th>
					<th>Test Requst Name &#8597;</th>
					<th>Specimen Type &#8597;</th>
					<th>Collection Date/Time &#8597;</th>
					<th>Last Updated in OLIS &#8597;</th>
					<th>Results Indicator &#8597;</th>
					<th>Ordering Practitioner &#8597;</th>
					<th>Admitting Practitioner &#8597;</th>
					<th class="hidden">Placer Group</th>
					<th class="hidden">Test Request Sort Key</th>
				</tr>
				</thead>
				<tbody>
				<% for (OlisLabResultDisplay resultDisplay : olisResultList) { 
					String resultUuid = resultDisplay.getLabUuid();%>
				<tr reportingLaboratory="<%=resultDisplay.getReportingFacilityName()%>">
					<td>
						<div id="<%=resultUuid%>_result"></div>
						<input type="button" onClick="addToInbox('<%=resultUuid %>'); return false;" id="<%=resultUuid %>" value="Add to Inbox" />
						<input type="button" onClick="preview('<%=resultUuid %>'); return false;" id="<%=resultUuid %>_preview" value="Preview" />
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
			<div class="resultsSummaryPager" style="float: right;">
				<img src="<%=request.getContextPath()%>/css/tablesorter/icons/first.png" class="first"/>
				<img src="<%=request.getContextPath()%>/css/tablesorter/icons/prev.png" class="prev"/>
				<span class="pagedisplay"></span>
				<img src="<%=request.getContextPath()%>/css/tablesorter/icons/next.png" class="next"/>
				<img src="<%=request.getContextPath()%>/css/tablesorter/icons/last.png" class="last"/>
			</div>
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
						<option selected="selected" value="20">20</option>
						<option value="30">30</option>
						<option value="40">40</option>
					</select>
				</label>
				<div style="float: right">
					<img src="<%=request.getContextPath()%>/css/tablesorter/icons/first.png" class="first"/>
					<img src="<%=request.getContextPath()%>/css/tablesorter/icons/prev.png" class="prev"/>
					<span class="pagedisplay"></span>
					<img src="<%=request.getContextPath()%>/css/tablesorter/icons/next.png" class="next"/>
					<img src="<%=request.getContextPath()%>/css/tablesorter/icons/last.png" class="last"/>
				</div>
			</div>
			<table style="min-width: 1200px;"  id="measurementsDetailTable" class="resultsTable tablesorter">
				<thead>
				<tr>
					<th class="small-text" style="min-width: 75px;">Last Updated In OLIS &#8597;</th>
					<th class="small-text">Test Request Name &#8597;</th>
					<th class="small-text">Status &#8597;</th>
					<th class="small-text">Specimen Type &#8597;</th>
					<th class="small-text" style="min-width: 75px;">Collection Date/Time &#8597;</th>
					<th class="small-text">Collector's Comments &#8597;</th>
					<th class="small-text">Test Result Name &#8597;</th>
					<th class="small-text">Status &#8597;</th>
					<th class="small-text">Result Value &#8597;</th>
					<th class="small-text">Flag &#8597;</th>
					<th class="small-text">Reference Range &#8597;</th>
					<th class="small-text">Units &#8597;</th>
					<th class="small-text">Nature of Abnormal Test &#8597;</th>
					<th class="small-text">Notes &#8597;</th>
					<th class="small-text">Attachments &#8597;</th>
					<th class="small-text">Full Report &#8597;</th>
					<th class="small-text">Ordering Provider &#8597;</th>
				</tr>
				</thead>
				<tbody>
				<% for (OlisMeasurementsResultDisplay measurementDisplay : olisLabResults.getAllMeasurements()) {
					OlisLabResultDisplay parentLab = measurementDisplay.getParentLab();
					String valueDisplayClass = "";
					if (measurementDisplay.isAbnormal()) {
					    valueDisplayClass = "abnormal";
					}
				%>
				<tr>
					<td><%=parentLab.getOlisLastUpdated()%></td>
					<td>
						<% if (parentLab.getTestRequestName().length() > 40) { %>
						<span title="<%=parentLab.getTestRequestName()%>">
							<%=parentLab.getTestRequestName().substring(0, 40)%>...
						</span>
						<% } else { %>
						<%=parentLab.getTestRequestName()%>
						<% } %>
					</td>
					<td><%=parentLab.getStatus()%></td>
					<td><%=parentLab.getSpecimenType()%></td>
					<td><%=parentLab.getCollectionDate()%></td>
					<td>
						<% if (parentLab.getCollectorsComment().length() > 20) { %>
						<span title="<%=parentLab.getCollectorsComment()%>">
							<%=parentLab.getCollectorsComment().substring(0, 20)%>...
						</span>
						<% } else { %>
						<%=parentLab.getCollectorsComment()%>
						<% } %>
					</td>
					<td><%=measurementDisplay.getTestResultName()%></td>
					<td><%=measurementDisplay.getStatus()%></td>
					<td class="<%=valueDisplayClass%>">
						<% if (measurementDisplay.getResultValue().length() > 30) { %>
						<span title="<%=measurementDisplay.getResultValue()%>">
							<%=measurementDisplay.getResultValue().substring(0, 30)%>...
						</span>
						<% } else { %>
						<%=measurementDisplay.getResultValue()%>
						<% } %>
					</td>
					<td class="<%=valueDisplayClass%>"><%=measurementDisplay.getFlag()%></td>
					<td class="<%=valueDisplayClass%>"><%=measurementDisplay.getReferenceRange()%></td>
					<td class="<%=valueDisplayClass%>"><%=measurementDisplay.getUnits()%></td>
					<td class="<%=valueDisplayClass%>"><%=measurementDisplay.getNatureOfAbnormalText()%></td>
					<td>
						<% 
						StringBuilder comments = new StringBuilder();
						for (String comment : measurementDisplay.getComments()) {
							comments.append(comment).append("<br/>");
						}
						if (comments.length() > 30) { %>
						<span title="<%=comments.toString()%>">
							<%=comments.toString().substring(0, 30)%>...
						</span>
						<% } else { %>
						<%=comments.toString()%>
						<% } %>
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
		</td>
	</tbody>
</table>
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
        size: 20,
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
        size: 20,
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
<!-- RAW HL7 ERP
<%=request.getAttribute("unsignedResponse") %>
-->
</body>
</html>
