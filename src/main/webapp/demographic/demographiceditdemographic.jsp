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

<%@ taglib uri="/WEB-INF/security.tld" prefix="security"%>
<%
    String roleName$ = (String)session.getAttribute("userrole") + "," + (String) session.getAttribute("user");
    boolean authed=true;
%>
<security:oscarSec roleName="<%=roleName$%>" objectName="_demographic" rights="r" reverse="<%=true%>">
	<%authed=false; %>
	<%response.sendRedirect(request.getContextPath() + "/securityError.jsp?type=_demographic");%>
</security:oscarSec>
<%
	if(!authed) {
		return;
	}
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<%-- @ taglib uri="../WEB-INF/taglibs-log.tld" prefix="log" --%>
<%@page import="org.oscarehr.sharingcenter.SharingCenterUtil"%>
<%@page import="oscar.util.ConversionUtils"%>
<%@page import="org.oscarehr.myoscar.utils.MyOscarLoggedInInfo"%>
<%@page import="org.oscarehr.phr.util.MyOscarUtils"%>
<%@page import="org.oscarehr.util.LoggedInInfo" %>
<%@page import="org.oscarehr.PMmodule.caisi_integrator.ConformanceTestHelper"%>
<%@page import="org.oscarehr.common.dao.DemographicExtDao" %>
<%@page import="org.oscarehr.common.dao.DemographicArchiveDao" %>
<%@page import="org.oscarehr.common.dao.DemographicExtArchiveDao" %>
<%@page import="org.oscarehr.common.dao.PatientTypeDao" %>
<%@page import="org.oscarehr.common.dao.DemographicGroupLinkDao" %>
<%@page import="org.oscarehr.common.dao.DemographicGroupDao" %>
<%@page import="org.oscarehr.common.model.DemographicGroup" %>
<%@page import="org.oscarehr.common.model.DemographicGroupLink" %>
<%@page import="oscar.OscarProperties" %>
<%@page import="org.oscarehr.common.dao.ScheduleTemplateCodeDao" %>
<%@page import="org.oscarehr.common.model.ScheduleTemplateCode" %>
<%@page import="org.oscarehr.common.dao.WaitingListDao" %>
<%@page import="org.oscarehr.common.dao.WaitingListNameDao" %>
<%@page import="org.oscarehr.common.model.WaitingListName" %>
<%@page import="org.apache.commons.lang.StringEscapeUtils" %>
<%@page import="org.oscarehr.common.Gender" %>
<%@page import="org.oscarehr.util.SpringUtils" %>
<%@page import="org.oscarehr.managers.ProgramManager2" %>
<%@page import="org.oscarehr.PMmodule.model.Program" %>
<%@page import="org.oscarehr.PMmodule.web.GenericIntakeEditAction" %>
<%@page import="org.oscarehr.PMmodule.model.ProgramProvider" %>
<%@page import="org.oscarehr.managers.PatientConsentManager" %>
<%@page import="org.oscarehr.common.model.Consent" %>
<%@page import="org.oscarehr.common.model.ConsentType" %>
<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean"%>
<jsp:useBean id="apptMainBean" class="oscar.AppointmentMainBean" scope="session" />
<%

    String demographic$ = request.getParameter("demographic_no") ;
    
    LoggedInInfo loggedInInfo=LoggedInInfo.getLoggedInInfoFromSession(request);
    
    WebApplicationContext ctx = WebApplicationContextUtils.getRequiredWebApplicationContext(getServletContext());
    CountryCodeDao ccDAO =  (CountryCodeDao) ctx.getBean("countryCodeDao");
    UserPropertyDAO pref = (UserPropertyDAO) ctx.getBean("UserPropertyDAO");                       
    List<CountryCode> countryList = ccDAO.getAllCountryCodes();

    DemographicExtDao demographicExtDao = SpringUtils.getBean(DemographicExtDao.class);
    DemographicArchiveDao demographicArchiveDao = SpringUtils.getBean(DemographicArchiveDao.class);
    DemographicExtArchiveDao demographicExtArchiveDao = SpringUtils.getBean(DemographicExtArchiveDao.class);
    ScheduleTemplateCodeDao scheduleTemplateCodeDao = SpringUtils.getBean(ScheduleTemplateCodeDao.class);
    WaitingListDao waitingListDao = SpringUtils.getBean(WaitingListDao.class);
    WaitingListNameDao waitingListNameDao = SpringUtils.getBean(WaitingListNameDao.class);
    String privateConsentEnabledProperty = OscarProperties.getInstance().getProperty("privateConsentEnabled");
    boolean privateConsentEnabled = (privateConsentEnabledProperty != null && privateConsentEnabledProperty.equals("true"));
	DemographicGroupLinkDao demographicGroupLinkDao = SpringUtils.getBean(DemographicGroupLinkDao.class);
    DemographicGroupDao demographicGroupDao = SpringUtils.getBean(DemographicGroupDao.class);
    
    PatientTypeDao patientTypeDao = (PatientTypeDao) SpringUtils.getBean("patientTypeDao");
    List<PatientType> patientTypes = patientTypeDao.findAllPatientTypes();
%>

<security:oscarSec roleName="<%=roleName$%>"
	objectName='<%="_demographic$"+demographic$%>' rights="o"
	reverse="<%=false%>">
<bean:message key="demographic.demographiceditdemographic.accessDenied"/>
<% response.sendRedirect("../acctLocked.html"); 
authed=false;
%>
</security:oscarSec>

<%
if(!authed) {
	return;
}

%>
<%@ page import="java.util.*, java.sql.*, java.net.*,java.text.DecimalFormat, oscar.*, oscar.oscarDemographic.data.ProvinceNames, oscar.oscarWaitingList.WaitingList, oscar.oscarReport.data.DemographicSets,oscar.log.*"%>
<%@ page import="oscar.oscarDemographic.data.*"%>
<%@ page import="oscar.oscarDemographic.pageUtil.Util" %>
<%@ page import="org.springframework.web.context.*,org.springframework.web.context.support.*" %>
<%@ page import="oscar.OscarProperties"%>
<%@ page import="org.oscarehr.common.dao.*,org.oscarehr.common.model.*" %>
<%@ page import="org.oscarehr.common.OtherIdManager" %>
<%@ page import="org.oscarehr.common.web.ContactAction" %>
<%@ page import="org.oscarehr.casemgmt.model.CaseManagementNoteLink" %>
<%@ page import="org.oscarehr.casemgmt.service.CaseManagementManager" %>
<%@page import="org.oscarehr.common.model.ProfessionalSpecialist" %>
<%@page import="org.oscarehr.common.dao.ProfessionalSpecialistDao" %>
<%@page import="org.oscarehr.common.model.DemographicCust" %>
<%@page import="org.oscarehr.common.dao.DemographicCustDao" %>
<%@page import="org.oscarehr.common.model.Demographic" %>
<%@page import="org.oscarehr.common.dao.DemographicDao" %>
<%@page import="org.oscarehr.common.model.Provider" %>
<%@page import="org.oscarehr.PMmodule.dao.ProviderDao" %>
<%@page import="org.oscarehr.managers.DemographicManager" %>
<%@page import="org.oscarehr.PMmodule.service.ProgramManager" %>
<%@page import="org.oscarehr.PMmodule.dao.ProgramDao" %>
<%@page import="org.oscarehr.PMmodule.service.AdmissionManager" %>
<%@ page import="org.oscarehr.common.dao.SpecialtyDao" %>
<%@ page import="org.oscarehr.common.model.Specialty" %>
<%
	DemographicDao demographicDao=(DemographicDao)SpringUtils.getBean("demographicDao");
	ProfessionalSpecialistDao professionalSpecialistDao = (ProfessionalSpecialistDao) SpringUtils.getBean("professionalSpecialistDao");
	DemographicCustDao demographicCustDao = (DemographicCustDao)SpringUtils.getBean("demographicCustDao");
	ProviderDao providerDao = SpringUtils.getBean(ProviderDao.class);
	List<Provider> providers = providerDao.getActiveProviders();
	List<Provider> doctors = providerDao.getActiveProvidersByRole("doctor");
	List<Provider> nurses = providerDao.getActiveProvidersByRole("nurse");
	List<Provider> midwifes = providerDao.getActiveProvidersByRole("midwife");
	
	DemographicManager demographicManager = SpringUtils.getBean(DemographicManager.class);
	ProgramManager2 programManager2 = SpringUtils.getBean(ProgramManager2.class);
    
%>

<jsp:useBean id="providerBean" class="java.util.Properties"	scope="session" />
<% java.util.Properties oscarVariables = OscarProperties.getInstance(); %>

<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html"%>
<%@ taglib uri="/WEB-INF/phr-tag.tld" prefix="phr"%>
<%@ taglib uri="/WEB-INF/oscar-tag.tld" prefix="oscar"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-logic"
	prefix="logic"%>
<%@ taglib uri="/WEB-INF/special_tag.tld" prefix="special" %>
<%@ taglib uri="http://www.caisi.ca/plugin-tag" prefix="plugin" %>

<c:set var="ctx" value="${ pageContext.request.contextPath }" />
<%
	if(session.getAttribute("user") == null)
	{
		response.sendRedirect("../logout.jsp");
		return;
	}

	ProgramManager pm = SpringUtils.getBean(ProgramManager.class);
	ProgramDao programDao = (ProgramDao)SpringUtils.getBean("programDao");
    

	String curProvider_no = (String) session.getAttribute("user");
	String demographic_no = request.getParameter("demographic_no");
	String apptProvider = request.getParameter("apptProvider");
	String appointment = request.getParameter("appointment");
	String userfirstname = (String) session.getAttribute("userfirstname");
	String userlastname = (String) session.getAttribute("userlastname");
	String deepcolor = "#CCCCFF", weakcolor = "#EEEEFF" ;
	String str = null;
	String prov= (oscarVariables.getProperty("billregion","")).trim().toUpperCase();

	String nurseMessageKey = "demographic.demographiceditdemographic.formNurse";
	String midwifeMessageKey = "demographic.demographiceditdemographic.formMidwife";
	String residentMessageKey = "demographic.demographiceditdemographic.formResident";
	if (oscarVariables.getProperty("queens_resident_tagging") != null)
	{
		nurseMessageKey = "demographic.demographiceditdemographic.formAltProvider1";
		midwifeMessageKey = "demographic.demographiceditdemographic.formAltProvider2";
		residentMessageKey = "demographic.demographiceditdemographic.formAltProvider3";
	}
	
	CaseManagementManager cmm = (CaseManagementManager) SpringUtils.getBean("caseManagementManager");
	List<CaseManagementNoteLink> cml = cmm.getLinkByTableId(CaseManagementNoteLink.DEMOGRAPHIC, Long.valueOf(demographic_no));
	boolean hasImportExtra = (cml.size()>0);
	String annotation_display = CaseManagementNoteLink.DISP_DEMO;

	LogAction.addLog((String) session.getAttribute("user"), LogConst.READ, LogConst.CON_DEMOGRAPHIC,  demographic_no , request.getRemoteAddr(),demographic_no);


	OscarProperties oscarProps = OscarProperties.getInstance();

  int demographicNoAsInt = 0;
  try {
    demographicNoAsInt = Integer.parseInt( demographic_no );
  } catch (Exception e) {
    // TODO: Handle error
  }

  Boolean isMobileOptimized = session.getAttribute("mobileOptimized") != null;
	ProvinceNames pNames = ProvinceNames.getInstance();
	Map<String,String> demoExt = demographicExtDao.getAllValuesForDemo(Integer.parseInt(demographic_no));
	List<DemographicGroupLink> demographicGroupsForPatient = demographicGroupLinkDao.findByDemographicNo(demographicNoAsInt);
	pageContext.setAttribute("demoExtended", demoExt);
	List<DemographicGroup> demographicGroups = demographicGroupDao.getAll();
	List<String> demographicGroupNamesForPatient = new ArrayList<String>();
  
	for ( DemographicGroupLink dgl : demographicGroupsForPatient ) {
		for ( DemographicGroup dg : demographicGroups ) {
			if ( dgl.getId().getDemographicGroupId() == dg.getId().intValue() ) {
				demographicGroupNamesForPatient.add( dg.getName() );
			}
		}
	}

	
	String usSigned = StringUtils.defaultString(apptMainBean.getString(demoExt.get("usSigned")));
    String privacyConsent = StringUtils.defaultString(apptMainBean.getString(demoExt.get("privacyConsent")), "");
	String informedConsent = StringUtils.defaultString(apptMainBean.getString(demoExt.get("informedConsent")), "");
	
	boolean showConsentsThisTime = false;
	
    GregorianCalendar now=new GregorianCalendar();
    int curYear = now.get(Calendar.YEAR);
    int curMonth = (now.get(Calendar.MONTH)+1);
    int curDay = now.get(Calendar.DAY_OF_MONTH);
    
	java.util.ResourceBundle oscarResources = ResourceBundle.getBundle("oscarResources", request.getLocale());
    String noteReason = oscarResources.getString("oscarEncounter.noteReason.TelProgress");

	if (OscarProperties.getInstance().getProperty("disableTelProgressNoteTitleInEncouterNotes") != null 
			&& OscarProperties.getInstance().getProperty("disableTelProgressNoteTitleInEncouterNotes").equals("yes")) {
		noteReason = "";
	}
	
	//String patientType = demoExt.get("patientType");
	String patientType = demographicDao.getDemographic(demographic_no).getPatientType();
	String patientId = demographicDao.getDemographic(demographic_no).getPatientId();
	String demographicMiscId = demoExt.get("demographicMiscId");
  
	if (patientType == null) {
		patientType = "";
	}
  
	String patientTypeDesc = "";
	for (PatientType pt : patientTypes ) {
		if( pt.getType().equals(patientType) ) {
			patientTypeDesc = pt.getDescription();
			break;
		}
	}
  
  
	if (patientId == null) {
		patientId = "";
	}
  
	if (demographicMiscId == null) {
		demographicMiscId = "";
	}
	
	// MARC-HI's Sharing Center
	boolean isSharingCenterEnabled = SharingCenterUtil.isEnabled();

	String currentProgram="";
	String programId = (String)session.getAttribute(org.oscarehr.util.SessionConstants.CURRENT_PROGRAM_ID);
	if(programId != null && programId.length()>0) {
		Integer prId = null;
		try {
			prId = Integer.parseInt(programId);
		} catch(NumberFormatException e) {
			//do nothing
		}
		if(prId != null) {
			ProgramManager2 programManager = SpringUtils.getBean(ProgramManager2.class);
			Program p = programManager.getProgram(loggedInInfo, prId);
			if(p != null) {
				currentProgram = p.getName();
			}
		}
	}
	
	// get a list of programs the patient has consented to. 
	if( OscarProperties.getInstance().getBooleanProperty("USE_NEW_PATIENT_CONSENT_MODULE", "true") ) {
	    PatientConsentManager patientConsentManager = SpringUtils.getBean( PatientConsentManager.class );
		pageContext.setAttribute( "consentTypes", patientConsentManager.getConsentTypes() );
		pageContext.setAttribute( "patientConsents", patientConsentManager.getAllConsentsByDemographic( loggedInInfo, Integer.parseInt(demographic_no) ) );
	}

%>

<%@page import="org.apache.commons.lang.StringUtils"%><html:html locale="true">

<head>
<title><bean:message
	key="demographic.demographiceditdemographic.title" /></title>
<html:base />

<oscar:oscarPropertiesCheck property="DEMOGRAPHIC_PATIENT_HEALTH_CARE_TEAM" value="true">
	<link rel="stylesheet" type="text/css" href="${ pageContext.request.contextPath }/css/healthCareTeam.css" />
</oscar:oscarPropertiesCheck>

<!-- calendar stylesheet -->
<link rel="stylesheet" type="text/css" media="all"
	href="../share/calendar/calendar.css" title="win2k-cold-1" />
<script type="text/javascript" src="<%=request.getContextPath()%>/js/jquery.js"></script>
<% if (OscarProperties.getInstance().getBooleanProperty("workflow_enhance", "true")) { %>
<script language="javascript" src="<%=request.getContextPath() %>/hcHandler/hcHandler.js"></script>
<script language="javascript" src="<%=request.getContextPath() %>/hcHandler/hcHandlerUpdateDemographic.js"></script>
<link rel="stylesheet" href="<%=request.getContextPath() %>/hcHandler/hcHandler.css" type="text/css" />
<link rel="stylesheet" href="<%=request.getContextPath() %>/demographic/demographiceditdemographic.css" type="text/css" />
<% } %>

