<%--

    Copyright (c) 2006-. OSCARservice, OpenSoft System. All Rights Reserved.
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

--%>
<%@ page import="java.util.*, java.lang.*, org.oscarehr.common.dao.AppointmentTypeDao, org.oscarehr.common.model.AppointmentType, org.oscarehr.util.SpringUtils" %>
<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean" %>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html" %>
<%@ taglib uri="/WEB-INF/struts-logic.tld" prefix="logic" %>
<%@ taglib uri="/WEB-INF/security.tld" prefix="security" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ include file="dbconnection.jsp" %>
<%  
  String roleName$ = (String)session.getAttribute("userrole") + "," + (String) session.getAttribute("user");
  
  String sError = "";
  if (request.getParameter("err")!=null &&  !request.getParameter("err").equals(""))
  	sError = "Error: " + request.getParameter("err");

  	LoggedInInfo loggedInInfo = LoggedInInfo.getLoggedInInfoFromSession(request);
	LookupListManager lookupListManager = SpringUtils.getBean(LookupListManager.class);
	LookupList reasonCodes = lookupListManager.findActiveLookupListByName(loggedInInfo, "reasonCode");

	ProviderDao proivderDao = SpringUtils.getBean(ProviderDao.class);
	List<Provider> activeProviders = proivderDao.getActiveProviders();
	
	String selectedProviderNo = request.getParameter("selectedProvider");
	if (selectedProviderNo == null) { selectedProviderNo = (String) request.getAttribute("selectedProvider"); }
	if ("all".equalsIgnoreCase(selectedProviderNo)) {
		selectedProviderNo = null;
	}

	boolean multisites = org.oscarehr.common.IsPropertiesOn.isMultisitesEnable();
	
%>

<%@ page errorPage="../errorpage.jsp" %>
<%@ page import="java.util.*" %>
<%@ page import="org.apache.commons.lang.StringEscapeUtils" %>
<%@ page import="org.oscarehr.common.model.LookupListItem" %>
<%@ page import="org.oscarehr.managers.LookupListManager" %>
<%@ page import="org.oscarehr.common.model.LookupList" %>
<%@ page import="org.oscarehr.util.LoggedInInfo" %>
<%@ page import="oscar.appt.web.AppointmentTypeForm" %>
<%@ page import="org.oscarehr.PMmodule.dao.ProviderDao" %>
<%@ page import="org.oscarehr.common.model.Provider" %>
<html>
<head>
	<title>
		APPOINTMENT TYPES
	</title>
	<script type="text/javascript" src="<%=request.getContextPath() %>/js/jquery-1.9.1.min.js"></script>
	<script type="text/javascript" src="<%=request.getContextPath() %>/js/bootstrap.min.js"></script>
	<link href="<%=request.getContextPath() %>/css/bootstrap.min.css" rel="stylesheet" />
	<link href="<%=request.getContextPath() %>/css/panel.css" rel="stylesheet" />
	<link href="<%=request.getContextPath() %>/css/list-group.css" rel="stylesheet" />
	<script language="JavaScript">
		function checkTextPresent(field) {
			if (field.value == null || field.value === '') {
				alert("Please enter value in " + field.name + " field");
				field.focus();
			}
		}
		function checkNumberPresent(field) {
			var value = field.value;
			if (value == null || value === '' || parseInt(value) != value || value <= 0) {
				alert("Please enter whole positive number in " + field.name + " field");
				field.focus();
			}
		}
		function delType(url) {
			var answer = confirm("Type will be deleted! Are you sure?")
			if (answer){
				window.location = url;
			}
		}
		function setEnabled(url) {
			window.location = url;
		}

		function selectProvider(selectedProviderNo) {
			var selectProviderUrl = '../appointment/appointmentTypeAction.do?selectedProvider=' + selectedProviderNo;
			window.location = selectProviderUrl;
		}
	</script>
	<style type="text/css">
		[class*="span"] {
			margin-left: 0;
			margin-bottom: 5px;
		}
	</style>
