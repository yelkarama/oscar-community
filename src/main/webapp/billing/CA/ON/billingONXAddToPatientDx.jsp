<%--

    Copyright (c) 2006-. OSCARservice, OpenSoft System. All Rights Reserved.
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

--%>
<%@ page import="org.oscarehr.common.dao.UserPropertyDAO, org.oscarehr.common.model.UserProperty"%>
<%@ page import="org.oscarehr.util.SpringUtils"%>
<%@ page import="oscar.log.LogAction" %>
<%
	String user_no = (String) session.getAttribute("user");
	String demoNo = request.getParameter("demo");
	String dxCode = request.getParameter("dxcode");
	String icd9Code = request.getParameter("icd9code");
	
	if (demoNo==null || demoNo.trim().isEmpty()) return;
	if (dxCode==null || dxCode.trim().isEmpty()) return;
	if (icd9Code==null || icd9Code.trim().isEmpty()) return;
	
	UserPropertyDAO userPropertyDao = SpringUtils.getBean(UserPropertyDAO.class);
	UserProperty codeNotApproved = userPropertyDao.getProp(user_no, "code_to_avoid_patientDx");
	
	if (codeNotApproved!=null) {
		String value = codeNotApproved.getValue();
		if (value!=null && !value.trim().isEmpty()) icd9Code += ","+value;
	}		
	userPropertyDao.saveProp(user_no, "code_to_avoid_patientDx", icd9Code);
	LogAction.addLog(user_no, "Billing Add to Disease Registry Not Approved", "billing diagnostic code: "+dxCode+", mapped ICD9 code: "+icd9Code, null, null, demoNo);
%>
<html>
<body onload="window.close()">
	Logging dx code not approved...
</body>
</html>