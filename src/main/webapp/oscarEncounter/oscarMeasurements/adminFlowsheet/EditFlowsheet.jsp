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
<%@ taglib uri="/WEB-INF/oscar-tag.tld" prefix="oscar" %>
<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean" %>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html" %>
<%@ taglib uri="/WEB-INF/rewrite-tag.tld" prefix="rewrite" %>
<%@ taglib uri="/WEB-INF/security.tld" prefix="security"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<% long startTime = System.currentTimeMillis(); %>
<%@ page import="oscar.oscarDemographic.data.*,java.util.*,oscar.oscarPrevention.*,oscar.oscarEncounter.oscarMeasurements.*,oscar.oscarEncounter.oscarMeasurements.bean.*,java.net.*"%>
<%@ page import="org.jdom.Element,oscar.oscarEncounter.oscarMeasurements.data.*,org.jdom.output.Format,org.jdom.output.XMLOutputter,oscar.oscarEncounter.oscarMeasurements.util.*,java.io.*" %>
<%@ page import="org.springframework.web.context.support.WebApplicationContextUtils"%>
<%@ page import="org.springframework.web.context.WebApplicationContext"%>
<%@ page import="org.oscarehr.common.dao.*"%>
<%@ page import="oscar.oscarEncounter.oscarMeasurements.MeasurementTemplateFlowSheetConfig"%>
<%@ page import="oscar.oscarEncounter.oscarMeasurements.FlowSheetItem"%>

<%@page import="org.oscarehr.util.SpringUtils" %>
<%@ page import="org.oscarehr.common.model.*" %>
<%@ page import="oscar.oscarRx.data.RxPrescriptionData" %>
<%@ page import="org.oscarehr.util.LoggedInInfo" %>


<%
      String roleName2$ = (String)session.getAttribute("userrole") + "," + (String) session.getAttribute("user");
      boolean authed2=true;
%>
<security:oscarSec roleName="<%=roleName2$%>" objectName="_flowsheet" rights="w" reverse="<%=true%>">
	<%authed2=false; %>
	<%response.sendRedirect("../../../securityError.jsp?type=_flowsheet");%>
</security:oscarSec>
<%
if(!authed2) {
	return;
}
%>

<%
    LoggedInInfo loggedInInfo = LoggedInInfo.getLoggedInInfoFromSession(request);
    long startTimeToGetP = System.currentTimeMillis();
    
    String module="";
    String htQueryString = "";
    if(request.getParameter("htracker")!=null){
    	module="htracker";
    	htQueryString="&"+module;	
    }
    
    if(request.getParameter("htracker")!=null && request.getParameter("htracker").equals("slim")){
    	module="slim";
    	htQueryString=htQueryString+"=slim";
    }
    
    String temp = "";
    if(request.getParameter("flowsheet") != null){
    	temp = request.getParameter("flowsheet");
    }else{
		temp = "tracker";
    }

    String flowsheet = temp;
    String demographic = request.getParameter("demographic");
    MeasurementTemplateFlowSheetConfig templateConfig = MeasurementTemplateFlowSheetConfig.getInstance();
    Hashtable<String, String> flowsheetNames = templateConfig.getFlowsheetDisplayNames();

    WebApplicationContext ctx = WebApplicationContextUtils.getRequiredWebApplicationContext(getServletContext());
    FlowSheetCustomizationDao flowSheetCustomizationDao = (FlowSheetCustomizationDao) ctx.getBean("flowSheetCustomizationDao");
    FlowSheetDrugDao flowSheetDrugDao = ctx.getBean(FlowSheetDrugDao.class);
    List<FlowSheetCustomization> custList = null;
    if(demographic == null || demographic.isEmpty()) {
    	custList = flowSheetCustomizationDao.getFlowSheetCustomizations( flowsheet,(String) session.getAttribute("user"));
    } else {
    	custList = flowSheetCustomizationDao.getFlowSheetCustomizations( flowsheet,(String) session.getAttribute("user"),Integer.parseInt(demographic));
    }
    Enumeration en = flowsheetNames.keys();

    EctMeasurementTypesBeanHandler hd = new EctMeasurementTypesBeanHandler();
    Vector<EctMeasurementTypesBean> vec = hd.getMeasurementTypeVector();
    String demographicStr = "";
    if (demographic != null){
        demographicStr = "&demographic="+demographic;
    }

    XMLOutputter outp = new XMLOutputter();
    outp.setFormat(Format.getPrettyFormat());

    DemographicDao demographicDao = SpringUtils.getBean(DemographicDao.class); 
    Demographic demo = demographicDao.getDemographic(demographic);
