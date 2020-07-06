package org.oscarehr.integration.ohcms;

import org.hl7.fhir.r4.model.Identifier;
import org.hl7.fhir.r4.model.Organization;
import org.hl7.fhir.r4.model.Parameters;
import org.hl7.fhir.r4.model.Patient;
import org.hl7.fhir.r4.model.Practitioner;
import org.hl7.fhir.r4.model.StringType;
import org.hl7.fhir.r4.model.Address.AddressType;
import org.hl7.fhir.r4.model.Address.AddressUse;

import java.sql.Date;
import java.util.UUID;

import org.hl7.fhir.r4.model.BaseResource;
import org.hl7.fhir.r4.model.CodeableConcept;
import org.hl7.fhir.r4.model.Coding;
import org.hl7.fhir.r4.model.HumanName;
import org.hl7.fhir.r4.model.IdType;
import org.hl7.fhir.r4.model.ContactPoint.ContactPointSystem;
import org.hl7.fhir.r4.model.ContactPoint.ContactPointUse;
import org.hl7.fhir.r4.model.HumanName.NameUse;
import org.oscarehr.common.Gender;
import org.oscarehr.common.dao.ClinicDAO;
import org.oscarehr.common.model.Clinic;
import org.oscarehr.common.model.Demographic;
import org.oscarehr.integration.OneIdGatewayData;
import org.oscarehr.integration.fhirR4.utils.EnumMappingUtil;
import org.oscarehr.util.LoggedInInfo;
import org.oscarehr.util.SpringUtils;

import ca.uhn.fhir.context.FhirContext;

public class FhirResources {
	
	ClinicDAO clinicDao = SpringUtils.getBean(ClinicDAO.class);
	private static FhirContext fhirContext = FhirContext.forR4();
	
	public Organization getOrganization(LoggedInInfo loggedInInfo) {
		Organization organization = new Organization();
		OneIdGatewayData oneIdGatewayData = loggedInInfo.getOneIdGatewayData();
		organization.getMeta().addProfile("http://ehealthontario.ca/fhir/StructureDefinition/ca-on-cms-profile-Organization|1.0.0");
		Identifier identifier = new Identifier();
		CodeableConcept codeableConcept = new CodeableConcept();
		codeableConcept.addCoding().setSystem("http://hl7.org/fhir/v2/0203").setCode("RRI");
		identifier.setType(codeableConcept);
		identifier.setSystem("https://fhir.infoway-inforoute.ca/NamingSystem/ca-on-provider-upi").setValue( oneIdGatewayData.getProviderUPI()); 
		organization.addIdentifier(identifier);
		//not sure what code is for this organization.addType().addCoding().setSystem("http://terminology.hl7.org/CodeSystem/organization-type");
		Clinic clinic = clinicDao.getClinic();
		
		organization.setName(clinic.getOrganizationName());
		
		organization.addAddress()
		.setUse(AddressUse.WORK)
		.addLine( clinic.getAddress2() )
		.setCity( clinic.getCity() )
		.setState( clinic.getProvince())
		.setPostalCode( clinic.getPostal() )
		.setType(AddressType.PHYSICAL);
		
		organization.addTelecom().setSystem( ContactPointSystem.PHONE ).setValue( clinic.getWorkPhone() );	
		organization.addTelecom().setSystem( ContactPointSystem.FAX ).setValue( clinic.getFax() );
		
		return organization;
	}
	
	public Practitioner getPractitioner(LoggedInInfo loggedInInfo) {
		Practitioner practitioner = new Practitioner();
		practitioner.getMeta().addProfile("http://ehealthontario.ca/fhir/StructureDefinition/ca-on-cms-profile-Practitioner|1.0.0");
		OneIdGatewayData oneIdGatewayData = loggedInInfo.getOneIdGatewayData();
		practitioner.addIdentifier().setSystem("https://fhir.infoway-inforoute.ca/NamingSystem/ca-on-license-physician").setValue(loggedInInfo.getLoggedInProvider().getPractitionerNo());
		practitioner.addName().setFamily(loggedInInfo.getLoggedInProvider().getLastName()).addGiven(loggedInInfo.getLoggedInProvider().getFirstName());
		//TODO need to set qualification.
		return practitioner;
	}
	
