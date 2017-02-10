<%@ include file="/casemgmt/taglibs.jsp"%>
<%
    String roleName$ = (String)session.getAttribute("userrole") + "," + (String) session.getAttribute("user");
    boolean authed=true;
%>
<security:oscarSec roleName="<%=roleName$%>" objectName="_casemgmt.notes" rights="r" reverse="<%=true%>">
    <%authed=false; %>
    <%response.sendRedirect(request.getContextPath() + "/securityError.jsp?type=_casemgmt.notes");%>
</security:oscarSec>
<%
    if(!authed) {
        return;
    }
%>

<%@ page
        import="org.springframework.web.context.*,org.springframework.web.context.support.*, org.oscarehr.PMmodule.service.ProviderManager, org.oscarehr.casemgmt.model.CaseManagementNote"%>
<%@ page import="java.util.List" %>
<%
    HttpSession se = request.getSession();
    WebApplicationContext  ctx = WebApplicationContextUtils.getRequiredWebApplicationContext(se.getServletContext());
    ProviderManager providerManager = (ProviderManager)ctx.getBean("providerManager");

    List<CaseManagementNote> notes = ( List<CaseManagementNote>)request.getAttribute("showAll");
%>
<html>
<head>
    <script type="text/javascript" src="<%= request.getContextPath() %>/js/global.js"></script>
    <title>Encounter Notes</title>
</head>
<body>
<h3 style="text-align: center;"><%=request.getAttribute("title")%></h3>
<h3 style="text-align: center;"><%=request.getAttribute("demoName")%></h3>
<% if (notes.size()==0){%>
<div style="text-align: center"><pre>No notes to display.</pre></div>
<%}%>
<% for (CaseManagementNote note : notes) { %>
    <div style="width: 99%; background-color: #EFEFEF; font-size: 12px; border-left: thin groove #000000; border-bottom: thin groove #000000; border-right: thin groove #000000;">
        <div><pre><%=note.getNote()%></pre></div>
        <div style="color: #0000FF;">
            <% if(note.getNote()==null) { %>
                <div style="color: #FF0000;">REMOVED</div>
            <%} else if(note.isArchived()) { %>
                <div style="color: #336633;">ARCHIVED</div>
            <%}%>
            Documentation Date: <%=note.getObservation_date()%><br/>
            <% if(note.isSigned() && Integer.parseInt(note.getSigning_provider_no()) != -1) { %>
                Signed by <%=providerManager.getProviderName(note.getSigning_provider_no())%>:
            <%} else {%>
                Saved by <%=providerManager.getProviderName(note.getProviderNo())%>:
            <%}%>
            <%=note.getUpdate_date()%></div>
    </div>
<%}%>

</body>
</html>
