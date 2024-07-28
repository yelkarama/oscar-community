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
package org.oscarehr.integration.excelleris.com.colcamex.www.main;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Properties;
import java.util.concurrent.ScheduledExecutorService;
import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import org.apache.logging.log4j.Logger;
import org.oscarehr.integration.excelleris.com.colcamex.www.core.ControllerHandler;
import org.oscarehr.integration.excelleris.com.colcamex.www.core.PollTimer;


import oscar.OscarProperties;

/**
 * @author Dennis Warren Colcamex Resources
 * 
 * Major Contributors: 
 *  OSCARprn
 *  NERD
 *   
 * This community edition of Expedius is for use at your own risk, without warranty, and 
 * support. 
 * 
 */
public class StartupListener implements ServletContextListener {

	public static Logger logger = org.oscarehr.util.MiscUtils.getLogger();
	private static Properties properties;
	private static final String keyFilePath = "./keys.txt";
	protected static String  SERVICE_NAME ; 
	protected static String  TRUSTSTORE_URL ;
	protected static String  STORE_TYPE ;
	protected static String  STORE_PASS ;
	protected static String  HTTPS_PROTOCOL ;
	protected static String  KEYSTORE_URL ;
	protected static String  USER;
	protected static String  PASS;	
	protected static String  URI;
	protected static String  LOGIN;	
	protected static String  FETCH;
	protected static String  ACKNOWLEDGE;
	protected static String  LOGOUT;
	protected static String  ACKNOWLEDGE_DOWNLOADS;
	
    /**
     * Default constructor. 
     */
    public StartupListener() {
        // default constructor
    }

	/**
     * @see ServletContextListener#contextInitialized(ServletContextEvent)
     */
    public void contextInitialized(ServletContextEvent event) {

		//instantiate ExcellerisConfigurationBean
		ExcellerisConfigurationBean notABean = new ExcellerisConfigurationBean(); 
    	Boolean isBeanLoadedWithProperties = _init(OscarProperties.getInstance(), notABean);

		ControllerHandler controllerHandler = null;
		
		if( isBeanLoadedWithProperties && properties != null && Boolean.parseBoolean( properties.getProperty("EXCELLERIS") )) {
			logger.info("Starting EXCELLERIS listener");
			controllerHandler = ControllerHandler.getInstance(properties, notABean);
		} else {
			logger.error("Failed to start autodownloader. Is EXCELLERIS set to true? Is Oscar Properties accessable?");
		}

		if(controllerHandler != null) {
			controllerHandler.start();
			controllerHandler.getMessageHandler().setServiceStatus(Boolean.TRUE);
		}

    }

	/**
     * @see ServletContextListener#contextDestroyed(ServletContextEvent)
     */
    public void contextDestroyed(ServletContextEvent event) {
    	ScheduledExecutorService scheduler = PollTimer.getScheduler();
		if(scheduler != null) {
			scheduler.shutdown();
		}
		
		logger.info(" Autolab download server shutdown occurred.");
    }
    
