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
<security:oscarSec roleName="<%=roleName$%>" objectName="_demographic" rights="w" reverse="<%=true%>">
	<%authed=false; %>
	<%response.sendRedirect(request.getContextPath() + "/securityError.jsp?type=_demographic");%>
</security:oscarSec>
<%
	if(!authed) {
		return;
	}
%>

<%@page import="org.oscarehr.provider.model.PreventionManager"%>
<%@ page import="java.sql.*, java.util.*, oscar.MyDateFormat, oscar.oscarWaitingList.util.WLWaitingListUtil, oscar.log.*, org.oscarehr.common.OtherIdManager"%>

<%@page import="org.apache.commons.lang.StringUtils"%>
<%@page import="org.oscarehr.util.MiscUtils"%>
<%@page import="org.oscarehr.util.SpringUtils" %>

<%@ page import="org.oscarehr.PMmodule.dao.ProgramDao" %>
<%@ page import="org.oscarehr.PMmodule.model.Program" %>
<%@page import="org.oscarehr.PMmodule.web.GenericIntakeEditAction" %>
<%@page import="org.oscarehr.PMmodule.service.ProgramManager" %>
<%@page import="org.oscarehr.PMmodule.service.AdmissionManager" %>
<%@page import="org.oscarehr.managers.PatientConsentManager" %>
<%@page import="org.oscarehr.util.LoggedInInfo" %>
<%@page import="oscar.OscarProperties" %>
<%@ page import="org.oscarehr.common.model.*" %>
<%@ page import="org.oscarehr.common.dao.*" %>
<%@ page import="javax.swing.*" %>
<%@ page import="org.oscarehr.casemgmt.model.ProviderExt" %>
<%@ page import="oscar.util.ChangedField" %>
<%@ page import="org.owasp.encoder.Encode" %>

<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean"%>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html"%>
<%@ taglib uri="/WEB-INF/struts-logic.tld" prefix="logic"%>


<%
	java.util.Properties oscarVariables = oscar.OscarProperties.getInstance();

    DemographicExtDao demographicExtDao = SpringUtils.getBean(DemographicExtDao.class);
    DemographicExtArchiveDao demographicExtArchiveDao = SpringUtils.getBean(DemographicExtArchiveDao.class);
	DemographicDao demographicDao = (DemographicDao)SpringUtils.getBean("demographicDao");
	DemographicArchiveDao demographicArchiveDao = (DemographicArchiveDao)SpringUtils.getBean("demographicArchiveDao");
	DemographicCustDao demographicCustDao = (DemographicCustDao)SpringUtils.getBean("demographicCustDao");
	AlertDao alertDao = SpringUtils.getBean(AlertDao.class);
	WaitingListDao waitingListDao = (WaitingListDao)SpringUtils.getBean("waitingListDao");
	OscarAppointmentDao appointmentDao = (OscarAppointmentDao)SpringUtils.getBean("oscarAppointmentDao");
	DemographicGroupLinkDao demographicGroupLinkDao = SpringUtils.getBean(DemographicGroupLinkDao.class);
	AppointmentReminderDao appointmentReminderDao = SpringUtils.getBean(AppointmentReminderDao.class);

	LoggedInInfo loggedInInfo=LoggedInInfo.getLoggedInInfoFromSession(request);
	
	
%>

<html:html locale="true">
<head>
<script type="text/javascript" src="<%= request.getContextPath() %>/js/global.js"></script></head>

<body>
<center>
<table border="0" cellspacing="0" cellpadding="0" width="100%">
	<tr bgcolor="#486ebd">
		<th align="CENTER"><font face="Helvetica" color="#FFFFFF">
		UPDATE demographic RECORD</font></th>
	</tr>
