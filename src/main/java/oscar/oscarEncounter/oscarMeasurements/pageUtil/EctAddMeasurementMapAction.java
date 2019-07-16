/**
 * Copyright (c) 2001-2002. Department of Family Medicine, McMaster University. All Rights Reserved.
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
 * This software was written for the
 * Department of Family Medicine
 * McMaster University
 * Hamilton
 * Ontario, Canada
 */


/*
 * EctEditMeasurementMapAction.java
 *
 * Created on September 29, 2007, 2:22 PM
 *
 * To change this template, choose Tools | Template Manager
 * and open the template in the editor.
 */

package oscar.oscarEncounter.oscarMeasurements.pageUtil;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;
import org.apache.struts.action.Action;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.oscarehr.managers.SecurityInfoManager;
import org.oscarehr.util.LoggedInInfo;
import org.oscarehr.util.SpringUtils;

import oscar.oscarEncounter.oscarMeasurements.data.MeasurementMapConfig;

/**
 *
 * @author wrighd
 */
public class EctAddMeasurementMapAction extends Action{
    
    Logger logger = Logger.getLogger(EctAddMeasurementMapAction.class);
    private SecurityInfoManager securityInfoManager = SpringUtils.getBean(SecurityInfoManager.class);
    
    
    /** Creates a new instance of EctEditMeasurementMapAction */
    public EctAddMeasurementMapAction() {
    }
    
    public ActionForward execute(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException{
        
    	if( securityInfoManager.hasPrivilege(LoggedInInfo.getLoggedInInfoFromSession(request), "_admin", "w", null) || securityInfoManager.hasPrivilege(LoggedInInfo.getLoggedInInfoFromSession(request), "_admin.measurements", "w", null) )  {
    	
        String identifier = request.getParameter("identifier");
        String loinc_code = request.getParameter("loinc_code");
        String outcome = "continue";
        
        if (loinc_code != null && identifier != null){
            
                String[] measurement = identifier.split(",");
                MeasurementMapConfig mmc = new MeasurementMapConfig();
                if (!mmc.checkLoincMapping(loinc_code, measurement[1], measurement[2]) && validate(loinc_code)){
                    mmc.mapMeasurement(measurement[0], loinc_code, measurement[2], measurement[1]);
                    outcome = "success";
                }else{
                    outcome = "failedcheck";
                }
                
        }
        return mapping.findForward(outcome);
        
    	}else{
			throw new SecurityException("Access Denied!"); //missing required security object (_admin)
		
    	} 
    }
    
    private boolean validate (String loinc_code) {
        if (StringUtils.isEmpty(loinc_code) || loinc_code.length() > 20) {
            return false;
        }
        if (loinc_code.startsWith("x") || loinc_code.startsWith("X")) {
            return true;
        }
        
        String[] codeArray = loinc_code.split("-");
        
        if (codeArray.length != 2 || !StringUtils.isNumeric(codeArray[0]) || !StringUtils.isNumeric(codeArray[1])) {
            return false;
        }

        boolean even = false;
        
        if (codeArray[0].length() % 2 == 0) {
            even = true;
        }
        
        String evenNumbers = "";
        String oddNumbers = "";
        
        for (int i = codeArray[0].length()-1; i >= 0; i--) {
            if (even) {
                even = false;
                evenNumbers += codeArray[0].charAt(i);
            } else {
                even = true;
                oddNumbers += codeArray[0].charAt(i);
            }
        }
        
        oddNumbers = String.valueOf(Integer.parseInt(oddNumbers)*2);
        
        String newNum = evenNumbers + oddNumbers;
        int sum = 0;
        
        for (int i = 0; i < newNum.length(); i++) {
            sum += Integer.parseInt(String.valueOf(newNum.charAt(i)));
        }
        
        int newSum = sum;
        
        while ((newSum % 10) != 0) {
            newSum++;
        }
        
        int checkDigit = newSum - sum;
        
        if (checkDigit == Integer.parseInt(codeArray[1])) {
            return true;
        }
        
        return false;
    }
}
