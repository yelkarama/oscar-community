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
<%@ taglib uri="/WEB-INF/security.tld" prefix="security"%>
<%
    String roleName$ = (String)session.getAttribute("userrole") + "," + (String) session.getAttribute("user");
    boolean authed=true;
%>
<security:oscarSec roleName="<%=roleName$%>" objectName="_demographic" rights="r" reverse="<%=true%>">
	<%authed=false; %>
	<%response.sendRedirect(request.getContextPath() + "/securityError.jsp?type=_demographic");%>
</security:oscarSec>
<%
	if(!authed) {
		return;
	}
%>

<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean"%>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html"%>
<%@ taglib uri="/WEB-INF/struts-logic.tld" prefix="logic"%>
<%@ taglib uri="/WEB-INF/oscarProperties-tag.tld" prefix="oscarProp"%>
<%@page import="org.oscarehr.util.SpringUtils"%>
<%@page import="org.oscarehr.PMmodule.dao.ProviderDao"%>
<%@page import="org.oscarehr.common.dao.DemographicDao"%>
<%@page import="org.oscarehr.common.model.Provider"%>
<%@page import="org.oscarehr.common.model.Demographic"%>
<%@page import="org.oscarehr.common.dao.DemographicArchiveDao" %>
<%@page import="org.oscarehr.common.model.DemographicArchive" %>
<%@ page import="org.oscarehr.common.model.DemographicExt" %>
<%@ page import="org.oscarehr.common.model.DemographicExtArchive" %>
<%@ page import="org.oscarehr.common.dao.DemographicExtDao" %>
<%@ page import="org.oscarehr.common.dao.DemographicExtArchiveDao" %>
<%@page import="java.util.List" %>
<%@page import="java.util.Date" %>
<%@page import="oscar.util.DateUtils" %>
<%@page import="oscar.util.StringUtils" %>
<%@page import="oscar.oscarDemographic.pageUtil.Util" %>
<html:html locale="true">
<head>
<title>Enrollment History</title>
<link href="<%=request.getContextPath() %>/css/bootstrap.min.css" rel="stylesheet">
<script type="text/javascript" src="<%= request.getContextPath() %>/js/global.js"></script>
<link rel="stylesheet" type="text/css" href="styles.css">
<html:base />
<link rel="stylesheet" type="text/css" media="all" href="../share/css/extractedFromPages.css"  />
<style>
	.table td {
		text-align: center;
	}

	.table th {
		text-align: center;
	}

	.patientInformation p {
		display: inline-block;
	}

	.patientInformation {
		margin-bottom: 30px;
	}

	.headerDiv {
		background-color: #F5F5F5;
		margin: auto;
		width: 50%;
		padding-left: 10px;
		padding-right: 10px;
		border-radius: 5px;
	}
</style>
</head>
<%
	String demographicNo = request.getParameter("demographicNo");
	ProviderDao providerDao = (ProviderDao)SpringUtils.getBean("providerDao");

	//load demographic
	DemographicDao demographicDao=(DemographicDao)SpringUtils.getBean("demographicDao");
	Demographic demographic = demographicDao.getClientByDemographicNo(Integer.valueOf(demographicNo));
	DemographicExtDao demoExtDao = SpringUtils.getBean(DemographicExtDao.class);
	DemographicExt demoExt = demoExtDao.getDemographicExt(Integer.parseInt(demographicNo), "enrollmentProvider");
	DemographicArchiveDao demoArchiveDao = SpringUtils.getBean(DemographicArchiveDao.class);

	Provider enrollmentProvider = providerDao.getProvider(demographic.getProviderNo());
	if (demoExt != null) {
	    enrollmentProvider = providerDao.getProvider(demoExt.getValue());
	}
	String providerOHIP = "Not Set";
	String enrollmentProviderName = "Not Set";
	if (enrollmentProvider != null) {
	    enrollmentProviderName = enrollmentProvider.getFormattedName();
		providerOHIP = enrollmentProvider.getOhipNo() == null ? "Not Set" : enrollmentProvider.getOhipNo().isEmpty() ? "Not Set" : enrollmentProvider.getOhipNo();
	}

	String enrollmentStatus = demographic.getRosterStatus();
		enrollmentStatus = enrollmentStatus.equals("RO") ? "Yes" : "No";
	Date rosterDate = demographic.getRosterDate();
	String rosterTermDate = DateUtils.formatDate(demographic.getRosterTerminationDate(), request.getLocale());
	String enrollmentDate = DateUtils.formatDate(rosterDate,request.getLocale());
	if (enrollmentDate.isEmpty()) {
	    enrollmentDate = "Not Set";
	}
	if (rosterTermDate.isEmpty()) {
		rosterTermDate = "Not Set";
	}
	String terminationReasonCode = demographic.getRosterTerminationReason() == null ? "N/A" : demographic.getRosterTerminationReason().isEmpty() ? "N/A" : demographic.getRosterTerminationReason();
	if (terminationReasonCode.equals("N/A")) {
		rosterTermDate = "N/A";
	}
