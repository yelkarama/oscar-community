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
package org.oscarehr.managers;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.Set;

import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;
import org.hl7.fhir.r4.model.Bundle;
import org.hl7.fhir.r4.model.Bundle.BundleEntryComponent;
import org.hl7.fhir.r4.model.CodeableConcept;
import org.hl7.fhir.r4.model.Coding;
import org.hl7.fhir.r4.model.Extension;
import org.hl7.fhir.r4.model.Medication;
import org.hl7.fhir.r4.model.Resource;
import org.hl7.fhir.r4.model.ResourceType;
import org.hl7.fhir.r4.model.ValueSet;
import org.hl7.fhir.r4.model.ValueSet.ConceptReferenceComponent;
import org.hl7.fhir.r4.model.ValueSet.ConceptReferenceDesignationComponent;
import org.hl7.fhir.r4.model.ValueSet.ConceptSetComponent;
import org.oscarehr.common.dao.CVCImmunizationDao;
import org.oscarehr.common.dao.CVCMedicationDao;
import org.oscarehr.common.dao.CVCMedicationGTINDao;
import org.oscarehr.common.dao.CVCMedicationLotNumberDao;
import org.oscarehr.common.dao.UserPropertyDAO;
import org.oscarehr.common.model.CVCImmunization;
import org.oscarehr.common.model.CVCImmunizationName;
import org.oscarehr.common.model.CVCMedication;
import org.oscarehr.common.model.CVCMedicationGTIN;
import org.oscarehr.common.model.CVCMedicationLotNumber;
import org.oscarehr.common.model.LookupList;
import org.oscarehr.common.model.LookupListItem;
import org.oscarehr.common.model.UserProperty;
import org.oscarehr.util.LoggedInInfo;
import org.oscarehr.util.MiscUtils;
import org.oscarehr.util.SpringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import ca.uhn.fhir.context.FhirContext;
import ca.uhn.fhir.rest.client.api.IGenericClient;
import ca.uhn.fhir.rest.client.api.IRestfulClientFactory;
import ca.uhn.fhir.rest.client.api.ServerValidationModeEnum;
import oscar.OscarProperties;
import oscar.log.LogAction;

@Service
public class CanadianVaccineCatalogueManager2 {
	
	protected static FhirContext ctxR4 = null;
	Logger logger = MiscUtils.getLogger();

	@Autowired
	CVCMedicationDao medicationDao;
	@Autowired
	CVCMedicationLotNumberDao lotNumberDao;
	@Autowired
	CVCMedicationGTINDao gtinDao;
	@Autowired
	CVCImmunizationDao immunizationDao;
	
	static {
		ctxR4 = FhirContext.forR4();
	}
	
	public void update(LoggedInInfo loggedInInfo) {
		clearCurrentData();
		Bundle bundle = getBundleFromServer();
		
		/*
		String bundleJSON = ctxR4.newJsonParser().setPrettyPrint(true).encodeResourceToString(bundle);
		try {
			FileUtils.writeStringToFile(new File("/home/marc/Downloads/bundle.json"), bundleJSON);
		}catch(IOException e) {
			logger.error("Error",e);
		}
		*/
		
		for(Bundle.BundleEntryComponent bec : bundle.getEntry()) {
			Resource res = bec.getResource();
			if(res.getResourceType() ==  ResourceType.ValueSet) {
				if(res.getIdElement().getIdPart().equals("Generic")) {
					updateGenericImmunizations(loggedInInfo,(ValueSet)res);
				} else if(res.getIdElement().getIdPart().equals("Tradename")) {
					updateBrandNameImmunizations(loggedInInfo,(ValueSet)res);
				} else if(res.getIdElement().getIdPart().equals("AnatomicalSite")) {
					updateAnatomicalSites(loggedInInfo,(ValueSet)res);
				} else if(res.getIdElement().getIdPart().equals("RouteOfAdmin")) {
					updateRoutes(loggedInInfo,(ValueSet)res);
				} else {
					//ShelfStatus, Disease, AntigenAntitoxen, administrative-gender, RepSource, ForecastStatus
					logger.debug("value-set " + res.getId());
				}
			} else if(res.getResourceType() ==  ResourceType.Bundle) {
				if(res.getIdElement().getIdPart().equals("Tradename")) {
					updateMedications(loggedInInfo,(Bundle)res);
				}
			} else {
				logger.warn("resource type = " + res.getResourceType().toString());	
			}
		}
		
		//store when we last update
		setUpdatedInPropertyTable();
	}

