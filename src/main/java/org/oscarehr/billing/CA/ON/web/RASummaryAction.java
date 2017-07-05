/**
 *
 * Copyright (c) 2005-2012. Centre for Research on Inner City Health, St. Michael's Hospital, Toronto. All Rights Reserved.
 * This software is published under the GPL GNU General Public License.
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 *
 * This software was written for
 * Centre for Research on Inner City Health, St. Michael's Hospital,
 * Toronto, Ontario, Canada
 */


package org.oscarehr.billing.CA.ON.web;

import java.util.List;
import java.util.ArrayList;
import java.util.Hashtable;
import java.util.Properties;
import java.math.BigDecimal;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.apache.struts.action.Action;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;

import org.oscarehr.managers.SecurityInfoManager;
import org.oscarehr.util.LoggedInInfo;
import org.oscarehr.util.MiscUtils;
import org.oscarehr.util.SpringUtils;

import org.oscarehr.common.dao.RaHeaderDao;
import org.oscarehr.common.model.RaHeader;
import oscar.oscarBilling.ca.on.bean.RaSummaryBean;
import oscar.oscarBilling.ca.on.data.JdbcBillingRAImpl;
import oscar.SxmlMisc;

/**
 *
 * @author rjonasz
 */
public class RASummaryAction extends Action {
    private SecurityInfoManager securityInfoManager = SpringUtils.getBean(SecurityInfoManager.class);
    
	private String obCodes = "'P006A','P020A','P022A','P028A','P023A','P007A','P009A','P011A','P008B','P018B','E502A','C989A','E409A','E410A','E411A','H001A'";	
	private String colposcopyCodes = "'A004A','A005A','Z731A','Z666A','Z730A','Z720A'";	
	
	private Hashtable map;
    private String raNo;
    
    public ActionForward execute(ActionMapping actionMapping,
            ActionForm actionForm,
            HttpServletRequest request,
            HttpServletResponse servletResponse) {

    	if(!securityInfoManager.hasPrivilege(LoggedInInfo.getLoggedInInfoFromSession(request), "_billing", "r", null)) {
        	throw new SecurityException("missing required security object (_billing)");
        }
        raNo = request.getParameter("rano");
        
        RaSummaryBean raSummary = new RaSummaryBean();
        RaHeaderDao dao = SpringUtils.getBean(RaHeaderDao.class);
		RaHeader raHeader = dao.find(Integer.parseInt(raNo));
        
        RASummaryByProvider(raSummary);
		
		String HTMLtransaction = "";
		String htmlBalancefwd = "";
		if(raHeader != null && !raHeader.getStatus().equals("D")) {
			HTMLtransaction= SxmlMisc.getXmlContent(raHeader.getContent(),"<xml_transaction>","</xml_transaction>");
			htmlBalancefwd= SxmlMisc.getXmlContent(raHeader.getContent(),"<xml_balancefwd>","</xml_balancefwd>");
		}
		
		List<String> rowsInTable = SxmlMisc.getAllElementsOfTag(HTMLtransaction, "<tr>", "</tr>");
		//Skip first two rows: one is title and other is column names
		for(int i = 2; i < rowsInTable.size(); i++){
			String row = rowsInTable.get(i);
			
			List<String> elementsInRow = SxmlMisc.getAllElementsOfTag(row, "<td width='", "</td>");
			String amountString = elementsInRow.get(3).substring(5, elementsInRow.get(3).length()); //clean up rest of tag
			String transType = elementsInRow.get(4).substring(5, elementsInRow.get(4).length());
			boolean negative = false;
			
			Properties transaction = new Properties();
			
			if(amountString.indexOf("-") > -1){
					negative = true;
					amountString = amountString.substring(0, amountString.length()-1);
			}
			
			double amountd = Double.parseDouble(amountString);
			
			if(negative)
				amountd = amountd * -1;
			
			BigDecimal amountbd = new BigDecimal(amountd).setScale(2, BigDecimal.ROUND_HALF_UP);
			
			if(negative){
				raSummary.addToRaTotalNeg(amountbd);
				transaction.setProperty("negative", "true");
			}else{
				raSummary.addToRaTotalPos(amountbd);
			}
			
			transaction.setProperty("type", transType);
			transaction.setProperty("amount",  amountbd.toString());
			
			raSummary.addAccountingTransaction(transaction);
		}
		
		rowsInTable =  SxmlMisc.getAllElementsOfTag(htmlBalancefwd, "<tr>", "</tr>");
		//only one row to parse here:
		String row = rowsInTable.get(2);
		
		List<String> elementsInRow = SxmlMisc.getAllElementsOfTag(row, "<td>", "</td>");
		List<BigDecimal> abfAmounts = new ArrayList<BigDecimal>();

		for(int i=0; i < elementsInRow.size(); i++){
			String amountString = elementsInRow.get(i);
			boolean negative = false;
			
			if(amountString.indexOf("-") > -1){
					negative = true;
					amountString = amountString.substring(0, amountString.length()-1);
			}
			
			double amountd = 0.00;
			if (amountString.length() > 0){
				amountd = Double.parseDouble(amountString);			
				if(negative){
					amountd = amountd * -1;
				}
			}
			
			BigDecimal amountbd = new BigDecimal(amountd).setScale(2, BigDecimal.ROUND_HALF_UP);
			abfAmounts.add(amountbd);
			
			if(negative)
				raSummary.addToRaTotalNeg(amountbd);
			else
				raSummary.addToRaTotalPos(amountbd);
		}
		raSummary.setAbfClaimsAdjust(abfAmounts.get(0));
		raSummary.setAbfAdvances(abfAmounts.get(1));
		raSummary.setAbfReductions(abfAmounts.get(2));
		raSummary.setAbfDeductions(abfAmounts.get(3));
		
		raSummary.calcRaTotalNet();
		
		HttpSession session = request.getSession();
        session.setAttribute("raSummary", raSummary);   		
        session.setAttribute("raNo", raNo);   		
		ActionForward fwd = actionMapping.findForward("success");
		return fwd;
	}
	
