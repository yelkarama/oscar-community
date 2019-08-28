<%--
  Created by IntelliJ IDEA.
  User: David Bond
  Date: 2017-12-04
  Time: 11:19 AM
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8"%>
<%@ taglib uri="/WEB-INF/oscar-tag.tld" prefix="oscar"%>
<%@ taglib uri="/WEB-INF/security.tld" prefix="security"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib prefix="html" uri="http://struts.apache.org/tags-html" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />

<%@page import="org.oscarehr.util.SpringUtils" %>
<%@ page import="org.oscarehr.common.model.SystemPreferences" %>
<%@ page import="org.oscarehr.common.dao.SystemPreferencesDao" %>
<%@ page import="java.util.Date" %>

<jsp:useBean id="dataBean" class="java.util.Properties" />

<%
    String roleName$ = session.getAttribute("userrole") + "," + session.getAttribute("user");
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
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<%

    boolean saveSuccess = false;
    SystemPreferencesDao systemPreferencesDao = SpringUtils.getBean(SystemPreferencesDao.class);

    if (request.getParameter("dboperation")!=null && !request.getParameter("dboperation").isEmpty())
    {
        if (request.getParameter("dboperation").equals("Save"))
        {
            SystemPreferences systemPreferences = systemPreferencesDao.findPreferenceByName("inboxDateSearchType");

            if (systemPreferences!=null)
            {
                systemPreferences.setValue(request.getParameter("inboxDateSearchType"));
                systemPreferencesDao.merge(systemPreferences);
                saveSuccess = true;
            }
            else
            {
                systemPreferences = new SystemPreferences();
                systemPreferences.setName("inboxDateSearchType");
                systemPreferences.setValue(request.getParameter("inboxDateSearchType"));
                systemPreferences.setUpdateDate(new Date());
                systemPreferencesDao.persist(systemPreferences);
                saveSuccess = true;
            }
        }
    }
%>

<html:html locale="true">
<head>
    <title>Change Inbox Date Search</title>
<script src="<%=request.getContextPath()%>/JavaScriptServlet" type="text/javascript"></script>
    <link href="<%=request.getContextPath() %>/css/bootstrap.css" rel="stylesheet" type="text/css">

    <script type="text/javascript" src="<%= request.getContextPath() %>/js/global.js"></script>
    <script type="text/javascript" src="<%=request.getContextPath() %>/js/jquery-1.7.1.min.js"></script>
    <script type="text/javascript" src="<%=request.getContextPath() %>/js/bootstrap.js"></script>
    <script type="text/javascript" language="JavaScript" src="<%= request.getContextPath() %>/share/javascript/Oscar.js"></script>

    <%
        SystemPreferences systemPreferences = systemPreferencesDao.findPreferenceByName("inboxDateSearchType");

        if (systemPreferences!=null)
        {
            dataBean.setProperty("inboxDateSearchType", systemPreferences.getValue()==null?"serviceObservation":systemPreferences.getValue());
        }
    %>
</head>
<body>
<h3>Change Inbox Date Search</h3>

<div class="well">
    <h4>Search by:</h4>
    <form name="inboxDateSearchForm" method="post" action="changeInboxDateSearch.jsp">
        <input type="hidden" name="dboperation" value=""/>
        <select name="inboxDateSearchType">
            <option value="serviceObservation" <%=(systemPreferences!=null ? (dataBean.getProperty("inboxDateSearchType").equals("serviceObservation")? "selected" : "") : "")%>>Service/Observation</option>
            <option value="receivedCreated" <%=(systemPreferences!=null ? (dataBean.getProperty("inboxDateSearchType").equals("receivedCreated")? "selected" : "") : "")%>>Received/Created</option>
        </select>
        <input type="submit" class="btn btn-primary" value="Update" onclick="document.forms['inboxDateSearchForm'].dboperation.value='Save'; document.forms['inboxDateSearchForm'].submit();">
    </form>
</div>

<%
    if (saveSuccess)
    {
%>
        <div class="alert alert-success">
            <strong>Preference successfully saved!</strong>
        </div>
<%
    }
%>
</body>
</html:html>
