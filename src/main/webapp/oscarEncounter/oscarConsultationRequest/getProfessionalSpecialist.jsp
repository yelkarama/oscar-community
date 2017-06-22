<%@page import="net.sf.json.JSONObject"%>
<%@page import="net.sf.json.JSONSerializer"%>
<%@page import="org.oscarehr.common.model.ProfessionalSpecialist"%>
<%@page import="java.util.List"%>
<%@page import="org.oscarehr.util.SpringUtils"%>
<%@page import="org.oscarehr.common.dao.ProfessionalSpecialistDao"%><%
	ProfessionalSpecialistDao professionalSpecialistDao=(ProfessionalSpecialistDao)SpringUtils.getBean("professionalSpecialistDao");
	ProfessionalSpecialist professionalSpecialist = null;			
	String id = request.getParameter("id")==null?"":request.getParameter("id");
				
	if (id.length() > 0)
	{
		professionalSpecialist=professionalSpecialistDao.find(Integer.parseInt(id));
	}

	if(professionalSpecialist != null) {
		response.setContentType("text/x-json");
	    JSONObject jsonArray = (JSONObject) JSONSerializer.toJSON(professionalSpecialist);
	    jsonArray.write(out);
	}
%>