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

import java.util.*;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionRedirect;
import org.apache.struts.actions.DispatchAction;
import org.jdom.Element;
import org.jdom.output.Format;
import org.jdom.output.XMLOutputter;
import org.oscarehr.common.dao.FlowSheetCustomizationDao;
import org.oscarehr.common.dao.FlowSheetDrugDao;
import org.oscarehr.common.dao.FlowSheetUserCreatedDao;
import org.oscarehr.common.model.FlowSheetCustomization;
import org.oscarehr.common.model.FlowSheetDrug;
import org.oscarehr.common.model.FlowSheetUserCreated;
import org.oscarehr.managers.SecurityInfoManager;
import org.oscarehr.util.LoggedInInfo;
import org.oscarehr.util.MiscUtils;
import org.oscarehr.util.SpringUtils;

import oscar.oscarEncounter.oscarMeasurements.FlowSheetItem;
import oscar.oscarEncounter.oscarMeasurements.MeasurementFlowSheet;
import oscar.oscarEncounter.oscarMeasurements.MeasurementTemplateFlowSheetConfig;
import oscar.oscarEncounter.oscarMeasurements.util.Recommendation;
import oscar.oscarEncounter.oscarMeasurements.util.RecommendationCondition;
import oscar.oscarEncounter.oscarMeasurements.util.TargetColour;
import oscar.oscarEncounter.oscarMeasurements.util.TargetCondition;
import oscar.oscarRx.data.RxDrugData;

public class FlowSheetCustomAction extends DispatchAction {
    private static final Logger logger = MiscUtils.getLogger();

    private FlowSheetCustomizationDao flowSheetCustomizationDao =  (FlowSheetCustomizationDao) SpringUtils.getBean("flowSheetCustomizationDao");
    private FlowSheetUserCreatedDao flowSheetUserCreatedDao = (FlowSheetUserCreatedDao) SpringUtils.getBean("flowSheetUserCreatedDao");
    private SecurityInfoManager securityInfoManager = SpringUtils.getBean(SecurityInfoManager.class);
    private FlowSheetDrugDao flowSheetDrugDao = SpringUtils.getBean(FlowSheetDrugDao.class);
    
    public void setFlowSheetCustomizationDao(FlowSheetCustomizationDao flowSheetCustomizationDao) {
        this.flowSheetCustomizationDao = flowSheetCustomizationDao;
    }

    @Override
    protected ActionForward unspecified(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
       return null;
    }

