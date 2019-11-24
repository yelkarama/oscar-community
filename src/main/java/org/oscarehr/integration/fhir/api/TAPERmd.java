package org.oscarehr.integration.fhir.api;

import java.util.Date;
import java.util.List;

import org.hl7.fhir.dstu3.model.CodeableConcept;
import org.hl7.fhir.dstu3.model.Coding;
import org.hl7.fhir.dstu3.model.Enumerations.AdministrativeGender;

import org.hl7.fhir.dstu3.model.Identifier;
import org.hl7.fhir.dstu3.model.Quantity;
import org.hl7.fhir.dstu3.model.Observation.ObservationComponentComponent;
import org.hl7.fhir.dstu3.model.Observation.ObservationStatus;
import org.oscarehr.integration.fhir.builder.FhirBundleBuilder;

import org.oscarehr.integration.fhir.manager.OscarFhirConfigurationManager;
import org.oscarehr.integration.fhir.resources.Settings;
import org.oscarehr.integration.fhir.resources.constants.FhirDestination;
import org.oscarehr.util.LoggedInInfo;
 


public class TAPERmd {
	
	private static Settings SETTINGS = new Settings( FhirDestination.TAPERMD, null );
	
	/*
	 *  TaperMD is looking for a bundle with 
	 *  
		 - sCr [umol/L ]
		 -age 
		 -bp 
		 
	 */
	public FhirBundleBuilder getFhirBundleBuilder(LoggedInInfo loggedInInfo,int demographicNo,List<String> dins,
												double weight, Date weightDate, int systolic,int diastolic, Date bpDate,
												double scr, Date scrDate,
												String patientSex,
												String mrpLastname, String mrpFirstname,String mrpNumber) {
		
		OscarFhirConfigurationManager configurationManager = new OscarFhirConfigurationManager( loggedInInfo, SETTINGS );
		FhirBundleBuilder fhirBundleBuilder = new FhirBundleBuilder( configurationManager );
		for(String din:dins) {
			fhirBundleBuilder.addResource(getMed(din));
		}
		
		
		fhirBundleBuilder.addResource(getWeight(weight, weightDate));
		fhirBundleBuilder.addResource(getBp(systolic, diastolic, bpDate));
		fhirBundleBuilder.addResource(getCreatinine(scr, scrDate));
		fhirBundleBuilder.addResource(getPatientResource(demographicNo, patientSex));
		fhirBundleBuilder.addResource(getPractioner(mrpFirstname, mrpLastname, mrpNumber));
		return fhirBundleBuilder;
		
	}
	
	org.hl7.fhir.dstu3.model.Patient getPatientResource(int demographicNo, String sex) {
		org.hl7.fhir.dstu3.model.Patient patient = new org.hl7.fhir.dstu3.model.Patient();
		
		
		Identifier id = patient.addIdentifier();
		id.setSystem("2.16.840.1.113883.3.239.23.269");
		CodeableConcept type = new CodeableConcept();
		type.addCoding().setSystem("http://hl7.org/fhir/v2/0203").setCode("MR");
		id.setType(type);
		id.setValue(""+demographicNo);
		if("F".equals(sex)) {
			patient.setGender(AdministrativeGender.FEMALE);
		}else if("M".equals(sex)) {
			patient.setGender(AdministrativeGender.MALE);
		}else {
			patient.setGender(AdministrativeGender.OTHER);
		}
	
		return patient;
	}

/////////
	org.hl7.fhir.dstu3.model.Practitioner getPractioner(String firstName, String lastName, String providerNo){
		org.hl7.fhir.dstu3.model.Practitioner provider = new org.hl7.fhir.dstu3.model.Practitioner();
		org.hl7.fhir.dstu3.model.HumanName name = new org.hl7.fhir.dstu3.model.HumanName();
		name.setFamily(lastName);
		name.addGiven(firstName);
		provider.getName().add(name);
		provider.addIdentifier().setSystem( "OSCAR" ).setValue( providerNo );
		return provider;
	}
	
/////////
	