</table>
<%

	ResultSet rs = null;
	java.util.Locale vLocale =(java.util.Locale)session.getAttribute(org.apache.struts.Globals.LOCALE_KEY);
	
	Demographic demographic = demographicDao.getDemographic(request.getParameter("demographic_no"));
	Demographic oldDemographic = new Demographic(demographic);

	boolean updateFamily = false;
	if (request.getParameter("submit")!=null&&request.getParameter("submit").equalsIgnoreCase("Save & Update Family Members")){
		updateFamily = true;
	}

	List<Demographic> family = null;
	if (updateFamily){
		 family = demographicDao.getDemographicFamilyMembers(String.valueOf(demographic.getDemographicNo()));
	}

	SystemPreferencesDao systemPreferencesDao = SpringUtils.getBean(SystemPreferencesDao.class);
	Map<String, Boolean> masterFilePreferences = systemPreferencesDao.findByKeysAsMap(SystemPreferences.MASTER_FILE_PREFERENCE_KEYS);

	// Update Freshbooks section
	UserPropertyDAO propertyDao = (UserPropertyDAO) SpringUtils.getBean("UserPropertyDAO");
	String demoNo = request.getParameter("demographic_no");
	int demographicNo = Integer.parseInt(demoNo);
	List<DemographicExt> demoProviders = demographicExtDao.getMultipleDemographicExt(demographicNo, "freshbooksId");
	List<Appointment> demoAppointments = appointmentDao.getAllByDemographicNo(demographicNo);
	List<AppointmentReminder> demoReminders = new ArrayList<AppointmentReminder>();

	for(Appointment appointment : demoAppointments) {
	    AppointmentReminder appointmentReminder = appointmentReminderDao.getByAppointmentNo(appointment.getId());
	    if (appointmentReminder != null) {
	        demoReminders.add(appointmentReminder);
		}
	}

	String updateEmail = demographic.getEmail();
	String updateFirstName = demographic.getFirstName();
	String updateLastName = demographic.getLastName();
	String updateHomePhone = demographic.getPhone();
	String updateStreet = demographic.getAddress();
	String updatePostal = demographic.getPostal();
	String updateProvince = demographic.getProvince();
	String updateCity = demographic.getCity();

	if (!request.getParameter("email").equalsIgnoreCase(demographic.getEmail()))
	{
		updateEmail = request.getParameter("email");
		for (AppointmentReminder appointmentReminder : demoReminders) {
				appointmentReminder.setReminderEmail(updateEmail);
				appointmentReminderDao.merge(appointmentReminder);
			}
	}

	if (!request.getParameter("first_name").equalsIgnoreCase(demographic.getFirstName()))
	{
		updateFirstName = request.getParameter("first_name");
	}

	if (!request.getParameter("last_name").equalsIgnoreCase(demographic.getLastName()))
	{
		updateLastName = request.getParameter("last_name");
	}

	if (!request.getParameter("phone").equalsIgnoreCase(demographic.getPhone()))
	{
		updateHomePhone = request.getParameter("phone");
		updateHomePhone = updateHomePhone.replaceAll("[^0-9]", "");
		if (!updateHomePhone.equals("")) {
            if (updateHomePhone.substring(0, 1).equals("1")) {
                updateHomePhone = "+" + updateHomePhone;
            } else {
                updateHomePhone = "+1" + updateHomePhone;
            }
        }
		for (AppointmentReminder appointmentReminder : demoReminders) {
			appointmentReminder.setReminderPhone(updateHomePhone);
			appointmentReminderDao.merge(appointmentReminder);
		}
	}

	Map<String, String> demoExt = demographicExtDao.getAllValuesForDemo(demographicNo);

	if (!StringUtils.trimToEmpty(request.getParameter("demo_cell")).equalsIgnoreCase(StringUtils.trimToEmpty(demoExt.get("demo_cell"))))
	{
        String updateCell = request.getParameter("demo_cell");
        updateCell = updateCell.replaceAll("[^0-9]", "");
        if (!updateCell.equals("")) {
            if (updateCell.substring(0, 1).equals("1")) {
                updateCell = "+" + updateCell;
            } else {
                updateCell = "+1" + updateCell;
            }
        }
        for (AppointmentReminder appointmentReminder : demoReminders) {
            appointmentReminder.setReminderCell(updateCell);
            appointmentReminderDao.merge(appointmentReminder);
        }
	}

	if (!request.getParameter("address").equalsIgnoreCase(demographic.getAddress()))
	{
		updateStreet = request.getParameter("address");
	}

	if (!request.getParameter("city").equalsIgnoreCase(demographic.getCity()))
	{
		updateCity = request.getParameter("city");
	}

	if (!request.getParameter("province").equalsIgnoreCase(demographic.getProvince()))
	{
		updateProvince = request.getParameter("province");
	}

	if (!request.getParameter("postal").equalsIgnoreCase(demographic.getPostal()))
	{
		updatePostal = request.getParameter("postal");
	}

	if (!demoProviders.isEmpty() && demoProviders.size() > 0)
	{
		for (DemographicExt demo : demoProviders)
		{
		    UserProperty prop = propertyDao.getProp(demo.getProviderNo(), UserProperty.PROVIDER_FRESHBOOKS_ID);
			if (prop!=null)
			{
				String provFreshbooksId = prop.getValue();
				String demoFreshbooksId = demo.getValue();
				FreshbooksService fs = new FreshbooksService();
				if(provFreshbooksId!=null && demoFreshbooksId != null && !provFreshbooksId.equals("") && !demoFreshbooksId.equals(""))
				{
					fs.updateClient(demoFreshbooksId, provFreshbooksId, updateEmail, updateFirstName, updateLastName, updateHomePhone, updateStreet, updateCity, updateProvince, updatePostal, false);
				}
			}
		}
	}

	String enrollmentStatus = request.getParameter("roster_status");
	if (enrollmentStatus.equals("EN")) {
        enrollmentStatus = "RO";
	} else if (enrollmentStatus.equals("NE")) {
	    enrollmentStatus = "NR";
    }

	demographic.setLastName(request.getParameter("last_name").trim());
	demographic.setFirstName(request.getParameter("first_name").trim());
	demographic.setPrefName(request.getParameter("pref_name").trim());
	demographic.setAddress(request.getParameter("address"));
	demographic.setCity(request.getParameter("city"));
	demographic.setProvince(request.getParameter("province"));
	demographic.setPostal(request.getParameter("postal"));
	demographic.setPhone(request.getParameter("phone"));
	demographic.setPhone2(request.getParameter("phone2"));
	demographic.setEmail(request.getParameter("email"));
	demographic.setMyOscarUserName(StringUtils.trimToNull(request.getParameter("myOscarUserName")));
	demographic.setYearOfBirth(request.getParameter("year_of_birth"));
	demographic.setMonthOfBirth(request.getParameter("month_of_birth")!=null && request.getParameter("month_of_birth").length()==1 ? "0"+request.getParameter("month_of_birth") : request.getParameter("month_of_birth"));
	demographic.setDateOfBirth(request.getParameter("date_of_birth")!=null && request.getParameter("date_of_birth").length()==1 ? "0"+request.getParameter("date_of_birth") : request.getParameter("date_of_birth"));
	demographic.setHin(request.getParameter("hin")!=null?request.getParameter("hin").trim():"");
	demographic.setVer(request.getParameter("ver"));
	demographic.setRosterStatus(enrollmentStatus);
	demographic.setPatientStatus(request.getParameter("patient_status"));
	demographic.setChartNo(request.getParameter("chart_no"));
	demographic.setProviderNo(request.getParameter("provider_no"));
	demographic.setSex(request.getParameter("sex"));
	demographic.setPcnIndicator(request.getParameter("pcn_indicator"));
	demographic.setHcType(request.getParameter("hc_type"));
	demographic.setFamilyDoctor("<rdohip>" + request.getParameter("r_doctor_ohip") + "</rdohip><rd>" + request.getParameter("r_doctor") + "</rd>" + (request.getParameter("family_doc")!=null? ("<family_doc>" + request.getParameter("family_doc") + "</family_doc>") : ""));
	demographic.setFamilyPhysician("<fdohip>" + request.getParameter("f_doctor_ohip") + "</fdohip><fd>" + request.getParameter("f_doctor") + "</fd>");
	demographic.setCountryOfOrigin(request.getParameter("countryOfOrigin"));
	demographic.setNewsletter(request.getParameter("newsletter"));
	demographic.setSin(request.getParameter("sin"));
	demographic.setTitle(request.getParameter("title"));
	demographic.setOfficialLanguage(request.getParameter("official_lang"));
	demographic.setSpokenLanguage(request.getParameter("spoken_lang"));
	demographic.setRosterTerminationReason(request.getParameter("roster_termination_reason"));
	demographic.setLastUpdateUser((String)session.getAttribute("user"));
	demographic.setLastUpdateDate(new java.util.Date());
	demographic.setPatientType(request.getParameter("patientType"));
	demographic.setPatientId(request.getParameter("patientId"));	
	
	String dateJoined=StringUtils.trimToNull(request.getParameter("date_joined"));
	if(dateJoined != null) {
		demographic.setDateJoined(MyDateFormat.getSysDate(dateJoined));
	} else {
		demographic.setDateJoined(null);
	}
	
	String endDate=StringUtils.trimToNull(request.getParameter("end_date"));
	if( endDate != null ) {
		demographic.setEndDate(MyDateFormat.getSysDate(endDate));
	} else {
		demographic.setEndDate(null);
	}

	String effDate=StringUtils.trimToNull(request.getParameter("eff_date"));
	if( effDate != null ) {
		demographic.setEffDate(MyDateFormat.getSysDate(effDate));
	} else {
		demographic.setEffDate(null);
	}
	
	String hcRenewDate=StringUtils.trimToNull(request.getParameter("hc_renew_date"));
	if( hcRenewDate != null ) {
		demographic.setHcRenewDate(MyDateFormat.getSysDate(hcRenewDate));
	} else {
		demographic.setHcRenewDate(null);
	}
	
	String rosterDate=StringUtils.trimToNull(request.getParameter("roster_date"));
	if( rosterDate != null ) {
		demographic.setRosterDate(MyDateFormat.getSysDate(rosterDate));
	} else {
		demographic.setRosterDate(null);
	}
	
	String rosterTerminationDate=StringUtils.trimToNull(request.getParameter("roster_termination_date"));
	if( rosterTerminationDate != null ) {
		demographic.setRosterTerminationDate(MyDateFormat.getSysDate(rosterTerminationDate));
	} else {
		demographic.setRosterTerminationDate(null);
	}

	String patientStatusDate=StringUtils.trimToNull(request.getParameter("patientstatus_date"));
	if( patientStatusDate != null ) {
		demographic.setPatientStatusDate(MyDateFormat.getSysDate(patientStatusDate));
	} else {
		demographic.setPatientStatusDate(null);
	}
	
	if( OscarProperties.getInstance().getBooleanProperty("USE_NEW_PATIENT_CONSENT_MODULE", "true") ) {
		// Retrieve and set patient consents.
		PatientConsentManager patientConsentManager = SpringUtils.getBean( PatientConsentManager.class );
		List<ConsentType> consentTypes = patientConsentManager.getConsentTypes();
		String consentTypeId = null;
		int patientConsentIdInt = 0; 

		for( ConsentType consentType : consentTypes ) {
			consentTypeId = request.getParameter( consentType.getType() );
			String patientConsentId = request.getParameter( consentType.getType() + "_id" );
			if( patientConsentId != null ){
				patientConsentIdInt = Integer.parseInt( patientConsentId );
				
				// checked box means add or edit consent. 
				if( consentTypeId != null ) {
					patientConsentManager.addConsent(loggedInInfo, demographic.getDemographicNo(), Integer.parseInt( consentTypeId ) );
				
				// unchecked and patientConsentId > 0 could mean the patient opted out. 
				} else if( patientConsentIdInt > 0 ) {
					patientConsentManager.optoutConsent( loggedInInfo, patientConsentIdInt );		
				}
			}
		}
	}
	
	//DemographicExt
	String proNo = (String) session.getValue("user");
	String familyDoctorId = "";
	String familyPhysicianId = "";
    String refSource = request.getParameter("referralSource");
	List<DemographicExt> extensions = new ArrayList<DemographicExt>();
	List<DemographicExt> oldExtensions = demographicExtDao.getDemographicExtByDemographicNo(oldDemographic.getDemographicNo());

	if (!StringUtils.trimToEmpty(demoExt.get("reminder_preference")).equals(StringUtils.trimToEmpty(request.getParameter("reminder_preference")))) {
		extensions.add(new DemographicExt(request.getParameter("reminder_preference_id"), proNo, demographicNo, "reminder_preference", request.getParameter("reminder_preference")));
	}

	if (!StringUtils.trimToEmpty(demoExt.get("enableMailing")).equals(StringUtils.trimToEmpty(request.getParameter("enableMailing")))) {
		extensions.add(new DemographicExt(request.getParameter("enableMailing"), proNo, demographicNo, "enableMailing", request.getParameter("enableMailing")));
	}

    if (refSource.equals("Other")) {
        refSource = StringUtils.trimToEmpty(request.getParameter("referralSourceCust"));
    }

	if (!StringUtils.trimToEmpty(demoExt.get("referral_source")).equals(refSource)) {
		extensions.add(new DemographicExt(refSource, proNo, demographicNo, "referral_source", refSource));
	}

	if (!StringUtils.trimToEmpty(demoExt.get("address_mailing")).equals(StringUtils.trimToEmpty(request.getParameter("address_mailing")))) {
		extensions.add(new DemographicExt(request.getParameter("address_mailing"), proNo, demographicNo, "address_mailing", request.getParameter("address_mailing")));
	}

	if (!StringUtils.trimToEmpty(demoExt.get("city_mailing")).equals(StringUtils.trimToEmpty(request.getParameter("city_mailing")))) {
		extensions.add(new DemographicExt(request.getParameter("city_mailing"), proNo, demographicNo, "city_mailing", request.getParameter("city_mailing")));
	}

	if (!StringUtils.trimToEmpty(demoExt.get("province_mailing")).equals(StringUtils.trimToEmpty(request.getParameter("province_mailing")))) {
		extensions.add(new DemographicExt(request.getParameter("province_mailing"), proNo, demographicNo, "province_mailing", request.getParameter("province_mailing")));
	}

	if (!StringUtils.trimToEmpty(demoExt.get("postal_mailing")).equals(StringUtils.trimToEmpty(request.getParameter("postal_mailing")))) {
		extensions.add(new DemographicExt(request.getParameter("postal_mailing"), proNo, demographicNo, "postal_mailing", request.getParameter("postal_mailing")));
	}

	if (!StringUtils.trimToEmpty(demoExt.get("insurance_company")).equals(StringUtils.trimToEmpty(request.getParameter("insurance_company")))) {
		extensions.add(new DemographicExt(request.getParameter("insurance_company_id"), proNo, demographicNo, "insurance_company", request.getParameter("insurance_company")));
	}

	if (!StringUtils.trimToEmpty(demoExt.get("insurance_number")).equals(StringUtils.trimToEmpty(request.getParameter("insurance_number")))) {
		extensions.add(new DemographicExt(request.getParameter("insurance_number_id"), proNo, demographicNo, "insurance_number", request.getParameter("insurance_number")));
	}

	if (request.getParameter("r_doctor")!=null && !request.getParameter("r_doctor").isEmpty()){
		familyDoctorId = request.getParameter("r_doctor_id");
	}

	if (request.getParameter("f_doctor")!=null && !request.getParameter("f_doctor").isEmpty()){
		familyPhysicianId = request.getParameter("f_doctor_id");
	}

	if (!StringUtils.trimToEmpty(demoExt.get("demo_cell")).equals(StringUtils.trimToEmpty(request.getParameter("demo_cell")))) {
		extensions.add(new DemographicExt(request.getParameter("demo_cell_id"), proNo, demographicNo, "demo_cell", request.getParameter("demo_cell")));
	}

	if (!StringUtils.trimToEmpty(demoExt.get("aboriginal")).equals(StringUtils.trimToEmpty(request.getParameter("aboriginal")))) {
		extensions.add(new DemographicExt(request.getParameter("aboriginal_id"), proNo, demographicNo, "aboriginal", request.getParameter("aboriginal")));
	}

	if (!StringUtils.trimToEmpty(demoExt.get("hPhoneExt")).equals(StringUtils.trimToEmpty(request.getParameter("hPhoneExt")))) {
		extensions.add(new DemographicExt(request.getParameter("hPhoneExt_id"), proNo, demographicNo, "hPhoneExt", request.getParameter("hPhoneExt")));
	}

	if (!StringUtils.trimToEmpty(demoExt.get("wPhoneExt")).equals(StringUtils.trimToEmpty(request.getParameter("wPhoneExt")))) {
		extensions.add(new DemographicExt(request.getParameter("wPhoneExt_id"), proNo, demographicNo, "wPhoneExt", request.getParameter("wPhoneExt")));
	}

	if (!StringUtils.trimToEmpty(demoExt.get("cytolNum")).equals(StringUtils.trimToEmpty(request.getParameter("cytolNum")))) {
		extensions.add(new DemographicExt(request.getParameter("cytolNum_id"), proNo, demographicNo, "cytolNum", request.getParameter("cytolNum")));
	}

	if (!StringUtils.trimToEmpty(demoExt.get("ethnicity")).equals(StringUtils.trimToEmpty(request.getParameter("ethnicity")))) {
		extensions.add(new DemographicExt(request.getParameter("ethnicity_id"), proNo, demographicNo, "ethnicity", request.getParameter("ethnicity")));
	}

	if (!StringUtils.trimToEmpty(demoExt.get("area")).equals(StringUtils.trimToEmpty(request.getParameter("area")))) {
		extensions.add(new DemographicExt(request.getParameter("area_id"), proNo, demographicNo, "area", request.getParameter("area")));
	}

	if (!StringUtils.trimToEmpty(demoExt.get("statusNum")).equals(StringUtils.trimToEmpty(request.getParameter("statusNum")))) {
		extensions.add(new DemographicExt(request.getParameter("statusNum_id"), proNo, demographicNo, "statusNum", request.getParameter("statusNum")));
	}

	if (!StringUtils.trimToEmpty(demoExt.get("fNationCom")).equals(StringUtils.trimToEmpty(request.getParameter("fNationCom")))) {
		extensions.add(new DemographicExt(request.getParameter("fNationCom_id"), proNo, demographicNo, "fNationCom", request.getParameter("fNationCom")));
	}

	if (!StringUtils.trimToEmpty(demoExt.get("fNationFamilyNumber")).equals(StringUtils.trimToEmpty(request.getParameter("fNationFamilyNumber")))) {
		extensions.add(new DemographicExt(request.getParameter("fNationFamilyNumber_id"), proNo, demographicNo, "fNationFamilyNumber", request.getParameter("fNationFamilyNumber")));
	}

	if (!StringUtils.trimToEmpty(demoExt.get("fNationFamilyPosition")).equals(StringUtils.trimToEmpty(request.getParameter("fNationFamilyPosition")))) {
		extensions.add(new DemographicExt(request.getParameter("fNationFamilyPosition_id"), proNo, demographicNo, "fNationFamilyPosition", request.getParameter("fNationFamilyPosition")));
	}

	if (!StringUtils.trimToEmpty(demoExt.get("given_consent")).equals(StringUtils.trimToEmpty(request.getParameter("given_consent")))) {
		extensions.add(new DemographicExt(request.getParameter("given_consent_id"), proNo, demographicNo, "given_consent", request.getParameter("given_consent")));
	}

	if (!StringUtils.trimToEmpty(demoExt.get("rxInteractionWarningLevel")).equals(StringUtils.trimToEmpty(request.getParameter("rxInteractionWarningLevel")))) {
		extensions.add(new DemographicExt(request.getParameter("rxInteractionWarningLevel_id"), proNo, demographicNo, "rxInteractionWarningLevel", request.getParameter("rxInteractionWarningLevel")));
	}

	if (!StringUtils.trimToEmpty(demoExt.get("primaryEMR")).equals(StringUtils.trimToEmpty(request.getParameter("primaryEMR")))) {
		extensions.add(new DemographicExt(request.getParameter("primaryEMR_id"), proNo, demographicNo, "primaryEMR", request.getParameter("primaryEMR")));
	}

	if (!StringUtils.trimToEmpty(demoExt.get("phoneComment")).equals(StringUtils.trimToEmpty(request.getParameter("phoneComment")))) {
		extensions.add(new DemographicExt(request.getParameter("phoneComment_id"), proNo, demographicNo, "phoneComment", request.getParameter("phoneComment")));
	}

	if (!StringUtils.trimToEmpty(demoExt.get("usSigned")).equals(StringUtils.trimToEmpty(request.getParameter("usSigned")))) {
		extensions.add(new DemographicExt(request.getParameter("usSigned_id"), proNo, demographicNo, "usSigned", request.getParameter("usSigned")));
	}

	if (!StringUtils.trimToEmpty(demoExt.get("privacyConsent")).equals(StringUtils.trimToEmpty(request.getParameter("privacyConsent")))) {
		extensions.add(new DemographicExt(request.getParameter("privacyConsent_id"), proNo, demographicNo, "privacyConsent", request.getParameter("privacyConsent")));
	}

	if (!StringUtils.trimToEmpty(demoExt.get("informedConsent")).equals(StringUtils.trimToEmpty(request.getParameter("informedConsent")))) {
		extensions.add(new DemographicExt(request.getParameter("informedConsent_id"), proNo, demographicNo, "informedConsent", request.getParameter("informedConsent")));
	}

	if (!StringUtils.trimToEmpty(demoExt.get("paper_chart_archived")).equals(StringUtils.trimToEmpty(request.getParameter("paper_chart_archived")))) {
		extensions.add(new DemographicExt(request.getParameter("paper_chart_archived_id"), proNo, demographicNo, "paper_chart_archived", request.getParameter("paper_chart_archived")));
	}

	if (!StringUtils.trimToEmpty(demoExt.get("paper_chart_archived_date")).equals(StringUtils.trimToEmpty(request.getParameter("paper_chart_archived_date")))) {
		extensions.add(new DemographicExt(request.getParameter("paper_chart_archived_date_id"), proNo, demographicNo, "paper_chart_archived_date", request.getParameter("paper_chart_archived_date")));
	}

	if (!StringUtils.trimToEmpty(demoExt.get("paper_chart_archived_program")).equals(StringUtils.trimToEmpty(request.getParameter("paper_chart_archived_program")))) {
		extensions.add(new DemographicExt(request.getParameter("paper_chart_archived_program_id"), proNo, demographicNo, "paper_chart_archived_program", request.getParameter("paper_chart_archived_program")));
	}

	if (!StringUtils.trimToEmpty(demoExt.get("familyDoctorId")).equals(StringUtils.trimToEmpty(familyDoctorId))) {
		extensions.add(new DemographicExt(request.getParameter("familyDoctorId_id"), proNo, demographicNo, "familyDoctorId", familyDoctorId));
	}

	if (!StringUtils.trimToEmpty(demoExt.get("familyPhysicianId")).equals(StringUtils.trimToEmpty(familyPhysicianId))) {
		extensions.add(new DemographicExt(request.getParameter("familyPhysicianId_id"), proNo, demographicNo, "familyPhysicianId", familyPhysicianId));
	}

	String includeEmailOnConsults = request.getParameter("includeEmailOnConsults");
	if (StringUtils.trimToNull(includeEmailOnConsults) == null) {
		includeEmailOnConsults = "false";
	}

	if (!StringUtils.trimToEmpty(demoExt.get("includeEmailOnConsults")).equals(StringUtils.trimToEmpty(includeEmailOnConsults))) {
		extensions.add(new DemographicExt(request.getParameter("includeEmailOnConsults_id"), proNo, demographicNo, "includeEmailOnConsults", includeEmailOnConsults));
	}

	if (!StringUtils.trimToEmpty(demoExt.get("patientEmailConsent")).equals(StringUtils.trimToEmpty(request.getParameter("patientEmailConsent")))) {
		extensions.add(new DemographicExt(request.getParameter("patientEmailConsent_id"), proNo, demographicNo, "patientEmailConsent", request.getParameter("patientEmailConsent") == null ? "" : request.getParameter("patientEmailConsent")));
	}

	if (OscarProperties.getInstance().getBooleanProperty("enable_appointment_reminders", "true")) {

		if (!StringUtils.trimToEmpty(demoExt.get("allow_appointment_reminders")).equals(StringUtils.trimToEmpty(request.getParameter("allow_appointment_reminders")))) {
			extensions.add(new DemographicExt(request.getParameter("allow_appointment_reminders_id"), "CLINIC", demographicNo, "allow_appointment_reminders", request.getParameter("allow_appointment_reminders") == null ? "" : request.getParameter("allow_appointment_reminders")));
		}

		String phoneReminderComparison = request.getParameter("reminder_phone") != null ? request.getParameter("reminder_phone").equals("on") ? "true" : "false" : "false";
		String cellReminderComparison = request.getParameter("reminder_cell") != null ? request.getParameter("reminder_cell").equals("on") ? "true" : "false" : "false";
		String emailReminderComparison = request.getParameter("reminder_email") != null ? request.getParameter("reminder_email").equals("on") ? "true" : "false" : "false";

		if (!StringUtils.trimToEmpty(demoExt.get("reminder_phone")).equals(phoneReminderComparison)) {
			extensions.add(new DemographicExt(request.getParameter("reminder_phone_id"), "CLINIC", demographicNo, "reminder_phone", request.getParameter("reminder_phone") == null ? "false" : request.getParameter("reminder_phone").equals("on") ? "true" : "false"));
		}

		if (!StringUtils.trimToEmpty(demoExt.get("reminder_cell")).equals(cellReminderComparison)) {
			extensions.add(new DemographicExt(request.getParameter("reminder_cell_id"), "CLINIC", demographicNo, "reminder_cell", request.getParameter("reminder_cell") == null ? "false" : request.getParameter("reminder_cell").equals("on") ? "true" : "false"));
		}

		if (!StringUtils.trimToEmpty(demoExt.get("reminder_email")).equals(emailReminderComparison)) {
			extensions.add(new DemographicExt(request.getParameter("reminder_email_id"), "CLINIC", demographicNo, "reminder_email", request.getParameter("reminder_email") == null ? "false" : request.getParameter("reminder_email").equals("on") ? "true" : "false"));
		}

	}
	String referralSourceString = request.getParameter("referral_source");
	if (OscarProperties.getInstance().isPropertyActive("masterfile_referral_source") &&
			!StringUtils.trimToEmpty(demoExt.get("referral_source")).equals(referralSourceString)) {
	    extensions.add(new DemographicExt(request.getParameter("referral_source_id"), proNo, demographicNo, "referral_source", referralSourceString));
	}

	if ((!StringUtils.trimToEmpty(demoExt.get("enrollmentProvider")).equals(StringUtils.trimToEmpty(request.getParameter("enrollmentProvider"))))
			|| (!request.getParameter("roster_status").equalsIgnoreCase(oldDemographic.getRosterStatus())) || ((rosterDate == null ? "" : rosterDate).equals(oldDemographic.getRosterDate() == null ? "" : oldDemographic.getRosterDate().toString()))
			|| ((rosterTerminationDate == null ? "" : rosterTerminationDate).equalsIgnoreCase(oldDemographic.getRosterTerminationDate() == null ? "" : oldDemographic.getRosterTerminationDate().toString()))
			|| (!request.getParameter("roster_termination_reason").equalsIgnoreCase(oldDemographic.getRosterTerminationReason()))) {
		extensions.add(new DemographicExt(request.getParameter("enrollmentProvider_id"), proNo, demographicNo, "enrollmentProvider", request.getParameter("enrollmentProvider") == null ? "" : request.getParameter("enrollmentProvider")));
	}

	if (!StringUtils.trimToEmpty(demoExt.get("notMrp")).equals(StringUtils.trimToEmpty(request.getParameter("notMrp")))) {
		extensions.add(new DemographicExt(request.getParameter("notMrp_id"), proNo, demographicNo, "notMrp", request.getParameter("notMrp") == null ? "" : request.getParameter("notMrp")));
	}

    if (OscarProperties.getInstance().isPropertyActive("show_referral_date")) {
        String referralDate = "";

        if (request.getParameter("referral-date") != null && !request.getParameter("referral-date").isEmpty()) {
            referralDate = request.getParameter("referral-date");
        }
        if (!StringUtils.trimToEmpty(demoExt.get("referralDate")).equals(StringUtils.trimToEmpty(includeEmailOnConsults))) {
            extensions.add(new DemographicExt(request.getParameter("referral-date-id"), proNo, demographicNo, "referralDate", referralDate));
        }
    }
	
	
	if (masterFilePreferences.getOrDefault("display_former_name", false)) {
		String formerName = request.getParameter("former_name") != null ? request.getParameter("former_name") : "";
		if (!StringUtils.trimToEmpty(demoExt.get("former_name")).equals(StringUtils.trimToEmpty(formerName))) {
			extensions.add(new DemographicExt(request.getParameter("former_name_id"), proNo, demographicNo, "former_name", formerName));
		}
	}

	// Demographic Groups
	int demographicNoAsInt = 0;
	try {
		demographicNoAsInt = Integer.parseInt( demoNo );
	} catch (Exception e) {
		// TODO: Handle error
		MiscUtils.getLogger().error("Error parsing demographic number", e);
	}

	String[] groupsOrig = request.getParameterValues("demographicGroupsOrig");
	String[] groups = request.getParameterValues("demographicGroups");

	if (groupsOrig != null) {
		for (int i=0; i < groupsOrig.length; i++) {
			try {
				int groupId = Integer.parseInt( groupsOrig[i] );
				demographicGroupLinkDao.remove(demographicNoAsInt, groupId);
			} catch (Exception e) {
				MiscUtils.getLogger().error("Error parsing demographic group number", e);
			}
		}
	}

	if (groups != null) {
		for (int i=0; i < groups.length; i++) {
			if (groups[i] != null) {
				// An empty group number indicates the 'None' group
				if (groups[i].length() > 0) {
					try {
						int groupId = Integer.parseInt( groups[i] );
				        demographicGroupLinkDao.add(demographicNoAsInt, groupId);
					} catch (Exception e) {
						MiscUtils.getLogger().error("Error parsing demographic group number", e);
					}
				}
			} else {
				MiscUtils.getLogger().warn("Null demographic group number passed in.");
			}
		}
	}


	if (!StringUtils.trimToEmpty(demoExt.get("HasPrimaryCarePhysician")).equals(StringUtils.trimToEmpty(request.getParameter("HasPrimaryCarePhysician")))) {
		extensions.add(new DemographicExt(request.getParameter("HasPrimaryCarePhysician_id"), proNo, demographicNo, "HasPrimaryCarePhysician", request.getParameter("HasPrimaryCarePhysician")));
	}

	if (!StringUtils.trimToEmpty(demoExt.get("EmploymentStatus")).equals(StringUtils.trimToEmpty(request.getParameter("EmploymentStatus")))) {
		extensions.add(new DemographicExt(request.getParameter("EmploymentStatus_id"), proNo, demographicNo, "EmploymentStatus", request.getParameter("EmploymentStatus")));
	}
	
	
	// customized key
	if(oscarVariables.getProperty("demographicExt") != null) {
	   String [] propDemoExt = oscarVariables.getProperty("demographicExt","").split("\\|");
	   for(int k=0; k<propDemoExt.length; k++) {
                   extensions.add(new DemographicExt(request.getParameter(propDemoExt[k].replace(' ','_')+"_id"),proNo, demographicNo, propDemoExt[k].replace(' ','_'), request.getParameter(propDemoExt[k].replace(' ','_'))));
	   }
	}
        
        for (DemographicExt extension : extensions) {
	    demographicExtDao.saveEntity(extension);
	}
	
	// for the IBD clinic
	OtherIdManager.saveIdDemographic(demographicNo, "meditech_id", request.getParameter("meditech_id"));
	
     // added check to see if patient has a bc health card and has a version code of 66, in this case you are aloud to have dup hin
     boolean hinDupCheckException = false;
     String hcType = request.getParameter("hc_type");
     String ver  = request.getParameter("ver");
     if (hcType != null && ver != null && hcType.equals("BC") && ver.equals("66")){
        hinDupCheckException = true;
     }

     if(request.getParameter("hin")!=null && request.getParameter("hin").length()>5 && !hinDupCheckException) {
		String paramNameHin =new String();
		paramNameHin=request.getParameter("hin").trim();
		
		boolean outOfDomain = true;
		
		List<Demographic> hinDemoList = demographicDao.searchDemographicByHIN(paramNameHin, 100, 0, loggedInInfo.getLoggedInProviderNo(),outOfDomain);
		for(Demographic hinDemo : hinDemoList) {
        
            if (!(hinDemo.getDemographicNo().toString().equals(request.getParameter("demographic_no")))) {
                if (hinDemo.getVer() != null && !hinDemo.getVer().equals("66")){

%>
				***<font color='red'><bean:message key="demographic.demographicaddarecord.msgDuplicatedHIN" /></font>
				***<br><br><a href=# onClick="history.go(-1);return false;"><b>&lt;-<bean:message key="global.btnBack" /></b></a> 
<% 
				return;
	            }
	        }
	    }
	}

    Long archiveId = demographicArchiveDao.archiveRecord(oldDemographic);
	for (DemographicExt extension : oldExtensions) {
		DemographicExtArchive archive = new DemographicExtArchive(extension);
		archive.setArchiveId(archiveId);
		//String oldValue = request.getParameter(archive.getKey() + "Orig");
		archive.setValue(archive.getValue());
		demographicExtArchiveDao.saveEntity(archive);	
	}

	List<ChangedField> changedFields = new ArrayList<ChangedField>(ChangedField.getChangedFieldsAndValues(oldDemographic, demographic));
	String keyword = "demographicNo=" + demographic.getDemographicNo();
	if (request.getParameter("keyword") != null) { keyword += "\n" + request.getParameter("keyword"); }
	LogAction.addLog(LoggedInInfo.getLoggedInInfoFromSession(request), LogConst.UPDATE, "demographic", keyword, demographic.getDemographicNo().toString(), changedFields);
	
    demographicDao.save(demographic);
	if(family!=null && !family.isEmpty()){
	    List<String> members = new ArrayList<String>();
		for (Demographic member : family){
		    member.setAddress(demographic.getAddress());
		    member.setCity(demographic.getCity());
		    member.setProvince(demographic.getProvince());
		    member.setPostal(demographic.getPostal());
		    member.setPhone(demographic.getPhone());
			demographicDao.save(member);
			members.add(member.getFormattedName());
		}
		session.setAttribute("updatedFamily", members);
	}
    
    try{
    	oscar.oscarDemographic.data.DemographicNameAgeString.resetDemographic(request.getParameter("demographic_no"));
    }catch(Exception nameAgeEx){
    	MiscUtils.getLogger().error("ERROR RESETTING NAME AGE", nameAgeEx);
    }

    //find the democust record for update
    DemographicCust demographicCust = demographicCustDao.find(Integer.parseInt(request.getParameter("demographic_no")));
    if(demographicCust == null) {
		demographicCust = new DemographicCust();
		demographicCust.setId(Integer.parseInt(request.getParameter("demographic_no")));
	}
	demographicCust.setResident(request.getParameter("resident"));
	demographicCust.setNurse(request.getParameter("nurse"));
	demographicCust.setBookingAlert(request.getParameter("bookingAlert"));
	demographicCust.setMidwife(request.getParameter("midwife"));
	demographicCust.setNotes("<unotes>"+ request.getParameter("notes")+"</unotes>");
    demographicCustDao.saveEntity(demographicCust);


	String newChartAlertText = request.getParameter("chartAlertText");
	Alert oldChartAlert = alertDao.findLatestEnabledByDemographicNoAndType(demographicNo, Alert.AlertType.CHART);
	
	if ((oldChartAlert == null || !newChartAlertText.equals(Encode.forHtmlContent(oldChartAlert.getMessage())))) {
	    if (oldChartAlert != null) {
	        oldChartAlert.setEnabled(false);
	        alertDao.saveEntity(oldChartAlert);
		}
	    
		if (!StringUtils.isBlank(newChartAlertText) && newChartAlertText.length() <= 200) {
			Alert newChartAlert = new Alert(demographicNo, Alert.AlertType.CHART, newChartAlertText);
			alertDao.saveEntity(newChartAlert);
		}
	}

    //update admission information
    GenericIntakeEditAction gieat = new GenericIntakeEditAction();
    ProgramManager pm = SpringUtils.getBean(ProgramManager.class);
	AdmissionManager am = SpringUtils.getBean(AdmissionManager.class);
    gieat.setAdmissionManager(am);
    gieat.setProgramManager(pm);
    
	String bedP = request.getParameter("rps");
    if(bedP != null && bedP.length()>0) {
	    try {
	   	 gieat.admitBedCommunityProgram(demographic.getDemographicNo(), (String)session.getAttribute("user"), Integer.parseInt(bedP), "", "(Master record change)", new java.util.Date());
	    }catch(Exception e) {
	    	
	    }
    }
    
    String[] servP = request.getParameterValues("sp");
    if(servP!=null&&servP.length>0){
    	Set<Integer> s = new HashSet<Integer>();
        for(String _s:servP) s.add(Integer.parseInt(_s));
   		try {
   	   	 gieat.admitServicePrograms(demographic.getDemographicNo(), (String)session.getAttribute("user"), s, "(Master record change)", new java.util.Date());
   	    }catch(Exception e) {
   	 }
    }
    
    String _pvid = loggedInInfo.getLoggedInProviderNo();
    Set<Program> pset = gieat.getActiveProviderProgramsInFacility(loggedInInfo,_pvid,loggedInInfo.getCurrentFacility().getId());
    List<Program> allServiceProgramsShown = gieat.getServicePrograms(pset,_pvid);
    for(Program p:allServiceProgramsShown) {
    	if(!isFound(servP,p.getId().toString())) {
    		try {
    			am.processDischarge(p.getId(), demographic.getDemographicNo(), "(Master record change)", "0");
    		}catch(org.oscarehr.PMmodule.exception.AdmissionException e) {}
    	}
    }
    
