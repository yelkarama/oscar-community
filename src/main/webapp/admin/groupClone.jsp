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

<%@page import="org.joda.time.DateTimeConstants"%>
<%@page import="org.oscarehr.util.LoggedInInfo"%>
<%@page import="org.oscarehr.common.GroupProviderUtil"%>
<%@ taglib uri="/WEB-INF/security.tld" prefix="security"%>
<%
      String roleName$ = (String)session.getAttribute("userrole") + "," + (String) session.getAttribute("user");
      boolean authed=true;
%>
<security:oscarSec roleName="<%=roleName$%>" objectName="_admin" rights="w" reverse="<%=true%>">
	<%authed=false; %>
	<%response.sendRedirect("../securityError.jsp?type=_admin");%>
</security:oscarSec>
<%
if(!authed) {
	return;
}
%>


<%@ page import="java.util.*,oscar.oscarReport.pageUtil.*"%>
<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean"%>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html"%>
<%@ taglib uri="/WEB-INF/struts-logic.tld" prefix="logic"%>

<html:html locale="true">
<head>
<script type="text/javascript" src="<%= request.getContextPath() %>/js/global.js"></script>
<title>Groups - Clone</title>
<link rel="stylesheet" type="text/css" media="all" href="../share/css/extractedFromPages.css"  />
<link rel="stylesheet" type="text/css" href="../oscarEncounter/encounterStyles.css">
<link rel="stylesheet" type="text/css" media="all" href="../share/calendar/calendar.css" title="win2k-cold-1" />

<script type="text/javascript" src="../share/calendar/calendar.js" ></script>
<script type="text/javascript" src="../share/calendar/lang/<bean:message key="global.javascript.calendar"/>" ></script>
<script type="text/javascript" src="../share/calendar/calendar-setup.js" ></script>
<script type="text/javascript" src="../share/javascript/prototype.js"></script>

<script type="text/javascript" src="../js/jquery-1.12.3.js"></script>
<script>
function validateForm() {
	var name = $("#name").val();
	  
	var lastName = $("#lastName").val();
	 var firstName = $("#firstName").val();
	 
	 var startDate = $("#startDate").val();
	 var endDate = $("#endDate").val();
	 
	 
	 if(name.length == 0) {
		 alert('Provide a series name');
		 return false;
	 }
	 
	 if(lastName.length == 0) {
		 alert('Provide a last name for the new group provider');
		 return false;
	 }
	 if(firstName.length == 0) {
		 alert('Provide a first name for the new group provider');
		 return false;
	 }
	 
	 if(startDate.length == 0) {
		 alert('Provide a start date for the new group provider');
		 return false;
	 }
	 
	 if(endDate.length == 0) {
		 alert('Provide a end date for the new group provider');
		 return false;
	 }
	 
	 if ($("input:checkbox[name='days_of_week']:checked").length == 0)
	 {
	    alert('Please choose atleast a day of the seek to apply schedule to');
	    return false;
	 }
	return true;
}
</script>

</head>

