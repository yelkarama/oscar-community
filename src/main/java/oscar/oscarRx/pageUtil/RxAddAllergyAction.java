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


package oscar.oscarRx.pageUtil;

import java.io.IOException;
import java.util.GregorianCalendar;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.struts.action.Action;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.oscarehr.common.model.Allergy;
import org.oscarehr.common.model.PartialDate;
import org.oscarehr.managers.SecurityInfoManager;
import org.oscarehr.util.LoggedInInfo;
import org.oscarehr.util.MiscUtils;
import org.oscarehr.util.SpringUtils;

import oscar.log.LogAction;
import oscar.log.LogConst;
import oscar.oscarRx.data.RxDrugData;
import oscar.oscarRx.data.RxPatientData;

import static oscar.oscarRx.util.RxUtil.StringToDate;


public final class RxAddAllergyAction extends Action {
	private SecurityInfoManager securityInfoManager = SpringUtils.getBean(SecurityInfoManager.class);

    public ActionForward execute(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
		if (!securityInfoManager.hasPrivilege(LoggedInInfo.getLoggedInInfoFromSession(request), "_allergy", "w", null)) {
			throw new RuntimeException("missing required security object (_allergy)");
		}
    	
            String drugId = request.getParameter("ID");
            if (drugId.contains(" ")) {
                drugId = drugId.substring(drugId.indexOf(" ") + 1);
            }

		    String reactionType = request.getParameter("reactionType");
            String name = request.getParameter("name");
            String type = request.getParameter("type");
            String atc = request.getParameter("atc");
            String description = request.getParameter("reactionDescription");

            String entryDate = request.getParameter("entryDate");
            String startDate = request.getParameter("startDate");
            String ageOfOnset = request.getParameter("ageOfOnset");
            String severityOfReaction = request.getParameter("severityOfReaction");
            String onSetOfReaction = request.getParameter("onSetOfReaction");
            String lifeStage = request.getParameter("lifeStage");

            RxPatientData.Patient patient = (RxPatientData.Patient)request.getSession().getAttribute("Patient");
            
            Allergy allergy = new Allergy();
            allergy.setDrugrefId(drugId);
            if (name != null && name.length() > 50) {
                name = name.substring(0, 50);
            }
            allergy.setDescription(name);
            allergy.setTypeCode(Integer.parseInt(type));
            if (!"null".equals(atc) && !"".equals(atc)) {
                allergy.setAtc(atc);
            }
            allergy.setReaction(description);
            
            if(!entryDate.trim().equals("")){
                String pattern = allergy.getDatePattern(entryDate);
                allergy.setEntryDate(StringToDate(entryDate, pattern));
            } else {
                allergy.setEntryDate(GregorianCalendar.getInstance().getTime());
            }
                
            if(!startDate.trim().equals("")){
                String pattern = allergy.getDatePattern(startDate);
                allergy.setStartDate(StringToDate(startDate, pattern));
                if (pattern.toUpperCase().equals(PartialDate.YEARMONTH)) {
                    allergy.setStartDateFormat(PartialDate.YEARMONTH);
                } else if (pattern.toUpperCase().equals(PartialDate.YEARONLY)) {
                    allergy.setStartDateFormat(PartialDate.YEARONLY);
                }
            }

            allergy.setAgeOfOnset(ageOfOnset);
            allergy.setSeverityOfReaction(severityOfReaction);
            allergy.setOnsetOfReaction(onSetOfReaction);
            allergy.setLifeStage(lifeStage);
            allergy.setReactionType(reactionType);

            if (allergy.getTypeCode() != 8) {
                RxDrugData.DrugMonograph drugMonograph = allergy.isDrug(Integer.parseInt(type));
                if (drugMonograph != null) {
                    allergy.setRegionalIdentifier(drugMonograph.regionalIdentifier);
                }
            }

            allergy.setDemographicNo(patient.getDemographicNo());
            allergy.setArchived(false);

            Allergy allerg = patient.addAllergy(allergy);

            String ip = request.getRemoteAddr();
            LogAction.addLog((String) request.getSession().getAttribute("user"), LogConst.ADD, LogConst.CON_ALLERGY, ""+allerg.getAllergyId() , ip,""+patient.getDemographicNo(), allergy.getAuditString());

            return (mapping.findForward("success"));
    }

    private int getCharOccur(String str, char ch) {
	int occurence=0, from=0;
	while (str.indexOf(ch,from)>=0) {
	    occurence++;
	    from = str.indexOf(ch,from)+1;
	}
	return occurence;
    }
}