	private void setUpdatedInPropertyTable() {
		UserPropertyDAO userPropertyDao = SpringUtils.getBean(UserPropertyDAO.class);
		SimpleDateFormat formatter = new SimpleDateFormat("yyyy-MM-dd");
		UserProperty up = userPropertyDao.getProp("cvc.updated");
		if(up == null) {
			up = new UserProperty();
			up.setName("cvc.updated");
		}
		up.setValue(formatter.format(new Date()));
		
		userPropertyDao.merge(up);
		
	}
	
	private void clearCurrentData() {
		medicationDao.removeAll();
		lotNumberDao.removeAll();
		gtinDao.removeAll();
		immunizationDao.removeAll();
	}
	
	private Bundle getBundleFromServer() {
		IRestfulClientFactory clientFactory = ctxR4.getRestfulClientFactory();
		clientFactory.setServerValidationMode(ServerValidationModeEnum.NEVER);
		IGenericClient client = clientFactory.newGenericClient(CanadianVaccineCatalogueManager2.getCVCURL());
		logger.debug("serverBase=" + CanadianVaccineCatalogueManager2.getCVCURL());
		String xAppDesc = OscarProperties.getInstance().getProperty("oneid.oauth2.clientId","OSCAREMR");
		Bundle bundle =client.search().byUrl(CanadianVaccineCatalogueManager2.getCVCURL() + "/Bundle/CVC").withAdditionalHeader("x-app-desc",xAppDesc).returnBundle(Bundle.class).execute();
		return bundle;
	}
	
	public void updateGenericImmunizations(LoggedInInfo loggedInInfo, ValueSet vs) {
		 
		for (ConceptSetComponent c : vs.getCompose().getInclude()) {
			List<ConceptReferenceComponent> cons = c.getConcept();
			for (ConceptReferenceComponent cc : cons) {
				CVCImmunization imm = new CVCImmunization();

				imm.setSnomedConceptId(cc.getCode());
				imm.setVersionId(0);
				//cc.getDisplay()
				
				for(ConceptReferenceDesignationComponent cr : cc.getDesignation()) {
					Coding use = cr.getUse();
					CVCImmunizationName name = new CVCImmunizationName();
					name.setLanguage(cr.getLanguage());
					if(use  != null) {
						name.setUseSystem(use.getSystem());
						name.setUseCode(use.getCode());
						name.setUseDisplay(use.getDisplay());
					}
					name.setValue(cr.getValue());
					imm.getNames().add(name);
				}
				
				for (Extension ext : cc.getExtension()) {
					if ("https://cvc.canimmunize.ca/v3/StructureDefinition/ca-cvc-concept-status-extension".equals(ext.getUrl())) {
						//active or inactive
						String status = ext.getValueAsPrimitive().getValueAsString();
					}
					
					if ("https://cvc.canimmunize.ca/v3/StructureDefinition/ca-cvc-concept-last-updated".equals(ext.getUrl())) {
						Date lastUpdated = (Date)ext.getValueAsPrimitive().getValue();
					}
					
					if ("https://cvc.canimmunize.ca/v3/StructureDefinition/ca-cvc-ontario-ispa-vaccine".equals(ext.getUrl())) {
						Boolean ispa = (Boolean)ext.getValueAsPrimitive().getValue();
						imm.setIspa(ispa);	
					}
					
					if ("https://cvc.canimmunize.ca/v3/StructureDefinition/ca-cvc-passive-immunizing-agent".equals(ext.getUrl())) {
						Boolean passiveImmAgent = (Boolean)ext.getValueAsPrimitive().getValue();
						
					}
					
					if ("https://cvc.canimmunize.ca/v3/StructureDefinition/ca-cvc-contains-antigens".equals(ext.getUrl())) {
						//more structure
					}
					
					if ("https://cvc.canimmunize.ca/v3/StructureDefinition/ca-cvc-protects-against-diseases".equals(ext.getUrl())) {
						//more structure
					}
					
				}
				
				
				/*
				for (Extension ext : cc.getExtension()) {
					if ("https://cvc.canimmunize.ca/extensions/prevalence".equals(ext.getUrl())) {
						Integer prevalence = (Integer) ext.getValueAsPrimitive().getValue();
						imm.setPrevalence(prevalence);
					}
					
				}
				*/
				imm.setGeneric(true);
				saveImmunization(loggedInInfo, imm);
			}
		}
	}
	