	org.hl7.fhir.dstu3.model.Observation getWeight(double weight, Date date){
		org.hl7.fhir.dstu3.model.Observation observation = new org.hl7.fhir.dstu3.model.Observation();
		
		observation.setStatus(ObservationStatus.FINAL);
		 
		// Give the observation a code (what kind of observation is this)
		Coding coding = observation.getCode().addCoding();
		coding.setCode("29463-7").setSystem("http://loinc.org").setDisplay("Body Weight");
		 
		// Create a quantity datatype
		Quantity quantity = new Quantity();
		quantity.setValue(weight).setSystem("http://unitsofmeasure.org").setCode("kg");
		observation.setValue(quantity);
		org.hl7.fhir.dstu3.model.DateTimeType  dateTime = new org.hl7.fhir.dstu3.model.DateTimeType();
		dateTime.setValue(date);
		observation.setEffective(dateTime);
		return observation;
	}
	
	
	org.hl7.fhir.dstu3.model.Observation getCreatinine(double scr, Date date){
		
		
		org.hl7.fhir.dstu3.model.Observation observation = new org.hl7.fhir.dstu3.model.Observation();
		
		observation.setStatus(ObservationStatus.FINAL);
		 
		// Give the observation a code (what kind of observation is this)
		Coding coding = observation.getCode().addCoding();
		coding.setCode("14682-9").setSystem("http://loinc.org").setDisplay("Creatinine");
		 
		// Create a quantity datatype
		Quantity quantity = new Quantity();
		quantity.setValue(scr).setSystem("http://unitsofmeasure.org").setCode("kg");
		observation.setValue(quantity);
		org.hl7.fhir.dstu3.model.DateTimeType  dateTime = new org.hl7.fhir.dstu3.model.DateTimeType();
		dateTime.setValue(date);
		observation.setEffective(dateTime);
		return observation;
	}
	
	org.hl7.fhir.dstu3.model.Observation getBp(int systolic,int diastolic, Date date){
		org.hl7.fhir.dstu3.model.Observation observation = new org.hl7.fhir.dstu3.model.Observation();
		
		observation.setStatus(ObservationStatus.FINAL);
		ObservationComponentComponent oCC = observation.addComponent();
		Coding coding  = oCC.getCode().addCoding();
		coding.setCode("8480-6").setSystem("http://loinc.org").setDisplay("Systolic blood pressure");
		
		Quantity quantity = new Quantity();
		quantity.setValue(systolic).setSystem("http://unitsofmeasure.org").setCode("mm[Hg]").setUnit("mmHg");
		oCC.setValue(quantity);
		
		
		
		ObservationComponentComponent oCC2 = observation.addComponent();
		Coding coding2  = oCC.getCode().addCoding();
		coding2.setCode("8462-4").setSystem("http://loinc.org").setDisplay("Diastolic blood pressure");
	
    
		Quantity quantity2 = new Quantity();
		quantity2.setValue(diastolic).setSystem("http://unitsofmeasure.org").setCode("mm[Hg]").setUnit("mmHg");
		oCC2.setValue(quantity2);
		
		
	
        
		 
		 
		// Create a quantity datatype
		org.hl7.fhir.dstu3.model.DateTimeType  dateTime = new org.hl7.fhir.dstu3.model.DateTimeType();
		dateTime.setValue(date);
		observation.setEffective(dateTime);
		return observation;
	}
	
	org.hl7.fhir.dstu3.model.Medication getMed(String din){
		org.hl7.fhir.dstu3.model.Medication med = new org.hl7.fhir.dstu3.model.Medication();
		CodeableConcept dinCode = new CodeableConcept();
		Coding coding = new Coding();
		coding.setCode(din);
		coding.setSystem("http://hl7.org/fhir/NamingSystem/ca-hc-din");
		dinCode.getCoding().add(coding);
		med.setCode(dinCode);
		return med;
	}

}
