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
<%@ page import="org.oscarehr.common.model.ProfessionalSpecialist" %>
<%@ page import="org.oscarehr.common.dao.ProfessionalSpecialistDao" %>
<%@ page import="org.oscarehr.common.model.DemographicCust" %>
<%@ page import="org.oscarehr.common.dao.DemographicCustDao" %>
<%@ page import="org.oscarehr.common.model.Demographic" %>
<%@ page import="org.oscarehr.common.dao.DemographicDao" %>
<%@ page import="org.oscarehr.common.model.Provider" %>
<%@ page import="org.oscarehr.PMmodule.dao.ProviderDao" %>
<%@ page import="org.oscarehr.managers.DemographicManager" %>
<%@ page import="org.oscarehr.PMmodule.service.ProgramManager" %>
<%@ page import="org.oscarehr.PMmodule.dao.ProgramDao" %>
<%@ page import="org.oscarehr.PMmodule.service.AdmissionManager" %>
<%@ page import="org.oscarehr.common.dao.SpecialtyDao" %>
<%@ page import="org.oscarehr.common.model.Specialty" %>
<%@ page import="org.apache.commons.lang.StringUtils"%>
<%@ page import="oscar.oscarBilling.ca.on.data.JdbcBilling3rdPartImpl" %>
<%@ page import="org.owasp.encoder.Encode" %>
<html:html locale="true">
<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean"%>
<jsp:useBean id="apptMainBean" class="oscar.AppointmentMainBean" scope="session" />

<%	
	LoggedInInfo loggedInInfo=LoggedInInfo.getLoggedInInfoFromSession(request);
	java.util.Properties oscarVariables = OscarProperties.getInstance();



	String demographic_no = request.getParameter("demographic_no");
	String aboriginal = request.getParameter("aboriginal");
	String birthYear = request.getParameter("birthYear");
	String birthMonth = request.getParameter("birthMonth");
	String birthDate = request.getParameter("birthDate");
	String age = request.getParameter("age");
	String nurseMessageKey = request.getParameter("nurseMessageKey");
	String midwifeMessageKey = request.getParameter("midwifeMessageKey");
	String residentMessageKey = request.getParameter("residentMessageKey");
	String nurse = request.getParameter("nurse");
	String midwife = request.getParameter("midwife");
	String resident = request.getParameter("resident");
	String rdohip = request.getParameter("rdohip");
	String rd = request.getParameter("rd");
	String prov = request.getParameter("prov");
	String family_doc = request.getParameter("family_doc");
	String warningLevel = request.getParameter("warningLevel");
	String patientId = request.getParameter("patientId");
	String patientType = request.getParameter("patientType");
	Boolean showConsentsThisTime = Boolean.parseBoolean(request.getParameter("showConsentsThisTime"));
	String usSigned = request.getParameter("usSigned");
	String privacyConsent = request.getParameter("privacyConsent");
	String informedConsent = request.getParameter("informedConsent");
	String wLReadonly = request.getParameter("wLReadonly");
	String bookingAlert = request.getParameter("bookingAlert");
	String chartAlertText = request.getParameter("chartAlertText");
	String notes = request.getParameter("notes");

	int demographicNoAsInt = Integer.parseInt(demographic_no);
	int nStrShowLen = 20;

    WebApplicationContext ctx = WebApplicationContextUtils.getRequiredWebApplicationContext(getServletContext());
    CountryCodeDao ccDAO =  (CountryCodeDao) ctx.getBean("countryCodeDao");
    UserPropertyDAO pref = (UserPropertyDAO) ctx.getBean("UserPropertyDAO");                       
    List<CountryCode> countryList = ccDAO.getAllCountryCodes();
	JdbcBilling3rdPartImpl dbObj = new JdbcBilling3rdPartImpl();
	Billing3rdPartyAddressDao billing3rdPartyAddressDao = SpringUtils.getBean(Billing3rdPartyAddressDao.class);


	DemographicDao demographicDao=(DemographicDao)SpringUtils.getBean("demographicDao");
    Demographic demographic = demographicDao.getDemographic(demographic_no);
	DemographicExtDao demographicExtDao = SpringUtils.getBean(DemographicExtDao.class);
	ProfessionalSpecialistDao professionalSpecialistDao = (ProfessionalSpecialistDao) SpringUtils.getBean("professionalSpecialistDao");
	DemographicCustDao demographicCustDao = (DemographicCustDao)SpringUtils.getBean("demographicCustDao");
    DemographicGroupDao demographicGroupDao = SpringUtils.getBean(DemographicGroupDao.class);
	ProviderDao providerDao = SpringUtils.getBean(ProviderDao.class);
    DemographicGroupLinkDao demographicGroupLinkDao = SpringUtils.getBean(DemographicGroupLinkDao.class);
    WaitingListDao waitingListDao = SpringUtils.getBean(WaitingListDao.class);
    WaitingListNameDao waitingListNameDao = SpringUtils.getBean(WaitingListNameDao.class);
	ProgramManager pm = SpringUtils.getBean(ProgramManager.class);
    AdmissionManager admissionManager = SpringUtils.getBean(AdmissionManager.class);
	CustomHealthcardTypeDao customHealthcardTypeDao = SpringUtils.getBean(CustomHealthcardTypeDao.class);
 	Admission bedAdmission = admissionManager.getCurrentBedProgramAdmission(demographic.getDemographicNo());
 	List<Admission> serviceAdmissions = admissionManager.getCurrentServiceProgramAdmission(demographic.getDemographicNo());
	ProgramDao programDao = (ProgramDao)SpringUtils.getBean("programDao");
	List<Provider> providers = providerDao.getActiveProviders();
	List<Provider> doctors = providerDao.getActiveProvidersByRole("doctor");
	Provider importMRPMatch = demographic.getProvider();
	if (importMRPMatch != null && !doctors.contains(importMRPMatch)) {
	    doctors.add(importMRPMatch);
	}
	List<Provider> nurses;
	List<Provider> midwifes;	
	if (oscarVariables.getProperty("queens_resident_tagging") != null)
	{
		nurses = doctors;
		midwifes = doctors;
	}
	else
	{
		nurses = providerDao.getActiveProvidersByRole("nurse");
		midwifes = providerDao.getActiveProvidersByRole("midwife");	
	}
	
    OscarProperties oscarProps = OscarProperties.getInstance();
	PropertyDao propertyDao = new SpringUtils().getBean(PropertyDao.class);
    ProvinceNames pNames = ProvinceNames.getInstance();
	Map<String,String> demoExt = demographicExtDao.getAllValuesForDemo(Integer.parseInt(demographic_no));
	String enrollmentProvider = demoExt.get("enrollmentProvider");
	if (enrollmentProvider != null && !enrollmentProvider.equals("")) {
	    Provider enrollmentProviderRecord = providerDao.getProvider(enrollmentProvider);
	    if (!doctors.contains(enrollmentProviderRecord)) {
			doctors.add(enrollmentProviderRecord);
		}
	}
	List<DemographicGroupLink> demographicGroupsForPatient = demographicGroupLinkDao.findByDemographicNo(demographicNoAsInt);

    PatientTypeDao patientTypeDao = (PatientTypeDao) SpringUtils.getBean("patientTypeDao");
    List<PatientType> patientTypes = patientTypeDao.findAllPatientTypes();
	List<DemographicGroup> demographicGroups = demographicGroupDao.getAll();
	
	GregorianCalendar dateCal = new GregorianCalendar();

	boolean allowAppointmentReminders = true;
	boolean phoneReminders = true;
	boolean cellReminders = true;
	boolean emailReminders = true;
	String currentReferralSource = null;
	DemographicExt demographicExt = demographicExtDao.getDemographicExt(Integer.parseInt(demographic_no), "allow_appointment_reminders");
	if (demographicExt != null && demographicExt.getValue() != null) {
	    allowAppointmentReminders = Boolean.parseBoolean(demographicExt.getValue());
	}
	demographicExt = demographicExtDao.getDemographicExt(Integer.parseInt(demographic_no), "reminder_phone");
	if (demographicExt != null && demographicExt.getValue() != null) {
		phoneReminders = Boolean.parseBoolean(demographicExt.getValue());
	}
	demographicExt = demographicExtDao.getDemographicExt(Integer.parseInt(demographic_no), "reminder_cell");
	if (demographicExt != null && demographicExt.getValue() != null) {
		cellReminders = Boolean.parseBoolean(demographicExt.getValue());
	}
	demographicExt = demographicExtDao.getDemographicExt(Integer.parseInt(demographic_no), "reminder_email");
	if (demographicExt != null && demographicExt.getValue() != null) {
		emailReminders = Boolean.parseBoolean(demographicExt.getValue());
	}
	demographicExt = demographicExtDao.getDemographicExt(Integer.parseInt(demographic_no), "referral_source");
	if (demographicExt != null && demographicExt.getValue() != null) {
		currentReferralSource = demographicExt.getValue();
	}
	List<String> referralSources = demographicExtDao.findAllDistinctValuesByKey("referral_source");

	SystemPreferencesDao systemPreferencesDao = SpringUtils.getBean(SystemPreferencesDao.class);
	Map<String, Boolean> masterFilePreferences = systemPreferencesDao.findByKeysAsMap(SystemPreferences.MASTER_FILE_PREFERENCE_KEYS);
    boolean showSin = !"hidden".equalsIgnoreCase(propertyDao.getValueByNameAndDefault("demographic.field.sin", ""));
%>
<%!
	public String getDisabled(String fieldName) {
		String val = OscarProperties.getInstance().getProperty("demographic.edit."+fieldName,"");
		if(val != null && val.equals("disabled")) {
			return " disabled=\"disabled\" ";
		}

		return "";
	}
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


