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
<%@page import="oscar.oscarDemographic.data.EctInformation"%>
<%@page import="oscar.oscarDemographic.data.RxInformation"%>
<%@page import="org.oscarehr.common.model.Demographic"%>
<%@ page language="java"%>
<%@page
	import="java.util.ArrayList, java.util.Collections, java.util.List, oscar.dms.*, oscar.oscarEncounter.pageUtil.*,oscar.oscarEncounter.data.*, oscar.util.StringUtils, oscar.oscarLab.ca.on.*"%>
<%@page
	import="org.oscarehr.casemgmt.service.CaseManagementManager, org.oscarehr.casemgmt.model.CaseManagementNote, org.oscarehr.casemgmt.model.Issue, org.oscarehr.common.model.UserProperty, org.oscarehr.common.dao.UserPropertyDAO, org.springframework.web.context.support.*,org.springframework.web.context.*,java.text.DecimalFormat"%>
<%@ page import="oscar.form.*, oscar.OscarProperties"%>
<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean"%>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html"%>
<%@ taglib uri="/WEB-INF/struts-logic.tld" prefix="logic"%>
<%@ taglib uri="/WEB-INF/rewrite-tag.tld" prefix="rewrite"%>


<html>
 <head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>OFC - Female Consult</title>

<script type="text/javascript" src="../js/jquery.js"></script>
<script type="text/javascript"
	src="<%= request.getContextPath() %>/js/global.js"></script>
<!-- calendar stylesheet -->
<link rel="stylesheet" type="text/css" media="all"
	href="../share/calendar/calendar.css" title="win2k-cold-1" />

<!-- main calendar program -->
<script type="text/javascript" src="../share/calendar/calendar.js"></script>

<!-- language for the calendar -->
<script type="text/javascript"
	src="../share/calendar/lang/calendar-en.js"></script>

<!-- the following script defines the Calendar.setup helper function, which makes
       adding a calendar a matter of 1 or 2 lines of code. -->
<script type="text/javascript" src="../share/calendar/calendar-setup.js"></script>

<script>
function onclick_chk_group(chk_obj, chk_class)
{
	if($(chk_obj).attr("checked"))
	{
		var selected_obj = $(chk_obj);
		$("."+chk_class).each(function(){
			if($(this).attr("name") != $(selected_obj).attr("name"))
			{
				$(this).removeAttr("checked");
			}
		});
	}
}
</script>

</head> 

<style>
.field_row_div{
float: left;
white-space: nowrap;
margin-right: 4px;
height: 25px;
}
</style>

<%
	String formClass = "ConsultLetter";
	String formLink = "formConsultLetter.jsp";

   boolean readOnly = false;
   int demoNo = Integer.parseInt(request.getParameter("demographic_no"));
   int formId = Integer.parseInt(request.getParameter("formId"));
	int provNo = Integer.parseInt((String) session.getAttribute("user"));
	String providerNo = (String) session.getAttribute("user");
	FrmRecord rec = (new FrmRecordFactory()).factory(formClass);
	System.out.println("print new id " + formId);
 java.util.Properties props = rec.getFormRecord(demoNo, formId);
   
		String demo = request.getParameter("demographic_no");
        oscar.oscarDemographic.data.DemographicData demoData = null;
        Demographic demographic = null;
        demoData = new oscar.oscarDemographic.data.DemographicData();
        demographic = demoData.getDemographic(demo);

ArrayList<String> users = (ArrayList<String>)session.getServletContext().getAttribute("CaseMgmtUsers");
boolean useNewCmgmt = false;
WebApplicationContext  ctx = WebApplicationContextUtils.getRequiredWebApplicationContext(getServletContext());
CaseManagementManager cmgmtMgr = null;
if( users != null && users.size() > 0 && (users.get(0).equalsIgnoreCase("all") || Collections.binarySearch(users, providerNo)>=0)) {
        useNewCmgmt = true;
        cmgmtMgr = (CaseManagementManager)ctx.getBean("caseManagementManager");
}

String partner = props.getProperty("partner_no", "");
oscar.oscarDemographic.data.DemographicData partnerDemoData = null;
Demographic partnerDemographic = null;
if(partner != null && !"".equals(partner)){
	partnerDemoData = new oscar.oscarDemographic.data.DemographicData();
	partnerDemographic = partnerDemoData.getDemographic(partner);
	
	RxInformation rxInfo = new RxInformation();
	
	//partner medication and allergies
	props.setProperty("partner_allergies",
			org.apache.commons.lang.StringEscapeUtils.escapeJavaScript(rxInfo.getAllergies(partner)));
	props.setProperty("partner_medication",
			org.apache.commons.lang.StringEscapeUtils.escapeJavaScript(rxInfo.getCurrentMedication(partner)));
	props.setProperty("partner_medhistory",
			org.apache.commons.lang.StringEscapeUtils.escapeJavaScript(listNotes(cmgmtMgr, "MedHistory", providerNo, partner)) );
	props.setProperty("partner_familyhistory",
			org.apache.commons.lang.StringEscapeUtils.escapeJavaScript(listNotes(cmgmtMgr, "FamHistory", providerNo, partner)) );
	props.setProperty("partner_OMeds",
			org.apache.commons.lang.StringEscapeUtils.escapeJavaScript(listNotes(cmgmtMgr, "OMeds", providerNo, partner)) );

}

String spouse = props.getProperty("spouse_no", "");
oscar.oscarDemographic.data.DemographicData spouseDemoData = null;
Demographic spouseDemographic = null;
if(spouse != null && !"".equals(spouse)){
	spouseDemoData = new oscar.oscarDemographic.data.DemographicData();
	spouseDemographic = spouseDemoData.getDemographic(spouse);
	
	RxInformation rxInfo = new RxInformation();
	
	//spouse medication and allergies
	props.setProperty("spouse_allergies",
			org.apache.commons.lang.StringEscapeUtils.escapeJavaScript(rxInfo.getAllergies(spouse)));
	props.setProperty("spouse_medication",
			org.apache.commons.lang.StringEscapeUtils.escapeJavaScript(rxInfo.getCurrentMedication(spouse)));
	props.setProperty("spouse_medhistory",
			org.apache.commons.lang.StringEscapeUtils.escapeJavaScript(listNotes(cmgmtMgr, "MedHistory", providerNo, spouse)) );
	props.setProperty("spouse_familyhistory",
			org.apache.commons.lang.StringEscapeUtils.escapeJavaScript(listNotes(cmgmtMgr, "FamHistory", providerNo, spouse)) );
	props.setProperty("spouse_OMeds",
			org.apache.commons.lang.StringEscapeUtils.escapeJavaScript(listNotes(cmgmtMgr, "OMeds", providerNo, spouse)) );
}
String husband = props.getProperty("husband_no", "");
oscar.oscarDemographic.data.DemographicData husbandDemoData = null;
Demographic husbandDemographic = null;
if(husband != null && !"".equals(husband)){
		
	husbandDemoData = new oscar.oscarDemographic.data.DemographicData();
	husbandDemographic = husbandDemoData.getDemographic(husband);
	
	RxInformation rxInfo = new RxInformation();
	
	//husband medication and allergies
	System.out.println("husband is:555" + rxInfo.getAllergies(husband));
	props.setProperty("husband_allergies",
			org.apache.commons.lang.StringEscapeUtils.escapeJavaScript(rxInfo.getAllergies(husband)));
	props.setProperty("husband_medication",
			org.apache.commons.lang.StringEscapeUtils.escapeJavaScript(rxInfo.getCurrentMedication(husband)));
	props.setProperty("husband_medhistory",
			org.apache.commons.lang.StringEscapeUtils.escapeJavaScript(listNotes(cmgmtMgr, "MedHistory", providerNo, husband)) );
	props.setProperty("husband_familyhistory",
			org.apache.commons.lang.StringEscapeUtils.escapeJavaScript(listNotes(cmgmtMgr, "FamHistory", providerNo, husband)) );
	props.setProperty("husband_OMeds",
			org.apache.commons.lang.StringEscapeUtils.escapeJavaScript(listNotes(cmgmtMgr, "OMeds", providerNo, husband)) );
}
	
   request.removeAttribute("submit");
%>

<script type="text/javascript" language="Javascript">

var temp;
temp = "";


    function onPrint(pdf) {
        document.forms[0].action = "<rewrite:reWrite jspPage="formname.do"/>";
        document.forms[0].submit.value="printConsultLetter"; 
        document.forms[0].target="_blank";          
        return true;
    }
    function onSave() {
        if (temp != "") { document.forms[0].action = temp; }
        document.forms[0].target="_self";        
        document.forms[0].submit.value="save";
        var ret = checkAllDates();
        if(ret==true)
        {
            ret = confirm("Are you sure you want to save this form?");
        }
        return ret;
    }
    
    function onSaveExit() {
        if (temp != "") { document.forms[0].action = temp; }
        document.forms[0].target="_self";
        document.forms[0].submit.value="exit";
        var ret = checkAllDates();
        if(ret == true)
        {
            ret = confirm("Are you sure you wish to save and close this window?");
        }
        return ret;
    }
    
function popupFixedPage(vheight,vwidth,varpage) { 
  var page = "" + varpage;
  windowprop = "height="+vheight+",width="+vwidth+",location=no,scrollbars=yes,menubars=no,toolbars=no,resizable=yes,screenX=10,screenY=0,top=0,left=0";
  var popup=window.open(page, "planner", windowprop);
}

/**
 * DHTML date validation script. Courtesy of SmartWebby.com (http://www.smartwebby.com/dhtml/)
 */
// Declaring valid date character, minimum year and maximum year
var dtCh= "/";
var minYear=1900;
var maxYear=3100;

    function isInteger(s){
        var i;
        for (i = 0; i < s.length; i++){
            // Check that current character is number.
            var c = s.charAt(i);
            if (((c < "0") || (c > "9"))) return false;
        }
        // All characters are numbers.
        return true;
    }

    function stripCharsInBag(s, bag){
        var i;
        var returnString = "";
        // Search through string's characters one by one.
        // If character is not in bag, append to returnString.
        for (i = 0; i < s.length; i++){
            var c = s.charAt(i);
            if (bag.indexOf(c) == -1) returnString += c;
        }
        return returnString;
    }

    function daysInFebruary (year){
        // February has 29 days in any year evenly divisible by four,
        // EXCEPT for centurial years which are not also divisible by 400.
        return (((year % 4 == 0) && ( (!(year % 100 == 0)) || (year % 400 == 0))) ? 29 : 28 );
    }
    function DaysArray(n) {
        for (var i = 1; i <= n; i++) {
            this[i] = 31
            if (i==4 || i==6 || i==9 || i==11) {this[i] = 30}
            if (i==2) {this[i] = 29}
       }
       return this
    }

    function isDate(dtStr){
        var daysInMonth = DaysArray(12)
        var pos1=dtStr.indexOf(dtCh)
        var pos2=dtStr.indexOf(dtCh,pos1+1)
        var strMonth=dtStr.substring(0,pos1)
        var strDay=dtStr.substring(pos1+1,pos2)
        var strYear=dtStr.substring(pos2+1)
        strYr=strYear
        if (strDay.charAt(0)=="0" && strDay.length>1) strDay=strDay.substring(1)
        if (strMonth.charAt(0)=="0" && strMonth.length>1) strMonth=strMonth.substring(1)
        for (var i = 1; i <= 3; i++) {
            if (strYr.charAt(0)=="0" && strYr.length>1) strYr=strYr.substring(1)
        }
        month=parseInt(strMonth)
        day=parseInt(strDay)
        year=parseInt(strYr)
        if (pos1==-1 || pos2==-1){
            return "format"
        }
        if (month<1 || month>12){
            return "month"
        }
        if (day<1 || day>31 || (month==2 && day>daysInFebruary(year)) || day > daysInMonth[month]){
            return "day"
        }
        if (strYear.length != 4 || year==0 || year<minYear || year>maxYear){
            return "year"
        }
        if (dtStr.indexOf(dtCh,pos2+1)!=-1 || isInteger(stripCharsInBag(dtStr, dtCh))==false){
            return "date"
        }
    return true
    }


    function checkTypeIn(obj) {
      if(!checkTypeNum(obj.value) ) {
          alert ("You must type in a number in the field.");
        }
    }

    function valDate(dateBox)
    {
        try
        {
            var dateString = dateBox.value;
            if(dateString == "")
            {
    //            alert('dateString'+dateString);
                return true;
            }
            var dt = dateString.split('/');
            var y = dt[0];
            var m = dt[1];
            var d = dt[2];
            var orderString = m + '/' + d + '/' + y;
            var pass = isDate(orderString);

            if(pass!=true)
            {
                var s = dateBox.name;
                alert('Invalid '+pass+' in field ' + s.substring(3));
                dateBox.focus();
                return false;
            }
        }
        catch (ex)
        {
            alert('Catch Invalid Date in field ' + dateBox.name);
            dateBox.focus();
            return false;
        }
        return true;
    }

    function checkAllDates()
    {
        var b = true;
        if(valDate(document.forms[0].formDate)==false){
            b = false;
        }
        return b;

    }

    function popup(link) {
    windowprops = "height=700, width=960,location=no,"
    + "scrollbars=yes, menubars=no, toolbars=no, resizable=no, top=0, left=0 titlebar=yes";
    window.open(link, "_blank", windowprops);
}

function importFromEnct(reqInfo,txtArea)
{
    var info = "";
    switch( reqInfo )
    {
        case "Medical":
            <%
            String value = "";
                 if( demo != null )
                 {
                  if(OscarProperties.getInstance().getBooleanProperty("caisi","on")) {
                		 value = "";
                  }else{
					if( useNewCmgmt ) {
                        value = listNotes(cmgmtMgr, "MedHistory", providerNo, demo);
                    }
                    else {
                    //family history was used as bucket for Other Meds in old encounter
                    EctInformation ectInfo = new EctInformation(demo);
                        value = ectInfo.getFamilyHistory();
                    }
				  }
                    value = org.apache.commons.lang.StringEscapeUtils.escapeJavaScript(value);
                    out.println("info = '" + value + "'");

                }
              %>
             break;
          case "Family":
             <%
                 if( demo != null )
                 {
                  if(OscarProperties.getInstance().getBooleanProperty("caisi","on")) {
                		 value = "";
                  }else{
					if( useNewCmgmt ) {
                        value = listNotes(cmgmtMgr, "FamHistory", providerNo, demo);
                    }
                    else {
                    //family history was used as bucket for Other Meds in old encounter
                    EctInformation ectInfo = new EctInformation(demo);
                        value = ectInfo.getFamilyHistory();
                    }
				  }
                    value = org.apache.commons.lang.StringEscapeUtils.escapeJavaScript(value);
                    out.println("info = '" + value + "'");

                }
              %>
             break;
           case "Social":
              <%
                 if( demo != null )
                 {
                  if(OscarProperties.getInstance().getBooleanProperty("caisi","on")) {
                		 value = "";
                  }else{
					if( useNewCmgmt ) {
                        value = listNotes(cmgmtMgr, "SocHistory", providerNo, demo);
                    }
                    else {
                    //family history was used as bucket for Other Meds in old encounter
                    EctInformation ectInfo = new EctInformation(demo);
                        value = ectInfo.getFamilyHistory();
                    }
				  }
                    value = org.apache.commons.lang.StringEscapeUtils.escapeJavaScript(value);
                    out.println("info = '" + value + "'");

                }
              %>
             break;
			 case "Allergies":
              <%
              RxInformation rxInfo = new RxInformation();
                value = rxInfo.getAllergies(demo);
				value = org.apache.commons.lang.StringEscapeUtils.escapeJavaScript(value);
                out.println("info = '" + value + "'");
             %>
             break; 
			 case "OtherMeds":
              <%
                 if( demo != null )
                 {
                  if(OscarProperties.getInstance().getBooleanProperty("caisi","on")) {
                		 value = "";
                  }else{
					if( useNewCmgmt ) {
                        value = listNotes(cmgmtMgr, "OMeds", providerNo, demo);
                    }
                    else {
                    //family history was used as bucket for Other Meds in old encounter
                    EctInformation ectInfo = new EctInformation(demo);
                        value = ectInfo.getFamilyHistory();
                    }
				  }
                    value = org.apache.commons.lang.StringEscapeUtils.escapeJavaScript(value);
                    out.println("info = '" + value + "'");

                }
              %>
                break;
              case "Medication":
              <%
              RxInformation rxInfo1 = new RxInformation();
                value = rxInfo1.getCurrentMedication(demo);
				value = org.apache.commons.lang.StringEscapeUtils.escapeJavaScript(value);
                out.println("info = '" + value + "'");
             %>
             break; 
	} //end switch
	
    if( txtArea.value.length > 0 && info.length > 0 )
    {
    	//if(reqInfo=="Allergies")
        	txtArea.value += '; ';
    	/*else
    		txtArea.value += '\n';*/
    }

    txtArea.value += info;
    txtArea.scrollTop = txtArea.scrollHeight;
    txtArea.focus();

}
function importDoctor(lastNameCtrl,firstNameCtrl)
{
    lastNameCtrl.value = "<%=props.getProperty("family_doctor_default_lname", "")%>";
	firstNameCtrl.value = "<%=props.getProperty("family_doctor_default_fname", "")%>";
}

