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

import com.lowagie.text.BadElementException;
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
import com.lowagie.text.pdf.PdfGState;
import com.lowagie.text.pdf.PdfPTable;
import com.lowagie.text.pdf.PdfPageEventHelper;
import com.lowagie.text.pdf.PdfTemplate;
import com.lowagie.text.pdf.PdfWriter;
import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;
import org.oscarehr.common.dao.RxManageDao;
import org.oscarehr.common.model.RxManage;
import org.oscarehr.common.printing.FontSettings;
import org.oscarehr.common.printing.PdfWriterFactory;
import org.oscarehr.util.LocaleUtils;
import org.oscarehr.util.LoggedInInfo;
import org.oscarehr.util.MiscUtils;
import org.oscarehr.util.SpringUtils;
import org.oscarehr.web.PrescriptionQrCodeUIBean;
import oscar.OscarProperties;

import java.io.ByteArrayOutputStream;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;

public class FrmCustomedPDFGenerator {
    
	public static final String HSFO_RX_DATA_KEY = "hsfo.rx.data";
	private static Logger logger = MiscUtils.getLogger();
	private float endPara = 0;


    /**
     * the form txt file has lines in the form: For Checkboxes: ie. ohip : left, 76, 193, 0, BaseFont.ZAPFDINGBATS, 8, \u2713 requestParamName : alignment, Xcoord, Ycoord, 0, font, fontSize, textToPrint[if empty, prints the value of the request param]
     * NOTE: the Xcoord and Ycoord refer to the bottom-left corner of the element For single-line text: ie. patientCity : left, 242, 261, 0, BaseFont.HELVETICA, 12 See checkbox explanation For multi-line text (textarea) ie. aci : left, 20, 308, 0,
     * BaseFont.HELVETICA, 8, _, 238, 222, 10 requestParamName : alignment, bottomLeftXcoord, bottomLeftYcoord, 0, font, fontSize, _, topRightXcoord, topRightYcoord, spacingBtwnLines NOTE: When working on these forms in linux, it helps to load the PDF file
     * into gimp, switch to pt. coordinate system and use the mouse to find the coordinates. Prepare to be bored!
     */

    class EndPage extends PdfPageEventHelper {

        private FrmCustomedPDFParameters pdfParameters;
        private Locale locale = null;


        public EndPage() {
        }

