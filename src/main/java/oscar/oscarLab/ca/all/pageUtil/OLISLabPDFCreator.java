package oscar.oscarLab.ca.all.pageUtil;

import java.awt.Color;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.servlet.http.HttpServletRequest;

import org.apache.log4j.Logger;
import org.json.JSONObject;
import org.oscarehr.common.dao.Hl7TextMessageDao;
import org.oscarehr.common.model.Hl7TextMessage;
import org.oscarehr.common.model.Provider;
import org.oscarehr.util.LoggedInInfo;
import org.oscarehr.util.MiscUtils;
import org.oscarehr.util.SpringUtils;

import com.lowagie.text.Chunk;
import com.lowagie.text.Document;
import com.lowagie.text.DocumentException;
import com.lowagie.text.Element;
import com.lowagie.text.ExceptionConverter;
import com.lowagie.text.Font;
import com.lowagie.text.PageSize;
import com.lowagie.text.Phrase;
import com.lowagie.text.Rectangle;
import com.lowagie.text.pdf.BaseFont;
import com.lowagie.text.pdf.PdfContentByte;
import com.lowagie.text.pdf.PdfPCell;
import com.lowagie.text.pdf.PdfPTable;
import com.lowagie.text.pdf.PdfPageEventHelper;
import com.lowagie.text.pdf.PdfWriter;

import oscar.OscarProperties;
import oscar.oscarLab.ca.all.Hl7textResultsData;
import oscar.oscarLab.ca.all.parsers.Factory;
import oscar.oscarLab.ca.all.parsers.OLISHL7Handler;
import oscar.oscarLab.ca.all.util.Utilities;
import oscar.util.UtilDateUtilities;


public class OLISLabPDFCreator extends PdfPageEventHelper{
    private OutputStream os;

    private final String FINAL_CODE = "F";
    private final String REPORT_FINAL = "Final";
    private final String REPORT_PARTIAL = "Partial";
    
    private boolean ackFlag = false;
    private boolean isUnstructuredDoc = false;
    private OLISHL7Handler handler;
    private int versionNum;
    private String[] multiID;
    private String id;

    private Provider printingProvider;
    private Document document;
    private BaseFont bf;
	private BaseFont bfBold;
    private BaseFont cf;
    private Font font;
    private Font boldFont;
    private Font redFont;
    private Font categoryHeadFont;
    private Font commentFont;
    private Font subscriptFont;
    private String dateLabReceived;
    
    private String category = "";
	private String newCategory = "";

	private Logger logger = MiscUtils.getLogger();
	
	public static byte[] getPdfBytes(String segmentId, String providerNo) throws IOException, DocumentException
    {
    	ByteArrayOutputStream baos=new ByteArrayOutputStream();

    	LabPDFCreator labPDFCreator=new LabPDFCreator(baos, segmentId, providerNo);
    	labPDFCreator.printPdf();

    	return(baos.toByteArray());
    }

    /** Creates a new instance of LabPDFCreator */
    public OLISLabPDFCreator(HttpServletRequest request, OutputStream os) {
		this(os, request, request.getParameter("segmentID")!=null?request.getParameter("segmentID"):(String)request.getAttribute("segmentID"));
    }

    public OLISLabPDFCreator(OutputStream os, HttpServletRequest request, String segmentId) {
        this.os = os;
        this.id = segmentId;

        // determine lab version
		String multiLabId = Hl7textResultsData.getMatchingLabs(id);
		this.multiID = multiLabId.split(",");

		int i=0;
		while (!multiID[i].equals(id)){
			i++;
		}
		this.versionNum = i+1;

        LoggedInInfo loggedInInfo=LoggedInInfo.getLoggedInInfoFromSession(request);
        printingProvider = loggedInInfo.getLoggedInProvider();

        if(!segmentId.equals("0")){ // OLIS lab that is stored in chart has a segmentID that is not 0
			//Need date lab was received by OSCAR
			Hl7TextMessageDao hl7TxtMsgDao = (Hl7TextMessageDao)SpringUtils.getBean("hl7TextMessageDao");
			Hl7TextMessage hl7TextMessage = hl7TxtMsgDao.find(Integer.parseInt(segmentId));
			java.util.Date date = hl7TextMessage.getCreated();
			String stringFormat = "yyyy-MM-dd HH:mm";
			dateLabReceived = UtilDateUtilities.DateToString(date, stringFormat);

			// create handler
			this.handler = (OLISHL7Handler) Factory.getHandler(id);
		}
		else{ // OLIS lab not saved to chart has a segmentId of 0

			String uuidToAdd = request.getParameter("uuid");
			String fileName = System.getProperty("java.io.tmpdir") + "/olis_" + uuidToAdd + ".response";
			String hl7Parsed = "";
			try {
				if (Files.exists(Paths.get(fileName))) {
					ArrayList<String> hl7Body = Utilities.separateMessages(fileName);
					for (String hl7Text : hl7Body){
						hl7Parsed += hl7Text.replace("\\H\\", "\\.H\\").replace("\\N\\", "\\.N\\");

					}
					// set
					java.util.Date date = new java.util.Date();
					String stringFormat = "yyyy-MM-dd HH:mm";
					dateLabReceived = UtilDateUtilities.DateToString(date, stringFormat);
					//create handler
					this.handler = (OLISHL7Handler) Factory.getHandler("OLIS_HL7", hl7Parsed);
				}
			} catch (IOException ioe) {
				//Reading file failed
				MiscUtils.getLogger().error("Couldn't print requested OLIS lab.", ioe);
				request.setAttribute("result", "Error");
			}
			catch (Exception e){
				// separating message failed
				MiscUtils.getLogger().error("Couldn't print requested OLIS lab.", e);
				request.setAttribute("result", "Error");
			}
		}
    }
    
    public void printPdf() throws IOException, DocumentException{

        // check that we have data to print
        if (handler == null)
            throw new DocumentException();

        //Create the document we are going to write to
        document = new Document();
        //PdfWriter writer = PdfWriter.getInstance(document, response.getOutputStream());
        PdfWriter writer = PdfWriter.getInstance(document, os);

        //Set page event, function onEndPage will execute each time a page is finished being created
        writer.setPageEvent(this);

        document.setPageSize(PageSize.LETTER);
        document.setMargins(35, 35, 45, 40);
        document.addTitle("Title of the Document");
        document.addCreator("OSCAR");
        document.open();

        //Create the fonts that we are going to use
        bf = BaseFont.createFont(BaseFont.HELVETICA, BaseFont.CP1252, BaseFont.NOT_EMBEDDED);
		bfBold = BaseFont.createFont(BaseFont.HELVETICA_BOLD, BaseFont.CP1252, BaseFont.NOT_EMBEDDED);
        cf = BaseFont.createFont(BaseFont.COURIER, BaseFont.CP1252, BaseFont.NOT_EMBEDDED);
        font = new Font(bf, 9, Font.NORMAL);
        boldFont = new Font(bfBold, 9, Font.NORMAL);
        redFont = new Font(bf, 9, Font.NORMAL, Color.RED);
        categoryHeadFont = new Font(bf, 12, Font.BOLD);
        commentFont = new Font(cf, 9, Font.NORMAL);
        subscriptFont = new Font(bf, 6, Font.NORMAL);
        

        // add the header table containing the patient and lab info to the document
        createInfoTable();

        // add the tests and test info for each header
        ArrayList<String> headers = handler.getHeaders();
        int obr;
        int lineNum = 0;
        for (int i=0; i < headers.size(); i++){
        	//Gets the mapped OBR for the current index
        	obr = handler.getMappedOBR(i);
        	lineNum = obr + 1;
        	//If the current lineNum is not a childOBR
        	if (!handler.isChildOBR(lineNum)){
        		//Calls on the addOLISLabCategory function passing the header at the current obr, and the obr itself
        		addOLISLabCategory(headers.get(obr), obr);
        	}
        }

        createClientTable();
        
        document.close();

        os.flush();
    }
    
