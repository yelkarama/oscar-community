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


package oscar.form.pdfservlet;

import java.io.ByteArrayOutputStream;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Properties;

import javax.servlet.ServletContext;
import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.io.FileUtils;

import net.sf.jasperreports.engine.JRException;
import net.sf.jasperreports.engine.JasperRunManager;
import net.sf.jasperreports.engine.data.JRBeanCollectionDataSource;

import org.apache.log4j.Logger;
import org.oscarehr.common.dao.FaxConfigDao;
import org.oscarehr.common.dao.FaxJobDao;
import org.oscarehr.common.model.FaxConfig;
import org.oscarehr.common.model.FaxJob;
import org.oscarehr.common.printing.FontSettings;
import org.oscarehr.common.printing.PdfWriterFactory;
import org.oscarehr.util.LocaleUtils;
import org.oscarehr.util.LoggedInInfo;
import org.oscarehr.util.MiscUtils;
import org.oscarehr.util.SpringUtils;
import org.oscarehr.web.PrescriptionQrCodeUIBean;

import oscar.OscarProperties;
import oscar.form.pdfservlet.FrmCustomedPDFServlet.EndPage;
import oscar.log.LogAction;
import oscar.log.LogConst;

import com.itextpdf.text.pdf.PdfReader;
import com.lowagie.text.Document;
import com.lowagie.text.DocumentException;
import com.lowagie.text.Element;
import com.lowagie.text.Font;
import com.lowagie.text.Image;
import com.lowagie.text.PageSize;
import com.lowagie.text.Paragraph;
import com.lowagie.text.Phrase;
import com.lowagie.text.Rectangle;
import com.lowagie.text.pdf.BaseFont;
import com.lowagie.text.pdf.ColumnText;
import com.lowagie.text.pdf.PdfContentByte;
import com.lowagie.text.pdf.PdfPTable;
import com.lowagie.text.pdf.PdfPageEventHelper;
import com.lowagie.text.pdf.PdfWriter;

public class FrmCustomedPDFServlet extends HttpServlet {

	public static final String HSFO_RX_DATA_KEY = "hsfo.rx.data";
	private static Logger logger = MiscUtils.getLogger();

	@Override
    public void service(HttpServletRequest req, HttpServletResponse res) throws javax.servlet.ServletException, java.io.IOException {

		ByteArrayOutputStream baosPDF = null;

		try {
			String method = req.getParameter("__method");
			boolean isFax = method.equals("oscarRxFax");
			baosPDF = generatePDFDocumentBytes(req, this.getServletContext());
			if (isFax) {
				res.setContentType("text/html");
				PrintWriter writer = res.getWriter();
				String faxNo = req.getParameter("pharmaFax").trim().replaceAll("\\D", "");
			    if (faxNo.length() < 7) {
					writer.println("<script>alert('Error: No fax number found!');window.close();</script>");
				} else {
		                	// write to file
		                	String pdfFile = "prescription_"+req.getParameter("pdfId")+".pdf";
		                	String path = OscarProperties.getInstance().getProperty("DOCUMENT_DIR") + "/";
		                	FileOutputStream fos = new FileOutputStream(path+pdfFile);
		                	baosPDF.writeTo(fos);
		                	fos.close();
		                	
		                	// write to file
		                	String tempPdf = System.getProperty("java.io.tmpdir")+"/prescription_"+req.getParameter("pdfId")+".pdf";
		                	// Copying the fax pdf.
							FileUtils.copyFile(new File(path+pdfFile), new File(tempPdf));

			                String txtFile = System.getProperty("java.io.tmpdir")+"/prescription_"+req.getParameter("pdfId")+".txt";
		                	FileWriter fstream = new FileWriter(txtFile);
		                	BufferedWriter out = new BufferedWriter(fstream);
			                try {
			                	out.write(faxNo);
		                    } finally {
		                    	if (out != null) out.close();
		                	}
		                	
			                String faxNumber = req.getParameter("clinicFax");
			                String demo = req.getParameter("demographic_no");
			                FaxJobDao faxJobDao = SpringUtils.getBean(FaxJobDao.class);
			                FaxConfigDao faxConfigDao = SpringUtils.getBean(FaxConfigDao.class);
			                List<FaxConfig> faxConfigs = faxConfigDao.findAll(null, null);
			                String provider_no = LoggedInInfo.getLoggedInInfoFromSession(req).getLoggedInProviderNo();
			                FaxJob faxJob;
			                boolean validFaxNumber = false;
			                
			                for( FaxConfig faxConfig : faxConfigs ) {
			                	
			                	if( faxConfig.getFaxNumber().equals(faxNumber) ) {
			                		
			                		PdfReader pdfReader = new PdfReader(path+pdfFile);
			                		
			                		faxJob = new FaxJob();
			                		faxJob.setDestination(faxNo);
			                		faxJob.setFax_line(faxNumber);
			                		faxJob.setFile_name(pdfFile);
			                		faxJob.setUser(faxConfig.getFaxUser());
			                		faxJob.setNumPages(pdfReader.getNumberOfPages());
			                		faxJob.setStamp(new Date());
			                		faxJob.setStatus(FaxJob.STATUS.SENT);
			                		faxJob.setOscarUser(provider_no);
			                		faxJob.setDemographicNo(Integer.parseInt(demo));
			                		
			                		faxJobDao.persist(faxJob);
			                		validFaxNumber = true;
			                		break;
			                		
			                	}
			                }
			                
			        if( validFaxNumber ) {
			        	
			        	LogAction.addLog(provider_no, LogConst.SENT, LogConst.CON_FAX, "PRESCRIPTION " + pdfFile );
			        	writer.println("<script>alert('Fax sent to: " + req.getParameter("pharmaName") + " (" + req.getParameter("pharmaFax") + ")');window.parent.clearPendingFax();</script>");
			        }
				}
			} else {
				StringBuilder sbFilename = new StringBuilder();
				sbFilename.append("filename_");
				sbFilename.append(".pdf");

				// set the Cache-Control header
				res.setHeader("Cache-Control", "max-age=0");
				res.setDateHeader("Expires", 0);

				res.setContentType("application/pdf");

				// The Content-disposition value will be inline
				StringBuilder sbContentDispValue = new StringBuilder();
				sbContentDispValue.append("inline; filename="); // inline - display
				// the pdf file
				// directly rather
				// than open/save
				// selection
				// sbContentDispValue.append("; filename=");
				sbContentDispValue.append(sbFilename);

				res.setHeader("Content-disposition", sbContentDispValue.toString());

				res.setContentLength(baosPDF.size());

				ServletOutputStream sos;

				sos = res.getOutputStream();

				baosPDF.writeTo(sos);

				sos.flush();
			}
		} catch (DocumentException dex) {
			res.setContentType("text/html");
			PrintWriter writer = res.getWriter();
			writer.println("Exception from: " + this.getClass().getName() + " " + dex.getClass().getName() + "<br>");
			writer.println("<pre>");
			writer.println(dex.getMessage());
			writer.println("</pre>");
		} catch (java.io.FileNotFoundException dex) {
		    res.setContentType("text/html");
		    PrintWriter writer = res.getWriter();
		    writer.println("<script>alert('Signature not found. Please sign the prescription.');</script>");
	    } finally {
			if (baosPDF != null) {
				baosPDF.reset();
			}
		}

	}

