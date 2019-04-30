<%--

    Copyright (c) 2008-2012 Indivica Inc.

    This software is made available under the terms of the
    GNU General Public License, Version 2, 1991 (GPLv2).
    License details are available via "indivica.ca/gplv2"
    and "gnu.org/licenses/gpl-2.0.html".

--%>
<%@page contentType="text/html"%>
	<%@page import="java.util.*,org.oscarehr.common.dao.DemographicDao, 
		org.oscarehr.common.model.Demographic, org.oscarehr.PMmodule.dao.ProviderDao, org.oscarehr.common.model.Provider,
		org.oscarehr.olis.dao.OLISRequestNomenclatureDao, org.oscarehr.olis.dao.OLISResultNomenclatureDao,
		org.oscarehr.olis.model.OLISRequestNomenclature, org.oscarehr.olis.model.OLISResultNomenclature, org.oscarehr.util.SpringUtils" %>
	<%@page import="org.oscarehr.common.dao.UserPropertyDAO" %>
	<%@page import="org.oscarehr.common.model.UserProperty" %>
	<%@page import="org.oscarehr.util.LoggedInInfo" %>
<%@ page import="org.apache.commons.lang.StringUtils" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="org.oscarehr.olis.dao.OLISFacilitiesDao" %>
<%@ page import="org.oscarehr.olis.model.OLISFacilities" %>
<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean"%>
	<%@ taglib uri="/WEB-INF/oscar-tag.tld" prefix="oscar"%>

	<% 
	if(session.getValue("user") == null) response.sendRedirect("../../logout.jsp");
	LoggedInInfo loggedInInfo=LoggedInInfo.getLoggedInInfoFromSession(request);

		String requestingHic = loggedInInfo.getLoggedInProviderNo();

		OLISFacilitiesDao olisFacilitiesDao = SpringUtils.getBean(OLISFacilitiesDao.class);
		List<OLISFacilities> facilities = olisFacilitiesDao.getAll();
	%>


	<%
	String outcome = (String) request.getAttribute("outcome");
	if(outcome != null){
	    if(outcome.equalsIgnoreCase("success")){
	%><script type="text/javascript">alert("Lab uploaded successfully");opener.refreshView();</script>
	<%
	    }else if(outcome.equalsIgnoreCase("uploaded previously")){
	%><script type="text/javascript">alert("Lab has already been uploaded");</script>
	<%    
	    }else if(outcome.equalsIgnoreCase("exception")){
	%><script type="text/javascript">alert("Exception uploading the lab");</script>
	<%
	    }else{
	%><script type="text/javascript">alert("Failed to upload lab");</script>
	<%
	    }
	}

	%>
	


	<html>
	<head>
	<script type="text/javascript" src="<%= request.getContextPath() %>/js/global.js"></script>
	<script type="text/javascript" src="<%= request.getContextPath() %>/js/jquery-1.9.1.js"></script>
	<script type="text/javascript" src="<%= request.getContextPath() %>/js/jquery-ui/1.12.1-jquery-ui.js"></script>
	
		
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<title><bean:message key="olis.olisSearch" /></title>
	<link rel="stylesheet" type="text/css" href="../../../share/css/OscarStandardLayout.css">
	<link rel="stylesheet" type="text/css" href="../share/css/OscarStandardLayout.css">
	<link rel="stylesheet" type="text/css" href="../css/jquery-ui/1.12.1-jquery-ui.css">
	<script type="text/javascript" src="../../../share/javascript/Oscar.js"></script>
	<script type="text/javascript" src="../share/javascript/Oscar.js"></script>
	
	<script type="text/javascript" src="../share/yui/js/yahoo-dom-event.js"></script>
        <script type="text/javascript" src="../share/yui/js/connection-min.js"></script>
        <script type="text/javascript" src="../share/yui/js/animation-min.js"></script>
        <script type="text/javascript" src="../share/yui/js/datasource-min.js"></script>
        <script type="text/javascript" src="../share/yui/js/autocomplete-min.js"></script>
        <script type="text/javascript" src="../js/demographicProviderAutocomplete.js"></script>
        <script type="text/javascript" src="../js/OlisRequestResultTypeaheads.js"></script>

        <link rel="stylesheet" type="text/css" href="../share/yui/css/fonts-min.css"/>
        <link rel="stylesheet" type="text/css" href="../share/yui/css/autocomplete.css"/>
	
	
	<script type="text/javascript">
		    function selectOther(){                
		        if (document.UPLOAD.type.value == "OTHER")
		            document.getElementById('OTHER').style.visibility = "visible";
		        else
		            document.getElementById('OTHER').style.visibility = "hidden";                
		    }
		    
		    function checkInput(){
		        if (document.UPLOAD.lab.value ==""){
		            alert("Please select a lab for upload");
		            return false;
		        }else if (document.UPLOAD.type.value == "OTHER" && document.UPLOAD.otherType.value == ""){
		            alert("Please specify the other message type");
		            return false;
		        }else{
		            var lab = document.UPLOAD.lab.value;
		            var ext = lab.substring((lab.length - 3), lab.length);
		            if (ext != 'hl7' && ext != 'xml'){
		                alert("Error: The lab must be either a .xml or .hl7 file");
		                return false;
		            }
		        }
		        return true;
		    }
		    
		    function checkBlockedConsent(form) {
		    	value = document.forms[form + "_form"].blockedInformationConsent;
		    	if (value != null && value == "Z") {
		    		return confirm("You have chosen to view blocked information.  This action is recorded in the audit log.  Are you sure?")
		    	}
		    	return true;
		    }
		</script>
		
		<style type="text/css">
		table {
			font-size: 12px;
			width: 1000px;
		}
	
		table.innerTable {
			width: 600px;
		}
	
		table.smallTable {
			width: 300px;
		}
	
		th {
			text-align: right;
			font-size: 14px;
		}
	
		td span {
			font-size: 14px;
			font-weight: bold;
		}
	
		input {
			width: 120px;
		}
	
		input.checkbox {
			width: auto;
		}
	</style>
	 <style type="text/css">