%>
<!DOCTYPE html>
<html lang="en">

<head>
<title>Edit Flowsheet</title><!--I18n-->

<link href="<%=request.getContextPath() %>/css/bootstrap.css" rel="stylesheet">


<!-- HTML5 shim, for IE6-8 support of HTML5 elements -->
<!--[if lt IE 9]>
  <script src="<%=request.getContextPath() %>/js/html5.js"></script>
<![endif]-->

<!-- Fav and touch icons -->
<link rel="apple-touch-icon-precomposed" sizes="144x144" href="ico/apple-touch-icon-144-precomposed.png">
<link rel="apple-touch-icon-precomposed" sizes="114x114" href="ico/apple-touch-icon-114-precomposed.png">
  <link rel="apple-touch-icon-precomposed" sizes="72x72" href="ico/apple-touch-icon-72-precomposed.png">
                <link rel="apple-touch-icon-precomposed" href="ico/apple-touch-icon-57-precomposed.png">
                               <link rel="shortcut icon" href="ico/favicon.png">
                                   
<link rel="stylesheet" type="text/css" href="<%=request.getContextPath() %>/css/DT_bootstrap.css">

<%
if( request.getParameter("htracker")!=null && request.getParameter("htracker").equals("slim") ){
%>
<style type="text/css">
#container-main{
width:720px !important;
}
</style>
<%}%>

<style type="text/css">

.table tbody tr:hover td, .table tbody tr:hover th {
    background-color: #FFFFAA;
}

.action-head{width:60px !important;}
.action-icon{
padding-right:10px;
opacity:0.6;
filter:alpha(opacity=60); /* For IE8 and earlier */
}

.action-icon:hover{
opacity:1;
filter:alpha(opacity=100); /* For IE8 and earlier */
}

.mode-toggle{
font-size: 14px;
padding-left:10px;
font-weight:normal;
}

#scrollToTop{
Position:fixed;
display:none;
bottom:30px;
right:15px;
}


.select-measurement{
font-size:16px;
width:250px;
}

.month-range{
width:100px !important;
}

.rule-text{
width:100px !important;
}

.list-title {
   padding-top:10px;
   padding-right: 12px;
}

#myTab{
margin-top:10px;
}
.measurement-select{
width:450px;
}
</style>

<style type="text/css" media="print">
.DoNotPrint {
	display: none;
}
</style>

	<link rel="stylesheet" type="text/css" href="<%=request.getContextPath()%>/share/yui/css/fonts-min.css" >
	<link rel="stylesheet" type="text/css" href="<%=request.getContextPath()%>/share/yui/css/autocomplete.css" >
</head>

<body id="editFlowsheetBody" class="yui-skin-sam">

<%
if( request.getParameter("tracker")!=null && request.getParameter("tracker").equals("slim") ){ 
	
}else{
if(request.getParameter("demographic")==null){ %>
<div class="well well-small" id="demoHeader"></div>
<%}else{%>
<%@ include file="/share/templates/patient.jspf"%>
<div style="height:60px;"></div>
<%
}
}
%>

<div class="container" id="container-main">

<div class="row-fluid">

<h4 style="display:inline;">

