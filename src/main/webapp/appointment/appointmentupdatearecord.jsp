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
<security:oscarSec roleName="<%=roleName$%>" objectName="_appointment" rights="u" reverse="<%=true%>">
	<%authed=false; %>
	<%response.sendRedirect("../securityError.jsp?type=_appointment");%>
</security:oscarSec>
<%
	if(!authed) {
		return;
	}
%>

<%@ page import="java.sql.*, java.util.*, oscar.*, oscar.util.*, org.oscarehr.common.OtherIdManager"%>
<%@ page import="org.oscarehr.event.EventService"%>
<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean"%>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html"%>
<%@page import="org.oscarehr.common.model.Appointment" %>
<%@page import="org.oscarehr.util.SpringUtils" %>
<%@page import="oscar.util.ConversionUtils" %>
<%@ page import="oscar.log.LogAction" %>
<%@ page import="org.oscarehr.util.LoggedInInfo" %>
<%@ page import="oscar.log.LogConst" %>
<%@ page import="org.oscarehr.common.model.AppointmentReminder" %>
<%@ page import="org.oscarehr.common.model.Appointment" %>
<%@ page import="org.oscarehr.common.dao.AppointmentReminderDao" %>
<%@ page import="org.oscarehr.common.dao.AppointmentReminderStatusDao" %>
<%@ page import="org.oscarehr.common.model.AppointmentReminderStatus" %>
<%@ page import="org.oscarehr.common.model.OnlineBookingInfo" %>
<%@ page import="org.oscarehr.common.dao.AppointmentArchiveDao" %>
<%@ page import="org.oscarehr.common.dao.OscarAppointmentDao" %>
<%@ page import="org.oscarehr.common.dao.DemographicExtDao" %>
<%@ page import="org.oscarehr.common.dao.DemographicDao" %>
<%@ page import="org.oscarehr.common.model.Demographic" %>
<%@ page import="org.oscarehr.common.model.DemographicExt" %>
<%@ page import="org.oscarehr.common.dao.OnlineBookingInfoDao" %>
<%
	AppointmentArchiveDao appointmentArchiveDao = (AppointmentArchiveDao)SpringUtils.getBean("appointmentArchiveDao");
	OscarAppointmentDao appointmentDao = (OscarAppointmentDao)SpringUtils.getBean("oscarAppointmentDao");
	DemographicDao demographicDao = SpringUtils.getBean(DemographicDao.class);
	DemographicExtDao demographicExtDao = SpringUtils.getBean(DemographicExtDao.class);
    String changedStatus = null;
%>
<html:html locale="true">
<head>
<script type="text/javascript" src="<%= request.getContextPath() %>/js/global.js"></script>
</head>

<body>
<center>
<table border="0" cellspacing="0" cellpadding="0" width="90%">
	<tr bgcolor="#486ebd">
		<th align="CENTER"><font face="Helvetica" color="#FFFFFF">
		<bean:message key="appointment.appointmentupdatearecord.msgMainLabel" /></font></th>
	</tr>
