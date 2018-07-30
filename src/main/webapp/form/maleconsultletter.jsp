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
 
<%@page import="oscar.oscarDemographic.data.EctInformation"%>
<%@page import="oscar.oscarDemographic.data.RxInformation"%>
<%@page import="org.oscarehr.common.model.Demographic"%>
<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean"%>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html"%>
<%@ taglib uri="/WEB-INF/struts-logic.tld" prefix="logic"%>
<%@ taglib uri="/WEB-INF/rewrite-tag.tld" prefix="rewrite"%>

<%@page import="oscar.OscarProperties"%>
<%@page import="org.oscarehr.casemgmt.model.CaseManagementNote"%>
<%@page import="org.oscarehr.casemgmt.model.Issue"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Collections"%>
<%@page import="org.springframework.web.context.support.WebApplicationContextUtils"%>
<%@page import="org.oscarehr.casemgmt.service.CaseManagementManager"%>
<%@page import="org.springframework.web.context.WebApplicationContext"%>
<%@page import="java.util.ArrayList"%>
<%@page import="oscar.form.FrmRecordFactory"%>
<%@page import="oscar.form.FrmRecord"%>
<%@ page import="org.oscarehr.util.LoggedInInfo" %>
<%@ page import="static org.caisi.comp.web.WebComponentUtil.getServletContext" %>
<HTML>
	<HEAD>
		<TITLE>OFC-Male Consult</TITLE>

	</HEAD>

<style>
body{
	margin: 0;
	font-family: Arial,sans-serif;
	font-size: 12.5px;
}

.table_main{
	border: 1px solid #E5E5E5;
}

.tr_section_header{
background-color: #E5E5E5;
font-size: 14px !important;
color: #317CF0;
font-weight: bold;
height: 23px;
}

.tr_section_header td{
	padding-left: 4px;
	cursor: pointer;
}

.textarea_other{
	width: 100%;
	border: 1px solid #C6C4C4;
}

.cls_text_disabled{
background-color: #F2EFEF;
}

.cls_text{
	border: 1px solid #C6C4C4;
}

.div_form_header{
	font-weight: bold;
	color: white;
	background-color: #86A1C9;
	height: 80px;
}

.span_form_header1{
	font-size: 25px;
	padding-bottom: 3px;
}
.span_form_header2{
	font-size: 17px;
}

.tr_seperator{
	height: 10px;
}
</style>

<script type="text/javascript" src="../js/jquery-1.7.1.min.js"></script>
<link rel="stylesheet" type="text/css" media="all" href="../share/calendar/calendar.css" title="win2k-cold-1">
<script type="text/javascript" src="../share/calendar/calendar.js"></script>
<script type="text/javascript" src="../share/calendar/lang/calendar-en.js"></script>
<script type="text/javascript" src="../share/calendar/calendar-setup.js"></script>