	// added by vic, hsfo
	private ByteArrayOutputStream generateHsfoRxPDF(HttpServletRequest req) {

		HsfoRxDataHolder rx = (HsfoRxDataHolder) req.getSession().getAttribute(HSFO_RX_DATA_KEY);

		JRBeanCollectionDataSource ds = new JRBeanCollectionDataSource(rx.getOutlines());
		InputStream is = Thread.currentThread().getContextClassLoader().getResourceAsStream("/oscar/form/prop/Hsfo_Rx.jasper");

		ByteArrayOutputStream baos = new ByteArrayOutputStream();
		try {
			JasperRunManager.runReportToPdfStream(is, baos, rx.getParams(), ds);
		} catch (JRException e) {
			throw new RuntimeException(e);
		}
		return baos;
	}

	/**
	 * the form txt file has lines in the form: For Checkboxes: ie. ohip : left, 76, 193, 0, BaseFont.ZAPFDINGBATS, 8, \u2713 requestParamName : alignment, Xcoord, Ycoord, 0, font, fontSize, textToPrint[if empty, prints the value of the request param]
	 * NOTE: the Xcoord and Ycoord refer to the bottom-left corner of the element For single-line text: ie. patientCity : left, 242, 261, 0, BaseFont.HELVETICA, 12 See checkbox explanation For multi-line text (textarea) ie. aci : left, 20, 308, 0,
	 * BaseFont.HELVETICA, 8, _, 238, 222, 10 requestParamName : alignment, bottomLeftXcoord, bottomLeftYcoord, 0, font, fontSize, _, topRightXcoord, topRightYcoord, spacingBtwnLines NOTE: When working on these forms in linux, it helps to load the PDF file
	 * into gimp, switch to pt. coordinate system and use the mouse to find the coordinates. Prepare to be bored!
	 */

	class EndPage extends PdfPageEventHelper {