#myAutoComplete {
    width:15em; /* set width here or else widget will expand to fit its container */
    padding-bottom:2em;
}




        .yui-ac {
	    position:relative;font-family:arial;font-size:100%;
	}

	/* styles for input field */
	.yui-ac-input {
	    position:relative;width:100%;
	}

	/* styles for results container */
	.yui-ac-container {
	    position:absolute;top:0em;width:100%;
	}

	/* styles for header/body/footer wrapper within container */
	.yui-ac-content {
	    position:absolute;width:100%;border:1px solid #808080;background:#fff;overflow:hidden;z-index:9050;
	}

	/* styles for container shadow */
	.yui-ac-shadow {
	    position:absolute;margin:.0em;width:100%;background:#000;-moz-opacity: 0.10;opacity:.10;filter:alpha(opacity=10);z-index:9049;
	}

	/* styles for results list */
	.yui-ac-content ul{
	    margin:0;padding:0;width:100%;
	}

	/* styles for result item */
	.yui-ac-content li {
	    margin:0;padding:0px 0px;cursor:default;white-space:nowrap;
	}

	/* styles for prehighlighted result item */
	.yui-ac-content li.yui-ac-prehighlight {
	    background:#B3D4FF;
	}

	/* styles for highlighted result item */
	.yui-ac-content li.yui-ac-highlight {
	    background:#426FD9;color:#FFF;
	}

	.footer-table {
		padding-top: 20px;
	}
	
	.footer-table tr th {
		width: 7.5%;
		text-align: center;
	}
	
	.footer-table tr td {
		vertical-align: top;
		padding: 0 5px;
	}

	.footer-table tr td textarea {
		margin-top: 5px;
		height: 50px;
	}
	
	.footer-table tr td input,
	.footer-table tr td select,
	.footer-table tr td textarea {
		width: 100%;
	}
		 
</style>
	
	</head>

	<body>
	
	<table style="width:600px;" class="MainTable" align="left">
		<tbody><tr class="MainTableTopRow">
			<td class="MainTableTopRowLeftColumn" width="175">OLIS</td>
			<td class="MainTableTopRowRightColumn">
			<table class="TopStatusBar">
				<tbody><tr>
					<td>Search</td>
					<td>&nbsp;</td>
					<td style="text-align: right"><a href="javascript:popupStart(300,400,'Help.jsp')"><u>H</u>elp</a> | <a href="javascript:popupStart(300,400,'About.jsp')">About</a> | <a href="javascript:popupStart(300,400,'License.jsp')">License</a></td>
				</tr>
				</tbody>
			</table>
			</td>
		</tr>
		<tr>
			<td colspan="2">

		
	<script type="text/javascript">
	var currentQuery = "Z01";

	function displaySearch(selectBox) {
		queryType = document.getElementById("queryType").value;
		if (document.getElementById(queryType + "_query") != null) {
			document.getElementById(currentQuery + "_query").style.display = "none";
			document.getElementById(queryType + "_query").style.display = "block";
			currentQuery = queryType;
		}
	
	}
	
	function setTimePeriod(timeSpan) {
	    let startDateElements = document.getElementsByName('startTimePeriod');
        let endDateElements = document.getElementsByName('endTimePeriod');
        let now = new Date();
        let then = new Date(now);
        let nowString = now.toISOString().slice(0, 10);
        let thenString = ''
		if (timeSpan === 'week') {
            then.setDate(then.getDate() - 7);
            thenString = then.toISOString().slice(0, 10);
		} else if (timeSpan === 'month') {
            then.setMonth(then.getMonth() - 1);
            thenString = then.toISOString().slice(0, 10);
		} else if (timeSpan === 'year') {
            then.setFullYear(then.getFullYear() - 1);
            then.setDate(then.getDate() + 1);
            thenString = then.toISOString().slice(0, 10);
        }

        endDateElements.forEach(function(endDateElement) {
            endDateElement.value = nowString;
        });
		startDateElements.forEach(function(startDateElement) {
            startDateElement.value = thenString;
        });
    }

	</script>