    /*
	 * Given the name of a lab category this method will add the category
	 * header, the test result headers and the test results for that category.
	 */
	private void addOLISLabCategory(String header, Integer obr) throws DocumentException {	
		Color categoryBackground = new Color(255, 204, 0);
		Color separatorColour = new Color(0, 51, 153);
		
		//Creates a separator cell for separation between results
		PdfPCell separator = new PdfPCell();
		separator.setColspan(2);
		separator.setBorder(0);
		separator.setBackgroundColor(separatorColour);
		separator.setFixedHeight(1f);
		
		
		//Category Table Variables
		float[] categoryTableWidths;
		categoryTableWidths = new float[] {2f, 3f};
		PdfPTable categoryTable = new PdfPTable(categoryTableWidths);
		categoryTable.setWidthPercentage(100);
		categoryTable.setKeepTogether(true);
		
		//Main Table Variables
		float[] mainTableWidths;
		//Unused column is 3f
		mainTableWidths = new float[] {8f, 3f, 1f, 3f, 2f, 2f };
		PdfPTable table = new PdfPTable(mainTableWidths);
		table.setWidthPercentage(100);
		
		PdfPCell cell = new PdfPCell();
		cell.setBorder(0);
		//Sets the current category as a newCategory
		newCategory = handler.getOBRCategory(obr);
		
		//If it is a different category, then add a new category header to the category table
		if (!category.equals(newCategory)){
			if (newCategory.contains("Microbiology")) {
				newCategory = "Microbiology";
			}
			categoryTable.addCell(separator);
			//Adds the Category name to the table
			cell = new PdfPCell();
			cell.setColspan(2);
			cell.setBorder(0);
			cell.setHorizontalAlignment(Element.ALIGN_CENTER);
			cell.setBackgroundColor(categoryBackground);
			cell.setPhrase(new Phrase(newCategory, categoryHeadFont));
			categoryTable.addCell(cell);
			//The new category becomes the current category
			category = newCategory;
		}
		
		//Adds a separator
		categoryTable.addCell(separator);
		
		//Creates the collection table and adds it to the category table
		PdfPTable collectionTable = createCollectionTable(obr);
		cell = new PdfPCell(collectionTable);
		cell.setBorder(0);
		cell.setColspan(2);
		categoryTable.addCell(cell);
		
		String collectorsComment = handler.getCollectorsComment(obr);
		if (!stringIsNullOrEmpty(collectorsComment)){
			cell = new PdfPCell();
			cell.setBorder(0);
			cell.setColspan(2);
			cell.setPhrase(new Phrase("Collector's Comments", boldFont));
			categoryTable.addCell(cell);
			String collectorsCommentPhrase = collectorsComment;
			OLISLabPDFUtils.addAllCellsToTable(categoryTable, OLISLabPDFUtils.createCellsFromHl7(collectorsCommentPhrase, this.font, cell));
		}
		
		//Adds a small separator between the top row and the collection table
		cell = new PdfPCell();
		cell.setColspan(2);
		cell.setBorder(0);
		cell.setFixedHeight(1f);
		categoryTable.addCell(cell);
		
		
		cell = new PdfPCell();
		cell.setBorder(0);
		String primaryFacility = handler.getPerformingFacilityName();
		String performingFacility = handler.getOBRPerformingFacilityName(obr);
		if (!primaryFacility.equals(performingFacility) && !stringIsNullOrEmpty(performingFacility)){
			cell.setPhrase(new Phrase("Performing Facility: ", boldFont));
			categoryTable.addCell(cell);
			cell.setPhrase(new Phrase(performingFacility, font));
			categoryTable.addCell(cell);
			cell.setPhrase(new Phrase("Address: ", boldFont));
			categoryTable.addCell(cell);
			cell.setPhrase(new Phrase(getFullAddress(handler.getPerformingFacilityAddress(obr)), font));
			categoryTable.addCell(cell);
		}
		
		cell = new PdfPCell();
		//Column Headers
		cell.setColspan(1);
		cell.setBorder(15);
		cell.setHorizontalAlignment(Element.ALIGN_CENTER);
		cell.setBackgroundColor(new Color(210, 212, 255));
		cell.setPhrase(new Phrase("Test Name(s)", boldFont));
		table.addCell(cell);
		cell.setPhrase(new Phrase("Result", boldFont));
		table.addCell(cell);
		cell.setPhrase(new Phrase("Abn", boldFont));
		table.addCell(cell);
		cell.setPhrase(new Phrase("Reference Range", boldFont));
		table.addCell(cell);
		cell.setPhrase(new Phrase("Units", boldFont));
		table.addCell(cell);
		cell.setPhrase(new Phrase("Status", boldFont));
		table.addCell(cell);

		//Renews the cell so that it is clean
		cell = new PdfPCell();
		cell.setColspan(6);
		cell.setPaddingBottom(5);
		cell.setBorder(12);
		
		Phrase categoryPhrase = new Phrase();
		categoryPhrase.setFont(new Font(bfBold, 11, Font.NORMAL));
		categoryPhrase.add(header.replaceAll("<br\\s*/*>", "\n"));
		
		//Replaces breakpoints in the header and adds it to the phrase
		// Checks if the status colour should be red
		if (!handler.isObrStatusFinal(obr)) {
			categoryPhrase.setFont(redFont);
		}
		//Adds the obr status to the phrase so it appears beside the test request/header
		categoryPhrase.add(" (" + handler.getObrStatus(obr) + ")");
		
		//Gets the point of care and outputs message if it exists
		String poc = handler.getPointOfCare(obr);
		if (!stringIsNullOrEmpty(poc)){
			categoryPhrase.setFont(new Font(bf, 8, Font.NORMAL));
			categoryPhrase.add("\n(Test performed at point of care)");
		}

		//Checks if the OBR is blocked
		boolean blocked = handler.isOBRBlocked(obr);
		if (blocked){
			categoryPhrase.setFont(new Font(bf, 8, Font.NORMAL, Color.RED));
			categoryPhrase.add("\n\n(Do Not Disclose Without Explicit Patient Consent");
		}

		cell.setPhrase(categoryPhrase);
		table.addCell(cell);
		
		cell.setBorder(12);
		cell.setBorderColor(Color.BLACK); // cell.setBorderColor(Color.WHITE);
		cell.setBackgroundColor(new Color(255, 255, 255));
		
		boolean obrFlag = false;
		int obxCount = handler.getOBXCount(obr);
		int obx = 0;
		
		if (handler.getObservationHeader(obr, 0).equals(header)){
			int commentCount = handler.getOBRCommentCount(obr);
			for (int comment = 0; comment < commentCount; comment++){
				String obxNN = handler.getOBXName(obr, 0);
				if (!obrFlag && obxNN.equals("")){
                    OLISLabPDFUtils.addAllCellsToTable(table, OLISLabPDFUtils.createCellsFromHl7(handler.getOBRName(comment), font, cell));
                    OLISLabPDFUtils.addAllCellsToTable(table, OLISLabPDFUtils.createCellsFromHl7(handler.getObrSpecimenSource(comment), font, cell));
					cell.setColspan(5);
					table.addCell(cell);
					obrFlag = true;
				}
				
				String obrComment = handler.getOBRCommentString(obr, comment).replaceAll("<br\\s*/*>", "\n");
				String sourceOrg = handler.getOBRSourceOrganization(obr, comment);
				
				cell.setColspan(6);
				cell.setHorizontalAlignment(Element.ALIGN_LEFT);
				String obrCommentPhrase = obrComment + "\t\t" + sourceOrg;
                OLISLabPDFUtils.addAllCellsToTable(table, OLISLabPDFUtils.createCellsFromHl7(obrCommentPhrase, font, cell));
			}
		}

		String diagnosis = handler.getDiagnosis(obr);
		if (!stringIsNullOrEmpty(diagnosis)){
			cell.setColspan(6);
			Phrase diagnosisPhrase = new Phrase();
			diagnosisPhrase.setFont(boldFont);
			diagnosisPhrase.add("Diagnosis: ");
			diagnosisPhrase.setFont(font);
			diagnosisPhrase.add(diagnosis);
			cell.setPhrase(diagnosisPhrase);
			table.addCell(cell);
		}
		
		for (int count = 0; count < obxCount; count++){
			obx = handler.getMappedOBX(obr, count);
			String obxName = handler.getOBXName(obr, obx);
			boolean b1 = false;
			boolean b2 = false;
			boolean b3 = false;
			
			boolean fail = true;
			
			try{
				b1 = !handler.getOBXResultStatus(obr, obx).equals("DNS");
				b2 = !stringIsNullOrEmpty(obxName);
				String obsHeader = handler.getObservationHeader(obr, obx);
				b3 = obsHeader.equals(header);
				fail = false;
				
			}catch(Exception e){
				logger.info("ERROR: " + e);
			}
			
			if (!fail && b1 && b2 && b3){
				String obrName = handler.getOBRName(obr);
				b1 = !obrFlag && !stringIsNullOrEmpty(obrName);
				b2 = !(obxName.contains(obrName));
				b3 = obxCount < 2;
				
				if (b1 && b2 && b3){
					obrFlag = true;
				}
				
				String status = handler.getOBXResultStatus(obr, obx).trim();
				String statusMsg = "";
				try{
					statusMsg = handler.getTestResultStatusMessage(handler.getOBXResultStatus(obr, obx).charAt(0));
				}
				catch(Exception e){
					statusMsg = "";
				}

				//Creates a new font used on the line
				Font lineFont = new Font(font);
				String abnormal = handler.getOBXAbnormalFlag(obr, obx);
				
				//If the abnormal status starts with L then the font color is blue
				if (abnormal!= null && (abnormal.startsWith("L") || abnormal.equals("A") || abnormal.startsWith("H") || handler.isOBXAbnormal(obr, obx))){
					lineFont = redFont;
				}
				
				Font statusMsgFont = new Font(lineFont);
				
				//Gets the font style to be used in the table according to the status
				if (status != null && status.startsWith("W")){
					lineFont.setStyle(Font.STRIKETHRU);
				}
				//Creates a new phrase to hold the display name
				String obxDisplayName = obxName.replaceAll("<br\\s*/*>", "\n");
				
				//Checks the abnormal nature of the test and adds the necessary portion to the displayName
				String abnormalNature = handler.getNatureOfAbnormalTest(obr, obx);
				if (!stringIsNullOrEmpty(abnormalNature)){
					obxDisplayName += "\n(" + abnormalNature + ")";
				}
				
				
				String obxValueType = handler.getOBXValueType(obr, obx).trim();
				if (obxValueType.equals("ST") && handler.renderAsFT(obr,obx)) {
					obxValueType = "FT";
				}
				else if (obxValueType.equals("TX") && handler.renderAsNM(obr,obx)) {
					obxValueType = "NM";
				}
				else if (obxValueType.equals("FT") && handler.renderAsNM(obr,obx)) {
					obxValueType = "NM";
				}
				
				//Sets the cell border to 15 so that the cells in the table are completely bordered instead of just left and right borders
				cell.setBorder(15);
				
				//Checks the obxValueType and populates the table row with the proper data
				if (obxValueType.equals("NM") || obxValueType.equals("ST") || obxValueType.equals("SN")){
					//Checks if it is Ancillary and obxValueType is not SN, adds Patient Observation row to table
					if (handler.isAncillary(obr, obx) && !obxValueType.equals("SN")){
						cell.setColspan(6);
						cell.setPhrase(new Phrase("Patient Observation", font));
						table.addCell(cell);
					}
					
					cell.setColspan(1);
					//Adds the columns for the current Value Type
					cell.setVerticalAlignment(Element.ALIGN_TOP);
					cell.setHorizontalAlignment(Element.ALIGN_LEFT);
                    OLISLabPDFUtils.addAllCellsToTable(table, OLISLabPDFUtils.createCellsFromHl7(obxDisplayName, font, cell));
					
					 
					cell.setHorizontalAlignment(Element.ALIGN_RIGHT);

					//If the type does not equal SN, then outputs normal OBX result, if it is SN then outputs SNResult
					if (!obxValueType.equals("SN")) {
//                        cell.setPhrase(OLISLabPDFUtils.createPhraseFromHl7(OLISLabPDFUtils.Hl7EncodedRepeatableCharacter.performReplacement(handler.getOBXResult(obr, obx)).replaceAll("<br\\s*/*>", "\n"), lineFont));
                        OLISLabPDFUtils.addAllCellsToTable(table, OLISLabPDFUtils.createCellsFromHl7(handler.getOBXResult(obr, obx), lineFont, cell));
                    } else {
//                        cell.setPhrase(OLISLabPDFUtils.createPhraseFromHl7(OLISLabPDFUtils.Hl7EncodedRepeatableCharacter.performReplacement(handler.getOBXSNResult(obr, obx)).replaceAll("<br\\s*/*>", "\n"), lineFont));
                        OLISLabPDFUtils.addAllCellsToTable(table, OLISLabPDFUtils.createCellsFromHl7(handler.getOBXSNResult(obr, obx), lineFont, cell));
                    }
					
					cell.setHorizontalAlignment(Element.ALIGN_CENTER);
                    OLISLabPDFUtils.addAllCellsToTable(table, OLISLabPDFUtils.createCellsFromHl7(handler.getOBXAbnormalFlag(obr, obx), lineFont, cell));
					
					cell.setHorizontalAlignment(Element.ALIGN_LEFT);
                    OLISLabPDFUtils.addAllCellsToTable(table, OLISLabPDFUtils.createCellsFromHl7(handler.getOBXReferenceRange(obr, obx), lineFont, cell));
					
					cell.setHorizontalAlignment(Element.ALIGN_LEFT);
                    OLISLabPDFUtils.addAllCellsToTable(table, OLISLabPDFUtils.createCellsFromHl7(handler.getOBXUnits(obr, obx), lineFont, cell));
					
					cell.setHorizontalAlignment(Element.ALIGN_CENTER);
                    OLISLabPDFUtils.addAllCellsToTable(table, OLISLabPDFUtils.createCellsFromHl7(statusMsg, statusMsgFont, cell));
				}
				else if (obxValueType.equals("TX") || obxValueType.equals("FT")){
					//Adds the columns for the current Value Type
					cell.setVerticalAlignment(Element.ALIGN_TOP);
					cell.setHorizontalAlignment(Element.ALIGN_LEFT);
					cell.setColspan(6);
                    OLISLabPDFUtils.addAllCellsToTable(table, OLISLabPDFUtils.createCellsFromHl7(obxDisplayName, lineFont, cell));
					
					cell.setColspan(5);
					cell.setVerticalAlignment(Element.ALIGN_MIDDLE);
                    List<PdfPCell> commentCells = OLISLabPDFUtils.createCellsFromHl7(handler.getOBXResult(obr, obx).replaceAll("<br\\s*/*>", "\n"), lineFont, cell);
                    if (commentCells.size() > 1) {
                        int numberOfCommentCells = commentCells.size();
                        PdfPCell firstCell = commentCells.remove(0);
                        PdfPCell lastCell = commentCells.remove(commentCells.size() - 1);

                        firstCell.setBorderWidthBottom(0);
                        table.addCell(firstCell);

                        cell.setColspan(1);
                        cell.setRowspan(numberOfCommentCells);
                        cell.setHorizontalAlignment(Element.ALIGN_CENTER);
                        OLISLabPDFUtils.addAllCellsToTable(table, OLISLabPDFUtils.createCellsFromHl7(statusMsg, statusMsgFont, cell));
                        cell.setRowspan(1);

                        for (PdfPCell commentCell : commentCells) {
                            commentCell.setBorderWidthBottom(0);
                            commentCell.setBorderWidthTop(0);
                            table.addCell(commentCell);
                        }
                        
                        lastCell.setBorderWidthTop(0);
                        table.addCell(lastCell);
                    } else {
                        OLISLabPDFUtils.addAllCellsToTable(table, commentCells);
                        cell.setColspan(1);
                        cell.setHorizontalAlignment(Element.ALIGN_CENTER);
                        OLISLabPDFUtils.addAllCellsToTable(table, OLISLabPDFUtils.createCellsFromHl7(statusMsg, statusMsgFont, cell));
                    }
				}
				//Combines the TM, DT, and TS displays into one to reduce redundant code since the only difference between them is the OBX Results that are retrieved
				else if(obxValueType.equals("TM") || obxValueType.equals("DT") || obxValueType.equals("TS")){
					cell.setColspan(1);
					//Adds the columns for the current Value Type
					cell.setVerticalAlignment(Element.ALIGN_TOP);
					cell.setHorizontalAlignment(Element.ALIGN_LEFT);
                    OLISLabPDFUtils.addAllCellsToTable(table, OLISLabPDFUtils.createCellsFromHl7(obxDisplayName, lineFont, cell));
					
					cell.setVerticalAlignment(Element.ALIGN_MIDDLE);
					cell.setHorizontalAlignment(Element.ALIGN_RIGHT);
					
					//Gets the OBX result based on the value type
					if(obxValueType.equals("TM")){
                        OLISLabPDFUtils.addAllCellsToTable(table, OLISLabPDFUtils.createCellsFromHl7(handler.getOBXTMResult(obr, obx).replaceAll("<br\\s*/*>", "\n"), lineFont, cell));
					}
					else if(obxValueType.equals("DT")){
                        OLISLabPDFUtils.addAllCellsToTable(table, OLISLabPDFUtils.createCellsFromHl7(handler.getOBXDTResult(obr, obx).replaceAll("<br\\s*/*>", "\n"), lineFont, cell));
					}
					else{
                        OLISLabPDFUtils.addAllCellsToTable(table, OLISLabPDFUtils.createCellsFromHl7(handler.getOBXTSResult(obr, obx).replaceAll("<br\\s*/*>", "\n"), lineFont, cell));
					}
					
					cell.setColspan(3);
					cell.setPhrase(new Phrase("", lineFont));
					table.addCell(cell);
					
					cell.setColspan(1);
					cell.setHorizontalAlignment(Element.ALIGN_CENTER);
                    OLISLabPDFUtils.addAllCellsToTable(table, OLISLabPDFUtils.createCellsFromHl7(statusMsg, statusMsgFont, cell));
				}
				else if (obxValueType.equals("ED")){
					//Adds the columns for the current row
					cell.setColspan(1);
					cell.setVerticalAlignment(Element.ALIGN_TOP);
					cell.setHorizontalAlignment(Element.ALIGN_LEFT);
                    OLISLabPDFUtils.addAllCellsToTable(table, OLISLabPDFUtils.createCellsFromHl7(obxDisplayName, lineFont, cell));
					
					cell.setColspan(3);
					cell.setPhrase(new Phrase("", lineFont));
					table.addCell(cell);
					
					cell.setColspan(1);
					cell.setVerticalAlignment(Element.ALIGN_MIDDLE);
                    OLISLabPDFUtils.addAllCellsToTable(table, OLISLabPDFUtils.createCellsFromHl7(handler.getOBXUnits(obr, obx), lineFont, cell));
					
					cell.setHorizontalAlignment(Element.ALIGN_CENTER);
                    OLISLabPDFUtils.addAllCellsToTable(table, OLISLabPDFUtils.createCellsFromHl7(statusMsg, statusMsgFont, cell));
					
					cell.setColspan(6);
					cell.setHorizontalAlignment(Element.ALIGN_LEFT);
					cell.setPhrase(new Phrase("Attachment omitted from printing", lineFont));
					table.addCell(cell);
					
				}
				else if(obxValueType.equals("CE")){
					//Adds the columns for the current Value Type
					cell.setColspan(6);
					cell.setVerticalAlignment(Element.ALIGN_TOP);
					cell.setHorizontalAlignment(Element.ALIGN_LEFT);
                    OLISLabPDFUtils.addAllCellsToTable(table, OLISLabPDFUtils.createCellsFromHl7(obxDisplayName, lineFont, cell));
					
					cell.setColspan(5);
					cell.setVerticalAlignment(Element.ALIGN_MIDDLE);
                    OLISLabPDFUtils.addAllCellsToTable(table, OLISLabPDFUtils.createCellsFromHl7(handler.getOBXCEName(obr, obx), font, cell));
					
					cell.setColspan(1);
					cell.setHorizontalAlignment(Element.ALIGN_CENTER);
                    OLISLabPDFUtils.addAllCellsToTable(table, OLISLabPDFUtils.createCellsFromHl7(statusMsg, statusMsgFont, cell));
					
					//If the status is final
					if(handler.isStatusFinal(handler.getOBXResultStatus(obr, obx).charAt(0))){
						String parentId = handler.getOBXCEParentId(obr, obx);
						//If there is a parent ID then outputs a table for Agent and Sensitivity
						if (!stringIsNullOrEmpty(parentId)){
							float[] ceTableWidths = {2f, 3f};
							PdfPTable ceTable = new PdfPTable(ceTableWidths);
							ceTable.setWidthPercentage(10f);
							
							
							//Column Headers
							cell.setColspan(1);
							//Enables the borders with the bitwise combination of 11 (1 top, 2 bottom, 8 right)
							cell.setBorder(11);
							cell.setPhrase(new Phrase("Sensitivity", boldFont));
							ceTable.addCell(cell);
							//Enables the borders with the bitwise combination of 7 (1 top, 2 bottom, 4 left)
							cell.setBorder(7);
							cell.setHorizontalAlignment(Element.ALIGN_CENTER);
							cell.setPhrase(new Phrase("Agent", boldFont));
							ceTable.addCell(cell);
							cell.setBorder(12);
							
							cell.setColspan(1);
							int childOBR = handler.getChildOBR(parentId) - 1;
							//If the childOBR does not equal -1
							if (childOBR != -1){
								//Gets the Gets the childOBR length
								int childLength = handler.getOBXCount(childOBR);
								//For each child obr, outputs it
								for (int ceIndex = 0; ceIndex < childLength; ceIndex++){
									Font strikeoutFont = new Font(bf, 9, Font.STRIKETHRU);
									String ceStatus = handler.getOBXResultStatus(childOBR, ceIndex).trim();
                                    boolean ceStrikeout = ceStatus != null && ceStatus.startsWith("W");
									cell.setHorizontalAlignment(Element.ALIGN_LEFT);
                                    OLISLabPDFUtils.addAllCellsToTable(ceTable, OLISLabPDFUtils.createCellsFromHl7(handler.getOBXName(childOBR,ceIndex), (ceStrikeout ? strikeoutFont : font), cell));
									cell.setHorizontalAlignment(Element.ALIGN_CENTER);
                                    OLISLabPDFUtils.addAllCellsToTable(ceTable, OLISLabPDFUtils.createCellsFromHl7(handler.getOBXCESensitivity(childOBR,ceIndex), (ceStrikeout ? strikeoutFont : font), cell));
                                    
                                    cell.setHorizontalAlignment(Element.ALIGN_LEFT);
								}
							}
							
							//Adds the ceTable to the main table
							cell = new PdfPCell(ceTable);
							cell.setBorder(12);
					        cell.setColspan(6);
					        //For the table, sets the padding to
					        cell.setPaddingLeft(50);
					        cell.setPaddingRight(20);
					        table.addCell(cell);
					        //Sets the padding back to 0
					        cell.setPaddingLeft(0);
					        cell.setPaddingRight(0);
					        
					        if (category.contains("Microbiology")){
					        	cell.setHorizontalAlignment(Element.ALIGN_CENTER);
					        	cell.setPhrase(new Phrase("S=Sensitive R=Resistant I=Intermediate MS=Moderately Sensitive VS=Very Sensitive", font));
					        	table.addCell(cell);
					        }
					        cell.setColspan(1);
						}
					}
				}
				else{
					//Adds the columns for the current Value Type
					cell.setColspan(1);
					cell.setVerticalAlignment(Element.ALIGN_TOP);
					cell.setHorizontalAlignment(Element.ALIGN_LEFT);
                    OLISLabPDFUtils.addAllCellsToTable(table, OLISLabPDFUtils.createCellsFromHl7(obxDisplayName, lineFont, cell));
					
					 
					cell.setHorizontalAlignment(Element.ALIGN_RIGHT);
                    OLISLabPDFUtils.addAllCellsToTable(table, OLISLabPDFUtils.createCellsFromHl7(handler.getOBXResult(obr, obx), lineFont, cell));
					
					cell.setHorizontalAlignment(Element.ALIGN_CENTER);
                    OLISLabPDFUtils.addAllCellsToTable(table, OLISLabPDFUtils.createCellsFromHl7(handler.getOBXAbnormalFlag(obr, obx), lineFont, cell));
					
					cell.setHorizontalAlignment(Element.ALIGN_LEFT);
                    OLISLabPDFUtils.addAllCellsToTable(table, OLISLabPDFUtils.createCellsFromHl7(handler.getOBXReferenceRange(obr, obx), lineFont, cell));
					
					cell.setHorizontalAlignment(Element.ALIGN_LEFT);
                    OLISLabPDFUtils.addAllCellsToTable(table, OLISLabPDFUtils.createCellsFromHl7(handler.getOBXUnits(obr, obx), lineFont, cell));
					
					cell.setHorizontalAlignment(Element.ALIGN_CENTER);
                    OLISLabPDFUtils.addAllCellsToTable(table, OLISLabPDFUtils.createCellsFromHl7(statusMsg, statusMsgFont, cell));
				}
				cell.setHorizontalAlignment(Element.ALIGN_LEFT);
				//If there is an obs method, outputs it
				String obsMethod = handler.getOBXObservationMethod(obr, obx);
				if (!stringIsNullOrEmpty(obsMethod)){
					cell.setColspan(6);
                    OLISLabPDFUtils.addAllCellsToTable(table, OLISLabPDFUtils.createCellsFromHl7("Observation Method: " + obsMethod, font, cell));
					cell.setColspan(0);
				}
				//If there is an obsDate, outputs it
				String obsDate = handler.getOBXObservationDate(obr, obx);
				if (!stringIsNullOrEmpty(obsDate)){
					cell.setColspan(6);
                    OLISLabPDFUtils.addAllCellsToTable(table, OLISLabPDFUtils.createCellsFromHl7("Observation Date: " + obsDate, font, cell));
					cell.setColspan(0);
				}
				
				cell.setColspan(6);
				cell.setBorder(12);
				//For each comment, outputs it
				for(int commentCount = 0; commentCount < handler.getOBXCommentCount(obr, obx); commentCount++){
					String comment = handler.getOBXCommentNoFormat(obr, obx, commentCount).replaceAll("<br\\s*/*>", "\n").replaceAll("&nbsp;", "\u00A0");
					comment += "\t\t" + handler.getOBXSourceOrganization(obr, obx, commentCount);
                    OLISLabPDFUtils.addAllCellsToTable(table, OLISLabPDFUtils.createCellsFromHl7(comment, commentFont, cell));
				}
			}
		}
		
		PdfPTable borderedCategoryTable = new PdfPTable(1);
		borderedCategoryTable.setWidthPercentage(100);
		cell = new PdfPCell(categoryTable);
		cell.setBorder(15);
		borderedCategoryTable.addCell(cell);
		
		document.add(borderedCategoryTable);
		document.add(table);

	}

    
    /*
     *  createInfoTable creates and adds the table at the top of the document
     *  which contains the patient and lab information
     */
    private void createInfoTable() throws DocumentException{
    	
    	String fullAddress = "";
    	
        //Create patient info table
        PdfPCell cell = new PdfPCell();
        cell.setBorder(0);
        float[] pInfoWidths = {2f, 3f};
        PdfPTable pInfoTable = new PdfPTable(pInfoWidths);
        cell.setPhrase(new Phrase("Health #: ", boldFont));
        pInfoTable.addCell(cell);
        cell.setPhrase(new Phrase(handler.getFormattedHealthNumber(), font));
        pInfoTable.addCell(cell);

		Set<String> patientIdentifiers = handler.getPatientIdentifiers();
		for (String identifier : patientIdentifiers) {
			// Skip the health number (displayed above)
			if (identifier.equals("JHN")) {
				continue;
			}
			String[] identifiers = handler.getPatientIdentifier(identifier);
			String identifierVal = identifiers[0];
			String identifierAttrib = identifiers[1];
			String identifierAttribName = null;
			
			if (identifierAttrib != null) {
				identifierAttribName = handler.getSourceOrganization(identifierAttrib);
			}
			cell.setPhrase(new Phrase(handler.getNameOfIdentifier(identifier) + ": ", boldFont));
			pInfoTable.addCell(cell);
			
			
			//StringBuilder identifierDisplay = new StringBuilder(identifierVal);
			Phrase identifierPhrase = new Phrase();

			identifierPhrase.setFont(font);
			identifierPhrase.add(identifierVal);
			
			if (identifierAttribName != null) {
				identifierPhrase.setFont(subscriptFont);
				identifierPhrase.add(identifierAttribName + " (Lab " + identifierAttrib + ")");
			}
			
			cell.setPhrase(identifierPhrase);
			pInfoTable.addCell(cell);
		}
        
        cell.setPhrase(new Phrase("Patient Name: ", boldFont));
        pInfoTable.addCell(cell);
        cell.setPhrase(new Phrase(handler.getPatientName(), font));
        pInfoTable.addCell(cell);
        
        cell.setPhrase(new Phrase("Date of Birth: ", boldFont));
        pInfoTable.addCell(cell);
        cell.setPhrase(new Phrase(handler.getDOB(), font));
        pInfoTable.addCell(cell);
        
        cell.setPhrase(new Phrase("Age: ", boldFont));
        pInfoTable.addCell(cell);
        cell.setPhrase(new Phrase(handler.getAge(), font));
        pInfoTable.addCell(cell);
        
        cell.setPhrase(new Phrase("Sex: ", boldFont));
        pInfoTable.addCell(cell);
        cell.setPhrase(new Phrase(handler.getSex(), font));
        pInfoTable.addCell(cell);
        
        //Patient Address
    	for (HashMap<String, String> address : handler.getPatientAddresses()){
    		//Adds the address type to the table
    		cell.setPhrase(new Phrase(address.get("Address Type") + ": ", boldFont));
            pInfoTable.addCell(cell);
            //Gets the full address
            fullAddress = getFullAddress(address);
            //Sets the cell's phrase and adds the cell to the table
            cell.setPhrase(new Phrase(fullAddress, font));
            pInfoTable.addCell(cell);
    	}
    	//Patient Home Phone
        ArrayList<HashMap<String,String>> homePhones = handler.getPatientHomeTelecom();
    	for(HashMap<String, String> homePhone : homePhones){
        	Phrase phonePhrase = new Phrase();
        	//Adds the phone's use
        	cell.setPhrase(new Phrase("Home: ", boldFont));
        	pInfoTable.addCell(cell);
        	
        	//Adds the phone number and useCode to the phrase
        	phonePhrase.setFont(font);
        	phonePhrase.add(getPhone(homePhone));
        	phonePhrase.setFont(subscriptFont);
        	phonePhrase.add(homePhone.get("useCode"));
        	//Adds the phrase to the table
        	cell.setPhrase(phonePhrase);
        	pInfoTable.addCell(cell);
        }
    	//Patient Work Telephone
        ArrayList<HashMap<String, String>> workPhones = handler.getPatientWorkTelecom();
        for (HashMap<String, String> workPhone : workPhones){
        	Phrase phonePhrase = new Phrase();
        	//Adds the phone's use
        	cell.setPhrase(new Phrase("Work: ", boldFont));
        	pInfoTable.addCell(cell);
        	//Adds the phone number and useCode
        	phonePhrase.setFont(font);
        	phonePhrase.add(getPhone(workPhone));
        	phonePhrase.setFont(subscriptFont);
        	phonePhrase.add(workPhone.get("useCode"));
        	//Adds the phrase to the table
        	cell.setPhrase(phonePhrase);
        	pInfoTable.addCell(cell);
        }
        
        
        //Create results info table
        PdfPTable rInfoTable = new PdfPTable(2);
        cell.setPhrase(new Phrase("Report Status: ", boldFont));
        rInfoTable.addCell(cell);
        String reportStatus = handler.getReportStatusDescription();
        cell.setPhrase(new Phrase(reportStatus, handler.isReportNormal() ? font : redFont));
        rInfoTable.addCell(cell);
        
        cell.setPhrase(new Phrase("Order Id: ", boldFont));
        rInfoTable.addCell(cell);
        Phrase orderIdPhrase = new Phrase();
        orderIdPhrase.setFont(font);
        orderIdPhrase.add(handler.getAccessionNum());
        orderIdPhrase.setFont(subscriptFont);
        orderIdPhrase.add("\t\t" + handler.getAccessionNumSourceOrganization());
        
        cell.setPhrase(orderIdPhrase);
        rInfoTable.addCell(cell);
        
        cell.setPhrase(new Phrase("Order Date: ", boldFont));
        rInfoTable.addCell(cell);
        cell.setPhrase(new Phrase(handler.getOrderDate(), font));
        rInfoTable.addCell(cell);
        
        if(!stringIsNullOrEmpty(handler.getLastUpdateInOLISUnformated())){
	        cell.setPhrase(new Phrase("Last Updated In OLIS: ", boldFont));
	        rInfoTable.addCell(cell);
	        cell.setPhrase(new Phrase(handler.getLastUpdateInOLIS(), font));
	        rInfoTable.addCell(cell);
        }
        
        if(!stringIsNullOrEmpty(handler.getSpecimenReceivedDateTime())){
	        cell.setPhrase(new Phrase("Specimen Received: ", boldFont));
	        rInfoTable.addCell(cell);
	        Phrase specimentReceived = new Phrase(handler.getSpecimenReceivedDateTime(), font);
	        specimentReceived.setFont(subscriptFont);
	        specimentReceived.add("\n (unless otherwise specified)");
	        cell.setPhrase(specimentReceived);
	        rInfoTable.addCell(cell);
        }
        
        HashMap<String,String> address;
        address = handler.getOrderingFacilityAddress();
        if (!stringIsNullOrEmpty(handler.getOrderingFacilityName())){
	        cell.setPhrase(new Phrase("Ordering Facility: ", boldFont));
	        rInfoTable.addCell(cell);
	        cell.setPhrase(new Phrase(handler.getOrderingFacilityName(), font));
	        rInfoTable.addCell(cell);
	        
	        if (address != null && address.size() > 0){
		        cell.setPhrase(new Phrase("Address: ", boldFont));
		        rInfoTable.addCell(cell);
		        cell.setPhrase(new Phrase(getFullAddress(handler.getOrderingFacilityAddress()), font));
		        rInfoTable.addCell(cell);
	        }
        }
        
        cell.setPhrase(new Phrase("Ordering Provider: ", boldFont));
        rInfoTable.addCell(cell);   
        cell.setPhrase(getDoctorNamePhrase(handler.getDocName()));
        rInfoTable.addCell(cell);
        
        address = handler.getOrderingProviderAddress(); 
        if (address != null && address.size() > 0){
	        cell.setPhrase(new Phrase("Address: ", boldFont));
	    	rInfoTable.addCell(cell);
	        fullAddress = getFullAddress(handler.getOrderingProviderAddress());
	        cell.setPhrase(new Phrase(fullAddress, font));
	        rInfoTable.addCell(cell);
        }
        
        for(HashMap<String, String> phone : handler.getOrderingProviderPhones()){
        	String phoneNumber = "";
        	//Adds the phone's use
        	cell.setPhrase(new Phrase(phone.get("useCode") + ": ", boldFont));
        	rInfoTable.addCell(cell);
        	//Adds the phone number
        	phoneNumber = getPhone(phone);
        	cell.setPhrase(new Phrase(phoneNumber, font));
        	rInfoTable.addCell(cell);
        }
        
        if (!stringIsNullOrEmpty(handler.getAttendingProviderName())){
        	cell.setPhrase(new Phrase("Attending Provider: ", boldFont));
        	rInfoTable.addCell(cell);
            cell.setPhrase(getDoctorNamePhrase(handler.getAttendingProviderName()));
            rInfoTable.addCell(cell);
        }
        
        if (!stringIsNullOrEmpty(handler.getAdmittingProviderName())){
        	cell.setPhrase(new Phrase("Admitting Provider: ", boldFont));
        	rInfoTable.addCell(cell);
            cell.setPhrase(getDoctorNamePhrase(handler.getAdmittingProviderName()));
            rInfoTable.addCell(cell);
        }
    
        String primaryFacility = handler.getPerformingFacilityName();
        String reportingFacility = handler.getReportingFacilityName();
        
        if (!stringIsNullOrEmpty(primaryFacility)){
        	//Determines if the performing facility is also the reporting facility and adds it and the name
        	String facilityRole = "Performing " + (primaryFacility.equals(reportingFacility) ? "and Reporting " : "") + "Facility: ";
        	cell.setPhrase(new Phrase(facilityRole, boldFont));
        	rInfoTable.addCell(cell);
        	cell.setPhrase(new Phrase(primaryFacility, font));
        	rInfoTable.addCell(cell);
        	//Creates the format for the address and adds it
        	address = handler.getPerformingFacilityAddress();
        	if (address != null && address.size() > 0){
        		cell.setPhrase(new Phrase("Address: ", boldFont));
            	rInfoTable.addCell(cell);
        		fullAddress = getFullAddress(address);
        		cell.setPhrase(new Phrase(fullAddress, font));
        		rInfoTable.addCell(cell);
        	}
        }
        
        if (!stringIsNullOrEmpty(reportingFacility) && !reportingFacility.equals(primaryFacility)){
        	//Adds reporting facility name
        	cell.setPhrase(new Phrase("Reporting Facility: ", boldFont));
        	rInfoTable.addCell(cell);
        	cell.setPhrase(new Phrase(reportingFacility, font));
        	rInfoTable.addCell(cell);
        	
        	
        	//Creates the format for the address and adds it
        	address = handler.getReportingFacilityAddress();
        	if (address != null && address.size() > 0){
        		cell.setPhrase(new Phrase("Address: ", boldFont));
            	rInfoTable.addCell(cell);
            	
        		fullAddress = getFullAddress(address);
        		cell.setPhrase(new Phrase(fullAddress, font));
        		rInfoTable.addCell(cell);;
        	}
        }
        
        //Create comment table
        Phrase commentPhrase = new Phrase();
        PdfPTable commentTable = new PdfPTable(1);
        commentTable.setWidthPercentage(100);
        cell.setHorizontalAlignment(Element.ALIGN_LEFT);
        cell.setColspan(1);
        cell.setPhrase(new Phrase("Report Comments: ", boldFont));
        commentTable.addCell(cell);
        for (int commentIndex = 0; commentIndex < handler.getReportCommentCount(); commentIndex++){
            
            String comment = handler.getReportCommentForPdf(commentIndex);

            // Replace repeatable encoded characters with their pdf equivalent replacements
            comment = OLISLabPDFUtils.Hl7EncodedRepeatableCharacter.performReplacement(comment);
            
            // Split comment on \.ce\ (center tag span) markup, due to the fact that adding centered text requires cell-level alignment
            Pattern pattern = Pattern.compile("\\\\\\.ce\\\\(.+?)\n");
            Matcher matcher = pattern.matcher(comment);
            while (matcher.find()) {
                String beforeSpan = comment.substring(0, matcher.start());
                String spanContent = matcher.group(1);
                String afterSpan = comment.substring(matcher.end());
                
                // Create cell for comment before center tag
                cell = new PdfPCell(OLISLabPDFUtils.createPhraseFromHl7(beforeSpan, font));
                cell.setPaddingLeft(10);
                cell.setBorder(0);
                commentTable.addCell(cell);
                
                // Create cell for comment within center tag
                cell = new PdfPCell(OLISLabPDFUtils.createPhraseFromHl7(spanContent, font));
                cell.setHorizontalAlignment(Element.ALIGN_CENTER);
                cell.setPaddingLeft(10);
                cell.setBorder(0);
                commentTable.addCell(cell);

                // Set comment to remaining comment text
                comment = afterSpan;
            }
            
            commentPhrase = OLISLabPDFUtils.createPhraseFromHl7(comment, font);
            commentPhrase.setFont(subscriptFont);
            commentPhrase.add("\t\t" + handler.getReportSourceOrganization(commentIndex));
            cell = new PdfPCell(commentPhrase);
            cell.setPaddingLeft(10);
            cell.setBorder(0);
            commentTable.addCell(cell);
        }
        

        
        //Create header info table
        float[] tableWidths = {2f, 3f};
        PdfPTable table = new PdfPTable(tableWidths);
        if (multiID.length > 1){
            cell = new PdfPCell(new Phrase("Version: "+versionNum+" of "+multiID.length, boldFont));
            cell.setBackgroundColor(new Color(210, 212, 255));
            cell.setPadding(3);
            cell.setColspan(2);
            table.addCell(cell);
        }
        cell = new PdfPCell(new Phrase("Detail Results: Patient Info", boldFont));
        cell.setBackgroundColor(new Color(210, 212, 255));
        cell.setPadding(5);
        table.addCell(cell);
        cell.setPhrase(new Phrase("Results Info", boldFont));
        table.addCell(cell);

        // add the created tables to the document
        table = addTableToTable(table, pInfoTable, 1);
        table = addTableToTable(table, rInfoTable, 1);
        table = addTableToTable(table, commentTable, 2);

        table.setWidthPercentage(100);

        document.add(table);
    }

