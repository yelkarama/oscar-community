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
<%@page import="oscar.oscarClinic.ClinicData"%>
<%@page import="oscar.oscarDemographic.data.RxInformation"%>
<%@page import="oscar.oscarDemographic.data.EctInformation"%>
<%@page import="org.oscarehr.common.model.Demographic"%>
<%@page import="org.oscarehr.util.LoggedInInfo"%> 
<%@page import="java.util.Properties"%>
<%@ page language="java"%>
<%@page
	import="java.util.ArrayList,java.util.Collections,java.util.List,oscar.dms.*,oscar.oscarEncounter.pageUtil.*,oscar.oscarEncounter.data.*,oscar.util.StringUtils,oscar.oscarLab.ca.on.*"%>
<%@page
	import="org.oscarehr.casemgmt.service.CaseManagementManager,org.oscarehr.casemgmt.model.CaseManagementNote,org.oscarehr.casemgmt.model.Issue,org.oscarehr.common.model.UserProperty,org.oscarehr.common.dao.UserPropertyDAO,org.springframework.web.context.support.*,org.springframework.web.context.*,java.text.DecimalFormat"%>

<%@ page import="oscar.form.*,oscar.OscarProperties"%>
<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean"%>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html"%>
<%@ taglib uri="/WEB-INF/struts-logic.tld" prefix="logic"%>
<%@ taglib uri="/WEB-INF/rewrite-tag.tld" prefix="rewrite"%>

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">

<title>Gynae Form</title>
<style type="text/css">
.style1 {
	width: 1123px;
}

.reason_div{
float: left;
white-space: nowrap;
margin-right: 4px;
}

</style>

<!-- calendar stylesheet -->
<link rel="stylesheet" type="text/css" media="all"
	href="../share/calendar/calendar.css" title="win2k-cold-1">

<!-- main calendar program -->
<script type="text/javascript" src="../share/calendar/calendar.js"></script>
<link href="printStyle.css" rel=" stylesheet" type="text/css"
	media="print">

<!-- language for the calendar -->
<script type="text/javascript"
	src="../share/calendar/lang/calendar-en.js"></script>

<!-- the following script defines the Calendar.setup helper function, which makes
       adding a calendar a matter of 1 or 2 lines of code. -->
<script type="text/javascript" src="../share/calendar/calendar-setup.js"></script>
<script language="JavaScript">
	function showHide(checkBoxId, tagName) {
		var checkBoxStatus = document.getElementById(checkBoxId).checked;
		var table = document.getElementById(tagName);
		if (checkBoxStatus == true) {
			table.style.display = 'table';
		} else {
			table.style.display = 'none';
		}
	}
</script>
<script type="text/javascript" src="../js/jquery.js"></script>
</head>

<script type="text/javascript">
function onSave()
{
	document.forms[0].submit.value = "save";
}
function onSaveExit()
{
	document.forms[0].submit.value = "exit";
}


function onClickPrint()
{ 
	onSave();
	hideTextArea();	
	
	manageCheckboxLayout_show("reason_for_referral", 0);
	manageCheckboxLayout_show("past_med_history", 2);
	manageCheckboxLayout_show("investigations_", 0, "investigations_");
	manageCheckboxLayout_show("treatment", 0, "treatment");
	manageCheckboxLayout_show("follow_up", 0, "follow_up");
	
	$("[class=NonPrintable]").toggle();
	hideTextboxBorder();
	$("[id=div_intro]").toggle();
	
	window.print();
	
	$("[id=div_intro]").toggle();
	$("[class=NonPrintable]").toggle();
	
	manageCheckboxLayout_hide("reason_for_referral", 0);
	manageCheckboxLayout_hide("past_med_history", 2);
	manageCheckboxLayout_hide("investigations_", 0, "investigations_");
	manageCheckboxLayout_hide("treatment", 0, "treatment");
	manageCheckboxLayout_hide("follow_up", 0, "follow_up");
	
	showTextArea();
	
}

function hideTextboxBorder()
{
	$("[id=followup_weeks1]").css("border", "0");
	$("[id=treatment_bcp1]").css("border", "0");
}

function manageCheckboxLayout_hide(id, index, tr_id)
{
	var tr_id_hide = "cls_tr_"+id;
	var tr_id_show = "tr_div_"+id;
	var div_id = "div_"+id;
	
	$("[class="+tr_id_hide+"]").show();
	$("[id="+div_id+"]").children().remove();
	$("[id="+tr_id_show+"]").hide();
}

function manageCheckboxLayout_show(id, index, tr_id) //tr_id for investigations
{
	var tr_id_hide = "cls_tr_"+id;
	var tr_id_show = "tr_div_"+id;
	var div_id = "div_"+id;
	var table_id = "table_"+id;
	if(tr_id=="investigations_" || tr_id=="treatment" || tr_id=="follow_up")
		table_id = "cls_tr_"+id;
	else
		table_id = "table_"+id;
	var chk_arr = $("[id="+table_id+"]").find("[type=checkbox]");
	
	if(tr_id=="investigations_" || tr_id=="treatment" || tr_id=="follow_up")
	{
		chk_arr = $("[class="+table_id+"]").find("[type=checkbox]");
		//alert("chk_arr = "+chk_arr.length);
	}
	
	$("[class="+tr_id_hide+"]").hide();
	$("[id="+div_id+"]").children().remove();
	$("[id="+tr_id_show+"]").show();
	
	//alert(jQuery.trim($(chk_arr[0]).html()));
	var divStr = "<div class='reason_div'>";
	for(i=index;i<chk_arr.length;i++)
	{
		if(!$(chk_arr[i]).attr("checked"))
			continue;
		
		/*if(tr_id=="investigations_")
			alert("id = "+$(chk_arr[i]).attr("id"));*/
		
		var txt = jQuery.trim($(chk_arr[i]).parent().text());
		
		if(tr_id=="investigations_" || tr_id=="treatment" || tr_id=="follow_up")
			txt = jQuery.trim($(chk_arr[i]).parent().parent().text());
		if(tr_id=="treatment" || tr_id=="follow_up")
		{
			txt = jQuery.trim($(chk_arr[i]).parent().next().html());
		}
		divStr = "<div class='reason_div'>";
		
		var cloneObj = $(chk_arr[i]).clone();
		cloneObj.attr("checked", $(chk_arr[i]).attr("checked")+"");
		
		divStr = divStr+cloneObj.wrap('<div></div>').parent().html();
		divStr = divStr+"<span>"+txt+"</span>";
		divStr = divStr+"</div>";
		$("[id="+div_id+"]").append(divStr);
		
		if($(chk_arr[i]).attr("checked"))
		{
			$("[id="+$(chk_arr[i]).attr("id")+"]").attr("checked", true);
		}
		
		if(tr_id=="treatment" || tr_id=="follow_up") 
		{
			//alert($(chk_arr[i]).parent().next().children("[type=text]").length);
			if($(chk_arr[i]).parent().next().children("[type=text]").length==1)
			{
				var txtVal = $(chk_arr[i]).parent().next().children("[type=text]").attr("value");
				//alert("txtVal = "+txtVal);
				$("[id="+$(chk_arr[i]).parent().next().children("[type=text]").attr("id")+"]").each(function(){
					if($(this).attr("value")=="")
					{
						$(this).attr("value", txtVal);
					}
				});
			}
		}	
	}
	
	//$("[class=cls_tr_reason_for_referral]").show();
	//$("[id=tr_div_reason_for_referral]").hide();
}

var txtAreaArr;
function hideTextArea()
{
	txtAreaArr = new Array();
	var i = 1;
	$("textarea").each(function(){
		//alert($(this).attr("id")+" - "+$(this).is(":visible"));
		if($(this).is(":visible"))
		{
			txtAreaArr[i++] = $(this);
			//alert($(this).parent());
			var spanStr = "<span id='span_hide'>"+$(this).attr("value")+"</span>";
			//alert("spanStr = "+spanStr);
			$(this).hide(); 
			$(this).parent().append(spanStr);
			//alert("id = "+$(this).attr("id"));
		}
	});
	
}

function showTextArea()
{
	if(txtAreaArr)
	{
		$(txtAreaArr).each(function(){
			if($(this).attr("id")) 
				$(this).show();
		});
		
		$("[id=span_hide]").each(function(){
			$(this).hide();
		});
	}
}
</script>

<%!
private String getMonthYearStr(String str)
{
	if(str!=null && str.length()>3)
	{
		str = str.substring(0, str.length()-3);
	}
	
	return str;
}
%>
<%
	LoggedInInfo loggedInInfo = LoggedInInfo.getLoggedInInfoFromSession(request);
	String formClass = "GynaeForm";
	String formLink = "formgynae.jsp";
	String strDemoNum = request.getParameter("demographic_no");

	boolean readOnly = false;
	int formId = Integer.parseInt(request.getParameter("formId"));
	String providerNo = (String) session.getAttribute("user");
	FrmRecord rec = (new FrmRecordFactory()).factory(formClass);
	
	java.util.Properties props = rec.getFormRecord(loggedInInfo, Integer.parseInt(strDemoNum), formId);
 
	request.removeAttribute("submit");
	String userfirstname = (String) session
			.getAttribute("userfirstname");
	String userlastname = (String) session.getAttribute("userlastname");
	String abnPAPDivStyle = "style='display: none;width: 8.5in;'";
	String string1 = props.getProperty("rfr_abn_pap", "");
	if (!string1.equals("")) {
		abnPAPDivStyle = "style='display: table;width: 8.5in;'";
	}

	String infertilityDivStyle = "style='display: none;width: 8.5in;'";
	string1 = props.getProperty("rfr_infertility", "");
	if (!string1.equals("")) {
		infertilityDivStyle = "style='display: table;width: 8.5in;'";
	}

	String menorrhagiaDivStyle = "style='display: none;width: 8.5in;'";
	string1 = props.getProperty("rfr_menorrhagia", "");
	if (!string1.equals("")) {
		menorrhagiaDivStyle = "style='display: table;width: 8.5in;'";
	}
	String contraceptiveDivStyle = "style='display: none;width: 8.5in;'";
	string1 = props.getProperty("rfr_contraceptivehist", "");
	if (!string1.equals("")) {
		contraceptiveDivStyle = "style='display: table;width: 8.5in;'";
	}
	String irregularDivStyle = "style='display: none;width: 8.5in;'";
	string1 = props.getProperty("rfr_irregularperiods", "");
	if (!string1.equals("")) {
		irregularDivStyle = "style='display: table;width: 8.5in;'";
	}
	String ovarianDivStyle = "style='display: none;width: 8.5in;'";
	string1 = props.getProperty("rfr_ovariancyst", "");
	if (!string1.equals("")) {
		ovarianDivStyle = "style='display: table;width: 8.5in;'";
	}
	String fibroidsDivStyle = "style='display: none;width: 8.5in;'";
	string1 = props.getProperty("rfr_fibroids", "");
	if (!string1.equals("")) {
		fibroidsDivStyle = "style='display: table;width: 8.5in;'";
	}
	String menopauseDivStyle = "style='display: none;width: 8.5in;'";
	string1 = props.getProperty("rfr_menopause", "");
	if (!string1.equals("")) {
		menopauseDivStyle = "style='display: table;width: 8.5in;'";
	}
	String pelvicPainDivStyle = "style='display: none;width: 8.5in;'";
	string1 = props.getProperty("rfr_pelvicpain", "");
	if (!string1.equals("")) {
		pelvicPainDivStyle = "style='display: table;width: 8.5in;'";
	}
	String incontinenceDivStyle = "style='display: none;width: 8.5in;'";
	string1 = props.getProperty("rfr_incontinence", "");
	if (!string1.equals("")) {
		incontinenceDivStyle = "style='display: table;width: 8.5in;'";
	}
	
	//clinic information
	
	ClinicData clinic = new ClinicData();

	String clinicName = clinic.getClinicName();
	String clinicAddress = clinic.getClinicAddress();
	String clinicCity = clinic.getClinicCity();
	String clinicProvince = clinic.getClinicProvince();
	String clinicPostal = clinic.getClinicPostal();
	
	//Default values.
	String demo = request.getParameter("demographic_no");
	oscar.oscarDemographic.data.DemographicData demoData = null;
	Demographic demographic = null;
	demoData = new oscar.oscarDemographic.data.DemographicData();
	demographic = demoData.getDemographic(loggedInInfo, demo);

	ArrayList<String> users = (ArrayList<String>)session.getServletContext().getAttribute("CaseMgmtUsers");
	boolean useNewCmgmt = false;
	WebApplicationContext  ctx = WebApplicationContextUtils.getRequiredWebApplicationContext(getServletContext());
	CaseManagementManager cmgmtMgr = null;
	if( users != null && users.size() > 0 && (users.get(0).equalsIgnoreCase("all") || Collections.binarySearch(users, providerNo)>=0)) {
		useNewCmgmt = true;
		cmgmtMgr = (CaseManagementManager)ctx.getBean("caseManagementManager");
	}
	
	boolean recordFromDB = false;
	if(props.getProperty("ID")!=null && props.getProperty("ID").length()>0)
	{
		recordFromDB = true;
	}
	
%>


