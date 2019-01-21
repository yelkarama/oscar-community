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

<jsp:useBean id="dataBean" class="java.util.Properties"/>
<%
    SystemPreferencesDao systemPreferencesDao = SpringUtils.getBean(SystemPreferencesDao.class);
    String preferenceName = "rtl_template_document_type";
    if (request.getParameter("dboperation") != null && !request.getParameter("dboperation").isEmpty() && request.getParameter("dboperation").equals("Save")) {
        SystemPreferences preference = systemPreferencesDao.findPreferenceByName(preferenceName);
        String newValue = request.getParameter(preferenceName);

        if (preference != null) {
            if (!preference.getValue().equals(newValue)) {
                preference.setUpdateDate(new Date());
                preference.setValue(newValue);
                systemPreferencesDao.merge(preference);
            }
        } else {
            preference = new SystemPreferences();
            preference.setName(preferenceName);
            preference.setUpdateDate(new Date());
            preference.setValue(newValue);
            systemPreferencesDao.persist(preference);
        }
    }

    List<String> documentTypes = EDocUtil.getActiveDocTypes("demographic");
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
        SystemPreferences rtlPreference = systemPreferencesDao.findPreferenceByName(preferenceName);
        String documentType = rtlPreference != null ? rtlPreference.getValue() : "";
    %>

    <body vlink="#0000FF" class="BodyStyle">
    <h4>Manage RTL Templating Settings</h4>
    <form name="rtlTemplateSettingsForm" method="post" action="rtlTemplateSettings.jsp">
        <input type="hidden" name="dboperation" value="">
        <table id="displaySettingsTable" class="table table-bordered table-striped table-hover table-condensed">
            <tbody>
                <tr>
                    <td>Save as document with type: </td>
                    <td>
                        <select id="rtl_template_document_type" name="rtl_template_document_type">
                            <option value="">Select a Type</option>
                            <% for(String type : documentTypes) { %>
                            <option value="<%=type%>" <%= documentType.equals(type) ? "selected=\"selected\"" : ""%>><%=type%></option>
                            <% } %>
                        </select>
                    </td>
                </tr>
            </tbody>
        </table>
        <input type="button" onclick="document.forms['rtlTemplateSettingsForm'].dboperation.value='Save'; document.forms['rtlTemplateSettingsForm'].submit();" name="saveRtlTemplateSettings" value="Save"/>
    </form>
    </body>
</html:html>