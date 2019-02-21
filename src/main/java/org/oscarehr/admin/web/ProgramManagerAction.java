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
package org.oscarehr.admin.web;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;
import org.apache.struts.action.DynaActionForm;
import org.apache.struts.actions.DispatchAction;
import org.apache.struts.validator.DynaValidatorForm;
import org.oscarehr.PMmodule.dao.ProgramDao;
import org.oscarehr.PMmodule.model.Program;
import org.oscarehr.PMmodule.service.AdmissionManager;
import org.oscarehr.PMmodule.service.ProgramManager;
import org.oscarehr.PMmodule.service.ProgramQueueManager;
import org.oscarehr.PMmodule.utility.ProgramAccessCache;
import org.oscarehr.common.dao.FacilityDao;
import org.oscarehr.common.dao.FunctionalCentreDao;
import org.oscarehr.common.model.FunctionalCentre;
import org.oscarehr.util.LoggedInInfo;
import org.oscarehr.util.MiscUtils;
import org.oscarehr.util.SpringUtils;

import oscar.log.LogAction;

public class ProgramManagerAction extends DispatchAction {
	
	ProgramDao programDao = SpringUtils.getBean(ProgramDao.class);
	FacilityDao facilityDao = SpringUtils.getBean(FacilityDao.class);
	FunctionalCentreDao functionalCentreDao = SpringUtils.getBean(FunctionalCentreDao.class);
	AdmissionManager admissionManager = SpringUtils.getBean(AdmissionManager.class);
	ProgramQueueManager programQueueManager = SpringUtils.getBean(ProgramQueueManager.class);
	ProgramManager programManager = SpringUtils.getBean(ProgramManager.class);
	
	@Override
	public ActionForward unspecified(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) {
		return list(mapping, form, request, response);
	}

	public ActionForward list(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) {
		List<Program> programs = new ArrayList<Program>();
		
		String filterType = request.getParameter("filterType");
		if(filterType == null) {
			filterType = "bs";
		}
		
		if(filterType != null) {
			LoggedInInfo loggedInInfo = LoggedInInfo.getLoggedInInfoFromSession(request);
			if(filterType.contains("b")) {
				programs.addAll(programDao.getProgramsByType(loggedInInfo.getCurrentFacility().getId(), "bed", true));
			}
			if(filterType.contains("s")) {
				programs.addAll(programDao.getProgramsByType(loggedInInfo.getCurrentFacility().getId(), "service", true));
			}
			if(filterType.contains("c")) {
				programs.addAll(programDao.getProgramsByType(loggedInInfo.getCurrentFacility().getId(), "community", true));
			}
			if(filterType.isEmpty()) {
				programs.addAll(programDao.getProgramsByType(loggedInInfo.getCurrentFacility().getId(), "bed", true));
				programs.addAll(programDao.getProgramsByType(loggedInInfo.getCurrentFacility().getId(), "service", true));
				programs.addAll(programDao.getProgramsByType(loggedInInfo.getCurrentFacility().getId(), "community", true));
			}
		}
		
		request.setAttribute("filterType", filterType);
		request.setAttribute("programs",programs);
		return mapping.findForward("list");
	}
	
	protected void setEditAttributes(HttpServletRequest request, Integer programId) {
		request.setAttribute("facilities", facilityDao.findAll(true));

		List<FunctionalCentre> functionalCentres = functionalCentreDao.findAll();
		Collections.sort(functionalCentres, FunctionalCentre.ACCOUNT_ID_COMPARATOR);
		request.setAttribute("functionalCentres", functionalCentres);

	}
	
	public ActionForward add(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) {
		
		setEditAttributes(request,null);
		
		Program p = new Program();
		
		DynaValidatorForm f = (DynaValidatorForm)form;
		
		f.set("program", p);
		return mapping.findForward("edit");
	}
	
