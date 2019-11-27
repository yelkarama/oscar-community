package org.oscarehr.integration.fhir.api;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.zip.GZIPInputStream;

import javax.net.ssl.TrustManager;

import org.apache.commons.io.IOUtils;
import org.apache.commons.net.util.TrustManagerUtils;
import org.apache.cxf.configuration.jsse.TLSClientParameters;
import org.apache.cxf.jaxrs.client.WebClient;
import org.apache.cxf.jaxrs.provider.json.JSONProvider;
import org.apache.cxf.transport.http.HTTPConduit;
import org.apache.log4j.Logger;
import org.hl7.fhir.dstu3.model.CodeableConcept;
import org.hl7.fhir.dstu3.model.Coding;
import org.hl7.fhir.dstu3.model.Enumerations.AdministrativeGender;

import org.hl7.fhir.dstu3.model.Identifier;
import org.hl7.fhir.dstu3.model.Quantity;
import org.hl7.fhir.dstu3.model.Observation.ObservationComponentComponent;
import org.hl7.fhir.dstu3.model.Observation.ObservationStatus;
import org.oscarehr.common.model.Demographic;
import org.oscarehr.common.model.Drug;
import org.oscarehr.common.model.Measurement;
import org.oscarehr.integration.fhir.builder.FhirBundleBuilder;

import org.oscarehr.integration.fhir.manager.OscarFhirConfigurationManager;
import org.oscarehr.integration.fhir.resources.Settings;
import org.oscarehr.integration.fhir.resources.constants.FhirDestination;
import org.oscarehr.managers.DemographicManager;
import org.oscarehr.managers.MeasurementManager;
import org.oscarehr.managers.PrescriptionManager;
import org.oscarehr.util.LoggedInInfo;
import org.oscarehr.util.MiscUtils;
import org.oscarehr.util.SpringUtils;

import com.auth0.jwt.JWT;
import com.auth0.jwt.algorithms.Algorithm;
import com.auth0.jwt.exceptions.JWTCreationException;

import oscar.OscarProperties;
 


public class TAPERmd {
	
	private static Settings SETTINGS = new Settings( FhirDestination.TAPERMD, null );
	private static final Logger logger = MiscUtils.getLogger();
	
	
	public String callService(LoggedInInfo loggedInInfo, int demographicNo) {
		//Get needed info
		PrescriptionManager prescriptionManager = SpringUtils.getBean(PrescriptionManager.class);
		MeasurementManager measurementManager = SpringUtils.getBean(MeasurementManager.class);
		DemographicManager demographicManager = SpringUtils.getBean(DemographicManager.class);
		List<String> dins = new ArrayList<String>();
		Double weight = null;
		Date weightDate = null;
		Integer systolic = null;
		Integer diastolic = null;
		Date bpDate = null;
		Double scr = null;
		Date scrDate = null;
		String patientSex = null;
		String mrpLastname = null;
		String mrpFirstname = null;
		String mrpNumber = null;
		
		List<Drug> drugList = prescriptionManager.getLongTermDrugs(loggedInInfo, demographicNo);
		for(Drug drug: drugList) {
			if(drug.getRegionalIdentifier() != null && !dins.contains(drug.getRegionalIdentifier())) {
				dins.add(drug.getRegionalIdentifier());
			}
		}
		
		List<String> weightMeasurement = new ArrayList<String>();
		weightMeasurement.add("WT");
		List<Measurement> weightMeasurements = measurementManager.getMeasurementByType(loggedInInfo, demographicNo,weightMeasurement);
		
		List<String> bpMeasurement = new ArrayList<String>();
		bpMeasurement.add("BP");
		List<Measurement> bpMeasurements = measurementManager.getMeasurementByType(loggedInInfo, demographicNo,weightMeasurement);
		
		List<String> sCrMeasurement = new ArrayList<String>();
		sCrMeasurement.add("SCR");
		List<Measurement> sCrMeasurements = measurementManager.getMeasurementByType(loggedInInfo, demographicNo,sCrMeasurement);
		
		if(weightMeasurements.size() > 0) {
			Measurement wMeasurement = weightMeasurements.get(0);
			weightDate = wMeasurement.getDateObserved();
			weight = Double.parseDouble(wMeasurement.getDataField());
		}
		
		if(sCrMeasurements.size() > 0) {
			Measurement measurement = sCrMeasurements.get(0);
			scrDate = measurement.getDateObserved();
			scr = Double.parseDouble(measurement.getDataField());
		}
		
		if(bpMeasurements.size() > 0) {
			Measurement measurement = bpMeasurements.get(0);
			bpDate = measurement.getDateObserved();
			String value = measurement.getDataField();
			String[] valueSplit = value.split("/");
			systolic = Integer.parseInt(valueSplit[0]);
			diastolic = Integer.parseInt(valueSplit[1]);
			
		}
		
		Demographic demographic = demographicManager.getDemographic(loggedInInfo, demographicNo);
		if(demographic != null) {
			patientSex = demographic.getSex();
			mrpNumber = "9999";demographic.getProviderNo();
			mrpLastname  = "test";  
			mrpFirstname = "test";
		}
		
		logger.debug("loggedInInfo "+loggedInInfo+" demographicNo "+demographicNo+" dins "+dins+" weight "+weight+" weightDate "+ weightDate+" systolic "+ systolic+" diastolic "+ diastolic +"   bpDate "+ bpDate+ " scr "+scr+" scrDate "+  scrDate+ " patientSex "+patientSex +" mrpLastname "+mrpLastname+" mrpFirstname "+  mrpFirstname+"  mrpNumber "+mrpNumber);
		//create fhirBundle 
		
		FhirBundleBuilder fhirBundleBuilder = getFhirBundleBuilder(loggedInInfo,
				demographicNo,
				dins,
				weight,  
				weightDate,  
				systolic, 
				diastolic,  
				bpDate,
				scr,  
				scrDate,
				patientSex,
				mrpLastname,  
				mrpFirstname, 
				mrpNumber); 
		
		
		String messageJson = fhirBundleBuilder.getMessageJson();
		logger.debug("messageJson:"+messageJson);
		//Send to Taper REST service with bearer token
		
		String bearerToken = createBearerToken(""+demographicNo,"patientName",loggedInInfo.getLoggedInProvider().getFormattedName(),loggedInInfo.getLoggedInProviderNo());
		logger.debug("bearerToken:"+bearerToken);
		
		String url = "https://demo.tapermd.org/functions/oscar.php";
		
		javax.ws.rs.core.Response resp = callPHRWebClient(url,messageJson, bearerToken);
		String response = getResponse(resp);
		//Return URL to launch
		String urlToLaunch = null;
		try {
			
			org.codehaus.jettison.json.JSONObject responseObject = new org.codehaus.jettison.json.JSONObject(response);
			urlToLaunch = responseObject.getString("url");
		}catch(Exception e) {
			logger.error("url error" +response,e);
		}
		return urlToLaunch;
	}
	
