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
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.UUID;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.codec.digest.DigestUtils;
import org.apache.commons.io.FileUtils;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.actions.DispatchAction;
import org.oscarehr.common.dao.OLISResultsDao;
import org.oscarehr.common.model.OLISResults;
import org.oscarehr.managers.SecurityInfoManager;
import org.oscarehr.util.LoggedInInfo;
import org.oscarehr.util.MiscUtils;
import org.oscarehr.util.SpringUtils;

import com.indivica.olis.Driver;
import com.indivica.olis.queries.Query;

import oscar.log.LogAction;
import oscar.oscarLab.ca.all.parsers.Factory;
import oscar.oscarLab.ca.all.parsers.MessageHandler;
import oscar.oscarLab.ca.all.parsers.OLISHL7Handler;
import oscar.oscarLab.ca.all.upload.MessageUploader;
import oscar.oscarLab.ca.all.util.Utilities;

public class OLISResultsAction extends DispatchAction {

	public static HashMap<String, OLISHL7Handler> searchResultsMap = new HashMap<String, OLISHL7Handler>();
	private SecurityInfoManager securityInfoManager = SpringUtils.getBean(SecurityInfoManager.class);
	protected OLISResultsDao olisResultsDao = SpringUtils.getBean(OLISResultsDao.class);
	
	@Override
    public ActionForward execute(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) {

		if(!securityInfoManager.hasPrivilege(LoggedInInfo.getLoggedInInfoFromSession(request), "_lab", "r", null)) {
        	throw new SecurityException("missing required security object (_lab)");
        }
		
		try {
			String olisResultString = (String) request.getAttribute("olisResponseContent");			
			olisResultString = (String)request.getSession().getAttribute("olisResponseContent");
			if(olisResultString == null) {
				olisResultString = oscar.Misc.getStr(request.getParameter("olisResponseContent"), "");
				request.setAttribute("olisResponseContent", olisResultString);
				
				String olisXmlResponse = oscar.Misc.getStr(request.getParameter("olisXmlResponse"), "");
				if (olisResultString.trim().equalsIgnoreCase("")) {
					if (!olisXmlResponse.trim().equalsIgnoreCase("")) {
						Driver.readResponseFromXML(LoggedInInfo.getLoggedInInfoFromSession(request), request, olisXmlResponse);
					}
					
					List<String> resultList = new LinkedList<String>();
					request.setAttribute("resultList", resultList);				
					return mapping.findForward("results");
				}
			}
			
			UUID uuid = UUID.randomUUID();
			
			Query query = (Query)request.getSession().getAttribute("olisResponseQuery");

			File tempFile = new File(System.getProperty("java.io.tmpdir") + "/olis_" + uuid.toString() + ".response");
			FileUtils.writeStringToFile(tempFile, olisResultString);

			
			@SuppressWarnings("unchecked")
            ArrayList<String> messages = Utilities.separateMessages(System.getProperty("java.io.tmpdir") + "/olis_" + uuid.toString() + ".response");
			
			List<String> resultList = new LinkedList<String>();
			
			if (messages != null) {
				for (String message : messages) {
					
					String resultUuid = UUID.randomUUID().toString();
										
					tempFile = new File(System.getProperty("java.io.tmpdir") + "/olis_" + resultUuid.toString() + ".response");
					FileUtils.writeStringToFile(tempFile, message);
					
					
					String messageNoMSH = message.replaceAll("^MSH.*[\\r\\n]+", "");
					String hash = DigestUtils.md5Hex(messageNoMSH); //need to remove the MSH line i guess
					if(!olisResultsDao.hasExistingResult(query.getRequestingHICProviderNo() != null ? query.getRequestingHICProviderNo() : LoggedInInfo.getLoggedInInfoFromSession(request).getLoggedInProviderNo(), query.getQueryType().toString(), hash)) {
						
						boolean dup2 = OLISUtils.isDuplicate(LoggedInInfo.getLoggedInInfoFromSession(request), new File(System.getProperty("java.io.tmpdir") + "/olis_" + resultUuid + ".response"));
						if(!dup2) {
							OLISResults result = new OLISResults();
							result.setHash(hash);
							result.setProviderNo(LoggedInInfo.getLoggedInInfoFromSession(request).getLoggedInProviderNo());
							result.setQuery(query.getQueryHL7String());
							result.setQueryType(query.getQueryType().toString());
							result.setResults(message);
							//result.setStatus(status);
							result.setUuid(resultUuid);
							if(query.getRequestingHICProviderNo() != null)
								result.setRequestingHICProviderNo(query.getRequestingHICProviderNo());
							else
								result.setRequestingHICProviderNo(result.getProviderNo());
							
							MessageHandler h = Factory.getHandler("OLIS_HL7", result.getResults());
							
							Integer demId = MessageUploader.willOLISLabReportMatch(LoggedInInfo.getLoggedInInfoFromSession(request), h.getLastName(),h.getFirstName(), h.getSex(), h.getDOB(), h.getHealthNum());
							if(demId != null) {
								result.setDemographicNo(demId);
							}
							olisResultsDao.persist(result);
						} else {
							//duplicate from community lab already in OSCAR
							LogAction.addLog(LoggedInInfo.getLoggedInInfoFromSession(request).getLoggedInProviderNo(), "OLIS","DUPLICATE (Community Lab)", uuid.toString() , null);
						}
					} else {
						//duplicate from OLIS
						LogAction.addLog(LoggedInInfo.getLoggedInInfoFromSession(request).getLoggedInProviderNo(), "OLIS","DUPLICATE (OLIS)", uuid.toString() , null);
					}
					 
				}
				
				//create a new result list based on whats in the DB
				List<OLISResults> results = olisResultsDao.getResultList(query.getRequestingHICProviderNo() != null ? query.getRequestingHICProviderNo() : LoggedInInfo.getLoggedInInfoFromSession(request).getLoggedInProviderNo(), query.getQueryType().toString());
				for(OLISResults result : results) {
					MessageHandler h = Factory.getHandler("OLIS_HL7", result.getResults());
					searchResultsMap.put(result.getUuid(), (OLISHL7Handler)h);
					resultList.add(result.getUuid());
				}
				
				request.setAttribute("resultList", resultList);
			}

		} catch (Exception e) {
			MiscUtils.getLogger().error("Can't pull out messages from OLIS response.", e);
		}
		return mapping.findForward("results");
	}
}
