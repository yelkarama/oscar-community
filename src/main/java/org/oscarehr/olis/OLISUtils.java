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
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Calendar;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.servlet.http.HttpServletRequest;
import javax.xml.bind.JAXBContext;
import javax.xml.bind.JAXBElement;
import javax.xml.bind.JAXBException;
import javax.xml.bind.Unmarshaller;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.transform.Source;
import javax.xml.transform.stream.StreamSource;
import javax.xml.validation.SchemaFactory;

import ca.uhn.hl7v2.HL7Exception;
import ca.uhn.hl7v2.model.Segment;
import ca.uhn.hl7v2.parser.Parser;
import ca.uhn.hl7v2.parser.PipeParser;
import ca.uhn.hl7v2.util.Terser;
import com.indivica.olis.parameters.OBR16;
import com.indivica.olis.parameters.OBR22;
import com.indivica.olis.parameters.OBR25;
import com.indivica.olis.parameters.OBR28;
import com.indivica.olis.parameters.OBR7;
import com.indivica.olis.parameters.ORC21;
import com.indivica.olis.parameters.ORC4;
import com.indivica.olis.parameters.PID3;
import com.indivica.olis.parameters.PID51;
import com.indivica.olis.parameters.PID52;
import com.indivica.olis.parameters.PID7;
import com.indivica.olis.parameters.PID8;
import com.indivica.olis.parameters.PV117;
import com.indivica.olis.parameters.PV17;
import com.indivica.olis.parameters.QRD7;
import com.indivica.olis.parameters.ZBE4;
import com.indivica.olis.parameters.ZBE6;
import com.indivica.olis.parameters.ZBR2;
import com.indivica.olis.parameters.ZBR3;
import com.indivica.olis.parameters.ZBR4;
import com.indivica.olis.parameters.ZBR6;
import com.indivica.olis.parameters.ZBR8;
import com.indivica.olis.parameters.ZBX1;
import com.indivica.olis.parameters.ZPD1;
import com.indivica.olis.parameters.ZPD3;
import com.indivica.olis.parameters.ZRP1;
import com.indivica.olis.queries.Query;
import com.indivica.olis.queries.QueryType;
import com.indivica.olis.queries.RequestingHicQuery;
import com.indivica.olis.queries.Z01Query;
import com.indivica.olis.queries.Z02Query;
import com.indivica.olis.queries.Z04Query;
import com.indivica.olis.queries.Z05Query;
import com.indivica.olis.queries.Z06Query;
import com.indivica.olis.queries.Z07Query;
import com.indivica.olis.queries.Z08Query;
import com.indivica.olis.queries.Z50Query;
import org.apache.commons.lang.StringUtils;
import org.apache.commons.lang.time.DateUtils;
import org.apache.log4j.Logger;
import org.oscarehr.PMmodule.dao.ProviderDao;
import org.oscarehr.common.dao.DemographicDao;
import org.oscarehr.common.dao.Hl7TextInfoDao;
import org.oscarehr.common.dao.OscarLogDao;
import org.oscarehr.common.dao.UserPropertyDAO;
import org.oscarehr.common.model.Demographic;
import org.oscarehr.common.model.Hl7TextInfo;
import org.oscarehr.common.model.OscarLog;
import org.oscarehr.common.model.Provider;
import org.oscarehr.common.model.UserProperty;
import org.oscarehr.olis.dao.OlisQueryLogDao;
import org.oscarehr.olis.model.OlisQueryLog;
import org.oscarehr.olis.model.OlisQueryParameters;
import org.oscarehr.util.LoggedInInfo;
import org.oscarehr.util.MiscUtils;
import org.oscarehr.util.OscarAuditLogger;
import org.oscarehr.util.SpringUtils;
import org.xml.sax.InputSource;

