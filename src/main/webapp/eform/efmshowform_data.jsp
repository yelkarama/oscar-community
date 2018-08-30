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
<%@page import="org.oscarehr.util.LoggedInInfo"%>
<%@ page import="java.sql.*, oscar.eform.data.*"%>
<%
	//String id = request.getParameter("fid");
	LoggedInInfo loggedInInfo=LoggedInInfo.getLoggedInInfoFromSession(request);
   	String providerName = "";
   	if(null != loggedInInfo){
   		providerName = loggedInInfo.getLoggedInProvider().getFullName();
   	}
	String id = request.getParameter("fdid");
	String messageOnFailure = "No eform or appointment is available";
	String setDocName = "<script type=\"text/javascript\"> var setDocName='" + providerName + "';</script>";
	out.print(setDocName);
  if (id != null) {  // form exists in patient
      //id = request.getParameter("fdid");
      String appointmentNo = request.getParameter("appointment");
      String eformLink = request.getParameter("eform_link");

      EForm eForm = new EForm(id);
      
      String setEformName = "<script type=\"text/javascript\"> var setEformName='" + eForm.getFormName() + "';</script>";
  	  out.print(setEformName);
      
      eForm.setContextPath(request.getContextPath());
      eForm.setOscarOPEN(request.getRequestURI());
      if ( appointmentNo != null ) {
    	  eForm.setAppointmentNo(appointmentNo);
    	  eForm.setupAppointmentNo(appointmentNo);
      }
      if ( eformLink != null ) eForm.setEformLink(eformLink);

      String parentAjaxId = request.getParameter("parentAjaxId");
      if( parentAjaxId != null ) eForm.setAction(parentAjaxId);
      String setWhite = "<div id=\"root\" style=\"background-color:#ffffff\">";
      eForm.setFormHtml(eForm.getFormHtml().replace("<div id=\"root\">",setWhite));
      String oscarJS = request.getContextPath() + "/share/javascript/";
      String path_js = "<script type=\"text/javascript\" src=\"" + oscarJS + "eforms/printControl.js\"></script>";
      
      String replaceJs = "<script type=\"text/javascript\" src=\""+oscarJS+"eforms/jspdf.debug.js\"></script>"
    			+ "<script type=\"text/javascript\" src=\""+oscarJS+"eforms/html2canvas.js\"></script>"
    			+ "<script type=\"text/javascript\" src=\""+oscarJS+"eforms/dom-to-image.js\"></script>"
    			+ "<script type=\"text/javascript\" src=\""+oscarJS+"eforms/renderPDF.js\"></script>"
    			+ "<script type=\"text/javascript\" src=\""+oscarJS+"eforms/printControl.js\"></script>"	;
    			eForm.setFormHtml(eForm.getFormHtml().replace(path_js,replaceJs));
      out.print(eForm.getFormHtml());
  } else {  //if form is viewed from admin screen
	  id = request.getParameter("fid");
      EForm eForm = new EForm(id, "-1"); //form cannot be submitted, demographic_no "-1" indicate this specialty
      String setEformName = "<script type=\"text/javascript\"> var setEformName='" + eForm.getFormName() + "';</script>";
  	  out.print(setEformName);
  	  
      eForm.setContextPath(request.getContextPath());
      eForm.setupInputFields();
      eForm.setOscarOPEN(request.getRequestURI());
      eForm.setImagePath();
      String setWhite = "<div id=\"root\" style=\"background-color:#ffffff\">";
      eForm.setFormHtml(eForm.getFormHtml().replace("<div id=\"root\">",setWhite));
      String oscarJS = request.getContextPath() + "/share/javascript/";
      String path_js = "<script type=\"text/javascript\" src=\"" + oscarJS + "eforms/printControl.js\"></script>";
      
      String replaceJs = "<script type=\"text/javascript\" src=\""+oscarJS+"eforms/jspdf.debug.js\"></script>"
    			+ "<script type=\"text/javascript\" src=\""+oscarJS+"eforms/html2canvas.js\"></script>"
    			+ "<script type=\"text/javascript\" src=\""+oscarJS+"eforms/dom-to-image.js\"></script>"
    			+ "<script type=\"text/javascript\" src=\""+oscarJS+"eforms/renderPDF.js\"></script>"
    			+ "<script type=\"text/javascript\" src=\""+oscarJS+"eforms/printControl.js\"></script>"	;
    			eForm.setFormHtml(eForm.getFormHtml().replace(path_js,replaceJs));
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