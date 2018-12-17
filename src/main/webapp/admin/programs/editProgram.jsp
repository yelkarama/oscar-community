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
<%@page import="org.apache.struts.validator.DynaValidatorForm"%>
<%@page import="org.oscarehr.common.model.FunctionalCentre"%>
<%@page import="org.oscarehr.PMmodule.model.Program"%>
<%@ taglib uri="/WEB-INF/security.tld" prefix="security"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html-el" prefix="html-el"%>


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
	var bCancel = false;

	function save() {
		if(!bCancel) {
			var maxAllowed = document.programManagerForm.elements['program.maxAllowed'].value;
			if (isNaN(maxAllowed)) {
				alert("Maximum participants '" + maxAllowed + "' is not a number");
				return false;
			}
			if (document.programManagerForm.elements['program.maxAllowed'].value <= 0) {
				alert('Maximum participants must be a positive integer');
				return false;
			}
	
			if (document.programManagerForm.elements['program.name'].value == null
					|| document.programManagerForm.elements['program.name'].value.length <= 0) {
				alert('The program name can not be blank.');
				return false;
			}
		}

		document.programManagerForm.method.value = 'save';
		document.programManagerForm.submit()
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
						<td>Manage Program Details</td>
					</tr>
				</table>
			</td>
		</tr>
		<tr>

			<td class="MainTableRightColumn" valign="top"><html:form
					action="/ProgramManager.do" onsubmit="return save();">
					<input type="hidden" name="method" value="save" />
					<table width="100%" border="1" cellspacing="2" cellpadding="3">

						<tr class="b">
							<td width="20%">Program Name:</td>
							<td><html:text property="program.name" size="70"
									maxlength="70" /></td>
						</tr>

						<tr class="b">
							<td width="20%">Facility</td>
							<td><html-el:select property="program.facilityId">
									<c:forEach var="facility" items="${facilities}">
										<html-el:option value="${facility.id}">
											<c:out value="${facility.name}" />
										</html-el:option>
									</c:forEach>
								</html-el:select></td>
						</tr>

						<tr class="b">
							<td width="20%">Description:</td>
							<td><html:text property="program.description" size="30"
									maxlength="255" /></td>
						</tr>
						<tr class="b">
							<td width="20%">Functional Centre:</td>
							<td>
							
							<select name="program.functionalCentreId">
								<option value="">None</option>
								<%
									DynaValidatorForm f = (DynaValidatorForm)pageContext.getAttribute("programManagerForm");
									Program p = (Program)f.get("program");
									List<FunctionalCentre> functionalCentres = (List<FunctionalCentre>)request.getAttribute("functionalCentres");
									
									for(FunctionalCentre fc : functionalCentres) {
										String selected = "";
										if(fc.getAccountId().equals(p.getFunctionalCentreId())) {
											selected=" selected=\"selected\" ";
										}
										%>
											<option value="<%=fc.getAccountId()%>" <%=selected %>><%=fc.getDescription() %></option>
										<%
									}
								%>
							</select>
							
							
								
								
								</td>
						</tr>

						<tr class="b">
							<td width="20%">HIC:</td>
							<td><html:checkbox property="program.hic" /></td>
						</tr>
						<tr class="b">
							<td width="20%">Address:</td>
							<td><html:text property="program.address" size="30"
									maxlength="255" /></td>
						</tr>
						<tr class="b">
							<td width="20%">Phone:</td>
							<td><html:text property="program.phone" size="30"
									maxlength="25" /></td>
						</tr>
						<tr class="b">
							<td width="20%">Fax:</td>
							<td><html:text property="program.fax" size="30"
									maxlength="25" /></td>
						</tr>
						<tr class="b">
							<td width="20%">URL:</td>
							<td><html:text property="program.url" size="30"
									maxlength="100" /></td>
						</tr>
						<tr class="b">
							<td width="20%">Email:</td>
							<td><html:text property="program.email" size="30"
									maxlength="50" /></td>
						</tr>
						<tr class="b">
							<td width="20%">Emergency Number:</td>
							<td><html:text property="program.emergencyNumber" size="30"
									maxlength="25" /></td>
						</tr>
						<tr class="b">
							<td width="20%">Type:</td>
							<td><html:select property="program.type">
									<html:option value="Bed" />
									<html:option value="Service" />
									<caisi:isModuleLoad moduleName="TORONTO_RFQ" reverse="false">
										<html:option value="External" />
										<html:option value="community">Community</html:option>
									</caisi:isModuleLoad>
								</html:select></td>
						</tr>
						<tr class="b">
							<td width="20%">Status:</td>
							<td><html:select property="program.programStatus">
									<html:option value="active" />
									<html:option value="inactive" />
								</html:select></td>
						</tr>
						<tr class="b">
							<td width="20%">Location:</td>
							<td><html:text property="program.location" size="30"
									maxlength="70" /></td>
						</tr>
						<tr class="b">
							<td width="20%">Max Participants:</td>
							<td><html:text property="program.maxAllowed" size="8"
									maxlength="8" /></td>
						</tr>

						<tr class="b">
							<td width="20%">Exclusive View:</td>
							<td><html:select property="program.exclusiveView">
									<html:option value="no">No</html:option>
									<html:option value="appointment">Appointment View</html:option>
									<html:option value="case-management">Case-management View</html:option>
								</html:select> (Selecting "No" allows users to switch views)</td>
						</tr>

						<tr class="b">
							<td width="20%">Enable Mandatory Encounter Time:</td>
							<td><html:checkbox property="program.enableEncounterTime" /></td>
						</tr>
						<tr class="b">
							<td width="20%">Enable Mandatory Transportation Time:</td>
							<td><html:checkbox
									property="program.enableEncounterTransportationTime" /></td>
						</tr>
						<tr class="b">
							<td width="20%">Email Notification Addresses (csv):</td>
							<td><html:text
									property="program.emailNotificationAddressesCsv" /></td>
						</tr>
						<tr class="b">
							<td width="20%">Enable OCAN:</td>
							<td><html:checkbox property="program.enableOCAN" /></td>
						</tr>

						<tr class="b">
							<td width="20%">Holding Tank:</td>
							<td><html:checkbox property="program.holdingTank" /></td>
						</tr>
						<tr class="b">
							<td width="20%">Allow Batch Admissions:</td>
							<td><html:checkbox property="program.allowBatchAdmission" /></td>
						</tr>
						<tr class="b">
							<td width="20%">Allow Batch Discharges:</td>
							<td><html:checkbox property="program.allowBatchDischarge" /></td>
						</tr>
						<tr class="b">
							<td width="20%">Bed Program Affiliated:</td>
							<td><html:checkbox property="program.bedProgramAffiliated" /></td>
						</tr>
						<tr>
							<td colspan="2"><html:submit property="submit.save"
									onclick="bCancel=false;">Save</html:submit> <html:cancel onclick="bCancel=true;">Cancel</html:cancel></td>
						</tr>
					</table>
				</html:form></td>
		</tr>
		<tr>

			<td class="MainTableBottomRowRightColumn">&nbsp;</td>
		</tr>
	</table>
</html:html>
