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
<security:oscarSec roleName="<%=roleName$%>" objectName="_admin,_admin.consult" rights="w" reverse="<%=true%>">
	<%authed=false; %>
	<%response.sendRedirect("../../../securityError.jsp?type=_admin&type=_admin.consult");%>
</security:oscarSec>
<%
if(!authed) {
	return;
}
%>
<%@ page import="org.owasp.encoder.Encode" %>
<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean"%>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html"%>
<%@ taglib uri="/WEB-INF/struts-logic.tld" prefix="logic"%>
<html:html locale="true">
<jsp:useBean id="displayServiceUtil" scope="request"
	class="oscar.oscarEncounter.oscarConsultationRequest.config.pageUtil.EctConDisplayServiceUtil" />
<%
displayServiceUtil.estSpecialistVector();
%>
<head>
<script type="text/javascript" src="<%= request.getContextPath() %>/js/global.js"></script>
<title><bean:message
	key="oscarEncounter.oscarConsultationRequest.config.EditSpecialists.title" />
</title>
<html:base />
<!--<link rel="stylesheet" type="text/css" media="all" href="../share/css/extractedFromPages.css"  />-->
<link href="<%=request.getContextPath() %>/css/bootstrap.css" rel="stylesheet" type="text/css">
<link href="<%=request.getContextPath() %>/css/bootstrap-responsive.css" rel="stylesheet" type="text/css">
<link href="<%=request.getContextPath() %>/css/DT_bootstrap.css" rel="stylesheet" type="text/css">
<script type="text/javascript" src="<%=request.getContextPath() %>/js/jquery-1.9.1.js"></script>
<script type="text/javascript" src="<%=request.getContextPath() %>/js/jquery.dataTables.1.10.11.min.js"></script>
<style>
.dtable{
    table-layout: fixed;
    word-wrap:break-word;
    font-size: 12px;
}
.MainTableLeftColumn td{
    font-size: 12px;

}
</style>
</head>
<script language="javascript">
function BackToOscar()
{
       window.close();
}
</script>
<!--<link rel="stylesheet" type="text/css" href="../../encounterStyles.css">-->
<body class="BodyStyle"  vlink="#0000FF">

<html:errors />
<!--  -->
<table class="MainTable" id="scrollNumber1" name="encounterTable">
	<tr class="MainTableTopRow">
		<td class="MainTableTopRowLeftColumn"><h4>Consultation</h4></td>
		<td class="MainTableTopRowRightColumn">
		<table class="TopStatusBar">
			<tr>
				<td class="Header"><h4><bean:message
					key="oscarEncounter.oscarConsultationRequest.config.EditSpecialists.title" /></h4>
				</td>
			</tr>
		</table>
		</td>
	</tr>
	<tr style="vertical-align: top">
		<td class="MainTableLeftColumn">
		<%oscar.oscarEncounter.oscarConsultationRequest.config.pageUtil.EctConTitlebar titlebar = new oscar.oscarEncounter.oscarConsultationRequest.config.pageUtil.EctConTitlebar(request);
                  out.print(titlebar.estBar(request));
                  %>
		</td>
		<td class="MainTableRightColumn">
		<table cellpadding="0" cellspacing="2"
			style="border-collapse: collapse" bordercolor="#111111" width="100%"
			height="100%"
            >

			<!----Start new rows here-->
			<tr>
                            <td><%--bean:message
					key="oscarEncounter.oscarConsultationRequest.config.EditSpecialists.msgCheckOff" /--%><br>
				<bean:message
					key="oscarEncounter.oscarConsultationRequest.config.EditSpecialists.msgClickOn" /><br>


				</td>
			</tr>
			<tr>
				<td><html:form action="/oscarEncounter/EditSpecialists">
					<%-- input type="submit" name="delete"
						value="<bean:message key="oscarEncounter.oscarConsultationRequest.config.EditSpecialists.btnDeleteSpecialist"/>"--%>
					<div class="ChooseRecipientsBox1">
					<table class="table table-condensed table-striped dtable" id="specialistsTbl">
                        <thead>
						    <tr>
							    <!--<th>&nbsp;</th>-->
							    <th><bean:message
								    key="oscarEncounter.oscarConsultationRequest.config.EditSpecialists.specialist" />
							    </th>
							    <th style="width: 300px;"><bean:message
								    key="oscarEncounter.oscarConsultationRequest.config.EditSpecialists.address" />
							    </th>
							    <th><bean:message
								    key="oscarEncounter.oscarConsultationRequest.config.EditSpecialists.phone" />
							    </th>
							    <th><bean:message
								    key="oscarEncounter.oscarConsultationRequest.config.EditSpecialists.fax" />
							    </th>
						    </tr>
                        </thead>
                        <tbody>
						<tr>
							<!--<div class="ChooseRecipientsBox1">--> <%

                                 for(int i=0;i < displayServiceUtil.specIdVec.size(); i++){
                                 String  specId     = displayServiceUtil.specIdVec.elementAt(i);
                                 String  fName      = Encode.forHtml(displayServiceUtil.fNameVec.elementAt(i));
                                 String  lName      = Encode.forHtml(displayServiceUtil.lNameVec.elementAt(i));
                                 String  proLetters = displayServiceUtil.proLettersVec.elementAt(i);
                                 proLetters = (proLetters==null?"":Encode.forHtml(displayServiceUtil.proLettersVec.elementAt(i)));
                                 String  address    = Encode.forHtml(displayServiceUtil.addressVec.elementAt(i));
                                 String  phone      = Encode.forHtml(displayServiceUtil.phoneVec.elementAt(i));
                                 String  fax        = Encode.forHtml(displayServiceUtil.faxVec.elementAt(i));
                              %>
							
						
							<!--<td><input type="checkbox" name="specialists"
								value="<%=specId%>"></td>-->
							<td>
							<%
                                      out.print("<a href=\"../../EditSpecialists.do?specId="+specId+"\"/>");
                                      out.print(lName+" "+fName+" "+proLetters);
                                      out.print("</a>");
                                    %>
							</td>
							<td style="overflow:hidden; white-space: nowrap; text-overflow:ellipsis" title="<%=address%>"><%=address %></td>
							<td><%=phone%></td>
							<td><%=fax%></td>
						</tr>
						<% }%>
						
</tbody>
					</table>
					</div>
				</html:form></td>
			</tr>
			<!----End new rows here-->

			<tr height="100%">
				<td></td>
			</tr>
		</table>
		</td>
	</tr>
	<tr>
		<td class="MainTableBottomRowLeftColumn"></td>
		<td class="MainTableBottomRowRightColumn"></td>
	</tr>
</table>

<script>
$(document).ready(function() {
    $('#specialistsTbl').DataTable({
       "pageLength": 15
    } );
} );
</script>
</body>
</html:html>