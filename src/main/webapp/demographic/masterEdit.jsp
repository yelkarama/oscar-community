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
<%@ page import="org.apache.commons.lang.StringUtils"%><html:html locale="true">
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
	String alert = request.getParameter("alert");
	String notes = request.getParameter("notes");

	int demographicNoAsInt = Integer.parseInt(demographic_no);
	int nStrShowLen = 20;

    WebApplicationContext ctx = WebApplicationContextUtils.getRequiredWebApplicationContext(getServletContext());
    CountryCodeDao ccDAO =  (CountryCodeDao) ctx.getBean("countryCodeDao");
    UserPropertyDAO pref = (UserPropertyDAO) ctx.getBean("UserPropertyDAO");                       
    List<CountryCode> countryList = ccDAO.getAllCountryCodes();
	
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
 	Admission bedAdmission = admissionManager.getCurrentBedProgramAdmission(demographic.getDemographicNo());
 	List<Admission> serviceAdmissions = admissionManager.getCurrentServiceProgramAdmission(demographic.getDemographicNo());
	ProgramDao programDao = (ProgramDao)SpringUtils.getBean("programDao");
	List<Provider> providers = providerDao.getActiveProviders();
	List<Provider> doctors = providerDao.getActiveProvidersByRole("doctor");
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
    ProvinceNames pNames = ProvinceNames.getInstance();
	Map<String,String> demoExt = demographicExtDao.getAllValuesForDemo(Integer.parseInt(demographic_no));
	List<DemographicGroupLink> demographicGroupsForPatient = demographicGroupLinkDao.findByDemographicNo(demographicNoAsInt);

    PatientTypeDao patientTypeDao = (PatientTypeDao) SpringUtils.getBean("patientTypeDao");
    List<PatientType> patientTypes = patientTypeDao.findAllPatientTypes();
	List<DemographicGroup> demographicGroups = demographicGroupDao.getAll();
	
	GregorianCalendar dateCal = new GregorianCalendar();
	
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
	style="display: none;">
	<tr>
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
		<td align="right"><b><bean:message
					key="demographic.demographiceditdemographic.msgDemoTitle" />: </b></td>
		<td align="left">
			<%
						String title = demographic.getTitle();
						if(title == null) {
							title="";
						}
					%> <select name="title" <%=getDisabled("title")%>>
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
		<td colspan="2">&nbsp;</td>
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
				<% } else { %>
				<option value="AB" <%="AB".equals(province)?" selected":""%>>AB-Alberta</option>
				<option value="BC" <%="BC".equals(province)?" selected":""%>>BC-British
					Columbia</option>
				<option value="MB" <%="MB".equals(province)?" selected":""%>>MB-Manitoba</option>
				<option value="NB" <%="NB".equals(province)?" selected":""%>>NB-New
					Brunswick</option>
				<option value="NL" <%="NL".equals(province)?" selected":""%>>NL-Newfoundland
					Labrador</option>
				<option value="NT" <%="NT".equals(province)?" selected":""%>>NT-Northwest
					Territory</option>
				<option value="NS" <%="NS".equals(province)?" selected":""%>>NS-Nova
					Scotia</option>
				<option value="NU" <%="NU".equals(province)?" selected":""%>>NU-Nunavut</option>
				<option value="ON" <%="ON".equals(province)?" selected":""%>>ON-Ontario</option>
				<option value="PE" <%="PE".equals(province)?" selected":""%>>PE-Prince
					Edward Island</option>
				<option value="QC" <%="QC".equals(province)?" selected":""%>>QC-Quebec</option>
				<option value="SK" <%="SK".equals(province)?" selected":""%>>SK-Saskatchewan</option>
				<option value="YT" <%="YT".equals(province)?" selected":""%>>YT-Yukon</option>
				<option value="US" <%="US".equals(province)?" selected":""%>>US
					resident</option>
				<option value="US-AK" <%="US-AK".equals(province)?" selected":""%>>US-AK-Alaska</option>
				<option value="US-AL" <%="US-AL".equals(province)?" selected":""%>>US-AL-Alabama</option>
				<option value="US-AR" <%="US-AR".equals(province)?" selected":""%>>US-AR-Arkansas</option>
				<option value="US-AZ" <%="US-AZ".equals(province)?" selected":""%>>US-AZ-Arizona</option>
				<option value="US-CA" <%="US-CA".equals(province)?" selected":""%>>US-CA-California</option>
				<option value="US-CO" <%="US-CO".equals(province)?" selected":""%>>US-CO-Colorado</option>
				<option value="US-CT" <%="US-CT".equals(province)?" selected":""%>>US-CT-Connecticut</option>
				<option value="US-CZ" <%="US-CZ".equals(province)?" selected":""%>>US-CZ-Canal
					Zone</option>
				<option value="US-DC" <%="US-DC".equals(province)?" selected":""%>>US-DC-District
					Of Columbia</option>
				<option value="US-DE" <%="US-DE".equals(province)?" selected":""%>>US-DE-Delaware</option>
				<option value="US-FL" <%="US-FL".equals(province)?" selected":""%>>US-FL-Florida</option>
				<option value="US-GA" <%="US-GA".equals(province)?" selected":""%>>US-GA-Georgia</option>
				<option value="US-GU" <%="US-GU".equals(province)?" selected":""%>>US-GU-Guam</option>
				<option value="US-HI" <%="US-HI".equals(province)?" selected":""%>>US-HI-Hawaii</option>
				<option value="US-IA" <%="US-IA".equals(province)?" selected":""%>>US-IA-Iowa</option>
				<option value="US-ID" <%="US-ID".equals(province)?" selected":""%>>US-ID-Idaho</option>
				<option value="US-IL" <%="US-IL".equals(province)?" selected":""%>>US-IL-Illinois</option>
				<option value="US-IN" <%="US-IN".equals(province)?" selected":""%>>US-IN-Indiana</option>
				<option value="US-KS" <%="US-KS".equals(province)?" selected":""%>>US-KS-Kansas</option>
				<option value="US-KY" <%="US-KY".equals(province)?" selected":""%>>US-KY-Kentucky</option>
				<option value="US-LA" <%="US-LA".equals(province)?" selected":""%>>US-LA-Louisiana</option>
				<option value="US-MA" <%="US-MA".equals(province)?" selected":""%>>US-MA-Massachusetts</option>
				<option value="US-MD" <%="US-MD".equals(province)?" selected":""%>>US-MD-Maryland</option>
				<option value="US-ME" <%="US-ME".equals(province)?" selected":""%>>US-ME-Maine</option>
				<option value="US-MI" <%="US-MI".equals(province)?" selected":""%>>US-MI-Michigan</option>
				<option value="US-MN" <%="US-MN".equals(province)?" selected":""%>>US-MN-Minnesota</option>
				<option value="US-MO" <%="US-MO".equals(province)?" selected":""%>>US-MO-Missouri</option>
				<option value="US-MS" <%="US-MS".equals(province)?" selected":""%>>US-MS-Mississippi</option>
				<option value="US-MT" <%="US-MT".equals(province)?" selected":""%>>US-MT-Montana</option>
				<option value="US-NC" <%="US-NC".equals(province)?" selected":""%>>US-NC-North
					Carolina</option>
				<option value="US-ND" <%="US-ND".equals(province)?" selected":""%>>US-ND-North
					Dakota</option>
				<option value="US-NE" <%="US-NE".equals(province)?" selected":""%>>US-NE-Nebraska</option>
				<option value="US-NH" <%="US-NH".equals(province)?" selected":""%>>US-NH-New
					Hampshire</option>
				<option value="US-NJ" <%="US-NJ".equals(province)?" selected":""%>>US-NJ-New
					Jersey</option>
				<option value="US-NM" <%="US-NM".equals(province)?" selected":""%>>US-NM-New
					Mexico</option>
				<option value="US-NU" <%="US-NU".equals(province)?" selected":""%>>US-NU-Nunavut</option>
				<option value="US-NV" <%="US-NV".equals(province)?" selected":""%>>US-NV-Nevada</option>
				<option value="US-NY" <%="US-NY".equals(province)?" selected":""%>>US-NY-New
					York</option>
				<option value="US-OH" <%="US-OH".equals(province)?" selected":""%>>US-OH-Ohio</option>
				<option value="US-OK" <%="US-OK".equals(province)?" selected":""%>>US-OK-Oklahoma</option>
				<option value="US-OR" <%="US-OR".equals(province)?" selected":""%>>US-OR-Oregon</option>
				<option value="US-PA" <%="US-PA".equals(province)?" selected":""%>>US-PA-Pennsylvania</option>
				<option value="US-PR" <%="US-PR".equals(province)?" selected":""%>>US-PR-Puerto
					Rico</option>
				<option value="US-RI" <%="US-RI".equals(province)?" selected":""%>>US-RI-Rhode
					Island</option>
				<option value="US-SC" <%="US-SC".equals(province)?" selected":""%>>US-SC-South
					Carolina</option>
				<option value="US-SD" <%="US-SD".equals(province)?" selected":""%>>US-SD-South
					Dakota</option>
				<option value="US-TN" <%="US-TN".equals(province)?" selected":""%>>US-TN-Tennessee</option>
				<option value="US-TX" <%="US-TX".equals(province)?" selected":""%>>US-TX-Texas</option>
				<option value="US-UT" <%="US-UT".equals(province)?" selected":""%>>US-UT-Utah</option>
				<option value="US-VA" <%="US-VA".equals(province)?" selected":""%>>US-VA-Virginia</option>
				<option value="US-VI" <%="US-VI".equals(province)?" selected":""%>>US-VI-Virgin
					Islands</option>
				<option value="US-VT" <%="US-VT".equals(province)?" selected":""%>>US-VT-Vermont</option>
				<option value="US-WA" <%="US-WA".equals(province)?" selected":""%>>US-WA-Washington</option>
				<option value="US-WI" <%="US-WI".equals(province)?" selected":""%>>US-WI-Wisconsin</option>
				<option value="US-WV" <%="US-WV".equals(province)?" selected":""%>>US-WV-West
					Virginia</option>
				<option value="US-WY" <%="US-WY".equals(province)?" selected":""%>>US-WY-Wyoming</option>
				<% } %>
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
		<td align="right"><b><bean:message
					key="demographic.demographiceditdemographic.formPhoneH" />: </b></td>
		<td align="left"><input type="text" name="phone"
			onblur="formatPhoneNum();" <%=getDisabled("phone")%>
			style="display: inline; width: auto;"
			value="<%=StringUtils.trimToEmpty(StringUtils.trimToEmpty(demographic.getPhone()))%>">
			<bean:message key="demographic.demographiceditdemographic.msgExt" />:<input
			type="text" name="hPhoneExt" <%=getDisabled("hPhoneExt")%>
			value="<%=StringUtils.trimToEmpty(StringUtils.trimToEmpty(demoExt.get("hPhoneExt")))%>"
			size="4" /> <input type="hidden" name="hPhoneExtOrig"
			value="<%=StringUtils.trimToEmpty(StringUtils.trimToEmpty(demoExt.get("hPhoneExt")))%>" />
		</td>
		<td align="right"><b><bean:message
					key="demographic.demographiceditdemographic.formPhoneW" />:</b></td>
		<td align="left"><input type="text" name="phone2"
			<%=getDisabled("phone2")%> onblur="formatPhoneNum();"
			style="display: inline; width: auto;"
			value="<%=StringUtils.trimToEmpty(demographic.getPhone2())%>">
			<bean:message key="demographic.demographiceditdemographic.msgExt" />:<input
			type="text" name="wPhoneExt" <%=getDisabled("wPhoneExt")%>
			value="<%=StringUtils.trimToEmpty(StringUtils.trimToEmpty(demoExt.get("wPhoneExt")))%>"
			style="display: inline" size="4" /> <input type="hidden"
			name="wPhoneExtOrig"
			value="<%=StringUtils.trimToEmpty(StringUtils.trimToEmpty(demoExt.get("wPhoneExt")))%>" />
		</td>
	</tr>
	<tr valign="top">
		<td align="right"><b><bean:message
					key="demographic.demographiceditdemographic.formPhoneC" />: </b></td>
		<td align="left"><input type="text" name="demo_cell"
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
		<td align="left"><input type="text" name="email" size="30"
			<%=getDisabled("email")%>
			value="<%=demographic.getEmail()!=null? demographic.getEmail() : ""%>">
		</td>
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
			onBlur="upCaseCtrl(this)"></td>
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
				<% } else { %>
				<option value="AB" <%=hctype.equals("AB")?" selected":""%>>AB-Alberta</option>
				<option value="BC" <%=hctype.equals("BC")?" selected":""%>>BC-British
					Columbia</option>
				<option value="MB" <%=hctype.equals("MB")?" selected":""%>>MB-Manitoba</option>
				<option value="NB" <%=hctype.equals("NB")?" selected":""%>>NB-New
					Brunswick</option>
				<option value="NL" <%=hctype.equals("NL")?" selected":""%>>NL-Newfoundland
					& Labrador</option>
				<option value="NT" <%=hctype.equals("NT")?" selected":""%>>NT-Northwest
					Territory</option>
				<option value="NS" <%=hctype.equals("NS")?" selected":""%>>NS-Nova
					Scotia</option>
				<option value="NU" <%=hctype.equals("NU")?" selected":""%>>NU-Nunavut</option>
				<option value="ON" <%=hctype.equals("ON")?" selected":""%>>ON-Ontario</option>
				<option value="PE" <%=hctype.equals("PE")?" selected":""%>>PE-Prince
					Edward Island</option>
				<option value="QC" <%=hctype.equals("QC")?" selected":""%>>QC-Quebec</option>
				<option value="SK" <%=hctype.equals("SK")?" selected":""%>>SK-Saskatchewan</option>
				<option value="YT" <%=hctype.equals("YT")?" selected":""%>>YT-Yukon</option>
				<option value="US" <%=hctype.equals("US")?" selected":""%>>US
					resident</option>
				<option value="US-AK" <%=hctype.equals("US-AK")?" selected":""%>>US-AK-Alaska</option>
				<option value="US-AL" <%=hctype.equals("US-AL")?" selected":""%>>US-AL-Alabama</option>
				<option value="US-AR" <%=hctype.equals("US-AR")?" selected":""%>>US-AR-Arkansas</option>
				<option value="US-AZ" <%=hctype.equals("US-AZ")?" selected":""%>>US-AZ-Arizona</option>
				<option value="US-CA" <%=hctype.equals("US-CA")?" selected":""%>>US-CA-California</option>
				<option value="US-CO" <%=hctype.equals("US-CO")?" selected":""%>>US-CO-Colorado</option>
				<option value="US-CT" <%=hctype.equals("US-CT")?" selected":""%>>US-CT-Connecticut</option>
				<option value="US-CZ" <%=hctype.equals("US-CZ")?" selected":""%>>US-CZ-Canal
					Zone</option>
				<option value="US-DC" <%=hctype.equals("US-DC")?" selected":""%>>US-DC-District
					Of Columbia</option>
				<option value="US-DE" <%=hctype.equals("US-DE")?" selected":""%>>US-DE-Delaware</option>
				<option value="US-FL" <%=hctype.equals("US-FL")?" selected":""%>>US-FL-Florida</option>
				<option value="US-GA" <%=hctype.equals("US-GA")?" selected":""%>>US-GA-Georgia</option>
				<option value="US-GU" <%=hctype.equals("US-GU")?" selected":""%>>US-GU-Guam</option>
				<option value="US-HI" <%=hctype.equals("US-HI")?" selected":""%>>US-HI-Hawaii</option>
				<option value="US-IA" <%=hctype.equals("US-IA")?" selected":""%>>US-IA-Iowa</option>
				<option value="US-ID" <%=hctype.equals("US-ID")?" selected":""%>>US-ID-Idaho</option>
				<option value="US-IL" <%=hctype.equals("US-IL")?" selected":""%>>US-IL-Illinois</option>
				<option value="US-IN" <%=hctype.equals("US-IN")?" selected":""%>>US-IN-Indiana</option>
				<option value="US-KS" <%=hctype.equals("US-KS")?" selected":""%>>US-KS-Kansas</option>
				<option value="US-KY" <%=hctype.equals("US-KY")?" selected":""%>>US-KY-Kentucky</option>
				<option value="US-LA" <%=hctype.equals("US-LA")?" selected":""%>>US-LA-Louisiana</option>
				<option value="US-MA" <%=hctype.equals("US-MA")?" selected":""%>>US-MA-Massachusetts</option>
				<option value="US-MD" <%=hctype.equals("US-MD")?" selected":""%>>US-MD-Maryland</option>
				<option value="US-ME" <%=hctype.equals("US-ME")?" selected":""%>>US-ME-Maine</option>
				<option value="US-MI" <%=hctype.equals("US-MI")?" selected":""%>>US-MI-Michigan</option>
				<option value="US-MN" <%=hctype.equals("US-MN")?" selected":""%>>US-MN-Minnesota</option>
				<option value="US-MO" <%=hctype.equals("US-MO")?" selected":""%>>US-MO-Missouri</option>
				<option value="US-MS" <%=hctype.equals("US-MS")?" selected":""%>>US-MS-Mississippi</option>
				<option value="US-MT" <%=hctype.equals("US-MT")?" selected":""%>>US-MT-Montana</option>
				<option value="US-NC" <%=hctype.equals("US-NC")?" selected":""%>>US-NC-North
					Carolina</option>
				<option value="US-ND" <%=hctype.equals("US-ND")?" selected":""%>>US-ND-North
					Dakota</option>
				<option value="US-NE" <%=hctype.equals("US-NE")?" selected":""%>>US-NE-Nebraska</option>
				<option value="US-NH" <%=hctype.equals("US-NH")?" selected":""%>>US-NH-New
					Hampshire</option>
				<option value="US-NJ" <%=hctype.equals("US-NJ")?" selected":""%>>US-NJ-New
					Jersey</option>
				<option value="US-NM" <%=hctype.equals("US-NM")?" selected":""%>>US-NM-New
					Mexico</option>
				<option value="US-NU" <%=hctype.equals("US-NU")?" selected":""%>>US-NU-Nunavut</option>
				<option value="US-NV" <%=hctype.equals("US-NV")?" selected":""%>>US-NV-Nevada</option>
				<option value="US-NY" <%=hctype.equals("US-NY")?" selected":""%>>US-NY-New
					York</option>
				<option value="US-OH" <%=hctype.equals("US-OH")?" selected":""%>>US-OH-Ohio</option>
				<option value="US-OK" <%=hctype.equals("US-OK")?" selected":""%>>US-OK-Oklahoma</option>
				<option value="US-OR" <%=hctype.equals("US-OR")?" selected":""%>>US-OR-Oregon</option>
				<option value="US-PA" <%=hctype.equals("US-PA")?" selected":""%>>US-PA-Pennsylvania</option>
				<option value="US-PR" <%=hctype.equals("US-PR")?" selected":""%>>US-PR-Puerto
					Rico</option>
				<option value="US-RI" <%=hctype.equals("US-RI")?" selected":""%>>US-RI-Rhode
					Island</option>
				<option value="US-SC" <%=hctype.equals("US-SC")?" selected":""%>>US-SC-South
					Carolina</option>
				<option value="US-SD" <%=hctype.equals("US-SD")?" selected":""%>>US-SD-South
					Dakota</option>
				<option value="US-TN" <%=hctype.equals("US-TN")?" selected":""%>>US-TN-Tennessee</option>
				<option value="US-TX" <%=hctype.equals("US-TX")?" selected":""%>>US-TX-Texas</option>
				<option value="US-UT" <%=hctype.equals("US-UT")?" selected":""%>>US-UT-Utah</option>
				<option value="US-VA" <%=hctype.equals("US-VA")?" selected":""%>>US-VA-Virginia</option>
				<option value="US-VI" <%=hctype.equals("US-VI")?" selected":""%>>US-VI-Virgin
					Islands</option>
				<option value="US-VT" <%=hctype.equals("US-VT")?" selected":""%>>US-VT-Vermont</option>
				<option value="US-WA" <%=hctype.equals("US-WA")?" selected":""%>>US-WA-Washington</option>
				<option value="US-WI" <%=hctype.equals("US-WI")?" selected":""%>>US-WI-Wisconsin</option>
				<option value="US-WV" <%=hctype.equals("US-WV")?" selected":""%>>US-WV-West
					Virginia</option>
				<option value="US-WY" <%=hctype.equals("US-WY")?" selected":""%>>US-WY-Wyoming</option>
				<% } %>
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
			<td align="left"><select name="provider_no"
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

	</oscar:oscarPropertiesCheck>
	<%-- END TOGGLE OFF PATIENT CLINIC STATUS --%>

	<%-- TOGGLE OFF PATIENT ROSTERING - NOT USED IN ALL PROVINCES. --%>
	<oscar:oscarPropertiesCheck property="DEMOGRAPHIC_PATIENT_ROSTERING"
		value="true">

		<jsp:include page="./familyPhysicianModule.jsp">
			<jsp:param name="family_doc" value="<%=family_doc%>" />
		</jsp:include>
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
					<option value="RO" <%="RO".equals(rosterStatus) ? " selected" : ""%>>
						<bean:message key="demographic.demographiceditdemographic.optRostered" />
					</option>
					<option value="NR" <%=rosterStatus.equals("NR") ? " selected" : ""%>>
						<bean:message key="demographic.demographiceditdemographic.optNotRostered" />
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

				String patientStatusDate = "";
				if (demographic.getPatientStatusDate() != null) {
					patientStatusDate = demographic.getPatientStatusDate().toString();
				}
			%>

			<td align="right" nowrap><b><bean:message
						key="demographic.demographiceditdemographic.DateJoined" />: </b></td>
			<td align="left">
				<input type="text" name="roster_date" id="roster_date" size="11" value="<%=rosterDate%>">
				<img src="../images/cal.gif" id="roster_date_cal">
				<script type="application/javascript">createStandardDatepicker(jQuery_3_1_0('#roster_date'), "roster_date_cal");</script>
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
            patientStatus.value = d.getFullYear() + "-" + d.getMonth() + 1 + "-" + d.getDate();
        }
	}
	else if (patientOrRoster == "roster"){
		var selectedRosterStatus = document.getElementById("roster_status").value;
		var rosterStatusDate = document.getElementById("roster_date");

		if(rosterStatusDate.value == "" ){
		    if (selectedRosterStatus == "RO" || selectedRosterStatus == "NR" || selectedRosterStatus == "UHIP"){
				rosterStatusDate.value = d.getFullYear() + "-" + d.getMonth() + 1 + "-" + d.getDate();
			}
		}
	}
}
</script>

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

	<%
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
		<td nowrap colspan="4"><b><bean:message
					key="demographic.demographiceditdemographic.rxInteractionWarningLevel" /></b>
			<input type="hidden" name="rxInteractionWarningLevelOrig"
			value="<%=StringUtils.trimToEmpty(demoExt.get("rxInteractionWarningLevel"))%>" />
			<select id="rxInteractionWarningLevel"
			name="rxInteractionWarningLevel">
				<option value="0"
					<%=(warningLevel.equals("0") ? "selected=\"selected\"" : "")%>>Not
					Specified</option>
				<option value="1"
					<%=(warningLevel.equals("1") ? "selected=\"selected\"" : "")%>>Low</option>
				<option value="2"
					<%=(warningLevel.equals("2") ? "selected=\"selected\"" : "")%>>Medium</option>
				<option value="3"
					<%=(warningLevel.equals("3") ? "selected=\"selected\"" : "")%>>High</option>
				<option value="4"
					<%=(warningLevel.equals("4") ? "selected=\"selected\"" : "")%>>None</option>
		</select> <oscar:oscarPropertiesCheck property="INTEGRATOR_LOCAL_STORE"
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
					<td width="7%" align="right"><font color="#FF0000"><b><bean:message
									key="demographic.demographiceditdemographic.formAlert" />: </b></font></td>
					<td><textarea name="alert" style="width: 100%" cols="80"
							rows="2"><%=alert%></textarea></td>
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