<%if(demographic!=null){

String tracker = "";
if( request.getParameter("tracker")!=null && request.getParameter("tracker").equals("slim") ){ 
tracker="&tracker=slim";
}

String flowsheetPath = "";

if ( request.getParameter("htracker")!=null ){
	flowsheetPath = "HealthTrackerPage.jspf";
}else{
	flowsheetPath = "TemplateFlowSheet.jsp";
}%>

<a href="../<%=flowsheetPath%>?demographic_no=<%=demographic%>&template=<%=flowsheet%><%=tracker%>" class="btn btn-small" title="go back to <%=flowsheet%> flowsheet"><i class="icon-backward"></i></a>

<%}%> 

Flowsheet: <span style="font-weight:normal"><%=flowsheet.toUpperCase()%></span>
</h4>
		  <span class="mode-toggle">
		            <% if (demographic!=null) { %>
		             Patient 
					<security:oscarSec roleName="<%=roleName2$%>" objectName="_flowsheet" rights="w">
						| <a href="EditFlowsheet.jsp?flowsheet=<%=flowsheet%>">All Patients</a> 
					</security:oscarSec>

		            <%}else{%>
		               <i>for</i> All Patients
		            <%}%>
		  </span>
</div><!-- row -->

<div class="row-fluid">
		
		
		<ul class="nav nav-tabs" id="myTab">
		<li class="list-title">Measurements:</li>
		<li class="active"><a href="#home" data-toggle="tab">All</a></li>
		<li><a href="#custom" data-toggle="tab">Custom</a></li>
		<li><a href="#add" data-toggle="tab"><i class="icon-plus-sign"></i> Add</a></li>
			<li><a href="#addMedication" data-toggle="tab"><i class="icon-plus-sign"></i> Add Medication</a></li>
		</ul>

	<%if (demographic!=null) { %>
		<div class="alert alert-info">
			Any changes made to this flowsheet will be applied to this patient <strong><%=demo.getLastName()%>, <%=demo.getFirstName()%></strong> for you only.
		</div>
	 <%}else{%>
		<div class="alert">
			Any changes made to this flowsheet will be applied to all of <u>your</u> patients.
		</div>
	 <%}%>
 
