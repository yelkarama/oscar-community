package org.oscarehr.integration.fhir.builder;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import org.apache.log4j.Logger;
import org.junit.Test;
import org.oscarehr.common.model.Clinic;
import org.oscarehr.integration.fhir.api.TAPERmd;
import org.oscarehr.util.LoggedInInfo;
import org.oscarehr.util.MiscUtils;




public class FHIRTaperTest{
	Logger logger = MiscUtils.getLogger();
	
	private static Clinic clinic = getClinic();
	
	static public Clinic getClinic() {
		Clinic clinic = new Clinic();
		clinic.setId( 4321 );
		clinic.setClinicAddress("123 Clinic Street");
		clinic.setClinicCity("Vancouver");
		clinic.setClinicProvince("BC");
		clinic.setClinicPhone("778-567-3445");
		clinic.setClinicFax("778-343-3453");
		clinic.setClinicName( "Test Medical Clinic" );
		return clinic;
	}
	
	
	
	@Test
	public void createSendBundle() {
		logger.info("Starting to create Bundle");

		LoggedInInfo loggedInInfo = LoggedInInfo.getLoggedInInfoAsCurrentClassAndMethod();
		
		TAPERmd taperMD = new TAPERmd(); 
		int demographicNo = 233;
		List<String> dins = new ArrayList<String>();
		dins.add("00023432");
		dins.add("00023435");
		
		FhirBundleBuilder fhirBundleBuilder = taperMD.getFhirBundleBuilder(loggedInInfo, demographicNo, dins,
				103.3, new Date() , 120,80, new Date(),
				45.5, new Date(),
				"F",
				"Welby", "Doug","5555");
		
		logger.info("going out "+fhirBundleBuilder.getMessageJson());
		}
}
