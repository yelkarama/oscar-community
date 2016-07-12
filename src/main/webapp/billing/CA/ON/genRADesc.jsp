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

<%@page import="org.oscarehr.util.LoggedInInfo"%>
<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean" %>
<%@taglib uri="/WEB-INF/struts-html.tld" prefix="html"%>

<%@page import="oscar.util.DateUtils"%>
<%@page import="org.oscarehr.util.SpringUtils"%>
<%@page import="org.oscarehr.common.model.Provider,org.oscarehr.PMmodule.dao.ProviderDao"%>
<%@page import="org.oscarehr.common.model.BillingONPremium, org.oscarehr.common.dao.BillingONPremiumDao"%>

<html>
<head>
<script type="text/javascript" src="<%= request.getContextPath() %>/js/global.js"></script>
<title>OSCAR Project</title>
<link rel="stylesheet" href="../web.css">
<script LANGUAGE="JavaScript">
<!--



//-->
</script>
</head>

<body onLoad="setfocus()" topmargin="0" leftmargin="0" rightmargin="0">
<table border="0" cellspacing="0" cellpadding="0" width="100%">
	<tr bgcolor="#486ebd">
		<th align="left">
		<form><input type="button" onclick="window.print()"
			value="Print"></form>
		</th>
		<th align="center"><font face="Helvetica" color="#FFFFFF">
		Reconcillation Report </font></th>
		<th align="right">
		<form><input type="button"
			onClick="popupPage(700,600,'billingClipboard.jsp')" value="Clipboard"></form>
		</th>
	</tr>
</table>

Cheque amount:
<%=total%>
<br>
<%="Local clinic "%>:
<%=local_total%>
<br>
Other clinic :
<%=other_total%><br>

OB Total :
<%=ob_total%><br>
Colposcopy Total :
<%=co_total%><br>

<br>
<br>
<table bgcolor="#EEEEEE" bordercolor="#666666" border="1">
	<%=htmlContent%>
</table>
<br>
<table bgcolor="#EEEEFF" bordercolor="#666666" border="1">
	<%=transaction%>
</table>

<%
	LoggedInInfo loggedInInfo=LoggedInInfo.getLoggedInInfoFromSession(request);
    Integer raHeaderNo = Integer.parseInt(raNo);
    
    BillingONPremiumDao bPremiumDao = (BillingONPremiumDao) SpringUtils.getBean("billingONPremiumDao");
    List<BillingONPremium> bPremiumList = bPremiumDao.getRAPremiumsByRaHeaderNo(raHeaderNo);
    if (bPremiumList.isEmpty()) {
        bPremiumDao.parseAndSaveRAPremiums(loggedInInfo, raHeaderNo, request.getLocale());
        bPremiumList = bPremiumDao.getRAPremiumsByRaHeaderNo(raHeaderNo);
    }
    
            
    if (!bPremiumList.isEmpty()) {
%>
    <html:form action="/billing/CA/ON/ApplyPractitionerPremium">
        <input type="hidden" name="rano" value="<%=raNo%>"/>
        <input type="hidden" name="method" value="applyPremium"/>
        <h3><bean:message key="oscar.billing.on.genRADesc.premiumTitle"/></h3>
        <table>
            <thead>
                <th style="width:30px;font-family: helvetica; background-color: #486ebd; color:white;"><bean:message key="oscar.billing.on.genRADesc.applyPremium"/></th>
                <th style="font-family: helvetica; background-color: #486ebd; color:white;"><bean:message key="oscar.billing.on.genRADesc.ohipNo"/></th>
                <th style="font-family: helvetica; background-color: #486ebd; color:white;"><bean:message key="oscar.billing.on.genRADesc.providerName"/></th>
                <th style="font-family: helvetica; background-color: #486ebd; color:white;"><bean:message key="oscar.billing.on.genRADesc.totalMonthlyPayment"/></th>
                <th style="font-family: helvetica; background-color: #486ebd; color:white;"><bean:message key="oscar.billing.on.genRADesc.paymentDate"/></th>
            </thead>
    <%
           
            for (BillingONPremium premium : bPremiumList) {   
                Integer premiumId = premium.getId();
                ProviderDao providerDao = (ProviderDao)SpringUtils.getBean("providerDao");
                List<Provider> pList = providerDao.getBillableProvidersByOHIPNo(premium.getProviderOHIPNo());  
                if ((pList != null) && !pList.isEmpty()) {
                    String isChecked = "";
                    if (premium.getStatus())
                         isChecked = "checked";   
    %>
            <tr>
                <td><input name="choosePremium<%=premiumId%>" type="checkbox" value="Y" <%=isChecked%>/>
                <td><%=premium.getProviderOHIPNo()%></td>
                <td><select name="providerNo<%=premiumId%>">
    <%                     
                    for (Provider p : pList) { 
                        String selectedChoice = "";
                        String providerNo = p.getProviderNo();
                        String premiumProviderNo = premium.getProviderNo();
                        if (premiumProviderNo != null && providerNo.equals(premiumProviderNo)) {
                            selectedChoice = "selected=\"selected\"";
                        }
     %>
                        <option value="<%=p.getProviderNo()%>" <%=selectedChoice%>><%=p.getFormattedName()%></option>
    <%              } %>
                    </select>
                </td>
                <td><%=premium.getAmountPay()%></td>
                <td><%=DateUtils.formatDate(premium.getPayDate(), request.getLocale())%></td>
            </tr>
    <%                 
                }
            }        
    %>
            <tr>
                <td colspan="5" style="text-align: right"><input type="submit" value="<bean:message key="oscar.billing.on.genRADesc.submitPremium"/>"/></td>
            </tr>
        </table>    
    </html:form>
<%      } %><%--  --%>
<pre><%=message_txt%></pre>

</body>
</html>
