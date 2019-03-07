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


package org.oscarehr.common.dao;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;

import javax.persistence.Query;

import org.oscarehr.common.model.FlowSheetCustomization;
import org.springframework.stereotype.Repository;

@Repository
public class FlowSheetCustomizationDao extends AbstractDao<FlowSheetCustomization>{

	public FlowSheetCustomizationDao() {
		super(FlowSheetCustomization.class);
	}

    public FlowSheetCustomization getFlowSheetCustomization(Integer id){
    	return this.find(id);
    }

    /**
     * Gets a list of flowsheet customizations for the given flowsheet, providerNo, and demographicNo.
     * Note: a demographic's customizations takeprecedencee over a provider's
     * @param flowSheet The flowsheets short name
     * @param providerNo The provider's customizations to find
     * @param demographicNo The demographic's customizations to find
     * @return a list of the customizations
     */
    public List<FlowSheetCustomization> getFlowSheetCustomizations(String flowSheet, String providerNo, Integer demographicNo){
        LinkedHashMap<String, FlowSheetCustomization> providersCustomizations = getProviderLevelFlowSheetCustomizations(flowSheet, providerNo);
        LinkedHashMap<String, FlowSheetCustomization> demographicsCustomizations = getDemographicLevelFlowSheetCustomizations(flowSheet, demographicNo);

        LinkedHashMap<String, FlowSheetCustomization> prioritizedCustomizations = new LinkedHashMap<String, FlowSheetCustomization>();
        // Add all provider's customizations
        prioritizedCustomizations.putAll(providersCustomizations);
        // Add all demographic's customizations, overwriting any duplicates
        prioritizedCustomizations.putAll(demographicsCustomizations);
        
        return new ArrayList<FlowSheetCustomization>(prioritizedCustomizations.values());
    }
    
    public List<FlowSheetCustomization> getFlowSheetCustomizations(String flowsheet,String provider){
    	Query query = entityManager.createQuery("SELECT fd FROM FlowSheetCustomization fd WHERE fd.flowsheet=? and fd.archived=0 and fd.providerNo = ?  and fd.demographicNo = 0");
    	query.setParameter(1, flowsheet);
    	query.setParameter(2, provider);
    	
        @SuppressWarnings("unchecked")
        List<FlowSheetCustomization> list = query.getResultList();
        return list;
    }

    public LinkedHashMap<String, FlowSheetCustomization> getDemographicLevelFlowSheetCustomizations(String flowSheet, Integer demographic){
        Query query = entityManager.createQuery("SELECT fd FROM FlowSheetCustomization fd WHERE fd.flowsheet = :flowSheet and fd.archived=0 AND fd.demographicNo = :demographicNo ORDER BY fd.demographicNo DESC, fd.id");
        query.setParameter("flowSheet", flowSheet);
        query.setParameter("demographicNo", String.valueOf(demographic));

        @SuppressWarnings("unchecked")
        List<FlowSheetCustomization> resultList = query.getResultList();
        LinkedHashMap<String, FlowSheetCustomization> resultMap = new LinkedHashMap<String, FlowSheetCustomization>();
        
        for (FlowSheetCustomization result : resultList) {
            if (result.getMeasurement() != null) {
                resultMap.put(result.getMeasurement(), result);
            } else if (result.getPayload() != null) {
                resultMap.put(result.getPayload(), result);
            }
        }
        return resultMap;
    }
    public LinkedHashMap<String, FlowSheetCustomization> getProviderLevelFlowSheetCustomizations(String flowSheet, String providerNo){
        Query query = entityManager.createQuery("SELECT fd FROM FlowSheetCustomization fd WHERE fd.flowsheet = :flowSheet and fd.archived=0 " +
                "AND (fd.demographicNo = 0 OR fd.demographicNo IS NULL) " +
                "AND fd.providerNo = :providerNo ORDER BY fd.demographicNo DESC, fd.id");
        query.setParameter("flowSheet", flowSheet);
        query.setParameter("providerNo", providerNo);
        
        @SuppressWarnings("unchecked")
        List<FlowSheetCustomization> resultList = query.getResultList();
        LinkedHashMap<String, FlowSheetCustomization> resultMap = new LinkedHashMap<String, FlowSheetCustomization>();
        
        for (FlowSheetCustomization result : resultList) {
            if (result.getMeasurement() != null) {
                resultMap.put(result.getMeasurement(), result);
            } else if (result.getPayload() != null) {
                resultMap.put(result.getPayload(), result);
            }
        }
        return resultMap;
    }
}
