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
<%-- <%@ page import="org.oscarehr.common.dao.UserPropertyDAO, org.oscarehr.common.model.UserProperty"%> --%>
<%@ page import="org.oscarehr.common.dao.DemographicExtDao, org.oscarehr.common.model.DemographicExt"%>
<%@ page import="org.oscarehr.util.SpringUtils"%>
<%@ page import="oscar.log.LogAction" %>
<%@ page import="java.util.*" %>
<%
	String user_no = (String) session.getAttribute("user");
	String demoNo = request.getParameter("demo");
	String dxCode = request.getParameter("dxcode");
	String icd9Code = request.getParameter("icd9code");
	
	if (demoNo==null || demoNo.trim().isEmpty()) return;
	if (dxCode==null || dxCode.trim().isEmpty()) return;
	if (icd9Code==null || icd9Code.trim().isEmpty()) return;
	
	int demoNoI = Integer.parseInt(demoNo);
	String key = "code_to_avoid_patientDx";
	
// 	UserPropertyDAO userPropertyDao = SpringUtils.getBean(UserPropertyDAO.class);
// 	UserProperty codeNotApproved = userPropertyDao.getProp(user_no, UserProperty.CODE_TO_AVOID_PATIENTDX);

	DemographicExtDao demoExtDao = SpringUtils.getBean(DemographicExtDao.class);
	DemographicExt codeNotApproved = demoExtDao.getLatestDemographicExt(demoNoI, key);
	
	if (codeNotApproved!=null) {
		String codes = codeNotApproved.getValue();
		if (codes!=null && !codes.trim().isEmpty()) {
			String[] codeArray = codes.split(",");
			codes = new String();
			for (String code : codeArray) {
				String[] c = code.split("x");
				if (c[0].equals(icd9Code)) {
					icd9Code = null;
					int x = Integer.parseInt(c[1]);
					x = x<3 ? x+1 : 3;
					code = c[0]+"x"+x;
				}
				if (!codes.isEmpty()) codes+=",";
				codes += code;
			}
			if (icd9Code!=null) icd9Code += "x1,"+codes;
			else icd9Code = codes;
		}
		demoExtDao.saveDemographicExt(demoNoI, key, icd9Code);
	} else {
		demoExtDao.addKey(user_no, demoNoI, key, icd9Code+"x1");
	}
	
// 	userPropertyDao.saveProp(user_no, UserProperty.CODE_TO_AVOID_PATIENTDX, icd9Code);

	LogAction.addLog(user_no, "Billing: Add to Disease Registry: Not approved", "billing diagnostic code: "+dxCode+", mapped ICD9 code: "+icd9Code, null, null, demoNo);
%>
<html>
<body onload="window.close()">
	Logging dx code which is not approved...<br/>
	(This window should close by itself)
</body>
</html>