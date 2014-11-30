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
<%@page import="oscar.oscarProvider.data.ProSignatureData"%>
<%@ page language="java"%>
<%@page
	import="java.util.ArrayList, java.util.Collections, java.util.List, oscar.dms.*, oscar.oscarEncounter.pageUtil.*,oscar.oscarEncounter.data.*, oscar.util.StringUtils, oscar.oscarLab.ca.on.*,
	java.util.Vector,java.util.StringTokenizer"%>
<%@page
	import="org.oscarehr.casemgmt.service.CaseManagementManager, org.oscarehr.casemgmt.model.CaseManagementNote, org.oscarehr.casemgmt.model.Issue, org.oscarehr.common.model.UserProperty, org.oscarehr.common.dao.UserPropertyDAO, org.springframework.web.context.support.*,org.springframework.web.context.*,java.text.DecimalFormat,
	oscar.form.FrmConsultLetterPrintUtil,oscar.oscarClinic.ClinicData"%>
<%@ page import="oscar.form.*, oscar.OscarProperties"%>
<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean"%>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html"%>
<%@ taglib uri="/WEB-INF/struts-logic.tld" prefix="logic"%>
<%@ taglib uri="/WEB-INF/rewrite-tag.tld" prefix="rewrite"%>

<html>
 <head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>OFC - Female Consult</title>
<link rel="stylesheet" type="text/css" href="formConsultLetterPrintStyle.css">
</head> 
<%
	String formClass = "ConsultLetter";
	FrmRecord rec = (new FrmRecordFactory()).factory(formClass);
	int demoNo = Integer.parseInt(request.getParameter("demographic_no"));
	int formId = Integer.parseInt(request.getParameter("formId"));
	System.out.println("print new id " + formId);
	java.util.Properties props = rec.getFormRecord(demoNo, formId);
	FrmConsultLetterPrintUtil printutil = new FrmConsultLetterPrintUtil(props);
	
	//Clinic data
	Vector vecPhones = new Vector();
    Vector vecFaxes  = new Vector();
	ClinicData clinic = new ClinicData();
	String strPhones = clinic.getClinicDelimPhone();
	if (strPhones == null) { strPhones = ""; }
	String strFaxes  = clinic.getClinicDelimFax();
	if (strFaxes == null) { strFaxes = ""; }
	
	StringTokenizer st = new StringTokenizer(strPhones,"|");
	while (st.hasMoreTokens()) {
		vecPhones.add(st.nextToken());
	}
	
	st = new StringTokenizer(strFaxes,"|");
	while (st.hasMoreTokens()) {
	 vecFaxes.add(st.nextToken());
	}

	request.removeAttribute("submit");
%>
<script type="text/javascript" language="Javascript">

var temp;
temp = "";
var flag = 1;

	function flipFaxFooter(){
			if (flag == 1 ){
				document.getElementById("faxFooter").innerHTML="<hr><bean:message key="oscarEncounter.oscarConsultationRequest.consultationFormPrint.msgFaxFooterMessage"/>";
				flag = 0;
			}else{
				document.getElementById("faxFooter").innerHTML="";
				flag = 1;
			}
	}
	
	function PrintWindow(){
			window.print();
	}
	
	function CloseWindow(){
			window.close();
	}
	

</script>

 <style type="text/css" media="print">
        .header {
        display:none;
        }
      
 </style>
<style type="text/css">
td {
padding-left: 5px;
padding-right: 0px;
padding-top: 0px;
padding-bottom: 0px;
}

.section_title
{
	float: left;
	padding-right: 3px;
}

.reason_div{
float: left;
white-space: nowrap;
margin-right: 4px;
}

.large_txt
{
	white-space: normal !important;
}

.other_div
{
	margin-top: 5px;
}
</style>

<html:form action="/form/formname">
<body>

<%
String curUser_no = (String) session.getAttribute("user");
ProSignatureData sig = new ProSignatureData();
String multiLineHeader = sig.getMultiLineHeader(curUser_no);
//String multiLineHeader = sig.getSignature(curUser_no);
System.out.println("multiLineHeader = "+multiLineHeader);
if(multiLineHeader!=null && multiLineHeader.trim().length()>0) {
	multiLineHeader = multiLineHeader.replaceAll("\n", "<br>");
}
%>

<table align="center" style="width: 100%;" >
		
		 <tr class="header" >
			 <td>
			 	<input type=button value="<bean:message key="oscarEncounter.oscarConsultationRequest.consultationFormPrint.msgFaxFooter"/>" onclick="javascript :flipFaxFooter();"/>
				<input type=button value="<bean:message key="oscarEncounter.oscarConsultationRequest.consultationFormPrint.msgPrint"/>" onclick="javascript: PrintWindow();"/>
				<input type=button value="<bean:message key="global.btnClose"/>" onclick="javascript: CloseWindow();"/>
				
			</td>
		</tr>
		</table>
		
<table align="center" RULES=NONE FRAME=BOX style="width: 100%;" border="0" >
		
		<tr>
			<td style="padding-bottom: 3px; border-bottom: 0px solid black;">
				<table width="100%">
					<tr> 
						<td>
							<img alt="OFC consult letter logo"
							src="../images/ofc_consult_letter_logo.png">
						</td>
						<td align="right" valign="bottom">
							<div style="padding-bottom: 3px;">
							<%if(multiLineHeader!=null && multiLineHeader.trim().length()>0) {%>
							<b><%=multiLineHeader %></b><br>
							<%} %>
							<%=clinic.getClinicName()%> <br>
							<%=clinic.getClinicAddress()%><br>
							<%=clinic.getClinicCity()%>, <%=clinic.getClinicProvince()%>&nbsp;&nbsp;<%=clinic.getClinicPostal()%> <br>
								Tel: <%=vecPhones.size()>=1?vecPhones.elementAt(0):clinic.getClinicPhone()%>
								&nbsp;&nbsp;Fax: <%=vecFaxes.size()>=1?vecFaxes.elementAt(0):clinic.getClinicFax()%>
							</div>
						</td>
					</tr>
				</table>
			</td>
		</tr> 
		
		<!-- <tr><td>&nbsp;</td></tr> -->
		<%-- <tr>
			<td align="center">
				<font face="Calibri" size="6">
				<b>
				<%=clinic.getClinicName()%>
				</b>
				</font>
				<br>
				<font face="Calibri" size="5"><b>Consultation Letter</b></font>
				<!--<br> -->
				<br>
				<%=clinic.getClinicAddress()%>,<br> 
				<%=clinic.getClinicCity()%>, <%=clinic.getClinicProvince()%>  <%=clinic.getClinicPostal()%> <br>
				Tel: <%=vecPhones.size()>=1?vecPhones.elementAt(0):clinic.getClinicPhone()%>
				&nbsp;&nbsp;Fax: <%=vecFaxes.size()>=1?vecFaxes.elementAt(0):clinic.getClinicFax()%>
				<br>
			</td>
		</tr> --%> 
		<!--  <tr bgcolor="white" align="center"><td>
		<font face="Calibri" size="14">Ottawa Fertility Centre</font><br>
		<font face="Calibri" size="6">Consultation Letter</font></td>
		</tr> -->
		
		<tr>
		<td >&nbsp;</td> 
		</tr>
		<tr>
			<td height="10px" style="border-bottom: 1px solid black;"><font size="4"><b>Patient &
			Consultation Information:</b></font></td>
			<td ></td>
		</tr>
		<tr>
			<td>Date:&nbsp;<%=props.getProperty("consultDate", "")%>
			<br>
			<!-- <br> -->
			</td>
		</tr>
		<tr>
			<td>Patient Name:&nbsp; 
			<%= 
				getName(
						props.getProperty("patient_lname", ""),
						props.getProperty("patient_fname", "")
						)
			%>
			&nbsp;(<%=props.getProperty("patient_age", "")%> years old)
			<br>
			</td>
		</tr>
		
		<!--<tr>
			<td>Patient Age: &nbsp;&nbsp;<%=props.getProperty("patient_age", "")%> <br>
			<br></td>
		</tr>-->
		
		<%if(props.getProperty("partner_lname", "").trim().length()>0 && 
				props.getProperty("partner_fname", "").trim().length()>0) {%>
		<tr>
			<td>Partner Name: &nbsp;<%= 
				getName(
						props.getProperty("partner_lname", ""),
						props.getProperty("partner_fname", "")
						)
			%>
			&nbsp;(<%=props.getProperty("partner_age", "")%> years old)
			</td>
		</tr>
		<%} %>
		
		<tr><td>&nbsp;</td></tr>
		
		<!--<tr>
			<td>Partner Age: &nbsp;&nbsp; <%=props.getProperty("partner_age", "")%> <br>
			<br></td>
		</tr> -->
		<tr>
			<td>Dear Dr.&nbsp;<%=props.getProperty("family_doctor_lname", "")%>,
			<br>
			<!--<br> -->
			</td>
		</tr>
		<tr><td>
		<%
		String patientPartnerStr = "patient";
		
		if((props.getProperty("patient_lname", "").trim().length()>0 || props.getProperty("patient_fname", "").trim().length()>0)
		&& (props.getProperty("partner_lname", "").trim().length()>0 || props.getProperty("partner_fname", "").trim().length()>0))
		{	patientPartnerStr = "couple"; }
		%>
		Thank you for referring this <%=patientPartnerStr %> to our facility. Here are the results of our initial consultation. If you have any questions, please feel free to contact our office. We would be pleased to offer any additional information.
		</td></tr>
		
		<!-- <tr>
		<td class="bottomBorder">&nbsp;</td> 
		</tr> -->
		
		<tr>
		<td >&nbsp;</td> 
		</tr>
		
		<% if(printutil.isRFCGroupActive()) { %>
		<tr>
			<td style="border-bottom: 1px solid black;"><b>Reason for Consultation:</b> </td>
		</tr>
		
		<tr>
			<td >
			
			<!-- <div class="section_title"><b>Reason for
			Consultation :</b> 
			</div> -->
			<div >
			<!-- </td>
		</tr>
		<tr>
			<td> -->
			
			<% if(printutil.isActive("rfc_infertility")){%>
				<div class="reason_div"><input type="checkbox" checked >
				Infertility</div>
			<% } %>
			<% if(printutil.isActive("rfc_rpl")){%>
			<div class="reason_div">
			<input type="checkbox" checked >Recurrent Pregnancy loss</div>
			<% } %>
			<% if(printutil.isActive("rfc_fp")){%>
			<div class="reason_div">
			<input type="checkbox" checked >Fertility Preservation</div>
			<% } %>
			<% if(printutil.isActive("rfc_ivf")){%>
			<div class="reason_div">
			<input type="checkbox" checked >IVF</div>
			<% } %>
			<% if(printutil.isActive("rfc_afp")){%>
			<div class="reason_div">
			<input type="checkbox" checked >Assessment of fertility potential</div>
			<% } %>
			<% if(printutil.isActive("rfc_endometriosis")){%>
			<div class="reason_div">
			<input type="checkbox" checked >Endometriosis</div>
			<% } %>
			<% if(printutil.isActive("rfc_amenorrhea")){%>
			<div class="reason_div">
			<input type="checkbox" checked >Amenorrhea</div>
			<% } %>
			<% if(printutil.isActive("rfc_ros")){%>
			<div class="reason_div">
			<input type="checkbox" checked >Reversal of sterilization</div>
			<% } %>
			<% if(printutil.isActive("rfc_ps")){%>
			<div class="reason_div">
			<input type="checkbox" checked >Possible surgery</div>
			<% } %>
			<% if(printutil.isActive("rfc_pcos")){%>
			<div class="reason_div">
			<input type="checkbox" checked >PCOS</div>
			<% } %>
			<% if(printutil.isActive("rfc_pof")){%>
			<div class="reason_div">
			<input type="checkbox" name="rfc_pof"
				<%=props.getProperty("rfc_pof", "")%>>Premature ovarian failure</div>
			<% } %>
			<% if(printutil.isActive("rfc_tdi")){%>
			<div class="reason_div">
			<input type="checkbox" checked >Therapeutic donor insemination</div>
			<% } %>
			<% if(printutil.isActive("rfc_det")){%>
			<div class="reason_div">
			<input type="checkbox" checked >Donor egg therapy</div>
			<% } %>
			<% if(printutil.isActive("rfc_mfi")){%>
			<div class="reason_div">
			<input type="checkbox" checked >Male Factor	Infertility</div>
			<% } %>
			<% if(printutil.isActive("rfc_hov")){%>
			<div class="reason_div">
			<input type="checkbox" checked >History of vasectomy</div>
			<% } %>
			</div>
			</td>
		</tr>
		<% if(printutil.isActive("rfc_other")){%>
		<tr>
			<td>
			<!-- Other :  -->
			<div class="other_div">
			<%=props.getProperty("rfc_other", "")%>
			</div>
			</td>
		</tr>
		<%  } %>
		
		<!-- <tr>
		<td class="bottomBorder">&nbsp;</td> 
		</tr> -->
		
		<tr>
		<td>&nbsp;</td> 
		</tr>
		
		<%  } %>
		
		<% if(printutil.isRFHGroupActive()){ %>
		<tr>
			<td style="border-bottom: 1px solid black;">
			<b>Relevant Fertility History:</b>
			</td>
		</tr>
		
		<tr>
			<td height="10px">
			<!-- <div class="section_title">
			<b>Relevant
			Fertility History:</b>
			</div> -->
			<!-- </td>
		</tr> -->
		<% if(printutil.isRFHOF_AGroupActive()){ %>
		<!--<tr>
			<td height="10px"><font size="3"><b><i>a)
			Ovulation Factors</i></b></font></td>
		</tr>-->
		<!-- <tr>
			<td> -->
			<% if(printutil.isActive("rfhof_lmp")){%>
				<div class="reason_div">
				<input type="checkbox" checked >LMP&nbsp;<%=props.getProperty("rfhof_lmp_t", "")%> 
				</div>
			<%  } %>
			<% if(printutil.isActive("rfhof_gtpaepl")){%>
			<div class="reason_div"><input type="checkbox" checked >

			<% if(printutil.isActive("rfhof_gtpaepl_gt")){%>
			G&nbsp;<%=props.getProperty("rfhof_gtpaepl_gt", "").trim()%>,
			<% }
			if(printutil.isActive("rfhof_gtpaepl_tt")){%>
			T&nbsp;<%=props.getProperty("rfhof_gtpaepl_tt", "")%>,
			<% } 
			if(printutil.isActive("rfhof_gtpaepl_pt")){%>
			P&nbsp;<%=props.getProperty("rfhof_gtpaepl_pt", "")%>,
			<% } 
			if(printutil.isActive("rfhof_gtpaepl_at")){%>
			A&nbsp;<%=props.getProperty("rfhof_gtpaepl_at", "")%>,
			<% } 
			if(printutil.isActive("rfhof_gtpaepl_tat")){%>
			TA&nbsp;<%=props.getProperty("rfhof_gtpaepl_tat", "")%>,
			<% } 
			if(printutil.isActive("rfhof_gtpaepl_ept")){%>
			EP&nbsp;<%=props.getProperty("rfhof_gtpaepl_ept", "")%>,
			<% } 
			if(printutil.isActive("rfhof_gtpaepl_lt")){%>
			L&nbsp;<%=props.getProperty("rfhof_gtpaepl_lt", "")%><br>
			<%  } %>
			</div>
			<%  } %>

			<% if(printutil.isActive("rfhof_dot")){%>
			<div class="reason_div">
			<input type="checkbox" checked >Duration of trying:&nbsp;<%=props.getProperty("rfhof_dot_t", "")%> 
			</div>
			<%  } %>
			<% if(printutil.isActive("rfhof_menarche")){%>
			<div class="reason_div">
			<input type="checkbox" checked >Menarche:&nbsp;<%=props.getProperty("rfhof_menarche_t", "")%>
			</div>
			<%  } %>
		</td>
		</tr>
		<% if(printutil.isActive("rfhof_other")){%>
		<tr>
			<td>
			<!-- Other :  -->
			<div class="other_div">
			<%=props.getProperty("rfhof_other", "")%>
			</div>
			</td>
		</tr>
		<%  } %>
		<tr>
			<td>&nbsp;</td>
		</tr>
<%} %>
	<% if(printutil.isRFHOF_BGroupActive()){ %>
		<tr>
			<td height="10px">
			
			<div class="section_title">
			<font size="3"><b><i>a)
			Ovulation / Menstrual Factors</i>: </b></font>
			</div>
			
			<!-- </td>
		</tr>
		<tr>
			<td> -->
			
			<% if(printutil.isActive("rfhof_ci")){%>
			<div class="reason_div">
			<input type="checkbox" checked >Cycle interval:&nbsp;<%=props.getProperty("rfhof_ci_t", "")%>
			</div>
			<%  } %>
			<% if(printutil.isActive("rfhtf_atd")){%>
			<div class="reason_div">
			<input type="checkbox" checked >Admits to&nbsp;<%=props.getProperty("rfhtf_atd_t", "")%>&nbsp;dysmenorrhea
			</div>
			<%  } %>
			
			<% if(printutil.isActive("rfhof_dof")){%>
			<div class="reason_div">
			<input type="checkbox" checked >Duration of flow&nbsp;<%=props.getProperty("rfhof_dof_t", "")%>&nbsp;days
			</div>
			<%  } %>
			<% if(printutil.isActive("rfhof_fl")){%>
			<div class="reason_div">
			<input type="checkbox" checked >Flow is&nbsp;<%=props.getProperty("rfhof_fl_t", "")%>
			</div>
			<%  } %>
			
			<% if(printutil.isActive("rfhof_ra")){%>
			<div class="reason_div">
			<input type="checkbox" checked >Reports acne
			</div>
			<%  } %>
			
			<% if(printutil.isActive("rfhof_ra_d")){%>
			<div class="reason_div">
			<input type="checkbox" checked >Denies acne
			</div>
			<%  } %>
			
			<% if(printutil.isActive("rfhof_rh")){%>
			<div class="reason_div">
			<input type="checkbox" checked >Reports hirsutism
			</div>
			<%  } %>
			
			<% if(printutil.isActive("rfhof_rh_d")){%>
			<div class="reason_div">
			<input type="checkbox" checked >Denies hirsutism
			</div>
			<%  } %>
			
			<% if(printutil.isActive("rfhof_rg")){%>
			<div class="reason_div">
			<input type="checkbox" checked >Reports galactorrhea
			</div>
			<%  } %>
			<% if(printutil.isActive("rfhof_rg_d")){%>
			<div class="reason_div">
			<input type="checkbox" checked >Denies galactorrhea
			</div>
			<%  } %>
			
			</td>
		</tr>
		<% if(printutil.isActive("rfhof_other2")){%>
		<tr>
			<td>
			<!-- Other :  -->
			<div class="other_div">
			<%=props.getProperty("rfhof_other2", "")%>
			</div>
			</td>
		</tr>
		<%  } %>
		<tr>
			<td>&nbsp;</td>
		</tr>
