package org.oscarehr.integration.dhdr;
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
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;

import javax.servlet.http.HttpServletRequest;
import javax.ws.rs.core.Response;

import org.apache.commons.io.IOUtils;
import org.apache.cxf.jaxrs.client.WebClient;
import org.apache.log4j.Logger;
import org.hl7.fhir.r4.model.Bundle;
import org.hl7.fhir.r4.model.OperationOutcome;
import org.oscarehr.common.model.Demographic;
import org.oscarehr.util.LoggedInInfo;
import org.oscarehr.util.MiscUtils;

import ca.uhn.fhir.context.FhirContext;
import oscar.OscarProperties;

public class DHDRManager extends OmdGateway {
	
	Logger logger = MiscUtils.getLogger();
	static FhirContext ctx = FhirContext.forR4();
	/*
	public Bundle search(HttpServletRequest request, Demographic demographic, Date startDate, Date endDate) throws Exception {
		LoggedInInfo loggedInInfo = LoggedInInfo.getLoggedInInfoFromSession(request);
		Map<String, String> params = new HashMap<String, String>();
		SimpleDateFormat fmt = new SimpleDateFormat("yyyy-MM-dd");
		//params.put("patient.identifier", "http://ehealthontario.ca/fhir/NamingSystem/ca-on-patient-hcn|" + "7361544534");
		params.put("patient.identifier", "https://fhir.infoway-inforoute.ca/NamingSystem/ca-on-patient-hcn|" + "5365837912");
		
		
		if (endDate == null) {
			params.put("whenprepared", "lt"+fmt.format(new Date()));
		}
		//params.put("patient.birthdate", dob);
		//params.put("patient.gender", mapGender(gender));
		//params.put("patient.family", lastName);
		//params.put("patient.given", firstName);
		//params.put("_include", "Immunization:patient");
		//params.put("_include", "Immunization:performer");
		//params.put("_revinclude:recurse", "ImmunizationRecommendation:patient");
		params.put("_format", "application/fhir+json");
		
		
		
		WebClient wc = getWebClient(loggedInInfo,OmdGateway.MedicationDispense);
		
		for (Entry<String, String> entry : params.entrySet()) {
			wc.query(entry.getKey(), entry.getValue());
		}	
		
		Response response2 = doGet(wc, request);			
		String body = response2.readEntity(String.class);
		
		logger.info("body:"+ body);
		
		if(response2.getStatus() >= 200 && response2.getStatus() < 300) {	
			Bundle bundle = (Bundle) ctx.newJsonParser().parseResource(body);
			//hasConsentBlock(bundle);
			//outcomes.addAll(hasOperationOutcome(bundle));
			return bundle;
		} else if(response2.getStatus() >= 400 && response2.getStatus() < 600 && body != null) {
			OperationOutcome outcome = ctx.newJsonParser().parseResource(OperationOutcome.class, body);
			if(outcome != null) {
				logger.warn("would add outcome here "+outcome);
				//outcomes.add(outcome);
			} else {
				//notifyDHIRError(loggedInInfo,"An error occurred retrieving the data. (" + response2.getStatus() + ":" + ((body != null)?body:"") + ")");
				//throw new DHIRException("An error occurred retrieving the data. (" + response2.getStatus() + ":" + ((body != null)?body:"") + ")");
				logger.error("throw error here");
			}
		} else {
			logger.error(response2.getStatus()); 
			logger.error(body);
			//notifyDHIRError(loggedInInfo,"An error occurred retrieving the data. (" + response2.getStatus() + ":" + ((body != null)?body:"") + ")");
			//throw new DHIRException("An error occurred retrieving the data. (" + response2.getStatus() + ":" + ((body != null)?body:"") + ")");
		}
		 
		return null;

	}
*/
	//This only used if the endpoint is different for the dhdr than the rest of the gateway applications
	@Override
	protected String getConsumerKey() {
		if(OscarProperties.getInstance().hasProperty("oneid.consumerKey.dhdr")) {
			return OscarProperties.getInstance().getProperty("oneid.consumerKey.dhdr");
		}
		return OscarProperties.getInstance().getProperty("oneid.consumerKey");
	}
	
	@Override
	protected String getEndpointURL() {
		if(OscarProperties.getInstance().hasProperty("oneid.gateway.url.dhdr")) {
			return OscarProperties.getInstance().getProperty("oneid.gateway.url.dhdr");
		}
		return OscarProperties.getInstance().getProperty("oneid.gateway.url");
	}
	
	
	
	
	
