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


<%@ page import="java.math.*, java.util.*, java.io.*, java.sql.*, java.net.*,oscar.*, oscar.util.*, oscar.MyDateFormat" errorPage="errorpage.jsp"%>
<%@ page import="oscar.oscarBilling.ca.on.pageUtil.*"%>

<jsp:useBean id="billingLocalInvNoBean" class="java.util.Properties" scope="page" />

<%@page import="org.oscarehr.util.SpringUtils" %>
<%@page import="org.oscarehr.common.model.RaHeader" %>
<%@page import="org.oscarehr.common.dao.RaHeaderDao" %>
<%
	RaHeaderDao dao = SpringUtils.getBean(RaHeaderDao.class);
%>

<html>
<head>
<script type="text/javascript" src="<%= request.getContextPath() %>/js/global.js"></script>
<script type="text/javascript" src="<%= request.getContextPath() %>/js/tablefilter_all_min.js"></script>
<link rel="stylesheet" type="text/css" href="billingON.css" />
<title>Billing Reconcilliation</title>

<style>
<% if (bMultisites) { %>
	.positionFilter {position:absolute;top:2px;right:350px;display:block;}
<% } else { %>
	.positionFilter {display:none;}
<% } %>
</style>

</head>

<body leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">

<% 
String nowDate = UtilDateUtilities.DateToString(new java.util.Date(), "yyyy/MM/dd"); 
String flag="", plast="", pfirst="", pohipno="", proNo="";
String raNo = request.getParameter("rano");

BillingRAPrep obj = new BillingRAPrep();
String obCodes = "'P006A','P020A','P022A','P028A','P023A','P007A','P009A','P011A','P008B','P018B','E502A','C989A','E409A','E410A','E411A','H001A'";	
String colposcopyCodes = "'A004A','A005A','Z731A','Z666A','Z730A','Z720A'";
List<String> OBbilling_no = obj.getRABillingNo4Code(raNo, obCodes);
List<String> CObilling_no = obj.getRABillingNo4Code(raNo, colposcopyCodes);

Hashtable map = new Hashtable();
BigDecimal bdCFee = new BigDecimal(0).setScale(2, BigDecimal.ROUND_HALF_UP);     	     
BigDecimal bdPFee = new BigDecimal(0).setScale(2, BigDecimal.ROUND_HALF_UP);     	     
BigDecimal bdOFee = new BigDecimal(0).setScale(2, BigDecimal.ROUND_HALF_UP);     	     
BigDecimal bdCOFee = new BigDecimal(0).setScale(2, BigDecimal.ROUND_HALF_UP);     	     

BigDecimal bdFee = new BigDecimal(0).setScale(2, BigDecimal.ROUND_HALF_UP);
BigDecimal bdHFee = new BigDecimal(0).setScale(2, BigDecimal.ROUND_HALF_UP);
BigDecimal BigTotal = new BigDecimal(0).setScale(2, BigDecimal.ROUND_HALF_UP);
BigDecimal BigCTotal = new BigDecimal(0).setScale(2, BigDecimal.ROUND_HALF_UP);
BigDecimal BigPTotal = new BigDecimal(0).setScale(2, BigDecimal.ROUND_HALF_UP);
BigDecimal BigOTotal = new BigDecimal(0).setScale(2, BigDecimal.ROUND_HALF_UP);
BigDecimal BigCOTotal = new BigDecimal(0).setScale(2, BigDecimal.ROUND_HALF_UP);
BigDecimal BigLTotal = new BigDecimal(0).setScale(2, BigDecimal.ROUND_HALF_UP);
BigDecimal BigHTotal = new BigDecimal(0).setScale(2, BigDecimal.ROUND_HALF_UP);
BigDecimal bdOBFee = new BigDecimal(0).setScale(2, BigDecimal.ROUND_HALF_UP);
BigDecimal BigOBTotal = new BigDecimal(0).setScale(2, BigDecimal.ROUND_HALF_UP);
double dHFee = 0.00;        
double dFee = 0.00;
double dCOFee = 0.00; 
double dOBFee = 0.00; 
double dCFee = 0.00;       	
double dPFee = 0.00;       	       	
double dOFee = 0.00;

double dLocalHFee = 0.00;        
BigDecimal bdLocalHFee = new BigDecimal(0).setScale(2, BigDecimal.ROUND_HALF_UP);
BigDecimal BigLocalHTotal = new BigDecimal(0).setScale(2, BigDecimal.ROUND_HALF_UP);
String localServiceDate = "";
       	
