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
<%! boolean bMultisites = org.oscarehr.common.IsPropertiesOn.isMultisitesEnable(); %>
<%@ include file="../../../taglibs.jsp"%>
<html:html locale="true">

<head>
<script type="text/javascript" src="<%= request.getContextPath() %>/js/global.js"></script>
<script type="text/javascript" src="<%= request.getContextPath() %>/js/tablefilter_all_min.js"></script>
<link rel="stylesheet" type="text/css" href="billingON.css" />
<title>Billing Reconcilliation</title>
<html:base />

</head>
<script type="text/javascript" language=javascript>
    
</script>
<body topmargin="0" leftmargin="0" vlink="#0000FF" onload="window.focus();">
<html:errors />

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
	<table id="raReportTable">
		<tr>
			<th></th>
			<logic:iterate id="provider" name="raReport" property="providers">
				<th><bean:write name="provider"/></th>
			</logic:iterate>
		</tr>
		<tr>
			<td>Invoice</td>
			<logic:iterate id="invoice" name="raReport" property="invoice">
				<td class="math">$<bean:write name="invoice"/></td>
			</logic:iterate>
		</tr>
		<tr>
			<td>RMB</td>
			<logic:iterate id="rmb" name="raReport" property="rmb">
				<td class="math">$<bean:write name="rmb"/></td>
			</logic:iterate>
		</tr>
		<tr>
			<td class="sum">Gross</td>
			<logic:iterate id="gross" name="raReport" property="gross">
				<td class="math sum">$<bean:write name="gross"/></td>
			</logic:iterate>
		</tr>
		<tr>
			<td>Automated Premiums</td>
			<logic:iterate id="automated" name="raReport" property="automated">
				<td class="math">$<bean:write name="automated"/></td>
			</logic:iterate>
		</tr>
		<tr>
			<td>Opt-In</td>
			<logic:iterate id="optIn" name="raReport" property="optIn">
				<td class="math">$<bean:write name="optIn"/></td>
			</logic:iterate>
		</tr>
		<tr>
			<td>Age Premium</td>
			<logic:iterate id="agePremium" name="raReport" property="agePremium">
				<td class="math">$<bean:write name="agePremium"/></td>
			</logic:iterate>
		</tr>
		<tr>
			<td class="medsum"><b>Net Total</b></td>
			<logic:iterate id="net" name="raReport" property="net">
				<td class="math medsum">$<b><bean:write name="net"/></b></td>
			</logic:iterate>
		</tr>
		<tr>
			<th colspan="${raReport.getProviders().size() + 1}" class="separator">Balance Forward Record - Amount Brought Forward (ABF)</th>
		</tr>
		<tr>
			<td colspan="${raReport.getProviders().size()}">Claims Adjustment</td>
			<td class="math faded blackText">$<bean:write name="raReport" property="claimsAdjust"/></td>
		</tr>
		<tr>
			<td colspan="${raReport.getProviders().size()}">Advances</td>
			<td class="math faded blackText">$<bean:write name="raReport" property="advances"/></td>
		</tr>
		<tr>
			<td colspan="${raReport.getProviders().size()}">Reductions</td>
			<td class="math faded blackText">$<bean:write name="raReport" property="reductions"/></td>
		</tr>
		<tr>
			<td colspan="${raReport.getProviders().size()}">Deductions</td>
			<td class="math faded blackText">$<bean:write name="raReport" property="deductions"/></td>
		</tr>
		<tr>
			<td colspan="${raReport.getProviders().size() + 1}"></td>
		</tr>
		<tr>
			<td colspan="${raReport.getProviders().size()}" class="bigsum"></td>
			<td class="math blackText bigsum"><b>$<bean:write name="raReport" property="raTotal"/></b></td>
		</tr>
	</table>
<pre><bean:write name="raReport" property="messageTxt" /></pre>

</body>
</html:html>