<table width="100%" bgcolor="#EEEEFF" border=0 id="editDemographic"
	style="display: none;"><tr>
		<td align="right" title='<%=demographic.getDemographicNo()%>'><b><bean:message
					key="demographic.demographiceditdemographic.formLastName" />: </b></td>
		<td align="left"><input type="text" name="last_name"
			<%=getDisabled("last_name")%> size="30"
			value="<%=StringEscapeUtils.escapeHtml(demographic.getLastName())%>"
			onBlur="upCaseCtrl(this)"></td>
		<td align="right"><b><bean:message
					key="demographic.demographiceditdemographic.formFirstName" />: </b></td>
		<td align="left"><input type="text" name="first_name"
			<%=getDisabled("first_name")%> size="30"
			value="<%=StringEscapeUtils.escapeHtml(demographic.getFirstName())%>"
			onBlur="upCaseCtrl(this)"></td>
	</tr>
	<tr>
		<td align="right"><b><bean:message
			key="demographic.demographiceditdemographic.formPrefName" />: </b></td>
		<td align="left"><input type="text" name="pref_name"
			<%=getDisabled("pref_name")%> size="30"
			value="<%=StringEscapeUtils.escapeHtml(demographic.getPrefName())%>"
			onBlur="upCaseCtrl(this)"></td>

		<% if (masterFilePreferences.getOrDefault("display_former_name", false)) { %>
		<td align="right"><b><bean:message key="demographic.demographiceditdemographic.formFormerName" />: </b></td>
		<td align="left">
			<input type="hidden" name="former_name_id" size="10" maxlength="10" value="<%=demoExt.get("former_name_id")%>">
			<input type="text" name="former_name" size="30" onBlur="upCaseCtrl(this)"
			value="<%=StringEscapeUtils.escapeHtml(demoExt.getOrDefault("former_name", ""))%>">
		</td>
		<% } %>
	</tr>
	<tr>
		<td align="right"><b><bean:message
					key="demographic.demographiceditdemographic.msgDemoTitle" />: </b></td>
		<td align="left">
			<%
						String title = demographic.getTitle();
						if(title == null) {
							title="";
						}
					%> <select name="title" id="title" <%=getDisabled("title")%>>
				<option value="" <%=title.equals("")?"selected":""%>><bean:message
						key="demographic.demographiceditdemographic.msgNotSet" /></option>
				<option value="DR" <%=title.equalsIgnoreCase("DR")?"selected":""%>><bean:message
						key="demographic.demographicaddrecordhtm.msgDr" /></option>
				<option value="MS" <%=title.equalsIgnoreCase("MS")?"selected":""%>><bean:message
						key="demographic.demographiceditdemographic.msgMs" /></option>
				<option value="MISS"
					<%=title.equalsIgnoreCase("MISS")?"selected":""%>><bean:message
						key="demographic.demographiceditdemographic.msgMiss" /></option>
				<option value="MRS" <%=title.equalsIgnoreCase("MRS")?"selected":""%>><bean:message
						key="demographic.demographiceditdemographic.msgMrs" /></option>
				<option value="MR" <%=title.equalsIgnoreCase("MR")?"selected":""%>><bean:message
						key="demographic.demographiceditdemographic.msgMr" /></option>
				<option value="MSSR"
					<%=title.equalsIgnoreCase("MSSR")?"selected":""%>><bean:message
						key="demographic.demographiceditdemographic.msgMssr" /></option>
				<option value="PROF"
					<%=title.equalsIgnoreCase("PROF")?"selected":""%>><bean:message
						key="demographic.demographiceditdemographic.msgProf" /></option>
				<option value="REEVE"
					<%=title.equalsIgnoreCase("REEVE")?"selected":""%>><bean:message
						key="demographic.demographiceditdemographic.msgReeve" /></option>
				<option value="REV" <%=title.equalsIgnoreCase("REV")?"selected":""%>><bean:message
						key="demographic.demographiceditdemographic.msgRev" /></option>
				<option value="RT_HON"
					<%=title.equalsIgnoreCase("RT_HON")?"selected":""%>><bean:message
						key="demographic.demographiceditdemographic.msgRtHon" /></option>
				<option value="SEN" <%=title.equalsIgnoreCase("SEN")?"selected":""%>><bean:message
						key="demographic.demographiceditdemographic.msgSen" /></option>
				<option value="SGT" <%=title.equalsIgnoreCase("SGT")?"selected":""%>><bean:message
						key="demographic.demographiceditdemographic.msgSgt" /></option>
				<option value="SR" <%=title.equalsIgnoreCase("SR")?"selected":""%>><bean:message
						key="demographic.demographiceditdemographic.msgSr" /></option>
				<option value="DR" <%=title.equalsIgnoreCase("DR")?"selected":""%>><bean:message
						key="demographic.demographiceditdemographic.msgDr" /></option>
		</select>
		</td>
	</tr>
	<tr>
		<td align="right"><b><bean:message
			key="demographic.demographiceditdemographic.msgSpoken" />: </b></td>
		<td>
			<%String spokenLang = oscar.util.StringUtils.noNull(demographic.getSpokenLanguage()); %>
			<select name="spoken_lang" <%=getDisabled("spoken_lang")%>>
				<%for (String splang : Util.spokenLangProperties.getLangSorted()) { %>
					<option value="<%=splang %>"
					<%=spokenLang.equals(splang)?"selected":"" %>><%=splang %></option>
				<%} %>
			</select>
		</td>
		<td align="right"><b><bean:message
			key="demographic.demographiceditdemographic.msgDemoLanguage" />: </b></td>
		<td align="left">
			<% String lang = oscar.util.StringUtils.noNull(demographic.getOfficialLanguage()); %>
			<select name="official_lang" <%=getDisabled("official_lang")%>>
				<option value="English" <%=lang.equals("English")?"selected":""%>><bean:message
					key="demographic.demographiceditdemographic.msgEnglish" /></option>
				<option value="French" <%=lang.equals("French")?"selected":""%>><bean:message
					key="demographic.demographiceditdemographic.msgFrench" /></option>
				<option value="Other" <%=lang.equals("Other")?"selected":""%>><bean:message
					key="demographic.demographiceditdemographic.optOther" /></option>
			</select>
		</td>
	</tr>
	<% if (propertyDao.isActiveBooleanProperty("masterfile_show_reminder_preference")) { %>
	<tr>
		<td></td>
		<td></td>
		<td style="text-align: right"><b>Reminder Preference:</b></td>
		<td style="text-align: left">
			<input type="hidden" name=reminder_preference_id" value="<%=demoExt.get("reminder_preference_id")%>"/>
			<select name="reminder_preference">
				<%	DemographicReminderPreference.Types selectedReminderPreference = DemographicReminderPreference.Types.SYSTEM_DEFAULT;
					if (!StringUtils.isBlank(demoExt.get("reminder_preference"))) {
						selectedReminderPreference = DemographicReminderPreference.Types.valueOf(demoExt.get("reminder_preference"));
					}
					for (DemographicReminderPreference.Types rp : DemographicReminderPreference.Types.values()) { 
				%>
				<option value="<%=rp.name()%>"<%=(selectedReminderPreference == rp)?" selected=\"selected\"":""%>>
					<%=rp.getDescription()%>
				</option>
				<%	} %>
			</select>
		</td>
	</tr>
	<% } %>
	<tr valign="top">
	<td align="left" colspan="2"><b>Residential</b></td>
	</tr>
	<tr valign="top">
		<td align="right"><b><bean:message
					key="demographic.demographiceditdemographic.formAddr" />: </b></td>
		<td align="left"><input type="text" name="address"
			<%=getDisabled("address")%> size="30"
			value="<%=StringUtils.trimToEmpty(demographic.getAddress())%>">
		</td>
		<td align="right"><b><bean:message
					key="demographic.demographiceditdemographic.formCity" />: </b></td>
		<td align="left"><input type="text" name="city" size="30"
			<%=getDisabled("city")%>
			value="<%=StringEscapeUtils.escapeHtml(StringUtils.trimToEmpty(demographic.getCity()))%>"></td>
	</tr>

	<tr valign="top">
		<td align="right"><b> <% if(oscarProps.getProperty("demographicLabelProvince") == null) { %>
				<bean:message
					key="demographic.demographiceditdemographic.formProcvince" /> <% } else {
                                  out.print(oscarProps.getProperty("demographicLabelProvince"));
                              	 } %> :
		</b></td>
		<td align="left">
			<% String province = demographic.getProvince(); %> <select
			name="province" style="width: 200px" <%=getDisabled("province")%>>
				<option value="OT"
					<%=(province==null || province.equals("OT") || province.equals("") || province.length() > 2)?" selected":""%>>Other</option>
				<% if (pNames.isDefined()) {
                                       for (ListIterator li = pNames.listIterator(); li.hasNext(); ) {
                                           String pr2 = (String) li.next(); %>
				<option value="<%=pr2%>" <%=pr2.equals(province)?" selected":""%>><%=li.next()%></option>
				<% }//for %>
				<% } else {
					Map<String, String> provinces = ProvinceNames.getDefaultProvinces();
					for (Map.Entry<String, String> entry : provinces.entrySet()) {
						String shortName = entry.getKey();
						String longName = entry.getValue();
						Boolean selected = (province != null && shortName.equals(province));
				%>
					<option value="<%=shortName%>" <%=selected?" selected":""%>><%=shortName%>-<%=longName%></option>
				<%	}
				} %>
		</select>
		</td>
		<td align="right"><b> <% if(oscarProps.getProperty("demographicLabelPostal") == null) { %>
				<bean:message
					key="demographic.demographiceditdemographic.formPostal" /> <% } else {
                                  out.print(oscarProps.getProperty("demographicLabelPostal"));
                              	 } %> :
		</b></td>
		<td align="left"><input type="text" name="postal" size="30"
			<%=getDisabled("postal")%>
			value="<%=StringUtils.trimToEmpty(demographic.getPostal())%>"
			onBlur="upCaseCtrl(this)" onChange="isPostalCode()"></td>
	</tr>

	<tr valign="top">
	<td align="left" colspan="2"><b>Mailing</b></td>
	</tr>
	<tr valign="top">
	<td align="right"> <b><bean:message key="demographic.demographiceditdemographic.formAddr" />: </b> </td>
	<td align="left">
		<input type="text" name="address_mailing" <%=getDisabled("address")%> size="30" value="<%=StringUtils.trimToEmpty(demoExt.get("address_mailing"))%>"/>
	</td>
	<td align="right"> <b><bean:message key="demographic.demographiceditdemographic.formCity" />: </b> </td>
	<td align="left">
		<input type="text" name="city_mailing" size="30" <%=getDisabled("city")%> value="<%=StringEscapeUtils.escapeHtml(StringUtils.trimToEmpty(StringUtils.trimToEmpty(demoExt.get("city_mailing"))))%>" />
	</td>
	</tr>

	<tr valign="top">
	<td align="right">
		<b> 
			<% if(oscarProps.getProperty("demographicLabelProvince") == null) { %>
			<bean:message key="demographic.demographiceditdemographic.formProcvince" /> <% 
			} else { 
				out.print(oscarProps.getProperty("demographicLabelProvince")); 
			} %> :
		</b>
	</td>
	<td align="left">
	<% String provinceMailing = demoExt.get("province_mailing"); %> 
	<select name="province_mailing" style="width: 200px" <%=getDisabled("province")%>>
	<option value="OT" <%=(provinceMailing==null || provinceMailing.equals("OT") || provinceMailing.equals("") || provinceMailing.length() > 2)?" selected":""%>>Other</option>
	<% if (pNames.isDefined()) {
		for (ListIterator li = pNames.listIterator(); li.hasNext(); ) {
			String pr2 = (String) li.next(); %>
	<option value="<%=pr2%>" <%=pr2.equals(provinceMailing)?" selected":""%>><%=li.next()%></option>
	<% }//for %>
	<% } else { %>
	<option value="AB" <%="AB".equals(provinceMailing)?" selected":""%>>AB-Alberta</option>
	<option value="BC" <%="BC".equals(provinceMailing)?" selected":""%>>BC-British
	Columbia</option>
	<option value="MB" <%="MB".equals(provinceMailing)?" selected":""%>>MB-Manitoba</option>
	<option value="NB" <%="NB".equals(provinceMailing)?" selected":""%>>NB-New
	Brunswick</option>
	<option value="NL" <%="NL".equals(provinceMailing)?" selected":""%>>NL-Newfoundland
	Labrador</option>
	<option value="NT" <%="NT".equals(provinceMailing)?" selected":""%>>NT-Northwest
	Territory</option>
	<option value="NS" <%="NS".equals(provinceMailing)?" selected":""%>>NS-Nova
	Scotia</option>
	<option value="NU" <%="NU".equals(provinceMailing)?" selected":""%>>NU-Nunavut</option>
	<option value="ON" <%="ON".equals(provinceMailing)?" selected":""%>>ON-Ontario</option>
	<option value="PE" <%="PE".equals(provinceMailing)?" selected":""%>>PE-Prince
	Edward Island</option>
	<option value="QC" <%="QC".equals(provinceMailing)?" selected":""%>>QC-Quebec</option>
	<option value="SK" <%="SK".equals(provinceMailing)?" selected":""%>>SK-Saskatchewan</option>
	<option value="YT" <%="YT".equals(provinceMailing)?" selected":""%>>YT-Yukon</option>
	<option value="US" <%="US".equals(provinceMailing)?" selected":""%>>US
	resident</option>
	<option value="US-AK" <%="US-AK".equals(provinceMailing)?" selected":""%>>US-AK-Alaska</option>
	<option value="US-AL" <%="US-AL".equals(provinceMailing)?" selected":""%>>US-AL-Alabama</option>
	<option value="US-AR" <%="US-AR".equals(provinceMailing)?" selected":""%>>US-AR-Arkansas</option>
	<option value="US-AZ" <%="US-AZ".equals(provinceMailing)?" selected":""%>>US-AZ-Arizona</option>
	<option value="US-CA" <%="US-CA".equals(provinceMailing)?" selected":""%>>US-CA-California</option>
	<option value="US-CO" <%="US-CO".equals(provinceMailing)?" selected":""%>>US-CO-Colorado</option>
	<option value="US-CT" <%="US-CT".equals(provinceMailing)?" selected":""%>>US-CT-Connecticut</option>
	<option value="US-CZ" <%="US-CZ".equals(provinceMailing)?" selected":""%>>US-CZ-Canal
	Zone</option>
	<option value="US-DC" <%="US-DC".equals(provinceMailing)?" selected":""%>>US-DC-District
	Of Columbia</option>
	<option value="US-DE" <%="US-DE".equals(provinceMailing)?" selected":""%>>US-DE-Delaware</option>
	<option value="US-FL" <%="US-FL".equals(provinceMailing)?" selected":""%>>US-FL-Florida</option>
	<option value="US-GA" <%="US-GA".equals(provinceMailing)?" selected":""%>>US-GA-Georgia</option>
	<option value="US-GU" <%="US-GU".equals(provinceMailing)?" selected":""%>>US-GU-Guam</option>
	<option value="US-HI" <%="US-HI".equals(provinceMailing)?" selected":""%>>US-HI-Hawaii</option>
	<option value="US-IA" <%="US-IA".equals(provinceMailing)?" selected":""%>>US-IA-Iowa</option>
	<option value="US-ID" <%="US-ID".equals(provinceMailing)?" selected":""%>>US-ID-Idaho</option>
	<option value="US-IL" <%="US-IL".equals(provinceMailing)?" selected":""%>>US-IL-Illinois</option>
	<option value="US-IN" <%="US-IN".equals(provinceMailing)?" selected":""%>>US-IN-Indiana</option>
	<option value="US-KS" <%="US-KS".equals(provinceMailing)?" selected":""%>>US-KS-Kansas</option>
	<option value="US-KY" <%="US-KY".equals(provinceMailing)?" selected":""%>>US-KY-Kentucky</option>
	<option value="US-LA" <%="US-LA".equals(provinceMailing)?" selected":""%>>US-LA-Louisiana</option>
	<option value="US-MA" <%="US-MA".equals(provinceMailing)?" selected":""%>>US-MA-Massachusetts</option>
	<option value="US-MD" <%="US-MD".equals(provinceMailing)?" selected":""%>>US-MD-Maryland</option>
	<option value="US-ME" <%="US-ME".equals(provinceMailing)?" selected":""%>>US-ME-Maine</option>
	<option value="US-MI" <%="US-MI".equals(provinceMailing)?" selected":""%>>US-MI-Michigan</option>
	<option value="US-MN" <%="US-MN".equals(provinceMailing)?" selected":""%>>US-MN-Minnesota</option>
	<option value="US-MO" <%="US-MO".equals(provinceMailing)?" selected":""%>>US-MO-Missouri</option>
	<option value="US-MS" <%="US-MS".equals(provinceMailing)?" selected":""%>>US-MS-Mississippi</option>
	<option value="US-MT" <%="US-MT".equals(provinceMailing)?" selected":""%>>US-MT-Montana</option>
	<option value="US-NC" <%="US-NC".equals(provinceMailing)?" selected":""%>>US-NC-North
	Carolina</option>
	<option value="US-ND" <%="US-ND".equals(provinceMailing)?" selected":""%>>US-ND-North
	Dakota</option>
	<option value="US-NE" <%="US-NE".equals(provinceMailing)?" selected":""%>>US-NE-Nebraska</option>
	<option value="US-NH" <%="US-NH".equals(provinceMailing)?" selected":""%>>US-NH-New
	Hampshire</option>
	<option value="US-NJ" <%="US-NJ".equals(provinceMailing)?" selected":""%>>US-NJ-New
	Jersey</option>
	<option value="US-NM" <%="US-NM".equals(provinceMailing)?" selected":""%>>US-NM-New
	Mexico</option>
	<option value="US-NU" <%="US-NU".equals(provinceMailing)?" selected":""%>>US-NU-Nunavut</option>
	<option value="US-NV" <%="US-NV".equals(provinceMailing)?" selected":""%>>US-NV-Nevada</option>
	<option value="US-NY" <%="US-NY".equals(provinceMailing)?" selected":""%>>US-NY-New
	York</option>
	<option value="US-OH" <%="US-OH".equals(provinceMailing)?" selected":""%>>US-OH-Ohio</option>
	<option value="US-OK" <%="US-OK".equals(provinceMailing)?" selected":""%>>US-OK-Oklahoma</option>
	<option value="US-OR" <%="US-OR".equals(provinceMailing)?" selected":""%>>US-OR-Oregon</option>
	<option value="US-PA" <%="US-PA".equals(provinceMailing)?" selected":""%>>US-PA-Pennsylvania</option>
	<option value="US-PR" <%="US-PR".equals(provinceMailing)?" selected":""%>>US-PR-Puerto
	Rico</option>
	<option value="US-RI" <%="US-RI".equals(provinceMailing)?" selected":""%>>US-RI-Rhode
	Island</option>
	<option value="US-SC" <%="US-SC".equals(provinceMailing)?" selected":""%>>US-SC-South
	Carolina</option>
	<option value="US-SD" <%="US-SD".equals(provinceMailing)?" selected":""%>>US-SD-South
	Dakota</option>
	<option value="US-TN" <%="US-TN".equals(provinceMailing)?" selected":""%>>US-TN-Tennessee</option>
	<option value="US-TX" <%="US-TX".equals(provinceMailing)?" selected":""%>>US-TX-Texas</option>
	<option value="US-UT" <%="US-UT".equals(provinceMailing)?" selected":""%>>US-UT-Utah</option>
	<option value="US-VA" <%="US-VA".equals(provinceMailing)?" selected":""%>>US-VA-Virginia</option>
	<option value="US-VI" <%="US-VI".equals(provinceMailing)?" selected":""%>>US-VI-Virgin
	Islands</option>
	<option value="US-VT" <%="US-VT".equals(provinceMailing)?" selected":""%>>US-VT-Vermont</option>
	<option value="US-WA" <%="US-WA".equals(provinceMailing)?" selected":""%>>US-WA-Washington</option>
	<option value="US-WI" <%="US-WI".equals(provinceMailing)?" selected":""%>>US-WI-Wisconsin</option>
	<option value="US-WV" <%="US-WV".equals(provinceMailing)?" selected":""%>>US-WV-West
	Virginia</option>
	<option value="US-WY" <%="US-WY".equals(provinceMailing)?" selected":""%>>US-WY-Wyoming</option>
	<% } %>
	</select>
	</td>
	<td align="right"><b> <% if(oscarProps.getProperty("demographicLabelPostal") == null) { %>
	<bean:message
			key="demographic.demographiceditdemographic.formPostal" /> <% } else {
	out.print(oscarProps.getProperty("demographicLabelPostal"));
} %> :
	</b></td>
	<td align="left">
		<input type="text" name="postal_mailing" size="30" <%=getDisabled("postal")%> value="<%=StringUtils.trimToEmpty(demoExt.get("postal_mailing"))%>" onBlur="upCaseCtrl(this)" onChange="isPostalCode()"/>
	</td>
	</tr>
	
	<%
		if (OscarProperties.getInstance().getBooleanProperty("enable_appointment_reminders", "true")) {
	%>
	<tr valign="top">
		<td align="right" nowrap>
			<b><bean:message key="demographic.demographiceditdemographic.AllowAppointmentReminders" />:</b>
		</td>
		<td align="left">
			<select name="allow_appointment_reminders" id="allow_appointment_reminders" onchange="checkApptReminderSelect();">
				<option value="true" <%=allowAppointmentReminders ? "selected=\"selected\"" : ""%>>Yes</option>
				<option value="false" <%=!allowAppointmentReminders ? "selected=\"selected\"" : ""%>>No</option>
			</select>
		</td>
	</tr>
	<tr valign="top" class="reminderContactMethods">
		<td align="right" nowrap></td>
		<td align="left">
			<label>Phone:
				<input type="checkbox" id="reminder_phone" name="reminder_phone" onclick="checkReminderContactMethod('reminder_phone')" <%=phoneReminders ? "checked" : ""%>/>
			</label>
			<label>Cell:
				<input type="checkbox" id="reminder_cell" name="reminder_cell" onclick="checkReminderContactMethod('reminder_cell')" <%=cellReminders ? "checked" : ""%>/>
			</label>
			<label>Email:
				<input type="checkbox" id="reminder_email" name="reminder_email" onclick="checkReminderContactMethod('reminder_email')" <%=emailReminders ? "checked" : ""%>/>
			</label>
		</td>
	</tr>
	<% } %>
	<tr valign="top">
		<td align="right"><b><bean:message
					key="demographic.demographiceditdemographic.formPhoneH" />: </b></td>
		<td align="left"><input type="text" name="phone" id="phone"
			onblur="formatPhoneNum();" <%=getDisabled("phone")%>
			style="display: inline; width: auto;"
			value="<%=StringUtils.trimToEmpty(StringUtils.trimToEmpty(demographic.getPhone()))%>" maxlength="20">
			<bean:message key="demographic.demographiceditdemographic.msgExt" />:<input
			type="text" name="hPhoneExt" <%=getDisabled("hPhoneExt")%>
			value="<%=StringUtils.trimToEmpty(StringUtils.trimToEmpty(demoExt.get("hPhoneExt")))%>"
			size="4" maxlength="5" /> <input type="hidden" name="hPhoneExtOrig"
			value="<%=StringUtils.trimToEmpty(StringUtils.trimToEmpty(demoExt.get("hPhoneExt")))%>" />
		</td>
		<td align="right"><b><bean:message
					key="demographic.demographiceditdemographic.formPhoneW" />:</b></td>
		<td align="left"><input type="text" name="phone2"
			<%=getDisabled("phone2")%> onblur="formatPhoneNum();"
			style="display: inline; width: auto;"
			value="<%=StringUtils.trimToEmpty(demographic.getPhone2())%>"  maxlength="20">
			<bean:message key="demographic.demographiceditdemographic.msgExt" />:<input
			type="text" name="wPhoneExt" <%=getDisabled("wPhoneExt")%>
			value="<%=StringUtils.trimToEmpty(StringUtils.trimToEmpty(demoExt.get("wPhoneExt")))%>"
			style="display: inline" size="4" maxlength="5" /> <input type="hidden"
			name="wPhoneExtOrig"
			value="<%=StringUtils.trimToEmpty(StringUtils.trimToEmpty(demoExt.get("wPhoneExt")))%>" />
		</td>
	</tr>
	<tr valign="top">
		<td align="right"><b><bean:message
					key="demographic.demographiceditdemographic.formPhoneC" />: </b></td>
		<td align="left"><input type="text" name="demo_cell" id="demo_cell"
			onblur="formatPhoneNum();" style="display: inline; width: auto;"
			<%=getDisabled("demo_cell")%>
			value="<%=StringUtils.trimToEmpty(demoExt.get("demo_cell"))%>">
			<input type="hidden" name="demo_cellOrig"
			value="<%=StringUtils.trimToEmpty(demoExt.get("demo_cell"))%>" /></td>
		<td align="right"><b><bean:message
					key="demographic.demographicaddrecordhtm.formPhoneComment" />: </b></td>
		<td align="left" colspan="3"><input type="hidden"
			name="phoneCommentOrig"
			value="<%=StringUtils.trimToEmpty(demoExt.get("phoneComment"))%>" />
			<textarea rows="2" cols="30" name="phoneComment"><%=StringUtils.trimToEmpty(demoExt.get("phoneComment"))%></textarea>
		</td>
	</tr>
	<tr valign="top">
		<td align="right"><b><bean:message
					key="demographic.demographiceditdemographic.formNewsLetter" />: </b></td>
		<td align="left">
			<% String newsletter = oscar.util.StringUtils.noNull(demographic.getNewsletter()).trim();
								     if( newsletter == null || newsletter.equals("")) {
								        newsletter = "Unknown";
								     }
								  %> <select name="newsletter" <%=getDisabled("newsletter")%>>
				<option value="Unknown" <%if(newsletter.equals("Unknown")){%>
					selected <%}%>><bean:message
						key="demographic.demographicaddrecordhtm.formNewsLetter.optUnknown" /></option>
				<option value="No" <%if(newsletter.equals("No")){%> selected <%}%>><bean:message
						key="demographic.demographicaddrecordhtm.formNewsLetter.optNo" /></option>
				<option value="Paper" <%if(newsletter.equals("Paper")){%> selected
					<%}%>><bean:message
						key="demographic.demographicaddrecordhtm.formNewsLetter.optPaper" /></option>
				<option value="Electronic" <%if(newsletter.equals("Electronic")){%>
					selected <%}%>><bean:message
						key="demographic.demographicaddrecordhtm.formNewsLetter.optElectronic" /></option>
		</select>
		</td>
		<td align="right"><b><bean:message
					key="demographic.demographiceditdemographic.aboriginal" />: </b></td>
		<td align="left"><select name="aboriginal"
			<%=getDisabled("aboriginal")%>>
				<option value="" <%if(aboriginal.equals("")){%> selected <%}%>>Unknown</option>
				<option value="No" <%if(aboriginal.equals("No")){%> selected <%}%>>No</option>
				<option value="Yes" <%if(aboriginal.equals("Yes")){%> selected <%}%>>Yes</option>

		</select> <input type="hidden" name="aboriginalOrig"
			value="<%=StringUtils.trimToEmpty(demoExt.get("aboriginal"))%>" /></td>
	</tr>
	<tr valign="top">
		<td align="right"><b><bean:message
					key="demographic.demographiceditdemographic.formEmail" />: </b></td>
		<td align="left"><input type="text" name="email" id="email" size="30"
			<%=getDisabled("email")%>
			value="<%=demographic.getEmail()!=null? demographic.getEmail() : ""%>">
		<input type="checkbox" name="includeEmailOnConsults" <%=Boolean.parseBoolean(demoExt.get("includeEmailOnConsults")) ? "checked='checked'" : ""%> value="true"/> Include on Consults
		</td>
		<% if (oscarProps.getProperty("MY_OSCAR").equalsIgnoreCase("yes")) { %>
			<td align="right"><b><bean:message
				key="demographic.demographiceditdemographic.formPHRUserName" />: </b>
			</td>
			<td align="left"><input type="text" name="myOscarUserName"
			size="30" <%=getDisabled("myOscarUserName")%>
			value="<%=demographic.getMyOscarUserName()!=null? demographic.getMyOscarUserName() : ""%>"><br />
			<%
				if (demographic.getMyOscarUserName()==null ||demographic.getMyOscarUserName().equals(""))
				{
					String onclickString="popup(900, 800, '../phr/indivo/RegisterIndivo.jsp?demographicNo="+demographic_no+"', 'indivoRegistration');";
					MyOscarLoggedInInfo myOscarLoggedInInfo=MyOscarLoggedInInfo.getLoggedInInfo(session);
					if (myOscarLoggedInInfo==null || !myOscarLoggedInInfo.isLoggedIn()) onclickString="alert('Please login to MyOscar first.')";
			%>
			<a href="javascript:" onclick="<%=onclickString%>"><sub style="white-space: nowrap;"><bean:message key="demographic.demographiceditdemographic.msgRegisterPHR" /></sub>
			</a>
			<%}%>
			</td>
		<%}%>
	</tr>
	<tr valign="top">
		<td align="right"><b><bean:message
					key="demographic.demographiceditdemographic.formDOB" /></b>
		<bean:message
				key="demographic.demographiceditdemographic.formDOBDetais" /><b>:</b>
		</td>
		<td align="left" nowrap>
			<input type="text" name="full_birth_date" id="full_birth_date" value="<%=birthYear + "_" + birthMonth + "_" + birthDate%>"/>
			<img src="../images/cal.gif" id="full_birth_date_cal">
			<input type="hidden" name="year_of_birth" id="year_of_birth" value="<%=birthYear%>"/>
			<input type="hidden" name="month_of_birth" id="month_of_birth" value="<%=birthMonth%>"/>
			<input type="hidden" name="date_of_birth" id="date_of_birth" value="<%=birthDate%>"/>
			<script type="application/javascript">
				createStandardDatepicker(jQuery_3_1_0('#full_birth_date'), "full_birth_date_cal");
				jQuery_3_1_0('#full_birth_date').change(function(){
					var birthDate = new Date(jQuery_3_1_0('#full_birth_date').val());
					if (!isNaN(birthDate)) {
						document.getElementById('year_of_birth').value = birthDate.toISOString().substring(0, 4);
						document.getElementById('month_of_birth').value = birthDate.toISOString().substring(5, 7)
						document.getElementById('date_of_birth').value = birthDate.toISOString().substring(8, 10)
					}
				});
			</script>
			<b>Age: <input type="text" name="age" readonly value="<%=age%>" size="3"></b>
		</td>
		<td align="right" nowrap><b><bean:message key="demographic.demographiceditdemographic.formSex" />:</b></td>
		<td>
			<select name="sex" id="sex">
				<option value=""></option>
				<% for(Gender gn : Gender.values()){ %>
					<option value=<%=gn.name()%> <%=((demographic.getSex().toUpperCase().equals(gn.name())) ? " selected=\"selected\" " : "") %>>
						<%=gn.getText()%></option>
				<% } %>
			</select>
		</td>
	</tr>
	<tr valign="top">
		<td align="right"><b><bean:message
					key="demographic.demographiceditdemographic.formHin" />: </b></td>
		<td align="left" nowrap><input type="text" name="hin"
			<%=getDisabled("hin")%>
			value="<%=StringUtils.trimToEmpty(demographic.getHin())%>" size="17">
			<b><bean:message
					key="demographic.demographiceditdemographic.formVer" /></b> <input
			type="text" name="ver" <%=getDisabled("ver")%>
			value="<%=StringUtils.trimToEmpty(demographic.getVer())%>" size="3"
			onBlur="upCaseCtrl(this)">
		<a href="#" onclick="popup(500, 500, '/CardSwipe/?hc='+(document.getElementsByName('hin')[0].value)+' '+(document.getElementsByName('ver')[0].value)+'&providerNo=<%=loggedInInfo.getLoggedInProviderNo()%>', 'Card Swipe'); return false;">
			Validate HC
		</a>
	</td>
		<td align="right"><b><bean:message
					key="demographic.demographiceditdemographic.formEFFDate" />:</b></td>
		<td align="left">
			<%
				java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyy-MM-dd");
				String effDate=null;
				if(demographic.getEffDate() != null) {
					effDate=StringUtils.trimToNull(sdf.format(demographic.getEffDate()));
				}
			%>
			<input type="text" name="eff_date" id="eff_date" <%=getDisabled("eff_date")%> size="11" value="<%= effDate%>">
			<img src="../images/cal.gif" id="eff_date_cal">
			<script type="application/javascript">createStandardDatepicker(jQuery_3_1_0('#eff_date'), "eff_date_cal");</script>
		</td>
	</tr>
	<tr valign="top">
		<td align="right"><b><bean:message
					key="demographic.demographiceditdemographic.formHCType" />:</b></td>
		<td align="left">
			<% String hctype = demographic.getHcType()==null?"":demographic.getHcType(); %>
			<select name="hc_type" style="width: 200px"
			<%=getDisabled("hc_type")%>>
				<option value="OT"
					<%=(hctype.equals("OT") || hctype.equals("") || hctype.length() > 2)?" selected":""%>><bean:message
						key="demographic.demographiceditdemographic.optOther" /></option>
				<% if (pNames.isDefined()) {
                                       for (ListIterator li = pNames.listIterator(); li.hasNext(); ) {
                                           province = (String) li.next(); %>
				<option value="<%=province%>"
					<%=province.equals(hctype)?" selected":""%>><%=li.next()%></option>
				<% } %>
				<% } else { 
					Map<String, String> provinces = ProvinceNames.getDefaultProvinces();
					Boolean customHCTypesDisplayed = false;
					for (Map.Entry<String, String> entry : provinces.entrySet()) {
						String shortName = entry.getKey();
						String longName = entry.getValue(); 
						Boolean selected = hctype.equals(shortName);
						
						if (shortName.startsWith("US") && !customHCTypesDisplayed) {
							List<CustomHealthcardType> customHealthcardTypes = customHealthcardTypeDao.findAll();
							for (CustomHealthcardType customHcType : customHealthcardTypes) {
								if ((customHcType.getEnabled() && !customHcType.getDeleted()) || hctype.equals(customHcType.getName())) { %>
				<option value="<%=customHcType.getName()%>" <%=hctype.equals(customHcType.getName())?" selected=\"selected\"":""%>>
					<%=customHcType.getName() + (customHcType.getDeleted()?" (deleted)":"")%>
				</option>
				<% 				}
							}
							customHCTypesDisplayed = true;
						}
				%>
				<option value="<%=shortName%>" <%=selected?" selected":""%>><%=shortName%>-<%=longName%></option>
				<% 	}
				}
				%>
	
		</select>
		</td>

		<td align="right"><b><bean:message
					key="demographic.demographiceditdemographic.formHCRenewDate" />:</b></td>
		<td align="left">
			<%
				 String renewDate="";
				 if (demographic.getHcRenewDate()!=null) {
					 renewDate = demographic.getHcRenewDate().toString();
				 }
			%> 
			<input type="text" name="hc_renew_date" id="hc_renew_date"
				size="11" value="<%=renewDate%>" <%=getDisabled("hc_renew_date")%>>
			<img src="../images/cal.gif" id="hc_renew_date_cal">
			<script type="application/javascript">createStandardDatepicker(jQuery_3_1_0('#hc_renew_date'), "hc_renew_date_cal");</script>
		</td>
	</tr>
	<tr valign="top">
		<td align="right"><b><bean:message
					key="demographic.demographiceditdemographic.msgCountryOfOrigin" />:
		</b></td>
		<td align="left"><select id="countryOfOrigin"
			name="countryOfOrigin" <%=getDisabled("countryOfOrigin")%>>
				<option value="-1"><bean:message
						key="demographic.demographiceditdemographic.msgNotSet" /></option>
				<%for(CountryCode cc : countryList){ %>
				<option value="<%=cc.getCountryId()%>"
					<% if (oscar.util.StringUtils.noNull(demographic.getCountryOfOrigin()).equals(cc.getCountryId())){out.print("SELECTED") ;}%>><%=cc.getCountryName() %></option>
				<%}%>
		</select></td>
	</tr>
	<tr valign="top">
	<% if (showSin) {%>
		<td align="right"><b>SIN:</b></td>
		<td align="left"><input type="text" name="sin" <%=getDisabled("sin")%> size="30" value="<%=StringUtils.trimToEmpty(demographic.getSin())%>"></td>
	<%}%>
		<td align="right" nowrap><b> <bean:message
					key="demographic.demographiceditdemographic.cytolNum" />:
		</b></td>
		<td><input type="text" name="cytolNum"
			<%=getDisabled("cytolNum")%> style="display: inline; width: auto;"
			value="<%=StringUtils.trimToEmpty(demoExt.get("cytolNum"))%>">
			<input type="hidden" name="cytolNumOrig"
			value="<%=StringUtils.trimToEmpty(demoExt.get("cytolNum"))%>" /></td>
	</tr>

	<tr>
		<td colspan="8">
			<%-- TOGGLE FIRST NATIONS MODULE --%> <oscar:oscarPropertiesCheck
				value="true" defaultVal="false" property="FIRST_NATIONS_MODULE">

				<jsp:include page="manageFirstNationsModule.jsp" flush="false">
					<jsp:param name="demo" value="<%= demographic_no %>" />
				</jsp:include>

			</oscar:oscarPropertiesCheck> <%-- END TOGGLE FIRST NATIONS MODULE --%>

		</td>
	</tr>

	<%-- TOGGLE OFF PATIENT CLINIC STATUS --%>
	<oscar:oscarPropertiesCheck
		property="DEMOGRAPHIC_PATIENT_CLINIC_STATUS" value="true">

		<tr valign="top">
			<td align="right" nowrap><b> <% if(oscarProps.getProperty("demographicLabelDoctor") != null) { out.print(oscarProps.getProperty("demographicLabelDoctor","")); } else { %>
					<bean:message
						key="demographic.demographiceditdemographic.formDoctor" /> <% } %>:
			</b></td>
			<td align="left"><select name="provider_no" id="provider_no"
				<%=getDisabled("provider_no")%> style="width: 200px">
				<option value=""></option>
					<%
							for(Provider p : doctors) {
                         
                        %>
					<option value="<%=p.getProviderNo()%>"
						<%=p.getProviderNo().equals(demographic.getProviderNo())?"selected":""%>>
						<%=Misc.getShortStr( (p.getLastName()+","+p.getFirstName()),"",nStrShowLen)%></option>
					<% } %>
			</select></td>
			<td align="right" nowrap><b><bean:message
						key="<%= nurseMessageKey %>" />: </b></td>
			<td align="left"><select name="nurse" <%=getDisabled("nurse")%>
				style="width: 200px">
					<option value=""></option>
					<%
                         
                         
									for(Provider p : nurses) {
                        %>
					<option value="<%=p.getProviderNo()%>"
						<%=p.getProviderNo().equals(nurse)?"selected":""%>>
						<%=Misc.getShortStr( (p.getLastName()+","+p.getFirstName()),"",nStrShowLen)%></option>
					<% } %>
			</select></td>
		</tr>
		<%
			String patientStatusDate = "";
			if (demographic.getPatientStatusDate() != null) {
				patientStatusDate = demographic.getPatientStatusDate().toString();
			}
		%>
		<tr valign="top">
			<td align="right"><b><bean:message
					key="demographic.demographiceditdemographic.formPatientStatus" />:</b>
				<b> </b></td>
			<td align="left">
				<%
					String patientStatus = demographic.getPatientStatus();
					if (patientStatus == null)
						patientStatus = "";
				%>
				<input type="hidden" name="initial_patientstatus"
					   value="<%=patientStatus%>"> <select name="patient_status"
														   style="width: 120" <%=getDisabled("patient_status")%> onChange="updateStatusDate('patient');">

				<option value="AC" <%="AC".equals(patientStatus) ? " selected" : ""%>>
					<bean:message
							key="demographic.demographiceditdemographic.optActive" /></option>
				<option value="IN" <%="IN".equals(patientStatus) ? " selected" : ""%>>
					<bean:message
							key="demographic.demographiceditdemographic.optInActive" /></option>
				<option value="DE" <%="DE".equals(patientStatus) ? " selected" : ""%>>
					<bean:message
							key="demographic.demographiceditdemographic.optDeceased" /></option>
				<option value="MO" <%="MO".equals(patientStatus) ? " selected" : ""%>>
					<bean:message key="demographic.demographiceditdemographic.optMoved" /></option>
				<option value="FI" <%="FI".equals(patientStatus) ? " selected" : ""%>>
					<bean:message key="demographic.demographiceditdemographic.optFired" /></option>
				<%
					for (String status : demographicDao.search_ptstatus()) {
				%>
				<option <%=status.equals(patientStatus) ? " selected" : ""%>><%=status%></option>
				<%
					}

					// end while
				%>
			</select> <input type="button" onClick="newStatus();"
							 value="<bean:message key="demographic.demographiceditdemographic.btnAddNew"/>">

			</td>
			<td align="right" nowrap>
				<b><bean:message key="demographic.demographiceditdemographic.PatientStatusDate" />: </b></td>
			<td align="left">
				<input  type="text" name="patientstatus_date" id="patientstatus_date" size="11" value="<%=patientStatusDate%>">
				<img src="../images/cal.gif" id="patientstatus_date_cal">
				<script type="application/javascript">createStandardDatepicker(jQuery_3_1_0('#patientstatus_date'), "patientstatus_date_cal");</script>
			</td>
		</tr>
		<tr valign="top">
			<td align="right" nowrap><b><bean:message
						key="<%= midwifeMessageKey %>" />: </b></td>
			<td align="left"><select name="midwife"
				<%=getDisabled("midwife")%> style="width: 200px">
					<option value=""></option>
					<%
									for(Provider p : midwifes) {
                        %>
					<option value="<%=p.getProviderNo()%>"
						<%=p.getProviderNo().equals(midwife)?"selected":""%>>
						<%=Misc.getShortStr( (p.getLastName()+","+p.getFirstName()),"",nStrShowLen)%></option>
					<% } %>
			</select></td>
			<td align="right"><b><bean:message
						key="<%= residentMessageKey %>" />:</b></td>
			<td align="left"><select name="resident" style="width: 200px"
				<%=getDisabled("resident")%>>
					<option value=""></option>
					<%
									for(Provider p : doctors) {
                        %>
					<option value="<%=p.getProviderNo()%>"
						<%=p.getProviderNo().equals(resident)?"selected":""%>>
						<%=Misc.getShortStr( (p.getLastName()+","+p.getFirstName()),"",nStrShowLen)%></option>
					<% } %>
			</select></td>
		</tr>

		<tr valign="top">
			<td align="right" nowrap><b><bean:message
						key="demographic.demographiceditdemographic.formRefDoc" />: </b></td>
			<td align="left">
				<% if(oscarProps.getProperty("isMRefDocSelectList", "").equals("true") ) {
                                  		// drop down list
									  Properties prop = null;
									  ArrayList<Properties> refProperties = new ArrayList<Properties>();
									  List<ProfessionalSpecialist> specialists = professionalSpecialistDao.findAll();
                                      for(ProfessionalSpecialist specialist : specialists) {
                                    	  prop = new Properties();
                                    	  if (specialist != null && specialist.getReferralNo() != null && ! specialist.getReferralNo().equals("")) {
	                                          prop.setProperty("referral_no", specialist.getReferralNo());
	                                          prop.setProperty("last_name", specialist.getLastName());
	                                          prop.setProperty("first_name", specialist.getFirstName());
	                                          refProperties.add(prop);
                                    	  }
                                      }

                                  %> <select name="r_doctor"
				<%=getDisabled("r_doctor")%> onChange="changeRefDoc()"
				style="width: 200px">
					<option value=""></option>
					<% for(int k=0; k<refProperties.size(); k++) {
                                  		prop= (Properties) refProperties.get(k);
                                  	%>
					<option
						value="<%=prop.getProperty("last_name")+","+prop.getProperty("first_name")%>"
						<%=prop.getProperty("referral_no").equals(rdohip)?"selected":""%>>
						<%=Misc.getShortStr( (prop.getProperty("last_name")+","+prop.getProperty("first_name")),"",nStrShowLen)%></option>
					<% }
 	                      	
 	                       %>
			</select> <script type="text/javascript" language="Javascript">
<!--
function changeRefDoc() {
//alert(document.updatedelete.r_doctor.value);
var refName = document.updatedelete.r_doctor.options[document.updatedelete.r_doctor.selectedIndex].value;
var refNo = "";
  	<% for(int k=0; k<refProperties.size(); k++) {
  		prop= (Properties) refProperties.get(k);
  	%>
if(refName=="<%=prop.getProperty("last_name")+","+prop.getProperty("first_name")%>") {
  refNo = '<%=prop.getProperty("referral_no", "")%>';
}
<% } %>
document.updatedelete.r_doctor_ohip.value = refNo;
}
//-->
</script> <%
 	} else {
 %> <input type="hidden" name="rDoctorIdOrig" size="17"
				maxlength="40" value="<%=demoExt.get("familyDoctorId")%>"> <input
				type="hidden" name="r_doctor_id" size="17" maxlength="40"
				value="<%=demoExt.get("familyDoctorId")%>"> <input
				type="text" name="r_doctor" size="17" maxlength="40"
				<%=getDisabled("r_doctor")%> value="<%=rd%>"> <a
				href="javascript:referralScriptAttach2('r_doctor_ohip','r_doctor', 'r_doctor_id', 'name')"><bean:message
						key="demographic.demographiceditdemographic.btnSearch" /> Name</a> <%
 	}
 %>
			</td>
			<td align="right" nowrap><b><bean:message
						key="demographic.demographiceditdemographic.formRefDocNo" />: </b></td>
			<td align="left"><input type="text" name="r_doctor_ohip"
				<%=getDisabled("r_doctor_ohip")%> size="20" maxlength="6"
				value="<%=rdohip%>"> <%
 	if ("ON".equals(prov)) {
 %> <a
				href="javascript:referralScriptAttach2('r_doctor_ohip','r_doctor', 'r_doctor_id', 'number')"><bean:message
						key="demographic.demographiceditdemographic.btnSearch" /> #</a> <%
 	}
 %>
			</td>
		</tr>
		<% if (OscarProperties.getInstance().isPropertyActive("show_referral_date")) { %>
		<tr>
			<td align="right">
				<b>Referral Date:</b>
			</td>
			<td>
				<input type="hidden" name="referral-date-id" size="10" maxlength="10" value="<%=demoExt.get("referralDate_id")%>">
				<input type="text" name="referral-date" id="referral-date" value="<%=demoExt.get("referralDate")%>"/>
				<img src="../images/cal.gif" id="referral-date-calendar">
				<script type="application/javascript">
                    createStandardDatepicker(jQuery_3_1_0('#referral-date'), "referral-date-calendar");
				</script>
			</td>
		</tr>
        <% } %>

	</oscar:oscarPropertiesCheck>
	<%-- END TOGGLE OFF PATIENT CLINIC STATUS --%>

	<%-- TOGGLE OFF PATIENT ROSTERING - NOT USED IN ALL PROVINCES. --%>
	<oscar:oscarPropertiesCheck property="DEMOGRAPHIC_PATIENT_ROSTERING"
		value="true">

		<jsp:include page="./familyPhysicianModule.jsp">
			<jsp:param name="family_doc" value="<%=family_doc%>" />
		</jsp:include>
		<% if (oscarProps.isPropertyActive("masterfile_referral_source")) { %>
		<tr valign="top">
			<td align="right" nowrap>
				<b>Referral Source: </b>
			</td>
			<td>
				<select name="referral_source" style="width: 200px">
					<option value=""></option>
					<%  for (String rs : referralSources) { %>
					<option value="<%=rs%>"<%=rs.equals(currentReferralSource)?" selected=\"selected\"":""%>>
						<%=rs%>
					</option>
					<%  } %>
				</select>
				<input type="button" onClick="newReferralSource();" 
					   value="<bean:message key="demographic.demographiceditdemographic.btnAddNew"/>">
			</td>
			<td align="right" nowrap></td>
			<td></td>
		</tr>
        <% } %>
		<script>
            function toggleSameAsMRP() {
                jQuery_3_1_0('#enrollmentProvider').val(jQuery_3_1_0('#provider_no').val());
            }
		</script>
		<tr valign="top">
			<td align="right">
				<b><bean:message key="demographic.demographiceditdemographic.formEnrollmentDoctor" />: </b>
			</td>
			<td align="left">
				<select name="enrollmentProvider" id="enrollmentProvider" style="width: 200px">
					<option value=""></option>
					<%
						for(Provider p : doctors) {
					%>
							<option value="<%=p.getProviderNo()%>" <%=p.getProviderNo().equals(enrollmentProvider)?"selected":""%>>
								<%=Misc.getShortStr((p.getLastName() + "," + p.getFirstName()), "", nStrShowLen)%>
							</option>
					<% } %>
				</select>
				<input type="button" value="Same as MRP" onclick="toggleSameAsMRP(this)"/>
			</td>
		</tr>
		<tr valign="top">
			<td align="right" nowrap><b><bean:message
						key="demographic.demographiceditdemographic.formRosterStatus" />:
			</b></td>
			<td align="left">
				<%
					String rosterStatus = demographic.getRosterStatus();
						if (rosterStatus == null) {
							rosterStatus = "";
						}
				%> <input type="hidden"
				name="initial_rosterstatus" value="<%=rosterStatus%>" /> <select
				id="roster_status" name="roster_status" style="width: 120"
				<%=getDisabled("roster_status")%> onchange="updateStatusDate('roster');checkRosterStatus2();">
					<option value=""></option>
					<option value="EN" <%="RO".equals(rosterStatus) ? " selected" : ""%>>
						<bean:message key="demographic.demographiceditdemographic.optEnrolled" />
					</option>
					<option value="NE" <%=rosterStatus.equals("NR") ? " selected" : ""%>>
						<bean:message key="demographic.demographiceditdemographic.optNotEnrolled" />
					</option>
					<option value="TE" <%=rosterStatus.equals("TE") ? " selected" : ""%>>
						<bean:message key="demographic.demographiceditdemographic.optTerminated" />
					</option>
					<option value="FS" <%=rosterStatus.equals("FS") ? " selected" : ""%>>
						<bean:message key="demographic.demographiceditdemographic.optFeeService" />
					</option>
					<option value="UHIP" <%=rosterStatus.equals("UHIP") ? " selected" : ""%>>
						<bean:message key="demographic.demographiceditdemographic.optUhip"/>
					</option>
					<option value="BI" <%=rosterStatus.equals("BI") ? " selected" : ""%>>
						<bean:message key="demographic.demographiceditdemographic.optBillInsurance"/>
					</option>
					<%
						for (String status : demographicDao.getRosterStatuses()) {
					%>
					<option <%=rosterStatus.equals(status) ? " selected" : ""%>><%=status%></option>
					<%
						}

							// end while
					%>
			</select> <input type="button" onClick="newStatus1();"
				value="<bean:message key="demographic.demographiceditdemographic.btnAddNew"/>">
			</td>
			<%
				String rosterDate = "";
				if (demographic.getRosterDate() != null) {
					rosterDate = demographic.getRosterDate().toString();
				}

				String rosterTerminationDate = "";
				String rosterTerminationReason = "";
				if (demographic.getRosterTerminationDate() != null) {
					rosterTerminationDate = demographic.getRosterTerminationDate().toString();
				}
				rosterTerminationReason = demographic.getRosterTerminationReason();
			%>

			<td align="right" nowrap><b><bean:message
						key="demographic.demographiceditdemographic.DateJoined" />: </b></td>
			<td align="left">
				<input type="text" name="roster_date" id="roster_date" size="11" value="<%=rosterDate%>">
				<img src="../images/cal.gif" id="roster_date_cal">
				<script type="application/javascript">createStandardDatepicker(jQuery_3_1_0('#roster_date'), "roster_date_cal");</script>
			</td>
		</tr>
		<tr valign="top" class="bill_insurance">
			<td align="right" nowrap>
				<b><bean:message key="demographic.demographiceditdemographic.BillInsurance" />:</b>
			</td>
			<td align="left">
				<select name="insurance_company"
						id="insurance_company">
					<option selected="selected" value=""></option>
					<%
						List sL = dbObj.get3rdAddrNameList();
						for (int i = 0; i < sL.size(); i++) {
							Properties propT = (Properties) sL.get(i);
					%>
					<option value="<%=propT.getProperty("id", "")%>" <%=propT.getProperty("id", "").equalsIgnoreCase(demoExt.get("insurance_company"))?" selected" : ""%>><%=propT.getProperty("company_name", "")%></option>
					<%}
					%>
				</select>
			</td>
		</tr>
		<tr valign="top" class="insurance_number">
			<td align="right">
				<b><bean:message key="demographic.demographiceditdemographic.InsuranceNumber" />: </b>
			</td>
			<td align="left">
				<input type="text" name="insurance_number" id="insurance_number" value="<%=StringUtils.trimToEmpty(demoExt.get("insurance_number"))%>">
			</td>
		</tr>
		<tr valign="top" class="termination_details">
			<td align="right" nowrap><b><bean:message
				key="demographic.demographiceditdemographic.RosterTerminationReason" />: </b></td>
			<td align="left" colspan="3">
				<select  name="roster_termination_reason">
					<option value="">N/A</option>