    public ActionForward save(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
        String flowsheet = request.getParameter("flowsheet");
        String demographicNo = "0";
        if (request.getParameter("demographic")!=null){
        	demographicNo = request.getParameter("demographic");
        }

        if (StringUtils.isEmpty(request.getParameter("display_name"))) {
            return mapping.findForward("failure");
        }

        if(!securityInfoManager.hasPrivilege(LoggedInInfo.getLoggedInInfoFromSession(request), "_demographic", "w", demographicNo)) {
        	throw new SecurityException("missing required security object (_demographic)");
        }
        
        MeasurementTemplateFlowSheetConfig templateConfig = MeasurementTemplateFlowSheetConfig.getInstance();
        MeasurementFlowSheet mFlowsheet = templateConfig.getFlowSheet(flowsheet);

        if (request.getParameter("measurement") != null) {

            Hashtable<String,String> h = new Hashtable<String,String>();

            h.put("measurement_type", request.getParameter("measurement"));
            h.put("display_name", request.getParameter("display_name"));
            h.put("guideline", request.getParameter("guideline"));
            h.put("graphable", request.getParameter("graphable"));
            h.put("value_name", request.getParameter("value_name"));
            String prevItem = null;
            if (request.getParameter("count") != null) {
                int cou = Integer.parseInt(request.getParameter("count"));
                if (cou != 0) {
                    prevItem = mFlowsheet.getMeasurementList().get(cou);
                }
            }

            @SuppressWarnings("unchecked")
            Enumeration<String> en = request.getParameterNames();
                        
            List<Recommendation> ds = new ArrayList<Recommendation>();
            while (en.hasMoreElements()) {
                String s = en.nextElement();
                if (s.startsWith("monthrange")) {
                    String extrachar = s.replaceAll("monthrange", "").trim();
                    logger.debug("EXTRA CAH " + extrachar);
                    
                    if(request.getParameter("monthrange" + extrachar) != null){
                    String mRange = request.getParameter("monthrange" + extrachar);
                    String strn = request.getParameter("strength" + extrachar);
                    String dsText = request.getParameter("text" + extrachar);
                                        
                    if (!mRange.trim().equals("")){
                       ds.add(new Recommendation("" + h.get("measurement_type"), mRange, strn, dsText));
                    }
                    }
                }
            }

            if (h.get("measurement_type") != null) {
                FlowSheetItem item = new FlowSheetItem(h);
                item.setRecommendations(ds);
                Element va = templateConfig.getItemFromObject(item);

                XMLOutputter outp = new XMLOutputter();
                outp.setFormat(Format.getPrettyFormat());

                FlowSheetCustomization cust = new FlowSheetCustomization();
                cust.setAction(FlowSheetCustomization.ADD);
                cust.setPayload(outp.outputString(va));
                cust.setFlowsheet(flowsheet);
                cust.setMeasurement(prevItem);//THIS THE MEASUREMENT TO SET THIS AFTER!
                cust.setProviderNo((String) request.getSession().getAttribute("user"));
                cust.setDemographicNo(demographicNo);
                cust.setCreateDate(new Date());

                logger.debug("SAVE "+cust);

                flowSheetCustomizationDao.persist(cust);

            }
        }
        
        if(request.getParameter("drugId") != null) {
            String drugId = request.getParameter("drugId");
            String scope = request.getParameter("scope");
            LoggedInInfo loggedInInfo = LoggedInInfo.getLoggedInInfoFromSession(request);
            
            RxDrugData drugData = new RxDrugData();
            RxDrugData.DrugMonograph monograph = drugData.getDrug2(drugId);
            FlowSheetDrug drug = new FlowSheetDrug();
            
            String providerNo = "clinic".equals(scope) ? "0" : loggedInInfo.getLoggedInProviderNo();
            
            drug.setFlowsheet(flowsheet);
            drug.setAtcCode(monograph.getAtc());
            drug.setName(monograph.getName());
            drug.setProviderNo(providerNo);
            drug.setDemographicNo(Integer.valueOf(demographicNo));
            drug.setCreateDate(Calendar.getInstance().getTime());
            drug.setArchived(false);
            drug.setLastUpdateUser(loggedInInfo.getLoggedInProviderNo());
            drug.setLastUpdateDate(Calendar.getInstance().getTime());

            flowSheetDrugDao.persist(drug);
        }
        
        request.setAttribute("demographic",demographicNo);
        request.setAttribute("flowsheet", flowsheet);
        return mapping.findForward("success");
    }