</head>
<body>
<%
	AppointmentTypeDao appointmentTypeDao = SpringUtils.getBean(AppointmentTypeDao.class);
	List<AppointmentType> types;
	if (selectedProviderNo != null) {
		types = appointmentTypeDao.findAllForProvider(selectedProviderNo, false);
	} else {
		types = appointmentTypeDao.listAllTemplates();
	}
	AppointmentTypeForm thisAppointmentTypeForm = (AppointmentTypeForm) pageContext.findAttribute("AppointmentTypeForm");
%> 
<h3>Configure Appointment Types</h3>
<div class="container well">
	<div>
		<h4 style="margin-top: 0">Add new appointment type</h4>
	</div>
	<html:form action="appointment/appointmentTypeAction">
		<div class="span12">
			<input type="hidden" name="oper" value="save" />
			<input type="hidden" name="id" value="<bean:write name="AppointmentTypeForm" property="id"/>"/>
			<input type="hidden" name="providerNo" value="<bean:write name="AppointmentTypeForm" property="providerNo"/>"/>
			<input type="hidden" name="templateId" value="<bean:write name="AppointmentTypeForm" property="templateId"/>"/>
			<div class="span6 form-horizontal">
				<label class="span2 text-right" for="name">Name: </label>
				<div class="span4">
					<input type="text" id="name" name="name" value="<bean:write name="AppointmentTypeForm" property="name"/>" maxlength="50" onChange="checkTextPresent(this)"/>
				</div>
			</div>
			<div class="span6 form-horizontal">
				<label class="span2 text-right" for="duration">Duration: </label>
				<div class="span4">
					<input type="text" id="duration" name="duration" value="<bean:write name="AppointmentTypeForm" property="duration"/>" onChange="checkNumberPresent(this)">
				</div>
			</div>
		</div>
		<div class="span12">
			<div class="span6 form-horizontal">
				<label class="span2 text-right" for="reasonCode">Reason: </label>
				<div class="span4">
					<input type="text" name="newReasonCode" style="display: none" ondblclick="toggleReason();" />
					<select id="reasonCode" name="reasonCode" ondblclick="toggleReason();">
						<option value="0" selected></option>
						<%	Integer apptReasonCode = request.getParameter("reasonCode") != null ? Integer.valueOf(request.getParameter("reasonCode")) : null;
							if (thisAppointmentTypeForm != null && thisAppointmentTypeForm.getReasonCode() != null) {
								apptReasonCode = thisAppointmentTypeForm.getReasonCode();
							}
							if (reasonCodes != null) {
								for (LookupListItem reasonCode : reasonCodes.getItems()) { %>
						<option value="<%=reasonCode.getId()%>" <%=(apptReasonCode != null && apptReasonCode.equals(reasonCode.getId()) ? "selected":"")%>>
							<%=StringEscapeUtils.escapeHtml(reasonCode.getLabel())%>
						</option>
						<%		}
							} else { %>
						<option value="-1">Other</option>
						<%	} %>
					</select>
					<textarea style="width: 100%" name="reason"><bean:write name="AppointmentTypeForm" property="reason"/></textarea>
				</div>
			</div>
			<div class="span6 form-horizontal">
				<label class="span2 text-right" for="notes">Notes: </label>
				<div class="span4">
					<textarea style="width: 100%" id="notes" name="notes"><bean:write name="AppointmentTypeForm" property="notes"/></textarea>
				</div>
			</div>
		</div>
		<div class="span12">
			<div class="span6 form-horizontal">
				<label class="span2 text-right" for="location">Location: </label>
				<div class="span4">
					<logic:notEmpty name="locationsList">
						<html:select property="location">
							<html:option value="0">Select Location</html:option>
							<logic:iterate id="location" name="locationsList">
								<bean:define id="locValue" ><bean:write name='location' property='label'/></bean:define>
								<html:option value="<%= locValue %>">
									<bean:write name="location" property="label"/>
								</html:option>
							</logic:iterate>
						</html:select>
					</logic:notEmpty>
					<logic:empty name="locationsList">
						<input type="text" name="location" value="<bean:write name="AppointmentTypeForm" property="location"/>" maxlength="30" >
					</logic:empty>
				</div>
			</div>
			<div class="span6 form-horizontal">
				<label class="span2 text-right" for="resources">Resources: </label>
				<div class="span4">
					<input type="text" id="resources" name="resources" value="<bean:write name="AppointmentTypeForm" property="resources"/>">
				</div>
			</div>
			<div class="span6 form-horizontal">
				<label class="span2 text-right" for="enabled">Enabled: </label>
				<div class="span4">
					<% Boolean enabled = (thisAppointmentTypeForm != null && "true".equals(thisAppointmentTypeForm.getEnabled())); %>
					<input type="checkbox" name="enabled" id="enabled" value="true" <%=enabled?"checked=\"checked\"":""%>/>
				</div>
			</div>
		</div>
		<div class="span12">
			<input class="btn btn-primary" type="submit" value="Save">
		</div>
	</html:form>