<%} %>
	<% if(printutil.isTFGroupActive()){ %>
		<tr>
			<td height="10px">
			<div class="section_title">
			<font size="3"><b><i>b) Tubal
			Factors</i>: </b></font>
			</div>
			
			<!-- </td>
		</tr>
		<tr>
			<td> -->
			
			<% if(printutil.isActive("rfhtf_sti")){%>
			<div class="reason_div">
			<input type="checkbox" checked >Has a history of STI:&nbsp;<%=props.getProperty("rfhtf_sti_t", "")%>
			</div>
			<%  } %>
			<% if(printutil.isActive("rfhtf_sti_no")){%>
			<div class="reason_div">
			<input type="checkbox" checked >Has no history of previous STI
			</div>
			<%  } %>
			<% if(printutil.isActive("rfhtf_pid")){%>
			<div class="reason_div">
			<input type="checkbox" checked >Has history of PID: &nbsp;<%=props.getProperty("rfhtf_pid_t", "")%>
			</div>
			<%  } %>
			<% if(printutil.isActive("rfhtf_pelvsurg")){%>
			<div class="reason_div">
			<input type="checkbox" checked >Has a history of pelvic surgery:&nbsp;<%=props.getProperty("rfhtf_pelvsurg_t", "")%>
			</div>
			<%  } %>
			<% if(printutil.isActive("rfhtf_ectpsurg")){%>
			<div class="reason_div">
			<input type="checkbox" checked >Has a history of ectopic pregnancy:&nbsp;<%=props.getProperty("rfhtf_ectpsurg_t", "")%>
			</div>
			<%  } %>
			<% if(printutil.isActive("rfhtf_dtrs")){%>
			<div class="reason_div">
			<input type="checkbox" checked >Denies any tubal risk factors
			</div>
			<%  } %>
			
			<% if(printutil.isActive("rfhtf_prev_iud")){%>
			<div class="reason_div">
			<input type="checkbox" checked >Previous use of IUD
			</div>
			<%  } %>
			
		</td>
		</tr>
		<% if(printutil.isActive("rfhtf_other")){%>
		<tr>
			<td>
			<!-- Other :  -->
			<div class="other_div">
			<%=props.getProperty("rfhtf_other", "")%>
			</div>
			</td>
		</tr>
		<%  } %>
		<tr>
			<td>&nbsp;</td>
		</tr>
<% } %>
<% if(printutil.isCFGroupActive()){ %>
		<tr>
			<td height="10px">
			<div class="section_title">
			<font size="3"><b><i>c) Coital
			Factors</i>: </b></font>
			</div>
			
			<!-- </td>
		</tr>
		<tr>
			<td> -->
			
			<% if(printutil.isActive("rfhcf_ri")){%>
			<div class="reason_div">
			<input type="checkbox" checked >Regular	intercourse:&nbsp;&nbsp;<%=props.getProperty("rfhcf_ri_t", "")%>
			</div>
			<%  } %>
			
			<% if(printutil.isActive("rfhtf_atdd")){%>
			<div class="reason_div">
			<input type="checkbox" checked >Admits to deep dyspareunia
			</div>
			<%  } %>
			<% if(printutil.isActive("rfhcf_pd_no")){%>
			<div class="reason_div">
			<input type="checkbox" checked >Has no dyspareunia
			</div>
			<%  } %>
			
			<% if(printutil.isActive("rfhcf_pd")){%>
			<div class="reason_div">
			<input type="checkbox" checked >Penetration	dyspareunia
			</div>
			<%  } %>
			<% if(printutil.isActive("rfhcf_erd")){%>
			<div class="reason_div">
			<input type="checkbox" checked >Erectile dysfunction
			</div>
			<%  } %>
			<% if(printutil.isActive("rfhcf_ejd")){%>
			<div class="reason_div">
			<input type="checkbox" checked >Ejaculatory	dysfunction
			</div>
			<%  } %>
			
			<% if(printutil.isActive("rfhcf_dl")){%>
			<div class="reason_div">
			<input type="checkbox" checked >Decreased male/female libido
			</div>
			<%  } %>
			<% if(printutil.isActive("rfhcf_dl_f")){%>
			<div class="reason_div">
			<input type="checkbox" checked >Decreased female libido
			</div>
			<%  } %>
			
			<% if(printutil.isActive("rfhcf_nsf")){%>
			<div class="reason_div">
			<input type="checkbox" checked >Normal sexual function
			</div>
			<%  } %>
			
			<% if(printutil.isActive("rfhcf_lubricants")){%>
			<div class="reason_div">
			<input type="checkbox" checked >Lubricants
			</div>
			<%  } %>
			<% if(printutil.isActive("rfhcf_lubricants_no")){%>
			<div class="reason_div">
			<input type="checkbox" checked >Couple not using lubricants
			</div>
			<%  } %>
			
			</td>
		</tr>
		<% if(printutil.isActive("rfhcf_other")){%>
		<tr>
			<td>
			<!-- Other :  -->
			<div class="other_div">
			<%=props.getProperty("rfhcf_other", "")%>
			</div>
			</td>
		</tr>
		<%  } %>
		<tr>
			<td>&nbsp;</td>
		</tr>