<div class="tab-content">
	<div class="tab-pane active" id="home">

		<!-- Flowsheet Measurement List -->
		<table class="table table-striped table-bordered table-condensed" id="measurementTbl">
		<thead>
		<tr>
		<th style="min-width:60px;max-width:80px;"></th>
		<th style="min-width:60px;max-width:80px;">Position</th>
		<th style="min-width:100px;max-width:120px">Measurement</th>
		<th style="min-width:100px;max-width:140px">Display Name</th>
		<th style="min-width:200px;max-width:500px">Guideline</th>
		</tr>
		</thead>
		
		<tbody>
		            <%
		            MeasurementFlowSheet mFlowsheet = templateConfig.getFlowSheet(temp,custList);
		            Element va = templateConfig.getExportFlowsheet(mFlowsheet);
		
		            List<String> measurements = mFlowsheet.getMeasurementList();
				
			    int counter = 1;
		            
		            if (measurements != null) {
		                for (String mstring : measurements) {
		               %>
		                <tr>
		         		<td>
		         		<%if(mFlowsheet.getFlowSheetItem(mstring).getPreventionType()!=null){ %>
		         		<i class="icon-pencil action-icon"  rel="popover" data-container="body"  data-toggle="popover" data-placement="right" data-content="unable to edit a prevention item" data-trigger="hover" title=""></i>
		                <%}else{%>
		                <a href="UpdateFlowsheet.jsp?flowsheet=<%=temp%>&measurement=<%=mstring%><%=demographicStr%><%=htQueryString%>" title="Edit" class="action-icon"><i class="icon-pencil"></i></a>
		                <%}%>
		                <a href="FlowSheetCustomAction.do?method=delete&flowsheet=<%=temp%>&measurement=<%=mstring%><%=demographicStr%><%=htQueryString%>" title="Delete" class="action-icon"><i class="icon-trash"></i></a>
		                </td>
		                <td><%=counter%></td>
		                <td><%=mstring%></td>
		                <td title="<%=mstring%>"><%=mFlowsheet.getFlowSheetItem(mstring).getDisplayName()%></td>
		                <td title="<%=mstring%>"><%=mFlowsheet.getFlowSheetItem(mstring).getGuideline()%></td>
						</tr>
				            
		            <%	
				counter++;
		                }
		
		            }
		                
						RxPrescriptionData prescriptData = new RxPrescriptionData();
						List<FlowSheetDrug> flowSheetDrugs;
						if (demographic == null) {
                            flowSheetDrugs = flowSheetDrugDao.getFlowSheetDrugsByFlowsheetAndProvider(temp, loggedInInfo.getLoggedInProviderNo());
                        }
                        else {
						    
                            Integer demographicNo;
                            try {
                                demographicNo = Integer.parseInt(demographic);
                            }
                            catch(NumberFormatException e) {
                                demographicNo = 0;
                            }
                            flowSheetDrugs = flowSheetDrugDao.getFlowSheetDrugs(temp, demographicNo, loggedInInfo.getLoggedInProviderNo());
                        }
						oscar.oscarRx.data.RxPrescriptionData.Prescription [] arr;
		            for(FlowSheetDrug flowSheetDrug : flowSheetDrugs) {
						%>
					<tr>
						<td>
							<a href="FlowSheetCustomAction.do?method=deleteDrug&flowsheet=<%=temp%>&drugId=<%=flowSheetDrug.getId()%>" title="Delete" class="action-icon"><i class="icon-trash"></i></a>
						</td>
						<td>
							<%=counter%>
						</td>
						<td>
							<%=flowSheetDrug.getAtcCode()%>
						</td>
						<td>
							<%=flowSheetDrug.getName()%>
						</td>
						<td></td>
					</tr>
					<%
					    counter++;
					}
		                
		            %>
		 </tbody>    
		</table><!-- Flowsheet Measurement List END-->
		
		
	</div><!-- main tab -->
	
	<div class="tab-pane" id="custom">
		
		<div class="span4">
		<!--right sidebar-->
		
			<!-- Custom List -->
		    <div class="well" style="min-width: 240px">
		    <h4>Custom List:</h4>
		    <%
		    if(custList.size()==0){
	    		%>    	    		
	    		<p class="muted">No custom measurements</p>
	    		<%
	    	}else{
	    	%>
		    <table class="table table-striped table-condensed">
		
			<tbody>

	    	<%	
		    String mtype="";
		     
		    for (FlowSheetCustomization cust :custList){
		    	
		    	
		    	MeasurementTemplateFlowSheetConfig mfc = MeasurementTemplateFlowSheetConfig.getInstance() ;
		    	
		    	

		    	try{
                    FlowSheetItem item = mfc.getItemFromString(cust.getPayload());
                    
                    if(item.getMeasurementType() != null){
                        mtype = item.getMeasurementType();
		    	    }
		    	} catch (Exception e){
	                //do nothing
	            }
		    %>
		       <tr><td><a href="FlowSheetCustomAction.do?method=archiveMod&id=<%=cust.getId()%>&flowsheet=<%=flowsheet%><%=demographicStr%><%=htQueryString%>" class="action-icon"><i class="icon-trash"></i></a> </td> 
		       
		       <td><%=cust.getAction()%></td>
		       
		       <%if(cust.getAction().equals("add")){ %>
		       <td><%if(mtype!=null){out.print(mtype);} %> 
		       
		       <%if(cust.getMeasurement()!=null){%>
		       after <em><%=cust.getMeasurement()%></em> 
		       <%}%>

		       </td> 
		       
		       <%}else{ %>
		       <td><%=cust.getMeasurement()%></td> 
		       <%} %>
		       <td><%=cust.getProviderNo()%> </td> <td> 
		       
		       <%if(cust.getDemographicNo().equals("0")){ %>
		       All Patients
		       <%}else{ %>
		       <a href="<%=request.getContextPath() %>/demographic/demographiccontrol.jsp?demographic_no=<%=cust.getDemographicNo()%>&displaymode=edit&dboperation=search_detail" target="_blank"><%=cust.getDemographicNo()%></a>
		       <%} %>
		       </td></tr>
		    <%
		    	}
		    %>
		    </tbody>
		    </table><!-- Custom List END-->		
		    <%} %>
			</div><!-- well -->
			
		 </div><!-- span4 -->
		
	</div><!-- custom tab -->
	
	<!-- ADD NEW MEAS -->
