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
<%@ taglib uri="/WEB-INF/security.tld" prefix="security"%>
<%
    String roleName$ = (String)session.getAttribute("userrole") + "," + (String) session.getAttribute("user");
    boolean authed=true;
%>
<security:oscarSec roleName="<%=roleName$%>" objectName="_admin" rights="r" reverse="<%=true%>">
    <%authed=false; %>
    <%response.sendRedirect("../securityError.jsp?type=_admin");%>
</security:oscarSec>
<%
    if(!authed) {
        return;
    }
%>

<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean"%>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html"%>
<%@ taglib uri="/WEB-INF/struts-logic.tld" prefix="logic"%>
<%@ page import="org.oscarehr.util.SpringUtils" %>
<%@ page import="org.oscarehr.common.dao.SystemPreferencesDao" %>
<%@ page import="org.oscarehr.common.model.SystemPreferences" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.util.List" %>
<%@ page import="oscar.oscarClinic.ClinicData" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.StringTokenizer" %>
<%@ page import="org.owasp.encoder.Encode" %>
<%@ page import="oscar.OscarProperties" %>
<%@ page import="oscar.util.StringUtils" %>

<jsp:useBean id="dataBean" class="java.util.Properties"/>
<%
    SystemPreferencesDao systemPreferencesDao = SpringUtils.getBean(SystemPreferencesDao.class);
    OscarProperties oscarProps = OscarProperties.getInstance();

    ClinicData clinicData = new ClinicData();

    String strPhones = clinicData.getClinicDelimPhone();
    if (strPhones == null) {
        strPhones = "";
    }
    String strFaxes = clinicData.getClinicDelimFax();
    if (strFaxes == null) {
        strFaxes = "";
    }
    List<String> lPhones = new ArrayList<String>();
   	List<String> lFaxes = new ArrayList<String>();
    StringTokenizer st = new StringTokenizer(strPhones, "|");
    while (st.hasMoreTokens()) {
        lPhones.add(st.nextToken());
    }
    st = new StringTokenizer(strFaxes, "|");
    while (st.hasMoreTokens()) {
        lFaxes.add(st.nextToken());
    }
    
    String defaultClinicInfo = clinicData.getClinicName() + 
            "\n" + clinicData.getClinicAddress() + ", " + clinicData.getClinicCity() + ", " + clinicData.getClinicProvince() + " " + clinicData.getClinicPostal() + 
            "\nTelephone: " + (lPhones.size() >= 1 ? lPhones.get(0) : clinicData.getClinicPhone()) + 
            "\nFax: " + (lFaxes.size() >= 1 ? lFaxes.get(0) : clinicData.getClinicFax());

	String errorMessages = "";


    if (request.getParameter("dboperation") != null && !request.getParameter("dboperation").isEmpty() && request.getParameter("dboperation").equals("Save")) {
        for(String key : SystemPreferences.GENERAL_SETTINGS_KEYS) {
            SystemPreferences preference = systemPreferencesDao.findPreferenceByName(key);
            String newValue = request.getParameter(key);
            //If use custom wasn't checked, set to null so that the default gets used instead.
            if("invoice_custom_clinic_info".equals(key) && !"on".equals(request.getParameter("invoice_use_custom_clinic_info"))){
                newValue = null;
            } else if ("force_logout_when_inactive_time".equals(key)) {
                if (!StringUtils.isInteger(request.getParameter("force_logout_when_inactive_time"))) {
                    errorMessages += "<span style=\"color: red;\">Logout inactive time not updated: selected value is not a whole number</span>";
                    continue;
                } else if (Integer.parseInt(request.getParameter("force_logout_when_inactive_time")) <= 0) {
                    errorMessages += "<span style=\"color: red;\">Logout inactive time not updated: Value cannot be 0</span>";
                    continue;
                }
            }

            if (preference != null) {
                if (!preference.getValue().equals(newValue)) {
                    preference.setUpdateDate(new Date());
                    preference.setValue(newValue);
                    systemPreferencesDao.merge(preference);
                }
            } else {
                preference = new SystemPreferences();
                preference.setName(key);
                preference.setUpdateDate(new Date());
                preference.setValue(newValue);
                systemPreferencesDao.persist(preference);
            }
        }
    }
    List<SystemPreferences> preferences = systemPreferencesDao.findPreferencesByNames(SystemPreferences.GENERAL_SETTINGS_KEYS);
    for(SystemPreferences preference : preferences) {
        dataBean.setProperty(preference.getName(), preference.getValue());
    }
    
    boolean forceLogoutWhenInactive = dataBean.getProperty("force_logout_when_inactive", "false").equals("true");
    String forceLogoutTime = dataBean.getProperty("force_logout_when_inactive_time", "120");