<%
	ProviderDao providerDao = (ProviderDao) SpringUtils.getBean("providerDao");
	List<Provider> allProvidersList = providerDao.getActiveProviders(); 
	List<Provider> olsiHicProvidersList = providerDao.getOlisHicProviders();

	String selectedDemographicNo = "";
	String selectedDemographicName = "";
	Demographic selectedDemographic = null;
	if (!StringUtils.isBlank(request.getParameter("demographicNo")) && StringUtils.isNumeric(request.getParameter("demographicNo"))) {
		DemographicDao demographicDao = SpringUtils.getBean(DemographicDao.class);
		selectedDemographic = demographicDao.getDemographicById(Integer.valueOf(request.getParameter("demographicNo")));
		selectedDemographicNo = String.valueOf(selectedDemographic.getDemographicNo());
		selectedDemographicName = selectedDemographic.getLastName() + ", " + selectedDemographic.getFirstName() + "(" + selectedDemographic.getBirthDayAsString() + ")";
	}

	OLISResultNomenclatureDao resultDao = (OLISResultNomenclatureDao) SpringUtils.getBean("OLISResultNomenclatureDao");
	List<OLISResultNomenclature> resultNomenclatureList = new ArrayList<OLISResultNomenclature>();//resultDao.findAll();

	OLISRequestNomenclatureDao requestDao = (OLISRequestNomenclatureDao) SpringUtils.getBean("OLISRequestNomenclatureDao");
	List<OLISRequestNomenclature> requestNomenclatureList = new ArrayList<OLISRequestNomenclature>();//requestDao.findAll();


	UserPropertyDAO upDao = (UserPropertyDAO)SpringUtils.getBean("UserPropertyDAO");
	String providerNo = loggedInInfo.getLoggedInProviderNo();
	UserProperty repLabProp = upDao.getProp(providerNo,"olis_reportingLab");
	UserProperty exRepLabProp = upDao.getProp(providerNo,"olis_exreportingLab");
	UserProperty datePeriodSearchInterval = upDao.getProp("olis_dateSearchInterval");

	String reportingLabVal = (repLabProp!=null)?repLabProp.getValue():"";
	String exReportingLabVal = (exRepLabProp!=null)?exRepLabProp.getValue():"";
	String startTimePeriod = "";
	String endTimePeriod = "";
	if (datePeriodSearchInterval != null) {
		SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
		Calendar cal = new GregorianCalendar();
		cal.setTime(new Date());
		endTimePeriod = sdf.format(cal.getTime());
		cal.add(Calendar.MONTH, -1 * Integer.parseInt(datePeriodSearchInterval.getValue()));
		startTimePeriod = sdf.format(cal.getTime());
	}