	/**
	 * Creates the client table which is displayed at the end of the report
	 * 
	 * @throws DocumentException Throws DocumentException when the client table cannot be added to the document
	 */
	private void createClientTable() throws DocumentException {
    	float[] clientTableWidths = {1f, 1f, 1f};
		PdfPTable clientTable = new PdfPTable(clientTableWidths);
		clientTable.setWidthPercentage(100);
		
		PdfPCell header = new PdfPCell();
		header.setBackgroundColor(new Color(210, 212, 255));
		header.setPadding(5);
		// Adds the CC header and list to the table, spanning 3 columns
		header.setPhrase(new Phrase("CC List", boldFont));
		header.setColspan(3);
		clientTable.addCell(header);
		PdfPTable ccTable = getCcTable();
		// Adds the ccTable to the client table with no padding and a border 
		addTableToTable(clientTable, ccTable, 3, true, false);
		
		// Returns the colspan of the header cell to 1
		header.setColspan(1);
		
		//Sets the headers for the remaining tables
		header.setPhrase(new Phrase("Ordering Facility", boldFont));
		clientTable.addCell(header);
		header.setPhrase(new Phrase("Admitting Provider", boldFont));
		clientTable.addCell(header);
		header.setPhrase(new Phrase("Attending Provider", boldFont));
		clientTable.addCell(header);
		
		// Adds the ordering facility table to the client table
		PdfPTable orderingTable = getOrderingFacilityTable();
		addTableToTable(clientTable, orderingTable, 1);

		// Adds the admitting provider table to the client table
		PdfPTable admittingTable = new PdfPTable(1);
		addProviderToTable(admittingTable, handler.parseDoctor(handler.getAdmittingProviderName()));
		addTableToTable(clientTable, admittingTable, 1, true, false);

		// Adds the attenting provider table to the client table
		PdfPTable attendingTable = new PdfPTable(1);
		addProviderToTable(attendingTable, handler.parseDoctor(handler.getAttendingProviderName()));
		addTableToTable(clientTable, attendingTable, 1, true, false);
		
		// Adds the client table to the document
		document.add(clientTable);
	}