	public void saveImmunization(LoggedInInfo loggedInInfo, CVCImmunization immunization) {
		immunizationDao.saveEntity(immunization);
		LogAction.addLogSynchronous(loggedInInfo, "CanadianVaccineCatalogueManager.saveImmunization", immunization.getId().toString());

	}

	public void updateBrandNameImmunizations(LoggedInInfo loggedInInfo, ValueSet vs) {
	
		for (ConceptSetComponent c : vs.getCompose().getInclude()) {
			List<ConceptReferenceComponent> cons = c.getConcept();
			for (ConceptReferenceComponent cc : cons) {
				CVCImmunization imm = new CVCImmunization();

				imm.setSnomedConceptId(cc.getCode());
				imm.setVersionId(0);
				
				for(ConceptReferenceDesignationComponent cr : cc.getDesignation()) {
					Coding use = cr.getUse();
					CVCImmunizationName name = new CVCImmunizationName();
					name.setLanguage(cr.getLanguage());
					if(use  != null) {
						name.setUseSystem(use.getSystem());
						name.setUseCode(use.getCode());
						name.setUseDisplay(use.getDisplay());
					}
					name.setValue(cr.getValue());
					imm.getNames().add(name);
				}
				

				for (Extension ext : cc.getExtension()) {
					/*
					if ("https://cvc.canimmunize.ca/extensions/prevalence".equals(ext.getUrl())) {
						Integer prevalence = (Integer) ext.getValueAsPrimitive().getValue();
						imm.setPrevalence(prevalence);
					}
					*/
					
					if ("https://cvc.canimmunize.ca/v3/StructureDefinition/ca-cvc-shelf-status".equals(ext.getUrl())) {
						
					}
					
					if ("https://cvc.canimmunize.ca/v3/StructureDefinition/ca-cvc-concept-last-updated".equals(ext.getUrl())) {
						
					}
					
					if ("https://cvc.canimmunize.ca/v3/StructureDefinition/ca-cvc-ontario-ispa-vaccine".equals(ext.getUrl())) {
						Boolean ispa =  (Boolean)ext.getValueAsPrimitive().getValue();
						imm.setIspa(ispa);
					}
					if ("https://cvc.canimmunize.ca/v3/StructureDefinition/ca-cvc-parent-concept".equals(ext.getUrl())) {
						CodeableConcept parentConcept = (CodeableConcept)ext.getValue();
						for(Coding parentConceptCode :parentConcept.getCoding()) {
							if("https://cvc.canimmunize.ca/v3/ValueSet/Generic".equals(parentConceptCode.getSystem())) {
								imm.setParentConceptId(parentConceptCode.getCode());
							}
						}
						//String parent = ext.getValue().toString();
						//imm.setParentConceptId(parent);
					}
					if ("https://cvc.canimmunize.ca/v3/StructureDefinition/ca-cvc-din".equals(ext.getUrl())) {
						
					}
					if ("https://cvc.canimmunize.ca/v3/StructureDefinition/ca-cvc-typical-dose-size".equals(ext.getUrl())) {
						String typicalDose = ext.getValueAsPrimitive().getValueAsString();
						imm.setTypicalDose(typicalDose);
					}
					
					if ("https://cvc.canimmunize.ca/v3/StructureDefinition/ca-cvc-typical-dose-size-uom".equals(ext.getUrl())) {
						String typicalDoseUofM = ext.getValueAsPrimitive().getValueAsString();
						imm.setTypicalDoseUofM(typicalDoseUofM);
					}
					if ("https://cvc.canimmunize.ca/v3/StructureDefinition/ca-cvc-strength".equals(ext.getUrl())) {
						String strength = ext.getValueAsPrimitive().getValueAsString();
						imm.setStrength(strength);
					}
					
					if ("https://cvc.canimmunize.ca/v3/StructureDefinition/ca-cvc-passive-immunizing-agent".equals(ext.getUrl())) {
						Boolean passiveImmAgent = (Boolean)ext.getValueAsPrimitive().getValue();
						
					}
					
					if ("https://cvc.canimmunize.ca/v3/StructureDefinition/ca-cvc-contains-antigens".equals(ext.getUrl())) {
						//more structure
					}
					
					if ("https://cvc.canimmunize.ca/v3/StructureDefinition/ca-cvc-protects-against-diseases".equals(ext.getUrl())) {
						//more structure
					}
					
				}
				imm.setGeneric(false);

				saveImmunization(loggedInInfo, imm);
			}
		}
	}
	
