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

<jsp:useBean id="dataBean" class="java.util.Properties" scope="page" />
<%
    LoggedInInfo loggedInInfo=LoggedInInfo.getLoggedInInfoFromSession(request);
    Provider provider = loggedInInfo.getLoggedInProvider();

    RxManageDao rxManageDao = SpringUtils.getBean(RxManageDao.class);
    
    if (request.getParameter("dboperation")!=null && !request.getParameter("dboperation").isEmpty())
    {
        if (request.getParameter("dboperation").equals("Save"))
        {
            RxManage rxManage = rxManageDao.findByProviderNo(provider.getProviderNo());
            
            if (rxManage!=null)
            {
                rxManage.setProviderNo(provider.getProviderNo());
                rxManage.setMrpOnRx(Boolean.parseBoolean(request.getParameter("mrpPresc")));
                rxManageDao.merge(rxManage);
            }
            else
            {
                rxManage = new RxManage();
                rxManage.setProviderNo(provider.getProviderNo());
                rxManage.setMrpOnRx(Boolean.parseBoolean(request.getParameter("mrpPresc")));
                rxManageDao.persist(rxManage); 
            }
        } 
    }
    
%>
<html:html locale="true">
    <head>
        <title>Manage Rx</title>
        <link href="<%=request.getContextPath() %>/css/bootstrap.css" rel="stylesheet" type="text/css">

        <script type="text/javascript" src="<%= request.getContextPath() %>/js/global.js"></script>
        <script type="text/javascript" src="<%=request.getContextPath() %>/js/jquery-1.7.1.min.js"></script>
        <script type="text/javascript" src="<%=request.getContextPath() %>/js/bootstrap.js"></script>
        <script type="text/javascript" language="JavaScript" src="<%= request.getContextPath() %>/share/javascript/Oscar.js"></script>
    </head>
    
    <%
        RxManage rxManage = rxManageDao.findByProviderNo(provider.getProviderNo());
        if (rxManage!=null)
        {
            dataBean.setProperty("rxProvider", rxManage.getProviderNo()==null?provider.getProviderNo():rxManage.getProviderNo());
            dataBean.setProperty("mrpOnRx", String.valueOf(rxManage.getMrpOnRx())); 
        }
    %>

    <body vlink="#0000FF" class="BodyStyle">
    <h4>Manage Job Types</h4>
    <form name="mrpPrescriptionForm" method="post" action="manageRx.jsp">
        <input type="hidden" name="dboperation" value="">
    <table id="manageRxTable" name="manageRxTable" class="table table-bordered table-striped table-hover table-condensed">
        <tbody>
        <tr>
            <td>Add MRP to Prescriptions: </td>
            <td>
            <input type="radio" value="true" name="mrpPresc"<%=(rxManage!=null ? (dataBean.getProperty("mrpOnRx").equals("true")? "checked" : "") : "")%>/>Yes
                &nbsp;&nbsp;&nbsp;
            <input type="radio" value="false" name="mrpPresc"<%=(rxManage!=null ? (dataBean.getProperty("mrpOnRx").equals("false")? "checked" : "") : "")%>/>No
                &nbsp;&nbsp;&nbsp;
            <input type="button" onclick="document.forms['mrpPrescriptionForm'].dboperation.value='Save'; document.forms['mrpPrescriptionForm'].submit();" name="mrpPrescButton" value="Save"/>     
            </td>
        </tr>
        </tbody>
    </table>
    </form>
    </body>
</html:html>