<!-- main calendar program -->
<script type="text/javascript" src="../share/calendar/calendar.js"></script>

<!-- language for the calendar -->
<script type="text/javascript"
	src="../share/calendar/lang/<bean:message key="global.javascript.calendar"/>"></script>

<!-- the following script defines the Calendar.setup helper function, which makes
       adding a calendar a matter of 1 or 2 lines of code. -->
<script type="text/javascript" src="../share/calendar/calendar-setup.js"></script>

<script type="text/javascript" src="<%=request.getContextPath() %>/js/check_hin.js"></script>

<script type="text/javascript" src="<%=request.getContextPath() %>/js/nhpup_1.1.js"></script>

<!-- calendar stylesheet -->
<link rel="stylesheet" type="text/css" media="all"
	href="../share/calendar/calendar.css" title="win2k-cold-1" />
<% if (isMobileOptimized) { %>
    <meta name="viewport" content="initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no, width=device-width" />
    <link rel="stylesheet" type="text/css" href="../mobile/editdemographicstyle.css">
<% } else { %>
    <link rel="stylesheet" type="text/css" href="../oscarEncounter/encounterStyles.css">
    <link rel="stylesheet" type="text/css" href="../share/css/searchBox.css">
    <script type="text/javascript" src="<%= request.getContextPath() %>/js/global.js"></script>
<% } %>
<script language="javascript" type="text/javascript"
	src="../share/javascript/Oscar.js"></script>

<!--popup menu for encounter type -->
<script src="<c:out value="${ctx}"/>/share/javascript/popupmenu.js"
	type="text/javascript"></script>
<script src="<c:out value="${ctx}"/>/share/javascript/menutility.js"
	type="text/javascript"></script>
<script type="text/javascript" src="../share/javascript/prototype.js"></script>
   <script>
     jQuery.noConflict();
   </script>
	<script type="text/javascript" src="<%=request.getContextPath() %>/js/jquery-3.1.0.min.js"></script>
	<script type="text/javascript" src="<%=request.getContextPath() %>/js/jquery.maskedinput.js"></script>
	<script type="application/javascript">
		var jQuery_3_1_0 = jQuery.noConflict(true);
	</script>
<script>
jQuery( document ).ready( function() {
	var demographicGroupsForPatient = [];
	<%
	for (DemographicGroupLink dg : demographicGroupsForPatient) {
		%>
		demographicGroupsForPatient.push(<%=dg.getId().getDemographicGroupId()%>);
		<%
	}
	%>
	
	for ( var i in demographicGroupsForPatient ) {
		if (demographicGroupsForPatient.hasOwnProperty(i)) {
			var elem = jQuery('#demographicGroups option[value="' + demographicGroupsForPatient[i] + '"]');
			
			if (elem.length === 0) {
				console.error('Demographic Group with id "' + demographicGroupsForPatient[i] + '" does not exist.');
				continue;
			}
			
			elem.attr('selected', 'selected');
		}
	}
});
</script>
<oscar:customInterface section="master"/>

<script type="text/javascript" src="<%=request.getContextPath() %>/demographic/demographiceditdemographic.js.jsp"></script>

<script language="JavaScript" type="text/javascript">

jQuery(document).ready(function() {
	var referralDoctorId = document.updatedelete.r_doctor_id.value;

	var familyDoctorId = document.updatedelete.f_doctor_id.value;
	getSpecialistInfo(referralDoctorId, 'r')
	getSpecialistInfo(familyDoctorId, 'd')
});

function checkTypeIn() {
  var dob = document.titlesearch.keyword; typeInOK = false;

  if (dob.value.indexOf('%b610054') == 0 && dob.value.length > 18){
     document.titlesearch.keyword.value = dob.value.substring(8,18);
     document.titlesearch.search_mode[4].checked = true;
  }

  if(document.titlesearch.search_mode[2].checked) {
    if(dob.value.length==8) {
      dob.value = dob.value.substring(0, 4)+"-"+dob.value.substring(4, 6)+"-"+dob.value.substring(6, 8);
      //alert(dob.value.length);
      typeInOK = true;
    }
    if(dob.value.length != 10) {
      alert("<bean:message key="demographic.search.msgWrongDOB"/>");
      typeInOK = false;
    }

    return typeInOK ;
  } else {
    return true;
  }
}

function checkName() {
	var typeInOK = false;
	if(document.updatedelete.last_name.value!="" && document.updatedelete.first_name.value!="" && document.updatedelete.last_name.value!=" " && document.updatedelete.first_name.value!=" ") {
	    typeInOK = true;
	} else {
		alert ("<bean:message key="demographic.demographiceditdemographic.msgNameRequired"/>");
    }
	return typeInOK;
}
function checkDate(yyyy,mm,dd,err_msg) {

	var typeInOK = false;

	if(checkTypeNum(yyyy) && checkTypeNum(mm) && checkTypeNum(dd) ){
        var check_date = new Date(yyyy,(mm-1),dd);
		var now = new Date();
		var year=now.getFullYear();
		var month=now.getMonth()+1;
		var date=now.getDate();
		//alert(yyyy + " | " + mm + " | " + dd + " " + year + " " + month + " " +date);

		var young = new Date(year,month,date);
		var old = new Date(1800,01,01);
		//alert(check_date.getTime() + " | " + young.getTime() + " | " + old.getTime());
		if (check_date.getTime() <= young.getTime() && check_date.getTime() >= old.getTime() && yyyy.length==4) {
		    typeInOK = true;
		}
		if ( yyyy == "0000"){
                    typeInOK = false;
                }
        }

	if (!isValidDate(dd,mm,yyyy) || !typeInOK){
            alert (err_msg+"\n<bean:message key="demographic.demographiceditdemographic.msgWrongDate"/>");
            typeInOK = false;
        }

	return typeInOK;
}
function checkDob() {
	var yyyy = document.updatedelete.year_of_birth.value;
	var mm = document.updatedelete.month_of_birth.value;
	var dd = document.updatedelete.date_of_birth.value;

      return checkDate(yyyy,mm,dd,"<bean:message key="demographic.search.msgWrongDOB"/>");
}

function isValidDate(day,month,year){
   month = ( month - 1 );
   dteDate=new Date(year,month,day);
   //alert(dteDate);
   return ((day==dteDate.getDate()) && (month==dteDate.getMonth()) && (year==dteDate.getFullYear()));
}

function checkHin() {
	var hin = document.updatedelete.hin.value;
	var province = document.updatedelete.hc_type.value;

	if (!isValidHin(hin, province))
	{
		alert ("<bean:message key="demographic.demographiceditdemographic.msgWrongHIN"/>");
		return(false);
	}

	return(true);
}



function rosterStatusChangedNotBlank() {
	if (rosterStatusChanged()) {
		if (document.updatedelete.roster_status.value=="") {
			alert ("<bean:message key="demographic.demographiceditdemographic.msgBlankRoster"/>");
			document.updatedelete.roster_status.focus();
			return false;
		}
		return true;
	}
	return false;
}

function rosterStatusDateAllowed() {
	if (document.updatedelete.roster_status.value=="") {
	    yyyy = document.updatedelete.roster_date_year.value.trim();
	    mm = document.updatedelete.roster_date_month.value.trim();
	    dd = document.updatedelete.roster_date_day.value.trim();

	    if (yyyy!="" || mm!="" || dd!="") {
	    	alert ("<bean:message key="demographic.search.msgForbiddenRosterDate"/>");
	    	return false;
	    }
	    return true;
	}
	return true;
}

function rosterStatusDateValid(trueIfBlank) {
    yyyy = document.updatedelete.roster_date_year.value.trim();
    mm = document.updatedelete.roster_date_month.value.trim();
    dd = document.updatedelete.roster_date_day.value.trim();
    var errMsg = "<bean:message key="demographic.search.msgWrongRosterDate"/>";

    if (trueIfBlank) {
    	errMsg += "\n<bean:message key="demographic.search.msgLeaveBlank"/>";
    	if (yyyy=="" && mm=="" && dd=="") return true;
    }
    return checkDate(yyyy,mm,dd,errMsg);
}

function rosterStatusTerminationDateValid(trueIfBlank) {
    yyyy = document.updatedelete.roster_termination_date_year.value.trim();
    mm = document.updatedelete.roster_termination_date_month.value.trim();
    dd = document.updatedelete.roster_termination_date_day.value.trim();
    var errMsg = "<bean:message key="demographic.search.msgWrongRosterTerminationDate"/>";

    if (trueIfBlank) {
    	errMsg += "\n<bean:message key="demographic.search.msgLeaveBlank"/>";
    	if (yyyy=="" && mm=="" && dd=="") return true;
    }
    return checkDate(yyyy,mm,dd,errMsg);
}

function rosterStatusTerminationReasonNotBlank() {
	if (document.updatedelete.roster_termination_reason.value=="") {
		alert ("<bean:message key="demographic.demographiceditdemographic.msgNoTerminationReason"/>");
		return false;
	}
	return true;
}


function patientStatusDateValid(trueIfBlank) {
    var yyyy = document.updatedelete.patientstatus_date_year.value.trim();
    var mm = document.updatedelete.patientstatus_date_month.value.trim();
    var dd = document.updatedelete.patientstatus_date_day.value.trim();

    if (trueIfBlank) {
    	if (yyyy=="" && mm=="" && dd=="") return true;
    }
    return checkDate(yyyy,mm,dd,"<bean:message key="demographic.search.msgWrongPatientStatusDate"/>");
}




function checkONReferralNo() {
	<%
		String skip = oscar.OscarProperties.getInstance().getProperty("SKIP_REFERRAL_NO_CHECK","false");
		if(!skip.equals("true")) {
	%>
  var referralNo = document.updatedelete.r_doctor_ohip.value ;
  if (document.updatedelete.hc_type.value == 'ON' && referralNo.length > 0 && referralNo.length != 6) {
    alert("<bean:message key="demographic.demographiceditdemographic.msgWrongReferral"/>") ;
  }

  <% } %>
}
function checkONFamilyNo() {
    <%
        if(!skip.equals("true")) {
    %>
    var referralNo = document.updatedelete.f_doctor_ohip.value ;
    if (document.updatedelete.hc_type.value == 'ON' && referralNo.length > 0 && referralNo.length != 6) {
        alert("<bean:message key="demographic.demographiceditdemographic.msgWrongFamily"/>") ;
    }

    <% } %>
}


function newStatus() {
    newOpt = prompt("<bean:message key="demographic.demographiceditdemographic.msgPromptStatus"/>:", "");
    if (newOpt == null) {
    	return;
    } else if(newOpt != "") {
        document.updatedelete.patient_status.options[document.updatedelete.patient_status.length] = new Option(newOpt, newOpt);
        document.updatedelete.patient_status.options[document.updatedelete.patient_status.length-1].selected = true;
    } else {
        alert("<bean:message key="demographic.demographiceditdemographic.msgInvalidEntry"/>");
    }
}

function newStatus1() {
    newOpt = prompt("<bean:message key="demographic.demographiceditdemographic.msgPromptStatus"/>:", "");
    if (newOpt == null) {
    	return;
    } else if(newOpt != "") {
        document.updatedelete.roster_status.options[document.updatedelete.roster_status.length] = new Option(newOpt, newOpt);
        document.updatedelete.roster_status.options[document.updatedelete.roster_status.length-1].selected = true;
    } else {
        alert("<bean:message key="demographic.demographiceditdemographic.msgInvalidEntry"/>");
    }
}

</script>
<script language="JavaScript">
function showEdit(){
    document.getElementById('editDemographic').style.display = 'block';
    document.getElementById('viewDemographics2').style.display = 'none';
    document.getElementById('updateButton').style.display = 'block';
    document.getElementById('swipeButton').style.display = 'block';
    document.getElementById('editBtn').style.display = 'none';
    document.getElementById('closeBtn').style.display = 'inline';
}

function showHideDetail(){
    showHideItem('editDemographic');
    showHideItem('viewDemographics2');
    showHideItem('updateButton');
    showHideItem('swipeButton');

    showHideBtn('editBtn');
    showHideBtn('closeBtn');
   
}

// Used to display demographic sections, where sections is an array of id's for
// div elements with class "demographicSection"
function showHideMobileSections(sections) {
    showHideItem('mobileDetailSections');
    for (var i = 0; i < sections.length; i++) {
        showHideItem(sections[i]);
    }
    // Change behaviour of cancel button
    var cancelValue = "<bean:message key="global.btnCancel" />";
    var backValue = "<bean:message key="global.btnBack" />";
    var cancelBtn = document.getElementById('cancelButton');
    if (cancelBtn.value == cancelValue) {
        cancelBtn.value = backValue;
        cancelBtn.onclick = function() { showHideMobileSections(sections); };
    } else {
        cancelBtn.value = cancelValue;
        cancelBtn.onclick = function() { self.close(); };
    }
}

function showHideItem(id){
    if(document.getElementById(id).style.display == 'inline' || document.getElementById(id).style.display == 'block')
        document.getElementById(id).style.display = 'none';
    else
        document.getElementById(id).style.display = 'block';
}

function showHideBtn(id){
    if(document.getElementById(id).style.display == 'none')
        document.getElementById(id).style.display = 'inline';
    else
        document.getElementById(id).style.display = 'none';
}


function showItem(id){
        document.getElementById(id).style.display = 'inline';
}

function hideItem(id){
        document.getElementById(id).style.display = 'none';
}

<security:oscarSec roleName="<%= roleName$ %>" objectName="_eChart" rights="r" reverse="<%= false %>" >
var numMenus = 1;
var encURL = "<c:out value="${ctx}"/>/oscarEncounter/IncomingEncounter.do?providerNo=<%=curProvider_no%>&appointmentNo=&demographicNo=<%=demographic_no%>&curProviderNo=&reason=<%=URLEncoder.encode(noteReason)%>&encType=<%=URLEncoder.encode("telephone encounter with client")%>&userName=<%=URLEncoder.encode( userfirstname+" "+userlastname) %>&curDate=<%=""+curYear%>-<%=""+curMonth%>-<%=""+curDay%>&appointmentDate=&startTime=&status=";
function showMenu(menuNumber, eventObj) {
    var menuId = 'menu' + menuNumber;
    return showPopup(menuId, eventObj);
}

<%if (OscarProperties.getInstance().getProperty("workflow_enhance")!=null && OscarProperties.getInstance().getProperty("workflow_enhance").equals("true")) {%>

function showAppt (targetAppt, eventObj) {
    if(eventObj) {
	targetObjectId = 'menu' + targetAppt;
	hideCurrentPopup();
	eventObj.cancelBubble = true;
	moveObject(targetObjectId, 300, 200);
	if( changeObjectVisibility(targetObjectId, 'visible') ) {
	    window.currentlyVisiblePopup = targetObjectId;
	    return true;
	} else {
	    return false;
	}
    } else {
	return false;
    }
} // showPopup

function closeApptBox(e) {
	if (!e) var e = window.event;
	var tg = (window.event) ? e.srcElement : e.target;
	if (tg.nodeName != 'DIV') return;
	var reltg = (e.relatedTarget) ? e.relatedTarget : e.toElement;
	while (reltg != tg && reltg.nodeName != 'BODY')
		reltg= reltg.parentNode;
	if (reltg== tg) return;

	// Mouseout took place when mouse actually left layer
	// Handle event
	hideCurrentPopup();
}
<%}%>

function add2url(txt) {
    var reasonLabel = "reason=";
    var encTypeLabel = "encType=";
    var beg = encURL.indexOf(reasonLabel);
    beg+= reasonLabel.length;
    var end = encURL.indexOf("&", beg);
    var part1 = encURL.substring(0,beg);
    var part2 = encURL.substr(end);
    encURL = part1 + encodeURI(txt) + part2;
    beg = encURL.indexOf(encTypeLabel);
    beg += encTypeLabel.length;
    end = encURL.indexOf("&", beg);
    part1 = encURL.substring(0,beg);
    part2 = encURL.substr(end);
    encURL = part1 + encodeURI(txt) + part2;
    popupEChart(710, 1024,encURL);
    return false;
}

function customReason() {
    var txtInput;
    var list = document.getElementById("listCustom");
    if( list.style.display == "block" )
        list.style.display = "none";
    else {
        list.style.display = "block";
        txtInput = document.getElementById("txtCustom");
        txtInput.focus();
    }

    return false;
}

