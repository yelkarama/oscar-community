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
<%--This JSP displays the result of the report query--%>


<%@ page
	import="java.util.*,oscar.oscarReport.reportByTemplate.*,java.sql.*, org.apache.commons.lang.StringEscapeUtils"%>
<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean"%>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html"%>
<%@ taglib uri="/WEB-INF/security.tld" prefix="security"%>
<%
      String roleName$ = (String)session.getAttribute("userrole") + "," + (String) session.getAttribute("user");
      boolean authed=true;
%>
<security:oscarSec roleName="<%=roleName$%>" objectName="_report,_admin.reporting,_admin" rights="r" reverse="<%=true%>">
	<%authed=false; %>
	<%response.sendRedirect("../../securityError.jsp?type=_report&type=_admin.reporting&type=_admin");%>
</security:oscarSec>
<%
if(!authed) {
	return;
}
%>

<html:html locale="true">
<head>
<script type="text/javascript" src="<%= request.getContextPath() %>/js/global.js"></script>
<title>Report by Template</title>
<link rel="stylesheet" type="text/css"
	href="../../share/css/OscarStandardLayout.css">
<link rel="stylesheet" type="text/css" href="reportByTemplate.css">
<script type="text/javascript" language="JavaScript"
	src="../../share/javascript/prototype.js"></script>
<script type="text/javascript" language="JavaScript"
	src="../../share/javascript/Oscar.js"></script>
<script type="text/javascript" language="javascript">

var patt = /panel|provider|doctor|professional|^md/i ; //regex for likely sqlColumnName 
var sqlColumnName = 'Provider'; // Name on the button and graph but the column will be taken from patt
var dataTable = "";//document.getElementsByTagName('table')[2], // all query results are inside this dataTable
var dataTableSize = 1;//dataTable.rows.length, // save this so it does not need to be re-calculated in loops
theGreenGrass = `color: green;
       border: 2px solid green;
       margin: 2px;
       padding: 2px;`;
strBarChartLineColour = 'aqua';
let allowExecution = true; // controls whether the code is prevented from running on the page a second time
//changePage(); // colour alternate table rows in query results then insert a button into the user and go look


