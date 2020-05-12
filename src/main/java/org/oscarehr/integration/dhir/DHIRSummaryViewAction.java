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
package org.oscarehr.integration.dhir;

import java.io.IOException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.actions.DispatchAction;
import org.hl7.fhir.r4.model.Bundle;
import org.hl7.fhir.r4.model.Immunization;
import org.hl7.fhir.r4.model.Resource;
import org.hl7.fhir.r4.model.ResourceType;
import org.oscarehr.common.dao.DemographicDao;
import org.oscarehr.common.dao.PreventionDao;
import org.oscarehr.common.model.Demographic;
import org.oscarehr.common.model.Prevention;
import org.oscarehr.integration.TokenExpiredException;
import org.oscarehr.util.MiscUtils;
import org.oscarehr.util.SpringUtils;

import ca.uhn.fhir.context.FhirContext;
import net.sf.json.JSONArray;
import net.sf.json.JSONObject;

public class DHIRSummaryViewAction extends DispatchAction {

	Logger logger = MiscUtils.getLogger();
	DemographicDao demographicDao = SpringUtils.getBean(DemographicDao.class);

	public ActionForward unspecified(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws IOException {
		SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");

		List<ImmunizationHandler> handlers = new ArrayList<ImmunizationHandler>();

		String demographicNo = request.getParameter("demographic_no");
		String startDateStr = request.getParameter("startDate");
		String endDateStr = request.getParameter("endDate");

		Demographic demographic = demographicDao.getDemographic(demographicNo);

		if (StringUtils.isEmpty(demographic.getHin())) {
			JSONObject root = new JSONObject();
			root.put("error", "No Health Card Number");
			root.write(response.getWriter());
			return null;
		}
		if (StringUtils.isEmpty(demographic.getFormattedDob())) {
			JSONObject root = new JSONObject();
			root.put("error", "No valid Date of Birth");
			root.write(response.getWriter());
			return null;
		}

		Date startDate = null;
		Date endDate = null;
		SimpleDateFormat fmt1 = new SimpleDateFormat("yyyy-MM-dd");
		try {
			startDate = fmt1.parse(startDateStr);
		} catch (ParseException e) {
		}
		try {
			endDate = fmt1.parse(endDateStr);
		} catch (ParseException e) {
		}

		DHIRManager mgr = new DHIRManager();
		Bundle bundle = null;
		try {
			bundle = mgr.search(request, demographic, startDate, endDate);
		} catch (TokenExpiredException e) {
			JSONObject root = new JSONObject();
			root.put("error", e.getMessage());
			root.put("requireNewToken",true);
			root.write(response.getWriter());
			return null;
		} catch (ConsentBlockException e) {
			JSONObject root = new JSONObject();
			root.put("error", e.getMessage());
			root.write(response.getWriter());
			return null;
		} catch (DHIRException e) {
			JSONObject root = new JSONObject();
			root.put("error", e.getMessage());
			root.write(response.getWriter());
			return null;
		} catch (Exception e) {
			logger.error("Error", e);
			JSONObject root = new JSONObject();
			root.put("error", e.getMessage());
			root.write(response.getWriter());
			return null;
		}

		//TODO:
		if (bundle == null) {
			logger.debug("null bundle");
			JSONObject root = new JSONObject();
			root.put("error", "An error occured retrieving the data");
			root.write(response.getWriter());
			return null;
		}

		logger.info(FhirContext.forR4().newJsonParser().encodeResourceToString(bundle));

		SearchResultsHandler handler = new SearchResultsHandler(bundle);

		for (Immunization immunization : handler.getImmunizationResources()) {
			handlers.add(new ImmunizationHandler(immunization));
		}
		request.setAttribute("handlers", handlers);

		//convert to JSON
		JSONObject root = new JSONObject();
		JSONArray imms = new JSONArray();

		for (ImmunizationHandler iHandler : handlers) {
			JSONObject imm = new JSONObject();
			imm.put("immunizationDate", emptyIfNull(iHandler.getImmunizationDate()));
			imm.put("validFlag", emptyIfNull(iHandler.getValidFlag()));
			imm.put("agent", emptyIfNull(iHandler.getAgent()));
			imm.put("tradeName", emptyIfNull(iHandler.getTradeName()));
			imm.put("lotNumber", emptyIfNull(iHandler.getLotNumber()));
			imm.put("status", emptyIfNull(iHandler.getStatus()));
			imm.put("PHU", emptyIfNull(iHandler.getPHU()));
			imm.put("performerName", emptyIfNull(iHandler.getPerformerName(handler.getAllResources())));
			imm.put("expirationDate", emptyIfNull(iHandler.getExpirationDate()));

			imms.add(imm);
		}

		SimpleDateFormat fmt = new SimpleDateFormat("yyyy-MM-dd hh:mm:ss");
		//root.put("timestamp", fmt.format(handler.getTimestamp()));
		root.put("timestamp", "");
		root.put("startDate", startDateStr);
		root.put("endDate", endDateStr);
		root.put("immunizations", imms);

		//Forecasting
		Map<String, Resource> map = handler.getAllResources();
		JSONArray recommendations = new JSONArray();

		for (Resource r : map.values()) {
			if (r.getResourceType() == ResourceType.ImmunizationRecommendation) {
				ImmunizationRecommendationsHandler irHandler = new ImmunizationRecommendationsHandler((org.hl7.fhir.r4.model.ImmunizationRecommendation) r);

				String dateGenerated = sdf.format(irHandler.getDate());

				Map<String, List<JSONObject>> mapByStatus = new HashMap<String, List<JSONObject>>();
				mapByStatus.put("Overdue", new ArrayList<JSONObject>());
				mapByStatus.put("Up to date", new ArrayList<JSONObject>());
				mapByStatus.put("Due", new ArrayList<JSONObject>());
				mapByStatus.put("Eligible but not due", new ArrayList<JSONObject>());
				
				for (ImmunizationRecommendation ir : irHandler.getRecs()) {
					JSONObject rec = new JSONObject();

					JSONArray vaccineCodes = new JSONArray();
					for (Coding c : ir.getCodes()) {
						JSONObject v = new JSONObject();
						v.put("system", c.getSystem());
						v.put("code", c.getCode());
						v.put("display", c.getDisplay());
						vaccineCodes.add(v);
					}
					rec.put("vaccineCodes", vaccineCodes);
					rec.put("targetDisease", emptyIfNull(ir.getTargetDisease()));

					rec.put("date", sdf.format(ir.getDate()));

					Coding c = ir.getForecastStatus();
					JSONObject fs = new JSONObject();
					fs.put("system", c.getSystem());
					fs.put("code", c.getCode());
					fs.put("display", c.getDisplay());
					rec.put("forecastStatus", fs);

					rec.put("dateGenerated", dateGenerated);

					if(mapByStatus.get(c.getDisplay()) == null) {
						List<JSONObject> jList = new ArrayList<JSONObject>();
						jList.add(rec);
						mapByStatus.put(c.getDisplay(),jList);
					} else {
						List<JSONObject> jList = mapByStatus.get(c.getDisplay());
						jList.add(rec);
					}
					recommendations.add(rec);
				}

				root.put("recommendations", recommendations);
				
				JSONObject rec2 = new JSONObject();
				for(String key : mapByStatus.keySet()) {
					JSONArray arr = new JSONArray();
					arr.addAll(mapByStatus.get(key));
					rec2.put(key,arr);
				}
				root.put("recommendationsByStatus",rec2);
			}

		}

		root.write(response.getWriter());

		return null;

	}

	public ActionForward emrData(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
		PreventionDao preventionDao = SpringUtils.getBean(PreventionDao.class);
		SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");

		
		String startDateStr = request.getParameter("startDate");
		String endDateStr = request.getParameter("endDate");

		Date startDate = null;
		Date endDate = null;
		SimpleDateFormat fmt1 = new SimpleDateFormat("yyyy-MM-dd");
		try {
			startDate = fmt1.parse(startDateStr);
		} catch (ParseException e) {
		}
		try {
			endDate = fmt1.parse(endDateStr);
			Calendar c = Calendar.getInstance();
			c.setTime(endDate);
			c.set(Calendar.HOUR_OF_DAY,23);
			c.set(Calendar.MINUTE,59);
			c.set(Calendar.SECOND,59);
			endDate = c.getTime();
		} catch (ParseException e) {
		}
		
		
		
		List<Prevention> preventions = preventionDao.findActiveByDemoIdWithDates(Integer.parseInt(request.getParameter("demographic_no")),startDate,endDate);

		JSONObject root = new JSONObject();
		JSONArray imms = new JSONArray();

		for (Prevention prevention : preventions) {
			prevention.setPreventionExtendedProperties();
			//name, code, type, manufacturer, lot#, route, site, dose, date, refused, notes
			JSONObject imm = new JSONObject();
			imm.put("name", emptyIfNull(prevention.getName()));
			imm.put("code", emptyIfNull(prevention.getDIN()));
			imm.put("type", emptyIfNull(prevention.getImmunizationType()));
			imm.put("manufacturer", emptyIfNull(prevention.getManufacture()));
			imm.put("lotNumber", emptyIfNull(prevention.getLotNo()));
			imm.put("route", emptyIfNull(prevention.getRouteForDisplay()));
			imm.put("site", emptyIfNull(prevention.getSite()));
			imm.put("dose", emptyIfNull(prevention.getDose()));
			imm.put("date", emptyIfNull(sdf.format(prevention.getPreventionDate())));
			imm.put("refused", emptyIfNull(prevention.isRefused() ? "Yes" : "No"));
			imm.put("notes", emptyIfNull(prevention.getComment()));

			imms.add(imm);
		}

		root.put("immunizations", imms);
		root.write(response.getWriter());

		return null;
	}

	
	public ActionForward hideDisclaimer(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response)  {
		request.getSession().setAttribute("dhir.disclaimer.hide",true);
		return null;
	}
	
	private Object emptyIfNull(Object o) {
		if (o == null) {
			return "";
		}
		return o;
	}
	
}