<div class="tab-pane" id="add">


<form name="FlowSheetCustomActionForm" id="FlowSheetCustomActionForm" class="well" action="FlowSheetCustomAction.do" method="post">
		    <%if(request.getParameter("htracker")!=null){ %>
		    <input type="hidden" name="htracker" value="<%=module%>">
		    <%}%>   
            <input type="hidden" name="flowsheet" value="<%=temp%>"/>
            <input type="hidden" name="method" value="save"/>
            <%if (demographic !=null){%>
                    <input type="hidden" name="demographic" value="<%=demographic%>"/>
            <%}%>
          
	
		<h4>Select a Measurement</h4>
		<select name="measurement" class="measurement-select">
                	<option value="0">choose:</option>
                    <% for (EctMeasurementTypesBean measurementTypes : vec){ %>
                    <option value="<%=measurementTypes.getType()%>" ><%=measurementTypes.getTypeDisplayName()%> (<%=measurementTypes.getType()%>) </option>
                    <% } %>
        </select>
		
	    <h4>Customize Measurement</h4>
		<table>
		<tr><td>Display Name:</td><td><input type="text" name="display_name" id="display_name" required/></td></tr>
                <tr><td>Guideline:    </td><td><input type="text" name="guideline" /></td></tr>
                <tr><td>Graphable:</td><td> <select name="graphable"   >
                    <option  value="yes" >YES</option>
                    <option  value="no">NO</option>
                </select></td></tr>
                <tr><td>Value Name:</td><td><input type="text" name="value_name" id="value_name" /></td></tr>
			<tr>
				<td>Scope:</td>
				<td>
					<input type="radio" name="scope" id="clinicScope" value="1" checked><label style="display:inline-block;vertical-align:text-top;padding-right:10px;" for="clinicScope">Clinic</label>
					<input type="radio" name="scope" id="physicianScope"><label style="display:inline-block;vertical-align:text-top;" for="physicianScope">Physician</label>
				</td>
			</tr>
		</table>
                
                
                <div>
                
                    <h4>Create Rule</h4>
                    
                    <table class="rule">
                    <tr>
                    <td>Month Range:</td> <td>Strength: </td> <td>Text: </td>
                    </tr>
              
                    <tr>
                    <td><input type="text" name="monthrange1" class="month-range"/></td> 
                    <td><select name="strength1">
                        <option value="recommendation">Recommendation</option>
                        <option value="warning">Warning</option>
                    </select> </td> 
                    <td><input type="text" name="text1" class="rule-text"/> </td>
                    </tr>

                    <tr>
                    <td><input type="text" name="monthrange2" class="month-range"/></td> 
                    <td><select name="strength2">
                        <option value="recommendation">Recommendation</option>
                        <option value="warning">Warning</option>
                    </select> </td> 
                    <td><input type="text" name="text2" class="rule-text"/> </td>
                    </tr>

                    <tr>
                    <td><input type="text" name="monthrange3" class="month-range"/></td> 
                    <td><select name="strength3">
                        <option value="recommendation">Recommendation</option>
                        <option value="warning">Warning</option>
                    </select> </td> 
                    <td><input type="text" name="text3" class="rule-text"/> </td>
                    </tr>
                    </table>
                    
                </div>

		<div>
		<h4>Display Position</h4>
                Position: <%int count = measurements.size()-custList.size();%>
		
		<select id="count" name="count" required>
		<%for(int i=2;i<count;i++){ %>
			<option value="<%=i%>"><%=i%></option>
		<%} %>
			<option value="0" selected>Last</option>
		</select>
        </div>

       <legend></legend>
       
	   <input type="submit" class="btn btn-large btn-primary" value="Save" />
 
</form>  

  
</div><!-- add pane -->
	