	/**
	 * Gets the CC List table
	 * 
	 * @return A table with all CC recipients
	 */
	private PdfPTable getCcTable() {
    	PdfPTable ccTable = new PdfPTable(new float[]{1, 1, 1});
    	// Gets the CC doctors in a map format
    	List<HashMap<String, String>> formattedCcDoctors = handler.getFormattedCcDocs();
    	// Loops through each formatted CC doctor and adds them to the table
		for (HashMap<String, String> doctorMap : formattedCcDoctors) {
			addProviderToTable(ccTable, doctorMap);
		}
		// Sets the default cell's border to 0
		ccTable.getDefaultCell().setBorder(0);
		// Fills any remaining spaces in the row with the default cell
		ccTable.completeRow();
		
		return ccTable;
	}

	/**
	 * Generates the ordering facility table, displaying the ordering facility's names and address
	 * 
	 * @return Table containing the ordering facility information
	 */
	private PdfPTable getOrderingFacilityTable() {
		PdfPTable orderingFacilityTable = new PdfPTable(new float[]{1, 2});

		PdfPCell cell = new PdfPCell();
		cell.setBorder(0);
		cell.setPaddingTop(10);
		
		cell.setColspan(2);
		cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
		Phrase orderingFacility = new Phrase(handler.getOrderingFacilityName(), font);
		orderingFacility.setFont(subscriptFont);
		orderingFacility.add("\t" + handler.getOrderingFacilityOrganization());
		cell.setPhrase(orderingFacility);
		orderingFacilityTable.addCell(cell);
		
		cell.setPaddingTop(3);
		cell.setColspan(1);
		cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
		cell.setPhrase(new Phrase("Address: ", boldFont));
		orderingFacilityTable.addCell(cell);

		HashMap<String, String> addressMap = handler.getOrderingFacilityAddress();
		
		String formattedAddress = "";
		formattedAddress += getAddressFieldIfNotNullOrEmpty(addressMap, "Street Address");
		formattedAddress += getAddressFieldIfNotNullOrEmpty(addressMap, "Other Designation");
		formattedAddress += getAddressFieldIfNotNullOrEmpty(addressMap, "Postal Code", false);
		formattedAddress += ", " + getAddressFieldIfNotNullOrEmpty(addressMap, "City", false);
		formattedAddress += ", " + getAddressFieldIfNotNullOrEmpty(addressMap, "Province", false);
		formattedAddress += ", " + getAddressFieldIfNotNullOrEmpty(addressMap, "Country", false);
		
		cell.setPhrase(new Phrase(formattedAddress, font));
		orderingFacilityTable.addCell(cell);
		
		return orderingFacilityTable;
	}

