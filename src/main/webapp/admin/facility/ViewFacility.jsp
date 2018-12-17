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
<%@page import="org.oscarehr.common.model.Facility"%>
<%@page import="org.oscarehr.util.LoggedInInfo"%>
<%@ taglib uri="/WEB-INF/security.tld" prefix="security"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>


<%
	String roleName$ = (String) session.getAttribute("userrole") + "," + (String) session.getAttribute("user");
	boolean authed = true;
%>
<security:oscarSec roleName="<%=roleName$%>"
	objectName="_admin,_admin.misc" rights="r" reverse="<%=true%>">
	<%
		authed = false;
	%>
	<%
		response.sendRedirect("../securityError.jsp?type=_admin&type=_admin.misc");
	%>
</security:oscarSec>
<%
	if (!authed) {
		return;
	}
%>

<%@ page import="java.util.*,oscar.oscarReport.reportByTemplate.*"%>
<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean"%>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html"%>
<%@ taglib uri="/WEB-INF/struts-logic.tld" prefix="logic"%>
<%@ taglib uri="http://displaytag.sf.net" prefix="display"%>
<html:html locale="true">
<head>
<script type="text/javascript"
	src="<%=request.getContextPath()%>/js/global.js"></script>
<title>Clinic</title>
<link rel="stylesheet" type="text/css"
	href="<%=request.getContextPath()%>/share/css/OscarStandardLayout.css">
<link rel="stylesheet" type="text/css"
	href='<html:rewrite page="/css/displaytag.css" />' />

<script type="text/javascript" language="JavaScript"
	src="<%=request.getContextPath()%>/share/javascript/prototype.js"></script>
<script type="text/javascript" language="JavaScript"
	src="<%=request.getContextPath()%>/share/javascript/Oscar.js"></script>
<script type="text/javascript">
	function validateForm() {
		if (bCancel)
			return bCancel;

		var isOk = false;
		isOk = validateRequiredField('facilityName', 'Facility Name', 32);
		if (isOk)
			isOk = validateRequiredField('facilityDesc',
					'Facility Description', 70);
		//                if (isOk) isOk = validateUpdateInterval();
		if (isOk)
			isOk = validateRemoveDemoId();
		return isOk;
	}

	function validateUpdateInterval() {
		var ret = false;
		var interval = document.forms[0].updateInterval.value;
		if (!isInteger(interval)) {
			alert("Integrator Update Interval must be an integer!");
		} else if (parseInt(interval) < 1) {
			alert("Integrator Update Interval must be > 0");
		} else {
			ret = true;
		}
		return ret;
	}

	function validateRemoveDemoId() {
		var ret = true;
		var rid = document.forms[0].removeDemographicIdentity.checked;
		if (!rid) {
			ret = confirm("Remove Demographic Identity NOT checked! Is it OK?");
		}
		return ret;
	}
</script>
<style type="text/css">
table.outline {
	margin-top: 50px;
	border-bottom: 1pt solid #888888;
	border-left: 1pt solid #888888;
	border-top: 1pt solid #888888;
	border-right: 1pt solid #888888;
}

table.grid {
	border-bottom: 1pt solid #888888;
	border-left: 1pt solid #888888;
	border-top: 1pt solid #888888;
	border-right: 1pt solid #888888;
}

td.gridTitles {
	border-bottom: 2pt solid #888888;
	font-weight: bold;
	text-align: center;
}

td.gridTitlesWOBottom {
	font-weight: bold;
	text-align: center;
}

td.middleGrid {
	border-left: 1pt solid #888888;
	border-right: 1pt solid #888888;
	text-align: center;
}

label {
	float: left;
	width: 120px;
	font-weight: bold;
}

label.checkbox {
	float: left;
	width: 116px;
	font-weight: bold;
}

label.fields {
	float: left;
	width: 80px;
	font-weight: bold;
}

span.labelLook {
	font-weight: bold;
}

input, textarea, select { //
	margin-bottom: 5px;
}

textarea {
	width: 450px;
	height: 100px;
}

.boxes {
	width: 1em;
}

#submitbutton {
	margin-left: 120px;
	margin-top: 5px;
	width: 90px;
}

br {
	clear: left;
}
</style>
</head>

<body vlink="#0000FF" class="BodyStyle">

	<table class="MainTable">
		<tr class="MainTableTopRow">
			<td class="MainTableTopRowRightColumn">
				<table class="TopStatusBar" style="width: 100%;">
					<tr>
						<td>View Facility</td>
					</tr>
				</table>
			</td>
		</tr>
		<tr>

			<td class="MainTableRightColumn" valign="top">
			

<bean:define id="facility" name="facilityManagerForm"
	property="facility" />