%>			

	<select id="queryType" onchange="displaySearch(this)" style="margin-left:30px;">
		<option value="Z01">Z01 - Retrieve Laboratory Information for Patient</option>
		<option value="Z02">Z02 - Retrieve Laboratory Information for Order ID</option>
		<oscar:oscarPropertiesCheck value="true" property="olis_enable_z04" defaultVal="false">
		<option value="Z04">Z04 - Retrieve Laboratory Information Updates for Practitioner</option>
		</oscar:oscarPropertiesCheck>
		<option value="Z05">Z05 - Retrieve Laboratory Information Updates for Destination Laboratory</option>
		<option value="Z06">Z06 - Retrieve Laboratory Information Updates for Ordering Facility</option>
		<option value="Z07">Z07 - Retrieve Test Results Reportable to Public Health</option>
		<option value="Z08">Z08 - Retrieve Test Results Reportable to Cancer Care Ontario</option>
		<option value="Z50">Z50 - Identify Patient by Name, Sex, and Date of Birth</option>
	</select>

	<form action="<%=request.getContextPath() %>/olis/Search.do?method=loadResults" method="POST" onSubmit="checkBlockedConsent('Z01')" name="Z01_form">
	<input type="hidden" name="queryType" value="Z01" />
	<table id="Z01_query">
		<tbody><tr>
			<td colspan=2><input type="submit" name="submit" value="Search" /></td>
		</tr>
		<tr>
			<th width="20%">Date &amp; Time Period to Search<br />(yyyy-mm-dd)</th>
			<td width="30%">
				<input style="width:150px" type="text" name="startTimePeriod" id="startTimePeriod" value="<%=startTimePeriod%>"> to 
				<input style="width:150px" name="endTimePeriod" type="text" id="endTimePeriod" value="<%=endTimePeriod%>">
				&nbsp;<input type="button" value="One Week Ago" onclick="setTimePeriod('week')"/>
				&nbsp;<input type="button" value="One Month Ago" onclick="setTimePeriod('month')"/>
				&nbsp;<input type="button" value="One Year Ago" onclick="setTimePeriod('year')"/>
			</td>
		</tr><tr>
			<th width="20%">Observation Date &amp; Time Period<br />(yyyy-mm-dd)</th>
			<td width="30%"><input style="width:150px;" type="text" name="observationStartTimePeriod" id="observationStartTimePeriod" > to <input style="width:150px" name="observationEndTimePeriod" type="text" id="observationEndTimePeriod" ></td>
		</tr>
		<tr>
			<th width="20%"><input class="checkbox" type="checkbox" name="quantityLimitedQuery" id="quantityLimitedQuery"> Quantity Limit?</th>
			<td width="30%">Quantity<br><input type="text" id="quantityLimit" name="quantityLimit"></td>
		</tr><tr>
			<th width="20%">Consent to View Blocked Information?</th>
			<td width="30%"><select id="blockedInformationConsent" name="blockedInformationConsent"><option value="">(none)</option>
			<option value="Z">Temporary </option>
			</select>
			&nbsp;&nbsp;Authorized by: <select name="blockedInformationIndividual" id="blockedInformationIndividual">
			<option value="patient">Patient</option><option value="substitute">Substitute Decision Maker</option><option value="">Neither</option>
			</select> 
			</td>
		</tr>
		<tr>
			<td width="20%" colspan=4><span><input class="checkbox" type="checkbox" name="consentBlockAllIndicator" id="consentBlockAllIndicator"> Enable Patient Consent Block-All Indicator?</span></td>
		</tr>
		<tr>
			<th width="20%">Specimen Collector</th>
			<td width="30%">
				<select id="specimenCollector" name="specimenCollector">
					<option value=""></option>
					<% for (OLISFacilities facility : facilities) { %>
					<option value="<%=facility.getFullId()%>" <%=(reportingLabVal.equals(facility.getId())?"selected=\"selected\"":"") %>>
						<%=facility.getId() + " - " + (facility.getName().length() <= 75 ? facility.getName() : facility.getName().substring(0, 75) + "...")%>
					</option>
					<% } %>
				</select>
			</td>
		</tr>
		<tr>
			<th width="20%">Performing Laboratory</th>
			<td width="30%">
				<select id="performingLaboratory" name="performingLaboratory">
					<option value=""></option>
					<% for (OLISFacilities facility : facilities) { %>
					<option value="<%=facility.getFullId()%>" <%=(reportingLabVal.equals(facility.getId())?"selected=\"selected\"":"") %>>
						<%=facility.getId() + " - " + (facility.getName().length() <= 75 ? facility.getName() : facility.getName().substring(0, 75) + "...")%>
					</option>
					<% } %>
				</select>
			</td>
		</tr>
		<tr>
			<th width="20%">Exclude Performing Laboratory</th>
			<td width="30%">
				<select id="excludePerformingLaboratory" name="excludePerformingLaboratory">
					<option value=""></option>
					<% for (OLISFacilities facility : facilities) { %>
					<option value="<%=facility.getFullId()%>" <%=(reportingLabVal.equals(facility.getId())?"selected=\"selected\"":"") %>>
						<%=facility.getId() + " - " + (facility.getName().length() <= 75 ? facility.getName() : facility.getName().substring(0, 75) + "...")%>
					</option>
					<% } %>
				</select>
			</td>
		</tr>
		<tr>
			<th width="20%">Reporting Laboratory</th>
			<td colspan="3">
				<select id="reportingLaboratory" name="reportingLaboratory">
					<option value="" <%=(reportingLabVal.equals("")?"selected=\"selected\"":"") %>></option>
					<% for (OLISFacilities facility : facilities) { %>
					<option value="<%=facility.getFullId()%>" <%=(reportingLabVal.equals(facility.getId())?"selected=\"selected\"":"") %>>
						<%=facility.getId() + " - " + (facility.getName().length() <= 75 ? facility.getName() : facility.getName().substring(0, 75) + "...")%>
					</option>
					<% } %>
</select>
				<label>Placer Group:
					<input type="text" name="placerGroupNumber" id="placerGroupNumber" value=""/>
				</label>
</td>
		</tr>
<tr>
			<th width="20%">Exclude Reporting Laboratory</th>
			<td width="30%">
				<select id="excludeReportingLaboratory" name="excludeReportingLaboratory">
					<option value="" <%=(exReportingLabVal.equals("")?"selected=\"selected\"":"") %>></option>
					<% for (OLISFacilities facility : facilities) { %>
					<option value="<%=facility.getFullId()%>" <%=(reportingLabVal.equals(facility.getId())?"selected=\"selected\"":"") %>>
						<%=facility.getId() + " - " + (facility.getName().length() <= 75 ? facility.getName() : facility.getName().substring(0, 75) + "...")%>
					</option>
					<% } %>
