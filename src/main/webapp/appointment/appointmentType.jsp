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
<%@ page import="java.util.*, java.sql.*, oscar.*, java.text.*, java.lang.*,java.net.*, oscar.appt.*, org.oscarehr.common.dao.AppointmentTypeDao, org.oscarehr.common.model.AppointmentType, org.oscarehr.util.SpringUtils" %>
<%@ page import="org.oscarehr.common.dao.LookupListItemDao" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<%
	AppointmentTypeDao appDao = (AppointmentTypeDao) SpringUtils.getBean("appointmentTypeDao");
	List<AppointmentType> types = appDao.listAll();
	LookupListItemDao lookupListItemDao = SpringUtils.getBean(LookupListItemDao.class);
%>
<html>
<head>
<title>Appointment Type</title>
<script type="text/javascript">
var durations = [];
var reasonCodes = [];
var reasons = [];
var locations = [];
var notes = [];
var resources = [];
var names = [];
<%   for(int j = 0;j < types.size(); j++) { %>
		durations.push('<%= types.get(j).getDuration() %>');
		reasonCodes.push('<%= types.get(j).getReasonCode() %>_<%=lookupListItemDao.find(types.get(j).getReasonCode())!=null?lookupListItemDao.find(types.get(j).getReasonCode()).getLabel():""%>');
		reasons.push('<%= types.get(j).getReason() %>');
		locations.push('<%= types.get(j).getLocation() %>');
		notes.push('<%= types.get(j).getNotes() %>');
		resources.push('<%= types.get(j).getResources() %>');
		names.push('<%= types.get(j).getName() %>');
<%   } %>
	var typeSel = '';
	var reasonCodeSel = '';
	var reasonCodeSelLabel = '';
	var reasonSel = '';
	var locSel = '';
	var durSel = 15;
	var notesSel = '';
	var resSel = '';

function getFields(idx) {
	if(idx>0) {
		typeSel = document.getElementById('durId').innerHTML = names[idx-1];
		durSel = document.getElementById('durId').innerHTML = durations[idx-1];
        reasonCodeSelLabel = document.getElementById('reasonCodeId').innerHTML = reasonCodes[idx-1].split('_')[1];
        reasonCodeSel = reasonCodes[idx-1].split('_')[0];
		reasonSel = document.getElementById('reasonId').innerHTML = reasons[idx-1];
		locSel = document.getElementById('locId').innerHTML = locations[idx-1];
		notesSel = document.getElementById('notesId').innerHTML = notes[idx-1];
		resSel = document.getElementById('resId').innerHTML = resources[idx-1];
	}	
}
</script>
</head>
<body bgcolor="#EEEEFF" bgproperties="fixed" topmargin="0" leftmargin="0" rightmargin="0">
<table width="100%">
	<tr>
		<td width="100">Type</td>
		<td width="200">
			<select id="typesId" width="25" maxsize="50" onchange="getFields(this.selectedIndex)">
				<option value="-1">Select type</option>
<%   for(int i = 0;i < types.size(); i++) { 
%>
				<option value="<%= i %>" <%= (request.getParameter("type").equals(types.get(i).getName())?" selected":"") %>><%= types.get(i).getName() %></option>
<%   } %>
			</select>
		</td>
		<td><input type="button" name="Select" value="Select" onclick="window.opener.setType(typeSel,reasonCodeSel,reasonSel,locSel,durSel,notesSel,resSel); window.close()">
	</tr>
	<tr>
		<td>Duration</td>
		<td colspan="2"><div id="durId"></div></td>
	</tr>
	<tr>
		<td>Reason Code</td>
		<td colspan="2"><span id="reasonCodeId"/></td>
	</tr>
	<tr>
		<td>Reason</td>
		<td colspan="2"><span id="reasonId"/></td>
	</tr>
	<tr>
		<td>Location</td>
		<td colspan="2"><span id="locId"/></td>
	</tr>
	<tr>
		<td>Notes</td>
		<td colspan="2"><span id="notesId"/></td>
	</tr>
	<tr>
		<td>Resources</td>
		<td colspan="2"><span id="resId"/></td>
	</tr>
</table>
</body>
<script type="text/javascript">
	getFields(document.getElementById('typesId').selectedIndex);
</script>
</html>