    private Boolean _init(Properties properties, ExcellerisConfigurationBean notABean){ //, String context) {	

		Boolean errorFlag = false;
		
		if(properties != null) {
			
			//load the oscar.propreties file into ExcellerisConfigurationBean	
			
			if(properties.containsKey("EXCELLERIS_USER")) {
					USER = properties.getProperty("EXCELLERIS_USER").trim();
			} else {
					logger.error("Missing EXCELLERIS_USER in properties.");
					errorFlag = true;
			}
			if(properties.containsKey("EXCELLERIS_PASS")) {
					PASS = properties.getProperty("EXCELLERIS_PASS").trim();
			} else {
					logger.error("Missing EXCELLERIS_PASS in properties.");
					errorFlag = true;
			}
			if(properties.containsKey("EXCELLERIS_URI")) {
					URI = properties.getProperty("EXCELLERIS_URI").trim();
			} else {
					if(properties.containsKey("billregion")) {
							if(properties.getProperty("billregion").trim() == "ON") {
									URI = "https://api.on.excelleris.com/hl7pull.aspx";
							}
							if(properties.getProperty("billregion").trim() == "BC") {
									URI = "https://api.bc.excelleris.com/hl7pull.aspx";
							}              
							logger.info("Missing EXCELLERIS_URI in properties, setting to default of " + URI);
					} else {
							logger.error("Missing billregion in properties.");
							errorFlag = true;       
					}
			}
			if(properties.containsKey("LOGIN_PARAMS")) {
					LOGIN = URI + "?" + properties.getProperty("LOGIN_PARAMS").trim();
			} else {
					LOGIN = URI + "?Page=Login&Mode=Silent&UserID=@username&Password=@password";
					logger.info("Missing Excelleris LOGIN_PARAMS in properties, setting to default of Page=Login&Mode=Silent&UserID=@username&Password=@password");
			}
			if(properties.containsKey("PULLXMLPARAMS")) {
					FETCH = URI + "?" + properties.getProperty("PULLXMLPARAMS").trim();
			} else {
					FETCH = URI + "?Page=HL7&Query=NewRequests&Pending=Yes";
					logger.info("Missing Excelleris PULLXMLPARAMS in properties, setting to default of Page=HL7&Query=NewRequests&Pending=Yes");
			}
			if(ACKNOWLEDGE_DOWNLOADS == "true") {
					ACKNOWLEDGE = URI + "?Page=HL7&&ACK=Positive";
			} else {
					ACKNOWLEDGE = URI + "?Page=HL7&ACK=Negative";
			}
			if(properties.containsKey("LOGOUT_PARAMS")) {
					LOGOUT = URI + "?" + properties.getProperty("LOGOUT_PARAMS").trim();
			} else {
					LOGOUT = URI + "?Logout=Yes";
					logger.info("Missing Excelleris LOGOUT_PARAMS in properties, setting to default of Logout=Yes");
			}
			if(!properties.containsKey("ACKNOWLEDGE_DOWNLOADS")) { 
			        ACKNOWLEDGE_DOWNLOADS = "false";
			        logger.info("Missing Excelleris ACKNOWLEDGE_DOWNLOADS in properties, setting to false, **set to true for production use.**");
			} else {
			        ACKNOWLEDGE_DOWNLOADS = properties.getProperty("ACKNOWLEDGE_DOWNLOADS").trim();
			}
			if(properties.containsKey("TRUSTSTORE_URL")) {
					TRUSTSTORE_URL = properties.getProperty("TRUSTSTORE_URL").trim();
			} else {
					logger.error("Missing TRUSTSTORE_URL in properties.");
					errorFlag = true;
			}
			if(properties.containsKey("KEYSTORE_URL")) {
					KEYSTORE_URL = properties.getProperty("KEYSTORE_URL").trim();
			} else {
					logger.error("Missing KEYSTORE_URL in properties.");
					errorFlag = true;
			}
			if(properties.containsKey("STORE_PASS")) {
					STORE_PASS = properties.getProperty("STORE_PASS").trim();
			} else {
					logger.error("Missing STORE_PASS in properties.");
					errorFlag = true;
			}
			if(properties.containsKey("STORE_TYPE")) {
					STORE_TYPE = properties.getProperty("STORE_TYPE").trim();
			} else {
					logger.info("Missing STORE_TYPE in properties, setting to JKS");
					STORE_TYPE = "JKS";
			}
			if(properties.containsKey("SERVICE_NAME")) {
					SERVICE_NAME = properties.getProperty("SERVICE_NAME").trim();
			} else {
					logger.info("Missing SERVICE_NAME in properties, setting to Excelleris");
					SERVICE_NAME = "Excelleris";
			}
			if(properties.containsKey("HTTPS_PROTOCOL")) {
					HTTPS_PROTOCOL = properties.getProperty("HTTPS_PROTOCOL").trim();
			} else {
					logger.info("Missing HTTPS_PROTOCOL in properties, setting to TLSv1");
					HTTPS_PROTOCOL = "TLSv1";
			}

			// if any errors drop a useful error message and prevent Instantiating the Controller Handler
			if (errorFlag) {
				logger.error("Missing configuration parameters, correct properties file and restart OSCAR.");
				return !errorFlag;		
			}
			notABean.initialize(URI,FETCH,LOGIN,LOGOUT,ACKNOWLEDGE,USER,PASS,ACKNOWLEDGE_DOWNLOADS,TRUSTSTORE_URL,KEYSTORE_URL,STORE_PASS,SERVICE_NAME,HTTPS_PROTOCOL);
			/*
			* we will verify only essential keys for others if absent will make provide safe defaults
			*
			try {
	            verifyProperties(properties);
            } catch (IOException e) {
            	logger.error("Failed to initialize properties file. Essential property keys are listed in keys.text");
            	StartupListener.properties = null;
            }
			*/
			StartupListener.properties = properties;
			
		} else {
			logger.error("Properties file path is missing.");
		}
		return !errorFlag;
	}
    
    private static final boolean verifyProperties(Properties properties) throws IOException {

    	String line = "";
    	ArrayList<String> lines = new ArrayList<String>();
    	BufferedReader bufferedReader = new BufferedReader( new FileReader(keyFilePath) );
		while ( ( line = bufferedReader.readLine().trim() ) != null) {
			lines.add(line);
		}
		
		String[] keys = (String[]) lines.toArray();
    	
		String[] array1 = null;
		String[] array2 = null;
		boolean b = true;
		
		if(properties != null) {
			array1  = properties.keySet().toArray(new String[]{});
			Arrays.sort(array1 ); 
			Arrays.sort(keys);
			array2 = keys;		
		}
		
		if (array1 != null && array2 != null){

			if (array1.length != array2.length) {
				b = false;
			} else {
				for (int i = 0; i < array2.length; i++) {
			
					if (! array2[i].equalsIgnoreCase(array1[i]) ) {						
						b = false;    
					}                 
				}
			}
		}else{
			b = false;
		}
		
		if(bufferedReader != null) {
			bufferedReader.close();
		}
	
		return b;
	}
    
}