function grabEnterCustomReason(event){

  var txtInput = document.getElementById("txtCustom");
  if(window.event && window.event.keyCode == 13){
      add2url(txtInput.value);
  }else if (event && event.which == 13){
      add2url(txtInput.value);
  }

  return true;
}

function addToPatientSet(demoNo, patientSet) {
    if (patientSet=="-") return;
    window.open("addDemoToPatientSet.jsp?demoNo="+demoNo+"&patientSet="+patientSet, "addpsetwin", "width=50,height=50");
}
</security:oscarSec>

var demographicNo='<%=demographic_no%>';


function checkRosterStatus2(){
	var rosterSelect = document.getElementById("roster_status");
	<oscar:oscarPropertiesCheck property="FORCED_ROSTER_INTEGRATOR_LOCAL_STORE" value="yes">
	if(rosterSelect.value == "RO"){
		var primaryEmr = document.getElementById("primaryEMR");
		primaryEmr.value = "1";
		primaryEmr.disable(true);
	}
	</oscar:oscarPropertiesCheck>
	
	if(rosterSelect.value == "RO" || rosterSelect.value == ""){
		jQuery(".termination_details").hide();
        jQuery(".termination_details input").val("");
        jQuery(".termination_details select").val("");
	}else{
        jQuery(".termination_details").show();
        jQuery("#roster_termination_reason").focus();
	}
	
	return true;
}

jQuery(document).ready(function($) {
	jQuery("a.popup").click(function() {
		var $me = jQuery(this);
		var name = $me.attr("title");
		var rel = $me.attr("rel");
		var content = jQuery("#" + rel).html();
		var win = window.open(null, name, "height=250,width=600,location=no,scrollbars=yes,menubars=no,toolbars=no,resizable=yes");
		jQuery(win.document.body).html(content);
		return false;
	});

});


function showCbiReminder()
{
  alert('<bean:message key="demographic.demographiceditdemographic.updateCBIReminder"/>');
}



var addressHistory = "";
var homePhoneHistory="";
var workPhoneHistory="";
var cellPhoneHistory="";

function generateMarkup(addresses,type,header) {
	 var markup = '<table border="0" cellpadding="2" cellspacing="2" width="200px">';
     markup += '<tr><th><b>Date Entered</b></th><th><b>'+header+'</b></th></tr>';
     for(var x=0;x<addresses.length;x++) {
     	if(addresses[x].type == type) {
     		markup += '<tr><td>'+addresses[x].dateSeen+'</td><td>'+addresses[x].name+'</td></tr>';
     	}
     }
     markup += "</table>";
     return markup;
}

function updatePaperArchive(paperArchiveSel) {
	var val = jQuery("#paper_chart_archived").val();
	if(val == '' || val == 'NO') {
		jQuery("#paper_chart_archived_date").val('');
		jQuery("#paper_chart_archived_program").val('');
	}
	if(val == 'YES') {
		jQuery("#paper_chart_archived_program").val('<%=currentProgram%>');
	}
}

jQuery(document).ready(function() {
	var addresses;
	
	 jQuery.getJSON("../demographicSupport.do",
             {
                     method: "getAddressAndPhoneHistoryAsJson",
                     demographicNo: demographicNo
             },
             function(response){
                 if (response instanceof Array) {
                     addresses = response;
           	  	} else {
                     var arr = new Array();
                     arr[0] = response;
                     addresses = arr;
            	}
                 
                addressHistory = generateMarkup(addresses,'address','Address');
                homePhoneHistory = generateMarkup(addresses,'phone','Phone #');
                workPhoneHistory = generateMarkup(addresses,'phone2','Phone #');
                cellPhoneHistory = generateMarkup(addresses,'cell','Phone #');
       });
});

</script>

</head>
<body onLoad="setfocus(); checkONReferralNo(); checkONFamilyNo(); formatPhoneNum(); checkRosterStatus2();"
	topmargin="0" leftmargin="0" rightmargin="0" id="demographiceditdemographic">
<%
       Demographic demographic = demographicDao.getDemographic(demographic_no);
       List<DemographicArchive> archives = demographicArchiveDao.findByDemographicNo(Integer.parseInt(demographic_no));
       List<DemographicExtArchive> extArchives = demographicExtArchiveDao.getDemographicExtArchiveByDemoAndKey(Integer.parseInt(demographic_no), "demo_cell");
       
       AdmissionManager admissionManager = SpringUtils.getBean(AdmissionManager.class);  
     	Admission bedAdmission = admissionManager.getCurrentBedProgramAdmission(demographic.getDemographicNo());
     	Admission communityAdmission = admissionManager.getCurrentCommunityProgramAdmission(demographic.getDemographicNo());
     	List<Admission> serviceAdmissions = admissionManager.getCurrentServiceProgramAdmission(demographic.getDemographicNo());
     	if(serviceAdmissions == null) {
     		serviceAdmissions = new ArrayList<Admission>();
     	}

