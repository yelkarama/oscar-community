package org.oscarehr.olis;
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
import java.io.File;
import java.io.InputStream;
import java.io.StringReader;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.xml.bind.JAXBContext;
import javax.xml.bind.JAXBElement;
import javax.xml.bind.Unmarshaller;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.transform.Source;
import javax.xml.transform.stream.StreamSource;
import javax.xml.validation.SchemaFactory;

import org.apache.log4j.Logger;
import org.oscarehr.common.dao.Hl7TextInfoDao;
import org.oscarehr.common.model.Hl7TextInfo;
import org.oscarehr.util.LoggedInInfo;
import org.oscarehr.util.MiscUtils;
import org.oscarehr.util.OscarAuditLogger;
import org.oscarehr.util.SpringUtils;
import org.xml.sax.InputSource;

import ca.ssha._2005.hial.Response;
import oscar.OscarProperties;
import oscar.oscarLab.ca.all.parsers.Factory;
import oscar.oscarLab.ca.all.parsers.OLISHL7Handler;
import oscar.oscarLab.ca.all.upload.handlers.HL7Handler;


public class OLISUtils {
	static Logger logger = MiscUtils.getLogger();
	
	static Hl7TextInfoDao hl7TextInfoDao = SpringUtils.getBean(Hl7TextInfoDao.class);
	
	static final public String CMLIndentifier = "2.16.840.1.113883.3.59.1:5047";// Canadian Medical Laboratories
	static final public String GammaDyancareIndentifier = "2.16.840.1.113883.3.59.1:5552";// Gamma Dynacare
	static final public String LifeLabsIndentifier = "2.16.840.1.113883.3.59.1:5687";// LifeLabs
	static final public String AlphaLabsIndetifier = "2.16.840.1.113883.3.59.1:5254";// Alpha Laboratories"

	private static int previousLineLength = 0;
	public enum Hl7EncodedRepeatableCharacter {
		INDENT("in", " ", "&nbsp;"),
		SKIP_SPACE("sk", " ", "&nbsp;"),
		TEMPORARY_INDENT("ti", " ", "&nbsp;"),
		HARD_RETURN("br", "\n", "<br/>"),
		NEXT_LINE_ALIGN_HORIZONTAL("sp", "\n", "<br/>"),
		HIGHLIGHT_START("H", "", "<span style=\"color:#767676\">"),
		HIGHLIGHT_END("N", "", "</span>"),
		CENTER("ce", "", "<center>");

		public static final String TAG_REGEX = "\\\\\\.%s[ ]?(?:([ +-])?(\\d))*\\\\";
		private String hl7Tag;
		private String pdfReplacement;
		private String htmlReplacement;

		Hl7EncodedRepeatableCharacter(String hl7Tag, String pdfReplacement, String htmlReplacement) {
			this.hl7Tag = hl7Tag;
			this.pdfReplacement = pdfReplacement;
			this.htmlReplacement = htmlReplacement;
		}

		public String getHl7Tag() {
			return hl7Tag;
		}
		public String getPdfReplacement() {
			return pdfReplacement;
		}
		public String getHtmlReplacement() {
			return htmlReplacement;
		}

		/**
		 * Gets the enum's formatted regex to be used for matching
		 * @return The formatted regex for the enumeration
		 */
		public String getFormattedRegex() {
			return String.format(TAG_REGEX, this.hl7Tag);
		}

