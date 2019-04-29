/**
 * Copyright (c) 2008-2012 Indivica Inc.
 *
 * This software is made available under the terms of the
 * GNU General Public License, Version 2, 1991 (GPLv2).
 * License details are available via "indivica.ca/gplv2"
 * and "gnu.org/licenses/gpl-2.0.html".
 */
package org.oscarehr.olis;

import java.io.IOException;
import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.actions.DispatchAction;
import org.json.JSONArray;
import org.json.JSONObject;
import org.oscarehr.olis.dao.OLISRequestNomenclatureDao;
import org.oscarehr.olis.dao.OLISResultNomenclatureDao;
import org.oscarehr.olis.model.OLISRequestNomenclature;
import org.oscarehr.olis.model.OLISResultNomenclature;
import org.oscarehr.olis.model.OlisQueryParameters;
import org.oscarehr.olis.model.OlisSessionManager;
import org.oscarehr.olis.model.ProviderOlisSession;
import org.oscarehr.util.LoggedInInfo;
import org.oscarehr.util.SpringUtils;

public class OLISSearchAction extends DispatchAction {

	public ActionForward loadResults(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) {

		LoggedInInfo loggedInInfo = LoggedInInfo.getLoggedInInfoFromSession(request);
		OlisQueryParameters queryParameters = new OlisQueryParameters(request);

		ProviderOlisSession providerOlisSession = OlisSessionManager.getSession(loggedInInfo);
		
		String queryType = request.getParameter("queryType");
		boolean redo = "true".equals(request.getParameter("redo"));
		if (redo) {
			boolean force = "true".equals(request.getParameter("force"));
			providerOlisSession.redoQueries(force, queryParameters, false);
		} else if (queryType != null) {
            providerOlisSession.getRequestingHicResultMap().clear();
			providerOlisSession.doQueries(queryType, queryParameters);
		}
		
		return mapping.findForward("results");
	
	}

	public ActionForward loadMoreResults(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws IOException {
		LoggedInInfo loggedInInfo = LoggedInInfo.getLoggedInInfoFromSession(request);
		OlisQueryParameters queryParameters = new OlisQueryParameters(request);
		
		ProviderOlisSession providerOlisSession = OlisSessionManager.getSession(loggedInInfo);
		providerOlisSession.redoQueries(false, queryParameters, true);
		return mapping.findForward("results");
	}

	public ActionForward searchResultCodes(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws IOException {
		OLISResultNomenclatureDao resultNomenclatureDao = SpringUtils.getBean(OLISResultNomenclatureDao.class);
		LoggedInInfo loggedInInfo=LoggedInInfo.getLoggedInInfoFromSession(request);

		String keyword = request.getParameter("term");
		
		List<OLISResultNomenclature> results = resultNomenclatureDao.searchByName(keyword);
		
		JSONArray resultArray = new JSONArray();
		
		for (OLISResultNomenclature result : results) {
			JSONObject jsonObject = new JSONObject();
			jsonObject.put("label", result.getResultAlternateName1());
			jsonObject.put("value", result.getLoincCode());
			resultArray.put(jsonObject);
		}
		
		response.setContentType("text/x-json");
		response.getWriter().print(resultArray.toString());
		response.getWriter().flush();
		//resultArray.write(response.getWriter());
		
		return null;
	}
	
	public ActionForward searchRequestCodes(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws IOException {
		OLISRequestNomenclatureDao requestNomenclatureDao = SpringUtils.getBean(OLISRequestNomenclatureDao.class);
		LoggedInInfo loggedInInfo=LoggedInInfo.getLoggedInInfoFromSession(request);

		String keyword = request.getParameter("term");
		
		List<OLISRequestNomenclature> requestNomenclatures = requestNomenclatureDao.searchByName(keyword);
		
		JSONArray resultArray = new JSONArray();
		
		for (OLISRequestNomenclature requestNomenclature : requestNomenclatures) {
			JSONObject jsonObject = new JSONObject();
			jsonObject.put("label", requestNomenclature.getRequestAlternateName1());
			jsonObject.put("value", requestNomenclature.getRequestCode());
			resultArray.put(jsonObject);
		}
		
		response.setContentType("text/x-json");
		response.getWriter().print(resultArray.toString());
		response.getWriter().flush();
		
		return null;
	}
}