		private String clinicName;
		private String clinicTel;
		private String clinicFax;
		private String patientPhone;
		private String patientCityPostal;
		private String patientAddress;
		private String patientName;
        private String patientDOB;
        private String patientHIN;
        private String patientChartNo;
        private String bandNumber;
        private String pracNo;
		private String sigDoctorName;
		private String MRP;
		private String rxDate;
		private String promoText;
		private String origPrintDate = null;
		private String numPrint = null;
		private String imgPath;
		private String electronicSignature;
		private String pharmaName;
		private String pharmaTel;
		private String pharmaFax;
		private String pharmaAddress1;
		private String pharmaAddress2;
		private String pharmaEmail;
		private String pharmaNote;
		private boolean pharmaShow;
                Locale locale = null;
                
		public EndPage() {
		}

        public EndPage(String clinicName, String clinicTel, String clinicFax, String patientPhone, String patientCityPostal, String patientAddress,
                String patientName,String patientDOB, String sigDoctorName, String MRP, String rxDate,String origPrintDate,String numPrint, String imgPath, String electronicSignature, String patientHIN, String patientChartNo, String bandNumber, String pracNo, String pharmaName, String pharmaAddress1, String pharmaAddress2, String pharmaTel, String pharmaFax, String pharmaEmail, String pharmaNote, boolean pharmaShow, Locale locale) {
			this.clinicName = clinicName==null ? "" : clinicName;
			this.clinicTel = clinicTel==null ? "" : clinicTel;
			this.clinicFax = clinicFax==null ? "" : clinicFax;
			this.patientPhone = patientPhone==null ? "" : patientPhone;
			this.patientCityPostal = patientCityPostal==null ? "" : patientCityPostal;
			this.patientAddress = patientAddress==null ? "" : patientAddress;
			this.patientName = patientName;
            this.patientDOB=patientDOB;
			this.sigDoctorName = sigDoctorName==null ? "" : sigDoctorName;
			this.MRP = MRP==null ? "" : MRP;
			this.rxDate = rxDate;
			this.promoText = OscarProperties.getInstance().getProperty("FORMS_PROMOTEXT");
			this.origPrintDate = origPrintDate;
			this.numPrint = numPrint;
			if (promoText == null) {
				promoText = "";
			}
			this.imgPath = imgPath;
			this.electronicSignature = electronicSignature;
			this.patientHIN = patientHIN==null ? "" : patientHIN;
			this.patientChartNo = patientChartNo==null ? "" : patientChartNo;
			this.bandNumber = bandNumber;
			this.pracNo = pracNo==null ? "" : pracNo;
			this.pharmaName = pharmaName==null ? "" : pharmaName;
			this.pharmaTel=pharmaTel==null ? "" : pharmaTel;
			this.pharmaFax=pharmaFax==null ? "" : pharmaFax;
			this.pharmaAddress1=pharmaAddress1==null ? "" : pharmaAddress1;
			this.pharmaAddress2=pharmaAddress2==null ? "" : pharmaAddress2;
			this.pharmaEmail=pharmaEmail==null ? "" : pharmaEmail;
			this.pharmaNote=pharmaNote==null ? "" : pharmaNote;
			this.pharmaShow=pharmaShow;
			this.locale = locale;
		}

		@Override
        public void onEndPage(PdfWriter writer, Document document) {
			renderPage(writer, document);
		}

		public void writeDirectContent(PdfContentByte cb, BaseFont bf, float fontSize, int alignment, String text, float x, float y, float rotation) {
			cb.beginText();
			cb.setFontAndSize(bf, fontSize);
			cb.showTextAligned(alignment, text, x, y, rotation);
			cb.endText();
		}
		public void writeDirectContentWrapText(PdfContentByte cb, BaseFont bf, float fontSize, int alignment, String text, float x, float y, float rotation) {
			cb.beginText();
			cb.setFontAndSize(bf, fontSize);
			// Split the note's text onto separate so it does not get cut off if it is too long
			int startNote = 0;
			int endNote = 0;
			for (int wrapPoint : findWrapPoints(text) ) {
				// Find wrap points of the long text to display them on separate lines
				float width = bf.getWidth(text.substring(startNote,wrapPoint)) / 1000 * fontSize;
				if (startNote < endNote && width > x) {
					// Write out each line lower than the previous
					cb.moveText(15, y);
					cb.showTextAligned(alignment, text.substring(startNote,endNote), x, y, rotation);
					y += (bf.getDescentPoint(text.substring(wrapPoint), fontSize) - (bf.getAscentPoint(text.substring(wrapPoint), fontSize)));
					startNote = endNote;
				}
				endNote = wrapPoint;
			}
			// Write out last line
			cb.moveText(10, y);
			cb.showTextAligned(alignment, text.substring(startNote), x, y, rotation);
			cb.endText();
		}

		private int[] findWrapPoints(String text) {
			String[] lines = text.split("(?<=\\W)");
			int[] wrapPoints = new int[lines.length];
			wrapPoints[0] = lines[0].length();
			for (int i = 1 ; i < lines.length ; i++){
				wrapPoints[i] = wrapPoints[i-1] + lines[i].length();
			}
			return wrapPoints;
		}
		
