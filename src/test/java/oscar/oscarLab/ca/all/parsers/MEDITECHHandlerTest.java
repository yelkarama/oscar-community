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

package oscar.oscarLab.ca.all.parsers;

import java.io.IOException;
import java.io.InputStream;
import java.io.StringWriter;
import java.net.URL;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.Enumeration;
import java.util.List;
import java.util.zip.ZipEntry;
import java.util.zip.ZipFile;

import org.apache.commons.io.IOUtils;
import org.apache.log4j.Logger;
import org.junit.AfterClass;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.Parameterized;

import ca.uhn.hl7v2.HL7Exception;
import junit.framework.Assert;



@RunWith(Parameterized.class)
public class MEDITECHHandlerTest {
	
	private static Logger logger = Logger.getLogger(MEDITECHHandlerTest.class);
	private static MEDITECHHandler handler;
	private static ZipFile zipFile;
	private static int TEST_COUNT = 0;
		
	@Parameterized.Parameters
	public static Collection<String[]> hl7BodyArray() {
		
		logger.info( "Creating MEDITECHHandlerTest test parameters" );
	
		URL url = Thread.currentThread().getContextClassLoader().getResource("MEDITECH_test_data.zip");
		
		try {
			zipFile = new ZipFile(url.getPath());
        } catch (IOException e) {
        	 logger.error("Test Failed ", e);
        }
		
		Enumeration<? extends ZipEntry> enumeration = zipFile.entries();		
		StringWriter writer = null;
		InputStream is = null;
		List<String[]> hl7BodyArray = new ArrayList<String[]>();
		String hl7Body = "";

		while( enumeration.hasMoreElements() ) {
			
			ZipEntry zipEntry = enumeration.nextElement();
						
			if(zipEntry.getName().endsWith(".txt")) {
				
				logger.debug( zipEntry.getName() );
				
				writer = new StringWriter();
				
				try {					
					is = zipFile.getInputStream( zipEntry );					
					IOUtils.copy(is, writer, "UTF-8");														 
	            } catch (IOException e) {
	            	if( zipFile != null ) {
	            		try {
	                        zipFile.close();
	                        zipFile = null;
                        } catch (IOException e1) {
                        	 logger.error("Test Failed ", e);
                        }	            		
	            	}
	            	logger.error("Test Failed ", e);
	            }finally {
	            	if( is != null ) {
	            		try {
	    	                is.close();
	    	                is = null;
	                    } catch (IOException e) {
	                    	 logger.error("Test Failed ", e);
	                    }
	            	}	            	
	            }
				
				hl7Body = writer.toString();
				hl7BodyArray.add(new String[]{hl7Body});
			}
		}		
		return hl7BodyArray;
	}
	
	@AfterClass
	public static void close() {
		if( zipFile != null) {
			try {
	            zipFile.close();
	            zipFile = null;
            } catch (IOException e) {
	            logger.error("Test Failed ", e);
            }			
		}
	}
	
	public MEDITECHHandlerTest(String hl7Body) {

		handler = new MEDITECHHandler();
		try {
	        handler.init(hl7Body);
        } catch (HL7Exception e) {
	        logger.error("Test Failed ", e);
        }
	}

