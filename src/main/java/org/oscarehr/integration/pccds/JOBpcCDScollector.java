/**
 * Copyright (c) 2001-2017. Department of Family Medicine, McMaster University. All Rights Reserved.
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

package org.oscarehr.integration.pccds;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;
import java.sql.Timestamp;
import java.util.List;
import org.oscarehr.common.dao.DemographicToExportPCDS_Dao;
import org.oscarehr.common.jobs.OscarRunnable;
import org.oscarehr.common.model.Provider;
import org.oscarehr.common.model.Security;
import org.oscarehr.integration.pccds.MiscUtils;
import org.oscarehr.util.SpringUtils;
import oscar.OscarProperties;

public class JOBpcCDScollector implements OscarRunnable {

	@Override
	public synchronized void run() {
		String secString = sec.toString();
		String provString = prov.getFormattedName();
		

		if (DEBUG) {
			MiscUtils.getLogger().info("TESTING (logger) JOBpcCDScollector:  \nSECURITY: " + secString + "\nPROVIDER: " + provString);
		}
		
		// getInstructions from PCDS_Manager
		OscarProperties oscarProperties = OscarProperties.getInstance();
		String pcds_manager_url = oscarProperties.getProperty("PCDS_MANAGER_URL");
		String recStartProcessing =  oscarProperties.getProperty("PCDS_START_URL");
		String recDoneProcessing = oscarProperties.getProperty("PCDS_END_URL");
		
		String cleanResponse = sendHttpMsg(pcds_manager_url);
		
			
		if (DEBUG) {
			MiscUtils.getLogger().info("\tDEBUG: CommandCOM response:  " + cleanResponse);
		}
		
		if (cleanResponse.compareToIgnoreCase("nop")==0){
			MiscUtils.getLogger().info("Recieved a NOP : No processing will be done.");
		}else {


			if (cleanResponse.compareToIgnoreCase(PCDS_StaticInfo.FULL)==0){
				MiscUtils.getLogger().info("Processing FULL export.");
				
				String respStart = sendHttpMsg(recStartProcessing);
				DemographicExport demoExp = new DemographicExport(sec,prov);
				
				
				if (USEDAO){
					DemographicToExportPCDS_Dao dao = SpringUtils.getBean(DemographicToExportPCDS_Dao.class);
					long pageValue = dao.getPageValue();
					long totalDemo = dao.getTotalActive();
					int num_pages = (int)(totalDemo / pageValue);

					
					for (int i = 0; i <= num_pages; i++){
						if (DEBUG){
							MiscUtils.getLogger().info("EXPORT ALL ACTIVE:  totalDemo=" + totalDemo + ", pages=" + num_pages + ", current page= " + i);
						}
						
						if (demoExp.exportData(dao.getBulk(i))){
							MiscUtils.getLogger().info("####### PCDS SUCCESS for page : " + i + " reported for bulk export using DAO.");
						}else {
							MiscUtils.getLogger().info("####### PCDS Error in page : " + i + " reported for bulk export using DAO.");
							//MiscUtils.getLogger().info("####### END OF PROCESSING : PROCESSING NOT COMPLETE");
						}
						
						if (i == num_pages){
							String respStop = sendHttpMsg(recDoneProcessing);
							MiscUtils.getLogger().info("####### END OF PROCESSING :" + respStop);
						}
					}
					
				}else {	
					if (demoExp.exportData(PCDS_StaticInfo.EXPORT_LIST)){
						String respStop = sendHttpMsg(recDoneProcessing);
						MiscUtils.getLogger().info("####### END OF PROCESSING :" + respStop);
					}else {
						MiscUtils.getLogger().info("####### END OF PROCESSING : PROCESSING NOT COMPLETE");
					}
				}
				//String respStop = sendHttpMsg(recDoneProcessing);
			}else {
				MiscUtils.getLogger().info("Processing INCREMENTAL export.1");
				// Assume integer returned if not special message
				DemographicExport demoExp = new DemographicExport(sec,prov);
				MiscUtils.getLogger().info("Processing INCREMENTAL export.2");
				try{
					long timestamp = Long.parseLong(cleanResponse);
					MiscUtils.getLogger().info("Processing INCREMENTAL export.3");
					//System.out.println("PCDS : Received integer for INCREMENTAL export: NOT CODED YET");
					DemographicToExportPCDS_Dao dao = SpringUtils.getBean(DemographicToExportPCDS_Dao.class);
					MiscUtils.getLogger().info("Processing INCREMENTAL export.4");
					
					List<String> updatedCCP = dao.getIncremental(new Timestamp(timestamp));
					MiscUtils.getLogger().info("Processing INCREMENTAL export.5");
					if (updatedCCP.size() > 0){
						String respStart = sendHttpMsg(recStartProcessing);
						demoExp.exportData(updatedCCP);
						MiscUtils.getLogger().info("Processing INCREMENTAL export.6");
						String respStop = sendHttpMsg(recDoneProcessing);
						MiscUtils.getLogger().info("Processing INCREMENTAL export.7");
						MiscUtils.getLogger().info("####### END OF PROCESSING :" + respStop);
					}else {
						MiscUtils.getLogger().info("Processing INCREMENTAL export.8");
						
						MiscUtils.getLogger().info("####### END OF PROCESSING : PROCESSING NOT COMPLETE");
					}

				}catch(NumberFormatException e){
					MiscUtils.getLogger().info(this.getClass().getName() + " : " + "Can't identify the response value, NOT PROCESSING.");
				}
			}

		}
	}

	@Override
	public void setLoggedInProvider(Provider provider) {
		prov = provider;

	}

	@Override
	public void setLoggedInSecurity(Security security) {
		sec = security;

	}
	
	private String sendHttpMsg(String url){
		MiscUtils.getLogger().info("\t SendHTTPmessage : Processing URL: " + url);
		StringBuffer response = new StringBuffer();
		try{
			HttpURLConnection http = (HttpURLConnection)new URL(url).openConnection();
			http.connect();
			BufferedReader reader = new BufferedReader(new InputStreamReader((InputStream)http.getContent()));
			
			
			String line = "";
			while ((line = reader.readLine()) != null){
				response.append(line);
			}
			if (DEBUG){
				MiscUtils.getLogger().info(this.getClass().getName() + " : URL=" + url + "\n\tresponse=" + response.toString());
			}
			reader.close();
			http.disconnect();
			
		}catch(MalformedURLException e){
			MiscUtils.getLogger().info(this.getClass().getName() + " : " + e.getClass().getName() + " : " + e.getMessage());
		}catch(IOException e){
			MiscUtils.getLogger().info(this.getClass().getName() + " : " + e.getClass().getName() + " : " + e.getMessage());
		}
		
		return response.toString().trim();
	}
	
	private Security sec;
	private Provider prov;
	public static final boolean DEBUG = true;
	public static final boolean USEDAO = true; // uses paging

}