	public ActionForward delete(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) {
		
		String id = request.getParameter("id");
		
		Program p = programManager.getProgram(Integer.parseInt(id));
		
		if(p != null) {
			p.setProgramStatus("inactive");
			programManager.saveProgram(p);
		}
		
		return list(mapping,form,request,response);
	}
	
	public ActionForward edit(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) {
		String id = request.getParameter("id");
		
		Program program = programDao.getProgram(Integer.parseInt(id));
		
		DynaActionForm programForm = (DynaActionForm) form;
		programForm.set("program", program);
		
		//request.setAttribute("program", program);
		
		setEditAttributes(request,program.getId());
		return mapping.findForward("edit");
	}
	
	public ActionForward save(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) {
		DynaActionForm programForm = (DynaActionForm) form;

		Program program = (Program) programForm.get("program");

		if (this.isCancelled(request)) {
			programForm.set("program", new Program());
			return list(mapping, form, request, response);
		}

		try {
			program.setFacilityId(Integer.parseInt(request.getParameter("program.facilityId")));
		} catch (NumberFormatException e) {
			MiscUtils.getLogger().error("Error", e);
		}

		if (request.getParameter("program.allowBatchAdmission") == null) program.setAllowBatchAdmission(false);
		if (request.getParameter("program.allowBatchDischarge") == null) program.setAllowBatchDischarge(false);
		if (request.getParameter("program.hic") == null) program.setHic(false);
		if (request.getParameter("program.holdingTank") == null) program.setHoldingTank(false);
		if (request.getParameter("program.bedProgramAffiliated") == null) program.setBedProgramAffiliated(false);
		if (request.getParameter("program.bedProgramLinkId") == null) program.setBedProgramLinkId(0);
		if (request.getParameter("program.enableOCAN") == null) program.setEnableOCAN(false);
		if (request.getParameter("program.enableEncounterTime") == null) program.setEnableEncounterTime(false);
		if (request.getParameter("program.enableEncounterTransportationTime") == null) program.setEnableEncounterTransportationTime(false);

	
		// if a program has a client in it, you cannot make it inactive
		if (request.getParameter("program.programStatus").equals("inactive")) {
			if (!("External".equals(request.getParameter("program.type")))) {
				// Admission ad = admissionManager.getAdmission(Long.valueOf(request.getParameter("id")));
				List admissions = admissionManager.getCurrentAdmissionsByProgramId(String.valueOf(program.getId()));
				if (admissions.size() > 0) {
					ActionMessages messages = new ActionMessages();
					messages.add(ActionMessages.GLOBAL_MESSAGE, new ActionMessage("program.client_in_the_program", program.getName()));
					saveMessages(request, messages);
					setEditAttributes(request, program.getId());
					return mapping.findForward("edit");
				}
				int numQueue = programQueueManager.getActiveProgramQueuesByProgramId((long) program.getId()).size();
				if (numQueue > 0) {
					ActionMessages messages = new ActionMessages();
					messages.add(ActionMessages.GLOBAL_MESSAGE, new ActionMessage("program.client_in_the_queue", program.getName(), String.valueOf(numQueue)));
					saveMessages(request, messages);
					setEditAttributes(request, program.getId());
					return mapping.findForward("edit");
				}
			}
		}

		if (!program.getType().equalsIgnoreCase("bed") && program.isHoldingTank()) {
			ActionMessages messages = new ActionMessages();
			messages.add(ActionMessages.GLOBAL_MESSAGE, new ActionMessage("program.invalid_holding_tank"));
			saveMessages(request, messages);
			setEditAttributes(request, program.getId());
			return mapping.findForward("edit");
		}

		programManager.saveProgram(program);


		ActionMessages messages = new ActionMessages();
		messages.add(ActionMessages.GLOBAL_MESSAGE, new ActionMessage("program.saved", program.getName()));
		saveMessages(request, messages);

		ProgramAccessCache.setAccessMap(program.getId());
		
		LogAction.log("write", "edit program", String.valueOf(program.getId()), request);

		programForm.set("program", new Program());
		
		
		return list(mapping,form,request,response);
	}
}
