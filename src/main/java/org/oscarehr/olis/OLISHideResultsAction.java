/**
 * Copyright (c) 2008-2012 Indivica Inc.
 *
 * This software is made available under the terms of the
 * GNU General Public License, Version 2, 1991 (GPLv2).
 * License details are available via "indivica.ca/gplv2"
 * and "gnu.org/licenses/gpl-2.0.html".
 */
package org.oscarehr.olis;

import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.actions.DispatchAction;
import org.oscarehr.olis.dao.OlisRemovedLabRequestDao;
import org.oscarehr.olis.model.OlisLabResultDisplay;
import org.oscarehr.olis.model.OlisRemovedLabRequest;
import org.oscarehr.olis.model.OlisSessionManager;
import org.oscarehr.olis.model.ProviderOlisSession;
import org.oscarehr.util.LoggedInInfo;
import org.oscarehr.util.MiscUtils;
import org.oscarehr.util.SpringUtils;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.util.Date;
import java.util.List;

public class OLISHideResultsAction extends DispatchAction {
    private OlisRemovedLabRequestDao olisRemovedLabRequestDao = SpringUtils.getBean(OlisRemovedLabRequestDao.class);
    private Logger logger = MiscUtils.getLogger();
    
	@Override
	public ActionForward execute(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) {
	    if ("addHideResult".equals(request.getParameter("method"))) {
            addHideResult(request);
        }
	    return mapping.findForward("ajax");
	}
	
    private void addHideResult(HttpServletRequest request) {
        LoggedInInfo loggedInInfo = LoggedInInfo.getLoggedInInfoFromSession(request);
        String loggedInProviderNo = loggedInInfo.getLoggedInProviderNo();
        
        String placerGroupNo = request.getParameter("placerGroupNo");
        String resultUuid = request.getParameter("resultUuid");
        String emrTransactionId = request.getParameter("emrTransactionId");
        String reason = StringUtils.trimToEmpty(request.getParameter("reason"));
        
        List<OlisRemovedLabRequest> alreadyRemovedLabs = olisRemovedLabRequestDao.findByAccessionNumberAndProviderNo(placerGroupNo, loggedInProviderNo);
        // If the accession number hasn't already been removed for the provider, then we will remove it. 
        // If it has been removed, we don't need to do anything  
        if (alreadyRemovedLabs.isEmpty()) {
            ProviderOlisSession olisSession = OlisSessionManager.getSession(loggedInInfo);
            List<OlisLabResultDisplay> matchedResultDisplay = olisSession.getLabResultDisplayByPlacerGroupNo(placerGroupNo);

            // For each Request in the lab, adds it to the table with the appropriate data extracted from the lab
            for (OlisLabResultDisplay resultDisplay : matchedResultDisplay) {
                Date collectionDate = resultDisplay.getCollectionDateAsDate();
                String testRequest = resultDisplay.getTestRequestName();

                // Creates the removed object and adds it to the table 
                OlisRemovedLabRequest labRequest = new OlisRemovedLabRequest(emrTransactionId, loggedInProviderNo, new Date(), reason, "Manual", "OLIS", placerGroupNo, testRequest, collectionDate, new Date());
                olisRemovedLabRequestDao.persist(labRequest);
            }
        }

        request.setAttribute("result", "Success");
    }
}