try {   
    //add to waiting list if the waiting_list parameter in the property file is set to true
    oscar.oscarWaitingList.WaitingList wL = oscar.oscarWaitingList.WaitingList.getInstance();
    if(wL.getFound()){
 	  WLWaitingListUtil.updateWaitingListRecord(
 	  request.getParameter("list_id"), request.getParameter("waiting_list_note"),
 	  request.getParameter("demographic_no"), request.getParameter("waiting_list_referral_date"));

%>

		<form name="add2WLFrm" action="../oscarWaitingList/Add2WaitingList.jsp">
		<input type="hidden" name="listId" value="<%=request.getParameter("list_id")%>" /> 
		<input type="hidden" name="demographicNo" value="<%=request.getParameter("demographic_no")%>" /> 
		<input type="hidden" name="demographic_no" value="<%=request.getParameter("demographic_no")%>" /> 
		<input type="hidden" name="waitingListNote" value="<%=request.getParameter("waiting_list_note")%>" /> 
		<input type="hidden" name="onListSince" value="<%=request.getParameter("waiting_list_referral_date")%>" /> 
		<input type="hidden" name="displaymode" value="edit" /> 
		<input type="hidden" name="dboperation" value="search_detail" /> 

<%
	if(!request.getParameter("list_id").equalsIgnoreCase("0")){
		String wlDemoId = request.getParameter("demographic_no");
		String wlId = request.getParameter("list_id");
		Integer waitlistId = Integer.parseInt(wlId);
		Integer waitlistDemographicId = Integer.parseInt(wlDemoId);
        List<WaitingList> waitingListList = waitingListDao.findByWaitingListIdAndDemographicId(waitlistId, waitlistDemographicId);

		//check if patient has already added to the waiting list and check if the patient already has an appointment in the future
		if(waitingListList.isEmpty()){
			
			List<Appointment> apptList = appointmentDao.findNonCancelledFutureAppointments(new Integer(wlDemoId));
			if(!apptList.isEmpty()){
%>
			<script language="JavaScript">
				var add2List = confirm("The patient already has an appointment, do you still want to add him/her to the waiting list?");
				if(add2List){
					document.add2WLFrm.action = "../oscarWaitingList/Add2WaitingList.jsp?demographicNo=<%=request.getParameter("demographic_no")%>&listId=<%=request.getParameter("list_id")%>&waitingListNote=<%=request.getParameter("waiting_list_note")==null?"":request.getParameter("waiting_list_note")%>&onListSince=<%=request.getParameter("waiting_list_referral_date")==null?"":request.getParameter("waiting_list_referral_date")%>";
				}
				else{
					document.add2WLFrm.action ="demographiccontrol.jsp?demographic_no=<%=request.getParameter("demographic_no")%>&displaymode=edit&dboperation=search_detail";
				}
				document.add2WLFrm.submit();
		</script> 
<%
			}
			else{
%> 
			<script language="JavaScript">
				document.add2WLFrm.action = "../oscarWaitingList/Add2WaitingList.jsp?demographicNo=<%=request.getParameter("demographic_no")%>&listId=<%=request.getParameter("list_id")%>&waitingListNote=<%=request.getParameter("waiting_list_note")==null?"":request.getParameter("waiting_list_note")%>&onListSince=<%=request.getParameter("waiting_list_referral_date")==null?"":request.getParameter("waiting_list_referral_date")%>";
				document.add2WLFrm.submit();
			</script> 
<%
			}
		}
		else{
			response.sendRedirect("demographiccontrol.jsp?demographic_no=" + request.getParameter("demographic_no") + "&displaymode=edit&dboperation=search_detail");
		}
	}
	else{
		response.sendRedirect("demographiccontrol.jsp?demographic_no=" + request.getParameter("demographic_no") + "&displaymode=edit&dboperation=search_detail");
	}
%>
		</form>
<%
	}
	else{
		response.sendRedirect("demographiccontrol.jsp?demographic_no=" + request.getParameter("demographic_no") + "&displaymode=edit&dboperation=search_detail");
	}
%>

<h2>Update a Provider Record Successfully !
	<p><a href="demographiccontrol.jsp?demographic_no=<%=request.getParameter("demographic_no")%>&displaymode=edit&dboperation=search_detail"><%= request.getParameter("demographic_no") %></a></p>
</h2>

<%
	PreventionManager prevMgr = (PreventionManager) SpringUtils.getBean("preventionMgr");
	prevMgr.removePrevention(request.getParameter("demographic_no"));

}
catch (NumberFormatException nfe) { 
MiscUtils.getLogger().error("Either waitListId or demographicId is not a valid integer for the demographic");
%>
<h1 style="color:red">The waitlist could not be updated while saving the demographic.</h1>
<% } %>

</center>
</body>
</html:html>

<%!
	public boolean isFound(String[] vals, String val) {
		if(vals != null) {
			for(String t:vals) {
				if(t.equals(val)) {
					return true;
				}
			}
		}
		return false;
}
%>