	@Test
	public void runTests() {
		
		TEST_COUNT += 1;

		logger.info("#------------>>  Testing MEDITECHHandler Parser for file: (" + TEST_COUNT + ")");
		testGetXML();
		testGetSpecimenSource();
		testGetSpecimenDescription();
		testGetDiscipline();
		testIsReportData();
		testIsUnstructured();
		testGetSendingApplication();
		testGetMsgType();
		testGetMsgDate();
		testGetMsgPriority();
		testGetOBRCount();
		testGetOBXCount();
		testGetOBRName();
		testGetTimeStamp();
		testIsOBXAbnormal();
		testGetOBXAbnormalFlag();
		testGetObservationHeader();
		testGetOBXIdentifier();
		testGetOBXValueType();
		testGetOBXName();
		testGetOBXResult();
		testGetOBXReferenceRange();
		testGetOBXUnits();
		testGetOBXResultStatus();
		testGetHeaders();
		testGetOBRCommentCount();
		testGetOBRComment();
		testGetOBXCommentCount();
		testGetOBXComment();
		testGetPatientName();
		testGetFirstName();
		testGetLastName();
		testGetDOB();
		testGetAge();
		testGetSex();
		testGetHealthNum();
		testGetHomePhone();
		testGetWorkPhone();
		testGetPatientLocation();
		testGetServiceDate();
		testGetRequestDate();
		testGetOrderStatus();
		testGetOBXFinalResultCount();
		testGetClientRef();
		testGetAccessionNum();
		testGetOtherHealthcareProviders();
		testGetAttendingPhysician();
		testGetAdmittingPhysician();
		testGetDocName();
		testGetCCDocs();
		testGetProviderMap();
		testGetDocNums();
		testAudit();
		testGetFillerOrderNumber();
		testGetEncounterId();
		testGetRadiologistInfo();
		testGetNteForOBX();
		testGetNteForPID();

	}
	
	public void testGetSpecimenSource() {
		logger.info("testGetSpecimenSource() " + handler.getSpecimenSource(0) );
	}
	
	public void testGetSpecimenDescription() {
		logger.info("testGetSpecimenDescription() " + handler.getSpecimenDescription(0) );
	}
	
	public void testGetDiscipline() {
		logger.info("testGetDiscipline() " + handler.getDiscipline() );
	}
	
	public void testIsReportData() {
		logger.info("testIsReportData() " + handler.isReportData() );
	}
	
	public void testIsUnstructured() {
		logger.info("testIsUnstructured() " + handler.isUnstructured() );
	}
	
	public void testGetSendingApplication() {
		logger.info("testGetSendingApplication() " + handler.getSendingApplication());
	}
	
	public void testGetXML() {
		logger.info("testGetXML() " + handler.getXML());
	}
	
	public void testGetMsgType() {
		logger.info("testGetMsgType() " + handler.getMsgType());
		// assertEquals("MEDITECH", handler.getMsgType() );
	}

	
	public void testGetMsgDate() {
		logger.info("testGetMsgDate() " + handler.getMsgDate());

	}

	
	public void testGetMsgPriority() {
		logger.info("testGetMsgPriority() " + handler.getMsgPriority());
	}

	
	public void testGetOBRCount() {
		logger.info("testGetOBRCount() " + handler.getOBRCount());
		
	}

	
	public void testGetOBXCount() {

		int obrCount = handler.getOBRCount();
		int[] count = new int[obrCount];
		for( int i = 0; i < obrCount; i++ ) {
			count[i] = handler.getOBXCount(i);
		}

		logger.info("testGetOBXCount() " + Arrays.toString(count));
	}
	
	public int testGetOBXCount( int obrCount ) {
		int count = 0;
	
		for (int i = 0; i < obrCount; i++) {			
			count = handler.getOBXCount(i);
		}
		return count;
	}

	
	public void testGetOBRName() {
		StringBuilder stringBuilder = new StringBuilder("testGetOBRName() ");
		int obrCount = handler.getOBRCount();
		for( int i = 0; i < obrCount; i++ ) {
			stringBuilder.append( " OBR[" + i + "] " + handler.getOBRName(i) );
		}
		logger.info( stringBuilder.toString() );
	}

	
	public void testGetTimeStamp() {
		logger.info( "testGetTimeStamp() " + handler.getTimeStamp(0, 0) );
		
	}