	private void RASummaryByProvider(RaSummaryBean raSummary){
		JdbcBillingRAImpl dbObj = new JdbcBillingRAImpl();
		
		List<String> OBbilling_no = dbObj.getRABillingNo4Code(raNo, obCodes);
		List<String> CObilling_no = dbObj.getRABillingNo4Code(raNo, colposcopyCodes);
		map = new Hashtable();
		
		int raClaimCount = 0;
		BigDecimal raCTotal = new BigDecimal(0.).setScale(2, BigDecimal.ROUND_HALF_UP); //RA submitted
		BigDecimal raPTotal = new BigDecimal(0.).setScale(2, BigDecimal.ROUND_HALF_UP); //RA paid
		BigDecimal raLocalHTotal = new BigDecimal(0.).setScale(2, BigDecimal.ROUND_HALF_UP); //RA local hospital pay
		BigDecimal raHTotal = new BigDecimal(0.).setScale(2, BigDecimal.ROUND_HALF_UP); //RA hospital pay
		BigDecimal raClinicTotal = new BigDecimal(0.).setScale(2, BigDecimal.ROUND_HALF_UP); //RA clinic pay
		BigDecimal raOTotal = new BigDecimal(0.).setScale(2, BigDecimal.ROUND_HALF_UP); //RA other pay
		BigDecimal raLTotal = new BigDecimal(0.).setScale(2, BigDecimal.ROUND_HALF_UP); //RA local pay
		BigDecimal raRTotal = new BigDecimal(0.).setScale(2, BigDecimal.ROUND_HALF_UP); //RA RMB pay
		
		List provList = dbObj.getProviderListFromRAReport(raNo);
		
		for(int i=0; i<provList.size(); i++) {
			Properties prov = (Properties) provList.get(i);
			List provDetails = dbObj.getRASummary(raNo, prov.getProperty("providerohip_no", ""));
			int claimCount = 0;
			
			BigDecimal ProvCTotal = new BigDecimal(0.).setScale(2, BigDecimal.ROUND_HALF_UP); //provider submitted
			BigDecimal ProvPTotal = new BigDecimal(0.).setScale(2, BigDecimal.ROUND_HALF_UP); //provider paid
			BigDecimal ProvOBTotal = new BigDecimal(0.).setScale(2, BigDecimal.ROUND_HALF_UP); //provider OB paid
			BigDecimal ProvCOTotal = new BigDecimal(0.).setScale(2, BigDecimal.ROUND_HALF_UP); //provider colonoscopy paid
			BigDecimal ProvLocalHTotal = new BigDecimal(0.).setScale(2, BigDecimal.ROUND_HALF_UP); //provider local hospital pay
			BigDecimal ProvHTotal = new BigDecimal(0.).setScale(2, BigDecimal.ROUND_HALF_UP); //provider hospital pay
			BigDecimal ProvClinicTotal = new BigDecimal(0.).setScale(2, BigDecimal.ROUND_HALF_UP); //provider clinic pay
			BigDecimal ProvOTotal = new BigDecimal(0.).setScale(2, BigDecimal.ROUND_HALF_UP); //provider other pay
			BigDecimal ProvLTotal = new BigDecimal(0.).setScale(2, BigDecimal.ROUND_HALF_UP); //provider local pay
			BigDecimal ProvRTotal = new BigDecimal(0.).setScale(2, BigDecimal.ROUND_HALF_UP); //provider RMB pay

			for (int j = 0; j < provDetails.size(); j++) {
				Properties provProp = (Properties) provDetails.get(j);
				
				claimCount++;
				
				String servicedate = provProp.getProperty("servicedate");
				servicedate = servicedate.length() == 8 ? (servicedate.substring(0, 4) + "-" + servicedate.substring(4, 6)
					+ "-" + servicedate.substring(6)) : servicedate;
				
				String demo_hin = provProp.getProperty("demo_hin");
				String explain = provProp.getProperty("explain");
				String amountsubmit = provProp.getProperty("amountsubmit");
				String amountpay = provProp.getProperty("amountpay");
				String location = provProp.getProperty("location");
				String localServiceDate = provProp.getProperty("localServiceDate");
				String account = provProp.getProperty("account");
				String payProgram = provProp.getProperty("payProgram");
				
				double dCFee = Double.parseDouble(amountsubmit);
				BigDecimal bdCFee = new BigDecimal(dCFee).setScale(2, BigDecimal.ROUND_HALF_UP);
				ProvCTotal = ProvCTotal.add(bdCFee);

				double dPFee = Double.parseDouble(amountpay);
				BigDecimal bdPFee = new BigDecimal(dPFee).setScale(2, BigDecimal.ROUND_HALF_UP);
				ProvPTotal = ProvPTotal.add(bdPFee);
				
				String COflag = "0";
				String OBflag = "0";
				// set flag
				for (int k = 0; k < OBbilling_no.size(); k++) {
					String sqlRAOB = (String) OBbilling_no.get(k);
					if (sqlRAOB.compareTo(account) == 0) {
						OBflag = "1";
						break;
					}
				}
				for (int k = 0; k < CObilling_no.size(); k++) {
					String sqlRACO = (String) CObilling_no.get(k);
					if (sqlRACO.compareTo(account) == 0) {
						COflag = "1";
						break;
					}
				}

				if (OBflag.equals("1")) {
					String amountOB = amountpay;
					double dOBFee = Double.parseDouble(amountOB);
					BigDecimal bdOBFee = new BigDecimal(dOBFee).setScale(2, BigDecimal.ROUND_HALF_UP);
					ProvOBTotal = ProvOBTotal.add(bdOBFee);
				}

				if (COflag.equals("1")) {
					String amountCO = amountpay;
					double dCOFee = Double.parseDouble(amountCO);
					BigDecimal bdCOFee = new BigDecimal(dCOFee).setScale(2, BigDecimal.ROUND_HALF_UP);
					ProvCOTotal = ProvCOTotal.add(bdCOFee);
				}

				if (location.compareTo("02") == 0) {
					double dHFee = Double.parseDouble(amountpay);
					BigDecimal bdHFee = new BigDecimal(dHFee).setScale(2, BigDecimal.ROUND_HALF_UP);
					ProvHTotal = ProvHTotal.add(bdHFee);
					
					// is local for hospital
					if (demo_hin.length() > 1 && servicedate.equals(localServiceDate)) {
						ProvLocalHTotal = ProvLocalHTotal.add(bdHFee);
					}
				} else {
					if (location.compareTo("00") == 0 && demo_hin.length() > 1 && servicedate.equals(localServiceDate)) {
						double dFee = Double.parseDouble(amountpay);
						BigDecimal bdFee = new BigDecimal(dFee).setScale(2, BigDecimal.ROUND_HALF_UP);
						ProvClinicTotal = ProvClinicTotal.add(bdFee);
					} else {
						double dOFee = Double.parseDouble(amountpay);
						BigDecimal bdOFee = new BigDecimal(dOFee).setScale(2, BigDecimal.ROUND_HALF_UP);
						ProvOTotal = ProvOTotal.add(bdOFee);
					}
				}
				
				if(payProgram.equals("RMB")){
					double dRMB = Double.parseDouble(amountpay);
					BigDecimal bdRMB = new BigDecimal(dRMB).setScale(2, BigDecimal.ROUND_HALF_UP);
					ProvRTotal = ProvRTotal.add(bdRMB);
				}
			}

			ProvLTotal = ProvLTotal.add(ProvClinicTotal);
			ProvLTotal = ProvLTotal.add(ProvLocalHTotal);
			
			Properties provRASummary = new Properties();
			provRASummary.setProperty("providerName", prov.getProperty("last_name", "&nbsp;")+ ", " +prov.getProperty("first_name", "&nbsp;"));
			provRASummary.setProperty("pohipno", prov.getProperty("providerohip_no", "&nbsp;"));
			provRASummary.setProperty("claims", claimCount + "");
			provRASummary.setProperty("amountInvoiced", ProvCTotal.toString());
			provRASummary.setProperty("amountPay", ProvPTotal.toString());
			provRASummary.setProperty("localPay", ProvLTotal.toString());
			provRASummary.setProperty("clinicPay", ProvClinicTotal.toString());
			provRASummary.setProperty("localHospitalPay", ProvLocalHTotal.toString());
			provRASummary.setProperty("hospitalPay", ProvHTotal.toString());
			provRASummary.setProperty("obPay", ProvOBTotal.toString());
			provRASummary.setProperty("coPay", ProvCOTotal.toString());
			provRASummary.setProperty("otherPay", ProvOTotal.toString());
			provRASummary.setProperty("RMBPay", ProvRTotal.toString());
			raSummary.addToProvBreakDown(provRASummary);
			
			raClaimCount += claimCount;
			raCTotal = raCTotal.add(ProvCTotal);
			raPTotal = raPTotal.add(ProvPTotal);
			raLocalHTotal = raLocalHTotal.add(ProvLocalHTotal);
			raHTotal = raHTotal.add(ProvHTotal);
			raClinicTotal = raClinicTotal.add(ProvClinicTotal);
			raOTotal = raOTotal.add(ProvOTotal);
			raLTotal = raLTotal.add(ProvLTotal);
			raRTotal = raRTotal.add(ProvRTotal);
		
		}
		
		raSummary.addToRaTotalPos(raPTotal);
		
		Properties RASubTotal = new Properties();
		RASubTotal.setProperty("claims", raClaimCount + "");
		RASubTotal.setProperty("amountInvoiced", raCTotal.toString());
		RASubTotal.setProperty("amountPay", raPTotal.toString());
		RASubTotal.setProperty("localPay", raLTotal.toString());
		RASubTotal.setProperty("clinicPay", raClinicTotal.toString());
		RASubTotal.setProperty("localHospitalPay", raLocalHTotal.toString());
		RASubTotal.setProperty("hospitalPay", raHTotal.toString());
		RASubTotal.setProperty("otherPay", raOTotal.toString());
		RASubTotal.setProperty("RMBPay", raRTotal.toString());
		raSummary.addToProvBreakDown(RASubTotal);
	}
}