function importPatient(lastNameCtrl,firstNameCtrl)
{
    firstNameCtrl.value = "<%=props.getProperty("patient_default_fname", "")%>";
	lastNameCtrl.value = "<%=props.getProperty("patient_default_lname", "")%>";
}
function importPatientAge(ageCtrl)
{
    ageCtrl.value = '<%=props.getProperty("patient_default_age", "")%>';
	
}
function importPartner(lastNameCtrl,firstNameCtrl)
{	
	<%if(
		!(props.getProperty("partner_default_fname", "") == null || "".equals(props.getProperty("partner_default_fname", "")) ||
		props.getProperty("partner_default_lname", "") == null || "".equals(props.getProperty("partner_default_lname", ""))
		)){%>
    firstNameCtrl.value = "<%=props.getProperty("partner_default_fname", "")%>";
	lastNameCtrl.value = "<%=props.getProperty("partner_default_lname", "")%>";
	<%} else if(
		!(props.getProperty("spouse_default_fname", "") == null || "".equals(props.getProperty("spouse_default_fname", "")) ||
		props.getProperty("spouse_default_lname", "") == null || "".equals(props.getProperty("spouse_default_lname", ""))
		)){%>
	firstNameCtrl.value = "<%=props.getProperty("spouse_default_fname", "")%>";
	lastNameCtrl.value = "<%=props.getProperty("spouse_default_lname", "")%>";
	<%} else if(
		!(props.getProperty("husband_default_fname", "") == null || "".equals(props.getProperty("husband_default_fname", "")) ||
		props.getProperty("husband_default_lname", "") == null || "".equals(props.getProperty("husband_default_lname", ""))
		)){%>
	firstNameCtrl.value = "<%=props.getProperty("husband_default_fname", "")%>";
	lastNameCtrl.value = "<%=props.getProperty("husband_default_lname", "")%>";
	<%}%>
}
function importSpouse(lastNameCtrl,firstNameCtrl)
{
    firstNameCtrl.value = "<%=props.getProperty("spouse_default_fname", "")%>";
	lastNameCtrl.value = "<%=props.getProperty("spouse_default_lname", "")%>";
}
function importHusband(lastNameCtrl,firstNameCtrl)
{
    firstNameCtrl.value = "<%=props.getProperty("husband_default_fname", "")%>";
	lastNameCtrl.value = "<%=props.getProperty("husband_default_lname", "")%>";
}
function importPartnerAge(ageCtrl)
{
    <%if(
		!(
		props.getProperty("partner_default_age", "") == null || "".equals(props.getProperty("partner_default_age", ""))
		)){%>
    ageCtrl.value = '<%=props.getProperty("partner_default_age", "")%>';
	<%} else if(
		!(
		props.getProperty("spouse_default_age", "") == null || "".equals(props.getProperty("spouse_default_age", ""))
		)){%>
    ageCtrl.value = '<%=props.getProperty("spouse_default_age", "")%>';
	<%} else if(
		!(
		props.getProperty("husband_default_age", "") == null || "".equals(props.getProperty("husband_default_age", ""))
		)){%>
	ageCtrl.value = '<%=props.getProperty("husband_default_age", "")%>';
	<%}%>

	
	
}
function importHusbandAge(ageCtrl)
{
    ageCtrl.value = '<%=props.getProperty("husband_default_age", "")%>';
	
}
function importSpouseAge(ageCtrl)
{
    ageCtrl.value = '<%=props.getProperty("spouse_default_age", "")%>';
	
}
function importPartnerData(ctrlName, infotype)
{
    var info = "";
    switch( infotype )
    {
        case "allergies":
            <%
                value = getData("partner","allergies",props); 
            //	value = org.apache.commons.lang.StringEscapeUtils.escapeJavaScript(value);
                out.println("info = '" + value + "'");

              %>
             break;
          case "medication":
             <%
             value = getData("partner","medication",props); 
         	// value = org.apache.commons.lang.StringEscapeUtils.escapeJavaScript(value);
             out.println("info = '" + value + "'");
              %>
             break;
           case "medhistory":
              <%
              value = getData("partner","medhistory",props); 
          	// value = org.apache.commons.lang.StringEscapeUtils.escapeJavaScript(value);
              out.println("info = '" + value + "'");
              %>
             break;
			 case "familyhistory":
              <%

              value = getData("partner","familyhistory",props); 
          	 //value = org.apache.commons.lang.StringEscapeUtils.escapeJavaScript(value);
              out.println("info = '" + value + "'");
             %>
             break; 
			 case "OMeds":
              <%

              value = getData("partner","OMeds",props); 
          	 //value = org.apache.commons.lang.StringEscapeUtils.escapeJavaScript(value);
              out.println("info = '" + value + "'");
             %>
             break; 
	} //end switch

    if( ctrlName.value.length > 0 && info.length > 0 ){
    	ctrlName.value += '; ';
    }
      //  ctrlName.value += '\n';

    ctrlName.value += info;
    ctrlName.scrollTop = ctrlName.scrollHeight;
    ctrlName.focus();
	
}
function importSpouseData(ctrlName, infotype)
{
	//alert(ctrlName+" - "+infotype);
    var info = "";
    switch( infotype )
    {
        case "allergies":
            <%
                value = getData("spouse","allergies",props); 
            //	value = org.apache.commons.lang.StringEscapeUtils.escapeJavaScript(value);
                out.println("info = '" + value + "'");

              %>
             break;
          case "medication":
             <%
             value = getData("spouse","medication",props); 
         	 //value = org.apache.commons.lang.StringEscapeUtils.escapeJavaScript(value);
             out.println("info = '" + value + "'");
              %>
             break;
           case "medhistory":
              <%
              value = getData("spouse","medhistory",props); 
          	// value = org.apache.commons.lang.StringEscapeUtils.escapeJavaScript(value);
              out.println("info = '" + value + "'");
              %>
             break;
			 case "familyhistory":
              <%

              value = getData("spouse","familyhistory",props); 
          	// value = org.apache.commons.lang.StringEscapeUtils.escapeJavaScript(value);
              out.println("info = '" + value + "'");
             %>
             break;
			 case "OMeds":
              <%

              value = getData("spouse","OMeds",props); 
          	// value = org.apache.commons.lang.StringEscapeUtils.escapeJavaScript(value);
              out.println("info = '" + value + "'");
             %>
             break;
	} //end switch

    if( ctrlName.value.length > 0 && info.length > 0 ){}
      //  ctrlName.value += '\n';

    ctrlName.value += info;
    ctrlName.scrollTop = ctrlName.scrollHeight;
    ctrlName.focus();
	
}
function importHusbandData(ctrlName, infotype)
{
    var info = "";
	
   switch( infotype )
    {
        case "allergies":
            <%
                value = getData("husband","allergies",props); 
            	//value = org.apache.commons.lang.StringEscapeUtils.escapeJavaScript(value);
                out.println("info = '" + value + "'");

              %>
				  
             break;
          case "medication":
             <%
             value = getData("husband","medication",props); 
         	 //value = org.apache.commons.lang.StringEscapeUtils.escapeJavaScript(value);
             out.println("info = '" + value + "'");
              %>
             break;
           case "medhistory":
              <%
              value = getData("husband","medhistory",props); 
          	 //value = org.apache.commons.lang.StringEscapeUtils.escapeJavaScript(value);
              out.println("info = '" + value + "'");
              %>
             break;
			 case "familyhistory":
              <%

              value = getData("husband","familyhistory",props); 
          	 //value = org.apache.commons.lang.StringEscapeUtils.escapeJavaScript(value);
              out.println("info = '" + value + "'");
             %>
             break; 
			 case "OMeds":
              <%

              value = getData("husband","OMeds",props); 
          	 //value = org.apache.commons.lang.StringEscapeUtils.escapeJavaScript(value);
              out.println("info = '" + value + "'");
             %>
             break; 
	} //end switch

    if( ctrlName.value.length > 0 && info.length > 0 ){
    	ctrlName.value += '; ';
    }
        //ctrlName.value += '\n';
	
    ctrlName.value += info;
    ctrlName.scrollTop = ctrlName.scrollHeight;
    ctrlName.focus();
	
}

function toggleControl(srcCtrlName, targetControl){
	if(srcCtrlName.checked==true){
		targetControl.disabled=false;
	}
	if(srcCtrlName.checked==false){
		targetControl.value="";
		targetControl.disabled=true;
		targetControl.checked=false;
	}
	
}

function toggleControl_(srcCtrlName, targetControl){
	if(srcCtrlName.checked==true){
		$(targetControl).each(function(){
			$(this).removeAttr("disabled");
		});
	}
	if(srcCtrlName.checked==false){
		$(targetControl).each(function(){
			$(this).val("");
			$(this).attr("disabled", "disabled");
		});
		
		targetControl.checked=false;
	}
	
}

function toggleRevControl(srcCtrlName, targetControl){
	if(srcCtrlName.checked==true){
		targetControl.value="";
		targetControl.disabled=true;
		targetControl.checked=false;
	}
	if(srcCtrlName.checked==false){
		targetControl.disabled=false;
	}
	
}

function calcBMI(weightCtrl,weightUOMCtrl,heightCtrl,heightUOMCtrl,bmiCtrl,inchctrl)
{	if(weightCtrl.value=="")
	{
		alert("Enter the value for weight");
		return;
	}
	if(weightUOMCtrl.value=="")
	{
		alert("Enter the value for weight uom");
		return;
	}
	if(heightCtrl.value=="")
	{
		alert("Enter the value for height");
		return;
	}
	if(heightUOMCtrl.value=="")
	{
		alert("Enter the value for height uom");
		return;
	}
	/*if(heightUOMCtrl.value=="feet")
	{	if(inchctrl.value==""){
			inchctrl.value=0;
		}
	}*/
	/*
	var weight = weightCtrl.value;
	var weightUOM  = weightUOMCtrl.value;
	var height = heightCtrl.value;
	var heightUom = heightUOMCtrl.value;
	
	
	var bmi;
	if("kg"==weightUOM){
		var heightinmetres = height; 
		if("cm"==heightUom){
			heightinmetres = heightinmetres/100;
		}else if("feet"==heightUom){
			heightinmetres = heightinmetres*0.305;
		}else{
			//invalid selection
		}
		if(inchctrl.value!=""){
			heightinmetres = heightinmetres + inchctrl.value*0.0254;
		}
		bmi = weight/(heightinmetres*heightinmetres);
	}else if("lb"==weightUOM){
		var heightinches = height; //entered
		if("cm"==heightUom){
			heightinches = heightinches*0.3937;
		}else if("feet"==heightUom){
			heightinches = heightinches*30.48;
		}else{
			//invalid selection
		}
		if(inchctrl.value!=""){
			heightinches = heightinches + inchctrl.value;
		}
		bmi = (weight * 703)/(heightinches*heightinches);
	}
	bmi = Math.round(bmi);

	bmiCtrl.value=bmi;*/
	compute(weightCtrl,weightUOMCtrl,heightCtrl,heightUOMCtrl,bmiCtrl,inchctrl);
}

function cal_bmi(lbs, ins)
{
   h2 = ins * ins;
   bmi = lbs/h2 * 703
   f_bmi = Math.floor(bmi);
   diff  = bmi - f_bmi;
   diff = diff * 10;
   diff = Math.round(diff);

   if (diff == 10)    // Need to bump up the whole thing instead
   {
      f_bmi += 1;
      diff   = 0;
   }
   bmi = f_bmi + "." + diff;
   return bmi;
}

function compute(weightCtrl,weightUOMCtrl,heightCtrl,heightUOMCtrl,bmiCtrl,inchctrl){
   var f = self.document.forms[0];

   w = weightCtrl.value;
   v = heightCtrl.value;
   u = inchctrl.value;
	
	   if (!chkw(v))
   {
     alert("Please enter a number for your height.");
     heightCtrl.focus();
     return;
   }
   if (!chkw(w))
   {
     alert("Please enter a number for your weight.");
     weightCtrl.focus();
     return;
   }

   // Format values for the BMI calculation
   if("cm"==heightUOMCtrl.value){
		i = heightCtrl.value*0.393700787;
		if("kg"==weightUOMCtrl.value){
		bmiCtrl.value = cal_bmi(w/0.45359237, i);
		}else{
		bmiCtrl.value = cal_bmi(w, i);
		}
		return;
   }

   if (!chkw(u))
   {
     var ii = 0;
     inchctrl.value = 0;
   } else
   {
     var it = inchctrl.value*1;
     var ii = parseInt(it);
    }
	
   
   var fi = parseInt(heightCtrl.value * 12);
   var i =  parseInt(heightCtrl.value * 12) + inchctrl.value*1.0;  

   
  // Do validation of remaining fields to check for existence of values

   // Perform the calculation
   if("kg"==weightUOMCtrl.value){
		bmiCtrl.value = cal_bmi(w/0.45359237, i);
   }else{
		bmiCtrl.value = cal_bmi(w, i);
   }
   bmiCtrl.focus();
}

function chkw(w){
   if (isNaN(parseInt(w))){
      return false;
   } else if (w < 0){
  return false;
  }
  else{
  return true;
  }
}


function toggleHeight(heightuomctrl,inchCtrl){
	if(heightuomctrl.value=="feet"){
		inchCtrl.disabled=false;
	}else{
		inchCtrl.value="";
		inchCtrl.disabled=true;;
	}
}
</script>