	/**
	 * OBR count is always 1 in these tests. Therefore the OBR row index will
	 * always be zero.
	 */
	public void testIsOBXAbnormal() {

		boolean result = Boolean.FALSE;
		int obxCount = testGetOBXCount( handler.getOBRCount() );
		for( int i = 0; i < obxCount; i++ ) {
			 if( handler.isOBXAbnormal(0, i) ) {
				 result = Boolean.TRUE;
				 break;
			 }
		}
		
		logger.info("testIsOBXAbnormal() " + result );
	}

	
	public void testGetOBXAbnormalFlag() {

		StringBuilder stringBuilder = new StringBuilder("testGetOBXAbnormalFlag() ");
		int obxCount = testGetOBXCount( handler.getOBRCount() );
		for( int i = 0; i < obxCount; i++ ) {
			stringBuilder.append( " OBX["+ i + "] " + handler.getOBXAbnormalFlag(0, i) );
		}
		
		logger.info( stringBuilder.toString() );
	}

	
	public void testGetObservationHeader() {
	
		StringBuilder stringBuilder = new StringBuilder("testGetObservationHeader()");

		int obrCount = handler.getOBRCount();
		for(int i = 0; i < obrCount; i++) {
			stringBuilder.append( " OBR["+ i + "]"); 
		
			for(int j = 0; j < handler.getOBXCount(obrCount); j++) {
				stringBuilder.append( " OBX["+ j + "] " + handler.getObservationHeader(i, j) ); 
			}
		}
		logger.info( stringBuilder.toString() );
	}

	
	public void testGetOBXIdentifier() {
		
		StringBuilder stringBuilder = new StringBuilder("testGetOBXIdentifier() ");
		int obxCount = 0;

		
		for(int i = 0; i < handler.getOBRCount(); i++) {
			
			stringBuilder.append(" OBR[" + i + "]");
			obxCount = handler.getOBXCount(i);
		
			for(int j = 0; j < obxCount; j++) {

				stringBuilder.append( " OBX["+ j + "] " + handler.getOBXIdentifier( i, j ) );  
				
			}
		}

		logger.info(stringBuilder.toString());
	}

	
	public void testGetOBXValueType() {
		
		StringBuilder stringBuilder = new StringBuilder("testGetOBXValueType() ");
		int obxCount = 0;

		for(int i = 0; i < handler.getOBRCount(); i++) {
			
			stringBuilder.append(" OBR[" + i + "] {");
			obxCount = handler.getOBXCount(i);
		
			for(int j = 0; j < obxCount; j++) {

				stringBuilder.append( " OBX["+ j + "] " + handler.getOBXValueType( i, j ) );  
				
			}
		}

		logger.info(stringBuilder.toString());
	}

	
	public void testGetOBXName() {

		StringBuilder stringBuilder = new StringBuilder("testGetOBXName() ");
		
		int obxCount = 0;

		for(int i = 0; i < handler.getOBRCount(); i++) {
			
			stringBuilder.append(" OBR[" + i + "] {");
			obxCount = handler.getOBXCount(i);
		
			for(int j = 0; j < obxCount; j++) {

				stringBuilder.append( " OBX["+ j + "] " + handler.getOBXName( i, j ) );  
				
			}
		}

		logger.info(stringBuilder.toString());
	}

	
	public void testGetOBXResult() {

		StringBuilder stringBuilder = new StringBuilder("testGetOBXResult() \n");
		
		int obrCount = handler.getOBRCount();
		int obxCount = 0;
		
		for(int i = 0; i < obrCount; i++) {
			
			stringBuilder.append("OBR[" + i + "]");
			obxCount = handler.getOBXCount(i);
		
			for(int j = 0; j < obxCount; j++) {
				
				if( j == 0 ) {
					stringBuilder.append("\n");
				}
				
				stringBuilder.append( " OBX["+ j + "] " + handler.getOBXResult( i, j ) + "\n"); 
				
			}
		}
		logger.info(stringBuilder.toString()); 
		
	}

	
	public void testGetOBXReferenceRange() {
		
		StringBuilder stringBuilder = new StringBuilder("testGetOBXReferenceRange() ");
		int obxCount = testGetOBXCount( handler.getOBRCount() );
		for(int i = 0; i < obxCount; i++) {
			stringBuilder.append( " OBX["+ i + "] " + handler.getOBXReferenceRange( 0, i ) ); 
		}

		logger.info(stringBuilder.toString());
	}

	
	public void testGetOBXUnits() {
		
		StringBuilder stringBuilder = new StringBuilder("testGetOBXUnits() ");
		int obxCount = testGetOBXCount( handler.getOBRCount() );
		for(int i = 0; i < obxCount; i++) {
			stringBuilder.append( " OBX["+ i + "] " + handler.getOBXUnits( 0, i ) ); 
		}

		logger.info(stringBuilder.toString());
	}

	
	public void testGetOBXResultStatus() {
		
		StringBuilder stringBuilder = new StringBuilder("testGetOBXResultStatus() ");
		int obxCount = testGetOBXCount( handler.getOBRCount() );
		for(int i = 0; i < obxCount; i++) {
			stringBuilder.append( " OBX["+ i + "] " + handler.getOBXResultStatus( 0, i ) ); 
		}

		logger.info(stringBuilder.toString());
	}

	
	public void testGetHeaders() {
		logger.info("testGetHeaders() " + handler.getHeaders());
		
	}

	
	public void testGetOBRCommentCount() {
		logger.info("testGetOBRCommentCount() " + handler.getOBRCommentCount( 0 ));
		
	}

	
	public void testGetOBRComment() {
		logger.info("testGetOBRComment() " + handler.getOBRComment( 0, handler.getOBRCommentCount( 0 )  ));
		
	}

	
	public void testGetOBXCommentCount() {
		logger.info("testGetOBXCommentCount() " + testGetOBXCommentCount( handler.getOBRCount(), testGetOBXCount( handler.getOBRCount() ) ) );
	}
	