%>
<table class="MainTable" id="scrollNumber1" name="encounterTable">
	<tr class="MainTableTopRow">
		<td class="MainTableTopRowLeftColumn"><bean:message
			key="demographic.demographiceditdemographic.msgPatientDetailRecord" />
		</td>
		<td class="MainTableTopRowRightColumn">
		<table class="TopStatusBar">
			<tr>
				<td>
				<%
                           java.util.Locale vLocale =(java.util.Locale)session.getAttribute(org.apache.struts.Globals.LOCALE_KEY);
                                //----------------------------REFERRAL DOCTOR------------------------------
                                String rdohip="", rd="", fd="", family_doc = "";
                                String fam_doc_contents="", fam_doc_ohip="", fam_doc_name="";

                                String resident="", nurse="", alert="", notes="", midwife="";
                                
                                DemographicCust demographicCust = demographicCustDao.find(Integer.parseInt(demographic_no));
                                if(demographicCust != null) {
                                    resident = demographicCust.getResident() == null ? "" : demographicCust.getResident();
                            		nurse = demographicCust.getNurse() == null ? "" : demographicCust.getNurse();
                            		alert = demographicCust.getAlert() == null ? "" : demographicCust.getAlert();;
                            		midwife = demographicCust.getMidwife() == null ? "" : demographicCust.getMidwife();;
                                	notes = SxmlMisc.getXmlContent(demographicCust.getNotes(),"unotes") ;
                                	
                                	resident = resident==null?"":resident;
                                	nurse = nurse==null?"":nurse;
                                	alert = alert==null?"":alert;	
                                	midwife = midwife==null?"":midwife;
                                	notes = notes==null?"":notes;                               	
                                }
                                
                                if( resident == null ) {
                                	resident = "";
                                }
                                
                                if( nurse == null ) {
                                	nurse = "";
                                }
                                
                                if( midwife == null ) {
                                	midwife = "";
                                }

                                // Demographic demographic=demographicDao.getDemographic(demographic_no);

                                String dateString = curYear+"-"+curMonth+"-"+curDay;
                                int age=0, dob_year=0, dob_month=0, dob_date=0;
                                String birthYear="0000", birthMonth="00", birthDate="00";

                                
                                if(demographic==null) {
                                        out.println("failed!!!");
                                } else {
                                        if (true) {
                                                //----------------------------REFERRAL DOCTOR------------------------------
                                                fd=demographic.getFamilyDoctor();
                                                if (fd==null) {
                                                        rd = "";
                                                        rdohip="";
                                                        family_doc = "";
                                                }else{
                                                        rd = SxmlMisc.getXmlContent(StringUtils.trimToEmpty(demographic.getFamilyDoctor()),"rd");
                                                        rd = rd !=null && !rd.equals("null") ? rd : "" ;
                                                        rdohip = SxmlMisc.getXmlContent(StringUtils.trimToEmpty(demographic.getFamilyDoctor()),"rdohip");
                                                        rdohip = rdohip !=null && !rdohip.equals("null") ? rdohip : "" ;
                                                        family_doc = SxmlMisc.getXmlContent(StringUtils.trimToEmpty(demographic.getFamilyDoctor()),"family_doc");
                                                        family_doc = family_doc !=null ? family_doc : "" ;
                                                }

                                                fam_doc_contents = demographic.getFamilyPhysician();
                                                if(fam_doc_contents!=null) {
                                                    fam_doc_name = SxmlMisc.getXmlContent(StringUtils.trimToEmpty(demographic.getFamilyPhysician()), "fd");
                                                    fam_doc_name = fam_doc_name != null ? fam_doc_name : "";
                                                    fam_doc_ohip = SxmlMisc.getXmlContent(StringUtils.trimToEmpty(demographic.getFamilyPhysician()), "fdohip");
                                                    fam_doc_ohip = fam_doc_ohip != null ? fam_doc_ohip : "";
                                                }

                                                //----------------------------REFERRAL DOCTOR --------------end-----------

                                                if (oscar.util.StringUtils.filled(demographic.getYearOfBirth())) birthYear = StringUtils.trimToEmpty(demographic.getYearOfBirth());
                                                if (oscar.util.StringUtils.filled(demographic.getMonthOfBirth())) birthMonth = StringUtils.trimToEmpty(demographic.getMonthOfBirth());
                                                if (oscar.util.StringUtils.filled(demographic.getDateOfBirth())) birthDate = StringUtils.trimToEmpty(demographic.getDateOfBirth());

                                               	dob_year = Integer.parseInt(birthYear);
                                               	dob_month = Integer.parseInt(birthMonth);
                                               	dob_date = Integer.parseInt(birthDate);
                                                if(dob_year!=0) age=MyDateFormat.getAge(dob_year,dob_month,dob_date);
                        %> <%=demographic.getLastName()%>,
				<%=demographic.getFirstName()%> <%=demographic.getSex()%>
				<%=age%> years &nbsp;
				<oscar:phrverification demographicNo='<%=demographic.getDemographicNo().toString()%>' ><bean:message key="phr.verification.link"/></oscar:phrverification>

				<span style="margin-left: 20px;font-style:italic">
				<bean:message key="demographic.demographiceditdemographic.msgNextAppt"/>: <oscar:nextAppt demographicNo='<%=demographic.getDemographicNo().toString()%>' />
				</span>

				<%
				if (loggedInInfo.getCurrentFacility().isIntegratorEnabled()){%>
        		<jsp:include page="../admin/IntegratorStatus.jspf"/>
        		<%}%>
				
				</td>
			</tr>
		</table>
		</td>
	</tr>
	<tr>
		<td class="MainTableLeftColumn" valign="top">
		<table border=0 cellspacing=0 width="100%" id="appt_table">
			<tr class="Header">
				<td style="font-weight: bold"><bean:message key="demographic.demographiceditdemographic.msgAppt"/></td>
			</tr>
			<tr id="appt_hx">
				<td><a
					href='demographiccontrol.jsp?demographic_no=<%=demographic.getDemographicNo()%>&last_name=<%=URLEncoder.encode(demographic.getLastName())%>&first_name=<%=URLEncoder.encode(demographic.getFirstName())%>&orderby=appttime&displaymode=appt_history&dboperation=appt_history&limit1=0&limit2=25'><bean:message
					key="demographic.demographiceditdemographic.btnApptHist" /></a>
				</td>
			</tr>

<%
String wLReadonly = "";
WaitingList wL = WaitingList.getInstance();
if(!wL.getFound()){
    wLReadonly = "readonly";
}
if(wLReadonly.equals("")){
%>
			<tr>
				<td><a
					href="../oscarWaitingList/SetupDisplayPatientWaitingList.do?demographic_no=<%=demographic.getDemographicNo()%>">
				<bean:message key="demographic.demographiceditdemographic.msgWaitList"/></a>
				</td>
			</tr>
			</table>
			 <table border=0 cellspacing=0 width="100%">
<%}%>
<security:oscarSec roleName="<%=roleName$%>" objectName="_billing" rights="r">
			<tr class="Header">
				<td style="font-weight: bold"><bean:message
					key="admin.admin.billing" /></td>
			</tr>
			<tr>
				<td>
					<% 
					if ("CLINICAID".equals(prov)) 
					{
						%>
							<a href="../billing.do?billRegion=CLINICAID&action=invoice_reports" target="_blank">
							<bean:message key="demographic.demographiceditdemographic.msgInvoiceList"/>
							</a>
						<%
					}
					else if("ON".equals(prov)) 
					{
					%>
						<a href="javascript: function myFunction() {return false; }"
							onClick="popupPage(500,800,'../billing/CA/ON/billinghistory.jsp?demographic_no=<%=demographic.getDemographicNo()%>&last_name=<%=URLEncoder.encode(demographic.getLastName())%>&first_name=<%=URLEncoder.encode(demographic.getFirstName())%>&orderby=appointment_date&displaymode=appt_history&dboperation=appt_history&limit1=0&limit2=10')">
						<bean:message key="demographic.demographiceditdemographic.msgBillHistory"/></a>
					<%
					}
					else
					{
					%>
						<a href="#"
							onclick="popupPage(800,1000,'../billing/CA/BC/billStatus.jsp?lastName=<%=URLEncoder.encode(demographic.getLastName())%>&firstName=<%=URLEncoder.encode(demographic.getFirstName())%>&filterPatient=true&demographicNo=<%=demographic.getDemographicNo()%>');return false;">
						<bean:message key="demographic.demographiceditdemographic.msgInvoiceList"/></a>


						<br/>
						<a  href="javascript: void();" onclick="return !showMenu('2', event);" onmouseover="callEligibilityWebService('../billing/CA/BC/ManageTeleplan.do','returnTeleplanMsg');"><bean:message key="demographic.demographiceditdemographic.btnCheckElig"/></a>
						<div id='menu2' class='menu' onclick='event.cancelBubble = true;' style="width:350px;">
							<span id="search_spinner" ><bean:message key="demographic.demographiceditdemographic.msgLoading"/></span>
							<span id="returnTeleplanMsg"></span>
						</div>
					<%}%>
				</td>
			</tr>
			<tr>
				<td><a
					href="javascript: function myFunction() {return false; }"
					onClick="popupPage(700, 1000, '../billing.do?billRegion=<%=URLEncoder.encode(prov)%>&billForm=<%=URLEncoder.encode(oscarVariables.getProperty("default_view"))%>&hotclick=&appointment_no=0&demographic_name=<%=URLEncoder.encode(demographic.getLastName())%>%2C<%=URLEncoder.encode(demographic.getFirstName())%>&demographic_no=<%=demographic.getDemographicNo()%>&providerview=<%=demographic.getProviderNo()%>&user_no=<%=curProvider_no%>&apptProvider_no=none&appointment_date=<%=dateString%>&start_time=00:00:00&bNewForm=1&status=t');return false;"
					title="<bean:message key="demographic.demographiceditdemographic.msgBillPatient"/>"><bean:message key="demographic.demographiceditdemographic.msgCreateInvoice"/></a></td>
			</tr>
			<%
			if("ON".equals(prov)) {
				String default_view = oscarVariables.getProperty("default_view", "");

				if (!oscarProps.getProperty("clinic_no", "").startsWith("1022")) { // part 2 of quick hack to make Dr. Hunter happy
	%>
				<tr>
					<td><a
						href="javascript: function myFunction() {return false; }"
						onClick="window.open('../billing/CA/ON/specialtyBilling/fluBilling/addFluBilling.jsp?function=demographic&functionid=<%=demographic.getDemographicNo()%>&creator=<%=curProvider_no%>&demographic_name=<%=URLEncoder.encode(demographic.getLastName())%>%2C<%=URLEncoder.encode(demographic.getFirstName())%>&hin=<%=URLEncoder.encode(demographic.getHin()!=null?demographic.getHin():"")%><%=URLEncoder.encode(demographic.getVer()!=null?demographic.getVer():"")%>&demo_sex=<%=URLEncoder.encode(demographic.getSex())%>&demo_hctype=<%=URLEncoder.encode(demographic.getHcType()==null?"null":demographic.getHcType())%>&rd=<%=URLEncoder.encode(rd==null?"null":rd)%>&rdohip=<%=URLEncoder.encode(rdohip==null?"null":rdohip)%>&dob=<%=MyDateFormat.getStandardDate(Integer.parseInt(birthYear),Integer.parseInt(birthMonth),Integer.parseInt(birthDate))%>&mrp=<%=demographic.getProviderNo() != null ? demographic.getProviderNo() : ""%>','', 'scrollbars=yes,resizable=yes,width=720,height=500');return false;"
						title='<bean:message key="demographic.demographiceditdemographic.msgAddFluBill"/>'><bean:message key="demographic.demographiceditdemographic.msgFluBilling"/></a></td>
				</tr>
	<%          } %>
				<tr>
					<td><a
						href="javascript: function myFunction() {return false; }"
						onClick="popupS('../billing/CA/ON/billingShortcutPg1.jsp?billRegion=<%=URLEncoder.encode(prov)%>&billForm=<%=URLEncoder.encode(oscarVariables.getProperty("hospital_view", default_view))%>&hotclick=&appointment_no=0&demographic_name=<%=URLEncoder.encode(demographic.getLastName())%>%2C<%=URLEncoder.encode(demographic.getFirstName())%>&demographic_no=<%=demographic.getDemographicNo()%>&providerview=<%=demographic.getProviderNo()%>&user_no=<%=curProvider_no%>&apptProvider_no=none&appointment_date=<%=dateString%>&start_time=00:00:00&bNewForm=1&status=t');return false;"
						title="<bean:message key="demographic.demographiceditdemographic.msgBillPatient"/>"><bean:message key="demographic.demographiceditdemographic.msgHospitalBilling"/></a></td>
				</tr>
				<tr>
					<td><a
						href="javascript: function myFunction() {return false; }"
						onClick="window.open('../billing/CA/ON/addBatchBilling.jsp?demographic_no=<%=demographic.getDemographicNo().toString()%>&creator=<%=curProvider_no%>&demographic_name=<%=URLEncoder.encode(demographic.getLastName())%>%2C<%=URLEncoder.encode(demographic.getFirstName())%>&hin=<%=URLEncoder.encode(demographic.getHin()!=null?demographic.getHin():"")%><%=URLEncoder.encode(demographic.getVer()!=null?demographic.getVer():"")%>&dob=<%=MyDateFormat.getStandardDate(Integer.parseInt(birthYear),Integer.parseInt(birthMonth),Integer.parseInt(birthDate))%>','', 'scrollbars=yes,resizable=yes,width=600,height=400');return false;"
						title='<bean:message key="demographic.demographiceditdemographic.msgAddBatchBilling"/>'><bean:message key="demographic.demographiceditdemographic.msgAddBatchBilling"/></a>
					</td>
				</tr>
				<tr>
					<td><a
						href="javascript: function myFunction() {return false; }"
						onClick="window.open('../billing/CA/ON/inr/addINRbilling.jsp?function=demographic&functionid=<%=demographic.getDemographicNo()%>&creator=<%=curProvider_no%>&demographic_name=<%=URLEncoder.encode(demographic.getLastName())%>%2C<%=URLEncoder.encode(demographic.getFirstName())%>&hin=<%=URLEncoder.encode(demographic.getHin()!=null?demographic.getHin():"")%><%=URLEncoder.encode(demographic.getVer()!=null?demographic.getVer():"")%>&dob=<%=MyDateFormat.getStandardDate(Integer.parseInt(birthYear),Integer.parseInt(birthMonth),Integer.parseInt(birthDate))%>','', 'scrollbars=yes,resizable=yes,width=600,height=400');return false;"
						title='<bean:message key="demographic.demographiceditdemographic.msgAddINRBilling"/>'><bean:message key="demographic.demographiceditdemographic.msgAddINR"/></a>
					</td>
				</tr>
				<tr>
					<td><a
						href="javascript: function myFunction() {return false; }"
						onClick="window.open('../billing/CA/ON/inr/reportINR.jsp?provider_no=<%=curProvider_no%>','', 'scrollbars=yes,resizable=yes,width=600,height=600');return false;"
						title='<bean:message key="demographic.demographiceditdemographic.msgINRBilling"/>'><bean:message key="demographic.demographiceditdemographic.msgINRBill"/></a>
					</td>
				</tr>
<%
			}
%>

</security:oscarSec>
			<tr class="Header">
				<td style="font-weight: bold"><bean:message
					key="oscarEncounter.Index.clinicalModules" /></td>
			</tr>
			<tr>
				<td><a
					href="javascript: function myFunction() {return false; }"
					onClick="popupPage(700,960,'../oscarEncounter/oscarConsultationRequest/DisplayDemographicConsultationRequests.jsp?de=<%=demographic.getDemographicNo()%>&proNo=<%=demographic.getProviderNo()%>')"><bean:message
					key="demographic.demographiceditdemographic.btnConsultation" /></a></td>
			</tr>

			<tr>
				<td><a
					href="javascript: function myFunction() {return false; }"
					onClick="popupOscarRx(700,1027,'../oscarRx/choosePatient.do?providerNo=<%=curProvider_no%>&demographicNo=<%=demographic_no%>')"><bean:message
					key="global.prescriptions" /></a>
				</td>
			</tr>

			<security:oscarSec roleName="<%=roleName$%>" objectName="_eChart"
				rights="r" reverse="<%=false%>">
                    <special:SpecialEncounterTag moduleName="eyeform" reverse="true">
                    <tr><td>
					<a href="javascript: function myFunction() {return false; }" onClick="popupEChart(710, 1024,encURL);return false;" title="<bean:message key="demographic.demographiceditdemographic.btnEChart"/>">
					<bean:message key="demographic.demographiceditdemographic.btnEChart" /></a>&nbsp;<a style="text-decoration: none;" href="javascript: function myFunction() {return false; }" onmouseover="return !showMenu('1', event);">+</a>
					<div id='menu1' class='menu' onclick='event.cancelBubble = true;'>
					<h3 style='text-align: center'><bean:message key="demographic.demographiceditdemographic.msgEncType"/></h3>
					<br>
					<ul>
						<li><a href="#" onmouseover='this.style.color="black"' onmouseout='this.style.color="white"' onclick="return add2url('<bean:message key="oscarEncounter.faceToFaceEnc.title"/>');"><bean:message key="oscarEncounter.faceToFaceEnc.title"/>
						</a><br>
						</li>
						<li><a href="#" onmouseover='this.style.color="black"' onmouseout='this.style.color="white"' onclick="return add2url('<bean:message key="oscarEncounter.telephoneEnc.title"/>');"><bean:message key="oscarEncounter.telephoneEnc.title"/>
						</a><br>
						</li>
						<li><a href="#" onmouseover='this.style.color="black"' onmouseout='this.style.color="white"' onclick="return add2url('<bean:message key="oscarEncounter.noClientEnc.title"/>');"><bean:message key="oscarEncounter.noClientEnc.title"/>
						</a><br>
						</li>
						<li><a href="#" onmouseover='this.style.color="black"' onmouseout='this.style.color="white"' onclick="return customReason();"><bean:message key="demographic.demographiceditdemographic.msgCustom"/></a></li>
						<li id="listCustom" style="display: none;"><input id="txtCustom" type="text" size="16" maxlength="32" onkeypress="return grabEnterCustomReason(event);"></li>
					</ul>
					</div>
                    </td></tr>
                    </special:SpecialEncounterTag>
                    <special:SpecialEncounterTag moduleName="eyeform">
                    <tr><td>
                            <a href="javascript: function myFunction() {return false; }" onClick="popupEChart(710, 1024,encURL);return false;" title="<bean:message key="demographic.demographiceditdemographic.btnEChart"/>">
                            <bean:message key="demographic.demographiceditdemographic.btnEChart"/></a>
                    </td></tr>
                    </special:SpecialEncounterTag>
				<tr>
					<td><a
						href="javascript: function myFunction() {return false; }"
						onClick="popupPage(700,960,'<c:out value="${ctx}"/>/oscarPrevention/index.jsp?demographic_no=<%=demographic_no%>');return false;">
					<bean:message key="oscarEncounter.LeftNavBar.Prevent" /></a></td>
				</tr>
			</security:oscarSec>
                <plugin:hideWhenCompExists componentName="specialencounterComp" reverse="true">
<%session.setAttribute("encounter_oscar_baseurl",request.getContextPath());
%>
      			<special:SpecialEncounterTag moduleName="eyeform" exactEqual="true">

				<tr><td>
      			<a href="#" style="color: brown;" onclick="popupPage(600,800,'<%=request.getContextPath()%>/mod/specialencounterComp/PatientLog.do?method=editPatientLog&demographicNo=<%=demographic_no%>&providerNo=<%=curProvider_no%>&providerName=<%=URLEncoder.encode( userfirstname+" "+userlastname)%>');return false;">patient log</a>
      			</td>
      			</tr>
      			</special:SpecialEncounterTag>
      			<special:SpecialEncounterTag moduleName="eyeform">
      			<tr><td>
      			<a href="#" style="color: brown;" onclick="popupPage(600,600,'<%=request.getContextPath()%>/mod/specialencounterComp/EyeForm.do?method=eyeFormHistory&demographicNo=<%=demographic_no%>&providerNo=<%=curProvider_no%>&providerName=<%=URLEncoder.encode( userfirstname+" "+userlastname)%>');return false;">eyeForm Hx</a>
      			</td>
      			</tr>
      			<tr>
      			<td>
				<a href="#" style="color: brown;" onclick="popupPage(600,600,'<%=request.getContextPath()%>/mod/specialencounterComp/EyeForm.do?method=chooseField&&demographicNo=<%=demographic_no%>&providerNo=<%=curProvider_no%>&providerName=<%=URLEncoder.encode( userfirstname+" "+userlastname)%>');return false;">Exam Hx</a>
				</td>
				</tr>
				<tr>
				<td>
				<a href="#" style="color: brown;" onclick="popupPage(600,1000,'<%=request.getContextPath()%>/mod/specialencounterComp/ConReportList.do?method=list&&dno=<%=demographic_no%>');return false;">ConReport Hx</a>

      			</td></tr>
      			</special:SpecialEncounterTag>
      		</plugin:hideWhenCompExists>
			<tr>
				<td>
<%if( org.oscarehr.common.IsPropertiesOn.isTicklerPlusEnable() ) {%>
				<a
					href="javascript: function myFunction() {return false; }"
					onClick="popupPage(700,1000,'../Tickler.do?filter.demographic_no=<%=demographic_no%>');return false;">
				<bean:message key="global.tickler" /></a>
				<% }else { %>
				<a
					href="javascript: function myFunction() {return false; }"
					onClick="popupPage(700,1000,'../tickler/ticklerDemoMain.jsp?demoview=<%=demographic_no%>');return false;">
				<bean:message key="global.tickler" /></a>
				<% } %>
				</td>
			</tr>
			<tr>
				<td><a
					href="javascript: function myFunction() {return false; }"
					onClick="popup(700,960,'../oscarMessenger/SendDemoMessage.do?demographic_no=<%=demographic.getDemographicNo()%>','msg')">
				<bean:message key="demographic.demographiceditdemographic.msgSendMsg"/></a></td>
			</tr>
                        <tr>
                            <td> <a href="#" onclick="popup(300,300,'demographicCohort.jsp?demographic_no=<%=demographic.getDemographicNo()%>', 'cohort'); return false;"><bean:message key="demographic.demographiceditdemographic.msgAddPatientSet"/></a>
                            </td>
                        </tr>
                        
           <%
           	if(loggedInInfo.getCurrentFacility().isIntegratorEnabled()) {
           %>             
           <tr>
               <td> <a href="#" onclick="popup(500,500,'../integrator/manage_linked_clients.jsp?demographicId=<%=demographic.getDemographicNo()%>', 'manage_linked_clients'); return false;">Integrator Linking</a>
               </td>
           </tr>
           <% } %>
				<phr:indivoRegistered provider="<%=curProvider_no%>"
					demographic="<%=demographic_no%>">
                                <tr class="Header">
				     <td style="font-weight: bold"><bean:message key="global.personalHealthRecord"/></td>
                                </tr>
					<tr>
						<td>
							<%
								String onclickString="alert('Please login to MyOscar first.')";

								MyOscarLoggedInInfo myOscarLoggedInInfo=MyOscarLoggedInInfo.getLoggedInInfo(session);
								if (myOscarLoggedInInfo!=null && myOscarLoggedInInfo.isLoggedIn()) onclickString="popupOscarRx(600,900,'../phr/PhrMessage.do?method=createMessage&providerNo="+curProvider_no+"&demographicNo="+demographic_no+"')";
							%>
							<a href="javascript: function myFunction() {return false; }" ONCLICK="<%=onclickString%>"	title="myOscar">
								<bean:message key="demographic.demographiceditdemographic.msgSendMsgPHR"/>
							</a>
						</td>
					</tr>
					<tr>
						<td>
							<a href="" onclick="popup(600, 1000, '<%=request.getContextPath()%>/demographic/viewPhrRecord.do?demographic_no=<%=demographic_no%>', 'viewPatientPHR'); return false;">View PHR Record</a>
						</td>
					</tr>
					<tr>
						<td>
							<%
								if (myOscarLoggedInInfo!=null && myOscarLoggedInInfo.isLoggedIn()) onclickString="popupOscarRx(600,900,'"+request.getContextPath()+"/admin/oscar_myoscar_sync_config_redirect.jsp')";
							%>
							<a href="javascript: function myFunction() {return false; }" ONCLICK="<%=onclickString%>"	title="myOscar">
								<bean:message key="demographic.demographiceditdemographic.MyOscarDataSync"/>
							</a>
						</td>
					</tr>
				</phr:indivoRegistered>
			
<% if (oscarProps.getProperty("clinic_no", "").startsWith("1022")) { // quick hack to make Dr. Hunter happy
%>
			<tr>
				<td><a
					href="javascript: function myFunction() {return false; }"
					onClick="popupPage(700,1000,'../form/forwardshortcutname.jsp?formname=AR1&demographic_no=<%=request.getParameter("demographic_no")%>');">AR1</a>
				</td>
			</tr>
			<tr>
				<td><a
					href="javascript: function myFunction() {return false; }"
					onClick="popupPage(700,1000,'../form/forwardshortcutname.jsp?formname=AR2&demographic_no=<%=request.getParameter("demographic_no")%>');">AR2</a>
				</td>
			</tr>
<% } %>
			<tr class="Header">
				<td style="font-weight: bold"><bean:message
					key="oscarEncounter.Index.clinicalResources" /></td>
			</tr>
                <special:SpecialPlugin moduleName="inboxmnger">
                <tr>
                <td>

                        <a href="#" onClick="window.open('../mod/docmgmtComp/DocList.do?method=list&&demographic_no=<%=demographic_no %>','_blank','resizable=yes,status=yes,scrollbars=yes');return false;">Inbox Manager</a><br>
              	</td>
              	</tr>
                 </special:SpecialPlugin>
                 <special:SpecialPlugin moduleName="inboxmnger" reverse="true">
			<tr><td>
				<a href="javascript: function myFunction() {return false; }"
					onClick="popupPage(710,970,'../dms/documentReport.jsp?function=demographic&doctype=lab&functionid=<%=demographic.getDemographicNo()%>&curUser=<%=curProvider_no%>')"><bean:message
					key="demographic.demographiceditdemographic.msgDocuments" /></a></td>
			</tr>
                        <%
                        UserProperty upDocumentBrowserLink = pref.getProp(curProvider_no, UserProperty.EDOC_BROWSER_IN_MASTER_FILE);
                        if ( upDocumentBrowserLink != null && upDocumentBrowserLink.getValue() != null && upDocumentBrowserLink.getValue().equals("yes")) {%>
                        <tr><td>
				<a href="javascript: function myFunction() {return false; }"
					onClick="popupPage(710,970,'../dms/documentBrowser.jsp?function=demographic&doctype=lab&functionid=<%=demographic.getDemographicNo()%>&categorykey=Private Documents')"><bean:message
					key="demographic.demographiceditdemographic.msgDocumentBrowser" /></a></td>
			</tr>
                        <%}%>
			<tr>
				<td><a
					href="javascript: function myFunction() {return false; }"
					onClick="popupPage(710,970,'../dms/documentReport.jsp?function=demographic&doctype=lab&functionid=<%=demographic.getDemographicNo()%>&curUser=<%=curProvider_no%>&mode=add')"><bean:message
					key="demographic.demographiceditdemographic.btnAddDocument" /></a></td>
			</tr>
                </special:SpecialPlugin>
                <special:SpecialEncounterTag moduleName="eyeform">
<% String iviewTag=oscarProps.getProperty("iviewTag");

if (iviewTag!=null && !"".equalsIgnoreCase(iviewTag.trim())){
%>
	    		<tr><td>
				<a href='<%=request.getContextPath()%>/mod/specialencounterComp/iviewServlet?method=iview&demoNo=<%=demographic.getDemographicNo()%>&<%=System.currentTimeMillis() %>'>
				<%=iviewTag %></a>
				</td></tr>
<%} %>
		</special:SpecialEncounterTag>
			<tr>
				<td><a
					href="../eform/efmpatientformlist.jsp?demographic_no=<%=demographic_no%>&apptProvider=<%=apptProvider%>&appointment=<%=appointment%>"><bean:message
					key="demographic.demographiceditdemographic.btnEForm" /></a></td>
			</tr>
			<tr>
				<td><a
					href="../eform/efmformslistadd.jsp?demographic_no=<%=demographic_no%>&appointment=<%=appointment%>">
				<bean:message
					key="demographic.demographiceditdemographic.btnAddEForm" /> </a></td>
			</tr>
			
			<% if (isSharingCenterEnabled) { %>
			<!-- Sharing Center Links -->
			<tr>
			  <td><a href="../sharingcenter/networks/sharingnetworks.jsp?demographic_no=<%=demographic_no%>"><bean:message key="sharingcenter.networks.sharingnetworks" /></a></td>
			</tr>
			<tr>
			  <td><a href="../sharingcenter/documents/SharedDocuments.do?demographic_no=<%=demographic_no%>"><bean:message key="sharingcenter.documents.shareddocuments" /></a></td>
			</tr>
			<% } // endif isSharingCenterEnabled %>

		</table>
		</td>
		<td class="MainTableRightColumn" valign="top">
                    <!-- A list used in the mobile version for users to pick which information they'd like to see -->
                    <div id="mobileDetailSections" style="display:<%=(isMobileOptimized)?"block":"none"%>;">
                        <ul class="wideList">
                            <% if (!"".equals(alert)) { %>
                            <li><a style="color:brown" onClick="showHideMobileSections(new Array('alert'))"><bean:message
                                key="demographic.demographiceditdemographic.formAlert" /></a></li>
                            <% } %>
                            <li><a onClick="showHideMobileSections(new Array('demographic'))"><bean:message
                                key="demographic.demographiceditdemographic.msgDemographic"/></a></li>
                            <li><a onClick="showHideMobileSections(new Array('contactInformation'))"><bean:message
                                key="demographic.demographiceditdemographic.msgContactInfo"/></a></li>
                            <li><a onClick="showHideMobileSections(new Array('otherContacts'))"><bean:message
                                key="demographic.demographiceditdemographic.msgOtherContacts"/></a></li>
                            <li><a onClick="showHideMobileSections(new Array('healthInsurance'))"><bean:message
                                key="demographic.demographiceditdemographic.msgHealthIns"/></a></li>
                            <li><a onClick="showHideMobileSections(new Array('patientClinicStatus','clinicStatus'))"><bean:message
                                key="demographic.demographiceditdemographic.msgClinicStatus"/></a></li>
                            <li><a onClick="showHideMobileSections(new Array('notes'))"><bean:message
                                key="demographic.demographiceditdemographic.formNotes" /></a></li>
                        </ul>
                    </div>
		<table border=0 width="100%">
			<tr id="searchTable">
				<td colspan="4"><%-- log:info category="Demographic">Demographic [<%=demographic_no%>] is viewed by User [<%=userfirstname%> <%=userlastname %>]  </log:info --%>
				<jsp:include page="zdemographicfulltitlesearch.jsp"/>
				</td>
			</tr>
			<tr>
				<td>
				<form method="post" name="updatedelete" id="updatedelete"
					action="demographiccontrol.jsp"
					onSubmit="return checkTypeInEdit();"><input type="hidden"
					name="demographic_no"
					value="<%=demographic.getDemographicNo()%>">
				<table width="100%" class="demographicDetail">
					<tr>
						<td class="RowTop">
						<%
						oscar.oscarDemographic.data.DemographicMerged dmDAO = new oscar.oscarDemographic.data.DemographicMerged();
                            String dboperation = "search_detail";
                            String head = dmDAO.getHead(demographic_no);
                            ArrayList records = dmDAO.getTail(head);
                           
                                    %><a
							href="demographiccontrol.jsp?demographic_no=<%= head %>&displaymode=edit&dboperation=<%= dboperation %>"><%=head%></a>
						<%

                                for (int i=0; i < records.size(); i++){
                                    if (((String) records.get(i)).equals(demographic_no)){
                                        %><%=", "+demographic_no %>
						<%
                                    }else{
                                        %>, <a
							href="demographiccontrol.jsp?demographic_no=<%= records.get(i) %>&displaymode=edit&dboperation=<%= dboperation %>"><%=records.get(i)%></a>
						<%
                                    }
                                }
                            %> ) </span></b>
                            
                            <security:oscarSec roleName="<%=roleName$%>" objectName="_demographic" rights="w">
                            <%
                                                    if( head.equals(demographic_no)) {
                                                    %>
                                                        <a id="editBtn" href="javascript: showHideDetail();"><bean:message key="demographic.demographiceditdemographic.msgEdit"/></a>
                                                        <a id="closeBtn" href="javascript: showHideDetail();" style="display:none;">Close</a>
                                                   <% } %>
                              </security:oscarSec>
						</td>
					</tr>
<%
String printEnvelope, printLbl, printAddressLbl, printChartLbl, printSexHealthLbl, printHtmlLbl, printLabLbl;
printEnvelope = printLbl = printAddressLbl = printChartLbl = printSexHealthLbl = printHtmlLbl = printLabLbl = null;

if(oscarProps.getProperty("new_label_print") != null && oscarProps.getProperty("new_label_print").equals("true")) {

	printEnvelope = "printEnvelope.jsp?demos=";
	printLbl = "printDemoLabel.jsp?demographic_no=";
	printAddressLbl = "printAddressLabel.jsp?demographic_no=";
	printChartLbl = "printDemoChartLabel.jsp?demographic_no=";
	printSexHealthLbl = "printDemoChartLabel.jsp?labelName=SexualHealthClinicLabel&demographic_no=";
	printHtmlLbl = "demographiclabelprintsetting.jsp?demographic_no=";
	printLabLbl = "printClientLabLabel.jsp?demographic_no=";

}else{

	printEnvelope = "../report/GenerateEnvelopes.do?demos=";
	printLbl = "printDemoLabelAction.do?demographic_no=";
	printAddressLbl = "printDemoAddressLabelAction.do?demographic_no=";
	printChartLbl = "printDemoChartLabelAction.do?demographic_no=";
	printSexHealthLbl = "printDemoChartLabelAction.do?labelName=SexualHealthClinicLabel&demographic_no=";
	printHtmlLbl = "demographiclabelprintsetting.jsp?demographic_no=";
	printLabLbl = "printClientLabLabelAction.do?demographic_no=";

}

%>
<%if (OscarProperties.getInstance().getProperty("workflow_enhance") != null && OscarProperties.getInstance().getProperty("workflow_enhance").equals("true")) {%>
					
					<tr bgcolor="#CCCCFF">
                        <td colspan="4">
                        <table border="0" width="100%" cellpadding="0" cellspacing="0">
                            <tr>
                                <td width="30%" valign="top">
                                                             
                                <input type="hidden" name="displaymode" value="Update Record">
                                
                                <input type="hidden" name="dboperation" value="update_record">
                            
                            <security:oscarSec roleName="<%=roleName$%>" objectName="_demographicExport" rights="r" reverse="<%=false%>">
                                <input type="button" value="<bean:message key="demographic.demographiceditdemographic.msgExport"/>"
                                    onclick="window.open('demographicExport.jsp?demographicNo=<%=demographic.getDemographicNo()%>');">
                             </security:oscarSec>     
                                </td>
                                <td width="30%" align='center' valign="top">
                                <% if (OscarProperties.getInstance().getBooleanProperty("workflow_enhance", "true")) { %>
									<span style="position: relative; float: right; font-style: italic; background: black; color: white; padding: 4px; font-size: 12px; border-radius: 3px;">
										<span class="_hc_status_icon _hc_status_success"></span>Ready for Card Swipe
									</span>
								<% } %>	
                                <% if (!OscarProperties.getInstance().getBooleanProperty("workflow_enhance", "true")) { %>
								<span id="swipeButton" style="display: inline;"> 
                                    <input type="button" name="Button"
                                    value="<bean:message key="demographic.demographiceditdemographic.btnSwipeCard"/>"
                                    onclick="window.open('zdemographicswipe.jsp','', 'scrollbars=yes,resizable=yes,width=600,height=300, top=360, left=0')">
                                </span> <!--input type="button" name="Button" value="<bean:message key="demographic.demographiceditdemographic.btnSwipeCard"/>" onclick="javascript:window.alert('Health Card Number Already Inuse');"-->
                                <% } %>
                                </td>
                                <td width="40%" align='right' valign="top">
								<input type="button" size="110" name="Button"
								    value="<bean:message key="demographic.demographiceditdemographic.btnCreatePDFEnvelope"/>"
								    onclick="popupPage(400,700,'<%=printEnvelope%><%=demographic.getDemographicNo()%>');return false;">
								<input type="button" size="110" name="Button"
								    value="<bean:message key="demographic.demographiceditdemographic.btnCreatePDFLabel"/>"
								    onclick="popupPage(400,700,'<%=printLbl%><%=demographic.getDemographicNo()%>');return false;">
								<input type="button" size="110" name="Button"
								    value="<bean:message key="demographic.demographiceditdemographic.btnCreatePDFAddressLabel"/>"
								    onclick="popupPage(400,700,'<%=printAddressLbl%><%=demographic.getDemographicNo()%>');return false;">
								<input type="button" size="110" name="Button"
								    value="<bean:message key="demographic.demographiceditdemographic.btnCreatePDFChartLabel"/>"
								    onclick="popupPage(400,700,'<%=printChartLbl%><%=demographic.getDemographicNo()%>');return false;">
								    <%
										if(oscarVariables.getProperty("showSexualHealthLabel", "false").equals("true")) {
									%>
								<input type="button" size="110" name="Button"
								    value="<bean:message key="demographic.demographiceditdemographic.btnCreatePublicHealthLabel"/>"
								    onclick="popupPage(400,700,'<%=printSexHealthLbl%><%=demographic.getDemographicNo()%>');return false;">
								    <% } %>
								<input type="button" name="Button" size="110"
								    value="<bean:message key="demographic.demographiceditdemographic.btnPrintLabel"/>"
								    onclick="popupPage(600,800,'<%=printHtmlLbl%><%=demographic.getDemographicNo()%>');return false;">
								<input type="button" size="110" name="Button"
								    value="<bean:message key="demographic.demographiceditdemographic.btnClientLabLabel"/>"
								    onclick="popupPage(400,700,'<%=printLabLbl%><%=demographic.getDemographicNo()%>');return false;">
                                </td>
                              </tr>
                        </table>
                        </td>
                    </tr>
					
					
					<%} %>
					
					<tr>
						<td class="lightPurple"><!---new-->
						<div style="display: inline;" id="viewDemographics2">
						<div class="demographicWrapper">
						<div class="leftSection">
						<div class="demographicSection" id="demographic">
						<h3>&nbsp;<bean:message key="demographic.demographiceditdemographic.msgDemographic"/></h3>
						<%
							for (String key : demoExt.keySet()) {
							    if (key.endsWith("_id")) {
						%>
						<input type="hidden" name="<%=key%>" value="<%=StringEscapeUtils.escapeHtml(StringUtils.trimToEmpty(demoExt.get(key)))%>"/>
						<%
							    }
							}
						%>
						<ul>
                                                    <li><span class="label"><bean:message
                                                            key="demographic.demographiceditdemographic.formLastName" />:</span>
                                                        <span class="info"><%=demographic.getLastName()%></span>
                                                    </li>
                                                    <li><span class="label">
							<bean:message
                                                                key="demographic.demographiceditdemographic.formFirstName" />:</span>
                                                        <span class="info"><%=demographic.getFirstName()%></span>
							</li>
                                                    <li><span class="label"><bean:message key="demographic.demographiceditdemographic.msgDemoTitle"/>:</span>
                                                        <span class="info"><%=StringUtils.trimToEmpty(demographic.getTitle())%></span>
							</li>
                                                    <li><span class="label"><bean:message key="demographic.demographiceditdemographic.formSex" />:</span>
                                                        <span class="info"><%=demographic.getSex()%></span>
                                                    </li>
                                                    <li><span class="label"><bean:message key="demographic.demographiceditdemographic.msgDemoAge"/>:</span>
                                                        <span class="info"><%=age%>&nbsp;(<bean:message
                                                            key="demographic.demographiceditdemographic.formDOB" />: <%=birthYear%>-<%=birthMonth%>-<%=birthDate%>)
                                                        </span>
                                                    </li>
                                                    <li><span class="label"><bean:message key="demographic.demographiceditdemographic.msgDemoLanguage"/>:</span>
                                                        <span class="info"><%=StringUtils.trimToEmpty(demographic.getOfficialLanguage())%></span>
                                                    </li>
						<% if (demographic.getCountryOfOrigin() != null &&  !demographic.getCountryOfOrigin().equals("") && !demographic.getCountryOfOrigin().equals("-1")){
                                                        CountryCode countryCode = ccDAO.getCountryCode(demographic.getCountryOfOrigin());
                                                        if  (countryCode != null){
                                                    %>
                                                <li><span class="label"><bean:message key="demographic.demographiceditdemographic.msgCountryOfOrigin"/>:</span>
                                                    <span class="info"><%=countryCode.getCountryName() %></span>
                                                </li><%      }
                                                    }
                                                %>
						<% String sp_lang = demographic.getSpokenLanguage();
						   if (sp_lang!=null && sp_lang.length()>0) { %>
                                               <li><span class="label"><bean:message key="demographic.demographiceditdemographic.msgSpokenLang"/>:</span>
                                                   <span class="info"><%=sp_lang%></span>
							</li>
						<% } %>
						
						<% String aboriginal = StringUtils.trimToEmpty(demoExt.get("aboriginal"));
						   if (aboriginal!=null && aboriginal.length()>0) { %>
                                               <li><span class="label"><bean:message key="demographic.demographiceditdemographic.aboriginal"/>:</span>
                                                   <span class="info"><%=aboriginal%></span>
							</li>
						<% }%>
						<oscar:oscarPropertiesCheck value="true" defaultVal="false" property="FIRST_NATIONS_MODULE">  
	                           <li><span class="label">
	                           	First Nations:</span>
	                            <span class="info">
	                            	<c:out value='${ pageScope.demoExtended["aboriginal"] }' />
	                            </span>
								</li>
						  </oscar:oscarPropertiesCheck> 
						 <% if (oscarProps.getProperty("EXTRA_DEMO_FIELDS") !=null){
                                              String fieldJSP = oscarProps.getProperty("EXTRA_DEMO_FIELDS");
                                              fieldJSP+= "View.jsp";
                                            %>
							<jsp:include page="<%=fieldJSP%>">
								<jsp:param name="demo" value="<%=demographic_no%>" />
							</jsp:include>
							<%}%>

						</ul>
						</div>

<%-- TOGGLE NEW CONTACTS UI --%>
<%if(!OscarProperties.getInstance().isPropertyActive("NEW_CONTACTS_UI")) { %>
						
						<div class="demographicSection" id="otherContacts">
						<h3>&nbsp;<bean:message key="demographic.demographiceditdemographic.msgOtherContacts"/>: <b><a
							href="javascript: function myFunction() {return false; }"
							onClick="popup(700,960,'AddAlternateContact.jsp?demo=<%=demographic.getDemographicNo()%>','AddRelation')">
						<bean:message key="demographic.demographiceditdemographic.msgAddRelation"/><!--i18n--></a></b></h3>
						<ul>
							<%DemographicRelationship demoRelation = new DemographicRelationship();
                                          List relList = demoRelation.getDemographicRelationshipsWithNamePhone(loggedInInfo, demographic.getDemographicNo().toString(), loggedInInfo.getCurrentFacility().getId());
                                          for (int reCounter = 0; reCounter < relList.size(); reCounter++){
                                             HashMap relHash = (HashMap) relList.get(reCounter);
                                             String dNo = (String)relHash.get("demographicNo");
                                             String workPhone = demographicManager.getDemographicWorkPhoneAndExtension(loggedInInfo, Integer.valueOf(dNo));
                                             
                                             
                                             String formattedWorkPhone = (workPhone != null && workPhone.length()>0 && !workPhone.equals("null") )?"  W:"+workPhone:"";
                                             String sdb = relHash.get("subDecisionMaker") == null?"":((Boolean) relHash.get("subDecisionMaker")).booleanValue()?"<span title=\"SDM\" >/SDM</span>":"";
                                             String ec = relHash.get("emergencyContact") == null?"":((Boolean) relHash.get("emergencyContact")).booleanValue()?"<span title=\"Emergency Contact\">/EC</span>":"";
											 String masterLink = "<a target=\"demographic"+dNo+"\" href=\"" + request.getContextPath() + "/demographic/demographiccontrol.jsp?demographic_no="+dNo+"&displaymode=edit&dboperation=search_detail\">M</a>";
											 String encounterLink = "<a target=\"encounter"+dNo+"\" href=\"javascript: function myFunction() {return false; }\" onClick=\"popupEChart(710,1024,'" + request.getContextPath() + "/oscarEncounter/IncomingEncounter.do?demographicNo="+dNo+"&providerNo="+loggedInInfo.getLoggedInProviderNo()+"&appointmentNo=&curProviderNo=&reason=&appointmentDate=&startTime=&status=&userName="+URLEncoder.encode( userfirstname+" "+userlastname)+"&curDate="+curYear+"-"+curMonth+"-"+curDay+"');return false;\">E</a>";												 
                                          %>
							<li><span class="label"><%=relHash.get("relation")%><%=sdb%><%=ec%>:</span>
                            	<span class="info"><%=relHash.get("lastName")%>, <%=relHash.get("firstName")%>, H:<%=relHash.get("phone")== null?"":relHash.get("phone")%><%=formattedWorkPhone%> <%=masterLink%> <%=encounterLink %></span>
                            </li>
							<%}%>

						</ul>
						</div>

						<% } else { %>

						<div class="demographicSection" id="otherContacts2">
						<h3>&nbsp;<bean:message key="demographic.demographiceditdemographic.msgOtherContacts"/>: <b><a
							href="javascript: function myFunction() {return false; }"
							onClick="popup(700,960,'Contact.do?method=manage&demographic_no=<%=demographic.getDemographicNo()%>','ManageContacts')">
						<bean:message key="demographic.demographiceditdemographic.msgManageContacts"/><!--i18n--></a></b></h3>
						<ul>
						<%
							ContactDao contactDao = (ContactDao)SpringUtils.getBean("contactDao");
							DemographicContactDao dContactDao = (DemographicContactDao)SpringUtils.getBean("demographicContactDao");
							List<DemographicContact> dContacts = dContactDao.findByDemographicNo(demographic.getDemographicNo());
							dContacts = ContactAction.fillContactNames(dContacts);
							for(DemographicContact dContact:dContacts) {
								String sdm = (dContact.getSdm()!=null && dContact.getSdm().equals("true"))?"<span title=\"SDM\" >/SDM</span>":"";
								String ec = (dContact.getEc()!=null && dContact.getEc().equals("true"))?"<span title=\"Emergency Contact\" >/EC</span>":"";
						%>

								<li><span class="label"><%=dContact.getRole()%>:</span>
                                                            <span class="info"><%=dContact.getContactName() %><%=sdm%><%=ec%></span>
                                                        </li>

						<%  } %>

						</ul>
						</div>

						<% } %>
						<div class="demographicSection" id="clinicStatus">
						<h3>&nbsp;<bean:message key="demographic.demographiceditdemographic.msgClinicStatus"/> (<a href="#" onclick="popup(1000, 650, 'EnrollmentHistory.jsp?demographicNo=<%=demographic_no%>', 'enrollmentHistory'); return false;"><bean:message key="demographic.demographiceditdemographic.msgEnrollmentHistory"/></a>)</h3>
						<ul>
                                                    <li><span class="label"><bean:message
                                                            key="demographic.demographiceditdemographic.formRosterStatus" />:</span>
                                                        <span class="info"><%=StringUtils.trimToEmpty(demographic.getRosterStatus())%></span>
                                                    </li>
                                                    <li><span class="label"><bean:message
                                                            key="demographic.demographiceditdemographic.DateJoined" />:</span>
                                                        <span class="info"><%=MyDateFormat.getMyStandardDate(demographic.getRosterDate())%></span>
                                                    </li>
                                                    <li><span class="label"><bean:message
                                                            key="demographic.demographiceditdemographic.RosterTerminationDate" />:</span>
                                                        <span class="info"><%=MyDateFormat.getMyStandardDate(demographic.getRosterTerminationDate())%></span>
                                                    </li>
<%if (null != demographic.getRosterTerminationDate()) { %>
													<li><span class="label"><bean:message
                                                            key="demographic.demographiceditdemographic.RosterTerminationReason" />:</span>
                                                        <span class="info"><%=Util.rosterTermReasonProperties.getReasonByCode(demographic.getRosterTerminationReason()) %></span>
                                                    </li>
<%} %>
                                                    <li><span class="label"><bean:message
								key="demographic.demographiceditdemographic.formPatientStatus" />:</span>
                                                        <span class="info">
							<%
String PatStat = demographic.getPatientStatus();
String Dead = "DE";
String Inactive = "IN";

if ( Dead.equals(PatStat) ) {%>
							<b style="color: #FF0000;"><%=demographic.getPatientStatus()%></b>
							<%} else if (Inactive.equals(PatStat) ){%>
							<b style="color: #0000FF;"><%=demographic.getPatientStatus()%></b>
							<%} else {%>
                                                            <%=demographic.getPatientStatus()%>
							<%}%>
                                                        </span>
							</li>
							 <li><span class="label">
							 	<bean:message key="demographic.demographiceditdemographic.PatientStatusDate" />:</span>
                                <span class="info">
                                <%
                                String tmpDate="";
                                if(demographic.getPatientStatusDate ()!= null) {
                                	tmpDate = org.apache.commons.lang.time.DateFormatUtils.ISO_DATE_FORMAT.format(demographic.getPatientStatusDate());
                                }
                                %>
                                <%=tmpDate%></span>
							</li>
							
                                                    <li><span class="label"><bean:message
                                                            key="demographic.demographiceditdemographic.formChartNo" />:</span>
                                                        <span class="info"><%=StringUtils.trimToEmpty(demographic.getChartNo())%></span>
							</li>
							<% if (oscarProps.isPropertyActive("meditech_id")) { %>
                                                    <li><span class="label">Meditech ID:</span>
                                                        <span class="info"><%=OtherIdManager.getDemoOtherId(demographic_no, "meditech_id")%></span>
							</li>
<% } %>
                                                    <li><span class="label"><bean:message
                                                            key="demographic.demographiceditdemographic.cytolNum" />:</span>
                                                        <span class="info"><%=StringUtils.trimToEmpty(demoExt.get("cytolNum"))%></span></li>
                                                    <li><span class="label"><bean:message
                                                            key="demographic.demographiceditdemographic.formDateJoined1" />:</span>
							<span class="info"><%=MyDateFormat.getMyStandardDate(demographic.getDateJoined())%></span>
                                                    </li><li>
                                                        <span class="label"><bean:message
                                                            key="demographic.demographiceditdemographic.formEndDate" />:</span>
                                                        <span class="info"><%=MyDateFormat.getMyStandardDate(demographic.getEndDate())%></span>
							</li>
						</ul>
						</div>
            
            <div class="demographicSection" id="patientType">
              <h3>&nbsp;<bean:message key="demographic.demographiceditdemographic.msgPatientType"/></h3>
              <ul>
                <li>								
                <span class="label"><bean:message key="demographic.demographiceditdemographic.formPatientType"/>:</span>
                <span class="info"><%=patientTypeDesc%></span>
              </li>
              <li>
                <span class="label"><bean:message key="demographic.demographiceditdemographic.formDemographicMiscId"/>:</span>
                <span class="info"><%=patientId%></span>
                </li>	
              </ul>
            </div>

            <div class="demographicSection" id="demographicGroups">
              <h3>&nbsp; <bean:message key="demographic.demographiceditdemographic.formDemographicGroups"/> </h3>
              <ul>
                <li>
                <% for (String groupName : demographicGroupNamesForPatient) { %>
                <span class="info"> <%=groupName%> </span>
                <% } %>
                </li>	
              </ul>
            </div>

						<div class="demographicSection" id="alert">
						<h3>&nbsp;<bean:message
							key="demographic.demographiceditdemographic.formAlert" /></h3>
                                                <b style="color: brown;"><%=alert%></b>
						&nbsp;
						</div>

						<div class="demographicSection" id="rxInteractionWarningLevel">
						<h3>&nbsp;<bean:message
							key="demographic.demographiceditdemographic.rxInteractionWarningLevel" /></h3>
                              <%
                              	String warningLevel = demoExt.get("rxInteractionWarningLevel");
                              	if(warningLevel==null) warningLevel="0";
	          					String warningLevelStr = "Not Specified";
	          					if(warningLevel.equals("1")) {warningLevelStr="Low";}
	          					if(warningLevel.equals("2")) {warningLevelStr="Medium";}
	          					if(warningLevel.equals("3")) {warningLevelStr="High";}
	          					if(warningLevel.equals("4")) {warningLevelStr="None";}
                              %>
						&nbsp;
						
						</div>
						
						<div class="demographicSection" id="paperChartIndicator">
						<h3>&nbsp;<bean:message
							key="demographic.demographiceditdemographic.paperChartIndicator" /></h3>
							<%
								String archived = demoExt.get("paper_chart_archived");
								String archivedStr = "", archivedDate = "", archivedProgram = "";
								if("YES".equals(archived)) {
									archivedStr="Yes";
								}
								if("NO".equals(archived)) {
									archivedStr="No";
								}
                      			if(demoExt.get("paper_chart_archived_date") != null) {
                      				archivedDate = demoExt.get("paper_chart_archived_date");
                      			}
                      			if(demoExt.get("paper_chart_archived_program") != null) {
                      				archivedProgram = demoExt.get("paper_chart_archived_program");
                      			}
							%>
                           <ul>
	                          <li><span class="label"><bean:message key="demographic.demographiceditdemographic.paperChartIndicator.archived"/>:</span>
	                              <span class="info"><%=archivedStr %></span>
	                          </li>
	                          <li><span class="label"><bean:message key="demographic.demographiceditdemographic.paperChartIndicator.dateArchived"/>:</span>
	                              <span class="info"><%=archivedDate %></span>
	                          </li>
	                          <li><span class="label"><bean:message key="demographic.demographiceditdemographic.paperChartIndicator.programArchived"/>:</span>
	                              <span class="info"><%=archivedProgram %></span>
	                          </li>
	                       </ul>
						</div>
						
<%-- TOGGLE PRIVACY CONSENTS --%>						
<oscar:oscarPropertiesCheck property="privateConsentEnabled" value="true">

		<div class="demographicSection" id="consent">
				<h3>&nbsp;<bean:message key="demographic.demographiceditdemographic.consent" /></h3>
                             
					<ul>
					
						<%
							String[] privateConsentPrograms = OscarProperties.getInstance().getProperty("privateConsentPrograms","").split(",");
							ProgramProvider pp = programManager2.getCurrentProgramInDomain(loggedInInfo,loggedInInfo.getLoggedInProviderNo());
		
							if(pp != null) {
								for(int x=0;x<privateConsentPrograms.length;x++) {
									if(privateConsentPrograms[x].equals(pp.getProgramId().toString())) {
										showConsentsThisTime=true;
									}
								}
							}
						
						if(showConsentsThisTime) { %>

	                          <li><span class="label"><bean:message key="demographic.demographiceditdemographic.privacyConsent"/>:</span>
	                              <span class="info"><%=privacyConsent %></span>
	                          </li>
	                          <li><span class="label"><bean:message key="demographic.demographiceditdemographic.informedConsent"/>:</span>
	                              <span class="info"><%=informedConsent %></span>
	                          </li>
	                          <li><span class="label"><bean:message key="demographic.demographiceditdemographic.usConsent"/>:</span>
	                              <span class="info"><%=usSigned %></span>
	                          </li>
	                          
						
						<% } %>
    
<%-- ENABLE THE NEW PATIENT CONSENT MODULE --%>
<oscar:oscarPropertiesCheck property="USE_NEW_PATIENT_CONSENT_MODULE" value="true" >
		                          	
                          		<c:forEach items="${ patientConsents }" var="patientConsent" >
                          		<li>
                          			<span class="popup label" onmouseover="nhpup.popup(${ patientConsent.consentType.description },{'width':350} );" >
										<c:out value="${ patientConsent.consentType.name }" />
									</span>
                          			
                          			<c:choose>
										<c:when test="${ patientConsent.optout }">
											<span class="info" style="color:red;"> Opted Out:<c:out value="${ patientConsent.optoutDate }" /></span>
										</c:when>
															
										<c:otherwise>
											<span class="info" style="color:green;">Consented:<c:out value="${ patientConsent.consentDate }" /></span>
										</c:otherwise>				
									</c:choose>		
                          				
                          		</li>	
                          		</c:forEach>	                              	
</oscar:oscarPropertiesCheck>
<%-- END ENABLE NEW PATIENT CONSENT MODULE --%>

	                       </ul>						
						</div>
						
</oscar:oscarPropertiesCheck>	                      
<%-- END TOGGLE ALL PRIVACY CONSENTS --%>

						</div>
						<div class="rightSection">
						<div class="demographicSection" id="contactInformation">
						<h3>&nbsp;<bean:message key="demographic.demographiceditdemographic.msgContactInfo"/></h3>
						<ul>
                                                    <li><span class="label"><bean:message
                                                            key="demographic.demographiceditdemographic.formPhoneH" />(<span class="popup"  onmouseover="nhpup.popup(homePhoneHistory);" title="Home phone History">History</span>):</span>
                                                        <span class="info"><%=StringUtils.trimToEmpty(demographic.getPhone())%> <%=StringUtils.trimToEmpty(demoExt.get("hPhoneExt"))%></span>
							</li>
                                                    <li><span class="label"><bean:message
                                                            key="demographic.demographiceditdemographic.formPhoneW" />(<span class="popup"  onmouseover="nhpup.popup(workPhoneHistory);" title="Work phone History">History</span>):</span>
                                                        <span class="info"><%=StringUtils.trimToEmpty(demographic.getPhone2())%> <%=StringUtils.trimToEmpty(demoExt.get("wPhoneExt"))%></span>
							</li>
	                        						<li><span class="label"><bean:message
                                                            key="demographic.demographiceditdemographic.formPhoneC" />(<span class="popup"  onmouseover="nhpup.popup(cellPhoneHistory);" title="cell phone History">History</span>):</span>
                                                        <span class="info"><%=StringUtils.trimToEmpty(demoExt.get("demo_cell"))%></span></li>
                                                    <li><span class="label"><bean:message
                                                            key="demographic.demographicaddrecordhtm.formPhoneComment" />:</span>
                                                        <span class="info"><%=StringUtils.trimToEmpty(demoExt.get("phoneComment"))%></span></li>
                                                    <li><span class="label"><bean:message
                                                            key="demographic.demographiceditdemographic.formAddr" />(<span class="popup"  onmouseover="nhpup.popup(addressHistory);" title="Address History">History</span>):</span>
                                                        <span class="info"><%=StringUtils.trimToEmpty(demographic.getAddress())%></span>
							</li>
                                                    <li><span class="label"><bean:message
                                                            key="demographic.demographiceditdemographic.formCity" />:</span>
                                                        <span class="info"><%=StringUtils.trimToEmpty(demographic.getCity())%></span>
                                                    </li>
                                                    <li><span class="label">
							<% if(oscarProps.getProperty("demographicLabelProvince") == null) { %>
							<bean:message
								key="demographic.demographiceditdemographic.formProcvince" /> <% } else {
			                                  out.print(oscarProps.getProperty("demographicLabelProvince"));
                                                                               } %>:</span>
                                                        <span class="info"><%=StringUtils.trimToEmpty(demographic.getProvince())%></span></li>
                                                    <li><span class="label">
							<% if(oscarProps.getProperty("demographicLabelPostal") == null) { %>
							<bean:message
								key="demographic.demographiceditdemographic.formPostal" /> <% } else {
			                                  out.print(oscarProps.getProperty("demographicLabelPostal"));
                                                                               } %>:</span>
                                                       <span class="info"><%=StringUtils.trimToEmpty(demographic.getPostal())%></span></li>

                                                    <li><span class="label"><bean:message
                                                            key="demographic.demographiceditdemographic.formEmail" />:</span>
                                                        <span class="info"><%=demographic.getEmail()!=null? demographic.getEmail() : ""%></span>
							</li>
                                                    <li><span class="label"><bean:message
                                                            key="demographic.demographiceditdemographic.formNewsLetter" />:</span>
                                                        <span class="info"><%=demographic.getNewsletter()!=null? demographic.getNewsletter() : "Unknown"%></span>
							</li>
						</ul>
						</div>

						<div class="demographicSection" id="healthInsurance">
						<h3>&nbsp;<bean:message key="demographic.demographiceditdemographic.msgHealthIns"/> <a href="#" onclick="popup(500, 500, '/CardSwipe/?hc=<%=StringUtils.trimToEmpty(demographic.getHin())%> <%=StringUtils.trimToEmpty(demographic.getVer())%>&providerNo=<%=StringUtils.trimToEmpty(curProvider_no)%>', 'Card Swipe'); return false;" style="float:right; padding-right: 5px;">Validate HC</a></h3>
						<ul>
                                                    <li><span class="label"><bean:message
								key="demographic.demographiceditdemographic.formHin" />:</span>
                                                                <span class="info"><%=StringUtils.trimToEmpty(demographic.getHin())%>
							&nbsp; <%=StringUtils.trimToEmpty(demographic.getVer())%></span>
							</li>
                                                    <li><span class="label"><bean:message
								key="demographic.demographiceditdemographic.formHCType" />:</span>
                                                        <span class="info"><%=demographic.getHcType()==null?"":demographic.getHcType() %></span>
							</li>
                                                    <li><span class="label"><bean:message
                                                            key="demographic.demographiceditdemographic.formEFFDate" />:</span>
                                                        <span class="info"><%=MyDateFormat.getMyStandardDate(demographic.getEffDate())%></span>
                                                    </li>
                                                    <li><span class="label"><bean:message
                                                            key="demographic.demographiceditdemographic.formHCRenewDate" />:</span>
                                                        <span class="info"><%=MyDateFormat.getMyStandardDate(demographic.getHcRenewDate())%></span>
                                                    </li>
						</ul>
						
						<%-- TOGGLE FIRST NATIONS MODULE --%>

						<oscar:oscarPropertiesCheck value="true" defaultVal="false" property="FIRST_NATIONS_MODULE">
						                  
											<jsp:include page="./displayFirstNationsModule.jsp" flush="false">
												<jsp:param name="demo" value="<%= demographic_no %>" />
											</jsp:include>
						
						</oscar:oscarPropertiesCheck>						
						
						<%-- END TOGGLE FIRST NATIONS MODULE --%>
						
						</div>

<%-- TOGGLE WORKFLOW_ENHANCE - SHOWS PATIENTS INTERNAL PROVIDERS AND RELATED SCHEDULE AVAIL --%>

<oscar:oscarPropertiesCheck value="true" property="workflow_enhance">
<%--if (OscarProperties.getInstance().getProperty("workflow_enhance")!=null && OscarProperties.getInstance().getProperty("workflow_enhance").equals("true")) {--%>
						
						<div class="demographicSection">
                        <h3>&nbsp;<bean:message key="demographic.demographiceditdemographic.msgInternalProviders"/></h3>
                        <div style="background-color: #EEEEFF;">
                        <ul>
			<%!	// ===== functions for quick appointment booking =====

				// convert hh:nn:ss format to elapsed minutes (from 00:00:00)
				int timeStrToMins (String timeStr) {
					String[] temp = timeStr.split(":");
					return Integer.parseInt(temp[0])*60+Integer.parseInt(temp[1]);
				}
			%>
			<%	// ===== quick appointment booking =====
				// database access object, data objects for looking things up
				
				
				
				String[] twoLetterDate = {"", "Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"};
						
				// build templateMap, which maps template codes to their associated duration
				Map<String, String> templateMap = new HashMap<String, String>();
				for(ScheduleTemplateCode stc : scheduleTemplateCodeDao.findTemplateCodes()) {
					templateMap.put(String.valueOf(stc.getCode()),stc.getDuration());
				}
				

				// build list of providers associated with this patient 
				Map<String, Map<String, Map<String,String>>> provMap = new HashMap<String, Map<String, Map<String,String>>>();
				if (demographic != null) {
					provMap.put("doctor", new HashMap<String, Map<String,String>>());
					provMap.get("doctor").put("prov_no", new HashMap<String, String>());
					provMap.get("doctor").get("prov_no").put("no", demographic.getProviderNo());
				}
				if (StringUtils.isNotEmpty(providerBean.getProperty(resident,""))) {
					provMap.put("prov1", new HashMap<String, Map<String,String>>());
					provMap.get("prov1").put("prov_no", new HashMap<String, String>());
					provMap.get("prov1").get("prov_no").put("no", resident);
				}
				if (StringUtils.isNotEmpty(providerBean.getProperty(midwife,""))) {
					provMap.put("prov2", new HashMap<String, Map<String,String>>());
					provMap.get("prov2").put("prov_no", new HashMap<String, String>());
					provMap.get("prov2").get("prov_no").put("no", midwife); 
				}
				if (StringUtils.isNotEmpty(providerBean.getProperty(nurse,""))) {
					provMap.put("prov3", new HashMap<String, Map<String,String>>());
					provMap.get("prov3").put("prov_no", new HashMap<String, String>());
					provMap.get("prov3").get("prov_no").put("no", nurse);
				}
				
				// precompute all data for the providers associated with this patient
				for (String thisProv : provMap.keySet()) {
					
					String thisProvNo = provMap.get(thisProv).get("prov_no").get("no");

					// starting tomorrow, look for available appointment slots
					Calendar qApptCal = new GregorianCalendar();
					qApptCal.add(Calendar.DATE, 1);
					int numDays = 0;
					int maxLookahead = 90;

					while ((numDays < 5) && (maxLookahead > 0)) {
						int qApptYear = qApptCal.get(Calendar.YEAR);
						int qApptMonth = (qApptCal.get(Calendar.MONTH)+1);
						int qApptDay = qApptCal.get(Calendar.DAY_OF_MONTH);
						String qApptWkDay = twoLetterDate[qApptCal.get(Calendar.DAY_OF_WEEK)];
                        String qCurDate = qApptYear+"-"+qApptMonth+"-"+qApptDay;
						
						// get timecode string template associated with this day, number of minutes each slot represents
						ScheduleTemplateDao dao = SpringUtils.getBean(ScheduleTemplateDao.class); 
						List<Object> timecodeResult = dao.findTimeCodeByProviderNo2(thisProvNo, ConversionUtils.fromDateString(qCurDate));

						// if theres a template on this day, continue
                        if (!timecodeResult.isEmpty()) {

                       	String timecode = StringUtils.trimToEmpty(String.valueOf(timecodeResult.get(0)));
                       	
                  	    int timecodeInterval = 1440/timecode.length();

						// build schedArr, which has 1s where template slots are
                   		int[] schedArr = new int[timecode.length()];
                   		String schedChar;
                   		for (int i=0; i<timecode.length(); i++) {
                           		schedChar = ""+timecode.charAt(i);
                           		if (!schedChar.equals("_")) {
									if (templateMap.get(""+timecode.charAt(i)) != null) {
                                     	schedArr[i] = 1;
									}
                           		}
                   		}

						// get list of appointments on this day
						int start_index, end_index;
						OscarAppointmentDao apptDao = SpringUtils.getBean(OscarAppointmentDao.class);
						// put 0s in schedArr where appointments are
						for(Appointment appt : apptDao.findByProviderAndDayandNotStatuses(thisProvNo, ConversionUtils.fromDateString(qCurDate), new String[] {"N", "C"})) {
							start_index = timeStrToMins(StringUtils.trimToEmpty(ConversionUtils.toTimeString(appt.getStartTime())))/timecodeInterval;
							end_index = timeStrToMins(StringUtils.trimToEmpty(ConversionUtils.toTimeString(appt.getEndTime())))/timecodeInterval;
							
							// very late appts may push us past the time range we care about 
							// trying to invalidate these times will lead to a ArrayIndexOutOfBoundsException
							// fix this so we stay within the bounds of schedArr
							if (end_index > (timecode.length()-1)) {
								end_index = timecode.length()-1;
							}

							// protect against the dual case as well
							if (start_index < 0) {
								start_index = 0;
							} 
							
							// handle appts of duration longer than template interval
							for (int i=start_index; i<=end_index; i++) {
								schedArr[i] = 0;
							}
						}

						// list slots that can act as start times for appointments of template specified length
						boolean enoughRoom;
						boolean validDay = false;
						int templateDuration, startHour, startMin;
						String startTimeStr, endTimeStr, sortDateStr;
						String timecodeChar;
						for (int i=0; i<timecode.length(); i++) {
							if (schedArr[i] == 1) {
								enoughRoom = true;
								timecodeChar = ""+timecode.charAt(i);
								templateDuration = Integer.parseInt(templateMap.get(timecodeChar));
								for (int n=0; n<templateDuration/timecodeInterval; n++) {
									if (((i+n) < (schedArr.length-1)) && (schedArr[i+n] != 1)) {
										enoughRoom=false;
									}
								}
								if (enoughRoom) {
									validDay = true;
									sortDateStr = qApptYear+"-"+String.format("%02d",qApptMonth)+"-"+String.format("%02d",qApptDay);
									if (!provMap.get(thisProv).containsKey(sortDateStr+","+qApptWkDay+" "+qApptMonth+"-"+qApptDay)) {
										provMap.get(thisProv).put(sortDateStr+","+qApptWkDay+" "+qApptMonth+"-"+qApptDay, new HashMap<String, String>());
									}
									startHour = i*timecodeInterval / 60;
									startMin = i*timecodeInterval % 60;
									startTimeStr = String.format("%02d",startHour)+":"+String.format("%02d",startMin);
									endTimeStr = String.format("%02d",startHour)+":"+String.format("%02d",startMin+timecodeInterval-1);

									provMap.get(thisProv).get(sortDateStr+","+qApptWkDay+" "+qApptMonth+"-"+qApptDay).put(startTimeStr+","+timecodeChar, "../appointment/addappointment.jsp?demographic_no="+demographic.getDemographicNo()+"&name="+URLEncoder.encode(demographic.getLastName()+","+demographic.getFirstName())+"&provider_no="+thisProvNo+"&bFirstDisp=true&year="+qApptYear+"&month="+qApptMonth+"&day="+qApptDay+"&start_time="+startTimeStr+"&end_time="+endTimeStr+"&duration="+templateDuration+"&search=true");
								}
							}
						}
						
						if (validDay) {
							numDays++;
						}
						}
						
						// look at the next day
						qApptCal.add(Calendar.DATE, 1);
						maxLookahead--;
					} 
				}
			%>
                            <% if (demographic.getProviderNo()!=null) { %>
                            <li>
<% if(oscarProps.getProperty("demographicLabelDoctor") != null) { out.print(oscarProps.getProperty("demographicLabelDoctor","")); } else { %>
                            <bean:message
                                key="demographic.demographiceditdemographic.formDoctor" />
                            <% } %>: <b><%=providerBean.getProperty(demographic.getProviderNo(),"")%></b>
                        <% // ===== quick appointment booking for doctor =====
                        if (provMap.get("doctor") != null) {
				%><br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<%
				boolean firstBar = true;
                                ArrayList<String> sortedDays = new ArrayList(provMap.get("doctor").keySet());
                                Collections.sort(sortedDays);
                                for (String thisDate : sortedDays) {
                                        if (!thisDate.equals("prov_no")) {
                                                if (!firstBar) {%>|<%}; firstBar = false;
	                                        String[] thisDateArr = thisDate.split(",");
						String thisDispDate = thisDateArr[1];
						%>
                                                <a style="text-decoration: none;" href="#" onclick="return !showAppt('_doctor_<%=thisDateArr[0]%>', event);"><b><%=thisDispDate%></b></a>
                                                <div id='menu_doctor_<%=thisDateArr[0]%>' class='menu' onclick='event.cancelBubble = true;' >
                                                <h3 style='text-align: center; color: black;'>Available Appts. (<%=thisDispDate%>)</h3>
						<ul>
                                                <%
                                                ArrayList<String> sortedTimes = new ArrayList(provMap.get("doctor").get(thisDate).keySet());
                                                Collections.sort(sortedTimes);
                                                for (String thisTime : sortedTimes) {
							String[] thisTimeArr = thisTime.split(",");
                                                        %><li>[<%=thisTimeArr[1]%>] <a href="#" onClick="popupPage(400,780,'<%=provMap.get("doctor").get(thisDate).get(thisTime) %>');return false;"><%= thisTimeArr[0] %></a></li><%
                                                }
                                                %></ul></div><%                                        }
                                }
                        }
                        %>
                            </li>
                            <% } if (StringUtils.isNotEmpty(providerBean.getProperty(nurse,""))) { %>
                            <li>Alt. Provider 1: <b><%=providerBean.getProperty(nurse,"")%></b>
                        <% // ===== quick appointment booking for prov1 =====
                        if (provMap.get("prov1") != null) {
				%><br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<%
				boolean firstBar = true;
                                ArrayList<String> sortedDays = new ArrayList(provMap.get("prov1").keySet());
                                Collections.sort(sortedDays);
                                for (String thisDate : sortedDays) {
                                        if (!thisDate.equals("prov_no")) {
                                                if (!firstBar) {%>|<%}; firstBar = false;
	                                        String[] thisDateArr = thisDate.split(",");
						String thisDispDate = thisDateArr[1];
						%>
                                                <a style="text-decoration: none;" href="#" onclick="return !showAppt('_prov1_<%=thisDateArr[0]%>', event);"><b><%=thisDispDate%></b></a>
                                                <div id='menu_prov1_<%=thisDateArr[0]%>' class='menu' onclick='event.cancelBubble = true;'>
                                                <h3 style='text-align: center; color: black;'>Available Appts. (<%=thisDispDate%>)</h3> 
                                                <ul>
                                                <%
                                                ArrayList<String> sortedTimes = new ArrayList(provMap.get("prov1").get(thisDate).keySet());
                                                Collections.sort(sortedTimes);
                                                for (String thisTime : sortedTimes) {
							String[] thisTimeArr = thisTime.split(",");
                                                        %><li>[<%=thisTimeArr[1]%>] <a href="#" onClick="popupPage(400,780,'<%=provMap.get("prov1").get(thisDate).get(thisTime) %>');return false;"><%= thisTimeArr[0] %></a></li><%
                                                }
                                                %></ul></div><%
                                        }
                                }
                        }
                        %>
                            </li>
                            <% } if (StringUtils.isNotEmpty(providerBean.getProperty(midwife,""))) { %>
                            <li>Alt. Provider 2: <b><%=providerBean.getProperty(midwife,"")%></b>
                        <% // ===== quick appointment booking for prov2 =====
                        if (provMap.get("prov2") != null) {
							%><br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<%
							boolean firstBar = true;
                            	ArrayList<String> sortedDays = new ArrayList(provMap.get("prov2").keySet());
                            	Collections.sort(sortedDays);
                            	   for (String thisDate : sortedDays) {
                                        if (!thisDate.equals("prov_no")) {
                                                if (!firstBar) {%>|<%}; firstBar = false;
	                                        String[] thisDateArr = thisDate.split(",");
						String thisDispDate = thisDateArr[1];
						%>
                                                <a style="text-decoration: none;" href="#" onclick="return !showAppt('_prov2_<%=thisDateArr[0]%>', event);"><b><%=thisDispDate%></b></a>
                                                <div id='menu_prov2_<%=thisDateArr[0]%>' class='menu' onclick='event.cancelBubble = true;'>
                                                <h3 style='text-align: center; color: black;'>Available Appts. (<%=thisDispDate%>)</h3> 
                                                <ul>
                                                <%
                                                ArrayList<String> sortedTimes = new ArrayList(provMap.get("prov2").get(thisDate).keySet());
                                                Collections.sort(sortedTimes);
                                                for (String thisTime : sortedTimes) {
							String[] thisTimeArr = thisTime.split(",");
                                                        %><li>[<%=thisTimeArr[1]%>] <a href="#" onClick="popupPage(400,780,'<%=provMap.get("prov2").get(thisDate).get(thisTime) %>');return false;"><%= thisTimeArr[0] %></a></li><%
                                                }
                                                %></ul></div><%
                                        }
                                }
                        }
                        %>
                            </li>
                            <% } if (StringUtils.isNotEmpty(providerBean.getProperty(resident,""))) { %>
                            <li>Alt. Provider 3: <b><%=providerBean.getProperty(resident,"")%></b>
                        <% // ===== quick appointment booking for prov3 =====
                        if (provMap.get("prov3") != null) {
							%><br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<%
							boolean firstBar = true;
                                ArrayList<String> sortedDays = new ArrayList(provMap.get("prov3").keySet());
                                Collections.sort(sortedDays);
                                for (String thisDate : sortedDays) {
                                        if (!thisDate.equals("prov_no")) {
                                                if (!firstBar) {%>|<%}; firstBar = false;
	                                        String[] thisDateArr = thisDate.split(",");
						String thisDispDate = thisDateArr[1];
						%>
                                                <a style="text-decoration: none;" href="#" onclick="return !showAppt('_prov3_<%=thisDateArr[0]%>', event);"><b><%=thisDispDate%></b></a>
                                                <div id='menu_prov3_<%=thisDateArr[0]%>' class='menu' onclick='event.cancelBubble = true;'>
                                                <h3 style='text-align: center; color: black;'>Available Appts. (<%=thisDispDate%>)</h3> 
                                                <ul>
                                                <%
                                                ArrayList<String> sortedTimes = new ArrayList(provMap.get("prov3").get(thisDate).keySet());
                                                Collections.sort(sortedTimes);
                                                for (String thisTime : sortedTimes) {
							String[] thisTimeArr = thisTime.split(",");
                                                        %><li>[<%=thisTimeArr[1]%>] <a href="#" onClick="popupPage(400,780,'<%=provMap.get("prov3").get(thisDate).get(thisTime) %>');return false;"><%= thisTimeArr[0] %></a></li><%
                                                }
                                                %></ul></div><%
                                        }
                                }
                        }
                        %>
                            </li>
                            <% } %> 
                         </ul>
                         </div>
                         </div>
						
						<%--} --%>
</oscar:oscarPropertiesCheck>
<%-- END TOGGLE WORKFLOW_ENHANCE --%>

<%-- AUTHOR DENNIS WARREN O/A COLCAMEX RESOURCES --%>
<oscar:oscarPropertiesCheck property="DEMOGRAPHIC_PATIENT_HEALTH_CARE_TEAM" value="true">
	<jsp:include page="displayHealthCareTeam.jsp">
		<jsp:param name="demographicNo" value="<%= demographic_no %>" />
	</jsp:include>
</oscar:oscarPropertiesCheck>
	<%-- TOGGLE OFF PATIENT CLINIC STATUS --%>
<oscar:oscarPropertiesCheck property="DEMOGRAPHIC_PATIENT_CLINIC_STATUS" value="true">
						
						<div class="demographicSection" id="patientClinicStatus">
						<h3>&nbsp;<bean:message key="demographic.demographiceditdemographic.msgPatientClinicStatus"/></h3>
						<ul>
                                                    <li><span class="label">
							<% if(oscarProps.getProperty("demographicLabelDoctor") != null) { out.print(oscarProps.getProperty("demographicLabelDoctor","")); } else { %>
							<bean:message
								key="demographic.demographiceditdemographic.formDoctor" />
                                                    <% } %>:</span><span class="info">
                                                    <%if(demographic != null && demographic.getProviderNo() != null){%>	
                                                           <%=providerBean.getProperty(demographic.getProviderNo(),"")%>
                                                    <%}%>
                                                    </span>
							</li>
                                                    <li><span class="label"><bean:message
                                                            key="<%= nurseMessageKey %>" />:</span><span class="info"><%=providerBean.getProperty(nurse == null ? "" : nurse,"")%></span>
							</li>
                                                    <li><span class="label"><bean:message
                                                            key="<%= midwifeMessageKey %>" />:</span><span class="info"><%=providerBean.getProperty(midwife == null ? "" : midwife,"")%></span>
							</li>
                                                    <li><span class="label"><bean:message
                                                            key="<%= residentMessageKey %>" />:</span>
                                                        <span class="info"><%=providerBean.getProperty(resident==null ? "" : resident,"")%></span></li>
                                                    <li><span class="label"><bean:message
                                                            key="demographic.demographiceditdemographic.formRefDoc" />:</span><span class="info"><%=rd%></span>
							</li>
							<li><span class="label">Referral Doctor Phone #:</span> <span class="info" id="refDocPhone"></span></li>
							<li><span class="label">Referral Doctor Fax #:</span> <span class="info" id="refDocFax"></span></li>
                                                    <li><span class="label"><bean:message
                                                            key="demographic.demographiceditdemographic.formRefDocNo" />:</span><span class="info"><%=rdohip%></span>
							</li>
                            <li><span class="label"><bean:message
                                    key="demographic.demographiceditdemographic.formFamDoc" />:</span><span class="info"><%=fam_doc_name%></span>
                            </li>
							<li><span class="label">Family Doctor Phone #:</span> <span class="info" id="famDocPhone"></span></li>
							<li><span class="label">Family Doctor Fax #:</span> <span class="info" id="famDocFax"></span></li>
                            <li><span class="label"><bean:message
                                    key="demographic.demographiceditdemographic.formFamDocNo" />:</span><span class="info"><%=fam_doc_ohip%></span>
                            </li>
						</ul>
						</div>
						
</oscar:oscarPropertiesCheck>

	<%-- END TOGGLE OFF PATIENT CLINIC STATUS --%>
	
<%-- END AUTHOR DENNIS WARREN O/A COLCAMEX RESOURCES --%>


						<div class="demographicSection" id="notes">
						<h3>&nbsp;<bean:message
							key="demographic.demographiceditdemographic.formNotes" /></h3>

                                                    <%=notes%>&nbsp;
<%if (hasImportExtra) { %>
		                <a href="javascript:void(0);" title="Extra data from Import" onclick="window.open('../annotation/importExtra.jsp?display=<%=annotation_display %>&amp;table_id=<%=demographic_no %>&amp;demo=<%=demographic_no %>','anwin','width=400,height=250');">
		                    <img src="../images/notes.gif" align="right" alt="Extra data from Import" height="16" width="13" border="0"> </a>
<%} %>


						</div>
						
<%-- TOGGLED OFF PROGRAM ADMISSIONS --%>
<oscar:oscarPropertiesCheck property="DEMOGRAPHIC_PROGRAM_ADMISSIONS" value="true">						
						<div class="demographicSection" id="programs">
						<h3>&nbsp;Programs</h3>
						<ul>
                         <li><span class="label">Bed:</span><span class="info"><%=bedAdmission != null?bedAdmission.getProgramName():"N/A" %></span></li>
                         <%
                         for(Admission adm:serviceAdmissions) {
                        	 %>
                        		 <li><span class="label">Service:</span><span class="info"><%=adm.getProgramName()%></span></li>
                         
                        	 <%
                         }
                         %>
						</ul>
                                                  
						</div>
</oscar:oscarPropertiesCheck>
<%-- TOGGLED OFF PROGRAM ADMISSIONS --%>

						</div>
						</div>

						<% // customized key
						if(oscarVariables.getProperty("demographicExt") != null) {
							String [] propDemoExt = oscarVariables.getProperty("demographicExt","").split("\\|");
						%>
						<div class="demographicSection" id="special">
						<h3>&nbsp;Special</h3>
						<% 	for(int k=0; k<propDemoExt.length; k++) {%> <%=propDemoExt[k]+": <b>" + StringUtils.trimToEmpty(demoExt.get(propDemoExt[k].replace(' ', '_'))) +"</b>"%>
						&nbsp;<%=((k+1)%4==0&&(k+1)<propDemoExt.length)?"<br>":"" %> <% 	} %>
						</div>
						<% } %>
						</div>

						<!--newEnd-->
						<jsp:include page="masterEdit.jsp">
							<jsp:param name="demographicNo" value="<%= demographic_no %>" />
							<jsp:param name="aboriginal" value="<%= aboriginal %>" />
							<jsp:param name="birthYear" value="<%= birthYear %>" />
							<jsp:param name="birthMonth" value="<%= birthMonth %>" />
							<jsp:param name="birthDate" value="<%= birthDate %>" />
							<jsp:param name="age" value="<%= age %>" />
							<jsp:param name="nurseMessageKey" value="<%= nurseMessageKey %>" />
							<jsp:param name="midwifeMessageKey" value="<%= midwifeMessageKey %>" />
							<jsp:param name="residentMessageKey" value="<%= residentMessageKey %>" />
							<jsp:param name="nurse" value="<%= nurse %>" />
							<jsp:param name="midwife" value="<%= midwife %>" />
							<jsp:param name="resident" value="<%= resident %>" />
							<jsp:param name="rdohip" value="<%= rdohip %>" />
							<jsp:param name="rd" value="<%= rd %>" />
							<jsp:param name="prov" value="<%= prov %>" />
							<jsp:param name="prov" value="<%= family_doc %>" />
							<jsp:param name="warningLevel" value="<%= warningLevel %>" />
							<jsp:param name="patientId" value="<%= patientId %>" />
							<jsp:param name="patientType" value="<%= patientType %>" />
							<jsp:param name="showConsentsThisTime" value="<%= showConsentsThisTime %>" />
							<jsp:param name="usSigned" value="<%= usSigned %>" />
							<jsp:param name="privacyConsent" value="<%= privacyConsent %>" />
							<jsp:param name="informedConsent" value="<%= informedConsent %>" />
							<jsp:param name="wLReadonly" value="<%= wLReadonly %>" />
							<jsp:param name="alert" value="<%= alert %>" />
							<jsp:param name="notes" value="<%= notes %>" />
						</jsp:include>
						

						</td>
					</tr>
<%-- END PATIENT NOTES MODULE --%>	
<%-- BOTTOM TOOLBAR  --%>				
					<tr class="darkPurple">
						<td colspan="4">
						<table border="0" width="100%" cellpadding="0" cellspacing="0">
							<tr>
								<td width="30%" valign="top">
								<input type="hidden" name="dboperation" value="update_record"> 

								 <security:oscarSec roleName="<%=roleName$%>" objectName="_demographicExport" rights="r" reverse="<%=false%>">
								<input type="button" value="<bean:message key="demographic.demographiceditdemographic.msgExport"/>"
									onclick="window.open('demographicExport.jsp?demographicNo=<%=demographic.getDemographicNo()%>');">
								</security:oscarSec>
									<br>
								<input
									type="button" name="Button" id="cancelButton" class="leftButton top"
									value="Exit Master Record"	onclick="self.close();">
								</td>
								<td width="30%" align='center' valign="top"><input
									type="hidden" name="displaymode" value="Update Record">
								<!-- security code block --> <span id="updateButton"
									style="display: none;"> <security:oscarSec
									roleName="<%=roleName$%>" objectName="_demographic" rights="w">
									<%
										boolean showCbiReminder=oscarProps.getBooleanProperty("CBI_REMIND_ON_UPDATE_DEMOGRAPHIC", "true");
									%>
									<input type="submit" <%=(showCbiReminder?"onclick='showCbiReminder()'":"")%>
										value="<bean:message key="demographic.demographiceditdemographic.btnUpdate"/>">
								</security:oscarSec> </span> <!-- security code block --></td>
								<td width="40%" align='right' valign="top"><span
									id="swipeButton" style="display: none;"> <input
									type="button" name="Button"
									value="<bean:message key="demographic.demographiceditdemographic.btnSwipeCard"/>"
									onclick="window.open('zdemographicswipe.jsp','', 'scrollbars=yes,resizable=yes,width=600,height=300, top=360, left=0')">
								</span> <!--input type="button" name="Button" value="<bean:message key="demographic.demographiceditdemographic.btnSwipeCard"/>" onclick="javascript:window.alert('Health Card Number Already Inuse');"-->
									<input type="button" size="110" name="Button"
									    value="<bean:message key="demographic.demographiceditdemographic.btnCreatePDFEnvelope"/>"
									    onclick="popupPage(400,700,'<%=printEnvelope%><%=demographic.getDemographicNo()%>');return false;">
									<input type="button" size="110" name="Button"
									    value="<bean:message key="demographic.demographiceditdemographic.btnCreatePDFLabel"/>"
									    onclick="popupPage(400,700,'<%=printLbl%><%=demographic.getDemographicNo()%>&appointment_no=<%=appointment%>');return false;">
									<input type="button" size="110" name="Button"
									    value="<bean:message key="demographic.demographiceditdemographic.btnCreatePDFAddressLabel"/>"
									    onclick="popupPage(400,700,'<%=printAddressLbl%><%=demographic.getDemographicNo()%>');return false;">
									<input type="button" size="110" name="Button"
									    value="<bean:message key="demographic.demographiceditdemographic.btnCreatePDFChartLabel"/>"
									    onclick="popupPage(400,700,'<%=printChartLbl%><%=demographic.getDemographicNo()%>');return false;">
									    <%
											if(oscarVariables.getProperty("showSexualHealthLabel", "false").equals("true")) {
										%>
									<input type="button" size="110" name="Button"
									    value="<bean:message key="demographic.demographiceditdemographic.btnCreatePublicHealthLabel"/>"
									    onclick="popupPage(400,700,'<%=printSexHealthLbl%><%=demographic.getDemographicNo()%>');return false;">
									    <% } %>
									<input type="button" name="Button" size="110"
									    value="<bean:message key="demographic.demographiceditdemographic.btnPrintLabel"/>"
									    onclick="popupPage(600,800,'<%=printHtmlLbl%><%=demographic.getDemographicNo()%>');return false;">
									<input type="button" size="110" name="Button"
									    value="<bean:message key="demographic.demographiceditdemographic.btnClientLabLabel"/>"
									    onclick="popupPage(400,700,'<%=printLabLbl%><%=demographic.getDemographicNo()%>');return false;">
								</td>
                                                        </tr>
						</table>
<%-- END BOTTOM TOOLBAR  --%>

						<%
							if (ConformanceTestHelper.enableConformanceOnlyTestFeatures)
							{
								String styleBut = "";
								if(ConformanceTestHelper.hasDifferentRemoteDemographics(loggedInInfo, Integer.parseInt(demographic$))){
                                                                       styleBut = " style=\"background-color:yellow\" ";
                                                                }%>
									<input type="button" value="Compare with Integrator" <%=styleBut%>  onclick="popup(425, 600, 'DiffRemoteDemographics.jsp?demographicId=<%=demographic$%>', 'RemoteDemoWindow')" />
									<input type="button" value="Update latest integrated demographics information" onclick="document.location='<%=request.getContextPath()%>/demographic/copyLinkedDemographicInfoAction.jsp?demographicId=<%=demographic$%>&<%=request.getQueryString()%>'" />
									<input type="button" value="Send note to integrated provider" onclick="document.location='<%=request.getContextPath()%>/demographic/followUpSelection.jsp?demographicId=<%=demographic$%>'" />
								<%
							}
						%>
						</td>
					</tr>
				</table>
				
                                </form>
				<%
                    }
                  }
                %>

		</table>
		</td>
	</tr>
	<tr>
		<td class="MainTableBottomRowLeftColumn"></td>
		<td class="MainTableBottomRowRightColumn"></td>
	</tr>
