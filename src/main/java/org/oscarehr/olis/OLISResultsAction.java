/**
 * Copyright (c) 2008-2012 Indivica Inc.
 *
 * This software is made available under the terms of the
 * GNU General Public License, Version 2, 1991 (GPLv2).
 * License details are available via "indivica.ca/gplv2"
 * and "gnu.org/licenses/gpl-2.0.html".
 */
package org.oscarehr.olis;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.UUID;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.io.FileUtils;
import org.apache.commons.lang.StringUtils;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.actions.DispatchAction;
import org.oscarehr.PMmodule.dao.ProviderDao;
import org.oscarehr.common.model.Provider;
import org.oscarehr.managers.SecurityInfoManager;
import org.oscarehr.olis.model.OlisLabResultDisplay;
import org.oscarehr.olis.model.OlisLabResults;
import org.oscarehr.util.LoggedInInfo;
import org.oscarehr.util.MiscUtils;
import org.oscarehr.util.SpringUtils;

import com.indivica.olis.Driver;

import oscar.oscarLab.ca.all.parsers.Factory;
import oscar.oscarLab.ca.all.parsers.OLISHL7Handler;
import oscar.oscarLab.ca.all.util.Utilities;

public class OLISResultsAction extends DispatchAction {

	public static HashMap<String, OLISHL7Handler> searchResultsMap = new HashMap<String, OLISHL7Handler>();
    public static HashMap<String, OlisLabResults> currentResultsMap = new HashMap<String, OlisLabResults>();
	private SecurityInfoManager securityInfoManager = SpringUtils.getBean(SecurityInfoManager.class);
	 
