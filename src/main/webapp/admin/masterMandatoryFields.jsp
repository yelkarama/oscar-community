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

    if (request.getParameter("dboperation")!=null && !request.getParameter("dboperation").isEmpty())
    {
        if (request.getParameter("dboperation").equals("Save")) {
            SystemPreferences systemPreference = systemPreferencesDao.findPreferenceByName("referring_physician_mandatory");

            String refPhys = request.getParameter("refPhysicianMandatory");

            if (refPhys != null && (refPhys.equals("true") || refPhys.equals("false"))) {
                if (systemPreference != null) {
                    systemPreference.setUpdateDate(new Date());
                    systemPreference.setValue(request.getParameter("refPhysicianMandatory"));
                    systemPreferencesDao.merge(systemPreference);
                } else {
                    systemPreference = new SystemPreferences();
                    systemPreference.setName("referring_physician_mandatory");
                    systemPreference.setUpdateDate(new Date());
                    systemPreference.setValue(request.getParameter("refPhysicianMandatory"));
                    systemPreferencesDao.persist(systemPreference);
                }
            }
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
        SystemPreferences systemPreferences = systemPreferencesDao.findPreferenceByName("referring_physician_mandatory");
        if (systemPreferences!=null)
        {
            dataBean.setProperty("refPhysicianMandatory", systemPreferences.getValue());
        }
    %>

    <body vlink="#0000FF" class="BodyStyle">
    <h4>Manage Mandatory Fields on the Master File</h4>
    <form name="mandatoryFieldsForm" method="post" action="masterMandatoryFields.jsp">
        <input type="hidden" name="dboperation" value="">
        <table id="mandatoryFieldsTable" class="table table-bordered table-striped table-hover table-condensed">
            <tbody>
            <tr>
                <td>Make Referring Physician Mandatory: </td>
                <td>
                    <input type="radio" value="true" name="refPhysicianMandatory"<%=(systemPreferences!=null ? (dataBean.getProperty("refPhysicianMandatory").equals("true")? "checked" : "") : "")%>/>Yes
                    &nbsp;&nbsp;&nbsp;
                    <input type="radio" value="false" name="refPhysicianMandatory"<%=(systemPreferences!=null ? (dataBean.getProperty("refPhysicianMandatory").equals("false")? "checked" : "") : "")%>/>No
                    &nbsp;&nbsp;&nbsp;
                    <input type="button" onclick="document.forms['mandatoryFieldsForm'].dboperation.value='Save'; document.forms['mandatoryFieldsForm'].submit();" name="refPhysicianMandatoryButton" value="Save"/>
                </td>
            </tr>
            </tbody>
        </table>
    </form>
    </body>
</html:html>
