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

import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.DynaActionForm;
import org.apache.struts.actions.DispatchAction;

import org.oscarehr.common.model.DaySheetConfiguration;
import org.oscarehr.common.dao.DaySheetConfigurationDao;

public class DaySheetConfigAction extends DispatchAction {

    private DaySheetConfigurationDao dsConfigDao;

    @Override
    protected ActionForward unspecified(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
        return view(mapping, form, request, response);
    }

    public ActionForward view(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) {
        List<DaySheetConfiguration> dsConfig = dsConfigDao.getConfigurationList();
        DynaActionForm frm = (DynaActionForm)form;
        frm.set("dsConfig",dsConfig);
        request.setAttribute("dsConfigForm",form);
        return mapping.findForward("success");
    }

    public ActionForward update(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) {
        DynaActionForm frm = (DynaActionForm)form;
        
        //weird hack, but not sure why struts isn't filling in the id.
        //if(request.getParameter("clinic.id") != null && request.getParameter("clinic.id").length()>0 && clinic.getId()==null) {
        	//clinic.setId(Integer.parseInt(request.getParameter("clinic.id")));
        //}

        return mapping.findForward("success");
    }

    public void setDsConfigDao(DaySheetConfigurationDao dsConfigDao) {
        this.dsConfigDao = dsConfigDao;
    }
}