<% } %>
<% } %>
<% if(printutil.isPIGroupActive()){ %>
		
		<tr>
			<td style="border-bottom: 1px solid black;"><font size="3"><b>Previous
			Investigations:</b></font></td>
		</tr>
		<tr>
			<td>
			<% if(printutil.isActive("pi_tp")){%>
			<input type="checkbox" name="pi_tp" onchange="toggleControl(document.forms[0].pi_tp,document.forms[0].pi_tp_t)
;toggleControl(document.forms[0].pi_tp,document.forms[0].pi_tp_normal)
toggleControl(document.forms[0].pi_tp,document.forms[0].pi_tp_abnormal)"
				<%=props.getProperty("pi_tp", "")%>>Tubal patency:&nbsp;&nbsp;<%=props.getProperty("pi_tp_t", "")%>&nbsp;&nbsp;
			<% if(printutil.isActive("pi_tp_normal")){%>
			<input type="checkbox" name="pi_tp_normal" <%= getdisablestatus(props,"pi_tp") %> <%=props.getProperty("pi_tp_normal", "")%>>normal &nbsp;&nbsp;
			<% } %>
			<% if(printutil.isActive("pi_tp_abnormal")){%>
			<input
				type="checkbox" name="pi_tp_abnormal" <%= getdisablestatus(props,"pi_tp") %>onchange="toggleControl(document.forms[0].pi_tp_abnormal,document.forms[0].pi_tp_abnormal_t)" 
				<%=props.getProperty("pi_tp_abnormal", "")%>>abnormal &nbsp;<%=props.getProperty("pi_tp_abnormal_t", "")%>
			<% } %>
			<br>
			<% } %>
			<% if(printutil.isActive("pi_laparoscopy")){%>
			<input type="checkbox" name="pi_laparoscopy" <%=props.getProperty("pi_laparoscopy", "")%>>Laparoscopy:&nbsp;&nbsp;<%=props.getProperty("pi_laparoscopy_t", "")%>&nbsp;&nbsp;
				<% if(printutil.isActive("pi_lps_normal")){%>
				<input type="checkbox" name="pi_lps_normal" <%= getdisablestatus(props,"pi_laparoscopy") %>
				<%=props.getProperty("pi_lps_normal", "")%>>normal &nbsp;&nbsp;
				<% } %>
				<% if(printutil.isActive("pi_lps_abnormal")){%>
				<input type="checkbox" name="pi_lps_abnormal" <%= getdisablestatus(props,"pi_laparoscopy") %> onchange="toggleControl(document.forms[0].pi_lps_abnormal,document.forms[0].pi_lps_abnormal_t)"
				<%=props.getProperty("pi_lps_abnormal", "")%>>abnormal &nbsp;
				<%=props.getProperty("pi_lps_abnormal_t", "")%>
				<% } %>
				<br>
			<% } %>
			<% if(printutil.isActive("pi_lp")){%>
			<input type="checkbox" name="pi_lp" onchange="toggleControl(document.forms[0].pi_lp,document.forms[0].pi_lp_t)
;toggleControl(document.forms[0].pi_lp,document.forms[0].pi_lp_normal)
toggleControl(document.forms[0].pi_lp,document.forms[0].pi_lp_abnormal)"
				<%=props.getProperty("pi_lp", "")%>>Luteal
			Progesterone:&nbsp;&nbsp;<%=props.getProperty("pi_lp_t", "")%> &nbsp;&nbsp;
			<% if(printutil.isActive("pi_lp_normal")){%>
			<input type="checkbox" name="pi_lp_normal" <%= getdisablestatus(props,"pi_lp") %>
				<%=props.getProperty("pi_lp_normal", "")%>>normal &nbsp;&nbsp;
			<% } %>
			<% if(printutil.isActive("pi_lp_abnormal")){%>
			<input
				type="checkbox" name="pi_lp_abnormal" <%= getdisablestatus(props,"pi_lp") %> onchange="toggleControl(document.forms[0].pi_lp_abnormal,document.forms[0].pi_lp_abnormal_t)"
				<%=props.getProperty("pi_lp_abnormal", "")%>>abnormal &nbsp;<%=props.getProperty("pi_lp_abnormal_t", "")%>
			<% } %>
			<br>
			<% } %>
			<% if(printutil.isActive("pi_ha")){%>
			<input type="checkbox" name="pi_ha" onchange="toggleControl(document.forms[0].pi_ha,document.forms[0].pi_ha_t)
;toggleControl(document.forms[0].pi_ha,document.forms[0].pi_ha_normal)
toggleControl(document.forms[0].pi_ha,document.forms[0].pi_ha_abnormal)"
				<%=props.getProperty("pi_ha", "")%>>Hormonal
			assessment:&nbsp;&nbsp;<%=props.getProperty("pi_ha_t", "")%> &nbsp;&nbsp;
			<% if(printutil.isActive("pi_ha_normal")){%>
			<input
				type="checkbox" name="pi_ha_normal" d <%= getdisablestatus(props,"pi_ha") %>
				<%=props.getProperty("pi_ha_normal", "")%>>normal &nbsp;&nbsp;
			<% } %>
			<% if(printutil.isActive("pi_ha_abnormal")){%>
			<input
				type="checkbox" name="pi_ha_abnormal"  <%= getdisablestatus(props,"pi_ha") %> onchange="toggleControl(document.forms[0].pi_ha_abnormal,document.forms[0].pi_ha_abnormal_t)"
				<%=props.getProperty("pi_ha_abnormal", "")%>>abnormal &nbsp;<%=props.getProperty("pi_ha_abnormal_t", "")%> 
			<% } %>
			<br>
			<% } %>
			<% if(printutil.isActive("pi_pa")){%>
			<input type="checkbox" name="pi_pa" onchange="toggleControl(document.forms[0].pi_pa,document.forms[0].pi_pa_t)
;toggleControl(document.forms[0].pi_pa,document.forms[0].pi_pa_normal)
toggleControl(document.forms[0].pi_pa,document.forms[0].pi_pa_abnormal)"
				<%=props.getProperty("pi_pa", "")%>>Pelvic
			Ultrasound:&nbsp;&nbsp;<%=props.getProperty("pi_pa_t", "")%> &nbsp;&nbsp;
			<% if(printutil.isActive("pi_pa_normal")){%>
			<input
				type="checkbox" name="pi_pa_normal" <%= getdisablestatus(props,"pi_pa") %>
				<%=props.getProperty("pi_pa_normal", "")%>>normal &nbsp;&nbsp;
			<% } %>
			<% if(printutil.isActive("pi_pa_abnormal")){%>
			<input
				type="checkbox" name="pi_pa_abnormal"<%= getdisablestatus(props,"pi_pa") %> onchange="toggleControl(document.forms[0].pi_pa_abnormal,document.forms[0].pi_pa_abnormal_t)"
				<%=props.getProperty("pi_pa_abnormal", "")%>>abnormal &nbsp;<%=props.getProperty("pi_pa_abnormal_t", "")%>
			<% } %>
			<br>
			<% } %>
			<% if(printutil.isActive("pi_sa")){%>
			<input type="checkbox" name="pi_sa" onchange="toggleControl(document.forms[0].pi_sa,document.forms[0].pi_sa_t)
;toggleControl(document.forms[0].pi_sa,document.forms[0].pi_sa_normal)
toggleControl(document.forms[0].pi_sa,document.forms[0].pi_sa_abnormal)"
				<%=props.getProperty("pi_sa", "")%>>Semen
			Analysis:&nbsp;&nbsp;<%=props.getProperty("pi_sa_t", "")%> &nbsp;&nbsp;
			<% if(printutil.isActive("pi_sa_normal")){%>
			<input
				type="checkbox" name="pi_sa_normal" <%= getdisablestatus(props,"pi_sa") %>
				<%=props.getProperty("pi_sa_normal", "")%>>normal &nbsp;&nbsp;
			<% } %>
			<% if(printutil.isActive("pi_sa_abnormal")){%>
			<input
				type="checkbox" name="pi_sa_abnormal" <%= getdisablestatus(props,"pi_sa") %> onchange="toggleControl(document.forms[0].pi_sa_abnormal,document.forms[0].pi_sa_abnormal_t)"
				<%=props.getProperty("pi_sa_abnormal", "")%>>abnormal &nbsp;<%=props.getProperty("pi_sa_abnormal_t", "")%>
			<% } %>
			<br>
			<% } %>
			</td>
		</tr>
		<% if(printutil.isActive("pi_other")){%>
		<tr>
			<td>
			<!-- Other<br> -->
			<div class="other_div">
			<%=props.getProperty("pi_other", "")%><br>
			</div>
			</td>
		</tr>
		<% } %>
		<!-- <tr>
			<td>&nbsp;</td>
		</tr> -->
		<!-- <tr>
		<td class="bottomBorder">&nbsp;</td> 
		</tr> -->
		
		<tr>
		<td >&nbsp;</td> 
		</tr>
<% } %>
<% if(printutil.isPTGroupActive()){ %>
		<tr>
			<td style="border-bottom: 1px solid black;"><font size="3"><b>Previous
			Treatments:</b></font></td>
		</tr>
		<tr>
			<td>
			<% if(printutil.isActive("pt_oi")){%>
			<input type="checkbox" name="pt_oi" onchange="toggleControl(document.forms[0].pt_oi,document.forms[0].pt_oi_t)"
				<%=props.getProperty("pt_oi", "")%>>Ovulation
			Induction&nbsp;&nbsp;<%=props.getProperty("pt_oi_t", "")%><br>
			<% } %>
			<% if(printutil.isActive("pt_saii")){%>
			<input type="checkbox" name="pt_saii" onchange="toggleControl(document.forms[0].pt_saii,document.forms[0].pt_saii_t)"
				<%=props.getProperty("pt_saii", "")%>>Superovulation and
			intrauterine insemination:&nbsp;&nbsp;<%=props.getProperty("pt_saii_t", "")%><br>
			<% } %>
			<% if(printutil.isActive("pt_ivf")){%>
			<input type="checkbox" name="pt_ivf" onchange="toggleControl(document.forms[0].pt_ivf,document.forms[0].pt_ivf_t)"
				<%=props.getProperty("pt_ivf", "")%>>IVF:&nbsp;&nbsp;<%=props.getProperty("pt_ivf_t", "")%><br>
			<% } %>
			<% if(printutil.isActive("pt_ivf_icsi")){%>
			<input type="checkbox" name="pt_ivf_icsi" onchange="toggleControl(document.forms[0].pt_ivf_icsi,document.forms[0].pt_ivf_icsi_t)"
				<%=props.getProperty("pt_ivf_icsi", "")%>>IVF with
			ICSI:&nbsp;&nbsp;<%=props.getProperty("pt_ivf_icsi_t", "")%><br>
			<% } %>
			</td>
		</tr>
		<% if(printutil.isActive("pt_other")){%>
		<tr>
			<td>
			<!-- Other<br> -->
			<div class="other_div">
			<%=props.getProperty("pt_other", "")%><br>
			</div>
			</td>
		</tr>
		<% } %>
		<!-- <tr>
			<td>&nbsp;</td>
		</tr> -->
		
		<!-- <tr>
		<td class="bottomBorder">&nbsp;</td> 
		</tr> -->
		
		<tr>
		<td>&nbsp;</td> 
		</tr>
		
<% } %>
<% if(printutil.isOHGroupActive()) { %>
		<tr>
			<td height="10px" style="border-bottom: 1px solid black;"><font size="3"><b>Obstetrical
			History:</b></font>
			TTC  = Time to Conception (months)
			&nbsp;</td>
		</tr>
		<tr>
			<td>
			<table bgcolor="white" style="width: 6.5in;" align="left">
				<% if(printutil.isNumberedOHRowActive(1)){%>
				<tr>
					<td colspan="2">Year: <%=props.getProperty("oh_year1", "")%>;  
					Outcome: <%=props.getProperty("oh_po1", "")%>; 
					Weeks: <%=props.getProperty("oh_weeks1", "")%>; 
					TTC: <%=props.getProperty("oh_toc1", "")%>; 
					<%if(props.getProperty("oh_treatment1", "")!=null && props.getProperty("oh_treatment1", "").length()>0){ %>
					Treatment: <%=props.getProperty("oh_treatment1", "").trim()%>;
					<%} %>
					<%if(props.getProperty("oh_notes1", "")!=null && props.getProperty("oh_notes1", "").length()>0){ %>
					Notes:
						<%=props.getProperty("oh_notes1", "")%>
					<%} %>
					</td>
				</tr>
				<%-- <tr>
					<td width="10%" VALIGN="top">Treatment:</td>
					<td><%=props.getProperty("oh_treatment1", "")%></td>
				</tr> --%>
				<%-- <%if(props.getProperty("oh_notes1", "")!=null && props.getProperty("oh_notes1", "").length()>0){ %>
				<tr>
					<td width="10%" VALIGN="top">Notes:</td>
					<td><%=props.getProperty("oh_notes1", "")%></td>
				</tr>
				<%} %> --%>
				
				<% } %>
				<% if(printutil.isNumberedOHRowActive(2)){%>
				<tr> <td> &nbsp;</td> </tr>
				<tr>
					<td colspan="2">Year: <%=props.getProperty("oh_year2", "")%>; 
					Outcome: <%=props.getProperty("oh_po2", "")%>; 
					Weeks: <%=props.getProperty("oh_weeks2", "")%>; 
					TTC: <%=props.getProperty("oh_toc2", "")%>; 
					<%if(props.getProperty("oh_treatment2", "")!=null && props.getProperty("oh_treatment2", "").length()>0){ %>
					Treatment: <%=props.getProperty("oh_treatment2", "").trim()%>;
					<%} %>
					<%if(props.getProperty("oh_notes2", "")!=null && props.getProperty("oh_notes2", "").length()>0){ %>
					Notes:
						<%=props.getProperty("oh_notes2", "")%>
					<%} %>
					</td>
				</tr>
				<%-- <tr>
					<td width="10%" VALIGN="top">Treatment:</td>
					<td><%=props.getProperty("oh_treatment2", "")%></td>
				</tr> --%>
				<%-- <%if(props.getProperty("oh_notes2", "")!=null && props.getProperty("oh_notes2", "").length()>0){ %>
				<tr>
					<td VALIGN="top">Notes:</td>
					<td><%=props.getProperty("oh_notes2", "")%></td>
				</tr>
				<%} %> --%>
				
				<% } %>
				<% if(printutil.isNumberedOHRowActive(3)){%>
				<tr> <td> &nbsp;</td> </tr>
				<tr>
					<td colspan="2">Year: <%=props.getProperty("oh_year3", "")%>; 
					Outcome: <%=props.getProperty("oh_po3", "")%>; 
					Weeks: <%=props.getProperty("oh_weeks3", "")%>; 
					TTC: <%=props.getProperty("oh_toc3", "")%>; 
					<%if(props.getProperty("oh_treatment3", "")!=null && props.getProperty("oh_treatment3", "").length()>0){ %>
					Treatment: <%=props.getProperty("oh_treatment3", "").trim()%>;
					<%} %>
					<%if(props.getProperty("oh_notes3", "")!=null && props.getProperty("oh_notes3", "").length()>0){ %>
					Notes:
						<%=props.getProperty("oh_notes3", "")%>
					<%} %>
					</td>
				</tr>
				<%-- <tr>
					<td width="10%" VALIGN="top">Treatment:</td>
					<td><%=props.getProperty("oh_treatment3", "")%></td>
				</tr> --%>
				<%-- <%if(props.getProperty("oh_notes3", "")!=null && props.getProperty("oh_notes3", "").length()>0){ %>
				<tr>
					<td width="10%" VALIGN="top">Notes:</td>
					<td><%=props.getProperty("oh_notes3", "")%></td>
				</tr>
				<%} %> --%>
				
				<% } %>
				<% if(printutil.isNumberedOHRowActive(4)){%>
				<tr> <td> &nbsp;</td> </tr>
				<tr>
					<td colspan="2">Year: <%=props.getProperty("oh_year4", "")%>; 
					Outcome: <%=props.getProperty("oh_po4", "")%>; 
					Weeks: <%=props.getProperty("oh_weeks4", "")%>; 
					TTC: <%=props.getProperty("oh_toc4", "")%>; 
					<%if(props.getProperty("oh_treatment4", "")!=null && props.getProperty("oh_treatment4", "").length()>0){ %>
					Treatment: <%=props.getProperty("oh_treatment4", "").trim()%>;
					<%} %>
					<%if(props.getProperty("oh_notes4", "")!=null && props.getProperty("oh_notes4", "").length()>0){ %>
					Notes:
						<%=props.getProperty("oh_notes4", "")%>
					<%} %>
					</td>
				</tr>
				<%-- <tr>
					<td width="10%" VALIGN="top">Treatment:</td>
					<td><%=props.getProperty("oh_treatment4", "")%></td>
				</tr> --%>
				<%-- <%if(props.getProperty("oh_notes4", "")!=null && props.getProperty("oh_notes4", "").length()>0){ %>
				<tr>
					<td width="10%" VALIGN="top">Notes:</td>
					<td><%=props.getProperty("oh_notes4", "")%></td>
				</tr>
				<%} %> --%>
				
				<% } %>
				<% if(printutil.isNumberedOHRowActive(5)){%>
				<tr> <td> &nbsp;</td> </tr>
				<tr>
					<td colspan="2">Year: <%=props.getProperty("oh_year5", "")%>;  
					Outcome: <%=props.getProperty("oh_po5", "")%>; 
					Weeks: <%=props.getProperty("oh_weeks5", "")%>; 
					TTC: <%=props.getProperty("oh_toc5", "")%>;
					<%if(props.getProperty("oh_treatment5", "")!=null && props.getProperty("oh_treatment5", "").length()>0){ %> 
					Treatment: <%=props.getProperty("oh_treatment5", "").trim()%>;
					<%} %>
					<%if(props.getProperty("oh_notes5", "")!=null && props.getProperty("oh_notes5", "").length()>0){ %>
					Notes:
						<%=props.getProperty("oh_notes5", "")%>
					<%} %>
					</td>
				</tr>
				<%-- <tr>
					<td width="10%" VALIGN="top">Treatment:</td>
					<td><%=props.getProperty("oh_treatment5", "")%></td>
				</tr> --%>
				<%-- <%if(props.getProperty("oh_notes5", "")!=null && props.getProperty("oh_notes5", "").length()>0){ %>
				<tr>
					<td width="10%" VALIGN="top">Notes:</td>
					<td><%=props.getProperty("oh_notes5", "")%></td>
				</tr>
				<%} %> --%>
				
				<% } %>
				<% if(printutil.isNumberedOHRowActive(6)){%>
				<tr> <td> &nbsp;</td> </tr>
				<tr>
					<td colspan="2">Year: <%=props.getProperty("oh_year6", "")%>; 
					Outcome: <%=props.getProperty("oh_po6", "")%>; 
					Weeks: <%=props.getProperty("oh_weeks6", "")%>; 
					TTC: <%=props.getProperty("oh_toc6", "")%>; 
					<%if(props.getProperty("oh_treatment6", "")!=null && props.getProperty("oh_treatment6", "").length()>0){ %>
					Treatment: <%=props.getProperty("oh_treatment6", "").trim()%>;
					<%} %>
					<%if(props.getProperty("oh_notes6", "")!=null && props.getProperty("oh_notes6", "").length()>0){ %>
					Notes:
						<%=props.getProperty("oh_notes6", "")%>
					<%} %>
					</td>
				</tr>
				<%-- <tr>
					<td width="10%" VALIGN="top">Treatment:</td>
					<td><%=props.getProperty("oh_treatment6", "")%></td>
				</tr> --%>
				<%-- <%if(props.getProperty("oh_notes6", "")!=null && props.getProperty("oh_notes6", "").length()>0){ %>
				<tr>
					<td width="10%" VALIGN="top">Notes:</td>
					<td><%=props.getProperty("oh_notes6", "")%></td>
				</tr>
				<%} %> --%>
				
				<% } %>
				<% if(printutil.isNumberedOHRowActive(7)){%>
				<tr> <td> &nbsp;</td> </tr>
				<tr>
					<td colspan="2">Year: <%=props.getProperty("oh_year7", "")%>; 
					Outcome: <%=props.getProperty("oh_po7", "")%>; 
					Weeks: <%=props.getProperty("oh_weeks7", "")%>; 
					TTC: <%=props.getProperty("oh_toc7", "")%>; 
					<%if(props.getProperty("oh_treatment7", "")!=null && props.getProperty("oh_treatment7", "").length()>0){ %>
					Treatment: <%=props.getProperty("oh_treatment7", "").trim()%>;
					<%} %>
					<%if(props.getProperty("oh_notes7", "")!=null && props.getProperty("oh_notes7", "").length()>0){ %>
					Notes:
						<%=props.getProperty("oh_notes7", "")%>
					<%} %>
					</td>
				</tr>
			<%-- 	<tr>
					<td width="10%" VALIGN="top">Treatment:</td>
					<td><%=props.getProperty("oh_treatment7", "")%></td>
				</tr> --%>
				<%-- <%if(props.getProperty("oh_notes7", "")!=null && props.getProperty("oh_notes7", "").length()>0){ %>
				<tr>
					<td width="10%" VALIGN="top">Notes:</td>
					<td><%=props.getProperty("oh_notes7", "")%></td>
				</tr>
				<%} %> --%>
				
				<% } %>
				<% if(printutil.isNumberedOHRowActive(8)){%>
				<tr> <td> &nbsp;</td> </tr>
				<tr>
					<td colspan="2">Year: <%=props.getProperty("oh_year8", "")%>; 
					Outcome: <%=props.getProperty("oh_po8", "")%>; 
					Weeks: <%=props.getProperty("oh_weeks8", "")%>; 
					TTC: <%=props.getProperty("oh_toc8", "")%>; 
					<%if(props.getProperty("oh_treatment8", "")!=null && props.getProperty("oh_treatment8", "").length()>0){ %>
					Treatment: <%=props.getProperty("oh_treatment8", "").trim()%>;
					<%} %>
					<%if(props.getProperty("oh_notes8", "")!=null && props.getProperty("oh_notes8", "").length()>0){ %>
					Notes:
						<%=props.getProperty("oh_notes8", "")%>
					<%} %>
					</td>
				</tr>
				<%-- <tr>
					<td width="10%" VALIGN="top">Treatment:</td>
					<td><%=props.getProperty("oh_treatment8", "")%></td>
				</tr> --%>
				<%-- <%if(props.getProperty("oh_notes8", "")!=null && props.getProperty("oh_notes8", "").length()>0){ %>
				<tr>
					<td width="10%" VALIGN="top">Notes:</td>
					<td><%=props.getProperty("oh_notes8", "")%></td>
				</tr>
				<%} %> --%>
				
				<% } %>
				<% if(printutil.isNumberedOHRowActive(9)){%>
				<tr> <td> &nbsp;</td> </tr>
				<tr>
					<td colspan="2">Year: <%=props.getProperty("oh_year9", "")%>; 
					Outcome: <%=props.getProperty("oh_po9", "")%>; 
					Weeks: <%=props.getProperty("oh_weeks9", "")%>; 
					TTC: <%=props.getProperty("oh_toc9", "")%>;
					<%if(props.getProperty("oh_treatment9", "")!=null && props.getProperty("oh_treatment9", "").length()>0){ %> 
					Treatment: <%=props.getProperty("oh_treatment9", "").trim()%>;
					<%} %>
					<%if(props.getProperty("oh_notes9", "")!=null && props.getProperty("oh_notes9", "").length()>0){ %>
					Notes:
						<%=props.getProperty("oh_notes9", "")%>
					<%} %>
					</td>
				</tr>
				<%-- <tr>
					<td width="10%" VALIGN="top">Treatment:</td>
					<td><%=props.getProperty("oh_treatment9", "")%></td>
				</tr> --%>
				<%-- <%if(props.getProperty("oh_notes9", "")!=null && props.getProperty("oh_notes9", "").length()>0){ %>
				<tr>
					<td width="10%" VALIGN="top">Notes:</td>
					<td><%=props.getProperty("oh_notes9", "")%></td>
				</tr>
				<%} %> --%>
				
				<% } %>
				<% if(printutil.isNumberedOHRowActive(10)){%>
				<tr> <td> &nbsp;</td> </tr>
				<tr>
					<td colspan="2">Year: <%=props.getProperty("oh_year10", "")%>; 
					Outcome: <%=props.getProperty("oh_po10", "")%>; 
					Weeks: <%=props.getProperty("oh_weeks10", "")%>; 
					TTC: <%=props.getProperty("oh_toc10", "")%>; 
					<%if(props.getProperty("oh_treatment10", "")!=null && props.getProperty("oh_treatment10", "").length()>0){ %>
					Treatment: <%=props.getProperty("oh_treatment10", "").trim()%>;
					<%} %>
					<%if(props.getProperty("oh_notes10", "")!=null && props.getProperty("oh_notes10", "").length()>0){ %>
					Notes:
						<%=props.getProperty("oh_notes10", "")%>
					<%} %>
					</td>
				</tr>
			<%-- 	<tr>
					<td width="10%" VALIGN="top">Treatment:</td>
					<td><%=props.getProperty("oh_treatment10", "")%></td>
				</tr> --%>
				<%-- <%if(props.getProperty("oh_notes10", "")!=null && props.getProperty("oh_notes10", "").length()>0){ %>
				<tr>
					<td width="10%" VALIGN="top">Notes:</td>
					<td><%=props.getProperty("oh_notes10", "")%></td>
				</tr>
				<%} %> --%>
				<% } %>
				
			</table>
			</td>
		</tr>

		<tr>
			<td>&nbsp;</td>
		</tr>
		<!-- <tr>
		<td class="bottomBorder">&nbsp;</td> 
		</tr> -->
		<% } %>
