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
<body topmargin="0" leftmargin="0" vlink="#0000FF"
	onload="window.focus();">
<html:errors />
	<table border="0" cellspacing="0" cellpadding="0" width="100%">
		<tr class="myDarkGreen">
			<th align='LEFT'><font color="#FFFFFF"> Billing
			Reconcilliation - Summary Report</font></th>
			<th align='RIGHT'>
			 <input type='button' name='print' value='Print' onClick='window.print()'>
			<input type='button' name='close' value='Close'
				onClick='window.close()'></th>
		</tr>
	</table>
	<table id="raSummaryTable">
		<tr>
			<th>Provider</th>
			<th>Claims</th>
			<th>Invoiced</th>
			<th class="payFormat">Paid</th>
			<th>Clinic Pay</th>
			<th>Hospital Pay</th>
			<th>Other</th>
		</tr>
		<logic:iterate id="provBreakDown" name="raSummary" property="providerBreakDown">
			<tr>
			<logic:present name="provBreakDown" property="providerName">
				<td rowspan="4">
					<a href="onGenRAProvider.jsp?proNo=<bean:write name="provBreakDown" property="pohipno"/>&submit=Generate&rano=<bean:write name="raNo"/>">
						<bean:write name="provBreakDown" property="providerName" />
					</a>
				</td>
			</logic:present>
			<logic:notPresent name="provBreakDown" property="providerName">
				<td><b>RA subtotal:</b></td>
			</logic:notPresent>
				<td class="math"><bean:write name="provBreakDown" property="claims" /></td>
				<td class="math">$<bean:write name="provBreakDown" property="amountInvoiced" /></td>
			<logic:present name="provBreakDown" property="providerName">
				<td class="math medsum">$<bean:write name="provBreakDown" property="amountPay" /></td>
			</logic:present>
			<logic:notPresent name="provBreakDown" property="providerName">
				<td class="math bigsum">$<bean:write name="provBreakDown" property="amountPay" /></td>
			</logic:notPresent>
				<td class="math">$<bean:write name="provBreakDown" property="clinicPay" /></td>
				<td class="math">$<bean:write name="provBreakDown" property="hospitalPay" /></td>
				<td class="math">$<bean:write name="provBreakDown" property="otherPay" /></td>
			</tr>
			<tr>
			<logic:present name="provBreakDown" property="providerName">
				<td colspan="2" class="faded">Local Pay</td>
			</logic:present>
			<logic:notPresent name="provBreakDown" property="providerName">
				<td colspan="3" class="faded">RA Local subtotal: </td>
			</logic:notPresent>
				<td class="math faded">$<bean:write name="provBreakDown" property="localPay" /></td>
				<td class="math faded">$<bean:write name="provBreakDown" property="clinicPay" /></td>
				<td class="math faded">$<bean:write name="provBreakDown" property="localHospitalPay" /></td>
			</tr>
			<logic:present name="provBreakDown" property="obPay">
			<tr>
				<td colspan="2" class="faded">OB</td>
				<td class="math faded">$<bean:write name="provBreakDown" property="obPay" /></td>
			</tr>
			<tr>
				<td colspan="2" class="faded">CO</td>
				<td class="math faded">$<bean:write name="provBreakDown" property="coPay" /></td>
			</tr>
			</logic:present>
		</logic:iterate>
			<tr>
				<th class="separator" colspan="3"> </th>
				<th class="separator">Payments</th>
				<th class="separator">Reductions</th>
			</tr>
		<logic:iterate id="acctTrans" name="raSummary" property="accountingTransactions">
			<tr>
				<td colspan="3"><bean:write name="acctTrans" property="type" /></td>
				<logic:present name="acctTrans" property="negative">
				<td class="faded"></td>
				<td class="math faded blackText">$<bean:write name="acctTrans" property="amount" /></td>	
				</logic:present>		
				<logic:notPresent name="acctTrans" property="negative">
				<td class="math faded blackText">$<bean:write name="acctTrans" property="amount" /></td>
				<td class="faded"></td>
				</logic:notPresent>	
			</tr>
		</logic:iterate>
		<tr><td colspan="5"></td></tr>
		<tr><td colspan="5">Balance Forward Record - Amount Brought Forward (ABF)</td></tr>
		<tr><td colspan="3">Claims Adjustment</td>
			<logic:greaterEqual name="raSummary" property="abfClaimsAdjust" value="0">
			<td class="math faded blackText">$<bean:write name="raSummary" property="abfClaimsAdjust" /></td><td class="faded"></td>
			</logic:greaterEqual>
			<logic:lessThan name="raSummary" property="abfClaimsAdjust" value="0">
			<td  class="faded"></td><td class="math faded blackText">$<bean:write name="raSummary" property="abfClaimsAdjust" /></td>
			</logic:lessThan>
		</tr>
		<tr><td colspan="3">Advances</td>
			<logic:greaterEqual name="raSummary" property="abfAdvances" value="0">
			<td class="math faded blackText">$<bean:write name="raSummary" property="abfAdvances" /></td><td class="faded"></td>
			</logic:greaterEqual>
			<logic:lessThan name="raSummary" property="abfAdvances" value="0">
			<td class="faded"></td><td class="math faded blackText">$<bean:write name="raSummary" property="abfAdvances" /></td>
			</logic:lessThan>
		</tr>
		</tr>
		<tr><td colspan="3">Reductions</td>
			<logic:greaterEqual name="raSummary" property="abfReductions" value="0">
			<td class="math faded blackText">$<bean:write name="raSummary" property="abfReductions" /></td><td class="faded"></td>
			</logic:greaterEqual>
			<logic:lessThan name="raSummary" property="abfReductions" value="0">
			<td class="faded"></td><td class="math faded blackText">$<bean:write name="raSummary" property="abfReductions" /></td>
			</logic:lessThan>
		</tr>
		</tr>
		<tr><td colspan="3">Deductions</td>
			<logic:greaterEqual name="raSummary" property="abfDeductions" value="0">
			<td class="math faded blackText">$<bean:write name="raSummary" property="abfDeductions" /></td><td class="faded"></td>
			</logic:greaterEqual>
			<logic:lessThan name="raSummary" property="abfDeductions" value="0">
			<td class="faded"></td><td class="math faded blackText">$<bean:write name="raSummary" property="abfDeductions" /></td>
			</logic:lessThan>
		</tr>
		<tr><td colspan="5"></td></tr>
		<tr><td colspan="3">RA Total:</td>
			<td class="math sum">$<bean:write name="raSummary" property="raTotalPos" /></td>
			<td class="math sum">$<bean:write name="raSummary" property="raTotalNeg" /></td>
			<td class="math bigsum"><b>$<bean:write name="raSummary" property="raTotalNet" /><b></td>
		</tr>
	</table>
</body>
</html:html>
