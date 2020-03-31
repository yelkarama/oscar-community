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
package org.oscarehr.ws.rest;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import javax.ws.rs.Consumes;
import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.QueryParam;
import javax.ws.rs.core.Response;

import org.apache.log4j.Logger;
import org.hl7.fhir.r4.model.Bundle;
import org.hl7.fhir.r4.model.MedicationDispense;
import org.hl7.fhir.r4.model.Organization;
import org.hl7.fhir.r4.model.Practitioner;
import org.hl7.fhir.r4.model.Resource;
import org.hl7.fhir.r4.model.ResourceType;
import org.hl7.fhir.r4.model.Bundle.BundleEntryComponent;
import org.hl7.fhir.r4.model.Coding;
import org.hl7.fhir.r4.model.Extension;
import org.hl7.fhir.r4.model.HumanName;
import org.hl7.fhir.r4.model.Identifier;
import org.hl7.fhir.r4.model.Medication;
import org.oscarehr.common.dao.DemographicDao;
import org.oscarehr.common.model.Demographic;

import org.oscarehr.integration.dhdr.DHDRManager;
import org.oscarehr.util.MiscUtils;
import org.oscarehr.ws.rest.to.DHDRSearchConfig;
import org.oscarehr.ws.rest.to.model.MedicationDispenseTo1;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

@Path("/dhdr")
@Component("dhdrService")
public class DHDRService extends AbstractServiceImpl {
	Logger logger = MiscUtils.getLogger();

	@Autowired
	DemographicDao demographicDao;
	
	@GET
	@Path("/searchByDemographicNo")
	@Produces("application/json")
	public Response searchByDemographicNo(@QueryParam("demographicNo") int demographicNo, @QueryParam("offset") int offset, @QueryParam("limit") int limit) throws Exception{
		
		DHDRManager dhdrManager = new DHDRManager();
		Date startDate = null;
		Date endDate = null;
		Demographic demographic = demographicDao.getDemographicById(demographicNo);
		Bundle bundle = dhdrManager.search(getHttpServletRequest(), demographic, startDate, endDate);
		List<MedicationDispenseTo1> list = new ArrayList<MedicationDispenseTo1>();
		
		for(BundleEntryComponent comp : bundle.getEntry()) {
			Resource resource = comp.getResource();
			logger.info("resource type "+resource.getResourceType());
			if(resource.getResourceType() == ResourceType.MedicationDispense) {
				list.add(translate((MedicationDispense)resource));
			}
			
		}

		
		
		
		return Response.ok().entity(list).build();
	}
	
	
	@POST
	@Path("/searchByDemographicNo2")
	@Produces("application/json")
	@Consumes("application/json")
	public Response searchByDemographicNo2(@QueryParam("demographicNo") int demographicNo, @QueryParam("offset") int offset, @QueryParam("limit") int limit,DHDRSearchConfig searchConfig ) throws Exception{
		
		DHDRManager dhdrManager = new DHDRManager();
		Date startDate = null;
		Date endDate = null;
		if(searchConfig != null) {
			startDate = searchConfig.getStartDate();
			endDate = searchConfig.getEndDate();
		}
		Demographic demographic = demographicDao.getDemographicById(demographicNo);
		String bundle = dhdrManager.search2(getHttpServletRequest(), demographic, startDate, endDate);
				
		
		return Response.ok().entity(bundle).build();
	}
	
	
	
	public MedicationDispenseTo1 translate(MedicationDispense medicationDispense) {
		MedicationDispenseTo1 medicationDispenseTo1 = new MedicationDispenseTo1();
		List<Resource> listRes =medicationDispense.getContained();
		
		medicationDispenseTo1.setDispenseDate(medicationDispense.getWhenPrepared()); //
		medicationDispenseTo1.setDispensedQuantity(medicationDispense.getQuantity().getValue().toPlainString());
		medicationDispenseTo1.setEstimatedDaysSupply(medicationDispense.getDaysSupply().getValue().toPlainString());// display right?
		
		
		
		
		for(Resource resource :listRes) {
			
			if(resource.getResourceType()  == ResourceType.Medication) {
				Medication medication = (Medication) resource;
				if(medication != null && medication.getCode() != null) {
					medicationDispenseTo1.setDrugDosageForm(medication.getForm().getText());
					Extension ext = medication.getExtensionByUrl("http://ehealthontario.ca/fhir/StructureDefinition/ca-on-medications-ext-medication-strength");
					if(ext != null) {
						medicationDispenseTo1.setDispensedDrugStrength(ext.getValue().primitiveValue());
					}
					List<Coding> codings = medication.getCode().getCoding();
					for(Coding coding : codings) {
						//{"system": "http://hl7.org/fhir/NamingSystem/ca-hc-din","code": "01916580","display": "Hycodan"
						if("http://hl7.org/fhir/NamingSystem/ca-hc-din".equals(coding.getSystem())) {
							medicationDispenseTo1.setBrandName(coding.getDisplay());
						}
						if("http://ehealthontario.ca/fhir/NamingSystem/ca-drug-gen-name".equals(coding.getSystem())) {
							medicationDispenseTo1.setGenericName(coding.getDisplay());
						}
			            //"system": "http://ehealthontario.ca/fhir/NamingSystem/ca-drug-gen-name","display": "HYDROCODONE BITARTRATE"
			          
			            //"system": "http://ehealthontario.ca/fhir/NamingSystem/ca-on-drug-class-ahfs","code": "480000000","display": "COUGH PREPARATIONS"
			            //"system": "http://ehealthontario.ca/fhir/NamingSystem/ca-on-drug-subclass-ahfs","code": "480400000","display": "ANTITUSSIVES"
			         
					}
				}else {
					logger.error("was null "+medication);
				}
			
			}else if(resource.getResourceType()  == ResourceType.Organization) {
				Organization organization = (Organization) resource;
				medicationDispenseTo1.setDispensingPharmacy(organization.getName());
				medicationDispenseTo1.setDispensingPharmacyFaxNumber(organization.getTelecom().get(1).getValue());
			}else if(resource.getResourceType()  == ResourceType.Practitioner) {
				Practitioner practitioner = (Practitioner) resource;
				for(Identifier identifier:practitioner.getIdentifier()) {
					if("https://fhir.infoway-inforoute.ca/NamingSystem/ca-on-license-physician".equals(identifier.getSystem())) {
						for(HumanName humanName :practitioner.getName()) {
							medicationDispenseTo1.setPrescriberLastname(humanName.getFamily());
							medicationDispenseTo1.setPrescriberFirstname(humanName.getGivenAsSingleString());
						}
						
						
						medicationDispenseTo1.setPrescriberPhoneNumber(practitioner.getTelecom().get(0).getValue());
					}
						
				}
			}else {
				logger.error("resource.getResourceType() "+resource.getResourceType());
			}
			/*
			source.getResourceType() Patient
2020-03-14 01:49:08,823 ERROR [DHDRService:133] resource.getResourceType() Practitioner
2020-03-14 01:49:08,823 ERROR [DHDRService:133] resource.getResourceType() Organization
2020-03-14 01:49:08,823 ERROR [DHDRService:133] resource.getResourceType() Practitioner
2020-03-14 01:49:08,823 ERROR [DHDRService:133] resource.getResourceType() MedicationRequest 
			 */
		}
		
		
		return medicationDispenseTo1;
	}
	
}
