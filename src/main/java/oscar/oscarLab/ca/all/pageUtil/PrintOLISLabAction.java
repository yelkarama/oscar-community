/**
 * Copyright (c) 2008-2012 Indivica Inc.
 *
 * This software is made available under the terms of the
 * GNU General Public License, Version 2, 1991 (GPLv2).
 * License details are available via "indivica.ca/gplv2"
 * and "gnu.org/licenses/gpl-2.0.html".
 */

package oscar.oscarLab.ca.all.pageUtil;


import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.log4j.Logger;
import org.apache.struts.action.Action;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.bouncycastle.util.encoders.Base64;
import org.oscarehr.managers.SecurityInfoManager;
import org.oscarehr.olis.OLISResultsAction;
import org.oscarehr.util.LoggedInInfo;
import org.oscarehr.util.MiscUtils;
import org.oscarehr.util.SpringUtils;

import oscar.oscarLab.ca.all.parsers.Factory;
import oscar.oscarLab.ca.all.parsers.MessageHandler;

import com.lowagie.text.DocumentException;
import oscar.oscarLab.ca.all.parsers.OLISHL7Handler;

public class PrintOLISLabAction extends Action {

	private static final Logger logger = MiscUtils.getLogger();
	
	private SecurityInfoManager securityInfoManager = SpringUtils.getBean(SecurityInfoManager.class);
	
	public ActionForward execute(ActionMapping mapping, ActionForm form,
            HttpServletRequest request, HttpServletResponse response) {
		
		if(!securityInfoManager.hasPrivilege(LoggedInInfo.getLoggedInInfoFromSession(request), "_lab", "r", null)) {
			throw new SecurityException("missing required security object (_lab)");
		}
		
		try {
			String segmentId = request.getParameter("segmentID");
			String resultUuid = request.getParameter("uuid");
			boolean includeAttachmentsInZip = Boolean.valueOf(request.getParameter("includeAttachmentsInZip"));
			MessageHandler handler = null;
			if (segmentId==null && segmentId.equals("0")) {
				// if viewing in preview from OLIS search, use uuid
				handler = OLISResultsAction.searchResultsMap.get(resultUuid);
			}
			else{
				handler = Factory.getHandler(segmentId);
			}
			if (includeAttachmentsInZip) {
				createReportZip(request, response, (OLISHL7Handler) handler);
			} else {
				createReportPdf(request, response, handler);
			}

		}catch(DocumentException de) {
			logger.error("DocumentException occured insided OLISPrintLabsAction", de);
			request.setAttribute("printError", new Boolean(true));
			return mapping.findForward("error");
		}catch(IOException ioe) {
			logger.error("IOException occured insided OLISPrintLabsAction", ioe);
			request.setAttribute("printError", new Boolean(true));
			return mapping.findForward("error");
		}catch(Exception e){
			logger.error("Unknown Exception occured insided OLISPrintLabsAction", e);
			request.setAttribute("printError", new Boolean(true));
			return mapping.findForward("error");
		}
		
		
		return mapping.findForward("success");
	}

	private void createReportPdf(HttpServletRequest request, HttpServletResponse response, MessageHandler handler) throws IOException, DocumentException {
		response.setContentType("application/pdf");  //octet-stream
		response.setHeader("Content-Disposition", "attachment; filename=\"" + handler.getPatientName().replaceAll("\\s", "_") + "_OLISLabReport.pdf\"");
		OLISLabPDFCreator pdf = new OLISLabPDFCreator(request, response.getOutputStream());
		pdf.printPdf();
	}

	private void createReportZip(HttpServletRequest request, HttpServletResponse response, OLISHL7Handler handler) throws IOException, DocumentException {
		response.setContentType("Content-type: application/zip");  //octet-stream
		response.setHeader("Content-Disposition", "attachment; filename=\"" + handler.getPatientName().replaceAll("\\s", "_") + "_OLISLabReport.zip\"");

		ByteArrayOutputStream pdfStream = new ByteArrayOutputStream();
		OLISLabPDFCreator pdf = new OLISLabPDFCreator(request, pdfStream);
		pdf.printPdf();

		try (ZipOutputStream zos = new ZipOutputStream(response.getOutputStream())) {
			ZipEntry reportEntry = new ZipEntry(handler.getPatientName().replaceAll("\\s", "_") + "_OLISLabReport.pdf");
			zos.putNextEntry(reportEntry);
			zos.write(pdfStream.toByteArray());

			ArrayList<String> headers = handler.getHeaders();
			int obr;
			for (int i = 0; i < headers.size(); i++){
				//Gets the mapped OBR for the current index
				obr = handler.getMappedOBR(i);
				for (int obx = 0; obx < handler.getOBXCount(obr); obx++) {
					if ("ED".equals(handler.getOBXValueType(obr, obx))) {
						String subtype = handler.getOBXField(obr, obx, 5, 0, 3);
						String data = handler.getOBXEDField(obr, obx, 5, 0, 5);
						byte[] attachmentData = Base64.decode(data);
						String fileName;

						if (subtype.equals("PDF")) {
							fileName = handler.getAccessionNum().replaceAll("\\s", "_") + "_" + obr + "-" + obx + "_Document.pdf";
						} else if (subtype.equals("JPEG")) {
							fileName = handler.getAccessionNum().replaceAll("\\s", "_") + "_" + obr + "-" + obx + "_Image.jpg";
						} else if (subtype.equals("GIF")) {
							fileName = handler.getAccessionNum().replaceAll("\\s", "_") + "_" + obr + "-" + obx + "_Image.gif";
						} else if (subtype.equals("RTF")) {
							fileName = handler.getAccessionNum().replaceAll("\\s", "_") + "_" + obr + "-" + obx + "_Document.rtf";
						} else if (subtype.equals("HTML")) {
							fileName = handler.getAccessionNum().replaceAll("\\s", "_") + "_" + obr + "-" + obx + "_Document.html";
						} else if (subtype.equals("XML")) {
							fileName = handler.getAccessionNum().replaceAll("\\s", "_") + "_" + obr + "-" + obx + "_Document.xml";
						} else {
							fileName = handler.getAccessionNum().replaceAll("\\s", "_") + "_" + obr + "-" + obx + "_Document";
						}
						
						ZipEntry attachmentEntry = new ZipEntry(fileName);
						zos.putNextEntry(attachmentEntry);
						zos.write(attachmentData);
					}
				}
			}
		}
	}
}
