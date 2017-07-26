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


<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean"%>
<%@ page import="java.math.*, java.util.*, java.io.*, java.sql.*, oscar.*, java.net.*,oscar.MyDateFormat"%>
<%@ page import="org.oscarehr.util.SpringUtils" %>
<%@ page import="org.oscarehr.common.model.CtlBillingType" %>
<%@ page import="org.oscarehr.common.dao.CtlBillingTypeDao" %>
<%@ page import="org.oscarehr.common.dao.ClinicNbrDao" %>
<%@ page import="org.oscarehr.common.model.ClinicNbr" %>
<%@ page import="org.oscarehr.common.model.Provider" %>
<%@ page import="org.oscarehr.PMmodule.dao.ProviderDao" %>
<%@ page import="oscar.oscarBilling.ca.on.data.JdbcBillingPageUtil" %>

<%
	String providerNo = (String) session.getAttribute("user");
	CtlBillingTypeDao ctlBillingTypeDao = SpringUtils.getBean(CtlBillingTypeDao.class);
%>


<%
String type_id = "", type_name="", billtype="no";
type_id = request.getParameter("type_id");
type_name = request.getParameter("type_name");
String visitType ="";
String location = "";

for(CtlBillingType cbt:ctlBillingTypeDao.findByServiceType(type_id)) {
	billtype = cbt.getBillType();
	visitType = cbt.getVisitType()!=null?cbt.getVisitType():"";
	location = cbt.getLocation()!=null?cbt.getLocation():"";
}

oscar.OscarProperties oscarVariables = oscar.OscarProperties.getInstance();
boolean bHospitalBilling = false;
String clinicView = bHospitalBilling ? oscarVariables.getProperty("clinic_hospital", "") : oscarVariables.getProperty("clinic_view", "");
JdbcBillingPageUtil tdbObj = new JdbcBillingPageUtil();

%>

<table width=95%>
	<tr>
		<td class="black" width="15%"><%=type_id%></td>
		<td class="black" height="30"><%=type_name%></td>
	</tr>
	<tr>
		<td>&nbsp;</td>
		<td class="white">
		<p>&nbsp;<br>
		<bean:message key="billing.manageBillingform_add.formDefaultBillType" />
		:<br>
		<input type="hidden" name="bill_servicetype" value="<%=type_id%>">
		<input type="hidden" name="billtype_old" value="<%=billtype%>">
		<select name="billtype_new">
			<option value="no" <%=billtype.equals("no")?"selected":""%>>--
			no --</option>
			<option value="ODP" <%=billtype.equals("ODP")?"selected":""%>>Bill
			OHIP</option>
			<option value="WCB" <%=billtype.equals("WCB")?"selected":""%>>WSIB</option>
			<option value="NOT" <%=billtype.equals("NOT")?"selected":""%>>Do
			Not Bill</option>
			<option value="IFH" <%=billtype.equals("IFH")?"selected":""%>>IFH</option>
			<option value="PAT" <%=billtype.equals("PAT")?"selected":""%>>3rd
			Party</option>
			<option value="OCF" <%=billtype.equals("OCF")?"selected":""%>>-OCF</option>
			<option value="ODS" <%=billtype.equals("ODS")?"selected":""%>>-ODSP</option>
			<option value="CPP" <%=billtype.equals("CPP")?"selected":""%>>-CPP</option>
			<option value="STD" <%=billtype.equals("STD")?"selected":""%>>-STD/LTD</option>
		</select>

		&nbsp;<br/>
		Default <bean:message key="billing.visittype" />:<br>
		<select name="visitType_new">
			<option value="none">None</option>
			<% if (OscarProperties.getInstance().getBooleanProperty("rma_enabled", "true")) { %>
			<%
				ClinicNbrDao cnDao = (ClinicNbrDao) SpringUtils.getBean("clinicNbrDao");
				ArrayList<ClinicNbr> nbrs = cnDao.findAll();
				ProviderDao providerDao = (ProviderDao) SpringUtils.getBean("providerDao");
				Provider p = providerDao.getProvider(providerNo);
				String providerNbr = SxmlMisc.getXmlContent(p.getComments(),"xml_p_nbr");
				for (ClinicNbr clinic : nbrs) {
					String valueString = String.format("%s | %s", clinic.getNbrValue(), clinic.getNbrString());
			%>
			<option value="<%=valueString%>" <%=providerNbr.startsWith(clinic.getNbrValue())?"selected":""%>><%=valueString%></option>
			<%}%>
			<% } else { %>
			<option value="00| Clinic Visit" <%=visitType.startsWith("00")?"selected":""%>><bean:message key="billing.billingCorrection.formClinicVisit"/></option>
			<option value="01| Outpatient Visit" <%=visitType.startsWith("01")?"selected":""%>><bean:message key="billing.billingCorrection.formOutpatientVisit"/></option>
			<option value="02| Hospital Visit" <%=visitType.startsWith("02")?"selected":""%>><bean:message key="billing.billingCorrection.formHospitalVisit"/></option>
			<option value="03| ER"<%=visitType.startsWith("03")?"selected":""%>><bean:message key="billing.billingCorrection.formER"/></option>
			<option value="04| Nursing Home"<%=visitType.startsWith("04")?"selected":""%>><bean:message key="billing.billingCorrection.formNursingHome"/></option>
			<option value="05| Home Visit"<%=visitType.startsWith("05")?"selected":""%>><bean:message key="billing.billingCorrection.formHomeVisit"/></option>
			<% } %>
		</select>

		&nbsp;<br/>
		Default <bean:message key="billing.visitlocation" />:<br>
		<select name="location_new">
			<%
				String billLocationNo="", billLocation="";
				List lLocation = tdbObj.getFacilty_num();
				for (int i = 0; i < lLocation.size(); i = i + 2) {
					billLocationNo = (String) lLocation.get(i);
					billLocation = (String) lLocation.get(i + 1);
					String strLocation = location != null ? location : clinicView;
					location = !location.equals("") ? location.split("\\|")[0] : strLocation;
			%>
			<option value="<%=billLocationNo + "|" + billLocation%>" <%=billLocationNo.equals(location) ? "selected" : ""%>>
				<%=billLocationNo + " | " + billLocation%>
			</option>
			<%
				}
			%>

		</select>
		</p>
		<p>
			<input type="button" value="Update" onclick="manageBillType(bill_servicetype.value, billtype_new.value, visitType_new.value, location_new.value);"><br>
		</p>
		<p><input type="button" value="Delete Billing Form"
			onclick="onUnbilled('dbManageBillingform_delete.jsp?servicetype=<%=type_id%>');"></p>
		<p><input type="button" value="Cancel"
			onclick="showManageType(false);"></p>
		</td>
	</tr>
</table>
