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
<security:oscarSec roleName="<%=roleName$%>" objectName="_con" rights="r" reverse="<%=true%>">
	<%authed=false; %>
	<%response.sendRedirect("../../securityError.jsp?type=_con");%>
</security:oscarSec>
<%
if(!authed) {
	return;
}
%>

<%@page import="org.oscarehr.util.LoggedInInfo"%>
<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean"%>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html"%>
<%@ taglib uri="/WEB-INF/struts-logic.tld" prefix="logic"%>
<%@ page import="org.oscarehr.common.dao.ConsultationRequestDao" %>
<%@ page import="org.oscarehr.util.SpringUtils" %>
<%@ page import="org.oscarehr.common.model.ConsultationRequest" %>
<%@ page import="java.util.List" %>
<%@ page import="org.oscarehr.common.model.Provider" %>
<%@ page import="org.oscarehr.PMmodule.dao.ProviderDao" %>
<%@ page import="org.apache.commons.lang.StringUtils" %>
<%@ page import="org.apache.commons.lang.time.DateFormatUtils" %>
<%@ page import="org.oscarehr.common.model.ConsultationServices" %>
<%@ page import="org.oscarehr.common.dao.ConsultationServiceDao" %>
<%@ page import="oscar.oscarDemographic.data.DemographicData" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="org.oscarehr.common.dao.ConsultationRequestArchiveDao" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.Date" %>

<%
String demo = request.getParameter("de");
String proNo = (String) session.getAttribute("user");
org.oscarehr.common.model.Demographic demographic = null;

oscar.oscarProvider.data.ProviderData pdata = new oscar.oscarProvider.data.ProviderData(proNo);
String team = pdata.getTeam();

if (demo != null ){
	DemographicData demoData = new oscar.oscarDemographic.data.DemographicData();
    demographic = demoData.getDemographic(LoggedInInfo.getLoggedInInfoFromSession(request), demo);    
}
else
    response.sendRedirect("../error.jsp");


ConsultationRequestDao conRequestDao = SpringUtils.getBean(ConsultationRequestDao.class);
ProviderDao providerDao = SpringUtils.getBean(ProviderDao.class);
ConsultationServiceDao serviceDao = SpringUtils.getBean(ConsultationServiceDao.class);
ConsultationRequestArchiveDao consultationRequestArchiveDao = SpringUtils.getBean(ConsultationRequestArchiveDao.class);
SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd hh:mm aaa");

List<ConsultationRequest> conRequests = conRequestDao.getConsultationsByDemographicOrderByDate(demographic.getDemographicNo());
%>

<html:html locale="true">
<head>
<script type="text/javascript" src="<%= request.getContextPath() %>/js/global.js"></script>
<title><bean:message
	key="oscarEncounter.oscarConsultationRequest.DisplayDemographicConsultationRequests.title" />
</title>
<html:base />

<!--META HTTP-EQUIV="Refresh" CONTENT="20;"-->

<link rel="stylesheet" type="text/css" media="all" href="../share/css/extractedFromPages.css"  />





</head>
<script language="javascript">
function BackToOscar()
{
       window.close();
}
function popupOscarRx(vheight,vwidth,varpage) { //open a new popup window
  var page = varpage;
  windowprops = "height="+vheight+",width="+vwidth+",location=no,scrollbars=yes,menubars=no,toolbars=no,resizable=yes,screenX=0,screenY=0,top=0,left=0";
  var popup=window.open(varpage, "<bean:message key="oscarEncounter.oscarConsultationRequest.DisplayDemographicConsultationRequests.msgConsReq"/>", windowprops);
  //if (popup != null) {
  //  if (popup.opener == null) {
  //    popup.opener = self;
  //  }
  //}
}
function popupOscarConS(vheight,vwidth,varpage) { //open a new popup window
  var page = varpage;
  windowprops = "height="+vheight+",width="+vwidth+",location=no,scrollbars=yes,menubars=no,toolbars=no,resizable=yes,screenX=0,screenY=0,top=0,left=0";
  var popup=window.open(varpage, "<bean:message key="oscarEncounter.oscarConsultationRequest.ConsultChoice.oscarConS"/>", windowprops);
  window.close();
}
</script>