<html:form action="/form/formname">
<body style="margin: 0;">
<table align="center" border="0" RULES=NONE FRAME=BOX bgcolor="silver" style="width: 100%;"  >
		 <tr> 
			 <td>
				<input type="submit" value="Save" onclick="javascript:return onSave();" /> 
				<input type="submit" value="Save and Exit" onclick="javascript:return onSaveExit();" />
				<input type="submit" value="Exit" onclick="javascript:return onExit();" /> 
				<input type="submit" value="Save and Print Preview" onclick="javascript:return onPrint(false);" />
			</td>
		</tr>
		<input type="hidden" name="demographic_no"
		value="<%= props.getProperty("demographic_no", "0") %>" />
	<input type="hidden" name="ID" value="<%= formId %>" />
	<input type="hidden" name="provider_no"
		value=<%=request.getParameter("provider_no")%> />
	<input type="hidden" name="formCreated"
		value="<%= props.getProperty("formCreated", "") %>" />
	<input type="hidden" name="form_class" value="<%=formClass%>" />
	<input type="hidden" name="form_link" value="<%=formLink%>" />
	<input type="hidden" name="submit" value="exit" />
	<input type="hidden" name="formCreated"
		value="<%= props.getProperty("formCreated", "") %>" />
	<input type="hidden" name="re_text" 
		value="<%= props.getProperty("re_text", "") %>" />
		
		<tr bgcolor="white"><td>
		<font face="Calibri" size="14">Ottawa Fertility Centre</font><br>
		<font face="Calibri" size="6">Female Consult Template</font></td>
		</tr>
		<tr>
			<td height="10px"><u><font size="4"><b>Patient &
			Consultation Information:</b></font></u></td>
		</tr>
		<tr>
			<td>Date:&nbsp;<input tabindex="5" type="text" maxlength="15"
				name="consultDate" id="consultDate" size="10"
				value="<%=props.getProperty("consultDate", "")%>" /> <img
				src="../images/cal.gif" id="consultDate_cal"><br>
			<br>
			</td>
		</tr>
		<tr>
			<td>Patient Name: &nbsp;&nbsp; <input type="button"
				value="Patient"
				onclick="importPatient(document.forms[0].patient_lname,document.forms[0].patient_fname);">
			&nbsp;</td>
		</tr>
		<tr>
			<td><input name="patient_lname" type="text" maxlength="15" 
				value="<%=props.getProperty("patient_lname", "")%>">, <input
				name="patient_fname" type="text" maxlength="15"
				value="<%=props.getProperty("patient_fname", "")%>"><br>
			<br>
			</td>
		</tr>
		<tr>
			<td>Patient Age: &nbsp;&nbsp; <input type="button"
				value="Patient Age"
				onclick="importPatientAge(document.forms[0].patient_age);">
			&nbsp;
		</tr>
		<tr> 
			<td><input name="patient_age" type="text" maxlength="15"
				value="<%=props.getProperty("patient_age", "")%>"><br>
			<br>
			</td>
		</tr>
		<tr>
			<td>Partner Name: &nbsp;&nbsp; <input type="button"
				value="Partner"
				onclick="importPartner(document.forms[0].partner_lname,document.forms[0].partner_fname);">
			<!--<input type="button" value="Spouse"
				onclick="importSpouse(document.forms[0].partner_lname,document.forms[0].partner_fname);">
			<input type="button" value="Husband"
				onclick="importHusband(document.forms[0].partner_lname,document.forms[0].partner_fname);">
			&nbsp;--></td>
		</tr>
		<tr>
			<td><input name="partner_lname" type="text" maxlength="15"
				value="<%=props.getProperty("partner_lname", "")%>">, <input
				name="partner_fname" type="text" maxlength="15"
				value="<%=props.getProperty("partner_fname", "")%>"><br>
			<br>
			</td>
		</tr>
		<tr>
			<td>Partner Age: &nbsp;&nbsp; <input type="button"
				value="Partner Age"
				onclick="importPartnerAge(document.forms[0].partner_age);">
			<!--<input type="button" value="Spouse Age"
				onclick="importSpouseAge(document.forms[0].partner_age);"> <input
				type="button" value="Husband Age"
				onclick="importHusbandAge(document.forms[0].partner_age);">
			&nbsp;-->
		</tr>
		<tr>
			<td><input name="partner_age" type="text" maxlength="15"
				value="<%=props.getProperty("partner_age", "")%>"><br>
			<br>
			</td>
		</tr>
		<tr>
			<td>Referring Physician Name: &nbsp;&nbsp;<input type="button"
				value="Doctor"
				onclick="importDoctor(document.forms[0].family_doctor_lname,document.forms[0].family_doctor_fname);">
			&nbsp;
		</tr>
		<tr>
			<td><input name="family_doctor_lname" type="text" maxlength="15"
				value="<%=props.getProperty("family_doctor_lname", "")%>">,
			<input name="family_doctor_fname" type="text" maxlength="15"
				value="<%=props.getProperty("family_doctor_fname", "")%>"><br>
			<br>
			</td>
		</tr>
		<tr>
			<td height="10px"><u><font size="4"><b>Reason for
			Consultation:</b></font></u></td>
		</tr>
		<tr>
			<td><input type="checkbox" name="rfc_infertility"
				<%=props.getProperty("rfc_infertility", "")%>>Infertility<br>
			<input type="checkbox" name="rfc_rpl"
				<%=props.getProperty("rfc_rpl", "")%>>Recurrent Pregnancy
			loss<br>
			<input type="checkbox" name="rfc_fp"
				<%=props.getProperty("rfc_fp", "")%>>Fertility Preservation<br>
			<input type="checkbox" name="rfc_ivf"
				<%=props.getProperty("rfc_ivf", "")%>>IVF<br>				
			<input type="checkbox" name="rfc_afp"
				<%=props.getProperty("rfc_afp", "")%>>Assessment of
			fertility potential<br>
			<input type="checkbox" name="rfc_endometriosis"
				<%=props.getProperty("rfc_endometriosis", "")%>>Endometriosis<br>
			<input type="checkbox" name="rfc_amenorrhea"
				<%=props.getProperty("rfc_amenorrhea", "")%>>Amenorrhea<br>
			<input type="checkbox" name="rfc_ros"
				<%=props.getProperty("rfc_ros", "")%>>Reversal of
			sterilization<br>
			<input type="checkbox" name="rfc_ps"
				<%=props.getProperty("rfc_ps", "")%>>Possible surgery<br>
			<input type="checkbox" name="rfc_pcos"
				<%=props.getProperty("rfc_pcos", "")%>>PCOS<br>
			<input type="checkbox" name="rfc_pof"
				<%=props.getProperty("rfc_pof", "")%>>Premature ovarian
			failure<br>
			<input type="checkbox" name="rfc_tdi"
				<%=props.getProperty("rfc_tdi", "")%>>Therapeutic donor
			insemination<br>
			<input type="checkbox" name="rfc_det"
				<%=props.getProperty("rfc_det", "")%>>Donor egg therapy<br>
			<input type="checkbox" name="rfc_mfi"
				<%=props.getProperty("rfc_mfi", "")%>>Male Factor
			Infertility<br>
			<input type="checkbox" name="rfc_hov"
				<%=props.getProperty("rfc_hov", "")%>>History of vasectomy</td>
		</tr>
		<tr>
			<td>Other:<br>
			<textarea name="rfc_other" cols="1" rows="4" style="width: 750px;"><%=props.getProperty("rfc_other", "")%></textarea>
			</td>
		</tr>

		<tr>
			<td>&nbsp;</td>
		</tr>

		<tr>
			<td height="10px"><u><font size="4"><b>Relevant
			Fertility History:</b></font></u></td>
		</tr>
		<!--<tr>
			<td height="10px"><font size="3"><b><i>a)
			Ovulation Factors</i></b></font></td>
		</tr>-->
		<tr>
			<td><input type="checkbox" name="rfhof_lmp" onchange="toggleControl(document.forms[0].rfhof_lmp,document.forms[0].rfhof_lmp_t);
			toggleControl(document.forms[0].rfhof_lmp,document.forms[0].rfhof_lmp_t_cal)"
				<%=props.getProperty("rfhof_lmp", "")%>>LMP &nbsp;&nbsp; <input
				name="rfhof_lmp_t" id="rfhof_lmp_t" type="text"  maxlength="15" 
				<%= getdisablestatus(props,"rfhof_lmp") %> 
				value="<%=props.getProperty("rfhof_lmp_t", "")%>"> <img
				src="../images/cal.gif" id="rfhof_lmp_t_cal"  <%= getdisablestatus(props,"rfhof_lmp") %>  ><br>
			<input type="checkbox" name="rfhof_gtpaepl" onchange="toggleControl(document.forms[0].rfhof_gtpaepl,document.forms[0].rfhof_gtpaepl_gt)
			;toggleControl(document.forms[0].rfhof_gtpaepl,document.forms[0].rfhof_gtpaepl_tt)
			;toggleControl(document.forms[0].rfhof_gtpaepl,document.forms[0].rfhof_gtpaepl_pt)
			;toggleControl(document.forms[0].rfhof_gtpaepl,document.forms[0].rfhof_gtpaepl_at)
			;toggleControl(document.forms[0].rfhof_gtpaepl,document.forms[0].rfhof_gtpaepl_tat)
			;toggleControl(document.forms[0].rfhof_gtpaepl,document.forms[0].rfhof_gtpaepl_ept)
			;toggleControl(document.forms[0].rfhof_gtpaepl,document.forms[0].rfhof_gtpaepl_lt)"
				<%=props.getProperty("rfhof_gtpaepl", "")%>>G&nbsp;<input
				name="rfhof_gtpaepl_gt" type="text" maxlength="15"  
				<%= getdisablestatus(props,"rfhof_gtpaepl") %> 
				 size="2" 
				value="<%=props.getProperty("rfhof_gtpaepl_gt", "")%>">
			T&nbsp;<input name="rfhof_gtpaepl_tt" <%= getdisablestatus(props,"rfhof_gtpaepl") %> type="text"  maxlength="15" size="2"
				value="<%=props.getProperty("rfhof_gtpaepl_tt", "")%>">
			P&nbsp;<input name="rfhof_gtpaepl_pt" <%= getdisablestatus(props,"rfhof_gtpaepl") %> type="text"  maxlength="15" size="2"
				value="<%=props.getProperty("rfhof_gtpaepl_pt", "")%>">
			A&nbsp;<input name="rfhof_gtpaepl_at" <%= getdisablestatus(props,"rfhof_gtpaepl") %>" type="text" maxlength="15" size="2"
				value="<%=props.getProperty("rfhof_gtpaepl_at", "")%>">
			TA&nbsp;<input name="rfhof_gtpaepl_tat" <%= getdisablestatus(props,"rfhof_gtpaepl") %>" type="text" maxlength="15" size="2"
				value="<%=props.getProperty("rfhof_gtpaepl_tat", "")%>">
			EP&nbsp;<input name="rfhof_gtpaepl_ept" <%= getdisablestatus(props,"rfhof_gtpaepl") %> type="text"  maxlength="15" size="2"
				value="<%=props.getProperty("rfhof_gtpaepl_ept", "")%>">L&nbsp;<input
				name="rfhof_gtpaepl_lt" type="text" maxlength="15" <%= getdisablestatus(props,"rfhof_gtpaepl") %>  size="2"
				value="<%=props.getProperty("rfhof_gtpaepl_lt", "")%>"><br>
			<input type="checkbox" name="rfhof_dot" onchange="toggleControl(document.forms[0].rfhof_dot,document.forms[0].rfhof_dot_t)"
				<%=props.getProperty("rfhof_dot", "")%>>Duration of
			trying&nbsp;&nbsp;<input name="rfhof_dot_t" type="text"  maxlength="15" <%= getdisablestatus(props,"rfhof_dot") %>
				value="<%=props.getProperty("rfhof_dot_t", "")%>"><br>
			<input type="checkbox" name="rfhof_menarche" onchange="toggleControl(document.forms[0].rfhof_menarche,document.forms[0].rfhof_menarche_t)"
				<%=props.getProperty("rfhof_menarche", "")%>>Menarche&nbsp;&nbsp;<input
				name="rfhof_menarche_t" type="text" maxlength="15" <%= getdisablestatus(props,"rfhof_menarche") %>
				value="<%=props.getProperty("rfhof_menarche_t", "")%>"></td>
		</tr>
		<tr>
			<td>Other:<br>
			<textarea name="rfhof_other" cols="1" rows="4" style="width: 750px;"><%=props.getProperty("rfhof_other", "")%></textarea>
			</td>
		</tr>

		<tr>
			<td>&nbsp;</td>
		</tr>

		<tr>
			<td height="10px"><font size="3"><b><i>a)
			Ovulation / Menstral Factors</i></b></font></td>
		</tr>
		<tr>
			<td><input type="checkbox" name="rfhof_ci" onchange="toggleControl(document.forms[0].rfhof_ci,document.forms[0].rfhof_ci_t)"
				<%=props.getProperty("rfhof_ci", "")%>>Cycle interval
			&nbsp;&nbsp;<input name="rfhof_ci_t" <%= getdisablestatus(props,"rfhof_ci") %> type="text" maxlength="15"
				value="<%=props.getProperty("rfhof_ci_t", "")%>"><br>
			<input type="checkbox" name="rfhtf_atd" onchange="toggleControl(document.forms[0].rfhtf_atd,document.forms[0].rfhtf_atd_t)"
				<%=props.getProperty("rfhtf_atd", "")%>>Admits to <select
				name="rfhtf_atd_t" <%= getdisablestatus(props,"rfhtf_atd") %> value="<%=props.getProperty("rfhtf_atd_t", "")%>">
				<option value="">
				<option value="no">no
				<option value="mild">mild
				<option value="moderate">moderate
				<option value="severe">severe
			</select>&nbsp;dysmenorrhea<br>
			
			<input type="checkbox" name="rfhof_dof" onchange="toggleControl(document.forms[0].rfhof_dof,document.forms[0].rfhof_dof_t)"
				<%=props.getProperty("rfhof_dof", "")%>>Duration of flow 
			&nbsp;&nbsp;<input name="rfhof_dof_t" <%= getdisablestatus(props,"rfhof_dof") %> type="text" maxlength="2" style="width: 25px;"
				value="<%=props.getProperty("rfhof_dof_t", "")%>">&nbsp;days<br>
			
			<input type="checkbox" name="rfhof_fl" onchange="toggleControl_(document.forms[0].rfhof_fl,document.forms[0].rfhof_fl_t)"
				<%=props.getProperty("rfhof_fl", "")%>>Flow is
			<input type="radio" name="rfhof_fl_t" value="normal" <%= getdisablestatus(props,"rfhof_fl") %>
			<%=props.getProperty("rfhof_fl_t", "").equals("normal")?"checked":"" %> />Normal 
			<input type="radio" name="rfhof_fl_t" value="light" <%= getdisablestatus(props,"rfhof_fl") %>
			<%=props.getProperty("rfhof_fl_t", "").equals("light")?"checked":"" %>/>Light 
			<input type="radio" name="rfhof_fl_t" value="heavy" <%= getdisablestatus(props,"rfhof_fl") %>
			<%=props.getProperty("rfhof_fl_t", "").equals("heavy")?"checked":"" %>/>Heavy <br>
			
			<input type="checkbox" name="rfhof_ra" class="acne_chk" 
			onclick="onclick_chk_group(this, 'acne_chk')"  
				<%=props.getProperty("rfhof_ra", "")%>>Reports acne, &nbsp;<input type="checkbox" 
				name="rfhof_ra_d"  class="acne_chk" onclick="onclick_chk_group(this, 'acne_chk')" 
				<%=props.getProperty("rfhof_ra_d", "")%>>Denies acne
			<br>
			
			<input type="checkbox" name="rfhof_rh" class="hirsutism_chk"
			onclick="onclick_chk_group(this, 'hirsutism_chk')" 
				<%=props.getProperty("rfhof_rh", "")%>>Reports hirsutism, &nbsp;<input type="checkbox" 
				name="rfhof_rh_d"  class="hirsutism_chk" onclick="onclick_chk_group(this, 'hirsutism_chk')" 
				<%=props.getProperty("rfhof_rh_d", "")%>>Denies hirsutism
				<br>
				
			<input type="checkbox" name="rfhof_rg" class="galactorrhea_chk"
			onclick="onclick_chk_group(this, 'galactorrhea_chk')"
				<%=props.getProperty("rfhof_rg", "")%>>Reports galactorrhea, &nbsp;<input type="checkbox" 
				name="rfhof_rg_d"  class="galactorrhea_chk" onclick="onclick_chk_group(this, 'galactorrhea_chk')" 
				<%=props.getProperty("rfhof_rg_d", "")%>>Denies galactorrhea
			</td>
		</tr>
		<tr>
			<td>Other:<br>
			<textarea name="rfhof_other2" cols="1" rows="4" style="width: 750px;"><%=props.getProperty("rfhof_other2", "")%></textarea>
			</td>
		</tr>

		<tr>
			<td>&nbsp;</td>
		</tr>

		<tr>
			<td height="10px"><font size="3"><b><i>b) Tubal
			Factors</i></b></font></td>
		</tr>
		<tr>
			<td>
			<input type="checkbox" name="rfhtf_sti" onchange="toggleControl(document.forms[0].rfhtf_sti,document.forms[0].rfhtf_sti_t)"
				<%=props.getProperty("rfhtf_sti", "")%>>Has a history of
			STI
			<input name="rfhtf_sti_t" type="text" maxlength="60" size="60" size="60" <%= getdisablestatus(props,"rfhtf_sti") %>
				value="<%=props.getProperty("rfhtf_sti_t", "")%>">
			<br>
			
			<input type="checkbox" name="rfhtf_sti_no" 
				<%=props.getProperty("rfhtf_sti_no", "")%>>Has no history of previous STI <br>
			
			<input type="checkbox" name="rfhtf_pid" onchange="toggleControl(document.forms[0].rfhtf_pid,document.forms[0].rfhtf_pid_t)"
				<%=props.getProperty("rfhtf_pid", "")%>>Has history of
			PID&nbsp;&nbsp;<input name="rfhtf_pid_t" type="text" maxlength="60" size="60" size="60" <%= getdisablestatus(props,"rfhtf_pid") %>
				value="<%=props.getProperty("rfhtf_pid_t", "")%>"><br>
			<input type="checkbox" name="rfhtf_pelvsurg" onchange="toggleControl(document.forms[0].rfhtf_pelvsurg,document.forms[0].rfhtf_pelvsurg_t)"
				<%=props.getProperty("rfhtf_pelvsurg", "")%>>Has a history
			of pelvic surgery&nbsp;&nbsp;<input name="rfhtf_pelvsurg_t" <%= getdisablestatus(props,"rfhtf_pelvsurg") %>
				type="text" maxlength="60"  size="60" value="<%=props.getProperty("rfhtf_pelvsurg_t", "")%>"><br>
			
			<input type="checkbox" name="rfhtf_ectpsurg" onchange="toggleControl(document.forms[0].rfhtf_ectpsurg,document.forms[0].rfhtf_ectpsurg_t)"
				<%=props.getProperty("rfhtf_ectpsurg", "")%>>Has a history
			of ectopic pregnancy
			<input name="rfhtf_ectpsurg_t" type="text" maxlength="60" size="60" size="60" <%= getdisablestatus(props,"rfhtf_ectpsurg") %>
				value="<%=props.getProperty("rfhtf_ectpsurg_t", "")%>">
			<br>
			
			<input type="checkbox" name="rfhtf_dtrs"
				<%=props.getProperty("rfhtf_dtrs", "")%>>Denies any tubal
			risk factors
			<script language="javascript">
						if(document.forms[0].rfhtf_atd_t != null) {
							document.forms[0].rfhtf_atd_t.value = '<%=props.getProperty("rfhtf_atd_t", "")%>';
						}
					</script>
				
			<br><input type="checkbox" name="rfhtf_prev_iud" 
			<%=props.getProperty("rfhtf_prev_iud", "")%>>Previous use of IUD					
					
		</td>
		</tr>
		<tr>
			<td>Other:<br>
			<textarea name="rfhtf_other" cols="1" rows="4" style="width: 750px;"><%=props.getProperty("rfhtf_other", "")%></textarea>
			</td>
		</tr>

		<tr>
			<td>&nbsp;</td>
		</tr>

		<tr>
			<td height="10px"><font size="3"><b><i>c) Coital
			Factors</i></b></font></td>
		</tr>
		<tr>
			<td><input type="checkbox" name="rfhcf_ri" onchange="toggleControl(document.forms[0].rfhcf_ri,document.forms[0].rfhcf_ri_t)"
				<%=props.getProperty("rfhcf_ri", "")%>>Regular
			intercourse&nbsp;&nbsp;<input name="rfhcf_ri_t" type="text" maxlength="15" <%= getdisablestatus(props,"rfhcf_ri") %>
				value="<%=props.getProperty("rfhcf_ri_t", "")%>"><br>
				
			<input type="checkbox" name="rfhtf_atdd"
				<%=props.getProperty("rfhtf_atdd", "")%>>Admits to deep
			dysparuenia<br>

			<input type="checkbox" name="rfhcf_pd_no"
			<%=props.getProperty("rfhcf_pd_no", "")%>>Has no dyspareunia<br>
							
			<input type="checkbox" name="rfhcf_pd"
				<%=props.getProperty("rfhcf_pd", "")%>>Penetration
			dyspareunia<br>
			
			<input type="checkbox" name="rfhcf_erd"
				<%=props.getProperty("rfhcf_erd", "")%>>Erectile dysfunction<br>
			<input type="checkbox" name="rfhcf_ejd"
				<%=props.getProperty("rfhcf_ejd", "")%>>Ejaculatory
			dysfunction<br>
			<input type="checkbox" name="rfhcf_dl"
				<%=props.getProperty("rfhcf_dl", "")%>>Decreased male/female
			libido<br>
			
			<input type="checkbox" name="rfhcf_dl_f"
			<%=props.getProperty("rfhcf_dl_f", "")%>>Decreased female libido<br>
			
			<input type="checkbox" name="rfhcf_nsf"
				<%=props.getProperty("rfhcf_nsf", "")%>>Normal sexual
			function<br>
			<input type="checkbox" name="rfhcf_lubricants"
				<%=props.getProperty("rfhcf_lubricants", "")%>>Lubricants<br>
				
			<input type="checkbox" name="rfhcf_lubricants_no"
			<%=props.getProperty("rfhcf_lubricants_no", "")%>>Couple not using lubricants</td>
			
		</tr>
		<tr>
			<td>Other:<br>
			<textarea name="rfhcf_other" cols="1" rows="4" style="width: 750px;"><%=props.getProperty("rfhcf_other", "")%></textarea>
			</td>
		</tr>

		<tr>
			<td>&nbsp;</td>
		</tr>

		
		<tr>
			<td height="10px"><u><font size="4"><b>Previous
			Investigations:</b></font></u></td>
		</tr>
		<tr>
			<td><input type="checkbox" name="pi_tp" onchange="toggleControl(document.forms[0].pi_tp,document.forms[0].pi_tp_t)