	public void updateMedications(LoggedInInfo loggedInInfo,Bundle bundle) {
		
		processMedicationBundle(loggedInInfo, bundle);
		/*
		logger.debug("Retrieved Bundle ID + " + bundle.getId() + ", total records found = " + bundle.getTotal());
		while (bundle.getLink(Bundle.LINK_NEXT) != null) {
			bundle = client.loadPage().next(bundle).execute();
			logger.debug("Retrieved Next Bundle ID + " + bundle.getId());
			processMedicationBundle(loggedInInfo, bundle);
		}
		*/
	}
	
	private void processMedicationBundle(LoggedInInfo loggedInInfo, Bundle bundle) {

		SimpleDateFormat formatter = new SimpleDateFormat("yyyy-MM-dd");
		for (BundleEntryComponent entry : bundle.getEntry()) {
			CVCMedication cMed = new CVCMedication();

			Medication med = (Medication) entry.getResource();
			logger.debug("processing " + med.getId());
		//	cMed.setBrand(med.getIsBrand());
			cMed.setStatus(med.getStatus().toString());

			for (Coding c : med.getCode().getCoding()) {
				if ("http://hl7.org/fhir/sid/ca-hc-din".equals(c.getSystem())) {
					cMed.setDin(c.getCode());
					cMed.setDinDisplayName(c.getDisplay());
				}
				if ("https://fhir.infoway-inforoute.ca/CodeSystem/snomedctcaextension".equals(c.getSystem())) {
					cMed.setSnomedCode(c.getCode());
					cMed.setSnomedDisplay(c.getDisplay());
				}
				if ("http://www.gs1.org/gtin".equals(c.getSystem())) {
					cMed.getGtinList().add(new CVCMedicationGTIN(cMed, c.getCode()));
				}
			}
			
			for (Extension ext : med.getExtension()) {
				if ("https://cvc.canimmunize.ca/v3/StructureDefinition/ca-cvc-shelf-status".equals(ext.getUrl())) {
					
				}
				
				if ("https://cvc.canimmunize.ca/v3/StructureDefinition/ca-cvc-concept-last-updated".equals(ext.getUrl())) {
					
				}
				
				if ("https://cvc.canimmunize.ca/v3/StructureDefinition/ca-cvc-container".equals(ext.getUrl())) {
					
				}

				if ("https://cvc.canimmunize.ca/v3/StructureDefinition/ca-cvc-lots".equals(ext.getUrl())) {
					for(Extension lotsExt : ext.getExtension()) {
						if("ca-cvc-lot".equals(lotsExt.getUrl())) {
							String lotNumber = null;
							String expiry = null;
							for(Extension lotExt : lotsExt.getExtension()) {
								if("lotNumber".equals(lotExt.getUrl())) {
									lotNumber= lotExt.getValueAsPrimitive().getValueAsString();
								}
								if("expiryDate".equals(lotExt.getUrl())) {
									expiry = lotExt.getValueAsPrimitive().getValueAsString();
								}
							}
							try {
								cMed.getLotNumberList().add(new CVCMedicationLotNumber(cMed, lotNumber, formatter.parse(expiry)));
							}catch(ParseException e) {
								logger.warn("Error",e);
							}
						}
					}
				}
			}
			
			
/*
			if (med.getManufacturer() != null) {
				//med.getManufacturer().getIdentifier().getSystem();			
				cMed.setManufacturerId(med.getManufacturer().getIdentifier().getValue());
				cMed.setManufacturerDisplay(med.getManufacturer().getDisplay());
			}

			for (MedicationPackageBatchComponent comp : med.getPackage().getBatch()) {
				cMed.getLotNumberList().add(new CVCMedicationLotNumber(cMed, comp.getLotNumber(), comp.getExpirationDate()));
			}
*/
			//logger.info("saving a medication: " + cMed.getDinDisplayName());

			saveMedication(loggedInInfo, cMed);
		}

	}
	