		public static String performReplacement(String hl7Text, boolean replaceHtml) {
			int maxCharactersPerPdfLine = 92;
			int maxCharactersPerHtmlLine = 109;
			// Instantiates the html of the closing center tag
			String centerClose = "</center>";
			// Checks to see if an \.sp\ element exists, this will prevent \.br\ element from calculating the length of the last line as it will then need to calculate from the \.sp\ element
			boolean spElementExists = Pattern.compile(Hl7EncodedRepeatableCharacter.NEXT_LINE_ALIGN_HORIZONTAL.getFormattedRegex()).matcher(hl7Text).find();


			int charactersPerLine = replaceHtml ? maxCharactersPerHtmlLine : maxCharactersPerPdfLine;

			for (Hl7EncodedRepeatableCharacter hl7EncodedCharacter : Hl7EncodedRepeatableCharacter.values()) {
				// If the replacements are happening for PDF printing and the character has no pdf variation, skips the replacement as it is handled elsewhere
				if (!replaceHtml && hl7EncodedCharacter.getPdfReplacement().isEmpty()) {
					continue;
				}
				String replacementString;
				// Checks if the replacement is happening for HTML, if so then it gets the html version of the tag, if not then it gets the PDF version
				if (replaceHtml) {
					// Gets the HTML version of the HL7 tag
					replacementString = hl7EncodedCharacter.getHtmlReplacement();
				} else {
					// Gets the PDF version of the HL7 tag
					replacementString = hl7EncodedCharacter.getPdfReplacement();
				}

				String regex = hl7EncodedCharacter.getFormattedRegex();
				Pattern pattern = Pattern.compile(regex);
				Matcher matcher = pattern.matcher(hl7Text);
				while (matcher.find()) {
					String repetitionsGroup = matcher.group(2);
					int repetitions = 1;
					if (repetitionsGroup != null) {
						repetitions = Integer.valueOf(repetitionsGroup);
					}

					StringBuilder replacedText = new StringBuilder();
					// If there is no operator or it is a minus sign, we don't need to add the elements
					if (matcher.group(1) == null || !matcher.group(1).equals("-")) {
						for (int i = 0; i < repetitions; i++) {
							replacedText.append(replacementString);
						}
					}

					// If the current tag is a standard line break and there are no \.sp\ elements in the text then calculate the previous line's length based on the \.br\
					// If there are \.sp\ elements then the length of the previous sentence is calculated uses the current \.sp\, not \.br\
					if (hl7EncodedCharacter.getHl7Tag().equals("br") && !spElementExists) {
						// Calculates the previous line count based on the current \.br\ element after replacing all nbsp instances with a single space to represent the proper length
						String previousLine = hl7Text.substring(matcher.end());
						previousLineLength = previousLine.replaceAll("&nbsp;", " ").length();
					} else if (hl7EncodedCharacter.getHl7Tag().equals("sp")) {
						// If the \.sp\ element is not in the first index, gets the previous line length based on the last newline
						// If the \.sp\ element is the first in the index then the spacing needs to be calculated based on the previous comment's last line
						if (matcher.start() > 0) {
							// Gets the text before the matching element, removing all instances of newline characters that happen at the end of the string and all nbsp with single space characters so
							// the proper line length is represented better
							String previousLine = hl7Text.substring(0, matcher.start()).replaceAll("(" + replacementString + "|\\s)*$", "").replaceAll("&nbsp;", " ")
									.replaceAll("\\\\\\..+?\\\\", "");
							// Gets the last index of the replacement string in order to calculate the length of the previous line
							int previousLineStart = previousLine.lastIndexOf(replacementString);
							// Substrings the previousLine from the previousLineStart plus the length of the replacement string so that it isn't included in the length
							previousLine = previousLine.substring(previousLineStart + replacementString.length());
							// Gets the previous lines length
							previousLineLength = previousLine.length();
						}
						// Gets the needed spacing for the current line by getting the number of characters that overflow into the current line
						int numberOfSpacesToAdd = previousLineLength % charactersPerLine;
						// Creates a string with the number of spaces that need to be added
						String spacesToAdd = new String(new char[numberOfSpacesToAdd]).replaceAll("\0", " ");
						// Adds the spaces to the text that will be replacing the current match
						replacedText.append(spacesToAdd);
					} else if (hl7EncodedCharacter.getHl7Tag().equals("ce")) {
						// If the current element is to center the text, searches for the appropriate index to close the center element
						// Attempts to get the next line break to use as the index to close the center tag.
						int closeIndex = hl7Text.indexOf("<br/>", matcher.end());
						// If there isn't a line break after the center tag, looks for the next center tag to use it as the closing index
						if (closeIndex == -1) {
							closeIndex = hl7Text.indexOf("\\.ce\\", matcher.end());
						}
						// If a close index was found, inserts the close tag in that index
						// If a close index was not found, appends the close tag onto the end of the hl7 text
						if (closeIndex > -1) {
							hl7Text = new StringBuilder(hl7Text).insert(closeIndex, centerClose).toString();
						} else {
							hl7Text += centerClose;
						}
					}
					// Replaces the first instance of the regex
					hl7Text = hl7Text.replaceFirst(regex, replacedText.toString());
					// Resets the text in the matcher so proper indexes and lengths can be acquired
					matcher = pattern.matcher(hl7Text);
				}
			}
			return hl7Text;
		}
	}
	