;toggleControl(document.forms[0].pi_tp,document.forms[0].pi_tp_normal)
;toggleControl(document.forms[0].pi_tp,document.forms[0].pi_tp_abnormal)
;;toggleControl(document.forms[0].pi_tp_abnormal,document.forms[0].pi_tp_abnormal_t)"
				<%=props.getProperty("pi_tp", "")%>>Tubal
			patency:&nbsp;&nbsp;<input name="pi_tp_t" type="text" maxlength="40" <%= getdisablestatus(props,"pi_tp") %>
				value="<%=props.getProperty("pi_tp_t", "")%>"> &nbsp;&nbsp;<input
				type="checkbox" name="pi_tp_normal" <%= getdisablestatus(props,"pi_tp") %>
				<%=props.getProperty("pi_tp_normal", "")%>
				onchange="toggleControl(document.forms[0].pi_tp_abnormal,document.forms[0].pi_tp_abnormal_t)"
				onClick="pi_tp_abnormal.checked=!pi_tp_normal.checked;"
				>normal &nbsp;&nbsp;<input
				type="checkbox" name="pi_tp_abnormal" <%= getdisablestatus(props,"pi_tp") %>
				onchange="toggleControl(document.forms[0].pi_tp_abnormal,document.forms[0].pi_tp_abnormal_t);" 
				onClick="pi_tp_normal.checked=!pi_tp_abnormal.checked;"
				<%=props.getProperty("pi_tp_abnormal", "")%>
				
							>abnormal &nbsp;<input
				type="text" maxlength="80" size="40" <%= getdisablestatus(props,"pi_tp_abnormal") %> name="pi_tp_abnormal_t" value="<%=props.getProperty("pi_tp_abnormal_t", "")%>">
			<br>
			<input type="checkbox" name="pi_laparoscopy" onchange="toggleControl(document.forms[0].pi_laparoscopy,document.forms[0].pi_laparoscopy_t)
;toggleControl(document.forms[0].pi_laparoscopy,document.forms[0].pi_lps_normal)
;toggleControl(document.forms[0].pi_laparoscopy,document.forms[0].pi_lps_abnormal)
;;toggleControl(document.forms[0].pi_lps_abnormal,document.forms[0].pi_lps_abnormal_t)"
				<%=props.getProperty("pi_laparoscopy", "")%>>Laparoscopy:&nbsp;&nbsp;
				<input
				name="pi_laparoscopy_t" type="text" maxlength="40" <%= getdisablestatus(props,"pi_laparoscopy") %>
				value="<%=props.getProperty("pi_laparoscopy_t", "")%>">
			&nbsp;&nbsp;
			<input type="checkbox" name="pi_lps_normal" <%= getdisablestatus(props,"pi_laparoscopy") %>
				<%=props.getProperty("pi_lps_normal", "")%>
				onchange="toggleControl(document.forms[0].pi_lps_abnormal,document.forms[0].pi_lps_abnormal_t)"
				onClick="pi_lps_abnormal.checked=!pi_lps_normal.checked;"
				>normal &nbsp;&nbsp;<input
				type="checkbox" name="pi_lps_abnormal" <%= getdisablestatus(props,"pi_laparoscopy") %> 
				onchange="toggleControl(document.forms[0].pi_lps_abnormal,document.forms[0].pi_lps_abnormal_t);" 
				onClick="pi_lps_normal.checked=!pi_lps_abnormal.checked;"
				<%=props.getProperty("pi_lps_abnormal", "")%>
				>abnormal &nbsp;<input
				type="text" maxlength="80" size="40" <%= getdisablestatus(props,"pi_lps_abnormal") %>  name="pi_lps_abnormal_t" value="<%=props.getProperty("pi_lps_abnormal_t", "")%>">
			<br>
			<input type="checkbox" name="pi_lp" onchange="toggleControl(document.forms[0].pi_lp,document.forms[0].pi_lp_t)
;toggleControl(document.forms[0].pi_lp,document.forms[0].pi_lp_normal)
;toggleControl(document.forms[0].pi_lp,document.forms[0].pi_lp_abnormal)
;;toggleControl(document.forms[0].pi_lp_abnormal,document.forms[0].pi_lp_abnormal_t)"
				<%=props.getProperty("pi_lp", "")%>>Luteal
			Progesterone:&nbsp;&nbsp;<input name="pi_lp_t" type="text" maxlength="40" <%= getdisablestatus(props,"pi_lp") %>
				value="<%=props.getProperty("pi_lp_t", "")%>"> &nbsp;&nbsp;<input
				type="checkbox" name="pi_lp_normal" <%= getdisablestatus(props,"pi_lp") %>
				<%=props.getProperty("pi_lp_normal", "")%>
				onchange="toggleControl(document.forms[0].pi_lp_abnormal,document.forms[0].pi_lp_abnormal_t)"
				onClick="pi_lp_abnormal.checked=!pi_lp_normal.checked;">normal &nbsp;&nbsp;<input
				type="checkbox" name="pi_lp_abnormal" <%= getdisablestatus(props,"pi_lp") %> 
				onchange="toggleControl(document.forms[0].pi_lp_abnormal,document.forms[0].pi_lp_abnormal_t);" 
				onClick="pi_lp_normal.checked=!pi_lp_abnormal.checked;"
				<%=props.getProperty("pi_lp_abnormal", "")%> >abnormal &nbsp;<input
				type="text" maxlength="80" size="40" <%= getdisablestatus(props,"pi_lp_abnormal") %> name="pi_lp_abnormal_t" value="<%=props.getProperty("pi_lp_abnormal_t", "")%>">
			<br>
			<input type="checkbox" name="pi_ha" onchange="toggleControl(document.forms[0].pi_ha,document.forms[0].pi_ha_t)
;toggleControl(document.forms[0].pi_ha,document.forms[0].pi_ha_normal)
;toggleControl(document.forms[0].pi_ha,document.forms[0].pi_ha_abnormal)
;;toggleControl(document.forms[0].pi_ha_abnormal,document.forms[0].pi_ha_abnormal_t)"
				<%=props.getProperty("pi_ha", "")%>>Hormonal
			assessment:&nbsp;&nbsp;<input name="pi_ha_t" type="text" maxlength="40" <%= getdisablestatus(props,"pi_ha") %>
				value="<%=props.getProperty("pi_ha_t", "")%>"> &nbsp;&nbsp;<input
				type="checkbox" name="pi_ha_normal" d <%= getdisablestatus(props,"pi_ha") %>
				<%=props.getProperty("pi_ha_normal", "")%>
				onchange="toggleControl(document.forms[0].pi_ha_abnormal,document.forms[0].pi_ha_abnormal_t)"
				onClick="pi_ha_abnormal.checked=!pi_ha_normal.checked;" >normal &nbsp;&nbsp;<input
				type="checkbox" name="pi_ha_abnormal"  <%= getdisablestatus(props,"pi_ha") %> 
				onchange="toggleControl(document.forms[0].pi_ha_abnormal,document.forms[0].pi_ha_abnormal_t);" 
				onClick="pi_ha_normal.checked=!pi_ha_abnormal.checked;"
				<%=props.getProperty("pi_ha_abnormal", "")%>
				 >abnormal &nbsp;<input
				type="text" maxlength="80" size="40" name="pi_ha_abnormal_t"  <%= getdisablestatus(props,"pi_ha_abnormal") %> 
				value="<%=props.getProperty("pi_ha_abnormal_t", "")%>"> <br>
			<input type="checkbox" name="pi_pa" onchange="toggleControl(document.forms[0].pi_pa,document.forms[0].pi_pa_t)
;toggleControl(document.forms[0].pi_pa,document.forms[0].pi_pa_normal)
;toggleControl(document.forms[0].pi_pa,document.forms[0].pi_pa_abnormal)
;;toggleControl(document.forms[0].pi_pa_abnormal,document.forms[0].pi_pa_abnormal_t)"
				<%=props.getProperty("pi_pa", "")%>>Pelvic
			Ultrasound:&nbsp;&nbsp;<input name="pi_pa_t" type="text" maxlength="40" <%= getdisablestatus(props,"pi_pa") %>
				value="<%=props.getProperty("pi_pa_t", "")%>"> &nbsp;&nbsp;<input
				type="checkbox" name="pi_pa_normal" <%= getdisablestatus(props,"pi_pa") %>
				<%=props.getProperty("pi_pa_normal", "")%>
				onchange="toggleControl(document.forms[0].pi_pa_abnormal,document.forms[0].pi_pa_abnormal_t)"
				onClick="pi_pa_abnormal.checked=!pi_pa_normal.checked;">normal &nbsp;&nbsp;<input
				type="checkbox" name="pi_pa_abnormal" <%= getdisablestatus(props,"pi_pa") %> 
				onchange="toggleControl(document.forms[0].pi_pa_abnormal,document.forms[0].pi_pa_abnormal_t);" 
				onClick="pi_pa_normal.checked=!pi_pa_abnormal.checked;"
				<%=props.getProperty("pi_pa_abnormal", "")%>
				>abnormal &nbsp;<input
				type="text" maxlength="80" size="40" <%= getdisablestatus(props,"pi_pa_abnormal") %>  name="pi_pa_abnormal_t" value="<%=props.getProperty("pi_pa_abnormal_t", "")%>">
			<br>
			<input type="checkbox" name="pi_sa" onchange="toggleControl(document.forms[0].pi_sa,document.forms[0].pi_sa_t)