</table>
<%
  String updateuser = (String) session.getAttribute("user");

  int rowsAffected = 0;
  boolean appointmentRemindersEnabled = false;
  String appointmentReminderProperties = OscarProperties.getInstance().getProperty("enable_appointment_reminders");
  if (appointmentReminderProperties != null && appointmentReminderProperties.equals("true")) {
      	appointmentRemindersEnabled = true;
  }
  Appointment appt = appointmentDao.find(Integer.parseInt(request.getParameter("appointment_no")));
  appointmentArchiveDao.archiveAppointment(appt);
  Appointment oldAppointment = new Appointment(appt);
  AppointmentReminderDao appointmentReminderDao = SpringUtils.getBean(AppointmentReminderDao.class);
  AppointmentReminderStatusDao appointmentReminderStatusDao = SpringUtils.getBean(AppointmentReminderStatusDao.class);
  AppointmentReminder appointmentReminder = appointmentReminderDao.getByAppointmentNo(appt.getId());
  OnlineBookingInfoDao onlineBookingInfoDao = SpringUtils.getBean(OnlineBookingInfoDao.class);
  OnlineBookingInfo confirmedStatus = onlineBookingInfoDao.getOnlineBookingPreference("reminder_confirmed_status", "CLINIC");

  //Did the appt status change ?
  if(!appt.getStatus().equals(request.getParameter("status")) && request.getParameter("status") != null){
	  changedStatus = request.getParameter("status");

	  if (appointmentRemindersEnabled && confirmedStatus != null && confirmedStatus.getValue() != null && changedStatus.equals(confirmedStatus.getValue()) && appointmentReminder != null) {
	      appointmentReminder.setConfirmed(true);
	      appointmentReminderDao.merge(appointmentReminder);
		  AppointmentReminderStatus appointmentReminderStatus = appointmentReminderStatusDao.getByAppointmentReminderNo(appointmentReminder.getId());
		  if (appointmentReminderStatus != null) {
		      appointmentReminderStatus.setAllDelivered(true);
		      appointmentReminderStatusDao.merge(appointmentReminderStatus);
		  }
	  }
  }

   if (request.getParameter("buttoncancel")!=null && (request.getParameter("buttoncancel").equals("Cancel Appt") || request.getParameter("buttoncancel").equals("No Show"))) {
	  changedStatus = request.getParameter("buttoncancel").equals("Cancel Appt")?"C":"N";
	  if(appt != null) {
      	appt.setStatus(request.getParameter("buttoncancel").equals("Cancel Appt")?"C":"N");
      	appt.setLastUpdateUser(updateuser);
      	appointmentDao.merge(appt);
      	rowsAffected=1;

	if (appointmentRemindersEnabled && "C".equals(changedStatus)) {
		if (appointmentReminder != null) {
			appointmentReminder.setCancelled(true);
			appointmentReminderDao.merge(appointmentReminder);
			AppointmentReminderStatus appointmentReminderStatus = appointmentReminderStatusDao.getByAppointmentReminderNo(appointmentReminder.getId());
			if (appointmentReminderStatus != null) {
				appointmentReminderStatus.setAllDelivered(true);
				appointmentReminderStatusDao.merge(appointmentReminderStatus);
			}
		}
      }

  } else {

	  if(appt != null) {
		  	if (request.getParameter("demographic_no")!=null && !(request.getParameter("demographic_no").equals(""))) {
		  		appt.setDemographicNo(Integer.parseInt(request.getParameter("demographic_no")));

		  		Demographic demographic = demographicDao.getDemographic(request.getParameter("demographic_no"));
				DemographicExt demographicExt = demographicExtDao.getDemographicExt(Integer.parseInt(request.getParameter("demographic_no")), "demo_cell");

				appointmentReminder = appointmentReminderDao.getByAppointmentNo(appt.getId());
				if (appointmentReminder != null && demographic != null) {
					String reminderCell = demographicExt==null?"":demographicExt.getValue().isEmpty()?"":demographicExt.getValue().substring(0, 1).equals("1")?"+" + demographicExt.getValue().replaceAll("[^0-9]", ""):"+1" + demographicExt.getValue().replaceAll("[^0-9]", "");
					String reminderPhone = demographic.getPhone()==null?"":demographic.getPhone().isEmpty()?"":demographic.getPhone().substring(0, 1).equals("1") ? "+" + demographic.getPhone().replaceAll("[^0-9]", "") : "+1" + demographic.getPhone().replaceAll("[^0-9]", "");

				    appointmentReminder.setReminderCell(reminderCell);
				    appointmentReminder.setReminderPhone(reminderPhone);
				    appointmentReminder.setReminderEmail(demographic.getEmail()==null?"":demographic.getEmail());
				    appointmentReminderDao.merge(appointmentReminder);
				}
		 	} else {
			 	appt.setDemographicNo(0);
		 	}
			appt.setAppointmentDate(ConversionUtils.fromDateString(request.getParameter("appointment_date")));
			appt.setStartTime(new java.sql.Time(ConversionUtils.fromTimeString(MyDateFormat.getTimeXX_XX_XX(request.getParameter("start_time"))).getTime()));
			appt.setEndTime(new java.sql.Time(ConversionUtils.fromTimeString(MyDateFormat.getTimeXX_XX_XX(request.getParameter("end_time"))).getTime()));
			appt.setName(request.getParameter("keyword"));
			appt.setNotes(request.getParameter("notes"));
			appt.setReason(request.getParameter("reason"));
			appt.setLocation(request.getParameter("location"));
			appt.setResources(request.getParameter("resources"));
			appt.setType(request.getParameter("type"));
			appt.setStyle(request.getParameter("style"));
			appt.setBilling(request.getParameter("billing"));
			appt.setStatus(request.getParameter("status"));
			appt.setLastUpdateUser(updateuser);
			appt.setRemarks(request.getParameter("remarks"));
			appt.setUpdateDateTime(new java.util.Date());
			appt.setUrgency((request.getParameter("urgency")!=null)?request.getParameter("urgency"):"");
			appt.setReasonCode(Integer.valueOf(request.getParameter("reasonCode")));
			
			appointmentDao.merge(appt);
			rowsAffected=1;
	  }
	  
  }
  if (rowsAffected == 1) {
	  List<ChangedField> changedFields = new ArrayList<ChangedField>(ChangedField.getChangedFieldsAndValues(oldAppointment, appt));
	  LogAction.addLog(LoggedInInfo.getLoggedInInfoFromSession(request), LogConst.UPDATE, LogConst.CON_APPT,
			  "appointment_no=" + appt.getId(), String.valueOf(appt.getDemographicNo()), changedFields);
%>
<p>
<h1><bean:message
	key="appointment.appointmentupdatearecord.msgUpdateSuccess" /></h1>

<script LANGUAGE="JavaScript">
    <% 
        if(!(request.getParameter("printReceipt")==null) && request.getParameter("printReceipt").equals("1")) {
    %>
            popupPage(350,750,'printappointment.jsp?appointment_no=<%=request.getParameter("appointment_no")%>') ;
    <%}%>
	self.opener.refresh();
	self.close();
</script>
<%
	String apptNo = request.getParameter("appointment_no");
	String mcNumber = request.getParameter("appt_mc_number");
	OtherIdManager.saveIdAppointment(apptNo, "appt_mc_number", mcNumber);
	
	if(changedStatus != null){
		EventService eventService = SpringUtils.getBean(EventService.class); //updating an appt from the appt update screen delete doesn't work
		eventService.appointmentStatusChanged(this,apptNo.toString(), appt.getProviderNo(), changedStatus);
	}
	// End External Prescriber 
  } else {
%>
<p>
<h1><bean:message
	key="appointment.appointmentupdatearecord.msgUpdateFailure" /></h1>

<%
  }
%>
<p></p>
<hr width="90%"/>
<form>
<input type="button" value="<bean:message key="global.btnClose"/>" onClick="closeit()">
</form>
</center>
</body>
</html:html>
