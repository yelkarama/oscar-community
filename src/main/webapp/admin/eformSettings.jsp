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
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Arrays" %>
<%@ page import="oscar.dms.EDocUtil" %>
<%@ page import="oscar.eform.EFormUtil" %>
<%@ page import="oscar.OscarProperties" %>
<%@ page import="org.oscarehr.common.model.EForm" %>
<%@ page import="org.oscarehr.common.dao.EFormDao" %>
<%@ page import="java.util.Map" %>

<jsp:useBean id="dataBean" class="java.util.Properties"/>
<%
    SystemPreferencesDao systemPreferencesDao = SpringUtils.getBean(SystemPreferencesDao.class);
    Map<String, SystemPreferences> preferenceMap = systemPreferencesDao.findByKeysAsPreferenceMap(SystemPreferences.EFORM_SETTINGS);
    
    if (request.getParameter("dboperation") != null && !request.getParameter("dboperation").isEmpty() && request.getParameter("dboperation").equals("Save")) {
        for (String key : SystemPreferences.EFORM_SETTINGS) {
            SystemPreferences preference = preferenceMap.get(key);
            
            String newValue = request.getParameter(key);
            
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
            
            // Updates the preference in the preference map
            preferenceMap.put(key, preference);
        }
    }

    List<String> documentTypes = EDocUtil.getActiveDocTypes("demographic");
    EFormDao eFormDao = SpringUtils.getBean(EFormDao.class);
    List<EForm> eforms = eFormDao.findByStatus(true, EFormDao.EFormSortOrder.NAME);
%>

<html:html locale="true">
    <head>
        <title>Manage RTL Templating Settings</title>
        <link href="<%=request.getContextPath() %>/css/bootstrap.css" rel="stylesheet" type="text/css">

        <script type="text/javascript" src="<%= request.getContextPath() %>/js/global.js"></script>
        <script type="text/javascript" src="<%=request.getContextPath() %>/js/jquery-1.7.1.min.js"></script>
        <script type="text/javascript" src="<%=request.getContextPath() %>/js/bootstrap.js"></script>
        <script type="text/javascript" language="JavaScript" src="<%= request.getContextPath() %>/share/javascript/Oscar.js"></script>
    </head>

    <%
        for (SystemPreferences preference : preferenceMap.values()) {
            dataBean.setProperty(preference.getName(), preference.getValue());
        }
    %>

    <body vlink="#0000FF" class="BodyStyle">
    
    <form name="eformSettingsForm" method="post" action="eformSettings.jsp">
        <input type="hidden" name="dboperation" value="">
        <h4>Manage Patient Intake Form Settings</h4>
        <table id="patientIntakeSettingsTable" class="table table-bordered table-striped table-hover table-condensed">
            <tbody>
                <tr>
                    <td>Select the eform to use for patient intake: </td>
                    <td>
                        <select id="patient_intake_eform" name="patient_intake_eform">
                            <option value="">Select an eform</option>
                            <% for(EForm eform : eforms) { %>
                            <option value="<%=eform.getId()%>" <%= dataBean.getProperty("patient_intake_eform", "").equals(eform.getId().toString()) ? "selected=\"selected\"" : ""%>><%=eform.getFormName()%></option>
                            <% } %>
                        </select>
                    </td>
                </tr>
                <tr>
                    <td><label for="patient_intake_letter_eform">Select the eform to use for the intake letter: </label></td>
                    <td>
                        <select id="patient_intake_letter_eform" name="patient_intake_letter_eform">
                            <option value="">Select an eform</option>
                            <% for(EForm eform : eforms) { %>
                            <option value="<%=eform.getId()%>" <%= dataBean.getProperty("patient_intake_letter_eform", "").equals(eform.getId().toString()) ? "selected=\"selected\"" : ""%>><%=eform.getFormName()%></option>
                            <% } %>
                        </select>
                    </td>
                </tr>
            </tbody>
        </table>
        <% if (!OscarProperties.getInstance().getProperty("rtl_template_id", "").isEmpty()) { %>
            <h4>Manage RTL Templating Settings</h4>
            <table id="rtlTemplateSettingsTable" class="table table-bordered table-striped table-hover table-condensed">
                <tbody>
                <tr>
                    <td>Save as document with type: </td>
                    <td>
                        <select id="rtl_template_document_type" name="rtl_template_document_type">
                            <option value="">Select a Type</option>
                            <% for(String type : documentTypes) { %>
                            <option value="<%=type%>" <%= dataBean.getProperty("rtl_template_document_type", "").equals(type) ? "selected=\"selected\"" : ""%>><%=type%></option>
                            <% } %>
                        </select>
                    </td>
                </tr>
                </tbody>
            </table>
        <% } %>
        <input type="button" onclick="document.forms['eformSettingsForm'].dboperation.value='Save'; document.forms['eformSettingsForm'].submit();" name="saveEformSettings" value="Save"/>
    </form>
    </body>
</html:html>