		private String geti18nTagValue(Locale locale, String tag) {
			return LocaleUtils.getMessage(locale,tag);
		}
		
		public void renderPage(PdfWriter writer, Document document) {
			Rectangle page = document.getPageSize();
			PdfContentByte cb = writer.getDirectContent();

			try {


				float height = page.getHeight();
                BaseFont bf = BaseFont.createFont(BaseFont.HELVETICA, BaseFont.CP1252, BaseFont.NOT_EMBEDDED);
                // get the end of paragraph
                float endPara = writer.getVerticalPosition(true);
                if (writer.getPageNumber() == 1 && OscarProperties.getInstance().getBooleanProperty("queens_fax_cover_page", "true"))
                {
                    writeDirectContent(cb, bf, 50, PdfContentByte.ALIGN_LEFT, "Fax Message", 24, page.getHeight() - 73, 0);
                    writeDirectContent(cb, bf, 12, PdfContentByte.ALIGN_LEFT, "Recipient: " + this.clinicName, 24, page.getHeight() - 110, 0);
                    writeDirectContent(cb, bf, 12, PdfContentByte.ALIGN_LEFT, "Phone Number: " + this.clinicTel, 24, page.getHeight() - 126, 0);
                    writeDirectContent(cb, bf, 12, PdfContentByte.ALIGN_LEFT, "Fax Number: " + this.clinicFax, 24, page.getHeight() - 144, 0);
                    writeDirectContent(cb, bf, 12, PdfContentByte.ALIGN_LEFT, "Subject: Prescription for " + this.patientName, 24, page.getHeight() - 160, 0);

                    writeDirectContent(cb, bf, 12, PdfContentByte.ALIGN_LEFT, "The information contained in this electronic message and any attachments to this", 24, endPara - 40, 0);
                    writeDirectContent(cb, bf, 12, PdfContentByte.ALIGN_LEFT, "message are intended for the exclusive use of the addressee(s) and my contain", 24, endPara - 56, 0);
                    writeDirectContent(cb, bf, 12, PdfContentByte.ALIGN_LEFT, "confidential or privileged information. If the reader of this message is not the", 24, endPara - 72, 0);
                    writeDirectContent(cb, bf, 12, PdfContentByte.ALIGN_LEFT, "intended recipient, or the agent responsible to deliver it to the intended recipient,", 24, endPara - 88, 0);
                    writeDirectContent(cb, bf, 12, PdfContentByte.ALIGN_LEFT, "you are hereby notified that any review, retransmission, dissemination or other use", 24, endPara - 104, 0);
                    writeDirectContent(cb, bf, 12, PdfContentByte.ALIGN_LEFT, "of this communication is prohibited. If you received this in error, please contact ", 24, endPara - 120, 0);
                    writeDirectContent(cb, bf, 12, PdfContentByte.ALIGN_LEFT, "the Queen’s Family Health Team Clinic Manager at 613-533-9300 x 73983 and then ", 24, endPara - 136, 0);
                    writeDirectContent(cb, bf, 12, PdfContentByte.ALIGN_LEFT, "destroy all copies of this fax message.", 24, endPara - 152, 0);

                }
                else {
                    boolean showPatientDOB=false;
					//head.writeSelectedRows(0, 1,document.leftMargin(), page.height() - document.topMargin()+ head.getTotalHeight(),writer.getDirectContent());
					if(this.patientDOB!=null && this.patientDOB.length()>0){
						showPatientDOB=true;
					}
					//header table for patient's information.
					PdfPTable head = new PdfPTable(1);
					String newline = System.getProperty("line.separator");
					StringBuilder hStr = new StringBuilder(this.patientName);
					if(showPatientDOB){
						 hStr.append("   "+geti18nTagValue(locale, "RxPreview.msgDOB")+":").append(this.patientDOB);
					}
					hStr.append(newline).append(this.patientAddress).append(newline).append(this.patientCityPostal).append(newline).append(this.patientPhone);
					
					if (patientHIN != null && patientHIN.trim().length() > 0) { 
						hStr.append(newline).append(geti18nTagValue(locale, "oscar.oscarRx.hin")+" ").append(patientHIN); 
					}

					if (patientChartNo != null && !patientChartNo.isEmpty()) {
						String chartNoTitle = geti18nTagValue(locale, "oscar.oscarRx.chartNo") ;
						hStr.append(newline).append(chartNoTitle).append(patientChartNo);
					}
					
					if( bandNumber != null && ! bandNumber.isEmpty() ) {
						String bandNumberTitle = org.oscarehr.util.LocaleUtils.getMessage(locale, "oscar.oscarRx.bandNumber");
						 hStr.append(newline).append(bandNumberTitle).append(bandNumber);
					}
                                
					Phrase hPhrase = new Phrase(hStr.toString(), new Font(bf, 10));
					head.addCell(hPhrase);
					head.setTotalWidth(272f);
					head.writeSelectedRows(0, -1, 13f, height - 100f, cb);

					bf = BaseFont.createFont(BaseFont.TIMES_ROMAN, BaseFont.CP1252, BaseFont.NOT_EMBEDDED);
					writeDirectContent(cb, bf, 12, PdfContentByte.ALIGN_LEFT, "o s c a r", 21, page.getHeight() - 60, 90);
					// draw R
					writeDirectContent(cb, bf, 50, PdfContentByte.ALIGN_LEFT, "P", 24, page.getHeight() - 53, 0);

					bf = BaseFont.createFont(BaseFont.HELVETICA, BaseFont.CP1252, BaseFont.NOT_EMBEDDED);
					// draw X
					writeDirectContent(cb, bf, 43, PdfContentByte.ALIGN_LEFT, "X", 38, page.getHeight() - 69, 0);

					bf = BaseFont.createFont(BaseFont.HELVETICA_BOLD, BaseFont.CP1252, BaseFont.NOT_EMBEDDED);
					writeDirectContent(cb, bf, 10, PdfContentByte.ALIGN_LEFT, this.sigDoctorName, 80, (page.getHeight() - 25), 0);
					
					bf = BaseFont.createFont(BaseFont.HELVETICA, BaseFont.CP1252, BaseFont.NOT_EMBEDDED);
					int fontFlags = Font.NORMAL;
					Font font = new Font(bf, 10, fontFlags);
					ColumnText ct = new ColumnText(cb);
					ct.setSimpleColumn(80, (page.getHeight() - 25), 280, (page.getHeight() - 90), 11, Element.ALIGN_LEFT);
					// p("value of clinic name", this.clinicName);
					ct.setText(new Phrase(12, clinicName+(pracNo.trim().length()>0 ? "\r\n"+geti18nTagValue(locale, "RxPreview.PractNo")+": "+ pracNo : ""), font));ct.go();
					// render clinicTel;
					int diff = (this.clinicTel.length() - 12)*2;
					writeDirectContent(cb, bf, 10, PdfContentByte.ALIGN_LEFT, geti18nTagValue(locale, "RxPreview.msgTel")+":" + this.clinicTel, 188 - diff, (page.getHeight() - 70), 0);
					// render clinicFax;
					writeDirectContent(cb, bf, 10, PdfContentByte.ALIGN_LEFT, geti18nTagValue(locale, "RxPreview.msgFax")+":" + this.clinicFax, 188 - diff, (page.getHeight() - 80), 0);
					writeDirectContent(cb, bf, 10, PdfContentByte.ALIGN_LEFT, this.rxDate, 188 - diff, (page.getHeight() - 90), 0);
					
					if (this.pharmaShow) {
						writeDirectContent(cb,bf,10,PdfContentByte.ALIGN_LEFT,this.pharmaName,290,(page.getHeight()-30),0);
						writeDirectContent(cb,bf,10,PdfContentByte.ALIGN_LEFT,this.pharmaAddress1,290,(page.getHeight()-42),0);
						writeDirectContent(cb,bf,10,PdfContentByte.ALIGN_LEFT,this.pharmaAddress2,290,(page.getHeight()-54),0);
						writeDirectContent(cb,bf,10,PdfContentByte.ALIGN_LEFT,"Tel:" + this.pharmaTel,290,(page.getHeight()-66),0);
						writeDirectContent(cb,bf,10,PdfContentByte.ALIGN_LEFT,"Fax:" + this.pharmaFax,290,(page.getHeight()-78),0);
						writeDirectContent(cb,bf,10,PdfContentByte.ALIGN_LEFT,"Email:" + this.pharmaEmail,290,(page.getHeight()-90),0);
						writeDirectContentWrapText(cb,bf,10,PdfContentByte.ALIGN_LEFT,"Note:" + this.pharmaNote,290,(page.getHeight()-102),0);
					}
					// get the end of paragraph
					endPara = writer.getVerticalPosition(true) + 30;
					if (document.getPageSize().getWidth() == PageSize.A6.getWidth() && document.getPageSize().getHeight() == PageSize.A6.getHeight()) {
						endPara = endPara + 10;
					}
					// draw left line
					cb.setRGBColorStrokeF(0f, 0f, 0f);
					cb.setLineWidth(0.5f);
					// cb.moveTo(13f, 20f);
					cb.moveTo(13f, endPara - 110);
					cb.lineTo(13f, height - 15f);
					cb.stroke();

					// draw right line 285, 20, 285, 405, 0.5
					cb.setRGBColorStrokeF(0f, 0f, 0f);
					cb.setLineWidth(0.5f);
					// cb.moveTo(285f, 20f);
					cb.moveTo(285f, endPara - 110);
					cb.lineTo(285f, height - 15f);
					cb.stroke();
					// draw top line 10, 405, 285, 405, 0.5
					cb.setRGBColorStrokeF(0f, 0f, 0f);
					cb.setLineWidth(0.5f);
					cb.moveTo(13f, height - 15f);
					cb.lineTo(285f, height - 15f);
					cb.stroke();

					// draw bottom line 10, 20, 285, 20, 0.5
					cb.setRGBColorStrokeF(0f, 0f, 0f);
					cb.setLineWidth(0.5f);
					// cb.moveTo(13f, 20f);
					// cb.lineTo(285f, 20f);
					cb.moveTo(13f, endPara - 110);
					cb.lineTo(285f, endPara - 110);
					cb.stroke();
					// Render "Signature:"
					writeDirectContent(cb, bf, 10, PdfContentByte.ALIGN_LEFT, geti18nTagValue(locale, "RxPreview.msgSignature"), 20f, endPara - 60f, 0);// Render line for Signature 75, 55, 280, 55, 0.5
					cb.setRGBColorStrokeF(0f, 0f, 0f);
					cb.setLineWidth(0.5f);
					// cb.moveTo(75f, 50f);
					// cb.lineTo(280f, 50f);
					cb.moveTo(75f, endPara - 60f);
					cb.lineTo(280f, endPara - 60f);
					cb.stroke();

					if (this.imgPath != null && !this.imgPath.equals("")) {
						Image img = Image.getInstance(this.imgPath);
						// image, image_width, 0, 0, image_height, x, y
						//         131, 55, 375, 75, 0
						cb.addImage(img, 150, 0, 0, 40, 100f, endPara-55f);
					} else if (this.electronicSignature != null && !this.electronicSignature.equals("")) {
						//PdfContentByte
						String[] lines = this.electronicSignature.split(System.getProperty("line.separator"));
						writeDirectContent(cb, bf, 8, PdfContentByte.ALIGN_LEFT, lines[0], 72f, endPara - 48f, 0);
						writeDirectContent(cb, bf, 8, PdfContentByte.ALIGN_LEFT, lines[1], 72f, endPara - 57f, 0);
					}

					// Render doctor name
					bf = BaseFont.createFont(BaseFont.HELVETICA_BOLD, BaseFont.CP1252, BaseFont.NOT_EMBEDDED);
					writeDirectContent(cb, bf, 8, PdfContentByte.ALIGN_LEFT, "Req. Physician: " + this.sigDoctorName, 20f, endPara - 78f, 0);
					writeDirectContent(cb, bf, 8, PdfContentByte.ALIGN_LEFT, "MRP: " + this.MRP, 20f,endPara - 88f, 0);
					bf = BaseFont.createFont(BaseFont.HELVETICA, BaseFont.CP1252, BaseFont.NOT_EMBEDDED);
					// public void writeDirectContent(PdfContentByte cb, BaseFont bf, float fontSize, int alignment, String text, float x, float y, float rotation)
					// render reprint origPrintDate and numPrint
					if (origPrintDate != null && numPrint != null) {
						String rePrintStr = geti18nTagValue(locale, "RxPreview.msgReprintBy")+" " + this.sigDoctorName + "; "+geti18nTagValue(locale, "RxPreview.msgOrigPrinted")+": " + origPrintDate + "; "+geti18nTagValue(locale, "RxPreview.msgTimesPrinted") +": " + numPrint;writeDirectContent(cb, bf, 6, PdfContentByte.ALIGN_LEFT, rePrintStr, 45, endPara - 67, 0);
					}
					// print promoText
					writeDirectContent(cb, bf, 6, PdfContentByte.ALIGN_LEFT, this.promoText, 70, endPara - 102, 0);
					// print page number
					String footer = "" + writer.getPageNumber();
					writeDirectContent(cb, bf, 10, PdfContentByte.ALIGN_RIGHT, footer, 280, endPara - 102, 0);
                }
			} catch (Exception e) {
				logger.error("Error", e);
			}
		}
	}

