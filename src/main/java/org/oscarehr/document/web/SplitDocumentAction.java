/**
 * Copyright (c) 2008-2012 Indivica Inc.
 *
 * This software is made available under the terms of the
 * GNU General Public License, Version 2, 1991 (GPLv2).
 * License details are available via "indivica.ca/gplv2"
 * and "gnu.org/licenses/gpl-2.0.html".
 */
package org.oscarehr.document.web;

import java.io.*;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import net.sf.json.JSONObject;

import org.apache.commons.lang.time.DateFormatUtils;
import org.apache.pdfbox.exceptions.COSVisitorException;
import org.apache.pdfbox.pdfparser.PDFParser;
import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.pdmodel.PDPage;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.actions.DispatchAction;
import org.oscarehr.common.dao.CtlDocumentDao;
import org.oscarehr.common.dao.DocumentDao;
import org.oscarehr.common.dao.PatientLabRoutingDao;
import org.oscarehr.common.dao.ProviderInboxRoutingDao;
import org.oscarehr.common.dao.ProviderLabRoutingDao;
import org.oscarehr.common.dao.QueueDocumentLinkDao;
import org.oscarehr.common.model.CtlDocument;
import org.oscarehr.common.model.CtlDocumentPK;
import org.oscarehr.common.model.Document;
import org.oscarehr.common.model.PatientLabRouting;
import org.oscarehr.common.model.ProviderInboxItem;
import org.oscarehr.common.model.ProviderLabRoutingModel;
import org.oscarehr.util.LoggedInInfo;
import org.oscarehr.util.MiscUtils;
import org.oscarehr.util.SpringUtils;
import org.springframework.web.context.WebApplicationContext;
import org.springframework.web.context.support.WebApplicationContextUtils;

import oscar.dms.EDoc;
import oscar.dms.EDocUtil;
import oscar.oscarLab.ca.all.upload.ProviderLabRouting;



public class SplitDocumentAction extends DispatchAction {

	private DocumentDao documentDao = SpringUtils.getBean(DocumentDao.class);
	

