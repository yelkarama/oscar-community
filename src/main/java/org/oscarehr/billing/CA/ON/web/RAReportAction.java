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

import java.io.BufferedReader;
import java.io.FileInputStream;
import java.io.InputStreamReader;
import java.io.StringReader;
import java.io.IOException;
import java.io.FileNotFoundException;
import java.util.List;
import java.util.ArrayList;
import java.util.Properties;
import java.math.BigDecimal;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.apache.log4j.Logger;
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
import org.oscarehr.common.dao.BillingONPremiumDao;
import org.oscarehr.common.model.BillingONPremium;
import org.oscarehr.PMmodule.dao.ProviderDao;
import org.oscarehr.common.model.Provider;
import oscar.oscarBilling.ca.on.bean.RaReportBean;
import oscar.oscarBilling.ca.on.data.JdbcBillingRAImpl;
import oscar.SxmlMisc;
import oscar.OscarProperties;

/**
 *
 * @author rjonasz
 */
public class RAReportAction extends Action {
    private SecurityInfoManager securityInfoManager = SpringUtils.getBean(SecurityInfoManager.class);
    private static final Logger _logger = Logger.getLogger(JdbcBillingRAImpl.class);
    private OscarProperties props = OscarProperties.getInstance();
    
	private RaHeaderDao dao = SpringUtils.getBean(RaHeaderDao.class);
	private RaHeader rh;
    private String raNo;
    