import ca.ssha._2005.hial.Response;
import org.xml.sax.SAXException;
import oscar.OscarProperties;
import oscar.oscarLab.ca.all.parsers.Factory;
import oscar.oscarLab.ca.all.parsers.OLISHL7Handler;


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
							String previousLine = hl7Text.substring(0, matcher.start()).replaceAll("&nbsp;", " ").replaceAll("\\\\\\..+?\\\\", "");
							
							// Gets the last index of the replacement string in order to calculate the length of the previous line
							int previousLineStart = previousLine.lastIndexOf(replacementString);
							// If there is line break, gets the line using it as the start point
							if (previousLineStart > -1) {
								// Substrings the previousLine from the previousLineStart plus the length of the replacement string so that it isn't included in the length
								previousLine = previousLine.substring(previousLineStart + replacementString.length());
							}
							
							// Gets the previous lines length
							previousLineLength = previousLine.replaceAll("(" + replacementString + "|\\s)*$", "").length();
						}
						// Gets the needed spacing for the current line by getting the number of characters that overflow into the current line
						int numberOfSpacesToAdd = previousLineLength % charactersPerLine;
						// If it is HMTL, adds an extra space to circumvent HTML's handling of spaces
						if (replaceHtml) {
							numberOfSpacesToAdd += 1;
						}
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

	/**
	 * Creates a query string for OBR4 and OBX3 that will list out the query codes and the code system correctly and return the generated query string
	 * @param queryCode The query code version
	 * @param codes A list of codes as strings
	 * @param codeSystem The coding system for the codes
	 * @return The generated query for the provided information
	 */
	public static String createQueryStringForCodes(String queryCode, List<String> codes, String codeSystem) {
		StringBuilder query = new StringBuilder();
		query.append(queryCode).append(".1^").append(String.join("&", codes)).append("~").append(queryCode).append(".3^");
		// Adds the coding system to the query string for each code that is being queried
		for (int i = 0; i < codes.size(); i++) {
			// If the current index is greater than 1, appends an ampersand so link the coding systems
			if (i > 0) {
				query.append("&");
			}

			query.append(codeSystem);
		}
		
		return query.toString();
	}

    /**
     * Logs the OLIS transaction into the query log table
     * @param request The request that initiated the query to OLIS, null if the request was done through the polling
     * @param query The query that was used in the request to OLIS
     * @param olisResponse The response OLIS returned
     * @param loggedFileName The name of the file that was saved containing what was sent and OLIS's response
     */
	public static void logTransaction(HttpServletRequest request, Query query, String olisResponse, String loggedFileName) {
		OlisQueryLogDao olisQueryLogDao = SpringUtils.getBean(OlisQueryLogDao.class);
		
		String requestingHic = "";
		String olisTransactionId = "";
		String emrTransactionId = "";
		String initiatingProvider = "System";
		String queryType = "";
		
		// If the request is not null, uses it to get the logged in info and the initiating provider as it was manually submitted and now sent from the automatic polling
		if (request != null) {
			LoggedInInfo loggedInInfo = LoggedInInfo.getLoggedInInfoFromSession(request);
			initiatingProvider = loggedInInfo.getLoggedInProvider().getProviderNo();
		}
		
		try {
		    // Gets the HL7 message and parses it into a new terser object to be used to get some data from the response
			String hl7Message = OLISUtils.getOlisMessage(olisResponse);
			Parser parser = new PipeParser();
			Terser terser = new Terser(parser.parse(hl7Message.replaceAll("\n", "\r\n")));
			// Gets the OLIS and EMR transaction ids 
			olisTransactionId = getOlisTransactionId(terser);
			emrTransactionId = getEmrTransactionId(terser);
		} catch (HL7Exception e) {
			logger.error("Could not create the terser to parse the HL7 message", e);
		} catch (SAXException | JAXBException | ParserConfigurationException | NullPointerException e) {
			logger.error("Could not retrieve the content of the olis response", e);
		}
		
		// Sets the query type based on the query sent as well as if it had a consent override or it was initiated 
        // through polling
		if (query.hasConsentOverride()) {
			queryType = "Consent Overwrite";
		} else if (query.getQueryType().equals(QueryType.Z01)) {
			queryType = "OLIS Patient Query";
		} else if (query.getQueryType().equals(QueryType.Z04)) {
			if (request == null) {
				queryType = "OLIS Provider Query";
			} else {
				queryType = "OLIS Preload Query";
			}
		}
		
		// If the query is an instance of a query that requires a Requesting HIC, gets the requesting HIC to be stored
		if (query instanceof RequestingHicQuery) {
			requestingHic = ((RequestingHicQuery) query).getRequestingHicId();
		}
		// Creates and stores the query information
		OlisQueryLog queryLog = new OlisQueryLog(query.getQueryType().toString(), queryType, initiatingProvider, requestingHic, "OLIS", emrTransactionId, olisTransactionId, loggedFileName);
		olisQueryLogDao.persist(queryLog);
	}

    /**
     * Gets the OLIS message from OLIS's response by parsing it out of the xml into HL7
     * @param olisResponse The response from OLIS
     * @return The HL7 message that was contained in the OLIS response
     * @throws SAXException
     * @throws JAXBException
     * @throws ParserConfigurationException
     */
	public static String getOlisMessage(String olisResponse) throws SAXException, JAXBException, ParserConfigurationException {
		olisResponse = olisResponse.replaceAll("<Content", "<Content xmlns=\"\" ");
		olisResponse = olisResponse.replaceAll("<Errors", "<Errors xmlns=\"\" ");
		
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
		Response root = ((JAXBElement<Response>) u.unmarshal(new InputSource(new StringReader(olisResponse)))).getValue();
		
		return root.getContent();
	}

    /**
     * Gets the OLIS Transaction Id stored in the message that the provided terser was created for, must have 
     * an MSH segment
     * @param terser The terser that contains the HL7 message that was returned from OLIS
     * @return The OLIS transaction id
     */
	public static String getOlisTransactionId(Terser terser) {
		String olisTransactionId = "";
		try {
			Segment msh = terser.getSegment("/.MSH");
			if (msh != null) {
				olisTransactionId = StringUtils.trimToEmpty(Terser.get(msh, 10, 0, 1, 1));
			}
		} catch (HL7Exception e) {
			logger.error("Could not retrieve the OLIS transaction id from the MSH segment", e);
		}
		
		return olisTransactionId;
	}

    /**
     * Gets the EMR Transaction ID stored in the message that the terser was created for, must have an MSA segment
     * @param terser The terser that contains the HL7 message that was returned from OLIS
     * @return The EMR transaction id
     */
	public static String getEmrTransactionId(Terser terser) {
		String emrTransactionId = "";
		try {
			Segment msh = terser.getSegment("/.MSA");
			if (msh != null) {
				emrTransactionId = StringUtils.trimToEmpty(Terser.get(msh, 2, 0, 1, 1));
			}
		} catch (HL7Exception e) {
			logger.error("Could not retrieve the EMR transaction id from the MSA segment", e);
		}

		return emrTransactionId;
	}
	public static Query createOlisQuery(String queryType, LoggedInInfo loggedInInfo, String requestingHic, OlisQueryParameters queryParameters) {
		DemographicDao demographicDao = SpringUtils.getBean(DemographicDao.class);
		ProviderDao providerDao = SpringUtils.getBean(ProviderDao.class);
		UserPropertyDAO userPropertyDAO = SpringUtils.getBean(UserPropertyDAO.class);
		Query query = null;

		String[] dateFormat = new String[] {"yyyy-MM-dd"};

		if (queryType.equalsIgnoreCase("Z01")) {
			query = new Z01Query();
			String startTimePeriod = queryParameters.getStartTimePeriod();
			String endTimePeriod = queryParameters.getEndTimePeriod();

			try {
				if (startTimePeriod != null && startTimePeriod.trim().length() > 0) {
					Date startTime = DateUtils.parseDate(startTimePeriod, dateFormat);
					if (endTimePeriod != null && endTimePeriod.trim().length() > 0) {
						Date endTime = changeToEndOfDay(DateUtils.parseDate(endTimePeriod, dateFormat));

						List<Date> dateList = new LinkedList<Date>();
						dateList.add(startTime);
						dateList.add(endTime);

						OBR22 obr22 = new OBR22();
						obr22.setValue(dateList);

						((Z01Query) query).setStartEndTimestamp(obr22);
					} else {
						OBR22 obr22 = new OBR22();
						obr22.setValue(startTime);

						((Z01Query) query).setStartEndTimestamp(obr22);
					}
				}
			} catch (Exception e) {
				MiscUtils.getLogger().error("Can't parse date given for OLIS query", e);
			}

			String observationStartTimePeriod = queryParameters.getObservationStartTimePeriod();
			String observationEndTimePeriod = queryParameters.getObservationEndTimePeriod();

			try {
				if (observationStartTimePeriod != null && observationStartTimePeriod.trim().length() > 0) {
					Date observationStartTime = DateUtils.parseDate(observationStartTimePeriod, dateFormat);
					if (observationEndTimePeriod != null && observationEndTimePeriod.trim().length() > 0) {
						Date observationEndTime = changeToEndOfDay(DateUtils.parseDate(observationEndTimePeriod, dateFormat));

						List<Date> dateList = new LinkedList<Date>();
						dateList.add(observationStartTime);
						dateList.add(observationEndTime);

						OBR7 obr7 = new OBR7();
						obr7.setValue(dateList);

						((Z01Query) query).setEarliestLatestObservationDateTime(obr7);
					} else {
						OBR7 obr7 = new OBR7();
						obr7.setValue(observationStartTime);

						((Z01Query) query).setEarliestLatestObservationDateTime(obr7);
					}
				}
			} catch (Exception e) {
				MiscUtils.getLogger().error("Can't parse date given for OLIS query", e);
			}


			String quantityLimitedQuery = queryParameters.getQuantityLimitedQuery();
			String quantityLimit = queryParameters.getQuantityLimit();

			try {
				if (quantityLimitedQuery != null && quantityLimitedQuery.trim().length() > 0) {
					// Checked
					((Z01Query) query).setQuantityLimitedRequest(new QRD7(Integer.parseInt(quantityLimit)));
				}
			} catch (Exception e) {
				MiscUtils.getLogger().error("Can't parse the number given for quantity limit in OLIS query", e);
			}


			String blockedInformationConsent = queryParameters.getBlockedInformationConsent();

			if (blockedInformationConsent != null && blockedInformationConsent.trim().length() > 0) {
				((Z01Query) query).setConsentToViewBlockedInformation(new ZPD1(blockedInformationConsent));
			}


			String consentBlockAllIndicator = queryParameters.getConsentBlockAllIndicator();

			if (consentBlockAllIndicator != null && consentBlockAllIndicator.trim().length() > 0) {
				((Z01Query) query).setPatientConsentBlockAllIndicator(new ZPD3("Y"));
			}


			String specimenCollector = queryParameters.getSpecimenCollector();

			if (specimenCollector != null && specimenCollector.trim().length() > 0) {
				((Z01Query) query).setSpecimenCollector(new ZBR3(specimenCollector, "ISO"));
			}


			String performingLaboratory = queryParameters.getPerformingLaboratory();

			if (performingLaboratory != null && performingLaboratory.trim().length() > 0) {
				((Z01Query) query).setPerformingLaboratory(new ZBR6(performingLaboratory, "ISO"));
			}


			String excludePerformingLaboratory = queryParameters.getExcludePerformingLaboratory();

			if (excludePerformingLaboratory != null && excludePerformingLaboratory.trim().length() > 0) {
				((Z01Query) query).setExcludePerformingLaboratory(new ZBE6(excludePerformingLaboratory, "ISO"));
			}


			String reportingLaboratory = queryParameters.getReportingLaboratory();

			if (reportingLaboratory != null && reportingLaboratory.trim().length() > 0) {
				((Z01Query) query).setReportingLaboratory(new ZBR4(reportingLaboratory, "ISO"));

				String placerGroupNumber = queryParameters.getPlacerGroupNumber();
				if (!StringUtils.isEmpty(placerGroupNumber)) {
					((Z01Query) query).setPlacerGroupNumber(new ORC4(placerGroupNumber, reportingLaboratory, "ISO"));
				}
			}


			String excludeReportingLaboratory = queryParameters.getExcludeReportingLaboratory();

			if (excludeReportingLaboratory != null && excludeReportingLaboratory.trim().length() > 0) {
				((Z01Query) query).setExcludeReportingLaboratory(new ZBE4(excludeReportingLaboratory, "ISO"));
			}


			// Patient Identifier (PID.3 -- pull data from db and add to query)
			String demographicNo = queryParameters.getDemographic();
			query.setDemographicNo(demographicNo);
			try {
				if (demographicNo != null && demographicNo.trim().length() > 0) {
					Demographic demo = demographicDao.getDemographic(demographicNo);

					PID3 pid3 = new PID3(demo.getHin(), null, null, "JHN", demo.getHcType(), "HL70347", demo.getSex(), null);
					pid3.setValue(7, DateUtils.parseDate(demo.getYearOfBirth() + "-" + demo.getMonthOfBirth() + "-" + demo.getDateOfBirth(), dateFormat));

					((Z01Query) query).setPatientIdentifier(pid3);
				}
			} catch (Exception e) {
				MiscUtils.getLogger().error("Can't add requested patient data to OLIS query", e);
			}


			// Requesting HIC (ZRP.1 -- pull data from db and add to query)
			try {
				if (requestingHic != null && !requestingHic.trim().isEmpty()) {
					Provider provider = providerDao.getProvider(requestingHic);

					ZRP1 zrp1 = new ZRP1(provider.getPractitionerNo(), userPropertyDAO.getStringValue(provider.getProviderNo(), UserProperty.OFFICIAL_OLIS_IDTYPE), "ON", "HL70347",
							userPropertyDAO.getStringValue(provider.getProviderNo(),UserProperty.OFFICIAL_LAST_NAME),
							userPropertyDAO.getStringValue(provider.getProviderNo(),UserProperty.OFFICIAL_FIRST_NAME),
							userPropertyDAO.getStringValue(provider.getProviderNo(),UserProperty.OFFICIAL_SECOND_NAME));

					((Z01Query) query).setRequestingHic(zrp1);
				}
			} catch (Exception e) {
				MiscUtils.getLogger().error("Can't add requested requesting HIC data to OLIS query", e);
			}

			Map<String, String> map = new HashMap<>();
			String orderingPractitionerProviderNo = StringUtils.trimToEmpty(queryParameters.getOrderingPractitionerCpso());
			String copiedToPractitionerProviderNo = StringUtils.trimToEmpty(queryParameters.getCopiedToPractitionerCpso());
			String attendingPractitionerProviderNo = StringUtils.trimToEmpty(queryParameters.getAttendingPractitionerCpso());
			String admittingPractitionerProviderNo = StringUtils.trimToEmpty(queryParameters.getAdmittingPractitionerCpso());
			// Turns the retrieved practitioner numbers into an array list
			List<String> practitionerNumbers = new ArrayList(Arrays.asList(orderingPractitionerProviderNo, copiedToPractitionerProviderNo, attendingPractitionerProviderNo, admittingPractitionerProviderNo));
			// Removes all empty elements from the list
			practitionerNumbers.removeAll(Collections.singletonList(""));
			// Gets all providers for the list
			List<Provider> providers = new ArrayList<>();

			if (!practitionerNumbers.isEmpty()) {
				providers = providerDao.getOlisProvidersByPractitionerNo(practitionerNumbers);
			}

			Map<String, String> olisIdTypes = new HashMap<>();
			// Loops through each provider, getting their OLIS id type and adding it to the hashmap with the practitioner number as the key
			for (Provider provider : providers) {
				UserProperty property = userPropertyDAO.getProp(provider.getProviderNo(), UserProperty.OFFICIAL_OLIS_IDTYPE);
				if (property != null) {
					olisIdTypes.put(provider.getPractitionerNo(), StringUtils.trimToEmpty(property.getValue()));
				}
			}
			// OBR.16
			try {
				if (!orderingPractitionerProviderNo.isEmpty()) {
					OBR16 obr16 = new OBR16(orderingPractitionerProviderNo, olisIdTypes.getOrDefault(orderingPractitionerProviderNo, "MDL"), "ON", "HL70347");

					((Z01Query) query).setOrderingPractitioner(obr16);
				}
			} catch (Exception e) {
				MiscUtils.getLogger().error("Can't add requested ordering practitioner data to OLIS query", e);
			}


			try {
				if (!copiedToPractitionerProviderNo.isEmpty()) {
					OBR28 obr28 = new OBR28(copiedToPractitionerProviderNo, olisIdTypes.getOrDefault(copiedToPractitionerProviderNo, "MDL"), "ON", "HL70347");

					((Z01Query) query).setCopiedToPractitioner(obr28);
				}
			} catch (Exception e) {
				MiscUtils.getLogger().error("Can't add requested copied to practitioner data to OLIS query", e);
			}


			try {
				if (!attendingPractitionerProviderNo.isEmpty()) {
					PV17 pv17 = new PV17(attendingPractitionerProviderNo, olisIdTypes.getOrDefault(attendingPractitionerProviderNo, "MDL"), "ON", "HL70347");

					((Z01Query) query).setAttendingPractitioner(pv17);
				}
			} catch (Exception e) {
				MiscUtils.getLogger().error("Can't add requested attending practitioner data to OLIS query", e);
			}


			try {
				if (!admittingPractitionerProviderNo.isEmpty()) {
					PV117 pv117 = new PV117(admittingPractitionerProviderNo, olisIdTypes.getOrDefault(admittingPractitionerProviderNo, "MDL"), "ON", "HL70347");

					((Z01Query) query).setAdmittingPractitioner(pv117);
				}
			} catch (Exception e) {
				MiscUtils.getLogger().error("Can't add requested admitting practitioner data to OLIS query", e);
			}

			String[] testRequestStatusList = queryParameters.getTestRequestStatus();

			if (testRequestStatusList != null) {
				for (String testRequestStatus : testRequestStatusList) {
					((Z01Query) query).addToTestRequestStatusList(new OBR25(testRequestStatus));
				}
			}

			String testResultCodes = queryParameters.getResultCodes();
			if (StringUtils.isNotEmpty(testResultCodes)) {
				String[] testResultCodeList = testResultCodes.trim().split(System.lineSeparator());
				((Z01Query) query).addAllToTestResultCodeList(Arrays.asList(testResultCodeList));
			}


			String testRequestCodes = queryParameters.getRequestCodes();

			if (StringUtils.isNotEmpty(testRequestCodes)) {
				String[] testRequestCodeList = testRequestCodes.trim().split(System.lineSeparator());
				((Z01Query) query).addAllToTestRequestCodeList(Arrays.asList(testRequestCodeList));
			}

			String blockedInfoConsent = queryParameters.getBlockedInformationConsent();
			String blockedInfoIndividual = queryParameters.getBlockedInformationIndividual();

			if (blockedInfoConsent != null && blockedInfoConsent.equalsIgnoreCase("Z")) {
				// Log the consent override
				OscarLogDao logDao = (OscarLogDao) SpringUtils.getBean("oscarLogDao");
				OscarLog logItem = new OscarLog();
				logItem.setAction("OLIS search");
				logItem.setContent("consent override");
				logItem.setContentId("demographicNo=" + demographicNo + ",givenby=" + blockedInfoIndividual);
				if (loggedInInfo.getLoggedInProvider() != null)
					logItem.setProviderNo(loggedInInfo.getLoggedInProviderNo());
				else
					logItem.setProviderNo("-1");

				logItem.setIp(queryParameters.getRequestIp());

				logDao.persist(logItem);

			}

			String testRequestPlacer = queryParameters.getTestRequestPlacer();
			if (StringUtils.isNotEmpty(testRequestPlacer)) {
				((Z01Query) query).setTestResultPlacer(new ZBR2(testRequestPlacer, "ISO"));
			}

		} else if (queryType.equalsIgnoreCase("Z02")) {
			query = new Z02Query();

			String retrieveAllResults = queryParameters.getRetrieveAllResults();

			try {
				if (retrieveAllResults != null && retrieveAllResults.trim().length() > 0) {
					// Checked
					((Z02Query) query).setRetrieveAllTestResults(new ZBX1("*"));
				}
			} catch (Exception e) {
				MiscUtils.getLogger().error("Can't set retrieve all results option on OLIS query", e);
			}


			String blockedInformationConsent = queryParameters.getBlockedInformationConsent();

			if (blockedInformationConsent != null && blockedInformationConsent.trim().length() > 0) {
				((Z02Query) query).setConsentToViewBlockedInformation(new ZPD1(blockedInformationConsent));
			}


			String consentBlockAllIndicator = queryParameters.getConsentBlockAllIndicator();

			if (consentBlockAllIndicator != null && consentBlockAllIndicator.trim().length() > 0) {
				((Z02Query) query).setPatientConsentBlockAllIndicator(new ZPD3("Y"));
			}


			// Requesting HIC (ZRP.1 -- pull data from db and add to query)
			try {
				if (requestingHic != null && !requestingHic.trim().isEmpty()) {
					Provider provider = providerDao.getProvider(requestingHic);

					ZRP1 zrp1 = new ZRP1(provider.getPractitionerNo(), "MDL", "ON", "HL70347",
							userPropertyDAO.getStringValue(provider.getProviderNo(),UserProperty.OFFICIAL_LAST_NAME),
							userPropertyDAO.getStringValue(provider.getProviderNo(),UserProperty.OFFICIAL_FIRST_NAME),
							userPropertyDAO.getStringValue(provider.getProviderNo(),UserProperty.OFFICIAL_SECOND_NAME));

					((Z02Query) query).setRequestingHic(zrp1);
				}
			} catch (Exception e) {
				MiscUtils.getLogger().error("Can't add requested requesting HIC data to OLIS query", e);
			}


			// Patient Identifier (PID.3 -- pull data from db and add to query)
			String demographicNo = queryParameters.getDemographic();
			query.setDemographicNo(demographicNo);

			try {
				if (demographicNo != null && demographicNo.trim().length() > 0) {
					Demographic demo = demographicDao.getDemographic(demographicNo);

					PID3 pid3 = new PID3(demo.getHin(), null, null, "JHN", demo.getHcType(), "HL70347", demo.getSex(), null);
					pid3.setValue(7, DateUtils.parseDate(demo.getYearOfBirth() + "-" + demo.getMonthOfBirth() + "-" + demo.getDateOfBirth(), dateFormat));

					((Z02Query) query).setPatientIdentifier(pid3);
				}
			} catch (Exception e) {
				MiscUtils.getLogger().error("Can't add requested patient data to OLIS query", e);
			}

			String blockedInfoConsent = queryParameters.getBlockedInformationConsent();
			String blockedInfoIndividual = queryParameters.getBlockedInformationIndividual();

			if (blockedInfoConsent != null && blockedInfoConsent.equalsIgnoreCase("Z")) {
				// Log the consent override
				OscarLogDao logDao = (OscarLogDao) SpringUtils.getBean("oscarLogDao");
				OscarLog logItem = new OscarLog();
				logItem.setAction("OLIS search");
				logItem.setContent("consent override");
				logItem.setContentId("demographicNo=" + demographicNo + ",givenby=" + blockedInfoIndividual);
				if (loggedInInfo.getLoggedInProvider() != null)
					logItem.setProviderNo(loggedInInfo.getLoggedInProviderNo());
				else
					logItem.setProviderNo("-1");

				logItem.setIp(queryParameters.getRequestIp());

				logDao.persist(logItem);
			}


		} else if (queryType.equalsIgnoreCase("Z04")) {
			query = new Z04Query();

			String startTimePeriod = queryParameters.getStartTimePeriod();
			String endTimePeriod = queryParameters.getEndTimePeriod();

			try {
				if (startTimePeriod != null && startTimePeriod.trim().length() > 0) {
					Date startTime = DateUtils.parseDate(startTimePeriod, dateFormat);
					if (endTimePeriod != null && endTimePeriod.trim().length() > 0) {
						Date endTime = changeToEndOfDay(DateUtils.parseDate(endTimePeriod, dateFormat));

						List<Date> dateList = new LinkedList<Date>();
						dateList.add(startTime);
						dateList.add(endTime);

						OBR22 obr22 = new OBR22();
						obr22.setValue(dateList);

						((Z04Query) query).setStartEndTimestamp(obr22);
					} else {
						OBR22 obr22 = new OBR22();
						obr22.setValue(startTime);

						((Z04Query) query).setStartEndTimestamp(obr22);
					}
				}
			} catch (Exception e) {
				MiscUtils.getLogger().error("Can't parse date given for OLIS query", e);
			}


			String quantityLimitedQuery = queryParameters.getQuantityLimitedQuery();
			String quantityLimit = queryParameters.getQuantityLimit();

			try {
				if (quantityLimitedQuery != null && quantityLimitedQuery.trim().length() > 0) {
					// Checked
					((Z04Query) query).setQuantityLimitedRequest(new QRD7(Integer.parseInt(quantityLimit)));
				}
			} catch (Exception e) {
				MiscUtils.getLogger().error("Can't parse the number given for quantity limit in OLIS query", e);
			}


			// Requesting HIC (ZRP.1 -- pull data from db and add to query)
			try {
				if (requestingHic != null && !requestingHic.trim().isEmpty()) {
					Provider provider = providerDao.getProvider(requestingHic);
					ZRP1 zrp1 = new ZRP1(provider.getPractitionerNo(), "MDL", "ON", "HL70347",
							userPropertyDAO.getStringValue(provider.getProviderNo(),UserProperty.OFFICIAL_LAST_NAME),
							userPropertyDAO.getStringValue(provider.getProviderNo(),UserProperty.OFFICIAL_FIRST_NAME),
							userPropertyDAO.getStringValue(provider.getProviderNo(),UserProperty.OFFICIAL_SECOND_NAME));
					((Z04Query) query).setRequestingHic(zrp1);
				}
			} catch (Exception e) {
				MiscUtils.getLogger().error("Can't add requested requesting HIC data to OLIS query", e);
			}


			String testResultCodes = queryParameters.getResultCodes();
			if (StringUtils.isNotEmpty(testResultCodes)) {
				String[] testResultCodeList = testResultCodes.trim().split(System.lineSeparator());
				((Z04Query) query).addAllToTestResultCodeList(Arrays.asList(testResultCodeList));
			}


			String testRequestCodes = queryParameters.getRequestCodes();
			if (StringUtils.isNotEmpty(testRequestCodes)) {
				String[] testRequestCodeList = testRequestCodes.trim().split(System.lineSeparator());
				((Z04Query) query).addAllToTestRequestCodeList(Arrays.asList(testRequestCodeList));
			}


			String continuationPointer = queryParameters.getContinuationPointer();
			if (continuationPointer != null) {
				((Z04Query) query).setContinuationPointer(continuationPointer);
			}

		} else if (queryType.equalsIgnoreCase("Z05")) {
			query = new Z05Query();


			String startTimePeriod = queryParameters.getStartTimePeriod();
			String endTimePeriod = queryParameters.getEndTimePeriod();

			try {
				if (startTimePeriod != null && startTimePeriod.trim().length() > 0) {
					Date startTime = DateUtils.parseDate(startTimePeriod, dateFormat);
					if (endTimePeriod != null && endTimePeriod.trim().length() > 0) {
						Date endTime = changeToEndOfDay(DateUtils.parseDate(endTimePeriod, dateFormat));

						List<Date> dateList = new LinkedList<Date>();
						dateList.add(startTime);
						dateList.add(endTime);

						OBR22 obr22 = new OBR22();
						obr22.setValue(dateList);

						((Z05Query) query).setStartEndTimestamp(obr22);
					} else {
						OBR22 obr22 = new OBR22();
						obr22.setValue(startTime);

						((Z05Query) query).setStartEndTimestamp(obr22);
					}
				}
			} catch (Exception e) {
				MiscUtils.getLogger().error("Can't parse date given for OLIS query", e);
			}


			String quantityLimitedQuery = queryParameters.getQuantityLimitedQuery();
			String quantityLimit = queryParameters.getQuantityLimit();

			try {
				if (quantityLimitedQuery != null && quantityLimitedQuery.trim().length() > 0) {
					// Checked
					((Z05Query) query).setQuantityLimitedRequest(new QRD7(Integer.parseInt(quantityLimit)));
				}
			} catch (Exception e) {
				MiscUtils.getLogger().error("Can't parse the number given for quantity limit in OLIS query", e);
			}


			String destinationLaboratory = queryParameters.getDestinationLaboratory();

			if (destinationLaboratory != null && destinationLaboratory.trim().length() > 0) {
				((Z05Query) query).setDestinationLaboratory(new ZBR8(destinationLaboratory, "ISO"));
			}

		} else if (queryType.equalsIgnoreCase("Z06")) {
			query = new Z06Query();


			String startTimePeriod = queryParameters.getStartTimePeriod();
			String endTimePeriod = queryParameters.getEndTimePeriod();

			try {
				if (startTimePeriod != null && startTimePeriod.trim().length() > 0) {
					Date startTime = DateUtils.parseDate(startTimePeriod, dateFormat);
					if (endTimePeriod != null && endTimePeriod.trim().length() > 0) {
						Date endTime = changeToEndOfDay(DateUtils.parseDate(endTimePeriod, dateFormat));

						List<Date> dateList = new LinkedList<Date>();
						dateList.add(startTime);
						dateList.add(endTime);

						OBR22 obr22 = new OBR22();
						obr22.setValue(dateList);

						((Z06Query) query).setStartEndTimestamp(obr22);
					} else {
						OBR22 obr22 = new OBR22();
						obr22.setValue(startTime);

						((Z06Query) query).setStartEndTimestamp(obr22);
					}
				}
			} catch (Exception e) {
				MiscUtils.getLogger().error("Can't parse date given for OLIS query", e);
			}


			String quantityLimitedQuery = queryParameters.getQuantityLimitedQuery();
			String quantityLimit = queryParameters.getQuantityLimit();

			try {
				if (quantityLimitedQuery != null && quantityLimitedQuery.trim().length() > 0) {
					// Checked
					((Z06Query) query).setQuantityLimitedRequest(new QRD7(Integer.parseInt(quantityLimit)));
				}
			} catch (Exception e) {
				MiscUtils.getLogger().error("Can't parse the number given for quantity limit in OLIS query", e);
			}


			String orderingFacility = queryParameters.getOrderingFacility();

			if (orderingFacility != null && orderingFacility.trim().length() > 0) {
				((Z06Query) query).setOrderingFacilityId(new ORC21(orderingFacility, "^ISO"));
			}

		} else if (queryType.equalsIgnoreCase("Z07")) {
			query = new Z07Query();


			String startTimePeriod = queryParameters.getStartTimePeriod();
			String endTimePeriod = queryParameters.getEndTimePeriod();

			try {
				if (startTimePeriod != null && startTimePeriod.trim().length() > 0) {
					Date startTime = DateUtils.parseDate(startTimePeriod, dateFormat);
					if (endTimePeriod != null && endTimePeriod.trim().length() > 0) {
						Date endTime = changeToEndOfDay(DateUtils.parseDate(endTimePeriod, dateFormat));

						List<Date> dateList = new LinkedList<Date>();
						dateList.add(startTime);
						dateList.add(endTime);

						OBR22 obr22 = new OBR22();
						obr22.setValue(dateList);

						((Z07Query) query).setStartEndTimestamp(obr22);
					} else {
						OBR22 obr22 = new OBR22();
						obr22.setValue(startTime);

						((Z07Query) query).setStartEndTimestamp(obr22);
					}
				}
			} catch (Exception e) {
				MiscUtils.getLogger().error("Can't parse date given for OLIS query", e);
			}


			String quantityLimitedQuery = queryParameters.getQuantityLimitedQuery();
			String quantityLimit = queryParameters.getQuantityLimit();

			try {
				if (quantityLimitedQuery != null && quantityLimitedQuery.trim().length() > 0) {
					// Checked
					((Z07Query) query).setQuantityLimitedRequest(new QRD7(Integer.parseInt(quantityLimit)));
				}
			} catch (Exception e) {
				MiscUtils.getLogger().error("Can't parse the number given for quantity limit in OLIS query", e);
			}

		} else if (queryType.equalsIgnoreCase("Z08")) {
			query = new Z08Query();

			String startTimePeriod = queryParameters.getStartTimePeriod();
			String endTimePeriod = queryParameters.getEndTimePeriod();

			try {
				if (startTimePeriod != null && startTimePeriod.trim().length() > 0) {
					Date startTime = DateUtils.parseDate(startTimePeriod, dateFormat);
					if (endTimePeriod != null && endTimePeriod.trim().length() > 0) {
						Date endTime = changeToEndOfDay(DateUtils.parseDate(endTimePeriod, dateFormat));

						List<Date> dateList = new LinkedList<Date>();
						dateList.add(startTime);
						dateList.add(endTime);

						OBR22 obr22 = new OBR22();
						obr22.setValue(dateList);

						((Z08Query) query).setStartEndTimestamp(obr22);
					} else {
						OBR22 obr22 = new OBR22();
						obr22.setValue(startTime);

						((Z08Query) query).setStartEndTimestamp(obr22);
					}
				}
			} catch (Exception e) {
				MiscUtils.getLogger().error("Can't parse date given for OLIS query", e);
			}


			String quantityLimitedQuery = queryParameters.getQuantityLimitedQuery();
			String quantityLimit = queryParameters.getQuantityLimit();

			try {
				if (quantityLimitedQuery != null && quantityLimitedQuery.trim().length() > 0) {
					// Checked
					((Z08Query) query).setQuantityLimitedRequest(new QRD7(Integer.parseInt(quantityLimit)));
				}
			} catch (Exception e) {
				MiscUtils.getLogger().error("Can't parse the number given for quantity limit in OLIS query", e);
			}


		} else if (queryType.equalsIgnoreCase("Z50")) {
			query = new Z50Query();


			String firstName = queryParameters.getZ50firstName();

			if (firstName != null && firstName.trim().length() > 0) {
				((Z50Query) query).setFirstName(new PID52(firstName));
			}


			String lastName = queryParameters.getZ50lastName();

			if (lastName != null && lastName.trim().length() > 0) {
				((Z50Query) query).setLastName(new PID51(lastName));
			}


			String sex = queryParameters.getZ50sex();

			if (sex != null && sex.trim().length() > 0) {
				((Z50Query) query).setSex(new PID8(sex));
			}


			String dateOfBirth = queryParameters.getZ50dateOfBirth();
			try {
				if (dateOfBirth != null && dateOfBirth.trim().length() > 0) {
					PID7 pid7 = new PID7();
					pid7.setValue(DateUtils.parseDate(dateOfBirth,dateFormat));
					((Z50Query) query).setDateOfBirth(pid7);
				}
			} catch (Exception e) {
				MiscUtils.getLogger().error("Couldn't parse date given for OLIS query", e);
			}
		}
		return query;
	}

	private static Date changeToEndOfDay(Date d) {
		Calendar c = Calendar.getInstance();
		c.setTime(d);
		c.set(Calendar.HOUR_OF_DAY, 23);
		c.set(Calendar.MINUTE, 59);
		c.set(Calendar.SECOND,59);
		return c.getTime();
	}
}