<% if(printutil.isMASHGroupActive()){ %>
		<tr>
			<td height="10px" style="border-bottom: 1px solid black;"><b>Medical
			and Surgical History:</b></td>
		</tr>
		<tr>
			<td><%=props.getProperty("mash_t", "")%>
			</td>
		</tr>

		<tr>
			<td>&nbsp;</td>
		</tr>
		<!-- <tr>
		<td class="bottomBorder">&nbsp;</td> 
		</tr> -->
<% } %>
<% if(printutil.isPAMGroupActive()){ %>
		<tr>
			<td height="10px" style="border-bottom: 1px solid black;"><b>Prescriptions
			and Medications:</b></td>
		</tr>
		<tr>
			<td><%=props.getProperty("pam_t", "")%>
			</td>
		</tr>

		<tr>
			<td>&nbsp;</td>
		</tr>
		<!-- <tr>
		<td class="bottomBorder">&nbsp;</td> 
		</tr> -->
<% } %>
<% if(printutil.isAllergiesGroupActive()){ %>
		<tr>
			<td height="10px" style="border-bottom: 1px solid black;"><b>Allergies:</b></td>
		</tr>
		<tr>
			<td><%=props.getProperty("allergies_t", "")%>
			</td>
		</tr>

		<tr>
			<td>&nbsp;</td>
		</tr>
		<!-- <tr>
		<td class="bottomBorder">&nbsp;</td> 
		</tr> -->
<% } %>
<% if(printutil.isFHGroupActive()){ %>
		<tr>
			<td height="10px" style="border-bottom: 1px solid black;"><b>Family
			History:</b></td>
		</tr>
		<tr>
			<td><%=props.getProperty("fh_t", "")%>
			</td>
		</tr>

		<tr>
			<td>&nbsp;</td>
		</tr>
		<!-- <tr>
		<td class="bottomBorder">&nbsp;</td> 
		</tr> -->
<% } %>
<% if(printutil.isSHGroupActive()){ %>
		<tr>
			<td style="border-bottom: 1px solid black;">
			<div class="section_title">
			<font size="3"><b>Social
			History:</b></font> &nbsp;&nbsp;
			</div>
			</td>
		</tr>

		<tr>
			<td height="10px">
			
			<!-- </td>
		</tr>
		<tr>
			<td> -->
			
			<% if(printutil.isActive("sh_occupation")){%>
			<div class="reason_div">
			<input type="checkbox" name="sh_occupation" onchange="toggleControl(document.forms[0].sh_occupation,document.forms[0].sh_occupation_t)"
				<%=props.getProperty("sh_occupation", "")%>>Occupation&nbsp;&nbsp;<%=props.getProperty("sh_occupation_t", "")%>
			</div>
			<% } %>
			
			<% if(printutil.isActive("sh_smoker")){%>
			<div class="reason_div">
			<input type="checkbox" name="sh_smoker" onchange="toggleControl(document.forms[0].sh_smoker,document.forms[0].sh_smoker_t)"
				<%=props.getProperty("sh_smoker", "")%>>Smoker&nbsp;&nbsp;<%=props.getProperty("sh_smoker_t", "")%>
			</div>
			<% } %>
			<% if(printutil.isActive("sh_non_smoker")){%>
			<div class="reason_div">
			<input type="checkbox" name="sh_non_smoker" 
				<%=props.getProperty("sh_non_smoker", "")%>>Non-smoker
			</div>
			<% } %>
			
			<% if(printutil.isActive("sh_alcohol")){%>
			<div class="reason_div">
			<input type="checkbox" name="sh_alcohol" onchange="toggleControl(document.forms[0].sh_alcohol,document.forms[0].sh_alcohol_t)"
				<%=props.getProperty("sh_alcohol", "")%>>
			Alcohol&nbsp;&nbsp;<%=props.getProperty("sh_alcohol_t", "")%>
			</div>
			<% } %>
			<% if(printutil.isActive("sh_drugs")){%>
			<div class="reason_div">
			<input type="checkbox" name="sh_drugs" onchange="toggleControl(document.forms[0].sh_drugs,document.forms[0].sh_drugs_t)"
				<%=props.getProperty("sh_drugs", "")%>>Drugs&nbsp;&nbsp;<%=props.getProperty("sh_drugs_t", "")%>
			</div>
			<% } %>
			</td>
		</tr>
		<% if(printutil.isActive("sh_other")){%>
		<tr>
			<td>
			<!-- Other<br> -->
			<%=props.getProperty("sh_other", "")%><br>
			</td>
		</tr>
		<% } %>
		<tr>
			<td>&nbsp;</td>
		</tr>
		<!-- <tr>
		<td class="bottomBorder">&nbsp;</td> 
		</tr> -->
<% } %>
<% if(printutil.isMFGroupActive()){ %>
		<tr>
			<td style="border-bottom: 1px solid black;">
			<div class="section_title">
			<font size="3"><b>Male / Partner 
			Factors:</b></font>
			</div>
			</td>
		</tr>

		<tr>
			<td height="10px">
			
			
			<!-- </td>
		</tr>
		<tr>
			<td> -->
			
			<% if(printutil.isActive("rfhmf_maleocc")){%>
			<div class="reason_div">
			<input type="checkbox" name="rfhmf_maleocc" onchange="toggleControl(document.forms[0].rfhmf_maleocc,document.forms[0].rfhmf_maleocc_t)" 
				<%=props.getProperty("rfhmf_maleocc", "")%>>Occupation:&nbsp;<%=props.getProperty("rfhmf_maleocc_t", "")%>
				</div>
			<%  } %>
			<% if(printutil.isActive("rfhmf_fp")){%>
			<div class="reason_div">
			<input type="checkbox" name="rfhmf_fp" onchange="toggleControl(document.forms[0].rfhmf_fp,document.forms[0].rfhmf_fp_t)" 
				<%=props.getProperty("rfhmf_fp", "")%>>Fathered:&nbsp;<%=props.getProperty("rfhmf_fp_t", "")%>&nbsp;&nbsp;pregnancy / pregnancies
				</div>
			<%  } %>
			<% if(printutil.isActive("rfhmf_nsa")){%>
			<div class="reason_div">
			<input type="checkbox" name="rfhmf_nsa"
				<%=props.getProperty("rfhmf_nsa", "")%>>Normal semen
			analysis
			</div>
			<%  } %>
			<% if(printutil.isActive("rfhmf_asa")){%>
			<div class="reason_div">
			<input type="checkbox" name="rfhmf_asa" onchange="toggleControl(document.forms[0].rfhmf_asa,document.forms[0].rfhmf_asa_t)"
				<%=props.getProperty("rfhmf_asa", "")%>>Abnormal semen
			analysis:&nbsp;<%=props.getProperty("rfhmf_asa_t", "")%>
			</div>
			<%  } %>
			<% if(printutil.isActive("rfhmf_azoospermia")){%>
			<div class="reason_div">
			<input type="checkbox" name="rfhmf_azoospermia"
				<%=props.getProperty("rfhmf_azoospermia", "")%>>Azoospermia
				</div>
			<%  } %>
			<% if(printutil.isActive("rfhmf_hov")){%>
			<div class="reason_div">
			<input type="checkbox" name="rfhmf_hov" onchange="toggleControl(document.forms[0].rfhmf_hov,document.forms[0].rfhmf_hov_t)"
				<%=props.getProperty("rfhmf_hov", "")%>>History of
			vasectomy:&nbsp;<%=props.getProperty("rfhmf_hov_t", "")%>
			</div>
			<%  } %>
			<% if(printutil.isActive("rfhmf_hovr")){%>
			<div class="reason_div">
			<input type="checkbox" name="rfhmf_hovr" onchange="toggleControl(document.forms[0].rfhmf_hovr,document.forms[0].rfhmf_hovr_t)"
				<%=props.getProperty("rfhmf_hovr", "")%>>History of
			vasectomy reversal:&nbsp;<%=props.getProperty("rfhmf_hovr_t", "")%>
			</div>
			<%  } %>
			<% if(printutil.isActive("rfhmf_hout")){%>
			<div class="reason_div">
			<input type="checkbox" name="rfhmf_hout" onchange="toggleControl(document.forms[0].rfhmf_hout,document.forms[0].rfhmf_hout_t)"
				<%=props.getProperty("rfhmf_hout", "")%>>History of
			undescended:&nbsp;<%=props.getProperty("rfhmf_hout_t", "")%>&nbsp;testicle
			</div>
			<%  } %>
			<% if(printutil.isActive("rfhmf_oat")){%>
			<div class="reason_div">
			<input type="checkbox" name="rfhmf_oat" onchange="toggleControl(document.forms[0].rfhmf_oat,document.forms[0].rfhmf_oat_t)"
				<%=props.getProperty("rfhmf_oat", "")%>>Orchipexy
			at:&nbsp;<%=props.getProperty("rfhmf_oat_t", "")%>
			</div>
			<%  } %>
			<% if(printutil.isActive("rfhmf_hoo")){%>
			<div class="reason_div">
			<input type="checkbox" name="rfhmf_hoo"
				<%=props.getProperty("rfhmf_hoo", "")%>>History of orchitis
				</div>
			<%  } %>
			<%-- <% if(printutil.isActive("rfhmf_ge")){%>
			<div class="reason_div">
			<input type="checkbox" name="rfhmf_ge" onchange="toggleControl(document.forms[0].rfhmf_ge,document.forms[0].rfhmf_ge_t)"
				<%=props.getProperty("rfhmf_ge", "")%>>Gonadotoxic
			exposure&nbsp;&nbsp;<%=props.getProperty("rfhmf_ge_t", "")%>
			</div>
			
			<%  } %> --%>
			</td>
		</tr>

		<tr>
			<td>
			
			<% if(printutil.isActive("rfhmf_ge")){%>
			
			<div class="reason_div">
			<input type="checkbox" name="rfhmf_ge" onchange="toggleControl(document.forms[0].rfhmf_ge,document.forms[0].rfhmf_ge_t)"
				<%=props.getProperty("rfhmf_ge", "")%>>Gonadotoxic
			exposure:&nbsp;<%=props.getProperty("rfhmf_ge_t", "")%>
			</div>
			<!-- </td>
			</tr> -->
			<%  } %>

		<!-- <tr>
			<td>
			<div style="padding-left: 15px;"> -->
			
			<% if(printutil.isActive("rfhmf_ge_alcohol")){%>
			<div class="reason_div" >
			<input type="checkbox"
				name="rfhmf_ge_alcohol" <%=props.getProperty("rfhmf_ge_alcohol", "")%>>Alcoholic drinks per week <%=props.getProperty("rfhmf_ge_alcohol_t", "")%> </div>
			<%  } %>
			
			<% if(printutil.isActive("rfhmf_ge_marijuana")){%>
			<div class="reason_div" >
			<input type="checkbox"
				name="rfhmf_ge_marijuana" <%=props.getProperty("rfhmf_ge_marijuana", "")%>
				>Marijuana:&nbsp;<%=props.getProperty("rfhmf_ge_marijuana_t", "")%>
			</div>
			<%  } %>
		
			<% if(printutil.isActive("rfhmf_ge_smoker")){%>
			<div class="reason_div" >
			<input type="checkbox"
				name="rfhmf_ge_smoker" <%=props.getProperty("rfhmf_ge_smoker", "")%>
				>Smoker:&nbsp;<%=props.getProperty("rfhmf_ge_smoker_t", "")%>
			</div>
			<%  } %>
			
			<% if(printutil.isActive("rfhmf_ge_smoker_non")){%>
			<div class="reason_div" >
			<input type="checkbox"
				name="rfhmf_ge_smoker_non" <%=props.getProperty("rfhmf_ge_smoker_non", "")%>>non-smoker
			<!-- &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; -->
			</div>
			<%  } %>
			
			<% if(printutil.isActive("rfhmf_ge_saunas")){%>
			<div class="reason_div" >
			<input type="checkbox" name="rfhmf_ge_saunas"
				<%=props.getProperty("rfhmf_ge_saunas", "")%>>Hot tubs / saunas
				</div>
			<%  } %>
			
			<% if(printutil.isActive("rfhmf_ge_saunas")){%>
			<div class="reason_div" >
			<input type="checkbox" name="rfhmf_ge_saunas_d"
				<%=props.getProperty("rfhmf_ge_saunas_d", "")%>>denies hot tubs / sauna use
				</div>
			<%  } %>
			
			<% if(printutil.isActive("rfhmf_ge_degreasers")){%>
			<div class="reason_div" >
			<input type="checkbox" name="rfhmf_ge_degreasers"
				<%=props.getProperty("rfhmf_ge_degreasers", "")%>>Degreasers or
			solvents </div>
			<%  } %>
			
			
			<!-- </td>
		</tr>
		<tr><td> -->
		
		<!-- </div> -->
		</td>
		</tr>
		<tr>
			<td>&nbsp;</td>
		</tr>
		<% if(printutil.isActive("rfhmf_mmh")){%>
		<tr>
			<td><font size="3"><b>Male / Partner Medical History:</b></font>&nbsp;
			
			<!-- </td>
		</tr>
		<tr>
			<td> -->
			
			<%=props.getProperty("rfhmf_mmh", "")%></td>
		</tr>
		<!-- <tr>
			<td>&nbsp;</td>
		</tr> -->
		<%  } %>
		<% if(printutil.isActive("rfhmf_mm")){%>
		<tr>
			<td height="10px"><font size="3"><b>Male / Partner Prescription:</b></font>&nbsp;
			
			<!-- </td>
		</tr>
		<tr>
			<td> -->
			<%=props.getProperty("rfhmf_mm", "")%></td>
		</tr>
		<!-- <tr>
			<td>&nbsp;</td>
		</tr> -->
		<%  } %>
		<% if(printutil.isActive("rfhmf_ma")){%>
		<tr>
			<td height="10px"><font size="3"><b>Male / Partner Allergies:</b></font>&nbsp;
			<!-- </td>
		</tr>
		<tr>
			<td> --><%=props.getProperty("rfhmf_ma", "")%></td>
		</tr>
		<!-- <tr>
			<td>&nbsp;</td>
		</tr> -->
		<%  } %>
		<% if(printutil.isActive("rfhmf_mfh")){%>
		<tr>
			<td height="10px"><font size="3"><b>Male / Partner Family History:</b></font>&nbsp;
			<!-- </td>
		</tr>
		<tr>
			<td> --><%=props.getProperty("rfhmf_mfh", "")%></td>
		</tr>
		<!-- <tr>
			<td>&nbsp;</td>
		</tr> -->
		<%  } %>
		<% if(printutil.isActive("rfhmf_other")){%>
		<tr>
			<td>
			<!-- Other :  -->
			<%=props.getProperty("rfhmf_other", "")%>
			<br></td>
		</tr>
		<%  } %>
		<tr>
			<td>&nbsp;</td>
		</tr>
		<!-- <tr>
		<td class="bottomBorder">&nbsp;</td> 
		</tr> -->
		<% } %>