<script>
function toggleHeight(heightuomctrl,inchCtrl){
	if(heightuomctrl.value=="feet"){
		inchCtrl.disabled=false;
	}else{
		inchCtrl.value="";
		inchCtrl.disabled=true;;
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
	
function fn_enableDisableFields(chkObj, id1, id2, id3, id4, id5)
{	
	var flg = $(chkObj).attr("checked");
	enableDisabledField(flg, id1);
	enableDisabledField(flg, id2);
	enableDisabledField(flg, id3);
	enableDisabledField(flg, id4);
	enableDisabledField(flg, id5);

	if($("#"+id1))
	{
		$("#"+id1).focus();
	}
}

function enableDisabledField(flg, id)
{
	var obj = $("#"+id);
	if(obj)
	{
		if(flg)
		{
			$(obj).removeAttr("disabled");
			$(obj).removeClass("cls_text_disabled");
		}
		else
		{
			$(obj).attr("disabled", true);
			$(obj).addClass("cls_text_disabled");
		}
	}
}

$(document).ready(function(){
	$(".tr_section_header").click(function(){
		$(this).next().toggle();
	});
	
	/*$(".tr_section_header").append('<td width="200px" align="right"> '  
			+'<div><a href="#" title="Collapse All Sections"><image src="../trimara/images/collapse.ico" alt="Collapse All Sections"></a> <a href="#" title="Expand All Sections"><image src="../trimara/images/expand.ico" alt="Expand All Sections"></a> '
			+'</div></td>');*/
	$(".tr_section_header").append('<td width="200px" align="right"> '  
			+'</td>');
	
	$(".tr_section_header").next().toggle();
	$(".first_section").next().toggle();

	$("[type=text]").addClass("cls_text_disabled");
	$("#table_pci").find("[type=text]").removeClass("cls_text_disabled");
	
	$("[type=checkbox]").each(function(){
		var flg = $(this).attr("checked");
		if(flg){
			/*var txtObj = $(this).next("[type=text]");
			if(txtObj){
				$(txtObj).removeAttr("disabled");
				$(txtObj).removeClass("cls_text_disabled");
			}*/
			$(this).nextAll("[type=text]").each(function(){
				$(this).removeAttr("disabled");
				$(this).removeClass("cls_text_disabled");
			});
		}
		if(flg){
			var txtObj = $(this).next("select");
			if(txtObj){
				$(txtObj).removeAttr("disabled");
				$(txtObj).removeClass("cls_text_disabled");
			}
		}
	});
	
	Calendar.setup({
		inputField : "pci_date",
		ifFormat : "%Y/%m/%d",
		showsTime : false,
		button : "pci_date_cal",
		singleClick : true,
		step : 1
	});
});


</script>

<%!
String getComboSelectedText(String valueFromDB, String comboValue)
{
	String str = "";
	
	if(valueFromDB!=null && comboValue!=null && valueFromDB.equalsIgnoreCase(comboValue))
	{
		str = "selected='selected'";
	}
	
	return str;
}

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

<%
String formClass = "MaleConsultLetter";
String formLink = "maleconsultletter.jsp";

boolean readOnly = false;
LoggedInInfo loggedInInfo = LoggedInInfo.getLoggedInInfoFromSession(request);
String demographicNo = request.getParameter("demographic_no");
String formId = request.getParameter("formId");
String providerNo = (String) session.getAttribute("user");
FrmRecord rec = (new FrmRecordFactory()).factory(formClass);
java.util.Properties props = rec.getFormRecord(loggedInInfo, Integer.parseInt(demographicNo), Integer.parseInt(formId));

String demo = request.getParameter("demographic_no");
oscar.oscarDemographic.data.DemographicData demoData = null;
Demographic demographic = null;
demoData = new oscar.oscarDemographic.data.DemographicData();
demographic = demoData.getDemographic(loggedInInfo, demo);

ArrayList<String> users = (ArrayList<String>)session.getServletContext().getAttribute("CaseMgmtUsers");
boolean useNewCmgmt = false;
WebApplicationContext ctx = WebApplicationContextUtils.getRequiredWebApplicationContext(getServletContext());
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
partnerDemographic = partnerDemoData.getDemographic(loggedInInfo, partner);

RxInformation rxInfo = new RxInformation();

//partner medication and allergies
props.setProperty("partner_allergies",
	org.apache.commons.lang.StringEscapeUtils.escapeJavaScript(rxInfo.getAllergies(loggedInInfo, partner)));
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
	
RxInformation rxInfo = new RxInformation();

spouseDemoData = new oscar.oscarDemographic.data.DemographicData();
spouseDemographic = spouseDemoData.getDemographic(loggedInInfo, spouse);
//spouse medication and allergies
props.setProperty("spouse_allergies",
		org.apache.commons.lang.StringEscapeUtils.escapeJavaScript(rxInfo.getAllergies(loggedInInfo, spouse)));
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

RxInformation rxInfo = new RxInformation();
husbandDemoData = new oscar.oscarDemographic.data.DemographicData();
husbandDemographic = husbandDemoData.getDemographic(loggedInInfo, husband);
//husband medication and allergies
System.out.println("husband is:555" + rxInfo.getAllergies(loggedInInfo, husband));
props.setProperty("husband_allergies",
		org.apache.commons.lang.StringEscapeUtils.escapeJavaScript(rxInfo.getAllergies(loggedInInfo, husband)));
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

<script>
function importPatient(lNameId, fNameId)
{
    $("#"+lNameId).val("<%=props.getProperty("patient_default_lname", "")%>");
    $("#"+fNameId).val("<%=props.getProperty("patient_default_fname", "")%>");
}
function importPatientAge(id)
{
    $("#"+id).val('<%=props.getProperty("patient_default_age", "")%>');
}
function importPartner(lNameId,fNameId)
{	
	var firstNameCtrl = document.getElementById(fNameId);
	var lastNameCtrl = document.getElementById(lNameId);
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
function importPartnerAge(id)
{
	var ageCtrl = document.getElementById(id);
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
function importDoctor(lNameId, fNameId)
{
	var lastNameCtrl = document.getElementById(lNameId);
	var firstNameCtrl = document.getElementById(fNameId);
	
    lastNameCtrl.value = "<%=props.getProperty("family_doctor_default_lname", "")%>";
	firstNameCtrl.value = "<%=props.getProperty("family_doctor_default_fname", "")%>";
}
function importFromEnct(reqInfo,txtAreaId)
{
	var txtArea = document.getElementById(txtAreaId);
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
                    EctInformation ectInfo = new EctInformation(loggedInInfo, demo);
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
                    	EctInformation ectInfo = new EctInformation(loggedInInfo, demo);
                    //family history was used as bucket for Other Meds in old encounter
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
                    EctInformation ectInfo = new EctInformation(loggedInInfo, demo);
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
                value = rxInfo.getAllergies(loggedInInfo, demo);
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
                     EctInformation ectInfo = new EctInformation(loggedInInfo, demo);
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


function onPrint(pdf) {
	  //onSave();
	  document.forms[0].action = "<rewrite:reWrite jspPage="formname.do"/>";
      document.forms[0].submit.value="printMaleConsultLetter"; 
      document.forms[0].target="_blank";          
      return true;
}

function onSave() {
    //if (temp != "") { document.forms[0].action = temp; }
    document.forms[0].target="_self";
    document.forms[0].submit.value="save";
    /*var ret = checkAllDates();
    if(ret==true)
    {
        ret = confirm("Are you sure you want to save this form?");
    }*/
    return true;
}

function print() {
    document.forms[0].action = "";
    document.forms[0].submit.value="";
    popupFixedPage(1000, 1000, 'maleconsultletterPrint.jsp?formId=' + <%= formId %> + '&demographic_no=' + <%= demographicNo %>);
}

function popupFixedPage(vheight,vwidth,varpage) {
    var page = "" + varpage;
    windowprop = "height="+vheight+",width="+vwidth+",location=no,scrollbars=yes,menubars=no,toolbars=no,resizable=yes,screenX=10,screenY=0,top=0,left=0";
    var popup=window.open(page, "planner", windowprop);
}

</script>

<BODY>
<html:form action="/form/formname" method="post">

<input type="hidden" name="demographic_no" value="<%= props.getProperty("demographic_no", "0") %>" />
<input type="hidden" name="ID" value="<%= formId %>" />
<input type="hidden" name="provider_no" value=<%=request.getParameter("provider_no")%> />
<input type="hidden" name="formCreated" value="<%= props.getProperty("formCreated", "") %>" />
<input type="hidden" name="form_class" value="<%=formClass%>" />
<input type="hidden" name="form_link" value="<%=formLink%>" />
<input type="hidden" name="submit" value="exit" />
<input type="hidden" name="formCreated" value="<%= props.getProperty("formCreated", "") %>" />
<input type="hidden" name="re_text" value="<%= props.getProperty("re_text", "") %>" />
		
<table class="table_main" width="80%" align="center" cellpadding="0" cellspacing="0">
<tbody>
	<tr>
		<td>
			<input type="submit" value="Save" onclick="return onSave();" /> 
			<input type="submit" value="Save and Exit" onclick="javascript:return onSaveExit();" />
			<input type="submit" value="Exit" onclick="javascript:return onExit();" /> 
			<input type="submit" value="Save and Print Preview" onclick="javascript:return onPrint(false);" />
			<input type="submit" value="Print Preview" onclick="javascript:return print();" />
		</td>
	</tr>
	<tr height="2px"><td></td></tr>
	
	<tr>
		<td class="div_form_header" colspan="2">
			<div>
			<div class="span_form_header1">Ottawa Fertility Centre</div>
			<div class="span_form_header2">Male Consult Template</div>
			</div>
		</td>
	</tr>
	
	<tr class="tr_section_header first_section">
		<td>Patient & Consultation Information</td>
		<!-- <td width="200px" align="right"> 
			<div><a href="#">Collapse All</a> <a href="#">Expand All</a>
			</div>
		</td> -->
	</tr>
	<tr>
		<td colspan="2">
			<!-- Patient & Consultation Information - pci -->
			<table id="table_pci" width="100%">
				<tr>
					<td width="100px">Date</td>
					<td>
						<input type="text" maxlength="15" name="pci_date" id="pci_date" 
						size="10" value="<%=props.getProperty("pci_date", "")%>" /> <img
						src="../images/cal.gif" id="pci_date_cal">
					</td>
				</tr>
				<tr>
					<td>Patient Name</td>
					<td>
						<input type="text" maxlength="15" name="pci_patient_lname" id="pci_patient_lname" 
						size="20" value="<%=props.getProperty("pci_patient_lname", "")%>" />,
						<input type="text" maxlength="15" name="pci_patient_fname" id="pci_patient_fname" 
						size="20" value="<%=props.getProperty("pci_patient_fname", "")%>" />
						<input type="button" value="Patient" 
						onclick="importPatient('pci_patient_lname', 'pci_patient_fname');"/>
					</td>
				</tr>
				<tr>
					<td>Patient Age</td>
					<td>
						<input type="text" maxlength="2" name="pci_patient_age" id="pci_patient_age" 
						size="3" value="<%=props.getProperty("pci_patient_age", "")%>" />
						<input type="button" value="Patient Age" 
						onclick="importPatientAge('pci_patient_age');"/>
					</td>
				</tr>
				<tr>
					<td>Partner Name</td>
					<td>
						<input type="text" maxlength="15" name="pci_partner_lname" id="pci_partner_lname" 
						size="10" value="<%=props.getProperty("pci_partner_lname", "")%>" />,
						<input type="text" maxlength="15" name="pci_partner_fname" id="pci_partner_fname" 
						size="10" value="<%=props.getProperty("pci_partner_fname", "")%>" />
						<input type="button" value="Partner" 
						onclick="importPartner('pci_partner_lname', 'pci_partner_fname');"/>
					</td>
				</tr>
				<tr>
					<td>Partner Age</td>
					<td>
						<input type="text" maxlength="2" name="pci_partner_age" id="pci_partner_age" 
						size="3" value="<%=props.getProperty("pci_partner_age", "")%>" />
						<input type="button" value="Partner Age" 
						onclick="importPartnerAge('pci_partner_age');"/>
					</td>
				</tr>
				<tr>
					<td>Referring Physician Name</td>
					<td>
						<input type="text" maxlength="100" name="pci_refer_physic_lname" id="pci_refer_physic_lname" 
						size="10" value="<%=props.getProperty("pci_refer_physic_lname", "")%>" />,
						<input type="text" maxlength="100" name="pci_refer_physic_fname" id="pci_refer_physic_fname" 
						size="10" value="<%=props.getProperty("pci_refer_physic_fname", "")%>" />
						<input type="button" value="Doctor" 
						onclick="importDoctor('pci_refer_physic_lname', 'pci_refer_physic_fname');"/>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	
	<tr class="tr_seperator"><td></td></tr>
	<tr class="tr_section_header">
		<td>Reason for Referral</td>
	</tr>
	<tr>
		<td colspan="2">
			<!-- reason for referrral - rfr-->
			<table id="table_reason_for_referral" width="100%">
				<tr>
					<td>
						<input type="checkbox" id="rfr_male_factor" name="rfr_male_factor" <%=props.getProperty("rfr_male_factor", "")%>/>Male factor infertility
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="rfr_infertility" name="rfr_infertility" 
						<%=props.getProperty("rfr_infertility", "")%>/>Infertility
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="rfr_oligospermia" name="rfr_oligospermia" 
						<%=props.getProperty("rfr_oligospermia", "")%>/>Oligospermia
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="rfr_oligo_astheno" name="rfr_oligo_astheno" 
						<%=props.getProperty("rfr_oligo_astheno", "")%>/>Oligo-asthenospermia
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="rfr_asthenospermia" name="rfr_asthenospermia"
						<%=props.getProperty("rfr_asthenospermia", "")%>/>Asthenospermia
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="rfr_teratospermia" name="rfr_teratospermia"
						<%=props.getProperty("rfr_teratospermia", "")%>/>Teratospermia
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="rfr_oligo_astheno_t" name="rfr_oligo_astheno_t"
						<%=props.getProperty("rfr_oligo_astheno_t", "")%>/>Oligo-astheno-teratospermia
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="rfr_azoospermia" name="rfr_azoospermia"
						<%=props.getProperty("rfr_azoospermia", "")%>/>Azoospermia
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="rfr_testicular_failure" name="rfr_testicular_failure"
						<%=props.getProperty("rfr_testicular_failure", "")%>/>Testicular failure
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="rfr_history_of_vas" name="rfr_history_of_vas"
						<%=props.getProperty("rfr_history_of_vas", "")%>/>History of vasectomy
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="rfr_sperm_cryopre" name="rfr_sperm_cryopre"
						<%=props.getProperty("rfr_sperm_cryopre", "")%>/>Sperm cryopreservation
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="rfr_therapeutic_donor" name="rfr_therapeutic_donor"
						<%=props.getProperty("rfr_therapeutic_donor", "")%>/>Therapeutic donor insemination
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="rfr_erectile_dysfunct" name="rfr_erectile_dysfunct"
						<%=props.getProperty("rfr_erectile_dysfunct", "")%>/>Erectile dysfunction
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="rfr_retrograde_ejacul" name="rfr_retrograde_ejacul"
						<%=props.getProperty("rfr_retrograde_ejacul", "")%>/>Retrograde ejaculation
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="rfr_ejaculatory_dys" name="rfr_ejaculatory_dys"
						<%=props.getProperty("rfr_ejaculatory_dys", "")%>/>Ejaculatory dysfunction
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="rfr_decreased_libi" name="rfr_decreased_libi"
						<%=props.getProperty("rfr_decreased_libi", "")%>/>Decreased libido
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="rfr_varicocele" name="rfr_varicocele"
						<%=props.getProperty("rfr_varicocele", "")%>/>Varicocele(s)
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="rfr_assessment_of_fert" name="rfr_assessment_of_fert"
						<%=props.getProperty("rfr_assessment_of_fert", "")%>/>Assessment of fertility potential
					</td>
				</tr>
				<tr>
					<td>Other: </td>
				</tr>
				<tr>
					<td>
						<textarea id="rfr_other" name="rfr_other" class="textarea_other"><%=props.getProperty("rfr_other", "")%></textarea>
					</td>
				</tr>
			</table>
		</td>
	</tr>

	<tr class="tr_seperator"><td></td></tr>
	<tr class="tr_section_header" >
		<td>Relevant Fertility History and Risk Factors</td>
	</tr>

	<tr>
		<td colspan="2">
			<!-- Relevant Fertility History and Risk Factors - rfh -->
			<table id="table_relevant_fertility_history" width="100%">
				<tr>
					<td>
						<input type="checkbox" id="rfh_duration_of_try" name="rfh_duration_of_try"
						<%=props.getProperty("rfh_duration_of_try", "")%>
						onclick="fn_enableDisableFields(this, 'rfh_duration_of_try_t');" />
						Duration of trying to conceive <input type="text" id="rfh_duration_of_try_t" 
						name="rfh_duration_of_try_t" 
						class="cls_text" style="width: 60px;"  maxlength="15" disabled="true" value="<%=props.getProperty("rfh_duration_of_try_t", "")%>">
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="rfh_frequency_of_inter" name="rfh_frequency_of_inter"
						<%=props.getProperty("rfh_frequency_of_inter", "")%>
						onclick="fn_enableDisableFields(this, 'rfh_frequency_of_inter_t');" />
						Frequency of intercourse <input type="text" id="rfh_frequency_of_inter_t" 
						name="rfh_frequency_of_inter_t" class="cls_text" style="width: 60px;"  maxlength="15" disabled="true" 
						value="<%=props.getProperty("rfh_frequency_of_inter_t", "")%>">
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="rfh_fathered_pregn" name="rfh_fathered_pregn"
						<%=props.getProperty("rfh_fathered_pregn", "")%>
						onclick="fn_enableDisableFields(this, 'rfh_fathered_pregn_t');" />
						Fathered <input type="text" id="rfh_fathered_pregn_t" name="rfh_fathered_pregn_t" 
						class="cls_text" style="width: 60px;" value="<%=props.getProperty("rfh_fathered_pregn_t", "")%>"  
						maxlength="15" disabled="true"> pregnanc(ies)
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="rfh_longest_time_to" name="rfh_longest_time_to" 
						<%=props.getProperty("rfh_longest_time_to", "")%>
						onclick="fn_enableDisableFields(this, 'rfh_longest_time_to_t');" />
						Longest time to conception <input type="text" id="rfh_longest_time_to_t" 
						name="rfh_longest_time_to_t" class="cls_text" style="width: 60px;" 
						 maxlength="15" disabled="true" value="<%=props.getProperty("rfh_longest_time_to_t", "")%>">
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="rfh_erectile_dys" name="rfh_erectile_dys"
						<%=props.getProperty("rfh_erectile_dys", "")%>
						onclick="fn_enableDisableFields(this, 'rfh_erectile_dys_t');" />
						Erectile dysfunction <input type="text" id="rfh_erectile_dys_t"
						 name="rfh_erectile_dys_t" class="cls_text" style="width: 250px;"  
						 maxlength="60" disabled="true" value="<%=props.getProperty("rfh_erectile_dys_t", "")%>">
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="rfh_ejaculatory_dys" name="rfh_ejaculatory_dys"
						<%=props.getProperty("rfh_ejaculatory_dys", "")%>
						onclick="fn_enableDisableFields(this, 'rfh_ejaculatory_dys_t');" />
						Ejaculatory dysfunction <input type="text" id="rfh_ejaculatory_dys_t" 
						name="rfh_ejaculatory_dys_t" class="cls_text" style="width: 250px;"  
						maxlength="60" disabled="true" value="<%=props.getProperty("rfh_ejaculatory_dys_t", "")%>">
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="rfh_shaves" name="rfh_shaves"
						<%=props.getProperty("rfh_shaves", "")%>
						onclick="fn_enableDisableFields(this, 'rfh_shaves_t');" />
						Shaves <input type="text" id="rfh_shaves_t" name="rfh_shaves_t" 
						class="cls_text" style="width: 100px;"  maxlength="100" 
						disabled="true" value="<%=props.getProperty("rfh_shaves_t", "")%>">
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="rfh_vasectomy_done" name="rfh_vasectomy_done"
						<%=props.getProperty("rfh_vasectomy_done", "")%>
						onclick="fn_enableDisableFields(this, 'rfh_vasectomy_done_t');" />
						Vasectomy done in <input type="text" id="rfh_vasectomy_done_t" 
						name="rfh_vasectomy_done_t" class="cls_text" style="width: 100px;"  
						maxlength="100" disabled="true" value="<%=props.getProperty("rfh_vasectomy_done_t", "")%>">
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="rfh_vasectomy_rev" name="rfh_vasectomy_rev"
						<%=props.getProperty("rfh_vasectomy_rev", "")%>
						onclick="fn_enableDisableFields(this, 'rfh_vasectomy_rev_t');" />
						Vasectomy reversal done in <input type="text" id="rfh_vasectomy_rev_t" 
						name="rfh_vasectomy_rev_t" class="cls_text" style="width: 100px;"  
						maxlength="100" disabled="true" value="<%=props.getProperty("rfh_vasectomy_rev_t", "")%>">
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="rfh_history_of_unde" name="rfh_history_of_unde"
						<%=props.getProperty("rfh_history_of_unde", "")%>
						onclick="fn_enableDisableFields(this, 'rfh_history_of_unde_t');" />
						History of undescended <input type="text" id="rfh_history_of_unde_t" 
						name="rfh_history_of_unde_t" class="cls_text" style="width: 100px;" 
						 maxlength="100" disabled="true" value="<%=props.getProperty("rfh_history_of_unde_t", "")%>"> testicle
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="rfh_orchipexy_at" name="rfh_orchipexy_at"
						<%=props.getProperty("rfh_orchipexy_at", "")%>
						onclick="fn_enableDisableFields(this, 'rfh_orchipexy_at_t');" />
						Orchipexy at <input type="text" id="rfh_orchipexy_at_t" name="rfh_orchipexy_at_t" 
						class="cls_text" style="width: 100px;"  maxlength="100" 
						disabled="true" value="<%=props.getProperty("rfh_orchipexy_at_t", "")%>">
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="rfh_history_of_orch" name="rfh_history_of_orch" 
						<%=props.getProperty("rfh_history_of_orch", "")%>/>
						History of orchitis
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="rfh_history_of_scr" name="rfh_history_of_scr"
						<%=props.getProperty("rfh_history_of_scr", "")%>
						onclick="fn_enableDisableFields(this, 'rfh_history_of_scr_t');" />
						History of scrotal trauma <input type="text" id="rfh_history_of_scr_t" 
						name="rfh_history_of_scr_t" class="cls_text" style="width: 100px;" 
						 maxlength="40" disabled="true" value="<%=props.getProperty("rfh_history_of_scr_t", "")%>">
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="rfh_history_of_pro" name="rfh_history_of_pro" 
						<%=props.getProperty("rfh_history_of_pro", "")%>/>
						History of prostatitis
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="rfh_history_of_epi" name="rfh_history_of_epi" 
						<%=props.getProperty("rfh_history_of_epi", "")%>/>
						History of epididymitis
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="rfh_history_of_ure" name="rfh_history_of_ure" 
						<%=props.getProperty("rfh_history_of_ure", "")%>/>
						History of urethral trauma
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="rfh_inguinal_hern" 
						name="rfh_inguinal_hern" <%=props.getProperty("rfh_inguinal_hern", "")%>/>
						Inguinal hernia repair
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="rfh_gonadotoxic_exp" name="rfh_gonadotoxic_exp"
						<%=props.getProperty("rfh_gonadotoxic_exp", "")%>
						onclick="fn_enableDisableFields(this, 'rfh_gonadotoxic_exp_t');" />
						Gonadotoxic exposure(s) <input type="text" id="rfh_gonadotoxic_exp_t" 
						name="rfh_gonadotoxic_exp_t" class="cls_text" style="width: 100px;"  
						maxlength="40" disabled="true" value="<%=props.getProperty("rfh_gonadotoxic_exp_t", "")%>">
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="rfh_alcoholic_drinks" name="rfh_alcoholic_drinks"
						<%=props.getProperty("rfh_alcoholic_drinks", "")%>
						onclick="fn_enableDisableFields(this, 'rfh_alcoholic_drinks_t');" />
						Alcoholic drinks per week <input type="text" id="rfh_alcoholic_drinks_t" name="rfh_alcoholic_drinks_t" class="cls_text" style="width: 30px;"  maxlength="3" disabled="true" 
						value="<%=props.getProperty("rfh_alcoholic_drinks_t", "")%>">
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="rfh_marijuana" name="rfh_marijuana" 
						onclick="fn_enableDisableFields(this, 'rfh_marijuana_t');" <%=props.getProperty("rfh_marijuana", "")%>/>
						Marijuana <input type="text" id="rfh_marijuana_t" name="rfh_marijuana_t" class="cls_text" style="width: 100px;"  maxlength="40" disabled="true" value="<%=props.getProperty("rfh_marijuana_t", "")%>">
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="rfh_smoker" name="rfh_smoker"
						<%=props.getProperty("rfh_smoker", "")%>
						onclick="fn_enableDisableFields(this, 'rfh_smoker_t');" />
						Smoker <input type="text" id="rfh_smoker_t" name="rfh_smoker_t" 
						class="cls_text" style="width: 100px;"  maxlength="100" disabled="true" value="<%=props.getProperty("rfh_smoker_t", "")%>">
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="rfh_non_smoker" name="rfh_non_smoker"
						<%=props.getProperty("rfh_non_smoker", "")%>/>
						Non-Smoker
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="rfh_hot_tubes_sauna" name="rfh_hot_tubes_sauna" 
						<%=props.getProperty("rfh_hot_tubes_sauna", "")%>/>
						Hot tubes / sauna
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="rfh_denies_hot_tubes" name="rfh_denies_hot_tubes"
						<%=props.getProperty("rfh_denies_hot_tubes", "")%>/>
						Denies hot tubes / sauna use
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="rfh_degreasers" name="rfh_degreasers"
						<%=props.getProperty("rfh_degreasers", "")%>/>
						 Degreasers or solvents
					</td>
				</tr>
				<tr>
					<td>Other: </td>
				</tr>
				<tr>
					<td>
						<textarea id="rfh_other" name="rfh_other" class="textarea_other"><%=props.getProperty("rfh_other", "")%></textarea>
					</td>
				</tr>
			</table>
		</td>
	</tr>

	<tr class="tr_seperator"><td></td></tr>
	<tr class="tr_section_header" >
		<td>Previous Investigations</td>
	</tr>

	<tr>
		<td colspan="2">
			<!-- Previous Investigations - previ -->
			<table id="table_previous_investigations" width="100%">
				<tr>
					<td>
						<input type="checkbox" id="previ_normal_semen" name="previ_normal_semen"
						<%=props.getProperty("previ_normal_semen", "")%>/>
						Normal semen analysis
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="previ_abnormal_semen" name="previ_abnormal_semen"
						<%=props.getProperty("previ_abnormal_semen", "")%>
						onclick="fn_enableDisableFields(this, 'previ_abnormal_semen_t');" />
						Abnormal semen analysis <input type="text" id="previ_abnormal_semen_t" 
						name="previ_abnormal_semen_t" class="cls_text" style="width: 100px;"  
						maxlength="40" disabled="true" value="<%=props.getProperty("previ_abnormal_semen_t", "")%>">
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="previ_DNA_frag" name="previ_DNA_frag"
						<%=props.getProperty("previ_DNA_frag", "")%>
						onclick="fn_enableDisableFields(this, 'previ_DNA_frag_t');" />
						DNA Fragmentation <input type="text" id="previ_DNA_frag_t" 
						name="previ_DNA_frag_t" class="cls_text" style="width: 100px;" 
						 maxlength="100" disabled="true" value="<%=props.getProperty("previ_DNA_frag_t", "")%>">
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="previ_azoospermia" name="previ_azoospermia"
						<%=props.getProperty("previ_azoospermia", "")%>/>
						Azoospermia
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="previ_scrotal_ultr" name="previ_scrotal_ultr"
						<%=props.getProperty("previ_scrotal_ultr", "")%>
						onclick="fn_enableDisableFields(this, 'previ_scrotal_ultr_t');" />
						Scrotal ultrasound <input type="text" id="previ_scrotal_ultr_t" 
						name="previ_scrotal_ultr_t" class="cls_text" style="width: 100px;" 
						 maxlength="100" disabled="true" value="<%=props.getProperty("previ_scrotal_ultr_t", "")%>">
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="previ_transrectal_ult" name="previ_transrectal_ult" 
						<%=props.getProperty("previ_transrectal_ult", "")%>
						onclick="fn_enableDisableFields(this, 'previ_transrectal_ult_t');" />
						Scrotal ultrasound <input type="text" id="previ_transrectal_ult_t" 
						name="previ_transrectal_ult_t" class="cls_text" style="width: 100px;" 
						 maxlength="100" disabled="true" value="<%=props.getProperty("previ_transrectal_ult_t", "")%>">
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="previ_hormones" name="previ_hormones"
						<%=props.getProperty("previ_hormones", "")%>
						onclick="fn_enableDisableFields(this, 'previ_hormones_t');" />
						Hormones <input type="text" id="previ_hormones_t" name="previ_hormones_t" 
						class="cls_text" style="width: 100px;"  maxlength="40" disabled="true" value="<%=props.getProperty("previ_hormones_t", "")%>" />
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="previ_y_micro" name="previ_y_micro"
						<%=props.getProperty("previ_y_micro", "")%> onclick="fn_enableDisableFields(this, 'previ_y_micro_t');"  />
						Y microdeletion <input type="text" id="previ_y_micro_t" name="previ_y_micro_t" 
						class="cls_text" style="width: 100px;"  maxlength="40" disabled="true" value="<%=props.getProperty("previ_y_micro_t", "")%>" />
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="previ_karyotype" name="previ_karyotype"
						<%=props.getProperty("previ_karyotype", "")%> 
						onclick="fn_enableDisableFields(this, 'previ_karyotype_t');"/>
						Karyotype <input type="text" id="previ_karyotype_t" name="previ_karyotype_t" 
						class="cls_text" style="width: 100px;"  maxlength="40" disabled="true" 
						value="<%=props.getProperty("previ_karyotype_t", "")%>" />
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="previ_CFTR" name="previ_CFTR"
						<%=props.getProperty("previ_CFTR", "")%>
						onclick="fn_enableDisableFields(this, 'previ_CFTR_t');" />
						CFTR <input type="text" id="previ_CFTR_t" name="previ_CFTR_t" 
						class="cls_text" style="width: 100px;"  maxlength="40" disabled="true" 
						value="<%=props.getProperty("previ_CFTR_t", "")%>" />
					</td>
				</tr>
				<tr>
					<td>Other: </td>
				</tr>
				<tr>
					<td>
						<textarea id="previ_other" name="previ_other" class="textarea_other"><%=props.getProperty("previ_other", "")%></textarea>
					</td>
				</tr>
			</table>
		</td>
	</tr>

	<tr class="tr_seperator"><td></td></tr>
	<tr class="tr_section_header" >
		<td>Medical and Surgical History 
		&nbsp;<input type="button" value="Medical History" 
		onclick="importFromEnct('Medical', 'msh_t'); event.stopPropagation();"/>
		</td>
	</tr>
	<tr>
		<td colspan="2">
			<!-- Medical and Surgical History - msh -->
			<table id="table_medical_and_surgical_history" width="100%">
				<tr>
					<td>
						<textarea id="msh_t" name="msh_t" class="textarea_other"><%=props.getProperty("msh_t", "")%></textarea>
					</td>
				</tr>
			</table>
		</td>
	</tr>

	<tr class="tr_seperator"><td></td></tr>
	<tr class="tr_section_header" >
		<td>Prescriptions and Medications 
		&nbsp;<input type="button" value="Prescriptions"  
		onclick="importFromEnct('Medication', 'pm_t'); event.stopPropagation();"/>
		&nbsp;<input type="button" value="Medications" 
		onclick="importFromEnct('OtherMeds', 'pm_t'); event.stopPropagation();"/>
		</td>
	</tr>
	<tr>
		<td colspan="2">
			<!-- Prescriptions and Medications - pm -->
			<table id="table_prescriptions_and_medications" width="100%">
				<tr>
					<td>
						<textarea id="pm_t" name="pm_t" class="textarea_other"><%=props.getProperty("pm_t", "")%></textarea>
					</td>
				</tr>
			</table>
		</td>
	</tr>

	<tr class="tr_seperator"><td></td></tr>
	<tr class="tr_section_header" >
		<td>Allergies
		&nbsp;<input type="button" value="Allergies" 
		onclick="importFromEnct('Allergies', 'alle_t'); event.stopPropagation();"/>
		</td>
	</tr>
	<tr>
		<td colspan="2">
			<!-- Allergies - alle -->
			<table id="table_allergies" width="100%">
				<tr>
					<td>
						<textarea id="alle_t" name="alle_t" class="textarea_other"><%=props.getProperty("alle_t", "")%></textarea>
					</td>
				</tr>
			</table>
		</td>
	</tr>

	<tr class="tr_seperator"><td></td></tr>
	<tr class="tr_section_header" >
		<td>Family History
		&nbsp;<input type="button" value="Family History" 
		onclick="importFromEnct('Family', 'fh_t'); event.stopPropagation();"/>
		</td>
	</tr>
	<tr>
		<td colspan="2">
			<!-- Family History - fh -->
			<table id="table_family_history" width="100%">
				<tr>
					<td>
						<textarea id="fh_t" name="fh_t" class="textarea_other"><%=props.getProperty("fh_t", "")%></textarea>
					</td>
				</tr>
			</table>
		</td>
	</tr>

	<tr class="tr_seperator"><td></td></tr>
	<tr class="tr_section_header" >
		<td>Social History
		&nbsp;<input type="button" value="Social History" 
		onclick="importFromEnct('Social', 'sh_t'); event.stopPropagation();"/>
		</td>
	</tr>
	<tr>
		<td colspan="2">
			<!-- Social History - sh -->
			<table id="table_social_history" width="100%">
				<tr>
					<td>
						<input type="checkbox" id="sh_occupation" name="sh_occupation"
						<%=props.getProperty("sh_occupation", "")%>
						onclick="fn_enableDisableFields(this, 'sh_occupation_t');" />
						Occupation 
						<input type="text" id="sh_occupation_t" name="sh_occupation_t" 
						class="cls_text" style="width: 100px;"  maxlength="100" disabled="true" value="<%=props.getProperty("sh_occupation_t", "")%>"> 
					</td>
				</tr>
				<tr>
					<td>
						<textarea id="sh_t" name="sh_t" class="textarea_other"><%=props.getProperty("sh_t", "")%></textarea>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	<tr class="tr_seperator"><td></td></tr>
	<tr class="tr_section_header" >
		<td>Female History
		</td>
	</tr>
	<tr>
		<td colspan="2">
			<!-- Female History - fh -->
			<table id="table_female_history" width="100%">
				<tr>
					<td>
						<input type="checkbox" id="fh_age" name="fh_age"
						<%=props.getProperty("fh_age", "")%>
						onclick="fn_enableDisableFields(this, 'fh_age_t');" />
						Age <input type="text" id="fh_age_t" name="fh_age_t" class="cls_text" 
						style="width: 30px;"  maxlength="2" disabled="true" value="<%=props.getProperty("fh_age_t", "")%>">
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="fh_gpep" name="fh_gpep"
						<%=props.getProperty("fh_gpep", "")%>
						onclick="fn_enableDisableFields(this, 'fh_g_t', 'fh_p_t', 'fh_ep_t', 'fh_a_t', 'fh_l_t');" />
						G <input type="text" id="fh_g_t" name="fh_g_t" class="cls_text" 
						style="width: 30px;"  maxlength="2" disabled="true" value="<%=props.getProperty("fh_g_t", "")%>"> 
						P <input type="text" id="fh_p_t" name="fh_p_t" class="cls_text" 
						style="width: 30px;"  maxlength="2" disabled="true" value="<%=props.getProperty("fh_p_t", "")%>">
						EP <input type="text" id="fh_ep_t" name="fh_ep_t" class="cls_text" 
						style="width: 30px;"  maxlength="2" disabled="true" value="<%=props.getProperty("fh_ep_t", "")%>"> 
						A <input type="text" id="fh_a_t" name="fh_a_t" class="cls_text" 
						style="width: 30px;"  maxlength="2" disabled="true" value="<%=props.getProperty("fh_a_t", "")%>"> 
						L <input type="text" id="fh_l_t" name="fh_l_t" class="cls_text" 
						style="width: 30px;"  maxlength="2" disabled="true" value="<%=props.getProperty("fh_l_t", "")%>"> 
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="fh_preg_with_cur" name="fh_preg_with_cur"
						<%=props.getProperty("fh_preg_with_cur", "")%>
						onclick="fn_enableDisableFields(this, 'fh_preg_with_cur_t');" />
						# Pregnancies with current partner <input type="text" id="fh_preg_with_cur_t" 
						name="fh_preg_with_cur_t" class="cls_text" style="width: 30px;"  
						maxlength="2" disabled="true" value="<%=props.getProperty("fh_preg_with_cur_t", "")%>">
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="fh_preg_with_prev" name="fh_preg_with_prev"
						<%=props.getProperty("fh_preg_with_prev", "")%>
						onclick="fn_enableDisableFields(this, 'fh_preg_with_prev_t');" />
						# Pregnancies with previous partner <input type="text" id="fh_preg_with_prev_t" 
						name="fh_preg_with_prev_t" class="cls_text" style="width: 30px;"  
						maxlength="2" disabled="true" value="<%=props.getProperty("fh_preg_with_prev_t", "")%>">
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="fh_female_factor" name="fh_female_factor"
						<%=props.getProperty("fh_female_factor", "")%>
						onclick="fn_enableDisableFields(this, 'fh_female_factor_t');" />
						Female factor(s) identified: <input type="text" id="fh_female_factor_t" 
						name="fh_female_factor_t" class="cls_text" style="width: 100px;"  
						maxlength="100" disabled="true" value="<%=props.getProperty("fh_female_factor_t", "")%>"> 
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="fh_gynec" name="fh_gynec"
						<%=props.getProperty("fh_gynec", "")%>
						onclick="fn_enableDisableFields(this, 'fh_gynec_t');" />
						Gynecologist: <input type="text" id="fh_gynec_t" name="fh_gynec_t" 
						class="cls_text" style="width: 100px;"  maxlength="100" disabled="true" value="<%=props.getProperty("fh_gynec_t", "")%>">
					</td>
				</tr>
				<tr>
					<td>Other: </td>
				</tr>
				<tr>
					<td>
						<textarea id="fh_other" name="fh_other" class="textarea_other"><%=props.getProperty("fh_other", "")%></textarea>
					</td>
				</tr>
			</table>
		</td>
	</tr>

	<tr class="tr_seperator"><td></td></tr>
	<tr class="tr_section_header" >
		<td>Previous Fertility Treatments
		</td>
	</tr>
	<tr>
		<td colspan="2">
			<!-- Previous Fertility Treatments - pft -->
			<table id="table_female_history" width="100%">
				<tr>
					<td>
						<input type="checkbox" id="pft_ovul_induct" name="pft_ovul_induct"
						<%=props.getProperty("pft_ovul_induct", "")%>
						onclick="fn_enableDisableFields(this, 'pft_ovul_induct_t');" />
						Ovulation induction <input type="text" id="pft_ovul_induct_t" name="pft_ovul_induct_t" class="cls_text" 
						style="width: 100px;"  maxlength="100" disabled="true" value="<%=props.getProperty("pft_ovul_induct_t", "")%>">
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="pft_superov_IUI" name="pft_superov_IUI"
						<%=props.getProperty("pft_superov_IUI", "")%>
						onclick="fn_enableDisableFields(this, 'pft_superov_IUI_t');" />
						Superovulation and IUI <input type="text" id="pft_superov_IUI_t" name="pft_superov_IUI_t" class="cls_text" 
						style="width: 100px;"  maxlength="100" disabled="true" value="<%=props.getProperty("pft_superov_IUI_t", "")%>">
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="pft_IUI" name="pft_IUI"
						<%=props.getProperty("pft_IUI", "")%>
						onclick="fn_enableDisableFields(this, 'pft_IUI_t');" />
						IUI <input type="text" id="pft_IUI_t" name="pft_IUI_t" class="cls_text" 
						style="width: 100px;"  maxlength="100" disabled="true" value="<%=props.getProperty("pft_IUI_t", "")%>">
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="pft_IVF" name="pft_IVF"
						<%=props.getProperty("pft_IVF", "")%>
						onclick="fn_enableDisableFields(this, 'pft_IVF_t');" />
						IVF <input type="text" id="pft_IVF_t" name="pft_IVF_t" class="cls_text" 
						style="width: 100px;"  maxlength="100" disabled="true" value="<%=props.getProperty("pft_IVF_t", "")%>">
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="pft_IVF_ICSI" name="pft_IVF_ICSI"
						<%=props.getProperty("pft_IVF_ICSI", "")%>
						onclick="fn_enableDisableFields(this, 'pft_IVF_ICSI_t');" />
						IVF with ICSI <input type="text" id="pft_IVF_ICSI_t" name="pft_IVF_ICSI_t" class="cls_text" 
						style="width: 100px;"  maxlength="100" disabled="true" value="<%=props.getProperty("pft_IVF_ICSI_t", "")%>">
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="pft_donor_sperm_ins" name="pft_donor_sperm_ins"
						<%=props.getProperty("pft_donor_sperm_ins", "")%>/>
						Donor sperm insemination
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="pft_HMG" name="pft_HMG"
						<%=props.getProperty("pft_HMG", "")%>
						onclick="fn_enableDisableFields(this, 'pft_HMG_t');" />
						HMG <input type="text" id="pft_HMG_t" name="pft_HMG_t" class="cls_text" 
						style="width: 100px;"  maxlength="100" disabled="true" value="<%=props.getProperty("pft_HMG_t", "")%>" />
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="pft_HCG" name="pft_HCG"
						<%=props.getProperty("pft_HCG", "")%>
						onclick="fn_enableDisableFields(this, 'pft_HCG_t');" />
						HCG <input type="text" id="pft_HCG_t" name="pft_HCG_t" class="cls_text" 
						style="width: 100px;"  maxlength="100" disabled="true" value="<%=props.getProperty("pft_HCG_t", "")%>">
					</td>
				</tr>
				<tr>
					<td>Other: </td>
				</tr>
				<tr>
					<td>
						<textarea id="pft_other" name="pft_other" class="textarea_other"><%=props.getProperty("pft_other", "")%></textarea>
					</td>
				</tr>
			</table>
		</td>
	</tr>

	<tr class="tr_seperator"><td></td></tr>
	<tr class="tr_section_header" >
		<td>Physical Exam - Male
		</td>
	</tr>
	<tr>
		<td colspan="2">
			<!-- Physical Exam - Male - pem -->
			<table id="table_female_history" width="100%">
				<tr>
					<td>
						<input type="checkbox" id="pem_ht" name="pem_ht"
						<%=props.getProperty("pem_ht", "")%>
						onclick="fn_enableDisableFields(this, 'pem_ht_t', 'pem_ht_feet_inch', 'pem_ht_t_inch');" />
						Ht <input type="text" id="pem_ht_t" name="pem_ht_t" class="cls_text" 
						style="width: 30px;"  maxlength="3" disabled="true" value="<%=props.getProperty("pem_ht_t", "")%>">
						<select name="pem_ht_feet_inch" id="pem_ht_feet_inch" <%= getdisablestatus(props,"pem_ht") %> value="<%=props.getProperty("pem_ht_feet_inch", "")%>"
				onchange="toggleHeight(document.forms[0].pem_ht_feet_inch,document.forms[0].pem_ht_t_inch);"   >
				<option value="feet" <%=getComboSelectedText(props.getProperty("pem_ht_feet_inch", ""), "feet")%>>feet
				<option value="cm" <%=getComboSelectedText(props.getProperty("pem_ht_feet_inch", ""), "cm")%>>cm
			</select> 
				<input type="text" id="pem_ht_t_inch" name="pem_ht_t_inch" class="cls_text" 
						style="width: 30px;"  maxlength="3" disabled="true" value="<%=props.getProperty("pem_ht_t_inch", "")%>"> in
						<script>
				<%
				if(props.getProperty("pem_ht_feet_inch", "").equals("cm")){
					%>
					document.forms[0].pem_ht_t_inch.disabled = true;
					<%
				}
				%>
				</script>
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="pem_wt" name="pem_wt"
						<%=props.getProperty("pem_wt", "")%>
						onclick="fn_enableDisableFields(this, 'pem_wt_t', 'pem_wt_cmb');" />
						Wt <input type="text" id="pem_wt_t" name="pem_wt_t" class="cls_text" 
						style="width: 30px;"  maxlength="3" disabled="true" value="<%=props.getProperty("pem_wt_t", "")%>">
						<select name="pem_wt_cmb" id="pem_wt_cmb" <%= getdisablestatus(props,"pem_wt_t") %> value="<%=props.getProperty("pem_wt_cmb", "")%>">
							<option value="lb" <%=getComboSelectedText(props.getProperty("pem_wt_cmb", ""), "lb")%>>lb
							<option value="kg" <%=getComboSelectedText(props.getProperty("pem_wt_cmb", ""), "kg")%>>kg
						</select>
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="pem_BMI" name="pem_BMI"
						<%=props.getProperty("pem_BMI", "")%>
						onclick="fn_enableDisableFields(this, 'pem_BMI_t');" />
						BMI <input type="text" id="pem_BMI_t" name="pem_BMI_t" class="cls_text" 
						style="width: 50px;"  maxlength="3" disabled="true" value="<%=props.getProperty("pem_BMI_t", "")%>">
						<input type="button" value="Calculate" 
						onclick="calcBMI(document.forms[0].pem_wt_t,document.forms[0].pem_wt_cmb,document.forms[0].pem_ht_t,document.forms[0].pem_ht_feet_inch,document.forms[0].pem_BMI_t,document.forms[0].pem_ht_t_inch);">
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="pem_BP" name="pem_BP" 
						onclick="fn_enableDisableFields(this, 'pem_BP_t');"
						<%=props.getProperty("pem_BP", "")%>/>
						 BP <input type="text" id="pem_BP_t" name="pem_BP_t" class="cls_text" 
						style="width: 50px;"  maxlength="6" disabled="true" value="<%=props.getProperty("pem_BP_t", "")%>">
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="pem_normal_gen_phy" name="pem_normal_gen_phy"
						<%=props.getProperty("pem_normal_gen_phy", "")%>/>
						 Normal general physical exam  
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="pem_normal_andro" name="pem_normal_andro"
						<%=props.getProperty("pem_normal_andro", "")%>/>
						Normal androgenization 
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="pem_gen_phys_exam_fi" name="pem_gen_phys_exam_fi" 
						<%=props.getProperty("pem_gen_phys_exam_fi", "")%>
						onclick="fn_enableDisableFields(this, 'pem_gen_phys_exam_fi_t');" />
						General physical exam findings <input type="text" id="pem_gen_phys_exam_fi_t" name="pem_gen_phys_exam_fi_t" class="cls_text" 
						style="width: 100px;"  maxlength="100" disabled="true" value="<%=props.getProperty("pem_gen_phys_exam_fi_t", "")%>">
					</td>
				</tr>
				
			<!-- </table>
		</td>
	</tr> -->
	
	<!-- <tr class="tr_seperator"><td></td></tr>
	<tr class="tr_section_header" >
		<td>Physical Exam - Male Partner
		</td>
	</tr> -->
	
	<!-- <tr>
		<td colspan="2">
			Physical Exam - Male Partner - pemp
			<table id="table_pemp" width="100%">
				<thead>
					<tr>
						<td width="35%">Left Testicle</td>
						<td width="35%">Right Testicle</td>
						<td width="30">&nbsp;</td>
					</tr>
				</thead> -->
				<tr>
				<td>
				<table width="100%">
				
				<tr>
					<td width="35%"><b>Left Testicle</b></td>
					<td width="35%"><b>Right Testicle</b></td>
					<td width="30">&nbsp;</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="pemp_l_size" name="pemp_l_size"
						<%=props.getProperty("pemp_l_size", "")%>
						onclick="fn_enableDisableFields(this, 'pemp_l_size_t');" />
						Size <input type="text" id="pemp_l_size_t" name="pemp_l_size_t" class="cls_text" 
						style="width: 50px;"  maxlength="6" disabled="true" value="<%=props.getProperty("pemp_l_size_t", "")%>">
					</td>
					<td>
						<input type="checkbox" id="pemp_r_size" name="pemp_r_size"
						<%=props.getProperty("pemp_r_size", "")%>
						onclick="fn_enableDisableFields(this, 'pemp_r_size_t');" />
						Size <input type="text" id="pemp_r_size_t" name="pemp_r_size_t" class="cls_text" 
						style="width: 50px;"  maxlength="6" disabled="true" value="<%=props.getProperty("pemp_r_size_t", "")%>">
					</td>
					<td>&nbsp;</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="pemp_l_vas" name="pemp_l_vas"
						<%=props.getProperty("pemp_l_vas", "")%>
						onclick="fn_enableDisableFields(this, 'pemp_l_vas_t');" />
						Vas <select id="pemp_l_vas_t" name="pemp_l_vas_t" disabled="true" >
							<option value=""></option>
							<option value="Yes" <%=getComboSelectedText(props.getProperty("pemp_l_vas_t", ""), "Yes") %>>Yes</option>
							<option value="No" <%=getComboSelectedText(props.getProperty("pemp_l_vas_t", ""), "No") %>>No</option>
						</select>
					</td>
					<td>
						<input type="checkbox" id="pemp_r_vas" name="pemp_r_vas"
						<%=props.getProperty("pemp_r_vas", "")%>
						onclick="fn_enableDisableFields(this, 'pemp_r_vas_t');" />
						Vas <select id="pemp_r_vas_t" name="pemp_r_vas_t" disabled="true">
							<option value=""></option>
							<option value="Yes" <%=getComboSelectedText(props.getProperty("pemp_r_vas_t", ""), "Yes") %>>Yes</option>
							<option value="No" <%=getComboSelectedText(props.getProperty("pemp_r_vas_t", ""), "No") %>>No</option>
						</select>
					</td>
					<td>&nbsp;</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="pemp_l_varic_grade" name="pemp_l_varic_grade"
						<%=props.getProperty("pemp_l_varic_grade", "")%>
						onclick="fn_enableDisableFields(this, 'pemp_l_varic_grade_t');" />
						Varicocele grade <select id="pemp_l_varic_grade_t" name="pemp_l_varic_grade_t" disabled="true">
							<option value=""></option>
							<option value="0" <%=getComboSelectedText(props.getProperty("pemp_l_varic_grade_t", ""), "0") %>>0</option>
							<option value="1" <%=getComboSelectedText(props.getProperty("pemp_l_varic_grade_t", ""), "1") %>>1</option>
							<option value="2" <%=getComboSelectedText(props.getProperty("pemp_l_varic_grade_t", ""), "2") %>>2</option>
							<option value="3" <%=getComboSelectedText(props.getProperty("pemp_l_varic_grade_t", ""), "3") %>>3</option>							
						</select>
					</td>
					<td>
						<input type="checkbox" id="pemp_r_varic_grade" name="pemp_r_varic_grade"
						<%=props.getProperty("pemp_r_varic_grade", "")%>
						onclick="fn_enableDisableFields(this, 'pemp_r_varic_grade_t');" />
						Varicocele grade <select id="pemp_r_varic_grade_t" name="pemp_r_varic_grade_t" disabled="true">
							<option value=""></option>
							<option value="0" <%=getComboSelectedText(props.getProperty("pemp_r_varic_grade_t", ""), "0") %>>0</option>
							<option value="1" <%=getComboSelectedText(props.getProperty("pemp_r_varic_grade_t", ""), "1") %>>1</option>
							<option value="2" <%=getComboSelectedText(props.getProperty("pemp_r_varic_grade_t", ""), "2") %>>2</option>
							<option value="3" <%=getComboSelectedText(props.getProperty("pemp_r_varic_grade_t", ""), "3") %>>3</option>							
						</select>
					</td>
					<td>&nbsp;</td>
				</tr>
				<tr>
					<td>Other: </td>
				</tr>
				<tr>
					<td colspan="3">
						<textarea id="pemp_other" name="pemp_other" class="textarea_other"><%=props.getProperty("pemp_other", "")%></textarea>
					</td>
				</tr>
				</table>
				</td>
				</tr>
			</table>
		</td>
	</tr>

	<tr class="tr_seperator"><td></td></tr>
	<tr class="tr_section_header" >
		<td>Impression
		</td>
	</tr>
	<tr>
		<td colspan="2">
			<!-- Impression - impr -->
			<table id="table_impr" width="100%">
				<tr>
					<td>
						<input type="checkbox" id="impr_prim_infer_eti" name="impr_prim_infer_eti"
						<%=props.getProperty("impr_prim_infer_eti", "")%>/>
						Primary infertility, etiology not yet determined
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="impr_secon_infer_eti" name="impr_secon_infer_eti"
						<%=props.getProperty("impr_secon_infer_eti", "")%>/>
						Secondary infertility, etiology not yet determined
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="impr_male_factor_inf" name="impr_male_factor_inf"
						<%=props.getProperty("impr_male_factor_inf", "")%>/>
						Male factor infertility caused by gonadotoxic exposures
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="impr_oligospe" name="impr_oligospe"
						<%=props.getProperty("impr_oligospe", "")%>/>
						Oligospermia
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="impr_oligo_asth" name="impr_oligo_asth"
						<%=props.getProperty("impr_oligo_asth", "")%>/>
						Oligo-asthenospermia
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="impr_astheno" name="impr_astheno"
						<%=props.getProperty("impr_astheno", "")%>/>
						Asthenospermia
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="impr_terato" name="impr_terato"
						<%=props.getProperty("impr_terato", "")%>/>
						Teratospermia
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="impr_oligo_ast_tera" name="impr_oligo_ast_tera"
						<%=props.getProperty("impr_oligo_ast_tera", "")%>/>
						Oligo-astheno-teratospermia
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="impr_advan_pat_age" name="impr_advan_pat_age"
						<%=props.getProperty("impr_advan_pat_age", "")%>/>
						Advanced paternal age
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="impr_coital_fact_inf" name="impr_coital_fact_inf"
						<%=props.getProperty("impr_coital_fact_inf", "")%>/>
						Coital factor infertility
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="impr_erectile_dys" name="impr_erectile_dys"
						<%=props.getProperty("impr_erectile_dys", "")%>/>
						Erectile dysfunction
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="impr_retro_ejac" name="impr_retro_ejac"
						<%=props.getProperty("impr_retro_ejac", "")%>/>
						Retrograde ejaculation
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="impr_varico" name="impr_varico"
						<%=props.getProperty("impr_varico", "")%>/>
						Varicocele (s)
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="impr_hypot_dysf" name="impr_hypot_dysf"
						<%=props.getProperty("impr_hypot_dysf", "")%>/>
						Hypothalamic dysfunction
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="impr_test_fail" name="impr_test_fail"
						<%=props.getProperty("impr_test_fail", "")%>/>
						Testicular failure
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="impr_y_microd" name="impr_y_microd"
						<%=props.getProperty("impr_y_microd", "")%>/>
						Y microdeletion
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="impr_kline_syndr" name="impr_kline_syndr"
						<%=props.getProperty("impr_kline_syndr", "")%>/>
						Klinefelter's syndrome
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="impr_cong_bil_abs" name="impr_cong_bil_abs"
						<%=props.getProperty("impr_cong_bil_abs", "")%>/>
						Congenital bilateral absence of the vas
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="impr_azoospermia" name="impr_azoospermia"
						<%=props.getProperty("impr_azoospermia", "")%>/>
						Azoospermia
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="impr_obstr_azoo" name="impr_obstr_azoo"
						<%=props.getProperty("impr_obstr_azoo", "")%>/>
						Obstructive azoospermia
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="impr_non_obstr_azoo" name="impr_non_obstr_azoo"
						<%=props.getProperty("impr_non_obstr_azoo", "")%>/>
						Non-obstructive azoospermia
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="impr_epid_obstr" name="impr_epid_obstr"
						<%=props.getProperty("impr_epid_obstr", "")%>/>
						Epididymal obstruction
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="impr_male_obe" name="impr_male_obe"
						<%=props.getProperty("impr_male_obe", "")%>/>
						Male obesity
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="impr_hyperprola" name="impr_hyperprola"
						<%=props.getProperty("impr_hyperprola", "")%>/>
						Hyperprolactinemia
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="impr_req_sperm_cry"  name="impr_req_sperm_cry"
						<%=props.getProperty("impr_req_sperm_cry", "")%>
						onclick="fn_enableDisableFields(this, 'impr_req_sperm_cry_t');" />
						Request for sperm cryopreservation <input type="text" id="impr_req_sperm_cry_t" name="impr_req_sperm_cry_t" class="cls_text" 
						style="width: 100px;"  maxlength="100" disabled="true" value="<%=props.getProperty("impr_req_sperm_cry_t", "")%>">
					</td>
				</tr>
				<tr>
					<td>Other: </td>
				</tr>
				<tr>
					<td colspan="3">
						<textarea id="impr_other" name="impr_other" class="textarea_other"><%=props.getProperty("impr_other", "")%></textarea>
					</td>
				</tr>
			</table>
		</td>
	</tr>

	<tr class="tr_seperator"><td></td></tr>
	<tr class="tr_section_header" >
		<td>Options Discussed
		</td>
	</tr>
	<tr>
		<td colspan="2">
			<!-- Options Discussed - optd -->
			<table id="table_optd" width="100%">
				<tr>
					<td>
						<input type="checkbox" id="optd_expec_manage" name="optd_expec_manage"
						<%=props.getProperty("optd_expec_manage", "")%>/>
						Expectant management
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="optd_superov_intr" name="optd_superov_intr"
						<%=props.getProperty("optd_superov_intr", "")%>/>
						Superovulation and intrauterine insemination
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="optd_IVF_ICSI" name="optd_IVF_ICSI"
						<%=props.getProperty("optd_IVF_ICSI", "")%>/>
						IVF with ICSI
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="optd_IVF_ICSI_test" name="optd_IVF_ICSI_test"
						<%=props.getProperty("optd_IVF_ICSI_test", "")%>/>
						IVF with ICSI and testicular sperm extraction
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="optd_IVF_ICSI_micro" name="optd_IVF_ICSI_micro"
						<%=props.getProperty("optd_IVF_ICSI_micro", "")%>/>
						IVF with ICSI and micro-testicular sperm extraction
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="optd_scrotal_exp_pos" name="optd_scrotal_exp_pos"
						<%=props.getProperty("optd_scrotal_exp_pos", "")%>/>
						Scrotal exploration with possible vasoepididymostomy
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="optd_vasec_reve" name="optd_vasec_reve"
						<%=props.getProperty("optd_vasec_reve", "")%>/>
						Vasectomy revearsal
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="optd_vari_rep" name="optd_vari_rep"
						<%=props.getProperty("optd_vari_rep", "")%>/>
						Varicocele repair
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="optd_gonado_ther" name="optd_gonado_ther"
						<%=props.getProperty("optd_gonado_ther", "")%>/>
						Gonadotropin therapy
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="optd_clomi_ther" name="optd_clomi_ther"
						<%=props.getProperty("optd_clomi_ther", "")%>/>
						Clomiphene therapy
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="optd_antic_ther"  name="optd_antic_ther"
						<%=props.getProperty("optd_antic_ther", "")%>
						onclick="fn_enableDisableFields(this, 'optd_antic_ther_t');" />
						Anticholinergic therapy with <input type="text" id="optd_antic_ther_t" name="optd_antic_ther_t" class="cls_text" 
						style="width: 100px;"  maxlength="100" disabled="true" value="<%=props.getProperty("optd_antic_ther_t", "")%>">
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="optd_donor_sperm_ins" name="optd_donor_sperm_ins"
						<%=props.getProperty("optd_donor_sperm_ins", "")%>/>
						Donor sperm insemination
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="optd_lifestyle_ch" name="optd_lifestyle_ch"
						<%=props.getProperty("optd_lifestyle_ch", "")%>/>
						Lifestyle changes
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="optd_weight_loss" name="optd_weight_loss"
						<%=props.getProperty("optd_weight_loss", "")%>/>
						Weight loss
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="optd_adoption" name="optd_adoption"
						<%=props.getProperty("optd_adoption", "")%>/>
						Adoption
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="optd_sperm_cryopr" name="optd_sperm_cryopr"
						<%=props.getProperty("optd_sperm_cryopr", "")%>/>
						Sperm cryopreservation
					</td>
				</tr>
				<tr>
					<td>Other: </td>
				</tr>
				<tr>
					<td colspan="3">
						<textarea id="optd_other" name="optd_other" class="textarea_other"><%=props.getProperty("optd_other", "")%></textarea>
					</td>
				</tr>
			</table>
		</td>
	</tr>

	<tr class="tr_seperator"><td></td></tr>
	<tr class="tr_section_header" >
		<td>Investigations Ordered
		</td>
	</tr>
	<tr>
		<td colspan="2">
			<!-- Investigations Ordered - invo -->
			<table id="table_invo" width="100%">
				<tr>
					<td>
						<input type="checkbox" id="invo_horm_prof" name="invo_horm_prof"
						<%=props.getProperty("invo_horm_prof", "")%>/>
						Hormonal profile
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="invo_semen_analysis" name="invo_semen_analysis"
						<%=props.getProperty("invo_semen_analysis", "")%>/>
						Semen analysis
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="invo_repeat_semen" name="invo_repeat_semen"
						<%=props.getProperty("invo_repeat_semen", "")%>/>
						Repeat semen analysis
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="invo_kruger_semen" name="invo_kruger_semen"
						<%=props.getProperty("invo_kruger_semen", "")%>/>
						Kruger semen analysis
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="invo_DNA_frag" name="invo_DNA_frag"
						<%=props.getProperty("invo_DNA_frag", "")%>/>
						DNA Fragmentation
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="invo_scrotal_ultra" name="invo_scrotal_ultra"
						<%=props.getProperty("invo_scrotal_ultra", "")%>/>
						Scrotal ultrasound
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="invo_trans_ultr" name="invo_trans_ultr"
						<%=props.getProperty("invo_trans_ultr", "")%>/>
						Transrectal ultrasound
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="invo_male_CF" name="invo_male_CF"
						<%=props.getProperty("invo_male_CF", "")%>/>
						Male CF testing
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="invo_y_micro" name="invo_y_micro"
						<%=props.getProperty("invo_y_micro", "")%>/>
						 Y microdeletion
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="invo_karyotype" name="invo_karyotype"
						<%=props.getProperty("invo_karyotype", "")%>/>
						 Karyotype
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="invo_head_MRI" name="invo_head_MRI"
						<%=props.getProperty("invo_head_MRI", "")%>/>
						 Head MRI
					</td>
				</tr>
				<tr>
					<td>Other: </td>
				</tr>
				<tr>
					<td colspan="3">
						<textarea id="invo_other" name="invo_other" class="textarea_other"><%=props.getProperty("invo_other", "")%></textarea>
					</td>
				</tr>
			</table>
		</td>
	</tr>

	<tr class="tr_seperator"><td></td></tr>
	<tr class="tr_section_header" >
		<td>Treatment Plan
		</td>
	</tr>
	<tr>
		<td colspan="2">
			<!-- Treatment Plan - trtp -->
			<table id="table_trtp" width="100%">
				<tr>
					<td>
						<input type="checkbox" id="trtp_expe_manage"  name="trtp_expe_manage"
						<%=props.getProperty("trtp_expe_manage", "")%>
						onclick="fn_enableDisableFields(this, 'trtp_expe_manage_t');" />
						Expectant management <input type="text" id="trtp_expe_manage_t" name="trtp_expe_manage_t" class="cls_text" 
						style="width: 100px;"  maxlength="100" disabled="true" value="<%=props.getProperty("trtp_expe_manage_t", "")%>">
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="trtp_superov_intr" name="trtp_superov_intr"
						<%=props.getProperty("trtp_superov_intr", "")%>/>
						 Superovulation and intrauterine insemination
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="trtp_IVF_ICSI" name="trtp_IVF_ICSI"
						<%=props.getProperty("trtp_IVF_ICSI", "")%>/>
						 IVF with ICSI
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="trtp_IVF_ICSI_test" name="trtp_IVF_ICSI_test"
						<%=props.getProperty("trtp_IVF_ICSI_test", "")%>/>
						IVF with ICSI and testicular sperm extraction
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="trtp_IVF_ICSI_micro" name="trtp_IVF_ICSI_micro"
						<%=props.getProperty("trtp_IVF_ICSI_micro", "")%>/>
						IVF with ICSI and micro-testicular sperm extraction
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="trtp_donor_sperm_ins" name="trtp_donor_sperm_ins"
						<%=props.getProperty("trtp_donor_sperm_ins", "")%>/>
						Donor sperm insemination
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="trtp_vasec_rev" name="trtp_vasec_rev"
						<%=props.getProperty("trtp_vasec_rev", "")%>/>
						Vasectomy reversal
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="trtp_lifestyle_ch" name="trtp_lifestyle_ch"
						<%=props.getProperty("trtp_lifestyle_ch", "")%>/>
						Lifestyle changes
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="trtp_weight_loss" name="trtp_weight_loss"
						<%=props.getProperty("trtp_weight_loss", "")%>/>
						Weight loss
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="trtp_adoption" name="trtp_adoption"
						<%=props.getProperty("trtp_adoption", "")%>/>
						Adoption
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="trtp_sperm_cry" name="trtp_sperm_cry"
						<%=props.getProperty("trtp_sperm_cry", "")%>/>
						Sperm cryopreservation
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="trtp_varic_rep" name="trtp_varic_rep"
						<%=props.getProperty("trtp_varic_rep", "")%>/>
						Varicocele repair
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="trtp_clomi_ther"  name="trtp_clomi_ther"
						<%=props.getProperty("trtp_clomi_ther", "")%>
						onclick="fn_enableDisableFields(this, 'trtp_clomi_ther_t');" />
						Clomiphene therapy <input type="text" id="trtp_clomi_ther_t" name="trtp_clomi_ther_t" class="cls_text" 
						style="width: 100px;"  maxlength="100" disabled="true" value="<%=props.getProperty("trtp_clomi_ther_t", "")%>">
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="trtp_gona_ther"  name="trtp_gona_ther"
						<%=props.getProperty("trtp_gona_ther", "")%>
						onclick="fn_enableDisableFields(this, 'trtp_gona_ther_t');" />
						Gonadotropin therapy <input type="text" id="trtp_gona_ther_t" name="trtp_gona_ther_t" class="cls_text" 
						style="width: 100px;"  maxlength="100" disabled="true" value="<%=props.getProperty("trtp_gona_ther_t", "")%>">
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="trtp_anticho_ther"  name="trtp_anticho_ther"
						<%=props.getProperty("trtp_anticho_ther", "")%>
						onclick="fn_enableDisableFields(this, 'trtp_anticho_ther_t');" />
						Anticholinergic therapy with <input type="text" id="trtp_anticho_ther_t" name="trtp_anticho_ther_t" class="cls_text" 
						style="width: 100px;"  maxlength="100" disabled="true" value="<%=props.getProperty("trtp_anticho_ther_t", "")%>">
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="trtp_cialis"  name="trtp_cialis"
						<%=props.getProperty("trtp_cialis", "")%>
						onclick="fn_enableDisableFields(this, 'trtp_cialis_t');" />
						Cialis <input type="text" id="trtp_cialis_t" name="trtp_cialis_t" class="cls_text" 
						style="width: 100px;"  maxlength="100" disabled="true" value="<%=props.getProperty("trtp_cialis_t", "")%>">
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="trtp_viagra"  name="trtp_viagra"
						<%=props.getProperty("trtp_viagra", "")%>
						onclick="fn_enableDisableFields(this, 'trtp_viagra_t');" />
						Viagra <input type="text" id="trtp_viagra_t" name="trtp_viagra_t" class="cls_text" 
						style="width: 100px;"  maxlength="100" disabled="true" value="<%=props.getProperty("trtp_viagra_t", "")%>">
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="trtp_refer_dr"  name="trtp_refer_dr"
						<%=props.getProperty("trtp_refer_dr", "")%>
						onclick="fn_enableDisableFields(this, 'trtp_refer_dr_t');" />
						Referral to Dr. <input type="text" id="trtp_refer_dr_t" name="trtp_refer_dr_t" class="cls_text" 
						style="width: 100px;"  maxlength="100" disabled="true" value="<%=props.getProperty("trtp_refer_dr_t", "")%>">
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="trtp_refer_reprod" name="trtp_refer_reprod"
						<%=props.getProperty("trtp_refer_reprod", "")%>/>
						Referral to a Reproductive Endocrinologist
					</td>
				</tr>
				<tr>
					<td>
						<input type="checkbox" id="trtp_proceed_invest" name="trtp_proceed_invest"
						<%=props.getProperty("trtp_proceed_invest", "")%>/>
						Proceed with investigations and discuss results and potential treatments at follow-up appointment
					</td>
				</tr>
				<tr>
					<td>Other: </td>
				</tr>
				<tr>
					<td colspan="3">
						<textarea id="trtp_other" name="trtp_other" class="textarea_other"><%=props.getProperty("trtp_other", "")%></textarea>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	<tr height="2px"><td></td></tr>
	<tr>
		<td>
			<input type="submit" value="Save" onclick="javascript:return onSave();" /> 
			<input type="submit" value="Save and Exit" onclick="javascript:return onSaveExit();" />
			<input type="submit" value="Exit" onclick="javascript:return onExit();" /> 
			<input type="submit" value="Save and Print Preview" onclick="javascript:return onPrint(false);" />
		</td>
	</tr>
</tbody>

</table>
</html:form>
</BODY>
</HTML>