;toggleControl(document.forms[0].pi_sa,document.forms[0].pi_sa_normal)
;toggleControl(document.forms[0].pi_sa,document.forms[0].pi_sa_abnormal)
;;toggleControl(document.forms[0].pi_sa_abnormal,document.forms[0].pi_sa_abnormal_t)"
				<%=props.getProperty("pi_sa", "")%>>Semen
			Analysis:&nbsp;&nbsp;<input name="pi_sa_t" type="text" maxlength="40" <%= getdisablestatus(props,"pi_sa") %>
				value="<%=props.getProperty("pi_sa_t", "")%>"> &nbsp;&nbsp;<input
				type="checkbox" name="pi_sa_normal" <%= getdisablestatus(props,"pi_sa") %>
				<%=props.getProperty("pi_sa_normal", "")%>
				onchange="toggleControl(document.forms[0].pi_sa_abnormal,document.forms[0].pi_sa_abnormal_t)"
				onClick="pi_sa_abnormal.checked=!pi_sa_normal.checked;" >normal &nbsp;&nbsp;<input
				type="checkbox" name="pi_sa_abnormal" <%= getdisablestatus(props,"pi_sa") %> 
				onchange="toggleControl(document.forms[0].pi_sa_abnormal,document.forms[0].pi_sa_abnormal_t);" 
				onClick="pi_sa_normal.checked=!pi_sa_abnormal.checked;"
				<%=props.getProperty("pi_sa_abnormal", "")%>
				>abnormal &nbsp;<input
				type="text" maxlength="80" size="40" <%= getdisablestatus(props,"pi_sa_abnormal") %> name="pi_sa_abnormal_t" value="<%=props.getProperty("pi_sa_abnormal_t", "")%>">
			<br>
			</td>
		</tr>
		<tr>
			<td>Other:<br>
			<textarea name="pi_other" cols="1" rows="4" style="width: 750px;"><%=props.getProperty("pi_other", "")%></textarea>
			</td>
		</tr>

		<tr>
			<td>&nbsp;</td>
		</tr>

		<tr>
			<td height="10px"><u><font size="4"><b>Previous
			Treatments:</b></font></u></td>
		</tr>
		<tr>
			<td><input type="checkbox" name="pt_oi" onchange="toggleControl(document.forms[0].pt_oi,document.forms[0].pt_oi_t)"
				<%=props.getProperty("pt_oi", "")%>>Ovulation
			Induction&nbsp;&nbsp;<input name="pt_oi_t" type="text" maxlength="60" size="60" <%= getdisablestatus(props,"pt_oi") %>
				value="<%=props.getProperty("pt_oi_t", "")%>"><br>
			<input type="checkbox" name="pt_saii" onchange="toggleControl(document.forms[0].pt_saii,document.forms[0].pt_saii_t)"
				<%=props.getProperty("pt_saii", "")%>>Superovulation and
			intrauterine insemination:&nbsp;&nbsp;<input name="pt_saii_t" <%= getdisablestatus(props,"pt_saii") %>
				type="text" maxlength="60" size="60" value="<%=props.getProperty("pt_saii_t", "")%>"><br>
			<input type="checkbox" name="pt_ivf" onchange="toggleControl(document.forms[0].pt_ivf,document.forms[0].pt_ivf_t)"
				<%=props.getProperty("pt_ivf", "")%>>IVF:&nbsp;&nbsp;<input
				name="pt_ivf_t" type="text" maxlength="60" size="60" <%= getdisablestatus(props,"pt_ivf") %>
				value="<%=props.getProperty("pt_ivf_t", "")%>"><br>
			<input type="checkbox" name="pt_ivf_icsi" onchange="toggleControl(document.forms[0].pt_ivf_icsi,document.forms[0].pt_ivf_icsi_t)"
				<%=props.getProperty("pt_ivf_icsi", "")%>>IVF with
			ICSI:&nbsp;&nbsp;<input name="pt_ivf_icsi_t" type="text" maxlength="60" size="60" <%= getdisablestatus(props,"pt_ivf_icsi") %>
				value="<%=props.getProperty("pt_ivf_icsi_t", "")%>"><br>
			</td>
		</tr>
		<tr>
			<td>Other:<br>
			<textarea name="pt_other" cols="1" rows="4" style="width: 750px;"><%=props.getProperty("pt_other", "")%></textarea>
			</td>
		</tr>

		<tr>
			<td>&nbsp;</td>
		</tr>

		<tr>
			<td height="10px"><u><font size="4"><b>Obstetrical
			History:</b></font></u><br>
			&nbsp;</td>
		</tr>
		<tr>
			<td>
			<table border="1" bgcolor="white" style="width: 7.5in;">
				<tr>
					<!--  <td width="25px">Year</td>
					<td width="100px">Pregnancy Outcome</td>
					<td width="40px">Weeks</td>
					<td width="550px">Treatment</td>
					<td width="150px">Time to conception (Weeks)</td>
					<td width="550px">Notes</td> -->
					<td>Year</td>
					<td>Pregnancy Outcome</td>
					<td>Weeks</td>
					<td>Treatment</td>
					<td>TTC(mths)</td>
					<td>Notes</td>
				</tr>
				<tr>
					<td><input size="4" type="text" maxlength="15" name="oh_year1"
						value="<%=props.getProperty("oh_year1", "")%>" /></td>
					<td><select name="oh_po1"
						value="<%=props.getProperty("oh_po1", "")%>">
						<option value="">
						<option value="SA">SA
						<option value="EP">EP
						<option value="SVD">SVD
						<option value="CS">CS
						<option value="TA">TA
						<option value="Other">Other
					</select></td>
					<td><input type="text" maxlength="15" size="4" name="oh_weeks1"
						value="<%=props.getProperty("oh_weeks1", "")%>" /></td>
					<td><!-- <input type="text" maxlength="15" size="40" name="oh_treatment1"
						value="<%=props.getProperty("oh_treatment1", "")%>" /> -->
						<textarea name="oh_treatment1" cols="1" rows="2" style="width: 250px;"><%=props.getProperty("oh_treatment1", "")%></textarea>
						</td>
					<td><input type="text" maxlength="2" size="2" name="oh_toc1"
						value="<%=props.getProperty("oh_toc1", "")%>" /></td>
					<td><textarea name="oh_notes1" cols="1" rows="2" style="width: 250px;"><%=props.getProperty("oh_notes1", "")%></textarea></td>
				</tr>
				<tr>
					<td><input size="4" type="text" maxlength="15" name="oh_year2"
						value="<%=props.getProperty("oh_year2", "")%>" /></td>
					<td><select name="oh_po2"
						value="<%=props.getProperty("oh_po2", "")%>">
						<option value="">
						<option value="SA">SA
						<option value="EP">EP
						<option value="SVD">SVD
						<option value="CS">CS
						<option value="TA">TA
						<option value="Other">Other
					</select></td>
					<td><input type="text" maxlength="15" size="4" name="oh_weeks2"
						value="<%=props.getProperty("oh_weeks2", "")%>" /></td>
					<td><textarea name="oh_treatment2" cols="1" rows="2" style="width: 250px;"><%=props.getProperty("oh_treatment2", "")%></textarea></td>
					<td><input type="text" maxlength="2" size="2" name="oh_toc2"
						value="<%=props.getProperty("oh_toc2", "")%>" /></td>
					<td><textarea name="oh_notes2" cols="1" rows="2" style="width: 250px;"><%=props.getProperty("oh_notes2", "")%></textarea></td>
				</tr>
				<tr>
					<td><input size="4" type="text" maxlength="15" name="oh_year3"
						value="<%=props.getProperty("oh_year3", "")%>" /></td>
					<td><select name="oh_po3"
						value="<%=props.getProperty("oh_po3", "")%>">
						<option value="">
						<option value="SA">SA
						<option value="EP">EP
						<option value="SVD">SVD
						<option value="CS">CS
						<option value="TA">TA
						<option value="Other">Other
					</select></td>
					<td><input type="text" maxlength="15" size="4" name="oh_weeks3"
						value="<%=props.getProperty("oh_weeks3", "")%>" /></td>
					<td><textarea name="oh_treatment3" cols="1" rows="2" style="width: 250px;"><%=props.getProperty("oh_treatment3", "")%></textarea></td>
					<td><input type="text" maxlength="2" size="2" name="oh_toc3"
						value="<%=props.getProperty("oh_toc3", "")%>" /></td>
					<td><textarea name="oh_notes3" cols="1" rows="2" style="width: 250px;"><%=props.getProperty("oh_notes3", "")%></textarea></td>
				</tr>
				<tr>
					<td><input size="4" type="text" maxlength="15" name="oh_year4"
						value="<%=props.getProperty("oh_year4", "")%>" /></td>
					<td><select name="oh_po4"
						value="<%=props.getProperty("oh_po4", "")%>">
						<option value="">
						<option value="SA">SA
						<option value="EP">EP
						<option value="SVD">SVD
						<option value="CS">CS
						<option value="TA">TA
						<option value="Other">Other
					</select></td>
					<td><input type="text" maxlength="15" size="4" name="oh_weeks4"
						value="<%=props.getProperty("oh_weeks4", "")%>" /></td>
					<td><textarea name="oh_treatment4" cols="1" rows="2" style="width: 250px;"><%=props.getProperty("oh_treatment4", "")%></textarea></td>
					<td><input type="text" maxlength="2" size="2" name="oh_toc4"
						value="<%=props.getProperty("oh_toc4", "")%>" /></td>
					<td><textarea name="oh_notes4" cols="1" rows="2" style="width: 250px;"><%=props.getProperty("oh_notes4", "")%></textarea></td>
				</tr>
				<tr>
					<td><input size="4" type="text" maxlength="15" name="oh_year5"
						value="<%=props.getProperty("oh_year5", "")%>" /></td>
					<td><select name="oh_po5"
						value="<%=props.getProperty("oh_po5", "")%>">
						<option value="">
						<option value="SA">SA
						<option value="EP">EP
						<option value="SVD">SVD
						<option value="CS">CS
						<option value="TA">TA
						<option value="Other">Other
					</select></td>
					<td><input type="text" maxlength="15" size="4" name="oh_weeks5"
						value="<%=props.getProperty("oh_weeks5", "")%>" /></td>
					<td><textarea name="oh_treatment5" cols="1" rows="2" style="width: 250px;"><%=props.getProperty("oh_treatment5", "")%></textarea></td>
					<td><input type="text" maxlength="2" size="2" name="oh_toc5"
						value="<%=props.getProperty("oh_toc5", "")%>" /></td>
					<td><textarea name="oh_notes5" cols="1" rows="2" style="width: 250px;"><%=props.getProperty("oh_notes5", "")%></textarea></td>
				</tr>
				<tr>
					<td><input size="4" type="text" maxlength="15" name="oh_year6"
						value="<%=props.getProperty("oh_year6", "")%>" /></td>
					<td><select name="oh_po6"
						value="<%=props.getProperty("oh_po6", "")%>">
						<option value="">
						<option value="SA">SA
						<option value="EP">EP
						<option value="SVD">SVD
						<option value="CS">CS
						<option value="TA">TA
						<option value="Other">Other
					</select></td>
					<td><input type="text" maxlength="15" size="4" name="oh_weeks6"
						value="<%=props.getProperty("oh_weeks6", "")%>" /></td>
					<td><textarea name="oh_treatment6" cols="1" rows="2" style="width: 250px;"><%=props.getProperty("oh_treatment6", "")%></textarea></td>
					<td><input type="text" maxlength="2" size="2" name="oh_toc6"
						value="<%=props.getProperty("oh_toc6", "")%>" /></td>
					<td><textarea name="oh_notes6" cols="1" rows="2" style="width: 250px;"><%=props.getProperty("oh_notes6", "")%></textarea></td>
				</tr>
				<tr>
					<td><input size="4" type="text" maxlength="15" name="oh_year7"
						value="<%=props.getProperty("oh_year7", "")%>" /></td>
					<td><select name="oh_po7"
						value="<%=props.getProperty("oh_po7", "")%>">
						<option value="">
						<option value="SA">SA
						<option value="EP">EP
						<option value="SVD">SVD
						<option value="CS">CS
						<option value="TA">TA
						<option value="Other">Other
					</select></td>
					<td><input type="text" maxlength="15" size="4" name="oh_weeks7"
						value="<%=props.getProperty("oh_weeks7", "")%>" /></td>
					<td><textarea name="oh_treatment7" cols="1" rows="2" style="width: 250px;"><%=props.getProperty("oh_treatment7", "")%></textarea></td>
					<td><input type="text" maxlength="2" size="2" name="oh_toc7"
						value="<%=props.getProperty("oh_toc7", "")%>" /></td>
					<td><textarea name="oh_notes7" cols="1" rows="2" style="width: 250px;"><%=props.getProperty("oh_notes7", "")%></textarea></td>
				</tr>
				<tr>
					<td><input size="4" type="text" maxlength="15" name="oh_year8"
						value="<%=props.getProperty("oh_year8", "")%>" /></td>
					<td><select name="oh_po8"
						value="<%=props.getProperty("oh_po8", "")%>">
						<option value="">
						<option value="SA">SA
						<option value="EP">EP
						<option value="SVD">SVD
						<option value="CS">CS
						<option value="TA">TA
						<option value="Other">Other
					</select></td>
					<td><input type="text" maxlength="15" size="4" name="oh_weeks8"
						value="<%=props.getProperty("oh_weeks8", "")%>" /></td>
					<td><textarea name="oh_treatment8" cols="1" rows="2" style="width: 250px;"><%=props.getProperty("oh_treatment8", "")%></textarea></td>
					<td><input type="text" maxlength="2" size="2" name="oh_toc8"
						value="<%=props.getProperty("oh_toc8", "")%>" /></td>
					<td><textarea name="oh_notes8" cols="1" rows="2" style="width: 250px;"><%=props.getProperty("oh_notes8", "")%></textarea></td>
				</tr>
				<tr>
					<td><input size="4" type="text" maxlength="15" name="oh_year9"
						value="<%=props.getProperty("oh_year9", "")%>" /></td>
					<td><select name="oh_po9"
						value="<%=props.getProperty("oh_po9", "")%>">
						<option value="">
						<option value="SA">SA
						<option value="EP">EP
						<option value="SVD">SVD
						<option value="CS">CS
						<option value="TA">TA
						<option value="Other">Other
					</select></td>
					<td><input type="text" maxlength="15" size="4" name="oh_weeks9"
						value="<%=props.getProperty("oh_weeks9", "")%>" /></td>
					<td><textarea name="oh_treatment9" cols="1" rows="2" style="width: 250px;"><%=props.getProperty("oh_treatment9", "")%></textarea></td>
					<td><input type="text" maxlength="2" size="2" name="oh_toc9"
						value="<%=props.getProperty("oh_toc9", "")%>" /></td>
					<td><textarea name="oh_notes9" cols="1" rows="2" style="width: 250px;"><%=props.getProperty("oh_notes9", "")%></textarea></td>
				</tr>
				<tr>
					<td><input size="4" type="text" maxlength="15" name="oh_year10"
						value="<%=props.getProperty("oh_year10", "")%>" /></td>
					<td><select name="oh_po10"
						value="<%=props.getProperty("oh_po10", "")%>">
						<option value="">
						<option value="SA">SA
						<option value="EP">EP
						<option value="SVD">SVD
						<option value="CS">CS
						<option value="TA">TA
						<option value="Other">Other
					</select></td>
					<td><input type="text" maxlength="15" size="4" name="oh_weeks10"
						value="<%=props.getProperty("oh_weeks10", "")%>" /></td>
					<td><textarea name="oh_treatment10" cols="1" rows="2" style="width: 250px;"><%=props.getProperty("oh_treatment10", "")%></textarea></td>
					<td><input type="text" maxlength="2" size="2" name="oh_toc10"
						value="<%=props.getProperty("oh_toc10", "")%>" /></td>
					<td><textarea name="oh_notes10" cols="1" rows="2" style="width: 250px;"><%=props.getProperty("oh_notes10", "")%></textarea>
						</td>
						 <script language="javascript">
						if(document.forms[0].oh_po1 != null) {
							document.forms[0].oh_po1.value = '<%=props.getProperty("oh_po1", "")%>';
						}
						if(document.forms[0].oh_po2 != null) {
							document.forms[0].oh_po2.value = '<%=props.getProperty("oh_po2", "")%>';
						}
						if(document.forms[0].oh_po3 != null) {
							document.forms[0].oh_po3.value = '<%=props.getProperty("oh_po3", "")%>';
						}
						if(document.forms[0].oh_po4 != null) {
							document.forms[0].oh_po4.value = '<%=props.getProperty("oh_po4", "")%>';
						}
						if(document.forms[0].oh_po5 != null) {
							document.forms[0].oh_po5.value = '<%=props.getProperty("oh_po5", "")%>';
						}
						if(document.forms[0].oh_po6 != null) {
							document.forms[0].oh_po6.value = '<%=props.getProperty("oh_po6", "")%>';
						}
						if(document.forms[0].oh_po7 != null) {
							document.forms[0].oh_po7.value = '<%=props.getProperty("oh_po7", "")%>';
						}
						if(document.forms[0].oh_po8 != null) {
							document.forms[0].oh_po8.value = '<%=props.getProperty("oh_po8", "")%>';
						}
						if(document.forms[0].oh_po9 != null) {
							document.forms[0].oh_po9.value = '<%=props.getProperty("oh_po9", "")%>';
						}
						if(document.forms[0].oh_po10 != null) {
							document.forms[0].oh_po10.value = '<%=props.getProperty("oh_po10", "")%>';
						}
						
					</script>
				</tr>
			</table>
			</td>
		</tr>

		<tr>
			<td>&nbsp;</td>
		</tr>

		<tr>
			<td height="10px"><u><font size="4"><b>Medical
			and Surgical History:</b></font></u>&nbsp;&nbsp;<input type="button"
				value="Medical History"
				onclick="importFromEnct('Medical',document.forms[0].mash_t);"><br>
			&nbsp;</td>
		</tr>
		<tr>
			<td><textarea name="mash_t" cols="1" rows="4"
				style="width: 750px;"><%=props.getProperty("mash_t", "").trim()%></textarea>
			</td>
		</tr>

		<tr>
			<td>&nbsp;</td>
		</tr>

		<tr>
			<td height="10px"><u><font size="4"><b>Prescriptions
			and Medications:</b></font></u> &nbsp;&nbsp;<input type="button"
				value="Prescriptions"
				onclick="importFromEnct('Medication',document.forms[0].pam_t);">
			&nbsp;&nbsp;<input type="button" value="Medication"
				onclick="importFromEnct('OtherMeds',document.forms[0].pam_t);"><br>
			&nbsp;</td>
		</tr>
		<tr>
			<td><textarea name="pam_t" cols="1" rows="4"
				style="width: 750px;"><%=props.getProperty("pam_t", "").trim()%></textarea>
			</td>
		</tr>

		<tr>
			<td>&nbsp;</td>
		</tr>

		<tr>
			<td height="10px"><u><font size="4"><b>Allergies:</b></font></u>
			&nbsp;&nbsp;<input type="button" value="Allergies"
				onclick="importFromEnct('Allergies',document.forms[0].allergies_t);"><br>
			&nbsp;</td>
		</tr>
		<tr>
			<td><textarea name="allergies_t" cols="1" rows="4"
				style="width: 750px;"><%=props.getProperty("allergies_t", "").trim()%></textarea>
			</td>
		</tr>

		<tr>
			<td>&nbsp;</td>
		</tr>

		<tr>
			<td height="10px"><u><font size="4"><b>Family
			History:</b></font></u> &nbsp;&nbsp;<input type="button" value="Family History"
				onclick="importFromEnct('Family',document.forms[0].fh_t);"><br>
			&nbsp;</td>
		</tr>
		<tr>
			<td><textarea name="fh_t" cols="1" rows="4"
				style="width: 750px;"><%=props.getProperty("fh_t", "")%></textarea>
			</td>
		</tr>

		<tr>
			<td>&nbsp;</td>
		</tr>

		<tr>
			<td height="10px"><u><font size="4"><b>Social
			History:</b></font></u> &nbsp;&nbsp;<input type="button" value="Social History"
				onclick="importFromEnct('Social',document.forms[0].sh_other);">
			&nbsp;</td>
		</tr>
		<tr>
			<td><input type="checkbox" name="sh_occupation" onchange="toggleControl(document.forms[0].sh_occupation,document.forms[0].sh_occupation_t)"
				<%=props.getProperty("sh_occupation", "")%>>Occupation&nbsp;&nbsp;
			<input name="sh_occupation_t" type="text" maxlength="80" size="80" <%= getdisablestatus(props,"sh_occupation") %>
				value="<%=props.getProperty("sh_occupation_t", "")%>"><br>
			
			<input type="checkbox" name="sh_smoker" onclick="if(this.checked){document.forms[0].sh_non_smoker.checked = false;}" 
			onchange="toggleControl(document.forms[0].sh_smoker,document.forms[0].sh_smoker_t)"
				<%=props.getProperty("sh_smoker", "")%>>Smoker&nbsp;&nbsp; <input
				name="sh_smoker_t" type="text" maxlength="15" <%= getdisablestatus(props,"sh_smoker") %>
				value="<%=props.getProperty("sh_smoker_t", "")%>">
			<input type="checkbox" name="sh_non_smoker" onclick="if(this.checked){document.forms[0].sh_smoker.checked = false; toggleControl(document.forms[0].sh_smoker,document.forms[0].sh_smoker_t);}" 
				<%=props.getProperty("sh_non_smoker", "")%>>Non-smoker&nbsp;&nbsp;	
			<br>
			
			<input type="checkbox" name="sh_alcohol" onchange="toggleControl(document.forms[0].sh_alcohol,document.forms[0].sh_alcohol_t)"
				<%=props.getProperty("sh_alcohol", "")%>>
			Alcohol&nbsp;&nbsp;<input name="sh_alcohol_t" type="text" maxlength="15" <%= getdisablestatus(props,"sh_alcohol") %>
				value="<%=props.getProperty("sh_alcohol_t", "")%>"><br>
			<input type="checkbox" name="sh_drugs" onchange="toggleControl(document.forms[0].sh_drugs,document.forms[0].sh_drugs_t)"
				<%=props.getProperty("sh_drugs", "")%>>Drugs&nbsp;&nbsp;<input
				name="sh_drugs_t" type="text" maxlength="15" <%= getdisablestatus(props,"sh_drugs") %>
				value="<%=props.getProperty("sh_drugs_t", "")%>"><br>
			</td>
		</tr>
		<tr>
			<td><br>
			Other:<br>
			<textarea name="sh_other" cols="1" rows="4" style="width: 750px;"><%=props.getProperty("sh_other", "")%></textarea>
			</td>
		</tr>

		<tr>
			<td>&nbsp;</td>
		</tr>
				<tr>
			<td height="10px"><u><font size="4"><b>Male / Partner Factors:</b></font></u></td>
		</tr>
		<tr>
			<td>
			<input type="checkbox" name="rfhmf_maleocc" onchange="toggleControl(document.forms[0].rfhmf_maleocc,document.forms[0].rfhmf_maleocc_t)" 
				<%=props.getProperty("rfhmf_maleocc", "")%>>Occupation&nbsp;&nbsp;<input
				name="rfhmf_maleocc_t" type="text" maxlength="80" size="80" <%= getdisablestatus(props,"rfhmf_maleocc_t") %>
				value="<%=props.getProperty("rfhmf_maleocc_t", "")%>"><br>
			<input type="checkbox" name="rfhmf_fp" onchange="toggleControl(document.forms[0].rfhmf_fp,document.forms[0].rfhmf_fp_t)" 
				<%=props.getProperty("rfhmf_fp", "")%>>fathered&nbsp;&nbsp;<input
				name="rfhmf_fp_t" type="text" maxlength="15" size="2" <%= getdisablestatus(props,"rfhmf_fp") %>
				value="<%=props.getProperty("rfhmf_fp_t", "")%>">&nbsp;&nbsp;pregnancy / pregnancies<br>
			<input type="checkbox" name="rfhmf_nsa"
				<%=props.getProperty("rfhmf_nsa", "")%>>normal semen
			analysis<br>
			<input type="checkbox" name="rfhmf_asa" onchange="toggleControl(document.forms[0].rfhmf_asa,document.forms[0].rfhmf_asa_t)"
				<%=props.getProperty("rfhmf_asa", "")%>>abnormal semen
			analysis&nbsp;&nbsp;<input name="rfhmf_asa_t" type="text" maxlength="40" size="40" <%= getdisablestatus(props,"rfhmf_asa") %>
				value="<%=props.getProperty("rfhmf_asa_t", "")%>"><br>
			<input type="checkbox" name="rfhmf_azoospermia"
				<%=props.getProperty("rfhmf_azoospermia", "")%>>azoospermia<br>
			<input type="checkbox" name="rfhmf_hov" onchange="toggleControl(document.forms[0].rfhmf_hov,document.forms[0].rfhmf_hov_t)"
				<%=props.getProperty("rfhmf_hov", "")%>>history of
			vasectomy&nbsp;&nbsp;<input name="rfhmf_hov_t" type="text" maxlength="15" <%= getdisablestatus(props,"rfhmf_hov") %>
				value="<%=props.getProperty("rfhmf_hov_t", "")%>"><br>
			<input type="checkbox" name="rfhmf_hovr" onchange="toggleControl(document.forms[0].rfhmf_hovr,document.forms[0].rfhmf_hovr_t)"
				<%=props.getProperty("rfhmf_hovr", "")%>>history of
			vasectomy reversal&nbsp;&nbsp;<input name="rfhmf_hovr_t" type="text" maxlength="15" <%= getdisablestatus(props,"rfhmf_hovr") %>
				value="<%=props.getProperty("rfhmf_hovr_t", "")%>"><br>
			<input type="checkbox" name="rfhmf_hout" onchange="toggleControl(document.forms[0].rfhmf_hout,document.forms[0].rfhmf_hout_t)"
				<%=props.getProperty("rfhmf_hout", "")%>>history of
			undescended&nbsp;&nbsp;<input name="rfhmf_hout_t" type="text" maxlength="15" <%= getdisablestatus(props,"rfhmf_hout_t") %>
				value="<%=props.getProperty("rfhmf_hout_t", "")%>">&nbsp;&nbsp;testicle<br>
			<input type="checkbox" name="rfhmf_oat" onchange="toggleControl(document.forms[0].rfhmf_oat,document.forms[0].rfhmf_oat_t)"
				<%=props.getProperty("rfhmf_oat", "")%>>orchipexy
			at&nbsp;&nbsp;<input name="rfhmf_oat_t" type="text" maxlength="15" <%= getdisablestatus(props,"rfhmf_oat") %>
				value="<%=props.getProperty("rfhmf_oat_t", "")%>"><br>
			<input type="checkbox" name="rfhmf_hoo"
				<%=props.getProperty("rfhmf_hoo", "")%>>history of orchitis<br>
			<input type="checkbox" name="rfhmf_ge" onchange="toggleControl(document.forms[0].rfhmf_ge,document.forms[0].rfhmf_ge_t)"
				<%=props.getProperty("rfhmf_ge", "")%>>gonadotoxic
			exposure&nbsp;&nbsp;<input name="rfhmf_ge_t" type="text" maxlength="40" size="40" <%= getdisablestatus(props,"rfhmf_ge") %>
				value="<%=props.getProperty("rfhmf_ge_t", "")%>"></td>
		</tr>

		<tr>
			<td> 	
			<div style="margin-left: 30px;">
			
			<div class="field_row_div">
			<input type="checkbox"
				name="rfhmf_ge_alcohol" <%=props.getProperty("rfhmf_ge_alcohol", "")%>
				onchange="toggleControl(document.forms[0].rfhmf_ge_alcohol,document.forms[0].rfhmf_ge_alcohol_t)"
				>Alcoholic drinks per week 
				&nbsp;&nbsp;<input name="rfhmf_ge_alcohol_t" type="text" maxlength="2"  
				<%= getdisablestatus(props,"rfhmf_ge_alcohol") %> style="width: 25px;"
				value="<%=props.getProperty("rfhmf_ge_alcohol_t", "")%>">,
			</div>
			<div class="field_row_div">
				<input type="checkbox"
				onchange="toggleControl(document.forms[0].rfhmf_ge_marijuana,document.forms[0].rfhmf_ge_marijuana_t)"
					name="rfhmf_ge_marijuana" <%=props.getProperty("rfhmf_ge_marijuana", "")%>
					>marijuana &nbsp;&nbsp;<input name="rfhmf_ge_marijuana_t" type="text" maxlength="30"  
				<%= getdisablestatus(props,"rfhmf_ge_marijuana") %> size="30"
				value="<%=props.getProperty("rfhmf_ge_marijuana_t", "")%>">,
			</div>
			<div class="field_row_div">
				<input type="checkbox"
				onchange="toggleControl(document.forms[0].rfhmf_ge_smoker,document.forms[0].rfhmf_ge_smoker_t)"
				name="rfhmf_ge_smoker" <%=props.getProperty("rfhmf_ge_smoker", "")%>
				>smoker &nbsp;&nbsp;<input name="rfhmf_ge_smoker_t" type="text" maxlength="30"  
				<%= getdisablestatus(props,"rfhmf_ge_smoker") %> size="30"
				value="<%=props.getProperty("rfhmf_ge_smoker_t", "")%>">,
			</div>
			
			<div class="field_row_div">
				<input type="checkbox"
				name="rfhmf_ge_smoker_non" <%=props.getProperty("rfhmf_ge_smoker_non", "")%>>non-smoker,
			</div>
			
			<div class="field_row_div">
				<input type="checkbox" name="rfhmf_ge_saunas"
					<%=props.getProperty("rfhmf_ge_saunas", "")%>>hot tubs / saunas,
			</div>
			
			<div class="field_row_div">

				<input type="checkbox" name="rfhmf_ge_saunas_d"
					<%=props.getProperty("rfhmf_ge_saunas_d", "")%>>denies hot tubs / sauna use,
			</div>
			
			<div class="field_row_div">
				<input type="checkbox" name="rfhmf_ge_degreasers"
					<%=props.getProperty("rfhmf_ge_degreasers", "")%>>degreasers or
				solvents
			</div>
		<!-- </td>
		</tr>
		<tr><td> -->
		
		</div>	
		</td>
		</tr>
		<tr>
			<td>&nbsp;</td> 
		</tr>
		<tr>
			<td>Male / Partner Medical History:&nbsp;&nbsp; <input type="button"
				value="Partner"
				onclick="importPartnerData(document.forms[0].rfhmf_mmh,'medhistory');
				importSpouseData(document.forms[0].rfhmf_mmh,'medhistory');
				importHusbandData(document.forms[0].rfhmf_mmh,'medhistory');">
			<!--&nbsp; <input type="button" value="Spouse"
				onclick="importSpouseData(document.forms[0].rfhmf_mmh,'medhistory');">
			&nbsp; <input type="button" value="Husband"
				onclick="importHusbandData(document.forms[0].rfhmf_mmh,'medhistory');">
			&nbsp;--></td>
		</tr>
		<tr>
			<td><textarea name="rfhmf_mmh" cols="1" rows="4"
				style="width: 750px;"><%=props.getProperty("rfhmf_mmh", "")%></textarea>
			</td>
		</tr>
		<tr>
			<td>&nbsp;</td>
		</tr>
		<tr>
			<td height="10px"><font size="4">Male / Partner Prescription: </font>&nbsp;&nbsp;
			<input type="button" value="Partner"
				onclick="importPartnerData(document.forms[0].rfhmf_mm,'medication');
				importSpouseData(document.forms[0].rfhmf_mm,'medication');
				importHusbandData(document.forms[0].rfhmf_mm,'medication');">
			&nbsp;<input type="button" value="Meds"
				onclick="importPartnerData(document.forms[0].rfhmf_mm,'OMeds');
				importSpouseData(document.forms[0].rfhmf_mm,'OMeds');
				importHusbandData(document.forms[0].rfhmf_mm,'OMeds');">
			<!--&nbsp; <input type="button" value="Spouse"
				onclick="importSpouseData(document.forms[0].rfhmf_mm,'medication');">
			&nbsp; <input type="button" value="Husband"
				onclick="importHusbandData(document.forms[0].rfhmf_mm,'medication');">
			&nbsp;--></td>
		</tr>
		<tr>
			<td><textarea name="rfhmf_mm" cols="1" rows="4"
				style="width: 750px;"><%=props.getProperty("rfhmf_mm", "").trim()%></textarea>
			</td>
		</tr>
		<tr>
			<td>&nbsp;</td>
		</tr>
		<tr>
			<td height="10px"><font size="4">Male / Partner Allergies: </font>&nbsp;&nbsp;
			<input type="button" value="Partner"
				onclick="importPartnerData(document.forms[0].rfhmf_ma,'allergies');
				importSpouseData(document.forms[0].rfhmf_ma,'allergies');
				importHusbandData(document.forms[0].rfhmf_ma,'allergies');">
			<!--&nbsp; <input type="button" value="Spouse"
				onclick="importSpouseData(document.forms[0].rfhmf_ma,'allergies');">
			&nbsp; <input type="button" value="Husband"
				onclick="importHusbandData(document.forms[0].rfhmf_ma,'allergies');">
			&nbsp;--></td>
		</tr>
		<tr>
			<td><textarea name="rfhmf_ma" cols="1" rows="4"
				style="width: 750px;"><%=props.getProperty("rfhmf_ma", "").trim()%></textarea>
			</td>
		</tr>
		<tr>
			<td>&nbsp;</td>
		</tr>
		<tr>
			<td height="10px"><font size="4">Male / Partner Family History: </font>&nbsp;&nbsp;
			<input type="button" value="Partner"
				onclick="importPartnerData(document.forms[0].rfhmf_mfh,'familyhistory');
				importSpouseData(document.forms[0].rfhmf_mfh,'familyhistory');
				importHusbandData(document.forms[0].rfhmf_mfh,'familyhistory');">
			<!--&nbsp; <input type="button" value="Spouse"
				onclick="importSpouseData(document.forms[0].rfhmf_mfh,'familyhistory');">
			&nbsp; <input type="button" value="Husband"
				onclick="importHusbandData(document.forms[0].rfhmf_mfh,'familyhistory');">
			&nbsp;--></td>
		</tr>
		<tr>
			<td><textarea name="rfhmf_mfh" cols="1" rows="4"
				style="width: 750px;"><%=props.getProperty("rfhmf_mfh", "").trim()%></textarea>
			</td>
		</tr>
		<tr>
			<td>&nbsp;</td>
		</tr>
		<tr>
			<td>Other:<br>
			<textarea name="rfhmf_other" cols="1" rows="4" style="width: 750px;"><%=props.getProperty("rfhmf_other", "")%></textarea>
			</td>
		</tr>
		<tr>
			<td>&nbsp;</td>
		</tr>
		<tr>
			<td height="10px"><u><font size="4"><b>Physical
			Exam:</b></font></u></td>
		</tr>
		<tr><td>
		<font size="4">Female</font>
		</td></tr>
		<tr>
			<td><input type="checkbox" name="pe_ht" onchange="toggleControl(document.forms[0].pe_ht,document.forms[0].pe_ht_t)
			;toggleControl(document.forms[0].pe_ht,document.forms[0].pe_ht_uom_t)
			;toggleControl(document.forms[0].pe_ht,document.forms[0].pe_inch_t)"
				<%=props.getProperty("pe_ht", "")%>>Ht&nbsp;&nbsp;
				<input name="pe_ht_t" type="text" maxlength="15" <%= getdisablestatus(props,"pe_ht") %> value="<%=props.getProperty("pe_ht_t", "")%>"> 
				&nbsp;<select
				name="pe_ht_uom_t" <%= getdisablestatus(props,"pe_ht") %> value="<%=props.getProperty("pe_ht_uom_t", "")%>"
				onchange="toggleHeight(document.forms[0].pe_ht_uom_t,document.forms[0].pe_inch_t);"   >
				<option value="feet">feet
				<option value="cm">cm
			</select> 
				<input name="pe_inch_t" type="text" maxlength="15" 
				<%= getinchdisablestatus(props) %> 
				value="<%=props.getProperty("pe_inch_t", "")%>" >&nbsp;in
				<br>
			<script language="javascript">
						if(document.forms[0].pe_ht_uom_t != null) {
							document.forms[0].pe_ht_uom_t.value = '<%=props.getProperty("pe_ht_uom_t", "")%>';
						}
					</script>
			<input type="checkbox" name="pe_weight" onchange="toggleControl(document.forms[0].pe_weight,document.forms[0].pe_weight_t)
			;toggleControl(document.forms[0].pe_weight,document.forms[0].pe_weight_uom_t)"
				<%=props.getProperty("pe_weight", "")%>>Wt&nbsp;&nbsp;<input
				name="pe_weight_t" type="text" maxlength="15" <%= getdisablestatus(props,"pe_weight") %>
				value="<%=props.getProperty("pe_weight_t", "")%>"> &nbsp;<select
				name="pe_weight_uom_t"  <%= getdisablestatus(props,"pe_weight") %> value="<%=props.getProperty("pe_weight_uom_t", "")%>">
				<option value="lb">lb
				<option value="kg">kg
			</select> <br>
			<input type="checkbox" name="pe_bmi" onchange="toggleControl(document.forms[0].pe_bmi,document.forms[0].pe_bmi_t)"
				<%=props.getProperty("pe_bmi", "")%>>BMI&nbsp;&nbsp;<input
				name="pe_bmi_t" type="text" maxlength="15"  <%= getdisablestatus(props,"pe_bmi") %>
				value="<%=props.getProperty("pe_bmi_t", "")%>">
			&nbsp;&nbsp;<input type="button" value="Calculate" 
			onclick="calcBMI(document.forms[0].pe_weight_t,document.forms[0].pe_weight_uom_t,document.forms[0].pe_ht_t,document.forms[0].pe_ht_uom_t,document.forms[0].pe_bmi_t,document.forms[0].pe_inch_t);">
			<br>
			<input type="checkbox" name="pe_bp" onchange="toggleControl(document.forms[0].pe_bp,document.forms[0].pe_bp_t)"
				<%=props.getProperty("pe_bp", "")%>>BP&nbsp;&nbsp;<input
				name="pe_bp_t" type="text" maxlength="15" <%= getdisablestatus(props,"pe_bp") %>
				value="<%=props.getProperty("pe_bp_t", "")%>"><br>
			
			<div style="margin-top: 10px; margin-bottom: 0px;">
				<div class="field_row_div">
					<input type="checkbox" name="pe_ngpe"
						<%=props.getProperty("pe_ngpe", "")%>>Normal general physical exam,
				</div>
				<div class="field_row_div">
					<input type="checkbox" name="pe_nthe"
							<%=props.getProperty("pe_nthe", "")%>>Normal thyroid exam,
				</div>
				<div class="field_row_div">
					<input type="checkbox" name="pe_naus"
							<%=props.getProperty("pe_naus", "")%>>Normal ausculation of lungs and heart,
				</div>
				<div class="field_row_div">
					<input type="checkbox" name="pe_nabde"
							<%=props.getProperty("pe_nabde", "")%>>Normal abdomenal exam 
				</div> 
			</div>
			<div>&nbsp;</div>
			<div> <br>
			<input type="checkbox" name="pe_gpef" onchange="toggleControl(document.forms[0].pe_gpef,document.forms[0].pe_gpef_t)"
				<%=props.getProperty("pe_gpef", "")%>>General physical exam
			findings:&nbsp;&nbsp;
			</div> 
			<br>
			<textarea name="pe_gpef_t" cols="1" rows="4" style="width: 750px;"  <%= getdisablestatus(props,"pe_gpef") %> ><%=props.getProperty("pe_gpef_t", "")%></textarea>
			<br><br>

			<input type="checkbox" name="pe_npe"
				<%=props.getProperty("pe_npe", "")%>>Normal pelvic exam<br>
			<input type="checkbox" name="pe_pef" onchange="toggleControl(document.forms[0].pe_pef,document.forms[0].pe_pef_t)"
				<%=props.getProperty("pe_pef", "")%>>Pelvic exam
			findings:&nbsp;&nbsp;
			<br>
			<textarea name="pe_pef_t" cols="1" rows="4" style="width: 750px;"  <%= getdisablestatus(props,"pe_pef") %> ><%=props.getProperty("pe_pef_t", "")%></textarea>
			<br><br>

		<font size="4">Male</font><br>

			-Rt testicle<br>
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-&nbsp;size&nbsp;&nbsp;<input
				name="pe_rt_testicle_size" type="text" maxlength="15"
				value="<%=props.getProperty("pe_rt_testicle_size", "")%>"><br>
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-&nbsp;vas&nbsp;&nbsp;<!--<input
				name="pe_rt_testicle_vas" type="text" maxlength="15"
				value="<%=props.getProperty("pe_rt_testicle_vas", "")%>"><br> -->
				<select name="pe_rt_testicle_vas"  value="<%=props.getProperty("pe_rt_testicle_vas", "")%>">
				<option value="">
				<option value="Yes">Yes
				<option value="No">No
			</select> <br>
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-&nbsp;varicocele grade&nbsp;&nbsp;<!--<input
				name="pe_rt_testicle_varicocele" type="text" maxlength="15"
				value="<%=props.getProperty("pe_rt_testicle_varicocele", "")%>"> --> 
				<select name="pe_rt_testicle_varicocele"  value="<%=props.getProperty("pe_rt_testicle_varicocele", "")%>">
				<option value="">
				<option value="0">0
				<option value="1">1
				<option value="2">2
				<option value="3">3
			</select>
				<br>
			<br>
			-Lt testicle<br>
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-&nbsp;size&nbsp;&nbsp;<input
				name="pe_lt_testicle_size" type="text" maxlength="15"
				value="<%=props.getProperty("pe_lt_testicle_size", "")%>"><br>
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-&nbsp;vas&nbsp;&nbsp;<!--<input
				name="pe_lt_testicle_vas" type="text" maxlength="15"
				value="<%=props.getProperty("pe_lt_testicle_vas", "")%>"><br>-->
				<select name="pe_lt_testicle_vas"  value="<%=props.getProperty("pe_lt_testicle_vas", "")%>">
				<option value="">
				<option value="Yes">Yes
				<option value="No">No
			</select> <br>
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-&nbsp;varicocele grade&nbsp;&nbsp;<!--<input
				name="pe_lt_testicle_varicocele" type="text" maxlength="15"
				value="<%=props.getProperty("pe_lt_testicle_varicocele", "")%>"><br> -->
				<select name="pe_lt_testicle_varicocele"  value="<%=props.getProperty("pe_lt_testicle_varicocele", "")%>">
				<option value="">
				<option value="0">0
				<option value="1">1
				<option value="2">2
				<option value="3">3
			</select>
				<br>
			</td>
			<script language="javascript">
						if(document.forms[0].pe_lt_testicle_vas != null) {
							document.forms[0].pe_lt_testicle_vas.value = '<%=props.getProperty("pe_lt_testicle_vas", "")%>';
						}
						if(document.forms[0].pe_lt_testicle_varicocele != null) {
							document.forms[0].pe_lt_testicle_varicocele.value = '<%=props.getProperty("pe_lt_testicle_varicocele", "")%>';
						}
						if(document.forms[0].pe_rt_testicle_vas != null) {
							document.forms[0].pe_rt_testicle_vas.value = '<%=props.getProperty("pe_rt_testicle_vas", "")%>';
						}
						if(document.forms[0].pe_rt_testicle_varicocele != null) {
							document.forms[0].pe_rt_testicle_varicocele.value = '<%=props.getProperty("pe_rt_testicle_varicocele", "")%>';
						}
						
						
					</script>
		</tr>
		<tr>
			<td><br>
			Other:<br>
			<textarea name="pe_other" cols="1" rows="4" style="width: 750px;"><%=props.getProperty("pe_other", "")%></textarea>
			</td>
		</tr>

		<tr>
			<td>&nbsp;</td>
		</tr>

		<tr>
			<td height="10px"><font size="3"><b>Impression:</b></font></td>
		</tr>
		<tr>
			<td><input type="checkbox" name="impression_piue"
				<%=props.getProperty("impression_piue", "")%>>Primary
			infertility of unknown etiology<br>
			
			<input type="checkbox" name="impression_pi"
				<%=props.getProperty("impression_pi", "")%>>Primary infertility<br>
			
			<input type="checkbox" name="impression_siue"
				<%=props.getProperty("impression_siue", "")%>>Secondary
			infertility of unknown etiology<br>
			
			<input type="checkbox" name="impression_si"
				<%=props.getProperty("impression_si", "")%>>Secondary infertility<br>
			
			<input type="checkbox" name="impression_rplue"
				<%=props.getProperty("impression_rplue", "")%>>Recurrent
			pregnancy loss of unknown etiology<br>
			<input type="checkbox" name="impression_od" onchange="toggleControl(document.forms[0].impression_od,document.forms[0].impression_od_t)"
				<%=props.getProperty("impression_od", "")%>>Ovulatory
			dysfunction&nbsp;&nbsp;<input name="impression_od_t" type="text" maxlength="40" size="40" <%= getdisablestatus(props,"impression_od") %>
				value="<%=props.getProperty("impression_od_t", "")%>"><br>
			<input type="checkbox" name="impression_pcos"
				<%=props.getProperty("impression_pcos", "")%>>PCOS<br>
			<input type="checkbox" name="impression_endo"
				<%=props.getProperty("impression_endo", "")%>>Endometriosis<br>
			<input type="checkbox" name="impression_dor"
				<%=props.getProperty("impression_dor", "")%>>Decreased
			ovarian reserve<br>
			<input type="checkbox" name="impression_ama"
				<%=props.getProperty("impression_ama", "")%>>Advanced
			maternal age<br>
			<input type="checkbox" name="impression_poi"
				<%=props.getProperty("impression_poi", "")%>>Premature
			ovarian insufficiency<br>
			<input type="checkbox" name="impression_tfi"
				<%=props.getProperty("impression_tfi", "")%>>Tubal factor
			infertility<br>
			<input type="checkbox" name="impression_mfi"
				<%=props.getProperty("impression_mfi", "")%>>Male factor
			infertility<br>
			<input type="checkbox" name="impression_cfi"
				<%=props.getProperty("impression_cfi", "")%>>Coital factor
			infertility<br>
			<%-- <input type="checkbox" name="impression_azoospermia"
			 onchange="toggleControl(document.forms[0].impression_azoospermia,document.forms[0].impression_azoospermia_t)"
				<%=props.getProperty("impression_azoospermia", "")%>><select name="impression_azoospermia_t"
				<%= getdisablestatus(props,"impression_azoospermia") %>
				>
					<option value="Obstructive" 
					<%=props.getProperty("impression_azoospermia_t", "").equals("Obstructive")?"selected":"" %>
					>Obstructive</option>
					<option value="Non-Obstructive"
					<%=props.getProperty("impression_azoospermia_t", "").equals("Non-Obstructive")?"selected":"" %>
					>Non-Obstructive</option>
				</select> Azoospermia<br> --%>
			
			<script>
			$(document).ready(function(){
				$(".azoospermia").click(function(){
					//alert($(this).attr("checked"));
					if($(this).attr("checked"))
					{
						var selected_obj = $(this);
						$(".azoospermia").each(function(){
							if($(this).attr("name") != $(selected_obj).attr("name"))
							{
								$(this).removeAttr("checked");
							}
						});
					}
				});	
			});
			
			</script>
			
			<input type="checkbox" name="impression_azoospermia" class="azoospermia"
				<%=props.getProperty("impression_azoospermia", "")%>>Azoospermia
			<input type="checkbox" name="impression_azoospermia_o"  class="azoospermia"  
				<%=props.getProperty("impression_azoospermia_o", "")%>>Obstructive azoospermia
			<input type="checkbox" name="impression_azoospermia_n_o"  class="azoospermia"
				<%=props.getProperty("impression_azoospermia_n_o", "")%>>Non-Obstructive azoospermia
			<br>
			
			<input type="checkbox" name="impression_ha"
				<%=props.getProperty("impression_ha", "")%>>Hypothalamic
			annovulation<br>
			<input type="checkbox" name="impression_sfrdp"
				<%=props.getProperty("impression_sfrdp", "")%>>Single
			female requesting donor sperm<br>
			<input type="checkbox" name="impression_sscrds"
				<%=props.getProperty("impression_sscrds", "")%>>Same sex
			couple requesting donor sperm<br>
			<input type="checkbox" name="impression_fo"

				<%=props.getProperty("impression_fo", "")%>>Female obesity<br>
			<input type="checkbox" name="impression_mo"
				<%=props.getProperty("impression_rfsc", "")%>>Male obesity<br>
			<input type="checkbox" name="impression_rfsc" onchange="toggleControl(document.forms[0].impression_rfsc,document.forms[0].impression_rfsc_t)"
				<%=props.getProperty("impression_rfsc", "")%>>Request for
			sperm cryopreservation&nbsp;&nbsp;<input name="impression_rfsc_t" <%= getdisablestatus(props,"impression_rfsc") %>
				type="text" maxlength="40" size="40" value="<%=props.getProperty("impression_rfsc_t", "")%>"><br>
			<input type="checkbox" name="impression_rfoc" onchange="toggleControl(document.forms[0].impression_rfoc,document.forms[0].impression_rfoc_t)"
				<%=props.getProperty("impression_rfoc", "")%>>Request for
			oocyte cryopreservation&nbsp;&nbsp;<input name="impression_rfoc_t" <%= getdisablestatus(props,"impression_rfoc") %>
				type="text" maxlength="40" size="40" value="<%=props.getProperty("impression_rfoc_t", "")%>">
			</td>
		</tr>
		<tr>
			<td>Other:<br>
			<textarea name="impression_other" cols="1" rows="4"
				style="width: 750px;"><%=props.getProperty("impression_other", "")%></textarea>
			</td>
		</tr>

		<tr>
			<td>&nbsp;</td>
		</tr>

		<tr>
			<td height="10px"><font size="3"><b>Options
			Discussed:</b></font></td>
		</tr>
		<tr>
			<td><input type="checkbox" name="optd_em"
				<%=props.getProperty("optd_em", "")%>>Expectant management<br>
			<input type="checkbox" name="optd_oiv" onchange="toggleControl(document.forms[0].optd_oiv,document.forms[0].optd_oiv_t)"
				<%=props.getProperty("optd_oiv", "")%>>Ovulation induction
			with&nbsp;&nbsp;<input name="optd_oiv_t" type="text" maxlength="40" size="40" <%= getdisablestatus(props,"optd_oiv") %>
				value="<%=props.getProperty("optd_oiv_t", "")%>"><br>
			<input type="checkbox" name="optd_saii"
				<%=props.getProperty("optd_saii", "")%>>Superovulation and
			intrauterine insemination<br>
			<input type="checkbox" name="optd_ivf"
				<%=props.getProperty("optd_ivf", "")%>>IVF<br>
			<input type="checkbox" name="optd_ivficsi"
				<%=props.getProperty("optd_ivficsi", "")%>>IVF with ICSI<br>
			<input type="checkbox" name="optd_ivficsi_tse"
				<%=props.getProperty("optd_ivficsi_tse", "")%>>IVF with
			ICSI and testicular sperm extraction<br>
			<input type="checkbox" name="optd_laparoscopy"
				<%=props.getProperty("optd_laparoscopy", "")%>>Laparoscopy<br>
			<input type="checkbox" name="optd_myomectomy"
				<%=props.getProperty("optd_myomectomy", "")%>>Myomectomy<br>
			<input type="checkbox" name="optd_dsi"
				<%=props.getProperty("optd_dsi", "")%>>Donor sperm
			insemination<br>
			<input type="checkbox" name="optd_det"
				<%=props.getProperty("optd_det", "")%>>Donor egg therapy<br>
			<input type="checkbox" name="optd_rotl"
				<%=props.getProperty("optd_rotl", "")%>>Reversal of tubal
			ligation<br>
			<input type="checkbox" name="optd_vr"
				<%=props.getProperty("optd_vr", "")%>>Vasectomy Reversal<br>
			<input type="checkbox" name="optd_lc"
				<%=props.getProperty("optd_lc", "")%>>Lifestyle changes<br>
			<input type="checkbox" name="optd_wl"
				<%=props.getProperty("optd_wl", "")%>>Weight loss<br>
			<input type="checkbox" name="optd_adoption"
				<%=props.getProperty("optd_adoption", "")%>>Adoption<br>
			<input type="checkbox" name="optd_sc"
				<%=props.getProperty("optd_sc", "")%>>Sperm
			cryopreservation<br>
			<input type="checkbox" name="optd_oc"
				<%=props.getProperty("optd_oc", "")%>>Oocyte
			cryopreservation<br>
			<input type="checkbox" name="optd_ec"
				<%=props.getProperty("optd_ec", "")%>>Embryo
			cryopreservation<br>
			<input type="checkbox" name="optd_oswga"
				<%=props.getProperty("optd_oswga", "")%>>Ovarian
			suppression with a GnRH agonist</td>
		</tr>
		<tr>
			<td>Other:<br>
			<textarea name="optd_other" cols="1" rows="4" style="width: 750px;"><%=props.getProperty("optd_other", "")%></textarea>
			</td>
		</tr>

		<tr>
			<td>&nbsp;</td>
		</tr>

		<tr>
			<td height="10px"><font size="3"><b>Investigations
			Ordered:</b></font></td>
		</tr>
		<tr>
			<td><input type="checkbox" name="io_3hp"
				<%=props.getProperty("io_3hp", "")%>>Day 3 hormonal profile<br>
			<input type="checkbox" name="io_lpp"
				<%=props.getProperty("io_lpp", "")%>>Luteal phase
			progesterone<br>
			<input type="checkbox" name="io_buafc"
				<%=props.getProperty("io_buafc", "")%>>Baseline ultrasound
			with antral follicle count<br>
			<input type="checkbox" name="io_tpu"
				<%=props.getProperty("io_tpu", "")%>>Tubal patency
			ultrasound<br>
			<input type="checkbox" name="io_siuauc"
				<%=props.getProperty("io_siuauc", "")%>>Saline infusion
			ultrasound to assess uterine cavity<br>
			<input type="checkbox" name="io_ids"
				<%=props.getProperty("io_ids", "")%>>Infectious disease
			screening<br>
			<input type="checkbox" name="io_sa"
				<%=props.getProperty("io_sa", "")%>>Semen analysis<br>
			<input type="checkbox" name="io_ksa"
				<%=props.getProperty("io_ksa", "")%>>Kruger semen analysis<br>
			<input type="checkbox" name="io_apat"
				<%=props.getProperty("io_apat", "")%>>Anti-phospholipid
			antibody testing<br>
			<input type="checkbox" name="io_tt"
				<%=props.getProperty("io_tt", "")%>>Thrombophilia testing<br>
			<input type="checkbox" name="io_karyotype"
				<%=props.getProperty("io_karyotype", "")%>>Karyotype for
			both of them<br>
			<input type="checkbox" name="io_mhp"
				<%=props.getProperty("io_mhp", "")%>>Male hormonal profile<br>
			<input type="checkbox" name="io_su"
				<%=props.getProperty("io_su", "")%>>Scrotal ultrasound<br>
			<input type="checkbox" name="io_tu"
				<%=props.getProperty("io_tu", "")%>>Transrectal ultrasound<br>
			<input type="checkbox" name="io_mcf"
				<%=props.getProperty("io_mcf", "")%>>Male CF testing<br>
			<input type="checkbox" name="io_myk"
				<%=props.getProperty("io_myk", "")%>>Male Y-microdeletion
			and Karyotype</td>
		</tr>
		<tr>
			<td>Other:<br>
			<textarea name="io_other" cols="1" rows="4" style="width: 750px;"><%=props.getProperty("io_other", "")%></textarea>
			</td>
		</tr>

		<tr>
			<td height="10px"><font size="3"><b>Treatment Plan:</b></font></td>
		</tr>
		<tr>
			<td><input type="checkbox" name="tp_em" onchange="toggleControl(document.forms[0].tp_em,document.forms[0].tp_em_t)"
				<%=props.getProperty("tp_em", "")%>>Expectant
			management&nbsp;&nbsp;<input name="tp_em_t" type="text" maxlength="15" <%= getdisablestatus(props,"tp_em") %>
				value="<%=props.getProperty("tp_em_t", "")%>"><br>
			<input type="checkbox" name="tp_oiv"  onchange="toggleControl(document.forms[0].tp_oiv,document.forms[0].tp_oiv_t)"
				<%=props.getProperty("tp_oiv", "")%>>Ovulation induction
			with&nbsp;&nbsp;<input name="tp_oiv_t" type="text" maxlength="40" size="40" <%= getdisablestatus(props,"tp_oiv") %>
				value="<%=props.getProperty("tp_oiv_t", "")%>"><br>
			<input type="checkbox" name="tp_saii"
				<%=props.getProperty("tp_saii", "")%>>Superovulation and
			intrauterine insemination<br>
			<input type="checkbox" name="tp_ivf"
				<%=props.getProperty("tp_ivf", "")%>>IVF<br>
			<input type="checkbox" name="tp_ivficsi"
				<%=props.getProperty("tp_ivficsi", "")%>>IVF with ICSI<br>
			<input type="checkbox" name="tp_ivficsi_tse"
				<%=props.getProperty("tp_ivficsi_tse", "")%>>IVF with ICSI
			and testicular sperm extraction<br>
			<input type="checkbox" name="tp_laparoscopy"
				<%=props.getProperty("tp_laparoscopy", "")%>>Laparoscopy<br>
			<input type="checkbox" name="tp_myomectomy"
				<%=props.getProperty("tp_myomectomy", "")%>>Myomectomy<br>
			<input type="checkbox" name="tp_dsi"
				<%=props.getProperty("tp_dsi", "")%>>Donor sperm
			insemination<br>
			<input type="checkbox" name="tp_det"
				<%=props.getProperty("tp_det", "")%>>Donor egg therapy<br>
			<input type="checkbox" name="tp_rotl"
				<%=props.getProperty("tp_rotl", "")%>>Reversal of tubal
			ligation<br>
			<input type="checkbox" name="tp_vr"
				<%=props.getProperty("tp_vr", "")%>>Vasectomy reversal<br>
			<input type="checkbox" name="tp_lc"
				<%=props.getProperty("tp_lc", "")%>>Lifestyle changes<br>
			<input type="checkbox" name="tp_wl"
				<%=props.getProperty("tp_wl", "")%>>Weight loss<br>
			<input type="checkbox" name="tp_adoption"
				<%=props.getProperty("tp_adoption", "")%>>Adoption<br>
			<input type="checkbox" name="tp_sc"
				<%=props.getProperty("tp_sc", "")%>>Sperm cryopreservation<br>
			<input type="checkbox" name="tp_oc"
				<%=props.getProperty("tp_oc", "")%>>Oocyte cryopreservation<br>
			<input type="checkbox" name="tp_ec"
				<%=props.getProperty("tp_ec", "")%>>Embryo cryopreservation<br>
			<input type="checkbox" name="tp_oswga"
				<%=props.getProperty("tp_oswga", "")%>>Ovarian suppression
			with a GnRH agonist<br>
			<input type="checkbox" name="tp_ru"
				<%=props.getProperty("tp_ru", "")%>>Referral to urologist<br>
			<input type="checkbox" name="tp_followup"
				<%=props.getProperty("tp_followup", "")%>>Proceed with
			investigations. Discuss results and treatments at
			follow-up</td>
		</tr>
		<tr>
			<td>Other:<br>
			<textarea name="tp_other" cols="1" rows="4" style="width: 750px;"><%=props.getProperty("tp_other", "")%></textarea>
			</td>
		</tr>
