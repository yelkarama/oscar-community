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


package org.oscarehr.common.web;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.lang.StringUtils;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.DynaActionForm;
import org.apache.struts.actions.DispatchAction;
import org.oscarehr.common.dao.ClinicDAO;
import org.oscarehr.common.model.Clinic;

public class ClinicManageAction extends DispatchAction {

    private ClinicDAO clinicDAO;

    @Override
    protected ActionForward unspecified(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
        return view(mapping, form, request, response);
    }

    public ActionForward view(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) {
        Clinic clinic = clinicDAO.getClinic();
        DynaActionForm frm = (DynaActionForm)form;
        frm.set("clinic",clinic);
        request.setAttribute("clinicForm",form);
        return mapping.findForward("success");
    }

    public ActionForward update(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) {
        DynaActionForm frm = (DynaActionForm)form;
        Clinic clinic = (Clinic) frm.get("clinic");
        //weird hack, but not sure why struts isn't filling in the id.
        if(request.getParameter("clinic.id") != null && request.getParameter("clinic.id").length()>0 && StringUtils.isNumeric(request.getParameter("clinic.id")) &&clinic.getId()==null) {
        	clinic.setId(Integer.parseInt(request.getParameter("clinic.id")));
        }
        if (clinic != null &&
                (StringUtils.isEmpty(clinic.getClinicName()) || clinic.getClinicName().length() <= 100) &&
                (StringUtils.isEmpty(clinic.getClinicAddress()) || clinic.getClinicAddress().length() <= 60) &&
                (StringUtils.isEmpty(clinic.getClinicCity()) || clinic.getClinicCity().length() <= 40) &&
                (StringUtils.isEmpty(clinic.getClinicPostal()) || clinic.getClinicPostal().length() <= 15) &&
                (StringUtils.isEmpty(clinic.getClinicPhone()) || clinic.getClinicPhone().length() <= 50) &&
                (StringUtils.isEmpty(clinic.getClinicFax()) || clinic.getClinicFax().length() <= 20) &&
                (StringUtils.isEmpty(clinic.getClinicLocationCode()) || clinic.getClinicLocationCode().length() <= 10) &&
                (StringUtils.isEmpty(clinic.getClinicProvince()) || clinic.getClinicProvince().length() <= 40) &&
                (StringUtils.isEmpty(clinic.getClinicEmail()) || clinic.getClinicEmail().length() <= 255) &&
                (StringUtils.isEmpty(clinic.getClinicWebsite()) || clinic.getClinicWebsite().length() <= 255)) {
            clinicDAO.save(clinic);

            return mapping.findForward("success");
        }
        return mapping.findForward("failure");
    }

    public void setClinicDAO(ClinicDAO clinicDAO) {
        this.clinicDAO = clinicDAO;
    }
}