<body class="BodyStyle" vlink="#0000FF">
<%
	if("clone".equals(request.getParameter("action"))) {
		
		String lastName = request.getParameter("lastName");
		String firstName = request.getParameter("firstName");
		String startDate = request.getParameter("startDate");
		String endDate = request.getParameter("endDate");
		String providerNo = request.getParameter("providerNo");
		String name = request.getParameter("name");
		String[] daysOfWeek = request.getParameterValues("days_of_week");
		
		GroupProviderUtil util = new GroupProviderUtil();
		util.cloneExistingGroupProvider(LoggedInInfo.getLoggedInInfoFromSession(request), providerNo, firstName, lastName, name, startDate, endDate, daysOfWeek);
		
		%>
		<script>
			$(document).ready(function(){
				alert('Clone is complete.');
				window.close();
			});
		</script>
		<%
		
	} else {
%>
<form action="groupClone.jsp" onsubmit="return validateForm()">
	<input type="hidden" name="action" value="clone"/>
	<input type="hidden" name="providerNo" value="<%=request.getParameter("provider_no")%>"/>
	
	<table class="MainTable" id="scrollNumber1" name="encounterTable">
		<tr class="MainTableTopRow">
			<td class="MainTableTopRowLeftColumn">Groups</td>
			<td class="MainTableTopRowRightColumn">
			<table class="TopStatusBar">
				<tr>
					<td>Clone Existing Group Provider</td>
				</tr>
			</table>
			</td>
		</tr>
		<tr>
			<td class="MainTableLeftColumn"></td>
			<td class="MainTableRightColumn">
			<table border=0 cellspacing=4 width="70%">
				<tr>
					<td>
					<table>
						
						<tr>
							<td colspan="2"></td>
						</tr>
						<tr>
							<th align="left" class="td.tite" width="20%">Series Name:
							
							</th>
							<td><input type="text" id="name" name="name"/></td>
						</tr>
						
						<tr>
							<th align="left" class="td.tite" width="20%">Last Name:
							
							</th>
							<td><input type="text" id="lastName" name="lastName"/></td>
						</tr>
						<tr>
							<th align="left" class="td.tite" width="20%">First Name:
							
							</th>
							<td><input type="text" id="firstName" name="firstName"/></td>
						</tr>
						<tr>
							<th align="left" class="td.tite" width="20%">Start Date:
							</th>
							<td><input type="text" id="startDate" name="startDate" /><img id="startDate_cal" title="Calendar" src="../images/cal.gif" alt="Calendar" border="0" /></td>
						</tr>
						<tr>
							<th align="left" class="td.tite" width="20%">End Date:
							</th>
							<td><input type="text" id="endDate" name="endDate" /><img id="endDate_cal" title="Calendar" src="../images/cal.gif" alt="Calendar" border="0" /></td>
						</tr>
						<tr>
							<th align="left" class="td.tite" width="20%">Apply Schedule:
							</th>
							<td>
								<input type="checkbox" id="days_of_week" name="days_of_week" value="<%=DateTimeConstants.MONDAY%>"/>Monday&nbsp;
								<input type="checkbox" id="days_of_week" name="days_of_week" value="<%=DateTimeConstants.TUESDAY%>"/>Tuesday&nbsp;
								<input type="checkbox" id="days_of_week" name="days_of_week" value="<%=DateTimeConstants.WEDNESDAY%>"/>Wednesday&nbsp;
								<input type="checkbox" id="days_of_week" name="days_of_week" value="<%=DateTimeConstants.THURSDAY%>"/>Thursday&nbsp;
								<input type="checkbox" id="days_of_week" name="days_of_week" value="<%=DateTimeConstants.FRIDAY%>"/>Friday<br/>
								<input type="checkbox" id="days_of_week" name="days_of_week" value="<%=DateTimeConstants.SATURDAY%>"/>Saturday&nbsp;
								<input type="checkbox" id="days_of_week" name="days_of_week" value="<%=DateTimeConstants.SUNDAY%>"/>Sunday&nbsp;
						</tr>
						<tr>
							<td>
							<table>
								<tr>
									<td></td>
									<td><input type="submit" name="submit"
										value="Submit"/></td>
								</tr>
							</table>
							</td>
						</tr>
					
						</td>
						</tr>
					</table>
					</td>
				</tr>
			</table>
			</td>
		</tr>
		<tr>
			<td class="MainTableBottomRowLeftColumn"></td>
			<td class="MainTableBottomRowRightColumn"></td>
		</tr>
	</table>
</form>
<script type="text/javascript">
 
      Calendar.setup({ inputField : "startDate", ifFormat : "%Y-%m-%d", showsTime :false, button : "startDate_cal", singleClick : true, step : 1 });
      Calendar.setup({ inputField : "endDate", ifFormat : "%Y-%m-%d", showsTime :false, button : "endDate_cal", singleClick : true, step : 1 });
  
</script>

<% } %>
            
</body>
</html:html>
