/**
 * Copyright (c) 2008-2012 Indivica Inc.
 *
 * This software is made available under the terms of the
 * GNU General Public License, Version 2, 1991 (GPLv2).
 * License details are available via "indivica.ca/gplv2"
 * and "gnu.org/licenses/gpl-2.0.html".
 */

/*
 * HL7Handler
 * Upload handler
 * 
 */
package oscar.oscarLab.ca.all.upload.handlers;

import java.util.ArrayList;

import org.apache.log4j.Logger;
import org.oscarehr.common.dao.Hl7TextInfoDao;
import org.oscarehr.common.dao.ProviderDataDao;
import org.oscarehr.common.model.ProviderData;
import org.oscarehr.olis.OLISUtils;
import org.oscarehr.util.DbConnectionFilter;
import org.oscarehr.util.LoggedInInfo;
import org.oscarehr.util.SpringUtils;

import oscar.oscarLab.ca.all.parsers.Factory;
import oscar.oscarLab.ca.all.upload.MessageUploader;
import oscar.oscarLab.ca.all.upload.ProviderLabRouting;
import oscar.oscarLab.ca.all.upload.RouteReportResults;
import oscar.oscarLab.ca.all.util.Utilities;

import javax.servlet.http.HttpServletRequest;

/**
 * 
 */
public class OLISHL7Handler implements MessageHandler {

	Logger logger = Logger.getLogger(OLISHL7Handler.class);
	Hl7TextInfoDao hl7TextInfoDao = (Hl7TextInfoDao)SpringUtils.getBean("hl7TextInfoDao");
	
	private int lastSegmentId = 0;
	
	public OLISHL7Handler() {
		logger.info("NEW OLISHL7Handler UPLOAD HANDLER instance just instantiated. ");
	}

	public String parse(LoggedInInfo loggedInInfo, String serviceName, String fileName, int fileId, String ipAddr) {
		return parse(loggedInInfo, serviceName,fileName,fileId, false);
	}
	public String parse(LoggedInInfo loggedInInfo, String serviceName, String fileName, int fileId, boolean routeToCurrentProvider) {		
		int i = 0;
		String lastTimeStampAccessed = null;
		RouteReportResults results = new RouteReportResults();
		
				try {
			ArrayList<String> messages = Utilities.separateMessages(fileName);
			
			for (i = 0; i < messages.size(); i++) {
				String msg = messages.get(i);
				logger.info(msg);
				
				lastTimeStampAccessed = getLastUpdateInOLIS(msg) ;
				
				if(OLISUtils.isDuplicate(loggedInInfo, msg)) {
					continue; 
				}
				MessageUploader.routeReport(loggedInInfo, serviceName,"OLIS_HL7", msg.replace("\\E\\", "\\SLASHHACK\\").replace("µ", "\\MUHACK\\").replace("\\H\\", "\\.H\\").replace("\\N\\", "\\.N\\"), fileId, results);
				if (routeToCurrentProvider) {
					ProviderLabRouting routing = new ProviderLabRouting();
					ProviderDataDao providerDataDao = SpringUtils.getBean(ProviderDataDao.class);
					ProviderData provider = providerDataDao.findByOhipNumber(getOrderingProviderNo(msg));

					if (provider != null){
						routing.route(results.segmentId, provider.getId(), DbConnectionFilter.getThreadLocalDbConnection(), "HL7");
					}
					this.lastSegmentId = results.segmentId;
				}
			}
			logger.info("Parsed OK");
		} catch (Exception e) {
			MessageUploader.clean(fileId);
			logger.error("Could not upload message", e);
			return null;
		}
		return lastTimeStampAccessed;
	}

	public String parse(HttpServletRequest request, String serviceName, String fileName, int fileId) {
		LoggedInInfo loggedInInfo = LoggedInInfo.getLoggedInInfoFromSession(request);
		String requestingHic = request.getParameter("requestingHic");
		int i = 0;
		String lastTimeStampAccessed = null;
		RouteReportResults results = new RouteReportResults();

		try {
			ArrayList<String> messages = Utilities.separateMessages(fileName);

			for (i = 0; i < messages.size(); i++) {
				String msg = messages.get(i);
				logger.info(msg);

				lastTimeStampAccessed = getLastUpdateInOLIS(msg) ;

				if(OLISUtils.isDuplicate(loggedInInfo, msg)) {
					continue;
				}
				MessageUploader.routeReport(loggedInInfo, serviceName,"OLIS_HL7", msg.replace("\\E\\", "\\SLASHHACK\\").replace("µ", "\\MUHACK\\").replace("\\H\\", "\\.H\\").replace("\\N\\", "\\.N\\"), fileId, results);
				if (requestingHic != null) {
					ProviderLabRouting routing = new ProviderLabRouting();
					ProviderDataDao providerDataDao = SpringUtils.getBean(ProviderDataDao.class);
					ProviderData provider = providerDataDao.findByOhipNumber(getOrderingProviderNo(msg));

					if (provider != null){
						routing.route(results.segmentId, provider.getId(), DbConnectionFilter.getThreadLocalDbConnection(), "HL7");
					}
					this.lastSegmentId = results.segmentId;
				}
			}
			logger.info("Parsed OK");
		} catch (Exception e) {
			MessageUploader.clean(fileId);
			logger.error("Could not upload message", e);
			return null;
		}
		return lastTimeStampAccessed;
	}
	
	public int getLastSegmentId() {
		return this.lastSegmentId;
	}
	//TODO: check HIN
	//TODO: check # of results
	
	private String getLastUpdateInOLIS(String msg) {
		oscar.oscarLab.ca.all.parsers.OLISHL7Handler h = (oscar.oscarLab.ca.all.parsers.OLISHL7Handler) Factory.getHandler("OLIS_HL7", msg);
		return h.getLastUpdateInOLISUnformated();	
	}

	private String getOrderingProviderNo(String msg) {
		oscar.oscarLab.ca.all.parsers.OLISHL7Handler h = (oscar.oscarLab.ca.all.parsers.OLISHL7Handler) Factory.getHandler("OLIS_HL7", msg);
		return h.getClientRef();
	}


}