	public static String getOLISResponseContent(String response) throws Exception{
		response = response.replaceAll("<Content", "<Content xmlns=\"\" ");
		response = response.replaceAll("<Errors", "<Errors xmlns=\"\" ");
		
		DocumentBuilderFactory.newInstance().newDocumentBuilder();
		SchemaFactory factory = SchemaFactory.newInstance("http://www.w3.org/2001/XMLSchema");
		
		InputStream is = OLISPoller.class.getResourceAsStream("/org/oscarehr/olis/response.xsd");
		
		Source schemaFile = new StreamSource(is);
	
		if(OscarProperties.getInstance().getProperty("olis_response_schema") != null){
			schemaFile = new StreamSource(new File(OscarProperties.getInstance().getProperty("olis_response_schema")));
		}
		
		factory.newSchema(schemaFile);

		JAXBContext jc = JAXBContext.newInstance("ca.ssha._2005.hial");
		Unmarshaller u = jc.createUnmarshaller();
		@SuppressWarnings("unchecked")
		Response root = ((JAXBElement<Response>) u.unmarshal(new InputSource(new StringReader(response)))).getValue();
		
		return root.getContent();
	}
	

	
	
	
	public static boolean isDuplicate(LoggedInInfo loggedInInfo, String msg) {
		oscar.oscarLab.ca.all.parsers.OLISHL7Handler h = (oscar.oscarLab.ca.all.parsers.OLISHL7Handler) Factory.getHandler("OLIS_HL7", msg);
		return isDuplicate(loggedInInfo, h,msg);
	}
	
	
	public static boolean isDuplicate(LoggedInInfo loggedInInfo, OLISHL7Handler h,String msg) {
		
		String sendingFacility = h.getPlacerGroupNumber();//getPerformingFacilityNameOnly();
		logger.debug("SENDING FACILITY: " +sendingFacility);
		String accessionNumber = h.getAccessionNum();
		String hin = h.getHealthNum();

	
		return isDuplicate(loggedInInfo, sendingFacility,accessionNumber,msg,hin);
	}
	
	
	public static boolean isDuplicate(LoggedInInfo loggedInInfo, String sendingFacility, String accessionNumber,String msg,String hin){
		logger.debug("Facility "+sendingFacility+" Accession # "+accessionNumber);

		if(sendingFacility != null &&  sendingFacility.equals(CMLIndentifier)){ //.startsWith("CML")){ // CML HealthCare Inc.
			List<Hl7TextInfo> dupResults = hl7TextInfoDao.searchByAccessionNumber(accessionNumber.split("-")[0]);
			for(Hl7TextInfo dupResult:dupResults) {
				String dupResultAccessionNum = dupResult.getAccessionNumber();
				
				if(dupResultAccessionNum.indexOf("-") != -1){
					dupResultAccessionNum = dupResultAccessionNum.split("-")[0];
				}	
				
					//direct
				if(dupResultAccessionNum.equals(accessionNumber.split("-")[0])) {
						if(hin.equals(dupResult.getHealthNumber())) {
							OscarAuditLogger.getInstance().log(loggedInInfo, "Lab", "Skip", "Duplicate CML lab skipped - accession " + accessionNumber + "\n" + msg);
							return true;
						}
				}
				
			}
		}else if( sendingFacility != null && sendingFacility.equals(LifeLabsIndentifier)){//  startsWith("LifeLabs")){ //LifeLabs

			List<Hl7TextInfo> dupResults = hl7TextInfoDao.searchByAccessionNumber(accessionNumber.substring(5));
			for(Hl7TextInfo dupResult:dupResults) {
				logger.debug("LIFELABS "+dupResult.getAccessionNumber()+" "+accessionNumber+" == "+dupResult.getAccessionNumber().equals(accessionNumber.substring(5)));
				
				if(dupResult.getAccessionNumber().equals(accessionNumber.substring(5))) {
					if(hin.equals(dupResult.getHealthNumber())) {
						OscarAuditLogger.getInstance().log(loggedInInfo, "Lab", "Skip", "Duplicate LifeLabs lab skipped - accession " + accessionNumber + "\n" + msg);
						return true;
					}
				}
			}		

			
		}else if (sendingFacility != null && sendingFacility.equals(GammaDyancareIndentifier)){// startsWith("GAMMA")){ //GAMMA-DYNACARE MEDICAL LABORATORIES
			String directAcc = accessionNumber.substring(4);
			directAcc = directAcc.substring(0,2) + "-" + Integer.parseInt(directAcc.substring(2));
			List<Hl7TextInfo> dupResults = hl7TextInfoDao.searchByAccessionNumber(directAcc);
			
			for(Hl7TextInfo dupResult:dupResults) {
				logger.debug(dupResult.getAccessionNumber()+" == "+directAcc+" "+dupResult.getAccessionNumber().equals(directAcc));

				if(dupResult.getAccessionNumber().equals(directAcc)) {
					if(hin.equals(dupResult.getHealthNumber())) {
						OscarAuditLogger.getInstance().log(loggedInInfo, "Lab", "Skip", "Duplicate GAMMA lab skipped - accession " + accessionNumber + "\n" + msg);
						return true;
					}
				}
			}		

		}else if (sendingFacility != null && sendingFacility.equals(AlphaLabsIndetifier)){
			List<Hl7TextInfo> dupResults = hl7TextInfoDao.searchByAccessionNumber(accessionNumber.substring(5));
			for(Hl7TextInfo dupResult:dupResults) {
				logger.debug("AlphaLabs "+dupResult.getAccessionNumber()+" "+accessionNumber+" == "+dupResult.getAccessionNumber().equals(accessionNumber.substring(5)));
				
				if(dupResult.getAccessionNumber().equals(accessionNumber.substring(5))) {
					if(hin.equals(dupResult.getHealthNumber())) {
						OscarAuditLogger.getInstance().log(loggedInInfo, "Lab", "Skip", "Duplicate AlphaLabs lab skipped - accession " + accessionNumber + "\n" + msg);
						return true;
					}
				}
			}		

		}
		
		
		
		return false;	
	}
	