<% if(printutil.isPEGroupActive()){ %>
		<tr>
			<td height="10px" style="border-bottom: 1px solid black;"><b>Physical
			Exam:</b></td>
		</tr>
		
		<%if(props.getProperty("pe_ht", "").trim().length()>0 
			|| props.getProperty("pe_ht_uom_t", "").trim().length()>0
			|| props.getProperty("pe_inch_t", "").trim().length()>0
			|| props.getProperty("pe_ht_t", "").trim().length()>0
			|| props.getProperty("pe_weight", "").trim().length()>0
			|| props.getProperty("pe_weight_t", "").trim().length()>0
			
			|| props.getProperty("pe_bmi", "").trim().length()>0
			|| props.getProperty("pe_bmi_t", "").trim().length()>0
			|| props.getProperty("pe_bp", "").trim().length()>0
			|| props.getProperty("pe_bp_t", "").trim().length()>0
			|| props.getProperty("pe_ngpe", "").trim().length()>0
			
			|| props.getProperty("pe_gpef_t", "").trim().length()>0
			|| props.getProperty("pe_npe", "").trim().length()>0
			|| props.getProperty("pe_pef", "").trim().length()>0
			|| props.getProperty("pe_pef_t", "").trim().length()>0
			) {%>
			
		<tr><td>
		<div class="section_title">
		<font size="3"><b>Female</b></font>
		</div>
		<!-- </td></tr>
		<tr>
			<td> -->
			
			<% if(printutil.isActive("pe_ht")){%>
			<div class="reason_div">
			<input type="checkbox" name="pe_ht" onchange="toggleControl(document.forms[0].pe_ht,document.forms[0].pe_ht_t)
			;toggleControl(document.forms[0].pe_ht,document.forms[0].pe_ht_uom_t)"
				<%=props.getProperty("pe_ht", "")%>>Ht&nbsp;
				<% if("feet".equals(props.getProperty("pe_ht_uom_t", ""))){%>
							<%=props.getProperty("pe_ht_t", "")%>&nbsp;ft
							<% if(!"".equals(props.getProperty("pe_inch_t", ""))){%>
								&nbsp;<%=props.getProperty("pe_inch_t", "")%>&nbsp;in
							<%} %>
				<%}  else { %>
							<%=props.getProperty("pe_ht_t", "")%>&nbsp;cm
				<%}  %>
		</div>
			<% } %>
			<% if(printutil.isActive("pe_weight")){%>
			<div class="reason_div">
			<input type="checkbox" name="pe_weight" onchange="toggleControl(document.forms[0].pe_weight,document.forms[0].pe_weight_t)
			;toggleControl(document.forms[0].pe_ht,document.forms[0].pe_weight_uom_t)"
				<%=props.getProperty("pe_weight", "")%>>Wt&nbsp;
				<%=props.getProperty("pe_weight_t", "")%>
				&nbsp;
				<%=props.getProperty("pe_weight_uom_t", "")%>
			</div>
			<% } %>
			<% if(printutil.isActive("pe_bmi")){%>
			<div class="reason_div">
			<input type="checkbox" name="pe_bmi" onchange="toggleControl(document.forms[0].pe_bmi,document.forms[0].pe_bmi_t)"
				<%=props.getProperty("pe_bmi", "")%>>BMI&nbsp;
				<%=props.getProperty("pe_bmi_t", "")%>
			</div>
			<% } %>
			<% if(printutil.isActive("pe_bp")){%>
			<div class="reason_div">
			<input type="checkbox" name="pe_bp" onchange="toggleControl(document.forms[0].pe_bp,document.forms[0].pe_bp_t)"
				<%=props.getProperty("pe_bp", "")%>>BP&nbsp;
				<%=props.getProperty("pe_bp_t", "")%>
			</div>
			
			<% } %>
			
			<!-- </td></tr>
			<tr><td>&nbsp;</td></tr>
			<tr><td> -->
			
			<% if(printutil.isActive("pe_ngpe")){%>
			<div class="reason_div">
			<input type="checkbox" name="pe_ngpe"
				<%=props.getProperty("pe_ngpe", "")%>>Normal general
			physical exam</div>
			<% } %>
			
			<% if(printutil.isActive("pe_nthe")){%>
			<div class="reason_div">
			<input type="checkbox" name="pe_nthe"
				<%=props.getProperty("pe_nthe", "")%>>Normal thyroid exam</div>
			<% } %>
			
			<% if(printutil.isActive("pe_naus")){%>
			<div class="reason_div">
			<input type="checkbox" name="pe_naus"
				<%=props.getProperty("pe_naus", "")%>>Normal auscultation of lungs and heart</div>
			<% } %>
			
			<% if(printutil.isActive("pe_nabde")){%>
			<div class="reason_div">
			<input type="checkbox" name="pe_nabde"
				<%=props.getProperty("pe_nabde", "")%>>Normal abdominal exam</div>
			<% } %>
			
			<% if(printutil.isActive("pe_gpef")){%>
			<div>
			<input type="checkbox" name="pe_gpef" onchange="toggleControl(document.forms[0].pe_gpef,document.forms[0].pe_gpef_t)"
				<%=props.getProperty("pe_gpef", "")%>>General physical exam
			findings:&nbsp;<%=props.getProperty("pe_gpef_t", "")%>
			</div>
			<% } %>
			<% if(printutil.isActive("pe_npe")){%>
			<div class="reason_div">
			<input type="checkbox" name="pe_npe"
				<%=props.getProperty("pe_npe", "")%>>Normal pelvic exam</div>
			<% } %>
			<% if(printutil.isActive("pe_pef")){%>
			<div>
			<input type="checkbox" name="pe_pef" onchange="toggleControl(document.forms[0].pe_pef,document.forms[0].pe_pef_t)"
				<%=props.getProperty("pe_pef", "")%>>Pelvic exam
			findings:&nbsp;<%=props.getProperty("pe_pef_t", "")%>
			</div>
			<br>
			
			<% } %>
		
			</td></tr>
				<%} %>
			<!-- <tr><td>&nbsp;</td></tr> -->
			
			<%if(props.getProperty("pe_rt_testicle_size", "").trim().length()>0 
			|| props.getProperty("pe_rt_testicle_vas", "").trim().length()>0
			|| props.getProperty("pe_rt_testicle_varicocele", "").trim().length()>0
			|| props.getProperty("pe_lt_testicle_size", "").trim().length()>0
			|| props.getProperty("pe_lt_testicle_vas", "").trim().length()>0
			|| props.getProperty("pe_lt_testicle_varicocele", "").trim().length()>0
			) {%>
			
			<tr><td>
			<font size="3"><b>Male</b></font><br>
			
			<% if(printutil.isActive("pe_rt_testicle_size") || printutil.isActive("pe_rt_testicle_vasd") || printutil.isActive("pe_rt_testicle_varicocele")){%>
			-Rt testicle &nbsp;
			<% if(printutil.isActive("pe_rt_testicle_size")){%>
			<!-- &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; -->
			size:&nbsp;<%=props.getProperty("pe_rt_testicle_size", "")%>;
			<% } %>
			<% if(printutil.isActive("pe_rt_testicle_vas")){%>
			<!-- &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-&nbsp; -->
			vas:&nbsp;<%=props.getProperty("pe_rt_testicle_vas", "")%>;
			<% } %>
			<% if(printutil.isActive("pe_rt_testicle_varicocele")){%>
			<!-- &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-&nbsp; -->
			varicocele grade:&nbsp;<%=props.getProperty("pe_rt_testicle_varicocele", "")%>
			<% } %>
			<br>
			<% } %>
			
			<% if(printutil.isActive("pe_lt_testicle_size") || printutil.isActive("pe_lt_testicle_vas") || printutil.isActive("pe_lt_testicle_varicocele")){%>
			-Lt testicle &nbsp;
			<% if(printutil.isActive("pe_lt_testicle_size")){%>
			<!-- &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-&nbsp; -->
			size:&nbsp;<%=props.getProperty("pe_lt_testicle_size", "")%>;
			<% } %>
			<% if(printutil.isActive("pe_lt_testicle_vas")){%>
			<!-- &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-&nbsp; -->
			vas:&nbsp;<%=props.getProperty("pe_lt_testicle_vas", "")%>;
			<% } %>
			<% if(printutil.isActive("pe_lt_testicle_varicocele")){%>
			<!-- &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-&nbsp; -->
			varicocele grade:&nbsp;<%=props.getProperty("pe_lt_testicle_varicocele", "")%><br>
			<% } %>
			
			<% } %>	
			</td>
		</tr>
		<%} %>
		<% if(printutil.isActive("pe_other")){%>
		<tr>
			<td>
			<!-- Other<br> -->
			<%=props.getProperty("pe_other", "")%><br>
			</td>
		</tr>
		<% } %>	
		<tr>
			<td>&nbsp;</td>
		</tr>
		<!-- <tr>
		<td class="bottomBorder">&nbsp;</td> 
		</tr> -->
<% } %>
<% if(printutil.isImpressionGroupActive()){ %>

		<tr>
			<td style="border-bottom: 1px solid black;">
			<div class="section_title">
			<font size="3"><b>Impression:</b></font>
			</div>
			</td>
		</tr>
		
		<tr>
			<td height="10px">
			<!-- </td>
		</tr>
		<tr>
			<td> -->
			
			<% if(printutil.isActive("impression_piue")){%>
			<div class="reason_div">
			<input type="checkbox" name="impression_piue"
				<%=props.getProperty("impression_piue", "")%>>Primary
			infertility of unknown etiology
			</div>
			<% } %>	
			
			<% if(printutil.isActive("impression_pi")){%>
			<div class="reason_div">
			<input type="checkbox" name="impression_pi"
				<%=props.getProperty("impression_pi", "")%>>Primary infertility
			</div>
			<% } %>
			
			<% if(printutil.isActive("impression_siue")){%>
			<div class="reason_div">
			<input type="checkbox" name="impression_siue"
				<%=props.getProperty("impression_siue", "")%>>Secondary
			infertility of unknown etiology
			</div>
			<% } %>	
			
			<% if(printutil.isActive("impression_si")){%>
			<div class="reason_div">
			<input type="checkbox" name="impression_si"
				<%=props.getProperty("impression_si", "")%>>Secondary infertility
			</div>
			<% } %>
			
			<% if(printutil.isActive("impression_rplue")){%>
			<div class="reason_div">
			<input type="checkbox" name="impression_rplue"
				<%=props.getProperty("impression_rplue", "")%>>Recurrent
			pregnancy loss of unknown etiology
			</div>
			<% } %>	
			<% if(printutil.isActive("impression_od")){%>
			<div class="reason_div">
			<input type="checkbox" name="impression_od" onchange="toggleControl(document.forms[0].impression_od,document.forms[0].impression_od_t)"
				<%=props.getProperty("impression_od", "")%>>Ovulatory
			dysfunction:&nbsp;<%=props.getProperty("impression_od_t", "")%>
			</div>
			<% } %>	
			<% if(printutil.isActive("impression_pcos")){%>
			<div class="reason_div">
			<input type="checkbox" name="impression_pcos"
				<%=props.getProperty("impression_pcos", "")%>>PCOS
			</div>
			<% } %>	
			
			<% if(printutil.isActive("impression_endo")){%>
			<div class="reason_div">
			<input type="checkbox" name="impression_endo"
				<%=props.getProperty("impression_endo", "")%>>Endometriosis
			</div>
			<% } %>	
			
			<% if(printutil.isActive("impression_dor")){%>
			<div class="reason_div">
			<input type="checkbox" name="impression_dor"
				<%=props.getProperty("impression_dor", "")%>>Decreased
			ovarian reserve</div>
			<% } %>	
			<% if(printutil.isActive("impression_ama")){%>
			<div class="reason_div">
			<input type="checkbox" name="impression_ama"
				<%=props.getProperty("impression_ama", "")%>>Advanced
			maternal age</div>
			<% } %>	
			<% if(printutil.isActive("impression_poi")){%>
			<div class="reason_div">
			<input type="checkbox" name="impression_poi"
				<%=props.getProperty("impression_poi", "")%>>Premature
			ovarian insufficiency</div>
			<% } %>	
			<% if(printutil.isActive("impression_tfi")){%>
			<div class="reason_div">
			<input type="checkbox" name="impression_tfi"
				<%=props.getProperty("impression_tfi", "")%>>Tubal factor
			infertility</div>
			<% } %>	
			<% if(printutil.isActive("impression_mfi")){%>
			<div class="reason_div">
			<input type="checkbox" name="impression_mfi"
				<%=props.getProperty("impression_mfi", "")%>>Male factor
			infertility</div>
			<% } %>	
			<% if(printutil.isActive("impression_cfi")){%>
			<div class="reason_div">
			<input type="checkbox" name="impression_cfi"
				<%=props.getProperty("impression_cfi", "")%>>Coital factor
			infertility</div>
			<% } %>	
			
			<% if(printutil.isActive("impression_azoospermia")){%>
			<div class="reason_div">
			<input type="checkbox" name="impression_azoospermia"
				<%=props.getProperty("impression_azoospermia", "")%>><%-- <%=props.getProperty("impression_azoospermia_t", "")%>  --%>Azoospermia</div>
			<% } %>
			
			<% if(printutil.isActive("impression_azoospermia_o")){%>
			<div class="reason_div">
			<input type="checkbox" name="impression_azoospermia_o"
				<%=props.getProperty("impression_azoospermia_o", "")%>>Obstructive azoospermia</div>
			<% } %>	
			
			<% if(printutil.isActive("impression_azoospermia_n_o")){%>
			<div class="reason_div">
			<input type="checkbox" name="impression_azoospermia_n_o"
				<%=props.getProperty("impression_azoospermia_n_o", "")%>>Non-Obstructive azoospermia</div>
			<% } %>
			
			<% if(printutil.isActive("impression_ha")){%>
			<div class="reason_div">
			<input type="checkbox" name="impression_ha"
				<%=props.getProperty("impression_ha", "")%>>Hypothalamic
			anovulation</div>
			<% } %>	
			<% if(printutil.isActive("impression_sfrdp")){%>
			<div class="reason_div">
			<input type="checkbox" name="impression_sfrdp"
				<%=props.getProperty("impression_sfrdp", "")%>>Single
			female requesting donor sperm</div>
			<% } %>	
			<% if(printutil.isActive("impression_sscrds")){%>
			<div class="reason_div">
			<input type="checkbox" name="impression_sscrds"
				<%=props.getProperty("impression_sscrds", "")%>>Same sex
			couple requesting donor sperm</div>
			<% } %>	
			<% if(printutil.isActive("impression_fo")){%>
			<div class="reason_div">
			<input type="checkbox" name="impression_fo"
				<%=props.getProperty("impression_fo", "")%>>Female obesity</div>
			<% } %>	
			<% if(printutil.isActive("impression_mo")){%>
			<div class="reason_div">
			<input type="checkbox" name="impression_mo"
				<%=props.getProperty("impression_rfsc", "")%>>Male obesity</div>
			<% } %>	
			<% if(printutil.isActive("impression_rfsc")){%>
			<div class="reason_div">
			<input type="checkbox" name="impression_rfsc" onchange="toggleControl(document.forms[0].impression_rfsc,document.forms[0].impression_rfsc_t)"
				<%=props.getProperty("impression_rfsc", "")%>>Request for
			sperm cryopreservation:&nbsp;<%=props.getProperty("impression_rfsc_t", "")%></div>
			<% } %>	
			<% if(printutil.isActive("impression_rfoc")){%>
			<div class="reason_div">
			<input type="checkbox" name="impression_rfoc" onchange="toggleControl(document.forms[0].impression_rfoc,document.forms[0].impression_rfoc_t)"
				<%=props.getProperty("impression_rfoc", "")%>>Request for
			oocyte cryopreservation:&nbsp;<%=props.getProperty("impression_rfoc_t", "")%>
			</div>
			<% } %>	
			</td>
		</tr>
		<% if(printutil.isActive("impression_other")){%>
		<tr>
			<td>
			<!-- Other<br> -->
			<%=props.getProperty("impression_other", "")%><br>
			</td>
		</tr>
		<% } %>	
		<tr>
			<td>&nbsp;</td>
		</tr>
		<!-- <tr>
		<td class="bottomBorder">&nbsp;</td> 
		</tr> -->
<% } %>
<% if(printutil.isOptDGroupActive()){ %>

		<tr>
			<td style="border-bottom: 1px solid black;">
			<div class="section_title">
			<font size="3"><b>Options
			Discussed:</b></font>
			</div>				
			</td>
		</tr>

		<tr>
			<td height="10px">
			
			<!-- </td>
		</tr>
		<tr>
			<td> -->
			
			<% if(printutil.isActive("optd_em")){%>
			<div class="reason_div">
			<input type="checkbox" name="optd_em"
				<%=props.getProperty("optd_em", "")%>>Expectant management</div>
			<% } %>	
			<% if(printutil.isActive("optd_oiv")){%>
			<div class="reason_div">
			<input type="checkbox" name="optd_oiv" onchange="toggleControl(document.forms[0].optd_oiv,document.forms[0].optd_oiv_t)"
				<%=props.getProperty("optd_oiv", "")%>>Ovulation induction
			with:&nbsp;<%=props.getProperty("optd_oiv_t", "")%>
			</div>
			<% } %>	
			<% if(printutil.isActive("optd_saii")){%>
			<div class="reason_div">
			<input type="checkbox" name="optd_saii"
				<%=props.getProperty("optd_saii", "")%>>Superovulation and
			intrauterine insemination
			</div>
			<% } %>	
			<% if(printutil.isActive("optd_ivf")){%>
			<div class="reason_div">
			<input type="checkbox" name="optd_ivf"
				<%=props.getProperty("optd_ivf", "")%>>IVF
				</div>
			<% } %>	
			<% if(printutil.isActive("optd_ivficsi")){%>
			<div class="reason_div">
			<input type="checkbox" name="optd_ivficsi"
				<%=props.getProperty("optd_ivficsi", "")%>>IVF with ICSI</div>
			<% } %>	
			<% if(printutil.isActive("optd_ivficsi_tse")){%>
			<div class="reason_div">
			<input type="checkbox" name="optd_ivficsi_tse"
				<%=props.getProperty("optd_ivficsi_tse", "")%>>IVF with
			ICSI and testicular sperm extraction</div>
			<% } %>	
			<% if(printutil.isActive("optd_laparoscopy")){%>
			<div class="reason_div">
			<input type="checkbox" name="optd_laparoscopy"
				<%=props.getProperty("optd_laparoscopy", "")%>>Laparoscopy</div>
			<% } %>	
			<% if(printutil.isActive("optd_myomectomy")){%>
			<div class="reason_div">
			<input type="checkbox" name="optd_myomectomy"
				<%=props.getProperty("optd_myomectomy", "")%>>Myomectomy</div>
			<% } %>	
			<% if(printutil.isActive("optd_dsi")){%>
			<div class="reason_div">
			<input type="checkbox" name="optd_dsi"
				<%=props.getProperty("optd_dsi", "")%>>Donor sperm
			insemination</div>
			<% } %>	
			<% if(printutil.isActive("optd_det")){%>
			<div class="reason_div">
			<input type="checkbox" name="optd_det"
				<%=props.getProperty("optd_det", "")%>>Donor egg therapy</div>
			<% } %>	
			<% if(printutil.isActive("optd_rotl")){%>
			<div class="reason_div">
			<input type="checkbox" name="optd_rotl"
				<%=props.getProperty("optd_rotl", "")%>>Reversal of tubal
			ligation</div>
			<% } %>	
			<% if(printutil.isActive("optd_vr")){%>
			<div class="reason_div">
			<input type="checkbox" name="optd_vr"
				<%=props.getProperty("optd_vr", "")%>>Vasectomy Reversal</div>
			<% } %>	
			<% if(printutil.isActive("optd_lc")){%>
			<div class="reason_div">
			<input type="checkbox" name="optd_lc"
				<%=props.getProperty("optd_lc", "")%>>Lifestyle changes</div>
			<% } %>	
			<% if(printutil.isActive("optd_wl")){%>
			<div class="reason_div">
			<input type="checkbox" name="optd_wl"
				<%=props.getProperty("optd_wl", "")%>>Weight loss</div>
			<% } %>	
			<% if(printutil.isActive("optd_adoption")){%>
			<div class="reason_div">
			<input type="checkbox" name="optd_adoption"
				<%=props.getProperty("optd_adoption", "")%>>Adoption</div>
			<% } %>	
			<% if(printutil.isActive("optd_sc")){%>
			<div class="reason_div">
			<input type="checkbox" name="optd_sc"
				<%=props.getProperty("optd_sc", "")%>>Sperm
			cryopreservation</div>
			<% } %>	
			<% if(printutil.isActive("optd_oc")){%>
			<div class="reason_div">
			<input type="checkbox" name="optd_oc"
				<%=props.getProperty("optd_oc", "")%>>Oocyte
			cryopreservation</div>
			<% } %>	
			<% if(printutil.isActive("optd_ec")){%>
			<div class="reason_div">
			<input type="checkbox" name="optd_ec"
				<%=props.getProperty("optd_ec", "")%>>Embryo
			cryopreservation</div>
			<% } %>	
			<% if(printutil.isActive("optd_oswga")){%>
			<div class="reason_div">
			<input type="checkbox" name="optd_oswga"
				<%=props.getProperty("optd_oswga", "")%>>Ovarian
			suppression with a GnRH agonist</div>
			<% } %>	
			</td>
		</tr>
		<% if(printutil.isActive("optd_other")){%>
		<tr>
			<td>
			<!-- Other<br> -->
			<%=props.getProperty("optd_other", "")%><br>
			</td>
		</tr>
<% } %>	
		<tr>
			<td>&nbsp;</td>
		</tr>
		<!-- <tr>
		<td class="bottomBorder">&nbsp;</td> 
		</tr> -->
<% } %>
<% if(printutil.isIOGroupActive()){ %>

		<tr>
			<td style="border-bottom: 1px solid black;">
			<div class="section_title">
			<font size="3"><b>Investigations
			Ordered:</b></font>
			</div>
			</td>
		</tr>

		<tr>
			<td height="10px">
			
			<!-- </td>
		</tr>
		<tr>
			<td> -->
			
			<% if(printutil.isActive("io_3hp")){%>
			<div class="reason_div">
			<input type="checkbox" name="io_3hp"
				<%=props.getProperty("io_3hp", "")%>>Day 3 hormonal profile</div>
			<% } %>	
			<% if(printutil.isActive("io_lpp")){%>
			<div class="reason_div">
			<input type="checkbox" name="io_lpp"
				<%=props.getProperty("io_lpp", "")%>>Luteal phase
			progesterone</div>
			<% } %>	
			<% if(printutil.isActive("io_buafc")){%>
			<div class="reason_div">
			<input type="checkbox" name="io_buafc"
				<%=props.getProperty("io_buafc", "")%>>Baseline ultrasound
			with antral follicle count</div>
			<% } %>	
			<% if(printutil.isActive("io_tpu")){%>
			<div class="reason_div">
			<input type="checkbox" name="io_tpu"
				<%=props.getProperty("io_tpu", "")%>>Tubal patency
			ultrasound</div>
			<% } %>	
			<% if(printutil.isActive("io_siuauc")){%>
			<div class="reason_div">
			<input type="checkbox" name="io_siuauc"
				<%=props.getProperty("io_siuauc", "")%>>Saline infusion
			ultrasound to assess uterine cavity</div>
			<% } %>	
			<% if(printutil.isActive("io_ids")){%>
			<div class="reason_div">
			<input type="checkbox" name="io_ids"
				<%=props.getProperty("io_ids", "")%>>Infectious disease
			screening</div>
			<% } %>	
			<% if(printutil.isActive("io_sa")){%>
			<div class="reason_div">
			<input type="checkbox" name="io_sa"
				<%=props.getProperty("io_sa", "")%>>Semen analysis</div>
			<% } %>	
			<% if(printutil.isActive("io_ksa")){%>
			<div class="reason_div">
			<input type="checkbox" name="io_ksa"
				<%=props.getProperty("io_ksa", "")%>>Kruger semen analysis</div>
			<% } %>	
			<% if(printutil.isActive("io_apat")){%>
			<div class="reason_div">
			<input type="checkbox" name="io_apat"
				<%=props.getProperty("io_apat", "")%>>Anti-phospholipid
			antibody testing</div>
			<% } %>	
			<% if(printutil.isActive("io_tt")){%>
			<div class="reason_div">
			<input type="checkbox" name="io_tt"
				<%=props.getProperty("io_tt", "")%>>Thrombophilia testing</div>
			<% } %>	
			<% if(printutil.isActive("io_karyotype")){%>
			<div class="reason_div">
			<input type="checkbox" name="io_karyotype"
				<%=props.getProperty("io_karyotype", "")%>>Karyotype for
			both of them</div>
			<% } %>	
			<% if(printutil.isActive("io_mhp")){%>
			<div class="reason_div">
			<input type="checkbox" name="io_mhp"
				<%=props.getProperty("io_mhp", "")%>>Male hormonal profile</div>
			<% } %>	
			<% if(printutil.isActive("io_su")){%>
			<div class="reason_div">
			<input type="checkbox" name="io_su"
				<%=props.getProperty("io_su", "")%>>Scrotal ultrasound</div>
			<% } %>	
			<% if(printutil.isActive("io_tu")){%>
			<div class="reason_div">
			<input type="checkbox" name="io_tu"
				<%=props.getProperty("io_tu", "")%>>Transrectal ultrasound</div>
			<% } %>	
			<% if(printutil.isActive("io_mcf")){%>
			<div class="reason_div">
			<input type="checkbox" name="io_mcf"
				<%=props.getProperty("io_mcf", "")%>>Male CF testing</div>
			<% } %>	
			<% if(printutil.isActive("io_myk")){%>
			<div class="reason_div">
			<input type="checkbox" name="io_myk"
				<%=props.getProperty("io_myk", "")%>>Male Y-microdeletion
			and Karyotype
			</div>
			<% } %>	
			</td>
		</tr>
		<% if(printutil.isActive("io_other")){%>
		<tr>
			<td>
			<!-- Other<br> -->
			<%=props.getProperty("io_other", "")%><br>
			</td>
		</tr>
		<% } %>	
		<tr>
			<td>&nbsp;</td>
		</tr>
		<!-- <tr>
		<td class="bottomBorder">&nbsp;</td> 
		</tr> -->
<% } %>
<% if(printutil.isTPGroupActive()){ %>

		<tr>
			<td style="border-bottom: 1px solid black;">
			<div class="section_title">
			<font size="3"><b>Treatment Plan:</b></font>
			</div>
			</td>
		</tr>

		<tr>
			<td height="10px">
			
			<!-- </td>
		</tr>
		<tr>
			<td> -->
			
			<% if(printutil.isActive("tp_em")){%>
			<div class="reason_div">
			<input type="checkbox" name="tp_em" onchange="toggleControl(document.forms[0].tp_em,document.forms[0].tp_em_t)"
				<%=props.getProperty("tp_em", "")%>>Expectant
			management:&nbsp;<%=props.getProperty("tp_em_t", "")%></div>
			<% } %>	
			<% if(printutil.isActive("tp_oiv")){%>
			<div class="reason_div">
			<input type="checkbox" name="tp_oiv"  onchange="toggleControl(document.forms[0].tp_oiv,document.forms[0].tp_oiv_t)"
				<%=props.getProperty("tp_oiv", "")%>>Ovulation induction
			with:&nbsp;<%=props.getProperty("tp_oiv_t", "")%></div>
			<% } %>	
			<% if(printutil.isActive("tp_saii")){%>
			<div class="reason_div">
			<input type="checkbox" name="tp_saii"
				<%=props.getProperty("tp_saii", "")%>>Superovulation and
			intrauterine insemination</div>
			<% } %>	
			<% if(printutil.isActive("tp_ivf")){%>
			<div class="reason_div">
			<input type="checkbox" name="tp_ivf"
				<%=props.getProperty("tp_ivf", "")%>>IVF</div>
			<% } %>	
			<% if(printutil.isActive("tp_ivficsi")){%>
			<div class="reason_div">
			<input type="checkbox" name="tp_ivficsi"
				<%=props.getProperty("tp_ivficsi", "")%>>IVF with ICSI</div>
			<% } %>	
			<% if(printutil.isActive("tp_ivficsi_tse")){%>
			<div class="reason_div">
			<input type="checkbox" name="tp_ivficsi_tse"
				<%=props.getProperty("tp_ivficsi_tse", "")%>>IVF with ICSI
			and testicular sperm extraction</div>
			<% } %>	
			<% if(printutil.isActive("tp_laparoscopy")){%>
			<div class="reason_div">
			<input type="checkbox" name="tp_laparoscopy"
				<%=props.getProperty("tp_laparoscopy", "")%>>Laparoscopy</div>
			<% } %>	
			<% if(printutil.isActive("tp_myomectomy")){%>
			<div class="reason_div">
			<input type="checkbox" name="tp_myomectomy"
				<%=props.getProperty("tp_myomectomy", "")%>>Myomectomy</div>
			<% } %>	
			<% if(printutil.isActive("tp_dsi")){%>
			<div class="reason_div">
			<input type="checkbox" name="tp_dsi"
				<%=props.getProperty("tp_dsi", "")%>>Donor sperm
			insemination</div>
			<% } %>	
			<% if(printutil.isActive("tp_det")){%>
			<div class="reason_div">
			<input type="checkbox" name="tp_det"
				<%=props.getProperty("tp_det", "")%>>Donor egg therapy</div>
			<% } %>	
			<% if(printutil.isActive("tp_rotl")){%>
			<div class="reason_div">
			<input type="checkbox" name="tp_rotl"
				<%=props.getProperty("tp_rotl", "")%>>Reversal of tubal
			ligation</div>
			<% } %>	
			<% if(printutil.isActive("tp_vr")){%>
			<div class="reason_div">
			<input type="checkbox" name="tp_vr"
				<%=props.getProperty("tp_vr", "")%>>Vasectomy reversal</div>
			<% } %>	
			<% if(printutil.isActive("tp_lc")){%>
			<div class="reason_div">
			<input type="checkbox" name="tp_lc"
				<%=props.getProperty("tp_lc", "")%>>Lifestyle changes</div>
			<% } %>	
			<% if(printutil.isActive("tp_wl")){%>
			<div class="reason_div">
			<input type="checkbox" name="tp_wl"
				<%=props.getProperty("tp_wl", "")%>>Weight loss</div>
			<% } %>	
			<% if(printutil.isActive("tp_adoption")){%>
			<div class="reason_div">
			<input type="checkbox" name="tp_adoption"
				<%=props.getProperty("tp_adoption", "")%>>Adoption</div>
			<% } %>	
			<% if(printutil.isActive("tp_sc")){%>
			<div class="reason_div">
			<input type="checkbox" name="tp_sc"
				<%=props.getProperty("tp_sc", "")%>>Sperm cryopreservation</div>
			<% } %>	
			<% if(printutil.isActive("tp_oc")){%>
			<div class="reason_div">
			<input type="checkbox" name="tp_oc"
				<%=props.getProperty("tp_oc", "")%>>Oocyte cryopreservation</div>
			<% } %>	
			<% if(printutil.isActive("tp_ec")){%>
			<div class="reason_div">
			<input type="checkbox" name="tp_ec"
				<%=props.getProperty("tp_ec", "")%>>Embryo cryopreservation</div>
			<% } %>	
			<% if(printutil.isActive("tp_oswga")){%>
			<div class="reason_div">
			<input type="checkbox" name="tp_oswga"
				<%=props.getProperty("tp_oswga", "")%>>Ovarian suppression
			with a GnRH agonist</div>
			<% } %>	
			<% if(printutil.isActive("tp_ru")){%>
			<div class="reason_div">
			<input type="checkbox" name="tp_ru"
				<%=props.getProperty("tp_ru", "")%>>Referral to urologist</div>
			<% } %>	
			<% if(printutil.isActive("tp_followup")){%>
			<div class="reason_div">
			<input type="checkbox" name="tp_followup"
				<%=props.getProperty("tp_followup", "")%>>Proceed with
			investigations. Discuss results and treatments at follow-up.</div>
			<% } %>	
			</td>
		</tr>
		<% if(printutil.isActive("tp_other")){%>
		<tr>
			<td>
			<!-- Other<br> -->
			<%=props.getProperty("tp_other", "")%><br>
			</td>
		</tr>
		<% } %>	
		<!-- <tr>
		<td class="bottomBorder">&nbsp;</td> 
		</tr> -->
		<% } %>
		<tr bgcolor="white">
                    <td id="faxFooter">

                    </td>
         </tr>
         
         <%
         String multiLineSignStr = sig.getMultiLineSignature(curUser_no);
         //String multiLineSignStr = sig.getSignature(curUser_no);
         if(multiLineSignStr!=null && multiLineSignStr.trim().length()>0)
         {
        	 multiLineSignStr = multiLineSignStr.replaceAll("\n", "<br>");
        	 %>
        	 <tr>
                <td>
                <div>
                	<br><br>
                	Many thanks for your referral.
                	<br><br>
                	Yours sincerely,
                	<br><br>
                	<%
                	boolean flgElectronicSign = sig.hasElectronicSign(curUser_no);
                	//boolean flgElectronicSign = false;
                	if(flgElectronicSign){
                	%>
	                	<img border="0" src="../admin/signature.jsp?provider_no=<%=curUser_no%>">
	                	<br><br>
                	<%} %>
                	<%=multiLineSignStr %>
                </div>
                </td>
         	 </tr>
        	 <%
         }
         %>
         
		
	</table>
	</body>
</html:form>

</html>

<%!
	protected String getdisablestatus(java.util.Properties prop,String parentTag){
		if("".equals(prop.getProperty(parentTag, ""))){
			return " disabled ";
		}else{
			return " ";
		}
	}
	
	private String getName(String lastname, String firstname){
		if(lastname == null || "".equals(lastname)){
			return firstname;
		}else if(firstname == null || "".equals(firstname)){
			return lastname;
		}else{
			return lastname + ", " + firstname;
		}
	}
	
%>