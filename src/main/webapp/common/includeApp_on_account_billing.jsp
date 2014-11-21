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
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<%@page import="java.util.Properties"%>
<%@page import="java.util.Enumeration"%>
<html>
<head>

<%!
String appName = "";
boolean redirect = false;
%>
<%

appName = request.getParameter("appName");


if(request.getParameter("redirect")!=null && request.getParameter("redirect").equalsIgnoreCase("true"))
	redirect = true;


if(appName==null)
	appName = "";
%>

<title><%=appName %></title>
</head>

<%!
public void forward_cross_context(String url, ServletContext currentServletContext, 
		String toContextName, HttpSession currentSession, 
		HttpServletRequest currentRequest, HttpServletResponse currentResponse) throws Exception
{
	ServletContext servletContext = currentServletContext.getContext("/"+toContextName);
	


	String contextPath = currentServletContext.getContextPath();
	String contextName = contextPath.substring(1); 

	Enumeration e1 = currentSession.getAttributeNames();
	Object key = null, value = null;
	Properties sessionProperties = new Properties();
	while(e1.hasMoreElements())
	{
		key = e1.nextElement();
		if(key!=null)
			value = currentSession.getAttribute(key.toString());
		
		sessionProperties.put(key, value);
	}
	
	String currenSessionId = currentSession.getId();
	String currentOscarUserId = "";
	if(currentSession.getAttribute("user")!=null)
		currentOscarUserId = currentSession.getAttribute("user").toString();
	

	

	currentServletContext.setAttribute(currenSessionId+"SESSION_PROPERTIES", sessionProperties);
	currentServletContext.setAttribute(currentOscarUserId+"SESSION_PROPERTIES", sessionProperties);

	if(!redirect)
	{
		RequestDispatcher rd = servletContext.getRequestDispatcher(url);
		//rd.forward(request, response);
		currentRequest.setAttribute("oscar_context", contextName);

		rd.forward(currentRequest, currentResponse);
	}
	else
	{
		//assuming there is atleast one parameter
		url = url+"&user="+currentOscarUserId;
		currentResponse.sendRedirect(url);
	}
}

%>

<body>

<%
String contextName = "", url = "";

contextName = request.getParameter("contextName");
url = request.getParameter("url");




forward_cross_context(url, application, contextName, session, request, response);

%>

</body>
</html>