	/**
	 * Parses a name string and outputs it on two rows, identifying the name and their license type and number 
	 * 
	 * @param table Table to add the doctor to
	 * @param doctorMap Map with elements relating to the doctor's name and licence type and number
	 */
	private void addProviderToTable(PdfPTable table, HashMap<String, String> doctorMap) {
    	PdfPTable doctorTable = new PdfPTable(new float[] {1, 2});
		PdfPCell cell = new PdfPCell();
		cell.setBorder(0);
		
		cell.setPaddingTop(5);
		cell.setPhrase(new Phrase("Name: ", boldFont));
		doctorTable.addCell(cell);
		cell.setPhrase(new Phrase(doctorMap.get("name"), font));
		doctorTable.addCell(cell);
		cell.setPaddingTop(0);
		cell.setPhrase(new Phrase(doctorMap.get("licenceType") + " #: ", boldFont));
		doctorTable.addCell(cell);
		cell.setPhrase(new Phrase(doctorMap.get("licenceNumber"), font));
		doctorTable.addCell(cell);
		
		addTableToTable(table, doctorTable, 1, false, true);
	}
	
    
    private PdfPTable addTableToTable(PdfPTable main, PdfPTable add, int colspan){
    	return addTableToTable(main, add, colspan, true, false);
	}
	
