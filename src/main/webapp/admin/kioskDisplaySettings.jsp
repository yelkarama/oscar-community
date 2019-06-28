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
<jsp:useBean id="dataBean" class="java.util.Properties"/>
<%
    SystemPreferencesDao systemPreferencesDao = SpringUtils.getBean(SystemPreferencesDao.class);
    String key = SystemPreferences.KIOSK_DISPLAY_PREFERENCE_KEYS;
    SystemPreferences preference = systemPreferencesDao.findPreferenceByName(key);
    if (request.getParameter("dboperation") != null && !request.getParameter("dboperation").isEmpty() && request.getParameter("dboperation").equals("Save")) {
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
    }
%>

<html:html locale="true">
    <head>
        <title>Mandatory Fields - Master File</title>
<script src="<%=request.getContextPath()%>/JavaScriptServlet" type="text/javascript"></script>
        <link href="<%=request.getContextPath() %>/css/bootstrap.css" rel="stylesheet" type="text/css">

        <script type="text/javascript" src="<%= request.getContextPath() %>/js/global.js"></script>
        <script type="text/javascript" src="<%=request.getContextPath() %>/js/jquery-1.7.1.min.js"></script>
        <script type="text/javascript" src="<%=request.getContextPath() %>/js/bootstrap.js"></script>
        <script type="text/javascript" language="JavaScript" src="<%= request.getContextPath() %>/share/javascript/Oscar.js"></script>
    </head>

    <%
        if(preference != null && preference.getValue() != null) {
            dataBean.setProperty(preference.getName(), preference.getValue());
        }
    %>

    <body vlink="#0000FF" class="BodyStyle">
    <h4>Manage Kiosk Display Settings</h4>
    <form name="kioskDisplaySettingsForm" method="post" action="kioskDisplaySettings.jsp">
        <input type="hidden" name="dboperation" value="">
        <table id="displaySettingsTable" class="table table-bordered table-striped table-hover table-condensed">
            <tbody>
            <tr>
                <td>Allow Check-In For All Appointments: </td>
                <td>
                    <input id="check_in_all_appointments-true" type="radio" value="true" name="check_in_all_appointments"
                            <%=(dataBean.getProperty("check_in_all_appointments", "false").equals("true")) ? "checked" : ""%> />
                    Yes
                    &nbsp;&nbsp;&nbsp;
                    <input id="code_show_hide_column-false" type="radio" value="false" name="check_in_all_appointments"
                            <%=(dataBean.getProperty("check_in_all_appointments", "false").equals("false")) ? "checked" : ""%> />
                    No
                    &nbsp;&nbsp;&nbsp;
                </td>
            </tr>
            </tbody>
        </table>

        <input type="button" onclick="document.forms['kioskDisplaySettingsForm'].dboperation.value='Save'; document.forms['kioskDisplaySettingsForm'].submit();" name="saveKioskDisplaySettings" value="Save"/>
    </form>
    </body>
</html:html>