        public EndPage(FrmCustomedPDFParameters pdfParameters, Locale locale) {
            this.pdfParameters = pdfParameters;
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

            RxManageDao rxManageDao = SpringUtils.getBean(RxManageDao.class);
            RxManage rxManage = rxManageDao.getRxManageAttributes();
            Boolean mrpRx = rxManage!=null?rxManage.getMrpOnRx(): true;

            try {


                float height = page.getHeight();
                BaseFont bf = BaseFont.createFont(BaseFont.HELVETICA, BaseFont.CP1252, BaseFont.NOT_EMBEDDED);
                // get the end of paragraph
                endPara = writer.getVerticalPosition(true);
                if (writer.getPageNumber() == 1 && OscarProperties.getInstance().getBooleanProperty("queens_fax_cover_page", "true")) {
                    writeDirectContent(cb, bf, 50, PdfContentByte.ALIGN_LEFT, "Fax Message", 24, page.getHeight() - 73, 0);
                    writeDirectContent(cb, bf, 12, PdfContentByte.ALIGN_LEFT, "Recipient: " + pdfParameters.getClinicName(), 24, page.getHeight() - 110, 0);
                    writeDirectContent(cb, bf, 12, PdfContentByte.ALIGN_LEFT, "Phone Number: " + pdfParameters.getClinicPhone(), 24, page.getHeight() - 126, 0);
                    writeDirectContent(cb, bf, 12, PdfContentByte.ALIGN_LEFT, "Fax Number: " + pdfParameters.getClinicFax(), 24, page.getHeight() - 144, 0);
                    writeDirectContent(cb, bf, 12, PdfContentByte.ALIGN_LEFT, "Subject: Prescription for " + pdfParameters.getPatientName(), 24, page.getHeight() - 160, 0);

                    writeDirectContent(cb, bf, 12, PdfContentByte.ALIGN_LEFT, "The information contained in this electronic message and any attachments to this", 24, endPara - 40, 0);
                    writeDirectContent(cb, bf, 12, PdfContentByte.ALIGN_LEFT, "message are intended for the exclusive use of the addressee(s) and my contain", 24, endPara - 56, 0);
                    writeDirectContent(cb, bf, 12, PdfContentByte.ALIGN_LEFT, "confidential or privileged information. If the reader of this message is not the", 24, endPara - 72, 0);
                    writeDirectContent(cb, bf, 12, PdfContentByte.ALIGN_LEFT, "intended recipient, or the agent responsible to deliver it to the intended recipient,", 24, endPara - 88, 0);
                    writeDirectContent(cb, bf, 12, PdfContentByte.ALIGN_LEFT, "you are hereby notified that any review, retransmission, dissemination or other use", 24, endPara - 104, 0);
                    writeDirectContent(cb, bf, 12, PdfContentByte.ALIGN_LEFT, "of this communication is prohibited. If you received this in error, please contact ", 24, endPara - 120, 0);
                    writeDirectContent(cb, bf, 12, PdfContentByte.ALIGN_LEFT, "the Queen’s Family Health Team Clinic Manager at 613-533-9300 x 73983 and then ", 24, endPara - 136, 0);
                    writeDirectContent(cb, bf, 12, PdfContentByte.ALIGN_LEFT, "destroy all copies of this fax message.", 24, endPara - 152, 0);

                } else {
                    //header table for patient's information.
                    PdfPTable head = new PdfPTable(1);
                    String newline = System.getProperty("line.separator");
                    StringBuilder hStr = new StringBuilder(pdfParameters.getPatientName());
                    String today = oscar.oscarRx.util.RxUtil.DateToString(new Date(), "MMMM d, yyyy");
                    if(pdfParameters.getShowPatientDOB()){
                        hStr.append("   "+geti18nTagValue(locale, "RxPreview.msgDOB")+":").append(pdfParameters.getPatientDOB());
                    }
                    hStr.append(newline).append(pdfParameters.getPatientAddress()).append(newline)
                            .append(pdfParameters.getPatientCityPostal()).append(newline).append(pdfParameters.getPatientPhone());

                    if (!pdfParameters.getPatientHIN().isEmpty()) {
                        hStr.append(newline).append(geti18nTagValue(locale, "oscar.oscarRx.hin")+" ").append(pdfParameters.getPatientHIN());
                    }

                    if (!pdfParameters.getPatientChartNo().isEmpty()) {
                        String chartNoTitle = geti18nTagValue(locale, "oscar.oscarRx.chartNo") ;
                        hStr.append(newline).append(chartNoTitle).append(pdfParameters.getPatientChartNo());
                    }

                    if(!pdfParameters.getBandNumber().isEmpty() ) {
                        String bandNumberTitle = org.oscarehr.util.LocaleUtils.getMessage(locale, "oscar.oscarRx.bandNumber");
                        hStr.append(newline).append(bandNumberTitle).append(pdfParameters.getBandNumber());
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
                    writeDirectContent(cb, bf, 10, PdfContentByte.ALIGN_LEFT, pdfParameters.getSigDoctorName(), 80, (page.getHeight() - 25), 0);

                    bf = BaseFont.createFont(BaseFont.HELVETICA, BaseFont.CP1252, BaseFont.NOT_EMBEDDED);
                    int fontFlags = Font.NORMAL;
                    Font font = new Font(bf, 10, fontFlags);
                    ColumnText ct = new ColumnText(cb);
                    ct.setSimpleColumn(80, (page.getHeight() - 25), 280, (page.getHeight() - 90), 11, Element.ALIGN_LEFT);
                    // p("value of clinic name", this.clinicName);
                    ct.setText(new Phrase(12, pdfParameters.getClinicName() + (!pdfParameters.getPracNo().isEmpty() ? "\r\n"+geti18nTagValue(locale, "RxPreview.PractNo") + ": " + pdfParameters.getPracNo() : ""), font));
                    ct.go();
                    // render clinicTel;
                    int diff = (pdfParameters.getClinicPhone().length() - 12)*2;
                    writeDirectContent(cb, bf, 10, PdfContentByte.ALIGN_LEFT, geti18nTagValue(locale, "RxPreview.msgTel")+":" + pdfParameters.getClinicPhone(), 188 - diff, (page.getHeight() - 70), 0);
                    // render clinicFax;
                    writeDirectContent(cb, bf, 10, PdfContentByte.ALIGN_LEFT, geti18nTagValue(locale, "RxPreview.msgFax")+":" + pdfParameters.getClinicFax(), 188 - diff, (page.getHeight() - 80), 0);
                    writeDirectContent(cb, bf, 10, PdfContentByte.ALIGN_LEFT, pdfParameters.getRxDate(), 188 - diff, (page.getHeight() - 90), 0);

                    if (pdfParameters.getPharmaShow()) {
                        writeDirectContent(cb,bf,10,PdfContentByte.ALIGN_LEFT, pdfParameters.getPharmaName(),290,(page.getHeight()-30),0);
                        writeDirectContent(cb,bf,10,PdfContentByte.ALIGN_LEFT, pdfParameters.getPharmaAddress1(),290,(page.getHeight()-42),0);
                        writeDirectContent(cb,bf,10,PdfContentByte.ALIGN_LEFT, pdfParameters.getPharmaAddress2(),290,(page.getHeight()-54),0);
                        writeDirectContent(cb,bf,10,PdfContentByte.ALIGN_LEFT, "Tel:" + pdfParameters.getPharmaTel(),290,(page.getHeight()-66),0);
                        writeDirectContent(cb,bf,10,PdfContentByte.ALIGN_LEFT, "Fax:" + pdfParameters.getPharmaFax(),290,(page.getHeight()-78),0);
                        writeDirectContent(cb,bf,10,PdfContentByte.ALIGN_LEFT, "Email:" + pdfParameters.getPharmaEmail(),290,(page.getHeight()-90),0);
                        writeDirectContentWrapText(cb,bf,10,PdfContentByte.ALIGN_LEFT,"Note:" + pdfParameters.getPharmaNote(),290,(page.getHeight()-102),0);
                    }
                    // get the end of paragraph
                    endPara = writer.getVerticalPosition(true) + 30;
                    // draw left line
                    cb.setRGBColorStrokeF(0f, 0f, 0f);
                    cb.setLineWidth(0.5f);
                    // cb.moveTo(13f, 20f);
                    cb.moveTo(13f, endPara - 95);
                    cb.lineTo(13f, height - 15f);
                    cb.stroke();

                    // draw right line 285, 20, 285, 405, 0.5
                    cb.setRGBColorStrokeF(0f, 0f, 0f);
                    cb.setLineWidth(0.5f);
                    // cb.moveTo(285f, 20f);
                    cb.moveTo(285f, endPara - 95);
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
                    cb.moveTo(13f, endPara - 95);
                    cb.lineTo(285f, endPara - 95);
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

                    if (!StringUtils.isEmpty(pdfParameters.getImgFile())) {
                        Image img = Image.getInstance(pdfParameters.getImgFile());
                        // image, image_width, 0, 0, image_height, x, y
                        //         131, 55, 375, 75, 0
                        cb.addImage(img, 125, 0, 0, 25, 100f, endPara-60f);
                    } else if (!StringUtils.isEmpty(pdfParameters.getElectronicSignature())) {
                        //PdfContentByte
                        String[] lines = pdfParameters.getElectronicSignature().split(System.getProperty("line.separator"));
                        writeDirectContent(cb, bf, 8, PdfContentByte.ALIGN_LEFT, lines[0], 72f, endPara - 48f, 0);
                        writeDirectContent(cb, bf, 8, PdfContentByte.ALIGN_LEFT, lines[1], 72f, endPara - 57f, 0);
                    }


                    // Render doctor name
                    bf = BaseFont.createFont(BaseFont.HELVETICA_BOLD, BaseFont.CP1252, BaseFont.NOT_EMBEDDED);
                    writeDirectContent(cb, bf, 8, PdfContentByte.ALIGN_LEFT, "Requesting: " + pdfParameters.getSigDoctorName(), 20f, endPara - 75f, 0);
                    if (mrpRx) {
                        writeDirectContent(cb, bf, 8, PdfContentByte.ALIGN_LEFT, "MRP: " + pdfParameters.getMRP(), 20f,endPara - 85f, 0);
                    }
                    bf = BaseFont.createFont(BaseFont.HELVETICA, BaseFont.CP1252, BaseFont.NOT_EMBEDDED);
                    // public void writeDirectContent(PdfContentByte cb, BaseFont bf, float fontSize, int alignment, String text, float x, float y, float rotation)
                    // render reprint origPrintDate and numPrint
                    if (pdfParameters.getOrigPrintDate() != null && pdfParameters.getNumPrints() != null) {
                        String rePrintStr = geti18nTagValue(locale, "RxPreview.msgReprintBy")+" " + pdfParameters.getSigDoctorName() + "; "+geti18nTagValue(locale, "RxPreview.msgOrigPrinted")+": " + pdfParameters.getOrigPrintDate() + "; "+geti18nTagValue(locale, "RxPreview.msgTimesPrinted") +": " + pdfParameters.getNumPrints();
                        writeDirectContent(cb, bf, 6, PdfContentByte.ALIGN_LEFT, rePrintStr, 45, endPara - 67, 0);
                    }
                    // print promoText
                    writeDirectContent(cb, bf, 6, PdfContentByte.ALIGN_LEFT, pdfParameters.getPromoText(), 70, endPara - 92.5f, 0);
                    // print page number
                    String footer = "" + writer.getPageNumber();
                    writeDirectContent(cb, bf, 10, PdfContentByte.ALIGN_RIGHT, footer, 280, endPara - 92.5f, 0);
                }
            } catch (Exception e) {
                logger.error("Error", e);
            }
        }
    }