function clearSession(){
    new Ajax.Request('clearSession.jsp','{asynchronous:true}');

}
function changePage() {
    /*  -----------------------------------------------------------------------------------------------------
        changePage() - Scott Gingras <sgingras@pinchermedical.ca> - April 11, 2021
        -----------------------------------------------------------------------------------------------------
        - 1) browser console startup info
        - 2) alternate rows coloured
        - 3) Graph button inserted
        - 4) Go look at what we've done
        */
        dataTable = document.getElementsByTagName('table')[2], // all query results are inside this dataTable
        dataTableSize = dataTable.rows.length, // save this so it does not need to be re-calculated in loops
        
        
    fncLogStartupInfo(); // we used to type out a lot of things to the user that nobody bothered to read using F12 so we cut back
    fncColourAlternateDataTableRows(); // alternating row colours
    if (fncGetDataTableColumnByName(sqlColumnName) > -1) {
    	fncInsertGraphButton(); // insert and then immediately go look
	}
    //window.scrollTo(0,document.body.scrollHeight);
}
function fncInsertGraphButton() {
    dataTable.parentNode.appendChild(document.createTextNode((dataTableSize-1) + " data rows found"));
    dataTable.parentNode.appendChild(document.createElement("br"));
    dataTable.parentNode.appendChild(document.createElement("br"));
    let scottsButton = document.createElement('input'); // generate button
    formatScottsButton(scottsButton); // add sqlColumnName to button text
    dataTable.parentNode.appendChild(scottsButton); // insert button
    const linebreak = document.createElement("hr");
    dataTable.parentNode.appendChild(linebreak);
}
function formatScottsButton(scottsButton) {
    scottsButton.setAttribute('type',"button");
    scottsButton.setAttribute('value',"Graph by " + sqlColumnName);
    scottsButton.setAttribute('class',"ControlPushButton");
    scottsButton.onclick = scottyG;
}
function fncLogStartupInfo() {
    console.log(new Date);
    console.info('%cProcessing ' + (dataTable.rows.length-1) +
                 ' dataTable rows in the query results using column: ' + sqlColumnName, theGreenGrass);
}
function fncColourAlternateDataTableRows() {
    for (let x = 1;x<dataTableSize;x=x+2) {
        dataTable.rows[x].style.backgroundColor = '#e0e0ff';
    }
}
function scottyG() {
    /*  -----------------------------------------------------------------------------------------------------
        scottyG() - ScottyG <sgingras@pinchermedical.ca> - April 12, 2021
        -----------------------------------------------------------------------------------------------------
                The G stands for "Graph"

        This scottyG function is called by scottsButton which is inserted under the dataTable
        in the web page with all query results displayed inside that dataTable.
        It figures out which column has something useful to graph based on strColumnName
        and then inserts a simple bar graph into the page using without depending on other scripts.

        We do this with a button rather than just executing automatically on page load for 2 reasons:
        1) just in case something goes wrong with this graph generation it won't interfere with the rest
            of the code launched on page load that colours the alternate rows of the data results or whatever
        2) if somebody just wants to use the RBT query data to copy/paste into LibreOffice Calc then
            they don't need this code operation running and adding unnecessary objects onto their page

        */
    if (allowExecution) {
    const intColumnToAnalyzeAndGraph = fncGetDataTableColumnByName(sqlColumnName); // convert sqlColumnName to integer
        if (intColumnToAnalyzeAndGraph > -1) {
            console.info('%cInitiating scottyTableHeaderAndGraphInsertion', theGreenGrass);
            /*
            *  this step is critical and any weird errors are probably because of the
            *  fncGetSummaryData function trying to get this associative array arrG...
            */
            const arrG = fncGetSummaryData(intColumnToAnalyzeAndGraph);
            // we made it this far so sqlColumnName must really have existed for the user
            // they followed instructions correctly and changed this TamperMonkey script
            // so that the global variable sqlColumnName worked and matched their SQL column results name!
            // any reports that "THE BUTTON DOESN'T WORK WHEN I PUSH IT" probably 90% chance means that
            // there will be a message in the browser console saying something about
            // 'FATAL ERROR - CANNOT FIND panel - CHECK sqlColumnName VARIABLE TO MATCH SQL QUERY'
            // but that is all that the code does is display that message in the console, so to the
            // uninitiated they just think things are broken and the programmer is stupid because 'the button does nothing'
            // anyways...insert the summary and graph now that we know this RBTSummaryWithGraph.user.js file was done right
            scottySummaryAndGraphInsertion(arrG);
            // if we get here we know it was properly inserted into the user so go look
            //window.scrollTo(0,document.body.scrollHeight);
            allowExecution = false; // only allow code to run once per page load
        } else {
            console.error('FATAL ERROR - CANNOT FIND ' + sqlColumnName + ' - CHECK sqlColumnName VARIABLE TO MATCH SQL QUERY');
        }
    }
}
function scottySummaryAndGraphInsertion(arrG) {
    // 1) insert scotty table header with summary of what graph displays
    const table = scottyTableHeader(arrG);
    dataTable.parentNode.appendChild(table);
    // 2) insert graph below
    const graph = scottyGraph(arrG);
    dataTable.parentNode.appendChild(graph);
}
function scottyTableHeader(arrG) {
    const gtable = document.createElement("table"), // generate new table as return value of function
        caption = document.createElement("caption"),
        captiontext = document.createTextNode("Count number of occurrances of " + sqlColumnName);
    caption.appendChild(captiontext);
    gtable.appendChild(caption);
    // append 2 rows to the table
    const hrow = document.createElement("tr"),
        drow = document.createElement("tr");
    gtable.appendChild(hrow);
    gtable.appendChild(drow);
    let th,thtext,td,tdtext;
    for (const [key, value] of Object.entries(arrG)) {
        // key as the table header th
        th = document.createElement("th");
        thtext = document.createTextNode(`${key}`);
        th.appendChild(thtext);
        hrow.appendChild(th); // insert key as header
        // value as the table cell td
        td = document.createElement("td");
        tdtext = document.createTextNode(`${value}`);
        td.appendChild(tdtext);
        td.style = 'text-align: center';
        drow.appendChild(td); // insert value as cell text
    }
    return gtable; // return the table completely ready to insert into the user
}
function fncGetDataTableColumnByName(sqlColumnName) {
    const intColumns = dataTable.rows[0].cells.length;
    let intColumnWithName = -1; // default to -1 so it is obvious if nothing is found
    // loop through columns but break as soon as we find sqlColumnName
    for (let x = 0;x<intColumns;x++) {
    	str = dataTable.rows[0].cells[x].innerHTML;
    	var result = patt.test(str);
        if (result) {
        	sqlColumnName = dataTable.rows[0].cells[x].innerHTML;
        	console.info(sqlColumnName+ " identified as the column containing doctor info");
            intColumnWithName = x;
            break;
        }
    }
    return intColumnWithName;
}
function fncGetSummaryData(intColumn) {
    let setScotty = new Set(),
        arrRes = [], // return associative array with unique name keys based on the Set
        arrAll = []; // all values found in intColumn of the dataTable
    // start at 1 because we don't care about the header row at all
    for (let x = 1;x<dataTableSize;x++) {
        const scottyVal = dataTable.rows[x].cells[intColumn].innerHTML; // read cell value
        setScotty.add(scottyVal); // does nothing if value already exists
        arrAll.push(scottyVal); // add everything into arrAll
    }
    for (let scotty of setScotty) {
        arrRes[scotty] = 0; // we now know that this associative array arrRes contains unique values only so that is joyful
    }
    for (let scotts of arrAll) {
        arrRes[scotts] = arrRes[scotts] + 1; // very simply count all HTML cell values now
    }
    return arrRes;
}
function scottyGraph(arrG) {
    const graphTable = document.createElement("table"),
          hrow = graphTable.insertRow(); // header row
    graphTable.createCaption().textContent = (dataTableSize-1) + ' ' + sqlColumnName + ' occurrances';
    graphTable.style.border = "thin dotted grey";
    hrow.insertCell().outerHTML = '<th>' + sqlColumnName + '</th>';
    hrow.insertCell().outerHTML = '<th>% of total</th>';
    drawScottyGraphData();
    return graphTable;
    function drawScottyGraphData() {

        let drow; // each row containing key and value where the value becomes the bar graph
        for (const [key, value] of Object.entries(arrG)) {
                drow = graphTable.insertRow();
                drow.insertCell().appendChild(document.createTextNode(key));
                drawSinglesBarLine(value);
        }
        function drawSinglesBarLine(val) {

            const singlesCell = drow.insertCell(),
                  proportionality = val/(dataTableSize-1),
                  strPercent = proportionality.toLocaleString(undefined,{style: 'percent', minimumFractionDigits:2}),
                  tableSinglesBar = document.createElement('table'),
                  rowSinglesBar = tableSinglesBar.insertRow(),
                  tdBarLeft = rowSinglesBar.insertCell(),
                  tdBarRight = rowSinglesBar.insertCell();
            tableSinglesBar.style = 'table-layout: fixed'; // this table-layout: fixed is worth it's weight in gold
            tableSinglesBar.setAttribute('width', '100%'); // insert as wide as possible
            tdBarLeft.innerHTML = strPercent; // label displayed at right side of the line
            tdBarLeft.style = 'text-align: right'; // if there is not enough space the text spills over it's ok
            tdBarLeft.style.backgroundColor = strBarChartLineColour; // colour of the lines is controlled at the top
            tdBarLeft.setAttribute('width', strPercent+'%'); // small sizes are the reason we need minimumFractionDigits:2 to force it big enough
            tdBarRight.innerHTML = '&nbsp;'; // slip this into the user and hope they don't find out
            // add singles bar line
            singlesCell.appendChild(tableSinglesBar);
        }
    }
}
</script>
<style type="text/css" media="print">
.MainTableTopRow,.MainTableLeftColumn,.noprint,.showhidequery,.sqlBorderDiv,.MainTableBottomRow
	{
	display: none;
}

