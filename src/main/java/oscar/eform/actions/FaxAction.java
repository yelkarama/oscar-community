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
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.HashSet;
import java.util.List;

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

import com.itextpdf.text.pdf.PdfReader;
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
	public void faxForms(String[] numbers, String formId, String providerId) throws DocumentException, Exception {
		
		File tempFile = null;

		try {
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
			String tempPath = OscarProperties.getInstance().getProperty("DOCUMENT_DIR");
			
			FaxJob faxJob = null;
			FaxJobDao faxJobDao = SpringUtils.getBean(FaxJobDao.class);				
			FaxConfigDao faxConfigDao = SpringUtils.getBean(FaxConfigDao.class);
			
			List<FaxConfig> faxConfigs = faxConfigDao.findAll(null, null);
			if( faxConfigs.isEmpty() ) {
				throw new Exception("OSCaR FAX IS NOT CONFIGURED");
			}
			
			String outFaxNo = faxConfigs.get(0).getFaxNumber();
			String faxUser = faxConfigs.get(0).getFaxUser();
			
			for (int i = 0; i < recipients.size(); i++) {					
			    String faxNo = recipients.get(i).trim().replaceAll("\\D", "");
			    if (faxNo.length() < 7) { throw new DocumentException("Document target fax number '"+faxNo+"' is invalid."); }
			    String tempName = "EForm-" + formId + "." + System.currentTimeMillis();
				
				String tempPdf = String.format("%s%s%s.pdf", tempPath, File.separator, tempName);
				
				
				// Copying the fax pdf.
				FileUtils.copyFile(tempFile, new File(tempPdf));
				
				// A little sanity check to ensure both files exist.
				if (!new File(tempPdf).exists() ) {
					throw new DocumentException("Unable to create files for fax of eform " + formId + ".");
				}		
				
				
				faxJob = new FaxJob();
				faxJob.setDestination(faxNo);
				faxJob.setFile_name(tempName+".pdf");
				
				PdfReader pdfReader = new PdfReader(tempPdf);
				int numPages = pdfReader.getNumberOfPages();
				pdfReader.close();
				
				faxJob.setNumPages(numPages);
				faxJob.setFax_line(outFaxNo);
				faxJob.setStamp(new Date());
				faxJob.setOscarUser(providerId);
				
				EFormDataDao eFormDataDao=(EFormDataDao) SpringUtils.getBean("EFormDataDao");
	        	EFormData eFormData=eFormDataDao.find(Integer.parseInt(formId));
				
	        	faxJob.setDemographicNo(eFormData.getDemographicId());
				faxJob.setStatus(FaxJob.STATUS.SENT);
				faxJob.setUser(faxUser);
				faxJobDao.persist(faxJob);
				
				
				if (skipSave) {
		        	 
		        	 eFormData.setCurrent(false);
		        	 eFormDataDao.merge(eFormData);
				}
			}
			// Removing the consulation pdf.
			tempFile.delete();			
						
		} catch (IOException e) {
			MiscUtils.getLogger().error("Error converting and sending eform. id="+formId, e);
		} 
	}

}
