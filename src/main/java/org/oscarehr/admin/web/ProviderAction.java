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

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.lang3.StringUtils;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.actions.DispatchAction;
import org.oscarehr.PMmodule.dao.ProgramProviderDAO;
import org.oscarehr.PMmodule.model.ProgramProvider;
import org.oscarehr.caisi_integrator.util.MiscUtils;
import org.oscarehr.common.dao.ProviderFacilityDao;
import org.oscarehr.common.model.ProviderFacility;
import org.oscarehr.managers.SecurityInfoManager;
import org.oscarehr.util.LoggedInInfo;
import org.oscarehr.util.SpringUtils;

public class ProviderAction extends DispatchAction {

	private SecurityInfoManager securityInfoManager = SpringUtils.getBean(SecurityInfoManager.class);
	
	
	public ActionForward unspecified(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
		return mapping.findForward("program");
	}
	
	public ActionForward saveFacilities(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response)  {
		if(!securityInfoManager.hasPrivilege(LoggedInInfo.getLoggedInInfoFromSession(request), "_admin", "w", null)) {
        	throw new SecurityException("missing required security object (_admin)");
        }
		
		MiscUtils.getLogger().info("Saving provider facilities");
		
		String providerNo = request.getParameter("providerNo");
		
		ProviderFacilityDao providerFacilityDao = SpringUtils.getBean(ProviderFacilityDao.class);
		for(ProviderFacility pf : providerFacilityDao.findByProviderNo(providerNo)) {
			providerFacilityDao.remove(pf.getId());
		}
		
		String[] facilities = request.getParameterValues("facility");
		
		for(String facility : facilities) {
			providerFacilityDao.saveEntity(new ProviderFacility(providerNo,Integer.parseInt(facility)));
		}
		
		
		return mapping.findForward("program");
	}
	
	public ActionForward savePrograms(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response)  {
		if(!securityInfoManager.hasPrivilege(LoggedInInfo.getLoggedInInfoFromSession(request), "_admin", "w", null)) {
        	throw new SecurityException("missing required security object (_admin)");
        }
		
		MiscUtils.getLogger().info("Saving provider programs");
		
		String providerNo = request.getParameter("providerNo");
		
		ProgramProviderDAO programProviderDao = SpringUtils.getBean(ProgramProviderDAO.class);
		for(ProgramProvider pp : programProviderDao.getProgramProviderByProviderNo(providerNo)) {
			programProviderDao.deleteProgramProvider(pp.getId());
		}
		
		String[] programs = request.getParameterValues("program");
		
		
		for(String program : programs) {
			String role = request.getParameter("role_" + program);
			if(role != null && !StringUtils.isEmpty(role)) {
				programProviderDao.saveProgramProvider(new ProgramProvider(Long.valueOf(program),providerNo,Long.valueOf(role)));
			}
		}
		
		
		return mapping.findForward("program");
	}
}