<%!
String getSelectedAttr(java.util.Properties p1, String column, String value)
{
	String str = "";
	if(p1!=null && p1.getProperty(column, "").equals(value))
		str = "selected";
	return str;
}
%>
<html:form action="/form/formname">
	<input type="hidden" name="demographic_no"
		value=<%=props.getProperty("demographic_no", "")%>>
	<input type="hidden" name="ID" value="<%=formId%>">
	<input type="hidden" name="provider_no" value=<%=providerNo%>>
	<input type="hidden" name="form_class" value="<%=formClass%>">
	<input type="hidden" name="form_link" value="<%=formLink%>">
	<input type="hidden" name="submit" value="exit">
	<input type="hidden" name="formCreated"
		value=<%=props.getProperty("formCreated", "")%>>
	<!-- <body style="WIDTH: 8.5in" onUnload="parent.window.opener.location.reload(true);"> -->
	<body style="WIDTH: 8.5in" >
		<table style="width: 8.5in; class="NonPrintable">
			<tr>
				<td><input type="submit" value="Save"
					onclick="javascript:return onSave();" class="NonPrintable">
					<input type="submit" value="Save and Exit"
					onclick="javascript:return onSaveExit();" class="NonPrintable">
					<input type="button" value="Exit"
					onclick="javascript:window.close();" class="NonPrintable">
					<input type="submit" value="Save and Print" onClick="onClickPrint();"
					class="NonPrintable"> 
					
				</td> 
			</tr>
		
		</table>
		<div style="height: 10px; width: 100%" class="NonPrintable"></div>
		<table style="WIDTH: 8.5in" border="0">
			<tbody>
				<tr>
					<td width="100%"><b> <font size="4">Gynaecological
								Assessment<br> </font><%=clinicName%></b> <br><%=clinicAddress%><br><%=clinicCity%>, <%=clinicProvince%> <%=clinicPostal%></td>
				</tr>
			</tbody>
		</table>
		<br>
		<div style="padding-left: 3px; display: none;" id="div_intro"> 
		<p>
		Dear Dr. <%=props.getProperty("family_doctor_lname", "")%>, <br> 
		<br>Thank you for referring this patient to our clinic. Here are the results of our initial consultation. If you have any questions, please feel free to contact our office. We would be pleased to offer any additional information that you require.
		</p>
		</div>
		
		<table style="WIDTH: 8.5in">
			<tbody>
				<tr>
					<td colspan="2" align="left"><b>Basic Patient Information</b>
						<br>
						<hr noshade></td>
				</tr>
				<tr>
					<td colspan="2" align="left">
						Patient Name: &nbsp;&nbsp; 
						<input type="button" value="Patient" class="NonPrintable"  
							onclick="importPatient(document.forms[0].patient_lname,document.forms[0].patient_fname);">
						<input type="button"
							value="Age" class="NonPrintable" 
							onclick="importPatientAge(document.forms[0].bpi_age);">
					</td>
					
				</tr>
				<tr>
					<td align="left" width="470px">
					<input name="patient_lname" type="text" maxlength="15" 
						value="<%=props.getProperty("patient_lname", "")%>">, <input
						name="patient_fname" type="text" maxlength="15"
						value="<%=props.getProperty("patient_fname", "")%>">
					<%-- <span id="span_patient_age">
					<%=props.getProperty("bpi_age", "").length()>0?"("+props.getProperty("bpi_age", "")+" years old)":""%>
					</span> --%>
					<input id="bpi_age"
						maxlength="5" size="5" name="bpi_age"
						value=<%=props.getProperty("bpi_age", "")%>> years old
					</td>
					<td align="right">
						Appointment Date: <input tabindex="5" type="text" maxlength="15"
									name="appt_date" id="appt_date" size="10" readonly="readonly" 
									value=<%=props.getProperty("appt_date", "")%>>
									 <img
									src="../images/cal.gif" id="appt_date_call"
									class="NonPrintable">
					</td>
				</tr>
				<!-- <tr><td colspan="2">&nbsp;</td></tr> -->
			<%-- 	<tr>
					<td colspan="2" align="left">Age: <input id="bpi_age"
						maxlength="5" size="5" name="bpi_age"
						value=<%=props.getProperty("bpi_age", "")%>> 
						 &nbsp;&nbsp; <input type="button"
							value="Patient Age" class="NonPrintable" 
							onclick="importPatientAge(document.forms[0].bpi_age);">
						</td></tr>
						
						<!-- refering physician : start -->
					<tr><td colspan="2">&nbsp;</td></tr>
				<tr> --%>
					<td colspan="2" align="left" style="padding-top: 5px">		
			Referring Physician Name: &nbsp;&nbsp;
			<input type="button" value="Doctor" class="NonPrintable" 
				onclick="importDoctor(document.forms[0].family_doctor_lname,document.forms[0].family_doctor_fname);">
			</td></tr>
			
			<tr>
					<td colspan="2" align="left">
			<input name="family_doctor_lname" type="text" maxlength="15"
				value="<%=props.getProperty("family_doctor_lname", "")%>">,
			<input name="family_doctor_fname" type="text" maxlength="15"
				value="<%=props.getProperty("family_doctor_fname", "")%>">
				</td></tr>
				<!-- refering physician : end -->
				
				<tr>
					<td  align="left">
						<!-- <br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; -->G&nbsp;<input
						id="bpi_g" maxlength="5" size="5" name="bpi_g"
						value=<%=props.getProperty("bpi_g", "")%>>&nbsp;T&nbsp;<input
						id="bpi_t" maxlength="5" size="5" name="bpi_t"
						value=<%=props.getProperty("bpi_t", "")%>>&nbsp;P&nbsp;<input
						id="bpi_p" maxlength="5" size="5" name="bpi_p"
						value=<%=props.getProperty("bpi_p", "")%>>&nbsp;A&nbsp;<input
						id="bpi_a" maxlength="5" size="5" name="bpi_a"
						value=<%=props.getProperty("bpi_a", "")%>>&nbsp;L&nbsp;<input
						id="bpi_l" maxlength="5" size="5" name="bpi_l"
						value=<%=props.getProperty("bpi_l", "")%>><br> <br>Periods:<br>
						&nbsp;-length:&nbsp;&nbsp;&nbsp;&nbsp;<input id="bpi_minlength"
						maxlength="5" size="5" name="bpi_minlength"
						value=<%=props.getProperty("bpi_minlength", "")%>>-<input
						id="bpi_maxlength" maxlength="5" size="5" name="bpi_maxlength"
						value=<%=props.getProperty("bpi_maxlength", "")%>> days<br>-
						interval:&nbsp;&nbsp;<input id="bpi_mininterval" maxlength="5"
						size="5" name="bpi_mininterval"
						value=<%=props.getProperty("bpi_mininterval", "")%>>-<input
						id="bpi_maxinterval" maxlength="5" size="5" name="bpi_maxinterval"
						value=<%=props.getProperty("bpi_maxinterval", "")%>> days<br>-
						amounts: pads /&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input
						id="bpi_amountpads" maxlength="5" size="5" name="bpi_amountpads"
						value=<%=props.getProperty("bpi_amountpads", "")%>>hrs.</td>
					<td  align="right">Current Contraception Method: <br>
						<select id="bpi_current_contra_method"
						name="bpi_current_contra_method" type="text">
							<option  <%=getSelectedAttr(props, "bpi_current_contra_method", "-1")%> value="-1"></option>
							<option <%=getSelectedAttr(props, "bpi_current_contra_method", "BCP'S")%>>BCP'S</option>
							<option <%=getSelectedAttr(props, "bpi_current_contra_method", "Condoms")%>>Condoms</option>
							<option <%=getSelectedAttr(props, "bpi_current_contra_method", "Depo-Provera Injections")%>>Depo-Provera Injections</option>
							<option <%=getSelectedAttr(props, "bpi_current_contra_method", "Patch")%>>Patch</option>
							<option <%=getSelectedAttr(props, "bpi_current_contra_method", "FOAM")%>>FOAM</option>
							<option <%=getSelectedAttr(props, "bpi_current_contra_method", "IUD")%>>IUD</option>
							<option <%=getSelectedAttr(props, "bpi_current_contra_method", "No Birth Control Used")%>>No Birth Control Used</option>
							<option <%=getSelectedAttr(props, "bpi_current_contra_method", "Ring")%>>Ring</option>
							<option <%=getSelectedAttr(props, "bpi_current_contra_method", "Rhythm (Calendar) Method")%>>Rhythm (Calendar) Method</option>
							<option <%=getSelectedAttr(props, "bpi_current_contra_method", "Tubal Ligation")%>>Tubal Ligation</option>
							<option <%=getSelectedAttr(props, "bpi_current_contra_method", "Vasectomy")%>>Vasectomy</option>
							<option <%=getSelectedAttr(props, "bpi_current_contra_method", "Withdrawal")%>>Withdrawal</option>
					</select> <br> <br>LMP/PAP/Mamo:<br>
						<table>
							<tr>
								<td align="left">LMP:</td>
								<td>N<input id="bpi_lmp_n" type="checkbox" name="bpi_lmp_n"
									<%=props.getProperty("bpi_lmp_n", "")%> size="5"></td>
								<td>Abn<input id="bpi_lmp_abn" type="checkbox"
									name="bpi_lmp_abn" <%=props.getProperty("bpi_lmp_abn", "")%>>
								</td>
								<td><input tabindex="5" type="text" maxlength="15"
									name="bpi_date1_" id="bpi_date1_" size="10" readonly="readonly"
									value=<%=getMonthYearStr(props.getProperty("bpi_date1", ""))%>>
									
									<input tabindex="5" type="text" maxlength="15"
									name="bpi_date1" id="bpi_date1" size="10" readonly="readonly" 
									style="display: none;" onchange="fn_onchange_dt('bpi_date1');"
									value=<%=props.getProperty("bpi_date1", "")%>>
									 <img
									src="../images/cal.gif" id="bpi_date1_call"
									class="NonPrintable">  
									 <a href="#" title="Clear" onclick="document.getElementById('bpi_date1_').value='';"><img
									src="../images/delete.png" class="NonPrintable"></a>
									</td>
							</tr>
							<tr>
								<td>Last PAP:</td>
								<td>N<input id="bpi_lastpap_n" type="checkbox"
									name="bpi_lastpap_n"
									<%=props.getProperty("bpi_lastpap_n", "")%>>
								</td>
								<td>Abn<input id="bpi_lastpap_abn" type="checkbox"
									name="bpi_lastpap_abn"
									<%=props.getProperty("bpi_lastpap_abn", "")%>>
								</td>
								<td><input tabindex="5" type="text" maxlength="15"
									name="bpi_date2_" id="bpi_date2_" size="10" readonly="readonly"
									value=<%=getMonthYearStr(props.getProperty("bpi_date2", ""))%>> 
									
									<input tabindex="5" type="text" maxlength="15"
									name="bpi_date2" id="bpi_date2" size="10" readonly="readonly" 
									style="display: none;" onchange="fn_onchange_dt('bpi_date2');"
									value=<%=props.getProperty("bpi_date2", "")%>> 
									
									<img
									src="../images/cal.gif" id="bpi_date2_call"
									class="NonPrintable"> 
									 <a href="#" title="Clear" onclick="document.getElementById('bpi_date2_').value='';"><img
									src="../images/delete.png" class="NonPrintable"></a></td>
							</tr>
							<tr>
								<td>Last Mamo:</td>
								<td>N<input id="bpi_lastmemo_n" type="checkbox"
									name="bpi_lastmemo_n"
									<%=props.getProperty("bpi_lastmemo_n", "")%>>
								</td>
								<td>Abn<input id="bpi_lastmemo_abn" type="checkbox"
									name="bpi_lastmemo_abn"
									<%=props.getProperty("bpi_lastmemo_abn", "")%>>
								</td>
								<td><input tabindex="5" type="text" maxlength="15"
									name="bpi_date3_" id="bpi_date3_" size="10" readonly="readonly"
									value=<%=getMonthYearStr(props.getProperty("bpi_date3", ""))%>> 
									
									<input tabindex="5" type="text" maxlength="15"
									name="bpi_date3" id="bpi_date3" size="10" readonly="readonly" 
									style="display: none;" onchange="fn_onchange_dt('bpi_date3');"
									value=<%=props.getProperty("bpi_date3", "")%>>
									
									<img
									src="../images/cal.gif" id="bpi_date3_call"
									class="NonPrintable"> 
									<a href="#" title="Clear" onclick="document.getElementById('bpi_date3_').value='';"><img
									src="../images/delete.png" class="NonPrintable"></a></td>
							</tr>
						</table></td>
				</tr>
			</tbody>
		</table>
		<br>
		<table style="WIDTH: 8.5in" id="table_reason_for_referral">
			<tbody>
				<tr valign="top">
					<td
						style="BORDER-RIGHT-WIDTH: 0px; BORDER-TOP-WIDTH: 0px; BORDER-BOTTOM-WIDTH: 0px; BORDER-LEFT-WIDTH: 0px"
						colspan="3"><strong>Reason for Referral </strong>
						<hr noshade>
					</td>
				</tr>
				<tr valign="top" class="cls_tr_reason_for_referral">
					<td
						style="BORDER-RIGHT-WIDTH: 0px; BORDER-TOP-WIDTH: 0px; BORDER-BOTTOM-WIDTH: 0px; BORDER-LEFT-WIDTH: 0px">
						<input id="rfr_abn_pap" type="checkbox" name="rfr_abn_pap"
						<%=props.getProperty("rfr_abn_pap", "")%>
						onclick="showHide('rfr_abn_pap','AbnPAPDiv');">Abn PAP</td>
					<td
						style="BORDER-RIGHT-WIDTH: 0px; BORDER-TOP-WIDTH: 0px; BORDER-BOTTOM-WIDTH: 0px; BORDER-LEFT-WIDTH: 0px">
						<input id="rfr_infertility" type="checkbox" name="rfr_infertility"
						<%=props.getProperty("rfr_infertility", "")%>
						onclick="showHide('rfr_infertility','InfertilityDiv');">Infertility
					</td>
					<td
						style="BORDER-RIGHT-WIDTH: 0px; BORDER-TOP-WIDTH: 0px; BORDER-BOTTOM-WIDTH: 0px; BORDER-LEFT-WIDTH: 0px">
						<input id="rfr_menorrhagia" type="checkbox" name="rfr_menorrhagia"
						<%=props.getProperty("rfr_menorrhagia", "")%>
						onclick="showHide('rfr_menorrhagia','MenorrhagiaDiv');">Menorrhagia
					</td>
				</tr>
				<tr valign="top"  class="cls_tr_reason_for_referral">
					<td
						style="BORDER-RIGHT-WIDTH: 0px; BORDER-TOP-WIDTH: 0px; BORDER-BOTTOM-WIDTH: 0px; BORDER-LEFT-WIDTH: 0px">
						<input id="rfr_contraceptivehist" type="checkbox"
						name="rfr_contraceptivehist"
						<%=props.getProperty("rfr_contraceptivehist", "")%>
						onclick="showHide('rfr_contraceptivehist','ContraceptiveDiv');">Contraception</td>
					<td
						style="BORDER-RIGHT-WIDTH: 0px; BORDER-TOP-WIDTH: 0px; BORDER-BOTTOM-WIDTH: 0px; BORDER-LEFT-WIDTH: 0px">
						<input id="rfr_irregularperiods" type="checkbox"
						name="rfr_irregularperiods"
						<%=props.getProperty("rfr_irregularperiods", "")%>
						onclick="showHide('rfr_irregularperiods','IrregularDiv');">Irregular
						Periods</td>
					<td
						style="BORDER-RIGHT-WIDTH: 0px; BORDER-TOP-WIDTH: 0px; BORDER-BOTTOM-WIDTH: 0px; BORDER-LEFT-WIDTH: 0px">
						<input id="rfr_ovariancyst" type="checkbox" name="rfr_ovariancyst"
						<%=props.getProperty("rfr_ovariancyst", "")%>
						onclick="showHide('rfr_ovariancyst','OvarianDiv');">Ovarian
						Cyst</td>
				</tr>
				<tr valign="top"  class="cls_tr_reason_for_referral">
					<td
						style="BORDER-RIGHT-WIDTH: 0px; BORDER-TOP-WIDTH: 0px; BORDER-BOTTOM-WIDTH: 0px; BORDER-LEFT-WIDTH: 0px">
						<input id="rfr_fibroids" type="checkbox" name="rfr_fibroids"
						<%=props.getProperty("rfr_fibroids", "")%>
						onclick="showHide('rfr_fibroids','FibroidsDiv');">Fibroids</td>
					<td
						style="BORDER-RIGHT-WIDTH: 0px; BORDER-TOP-WIDTH: 0px; BORDER-BOTTOM-WIDTH: 0px; BORDER-LEFT-WIDTH: 0px">
						<input id="rfr_menopause" type="checkbox" name="rfr_menopause"
						<%=props.getProperty("rfr_menopause", "")%>
						onclick="showHide('rfr_menopause','MenopauseDiv');">Menopause</td>
					<td
						style="BORDER-RIGHT-WIDTH: 0px; BORDER-TOP-WIDTH: 0px; BORDER-BOTTOM-WIDTH: 0px; BORDER-LEFT-WIDTH: 0px">
						<input id="rfr_pelvicpain" type="checkbox" name="rfr_pelvicpain"
						<%=props.getProperty("rfr_pelvicpain", "")%>
						onclick="showHide('rfr_pelvicpain','PelvicPainDiv');">Pelvic
						Pain</td>
				</tr>
				<tr valign="top"  class="cls_tr_reason_for_referral">
					<td
						style="BORDER-RIGHT-WIDTH: 0px; BORDER-TOP-WIDTH: 0px; BORDER-BOTTOM-WIDTH: 0px; BORDER-LEFT-WIDTH: 0px"
						colspan="3"><input id="rfr_incontinence" type="checkbox" 
						name="rfr_incontinence"
						<%=props.getProperty("rfr_incontinence", "")%>
						onclick="showHide('rfr_incontinence','IncontinenceDiv');">Incontinence
					</td>
				</tr>
				
				<tr valign="top" style="display: none;" id="tr_div_reason_for_referral" >
					<td colspan="3">
						<div id="div_reason_for_referral">
						</div>
					</td>
				</tr>
				
				<tr valign="top">
					<td colspan="3"><br>
					</td>
				</tr>
			</tbody>
		</table>
		<table style="WIDTH: 8.5in">
			<tr valign="top">
					<td
						style="BORDER-RIGHT-WIDTH: 0px; BORDER-TOP-WIDTH: 0px; BORDER-BOTTOM-WIDTH: 0px; BORDER-LEFT-WIDTH: 0px">
						<b>Additional Notes</b>
						<hr noshade></td>
			</tr>
			<tr valign="top">
				<td
					style="BORDER-RIGHT-WIDTH: 0px; BORDER-TOP-WIDTH: 0px; BORDER-BOTTOM-WIDTH: 0px; BORDER-LEFT-WIDTH: 0px">
					<textarea style="WIDTH: 830px; HEIGHT: 104px; border: 1px solid #000000;"
						id="additional_notes" cols="80" rows="4" name="additional_notes"><%=props.getProperty("additional_notes", "")%></textarea>
				</td>
			</tr>
			<tr valign="top">
					<td>&nbsp;
					</td>
				</tr>
		</table>
		<table style="WIDTH: 8.5in">
			<tbody>
				<tr>
					<td colspan="2"><b>OBS History</b>&nbsp;&nbsp;
					<input type="checkbox" name="chk_obs_history_notes" id="chk_obs_history_notes"
					onclick="fn_remove_section_from_printout_(this, 'tr_obs_history_notes');">
					Notes
					<hr noshade></td>
				</tr>
				<tr>
					<td colspan="2">
						<table width="50%" border="0" bordercolor="black">
							<tr>
								<td width="25%">SVD: <input id="obs_svd" maxlength="5"
									size="5" name="obs_svd"
									value=<%=props.getProperty("obs_svd", "")%>></td>
								<td>CS: <input id="obs_cs" maxlength="5" size="5"
									name="obs_cs" value=<%=props.getProperty("obs_cs", "")%>>
								</td>
							</tr>
						</table></td>
				</tr>
				<tr>
					<td colspan="2">&nbsp;</td>
				</tr>
				<tr id="tr_obs_history_notes">
					<td colspan="2">Notes:<br> <textarea
							style="WIDTH: 830px; HEIGHT: 104px; border: 1px solid #000000;" id="obs_notes" rows="4"  
							cols="80" name="obs_notes"><%=props.getProperty("obs_notes", "")%></textarea>
					</td>
				</tr>
			</tbody>
		</table>
		<br>
		<table style="WIDTH: 8.5in" id="table_past_med_history">
			<tbody>
				<tr>
					<td colspan="4"><strong>Past Medical History</strong>
					&nbsp;&nbsp;
					<input type="checkbox" name="no_med_hist" 
					value="1" id="no_med_hist" 
					onclick="fn_remove_section_from_printout(this, 'tr_past_med_hist');"
					 <%=props.getProperty("no_med_hist", "").equals("1")?"checked":"" %>
					>No Medical History
					
					&nbsp;&nbsp;<input type="checkbox" name="chk_past_med_history_notes" id="chk_past_med_history_notes"
					onclick="fn_remove_section_from_printout_cls(this, 'cls_past_med_notes', 'no_med_hist');">
					Notes
					
						<hr noshade></td>
				</tr>
				<tr valign="top" id="tr_past_med_hist" class="cls_tr_past_med_history">
					<td width="25%"><input id="pmh_wt_loss" type="checkbox" name="pmh_wt_loss"
						<%=props.getProperty("pmh_wt_loss", "")%>>WT Loss</td>
					<td width="25%"><input id="pmh_tuberculosis" type="checkbox"
						name="pmh_tuberculosis"
						<%=props.getProperty("pmh_tuberculosis", "")%>>Tuberculosis</td>
					<td width="25%"><input id="pmh_urinary" type="checkbox" name="pmh_urinary"
						<%=props.getProperty("pmh_urinary", "")%>>Urinary</td>
					<td width="25%"><input id="pmh_diabetes" type="checkbox"
						name="pmh_diabetes" <%=props.getProperty("pmh_diabetes", "")%>>Diabetes</td>
				</tr>
				<tr valign="top" id="tr_past_med_hist"  class="cls_tr_past_med_history"> 
					<td><input id="pmh_headaches" type="checkbox"
						name="pmh_headaches" <%=props.getProperty("pmh_headaches", "")%>>Headaches</td>
					<td><input id="pmh_jaundice_hep" type="checkbox"
						name="pmh_jaundice_hep"
						<%=props.getProperty("pmh_jaundice_hep", "")%>>Jaundice/Hep</td>
					<td><input id="pmh_anemia_blood" type="checkbox"
						name="pmh_anemia_blood"
						<%=props.getProperty("pmh_anemia_blood", "")%>>Anemia/Blood</td>
					<td><input id="pmh_cancer" type="checkbox" name="pmh_cancer"
						<%=props.getProperty("pmh_cancer", "")%>>Cancer</td>
				</tr>
				<tr valign="top" id="tr_past_med_hist" class="cls_tr_past_med_history">
					<td><input id="pmh_heart_disease" type="checkbox"
						name="pmh_heart_disease"
						<%=props.getProperty("pmh_heart_disease", "")%>>Heart
						Disease</td>
					<td><input id="pmh_gall_bladder" type="checkbox"
						name="pmh_gall_bladder"
						<%=props.getProperty("pmh_gall_bladder", "")%>>Gall
						Bladder</td>
					<td><input id="pmh_blood_trans" type="checkbox"
						name="pmh_blood_trans"
						<%=props.getProperty("pmh_blood_trans", "")%>>Blood Trans</td>
					<td><input id="pmh_epilepsy" type="checkbox"
						name="pmh_epilepsy" <%=props.getProperty("pmh_epilepsy", "")%>>Epilepsy</td>
				</tr>
				<tr valign="top" id="tr_past_med_hist" class="cls_tr_past_med_history">
					<td><input id="pmh_hypertension" type="checkbox"
						name="pmh_hypertension"
						<%=props.getProperty("pmh_hypertension", "")%>>Hypertension</td>
					<td><input id="pmh_hernia_ulser" type="checkbox"
						name="pmh_hernia_ulser"
						<%=props.getProperty("pmh_hernia_ulser", "")%>>Hernia/Ulser</td>
					<td><input id="pmh_varicose" type="checkbox"
						name="pmh_varicose" <%=props.getProperty("pmh_varicose", "")%>>Varicose</td>
					<td><input id="pmh_arthritis" type="checkbox"
						name="pmh_arthritis" <%=props.getProperty("pmh_arthritis", "")%>>Arthritis</td>
				</tr>
				<tr valign="top" id="tr_past_med_hist" class="cls_tr_past_med_history">
					<td><input id="pmh_respiratory" type="checkbox"
						name="pmh_respiratory"
						<%=props.getProperty("pmh_respiratory", "")%>>Respiratory</td>
					<td><input id="pmh_bowel_disorder" type="checkbox"
						name="pmh_bowel_disorder"
						<%=props.getProperty("pmh_bowel_disorder", "")%>>Bowel
						Disorder</td>
					<td><input id="pmh_phlebitis" type="checkbox"
						name="pmh_phlebitis" <%=props.getProperty("pmh_phlebitis", "")%>>DVT</td>
					<td><input id="pmh_osteoporosis" type="checkbox"
						name="pmh_osteoporosis"
						<%=props.getProperty("pmh_osteoporosis", "")%>>Osteoporosis</td>
				</tr>
				<tr valign="top" id="tr_past_med_hist" class="cls_tr_past_med_history">
					<td><input id="pmh_breast_dis" type="checkbox"
						name="pmh_breast_dis" <%=props.getProperty("pmh_breast_dis", "")%>>Breast
						Dis</td>
					<td><input id="pmh_kidney" type="checkbox" name="pmh_kidney"
						<%=props.getProperty("pmh_kidney", "")%>>Kidney</td>
					<td><input id="pmh_thyroid" type="checkbox" name="pmh_thyroid"
						<%=props.getProperty("pmh_thyroid", "")%>>Thyroid</td>
					<td><input id="pmh_std" type="checkbox" name="pmh_std"
						<%=props.getProperty("pmh_std", "")%>>STI (specify)</td>
				</tr>
				
				<tr valign="top" style="display: none;" id="tr_div_past_med_history" >
					<td colspan="3">
						<div id="div_past_med_history">
						</div>
					</td>
				</tr>
				
				<tr valign="top" id="tr_past_med_hist" class="cls_past_med_notes">
					<td colspan="4"><br>Notes:<br> <textarea
							style="WIDTH: 800px; HEIGHT: 104px; border: 1px solid #000000;" id="pmh_notes" rows="4"
							cols="80" name="pmh_notes"><%=props.getProperty("pmh_notes", "")%></textarea>
					</td>
				</tr>
				
			</tbody>
		</table>
		<table style="WIDTH: 8.5in">
			<tbody>
				<tr>
					<td colspan="2"><br> <b>Family Medical History</b>
					
					&nbsp;&nbsp;<input type="checkbox" name="chk_family_med_hist_notes" id="chk_family_med_hist_notes"
					onclick="fn_remove_section_from_printout_(this, 'tr_family_med_hist_notes');">
					Notes
					
						<hr noshade></td>
				</tr>
				<tr valign="top">
					<td
						style="BORDER-RIGHT-WIDTH: 0px; BORDER-TOP-WIDTH: 0px; BORDER-BOTTOM-WIDTH: 0px; BORDER-LEFT-WIDTH: 0px">
						<table width="50%" align="left">
							<tr valign="top">
								<td>Cancer:</td>
								<td>
								<input id="fmh_brest" type="checkbox"
									name="fmh_brest" <%=props.getProperty("fmh_brest", "")%>>
									Breast,
								
								<input id="fmh_gynaecological" type="checkbox"
									name="fmh_gynaecological"
									<%=props.getProperty("fmh_gynaecological", "")%>> Gynaecological,
									
								<input id="fmh_bowel" type="checkbox"
									name="fmh_bowel" <%=props.getProperty("fmh_bowel", "")%>>
									Bowel
									
								</td>
							</tr>
							<tr>
								<td>&nbsp;</td>
								<td>
									<input id="fmh_osteoporosis"
									type="checkbox" name="fmh_osteoporosis"
									<%=props.getProperty("fmh_osteoporosis", "")%>> Osteoporosis
								</td>
							</tr>
						</table>
					</td>

				</tr>
				<tr valign="top" id="tr_family_med_hist_notes">
					<td colspan="2">Notes:<br> <textarea
							style="WIDTH: 810px; HEIGHT: 104px; border: 1px solid #000000;" id="fmh_notes" rows="4"
							cols="80" name="fmh_notes"><%=props.getProperty("fmh_notes", "").trim()%></textarea>
					</td>
				</tr>
			</tbody>
		</table>
		<br>
		<table style="WIDTH: 8.5in">
			<tbody>
				<tr valign="top">
					<td colspan="2"><br> <strong>Past Surgical
							History</strong>
						<hr noshade>
					</td>
				</tr>
				<tr valign="top">
					<td width="50%">Year</td>
					<td>Operation/Illness</td>
				</tr>
				<tr valign="top">
					<td><input id="year1" name="year1" type="text" maxlength="50"
						size="50" value="<%=props.getProperty("year1", "")%>">
					</td>
					<td><input id="operation1" name="operation1" type="text"
						maxlength="50" size="50"
						value="<%=props.getProperty("operation1", "")%>">
					</td>
				</tr>
				<tr valign="top">
					<td><input id="year2" name="year2" type="text" maxlength="50"
						size="50" value="<%=props.getProperty("year2", "")%>">
					</td>
					<td><input id="operation2" name="operation2" type="text"
						maxlength="50" size="50"
						value="<%=props.getProperty("operation2", "")%>">
					</td>
				</tr>
				<tr valign="top">
					<td><input id="year3" name="year3" type="text" maxlength="50"
						size="50" value="<%=props.getProperty("year3", "")%>">
					</td>
					<td><input id="operation3" name="operation3" type="text"
						maxlength="50" size="50"
						value="<%=props.getProperty("operation3", "")%>">
					</td>
				</tr>
				<tr valign="top">
					<td><input id="year4" name="year4" type="text" maxlength="50"
						size="50" value="<%=props.getProperty("year4", "")%>">
					</td>
					<td><input id="operation4" name="operation4" type="text"
						maxlength="50" size="50"
						value="<%=props.getProperty("operation4", "")%>">
					</td>
				</tr>
			</tbody>
		</table>
		<table style="WIDTH: 8.5in">
			<tbody>
				<tr valign="top">
					<td
						style="BORDER-RIGHT-WIDTH: 0px; BORDER-TOP-WIDTH: 0px; BORDER-BOTTOM-WIDTH: 0px; BORDER-LEFT-WIDTH: 0px">
						<br> <strong>Current Medications&nbsp;&nbsp;
						
						<input type="checkbox" name="no_current_medications" id="no_current_medications"
						onclick="fn_remove_section_from_printout(this, 'tr_current_medications');">No meds
						
						&nbsp;&nbsp;<input type="button" value="Medication" class="NonPrintable" 
						onclick="importFromEnct('OtherMeds',document.forms[0].cm_current_medication);"></strong>
						<hr noshade>
					</td>
				</tr>
				<tr valign="top" id="tr_current_medications">
					<td
						style="BORDER-RIGHT-WIDTH: 0px; BORDER-TOP-WIDTH: 0px; BORDER-BOTTOM-WIDTH: 0px; BORDER-LEFT-WIDTH: 0px">
						<textarea style="WIDTH: 830px; HEIGHT: 104px; border: 1px solid #000000;"
							id="cm_current_medication" cols="80" rows="4"
							name="cm_current_medication"><%=props.getProperty("cm_current_medication", "")%></textarea>
					</td>
				</tr>
				<tr valign="top">
					<td
						style="BORDER-RIGHT-WIDTH: 0px; BORDER-TOP-WIDTH: 0px; BORDER-BOTTOM-WIDTH: 0px; BORDER-LEFT-WIDTH: 0px">
						<br> <b>Habits</b>
						<hr noshade></td>
				</tr>
				<tr valign="top">
					<td
						style="BORDER-RIGHT-WIDTH: 0px; BORDER-TOP-WIDTH: 0px; BORDER-BOTTOM-WIDTH: 0px; BORDER-LEFT-WIDTH: 0px">
						<table style="WIDTH: 8.5in" width="1005" height="26">
							<tbody>
								<tr valign="top">
									<td><input id="habits_cigarettes" type="checkbox"
										name="habits_cigarettes"
										<%=props.getProperty("habits_cigarettes", "")%>>Cigarettes:</td>
									<td><input id="habits_cigperday" name="habits_cigperday"
										value=<%=props.getProperty("habits_cigperday", "")%>>/
										day:</td>
									<td><input id="habits_alcohol" type="checkbox"
										name="habits_alcohol"
										<%=props.getProperty("habits_alcohol", "")%>>Alcohol:</td>
									<td><input id="habits_alcoholperweek"
										name="habits_alcoholperweek"
										value=<%=props.getProperty("habits_alcoholperweek", "")%>>/
										week</td>
									<td><input id="habits_streetdrugs" type="checkbox"
										name="habits_streetdrugs"
										<%=props.getProperty("habits_streetdrugs", "")%>>Street
										Drugs</td>
								</tr>
							</tbody>
						</table>
					</td>
				</tr>
				<tr valign="top">
					<td
						style="BORDER-RIGHT-WIDTH: 0px; BORDER-TOP-WIDTH: 0px; BORDER-BOTTOM-WIDTH: 0px; BORDER-LEFT-WIDTH: 0px">Notes:</td>
				</tr>
				<tr valign="top">
					<td
						style="BORDER-RIGHT-WIDTH: 0px; BORDER-TOP-WIDTH: 0px; BORDER-BOTTOM-WIDTH: 0px; BORDER-LEFT-WIDTH: 0px">
						<textarea style="WIDTH: 830px; HEIGHT: 104px; border: 1px solid #000000;" id="habits_notes"
							rows="4" cols="80" name="habits_notes"><%=props.getProperty("habits_notes", "")%></textarea>
					</td>
				</tr>
				<tr valign="top">
					<td
						style="BORDER-RIGHT-WIDTH: 0px; BORDER-TOP-WIDTH: 0px; BORDER-BOTTOM-WIDTH: 0px; BORDER-LEFT-WIDTH: 0px">
						<br> <strong>Allergies&nbsp;&nbsp;
						
						<input type="checkbox" name="no_allergies" id="no_allergies"
						<%=props.getProperty("no_allergies", "").equals("1")?"checked":"" %>
						onclick="fn_remove_section_from_printout(this, 'tr_allergies');">NKDA
						
						&nbsp;&nbsp;<input type="button" value="Allergies" class="NonPrintable" 
				onclick="importFromEnct('Allergies',document.forms[0].allergies);"></strong>
						<hr noshade>
					</td>
				</tr>
				<tr valign="top" id="tr_allergies">
					<td
						style="BORDER-RIGHT-WIDTH: 0px; BORDER-TOP-WIDTH: 0px; BORDER-BOTTOM-WIDTH: 0px; BORDER-LEFT-WIDTH: 0px">
						<textarea style="WIDTH: 830px; HEIGHT: 104px; border: 1px solid #000000;" id="allergies"
							cols="80" name="allergies"><%=props.getProperty("allergies", "")%></textarea>
					</td>
				</tr>
				
			</tbody>
		</table>
		<table id="AbnPAPDiv" <%=abnPAPDivStyle%> class="nopagebreak">
			<tr valign="top">
				<td
					style="BORDER-RIGHT-WIDTH: 0px; BORDER-TOP-WIDTH: 0px; BORDER-BOTTOM-WIDTH: 0px; BORDER-LEFT-WIDTH: 0px"
					colspan="3"><strong>Abnormal PAP </strong>
					<hr noshade>
				</td>
			</tr>
			<tr valign="top">
				<td
					style="BORDER-RIGHT-WIDTH: 0px; BORDER-TOP-WIDTH: 0px; BORDER-BOTTOM-WIDTH: 0px; BORDER-LEFT-WIDTH: 0px">
					<input id="abpap_inflam" type="checkbox" name="abpap_inflam"
					<%=props.getProperty("abpap_inflam", "")%>>Inflam</td>
				<td
					style="BORDER-RIGHT-WIDTH: 0px; BORDER-TOP-WIDTH: 0px; BORDER-BOTTOM-WIDTH: 0px; BORDER-LEFT-WIDTH: 0px">
					<input id="abpap_lgsil" type="checkbox" name="abpap_lgsil"
					<%=props.getProperty("abpap_lgsil", "")%>>LGSIL</td>
				<td
					style="BORDER-RIGHT-WIDTH: 0px; BORDER-TOP-WIDTH: 0px; BORDER-BOTTOM-WIDTH: 0px; BORDER-LEFT-WIDTH: 0px">
					<table width="100%">
						<tr valign="top">
							<td width="20%">Previous Colpo:</td>
							<td width="10%">Y<input id="abpap_previouscolpo_y"
								type="checkbox" name="abpap_previouscolpo_y"
								<%=props.getProperty("abpap_previouscolpo_y", "")%>>
							</td>
							<td width="20%">N<input id="abpap_previouscolpo_n"
								type="checkbox" name="abpap_previouscolpo_n"
								<%=props.getProperty("abpap_previouscolpo_n", "")%>>
							</td>
						</tr>
					</table>
				</td>
			</tr>
			<tr valign="top">
				<td
					style="BORDER-RIGHT-WIDTH: 0px; BORDER-TOP-WIDTH: 0px; BORDER-BOTTOM-WIDTH: 0px; BORDER-LEFT-WIDTH: 0px">
					<input id="abpap_ascus" type="checkbox" name="abpap_ascus"
					<%=props.getProperty("abpap_ascus", "")%>>ASCUS</td>
				<td
					style="BORDER-RIGHT-WIDTH: 0px; BORDER-TOP-WIDTH: 0px; BORDER-BOTTOM-WIDTH: 0px; BORDER-LEFT-WIDTH: 0px">
					<input id="abpap_hgsil" type="checkbox" name="abpap_hgsil"
					<%=props.getProperty("abpap_hgsil", "")%>>HGSIL</td>
				<td
					style="BORDER-RIGHT-WIDTH: 0px; BORDER-TOP-WIDTH: 0px; BORDER-BOTTOM-WIDTH: 0px; BORDER-LEFT-WIDTH: 0px">
					<table width="100%">
						<tr valign="top">
							<td width="20%">Previous Tx:</td>
							<td width="10%">Y<input id="abpap_previoustx_y"
								type="checkbox" name="abpap_previoustx_y"
								<%=props.getProperty("abpap_previoustx_y", "")%>>
							</td>
							<td width="20%">N<input id="abpap_previoustx_n"
								type="checkbox" name="abpap_previoustx_n"
								<%=props.getProperty("abpap_previoustx_n", "")%>>
							</td>
						</tr>
					</table></td>
			</tr>
			<tr valign="top">
				<td colspan="3"><br>
				</td>
			</tr>
		</table>
		<table id="ContraceptiveDiv" <%=contraceptiveDivStyle%> class="nopagebreak">
			<tr valign="top">
				<td
					style="BORDER-RIGHT-WIDTH: 0px; BORDER-TOP-WIDTH: 0px; BORDER-BOTTOM-WIDTH: 0px; BORDER-LEFT-WIDTH: 0px"
					colspan="3"><strong>Past Contraceptive History </strong>
					<hr noshade>
				</td>
			</tr>
			<tr valign="top">
				<td
					style="BORDER-RIGHT-WIDTH: 0px; BORDER-TOP-WIDTH: 0px; BORDER-BOTTOM-WIDTH: 0px; BORDER-LEFT-WIDTH: 0px">
					<input id="pch_bcp" type="checkbox" name="pch_bcp"
					<%=props.getProperty("pch_bcp", "")%>>BCP's</td>
				<td
					style="BORDER-RIGHT-WIDTH: 0px; BORDER-TOP-WIDTH: 0px; BORDER-BOTTOM-WIDTH: 0px; BORDER-LEFT-WIDTH: 0px">
					<input id="pch_nuvo_ring" type="checkbox" name="pch_nuvo_ring"
					<%=props.getProperty("pch_nuvo_ring", "")%>>Nuvo-Ring</td>
				<td
					style="BORDER-RIGHT-WIDTH: 0px; BORDER-TOP-WIDTH: 0px; BORDER-BOTTOM-WIDTH: 0px; BORDER-LEFT-WIDTH: 0px">
					<input id="pch_IUD" type="checkbox" name="pch_IUD"
					<%=props.getProperty("pch_IUD", "")%>>IUD</td>
			</tr>
			<tr valign="top">
				<td
					style="BORDER-RIGHT-WIDTH: 0px; BORDER-TOP-WIDTH: 0px; BORDER-BOTTOM-WIDTH: 0px; BORDER-LEFT-WIDTH: 0px">
					<input id="pch_condoms" type="checkbox" name="pch_condoms"
					<%=props.getProperty("pch_condoms", "")%>>Condoms</td>
				<td
					style="BORDER-RIGHT-WIDTH: 0px; BORDER-TOP-WIDTH: 0px; BORDER-BOTTOM-WIDTH: 0px; BORDER-LEFT-WIDTH: 0px">
					<input id="pch_rhythmmethod" type="checkbox"
					name="pch_rhythmmethod"
					<%=props.getProperty("pch_rhythmmethod", "")%>>Rhythm
					Method</td>
				<td
					style="BORDER-RIGHT-WIDTH: 0px; BORDER-TOP-WIDTH: 0px; BORDER-BOTTOM-WIDTH: 0px; BORDER-LEFT-WIDTH: 0px">
					<input id="pch_vasectomy" type="checkbox" name="pch_vasectomy"
					<%=props.getProperty("pch_vasectomy", "")%>>Vasectomy</td>
			</tr>
			<tr valign="top">
				<td
					style="BORDER-RIGHT-WIDTH: 0px; BORDER-TOP-WIDTH: 0px; BORDER-BOTTOM-WIDTH: 0px; BORDER-LEFT-WIDTH: 0px">
					<input id="pch_depo_proverainj" type="checkbox"
					name="pch_depo_proverainj"
					<%=props.getProperty("pch_depo_proverainj", "")%>>Depo-Provera
					Inj</td>
				<td
					style="BORDER-RIGHT-WIDTH: 0px; BORDER-TOP-WIDTH: 0px; BORDER-BOTTOM-WIDTH: 0px; BORDER-LEFT-WIDTH: 0px">
					<input id="pch_tuballigation" type="checkbox"
					name="pch_tuballigation"
					<%=props.getProperty("pch_tuballigation", "")%>>Tubal
					Ligation</td>
				<td
					style="BORDER-RIGHT-WIDTH: 0px; BORDER-TOP-WIDTH: 0px; BORDER-BOTTOM-WIDTH: 0px; BORDER-LEFT-WIDTH: 0px">
					<input id="pch_withdrawal" type="checkbox" name="pch_withdrawal"
					<%=props.getProperty("pch_withdrawal", "")%>>Withdrawal</td>
			</tr>
			<tr valign="top">
				<td
					style="BORDER-RIGHT-WIDTH: 0px; BORDER-TOP-WIDTH: 0px; BORDER-BOTTOM-WIDTH: 0px; BORDER-LEFT-WIDTH: 0px">
					<input id="pch_evrapatch" type="checkbox" name="pch_evrapatch"
					<%=props.getProperty("pch_evrapatch", "")%>>Evra Patch</td>
				<td
					style="BORDER-RIGHT-WIDTH: 0px; BORDER-TOP-WIDTH: 0px; BORDER-BOTTOM-WIDTH: 0px; BORDER-LEFT-WIDTH: 0px">
					<input id="pch_foam" type="checkbox" name="pch_foam"
					<%=props.getProperty("pch_foam", "")%>>FOAM</td>
				<td
					style="BORDER-RIGHT-WIDTH: 0px; BORDER-TOP-WIDTH: 0px; BORDER-BOTTOM-WIDTH: 0px; BORDER-LEFT-WIDTH: 0px">
					<input id="pch_nobirthcontrolused" type="checkbox"
					name="pch_nobirthcontrolused"
					<%=props.getProperty("pch_nobirthcontrolused", "")%>>No
					Birth Control Used</td>
			</tr>
			<tr valign="top">
				<td
					style="BORDER-RIGHT-WIDTH: 0px; BORDER-TOP-WIDTH: 0px; BORDER-BOTTOM-WIDTH: 0px; BORDER-LEFT-WIDTH: 0px"
					colspan="3">Notes:</td>
			</tr>
			<tr valign="top">
				<td
					style="BORDER-RIGHT-WIDTH: 0px; BORDER-TOP-WIDTH: 0px; BORDER-BOTTOM-WIDTH: 0px; BORDER-LEFT-WIDTH: 0px"
					colspan="3"><textarea style="WIDTH: 830px; HEIGHT: 104px; border: 1px solid #000000;"
						cols="80" rows="4" id="pch_notes" name="pch_notes"><%=props.getProperty("pch_notes", "")%></textarea>
				</td>
			</tr>
			</tbody>
		</table>
		<table id="FibroidsDiv" <%=fibroidsDivStyle%> class="nopagebreak">
			<tbody>
				<tr valign="top">
					<td colspan="2"><br> <strong>Fibroids </strong>
						<hr noshade>
					</td>
				</tr>
				<tr valign="top">
					<td>-x <input id="fibro_year" name="fibro_years"
						value=<%=props.getProperty("fibro_years", "")%>> years <br>
						<table>
							<tr>
								<td>-Menorrhagia</td>
								<td>Y <input id="fibro_menorrhagia_y" type="checkbox"
									name="fibro_menorrhagia_y"
									<%=props.getProperty("fibro_menorrhagia_y", "")%>>
								</td>
								<td>N <input id="fibro_menorrhagia_n" type="checkbox"
									name="fibro_menorrhagia_n"
									<%=props.getProperty("fibro_menorrhagia_n", "")%>>
								</td>
							</tr>
							<tr>
								<td>- Pelvic Pressure</td>
								<td>Y <input id="fibro_pelvicpressure_y" type="checkbox"
									name="fibro_pelvicpressure_y"
									<%=props.getProperty("fibro_pelvicpressure_y", "")%>></td>
								<td>N <input id="fibro_pelvicpressure_n" type="checkbox"
									name="fibro_pelvicpressure_n"
									<%=props.getProperty("fibro_pelvicpressure_n", "")%>></td>

							</tr>
							<tr>
								<td>- Pelvic Pain</td>
								<td>Y <input id="fibro_pelvicpain_y" type="checkbox"
									name="fibro_pelvicpain_y"
									<%=props.getProperty("fibro_pelvicpain_y", "")%>>
								</td>
								<td>N <input id="fibro_pelvicpain_n" type="checkbox"
									name="fibro_pelvicpain_n"
									<%=props.getProperty("fibro_pelvicpain_n", "")%>>
								</td>
							</tr>
						</table>
					</td>
					<td>-Ultrasound Findings:<br>

						<table width="100%">
							<tr valign="top">
								<td width="50">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input
									style="WIDTH: 78px; HEIGHT: 22px" id="ultrasound_fibroids"
									size="10" name="ultrasound_fibroids"
									value=<%=props.getProperty("ultrasound_fibroids", "")%>>fibroids<br>
								</td>
							</tr>
							<tr>
								<td width="50">size &nbsp;&nbsp;<input
									style="WIDTH: 78px; HEIGHT: 22px" id="ultrasound_size"
									size="10" name="ultrasound_size"
									value=<%=props.getProperty("ultrasound_size", "")%>></td>
								<td width="50">-<input style="WIDTH: 78px; HEIGHT: 22px"
									id="ultrasound_cm" size="10" name="ultrasound_cm"
									value=<%=props.getProperty("ultrasound_cm", "")%>>cm</td>
							</tr>
						</table></td>
				</tr>
				<tr valign="top">
					<td colspan="2"><BR>
					</td>
				</tr>
		</table>
		<table id="IncontinenceDiv" <%=incontinenceDivStyle%> class="nopagebreak">
			<tr valign="top">
				<td colspan="2"><strong>Incontinence </strong>
					<hr>
				</td>
			</tr>
			<tr valign="top">
				<td>-x <input id="incontinence_years" name="incontinence_years"
					value=<%=props.getProperty("incontinence_years", "")%>>

					years <br>
					<table>
						<tr>
							<td>-Frequency</td>
							<td>Y <input id="incontinence_frequency_y" type="checkbox"
								name="incontinence_frequency_y"
								<%=props.getProperty("incontinence_frequency_y", "")%>>
							</td>
							<td>N <input id="incontinence_frequency_n" type="checkbox"
								name="incontinence_frequency_n"
								<%=props.getProperty("incontinence_frequency_n", "")%>>
							</td>
						</tr>
						<tr>
							<td>- Urgency</td>
							<td>Y <input id="incontinence_urgency_y" type="checkbox"
								name="incontinence_urgency_y"
								<%=props.getProperty("incontinence_urgency_y", "")%>></td>
							<td>N <input id="incontinence_urgency_n" type="checkbox"
								name="incontinence_urgency_n"
								<%=props.getProperty("incontinence_urgency_n", "")%>></td>
						</tr>
					</table></td>
				<td>
					<table>
						<tr>
							<td>- Nocturia</td>
							<td>Y <input id="incontinenc_nocturia_y" type="checkbox"
								name="incontinenc_nocturia_y"
								<%=props.getProperty("incontinenc_nocturia_y", "")%>></td>
							<td>N <input id="incontinenc_nocturia_n" type="checkbox"
								name="incontinenc_nocturia_n"
								<%=props.getProperty("incontinenc_nocturia_n", "")%>></td>
						</tr>
						<tr>
							<td>- Dysuria</td>
							<td>Y <input id="incontinenc_dysuria_y" type="checkbox"
								name="incontinenc_dysuria_y"
								<%=props.getProperty("incontinenc_dysuria_y", "")%>></td>
							<td>N <input id="incontinenc_dysuria_n" type="checkbox"
								name="incontinenc_dysuria_n"
								<%=props.getProperty("incontinenc_dysuria_n", "")%>></td>
						<tr>
							<td>- SUI</td>
							<td>Y <input id="incontinenc_sui_y" type="checkbox"
								name="incontinenc_sui_y"
								<%=props.getProperty("incontinenc_sui_y", "")%>>
							</td>
							<td>N <input id="incontinenc_sui_n" type="checkbox"
								name="incontinenc_sui_n"
								<%=props.getProperty("incontinenc_sui_n", "")%>>
							</td>
					</table></td>
			</tr>
			<tr valign="top">
				<td colspan="2"><BR>
				</td>
			</tr>
		</table>
		<table id="InfertilityDiv" <%=infertilityDivStyle%> class="nopagebreak">
			<tr valign="top">
				<td colspan="2"><strong>Infertility </strong>
					<hr noshade>
				</td>
			</tr>
			<tr valign="top">
				<td>- 1&deg; or 2&deg; x <input id="infertility_years"
					name="infertility_years"
					value=<%=props.getProperty("infertility_years", "")%>>
					years <br>
					<table>
						<tr>
							<td>- Sperm analysis</td>
							<td>Y <input id="infertility_sperm_analysis_y"
								type="checkbox" name="infertility_sperm_analysis_y"
								<%=props.getProperty("infertility_sperm_analysis_y", "")%>>
							</td>
							<td>N <input id="infertility_sperm_analysis_n"
								type="checkbox" name="infertility_sperm_analysis_n"
								<%=props.getProperty("infertility_sperm_analysis_n", "")%>>
							</td>

						</tr>
						<tr>
							<td>- Partner has children</td>
							<td>Y <input id="infertility_partnerhas_children_y"
								type="checkbox" name="infertility_partnerhas_children_y"
								<%=props.getProperty(
						"infertility_partnerhas_children_y", "")%>>
							</td>

							<td>N <input id="infertility_partnerhas_children_n"
								type="checkbox" name="infertility_partnerhas_children_n"
								<%=props.getProperty(
						"infertility_partnerhas_children_n", "")%>>
							</td>
						</tr>
					</table></td>
				<td>- STD Y &nbsp;<input id="infertility_std_y" type="checkbox"
					name="infertility_std_y"
					<%=props.getProperty("infertility_std_y", "")%>> N
					&nbsp;&nbsp;<input id="infertility_std_n" type="checkbox"
					name="infertility_std_n"
					<%=props.getProperty("infertility_std_n", "")%>> <br>-
					IUD Y &nbsp;<input id="infertility_iud_y" type="checkbox"
					name="infertility_iud_y"
					<%=props.getProperty("infertility_iud_y", "")%>> N
					&nbsp;&nbsp;<input id="infertility_iud_n" type="checkbox"
					name="infertility_iud_n"
					<%=props.getProperty("infertility_iud_n", "")%>> <br>-
					PID Y &nbsp;&nbsp;<input id="infertility_pid_y" type="checkbox"
					name="infertility_pid_y"
					<%=props.getProperty("infertility_pid_y", "")%>> N
					&nbsp;&nbsp;<input id="infertility_pid_n" type="checkbox"
					name="infertility_pid_n"
					<%=props.getProperty("infertility_pid_n", "")%>> <br>
				</td>
			</tr>
			<tr valign="top">
				<td colspan="2"><BR>
				</td>
			</tr>
		</table>
		<table id="IrregularDiv" <%=irregularDivStyle%> class="nopagebreak">
			<tr valign="top">
				<td colspan="2"><strong>Irregular Periods </strong>
					<hr noshade>
				</td>
			</tr>
			<tr valign="top">
				<td>
					<table>
						<tr>
							<td>- Hirsutism</td>
							<td>Y <input id="irregularperiods_hirsutism_y"
								type="checkbox" name="irregularperiods_hirsutism_y"
								<%=props.getProperty("irregularperiods_hirsutism_y", "")%>>
							</td>
							<td>N <input id="irregularperiods_hirsutism_n"
								type="checkbox" name="irregularperiods_hirsutism_n"
								<%=props.getProperty("irregularperiods_hirsutism_n", "")%>>
							</td>
						</tr>
						<tr>
							<td>- Acnea</td>
							<td>Y <input id="irregularperiods_acnea_y" type="checkbox"
								name="irregularperiods_acnea_y"
								<%=props.getProperty("irregularperiods_acnea_y", "")%>>
							</td>
							<td>N <input id="irregularperiods_acnea_n" type="checkbox"
								name="irregularperiods_acnea_n"
								<%=props.getProperty("irregularperiods_acnea_n", "")%>>
							</td>
						</tr>
					</table> <br>- Wt Gain: <input id="irregularperiods_wtgain_lbs"
					name="irregularperiods_wtgain_lbs"
					value=<%=props.getProperty("irregularperiods_wtgain_lbs", "")%>>lbs
					in <input id="irregularperiods_wtgain_months"
					name="irregularperiods_wtgain_months"
					value=<%=props.getProperty("irregularperiods_wtgain_months",
						"")%>>
					months <br></td>
				<td>Amenorrhea: <input id="irregularperiods_amenorrhea"
					name="irregularperiods_amenorrhea"
					value=<%=props.getProperty("irregularperiods_amenorrhea", "")%>>
					mths<br>
					<table>
						<tr>
							<td>- Extreme exercise:</td>
							<td>Y <input id="irregularperiods_extremeexercise_y"
								type="checkbox" name="irregularperiods_extremeexercise_y"
								<%=props.getProperty(
						"irregularperiods_extremeexercise_y", "")%>>
							</td>

							<td>N <input id="irregularperiods_extremeexercise_n"
								type="checkbox" name="irregularperiods_extremeexercise_n"
								<%=props.getProperty(
						"irregularperiods_extremeexercise_n", "")%>>
							</td>
						</tr>
						<tr>
							<td>- Galactorrhea</td>

							<td>Y <input id="irregularperiods_galactorrhea_y"
								type="checkbox" name="irregularperiods_galactorrhea_y"
								<%=props.getProperty("irregularperiods_galactorrhea_y",
						"")%>>
							</td>

							<td>N <input id="irregularperiods_galactorrhea_n"
								type="checkbox" name="irregularperiods_galactorrhea_n"
								<%=props.getProperty("irregularperiods_galactorrhea_n",
						"")%>>
							</td>
						</tr>

					</table></td>
			</tr>
			<tr valign="top">
				<td colspan="2"><BR>
				</td>
			</tr>
		</table>
		<table id="MenopauseDiv" <%=menopauseDivStyle%> class="nopagebreak">
			<tr valign="top">
				<td colspan="2"><strong>Menopause </strong>
					<hr noshade>
				</td>
			</tr>
			<tr valign="top">
				<td>Amenorrhea: x<input id="menopause_amenorrhea_months"
					name="menopause_amenorrhea_months"
					value=<%=props.getProperty("menopause_amenorrhea_months", "")%>>
					mths<br>
					<table>
						<tr>
							<td>- Hot flashes</td>
							<td>Y <input id="menopause_hotflashes_y" type="checkbox"
								name="menopause_hotflashes_y"
								<%=props.getProperty("menopause_hotflashes_y", "")%>></td>

							<td>N <input id="menopause_hotflashes_n" type="checkbox"
								name="menopause_hotflashes_n"
								<%=props.getProperty("menopause_hotflashes_n", "")%>></td>

						</tr>
						<tr>
							<td>- Insomnia</td>
							<td>Y <input id="menopause_insomnia_y" type="checkbox"
								name="menopause_insomnia_y"
								<%=props.getProperty("menopause_insomnia_y", "")%>>
							</td>

							<td>N <input id="menopause_insomnia_n" type="checkbox"
								name="menopause_insomnia_n"
								<%=props.getProperty("menopause_insomnia_n", "")%>>
							</td>

						</tr>

					</table></td>
				<td>
					<table>
						<tr>
							<td>- Night Sweats</td>
							<td>Y <input id="menopause_nightsweats_y" type="checkbox"
								name="menopause_nightsweats_y"
								<%=props.getProperty("menopause_nightsweats_y", "")%>></td>

							<td>N <input id="menopause_nightsweats_n" type="checkbox"
								name="menopause_nightsweats_n"
								<%=props.getProperty("menopause_nightsweats_n", "")%>></td>
						</tr>
						<tr>
							<td>- Vaginal Dryness</td>
							<td>Y <input id="menopause_vaginaldryness_y" type="checkbox"
								name="menopause_vaginaldryness_y"
								<%=props.getProperty("menopause_vaginaldryness_y", "")%>>
							</td>

							<td>N <input id="menopause_vaginaldryness_n" type="checkbox"
								name="menopause_vaginaldryness_n"
								<%=props.getProperty("menopause_vaginaldryness_n", "")%>>
							</td>
						</tr>
						<tr>
							<td>- Depression / Anxiety</td>

							<td>Y <input id="menopause_depressionanxiety_y"
								type="checkbox" name="menopause_depressionanxiety_y"
								<%=props
						.getProperty("menopause_depressionanxiety_y", "")%>>
							</td>
							<td>N <input id="menopause_depressionanxiety_n"
								type="checkbox" name="menopause_depressionanxiety_n"
								<%=props
						.getProperty("menopause_depressionanxiety_n", "")%>>
							</td>
						</tr>

					</table></td>
			</tr>
			<tr valign="top">
				<td colspan="2"><BR>
				</td>
			</tr>
		</table>
		<table id="MenorrhagiaDiv" <%=menorrhagiaDivStyle%> class="nopagebreak">
			<tr valign="top">
				<td colspan="2"><strong>Menorrhagia </strong>
					<hr noshade>
				</td>
			</tr>
			<tr valign="top">
				<td>Periods:<br>- Length:<input
					id="menorrhagia_periods_length" name="menorrhagia_periods_length"
					value=<%=props.getProperty("menorrhagia_periods_length", "")%>>-<input
					id="menorrhagia_periods_length_days"
					name="menorrhagia_periods_length_days"
					value=<%=props.getProperty("menorrhagia_periods_length_days",
						"")%>>
					days <br>- Interval:<input id="menorrhagia_periods_interval"
					name="menorrhagia_periods_interval"
					value=<%=props.getProperty("menorrhagia_periods_interval", "")%>>-<input
					id="menorrhagia_periods_interval_days"
					name="menorrhagia_periods_interval_days"
					value=<%=props.getProperty(
						"menorrhagia_periods_interval_days", "")%>>
					days <br>- Amounts:Pads /<input
					id="menorrhagia_periods_amountspads_hrs"
					name="menorrhagia_periods_amountspads_hrs"
					value=<%=props.getProperty(
						"menorrhagia_periods_amountspads_hrs", "")%>>
					hrs <br></td>
				<td>IMB/PCB:<br>- IMB Y <input id="menorrhagia_imb_y"
					type="checkbox" name="menorrhagia_imb_y"
					<%=props.getProperty("menorrhagia_imb_y", "")%>> N <input
					id="menorrhagia_imb_n" type="checkbox" name="menorrhagia_imb_n"
					<%=props.getProperty("menorrhagia_imb_n", "")%>> <br>-
					PCB Y <input id="menorrhagia_pcb_y" type="checkbox"
					name="menorrhagia_pcb_y"
					<%=props.getProperty("menorrhagia_pcb_y", "")%>> N <input
					id="menorrhagia_pcb_n" type="checkbox" name="menorrhagia_pcb_n"
					<%=props.getProperty("menorrhagia_pcb_n", "")%>> <br>
				</td>
			</tr>
			<tr valign="top">
				<td colspan="2"><BR>
				</td>
			</tr>
		</table>
		<table id="OvarianDiv" <%=ovarianDivStyle%> class="nopagebreak">
			<tr valign="top">
				<td colspan="2"><strong>Ovarian Cyst </strong>
					<hr noshade>
				</td>
			</tr>
			<tr valign="top">
				<td colspan="2">- x <input id="ovariancyst_years"
					name="ovariancyst_years"
					value=<%=props.getProperty("ovariancyst_years", "")%>>years<br>
					<table>
						<tr>
							<td>-Pain:</td>

							<td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Y<input
								id="ovariancyst_pain_y" type="checkbox"
								name="ovariancyst_pain_y"
								<%=props.getProperty("ovariancyst_pain_y", "")%>>
							</td>

							<td>&nbsp;&nbsp;N<input id="ovariancyst_pain_n"
								type="checkbox" name="ovariancyst_pain_n"
								<%=props.getProperty("ovariancyst_pain_n", "")%>><br>
							</td>
						</tr>
						<tr>
							<td>-Ultrasound:</td>
							<td>right <input id="ovariancyst_ultrasound_right"
								type="checkbox" name="ovariancyst_ultrasound_right"
								<%=props.getProperty("ovariancyst_ultrasound_right", "")%>>
							</td>
							<td>left<input id="ovariancyst_ultrasound_left"
								type="checkbox" name="ovariancyst_ultrasound_left"
								<%=props.getProperty("ovariancyst_ultrasound_left", "")%>>
							</td>
							<td>size :<input id="ovariancyst_ultrasound_size"
								name="ovariancyst_ultrasound_size"
								value=<%=props.getProperty("ovariancyst_ultrasound_size", "")%>>cm</td>


						</tr>



					</table></td>
			</tr>
			<tr valign="top">
				<td colspan="2"><BR>
				</td>
			</tr>
			<tr valign="top">
				<td colspan="2">- Characteristics:</td>
			</tr>
			<tr valign="top">
				<td colspan="2"><textarea style="WIDTH: 830px; HEIGHT: 104px; border: 1px solid #000000;"
						id="characteristics" cols="80" name="characteristics"><%=props.getProperty("characteristics", "")%></textarea>
				</td>
			</tr>
			<tr valign="top">
				<td colspan="2"><br>
				</td>
			</tr>
		</table>
		<table id="PelvicPainDiv" <%=pelvicPainDivStyle%> class="nopagebreak">
			<tr valign="top">
				<td colspan="2"><strong>Pelvic Pain </strong>
					<hr noshade>
				</td>
			</tr>
			<tr valign="top">
				<td>
					<table>
						<tr>
							<td>-Dysmenorrhea</td>

							<td>Y<input id="pelvicpain_dysmenorrhea_y" type="checkbox"
								name="pelvicpain_dysmenorrhea_y"
								<%=props.getProperty("pelvicpain_dysmenorrhea_y", "")%>>
							</td>

							<td>N<input id="pelvicpain_dysmenorrhea_n" type="checkbox"
								name="pelvicpain_dysmenorrhea_n"
								<%=props.getProperty("pelvicpain_dysmenorrhea_n", "")%>><br>
							</td>
						</tr>
						<tr>

							<td>-Dyspareunia</td>

							<td>Y<input id="pelvicpain_dyspareunia_y" type="checkbox"
								name="pelvicpain_dyspareunia_y"
								<%=props.getProperty("pelvicpain_dyspareunia_y", "")%>>
							</td>

							<td>N<input id="pelvicpain_dyspareunia_n" type="checkbox"
								name="pelvicpain_dyspareunia_n"
								<%=props.getProperty("pelvicpain_dyspareunia_n", "")%>><br>
							</td>
						</tr>

						<tr>
							<td>-Dyschezia</td>
							<td>Y<input id="pelvicpain_dyschezia_y" type="checkbox"
								name="pelvicpain_dyschezia_y"
								<%=props.getProperty("pelvicpain_dyschezia_y", "")%>></td>

							<td>N<input id="pelvicpain_dyschezia_n" type="checkbox"
								name="pelvicpain_dyschezia_n"
								<%=props.getProperty("pelvicpain_dyschezia_n", "")%>></td>

						</tr>
					</table></td>
				<td>
					<table>
						<tr valign="top">
							<td>-Location: RLQ</td>
							<td width="20%">Y<input id="pelvicpain_location_rlq_y"
								type="checkbox" name="pelvicpain_location_rlq_y"
								<%=props.getProperty("pelvicpain_location_rlq_y", "")%>>
							</td>

							<td>N<input id="pelvicpain_location_rlq_n" type="checkbox"
								name="pelvicpain_location_rlq_n"
								<%=props.getProperty("pelvicpain_location_rlq_n", "")%>><br>
							</td>

						</tr>
						<tr valign="top">
							<td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;LLQ</td>
							<td>Y<input id="pelvicpain_location_llq_y" type="checkbox"
								name="pelvicpain_location_llq_y"
								<%=props.getProperty("pelvicpain_location_llq_y", "")%>>
							</td>

							<td>N<input id="pelvicpain_location_llq_n" type="checkbox"
								name="pelvicpain_location_llq_n"
								<%=props.getProperty("pelvicpain_location_llq_n", "")%>>
							</td>

						</tr>
						<tr>
							<td>
								&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input
								id="pelvicpain_suprapublic" type="checkbox"
								name="pelvicpain_suprapublic"
								<%=props.getProperty("pelvicpain_suprapublic", "")%>></td>
							<td colspan="2">Suprapublic</td>
						</tr>
						<tr valign="top">
							<td>- Timing of Pain:</td>
							<td colspan="2"><input id="pelvicpain_timingof_pain"
								name="pelvicpain_timingof_pain"
								value=<%=props.getProperty("pelvicpain_timingof_pain", "")%>>
							</td>
						</tr>
					</table></td>
			</tr>
			<tr valign="top">
				<td colspan="2"><BR>
				</td>
			</tr>
			<tr valign="top">
				<td colspan="2"><strong>Previous Investigations </strong>
					<hr noshade>
				</td>
			</tr>
			<tr valign="top">
				<td colspan="2"><input id="previousinvestigations_bloodwork"
					type="checkbox" name="previousinvestigations_bloodwork"
					<%=props.getProperty("previousinvestigations_bloodwork",
						"")%>>Blood
					Work: Hb <input id="previousinvestigations_hb"
					name="previousinvestigations_hb"
					value=<%=props.getProperty("previousinvestigations_hb", "")%>>Hormones
					<input id="previousinvestigations_hormones"
					name="previousinvestigations_hormones"
					value=<%=props.getProperty("previousinvestigations_hormones",
						"")%>><br>
					<input id="previousinvestigations_ultrasound" type="checkbox"
					name="previousinvestigations_ultrasound"
					<%=props.getProperty(
						"previousinvestigations_ultrasound", "")%>>Ultrasound<br>
				</td>
			</tr>
			<tr valign="top">
				<td colspan="2">Notes:</td>
			</tr>
			<tr valign="top">
				<td colspan="2"><textarea style="WIDTH: 830px; HEIGHT: 104px; border: 1px solid #000000;"
						cols="80" rows="4" id="previousinvestigations_notes"
						name="previousinvestigations_notes"><%=props.getProperty("previousinvestigations_notes", "")%></textarea>
				</td>
			</tr>
			<tr valign="top">
				<td colspan="2"></td>
			</tr>
			<tr valign="top">
				<td colspan="2">&nbsp;</td>
			</tr>
			<tr valign="top">
				<td colspan="2"><strong>Physical Exam</strong>
					<hr noshade></td>
			</tr>
			<tr valign="top">
				<td colspan="2">
					<table>
						<tr>
							<td>-Breasts</td>

							<td>N<input id="physicalexam_breasts_n" type="checkbox"
								name="physicalexam_breasts_n"
								<%=props.getProperty("physicalexam_breasts_n", "")%>></td>
							<td>Abn<input id="physicalexam_breasts_abn" type="checkbox"
								name="physicalexam_breasts_abn"
								<%=props.getProperty("physicalexam_breasts_abn", "")%>><br>
							</td>

						</tr>
						<tr>
							<td>-Abdomen</td>
							<td>N<input id="physicalexam_abdomen_n" type="checkbox"
								name="physicalexam_abdomen_n"
								<%=props.getProperty("physicalexam_abdomen_n", "")%>></td>

							<td>Abn<input id="physicalexam_abdomen_abn" type="checkbox"
								name="physicalexam_abdomen_abn"
								<%=props.getProperty("physicalexam_abdomen_abn", "")%>>
							</td>
						</tr>

					</table></td>
			</tr>
			<tr valign="top">
				<td colspan="2">Notes:</td>
			</tr>
			<tr valign="top">
				<td colspan="2"><textarea style="WIDTH: 830px; HEIGHT: 104px; border: 1px solid #000000;"
						cols="80" rows="4" id="physicalexam_notes"
						name="physicalexam_notes"><%=props.getProperty("physicalexam_notes", "")%></textarea>
				</td>
			</tr>
			</tbody>
		</table>
		<table style="WIDTH: 8.5in" class="nopagebreak">
			<tbody>
				<tr><td>
					&nbsp;</td>
				</tr>
				<tr>
					<td colspan="3"><strong>Gynaecological Exam</strong>
					
					&nbsp;&nbsp;
					<input type="checkbox" name="no_gynaecologicalexam_notes" id="no_gynaecologicalexam_notes"
					onclick="fn_remove_section_from_printout_(this, 'tr_gynaecologicalexam_notes');"
					> Notes
					
						<hr noshade></td>
				</tr>
				<tr>
					<td  width="33%">
						<table>
							<tr>
								<td>- Genitalia</td>
								<td>N<input id="gynaecologicalexam_genitalia_n"
									type="checkbox" name="gynaecologicalexam_genitalia_n"
									<%=props.getProperty("gynaecologicalexam_genitalia_n",
						"")%>>
								</td>
								<td>Abn <input id="gynaecologicalexam_genitalia_abn"
									type="checkbox" name="gynaecologicalexam_genitalia_abn"
									<%=props.getProperty("gynaecologicalexam_genitalia_abn",
						"")%>>
								</td>
							</tr>
							<tr>
								<td>- Vaginal</td>
								<td>N<input id="gynaecologicalexam_vaginal_n"
									type="checkbox" name="gynaecologicalexam_vaginal_n"
									<%=props.getProperty("gynaecologicalexam_vaginal_n", "")%>>
								</td>
								<td>Abn <input id="gynaecologicalexam_vaginal_abn"
									type="checkbox" name="gynaecologicalexam_vaginal_abn"
									<%=props.getProperty("gynaecologicalexam_vaginal_abn",
						"")%>>
								</td>
							</tr>
							<tr>
								<td>- Cervix</td>
								<td>N<input id="gynaecologicalexam_cervix_n"
									type="checkbox" name="gynaecologicalexam_cervix_n"
									<%=props.getProperty("gynaecologicalexam_cervix_n", "")%>>
								</td>
								<td>Abn <input id="gynaecologicalexam_cervix_abn"
									type="checkbox" name="gynaecologicalexam_cervix_abn"
									<%=props
						.getProperty("gynaecologicalexam_cervix_abn", "")%>>
								</td>
							</tr>
							<tr>
								<td>- Rectum</td>
								<td>N<input id="gynaecologicalexam_rectum_n"
									type="checkbox" name="gynaecologicalexam_rectum_n"
									<%=props.getProperty("gynaecologicalexam_rectum_n", "")%>>
								</td>
								<td>Abn <input id="gynaecologicalexam_rectum_abn"
									type="checkbox" name="gynaecologicalexam_rectum_abn"
									<%=props
						.getProperty("gynaecologicalexam_rectum_abn", "")%>>
								</td>
							</tr>
						</table></td>
					<td>
						<table>
							<tr>
								<td>- Uterus:</td>
								<td width="20%">N&nbsp;<input
									id="gynaecologicalexam_uterus_n" type="checkbox"
									name="gynaecologicalexam_uterus_n"
									<%=props.getProperty("gynaecologicalexam_uterus_n", "")%>>
								</td>
								<td>Abn<input id="gynaecologicalexam_uterus_abn"
									type="checkbox" name="gynaecologicalexam_uterus_abn"
									<%=props
						.getProperty("gynaecologicalexam_uterus_abn", "")%>>
								</td>
							</tr>
							<tr>
								<td style="white-space: nowrap;">- Position:</td>
								<td>A/V<input id="gynaecologicalexam_position_av"
									type="checkbox" name="gynaecologicalexam_position_av"
									<%=props.getProperty("gynaecologicalexam_position_av",
						"")%>>
								</td>
								<td>R/V&nbsp;<input id="gynaecologicalexam_position_rv"
									type="checkbox" name="gynaecologicalexam_position_rv"
									<%=props.getProperty("gynaecologicalexam_position_rv",
						"")%>>
								</td>
							</tr>
							<tr>
								<td>size:</td>
								<td colspan="2"><input id="gynaecologicalexam_size"
									name="gynaecologicalexam_size"
									value=<%=props.getProperty("gynaecologicalexam_size", "")%>>
									weeks</td>

							</tr>
						</table>
					</td>
					<td>
						<table>
							<tr>
								<td>- Adnexa</td>
								<td>&nbsp;</td>
								<td>&nbsp;</td>
							</tr>
							<tr>
								<td>left:</td>
								<td>N<input id="gynaecologicalexam_adnexa_left_n"
									type="checkbox" name="gynaecologicalexam_adnexa_left_n"
									<%=props.getProperty("gynaecologicalexam_adnexa_left_n",
						"")%>>
								</td>
								<td>Abn <input id="gynaecologicalexam_adnexa_left_abn"
									type="checkbox" name="gynaecologicalexam_adnexa_left_abn"
									<%=props.getProperty(
						"gynaecologicalexam_adnexa_left_abn", "")%>>
								</td>
							</tr>
							<tr>
								<td>right:</td>
								<td>N<input id="gynaecologicalexam_adnexa_right_n"
									type="checkbox" name="gynaecologicalexam_adnexa_right_n"
									<%=props.getProperty(
						"gynaecologicalexam_adnexa_right_n", "")%>>
								</td>
								<td>Abn <input id="gynaecologicalexam_adnexa_right_abn"
									type="checkbox" name="gynaecologicalexam_adnexa_right_abn"
									<%=props.getProperty(
						"gynaecologicalexam_adnexa_right_abn", "")%>>
								</td>
							</tr>
						</table>
					</td>
				</tr>
				<!-- <tr>
					<td colspan="3">Notes:
					</td>
				</tr> -->
				<tr valign="top" id="tr_gynaecologicalexam_notes">
					<td colspan="3">
					Notes: <br>
					<textarea style="WIDTH: 810px; HEIGHT: 104px; border: 1px solid #000000;"
							cols="80" rows="4" id="gynaecologicalexam_notes"
							name="gynaecologicalexam_notes"><%=props.getProperty("gynaecologicalexam_notes", "")%></textarea>
					</td>
				</tr>
				<tr>
					<td colspan="3"><br> <strong>Investigations</strong>
					<input type="checkbox" name="no_investigations" value="1" 
					id="no_investigations" name="no_investigations"
					<%=props.getProperty("no_investigations", "").equals("1")?"checked":"" %>
					onclick="fn_remove_section_from_printout(this, 'tr_investigations');">None necessary
					
					&nbsp;&nbsp;
					<input type="checkbox" name="no_investigations_notes" id="no_investigations_notes"
					onclick="fn_remove_section_from_printout_cls(this, 'cls_tr_investigations', 'no_investigations');"
					>Notes
					
						<hr noshade></td>
				</tr>
				<tr id="tr_investigations" class="cls_tr_investigations_">
					<td  width="33%">
						<table>
							<tr>
								<td><input id="investigations_ultrasound" type="checkbox"
									name="investigations_ultrasound"
									<%=props.getProperty("investigations_ultrasound", "")%>>
								</td>
								<td>Ultrasound</td>
							</tr>
							<tr>
								<td><input id="investigations_bloodwork" type="checkbox"
									name="investigations_bloodwork"<%=props.getProperty("investigations_bloodwork")%>">
								</td>
								<td>Blood Work</td>
							</tr>
							<tr>
								<td><input id="investigations_cbcferritin" type="checkbox"
									name="investigations_cbcferritin"<%=props.getProperty("investigations_cbcferritin")%>">
								</td>
								<td>CBC, Ferritin</td>
							</tr>
							<tr>
								<td><input id="investigations_hormprofile" type="checkbox"
									<%=props.getProperty("investigations_hormprofile", "")%>
									name="investigations_hormprofile"></td>
								<td>Horm. Profile</td>
							</tr>
						</table></td>
					<td>
						<table>
							<tr>
								<td><input id="investigations_sis" type="checkbox"
									name="investigations_sis"
									<%=props.getProperty("investigations_sis", "")%>></td>
								<td>SIS</td>
							</tr>
							<tr>
								<td><input id="investigations_tubalpatency" type="checkbox"
									name="investigations_tubalpatency"
									<%=props.getProperty("investigations_tubalpatency", "")%>>
								</td>
								<td>Tubal Patency</td>
							</tr>
							<tr>
								<td><input id="investigations_menstrualcal" type="checkbox"
									name="investigations_menstrualcal"<%=props.getProperty("investigations_menstrualcal")%>">
								</td>
								<td>Menstrual Cal</td>
							</tr>
							<tr><td>&nbsp;</td></tr>
						</table>
					</td>
					<td>
						<table>
							<tr>
								<td><input id="investigations_bbt" type="checkbox"
									name="investigations_bbt"
									<%=props.getProperty("investigations_bbt", "")%>></td>
								<td>BBT</td>
							</tr>
							<tr>
								<td><input id="investigations_spermanalysis"
									type="checkbox" name="investigations_spermanalysis"
									<%=props.getProperty("investigations_spermanalysis", "")%>>
								</td>
								<td>Spermanalysis</td>
							</tr>
							<tr><td>&nbsp;</td></tr>
							<tr><td>&nbsp;</td></tr>
						</table>
					</td>
				</tr>
				<!-- <tr id="tr_investigations">
					<td colspan="3">Notes:
					</td>
				</tr> -->
				
				<tr valign="top" style="display: none;" id="tr_div_investigations_" >
					<td colspan="3">
						<div id="div_investigations_">
						</div>
					</td>
				</tr>
				
				<tr valign="top" id="tr_investigations" class="cls_tr_investigations">
					<td colspan="3">
					Notes: <br>
					<textarea style="WIDTH: 810px; HEIGHT: 104px; border: 1px solid #000000;"
							cols="80" rows="4" id="investigations_notes"
							name="investigations_notes"><%=props.getProperty("investigations_notes", "")%></textarea>
					</td>
				</tr>
				<tr>
					<td colspan="3"><br> <strong>Treatment</strong>
					<input type="checkbox" name="no_treatments" value="1" 
					id="no_treatments" name="no_treatments" 
					<%=props.getProperty("no_treatments", "").equals("1")?"checked":"" %>
					onclick="fn_remove_section_from_printout(this, 'tr_treament');">None necessary
					
					&nbsp;&nbsp;<input type="checkbox" name="chk_treatment_notes" id="chk_treatment_notes"
					onclick="fn_remove_section_from_printout_cls(this, 'cls_treatment_notes', 'no_treatments');">
					Notes
					
						<hr noshade></td>
				</tr>
				<tr id="tr_treament" class="cls_tr_treatment">
					<td width="33%">
						<table>
							<tr>
								<td>
									<input id="treatment_bcp" type="checkbox"
									name="treatment_bcp" <%=props.getProperty("treatment_bcp", "")%>>
								</td>
								<td>
									BCP:
									<input id="treatment_bcp1" type="text" name="treatment_bcp1"
									value=<%=props.getProperty("treatment_bcp1", "")%>>
								</td>
							</tr>
							<tr>
								<td>
									<input id="treatment_cyklokapron" type="checkbox"
									name="treatment_cyklokapron"
									<%=props.getProperty("treatment_cyklokapron", "")%>>
								</td>
								<td>
									Cyklokapron
								</td>
							</tr>
							<tr>
								<td>
									<input id="treatment_anaprox" type="checkbox"
									name="treatment_anaprox"
									<%=props.getProperty("treatment_anaprox", "")%>>
								</td>
								<td>
									Anaprox/Ponstan
								</td>
							</tr>
						</table>
					</td>
					<td>
						<table>
							<tr>
								<td>
									<input id="treatment_mirena" type="checkbox"
									name="treatment_mirena"
									<%=props.getProperty("treatment_mirena", "")%>>
								</td>
								<td>
									Mirena
								</td>
							</tr>
							<tr>
								<td>
									<input id="treatment_hrt" type="checkbox" name="treatment_hrt"
									<%=props.getProperty("treatment_hrt", "")%>>
								</td>
								<td>
									HRT
								</td>
							</tr>
						</table>
					</td>
					<td>
						<table>
							<tr>
								<td>
									<input id="treatment_surgery" type="checkbox"
									name="treatment_surgery"
									<%=props.getProperty("treatment_surgery", "")%>>
								</td>
								<td>
									Surgery
								</td>
							</tr>
							<tr>
								<td>
									<input id="treatment_vaginalestrogen" type="checkbox"
									<%=props.getProperty("treatment_vaginalestrogen", "")%>
									name="treatment_vaginalestrogen">
								</td>
								<td>
									Vaginal estrogen
								</td>
							</tr>
						</table>
					</td>
				</tr>
				<!-- <tr id="tr_treament">
					<td colspan="3">Notes:</td>
				</tr> -->
				
				<tr valign="top" style="display: none;" id="tr_div_treatment" >
					<td colspan="3">
						<div id="div_treatment">
						</div>
					</td>
				</tr>
				
				<tr valign="top" id="tr_treament" class="cls_treatment_notes">
					<td colspan="3">
					Notes: <br>
					<textarea style="WIDTH: 810px; HEIGHT: 104px; border: 1px solid #000000;"
							cols="80" rows="4" id="treatment_notes" name="treatment_notes"><%=props.getProperty("treatment_notes", "")%></textarea>
					</td>
				</tr>
				<tr>
					<td colspan="3"><br> <strong>Follow Up<br>
					</strong>
						<hr noshade>
					</td>
				</tr>
				<tr class="cls_tr_follow_up">
					<td colspan="3">
					<table>
						<tr>
							<td>
								<input id="followup_weeks" type="checkbox"
						<%=props.getProperty("followup_weeks", "")%> name="followup_weeks">
							</td>
							<td>
							<input id="followup_weeks1" name="followup_weeks1" type="text" style="width: 40px;"
						value=<%=props.getProperty("followup_weeks1", "")%>>&nbsp;weeks
							</td>
						</tr>
						
						<tr>
							<td>
								<input id="followup_afterinvestigations" type="checkbox"
						name="followup_afterinvestigations"
						<%=props.getProperty("followup_afterinvestigations", "")%>>
							</td>
							<td>
								After Investigations
							</td>
						</tr>
						
						<tr>
							<td>
								<input id="prn" type="checkbox"
						name="prn" value="1"
						<%=props.getProperty("prn", "")%>
						<%=props.getProperty("prn", "").equals("1")?"checked":""%>>
							</td>
							<td>
								Prn
							</td>
						</tr>
					</table>
					
						<%-- <br> <input id="followup_anaprox"
						name="followup_anaprox"
						<%=props.getProperty("followup_anaprox", "")%> type="checkbox">Anaprox<br> --%>
					</td>
				</tr>
				
				<tr valign="top" style="display: none;" id="tr_div_follow_up" >
					<td colspan="3">
						<div id="div_follow_up">
						</div>
					</td>
				</tr>
				
			</tbody>
		</table>
		<br>
		<br>
		<table style="width: 8.5in;">
			<tr>
				<td><input type="submit" value="Save"
					onclick="javascript:return onSave();" class="NonPrintable">
					<input type="submit" value="Save and Exit"
					onclick="javascript:return onSaveExit();" class="NonPrintable">
					<input type="button" value="Exit"
					onclick="javascript:window.close();" class="NonPrintable">
					<input type="submit" value="Save and Print" onClick="onClickPrint();"
					class="NonPrintable"> 
					
				</td>
			</tr>
		</table>
	</body>
	<script language="JavaScript">
		Calendar.setup({
			inputField : "bpi_date1",
			ifFormat : "%Y/%m/%d",
			showsTime : false,
			button : "bpi_date1_call",
			singleClick : true,
			step : 1
		});

		Calendar.setup({
			inputField : "appt_date",
			ifFormat : "%Y/%m/%d",
			showsTime : false,
			button : "appt_date_call",
			singleClick : true,
			step : 1
		});
		
		Calendar.setup({
			inputField : "bpi_date2",
			ifFormat : "%Y/%m/%d",
			showsTime : false,
			button : "bpi_date2_call",
			singleClick : true,
			step : 1
		});
		Calendar.setup({
			inputField : "bpi_date3",
			ifFormat : "%Y/%m/%d",
			showsTime : false,
			button : "bpi_date3_call",
			singleClick : true,
			step : 1
		});
	</script>
	<script>
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
        txtArea.value += '\n';

    txtArea.value += info;
    txtArea.scrollTop = txtArea.scrollHeight;
    txtArea.focus();

}