	public ActionForward split(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) {
		String docNum = request.getParameter("document");
		String[] commands = request.getParameterValues("page[]");
		String queueId = request.getParameter("queueID");

		LoggedInInfo loggedInInfo=LoggedInInfo.getLoggedInInfoFromSession(request);
		String providerNo=loggedInInfo.getLoggedInProviderNo();

		Document doc = documentDao.getDocument(docNum);

		String docdownload = oscar.OscarProperties.getInstance().getProperty("DOCUMENT_DIR");

		String newFilename = doc.getDocfilename();

		FileInputStream input = null;
		PDDocument pdf = null;
		PDDocument newPdf = null;
		
		try {
		
		input = new FileInputStream(docdownload + doc.getDocfilename());
		PDFParser parser = new PDFParser(input);
		parser.parse();
		pdf = parser.getPDDocument();

		newPdf = new PDDocument();

		List pages = pdf.getDocumentCatalog().getAllPages();

		if (commands != null) {
			for (String c : commands) {
				String[] command = c.split(",");
				int pageNum = Integer.parseInt(command[0]);
				int rotation = Integer.parseInt(command[1]);

				PDPage p = (PDPage)pages.get(pageNum-1);
				p.setRotation(rotation);

				newPdf.addPage(p);
			}

		}

		//newPdf.save(docdownload + newFilename);

		if (newPdf.getNumberOfPages() > 0) {


			EDoc newDoc = new EDoc("","", newFilename, "", providerNo, doc.getDoccreator(), "", 'A', DateFormatUtils.format(new Date(), "yyyy-MM-dd"), "", "", "demographic", "-1",0);
			newDoc.setDocPublic("0");
			newDoc.setContentType("application/pdf");
			newDoc.setNumberOfPages(newPdf.getNumberOfPages());

			String newDocNo = EDocUtil.addDocumentSQL(newDoc);

			newPdf.save(docdownload + newDoc.getFileName());
			newPdf.close();


			WebApplicationContext ctx = WebApplicationContextUtils.getRequiredWebApplicationContext(request.getSession().getServletContext());
			ProviderInboxRoutingDao providerInboxRoutingDao = (ProviderInboxRoutingDao) ctx.getBean("providerInboxRoutingDAO");
			//providerInboxRoutingDao.addToProviderInbox("0", Integer.parseInt(newDocNo), "DOC");

			List<ProviderInboxItem> routeList = providerInboxRoutingDao.getProvidersWithRoutingForDocument("DOC", Integer.parseInt(docNum));
			for (ProviderInboxItem i : routeList) {
				providerInboxRoutingDao.addToProviderInbox(i.getProviderNo(), Integer.parseInt(newDocNo), "DOC");
			}

			providerInboxRoutingDao.addToProviderInbox(providerNo, Integer.parseInt(newDocNo), "DOC");

			QueueDocumentLinkDao queueDocumentLinkDAO = (QueueDocumentLinkDao) ctx.getBean("queueDocumentLinkDAO");
			Integer qid = queueId == null ? 1 : Integer.parseInt(queueId);
			Integer did= Integer.parseInt(newDocNo.trim());
			queueDocumentLinkDAO.addActiveQueueDocumentLink(qid, did);

			ProviderLabRoutingDao providerLabRoutingDao = (ProviderLabRoutingDao) SpringUtils.getBean("providerLabRoutingDao");

			List<ProviderLabRoutingModel> result = providerLabRoutingDao.getProviderLabRoutingDocuments(Integer.parseInt(docNum));
			if (!result.isEmpty()) {
				new ProviderLabRouting().route(newDocNo,
						   result.get(0).getProviderNo(),"DOC");
			}

			PatientLabRoutingDao patientLabRoutingDao = (PatientLabRoutingDao) SpringUtils.getBean("patientLabRoutingDao");
			List<PatientLabRouting> result2 = patientLabRoutingDao.findDocByDemographic(Integer.parseInt(docNum));

			if (!result2.isEmpty()) {
				PatientLabRouting newPatientRoute = new PatientLabRouting();

				newPatientRoute.setDemographicNo(result2.get(0).getDemographicNo());
				newPatientRoute.setLabNo(Integer.parseInt(newDocNo));
				newPatientRoute.setLabType("DOC");

				patientLabRoutingDao.persist(newPatientRoute);
			}

			CtlDocumentDao ctlDocumentDao = SpringUtils.getBean(CtlDocumentDao.class);
			CtlDocument result3 = ctlDocumentDao.getCtrlDocument(Integer.parseInt(docNum));

			if (result3!=null) {
				CtlDocumentPK ctlDocumentPK = new CtlDocumentPK(Integer.parseInt(newDocNo), "demographic");
				CtlDocument newCtlDocument = new CtlDocument();
				newCtlDocument.setId(ctlDocumentPK);
				newCtlDocument.getId().setModuleId(result3.getId().getModuleId());
				newCtlDocument.setStatus(result3.getStatus());
				documentDao.persist(newCtlDocument);
			}
			
			if( result.isEmpty() || result2.isEmpty() ) {
				String json = "{newDocNum:" + newDocNo + "}";
				JSONObject jsonObject = JSONObject.fromObject(json);
				response.setContentType("application/json");
				PrintWriter printWriter = response.getWriter();
				printWriter.print(jsonObject);
				printWriter.flush();
				return null;
								
			}


		}
		
		}catch( Exception e) {
			MiscUtils.getLogger().error(e.getMessage(),e);
			return null;
		}
		finally {
			try {
				
				if( pdf != null)  pdf.close();
				if( input != null ) input.close();
				
			}catch(IOException e ) {
				//do nothing
			}
		}

		return mapping.findForward("success");
	}

