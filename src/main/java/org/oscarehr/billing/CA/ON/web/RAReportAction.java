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
	private Properties raReport;
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
		raReport = new Properties();
		rh = dao.find(Integer.parseInt(raNo));
		
		String message_txt="";
		String filepath="";
		String filename = "";
		String new_total = "";
		String HTMLtransaction = "";
		String balanceFwd = "";
		
		if(rh != null && !rh.getStatus().equals("D")) {
			filename =rh.getFilename();
			HTMLtransaction = SxmlMisc.getXmlContent(rh.getContent(),"<xml_transaction>","</xml_transaction>");
			balanceFwd = SxmlMisc.getXmlContent(rh.getContent(),"<xml_balancefwd>","</xml_balancefwd>");
			new_total = SxmlMisc.getXmlContent(rh.getContent(),"<xml_total>","</xml_total>");
		}
		
		raReport.setProperty("transactions", HTMLtransaction);
		raReport.setProperty("balanceFwd", balanceFwd);
		
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
					message_txt = message_txt + nextline.substring(3,73)+"\r\n";                       
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
		
		BillingONPremiumDao bPremiumDao = (BillingONPremiumDao) SpringUtils.getBean("billingONPremiumDao");
		List<BillingONPremium> bPremiumList = bPremiumDao.getRAPremiumsByRaHeaderNo(Integer.parseInt(raNo));
				
		if (!bPremiumList.isEmpty()) {
			for (BillingONPremium premium : bPremiumList) {  
                Integer premiumId = premium.getId();
                ProviderDao providerDao = (ProviderDao)SpringUtils.getBean("providerDao");
                List<Provider> pList = providerDao.getBillableProvidersByOHIPNo(premium.getProviderOHIPNo());  
                if ((pList != null) && !pList.isEmpty()) {
                    String isChecked = "";
                    if (premium.getStatus())
                         isChecked = "checked";
                         
					 for (Provider p : pList) { 
						String selectedChoice = "";
						String providerNo = p.getProviderNo();
						String premiumProviderNo = premium.getProviderNo();
						if (premiumProviderNo != null && providerNo.equals(premiumProviderNo)) {
							selectedChoice = "selected=\"selected\"";
						}
					}
				}
                        
			}
		}
		
		HttpSession session = request.getSession();
		
		session.setAttribute("raReport", raReport);   		
        session.setAttribute("bPremiumList", bPremiumList);
		
		ActionForward fwd = actionMapping.findForward("success");
		return fwd;
	}
}
