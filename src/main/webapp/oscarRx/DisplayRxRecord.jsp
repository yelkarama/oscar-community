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
<%@page import="org.oscarehr.common.dao.DrugDao,org.oscarehr.common.model.Drug,org.oscarehr.util.MiscUtils,org.oscarehr.util.SpringUtils,org.oscarehr.PMmodule.dao.ProviderDao,org.oscarehr.common.dao.DemographicDao" %>
<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean"%>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html"%>
<%@ taglib uri="/WEB-INF/struts-logic.tld" prefix="logic"%>
<%@ taglib uri="/WEB-INF/security.tld" prefix="security"%>
<%
    String roleName$ = (String)session.getAttribute("userrole") + "," + (String) session.getAttribute("user");
    boolean authed=true;
%>
<security:oscarSec roleName="<%=roleName$%>" objectName="_rx" rights="r" reverse="<%=true%>">
	<%authed=false; %>
	<%response.sendRedirect("../securityError.jsp?type=_rx");%>
</security:oscarSec>
<%
	if(!authed) {
		return;
	}
%>

<%
String id = request.getParameter("id");

CodingSystemManager codingSystemManager = SpringUtils.getBean(CodingSystemManager.class);
DrugDao drugDao = (DrugDao) SpringUtils.getBean("drugDao");
DrugReasonDao drugReasonDao = SpringUtils.getBean(DrugReasonDao.class);
ProviderDao providerDao = (ProviderDao)SpringUtils.getBean("providerDao");
DemographicDao demographicDao = (DemographicDao) SpringUtils.getBean("demographicDao");
PrescriptionFaxDao prescriptionFaxDao = SpringUtils.getBean(PrescriptionFaxDao.class);
PartialDateDao partialDateDao = SpringUtils.getBean(PartialDateDao.class);

List<DrugReason> drugReasons = new ArrayList<DrugReason>();
List<PrescriptionFax> prescriptionFaxes = new ArrayList<PrescriptionFax>();
Integer drugId = Integer.parseInt(id);

SimpleDateFormat dateTime = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");

Drug drug = drugDao.find(drugId);

