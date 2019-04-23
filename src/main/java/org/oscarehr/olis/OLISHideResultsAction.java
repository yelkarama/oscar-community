/**
 * Copyright (c) 2008-2012 Indivica Inc.
 *
 * This software is made available under the terms of the
 * GNU General Public License, Version 2, 1991 (GPLv2).
 * License details are available via "indivica.ca/gplv2"
 * and "gnu.org/licenses/gpl-2.0.html".
 */
package org.oscarehr.olis;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.actions.DispatchAction;
import org.oscarehr.olis.dao.OlisFilteredLabResultDao;
import org.oscarehr.olis.model.OlisFilteredLabResult;
import org.oscarehr.util.LoggedInInfo;
import org.oscarehr.util.SpringUtils;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class OLISHideResultsAction extends DispatchAction {
    private OlisFilteredLabResultDao olisFilteredLabResultDao = SpringUtils.getBean(OlisFilteredLabResultDao.class);
    
	@Override
	public ActionForward execute(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) {
	    if ("addHideResult".equals(request.getParameter("method"))) {
            addHideResult(request);
        }
	    return mapping.findForward("ajax");
	}
	
    private void addHideResult(HttpServletRequest request) {
        LoggedInInfo loggedInInfo = LoggedInInfo.getLoggedInInfoFromSession(request);


        String placerGroupNo = request.getParameter("placerGroupNo");
        String loggedInProviderNo = loggedInInfo.getLoggedInProviderNo();
        
        OlisFilteredLabResult existingFilteredLabResult = olisFilteredLabResultDao.findByPlacerGroupNoAndProviderNo(placerGroupNo, loggedInProviderNo);

        if (existingFilteredLabResult == null) {
            OlisFilteredLabResult newHiddenResult = new OlisFilteredLabResult();
            newHiddenResult.setPlacerGroupNo(placerGroupNo);
            newHiddenResult.setProviderNo(loggedInProviderNo);
            olisFilteredLabResultDao.persist(newHiddenResult);
        }

        request.setAttribute("result", "Success");
    }
}