	/*
	 *  addTableToTable(PdfPTable main, PdfPTable add) adds the table 'add' as
	 *  a cell spanning 'colspan' columns to the table main.
	 */
    private PdfPTable addTableToTable(PdfPTable main, PdfPTable add, int colspan, boolean noPadding, boolean hideBorder){
        PdfPCell cell = new PdfPCell(add);
		cell.setColspan(colspan);
		
        if (!noPadding) {
			cell.setPadding(3);
		}
		
        if (hideBorder) {
        	cell.setBorder(0);
		}
		
        main.addCell(cell);
        return main;
    }

    /*
     *  onEndPage is a page event that occurs when a page has finished being created.
     *  It is used to add header and footer information to each page.
     */
    public void onEndPage(PdfWriter writer, Document document){
        try {

            Rectangle page = document.getPageSize();
            PdfContentByte cb = writer.getDirectContent();
            BaseFont bf = BaseFont.createFont(BaseFont.TIMES_ROMAN, BaseFont.CP1252, BaseFont.NOT_EMBEDDED);
			BaseFont boldFont = BaseFont.createFont(BaseFont.TIMES_BOLD, BaseFont.CP1252, BaseFont.NOT_EMBEDDED);
            int pageNum = document.getPageNumber();
            float width = page.getWidth();
            float height = page.getHeight();

            // Add patient information header
            cb.beginText();
            cb.setFontAndSize(bf, 9);
            String patientInformation = "Patient: " + handler.getPatientName()  + " | Health Number: " + handler.getFormattedHealthNumber();
            cb.showTextAligned(PdfContentByte.ALIGN_LEFT, patientInformation, 35, height - 15, 0);
            
            // Adds text describing the report is from OLIS and the ministry of health
            cb.setFontAndSize(boldFont, 9);
            String disclaimer = "Ministry of Health and Long-Term Care";
            cb.showTextAligned(PdfContentByte.ALIGN_LEFT, disclaimer, 35, height - 30, 0);
            
            String disclaimerLineTwo = "Ontario Laboratories Information System (OLIS)";
            cb.showTextAligned(PdfContentByte.ALIGN_LEFT, disclaimerLineTwo, 35, height - 40, 0);
 
            // Sets the generated message
            cb.setFontAndSize(bf, 9);
            String generatedMessage = "Generated from OLIS on " + handler.getMsgDate() + " by user " + printingProvider.getFirstName() + " " + printingProvider.getLastName();
            cb.showTextAligned(PdfContentByte.ALIGN_RIGHT, generatedMessage, 575, height - 40, 0);
            cb.endText();

            //add footer for every page
			cb.beginText();
			cb.setFontAndSize(BaseFont.createFont(BaseFont.HELVETICA_OBLIQUE, BaseFont.CP1252, BaseFont.NOT_EMBEDDED), 8);
			cb.showTextAligned(PdfContentByte.ALIGN_LEFT, "CONFIDENTIAL - report contains Personal Health Information", 35, 30, 0);
			cb.endText();
			
            cb.beginText();
            cb.setFontAndSize(bf, 8);
            cb.showTextAligned(PdfContentByte.ALIGN_CENTER, "-"+pageNum+"-", width/2, 30, 0);
            cb.endText();


            // add promotext as footer if it is enabled
            if ( OscarProperties.getInstance().getProperty("FORMS_PROMOTEXT") != null){
                cb.beginText();
                cb.setFontAndSize(BaseFont.createFont(BaseFont.HELVETICA,BaseFont.CP1252,BaseFont.NOT_EMBEDDED), 6);
                cb.showTextAligned(PdfContentByte.ALIGN_CENTER, OscarProperties.getInstance().getProperty("FORMS_PROMOTEXT"), width/2, 19, 0);
                cb.endText();
            }

        // throw any exceptions
        } catch (Exception e) {
            throw new ExceptionConverter(e);
        }
    }
    