.MainTableRightColumn {
	border: 0;
}
</style>
</head>

<body vlink="#0000FF" class="BodyStyle" onload="changePage();"onunload="clearSession();">

<table class="MainTable" id="scrollNumber1" name="encounterTable">
	<tr class="MainTableTopRow">
		<td class="MainTableTopRowLeftColumn"><bean:message
			key="oscarReport.CDMReport.msgReport" /></td>
		<td class="MainTableTopRowRightColumn">
		<table class="TopStatusBar" style="width: 100%;">
			<tr>
				<td>Report by Template</td>
			</tr>
		</table>
		</td>
	</tr>
	<tr>
		<%
		
		ReportObjectGeneric curreport = (ReportObjectGeneric) request.getAttribute("reportobject");
        
		Integer sequenceLength = (Integer)request.getAttribute("sequenceLength");
		
		
		List<String> sqlList = new ArrayList<String>();
		List<String> htmlList = new ArrayList<String>();
		List<String> csvList = new ArrayList<String>();
		
		if(curreport.isSequence()) {
			for(int x=0;x<sequenceLength;x++) {
				sqlList.add((String) request.getAttribute("sql-" + x));
				htmlList.add((String) request.getAttribute("resultsethtml-" + x));
				csvList.add((String) request.getAttribute("csv-" + x));
			}
		} else {
			sqlList.add((String) request.getAttribute("sql"));
			htmlList.add((String) request.getAttribute("resultsethtml"));
			csvList.add((String) request.getAttribute("csv"));
		}
            
          %>
		<td class="MainTableLeftColumn" valign="top" width="160px;"><jsp:include
			page="listTemplates.jsp">
			<jsp:param name="templateviewid"
				value="<%=curreport.getTemplateId()%>" />
		</jsp:include></td>
		<td class="MainTableRightColumn" valign="top">
		<div class="reportTitle"><%=curreport.getTitle()%></div>
		<div class="reportDescription"><%=curreport.getDescription()%></div>
		<a href="#" style="font-size: 10px; text-decoration: none;"
			class="showhidequery" onclick="showHideItem('sqlDiv')">Hide/Show
		Query</a>
		<div class="sqlBorderDiv" id="sqlDiv" style="display: none;"><b>Query:</b><br />
		<code style="font-size: 11px;">
			<%
			for(int x=0;x<sqlList.size();x++) {
				out.println((x+1) + ")" + org.apache.commons.lang.StringEscapeUtils.escapeHtml(sqlList.get(x).trim()) + "<br/>");
			}
			%>
		</code>
		</div>
		<div class="reportBorderDiv">
		<%
		
			for(int x=0;x<htmlList.size();x++) {
				 out.println(htmlList.get(x));
				 out.println("<br/>");
				 
			}
			
        %>
		</div>
		<div class="noprint"
			style="clear: left; float: left; margin-top: 15px;">
			
			<input type="button" value="<-- Back"
				onclick="javascript: history.go(-1);return false;">
			<input type="button" value="Print"
				onclick="javascript: window.print();">
			<br/><br/>
	
	<%
		for(int x=0;x<csvList.size();x++) {
	%>			

			<html:form action="/oscarReport/reportByTemplate/generateOutFilesAction">
			<%if(x>1){ %>
			<label><%=(x+1)%></label>
			<%}%>
			<input type="hidden" name="csv"
				value="<%=StringEscapeUtils.escapeHtml(csvList.get(x))%>">

			<input type="submit" name="getCSV" value="Export to CSV">
			<input type="submit" name="getXLS" value="Export to XLS">
		</html:form>
		
	<% } %>	
		</div>
		</td>
	</tr>
	<tr class="MainTableBottomRow">
		<td class="MainTableBottomRowLeftColumn">&nbsp;</td>

		<td class="MainTableBottomRowRightColumn">&nbsp;</td>
	</tr>
</table>
</html:html>