    public ActionForward update(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response)  {
        MeasurementTemplateFlowSheetConfig templateConfig = MeasurementTemplateFlowSheetConfig.getInstance();
        
        if (StringUtils.isEmpty(request.getParameter("display_name"))) {
            return mapping.findForward("failure");
        }
        
        String flowsheet = request.getParameter("flowsheet");
        String demographicNo = "0";
        if (request.getParameter("demographic")!=null){
        	demographicNo = request.getParameter("demographic");
        }
        
        if(!securityInfoManager.hasPrivilege(LoggedInInfo.getLoggedInInfoFromSession(request), "_demographic", "w", demographicNo)) {
        	throw new SecurityException("missing required security object (_demographic)");
        }
        Boolean universal = Boolean.valueOf(request.getParameter("scope"));
        logger.debug("UPDATING FOR demographic "+demographicNo);

        if (request.getParameter("updater") != null) {
            Hashtable<String,String> h = new Hashtable<String,String>();
            h.put("measurement_type", request.getParameter("measurement_type"));
            h.put("display_name", request.getParameter("display_name"));
            h.put("guideline", request.getParameter("guideline"));
            h.put("graphable", request.getParameter("graphable"));
            h.put("value_name", request.getParameter("value_name"));

            FlowSheetItem item = new FlowSheetItem(h);


            @SuppressWarnings("unchecked")
            Enumeration<String> en = request.getParameterNames();

            List<TargetColour> targets = new ArrayList<TargetColour>();
            List<Recommendation> recommendations = new ArrayList<Recommendation>();
            while (en.hasMoreElements()) {
                String s = en.nextElement();
                if (s.startsWith("strength")) {
                    String extrachar = s.replaceAll("strength", "").trim();
                    logger.debug("EXTRA CAH " + extrachar);
                    boolean go = true;
                    Recommendation rec = new Recommendation();
                    rec.setStrength(request.getParameter(s));
                    int targetCount = 1;
                    rec.setText(request.getParameter("text"+extrachar));
                    List<RecommendationCondition> conds = new ArrayList<RecommendationCondition>();
                    while(go){
                        String type = request.getParameter("type"+extrachar+"c"+targetCount);
                        if (type != null){
                            if (!type.equals("-1")){
                                String param = request.getParameter("param"+extrachar+"c"+targetCount);
                                String value = request.getParameter("value"+extrachar+"c"+targetCount);
                                RecommendationCondition cond = new RecommendationCondition();
                                cond.setType(type);
                                cond.setParam(param);
                                cond.setValue(value);
                                if (value != null && !value.trim().equals("")){
                                   conds.add(cond);
                                }
                            }
                        }else{
                            go = false;
                        }
                        targetCount++;
                    }
                    if (conds.size() > 0){
                        rec.setRecommendationCondition(conds);
                        recommendations.add(rec);
                    }
                    //////
                    /*  Strength:   <select name="strength<%=count%>">
                        Text: <input type="text" name="text<%=count%>" length="100"  value="<%=e.getText()%>" />
                        <select name="type<%=count%>c<%=condCount%>" >
                        Param: <input type="text" name="param<%=count%>c<%=condCount%>" value="<%=s(cond.getParam())%>" />
                        Value: <input type="text" name="value<%=count%>c<%=condCount%>" value="<%=cond.getValue()%>" />
                    */
                    //////

                    
                    
                    
//                    String mRange = request.getParameter("monthrange" + extrachar);
//                    String strn = request.getParameter("strength" + extrachar);
//                    String dsText = request.getParameter("text" + extrachar);
//                    if (!mRange.trim().equals("")){
//                       ds.add(new Recommendation("" + h.get("measurement_type"), mRange, strn, dsText));
//                    }
                }else if(s.startsWith("col")){
                    String extrachar = s.replaceAll("col", "").trim();
                    logger.debug("EXTRA CHA "+extrachar);
                    boolean go = true;
                    int targetCount = 1;
                    TargetColour tcolour = new TargetColour();
                    tcolour.setIndicationColor(request.getParameter(s));
                    List<TargetCondition> conds = new ArrayList<TargetCondition>();
                    while(go){
                        String type = request.getParameter("targettype"+extrachar+"c"+targetCount);
                        if (type != null){
                            if (!type.equals("-1")){
                                String param = request.getParameter("targetparam"+extrachar+"c"+targetCount);
                                String value = request.getParameter("targetvalue"+extrachar+"c"+targetCount);
                                TargetCondition cond = new TargetCondition();
                                cond.setType(type);
                                cond.setParam(param);
                                cond.setValue(value);
                                if(value !=null && !value.trim().equals("")){
                                   conds.add(cond);
                                }
                            }
                        }else{
                            go = false;
                        }
                        targetCount++;
                    }
                    if (conds.size() > 0){
                        tcolour.setTargetConditions(conds);
                        targets.add(tcolour);
                    }
                }
            }
            item.setTargetColour(targets);
            item.setRecommendations(recommendations);




            //DEALING WITH TARGET DATA//////////

          /*
            <select name="type<%=targetCount%>c1">
               <option value="-1">Not Set</option>
                <option value="getDataAsDouble"       >Number Value</option>
                <option value="isMale"              > Is Male </option>
                <option value="isFemale"            > Is Female </option>
                <option value="getNumberFromSplit"  > Number Split </option>
                <option value="isDataEqualTo"       >  String </option>
           </select>

           Param: <input type="text" name="param<%=targetCount%>c1" value="" />
           Value: <input type="text" name="value<%=targetCount%>c1" value="" />

             */


            ////////////



            Element va = templateConfig.getItemFromObject(item);

            XMLOutputter outp = new XMLOutputter();
            outp.setFormat(Format.getPrettyFormat());

            FlowSheetCustomization cust = new FlowSheetCustomization();
            cust.setAction(FlowSheetCustomization.UPDATE);
            cust.setPayload(outp.outputString(va));
            cust.setFlowsheet(flowsheet);
            cust.setUniversal(universal);
            if(demographicNo != null ){
               cust.setDemographicNo(demographicNo);
            }
            cust.setMeasurement(item.getItemName());//THIS THE MEASUREMENT TO SET THIS AFTER!
            cust.setProviderNo((String) request.getSession().getAttribute("user"));
            logger.debug("UPDATE "+cust);

            flowSheetCustomizationDao.persist(cust);

        }
        request.setAttribute("demographic",demographicNo);
        request.setAttribute("flowsheet", flowsheet);
        return mapping.findForward("success");
    }