<link rel="stylesheet" type="text/css" href="../encounterStyles.css">
<body class="BodyStyle" vlink="#0000FF" onload="window.focus()">
<!--  -->
<table class="MainTable" id="scrollNumber1" name="encounterTable">
	<tr class="MainTableTopRow">
		<td class="MainTableTopRowLeftColumn">Consultation</td>
		<td class="MainTableTopRowRightColumn">
		<table class="TopStatusBar">
			<tr>
				<td class="Header" NOWRAP><bean:message
					key="oscarEncounter.oscarConsultationRequest.DisplayDemographicConsultationRequests.msgConsReqFor" />
				<%=demographic.getLastName() %>, <%=demographic.getFirstName()%> <%=demographic.getSex()%>
				<%=demographic.getAge()%></td>
				<td></td>
			</tr>
		</table>
		</td>
	</tr>
	<tr style="vertical-align: top">
		<td class="MainTableLeftColumn">
		<table>
			<tr>
				<td NOWRAP><a
					href="javascript:popupOscarRx(700,960,'ConsultationFormRequest.jsp?de=<%=demo%>&teamVar=<%=team%>')">
				<bean:message
					key="oscarEncounter.oscarConsultationRequest.ConsultChoice.btnNewCon" /></a>
				</td>
			</tr>
		</table>
		</td>
		<td class="MainTableRightColumn">
		<table width="100%">
			<tr>
				<td><bean:message
					key="oscarEncounter.oscarConsultationRequest.DisplayDemographicConsultationRequests.msgClickLink" />
				</td>
			</tr>
			<tr>
				<td>

				<table border="0" width="80%" cellspacing="1">
					<tr>
						<th align="left" class="VCRheads" width="75"><bean:message
							key="oscarEncounter.oscarConsultationRequest.DisplayDemographicConsultationRequests.msgStatus" />
						</th>
						<th align="left" class="VCRheads"><bean:message
							key="oscarEncounter.oscarConsultationRequest.DisplayDemographicConsultationRequests.msgPat" />
						</th>
						<th align="left" class="VCRheads"><bean:message
							key="oscarEncounter.oscarConsultationRequest.DisplayDemographicConsultationRequests.msgProvider" />
						</th>
						<th align="left" class="VCRheads"><bean:message
							key="oscarEncounter.oscarConsultationRequest.DisplayDemographicConsultationRequests.msgService" />
						</th>
						<th align="left" class="VCRheads"><bean:message
							key="oscarEncounter.oscarConsultationRequest.DisplayDemographicConsultationRequests.msgRefDate" />
						</th>
						<th align="left" class="VCRheads">Revisions</th>
					</tr>
					<%  
						for (ConsultationRequest conRequest : conRequests) {
							String id = conRequest.getId().toString();
							String status = conRequest.getStatus();
							String providerName = "N/A";
							if (!StringUtils.isBlank(conRequest.getProviderNo())) {
								Provider creatingProvider = providerDao.getProvider(conRequest.getProviderNo());
								if (creatingProvider != null) {
									providerName = creatingProvider.getFormattedName();
								}
							}
							
							String serviceName = "";
							ConsultationServices service = serviceDao.find(conRequest.getServiceId());
							if (service != null) {
								serviceName = service.getServiceDesc();
							}
							
							List<String> revisionsLinks = new ArrayList<String>();
							Map<Integer, Date> revisions = consultationRequestArchiveDao.findArchiveIdAndDateByRequestId(conRequest.getId());
							for (Map.Entry<Integer, Date> revision : revisions.entrySet()) {
								String link = "<a href=\"javascript:popupOscarRx(700,960,'../../oscarEncounter/ViewRequest.do" +
										"?de=" + demographic.getDemographicNo() + "&requestId=" 
										+ conRequest.getId() + "&archiveId=" + revision.getKey() + "')\">";
								link += sdf.format(revision.getValue()) + "</a>";
								revisionsLinks.add(link);
							}
					%>
					<tr>
						<td class="stat<%=status%>" width="75">
						<% if (status.equals("1")){ %>
							<bean:message key="oscarEncounter.oscarConsultationRequest.DisplayDemographicConsultationRequests.msgNothingDone" />
						<% } else if(status.equals("2")) { %>
							<bean:message key="oscarEncounter.oscarConsultationRequest.DisplayDemographicConsultationRequests.msgSpecialistCall" />
						<% } else if(status.equals("3")) { %>
							<bean:message key="oscarEncounter.oscarConsultationRequest.DisplayDemographicConsultationRequests.msgPatCall" />
						<% } else if(status.equals("4")) { %>
							<bean:message key="oscarEncounter.oscarConsultationRequest.DisplayDemographicConsultationRequests.msgAppMade" />
						<% } %>
						</td>
						<td class="stat<%=status%>">
							<a href="javascript:popupOscarRx(700,960,'../../oscarEncounter/ViewRequest.do?de=<%=demo%>&requestId=<%=id%>')">
								<%=demographic.getFormattedName()%> 
							</a>
						</td>
						<td class="stat<%=status%>"><%=providerName%></td>
						<td class="stat<%=status%>">
							<a href="javascript:popupOscarRx(700,960,'../../oscarEncounter/ViewRequest.do?de=<%=demo%>&requestId=<%=id%>')">
								<%=serviceName%>
							</a>
						</td>
						<td class="stat<%=status%>"><%=DateFormatUtils.ISO_DATE_FORMAT.format(conRequest.getReferralDate())%></td>
						<td class="stat<%=status%>"><%=StringUtils.join(revisionsLinks,"</br>")%></td>
					</tr>
					<%}%>
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
</body>
</html:html>