	private HashMap<String,String> parseSCAddress(String s) {
		HashMap<String,String> hm = new HashMap<String,String>();
		String[] ar = s.split("</b>");
		String[] ar2 = ar[1].split("<br>");
		ArrayList<String> lst = new ArrayList<String>(Arrays.asList(ar2));
		lst.remove(0);
		String tel = lst.get(3);
		tel = tel.replace("Tel: ", "");
		String fax = lst.get(4);
		fax = fax.replace("Fax: ", "");
		String clinicName = lst.get(0) + "\n" + lst.get(1) + "\n" + lst.get(2);
		logger.debug(tel);
		logger.debug(fax);
		logger.debug(clinicName);
		hm.put("clinicName", clinicName);
		hm.put("clinicTel", tel);
		hm.put("clinicFax", fax);

		return hm;

	}

	protected ByteArrayOutputStream generatePDFDocumentBytes(final HttpServletRequest req, final ServletContext ctx) throws DocumentException {
		logger.debug("***in generatePDFDocumentBytes2 FrmCustomedPDFServlet.java***");

		LoggedInInfo loggedInInfo=LoggedInInfo.getLoggedInInfoFromSession(req);
		
		// added by vic, hsfo
		Enumeration<String> em = req.getParameterNames();
		while (em.hasMoreElements()) {
			logger.debug("para=" + em.nextElement());
		}
		em = req.getAttributeNames();
		while (em.hasMoreElements())
			logger.debug("attr: " + em.nextElement());

		if (HSFO_RX_DATA_KEY.equals(req.getParameter("__title"))) {
			return generateHsfoRxPDF(req);
		}
		String newline = System.getProperty("line.separator");

		ByteArrayOutputStream baosPDF = new ByteArrayOutputStream();
		PdfWriter writer = null;
		String method = req.getParameter("__method");
		String origPrintDate = null;
		String numPrint = null;
		if (method != null && method.equalsIgnoreCase("rePrint")) {
			origPrintDate = req.getParameter("origPrintDate");
			numPrint = req.getParameter("numPrints");
		}

		logger.debug("method in generatePDFDocumentBytes " + method);
		String clinicName;
		String clinicTel;
		String clinicFax;
		// check if satellite clinic is used
		String useSatelliteClinic = req.getParameter("useSC");
		logger.debug(useSatelliteClinic);
		if (useSatelliteClinic != null && useSatelliteClinic.equalsIgnoreCase("true")) {
			String scAddress = req.getParameter("scAddress");
			logger.debug("clinic detail" + "=" + scAddress);
			HashMap<String,String> hm = parseSCAddress(scAddress);
			clinicName =  hm.get("clinicName");
			clinicTel = hm.get("clinicTel");
			clinicFax = hm.get("clinicFax");
		} else {
			// parameters need to be passed to header and footer
			clinicName = req.getParameter("clinicName");
			logger.debug("clinicName" + "=" + clinicName);
			clinicTel = req.getParameter("clinicPhone");
			clinicFax = req.getParameter("clinicFax");
		}
		String patientPhone = req.getParameter("patientPhone");
		String patientCityPostal = req.getParameter("patientCityPostal");
		String patientAddress = req.getParameter("patientAddress");
		String patientName = req.getParameter("patientName");
		String sigDoctorName = req.getParameter("sigDoctorName");
		String MRP = req.getParameter("MRP");
		String rxDate = req.getParameter("rxDate");
		String rx = req.getParameter("rx");
        String patientDOB=req.getParameter("patientDOB");
        String showPatientDOB=req.getParameter("showPatientDOB");
        String imgFile=req.getParameter("imgFile");
        String electronicSignature = req.getParameter("electronicSignature");
        String patientHIN=req.getParameter("patientHIN");
        String patientChartNo = req.getParameter("patientChartNo");
        String patientBandNumber = req.getParameter("bandNumber");
        String pracNo=req.getParameter("pracNo");
        String pharmaName = req.getParameter("pharmaName");
        String pharmaAddress1 = req.getParameter("pharmaAddress1");
        String pharmaAddress2 = req.getParameter("pharmaAddress2");
        String pharmaTel = req.getParameter("pharmaTel");
        String pharmaFax = req.getParameter("pharmaFax");
        String pharmaEmail = req.getParameter("pharmaEmail");
        String pharmaNote = req.getParameter("pharmaNote");
        boolean pharmaShow = (req.getParameter("pharmaShow").equals("true")?true:false);
        Locale locale = req.getLocale();


		if (clinicName==null) clinicName = "";
		if (clinicTel==null) clinicTel = "";
		if (clinicFax==null) clinicFax = "";
		if (patientPhone==null) patientPhone = "";
		if (patientCityPostal==null) patientCityPostal = "";
		if (patientAddress==null) patientAddress = "";
		if (sigDoctorName==null) sigDoctorName = "";
        if (patientHIN==null) patientHIN = "";
        if (patientChartNo==null) patientChartNo = "";
        if (pracNo==null) pracNo = "";
        
        boolean isShowDemoDOB=false;
        if(showPatientDOB!=null&&showPatientDOB.equalsIgnoreCase("true")){
            isShowDemoDOB=true;
        }
        if(!isShowDemoDOB)
            patientDOB="";
		if (rx == null) {
			rx = "";
		}

		String additNotes = req.getParameter("additNotes");
		String[] rxA = rx.split(newline);
		List<String> listRx = new ArrayList<String>();
		String listElem = "";
		// parse rx and put into a list of rx;
		for (String s : rxA) {

			if (s.equals("") || s.equals(newline) || s.length() == 1) {
				listRx.add(listElem);
				listElem = "";
			} else {
				listElem = listElem + s;
				listElem += newline;
			}

		}
		if (!listElem.equals("")) { listRx.add(listElem); }

		// get the print prop values
		Properties props = new Properties();
		StringBuilder temp = new StringBuilder();
		for (Enumeration<String> e = req.getParameterNames(); e.hasMoreElements();) {
			temp = new StringBuilder(e.nextElement().toString());
			props.setProperty(temp.toString(), req.getParameter(temp.toString()));
		}

		for (Enumeration<String> e = req.getAttributeNames(); e.hasMoreElements();) {
			temp = new StringBuilder(e.nextElement().toString());
			props.setProperty(temp.toString(), req.getAttribute(temp.toString()).toString());
		}
		Document document = new Document();

		try {
			String title = req.getParameter("__title") != null ? req.getParameter("__title") : "Unknown";

			// A0-A10, LEGAL, LETTER, HALFLETTER, _11x17, LEDGER, NOTE, B0-B5, ARCH_A-ARCH_E, FLSA
			// and FLSE
			// the following shows a temp way to get a print page size
			Rectangle pageSize = PageSize.LETTER;
			String pageSizeParameter = req.getParameter("rxPageSize");
			if (pageSizeParameter != null) {
				if ("PageSize.HALFLETTER".equals(pageSizeParameter)) {
					pageSize = PageSize.HALFLETTER;
				} else if ("PageSize.A6".equals(pageSizeParameter)) {
					pageSize = PageSize.A6;
				} else if ("PageSize.A4".equals(pageSizeParameter)) {
					pageSize = PageSize.A4;
				}
			}

			document.setPageSize(pageSize);
			// 285=left margin+width of box, 5f is space for looking nice
			document.setMargins(15, pageSize.getWidth() - 285f + 5f, 180, 60);// left, right, top , bottom

			// writer = PdfWriter.getInstance(document, baosPDF);
			writer = PdfWriterFactory.newInstance(document, baosPDF, FontSettings.HELVETICA_10PT);
			writer.setPageEvent(new EndPage(clinicName, clinicTel, clinicFax, patientPhone, patientCityPostal, patientAddress, patientName,patientDOB, sigDoctorName, MRP, rxDate, origPrintDate, numPrint, imgFile, electronicSignature, patientHIN, patientChartNo, patientBandNumber, pracNo, pharmaName, pharmaAddress1, pharmaAddress2, pharmaTel, pharmaFax, pharmaEmail, pharmaNote, pharmaShow, locale));
			document.addTitle(title);
			document.addSubject("");
			document.addKeywords("pdf, itext");
			document.addCreator("OSCAR");
			document.addAuthor("");
			document.addHeader("Expires", "0");

			document.open();
			BaseFont bf = BaseFont.createFont(BaseFont.HELVETICA, BaseFont.CP1252, BaseFont.NOT_EMBEDDED);
			Paragraph p = new Paragraph(new Phrase(" ", new Font(bf, 10)));
			if (OscarProperties.getInstance().getBooleanProperty("queens_fax_cover_page", "true")) {
				document.newPage();
				// render prescriptions
				p = new Paragraph(new Phrase(" ", new Font(bf, 10)));
				p.setKeepTogether(true);
				p.setSpacingBefore(5f);
				document.add(p);
			}
			document.newPage();

			PdfContentByte cb = writer.getDirectContent();

			cb.setRGBColorStroke(0, 0, 255);
			// render prescriptions
			for (String rxStr : listRx) {
				p = new Paragraph(new Phrase(rxStr, new Font(bf, 10)));
				p.setKeepTogether(true);
				p.setSpacingBefore(5f);
				document.add(p);
			}
			// render additional notes
			if (additNotes != null && !additNotes.equals("")) {
				p = new Paragraph(new Phrase(additNotes, new Font(bf, 10)));
				p.setKeepTogether(true);
				p.setSpacingBefore(10f);
				document.add(p);
			}

			// render QrCode
			if (PrescriptionQrCodeUIBean.isPrescriptionQrCodeEnabledForProvider(loggedInInfo.getLoggedInProviderNo()))
			{
				Integer scriptId=Integer.parseInt(req.getParameter("scriptId"));
				byte[] qrCodeImage=PrescriptionQrCodeUIBean.getPrescriptionHl7QrCodeImage(scriptId);
				Image qrCode=Image.getInstance(qrCodeImage);
				document.add(qrCode);
			}
		}
		catch (DocumentException dex) {
			baosPDF.reset();
			throw dex;
		} catch (Exception e) {
			logger.error("Error", e);
		} finally {
			if (document != null) {
				document.close();
			}
			if (writer != null) {
				writer.close();
			}
		}
		logger.debug("***END in generatePDFDocumentBytes2 FrmCustomedPDFServlet.java***");
		return baosPDF;
	}
}