<tr><td bgcolor="white" >&nbsp;<br></td></tr>

<tr class="Head">
			<td>
				<input type="submit" value="Save" onclick="javascript:return onSave();" /> 
				<input type="submit" value="Save and Exit" onclick="javascript:return onSaveExit();" />
				<input type="submit" value="Exit" onclick="javascript:return onExit();" /> 
				<input type="submit" value="Save and Print Preview" onclick="javascript:return onPrint(false);" />
			</td>
		</tr>
		
	</table>
	</body>
</html:form>

<script type="text/javascript">


// due to a glitch in how these form fields are handled by calander-setup.js
// the date parameter that gets passed in Calander.setup gets overwritten
// ... eventually by the current date, even with an empty input field
// so for the following to work you need to patch calander-setup.js;cdem  

// the following code sets the date to last November for the appropriate calanders

var dflu = new Date();
if (dflu.getMonth() < 10)
{
 dflu.setMonth(10); // (last) November is the shot season, so set the calander to it. 
 dflu.setFullYear(dflu.getFullYear()-1);
}


Calendar.setup({ inputField : "consultDate", ifFormat : "%Y/%m/%d", showsTime :false, button : "consultDate_cal", singleClick : true, step : 1 });
Calendar.setup({ inputField : "rfhof_lmp_t", ifFormat : "%Y/%m/%d", showsTime :false, button : "rfhof_lmp_t_cal", singleClick : true, step : 1 });