</table>

<oscar:oscarPropertiesCheck property="DEMOGRAPHIC_WAITING_LIST" value="true">
</oscar:oscarPropertiesCheck>

<script type="text/javascript">




function callEligibilityWebService(url,id){

       var ran_number=Math.round(Math.random()*1000000);
       var params = "demographic=<%=demographic_no%>&method=checkElig&rand="+ran_number;  //hack to get around ie caching the page
		 var response;
       new Ajax.Request(url+'?'+params, {
           onSuccess: function(response) {
                document.getElementById(id).innerHTML=response.responseText ;
                document.getElementById('search_spinner').innerHTML="";
           }
        } );
 }

<%
if (privateConsentEnabled) {
%>
jQuery(document).ready(function(){
	var countryOfOrigin = jQuery("#countryOfOrigin").val();
	if("US" != countryOfOrigin) {
		jQuery("#usSigned").hide();
	} else {
		jQuery("#usSigned").show();
	}
	
	jQuery("#countryOfOrigin").change(function () {
		var countryOfOrigin = jQuery("#countryOfOrigin").val();
		if("US" == countryOfOrigin){
		   	jQuery("#usSigned").show();
		} else {
			jQuery("#usSigned").hide();
		}
	});
});
<%
}
%>
if(jQuery("#roster_status").val() != "TE" && jQuery("#roster_status").val() != "NR"){
	jQuery(".termination_details").hide();
}
</script>
</body>
</html:html>


<%!
public String isProgramSelected(Admission admission, Integer programId) {
	if(admission != null && admission.getProgramId() != null && admission.getProgramId().equals(programId)) {
		return " selected=\"selected\" ";
	}
	
	return "";
}

	public String isProgramSelected(List<Admission> admissions, Integer programId) {
		for(Admission admission:admissions) {
			if(admission.getProgramId() != null && admission.getProgramId().equals(programId)) {
				return " checked=\"checked\" ";
			}
		}
		return "";
	}

%>
