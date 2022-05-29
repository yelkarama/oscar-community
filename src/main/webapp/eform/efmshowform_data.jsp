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
<%@ page import="java.sql.*, oscar.eform.data.*"%>
<%@ page import="oscar.log.LogAction" %>
<%@ page import="org.oscarehr.util.LoggedInInfo" %>
<%@ page import="oscar.log.LogConst" %>
<%@page import="org.oscarehr.util.SpringUtils"%>
<%@ page import="org.oscarehr.PMmodule.dao.ProviderDao" %>
<%@ page import="org.oscarehr.common.dao.SystemPreferencesDao" %>
<%@ page import="org.oscarehr.common.model.SystemPreferences" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Calendar" %>

<%
	int pasteFaxNote = 0;
  	HashMap<String, Boolean> echartPreferencesMap = new HashMap<String, Boolean>();
  	SystemPreferencesDao systemPreferencesDao = SpringUtils.getBean(SystemPreferencesDao.class);
  	List<SystemPreferences> schedulePreferences = systemPreferencesDao.findPreferencesByNames(SystemPreferences.ECHART_PREFERENCE_KEYS);
  	for (SystemPreferences preference : schedulePreferences) {
            	if(preference.getName().equals("echart_paste_fax_note")) {
                	if(preference.getValueAsBoolean()) {
                        	pasteFaxNote = 1;
                	} else {
                        	pasteFaxNote = 0;
                	}
            	}
  	}

  	String timeStamp = new SimpleDateFormat("dd-MMM-yyyy hh:mm a").format(Calendar.getInstance().getTime());
    	String provider_no = (String) session.getValue("user");

	String id = request.getParameter("fid");
	String messageOnFailure = "No eform or appointment is available";
	



  if (id == null) {  // form exists in patient
      id = request.getParameter("fdid");
      String appointmentNo = request.getParameter("appointment");
      String eformLink = request.getParameter("eform_link");

      EForm eForm = new EForm(id);
      eForm.setContextPath(request.getContextPath());
      eForm.setOscarOPEN(request.getRequestURI());
      eForm.setFdid(id);
      
      if (appointmentNo != null) eForm.setAppointmentNo(appointmentNo);
      if (eformLink != null) eForm.setEformLink(eformLink);

      String parentAjaxId = request.getParameter("parentAjaxId");
      if(parentAjaxId != null) eForm.setAction(parentAjaxId);
	  String logData = "fdid=" + request.getParameter("fdid") + "\nFormName=" + eForm.getFormName();
	  if (request.getParameter("appointment") != null) { logData += "\nappointment_no=" + request.getParameter("appointment"); }
	  LogAction.addLog(LoggedInInfo.getLoggedInInfoFromSession(request), LogConst.READ, "eForm",
			  request.getParameter("fdid"), eForm.getDemographicNo(), logData);
         out.print(eForm.getFormHtml());
	 String providerName = "";
          if(null != provider_no){
                        ProviderDao proDao = SpringUtils.getBean(ProviderDao.class);
                        providerName = proDao.getProviderName(provider_no);
          }
          String setProviderName = "<script type=\"text/javascript\"> var setProviderName='" + providerName + "';</script>";
          out.print(setProviderName);
          String setEformName = "<script type=\"text/javascript\"> var setEformName='" + eForm.getFormName() + "';</script>";
          out.print(setEformName);
          String currentTimeStamp = "<script type=\"text/javascript\"> var currentTimeStamp='" + timeStamp + "';</script>";
          out.print(currentTimeStamp);
          String pasteFaxNoteStr = "<script type=\"text/javascript\"> var pasteFaxNote='" + String.valueOf(pasteFaxNote) + "';</script>";
          out.print(pasteFaxNoteStr);
  } else {  //if form is viewed from admin screen
      EForm eForm = new EForm(id, "-1"); //form cannot be submitted, demographic_no "-1" indicate this specialty
      eForm.setContextPath(request.getContextPath());
      eForm.setupInputFields();
      eForm.setOscarOPEN(request.getRequestURI());
      eForm.setImagePath();
	  String logData = "fdid=" + request.getParameter("fdid") + "\nid=" + id;
	  if (request.getParameter("appointment") != null) { logData += "\nappointment_no=" + request.getParameter("appointment"); }
	  LogAction.addLog(LoggedInInfo.getLoggedInInfoFromSession(request), LogConst.READ, "eForm",
			  request.getParameter("fdid"), eForm.getDemographicNo(), logData);
      out.print(eForm.getFormHtml());
  }
%>
<%
String iframeResize = (String) session.getAttribute("useIframeResizing");
if(iframeResize !=null && "true".equalsIgnoreCase(iframeResize)){ %>
<script src="<%=request.getContextPath() %>/library/pym.js"></script>
<script>
    var pymChild = new pym.Child({ polling: 500 });
</script>
<%}%>