<html:form action="/FacilityManager.do">
	<input type="hidden" name="method" value="save" />
	<table border="1" cellspacing="2" cellpadding="3">
		<tr class="b">
			<td width="20%"><b>Facility Id:</b></td>
			<td><c:out value="${requestScope.id}" /></td>
		</tr>
		<tr class="b">
			<td width="20%"><b>Name:</td>
			<td><c:out
				value="${facilityManagerForm.facility.name}" /></td>
		</tr>
		<tr class="b">
			<td width="20%"><b>Description:</b></td>
			<td><c:out value="${facilityManagerForm.facility.description}" /></td>
		</tr>
		<tr class="b">
			<td width="20%"><b>HIC:</b></td>
			<td><c:out value="${facilityManagerForm.facility.hic}" /></td>
		</tr>
		<tr class="b">
			<td width="20%"><b>OCAN Service Org Number:</b></td>
			<td><c:out value="${facilityManagerForm.facility.ocanServiceOrgNumber}" /></td>
		</tr>
		<tr class="b">
			<td width="20%"><b>Primary Contact Name:</b></td>
			<td><c:out value="${facilityManagerForm.facility.contactName}" /></td>
		</tr>
		<tr class="b">
			<td width="20%"><b>Primary Contact Email:</b></td>
			<td><c:out value="${facilityManagerForm.facility.contactEmail}" /></td>
		</tr>
		<tr class="b">
			<td width="20%"><b>Primary Contact Phone:</b></td>
			<td><c:out value="${facilityManagerForm.facility.contactPhone}" /></td>
		</tr>

		<tr class="b">
			<td width="20%"><b>Digital Signatures Enabled:</b></td>
			<td><c:out value="${facilityManagerForm.facility.enableDigitalSignatures}" /></td>
		</tr>

		<tr class="b">
			<td width="20%"><b>Integrator Enabled:</b></td>
			<td>
				<c:out value="${facilityManagerForm.facility.integratorEnabled}" />
				<%
					// this needs to be checked against the running facility, not the viewing facility
					// because the running facility is the one who will contact the integrator to see the facility list.
					
					LoggedInInfo loggedInInfo= LoggedInInfo.getLoggedInInfoFromSession(request);
					if (loggedInInfo.getCurrentFacility().isIntegratorEnabled())
					{
						%>
						&nbsp;
						<a target="_blank" href="<%= request.getContextPath() %>/admin/viewIntegratedCommunity.jsp?facilityId=<c:out value="${requestScope.id}" />">
							View Integrated Facilities Community
						</a>
						<%
					}
				%>
			</td>
		</tr>


	</table>

	<br/>

	<div class="tabs" id="tabs">
	<table cellpadding="3" cellspacing="0" border="0">
		<tr>
			<th title="Associated programs">Associated programs</th>
		</tr>
	</table>
	</div>

	<br/>
	<display:table class="simple" cellspacing="2" cellpadding="3"
		id="program" name="associatedPrograms" export="false" pagesize="0">
		<display:setProperty name="basic.msg.empty_list" value="No programs." />
	

		<logic:equal name="program" property="facilityId"
			value="<%=((Facility)facility).getId().toString()%>">
			<display:column sortable="false" sortProperty="name"
				title="Program Name">
				
					<c:out value="${program.name}" />
			</display:column>
		</logic:equal>
		<logic:notEqual name="program" property="facilityId"
			value="<%=((Facility)facility).getId().toString()%>">
			<display:column sortable="false" sortProperty="name"
				title="Program Name">
				<c:out value="${program.name}" />
			</display:column>
		</logic:notEqual>

		<display:column property="type" sortable="false" title="Program Type" />
		<display:column property="queueSize" sortable="false"
			title="Clients in Queue" />

		
	</display:table>
	

	<br>
	<div class="tabs" id="tabs">
	<table cellpadding="3" cellspacing="0" border="0">
		<tr>
			<th title="Facility Messages">Messages</th>
		</tr>
	</table>
	</div>
	<br>This table displays client automatic discharges from this facility from the past seven days. An
automatic discharge occurs when the client is admitted to another facility
while still admitted in this facility.

	<table width="100%" border="1" cellspacing="2" cellpadding="3">
		<tr>
			<th>Name</th>
			<th>Client DOB</th>
			<th>Bed Program</th>
			<th>Discharge Date/Time</th>
		</tr>
		<c:forEach var="client" items="${associatedClients}">

			<%String styleColor=""; %>
			<c:if test="${client.inOneDay}">
				<%styleColor="style=\"color:red;\"";%>
			</c:if>
			<tr class="b" <%=styleColor%>>
				<td><c:out value="${client.name}" /></td>
				<td><c:out value="${client.dob}" /></td>
				<td><c:out value="${client.programName}" /></td>
				<td><c:out value="${client.dischargeDate}" /></td>
			</tr>

		</c:forEach>
	</table>


	<br>
    Automatic discharges in the past 24 hours appear red.

	<br/>
	<html:cancel value="Go Back"/>
	<br/>
</html:form>


			</td>
		</tr>
		<tr>

			<td class="MainTableBottomRowRightColumn">&nbsp;</td>
		</tr>
	</table>
</html:html>