<%for (String code : Util.rosterTermReasonProperties.getTermReasonCodes()) { %>
					<option value="<%=code %>" <%=code.equals(rosterTerminationReason)?"selected":"" %> ><%=Util.rosterTermReasonProperties.getReasonByCode(code) %></option>
<%} %>
				</select>
			</td>
		</tr>
		<tr valign="top" class="termination_details">
			<td align="right" nowrap><b><bean:message
				key="demographic.demographiceditdemographic.RosterTerminationDate" />: </b></td>
			<td align="left">
				<input type="text" name="roster_termination_date" id="roster_termination_date" value="<%=rosterTerminationDate%>">
				<img src="../images/cal.gif" id="roster_termination_date_cal">
				<script type="application/javascript">createStandardDatepicker(jQuery_3_1_0('#roster_termination_date'), "roster_termination_date_cal");</script>
			</td>
		</tr>

	</oscar:oscarPropertiesCheck>
	<%-- END TOGGLE OFF PATIENT ROSTERING --%>
<script type="text/javascript" language="Javascript">
function updateStatusDate(patientOrRoster){
	var d = new Date();
	if(patientOrRoster == "patient"){
        var patientStatus = document.getElementById("patientstatus_date");

        if(patientStatus.value == ""){
            patientStatus.value = d.toISOString().substring(0, 10);
        }
	}
	else if (patientOrRoster == "roster"){
		var selectedRosterStatus = document.getElementById("roster_status").value;
		var rosterStatusDate = document.getElementById("roster_date");

		if(rosterStatusDate.value == "" ){
		    if (selectedRosterStatus == "RO" || selectedRosterStatus == "NR" || selectedRosterStatus == "UHIP"){
				rosterStatusDate.value = d.toISOString().substring(0, 10);
			}
		}
	}
}
</script>
	<tr>
		<td align="right"><b><bean:message
					key="demographic.demographiceditdemographic.formPatientType" />:</b></td>
		<td><select id="patientType" name="patientType"
			onchange="this.form.patientTypeOrig.value=this.options[this.selectedIndex].value">
				<option value="NotSet">Not Specified</option>
				<%
					for (PatientType thisPatientType : patientTypes) {
				%>
				<option value="<%=thisPatientType.getType()%>"
					<%=(patientType.equals(thisPatientType.getType()) ? "selected" : "")%>><%=thisPatientType.getDescription()%></option>
				<%
					}
				%>
		</select></td>

		<td align="right"><b><bean:message
					key="demographic.demographiceditdemographic.formChartNo" />:</b></td>
		<td align="left"><input type="text" name="chart_no" size="30"
			value="<%=StringUtils.trimToEmpty(demographic.getChartNo())%>"
			<%=getDisabled("chart_no")%>></td>		
	</tr>

	<tr>
		<td align="right"><b><bean:message
					key="demographic.demographiceditdemographic.formPatientId" />:</b></td>
		<td><input type="text" name="patientId" id="patientId"
			value="<%=patientId%>" size="25" maxlength="45" /></td>
			
		<td align="right"><b><bean:message
					key="demographic.demographiceditdemographic.formDemographicGroups" />:</b>
		</td>
		<td>
			<%
				for (DemographicGroupLink dg : demographicGroupsForPatient) {
			%> <input
			type="hidden" name="demographicGroupsOrig"
			value="<%=dg.getId().getDemographicGroupId()%>" /> <%
 	}
 %> <select
			id="demographicGroups" name="demographicGroups">
				<option value=""
					<%=demographicGroupsForPatient.size() == 0 ? "selected" : ""%>>
					None</option>
				<%
					for (DemographicGroup dg : demographicGroups) {
				%>
				<option value="<%=dg.getId()%>">
					<%=dg.getName()%>
				</option>
				<%
					}
				%>
		</select>
		</td>
	</tr>

	<tr>
		<td align="right"><b><bean:message
					key="web.record.details.archivedPaperChart" />: </b></td>
		<td align="left">
			<%
				String paperChartIndicator = StringUtils.trimToEmpty(demoExt.get("paper_chart_archived"));
				String paperChartIndicatorDate = StringUtils.trimToEmpty(demoExt.get("paper_chart_archived_date"));
				String paperChartIndicatorProgram = StringUtils.trimToEmpty(demoExt.get("paper_chart_archived_program"));
			%> <select name="paper_chart_archived"
			id="paper_chart_archived" <%=getDisabled("paper_chart_archived")%>
			onChange="updatePaperArchive()">
				<option value="" <%="".equals(paperChartIndicator) ? " selected" : ""%>>
				</option>
				<option value="NO"
					<%="NO".equals(paperChartIndicator) ? " selected" : ""%>>
					<bean:message
						key="demographic.demographiceditdemographic.paperChartIndicator.no" />
				</option>
				<option value="YES"
					<%="YES".equals(paperChartIndicator) ? " selected" : ""%>>
					<bean:message
						key="demographic.demographiceditdemographic.paperChartIndicator.yes" />
				</option>
		</select>
			<input type="text" name="paper_chart_archived_date" id="paper_chart_archived_date" value="<%=paperChartIndicatorDate%>">
			<img src="../images/cal.gif" id="archive_date_cal">
			<script type="application/javascript">createStandardDatepicker(jQuery_3_1_0('#paper_chart_archived_date'), "archive_date_cal");</script>
			<input type="hidden" name="paper_chart_archived_program" id="paper_chart_archived_program" value="<%=paperChartIndicatorProgram%>" />
		</td>
	</tr>
	<%-- 
						THE "PATIENT JOINED DATE" ROW HAS NOT BEEN ADDED TWICE IN ERROR
						IT IS PLACED HERE FOR REPOSITIONING WHEN THE WAITING LIST
						MODULE IS ACTIVE.
						THIS WAY WILL MAKE EVERYONE HAPPY.
					--%>
	<tr valign="top">
		<td align="right" nowrap><b><bean:message
					key="demographic.demographiceditdemographic.formDateJoined1" />: </b></td>
		<td align="left">
			<% String dateJoined = demographic.getDateJoined() != null ? sdf.format(demographic.getDateJoined()) : null; %> 
			<input type="text" name="date_joined" id="date_joined" size="11" value="<%=dateJoined%>">
			<img src="../images/cal.gif" id="date_joined_cal">
			<script type="application/javascript">createStandardDatepicker(jQuery_3_1_0('#date_joined'), "date_joined_cal");</script>
		</td>
		<td align="right"><b><bean:message
					key="demographic.demographiceditdemographic.formEndDate" />: </b></td>
		<td align="left">
			<% String endDate = demographic.getEndDate() != null ? sdf.format(demographic.getEndDate()) : null; %> 
			<input type="text" name="end_date" id="end_date" size="11" value="<%=endDate%>">
			<img src="../images/cal.gif" id="end_date_cal">
			<script type="application/javascript">createStandardDatepicker(jQuery_3_1_0('#end_date'), "end_date_cal");</script>
		</td>
	</tr>
	<%-- END MOVE PATIENT JOINED DATE --%>


	<%-- TOGGLE PATIENT PRIVACY CONSENT --%>
	<oscar:oscarPropertiesCheck property="privateConsentEnabled"
		value="true">

		<tr valign="top">
			<td colspan="4">
				<table id="privacyConsentTable">
					<tr id="privacyConsentHeading" style="display: none;">
						<th class="alignLeft" colspan="2">Privacy Consent</th>
					</tr>
					<tr valign="top">
						<%
							if (showConsentsThisTime) {
						%>

					<tr>
						<td><input type="hidden" name="usSignedOrig"
							value="<%=StringUtils.defaultString(apptMainBean.getString(demoExt.get("usSigned")))%>" />
							<input type="hidden" name="privacyConsentOrig"
							value="<%=privacyConsent%>" /> <input type="hidden"
							name="informedConsentOrig" value="<%=informedConsent%>" /> <input
							type="checkbox" name="privacyConsent" id="privacyConsent"
							value="yes" <%=privacyConsent.equals("yes") ? "checked" : ""%>>
							<label style="font-weight: bold;" for="privacyConsent">Privacy
								Consent (verbal) Obtained</label></td>
						<td>&nbsp;</td>
					</tr>
					<tr>
						<td colspan="2"><input type="checkbox" name="informedConsent"
							id="informedConsent" value="yes"
							<%=informedConsent.equals("yes") ? "checked" : ""%>> <label
							style="font-weight: bold;" for="informedConsent">Informed
								Consent (verbal) Obtained</label></td>
					</tr>
					<tr>
						<td colspan="2">
							<div id="usSigned">
								<input type="radio" name="usSigned" id="usSigned" value="signed"
									<%=usSigned.equals("signed") ? "checked" : ""%>> <label
									style="font-weight: bold;" for="usSigned">U.S. Resident
									Consent Form Signed </label> <input type="radio" name="usSigned"
									id="usSigned" value="unsigned"
									<%=usSigned.equals("unsigned") ? "checked" : ""%>> <label
									style="font-weight: bold;" for="usSigned">U.S. Resident
									Consent Form NOT Signed</label>
							</div>
						</td>

						<%
							}
						%>
					</tr>
					<%
						String patientEmailConsent = StringUtils.trimToEmpty(demoExt.get("patientEmailConsent"));

						if (oscarProps.getBooleanProperty("patient_email_consent_section", "true"))
						{
					%>
					<tr>
						<td colspan="2">
							<label style="font-weight: bold;" for="patientEmailConsent">Patient Email Consent: </label>
							<select name="patientEmailConsent" id="patientEmailConsent">
								<option></option>
								<option value="Yes" <%="Yes".equals(patientEmailConsent) ? " selected" : ""%>>Yes</option>
								<option value="No" <%="No".equals(patientEmailConsent) ? " selected" : ""%>>No</option>
							</select>
						</td>
					</tr>
					<%
						}
					%>
				</table>
			</td>
		</tr>
	</oscar:oscarPropertiesCheck>

	<%-- END TOGGLE OFF PATIENT PRIVACY CONSENT --%>

	<%-- TOGGLE OFF MEDITECH MODULE --%>
	<%
		if (oscarProps.isPropertyActive("meditech_id")) {
	%>
	<tr>
		<td align="right"><b>Meditech ID: </b></td>
		<td align="left"><input type="text" name="meditech_id" size="30"
			value="<%=OtherIdManager.getDemoOtherId(demographic_no, "meditech_id")%>">
			<input type="hidden" name="meditech_idOrig"
			value="<%=OtherIdManager.getDemoOtherId(demographic_no, "meditech_id")%>">
		</td>
	</tr>
	<%
		}
	%>
	<%-- END TOGGLE OFF MEDITECH MODULE --%>

	<%-- TOGGLE OFF EXTRA DEMO FIELDS (NATIVE HEALTH) --%>
	<%
		if (oscarProps.getProperty("EXTRA_DEMO_FIELDS") != null) {
			String fieldJSP = oscarProps.getProperty("EXTRA_DEMO_FIELDS");
			fieldJSP += ".jsp";
	%>
	<jsp:include page="<%=fieldJSP%>">
		<jsp:param name="demo" value="<%=demographic_no%>" />
	</jsp:include>
	<%
		}
	%>

	<%-- END TOGGLE OFF EXTRA DEMO FIELDS (NATIVE HEALTH) --%>

	<%-- WAITING LIST MODULE --%>
	<oscar:oscarPropertiesCheck property="DEMOGRAPHIC_WAITING_LIST"
		value="true">


		<tr valign="top">
			<td colspan="4">
				<table border="0" cellspacing="0" cellpadding="0" width="100%"
					id="waitingListTable">

					<tr id="waitingListHeading" style="display: none;">
						<th colspan="4" class="alignLeft">Waiting List</th>
					</tr>
					<tr>
						<td align="right" width="16%" nowrap><b> <bean:message
									key="demographic.demographiceditdemographic.msgWaitList" />:
						</b></td>
						<td align="left" width="31%">
							<%
								List<org.oscarehr.common.model.WaitingList> wls = waitingListDao
											.search_wlstatus(Integer.parseInt(demographic_no));

									String wlId = "", listID = "", wlnote = "";
									String wlReferralDate = "";
									if (wls.size() > 0) {
										org.oscarehr.common.model.WaitingList wl = wls.get(0);
										wlId = wl.getId().toString();
										listID = String.valueOf(wl.getListId());
										wlnote = wl.getNote();
										wlReferralDate = oscar.util.ConversionUtils.toDateString(wl.getOnListSince());
										if (wlReferralDate != null && wlReferralDate.length() > 10) {
											wlReferralDate = wlReferralDate.substring(0, 11);
										}
									}
							%> <input type="hidden" name="wlId"
							value="<%=wlId%>"> <select name="list_id">
								<%
									if ("".equals(wLReadonly)) {
								%>
								<option value="0"><bean:message
										key="demographic.demographiceditdemographic.optSelectWaitList" /></option>
								<%
									} else {
								%>
								<option value="0">
									<bean:message
										key="demographic.demographiceditdemographic.optCreateWaitList" /></option>
								<%
									}
								%>
								<%
									List<WaitingListName> waitLists;
										if (OscarProperties.getInstance().getBooleanProperty("show_all_wait_lists", "true")) {
											waitLists = waitingListNameDao.getAllActiveWaitLists();
										} else {
											waitLists = waitingListNameDao
													.findCurrentByGroup(((org.oscarehr.common.model.ProviderPreference) session
															.getAttribute(org.oscarehr.util.SessionConstants.LOGGED_IN_PROVIDER_PREFERENCE))
																	.getMyGroupNo());
										}

										for (WaitingListName wln : waitLists) {
								%>
								<option value="<%=wln.getId()%>"
									<%=wln.getId().toString().equals(listID) ? " selected" : ""%>>
									<%=wln.getName()%></option>
								<%
									}
								%>
						</select>
						</td>
						<td align="right" nowrap><b><bean:message
									key="demographic.demographiceditdemographic.msgWaitListNote" />:
						</b></td>
						<td align="left"><input type="text" name="waiting_list_note"
							value="<%=wlnote%>" size="34" <%=wLReadonly%>></td>
					</tr>
					<tr>
						<td colspan="2">&nbsp;</td>
						<td align="right" nowrap><b><bean:message
									key="demographic.demographiceditdemographic.msgDateOfReq" />: </b></td>
						<td align="left">
							<input type="text" name="waiting_list_referral_date" id="waiting_list_referral_date" size="11" value="<%=wlReferralDate%>" <%=wLReadonly%>>
							<img src="../images/cal.gif" id="waiting_list_referral_date_cal">
							<script type="application/javascript">createStandardDatepicker(jQuery_3_1_0('#waiting_list_referral_date'), "waiting_list_referral_date_cal");</script>
						</td>
					</tr>
				</table>
			</td>
		</tr>
	</oscar:oscarPropertiesCheck>
	<%-- END WAITING LIST MODULE --%>



	<%-- AUTHOR DENNIS WARREN O/A COLCAMEX RESOURCES --%>
	<oscar:oscarPropertiesCheck
		property="DEMOGRAPHIC_PATIENT_HEALTH_CARE_TEAM" value="true">
		<tr>
			<td colspan="4"><jsp:include page="manageHealthCareTeam.jsp">
					<jsp:param name="demographicNo" value="<%=demographic_no%>" />
				</jsp:include></td>
		</tr>
	</oscar:oscarPropertiesCheck>
	<%-- END AUTHOR DENNIS WARREN O/A COLCAMEX RESOURCES --%>

	<%-- TOGGLED OFF PROGRAM ADMISSIONS --%>
	<oscar:oscarPropertiesCheck property="DEMOGRAPHIC_PROGRAM_ADMISSIONS"
		value="true">

		<tr valign="top">
			<td colspan="4">
				<table border="1" width="100%">
					<tr bgcolor="#CCCCFF">
						<td colspan="2">Program Admissions</td>
					</tr>
					<tr>
						<td>Residential Status<font color="red">:</font></td>
						<td>Service Programs</td>
					</tr>
					<tr>
						<td><select id="rsid" name="rps">
								<option value=""></option>
								<%
									GenericIntakeEditAction gieat = new GenericIntakeEditAction();
										gieat.setProgramManager(pm);

										String _pvid = loggedInInfo.getLoggedInProviderNo();
										Set<Program> pset = gieat.getActiveProviderProgramsInFacility(loggedInInfo, _pvid,
												loggedInInfo.getCurrentFacility().getId());
										List<Program> bedP = gieat.getBedPrograms(pset, _pvid);
										List<Program> commP = gieat.getCommunityPrograms();
										Program oscarp = programDao.getProgramByName("OSCAR");

										for (Program _p : bedP) {
								%>
								<option value="<%=_p.getId()%>"
									<%=isProgramSelected(bedAdmission, _p.getId())%>><%=_p.getName()%></option>
								<%
									}
								%>
						</select></td>
						<td>
							<%
								ProgramManager programManager = SpringUtils.getBean(ProgramManager.class);
									List<Program> servP = programManager.getServicePrograms();

									for (Program _p : servP) {
										boolean readOnly = false;
										if (!pset.contains(_p)) {
											readOnly = true;
										}
										String selected = isProgramSelected(serviceAdmissions, _p.getId());

										if (readOnly && selected.length() == 0) {
											continue;
										}
							%> <input type="checkbox" name="sp"
							value="<%=_p.getId()%>" <%=selected%>
							<%=(readOnly) ? " disabled=\"disabled\" " : ""%> /> <%=_p.getName()%>
							<br /> <%
 	}
 %>
						</td>
					</tr>
				</table>
			</td>
		</tr>

	</oscar:oscarPropertiesCheck>
	<%-- END TOGGLE OFF PROGRAM ADMISSIONS --%>

	<% // customized key + "Has Primary Care Physician" & "Employment Status"
		boolean hasHasPrimary = Boolean.parseBoolean(request.getParameter("hasHasPrimary"));
		String hasPrimary = request.getParameter("hasPrimary");
		String hasPrimaryCarePhysician = request.getParameter("hasPrimaryCarePhysician");
		boolean hasEmpStatus = Boolean.parseBoolean(request.getParameter("hasEmpStatus"));
		String empStatus = request.getParameter("empStatus");
		String employmentStatus = request.getParameter("employmentStatus");
		if (hasHasPrimary || hasEmpStatus) {
	%>							<tr valign="top" bgcolor="#CCCCFF">
	<%		if (hasHasPrimary) {
	%>								<td><b><%=hasPrimary.replace(" ", "&nbsp;")%>:</b></td>
	<td>
	<select name="<%=hasPrimary.replace(" ", "")%>">
	<option value="N/A" <%="N/A".equals(hasPrimaryCarePhysician)?"selected":""%>>N/A</option>
	<option value="Yes" <%="Yes".equals(hasPrimaryCarePhysician)?"selected":""%>>Yes</option>
	<option value="No" <%="No".equals(hasPrimaryCarePhysician)?"selected":""%>>No</option>
	</select>
	</td>
	<%		}
		if (hasEmpStatus) {
	%>								<td><b><%=empStatus.replace(" ", "&nbsp;")%>:</b></td>
	<td>
	<select name="<%=empStatus.replace(" ", "")%>">
	<option value="N/A" <%="N/A".equals(employmentStatus)?"selected":""%>>N/A</option>
	<option value="FULL TIME" <%="FULL TIME".equals(employmentStatus)?"selected":""%>>FULL TIME</option>
	<option value="ODSP" <%="ODSP".equals(employmentStatus)?"selected":""%>>ODSP</option>
	<option value="OW" <%="OW".equals(employmentStatus)?"selected":""%>>OW</option>
	<option value="PART TIME" <%="PART TIME".equals(employmentStatus)?"selected":""%>>PART TIME</option>
	<option value="UNEMPLOYED" <%="UNEMPLOYED".equals(employmentStatus)?"selected":""%>>UNEMPLOYED</option>
	</select>
	</td>
	</tr>
	<%		}
	}
		// customized key
		if (oscarVariables.getProperty("demographicExt") != null) {
			boolean bExtForm = oscarVariables.getProperty("demographicExtForm") != null ? true : false;
			String[] propDemoExtForm = bExtForm
					? (oscarVariables.getProperty("demographicExtForm", "").split("\\|")) : null;
			String[] propDemoExt = oscarVariables.getProperty("demographicExt", "").split("\\|");
			for (int k = 0; k < propDemoExt.length; k = k + 2) {
	%>
	<tr valign="top" bgcolor="#CCCCFF">
		<td align="right" nowrap><b><%=propDemoExt[k]%>: </b></td>
		<td align="left">
			<%
				if (bExtForm) {
							if (propDemoExtForm[k].indexOf("<select") >= 0) {
								out.println(propDemoExtForm[k].replaceAll(
										"value=\"" + StringUtils.trimToEmpty(demoExt.get(propDemoExt[k].replace(' ', '_')))
												+ "\"",
										"value=\"" + StringUtils.trimToEmpty(demoExt.get(propDemoExt[k].replace(' ', '_')))
												+ "\"" + " selected"));
							} else {
								out.println(propDemoExtForm[k].replaceAll("value=\"\"", "value=\""
										+ StringUtils.trimToEmpty(demoExt.get(propDemoExt[k].replace(' ', '_'))) + "\""));
							}
						} else {
			%> <input type="text"
			name="<%=propDemoExt[k].replace(' ', '_')%>"
			value="<%=StringUtils.trimToEmpty(demoExt.get(propDemoExt[k].replace(' ', '_')))%>" />
			<%
				}
			%> <input type="hidden"
			name="<%=propDemoExt[k].replace(' ', '_')%>Orig"
			value="<%=StringUtils.trimToEmpty(demoExt.get(propDemoExt[k].replace(' ', '_')))%>" />
		</td>
		<%
			if ((k + 1) < propDemoExt.length) {
		%>
		<td align="right" nowrap><b> <%
 	out.println(propDemoExt[k + 1] + ":");
 %>
		</b></td>
		<td align="left">
			<%
				if (bExtForm) {
								if (propDemoExtForm[k + 1].indexOf("<select") >= 0) {
									out.println(
											propDemoExtForm[k + 1]
													.replaceAll(
															"value=\""
																	+ StringUtils.trimToEmpty(demoExt
																			.get(propDemoExt[k + 1].replace(' ', '_')))
																	+ "\"",
															"value=\""
																	+ StringUtils.trimToEmpty(demoExt
																			.get(propDemoExt[k + 1].replace(' ', '_')))
																	+ "\"" + " selected"));
								} else {
									out.println(propDemoExtForm[k + 1].replaceAll("value=\"\"", "value=\""
											+ StringUtils.trimToEmpty(demoExt.get(propDemoExt[k + 1].replace(' ', '_')))
											+ "\""));
								}
							} else {
			%> <input type="text"
			name="<%=propDemoExt[k + 1].replace(' ', '_')%>"
			value="<%=StringUtils.trimToEmpty(demoExt.get(propDemoExt[k + 1].replace(' ', '_')))%>" />
			<%
				}
			%> <input type="hidden"
			name="<%=propDemoExt[k + 1].replace(' ', '_')%>Orig"
			value="<%=StringUtils.trimToEmpty(demoExt.get(propDemoExt[k + 1].replace(' ', '_')))%>" />
		</td>
		<%
			} else {
		%>
		<td>&nbsp;</td>
		<td>&nbsp;</td>
		<%
			}
		%>
	</tr>
	<%
		}
		}
		if (oscarVariables.getProperty("demographicExtJScript") != null) {
			out.println(oscarVariables.getProperty("demographicExtJScript"));
		}
	%>


	<tr valign="top">
		<td nowrap colspan="4">
			<b><bean:message key="demographic.demographiceditdemographic.rxInteractionWarningLevel" /></b>
			<input type="hidden" name="rxInteractionWarningLevelOrig" value="<%=StringUtils.trimToEmpty(demoExt.get("rxInteractionWarningLevel"))%>" />
			<select id="rxInteractionWarningLevel" name="rxInteractionWarningLevel">
				<option value="0"<%=(warningLevel.equals("0") ? " selected=\"selected\"" : "")%>>Not Specified</option>
				<option value="1"<%=(warningLevel.equals("1") ? " selected=\"selected\"" : "")%>>Low</option>
				<option value="2"<%=(warningLevel.equals("2") ? " selected=\"selected\"" : "")%>>Medium</option>
				<option value="3"<%=(warningLevel.equals("3") ? " selected=\"selected\"" : "")%>>High</option>
				<option value="4"<%=(warningLevel.equals("4") ? " selected=\"selected\"" : "")%>>None</option>
			</select>
			<% if (OscarProperties.getInstance().isPropertyActive("use_fdb")) { %>
			<a id="toggle-interaction-descriptions" href="javascript:void(0);" onclick="toggleInteractionDescriptions();">Show Description</a>
			<div id="interaction-descriptions" style="display: none;">
				SEVERITY LEVEL LOW:  Moderate Interaction: Assess the risk to the patient and
				take action as needed.<br/>
				SEVERITY LEVEL MEDIUM:  Severe Interaction: Action is required to reduce the risk
				of severe adverse interaction.<br/>
				SEVERITY LEVEL HIGH:  Contraindicated Drug Combination: This drug combination
				is contraindicated and generally should not be dispensed or administered to
				the same patient.<br/>
			</div>
			<script>
				function  toggleInteractionDescriptions() {
					var descriptionsDiv = document.getElementById("interaction-descriptions");
					var toggleLink = document.getElementById("toggle-interaction-descriptions");
					if (descriptionsDiv.style.display === 'none') {
						descriptionsDiv.style.display = 'block';
						toggleLink.innerHTML = 'Hide Description';
					} else {
						descriptionsDiv.style.display = 'none';
						toggleLink.innerHTML = 'Show Description';
					}
				}
			</script>
			<% } %>
	<oscar:oscarPropertiesCheck property="INTEGRATOR_LOCAL_STORE"
				value="yes">
				<b><bean:message
						key="demographic.demographiceditdemographic.primaryEMR" />:</b>

				<%
					String primaryEMR = demoExt.get("primaryEMR");
						if (primaryEMR == null)
							primaryEMR = "0";
				%>
				<input type="hidden" name="primaryEMROrig"
					value="<%=StringUtils.trimToEmpty(demoExt.get("primaryEMR"))%>" />
				<select id="primaryEMR" name="primaryEMR">
					<option value="0"
						<%=(primaryEMR.equals("0") ? "selected=\"selected\"" : "")%>>No</option>
					<option value="1"
						<%=(primaryEMR.equals("1") ? "selected=\"selected\"" : "")%>>Yes</option>
				</select>
			</oscar:oscarPropertiesCheck></td>
	</tr>
	<%-- PATIENT NOTES MODULE --%>
	<tr valign="top">
		<td nowrap colspan="4">
			<table width="100%" bgcolor="#EEEEFF" id="demographicPatientNotes">
				<tr id="paitientNotesHeading" style="display: none;">
					<th colspan="2" class="alignLeft">Patient Notes</th>
				</tr>

				<tr>
					<td width="7%" align="right"><font color="#FF0000"><b> Booking Alert: </b></font></td>
					<td>
						<textarea name="bookingAlert" style="width: 100%" cols="80" rows="2" maxlength="200"><%=Encode.forHtmlContent(bookingAlert)%></textarea>
					</td>
				</tr>
				<tr>
					<td width="7%" align="right"><font color="#FF0000"><b> Chart Alert: </b></font></td>
					<td>
						<textarea name="chartAlertText" style="width: 100%" cols="80" rows="2" maxlength="200"><%=Encode.forHtmlContent(chartAlertText)%></textarea>
					</td>
				</tr>
				<tr>
					<td align="right"><b><bean:message
								key="demographic.demographiceditdemographic.formNotes" />: </b></td>
					<td><textarea name="notes" style="width: 100%" cols="60"><%=notes%></textarea>
					</td>
				</tr>
			</table>
		</td>
	</tr>
</table>