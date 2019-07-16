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
<%-- This JSP is the first page you see when you enter 'report by template' --%>
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
<%@ page import="org.oscarehr.util.LoggedInInfo" %>
<%@ page import="org.oscarehr.common.model.Provider" %>
<%@ page import="org.oscarehr.common.dao.RxManageDao" %>
<%@ page import="org.oscarehr.common.model.RxManage" %>
<%@ page import="org.oscarehr.common.dao.SystemPreferencesDao" %>
<%@ page import="org.oscarehr.common.model.SystemPreferences" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.util.List" %>

<jsp:useBean id="dataBean" class="java.util.Properties" scope="page" />
<%
    LoggedInInfo loggedInInfo=LoggedInInfo.getLoggedInInfoFromSession(request);
    Provider provider = loggedInInfo.getLoggedInProvider();

    RxManageDao rxManageDao = SpringUtils.getBean(RxManageDao.class);
    SystemPreferencesDao systemPreferencesDao = SpringUtils.getBean(SystemPreferencesDao.class);
    
    if (request.getParameter("dboperation") != null && !request.getParameter("dboperation").isEmpty() && request.getParameter("dboperation").equals("Save")) {
        RxManage rxManage = rxManageDao.getRxManageAttributes();
        
        if (rxManage!=null)
        {
            rxManage.setMrpOnRx(Boolean.parseBoolean(request.getParameter("mrpPresc")));
            rxManageDao.merge(rxManage);
        }
        else
        {
            rxManage = new RxManage();
            rxManage.setMrpOnRx(Boolean.parseBoolean(request.getParameter("mrpPresc")));
            rxManageDao.persist(rxManage);
        }

        for(String key : SystemPreferences.RX_PREFERENCE_KEYS) {
            SystemPreferences preference = systemPreferencesDao.findPreferenceByName(key);
            String newValue = request.getParameter(key);

            if (newValue == null || newValue.equals("true") || newValue.equals("false")) {
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
    }
    
%>
<html:html locale="true">
    <head>
        <title>Manage Rx</title>
<script src="<%=request.getContextPath()%>/JavaScriptServlet" type="text/javascript"></script>
        <link href="<%=request.getContextPath() %>/css/bootstrap.css" rel="stylesheet" type="text/css">

        <script type="text/javascript" src="<%= request.getContextPath() %>/js/global.js"></script>
        <script type="text/javascript" src="<%=request.getContextPath() %>/js/jquery-1.7.1.min.js"></script>
        <script type="text/javascript" src="<%=request.getContextPath() %>/js/bootstrap.js"></script>
        <script type="text/javascript" language="JavaScript" src="<%= request.getContextPath() %>/share/javascript/Oscar.js"></script>
    </head>
    
    <%
        RxManage rxManage = rxManageDao.getRxManageAttributes();
        if (rxManage!=null)
        {
            dataBean.setProperty("mrpOnRx", String.valueOf(rxManage.getMrpOnRx())); 
        }

        List<SystemPreferences> preferences = systemPreferencesDao.findPreferencesByNames(SystemPreferences.RX_PREFERENCE_KEYS);
        for(SystemPreferences preference : preferences) {
            if (preference.getValue() != null) {
                dataBean.setProperty(preference.getName(), preference.getValue());
            }
        }
    %>

    <body vlink="#0000FF" class="BodyStyle">
    <h4>Rx Settings</h4>
    <form name="rx-settings" method="post" action="manageRx.jsp">
        <input type="hidden" name="dboperation" value="">
        <table id="manageRxTable" name="manageRxTable" class="table table-bordered table-striped table-hover table-condensed">
            <tbody>
            <tr>
                <td>Add MRP to Prescriptions: </td>
                <td>
                <input type="radio" value="true" name="mrpPresc"<%=(rxManage!=null ? (dataBean.getProperty("mrpOnRx").equals("true")? "checked" : "") : "")%>/> Yes
                    &nbsp;&nbsp;&nbsp;
                <input type="radio" value="false" name="mrpPresc"<%=(rxManage!=null ? (dataBean.getProperty("mrpOnRx").equals("false")? "checked" : "") : "")%>/> No
                    &nbsp;&nbsp;&nbsp;
                </td>
            </tr>
            <tr>
                <td>Display provider name when pasting Rx to echart: </td>
                <td>
                    <input type="radio" value="true" name="rx_paste_provider_to_echart" <%= (dataBean.getProperty("rx_paste_provider_to_echart", "false").equals("true") ? "checked" : "") %> /> Yes
                    &nbsp;&nbsp;&nbsp;
                    <input type="radio" value="false" name="rx_paste_provider_to_echart" <%= (dataBean.getProperty("rx_paste_provider_to_echart", "false").equals("false") ? "checked" : "") %> /> No
                    &nbsp;&nbsp;&nbsp;
                </td>
            </tr>
            <tr>
                <td>Display start date on prescriptions: </td>
                <td>
                    <label style="display: inline">
                        <input type="radio" value="true" name="rx_show_start_dates" <%= (dataBean.getProperty("rx_show_start_dates", "false").equals("true") ? "checked" : "") %> /> Yes
                    </label>
                    &nbsp;&nbsp;&nbsp;
                    <label style="display: inline">
                        <input type="radio" value="false" name="rx_show_start_dates" <%= (dataBean.getProperty("rx_show_start_dates", "false").equals("false") ? "checked" : "") %> /> No
                    </label>
                </td>
            </tr>
			<tr>
				<td>Show end date of drugs on prescriptions: </td>
				<td>
					<label style="display: inline">
						<input type="radio" value="true" name="rx_show_end_dates" <%= (dataBean.getProperty("rx_show_end_dates", "false").equals("true") ? "checked" : "") %> /> Yes
					</label>
					&nbsp;&nbsp;&nbsp;
					<label style="display: inline">
						<input type="radio" value="false" name="rx_show_end_dates" <%= (dataBean.getProperty("rx_show_end_dates", "false").equals("false") ? "checked" : "") %> /> No
					</label>
				</td>
			</tr>
            <tr>
                <td>Display refill duration on prescriptions: </td>
                <td>
                    <label style="display: inline">
                        <input type="radio" value="true" name="rx_show_refill_duration" <%= (dataBean.getProperty("rx_show_refill_duration", "false").equals("true") ? "checked" : "") %> /> Yes
                    </label>
                    &nbsp;&nbsp;&nbsp;
                    <label style="display: inline">
                        <input type="radio" value="false" name="rx_show_refill_duration" <%= (dataBean.getProperty("rx_show_refill_duration", "false").equals("false") ? "checked" : "") %> /> No
                    </label>
                </td>
            </tr>
            <tr>
                <td>Display refill quantity on prescriptions: </td>
                <td>
                    <label style="display: inline">
                        <input type="radio" value="true" name="rx_show_refill_quantity" <%= (dataBean.getProperty("rx_show_refill_quantity", "false").equals("true") ? "checked" : "") %> /> Yes
                    </label>
                    &nbsp;&nbsp;&nbsp;
                    <label style="display: inline">
                        <input type="radio" value="false" name="rx_show_refill_quantity" <%= (dataBean.getProperty("rx_show_refill_quantity", "false").equals("false") ? "checked" : "") %> /> No
                    </label>
                </td>
            </tr>
            <tr>
                <td>Display Methadone End Date Calculation Option:</td>
                <td>
                    <label style="display: inline">
                        <input type="checkbox" value="true" name="rx_methadone_end_date_calc" <%= (dataBean.getProperty("rx_methadone_end_date_calc", "false").equals("true") ? "checked" : "") %> /> 
                    </label>
                </td>
            </tr>
            <tr>
                <td>Save Rx Signature:</td>
                <td>
                    <label style="display: inline">
                        <input type="checkbox" value="true" name="save_rx_signature" <%= (dataBean.getProperty("save_rx_signature", "true").equals("true") ? "checked" : "") %> />
                    </label>
                </td>
            </tr>
            </tbody>
        </table>

        <input type="button" onclick="document.forms['rx-settings'].dboperation.value='Save'; document.forms['rx-settings'].submit();" name="mrpPrescButton" value="Save"/>
    </form>
    </body>
</html:html>
