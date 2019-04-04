/**
 * Copyright (c) 2008-2012 Indivica Inc.
 *
 * This software is made available under the terms of the
 * GNU General Public License, Version 2, 1991 (GPLv2).
 * License details are available via "indivica.ca/gplv2"
 * and "gnu.org/licenses/gpl-2.0.html".
 */
package oscar.eform.actions;

import java.io.BufferedInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.lowagie.text.DocumentException;
import org.apache.log4j.Logger;
import org.apache.struts.action.Action;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.oscarehr.common.dao.EFormDataDao;
import org.oscarehr.common.model.EFormData;
import org.oscarehr.common.printing.HtmlToPdfServlet;
import org.oscarehr.managers.SecurityInfoManager;
import org.oscarehr.util.LoggedInInfo;
import org.oscarehr.util.MiscUtils;
import org.oscarehr.util.SpringUtils;
import org.oscarehr.util.WKHtmlToPdfUtils;

import oscar.OscarProperties;
import oscar.dms.EDocUtil;
import oscar.eform.EFormUtil;
import oscar.util.UtilDateUtilities;

import com.sun.xml.messaging.saaj.util.ByteOutputStream;

public class PrintAction extends Action {

	private static final Logger logger = MiscUtils.getLogger();

	private String localUri = null;
	
	private boolean skipSave = false;
	
	private HttpServletResponse response;
	private HttpServletRequest request;
	
	private SecurityInfoManager securityInfoManager = SpringUtils.getBean(SecurityInfoManager.class);

	public ActionForward execute(ActionMapping mapping, ActionForm form,
            HttpServletRequest request, HttpServletResponse response) {
		
		if(!securityInfoManager.hasPrivilege(LoggedInInfo.getLoggedInInfoFromSession(request), "_eform", "r", null)) {
			throw new SecurityException("missing required security object (_eform)");
		}
		
		localUri = getEformRequestUrl(request);
		this.response = response;
		this.request = request;
		String id  = (String)request.getAttribute("fdid");
		String providerId = request.getParameter("providerId");
		skipSave = "true".equals(request.getParameter("skipSave"));
		try {
			printForm(id, providerId);
		} catch (Exception e) {
			MiscUtils.getLogger().error("",e);
			return mapping.findForward("error");
		}
		if(skipSave){
			return mapping.findForward("success");
		}
		else {
			return mapping.findForward("close");
		}
	}
	
	/**
	 * This method is a copy of Apache Tomcat's ApplicationHttpRequest getRequestURL method with the exception that the uri is removed and replaced with our eform viewing uri. Note that this requires that the remote url is valid for local access. i.e. the
	 * host name from outside needs to resolve inside as well. The result needs to look something like this : https://127.0.0.1:8443/oscar/eformViewForPdfGenerationServlet?fdid=2&parentAjaxId=eforms
	 */
    public static String getEformRequestUrl(HttpServletRequest request) {
		StringBuilder url = new StringBuilder();
		String scheme = "http";
		Integer port = 80;
		if (request.getServerPort() != 80) {
			port = 8080;
		}

		url.append(scheme);
		url.append("://");
		//url.append(request.getServerName());
		url.append("127.0.0.1");
		
		url.append(':');
		url.append(port);
		url.append(request.getContextPath());
		url.append("/EFormViewForPdfGenerationServlet?parentAjaxId=eforms&providerId=");
		url.append(request.getParameter("providerId"));
		url.append("&fdid=");

		return (url.toString());
	}

	/**
	 * This method will take eforms and send them to a PHR.
	 */
	public void printForm(String formId, String providerId) {
		boolean addDocumentToEchart = Boolean.parseBoolean(request.getParameter("printDocumentToEchartOnPdfFax"));
		File tempFile = null;

		try {
			logger.info("Generating PDF for eform with fdid = " + formId);

			EFormDataDao eFormDataDao = SpringUtils.getBean(EFormDataDao.class);
			EFormData eFormData = eFormDataDao.find(Integer.parseInt(formId));

			// convert to PDF
			String viewUri = localUri + formId;
			boolean isRichTextLetter = eFormData.getFormId().toString().equals(OscarProperties.getInstance().getProperty("rtl_template_id", ""));
			if (isRichTextLetter) {
				tempFile = File.createTempFile( "templatedRtl."  + formId + "-", ".pdf");
				EFormUtil.printRtlWithTemplate(eFormData, tempFile, skipSave, request);
			} else {
				tempFile = File.createTempFile("EFormPrint." + formId, ".pdf");
				WKHtmlToPdfUtils.convertToPdf(viewUri, tempFile);
			}
			logger.info("Writing pdf to : "+tempFile.getCanonicalPath());
			
			if (addDocumentToEchart) {
				LoggedInInfo loggedInInfo = LoggedInInfo.getLoggedInInfoFromSession(request);
				// Saves the eform to the patient's chart
				EDocUtil.saveDocumentToPatient(loggedInInfo, loggedInInfo.getLoggedInProvider(), eFormData.getDemographicId(), tempFile, -1, "", eFormData.getFormName());
			}
			
			InputStream is = new BufferedInputStream(new FileInputStream(tempFile));
			ByteOutputStream bos = new ByteOutputStream();
			byte buffer[] = new byte[1024];
			int read;
			while (is.available() != 0) {
				read = is.read(buffer,0,1024);
				bos.write(buffer,0, read);
			}
			
			bos.flush();
			// byte[] pdf = HtmlToPdfServlet.appendFooter(bos.getBytes());
			byte[] pdf;
            try {
            	if (isRichTextLetter) {
            		pdf = bos.getBytes();
				} else {
					pdf = HtmlToPdfServlet.stamp(bos.getBytes());
				}
            } catch (Exception e) {
            	throw new RuntimeException(e);
            }
			
			//while (fos.read() != -1)
			response.setContentType("application/pdf");  //octet-stream
            response.setHeader("Content-Disposition", "attachment; filename=\"EForm-"
            				+ formId + "-"
							+ UtilDateUtilities.getToday("yyyy-mm-dd.hh.mm.ss")
							+ ".pdf\"");
			// response.getOutputStream().write(bos.getBytes(), 0, bos.getCount());
            HtmlToPdfServlet.stream(response, pdf, false);
            // response.getOutputStream().write(pdf);
			
			// Removing the consulation pdf.
			tempFile.delete();	
			
			// Removing the eform
			if (skipSave) {
	        	 eFormDataDao=(EFormDataDao) SpringUtils.getBean("EFormDataDao");
	        	 eFormData=eFormDataDao.find(Integer.parseInt(formId));
	        	 eFormData.setCurrent(false);
	        	 eFormDataDao.merge(eFormData);
			}
		} catch (IOException | RuntimeException | DocumentException e) {
			MiscUtils.getLogger().error("", e);
		}
	}

	
}
