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
<%@page import="org.oscarehr.PMmodule.model.ProgramProvider"%>
<%@page import="org.oscarehr.common.model.SecRole"%>
<%@page import="org.oscarehr.common.dao.SecRoleDao"%>
<%@page import="org.oscarehr.PMmodule.dao.ProgramProviderDAO"%>
<%@page import="org.oscarehr.common.model.ProviderFacility"%>
<%@page import="org.oscarehr.common.dao.ProviderFacilityDao"%>
<%@page import="org.oscarehr.PMmodule.model.Program"%>
<%@page import="org.oscarehr.PMmodule.dao.ProgramDao"%>
<%@page import="org.oscarehr.common.dao.FacilityDao"%>
<%@page import="org.oscarehr.common.model.Facility"%>
<%@page import="org.oscarehr.common.model.Provider"%>
<%@page import="org.oscarehr.util.SpringUtils"%>
<%@page import="org.oscarehr.PMmodule.dao.ProviderDao"%>
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

<%
	String providerNo = request.getParameter("providerNo");

	ProviderFacilityDao providerFacilityDao = SpringUtils.getBean(ProviderFacilityDao.class);
	ProviderDao providerDao = SpringUtils.getBean(ProviderDao.class);
	FacilityDao facilityDao = SpringUtils.getBean(FacilityDao.class);
	ProgramDao programDao = SpringUtils.getBean(ProgramDao.class);
	SecRoleDao secRoleDao = SpringUtils.getBean(SecRoleDao.class);
	

	
	List<ProviderFacility> providerFacilities = providerFacilityDao.findByProviderNo(providerNo);
	Provider provider = providerDao.getProvider(providerNo);
	List<Facility> facilities = facilityDao.findAll(true);
	request.setAttribute("facilities",facilities);
	
	
	List<Program> programs1 = programDao.findAll();
	List<Program> programs = new ArrayList<Program>();
	for(Program p:programs1) {
		if(p.isActive() && !p.getType().equals("community")) {
			for(ProviderFacility pf: providerFacilities) {
				if(p.getFacilityId() == pf.getId().getFacilityId()) {
					programs.add(p);
				}
			}
			
		}
	}
	request.setAttribute("programs",programs);
	
	
	
	ProgramProviderDAO programProviderDao = SpringUtils.getBean(ProgramProviderDAO.class);
	
	List<SecRole> roles = secRoleDao.findAll();
%>
<body vlink="#0000FF" class="BodyStyle">
<%
if(provider != null) {
%>
	<table class="MainTable">
		<tr class="MainTableTopRow">
			<td class="MainTableTopRowRightColumn">
				<table class="TopStatusBar" style="width: 100%;">
					<tr>
						<% if(provider != null) { %>
						<td>Assign Facilities to <%=provider.getFirstName() %> <%=provider.getLastName() %></td>
						<% } else { %>
						<td>Assign Facilities and Programs to Provider</td>
						<% } %>
					</tr>
				</table>
			</td>
		</tr>
		<tr>
			<td class="MainTableRightColumn" valign="top">
		
				<form action="<%=request.getContextPath() %>/Provider.do">
				<display:table class="simple" cellspacing="2" cellpadding="3"
					id="facility" name="facilities" export="false" pagesize="0"
					>
					<display:setProperty name="paging.banner.placement" value="bottom" />
					<display:setProperty name="paging.banner.item_name" value="facility" />
					<display:setProperty name="paging.banner.items_name" value="facilities" />
					<display:setProperty name="basic.msg.empty_list" value="No facilities found." />
			
					<display:column sortable="false" title="">
						<%
							Facility item = (Facility)pageContext.getAttribute("facility");
							String checked="";
							if( providerFacilityDao.findByProviderNoAndFacilityId(providerNo, item.getId()) != null) {
								checked = " checked=\"checked\" ";
							}
						%>
						<input type="checkbox" name="facility" value="<%=item.getId() %>" <%=checked %>/>
					</display:column>
			
					<display:column property="name" sortable="false" title="Name" />
					<display:column property="description" sortable="false"
						title="Description" />
					<display:column property="contactName" sortable="false"
						title="Contact name" />
					
				</display:table>
				
				<input type="submit" value="Save Changes"/>
				<input type="hidden" name="method" value="saveFacilities"/>
				<input type="hidden" name="providerNo" value="<%=providerNo%>"/>
				</form>
				
			</td>
		</tr>
		<tr style="height:20px">
			<td style="height:20px"></td>
		</tr>
		
		<tr class="MainTableTopRow">
			<td class="MainTableTopRowRightColumn">
				<table class="TopStatusBar" style="width: 100%;">
					<tr>
						<td>Assign Programs to <%=provider.getFirstName() %> <%=provider.getLastName() %></td>
					</tr>
				</table>
			</td>
		</tr>
		<tr>

			<td class="MainTableRightColumn" valign="top">
		
				<form action="<%=request.getContextPath() %>/Provider.do">
				<display:table class="simple" cellspacing="2" cellpadding="3"
					id="program" name="programs" export="false" pagesize="0"
					>
					<display:setProperty name="paging.banner.placement" value="bottom" />
					<display:setProperty name="paging.banner.item_name" value="program" />
					<display:setProperty name="paging.banner.items_name" value="programs" />
					<display:setProperty name="basic.msg.empty_list" value="No programs found." />
			
					<display:column sortable="false" title="">
						<%
							Program item = (Program)pageContext.getAttribute("program");
							String checked="";
							ProgramProvider pp = programProviderDao.getProgramProvider(providerNo, item.getId().longValue());
							if( pp != null) {
								checked = " checked=\"checked\" ";
							}
						%>
						<input type="checkbox" name="program" value="<%=item.getId() %>" <%=checked %>/>
						&nbsp;
						<select name="role_<%=item.getId()%>">
							<option value=""></option>
							<%for(SecRole role:roles) {
								String roleChecked = "";
								if(pp != null && pp.getRoleId().intValue() == role.getId()) {
									roleChecked = " selected=\"selected\" ";
								}
								%>
								<option value="<%=role.getId()%>" <%=roleChecked %>><%=role.getName() %></option>
							<% } %>
						</select>
					</display:column>
			
					<display:column property="name" sortable="false" title="Name" />
					<display:column property="type" sortable="false" title="Type" />
					
					<display:column property="facilityDesc" sortable="false"
						title="Facility" />
					
				</display:table>
				
				<input type="submit" value="Save Changes"/>
				<input type="hidden" name="method" value="savePrograms"/>
				<input type="hidden" name="providerNo" value="<%=providerNo%>"/>
				</form>
				
			</td>
		</tr>		
		<tr>

			<td class="MainTableBottomRowRightColumn">&nbsp;</td>
		</tr>
	</table>
	<% } else { %>
		<h2>Invalid Provider!</h2>
	<% } %>
</html:html>