	String getResponse(javax.ws.rs.core.Response resp) {
		String response = null;
		try {
			InputStream in = (InputStream) resp.getEntity();
			GZIPInputStream gzip = new GZIPInputStream(in);
			BufferedReader bufferedReader = new BufferedReader(new InputStreamReader(gzip));
			response = IOUtils.toString(bufferedReader);
			logger.debug("response "+response);
			bufferedReader.close();
		}catch(Exception e) {
			logger.error("Error reading response from taper ",e);
		}
		return response;
	}
	
	/*
	 "sub": "1001",
  	 "patient_name":"Test, Billy",
  	 "provider_name": "Johnson,Ron",
  	 "provider_id":"44444", 
	 */
	String createBearerToken(String subject,String patientName, String providerName, String providerId) {
		String token = null;
		try {
		    Algorithm algorithm = Algorithm.HMAC256("secret");
		    token = JWT.create()
		        .withIssuer("auth0")
		        .withClaim("patient_name", patientName)
		        .withSubject(subject)
		        .withClaim("provider_name", providerName) 
		        .withClaim("provider_id", providerId) 
		        .sign(algorithm);
		} catch (JWTCreationException exception){
		    //Invalid Signing configuration / Couldn't convert Claims.
		}
		return token;
	}
	
	
	public FhirBundleBuilder getFhirBundleBuilder(LoggedInInfo loggedInInfo,int demographicNo,List<String> dins,
												Double weight, Date weightDate, Integer systolic,Integer diastolic, Date bpDate,
												Double scr, Date scrDate,
												String patientSex,
												String mrpLastname, String mrpFirstname,String mrpNumber) {
		logger.debug("trying to build bundle");
		OscarFhirConfigurationManager configurationManager = new OscarFhirConfigurationManager( loggedInInfo, SETTINGS );
		FhirBundleBuilder fhirBundleBuilder = new FhirBundleBuilder( configurationManager );
		for(String din:dins) {
			fhirBundleBuilder.addResource(getMed(din));
		}
		
		if(weightDate != null) {
			fhirBundleBuilder.addResource(getWeight(weight, weightDate));
		}
		if(bpDate != null) {
			fhirBundleBuilder.addResource(getBp(systolic, diastolic, bpDate));
		}
		if(scrDate != null) {
			fhirBundleBuilder.addResource(getCreatinine(scr, scrDate));
		}
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
	
	
	private javax.ws.rs.core.Response callPHRWebClient(String url,String object,String bearerToken) {
		List<Object> providers = new ArrayList<Object>();
		JSONProvider jsonProvider = new JSONProvider();
		jsonProvider.setDropRootElement(true);
	    providers.add(jsonProvider);
		WebClient webclient = WebClient.create(url, providers);
		HTTPConduit conduit = WebClient.getConfig(webclient).getHttpConduit();

	    TLSClientParameters params = conduit.getTlsClientParameters();

	    if (params == null) {
	        params = new TLSClientParameters();
	        conduit.setTlsClientParameters(params);
	    }
	    if(OscarProperties.getInstance().isPropertyActive("TAPER_TEST_CONNECTION")){
	    		params.setTrustManagers(new TrustManager[] { TrustManagerUtils.getAcceptAllTrustManager() });
	    		params.setDisableCNCheck(true);
	    }
	    javax.ws.rs.core.Response reps = webclient.accept("application/json, text/plain, */*")
			 .acceptEncoding("gzip, deflate")
			 .header("Authorization", "Bearer "+bearerToken)
			 .type("application/json;charset=utf-8")
			 .post(object);
	   
	    return reps;
	}

	

}