	public String search2(LoggedInInfo loggedInInfo, Demographic demographic, Date startDate, Date endDate) throws Exception {
		
		Map<String, String> params = new HashMap<String, String>();
		SimpleDateFormat fmt = new SimpleDateFormat("yyyy-MM-dd");
		//params.put("patient.identifier", "http://ehealthontario.ca/fhir/NamingSystem/ca-on-patient-hcn|" + "7361544534");
		params.put("patient.identifier", "https://fhir.infoway-inforoute.ca/NamingSystem/ca-on-patient-hcn|" + demographic.getHin());//"5365837912");
		
		
		if (endDate == null) {
			params.put("whenprepared", "lt"+fmt.format(endDate));
		}else {
			params.put("whenprepared", "lt"+fmt.format(new Date()));
		}
		if (startDate != null) {
			params.put("whenprepared", "gt"+fmt.format(startDate));
		}
		
		params.put("_format", "application/fhir+json");
		
		
		logger.info("params: "+params);
		WebClient wc = getWebClient(loggedInInfo,OmdGateway.MedicationDispense);
		
		wc.query("patient.identifier", "https://fhir.infoway-inforoute.ca/NamingSystem/ca-on-patient-hcn|" + demographic.getHin());//"5365837912");
		
		wc.query("patient.birthdate", demographic.getBirthDayAsString());
		
		//Map to fhir types “male”, “female”, “other”, “unknown”
		
		if("M".equalsIgnoreCase(demographic.getSex())){
			wc.query("patient.gender", "male");//"5365837912");
		}else if("F".equalsIgnoreCase(demographic.getSex())){
			wc.query("patient.gender", "female");//"5365837912");
		}else if("T".equalsIgnoreCase(demographic.getSex())){
			wc.query("patient.gender", "other");//"5365837912");
		}else if("O".equalsIgnoreCase(demographic.getSex())){
			wc.query("patient.gender", "other");//"5365837912");
		}else if("U".equalsIgnoreCase(demographic.getSex())){
			wc.query("patient.gender", "unknown");//"5365837912");
		}else{
			wc.query("patient.gender", "unknown");//"5365837912");
		}
	
		
		wc.query("_count", "500");
		
		if (endDate == null) {
			wc.query("whenprepared", "lt"+fmt.format(endDate));
		}else {
			wc.query("whenprepared", "lt"+fmt.format(new Date()));
		}
		if (startDate != null) {
			wc.query("whenprepared", "gt"+fmt.format(startDate));
		}
		wc.query("_format", "application/fhir+json");
		
		
		AuditInfo auditInfo = new AuditInfo(AuditInfo.DHDR,AuditInfo.SEARCH,demographic.getDemographicNo());
		Response response2 = doGet(loggedInInfo, wc,auditInfo);			
		String body = response2.readEntity(String.class);
		
		//java.io.InputStream salida = (java.io.InputStream) response2.getEntity();
		//java.io.StringWriter writer = new java.io.StringWriter();
        //IOUtils.copy(salida, writer, "UTF-8");
		//body = writer.toString();
		logger.info("body:"+ body);
		
		if(response2.getStatus() >= 200 && response2.getStatus() < 300) {	
			Bundle bundle = (Bundle) ctx.newJsonParser().parseResource(body);
			//hasConsentBlock(bundle);
			//outcomes.addAll(hasOperationOutcome(bundle));
			return body;
		} else if(response2.getStatus() >= 400 && response2.getStatus() < 600 && body != null) {
			OperationOutcome outcome = ctx.newJsonParser().parseResource(OperationOutcome.class, body);
			if(outcome != null) {
				logger.warn("would add outcome here "+outcome);
				return body;
				//outcomes.add(outcome);
			} else {
				//notifyDHIRError(loggedInInfo,"An error occurred retrieving the data. (" + response2.getStatus() + ":" + ((body != null)?body:"") + ")");
				//throw new DHIRException("An error occurred retrieving the data. (" + response2.getStatus() + ":" + ((body != null)?body:"") + ")");
				logger.error("throw error here");
			}
		} else {
			logger.error(response2.getStatus()); 
			logger.error(body);
			//notifyDHIRError(loggedInInfo,"An error occurred retrieving the data. (" + response2.getStatus() + ":" + ((body != null)?body:"") + ")");
			//throw new DHIRException("An error occurred retrieving the data. (" + response2.getStatus() + ":" + ((body != null)?body:"") + ")");
		}
		 
		return null;

	}
	
}