    /**
     * Parses an address provided from the frontend string
     * @param s an address from the frontend, complete with html tags
     * @return a multiline address string
     */
    public static HashMap<String,String> parseSCAddress(String s) {
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

    public ByteArrayOutputStream generatePDFDocumentBytes(FrmCustomedPDFParameters pdfParameters, LoggedInInfo loggedInInfo, Locale locale) throws DocumentException {
        logger.debug("***in generatePDFDocumentBytes2 FrmCustomedPDFServlet.java***");

        String newline = System.getProperty("line.separator");

        ByteArrayOutputStream baosPDF = new ByteArrayOutputStream();
        PdfWriter writer = null;

        String additNotes = pdfParameters.getAdditNotes() != null ? pdfParameters.getAdditNotes().replaceAll("<br>", "\n") : "";
        String[] rxA = pdfParameters.getRx().split(newline);
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

        Document document = new Document();

        try {
            String title = pdfParameters.get__title() != null ? pdfParameters.get__title() : "Unknown";

            // A0-A10, LEGAL, LETTER, HALFLETTER, _11x17, LEDGER, NOTE, B0-B5, ARCH_A-ARCH_E, FLSA
            // and FLSE
            // the following shows a temp way to get a print page size
            Rectangle pageSize = PageSize.LETTER;
            String pageSizeParameter = pdfParameters.getRxPageSize();
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
            if (PageSize.A6.equals(pageSize)){
                writer = PdfWriterFactory.newInstanceA6(document, baosPDF, FontSettings.HELVETICA_6PT);
            }
            else {
                writer = PdfWriterFactory.newInstance(document, baosPDF, FontSettings.HELVETICA_10PT);
            }

            writer.setPageEvent(new EndPage(pdfParameters, locale));
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

            // add water mark
            if (OscarProperties.getInstance().getBooleanProperty("enable_rx_watermark", "true") && !"oscarRxFax".equals(pdfParameters.get__method())) {
                Image image = null;

                float pageHeight = document.getPageSize().getHeight();
                float opacity = Float.parseFloat(OscarProperties.getInstance().getProperty("rx_watermark_opacity", "1"));
                if(OscarProperties.getInstance().getProperty("rx_watermark_file_name") != null ) {
                    loggedInInfo.getLoggedInProvider().getFormattedName();

                    image = Image.getInstance(OscarProperties.getInstance().getProperty("rx_watermark_file_name"));


                    PdfGState gstate = new PdfGState();
                    gstate.setFillOpacity(opacity);
                    cb.saveState();
                    cb.setGState(gstate);

                    float rxWidth = 285f - 13f;
                    float rxHeight = pageSize.getHeight() - 13 - (endPara - 95f);


                    image.setAlignment(Image.MIDDLE | Image.UNDERLYING);

                    if (image.getPlainHeight() > rxHeight) {
                        image.scaleAbsoluteHeight(rxHeight);
                        image.scaleAbsoluteWidth(rxWidth);
                    } else {
                        image.scaleToFit(rxWidth, 100);
                    }


                    int imageCount = (int) Math.ceil(rxHeight / image.getPlainHeight());
                    for (int i = 1; i <= imageCount; i++) {
                        float yPosition = pageHeight - 15 - (image.getScaledHeight() * i);

                        if (rxHeight < (image.getScaledHeight() * i)) {
                            image = getCroppedImage(image, cb, i, rxHeight);
                        }

                        image.setAbsolutePosition(13, yPosition);
                        cb.addImage(image);
                    }

                    cb.restoreState();
                } else {
                    PdfGState gstate = new PdfGState();
                    gstate.setFillOpacity(0.1f);
                    cb.saveState();
                    cb.setGState(gstate);

                    Phrase providerName = new Phrase(loggedInInfo.getLoggedInProvider().getFormattedName(), new Font(bf, 40));

                    int count = 15;
                    for (int i = 1; i <= count; i++) {
                        ColumnText.showTextAligned(cb, Element.ALIGN_CENTER, providerName, (37 * i), (pageHeight - (50 * i)), 37);
                    }
                    cb.restoreState();
                }
            }

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
                Integer scriptId=Integer.parseInt(pdfParameters.getScriptId());
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

    /**
     * Crops an image to fix the given element height based on the number of times the image has been printed and how much space is left to fill
     *
     * @param image The image to be cropped
     * @param cb The content bytes, used to create a PdfTemplate
     * @param imageCount Count of what # image is being printed, used to determine how much the image has to be cropped
     * @param rxHeight Height of the Rx area that the image has to be cropped to
     * @return the cropped Image
     */
    private Image getCroppedImage(Image image, PdfContentByte cb, int imageCount, float rxHeight) {
        // Gets the overflow height in order to determine the new height of the image
        float overflowHeight = (float)Math.ceil((image.getScaledHeight() * imageCount) - rxHeight);
        // Calculates the new height that the image will be cropped to
        float newHeight = image.getScaledHeight() - overflowHeight;
        // Creates a new template for the image
        PdfTemplate t = cb.createTemplate(image.getScaledWidth(), image.getScaledHeight());
        // Creates a rectangle that will crop the image. 2 is added to the overflow height so that there isn't a small line sticking out past the bottom of the rx
        t.rectangle(0, overflowHeight + 2, image.getScaledWidth(), newHeight);
        t.clip();
        t.newPath();
        try {
            t.addImage(image, image.getScaledWidth(), 0, 0, image.getScaledHeight(), 0, 0);

            return Image.getInstance(t);
        } catch (BadElementException e) {
            logger.error("Could not get the instance of the cropped image", e);
        } catch (DocumentException e) {
            logger.error("Could not add an image to the PdfTemplate to crop", e);
        }

        // Returns the passed image in the event that an error occurs
        return image;
    }
}