</select>
</td>
		</tr>
		<tr>
			<td colspan=4><hr /></td>
		</tr>
		<tr>
			<td><span>Patient</span></td>
			<td> 
				<%String currentDocId="1"; %>
				<input type="hidden" name="demographic" id="demofind<%=currentDocId%>" value="<%=selectedDemographicNo%>"/>
                <input type="text" id="autocompletedemo<%=currentDocId%>" onchange="checkSave('<%=currentDocId%>')" name="demographicKeyword" value="<%=selectedDemographicName%>"/>
                <div id="autocomplete_choices<%=currentDocId%>"class="autocomplete"></div>

                <script type="text/javascript">       <%-- testDemocomp2.jsp    --%>
                //new Ajax.Autocompleter("autocompletedemo<%=currentDocId%>", "autocomplete_choices<%=currentDocId%>", "../demographic/SearchDemographic.do", {minChars: 3, afterUpdateElement: saveDemoId});


                YAHOO.example.BasicRemote = function() {
                        var url = "../demographic/SearchDemographic.do";
                        var oDS = new YAHOO.util.XHRDataSource(url,{connMethodPost:true,connXhrMode:'ignoreStaleResponses'});
                        oDS.responseType = YAHOO.util.XHRDataSource.TYPE_JSON;// Set the responseType
                        // Define the schema of the delimited resultsTEST, PATIENT(1985-06-15)
                        oDS.responseSchema = {
                            resultsList : "results",
                            fields : ["formattedName","fomattedDob","demographicNo","status"]
                        };

                        // Instantiate the AutoComplete
                        var oAC = new YAHOO.widget.AutoComplete("autocompletedemo<%=currentDocId%>", "autocomplete_choices<%=currentDocId%>", oDS);
                        oAC.queryMatchSubset = true;
                        oAC.minQueryLength = 3;
                        oAC.maxResultsDisplayed = 25;
                        oAC.formatResult = resultFormatter2;
                        //oAC.typeAhead = true;
                        oAC.queryMatchContains = true;
                        oAC.itemSelectEvent.subscribe(function(type, args) {
                           var str = args[0].getInputEl().id.replace("autocompletedemo","demofind");
                           document.getElementById(str).value = args[2][2];//li.id;
                           args[0].getInputEl().value = args[2][0] + "("+args[2][1]+")";
                           selectedDemos.push(args[0].getInputEl().value);
                           
                        });


                        return {
                            oDS: oDS,
                            oAC: oAC
                        };
                    }();



                </script>

		</td>
		</tr>	
		<tr>
			<td colspan=4><hr /></td>
		</tr>	
		<tr>
			<td><span>Requesting HIC</span></td>
			<td>
				<select name="requestingHic">
					<option value=""></option>
			<% for (Provider provider : olsiHicProvidersList) { %>
					<option value="<%=provider.getProviderNo() %>" <%=provider.getProviderNo().equals(requestingHic)?"selected":""%>>[<%=provider.getProviderNo()%>] <%=provider.getLastName() %>, <%=provider.getFirstName() %></option>
			<% } %>
				</select>
			</td>
		</tr>
		<tr>
			<td><hr></td>
		</tr>
		<tr>
			<th width="20%">Ordering Practitioner</th>
			<td>
				<select name="orderingPractitionerCpso" id="orderingPractitionerCpso">
					<option value=""></option>
			<% for (Provider provider : allProvidersList) { 
				if (!StringUtils.isEmpty(provider.getPractitionerNo())) { %>
					<option value="<%=provider.getPractitionerNo() %>">[<%=provider.getProviderNo()%>] <%=provider.getLastName() %>, <%=provider.getFirstName() %></option>
			<%  }
			} %>
				</select>
			</td>		
		</tr>
		<tr>
			<th width="20%">Copied-to Practitioner</th>
			<td>
				<select name="copiedToPractitionerCpso" id="copiedToPractitionerCpso">
					<option value=""></option>
				<% for (Provider provider : allProvidersList) {
					if (!StringUtils.isEmpty(provider.getPractitionerNo())) { %>
					<option value="<%=provider.getPractitionerNo() %>">[<%=provider.getProviderNo()%>] <%=provider.getLastName() %>, <%=provider.getFirstName() %></option>
				<%  }
				} %>
				</select>
			</td>		
		</tr>
		<tr>
			<th width="20%">Attending Practitioner</th>
			<td>
				<select name="attendingPractitionerCpso" id="attendingPractitionerCpso">
					<option value=""></option>
					<% for (Provider provider : allProvidersList) {
						if (!StringUtils.isEmpty(provider.getPractitionerNo())) { %>
					<option value="<%=provider.getPractitionerNo() %>">[<%=provider.getProviderNo()%>] <%=provider.getLastName() %>, <%=provider.getFirstName() %></option>
					<%  }
					} %>
				</select>
			</td>		
		</tr>
		<tr>
			<th width="20%">Admitting Practitioner</th>
			<td>
				<select name="admittingPractitionerCpso" id="admittingPractitionerCpso">
					<option value=""></option>
					<% for (Provider provider : allProvidersList) {
						if (!StringUtils.isEmpty(provider.getPractitionerNo())) { %>
					<option value="<%=provider.getPractitionerNo() %>">[<%=provider.getProviderNo()%>] <%=provider.getLastName() %>, <%=provider.getFirstName() %></option>
					<%  }
					} %>
				</select>
			</td>		
		</tr>
		<tr>
			<th width="20%">Test Request Placer</th>
			<td>
				<select id="test-request-placer" name="testRequestPlacer">
					<option></option>
					<% for (OLISFacilities facility : facilities) { %>
					<option value="<%=facility.getFullId()%>" <%=(reportingLabVal.equals(facility.getId())?"selected=\"selected\"":"") %>>
						<%=facility.getId() + " - " + (facility.getName().length() <= 75 ? facility.getName() : facility.getName().substring(0, 75) + "...")%>
					</option>
					<% } %>
				</select>
			</td>
		</tr>
		<tr>
			<td colspan="4">
				<table class="footer-table">
					<tbody>
						<tr>
							<th>Test Request Status (max. 15)</th>
							<th>Test Result Code (max. 200)</th>
							<th>Test Request Code (max. 100)</th>
						</tr>
						<tr>
							<td>
								<select multiple="multiple" id="testRequestStatus" name="testRequestStatus">
									<option value=""></option>
									<option value="O"> Order Received </option>
									<option value="I"> No results </option>
									<option value="P"> Preliminary </option>
									<option value="A"> Partial </option>
									<option value="F"> Final </option>
									<option value="C"> Correction </option>
									<option value="X"> Cancelled </option>
									<option value="E"> Expired  </option>
								</select>
							</td>
						<td>
							<input id="resultCodeSearch" type="text" name="resultCodeKeyword" placeholder="Search by result name" />
							<textarea id="result-codes" name="resultCodes" tabindex="-1"></textarea>
						</td>
						
						<td>
							<input id="requestCodeSearch" type="text" name="requestCodeSearch" placeholder="Search by request name" />
							<textarea id="request-codes" name="requestCodes" tabindex="-1"></textarea>
						</td>
					</tr>
				</tbody></table>
			</td>
		</tr>
		
		<tr>
			<td colspan=2><input type="submit" name="submit" value="Search" /></td>
		</tr>			
	</tbody></table>
	</form>



	<form action="<%=request.getContextPath() %>/olis/Search.do?method=loadResults" method="POST" onSubmit="checkBlockedConsent('Z02')" name="Z02_form">
	<input type="hidden" name="queryType" value="Z02" />
	<table id="Z02_query" style="display: none;">
		<tbody><tr>
			<td colspan=2><input type="submit" name="submit" value="Search" /></td>
		</tr>
		<tr>
			<td width="50%" colspan=2><span><input class="checkbox" type="checkbox" name="retrieveAllResults" id="retrieveAllResults"> Retrieve All Test Results?</span></td>
			<th width="20%">Consent to View Blocked Information?</th>
			<td width="30%"><select id="blockedInformationConsent" name="blockedInformationConsent"><option value="">(none)</option>
			<option value="Z">Temporary </option>
			</select>
			<br />Authorized by: <select name="blockedInformationIndividual" id="blockedInformationIndividual">
			<option value="patient">Patient</option><option value="substitute">Substitute Decision Maker</option><option value="">Neither</option>
			</select>
			</td>
		</tr>
		<tr>
			<td width="20%" colspan=4><span><input class="checkbox" type="checkbox" name="consentBlockAllIndicator" id="consentBlockAllIndicator"> Enable Patient Consent Block-All Indicator?</span></td>
		</tr>
		<tr>
			<td colspan=4><hr /></td>
		</tr>
		<tr>
			<td width="20%"><span>Patient</span></td>
			<td> 
			<%currentDocId="2"; %>
				<input type="hidden" name="demographic" id="demofind<%=currentDocId%>" />
                <input type="text" id="autocompletedemo<%=currentDocId%>" onchange="checkSave('<%=currentDocId%>')" name="demographicKeyword"  />
                <div id="autocomplete_choices<%=currentDocId%>"class="autocomplete"></div>

                <script type="text/javascript">       <%-- testDemocomp2.jsp    --%>
                //new Ajax.Autocompleter("autocompletedemo<%=currentDocId%>", "autocomplete_choices<%=currentDocId%>", "../demographic/SearchDemographic.do", {minChars: 3, afterUpdateElement: saveDemoId});


                YAHOO.example.BasicRemote = function() {
                        var url = "../demographic/SearchDemographic.do";
                        var oDS = new YAHOO.util.XHRDataSource(url,{connMethodPost:true,connXhrMode:'ignoreStaleResponses'});
                        oDS.responseType = YAHOO.util.XHRDataSource.TYPE_JSON;// Set the responseType
                        // Define the schema of the delimited resultsTEST, PATIENT(1985-06-15)
                        oDS.responseSchema = {
                            resultsList : "results",
                            fields : ["formattedName","fomattedDob","demographicNo","status"]
                        };

                        // Instantiate the AutoComplete
                        var oAC = new YAHOO.widget.AutoComplete("autocompletedemo<%=currentDocId%>", "autocomplete_choices<%=currentDocId%>", oDS);
                        oAC.queryMatchSubset = true;
                        oAC.minQueryLength = 3;
                        oAC.maxResultsDisplayed = 25;
                        oAC.formatResult = resultFormatter2;
                        //oAC.typeAhead = true;
                        oAC.queryMatchContains = true;
                        oAC.itemSelectEvent.subscribe(function(type, args) {
                           var str = args[0].getInputEl().id.replace("autocompletedemo","demofind");

                           document.getElementById(str).value = args[2][2];//li.id;
                           args[0].getInputEl().value = args[2][0] + "("+args[2][1]+")";
                           selectedDemos.push(args[0].getInputEl().value);
                           
                        });


                        return {
                            oDS: oDS,
                            oAC: oAC
                        };
                    }();



                </script>
			
			</td>
		</tr>
		<tr>
			<td colspan=4><hr /></td>
		</tr>
		<tr>
			<td width="20%"><span>Requesting HIC</span></td>
			<td><select name="requestingHic" id="requestingHic" size="8">
			
			<option value=""></option>
			<%
			for (Provider provider : allProvidersList) {
				%>
				<option value="<%=provider.getProviderNo() %>" <%=provider.getProviderNo().equals(requestingHic)?"selected":""%>>[<%=provider.getProviderNo()%>] <%=provider.getLastName() %>, <%=provider.getFirstName() %></option>
			<%	
			}
			%>