</div>
<div class="container-fluid">
	<div>
		<label for="providerSelect">Configure for specific provider: </label>
		<select id="providerSelect" name="providerSelect" onchange="selectProvider(this.value)">
			<option value="all" selected="selected">All</option>
			<%	for (Provider p : activeProviders) { %>
			<option value="<%=p.getProviderNo()%>" <%=(p.getProviderNo().equals(selectedProviderNo)?"selected=\"selected\"":"")%>>
				<%=p.getFormattedName()%>
			</option>
			<% } %>
		</select>
		<% if (selectedProviderNo != null) { %>
		<div style="float: right;">
			<a href="../appointment/appointmentTypeAction.do?oper=enableAll&selectedProvider=<%=selectedProviderNo%>">Enable All</a>
			&nbsp;&nbsp;
			<a href="../appointment/appointmentTypeAction.do?oper=disableAll&selectedProvider=<%=selectedProviderNo%>">Disable All</a>
		</div>
		<% } %>
	</div>
	<table class="table table-condensed table-bordered">
		<thead>
			<tr bgcolor="silver">
				<th width="15%" nowrap>Name</th>
				<th width="5%" nowrap>Duration</th>
				<th width="20%" nowrap>Reason</th>
				<th nowrap>Notes</th>
				<th width="15%" nowrap>Location</th>
				<th width="8%" nowrap>Resources</th>
				<th width="5%" nowrap>Enabled</th>
				<th width="10%" nowrap></th>
			</tr>
		</thead>
		<tbody>
			<%	for(AppointmentType type : types) {
				String reasonCode = "";
				LookupListItem llItem = lookupListManager.findLookupListItemById(LoggedInInfo.getLoggedInInfoFromSession(request),type.getReasonCode());
				if (llItem != null){
					reasonCode = llItem.getLabel() + " - ";
				} 
			%>
			<tr>
				<td><%=type.getName()%></td>
				<td><%=Integer.toString(type.getDuration())%> min</td>
				<td><%=reasonCode + type.getReason() %></td>
				<td><%=type.getNotes() %></td>
				<td><%= type.getLocation() %></td>
				<td><%= type.getResources() %></td>
				<td>
					<label>
						<input type="checkbox" <%=type.isEnabled()?"checked=\"checked\"":""%> 
							onclick="setEnabled('../appointment/appointmentTypeAction.do?oper=toggleEnable&no=<%=type.getId()%><%=(selectedProviderNo != null?"&selectedProvider=" + selectedProviderNo:"")%>')">
					</label>
				</td>
				<td>
					<a href="../appointment/appointmentTypeAction.do?oper=edit&no=<%=type.getId()%><%=(selectedProviderNo != null?"&selectedProvider=" + selectedProviderNo:"")%>">edit</a>&nbsp;&nbsp;
					<a href="javascript:delType('../appointment/appointmentTypeAction.do?oper=del&no=<%= type.getId() %>')">delete</a>
				</td>
			</tr>
			<% } %>
		</tbody>
	</table>
</div>
</body>
</html>