function fn_remove_section_from_printout(chk, id)
{
	//alert(chk.checked);
	$("[id="+id+"]").each(function(){
		//alert($(this).attr("class"));
		if(chk.checked)
		{	
			//$(this).addClass("NonPrintable");
			$(this).hide();
			if(id=="tr_investigations")
			{
				$("[id=no_investigations_notes]").attr("checked", false);
			}
			if(id=="tr_treament")
			{
				$("[id=chk_treatment_notes]").attr("checked", false);
			}
		}
		else
		{
			//$(this).removeAttr("class");
			$(this).show();
			if(id=="tr_investigations")
			{
				$("[id=no_investigations_notes]").attr("checked", true);
			}
			if(id=="tr_treament")
			{
				$("[id=chk_treatment_notes]").attr("checked", true);
			}
		}
	});
	
}

function fn_remove_section_from_printout_(chk, id)
{
	//alert(chk.checked);
	$("[id="+id+"]").each(function(){
		//alert($(this).attr("class"));
		if(!chk.checked)
		{	
			//$(this).addClass("NonPrintable");
			$(this).hide();
		}
		else
		{
			//$(this).removeAttr("class");
			$(this).show();
		}
	});
	
}		

function fn_remove_section_from_printout_cls(chk, id, chk_main_id)
{
	if($("[id="+chk_main_id+"]").attr("checked"))
	{
		//alert("main is hidden.");
		return;
	}
	//alert(chk.checked);
	$("[class="+id+"]").each(function(){
		//alert($(this).attr("class"));
		if(!chk.checked)
		{	
			//$(this).addClass("NonPrintable");
			$(this).hide();
		}
		else
		{
			//$(this).removeAttr("class");
			$(this).show();
		}
	});
}	

