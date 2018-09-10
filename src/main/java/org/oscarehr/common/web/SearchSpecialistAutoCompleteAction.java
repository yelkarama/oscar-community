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

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.actions.DispatchAction;
import org.oscarehr.common.dao.ProfessionalSpecialistDao;
import org.oscarehr.common.model.ProfessionalSpecialist;
import org.oscarehr.util.MiscUtils;
import org.oscarehr.util.SpringUtils;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.util.List;

public class SearchSpecialistAutoCompleteAction extends DispatchAction{
    public ActionForward unspecified(ActionMapping mapping, ActionForm form,HttpServletRequest request,HttpServletResponse response) throws Exception {

        String searchStr = request.getParameter("term");
        String firstName, lastName;

        if (searchStr.contains(",")) {
            String[] searchParams = searchStr.split(",");
            lastName = searchParams[0].trim();
            firstName = searchParams[1].trim();
        } else {
            lastName = searchStr;
            firstName = "";
        }

        ProfessionalSpecialistDao professionalSpecialistDao = SpringUtils.getBean(ProfessionalSpecialistDao.class);
        List<ProfessionalSpecialist> specialists = professionalSpecialistDao.findByFullName(lastName, firstName);
        
        StringBuilder searchResults = new StringBuilder("[");
        
        if (specialists != null) {
            for (int i = 0; i < specialists.size(); i++) {
                ProfessionalSpecialist specialist = specialists.get(i);
                String specialistInfo = String.format("{\"label\":\"%s, %s\",\"value\":\"%s\"}", specialist.getLastName(), specialist.getFirstName(), specialist.getFaxNumber());
                searchResults.append(specialistInfo);
                if (i < specialists.size() - 1) {
                    searchResults.append(", ");
                }
            }
        }

        searchResults.append("]");

        response.setContentType("text/x-json");
        response.getWriter().write(searchResults.toString());
        
        return null;
    }
}
