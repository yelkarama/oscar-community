<%@page import="org.oscarehr.casemgmt.web.NoteDisplay"%>
<%@page import="org.oscarehr.util.LoggedInInfo"%>
<%@page import="org.oscarehr.casemgmt.service.NoteSelectionResult"%>
<%@page import="org.oscarehr.casemgmt.service.NoteSelectionCriteria"%>
<%@page import="org.oscarehr.casemgmt.service.NoteService"%>
<%@page import="org.oscarehr.casemgmt.web.CaseManagementViewAction"%>
<%@page import="java.util.List"%>
<%@page import="org.oscarehr.common.model.Demographic"%>
<%@page import="org.oscarehr.common.dao.DemographicDao"%>
<%@page import="org.oscarehr.util.SpringUtils"%>

<%

LoggedInInfo loggedInInfo = LoggedInInfo.getLoggedInInfoFromSession(request);

DemographicDao demographicDao = SpringUtils.getBean(DemographicDao.class);
NoteService noteService = SpringUtils.getBean(NoteService.class);

String demographicNo = request.getParameter("demoNo");

Demographic demographic = demographicDao.getDemographic(demographicNo);
String patientName = demographic.getFormattedName();

Integer maxNotes = 5;
Integer offset = 0;
String offsetStr = request.getParameter("offset");
if( offsetStr != null ) {
	offset = Integer.valueOf(offsetStr);
}

NoteSelectionCriteria noteSelectionCriteria = new NoteSelectionCriteria();
noteSelectionCriteria.setProgramId((String) request.getSession().getAttribute("case_program_id"));
noteSelectionCriteria.setDemographicId(Integer.valueOf(demographicNo));
noteSelectionCriteria.setMaxResults(maxNotes);
noteSelectionCriteria.setFirstResult(offset);
noteSelectionCriteria.setArchivedOnly(true);
noteSelectionCriteria.setSliceFromEndOfList(false);
NoteSelectionResult noteSelectionResult = noteService.findArchivedNotes(loggedInInfo, noteSelectionCriteria);

%>


<html>
<head>
<title>Archived Notes for <%=patientName %></title>
</head>
<body>
<h1 style="text-align: center;">Showing Archived Notes <%=String.valueOf(offset+1) %>  thru <%=String.valueOf(offset + noteSelectionResult.getNotes().size())  %> for <%=patientName%></h1>

<%
Integer origOffset = offset;
Integer nextOffset = offset + maxNotes;
if( offset >= maxNotes ) {
	offset-= maxNotes;
}
String fwd = "<a href=\"" + request.getContextPath() + "/casemgmt/showArchivedNotes.jsp?demoNo=" + demographicNo + "&offset=" + String.valueOf(nextOffset) + "\">></a>";
String rev = "<a href=\"" + request.getContextPath() + "/casemgmt/showArchivedNotes.jsp?demoNo=" + demographicNo + "&offset=" + String.valueOf(offset) + "\"><</a>";
%>
<div style="text-align: center">
	<%= origOffset > 0 ? rev :"" %>&nbsp;&nbsp;&nbsp;<%=noteSelectionResult.isMoreNotes() ? fwd : "" %>
</div>
<%
String bgColour ="";
String note;
for( NoteDisplay noteDisplay : noteSelectionResult.getNotes() ) {
	bgColour = CaseManagementViewAction.getNoteColour(noteDisplay);
	%>
	<div style="border-style: groove; border-width: 2px; border-color: grey; margin-bottom: 5px; background-color: <%=bgColour%>; color: white">
	
		<%=noteDisplay.getNote().replaceAll("\n", "<br>") %>
		<div style="margin-top: 5px; text-align: right;">
			Observation Date: <%=noteDisplay.getObservationDate() %><br/>
			Archive     Date: <%=noteDisplay.getUpdateDate() %>
		</div>
	</div>
	<%
}

%>
<div style="text-align: center">
	<%= origOffset > 0 ? rev :"" %>&nbsp;&nbsp;&nbsp;<%=noteSelectionResult.isMoreNotes() ? fwd : "" %>
</div>

</body>
</html>