	@Override
    public ActionForward execute(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) {

		if(!securityInfoManager.hasPrivilege(LoggedInInfo.getLoggedInInfoFromSession(request), "_lab", "r", null)) {
        	throw new SecurityException("missing required security object (_lab)");
        }

        OlisLabResults olisLabResults = new OlisLabResults();
		
		try {
			ProviderDao providerDao = SpringUtils.getBean(ProviderDao.class);
			// Gets the requestingHic's provider number
			String requestingHic = request.getParameter("requestingHic");
			String requestingPractitionerNumber = "";
			
			// Checks if the provider number is empty
			if (StringUtils.isNotEmpty(requestingHic)) {
			    // Gets the related provider and ensures that a provider is returned
				Provider provider = providerDao.getProvider(requestingHic);
				if (provider != null) {
				    // Gets the provider's practitioner number
					requestingPractitionerNumber = provider.getPractitionerNo();
				}
			}
			
			String olisResultString = (String) request.getAttribute("olisResponseContent");			
			if(olisResultString == null) {
				olisResultString = oscar.Misc.getStr(request.getParameter("olisResponseContent"), "");
				request.setAttribute("olisResponseContent", olisResultString);
				
				String olisXmlResponse = oscar.Misc.getStr(request.getParameter("olisXmlResponse"), "");
				if (olisResultString.trim().equalsIgnoreCase("")) {
					if (!olisXmlResponse.trim().equalsIgnoreCase("")) {
						Driver.readResponseFromXML(request, olisXmlResponse);
					}
					
					List<String> resultList = new LinkedList<String>();
					request.setAttribute("resultList", resultList);				
					return mapping.findForward("results");
				}
			}
			
			UUID olisResultFileUuid = UUID.randomUUID();
			File olisResultFile = new File(System.getProperty("java.io.tmpdir") + "/olis_" + olisResultFileUuid.toString() + ".response");
			FileUtils.writeStringToFile(olisResultFile, olisResultString);

            OLISHL7Handler reportHandler = (OLISHL7Handler) Factory.getHandler("OLIS_HL7", olisResultString);
            if (reportHandler != null) {
                if (reportHandler.hasPatient()) {
                    olisLabResults.setDemographicInfo(reportHandler);
                }
                
                List<OLISHL7Handler.OLISError> errors = reportHandler.getReportErrors();
                List<OLISHL7Handler.OLISError> errorsToRemove = new ArrayList<>();
                
                boolean hasBlockedContent = false;
                if (errors.size() > 0) {
                    olisLabResults.setErrors(errors);
                    boolean hasPatientConsent = reportHandler.hasPatientConsent();
					olisLabResults.setHasPatientConsent(hasPatientConsent);
                    // Loops through each error
                    for (OLISHL7Handler.OLISError error : errors) {
                        // If the error is either 320 or 920, then some of the results have blocked content and are hidden
                        if (error.getIndentifer().equals("320") || error.getIndentifer().equals("920")) {
                            hasBlockedContent = true;
							// If the error is a 920
                            if (error.getIndentifer().equals("920")) {
                                // If the error is a 920, then sets the patient level block flag so we know which
                                // consent messages to display
                                olisLabResults.setHasPatientLevelBlock(true);
								// If the error is a 920 error, then we don't need to display the 320 error
								olisLabResults.setDisplay320Error(false);
							}
                            
                            // If the patient has consent, then both 320 and 920 errors can be removed from the errors, if there is no patient consent, then checks if we need to display the 320 error
                            if (hasPatientConsent) {
                            	errorsToRemove.add(error);
							}
                        }
					}
                }
                
                errors.removeAll(errorsToRemove);
                olisLabResults.setHasBlockedContent(hasBlockedContent);
                String searchUuid = (String) request.getAttribute("searchUuid");
                olisLabResults.setQueryUsedUuid(searchUuid);
                olisLabResults.setContinuationPointer(reportHandler.getContinuationPointer());
            }
			
			@SuppressWarnings("unchecked")
            ArrayList<String> messages = Utilities.separateMessagesFromResponse(olisResultString);
			
			List<String> resultList = new LinkedList<String>();
			
			if (messages != null) {
				for (String message : messages) {
					
					String resultUuid = UUID.randomUUID().toString();

                    olisResultFile = new File(System.getProperty("java.io.tmpdir") + "/olis_" + resultUuid + ".response");
					FileUtils.writeStringToFile(olisResultFile, message);
					
					// Parse the HL7 string...
					message = message.replaceAll("\\\\H\\\\", "\\\\.H\\\\");
					message = message.replaceAll("\\\\N\\\\", "\\\\.N\\\\");
                    OLISHL7Handler olisResultHandler = (OLISHL7Handler) Factory.getHandler("OLIS_HL7", message);
					if (olisResultHandler.getOBRCount() == 0) {
						continue;
					}

					searchResultsMap.put(resultUuid, olisResultHandler);
					resultList.add(resultUuid);
					// Gets the ordering provider number from the report
					String licenceNumber = olisResultHandler.getOrderingProviderNumber();
					// Compares if the report is ordered by the requesting provider
					if (requestingPractitionerNumber.equals(licenceNumber)) {
					    // If so, sets the flag to true
						olisLabResults.setHasRequestingProvider(true);
					}
					
                    olisLabResults.getResultList().addAll(OlisLabResultDisplay.getListFromHandler(olisResultHandler, resultUuid));
				}
			}
			
			String currentViewUuid = UUID.randomUUID().toString();
			if (request.getAttribute("currentViewUuid") != null) {
				currentViewUuid = (String) request.getAttribute("currentViewUuid");
				OlisLabResults pastOlisLabResults = currentResultsMap.get(currentViewUuid);
				if (pastOlisLabResults != null) {
					olisLabResults.getResultList().addAll(pastOlisLabResults.getResultList());
					olisLabResults.getErrors().addAll(pastOlisLabResults.getErrors());
					// If the past results did not have consent carry it over
					if (!pastOlisLabResults.isHasPatientConsent()) {
						olisLabResults.setHasPatientConsent(false);
					}
					// If the past results had blocked content carry it over
					if (pastOlisLabResults.isHasBlockedContent()) {
						olisLabResults.setHasBlockedContent(true);
					}
				}
			}
			currentResultsMap.put(currentViewUuid, olisLabResults);

			request.setAttribute("resultList", resultList);
			request.setAttribute("currentViewUuid", currentViewUuid);
			request.setAttribute("olisLabResults", olisLabResults);

		} catch (IOException | NullPointerException e) {
			MiscUtils.getLogger().error("Can't pull out messages from OLIS response.", e);
		}
		return mapping.findForward("results");
	}
}
