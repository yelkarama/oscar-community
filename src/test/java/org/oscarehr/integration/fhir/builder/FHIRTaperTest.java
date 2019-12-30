package org.oscarehr.integration.fhir.builder;
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