	public int testGetOBXCommentCount(int obxIndex) {
		return handler.getOBXCommentCount( 0, obxIndex );
	}
	
	public List<Integer> testGetOBXCommentCount(int obrCount, int obxCount) {		
		ArrayList<Integer> countArray = new ArrayList<Integer>();
		for(int i = 0; i < obrCount; i++) {
			for(int j = 0; j < obxCount; j++) {
				countArray.add( handler.getOBXCommentCount( i, j ) ); 
			}
		}
		return  countArray;
	}

	
	public void testGetOBXComment() {

		StringBuilder stringBuilder = new StringBuilder("testGetOBXComment()  \n");
		int obxCount = testGetOBXCount( handler.getOBRCount() );
		int commentCount;
		for(int i = 0; i < obxCount; i++) {
			commentCount = testGetOBXCommentCount(i);			
			if( commentCount > 0 ) {
				for(int j = 0; j < commentCount; j++) {
					stringBuilder.append(handler.getOBXComment( 0, i, j ) + "\n");
				}			
			}
		}
		
		logger.info(stringBuilder.toString());

	}

	
	public void testGetPatientName() {
		logger.info("testGetPatientName() " + handler.getPatientName());
		
	}

	
	public void testGetFirstName() {
		logger.info("testGetFirstName() " + handler.getFirstName());
		
	}

	
	public void testGetLastName() {
		logger.info("testGetLastName() " + handler.getLastName());
		
	}

	
	public void testGetDOB() {
		logger.info("testGetDOB() " + handler.getDOB());
		
	}

	
	public void testGetAge() {
		logger.info("testGetAge() " + handler.getAge());
		
	}

	
	public void testGetSex() {
		logger.info("testGetSex() " + handler.getSex());
		
	}

	
	public void testGetHealthNum() {
		logger.info("testGetHealthNum() " + handler.getHealthNum());
		
	}

	
	public void testGetHomePhone() {
		logger.info("testGetHomePhone() " + handler.getHomePhone());
		
	}

	
	public void testGetWorkPhone() {
		logger.info("testGetWorkPhone() " + handler.getWorkPhone());
		
	}

	
	public void testGetPatientLocation() {
		logger.info("testGetPatientLocation() " + handler.getPatientLocation());
		
	}

	
	public void testGetServiceDate() {
		logger.info("testGetServiceDate() " + handler.getServiceDate());
		
	}

	
	public void testGetRequestDate() {
		logger.info("testGetRequestDate() " + handler.getRequestDate(0));
		
	}

	
	public void testGetOrderStatus() {
		logger.info("testGetOrderStatus() " + handler.getOrderStatus());
		
	}

	
	public void testGetOBXFinalResultCount() {
		logger.info("testGetOBXFinalResultCount() " + handler.getOBXFinalResultCount());
		
	}

	
	public void testGetClientRef() {
		logger.info("testGetClientRef() " + handler.getClientRef());
		
	}

	
	public void testGetAccessionNum() {
		logger.info("testGetAccessionNum() " + handler.getAccessionNum());
		
	}
	