</select></td>		
		</tr>
		<tr>
			<td colspan=2><input type="submit" name="submit" value="Search" /></td>
		</tr>
		</tbody>
	</table>
	</form>



	<form action="<%=request.getContextPath() %>/olis/Search.do?method=loadResults" method="POST">
	<input type="hidden" name="queryType" value="Z04" />
	<table id="Z04_query" style="display: none;">
		<tbody>
		<tr>
			<td colspan=2><input type="submit" name="submit" value="Search" /></td>
		</tr>
		<tr>
			<th width="20%">Date &amp; Time Period to Search<br />(yyyy-mm-dd)</th>
			<td width="30%">
				<input style="width:150px" type="text" name="startTimePeriod" id="startTimePeriod" value="2011-01-01" >
				to 
				<input style="width:150px" name="endTimePeriod" type="text" id="endTimePeriod" value="2011-12-31">
				&nbsp;<input type="button" value="One Week Ago" onclick="setTimePeriod('week')"/>
				&nbsp;<input type="button" value="One Month Ago" onclick="setTimePeriod('month')"/>
				&nbsp;<input type="button" value="One Year Ago" onclick="setTimePeriod('year')"/>
			</td>
			<th width="20%"><input class="checkbox" type="checkbox" name="quantityLimitedQuery" id="quantityLimitedQuery"> Quantity Limit?</th>
			<td width="30%">Quantity<br><input type="text" id="quantityLimit" name="quantityLimit"></td>
		</tr>
		<tr>
			<td colspan=4><hr /></td>
		</tr>
		<tr>
			<td width="20%"><span>Requesting HIC</span></td><td><select multiple="multiple" name="requestingHic" id="requestingHic" size="8">
			
			<option value=""></option>
			<% for (Provider provider : allProvidersList) { %>
				<option value="<%=provider.getProviderNo() %>">[<%=provider.getProviderNo()%>] <%=provider.getLastName() %>, <%=provider.getFirstName() %></option>
			<% } %>