if (raNo.compareTo("") == 0 || raNo == null){
	flag = "0";
	return;
} else {
%>

<table border="0" cellspacing="0" cellpadding="0" width="100%">
	<form action="onGenRAProvider.jsp">
	<tr class="myDarkGreen">
		<th align='LEFT'><font color="#FFFFFF"> Billing
		Reconcilliation - Summary Report</font></th>
		<th align='RIGHT'>
		<select id="loadingMsg" class="positionFilter"><option>Loading filters...</option></select>
		 <input type='button' name='print' value='Print' onClick='window.print()'>
		<input type='button' name='close' value='Close'
			onClick='window.close()'></th>
	</tr>
	</form>
</table>

<table id="ra_table" width="100%" border="0" cellspacing="1" cellpadding="0"
	class="myIvory">
	<tr class="myYellow">
		<th width="6%">Provider</th>
		<th width="8%">Claims</th>
		<th width="7%" align=right>Invoiced</th>
		<th width="7%" align=right>Paid</th>
		<th width="7%" align=right>Clinic Pay</th>
		<th width="7%" align=right>Hospital Pay</th>
		<th width="7%" align=right>OB</th>
		<th width="0" align=right style="display:none">Site</th>			
	</tr>

	<%
List aL = obj.getRASummary(raNo, OBbilling_no, CObilling_no,map);
for(int i=0; i<aL.size(); i++) { //to use table-filter js to generate the sum - so the total-1
	Properties prop = (Properties) aL.get(i);
	String color = i%2==0? "class='myGreen'":"";
	color = i == (aL.size()-1) ? "class='myYellow'" : color;
%>
	<tr <%=color %>>
		<td align="center"><a href="onGenRAProvider.jsp?proNo=<%=prop.getProperty("providerohip_no", "&nbsp;")%>&rano=<%=raNo%>&submit=Generate">
			<%=prop.getProperty("last_name", "&nbsp;")%>, <%=prop.getProperty("first_name", "&nbsp;")%></a></td>
		<td align="center"><%=prop.getProperty("claims", "&nbsp;")%></td>
		<td align=right><%=prop.getProperty("amountsubmit", "&nbsp;")%></td>
		<td align=right><%=prop.getProperty("amountpay", "&nbsp;")%></td>
		<td align=right><%=prop.getProperty("clinicPay", "&nbsp;")%></td>
		<td align=right><%=prop.getProperty("hospitalPay", "&nbsp;")%></td>
		<td align=right><%=prop.getProperty("obPay", "&nbsp;")%></td>
		<td width="0" style="display:none"><%=prop.getProperty("site", "")%></td>			
	</tr>

		<% }
}
%>
<!-- added another TR for table-filter js to automatically calculate totals based on filters -->
<tr class="myYellow">
                        <td align="center"></td>
                        <td align="center">Total:</td>
                        <td id="amountSubmit" align=right></td>
                        <td id="amountPay" align=right></td>
                        <td id="clinicPay" align=right></td>
                        <td id="hospitalPay" align=right></td>
                        <td id="OBPay" align=right></td>
                        <td align=right  width="0" style="display:none" >&nbsp;</td>


</tr>
</table>

		<%

String transaction="", content="", balancefwd="", xtotal="", other_total="", ob_total=""; 
RaHeader rh = dao.find(Integer.parseInt(raNo));
if(rh != null) {
	transaction= SxmlMisc.getXmlContent(rh.getContent(),"<xml_transaction>","</xml_transaction>");
	balancefwd= SxmlMisc.getXmlContent(rh.getContent(),"<xml_balancefwd>","</xml_balancefwd>");
}


if(!map.isEmpty()){
    BigLTotal = (BigDecimal) map.get("xml_local");
    BigPTotal = (BigDecimal) map.get("xml_total"); 
    BigOTotal = (BigDecimal) map.get("xml_other_total"); 
    BigOBTotal= (BigDecimal) map.get("xml_ob_total"); 
    BigCOTotal= (BigDecimal) map.get("xml_co_total");
}


content = content + "<xml_transaction>" + transaction + "</xml_transaction>" + "<xml_balancefwd>" + balancefwd + "</xml_balancefwd>";
content = content + "<xml_local>" + BigLTotal + "</xml_local>"+ "<xml_total>" + BigPTotal + "</xml_total>" + "<xml_other_total>" + BigOTotal + "</xml_other_total>" + "<xml_ob_total>" + BigOBTotal + "</xml_ob_total>" + "<xml_co_total>" + BigCOTotal + "</xml_co_total>";

int recordAffected=0;
RaHeader raHeader = dao.find(Integer.parseInt(raNo));
if(raHeader != null) {
	 raHeader.setContent(content);
	 dao.merge(raHeader);
	recordAffected++;
}

%>
<script language="javascript" type="text/javascript">
        document.getElementById('loadingMsg').style.display='none';
        var totRowIndex = tf_Tag(tf_Id('ra_table'),"tr").length;
        var table_Props =       {
                                        col_0: "none",
                                        col_1: "none",
                                        col_2: "none",
                                        col_3: "none",
                                        col_4: "none",
                                        col_5: "none",
                                        col_6: "none",
                                        col_7: "none",
                                        col_8: "none",
                                        col_9: "none",
                                        col_10: "none",
                                        col_11: "none",
                                        col_12: "select",
                                        display_all_text: " [ Show all clinics ] ",
                                        flts_row_css_class: "dummy",
                                        flt_css_class: "positionFilter",
                                        sort_select: true,
                                        rows_always_visible: [totRowIndex],
                                        col_operation: {
                                                                id: ["amountSubmit","amountPay","clinicPay","hospitalPay","OBPay"],
                                                                col: [7,8,9,10,11],
                                                                operation: ["sum","sum","sum","sum","sum"],
                                                                write_method: ["innerHTML","innerHTML","innerHTML","innerHTML","innerHTML"],
                                                                exclude_row: [totRowIndex],
                                                                decimal_precision: [2,2,2,2,2],
                                                                tot_row_index: [totRowIndex]
                                                        }
                                };
        var tf = setFilterGrid( "ra_table",table_Props );

</script>
	
</body>
</html>
