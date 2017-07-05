/**
 * Copyright (c) 2008-2012 Indivica Inc.
 *
 * This software is made available under the terms of the
 * GNU General Public License, Version 2, 1991 (GPLv2).
 * License details are available via "indivica.ca/gplv2"
 * and "gnu.org/licenses/gpl-2.0.html".
 */
package oscar.eform.actions;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.List;
import java.util.HashSet;

import javax.servlet.http.HttpServletRequest;

import org.apache.commons.io.FileUtils;
import org.apache.log4j.Logger;
import org.oscarehr.common.dao.EFormDataDao;
import org.oscarehr.common.dao.FaxConfigDao;
import org.oscarehr.common.dao.FaxJobDao;
import org.oscarehr.common.model.EFormData;
import org.oscarehr.common.model.FaxConfig;
import org.oscarehr.common.model.FaxJob;
import org.oscarehr.util.MiscUtils;
import org.oscarehr.util.SpringUtils;
import org.oscarehr.util.WKHtmlToPdfUtils;

import oscar.OscarProperties;

import com.lowagie.text.DocumentException;

public final class FaxAction {

	private static final Logger logger = MiscUtils.getLogger();

	private String localUri = null;
	
	private boolean skipSave = false;

	public FaxAction(HttpServletRequest request) {
		localUri = getEformRequestUrl(request);
		skipSave = "true".equals(request.getParameter("skipSave"));
	}

	/**
	 * This method is a copy of Apache Tomcat's ApplicationHttpRequest getRequestURL method with the exception that the uri is removed and replaced with our eform viewing uri. Note that this requires that the remote url is valid for local access. i.e. the
	 * host name from outside needs to resolve inside as well. The result needs to look something like this : https://127.0.0.1:8443/oscar/eformViewForPdfGenerationServlet?fdid=2&parentAjaxId=eforms
	 */
	private String getEformRequestUrl(HttpServletRequest request) {
		StringBuilder url = new StringBuilder();
		String scheme = request.getScheme();
		Integer port;
		try { port = new Integer(OscarProperties.getInstance().getProperty("oscar_port")); }
	    catch (Exception e) { port = 8443; }
		if (port < 0) port = 80; // Work around java.net.URL bug

		url.append(scheme);
		url.append("://");
		//url.append(request.getServerName());
		url.append("127.0.0.1");
		
		if ((scheme.equals("http") && (port != 80)) || (scheme.equals("https") && (port != 443))) {
			url.append(':');
			url.append(port);
		}
		url.append(request.getContextPath());
		url.append("/EFormViewForPdfGenerationServlet?parentAjaxId=eforms&prepareForFax=true&providerId=");
		url.append(request.getParameter("providerId"));
		url.append("&fdid=");

		return (url.toString());
	}