</select></td>		
		</tr>
		
		<tr>
			<td colspan="4"><hr></td>
		</tr>
		<tr>
			<td colspan="4">
				<table class="footer-table">
					<tbody>
					<tr>
						<th width="20%">Test Result Code (max. 200)</th>
						<th width="20%">Test Request Code (max. 100)</th>
					</tr>
					<tr>
						<td>
							<input id="resultCodeSearchZ04" type="text" name="resultCodeKeywordZ04" placeholder="Search by result name" />
							<textarea id="result-codes-Z04" name="resultCodes" tabindex="-1"></textarea>
						</td>
						<td>
							<input id="requestCodeSearchZ04" type="text" name="requestCodeSearchZ04" placeholder="Search by request name" />
							<textarea id="request-codes-Z04" name="requestCodes" tabindex="-1"></textarea>
						</td>
					</tr>
				</tbody></table>
			</td>
		</tr>
		<tr>
			<td colspan=2><input type="submit" name="submit" value="Search" /></td>
		</tr>
	</tbody></table>
	</form>
	
	
	
	<form action="<%=request.getContextPath() %>/olis/Search.do?method=loadResults" method="POST">
	<input type="hidden" name="queryType" value="Z05" />
	<table id="Z05_query" style="display: none;">
		<tbody>
		<tr>
			<td colspan=2><input type="submit" name="submit" value="Search" /></td>
		</tr>
		<tr>
			<th width="20%">Date &amp; Time Period to Search<br />(yyyy-mm-dd)</th>
			<td width="30%"><input style="width:150px" type="text" name="startTimePeriod" id="startTimePeriod" value="" > to <input style="width:150px" name="endTimePeriod" type="text" id="endTimePeriod" ></td>
			<th width="20%"><input class="checkbox" type="checkbox" name="quantityLimitedQuery" id="quantityLimitedQuery"> Quantity Limit?</th>
			<td width="30%">Quantity<br><input type="text" id="quantityLimit" name="quantityLimit"></td>
		</tr>
		<tr>
			<th width="20%">Destination Laboratory</th>
			<td width="30%"><select id="destinationLaboratory" name="destinationLaboratory">