	public void saveMedication(LoggedInInfo loggedInInfo, CVCMedication medication) {
		Set<CVCMedicationGTIN> gtins = medication.getGtinList();
		Set<CVCMedicationLotNumber> lotNumbers = medication.getLotNumberList();

		medication.setGtinList(null);
		medication.setLotNumberList(null);
		medicationDao.saveEntity(medication);

		for (CVCMedicationGTIN g : gtins) {
			gtinDao.saveEntity(g);
		}

		for (CVCMedicationLotNumber l : lotNumbers) {
			lotNumberDao.saveEntity(l);
		}

		//--- log action ---
		LogAction.addLogSynchronous(loggedInInfo, "CanadianVaccineCatalogueManager.saveMedication", medication.getId().toString());

	}

	public void updateAnatomicalSites(LoggedInInfo loggedInInfo, ValueSet vs) {
		int displayOrder = 0;
		String siteData = FhirContext.forR4().newJsonParser().encodeResourceToString(vs);
		
		//create and/or get reference to LookupList
		//clear existing list
		LookupListManager llm = SpringUtils.getBean(LookupListManager.class);
		LookupList ll = llm.findLookupListByName(loggedInInfo,"AnatomicalSite");
		if(ll == null) {
			ll = new LookupList();
			ll.setActive(true);
			ll.setCreatedBy("OSCAR");
			ll.setDateCreated(new Date());
			ll.setDescription("Anatomical Sites from CVC");
			ll.setName("AnatomicalSite");
			ll.setListTitle("Anatomical Site");
			ll = llm.addLookupList(loggedInInfo, ll);
		} else {
			llm.removeLookupListItems(loggedInInfo, ll.getId());
			ll = llm.findLookupListByName(loggedInInfo,"AnatomicalSite");
		}
		
		for (ConceptSetComponent c : vs.getCompose().getInclude()) {
			String version = c.getVersion();
			String system = c.getSystem();
			
			
			List<ConceptReferenceComponent> cons = c.getConcept();
			for (ConceptReferenceComponent cc : cons) {
				for(Extension ext : cc.getExtension()) {
					if("https://cvc.canimmunize.ca/v3/StructureDefinition/ca-cvc-concept-status-extension".equals(ext.getUrl())) {
						String status = (String)ext.getValueAsPrimitive().getValue();
					}
					if("https://cvc.canimmunize.ca/v3/StructureDefinition/ca-cvc-concept-last-updated".equals(ext.getUrl())) {
						Date dateLastUpdated = (Date)ext.getValueAsPrimitive().getValue();
					}
				}
				String code = cc.getCode();
				String display = cc.getDisplay();
				
				for(ConceptReferenceDesignationComponent crdc : cc.getDesignation()) {
					String language = crdc.getLanguage();
					String value = crdc.getValue();
					if(crdc.getUse() != null) {
						String useSystem = crdc.getUse().getSystem();
						String useCode = crdc.getUse().getCode();
						String useDisplay = crdc.getUse().getDisplay();
					}
				}
				
				LookupListItem lli = new LookupListItem();
				lli.setActive(true);
				lli.setCreatedBy("OSCAR");
				lli.setDateCreated(new Date());
				lli.setLabel(display);
				lli.setValue(code);
				lli.setLookupListId(ll.getId());
				lli.setDisplayOrder(displayOrder++);
				llm.addLookupListItem(loggedInInfo, lli);
			}	
		}
	}
	