if (drug != null) {
	drugReasons = drugReasonDao.getReasonsForDrugID(drug.getId(), true);
	prescriptionFaxes = prescriptionFaxDao.findFaxedByPrescriptionIdentifier(drug.getPrescriptionIdentifier());
}

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@page import="org.oscarehr.util.MiscUtils"%>
<%@ page import="org.oscarehr.common.model.DrugReason" %>
<%@ page import="org.oscarehr.common.dao.DrugReasonDao" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="org.apache.commons.lang.StringEscapeUtils" %>
<%@ page import="org.oscarehr.managers.CodingSystemManager" %>
<%@ page import="org.apache.commons.lang.StringUtils" %>
<%@ page import="org.oscarehr.common.model.PharmacyInfo" %>
<%@ page import="org.oscarehr.common.dao.PharmacyInfoDao" %>
<%@ page import="org.oscarehr.common.dao.PrescriptionFaxDao" %>
<%@ page import="org.oscarehr.common.model.PrescriptionFax" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="org.oscarehr.common.model.PartialDate" %>
<%@ page import="org.oscarehr.common.dao.PartialDateDao" %>
<html>
    <head>
        <script type="text/javascript" src="<%= request.getContextPath()%>/js/global.js"></script>
        <html:base />
        <title><bean:message key="oscarRx.DisplayRxRecord.title" /></title>
        <link rel="stylesheet" type="text/css" href="../../../share/css/OscarStandardLayout.css">
        <link rel="stylesheet" type="text/css" media="all" href="../share/css/extractedFromPages.css"  />
    </head>
    
        
    <body>
            <table width="100%" height="100%" border="0" cellspacing="0"
                   cellpadding="0">
                <tr>
                    <td valign="top">
                        
                        <table width="100%" border="0" cellspacing="0" cellpadding="3"
                               bgcolor="black" >
                            <tr>
                                <td width="66%" align="left" class="Cell">
                                    <div style="color:white;margin-left:5px;" class="Field2"><bean:message  key="oscarMDS.segmentDisplay.formDetailResults" /></div>
                                </td>
                                <td align="right">
                                    <input type="button" value="<bean:message key="global.btnClose"/>"  onClick="window.close()" />
                                    <input type="button" value="<bean:message key="global.btnPrint"/>"  onClick="window.print()" />         
                                </td>
                            </tr>
                        </table>    
                       				Provider: <%= providerDao.getProviderName(drug.getProviderNo()) %><br>
									Demographic: <%= demographicDao.getDemographic(""+drug.getDemographicId()).getDisplayName() %><br>
									
									
									Drug Name: <%= drug.getDrugName() %>     <br> 
									<% if(drug.getBrandName() != null && !drug.getBrandName().equalsIgnoreCase("null") ){ %>
									Brand Name: <%= drug.getBrandName()%><br>
									<%}%>
									<% if(drug.getCustomName() != null && !drug.getCustomName().equalsIgnoreCase("null") ){ %>
									Drug Description: <%= drug.getCustomName()%><br>
									<%}%>
									<br>   
									Rx Date: <%= partialDateDao.getDatePartial(drug.getRxDate(), PartialDate.DRUGS, drug.getId(), PartialDate.DRUGS_START_DATE) %><br>
									Rx End Date: <%= drug.getEndDate() %><br>
									Written Date: <%= partialDateDao.getDatePartial(drug.getWrittenDate(), PartialDate.DRUGS, drug.getId(), PartialDate.DRUGS_WRITTENDATE)%><br>
									Create Date: <%= drug.getCreateDate()%><br>
									<br>
									ATC: <%= drug.getAtc()%><br>
									DIN: <%= drug.getRegionalIdentifier()%><br>
									<br>
									
									Rx Text: <%= drug.getSpecial()%><br>
									<br>
									
									Dosage: <%= drug.getDosageDisplay() %><br>
									
									
									Frequency: <%= drug.getFreqCode()%><br>
									Duration: <%= drug.getDuration()%> &nbsp;<%= drug.getDurUnit()%><br>
									Quantity: <%= drug.getQuantity()%><br>
									Repeats: <%= drug.getRepeat()%><br>
									
									
									
									Refill Duration: <%= drug.getRefillDuration() %><br>
									Refill Quantity: <%= drug.getRefillQuantity() %><br>
									Dispense Interval: <%= drug.getDispenseInterval() %><br>
									Pickup Date: <%= drug.getPickUpDateTime() %><br>
									
									Unit: <%= drug.getUnit()%><br>
									Method: <%= drug.getMethod()%><br>
									Route: <%= drug.getRoute()%><br>
									Form: <%= drug.getDrugForm()%><br>
									
									Strength: <%= drug.getDosage()%> 
									<% if(drug.getUnitName() != null && !drug.getUnitName().equalsIgnoreCase("null") ){ %>
									<%= drug.getUnitName()%>
									<%}%>
									<br>
									Long Term: <%= drug.getLongTerm()%><br>
									Substitution Not Allowed: <%= drug.isNoSubs()%><br>
									Past Med: <%= drug.getPastMed()%><br>
									Patient Compliance: <%= drug.getPatientCompliance()%><br>
									Last Refill: <%= drug.getLastRefillDate()%><br>
									eTreatment: <%= drug.getETreatmentType()%><br>
									Status: <%= drug.getRxStatus()%><br>
									
									<br>
									Outside Provider<br>
									&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Name: <%= drug.getOutsideProviderName()%><br>
									&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Ohip: <%= drug.getOutsideProviderOhip()%><br>
									
									<br>
									Archived Reason: <%= drug.getArchivedReason()%><br>
									Archived Date: <%= drug.getArchivedDate()%><br>
									
									Comment: <%= drug.getComment()%><br>
						
						<br/>
						Prescription Identifier: <%=drug.getPrescriptionIdentifier()%><br/>
						Prior Prescription Reference Identifier: <%=drug.getPriorRxRefId()%><br/>
						Protocol Identifier: <%=drug.getProtocolId()%><br/>
						
						<fieldset style="max-height:200px; overflow:auto;">
							<legend>Current Indications</legend>
							<table style="font-size: x-small;">
								<tr>
									<th><bean:message key="SelectReason.table.codingSystem" /></th>
									<th><bean:message key="SelectReason.table.code" /></th>
									<th><bean:message key="SelectReason.table.description" /></th>
									<th><bean:message key="SelectReason.table.comments" /></th>
									<th><bean:message key="SelectReason.table.primaryReasonFlag" /></th>
									<th><bean:message key="SelectReason.table.dateCoded" /><th>
								</tr>
	
								<%for(DrugReason drugReason:drugReasons){ %>
								<tr>
									<td><%=drugReason.getCodingSystem() %></td>
									<td><%=drugReason.getCode() %></td>
									<td>
										<%
											String codeDescription = codingSystemManager.getCodeDescription(drugReason.getCodingSystem(), drugReason.getCode());
											codeDescription = StringUtils.trimToEmpty(codeDescription);
										%>
										<%=StringEscapeUtils.escapeHtml(codeDescription) %>
									</td>
									<td><%=drugReason.getComments() %></td>
									<td>
										<%if(drugReason.getPrimaryReasonFlag()){ %>
										True
										<%}%>
									</td>
									<td><%=drugReason.getDateCoded() %></td>
								</tr>
								<%}%>
							</table>
						</fieldset>
								<br/>

						<fieldset style="max-height:200px; overflow:auto;">
							<legend>Fax History</legend>
							<table style="font-size: x-small;">
								<tr>
									<th style="width: 150px;">Date/Time Faxed</th>
									<th style="width: 250px;">Pharmacy Info</th>
								</tr>

								<%for(PrescriptionFax prescriptionFax : prescriptionFaxes){ %>
								<tr>
									<td><%=dateTime.format(prescriptionFax.getDateFaxed())%></td>
									<td style="width: 250px;">
										<%
											PharmacyInfo pharmacyInfo = prescriptionFax.getPharmacyInfo();
											if (pharmacyInfo != null) {
										%>
										<strong><%=StringUtils.trimToEmpty(pharmacyInfo.getName())%></strong> <br/>
										<%=StringUtils.trimToEmpty(pharmacyInfo.getAddress())%> <br/>
										<%=StringUtils.trimToNull(pharmacyInfo.getCity()) != null ? pharmacyInfo.getCity() + ", " : ""%> <%=StringUtils.trimToEmpty(pharmacyInfo.getProvince())%><br/>
										<%=StringUtils.trimToEmpty(pharmacyInfo.getPostalCode())%> <br/>
										Phone: <%=StringUtils.trimToEmpty(pharmacyInfo.getPhone1())%> <br/>
										Fax: <%=StringUtils.trimToEmpty(pharmacyInfo.getFax())%> <br/>
										Email: <%=StringUtils.trimToEmpty(pharmacyInfo.getEmail())%> <br/>
										
										<% } %>
										
									</td>
								</tr>
								<%}%>
							</table>
						</fieldset>
						<br/>
									<%--
									Unused Items
									
									ID: <%= drug.getId()%><br>
									Audit: <%= drug.getAuditString()%><br>
									Full: <%= drug.getFullOutLine()%><br>
									Remote Facility Name: <%= drug.getRemoteFacilityName()%><br>
									Facility Id: <%= drug.getRemoteFacilityId()%><br>
									Position: <%= drug.getPosition()%><br>
									Start Date Unknown: <%= drug.getStartDateUnknown()%><br>
									Script No: <%= drug.getScriptNo()%><br>
									hide for cpp: <%= drug.getHideFromCpp() %><br>
									GCN: <%= drug.getGcnSeqNo()%><br>
									Special Instr: <%= drug.getSpecialInstruction()%><br>
									Gen Name: <%= drug.getGenericName()%><br>
									Min: <%= drug.getTakeMin()%><br>
									Max: <%= drug.getTakeMax()%><br>
									 --%>
                              
            		</td>
                </tr>
            </table> 
    </body>
</html>
