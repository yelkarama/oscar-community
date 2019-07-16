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


<%@ page import="java.math.*, java.util.*, java.io.*, java.sql.*, oscar.*, java.net.*,oscar.MyDateFormat"%>

<%@ page import="org.oscarehr.util.SpringUtils" %>
<%@ page import="org.oscarehr.common.model.CtlBillingService" %>
<%@ page import="org.oscarehr.common.dao.CtlBillingServiceDao" %>
<%@ page import="org.apache.commons.lang3.math.NumberUtils" %>
<%@ page import="org.apache.commons.lang.StringUtils" %>
<%
	CtlBillingServiceDao ctlBillingServiceDao = SpringUtils.getBean(CtlBillingServiceDao.class);
%>
<%
String typeid = request.getParameter("typeid");
String type = request.getParameter("type");

for(CtlBillingService b:ctlBillingServiceDao.findByServiceType(typeid)) {
	ctlBillingServiceDao.remove(b.getId());
}

String[] group = new String[4];

boolean valid = true;
List<String> errors = new ArrayList<String>();
int rowsAffected = -100;

for(int j=1;j<4;j++){
	group[j] = request.getParameter("group"+j);

	for (int i=0; i<20; i++){
		if(request.getParameter("group"+j+"_service"+i).length() !=0){
			CtlBillingService cbs = new CtlBillingService();
			cbs.setServiceTypeName(type);
			cbs.setServiceType(typeid);
			cbs.setServiceCode(request.getParameter("group"+j+"_service"+i));
			cbs.setServiceGroupName(group[j]);
			cbs.setServiceGroup("Group"+j);
			cbs.setStatus("A");
			cbs.setServiceOrder(Integer.parseInt(request.getParameter("group"+j+"_service"+i+"_order")));
			
			if(StringUtils.isNotEmpty(cbs.getServiceCode())) {
				if (StringUtils.isNotEmpty(request.getParameter("group"+j+"_service"+i+"_order"))) {
					valid = false;
					errors.add("Missing service order for service " + cbs.getServiceCode() + " in group " + cbs.getServiceGroupName());
				} else if (NumberUtils.isParsable(cbs.getServiceCode())) {
					valid = false;
					errors.add("Invalid service order value for service " + cbs.getServiceCode() + " in group " + cbs.getServiceGroupName() +
							"\n Service order value must be a number.");
				}
			}

			if (!valid) {
				for (String error : errors) {
					System.out.println (error + "\n");
				}
			} else {
				ctlBillingServiceDao.persist(cbs);
			}
		}
	}
}

response.sendRedirect("manageBillingform.jsp");
%>