	public void updateRoutes(LoggedInInfo loggedInInfo, ValueSet vs) {
		int displayOrder = 0;
		
		String routeData = FhirContext.forR4().newJsonParser().encodeResourceToString(vs);
		//logger.info("routeData=" + routeData);
		//create and/or get reference to LookupList
		//clear existing list
		LookupListManager llm = SpringUtils.getBean(LookupListManager.class);
		LookupList ll = llm.findLookupListByName(loggedInInfo,"RouteOfAdmin");
		if(ll == null) {
			ll = new LookupList();
			ll.setActive(true);
			ll.setCreatedBy("OSCAR");
			ll.setDateCreated(new Date());
			ll.setDescription("Routes of Administration from CVC");
			ll.setName("RouteOfAdmin");
			ll.setListTitle("Routes of Administration");
			ll = llm.addLookupList(loggedInInfo, ll);
		} else {
			llm.removeLookupListItems(loggedInInfo, ll.getId());
			ll = llm.findLookupListByName(loggedInInfo,"RouteOfAdmin");
		}
		
		for (ConceptSetComponent c : vs.getCompose().getInclude()) {
			String version = c.getVersion();
			String system = c.getSystem();
			
			List<ConceptReferenceComponent> cons = c.getConcept();
			for (ConceptReferenceComponent cc : cons) {
				for(Extension ext : cc.getExtension()) {
					if("https://cvc.canimmunize.ca/v3/StructureDefinition/ca-cvc-concept-status-extension".equals(ext.getUrl())) {
						String status = (String)ext.getValueAsPrimitive().getValue();
					}
					if("https://cvc.canimmunize.ca/v3/StructureDefinition/ca-cvc-concept-last-updated".equals(ext.getUrl())) {
						Date dateLastUpdated = (Date)ext.getValueAsPrimitive().getValue();
					}
				}
				String code = cc.getCode();
				String display = cc.getDisplay();
				
				for(ConceptReferenceDesignationComponent crdc : cc.getDesignation()) {
					String language = crdc.getLanguage();
					String value = crdc.getValue();
					if(crdc.getUse() != null) {
						String useSystem = crdc.getUse().getSystem();
						String useCode = crdc.getUse().getCode();
						String useDisplay = crdc.getUse().getDisplay();
					}
				}
				
				LookupListItem lli = new LookupListItem();
				lli.setActive(true);
				lli.setCreatedBy("OSCAR");
				lli.setDateCreated(new Date());
				lli.setLabel(display);
				lli.setValue(code);
				lli.setLookupListId(ll.getId());
				lli.setDisplayOrder(displayOrder++);
				llm.addLookupListItem(loggedInInfo, lli);
			}	
		}
		
	}
	
	public static String getCVCURL() {
		String url = OscarProperties.getInstance().getProperty("cvc.url");
		UserPropertyDAO upDao = SpringUtils.getBean(UserPropertyDAO.class);
		
		UserProperty up =  upDao.getProp("cvc.url");
		if(up != null && !StringUtils.isEmpty(up.getValue())) {
			url = up.getValue();
		}
		
		return url;
	}
}