<div class="tab-pane" id="addMedication">
	<form action="FlowSheetCustomAction.do" method="post">
		<input type="hidden" name="flowsheet" value="<%=temp%>"/>
		<input type="hidden" name="method" value="save"/>
		<%if (demographic !=null){%>
		<input type="hidden" name="demographic" value="<%=demographic%>"/>
		<%}%>
		
		Search
		<input type="text" id="searchString" name="searchString" onfocus="changeContainerHeight();" onblur="changeContainerHeight();" onclick="changeContainerHeight();" onkeydown="changeContainerHeight();" style="width:248px;" autocomplete="off" />
		<div id="autocomplete_choices" style="overflow:auto;width:500px"></div>
		
		<div id="drugDisplay" name="drugDisplay">
			<h5>Drug Information:</h5>
			<div>
				<span>Id: </span> <input type="number" id="drugId" name="drugId" required />
			</div>
			<div>
				<span>Name: </span> <input type="text" id="drugName" name="drugName" readonly /></h4> <span class="icon-trash"></span>
			</div>
			<div>
				<span>Scope:
					<input type="radio" name="scope" id="clinicScope" value="clinic" checked><label style="display:inline-block;vertical-align:text-top;padding-right:10px;" for="clinicScope">Clinic</label>
					<input type="radio" name="scope" id="physicianScope" value="provider"><label style="display:inline-block;vertical-align:text-top;" for="physicianScope">Physician</label>
				</span>
			</div>
		</div>
		
		
		<input type="submit" class="btn btn-primary" value="Save">
	</form>
</div>
	
	
	</div><!-- tab-content -->

		
	</div><!-- row -->
	
</div><!-- container -->
            





<div id="scrollToTop"><a href="#editFlowsheetBody"><i class="icon-arrow-up"></i>Top</a></div>

<!-- flowsheet xml output -->
        <textarea style="display:none;" cols="200" rows="200">
            <%=outp.outputString(va)%>
        </textarea><!-- flowsheet xml output END-->

	
<script src="<%=request.getContextPath() %>/js/jquery-1.7.1.min.js"></script>
<script type="text/javascript" src="<%=request.getContextPath() %>/js/jquery-ui-1.8.18.custom.min.js" ></script>
<script src="<%=request.getContextPath() %>/js/bootstrap.min.js"></script>	
<script type="text/javascript" src="<%=request.getContextPath() %>/js/jquery.dataTables.js"></script>
<script type="text/javascript" src="<%=request.getContextPath() %>/js/DT_bootstrap.js"></script> 
<script src="<%=request.getContextPath() %>/js/jquery.validate.js"></script>
	
<script type="text/javascript" src="<%=request.getContextPath() %>/share/javascript/prototype.js"></script>
<script type="text/javascript" src="<%=request.getContextPath() %>/share/javascript/Oscar.js"></script>
	
<script type="text/javascript" src="<%=request.getContextPath() %>/share/yui/js/yahoo-dom-event.js"></script>
<script type="text/javascript" src="<%=request.getContextPath() %>/share/yui/js/connection-min.js"></script>
<script type="text/javascript" src="<%=request.getContextPath() %>/share/yui/js/animation-min.js"></script>
<script type="text/javascript" src="<%=request.getContextPath() %>/share/yui/js/datasource-min.js"></script>
<script type="text/javascript" src="<%=request.getContextPath() %>/share/yui/js/autocomplete-min.js"></script>
<style>
	input[type="number"]::-webkit-inner-spin-button, input[type="number"]::-webkit-outer-spin-button{
		-webkit-appearance: none;
		-moz-appearance: none;
	}