	/**
	 * Compares the current OBR's collector comments to the previously displayed OBR's collectors comments to determine if they should be displayed or not 
	 * @param handler The OLISHL7Hander that is being displayed
	 * @param currentObr The current OBR
	 * @param previousObr The OBR that was previously displayed
	 * @return {@code: true} if the comments of the current OBR are different than the previous OBR's comments, {@code: false} if they are the same
	 */
	public static boolean areCollectorCommentsDifferent(OLISHL7Handler handler, int currentObr, int previousObr) {
		// Gets the collector comments from the current and previous OBRs
		String collectorComments = handler.getCollectorsComment(currentObr);
		String previousCollectorComments = handler.getCollectorsComment(previousObr);
	
		// Declares the regex to remove any hl7 tags as well as spaces (to prevent spacing causing an issue for the comparison)
		String hl7TagRegex = "(\\\\\\..+?\\\\|\\s)";
		String taglessCollectorComments = collectorComments.replaceAll(hl7TagRegex, "").trim();
		String taglessPreviousCollectorComments = previousCollectorComments.replaceAll(hl7TagRegex, "").trim();
		// Compares the current and previous collectors comments, returning the opposite for the return of .equals(),
		return !taglessPreviousCollectorComments.equals(taglessCollectorComments);
	}
	
	/**
	 * Compares two strings against each other, also checking if they are empty to determine positioning in the array.
	 * If s1 is empty, then it is considered greater than s2 and is placed after s2 in the array.
	 * If s2 is empty, then s1 is considered less than s2 and is placed before s2 in the array.
	 *
	 * @param s1 The string that is the main item of the Collection
	 * @param s2 The string to be compared to
	 * @return A number greater than {@code: 0} of s1 is empty or lesser than s2
	 *         A number less than {@code: 0} if s2 is empty or s1 is greater than s2
	 */
	public static int compareStringEmptyIsMore(String s1, String s2) {
		if (s1.isEmpty() && !s2.isEmpty()) {
			return 1;
		} else if (s2.isEmpty() && !s1.isEmpty()) {
			return -1;
		} else {
			// If both values are populated or empty, compares them for the ordering
			return s1.toLowerCase().compareTo(s2.toLowerCase());
		}
	}
}