function fn_onchange_dt(id)
{ 
	var obj1 = document.getElementById(id+"_");
	var obj2 = document.getElementById(id);
	
	//alert("obj2.value = "+obj2.value);
	
	if(obj2.value && obj2.value!=null && obj2.value!="")
	{
		var val = obj2.value.substring(0, obj2.value.length-3);
		//alert("val = "+val);
		obj1.value = val;
	}
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
function importDoctor(lastNameCtrl,firstNameCtrl)
{
	if(lastNameCtrl.value=="")
    	lastNameCtrl.value = "<%=props.getProperty("family_doctor_default_lname", "")%>";
    if(firstNameCtrl.value=="")
		firstNameCtrl.value = "<%=props.getProperty("family_doctor_default_fname", "")%>";
}

function showHideSections(id, chk_id)
{
	//alert("chk = "+$("[id="+chk_id+"]"));
	//alert("value = "+$("[id="+chk_id+"]").attr("checked"));
	$("[id="+id+"]").each(function(){
		//alert($(this).attr("class"));
		if($("[id="+chk_id+"]").attr("checked"))
		{	
			//$(this).addClass("NonPrintable");
			$(this).hide();
		}
		else
		{
			//$(this).removeAttr("class");
			$(this).show();
		}
		
	});
}

function init_()
{
	$("[id=tr_gynaecologicalexam_notes]").hide();
	$("[class=cls_tr_investigations]").hide();
	$("[id=tr_obs_history_notes]").hide();
	$("[id=tr_family_med_hist_notes]").hide();
	$("[class=cls_treatment_notes]").hide();
	$("[class=cls_past_med_notes]").hide();
	
	if('<%=recordFromDB%>'=='true')
	{
		if('<%=props.getProperty("cm_current_medication", "").trim()%>'=='')
		{
			$("[id=no_current_medications]").attr("checked", true);
			showHideSections("tr_current_medications", "no_current_medications");
		}
		if('<%=props.getProperty("allergies", "").trim()%>'=='')
		{
			$("[id=no_allergies]").attr("checked", true);
			showHideSections("tr_allergies", "no_allergies");
		}
		if('<%=props.getProperty("gynaecologicalexam_notes", "").trim()%>'!='')
		{
			$("[id=no_gynaecologicalexam_notes]").attr("checked", true);
			$("[id=tr_gynaecologicalexam_notes]").show();
		}
		
		if(!$("[id=no_investigations]").attr("checked"))
		{
			//pending
			if('<%=props.getProperty("investigations_notes", "").trim()%>'!='')
			{
				$("[id=no_investigations_notes]").attr("checked", true);
				$("[class=cls_tr_investigations]").show();
			}
			else
			{
				$("[id=no_investigations_notes]").attr("checked", false);
				$("[class=cls_tr_investigations]").hide();
			}
		}
		
		if('<%=props.getProperty("obs_notes", "").trim()%>'!='')
		{
			$("[id=chk_obs_history_notes]").attr("checked", true);
			$("[id=tr_obs_history_notes]").show();
		}
		
		if(!$("[id=no_med_hist]").attr("checked"))
		{
			//pending
			if('<%=props.getProperty("pmh_notes", "").trim()%>'!='')
			{
				$("[id=chk_past_med_history_notes]").attr("checked", true);
				$("[class=cls_past_med_notes]").show();
			}
			else
			{
				$("[id=chk_past_med_history_notes]").attr("checked", false);
				$("[class=cls_past_med_notes]").hide();
			}
		}
		

		if('<%=props.getProperty("fmh_notes", "").trim()%>'!='')
		{
			$("[id=chk_family_med_hist_notes]").attr("checked", true);
			$("[id=tr_family_med_hist_notes]").show();
		}
		
		if(!$("[id=no_treatments]").attr("checked"))
		{
			//pending
			if('<%=props.getProperty("treatment_notes", "").trim()%>'!='')
			{
				$("[id=chk_treatment_notes]").attr("checked", true);
				$("[class=cls_treatment_notes]").show();
			}
			else
			{
				$("[id=chk_treatment_notes]").attr("checked", false);
				$("[class=cls_treatment_notes]").hide();
			}
		}
		
	}
}

$(document).ready(function(){
	//alert("document ready");
	
	showHideSections("tr_past_med_hist", "no_med_hist");
	showHideSections("tr_investigations", "no_investigations");
	showHideSections("tr_treament", "no_treatments");
	showHideSections("tr_current_medications", "no_current_medications");
	showHideSections("tr_allergies", "no_allergies");
	
	init_();
});

</script>

</html:form>
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
                noteStr.append(n.getNote() + "\n");
        }

        return noteStr.toString();
    }
%>