	public ActionForward rotate180(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
		Document doc = documentDao.getDocument(request.getParameter("document"));

		String docdownload = oscar.OscarProperties.getInstance().getProperty("DOCUMENT_DIR");
		String fileName = docdownload + doc.getDocfilename();

		FileInputStream input = new FileInputStream(fileName);
		PDFParser parser = new PDFParser(input);
		parser.parse();
		PDDocument pdf = parser.getPDDocument();
		File file = new File(fileName);
		setFilePermissions(file);
		int x = 1;
		for (Object p : pdf.getDocumentCatalog().getAllPages()) {
			PDPage pg = (PDPage)p;
			Integer r = (pg.getRotation() != null ? pg.getRotation() : 0);
			pg.setRotation((r+180)%360);

			ManageDocumentAction.deleteCacheVersion(doc, x);
			x++;
		}

		saveFile(pdf,fileName,input);

		return null;
	}

	public ActionForward rotate90(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
		Document doc = documentDao.getDocument(request.getParameter("document"));

		String docdownload = oscar.OscarProperties.getInstance().getProperty("DOCUMENT_DIR");
		String fileName = docdownload + doc.getDocfilename();

		FileInputStream input = new FileInputStream(fileName);
		PDFParser parser = new PDFParser(input);
		parser.parse();
		PDDocument pdf = parser.getPDDocument();
		File file = new File(fileName);
		setFilePermissions(file);
		int x = 1;
		for (Object p : pdf.getDocumentCatalog().getAllPages()) {
			PDPage pg = (PDPage)p;
			Integer r = (pg.getRotation() != null ? pg.getRotation() : 0);
			pg.setRotation((r+90)%360);

			ManageDocumentAction.deleteCacheVersion(doc, x);
			x++;
		}

		saveFile(pdf,fileName,input);

		return null;
	}

	public ActionForward removeFirstPage(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
		Document doc = documentDao.getDocument(request.getParameter("document"));

		String docdownload = oscar.OscarProperties.getInstance().getProperty("DOCUMENT_DIR");
		String fileName = docdownload + doc.getDocfilename();

		FileInputStream input = new FileInputStream(fileName);
		PDFParser parser = new PDFParser(input);
		parser.parse();
		PDDocument pdf = parser.getPDDocument();

		// Documents must have at least 2 pages, for the first page to be removed.
		if (pdf.getNumberOfPages() <= 1) { return null; }

		File file = new File(fileName);
		setFilePermissions(file);
		int x = 1;
		for (Object p : pdf.getDocumentCatalog().getAllPages()) {
			ManageDocumentAction.deleteCacheVersion(doc, x);
			x++;
		}
		pdf.removePage(0);
		if (saveFile(pdf, fileName, input)){
			// Only update the number of pages in the database if no exceptions are thrown
			EDocUtil.subtractOnePage(request.getParameter("document"));
		}

		return null;
	}

	/**
	 *
	 * @param pdf The pdf document
	 * @param fileName The file name string
	 * @param input The input stream
	 * @return A boolean value indicating if the file was successfully saved without errors
	 */
	private boolean saveFile(PDDocument pdf, String fileName, InputStream input) {
		ArrayList<String> errors = new ArrayList<String>();
		try {
			pdf.save(fileName);
		} catch (IOException ioe) {
			errors.add(ioe.getMessage());
			ioe.printStackTrace();
		} catch (COSVisitorException cve) {
			errors.add(cve.getMessage());
			cve.printStackTrace();
		} finally {
			try {
				if (pdf != null) pdf.close();
				if (input != null) input.close();
			} catch (IOException ioeClose) {
				errors.add(ioeClose.getMessage());
				ioeClose.printStackTrace();
			}
			if(errors.size()>0){
				for (String errorMessage : errors){
					MiscUtils.getLogger().error(errorMessage);
				}
				return false;
			}
			else{
				return true;
			}
		}
	}

	/**
	 * Sets file permissions for the file that is being modified.
	 *
	 * @param   file  A file
	 */
	private void setFilePermissions(File file){
		file.setWritable(true, false);
		file.setExecutable(true,false);
		file.setReadable(true, false);
	}
}