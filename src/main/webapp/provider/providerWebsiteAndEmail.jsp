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

<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean"%>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html"%>
<%@ page import="org.oscarehr.common.dao.UserPropertyDAO"%>
<%@ page import="org.oscarehr.common.model.UserProperty"%>
<%@ page import="org.oscarehr.util.SpringUtils"%>

<%
  if(session.getValue("user") == null) response.sendRedirect("../logout.htm");
  String curUser_no = (String) session.getAttribute("user");
%>
<html:html locale="true">
<head>
<script type="text/javascript" src="<%= request.getContextPath() %>/js/global.js"></script>

<script type="text/javascript">
	
	function validate() {
		var msg = "<bean:message key="provider.editRxFax.msgPhoneFormat" />";
		var email = document.getElementsByName('email')[0];
		if(email.length > 0 ) {
			if(!validateEmail(email)) {
				alert(msg);
				return false;
			}
		}
		return true;
	}

	function validateEmail(email) {
		var re = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
		return re.test(email.toLowerCase());
	}
</script>
<html:base />
<link rel="stylesheet" type="text/css"
	href="../oscarEncounter/encounterStyles.css">

<title><bean:message key="provider.editRxFax.title" /></title>
<style type="text/css">
	.label-span {
		float: left;
		width: 120px;
		font-weight: bold;
	}
</style>
</head>

<body class="BodyStyle" vlink="#0000FF">

<table class="MainTable" id="scrollNumber1" name="encounterTable">
	<tr class="MainTableTopRow">
		<td class="MainTableTopRowLeftColumn"><bean:message
			key="provider.editRxFax.msgPrefs" /></td>
		<td style="color: white" class="MainTableTopRowRightColumn">Provider Website and Email</td>
	</tr>
	<tr>
		<td class="MainTableLeftColumn">&nbsp;</td>
		<td class="MainTableRightColumn">
		<%
			UserPropertyDAO propertyDao = (UserPropertyDAO)SpringUtils.getBean("UserPropertyDAO");
			UserProperty emailProp = propertyDao.getProp(curUser_no,"email");			
			String email = "";
			if(emailProp!=null) {
				email = emailProp.getValue();
			}
			UserProperty websiteProp = propertyDao.getProp(curUser_no,"website");
			String website = "";
			if(websiteProp!=null) {
				website = websiteProp.getValue();
			}
			if (request.getAttribute("status") == null) {
		%>
			<html:form action="/EditWebsiteAndEmail.do">
				
				<span style="color:blue">
					By entering in a value, you will override the email and/or website in consultation letterheads
				</span>
				<br/><br/>
				<label><span class="label-span">Website: </span><html:text property="website" value="<%=website%>" maxlength="255" size="40"/></label>
				<br/>
				<label><span class="label-span">Email Address: </span><html:text property="email" value="<%=email%>" maxlength="255" size="40"/></label>
				<br/>

				<input type="submit" onclick="return validate();" value="<bean:message key="provider.editRxFax.btnSubmit"/>"/>
			</html:form>
		<%
			} else if((request.getAttribute("status")).equals("complete")) { %>
			<bean:message key="oscarEncounter.oscarConsultationRequest.ConsultationFormRequest.letterheadWebsite"/> set to: 
			<%=website%><br/>
			<bean:message key="oscarEncounter.oscarConsultationRequest.ConsultationFormRequest.letterheadEmail"/> set to:
			<%=email%>
		<%	}%>
		</td>
	</tr>
	<tr>
		<td class="MainTableBottomRowLeftColumn"></td>
		<td class="MainTableBottomRowRightColumn"></td>
	</tr>
</table>
</body>
</html:html>