    public ActionForward delete(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) {
        logger.debug("IN DELETE");
        String flowsheet = request.getParameter("flowsheet");
        String measurement = request.getParameter("measurement");
        String demographicNo = "0";
        if (request.getParameter("demographic")!=null){
        	demographicNo = request.getParameter("demographic");
        }
        
        if(!securityInfoManager.hasPrivilege(LoggedInInfo.getLoggedInInfoFromSession(request), "_demographic", "w", demographicNo)) {
        	throw new SecurityException("missing required security object (_demographic)");
        }

        FlowSheetCustomization cust = new FlowSheetCustomization();
        cust.setAction(FlowSheetCustomization.DELETE);
        cust.setFlowsheet(flowsheet);
        cust.setMeasurement(measurement);
        cust.setProviderNo((String) request.getSession().getAttribute("user"));
        cust.setDemographicNo(demographicNo);

        flowSheetCustomizationDao.persist(cust);
        logger.debug("DELETE "+cust);

        request.setAttribute("demographic",demographicNo);
        request.setAttribute("flowsheet", flowsheet);
        return mapping.findForward("success");
    }

    public ActionForward deleteDrug(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) {
        logger.debug("IN DELETE");
        LoggedInInfo loggedInInfo = LoggedInInfo.getLoggedInInfoFromSession(request);
        String flowsheet = request.getParameter("flowsheet");
        String drugId = request.getParameter("drugId");
        String demographicNo = "0";
        if (request.getParameter("demographicNo")!=null){
            demographicNo = request.getParameter("demographicNo");
        }

        if(!securityInfoManager.hasPrivilege(LoggedInInfo.getLoggedInInfoFromSession(request), "_demographic", "w", demographicNo)) {
            throw new SecurityException("missing required security object (_demographic)");
        }
        
        FlowSheetDrug flowSheetDrug = flowSheetDrugDao.getFlowSheetDrug(Integer.valueOf(drugId));
        flowSheetDrug.setArchived(true);
        flowSheetDrug.setArchivedDate(Calendar.getInstance().getTime());
        flowSheetDrug.setLastUpdateUser(loggedInInfo.getLoggedInProviderNo());
        flowSheetDrug.setLastUpdateDate(Calendar.getInstance().getTime());
        flowSheetDrugDao.merge(flowSheetDrug);
        
        logger.debug("DELETE " + flowSheetDrug);

        request.setAttribute("demographic",demographicNo);
        request.setAttribute("flowsheet", flowsheet);
        return mapping.findForward("success");
    }

    public ActionForward archiveMod(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) {
        logger.debug("IN MOD");
        String id = request.getParameter("id");

        String flowsheet = request.getParameter("flowsheet");
        String demographicNo = request.getParameter("demographic");
        
        if(!securityInfoManager.hasPrivilege(LoggedInInfo.getLoggedInInfoFromSession(request), "_demographic", "w", demographicNo)) {
        	throw new SecurityException("missing required security object (_demographic)");
        }

        FlowSheetCustomization cust = flowSheetCustomizationDao.getFlowSheetCustomization(Integer.parseInt(id));
        if(cust != null) {
        	cust.setArchived(true);
        	cust.setArchivedDate(new Date());
        	flowSheetCustomizationDao.merge(cust);
        }
        logger.debug("archiveMod "+cust);

        request.setAttribute("demographic",demographicNo);
        request.setAttribute("flowsheet", flowsheet);
        return mapping.findForward("success");
    }