%>

<body>
	<div class="headerDiv">
		<h2 align="center">Patient Enrollment History</h2>
		<div class="patientInformation" align="center" style="margin-bottom: 30px;">
			<p><b>Name:</b> <%=demographic.getFormattedName()%></p> |
			<p><b>Date of Birth:</b> <%=demographic.getFormattedDob()%></p> |
			<input type="button" class="btn btn-success btn-small" style="display: inline-block;" value="Print" onclick="window.print();"/>
		</div>
	</div>
	<table class="table">
		<tr style="font-weight: bold;">
			<th>Enrollment Physician</th>
			<th>Physician OHIP #</th>
			<th>Enrollment Status</th>
			<th>Enrollment Date</th>
			<th>Termination Date</th>
			<th>Termination Reason Code</th>
		</tr>

		<% if (!enrollmentProviderName.equalsIgnoreCase("Not Set") || !providerOHIP.equalsIgnoreCase("Not Set") || !enrollmentStatus.equalsIgnoreCase("No") || !enrollmentDate.equalsIgnoreCase("Not Set") || !rosterTermDate.equalsIgnoreCase("N/A") || !terminationReasonCode.equalsIgnoreCase("N/A")) { %>

			<tr>
				<td><%=enrollmentProviderName%></td>
				<td><%=providerOHIP%></td>
				<td><%=enrollmentStatus%></td>
				<td><%=enrollmentDate%></td>
				<td><%=rosterTermDate%></td>
				<td><%=terminationReasonCode%></td>
			</tr>
		<%
		}
			List<DemographicArchive> DAs = demoArchiveDao.findRosterStatusHistoryByDemographicNo(Integer.valueOf(demographicNo));

			for (DemographicArchive demographicArchive : DAs) {

				DemographicExtArchiveDao demographicExtArchiveDao = SpringUtils.getBean(DemographicExtArchiveDao.class);
				DemographicExtArchive demographicExtArchive = demographicExtArchiveDao.getDemographicExtArchiveByArchiveIdAndKey(demographicArchive.getId(), "enrollmentProvider");
				Provider aEnrollmentProvider = providerDao.getProvider(demographicArchive.getProviderNo());
				if (demographicExtArchive != null) {
					aEnrollmentProvider = providerDao.getProvider(demographicExtArchive.getValue());
				}
				providerOHIP = "Not Set";
				String aEnrollmentProviderName = "Not Set";
				if (aEnrollmentProvider != null) {
					aEnrollmentProviderName = aEnrollmentProvider.getFormattedName();
					providerOHIP = aEnrollmentProvider.getOhipNo() == null ? "Not Set" : aEnrollmentProvider.getOhipNo().isEmpty() ? "Not Set" : aEnrollmentProvider.getOhipNo();
				}

				String aEnrollmentStatus = demographicArchive.getRosterStatus();
				aEnrollmentStatus = aEnrollmentStatus.equals("RO") ? "Yes" : "No";
				rosterDate = demographicArchive.getRosterDate();
				String aRosterTermDate = DateUtils.formatDate(demographicArchive.getRosterTerminationDate(), request.getLocale());
				String aEnrollmentDate = DateUtils.formatDate(rosterDate,request.getLocale());
				if (aEnrollmentDate.isEmpty()) {
					aEnrollmentDate = "Not Set";
				}
				if (aRosterTermDate.isEmpty()) {
					aRosterTermDate = "Not Set";
				}
				String aTerminationReasonCode = demographicArchive.getRosterTerminationReason() == null ? "N/A" : demographicArchive.getRosterTerminationReason().isEmpty() ? "N/A" : demographicArchive.getRosterTerminationReason();
				if (aTerminationReasonCode.equals("N/A")) {
					aRosterTermDate = "N/A";
				}

				if (!aEnrollmentProviderName.equals(enrollmentProviderName) || !aEnrollmentStatus.equals(enrollmentStatus)
					|| !aEnrollmentDate.equals(enrollmentDate) || !aRosterTermDate.equals(rosterTermDate) || !aTerminationReasonCode.equals(terminationReasonCode)) {
				    if (!aEnrollmentProviderName.equalsIgnoreCase("Not Set") || !providerOHIP.equalsIgnoreCase("Not Set") || !aEnrollmentStatus.equalsIgnoreCase("No") || !aEnrollmentDate.equalsIgnoreCase("Not Set") || !aRosterTermDate.equalsIgnoreCase("N/A") || !aTerminationReasonCode.equalsIgnoreCase("N/A")) {
		%>
		<tr>
			<td><%=aEnrollmentProviderName%></td>
			<td><%=providerOHIP%></td>
			<td><%=aEnrollmentStatus%></td>
			<td><%=aEnrollmentDate%></td>
			<td><%=aRosterTermDate%></td>
			<td><%=aTerminationReasonCode%></td>
		</tr>
		<%
				    }
				}
			}
			%>
	</table>
</body>
</html:html>