%>

<html:html locale="true">
    <head>
        <title>General Settings</title>
<script src="<%=request.getContextPath()%>/JavaScriptServlet" type="text/javascript"></script>
        <link href="<%=request.getContextPath() %>/css/bootstrap.css" rel="stylesheet" type="text/css">

        <script type="text/javascript" src="<%= request.getContextPath() %>/js/global.js"></script>
        <script type="text/javascript" src="<%=request.getContextPath() %>/js/jquery-1.7.1.min.js"></script>
        <script type="text/javascript" src="<%=request.getContextPath() %>/js/bootstrap.js"></script>
        <script type="text/javascript" language="JavaScript" src="<%= request.getContextPath() %>/share/javascript/Oscar.js"></script>
        <script type="text/javascript" language="JavaScript">
            var defaultClinicInvoiceInfo = '<%=Encode.forJavaScript(defaultClinicInfo)%>';
            function setClinicInfo(){
                var useCustom = document.getElementById('invoice_use_custom_clinic_info');
                var clinicInfo = document.getElementById('invoice_custom_clinic_info');
                if(useCustom === null || !useCustom.checked){
                    clinicInfo.value = defaultClinicInvoiceInfo;
                    clinicInfo.disabled = true;
                } else {
                    clinicInfo.disabled = false;
                }
            }
            
        </script>
    </head>

    <body vlink="#0000FF" class="BodyStyle">
    <h4>Manage General OSCAR Settings</h4>
    <form name="generalSettingsForm" method="post" action="generalSettings.jsp">
        <%=errorMessages%>
        <input type="hidden" name="dboperation" value="">
        <table id="displaySettingsTable" class="table table-bordered table-striped table-hover table-condensed">
            <tbody>
             <tr>
                <td>Activate Eyeform: </td>
                <td>
                    <input id="new_eyeform_enabled-true" type="radio" value="true" name="new_eyeform_enabled"
                            <%=(dataBean.getProperty("new_eyeform_enabled", "false").equals("true")) ? "checked" : ""%> />
                    Yes
                    &nbsp;&nbsp;&nbsp;
                    <input id="new_eyeform_enabled-false" type="radio" value="false" name="new_eyeform_enabled"
                            <%=(dataBean.getProperty("new_eyeform_enabled", "false").equals("false")) ? "checked" : ""%> />
                    No
                    &nbsp;&nbsp;&nbsp;
                </td>
            </tr>
            <tr>
                <td>Appointment Show Full Name: </td>
                <td>
                    <input id="appt_show_full_name-true" type="radio" value="true" name="appt_show_full_name"
                            <%=(dataBean.getProperty("appt_show_full_name", "false").equals("true")) ? "checked" : ""%> />
                    Yes
                    &nbsp;&nbsp;&nbsp;
                    <input id="appt_show_full_name-false" type="radio" value="false" name="appt_show_full_name"
                            <%=(dataBean.getProperty("appt_show_full_name", "false").equals("false")) ? "checked" : ""%> />
                    No
                    &nbsp;&nbsp;&nbsp;
                </td>
            </tr>            
            <tr>
                <td>Appointment Show Reason: </td>
                <td>
                    <input id="show_appt_reason-true" type="radio" value="true" name="show_appt_reason"
                            <%=(dataBean.getProperty("show_appt_reason", "false").equals("true")) ? "checked" : ""%> />
                    Yes
                    &nbsp;&nbsp;&nbsp;
                    <input id="show_appt_reason-false" type="radio" value="false" name="show_appt_reason"
                            <%=(dataBean.getProperty("show_appt_reason", "false").equals("false")) ? "checked" : ""%> />
                    No
                    &nbsp;&nbsp;&nbsp;
                </td>
            </tr>            
            <tr>
                <td>Show Non Scheduled Days in Week View: </td>
                <td>
                    <input id="show_NonScheduledDays_In_WeekView-true" type="radio" value="true" name="show_NonScheduledDays_In_WeekView"
                            <%=(dataBean.getProperty("show_NonScheduledDays_In_WeekView", "false").equals("true")) ? "checked" : ""%> />
                    Yes
                    &nbsp;&nbsp;&nbsp;
                    <input id="show_NonScheduledDays_In_WeekView-false" type="radio" value="false" name="show_NonScheduledDays_In_WeekView"
                            <%=(dataBean.getProperty("show_NonScheduledDays_In_WeekView", "false").equals("false")) ? "checked" : ""%> />
                    No
                    &nbsp;&nbsp;&nbsp;
                </td>
            </tr>            
            <tr>
                <td>Receptionist Alternate View: </td>
                <td>
                    <input id="receptionist_alt_view-true" type="radio" value="true" name="receptionist_alt_view"
                            <%=(dataBean.getProperty("receptionist_alt_view", "false").equals("true")) ? "checked" : ""%> />
                    Yes
                    &nbsp;&nbsp;&nbsp;
                    <input id="receptionist_alt_view-false" type="radio" value="false" name="receptionist_alt_view"
                            <%=(dataBean.getProperty("receptionist_alt_view", "false").equals("false")) ? "checked" : ""%> />
                    No
                    &nbsp;&nbsp;&nbsp;
                </td>
            </tr>            
            <tr>
                <td>Show Appointment Type With Reason: </td>
                <td>
                    <input id="show_appt_type_with_reason-true" type="radio" value="true" name="show_appt_type_with_reason"
                            <%=(dataBean.getProperty("show_appt_type_with_reason", "false").equals("true")) ? "checked" : ""%> />
                    Yes
                    &nbsp;&nbsp;&nbsp;
                    <input id="show_appt_type_with_reason-false" type="radio" value="false" name="show_appt_type_with_reason"
                            <%=(dataBean.getProperty("show_appt_type_with_reason", "false").equals("false")) ? "checked" : ""%> />
                    No
                    &nbsp;&nbsp;&nbsp;
                </td>
            </tr>            
            <tr>
                <td>appt_show_short_letters: </td>
                <td>
                    <input id="appt_show_short_letters-true" type="radio" value="true" name="appt_show_short_letters"
                            <%=(dataBean.getProperty("appt_show_short_letters", "false").equals("true")) ? "checked" : ""%> />
                    Yes
                    &nbsp;&nbsp;&nbsp;
                    <input id="appt_show_short_letters-false" type="radio" value="false" name="appt_show_short_letters"
                            <%=(dataBean.getProperty("appt_show_short_letters", "false").equals("false")) ? "checked" : ""%> />
                    No
                    &nbsp;&nbsp;&nbsp;
                </td>
            </tr>
            <tr>
                <td>Display Alerts on Schedule: </td>
                <td>
                    <input id="displayAlertsOnScheduleScreen-true" type="radio" value="true" name="displayAlertsOnScheduleScreen"
                            <%=(dataBean.getProperty("show_appt_type_with_reason", "false").equals("true")) ? "checked" : ""%> />
                    Yes
                    &nbsp;&nbsp;&nbsp;
                    <input id="displayAlertsOnScheduleScreen-false" type="radio" value="false" name="displayAlertsOnScheduleScreen"
                            <%=(dataBean.getProperty("show_appt_type_with_reason", "false").equals("false")) ? "checked" : ""%> />
                    No
                    &nbsp;&nbsp;&nbsp;
                </td>
            </tr>            
            <tr>
                <td>Display Notes on Schedule: </td>
                <td>
                    <input id="displayNotesOnScheduleScreen-true" type="radio" value="true" name="displayNotesOnScheduleScreen"
                            <%=(dataBean.getProperty("displayNotesOnScheduleScreen", "false").equals("true")) ? "checked" : ""%> />
                    Yes
                    &nbsp;&nbsp;&nbsp;
                    <input id="displayNotesOnScheduleScreen-false" type="radio" value="false" name="displayNotesOnScheduleScreen"
                            <%=(dataBean.getProperty("displayNotesOnScheduleScreen", "false").equals("false")) ? "checked" : ""%> />
                    No
                    &nbsp;&nbsp;&nbsp;
                </td>
            </tr>                      
            <tr>
                <td>Display Quick Date Selector with Fixed Intervals: </td>
                <td>
                    <input id="display_quick_date_picker-true" type="radio" value="true" name="display_quick_date_picker"
                            <%=(dataBean.getProperty("display_quick_date_picker", "false").equals("true")) ? "checked" : ""%> />
                    Yes
                    &nbsp;&nbsp;&nbsp;
                    <input id="display_quick_date_picker-false" type="radio" value="false" name="display_quick_date_picker"
                            <%=(dataBean.getProperty("display_quick_date_picker", "false").equals("false")) ? "checked" : ""%> />
                    No
                    &nbsp;&nbsp;&nbsp;
                </td>
            </tr>  
            <tr>
                <td>Display Quick Date Selector with Multiplier: </td>
                <td>
                    <input id="display_quick_date_multiplier-true" type="radio" value="true" name="display_quick_date_multiplier"
                            <%=(dataBean.getProperty("display_quick_date_multiplier", "false").equals("true")) ? "checked" : ""%> />
                    Yes
                    &nbsp;&nbsp;&nbsp;
                    <input id="display_quick_date_multiplier-false" type="radio" value="false" name="display_quick_date_multiplier"
                            <%=(dataBean.getProperty("display_quick_date_multiplier", "false").equals("false")) ? "checked" : ""%> />
                    No
                    &nbsp;&nbsp;&nbsp;
                </td>
            </tr>                                               
            <tr>
                <td>Display preferred name instead of demographic name: </td>
                <td>
                    <input id="replace_demographic_name_with_preferred-true" type="radio" value="true" name="replace_demographic_name_with_preferred"
                            <%=(dataBean.getProperty("replace_demographic_name_with_preferred", "false").equals("true")) ? "checked" : ""%> />
                    Yes
                    &nbsp;&nbsp;&nbsp;
                    <input id="replace_demographic_name_with_preferred-false" type="radio" value="false" name="replace_demographic_name_with_preferred"
                            <%=(dataBean.getProperty("replace_demographic_name_with_preferred", "false").equals("false")) ? "checked" : ""%> />
                    No
                    &nbsp;&nbsp;&nbsp;
                </td>
            </tr>
            <tr>
                <td>Use create date instead of next appointment date on messages: </td>
                <td>
                    <input id="msg_use_create_date" type="checkbox" value="true" name="msg_use_create_date"
                            <%=(dataBean.getProperty("msg_use_create_date", "false").equals("true")) ? "checked" : ""%> />
                </td>
            </tr>
            <tr>
                <td>Force logout on inactive users: </td>
                <td>
                    <input id="force_logout_when_inactive_true" type="radio" value="true" name="force_logout_when_inactive"
                            <%=forceLogoutWhenInactive ? "checked" : ""%> />
                    Yes
                    &nbsp;&nbsp;&nbsp;
                    <input id="force_logout_when_inactive_false" type="radio" value="false" name="force_logout_when_inactive"
                            <%=!forceLogoutWhenInactive ? "checked" : ""%> />
                    No
                    <br/>Logout after
                    <input id="force_logout_when_inactive_time" type="text" value="<%=forceLogoutTime%>" name="force_logout_when_inactive_time"/> minutes
                </td>
            </tr>
            <% if(oscarProps.getProperty("billregion", "").equals("BC")){ %>
            <tr>
                <td>Set clinic information to display on invoice: </td>
                <td width="327px">
                    <input type="checkbox" id="invoice_use_custom_clinic_info" name="invoice_use_custom_clinic_info" onclick="setClinicInfo()" <%= StringUtils.isNullOrEmpty(dataBean.getProperty("invoice_custom_clinic_info")) ? "" : "checked"%>/>Use Custom
                    <br>
                    <textarea style="resize: none; width: 90%" rows="4" id="invoice_custom_clinic_info" name="invoice_custom_clinic_info" maxlength="250" <%=StringUtils.isNullOrEmpty(dataBean.getProperty("invoice_custom_clinic_info")) ? "disabled" : ""%>><%= Encode.forHtmlAttribute(StringUtils.isNullOrEmpty(dataBean.getProperty("invoice_custom_clinic_info")) ? defaultClinicInfo : dataBean.getProperty("invoice_custom_clinic_info"))%></textarea>
                </td>
            </tr>
            <% } %>
            </tbody>
        </table>

        <input type="button" onclick="document.forms['generalSettingsForm'].dboperation.value='Save'; document.forms['generalSettingsForm'].submit();" name="saveGeneralSettings" value="Save"/>
    </form>
    </body>
</html:html>