	/**
	 * This method will take eforms and send them to a PHR.
	 * @throws DocumentException 
	 */
	public void faxForms(String[] numbers, String formId, String providerId) throws DocumentException {
		
		File tempFile = null;

		try {
			EFormDataDao eFormDataDao = SpringUtils.getBean(EFormDataDao.class);
			EFormData eFormData = eFormDataDao.find(Integer.parseInt(formId));
			Integer demographicNumber = 0;
			if (eFormData!=null){
				demographicNumber = eFormData.getDemographicId();
			}

			logger.info("Generating PDF for eform with fdid = " + formId);

			tempFile = File.createTempFile("EForm." + formId, ".pdf");
			//tempFile.deleteOnExit();

			// convert to PDF
			String viewUri = localUri + formId;
			WKHtmlToPdfUtils.convertToPdf(viewUri, tempFile);
			logger.info("Writing pdf to : "+tempFile.getCanonicalPath());
			
			// Removing all non digit characters from fax numbers.
			for (int i = 0; i < numbers.length; i++) { 
				numbers[i] = numbers[i].trim().replaceAll("\\D", "");
			}
			ArrayList<String> recipients = new ArrayList<String>(Arrays.asList(numbers));
			
			// Removing duplicate phone numbers.
			recipients = new ArrayList<String>(new HashSet<String>(recipients));
			String tempPath = System.getProperty("java.io.tmpdir");
			FileOutputStream fos;
			for (int i = 0; i < recipients.size(); i++) {
				FaxJob faxJob = new FaxJob();
				FaxJobDao faxJobDao = SpringUtils.getBean(FaxJobDao.class);
				FaxConfigDao faxConfigDao = SpringUtils.getBean(FaxConfigDao.class);
				List<FaxConfig> faxConfigs = faxConfigDao.findAll(null, null);
				boolean validFaxNumber = false;

			    String faxNo = recipients.get(i).trim().replaceAll("\\D", "");
			    if (faxNo.length() < 7) { throw new DocumentException("Document target fax number '"+faxNo+"' is invalid."); }
			    String tempName = "EForm-" + formId + "." + String.valueOf(i) + "." + System.currentTimeMillis();
				
				String tempPdf = String.format("%s%s%s.pdf", tempPath, File.separator, tempName);
				String tempTxt = String.format("%s%s%s.txt", tempPath, File.separator, tempName);
				
				// Copying the fax pdf.
				FileUtils.copyFile(tempFile, new File(tempPdf));

				faxJob = new FaxJob();
				faxJob.setDestination(faxNo);
				faxJob.setFile_name(tempFile.getName());
				faxJob.setFax_line(faxNo);
				faxJob.setStamp(new Date());
				faxJob.setOscarUser(providerId);
				faxJob.setDemographicNo(demographicNumber);

				for (FaxConfig faxConfig : faxConfigs) {
					if (faxConfig.getFaxNumber().equals(faxNo)) {
						faxJob.setStatus(FaxJob.STATUS.SENT);
						faxJob.setUser(faxConfig.getFaxUser());
						validFaxNumber = true;
						break;
					}
				}

				// Creating text file with the specialists fax number.
				fos = new FileOutputStream(tempTxt);				
				PrintWriter pw = new PrintWriter(fos);
				pw.println(faxNo);
				pw.close();
				fos.close();
				
				// A little sanity check to ensure both files exist.
				if (!new File(tempPdf).exists() || !new File(tempTxt).exists()) {
					throw new DocumentException("Unable to create files for fax of eform " + formId + ".");
				}		
				if (skipSave) {
		        	 eFormData.setCurrent(false);
		        	 eFormDataDao.merge(eFormData);
				}

				if( !validFaxNumber ) {
					faxJob.setStatus(FaxJob.STATUS.ERROR);
					logger.error("PROBLEM CREATING FAX JOB", new DocumentException("Document outgoing fax number '"+faxNo+"' is invalid."));
				}
				else {
					faxJob.setStatus(FaxJob.STATUS.SENT);
				}
				faxJobDao.persist(faxJob);
			}
			// Removing the consulation pdf.
			tempFile.delete();			
						
		} catch (IOException e) {
			MiscUtils.getLogger().error("Error converting and sending eform. id="+formId, e);
		} 
	}

	public void attachForms(String formId) throws DocumentException {
		File tempFile = null;
		String tempPath = System.getProperty("java.io.tmpdir");
		String tempName = "EForm-" + formId + "." + System.currentTimeMillis();

		try {
			// Create temp file
			tempFile = File.createTempFile(tempName, ".pdf");

			// Convert to PDF
			String viewUri = localUri + formId;
			WKHtmlToPdfUtils.convertToPdf(viewUri, tempFile);
			logger.info("Writing pdf to : "+tempFile.getCanonicalPath());
			String tempPdf = String.format("%s%s%s.pdf", tempPath, File.separator, tempName);
			FileUtils.copyFile(tempFile, new File(tempPdf));

			// Removing the temp consultation pdf.
			tempFile.delete();

		} catch (IOException e) {
			MiscUtils.getLogger().error("Error converting and sending eform. id="+formId, e);
		}

	}

}