    public ActionForward execute(ActionMapping actionMapping,
            ActionForm actionForm,
            HttpServletRequest request,
            HttpServletResponse servletResponse) {

    	if(!securityInfoManager.hasPrivilege(LoggedInInfo.getLoggedInInfoFromSession(request), "_billing", "r", null)) {
        	throw new SecurityException("missing required security object (_billing)");
        }        
		raNo = request.getParameter("rano");
		rh = dao.find(Integer.parseInt(raNo));
		
		RaReportBean raReport = new RaReportBean();
		JdbcBillingRAImpl dbObj = new JdbcBillingRAImpl();
		BillingONPremiumDao bPremiumDao = (BillingONPremiumDao) SpringUtils.getBean("billingONPremiumDao");
		
		String filepath="";
		String filename = "";
		
		List provList = dbObj.getProviderListFromRAReport(raNo);
		
		BigDecimal raInvoiceTotal = new BigDecimal(0.).setScale(2, BigDecimal.ROUND_HALF_UP); //Total Pay
		BigDecimal raRMBTotal = new BigDecimal(0.).setScale(2, BigDecimal.ROUND_HALF_UP); //RA paid
		BigDecimal raGrossTotal = new BigDecimal(0.).setScale(2, BigDecimal.ROUND_HALF_UP); //Gross paid
		BigDecimal raAutoTotal = new BigDecimal(0.).setScale(2, BigDecimal.ROUND_HALF_UP); //Automated Premiums paid
		BigDecimal raOptInTotal = new BigDecimal(0.).setScale(2, BigDecimal.ROUND_HALF_UP); //Opt In paid
		BigDecimal raAgePremTotal = new BigDecimal(0.).setScale(2, BigDecimal.ROUND_HALF_UP); //Age Premiums paid
		BigDecimal raNetTotal = new BigDecimal(0.).setScale(2, BigDecimal.ROUND_HALF_UP); //Net paid
		
		for(int i=0; i<provList.size(); i++) {
			Properties prov = (Properties) provList.get(i);
			
			BigDecimal ProvInvoiceTotal = new BigDecimal(0.).setScale(2, BigDecimal.ROUND_HALF_UP); //provider submitted
			BigDecimal ProvRMBTotal = new BigDecimal(0.).setScale(2, BigDecimal.ROUND_HALF_UP); //provider paid
			BigDecimal ProvGrossTotal = new BigDecimal(0.).setScale(2, BigDecimal.ROUND_HALF_UP); //provider gross
			BigDecimal ProvNetTotal = new BigDecimal(0.).setScale(2, BigDecimal.ROUND_HALF_UP); //provider net
			
			List provDetails = dbObj.getRAProviderDetails(raNo, prov.getProperty("providerohip_no", ""));
			String provNo = prov.getProperty("provider_no", "");

			for (int j = 0; j < provDetails.size(); j++) {
				Properties provProp = (Properties) provDetails.get(j);
				String payProgram = provProp.getProperty("payProgram");
				double dpay = Double.parseDouble(provProp.getProperty("amountpay"));
				BigDecimal bdpay = new BigDecimal(dpay).setScale(2, BigDecimal.ROUND_HALF_UP);

				if(payProgram.equals("RMB")){
					ProvRMBTotal = ProvRMBTotal.add(bdpay);
					raRMBTotal = raRMBTotal.add(bdpay);
				}else{
					ProvInvoiceTotal = ProvInvoiceTotal.add(bdpay);
					raInvoiceTotal = raInvoiceTotal.add(bdpay);
				}
				ProvGrossTotal = ProvGrossTotal.add(bdpay);
				raGrossTotal = raGrossTotal.add(bdpay);
			}
			raReport.addToProviders(prov.getProperty("last_name", "&nbsp;")+ ", " +prov.getProperty("first_name", "&nbsp;"));
			raReport.addToInvoice(ProvInvoiceTotal);
			raReport.addToRmb(ProvRMBTotal);
			raReport.addToGross(ProvGrossTotal);
			ProvNetTotal = ProvNetTotal.add(ProvGrossTotal);
						
			List<BillingONPremium> bPremiumList = bPremiumDao.getActiveRAPremiumsByProviderAndRaHeader(provNo, Integer.parseInt(raNo));
			if (!bPremiumList.isEmpty()) {
				for (BillingONPremium premium : bPremiumList) {  
					double dprem = Double.parseDouble(premium.getAmountPay());
					BigDecimal bdprem = new BigDecimal(dprem).setScale(2, BigDecimal.ROUND_HALF_UP);
					ProvNetTotal = ProvNetTotal.add(bdprem);
					
					if(premium.getPremiumType().equals("AGE PREMIUM PAYMENT")){
						raReport.addToAgePremium(bdprem);
						raAgePremTotal = raAgePremTotal.add(bdprem);
					}else if(premium.getPremiumType().equals("PAYMENT REDUCTION-AUTOMATED PREMIUMS")){
						raReport.addToAutomated(bdprem);
						raAutoTotal = raAutoTotal.add(bdprem);
					}else if(premium.getPremiumType().equals("PAYMENT REDUCTION-OPTED-IN")){
						raReport.addToOptIn(bdprem);
						raOptInTotal = raOptInTotal.add(bdprem);
					}
							
				}
			}
			raReport.addToNet(ProvNetTotal);
			raNetTotal = raNetTotal.add(ProvNetTotal);
		}
		
		if(rh != null && !rh.getStatus().equals("D")) {
			filename =rh.getFilename();
			//HTMLtransaction = SxmlMisc.getXmlContent(rh.getContent(),"<xml_transaction>","</xml_transaction>");
			//balanceFwd = SxmlMisc.getXmlContent(rh.getContent(),"<xml_balancefwd>","</xml_balancefwd>");
		}
		
		/*
		List<String> rowsInTable = SxmlMisc.getAllElementsOfTag(HTMLtransaction, "<tr>", "</tr>");
		//Skip first two rows: one is title and other is column names
		for(int i = 2; i < rowsInTable.size(); i++){
			String row = rowsInTable.get(i);
			
			List<String> elementsInRow = SxmlMisc.getAllElementsOfTag(row, "<td width='", "</td>");
			String amountString = elementsInRow.get(3).substring(5, elementsInRow.get(3).length()); //clean up rest of tag
			String transType = elementsInRow.get(4).substring(5, elementsInRow.get(4).length());
			boolean negative = false;
			
			if(amountString.indexOf("-") > -1){
					negative = true;
					amountString = amountString.substring(0, amountString.length()-1);
			}
			
			double amountd = Double.parseDouble(amountString);
			
			if(negative)
				amountd = amountd * -1;
			
			BigDecimal amountbd = new BigDecimal(amountd).setScale(2, BigDecimal.ROUND_HALF_UP);
			
			if(transType.equals()){
				
			}
			
		}
		*/
		
		filepath = props.getProperty("DOCUMENT_DIR").trim();
		try{
			FileInputStream file = new FileInputStream(filepath + filename);
			InputStreamReader reader = new InputStreamReader(file);
			BufferedReader input = new BufferedReader(reader);
			
			String nextline;
			String header ="";
			String headerCount ="";
			
			while ((nextline=input.readLine())!=null){
				header = nextline.substring(0,1);
				if (header.compareTo("H") == 0)
					headerCount = nextline.substring(2, 3);
					
				if (headerCount.compareTo("8") == 0){
					raReport.addToMessageTxt(nextline.substring(3,73)+"\r\n");                       
				}
			}
			file.close();
			reader.close();
			input.close();
		}catch(FileNotFoundException fnfe){
			_logger.error("File " + filepath + filename + " not found: " + fnfe);
		}catch(IOException ioe){
			_logger.error("Error reading " + filepath + filename + ": " + ioe);
		}

		raReport.addToProviders("Total");
		raReport.addToInvoice(raInvoiceTotal);
		raReport.addToRmb(raRMBTotal);
		raReport.addToGross(raGrossTotal);
		raReport.addToAutomated(raAutoTotal);
		raReport.addToOptIn(raOptInTotal);
		raReport.addToAgePremium(raAgePremTotal);
		raReport.addToNet(raNetTotal);
		
		HttpSession session = request.getSession();
		session.setAttribute("raReport", raReport);
		ActionForward fwd = actionMapping.findForward("success");
		return fwd;
	}
}