    public ActionForward addForceShowToDemographic(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) {
        String measurementCode = request.getParameter("measurementCode");
        String flowSheet = request.getParameter("flowSheet");
        String demographicNo = request.getParameter("demographic");
        
        if(!securityInfoManager.hasPrivilege(LoggedInInfo.getLoggedInInfoFromSession(request), "_demographic", "w", demographicNo)) {
            throw new SecurityException("missing required security object (_demographic)");
        }

        FlowSheetCustomization customization = new FlowSheetCustomization();
        customization.setAction(FlowSheetCustomization.FORCE_SHOW);
        customization.setFlowsheet(flowSheet);
        customization.setMeasurement(measurementCode);
        customization.setProviderNo((String) request.getSession().getAttribute("user"));
        customization.setDemographicNo(demographicNo);
        customization.setCreateDate(new Date());
        flowSheetCustomizationDao.saveEntity(customization);
        

        request.setAttribute("demographic",demographicNo);
        request.setAttribute("flowsheet", flowSheet);
        ActionRedirect redirect = new ActionRedirect(mapping.findForward("successAndRedirect"));
        redirect.addParameter("flowsheet", flowSheet);
        redirect.addParameter("demographic", demographicNo);
        return redirect;
    }


    /*first add it as a flowsheet into the current system.  The save it to the database so that it will be there on reboot */
    public ActionForward createNewFlowSheet(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response)  {
        logger.debug("IN create new flowsheet");
        //String name let oscar create the name
    	String dxcodeTriggers 		= request.getParameter("dxcodeTriggers");
    	String displayName 			= request.getParameter("displayName");
    	String warningColour 		= request.getParameter("warningColour");
    	String recommendationColour = request.getParameter("recommendationColour");
    	//String topHTML 				= request.getParameter("topHTML");  // Not supported yet

        if (StringUtils.isEmpty(displayName) || displayName.length() > 255 ||
                StringUtils.isEmpty(dxcodeTriggers) || dxcodeTriggers.length() > 255 ||
                StringUtils.isEmpty(warningColour) || warningColour.length() > 20 ||
                StringUtils.isEmpty(recommendationColour) || recommendationColour.length() > 20) {
            return mapping.findForward("newflowsheet");
        }

    	/// NEW FLOWSHEET CODE
    	MeasurementFlowSheet m = new MeasurementFlowSheet();
        m.parseDxTriggers(dxcodeTriggers);
        m.setDisplayName(displayName);
        m.setWarningColour(warningColour);
        m.setRecommendationColour(recommendationColour);

        //Im not sure if adding an initializing measurement is required yet
        /*
        Map<String,String> h = new HashMap<String,String>();
        h.put("measurement_type","WT");
        h.put("display_name","WT");
        h.put("value_name","WT");

        FlowSheetItem fsi = new FlowSheetItem( h);
        m.addListItem(fsi);
*/
        MeasurementTemplateFlowSheetConfig templateConfig = MeasurementTemplateFlowSheetConfig.getInstance();
        String name =  templateConfig.addFlowsheet( m );
        m.loadRuleBase();
    	/// END FLOWSHEET CODE

        FlowSheetUserCreated fsuc = new FlowSheetUserCreated();
        fsuc.setName(name);
        fsuc.setDisplayName(displayName);
        fsuc.setDxcodeTriggers(dxcodeTriggers);
        fsuc.setWarningColour(warningColour);
        fsuc.setRecommendationColour(recommendationColour);
        fsuc.setArchived(false);
        fsuc.setCreatedDate(new Date());
        flowSheetUserCreatedDao.persist(fsuc);

        return mapping.findForward("newflowsheet");
    }





}
