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
import java.util.ArrayList;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.lang.StringUtils;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionRedirect;
import org.apache.struts.actions.DispatchAction;
import org.oscarehr.managers.SecurityInfoManager;
import org.oscarehr.util.LoggedInInfo;
import org.oscarehr.util.MiscUtils;
import org.oscarehr.util.SpringUtils;

import oscar.oscarRx.data.RxPatientData;
import oscar.oscarRx.data.RxPrescriptionData;
import oscar.oscarRx.util.DrugRefCategories;
import oscar.oscarRx.util.RxUtil;


public final class RxUseFavoriteAction extends DispatchAction {
	private SecurityInfoManager securityInfoManager = SpringUtils.getBean(SecurityInfoManager.class);

    public ActionForward unspecified(ActionMapping mapping,
    ActionForm form,
    HttpServletRequest request,
    HttpServletResponse response)
    throws IOException, ServletException {


    	LoggedInInfo loggedInInfo = LoggedInInfo.getLoggedInInfoFromSession(request);
		if (!securityInfoManager.hasPrivilege(loggedInInfo, "_rx", "r", null)) {
			throw new RuntimeException("missing required security object (_rx)");
		}
    	
    	
        // Setup variables
        oscar.oscarRx.pageUtil.RxSessionBean bean =
        (oscar.oscarRx.pageUtil.RxSessionBean)request.getSession().getAttribute("RxSessionBean");
        if(bean==null){
            response.sendRedirect("error.html");
            return null;
        }

        try {
            int favoriteId = Integer.parseInt(((RxUseFavoriteForm)form).getFavoriteId());
            RxPrescriptionData rxData =
            new RxPrescriptionData();

            // get favorite
            RxPrescriptionData.Favorite fav =
            rxData.getFavorite(favoriteId);

            // create Prescription
            RxPrescriptionData.Prescription rx =
            rxData.newPrescription(bean.getProviderNo(), bean.getDemographicNo(), fav);

            bean.addAttributeName(rx.getAtcCode() + "-" + String.valueOf(bean.getStashIndex()));

            bean.setStashIndex(bean.addStashItem(loggedInInfo, rx));
            request.setAttribute("BoxNoFillFirstLoad", "true");
        }
        catch (Exception e) {
           MiscUtils.getLogger().error("Error", e);
        }

        return (mapping.findForward("success"));
    }

    public ActionForward useFav2(ActionMapping mapping,
    ActionForm form,
    HttpServletRequest request,
    HttpServletResponse response)
    throws IOException {

    	LoggedInInfo loggedInInfo = LoggedInInfo.getLoggedInInfoFromSession(request);
		if (!securityInfoManager.hasPrivilege(loggedInInfo, "_rx", "r", null)) {
			throw new RuntimeException("missing required security object (_rx)");
		}
    	
        // Setup variables
        oscar.oscarRx.pageUtil.RxSessionBean bean =
        (oscar.oscarRx.pageUtil.RxSessionBean)request.getSession().getAttribute("RxSessionBean");
        if(bean==null){
            response.sendRedirect("error.html");
            return null;
        }

        try {
            int favoriteId = Integer.parseInt(request.getParameter("favoriteId"));
            String randomId=request.getParameter("randomId");


            RxPrescriptionData rxData =
            new RxPrescriptionData();

            // get favorite
            RxPrescriptionData.Favorite fav =
            rxData.getFavorite(favoriteId);

            // create Prescription
            RxPrescriptionData.Prescription rx =
            rxData.newPrescription(bean.getProviderNo(), bean.getDemographicNo(), fav);
            rx.setRandomId(Long.parseLong(randomId));

                String spec=RxUtil.trimSpecial(rx);
                rx.setSpecial(spec);

            bean.addAttributeName(rx.getAtcCode() + "-" + String.valueOf(bean.getStashIndex()));

            List<RxPrescriptionData.Prescription> listRxDrugs=new ArrayList();
            if(RxUtil.isRxUniqueInStash(bean, rx)){
                listRxDrugs.add(rx);
            }
            int rxStashIndex=bean.addStashItem(loggedInInfo, rx);
            bean.setStashIndex(rxStashIndex);
            bean.addNewRandomIdToMap(Integer.valueOf(favoriteId), Long.parseLong(randomId));
            

            request.setAttribute("listRxDrugs",listRxDrugs);
            request.setAttribute("BoxNoFillFirstLoad", "true");
        }
        catch (Exception e) {
           MiscUtils.getLogger().error("Error", e);
        }

        RxUtil.printStashContent(bean);

        return (mapping.findForward("useFav2"));
    }
    
    public ActionForward useFavAsAllergy(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) {
        LoggedInInfo loggedInInfo = LoggedInInfo.getLoggedInInfoFromSession(request);
        if (!securityInfoManager.hasPrivilege(loggedInInfo, "_rx", "r", null)) {
            throw new RuntimeException("missing required security object (_rx)");
        }
        String favouriteIdString = request.getParameter("favouriteId");
        
        try {
            int favouriteId = Integer.parseInt(favouriteIdString);
            RxPrescriptionData rxData = new RxPrescriptionData();
            RxPrescriptionData.Favorite fav = rxData.getFavorite(favouriteId);
            Integer drugId = 0;
            Integer categoryId = 0;
            String drugName = "";
            
            // Checks if the drug has a brand name, if it doesn't then it is a custom drug and the drug and category ids remain 0 
            if (fav.getBN() != null) {
                // Sets the Ids and drug name for a brand name drug 
                categoryId = DrugRefCategories.BRANDED_PRODUCT;
                drugId = fav.getGCN_SEQNO();
                drugName = fav.getBN();
            } else if (!StringUtils.isEmpty(fav.getCustomName())) {
                // Sets the custom name for the drug name since it is a custom drug
                drugName = fav.getCustomName();
            } else {
                drugName = fav.getFavoriteName();
            }
            
            ActionRedirect redirect = new ActionRedirect(mapping.findForward("addAllergy"));
            redirect.addParameter("ID", drugId);
            redirect.addParameter("name", drugName);
            redirect.addParameter("type", categoryId);
            redirect.addParameter("atc", fav.getAtcCode());
            redirect.addParameter("regionalIdentifier", fav.getRegionalIdentifier());
            
            return redirect;
        } catch (NumberFormatException e) {
            MiscUtils.getLogger().error("Error parsing the Favourite Id: " + favouriteIdString + " to use as an allergy", e);
        }

        ActionRedirect redirect = new ActionRedirect(mapping.findForward("allergyError"));
        RxPatientData.Patient patient = (RxPatientData.Patient)request.getSession().getAttribute("Patient");
        redirect.addParameter("demographicNo", patient.getDemographicNo());
        redirect.addParameter("allergyError", true);
        
        return redirect;
    }
}