    public String getAddressFieldIfNotNullOrEmpty(HashMap<String,String> address, String key) {
    	return getAddressFieldIfNotNullOrEmpty(address, key, true);
    }
    
    public String getAddressFieldIfNotNullOrEmpty(HashMap<String,String> address, String key, boolean newLine) {
    	String value = address.get(key);
    	if (stringIsNullOrEmpty(value)) { return ""; }
    	String result = value + (newLine ? "\n" : "");
    	return result;
    }
    
    public boolean stringIsNullOrEmpty(String s) {
    	return s == null || s.trim().length() == 0;
    }
    
    public String getFullAddress(HashMap<String, String> address){
    	
    	String city = getAddressFieldIfNotNullOrEmpty(address, "City", false);
    	String province = getAddressFieldIfNotNullOrEmpty(address, "Province", false);
    	
    	String fullAddress = "";
    	fullAddress += getAddressFieldIfNotNullOrEmpty(address, "Street Address");
    	fullAddress += getAddressFieldIfNotNullOrEmpty(address, "Other Designation");
    	fullAddress += getAddressFieldIfNotNullOrEmpty(address, "Postal Code");
    	fullAddress += city + ("".equals(city) || "".equals(province) ? "" : ", ") + province + ("".equals(city) && "".equals(province) ? "" : "\n");
    	fullAddress += getAddressFieldIfNotNullOrEmpty(address, "Country", false);
    	
    	return fullAddress;
    }
    
