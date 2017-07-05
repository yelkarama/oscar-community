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

<%@page 
	import="oscar.OscarProperties"%>
<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean"%>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html"%>
<%@ taglib uri="/WEB-INF/struts-logic.tld" prefix="logic"%>

<%
    String errormsg = request.getParameter("errormsg");
%>

<html:html locale="true">
<head>
<script type="text/javascript" src="<%= request.getContextPath() %>/js/global.js"></script>
<html:base />
<title>Login Failure</title>
</head>
<body style="font-family: Helvetica, Arial">
<h4><%=errormsg%></h4>
<h4>KAI Tips:</h4>
<ul>
    <li>Should it be after-hours, note that the account will automatically unlock after 15 minutes for you to try again.</li>
    <li>If another user with admin-rights in your clinic is currently logged in, they can click "Administration>User Management>Unlock Account" in order to unlock this for you immediately.</li>
    <li>If you have forgotten your password all together, please email KAI Support: <a href="mailto:support@kaiinnovations.com">support@kaiinnovations.com</a> to have it reset.</li>
</ul>
</body>
</html:html>