	public Patient getPatient(LoggedInInfo loggedInInfo,Demographic demographic) {
		Patient patient = new Patient();
		patient.getMeta().addProfile("http://ehealthontario.ca/fhir/StructureDefinition/ca-on-cms-profile-Patient|1.0.0");
		patient.addIdentifier().setSystem( "https://fhir.infoway-inforoute.ca/NamingSystem/ca-on-patient-hcn").setValue( demographic.getHin() );
		patient.setId( demographic.getDemographicNo() + "" );
		patient.setBirthDate( new Date( demographic.getBirthDay().getTimeInMillis() ) );
		
		Gender gender = Gender.valueOf( demographic.getSex().toUpperCase() );
		patient.setGender( EnumMappingUtil.genderToAdministrativeGender( gender ) );
		
		patient.addAddress()
		.setUse( AddressUse.HOME )				
		.addLine( demographic.getAddress() )
		.setCity( demographic.getCity() )
		.setState( demographic.getProvince() )
		.setPostalCode( demographic.getPostal() );
		
		HumanName humanName = new HumanName();
		
		//mandatory
		humanName.setFamily( demographic.getLastName() );
		humanName.addGiven( demographic.getFirstName() );
		
		//optional
		
		humanName.addPrefix( demographic.getTitle() );
		humanName.setUse( NameUse.OFFICIAL );
		humanName.getExtensionFirstRep().setUrl( "http://hl7.org/fhir/StructureDefinition/iso21090-EN-qualifier" );
		
		patient.addName( humanName );
		
		CodeableConcept cc = new CodeableConcept();
		Coding c = cc.addCoding();
		c.setSystem("https://www.hl7.org/fhir/valueset-languages.html");
		c.setCode("en-US");
		patient.addCommunication().setLanguage(cc);
		
		patient.addTelecom().setUse( ContactPointUse.HOME )
		.setSystem( ContactPointSystem.PHONE )
		.setValue( demographic.getPhone() );

		if(demographic.getPhone2() != null && !demographic.getPhone2().trim().isEmpty()) {
			patient.addTelecom().setUse( ContactPointUse.WORK )
			.setSystem( ContactPointSystem.PHONE )
			.setValue( demographic.getPhone2() );
		}
		
		return patient;
	}
	
	public Parameters getLanguageParameter(LoggedInInfo loggedInInfo, String id, String lang) {
		org.hl7.fhir.r4.model.Parameters parameters = new org.hl7.fhir.r4.model.Parameters();
		parameters.setId(id );
		parameters.getMeta().addProfile("http://ehealthontario.ca/fhir/StructureDefinition/ca-on-cms-profile-Parameters|1.0.0");
		Coding coding = new Coding();
		coding.setCode(lang);
		coding.setSystem("urn:ietf:bcp:47");
		parameters.addParameter().setName("appLanguage").setValue(coding);
		return parameters;
	}
	
	public Parameters getConsentTargetParameter(LoggedInInfo loggedInfo,String id,String param) {
		org.hl7.fhir.r4.model.Parameters parameters = new org.hl7.fhir.r4.model.Parameters();
		parameters.setId(id);
		parameters.getMeta().addProfile("http://ehealthontario.ca/fhir/StructureDefinition/ca-on-cms-profile-Parameters|1.0.0");
		StringType stringType = new StringType();
		stringType.setValue(param);
		parameters.addParameter().setName("consentTarget").setValue(stringType);
		return parameters;
	}
	
	public Parameters getContextSessionIdParameter(LoggedInInfo loggedInfo,String id,String param) {
		org.hl7.fhir.r4.model.Parameters parameters = new org.hl7.fhir.r4.model.Parameters();
		parameters.setId(id);
		parameters.getMeta().addProfile("http://ehealthontario.ca/fhir/StructureDefinition/ca-on-cms-profile-Parameters|1.0.0");
		IdType stringType = new IdType();
		stringType.setValue(param);
		parameters.addParameter().setName("contextSessionId").setValue(stringType);
		return parameters;	
	}
	
	public String getString(BaseResource baseResource) {
		return fhirContext.newJsonParser().setPrettyPrint(true).encodeResourceToString( baseResource );
	}

}