	public void testGetOtherHealthcareProviders() {
		logger.info("testGetOtherHealthcareProviders() " + handler.getOtherHealthcareProviders() );
	}
	
	public void testGetAttendingPhysician() {
		logger.info("testGetAttendingPhysician() " + handler.getAttendingPhysician() );
	}
	
	public void testGetAdmittingPhysician() {
		logger.info("testGetAdmittingPhysician() " + handler.getAdmittingPhysician());
	}

	public void testGetDocName() {
		logger.info("testGetDocName() " + handler.getDocName());
		
	}

	
	public void testGetCCDocs() {
		logger.info("testGetCCDocs() " + handler.getCCDocs());
		
	}

	public void testGetProviderMap() {
		logger.info("testGetProviderMap() " + handler.getProviderMap() );
	}
	
	public void testGetDocNums() {
		logger.info("testGetDocNums() " + handler.getDocNums());
		
	}

	
	public void testAudit() {
		logger.info("testAudit() " + handler.audit());
		Assert.assertEquals("success", handler.audit());
	}

	
	public void testGetFillerOrderNumber() {
		logger.info("testGetFillerOrderNumber() " + handler.getFillerOrderNumber());
		
	}

	
	public void testGetEncounterId() {
		logger.info("testGetEncounterId() " + handler.getEncounterId());
		
	}

	
	public void testGetRadiologistInfo() {
		logger.info("testGetRadiologistInfo() " + handler.getRadiologistInfo());
		
	}

	
	public void testGetNteForOBX() {
		
		StringBuilder stringBuilder = new StringBuilder("testGetNteForOBX() \n");
		int obxCount = testGetOBXCount( handler.getOBRCount() );
		for(int i = 0; i < obxCount; i++) {
			stringBuilder.append( " OBX["+ i + "] " + handler.getNteForOBX( 0, i ) ); 
		}

		logger.info(stringBuilder.toString());
	}

	
	public void testGetNteForPID() {
		logger.info("testGetNteForPID() " + handler.getNteForPID());
		
	}
	
	// @Test
	public void testFormatDateTimeZone() {
		logger.info("testFormatDateTimeZone(20151209081103-0500) to String: " + MEDITECHHandler.formatDateTime( "20151209081103-0500" ) );
	}
	
	// @Test
	public void testFormatDateWithTime() {
		logger.info("testFormatDateWithTime(20151209081103) to String: " + MEDITECHHandler.formatDateTime( "20151209081103" ) );
	}
	
	// @Test
	public void testFormatDate() {
		logger.info("testFormatDate(20151209) to String: " + MEDITECHHandler.formatDateTime( "20151209" ) );
	}
	
	//@Test
	public void testFormatDateTimeToDate() {
		logger.info("testFormatDateTimeToDate(20151209081103-0500) to String: " + MEDITECHHandler.formatDateTimeToDate( "20151209081103-0500" ) );		
	}
	

}
