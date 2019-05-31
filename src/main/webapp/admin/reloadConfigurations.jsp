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

<jsp:useBean id="dataBean" class="java.util.Properties"/>

<html:html locale="true">
<head>
    <title>General Settings</title>
    <link href="<%=request.getContextPath() %>/css/bootstrap.css" rel="stylesheet" type="text/css">

    <script type="text/javascript" src="<%= request.getContextPath() %>/js/global.js"></script>
    <script type="text/javascript" src="<%=request.getContextPath() %>/js/jquery-3.1.0.min.js"></script>
    <script type="text/javascript" src="<%=request.getContextPath() %>/js/bootstrap.js"></script>
    <script type="text/javascript" language="JavaScript" src="<%= request.getContextPath() %>/share/javascript/Oscar.js"></script>
    
    <style type="text/css">
        body {
            display: flex;
            flex-flow: column;
        }

        h3 {
            text-align: center;
            color: #3e3e3e;
        }
        
        .form-row {
            display: flex;
            flex-flow: row;
        }
        
        .action-group {
            width: 25%;
            display: flex;
            flex-flow: column;
        }
        
        .action-group button, 
        .action-group label {
            display: block;
            width: 75%;
            margin: 0 auto;
        }
        
        button {
            height: 3rem;
            background: #53B848;
            border: 1px solid rgb(37, 145, 69);
            color: #ffffff;
            border-radius: 4px;
            font-weight: 500;
        }
        
        button:hover {
            background: rgb(37, 145, 69);
        }
        
        .action-group label {
            margin-top: .5rem;
            cursor: text;
            text-align: center;
        }
        
        label.error {
            color: red;
        }
    </style>
</head>

<body vlink="#0000FF" class="BodyStyle">
    <h3>Reload OSCAR Configurations</h3>
    <div class="form-row">
        <div class="action-group">
            <button onclick="reloadData('reloadProperties')">Reload OSCAR Properties</button>
            <label id="reloadPropertiesMessage"></label>
        </div>
        <div class="action-group">
            <button onclick="reloadData('reloadApConfig')">Reload AP Config</button>
            <label id="reloadApConfigMessage"></label>
        </div>
        <div class="action-group">
            <button onclick="reloadData('reloadPreventions')">Reload Prevention Items XML</button>
            <label id="reloadPreventionsMessage"></label>
        </div>
        <div class="action-group">
            <button onclick="reloadData('reloadPreventionDrl')">Reload Prevention Drools/Rule Base</button>
            <label id="reloadPreventionDrlMessage"></label>
        </div>
    </div>

    
    
    <script type="text/javascript">
        function reloadData(method) {
            let url = "<%=request.getContextPath()%>/admin/ReloadData.do?method=" + method;
            jQuery.post(url)
                .done(function() {
                    updateMessage(method, true);
                })
                .fail(function(data) {
                    updateMessage(method, false);
                });
        }
        
        function updateMessage(method, success) {
            let label = document.getElementById(method + 'Message');
            if (success) {
                label.innerText = "The file has been successfully reloaded";
            } else {
                label.innerText = "An error occurred while reloading the file";
                label.classList.add("error");
            }
        }
    </script>
    </body>
</html:html>