</style>
<script type="text/javascript">
    function changeContainerHeight(ele){
        var ss=$('searchString').value;
        ss=trim(ss);
        if(ss.length==0)
            $('autocomplete_choices').setStyle({height:'0%'});
        else
            $('autocomplete_choices').setStyle({height:'100%'});
    }
    var highlightMatch = function(full, snippet, matchindex) {
        return "<a title='"+full+"'>"+full.substring(0, matchindex) +
            "<span class=match>" +full.substr(matchindex, snippet.length) + "</span>" + full.substring(matchindex + snippet.length)+"</a>";
    };

    var highlightMatchInactiveMatchWord = function(full, snippet, matchindex) {
        return "<a title='"+full+"'>"+"<span class=matchInactive>"+full.substring(0, matchindex) +
            "<span class=match>" +full.substr(matchindex, snippet.length) +"</span>" + full.substring(matchindex + snippet.length)+"</span>"+"</a>";
    };
    var highlightMatchInactive = function(full, snippet, matchindex) {

        return "<a title='"+full+"'>"+"<span class=matchInactive>"+full+"</span>"+"</a>";
    };
    var resultFormatter2 = function(oResultData, sQuery, sResultMatch) {
        var query = sQuery.toUpperCase();
        var drugName = oResultData.name;
        var isInactive=oResultData.isInactive;

        var mIndex = drugName.toUpperCase().indexOf(query);
        var display = '';
        if(mIndex>-1 && (isInactive=='true'||isInactive==true)){ //match and inactive
            display=highlightMatchInactiveMatchWord(drugName,query,mIndex);
        }
        else if(mIndex > -1 && (isInactive=='false'||isInactive==false || isInactive==undefined || isInactive==null)){ //match and active
            display = highlightMatch(drugName,query,mIndex);
        }else if(mIndex<=-1 && (isInactive=='true'||isInactive==true)){//no match and inactive
            display=highlightMatchInactive(drugName,query,mIndex);
        }
        else{//active and no match
            display = drugName;
        }


        return  display;
    };

    YAHOO.example.FnMultipleFields = function(){
        var url = "<%=request.getContextPath() %>/oscarRx/searchDrug.do?method=jsonSearch";
        var oDS = new YAHOO.util.XHRDataSource(url,{connMethodPost:true,connXhrMode:'ingoreStaleResponse'});
        oDS.responseType = YAHOO.util.XHRDataSource.TYPE_JSON;// Set the responseType
        // Define the schema of the delimited results
        oDS.responseSchema = {
            resultsList : "results",
            fields : ["name", "id","isInactive"]
        };
        // Enable caching
        oDS.maxCacheEntries =0;
        oDS.connXhrMode ="cancelStaleRequests";
        // Instantiate AutoComplete
        var oAC = new YAHOO.widget.AutoComplete("searchString", "autocomplete_choices", oDS);
        oAC.useShadow = true;
        oAC.resultTypeList = false;
        oAC.queryMatchSubset = true;
        oAC.minQueryLength = 3;
        oAC.maxResultsDisplayed = 40;
        oAC.formatResult = resultFormatter2;



        // Define an event handler to populate a hidden form field
        // when an item gets selected and populate the input field
        //var myHiddenField = YAHOO.util.Dom.get("myHidden");
        var myHandler = function(type, args) {
            var arr = args[2];
            var ran_number = Math.round(Math.random()*1000000);
            var name = arr.name;
            var id = args[2].id;

            $('drugDisplay').show();
            $('drugName').value = name;
            $('drugId').value = id;

            $('searchString').value = "";
        };

        oAC.doBeforeExpandContainer = function(sQuery, oResponse) {
            if (oAC._nDisplayedItems < oAC.maxResultsDisplayed) {
                oAC.setFooter("");
            } else {
                oAC.setFooter("<a href='javascript:void(0)' onClick='popupRxSearchWindow();oAC.collapseContainer();'>See more results...</a>");
            }

            return true;
        };

        oAC.itemSelectEvent.subscribe(myHandler);
        var collapseFn=function(){
            $('autocomplete_choices').hide();
        };
        oAC.containerCollapseEvent.subscribe(collapseFn);
        var expandFn=function(){
            $('autocomplete_choices').show();
        };
        oAC.dataRequestEvent.subscribe(expandFn);
        return {
            oDS: oDS,
            oAC: oAC
        };


    }();
    
</script>

</body>
</html>