</script>

</html>

<%!
    protected String listNotes(CaseManagementManager cmgmtMgr, String code, String providerNo, String demoNo) {
        List<Issue> issues = cmgmtMgr.getIssueInfoByCode(providerNo, code);

        String[] issueIds = new String[issues.size()];
        int idx = 0;
        for(Issue issue: issues) {
            issueIds[idx] = String.valueOf(issue.getId());
        }

        // need to apply issue filter
        List<CaseManagementNote>notes = cmgmtMgr.getActiveNotes(demoNo, issueIds);
        StringBuffer noteStr = new StringBuffer();
        for(CaseManagementNote n: notes) {
            if( !n.isLocked() )
                noteStr.append(n.getNote() + "; ");
        } 

        String str = noteStr.toString();
        str = str.trim();
        if(str.endsWith(";") && str.length()>2)
        	str = str.substring(0, str.length()-1);
        return str;
    }
	
	protected String getData(String partnerType,String infoType,java.util.Properties prop){
		/*System.out.println(partnerType + "_" + infoType + "-->"+ prop.getProperty(partnerType + "_" + infoType, ""));*/
		return prop.getProperty(partnerType + "_" + infoType, "");
	}
	
	protected String getdisablestatus(java.util.Properties prop,String parentTag){
		if("".equals(prop.getProperty(parentTag, ""))){
			return " disabled ";
		}else{
			return " ";
		}
	}
	
	protected String getinchdisablestatus(java.util.Properties prop){
		if("".equals(prop.getProperty("pe_ht", ""))){
			return " disabled ";
		}else if(!"feet".equals(prop.getProperty("pe_ht_uom_t", ""))){
			return " disabled ";
		}else{
			return " ";
		}
	}
%>
