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
<%@ page import="java.util.Map" %>
<jsp:useBean id="dataBean" class="java.util.Properties"/>
<%
    SystemPreferencesDao systemPreferencesDao = SpringUtils.getBean(SystemPreferencesDao.class);
    Map<String, SystemPreferences> preferenceMap = systemPreferencesDao.findByKeysAsPreferenceMap(SystemPreferences.DOCUMENT_SETTINGS_KEYS);
    
    if (request.getParameter("dboperation") != null && !request.getParameter("dboperation").isEmpty() && request.getParameter("dboperation").equals("Save")) {
        for (String key : SystemPreferences.DOCUMENT_SETTINGS_KEYS) {
            SystemPreferences preference = preferenceMap.get(key);
            
            String newValue = request.getParameter(key);
            if ((newValue != null && (newValue.equals("true") || newValue.equals("false"))) ||
                    (key.equals("inbox_use_fax_dropdown") && newValue == null)) {
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
    }
%>

<html:html locale="true">
    <head>
        <title>Document Settings</title>
<script src="<%=request.getContextPath()%>/JavaScriptServlet" type="text/javascript"></script>
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
    <h4>Manage Document Settings</h4>
    <form name="documentSettingsForm" method="post" action="documentSettings.jsp">
        <input type="hidden" name="dboperation" value="">
        <table id="displaySettingsTable" class="table table-bordered table-striped table-hover table-condensed">
            <tbody>
            <tr>
                <td>Autocomplete Document Descriptions: </td>
                <td>
                    <input id="document_description_typeahead-true" type="radio" value="true" name="document_description_typeahead"
                            <%=(dataBean.getProperty("document_description_typeahead", "false").equals("true")) ? "checked" : ""%> />
                    Yes
                    &nbsp;&nbsp;&nbsp;
                    <input id="document_description_typeahead-false" type="radio" value="false" name="document_description_typeahead"
                            <%=(dataBean.getProperty("document_description_typeahead", "false").equals("false")) ? "checked" : ""%> />
                    No
                    &nbsp;&nbsp;&nbsp;
                </td>
            </tr>
            <tr>
                <td>Use dropdown for document faxing in the inbox: </td>
                <td>
                    <input id="inbox_use_fax_dropdown" type="checkbox" value="true" name="inbox_use_fax_dropdown"
                            <%=(dataBean.getProperty("inbox_use_fax_dropdown", "false").equals("true")) ? "checked='checked'" : ""%> />
                </td>
            </tr>
            </tbody>
        </table>

        <input type="button" onclick="document.forms['documentSettingsForm'].dboperation.value='Save'; document.forms['documentSettingsForm'].submit();" name="saveDocumentSettings" value="Save"/>
    </form>
    </body>
</html:html>