    public String getPhone(HashMap<String, String> phone){
    	
    	String phoneNumber = "";
    	if (phone.get("email") != null){
    		phoneNumber = phone.get("email");
    	}
    	else{
    		String countryCode = phone.get("countryCode");
   			if (stringIsNullOrEmpty(countryCode)) {
   				countryCode = "";
   			}

   			String localNumber = phone.get("localNumber");
   			if (!stringIsNullOrEmpty(localNumber) && localNumber.length() > 4) {
   				localNumber = localNumber.substring(0,3) + "-" + localNumber.substring(3);
   			}
   			else { localNumber = ""; }
   			
   			String areaCode = phone.get("areaCode");
   			if (!stringIsNullOrEmpty(areaCode)) {
   				areaCode = " ("+areaCode+") ";
   			}
   			else { areaCode = ""; }
   			
   			String extension = phone.get("extension");
   			if (!stringIsNullOrEmpty(extension)) {
   				extension = " x" + extension;
   			}
   			else { extension = ""; }
   			
   			phoneNumber = countryCode + areaCode + localNumber + extension;
    	}
    	
    	return phoneNumber;
    }
    
	public PdfPTable createCollectionTable(Integer obr){
    	PdfPTable collectionTable = new PdfPTable(3);
    	//Sets the default cell's border to 0 in case completeRow() needs to add in a cell
    	collectionTable.getDefaultCell().setBorder(0);
    	//Gets the data from the handler
        JSONObject obrHeader = handler.getObrHeader(obr);
		String specimenType = obrHeader.getString(OLISHL7Handler.OBR_SPECIMEN_TYPE);
		String siteModifier = obrHeader.getString(OLISHL7Handler.OBR_SITE_MODIFIER);
    	String collectionDateTime = handler.getCollectionDateTime(obr);
        String specimenCollectedBy = handler.getSpecimenCollectedBy(obr);
        String collectionVolume = handler.getCollectionVolume(obr);
        String noOfSampleContainers = handler.getNoOfSampleContainers(obr);
		String specimenReceivedDate = obrHeader.getString(OLISHL7Handler.OBR_SPECIMEN_RECEIVED_DATETIME);
		specimenReceivedDate = specimenReceivedDate.equals(handler.getSpecimenReceivedDateTime()) ? "" : specimenReceivedDate;
        
        // Adds each item for the collection table using the addCollectionItem function
		addCollectionItem(collectionTable, "Specimen Type", specimenType);
		addCollectionItem(collectionTable, "Collection Date/Time", collectionDateTime);
		addCollectionItem(collectionTable, "Specimen Collected By", specimenCollectedBy);
		if (!siteModifier.isEmpty()) {
			addCollectionItem(collectionTable, "Site Modifier", siteModifier);
			collectionTable.completeRow();
		}
		addCollectionItem(collectionTable, "Collection Volume", collectionVolume);
		addCollectionItem(collectionTable, "No. of Sample Containers", noOfSampleContainers);
		addCollectionItem(collectionTable, "Specimen Received Date/Time", specimenReceivedDate);
		
        //Returns the collection table
        return collectionTable;
    }

	/**
	 * Adds an item for the collection header to the given collection table. If the value is empty, then it adds an empty pace to the collection table to retain formatting
	 * @param collectionTable Collection table to add the title and value to
	 * @param title Title of the section
	 * @param value Value that matches with the title
	 */
	private void addCollectionItem(PdfPTable collectionTable, String title, String value) {
    	// Instantiates a new innerTable and cell
		PdfPTable innerTable = new PdfPTable((1));
		PdfPCell cell = new PdfPCell();
		cell.setBorder(0);
		cell.setHorizontalAlignment(Element.ALIGN_CENTER);
		
		// Checks if the value is empty. If so, then skips adding the title/value
		if (!stringIsNullOrEmpty(value)) {
			//Adds the header and the value of the collection date time
			cell.setPhrase(new Phrase(title, boldFont));
			innerTable.addCell(cell);
			cell.setPhrase(new Phrase(value, font));
			innerTable.addCell(cell);
		}
		
		//Adds the inner table to the collectionCell
		PdfPCell collectionCell = new PdfPCell(innerTable);
		collectionCell.setBorder(0);
		//Adds the collectionCell to the collectionTable
		collectionTable.addCell(collectionCell);
	}
    
    /**
     * Takes a string of docNames, specifically the one returned from handler.getCCDocNames()
     * Converts the string into a phrase containing all doc names
     * @param docNames
     * @return ccDocNames
     */
    private Phrase getCCDocNamesPhrase(String docNames){
    	Phrase ccDocNames = new Phrase();
    	String[] splitNames;
    	
    	ccDocNames.setFont(boldFont);
    	ccDocNames.add("cc: Client:  ");
    	ccDocNames.setFont(font);
    	
    	splitNames = docNames.split(", ");
    	
    	for(String docName : splitNames){
    		
    		for(Object chunk : getDoctorNamePhrase(docName).getChunks()){
    			ccDocNames.add(chunk);
    		}
    		ccDocNames.add(new Chunk(", ", font));
    	}
    	ccDocNames.remove(ccDocNames.size() - 1);
    	
    	return ccDocNames;
    }
    /**
     * Takes a doctor name string and turns it into a phrase that contains the doctor 
     * name in normal font, and then their MD number in the smaller font
     * @param doctorName
     * @return doctorPhrase
     */
    private Phrase getDoctorNamePhrase(String doctorName){
    	
    	Integer openSpanStart = doctorName.indexOf("<");
        String mdNumber = "";
        
        if (openSpanStart != -1){
        	Integer openSpanEnd = doctorName.indexOf(">");
        	Integer closeSpanStart = doctorName.indexOf("<", openSpanEnd);
        	Integer closeSpanEnd = doctorName.indexOf(">", closeSpanStart);

        	mdNumber = doctorName.substring(openSpanEnd + 1, closeSpanStart);
        	doctorName = doctorName.substring(0, openSpanStart);
        }
        
        Phrase doctorPhrase = new Phrase();
        //doctorPhrase.setFont(font);
        doctorPhrase.add(new Chunk(doctorName, font));
        //doctorPhrase.setFont(subscriptFont);
        doctorPhrase.add(new Chunk("\t" + mdNumber, subscriptFont));
        
        return doctorPhrase;
    }
}