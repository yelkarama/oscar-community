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
						<td>Add/Edit Facility</td>
					</tr>
				</table>
			</td>
		</tr>
		<tr>

			<td class="MainTableRightColumn" valign="top"><html:form
					action="/FacilityManager" onsubmit="return validateForm();">
					<input type="hidden" name="method" value="save" />

					<!-- Ronnie
            < :hidden property="facility.ocanServiceOrgNumber" />
-->
					<table width="100%" border="1" cellspacing="2" cellpadding="3">
						<tr class="b">
							<td>Facility Id:</td>
							<td><c:out value="${requestScope.id}" /></td>
						</tr>
						<tr class="b">
							<td>Name: *</td>
							<td><html:text property="facility.name" size="32"
									maxlength="32" styleId="facilityName" /></td>
						</tr>
						<tr class="b">
							<td>Description: *</td>
							<td><html:text property="facility.description" size="60"
									maxlength="70" styleId="facilityDesc" /></td>
						</tr>
						<tr class="b">
							<td width="20%">HIC:</td>
							<td><html:checkbox property="facility.hic" /></td>
						</tr>
						<tr class="b">
							<td width="20%">OCAN Service Org Number:</td>
							<td><html:text property="facility.ocanServiceOrgNumber"
									size="5" maxlength="5" styleId="ocanServiceOrgNumber" /></td>
						</tr>
						<tr class="b">
							<td width="20%">Primary Contact Name:</td>
							<td><html:text property="facility.contactName" /></td>
						</tr>
						<tr class="b">
							<td width="20%">Primary Contact Email:</td>
							<td><html:text property="facility.contactEmail" /></td>
						</tr>
						<tr class="b">
							<td width="20%">Primary Contact Phone:</td>
							<td><html:text property="facility.contactPhone" /></td>
						</tr>
						<%
							Integer orgId = (Integer) request.getAttribute("orgId");
									Integer sectorId = (Integer) request.getAttribute("sectorID");
						%>
						<tr class="b">
							<td width="20%">Organization:</td>
							<td><select name="facility.orgId">
									<option value="0">&nbsp;</option>
									<c:forEach var="org" items="${orgList}">
										<c:choose>
											<c:when test="${orgId == org.code }">
												<option value="<c:out value="${org.code}"/>" selected><c:out
														value="${org.description}" /></option>
											</c:when>
											<c:otherwise>
												<option value="<c:out value="${org.code}"/>"><c:out
														value="${org.description}" /></option>
											</c:otherwise>
										</c:choose>
									</c:forEach>
							</select></td>
						</tr>
						<tr class="b">
							<td width="20%">Sector:</td>
							<td><select name="facility.sectorId">
									<option value="0">&nbsp;</option>
									<c:forEach var="sector" items="${sectorList}">
										<c:choose>
											<c:when test="${sectorId == sector.code }">
												<option value="<c:out value="${sector.code}"/>" selected><c:out
														value="${sector.description}" /></option>
											</c:when>
											<c:otherwise>
												<option value="<c:out value="${sector.code}"/>"><c:out
														value="${sector.description}" /></option>
											</c:otherwise>
										</c:choose>
									</c:forEach>
							</select></td>
						</tr>
						<tr class="b">
							<td width="20%">Enable Digital Signatures:</td>
							<td><html:checkbox
									property="facility.enableDigitalSignatures" /></td>
						</tr>
						<tr class="b">
							<td>Enable Integrator:</td>
							<td><html:checkbox property="facility.integratorEnabled" /></td>
						</tr>
						<tr class="b">
							<td>Integrator Url:</td>
							<td><html:text property="facility.integratorUrl" size="40" /></td>
						</tr>
						<tr class="b">
							<td>Integrator User:</td>
							<td><html:text property="facility.integratorU" /></td>
						</tr>
						<tr class="b">
							<td>Integrator Password:</td>
							<td><html:password property="facility.integratorP" /></td>
						</tr>
						<tr class="b">
							<td width="20%">Enable Referrals (Integrator):</td>
							<td><html:checkbox
									property="facility.enableIntegratedReferrals" /></td>
						</tr>
					
						<tr class="b">
							<td width="20%">Enable OCAN Forms:</td>
							<td><html:checkbox property="facility.enableOcanForms" /></td>
						</tr>
						<tr class="b">
							<td width="20%">Enable CBI Form:</td>
							<td><html:checkbox property="facility.enableCbiForm" /></td>
						</tr>
						<tr class="b">
							<td width="20%">Enable Anonymous Clients:</td>
							<td><html:checkbox property="facility.enableAnonymous" /></td>
						</tr>
						<tr class="b">
							<td width="20%">Enable Group Notes:</td>
							<td><html:checkbox property="facility.enableGroupNotes" /></td>
						</tr>
						<tr class="b">
							<td width="20%">Enable Mandatory Encounter Time in
								Encounter:</td>
							<td><html:checkbox property="facility.enableEncounterTime" /></td>
						</tr>
						<tr class="b">
							<td width="20%">Enable Mandatory Transportation Time in
								Encounter:</td>
							<td><html:checkbox
									property="facility.enableEncounterTransportationTime" /></td>
						</tr>
						<tr class="b">
							<td width="20%">Enable Health Number Registry:</td>
							<td><html:checkbox
									property="facility.enableHealthNumberRegistry" /></td>
						</tr>
						<tr class="b">
							<td>Remove Demographic Identity:</td>
							<td><html:checkbox property="removeDemographicIdentity" />
								(All patients' names, hin# & sin# will be removed in Integrator)
								<br></td>
						</tr>

						<tr class="b">
							<td>Rx Interaction Warning Level:</td>
							<td><html:select
									property="facility.rxInteractionWarningLevel">
									<html:option value="0">Not Specified</html:option>
									<html:option value="1">Low</html:option>
									<html:option value="2">Medium</html:option>
									<html:option value="3">High</html:option>
									<html:option value="4">None</html:option>
								</html:select></td>
						</tr>
						<!--Ronnie
                </tr>
                <tr class="b">
                    <td>Integrator Update Interval:</td>
                    <td>
                        <html:text property="updateInterval" size="3" />
                        Hour(s)
                        <br>
                    </td>
                </tr>
-->
						<tr>
							<td colspan="2">* Mandatory fields</td>
						<tr>
							<td colspan="2"><html:submit property="submit.save"
									onclick="bCancel=false;">Save</html:submit> <html:cancel>Cancel</html:cancel></td>
						</tr>
					</table>
				</html:form>
			</td>
		</tr>
		<tr>

			<td class="MainTableBottomRowRightColumn">&nbsp;</td>
		</tr>
	</table>
</html:html>