<option value=""></option>
<option value="5552">Gamma-Dynacare</option>
<option value="5407">CML</option>
<option value="5687">LifeLabs</option>
</select>
</td>
		</tr>
		<tr>
			<td colspan=2><input type="submit" name="submit" value="Search" /></td>
		</tr>
		</tbody>
	</table>
	</form>
	
	
	
	<form action="<%=request.getContextPath() %>/olis/Search.do?method=loadResults" method="POST">
	<input type="hidden" name="queryType" value="Z06" />
	<table id="Z06_query" style="display: none;">
		<tbody>
		<tr>
			<td colspan=2><input type="submit" name="submit" value="Search" /></td>
		</tr>
		<tr>
			<th width="20%">Date &amp; Time Period to Search<br />(yyyy-mm-dd)</th>
			<td width="30%"><input style="width:150px" type="text" name="startTimePeriod" id="startTimePeriod" value="" > to <input style="width:150px" name="endTimePeriod" type="text" id="endTimePeriod" ></td>
			<th width="20%"><input class="checkbox" type="checkbox" name="quantityLimitedQuery" id="quantityLimitedQuery"> Quantity Limit?</th>
			<td width="30%">Quantity<br><input type="text" id="quantityLimit" name="quantityLimit"></td>
		</tr>
		<tr>
			<th width="20%">Ordering Facility</th>
			<td width="30%"><select id="orderingFacility" name="orderingFacility">
<option value=""></option>
<option value="5552">Gamma-Dynacare</option>
<option value="5407">CML</option>
<option value="5687">LifeLabs</option>
</select>
</td>
		</tr>
		<tr>
			<td colspan=2><input type="submit" name="submit" value="Search" /></td>
		</tr>
		</tbody>
	</table>
	</form>
	
	
	<form action="<%=request.getContextPath() %>/olis/Search.do?method=loadResults" method="POST">
	<input type="hidden" name="queryType" value="Z07" />
	<table id="Z07_query" style="display: none;">
		<tbody>
		<tr>
			<td colspan=2><input type="submit" name="submit" value="Search" /></td>
		</tr>
		<tr>
			<th width="20%">Date &amp; Time Period to Search<br />(yyyy-mm-dd)</th>
			<td width="30%"><input style="width:150px" type="text" name="startTimePeriod" id="startTimePeriod" value="" > to <input style="width:150px" name="endTimePeriod" type="text" id="endTimePeriod" ></td>
			<th width="20%"><input class="checkbox" type="checkbox" name="quantityLimitedQuery" id="quantityLimitedQuery"> Quantity Limit?</th>
			<td width="30%">Quantity<br><input type="text" id="quantityLimit" name="quantityLimit"></td>
		</tr>
		<tr>
			<td colspan=2><input type="submit" name="submit" value="Search" /></td>
		</tr>
		</tbody>
	</table>
	</form>
	
	
	
	<form action="<%=request.getContextPath() %>/olis/Search.do?method=loadResults" method="POST">
	<input type="hidden" name="queryType" value="Z08" />
	<table id="Z08_query" style="display: none;">
		<tbody>
		<tr>
			<td colspan=2><input type="submit" name="submit" value="Search" /></td>
		</tr>
		<tr>
			<th width="20%">Date &amp; Time Period to Search<br />(yyyy-mm-dd)</th>
			<td width="30%"><input style="width:150px" type="text" name="startTimePeriod" id="startTimePeriod" value="" > to <input style="width:150px" name="endTimePeriod" type="text" id="endTimePeriod" ></td>
			<th width="20%"><input class="checkbox" type="checkbox" name="quantityLimitedQuery" id="quantityLimitedQuery"> Quantity Limit?</th>
			<td width="30%">Quantity<br><input type="text" id="quantityLimit" name="quantityLimit"></td>
		</tr>
		<tr>
			<td colspan=2><input type="submit" name="submit" value="Search" /></td>
		</tr>
		</tbody>
	</table>
	</form>
	
	
	
	<form action="<%=request.getContextPath() %>/olis/Search.do?method=loadResults" method="POST">
	<input type="hidden" name="queryType" value="Z50" />
	<table id="Z50_query" style="display: none;">
		<tbody>
		<tr>
			<td colspan=2><input type="submit" name="submit" value="Search" /></td>
		</tr>
		<tr>
			<th width="20%">First Name</th>
			<td width="30%"><input type="text" id="z50firstName" name="z50firstName"></td>
			<th width="20%">Last Name</th>
			<td width="30%"><input type="text" id="z50lastName" name="z50lastName"></td>
		</tr>
		<tr>
			<th width="20%">Sex</th>
			<td width="30%"><select name="z50sex"><option value="M">M</option><option value="F">F</option></select></td>
			<th width="20%">Date of Birth</th>
			<td width="30%"><input type="text" id="z50dateOfBirth" name="z50dateOfBirth"></td>
		</tr>
		<tr>
			<td colspan=2><input type="submit" name="submit" value="Search" /></td>
		</tr>
		</tbody>
	</table>
	</form>
	
	
	
	<oscar:oscarPropertiesCheck value="yes" property="olis_simulate">

		<iframe src="Simulate.jsp" width="500" heigh="300" frameborder="0" scrolling="no"></iframe>	

	</oscar:oscarPropertiesCheck>
		
			</td>
		</tr>
	</tbody></table>
	
	<script>
		jQuery(setupResultCodeSearchTypeahead());
		jQuery(setupRequestCodeSearchTypeahead());
		jQuery(setupResultCodeSearchZ04Typeahead());
		jQuery(setupRequestCodeSearchZ04Typeahead());
	</script>
	</body>
	</html>
