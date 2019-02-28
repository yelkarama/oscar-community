/**
 * Copyright (c) 2008-2012 Indivica Inc.
 *
 * This software is made available under the terms of the
 * GNU General Public License, Version 2, 1991 (GPLv2).
 * License details are available via "indivica.ca/gplv2"
 * and "gnu.org/licenses/gpl-2.0.html".
 */

/*
 * OLISHL7Handler.java
 */

package oscar.oscarLab.ca.all.parsers;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;
import org.bouncycastle.util.encoders.Base64;
import org.json.JSONObject;
import org.oscarehr.olis.OLISUtils;
import org.oscarehr.olis.dao.OLISFacilitiesDao;
import org.oscarehr.olis.dao.OLISRequestNomenclatureDao;
import org.oscarehr.olis.dao.OLISResultNomenclatureDao;
import org.oscarehr.olis.dao.OlisMicroorganismNomenclatureDao;
import org.oscarehr.olis.model.OLISFacilities;
import org.oscarehr.olis.model.OLISRequestNomenclature;
import org.oscarehr.olis.model.OLISResultNomenclature;
import org.oscarehr.olis.model.OlisLabResultSortable;
import org.oscarehr.olis.model.OlisMicroorganismNomenclature;
import org.oscarehr.util.MiscUtils;
import org.oscarehr.util.SpringUtils;

import oscar.util.UtilDateUtilities;
import ca.uhn.hl7v2.HL7Exception;
import ca.uhn.hl7v2.model.GenericComposite;
import ca.uhn.hl7v2.model.Message;
import ca.uhn.hl7v2.model.Segment;
import ca.uhn.hl7v2.model.Structure;
import ca.uhn.hl7v2.model.Type;
import ca.uhn.hl7v2.model.Varies;
import ca.uhn.hl7v2.parser.Parser;
import ca.uhn.hl7v2.parser.PipeParser;
import ca.uhn.hl7v2.util.Terser;
import ca.uhn.hl7v2.validation.impl.NoValidation;

/**
 * @author Adam Balanga
 */
public class OLISHL7Handler implements MessageHandler {

	Logger logger = Logger.getLogger(DefaultGenericHandler.class);
	protected boolean isFinal = true;
	protected boolean isCorrected = false;
	protected Message msg = null;
	protected Terser terser;
	protected ArrayList<ArrayList<Segment>> obrGroups = null;
	private ArrayList<String> obrSpecimenSource;
	private ArrayList<JSONObject> obrHeaders;
	private ArrayList<String> obrStatus;
	private HashMap<String, String> sourceOrganizations;
	private List<String> microorganismCodes = new ArrayList<>();
	private int obrCount = 0;
	private HashMap<String, String> defaultSourceOrganizations;
	
	private String reportStatus = "";
	private String reportStatusDescription = "Final";

    private Map<String, OLISRequestNomenclature> olisRequestNomenclatureMap = null;
    private Map<String, OLISResultNomenclature> olisResultNomenclatureMap = null;
    private Map<String, OlisMicroorganismNomenclature> olisMicroorganismNomenclatureMap = new HashMap<>();

	private HashMap<Integer, List<OlisLabResultSortable>> obxSortMap;
    
	public static final String OBR_SPECIMEN_TYPE = "specimenType";
	public static final String OBR_SPECIMEN_RECEIVED_DATETIME = "specimenReceived";
	public static final String OBR_SITE_MODIFIER = "siteModifier";

	private void initDefaultSourceOrganizations() {
		defaultSourceOrganizations = new HashMap<String, String>();
		defaultSourceOrganizations.put("4001", "BSD Lab1");
		defaultSourceOrganizations.put("4002", "BSD Lab2");
		defaultSourceOrganizations.put("4003", "BSD Lab3");
		defaultSourceOrganizations.put("4004", "BSD Lab4");
		defaultSourceOrganizations.put("4005", "BSD Lab5");
		defaultSourceOrganizations.put("4006", "BSD Lab6");
		defaultSourceOrganizations.put("4007", "BSD Lab7");
		defaultSourceOrganizations.put("4008", "BSD Lab8");
		defaultSourceOrganizations.put("4009", "BSD Lab9");
		defaultSourceOrganizations.put("4010", "BSD Lab10");
	}

	public String getSourceOrganization(String org) {
		return sourceOrganizations.containsKey(org) ? sourceOrganizations.get(org) : defaultSourceOrganizations.get(org);
	}

	public String getObrStatus(int index) {
		return obrStatus.get(index);
	}

	public String getObrSpecimenSource(int index) {
		return obrSpecimenSource.get(index);
	}

	public JSONObject getObrHeader(int index) {
		return obrHeaders.get(index);
	}

	private ArrayList<String> headers = null;

	/** Creates a new instance of OLISHL7Handler */
	public OLISHL7Handler() {
		super();
	}

	String[] getDentistLicenceNumber() {
		return patientIdentifiers.get("DDSL");
	}

	String[] getDriversLicenceNumber() {
		return patientIdentifiers.get("DL");
	}

	String[] getJurisdictionalHealthNumber() {
		return patientIdentifiers.get("JHN");
	}

	String[] getPhysicianLicenceNumber() {
		return patientIdentifiers.get("MDL");
	}

	String[] getMidwifeLicenceNumber() {
		return patientIdentifiers.get("ML");
	}

	String[] getMedicalRecordNumber() {
		return patientIdentifiers.get("MR");
	}

	String[] getNursePractitionerLicenceNumber() {
		return patientIdentifiers.get("NPL");
	}

	String[] getPassportNumber() {
		return patientIdentifiers.get("PPN");
	}

	String[] getUSASocialSecurityNumber() {
		return patientIdentifiers.get("SS");
	}

	public String[] getPatientIdentifier(String ident) {
		return patientIdentifiers.get(ident);
	}

	public Set<String> getPatientIdentifiers() {
		return patientIdentifiers.keySet();
	}

	public String getNameOfIdentifier(String ident) {
		return patientIdentifierNames.get(ident);
	}

	public String getReportStatusDescription() {
		return this.reportStatusDescription;
	}
	
	public boolean isReportNormal() {
		return reportStatus.isEmpty();
	}
	
	HashMap<String, String[]> patientIdentifiers = new HashMap<>();
	HashMap<String, String> patientIdentifierNames = new HashMap<>();

	private void initPatientIdentifierNames() {
		patientIdentifierNames.put("ANON", "Non Nominal Identifier");
		patientIdentifierNames.put("DDSL", "Dentist Licence Number");
		patientIdentifierNames.put("DL", "Driver's Licence Number");
		patientIdentifierNames.put("JHN", "Jurisdictional Health Number");
		patientIdentifierNames.put("MDL", "Physician Licence Number");
		patientIdentifierNames.put("ML", "Midwife Licence Number");
		patientIdentifierNames.put("MR", "Medical Record Number");
		patientIdentifierNames.put("NPL", "Nurse Practitioner Licence Number");
		patientIdentifierNames.put("PPN", "Passport Number");
		patientIdentifierNames.put("SS", "USA Social Security number");

	}

	private HashMap<String, String> addressTypeNames;
	private HashMap<String, String> telecomUseCode;
	private HashMap<String, String> telecomEquipType;

	public String getAddressTypeName(String ident) {
		return addressTypeNames.get(ident);
	}

	private void initAddressTypeNames() {
		addressTypeNames.put("M", "Mailing Address");
		addressTypeNames.put("B", "Business");
		addressTypeNames.put("O", "Office");
		addressTypeNames.put("H", "Home Address");
		addressTypeNames.put("E", "Emergency Contact");
	}

	private void initTelecomUseCodes() {
		telecomUseCode.put("PRN", "Primary Residence Number");
		telecomUseCode.put("ORN", "Other Residence Number");
		telecomUseCode.put("WPN", "Work Number");
		telecomUseCode.put("VHN", "Vacation Home Number");
		telecomUseCode.put("ASN", "Answering Service Number");
		telecomUseCode.put("EMR", "Emergency Number");
		telecomUseCode.put("NET", "Email");
	}

	private void initTelecomEquipTypes() {
		telecomEquipType.put("PH", "Telephone");
		telecomEquipType.put("FX", "Fax");
		telecomEquipType.put("CP", "Cellular Phone");
		telecomEquipType.put("BP", "Beeper");
		telecomEquipType.put("Internet", "Internet Address");
	}

	private ArrayList<HashMap<String, String>> patientAddresses;

	public ArrayList<HashMap<String, String>> getPatientAddresses() {
		return patientAddresses;
	}

	private ArrayList<HashMap<String, String>> patientHomeTelecom;

	public ArrayList<HashMap<String, String>> getPatientHomeTelecom() {
		return patientHomeTelecom;
	}

	public ArrayList<HashMap<String, String>> getPatientWorkTelecom() {
		return patientWorkTelecom;
	}

	private ArrayList<HashMap<String, String>> patientWorkTelecom;

	public String getAdmittingProviderName() {
		try {
			return getFullDocName("/.PV1-17-");
		} catch (HL7Exception e) {
			MiscUtils.getLogger().error("OLIS HL7 Error", e);
			return "";
		}
	}

	public String getAdmittingProviderNameShort() {
		try {
			return getShortName("/.PV1-17-");
		} catch (HL7Exception e) {
			MiscUtils.getLogger().error("OLIS HL7 Error", e);
			return "";
		}
	}

	public String getAttendingProviderName() {
		try {
			return getFullDocName("/.PV1-7-");
		} catch (HL7Exception e) {
			MiscUtils.getLogger().error("OLIS HL7 Error", e);
			return "";
		}
	}

	public boolean reportBlocked = false;

	public Boolean isReportBlocked() {
		return reportBlocked;
	}

	public boolean isOBRBlocked(int obr) {
		obr++;
		try {
			String indicator;
			Segment zbr = null;
			if (obr == 1) {
				zbr = terser.getSegment("/.ZBR");
			} else {
				zbr = (Segment) terser.getFinder().getRoot().get("ZBR" + obr);
			}
			indicator = Terser.get(zbr, 1, 0, 1, 1);
			return "Y".equals(indicator);

		} catch (Exception e) {
			MiscUtils.getLogger().error("OLIS HL7 Error", e);
		}
		return false;
	}

	public String getOBRPerformingFacilityName(int obr) {
		obr++;
		try {
			String key = "", value = "", ident = "";
			Segment zbr = null;
			if (obr == 1) {
				zbr = terser.getSegment("/.ZBR");
			} else {
				zbr = (Segment) terser.getFinder().getRoot().get("ZBR" + obr);
			}
			key = getString(Terser.get(zbr, 6, 0, 6, 2));
			if (key != null && key.indexOf(":") > 0) {
				ident = key.substring(0, key.indexOf(":"));
				ident = getOrganizationType(ident);
				key = key.substring(key.indexOf(":") + 1);
			}
			if (key == null || "".equals(key.trim())) {
				return "";
			}
			value = getString(Terser.get(zbr, 6, 0, 1, 1));
			return String.format("%s (%s %s)", value, ident, key);

		} catch (Exception e) {
			MiscUtils.getLogger().error("OLIS HL7 Error", e);
		}
		return "";
	}

	public HashMap<String, String> getPerformingFacilityAddress(int obr) {
		obr++;
		try {
			String value = "";
			Segment zbr = null;
			if (obr == 1) {
				zbr = terser.getSegment("/.ZBR");
			} else {
				zbr = (Segment) terser.getFinder().getRoot().get("ZBR" + obr);
			}
			HashMap<String, String> address;

			String identifier = getString(Terser.get(zbr, 7, 0, 7, 1));
			if ("".equals(identifier)) {
				return null;
			}
			address = new HashMap<String, String>();
			value = getString(Terser.get(zbr, 7, 0, 1, 1));
			if (stringIsNotNullOrEmpty(value)) {
				address.put("Street Address", value);
			}
			value = getString(Terser.get(zbr, 7, 0, 2, 1));
			if (stringIsNotNullOrEmpty(value)) {
				address.put("Other Designation", value);
			}
			value = getString(Terser.get(zbr, 7, 0, 3, 1));
			if (stringIsNotNullOrEmpty(value)) {
				address.put("City", value);
			}
			value = getString(Terser.get(zbr, 7, 0, 4, 1));
			if (stringIsNotNullOrEmpty(value)) {
				address.put("Province", value);
			}
			value = getString(Terser.get(zbr, 7, 0, 5, 1));
			if (stringIsNotNullOrEmpty(value)) {
				address.put("Postal Code", value);
			}
			value = getString(Terser.get(zbr, 7, 0, 6, 1));
			if (stringIsNotNullOrEmpty(value)) {
				address.put("Country", value);
			}
			address.put("Address Type", addressTypeNames.get(identifier));
			return address;

		} catch (Exception e) {
			MiscUtils.getLogger().error("OLIS HL7 Error", e);
		}
		return null;
	}

	public String getCategoryList() {
		String result = "";
		ArrayList<String> categories = new ArrayList<String>();
		for (int i = 0; i < getOBRCount(); i++) {
			categories.add(getOBRCategory(i));
		}
		String[] uniqueCategories = new HashSet<String>(categories).toArray(new String[0]);
		Arrays.sort(uniqueCategories);
		int count = 0;
		for (String category : uniqueCategories) {
			result += (count++ > 0 ? " / " : "") + category;
		}
		return result;
	}

	public String getTestList() {
		String result = "";
		String[] uniqueTests = new HashSet<String>(headers).toArray(new String[0]);
		Arrays.sort(uniqueTests);
		int count = 0;
		for (String test : uniqueTests) {
			result += (count++ > 0 ? " / " : "") + test;
		}
		return result;
	}
	
	
	/*
	Return the sending lab in the format of 2.16.840.1.113883.3.59.1:9999 where 9999 is the lab identifier
	
	 5047 Canadian Medical Laboratories
	 5552 Gamma Dynacare
	 5687 LifeLabs
	 5254 Alpha Laboratories
	 */
	public String getPlacerGroupNumber(){
		try {
			String value = getString(terser.get("/.ORC-4-3"));
			return value;
		} catch (Exception e) {
			MiscUtils.getLogger().error("OLIS HL7 Error", e);
		}
		return null;
	}

    public String getZBR11(int obrIndex) {
        Segment zbr = null;
        try {
            if ((obrIndex + 1) == 1) {
                zbr = terser.getSegment("/.ZBR");
            } else {
                zbr = (Segment) terser.getFinder().getRoot().get("ZBR" + (obrIndex + 1));
            }
            return getString(Terser.get(zbr, 11, 0, 1, 1));
        } catch (HL7Exception e) {
            if (zbr == null) {
                MiscUtils.getLogger().error("OLIS HL7 Error", e);
            } else {
                MiscUtils.getLogger().error("OLIS HL7 Error in segment" + zbr.getName(), e);
            }
        }
        return null;
    }

	public String getPerformingFacilityNameOnly() {
		try {
			String value = getString(terser.get("/.ZBR-6-1"));
			return value;
		} catch (Exception e) {
			MiscUtils.getLogger().error("OLIS HL7 Error", e);
		}
		return "";
	}
	
	public String getPerformingFacilityName() {
		try {
			String key = "", value = "", ident = "";
			key = getString(terser.get("/.ZBR-6-6-2"));
			if (key != null && key.indexOf(":") > 0) {
				ident = key.substring(0, key.indexOf(":"));
				ident = getOrganizationType(ident);
				key = key.substring(key.indexOf(":") + 1);
			} else {
				key = "";
			}
			if (key == null || key.trim().equals("")) {
				return "";
			}
			value = getString(terser.get("/.ZBR-6-1"));

			return String.format("%s (%s %s)", value, ident, key);
		} catch (Exception e) {
			MiscUtils.getLogger().error("OLIS HL7 Error", e);
		}
		return "";
	}

	public HashMap<String, String> getPerformingFacilityAddress() {
		try {
			String value;
			HashMap<String, String> address;
			String identifier = getString(terser.get("/.ZBR-7-7"));
			if ("".equals(identifier)) {
				return null;
			}
			address = new HashMap<String, String>();
			value = getString(terser.get("/.ZBR-7-1"));
			if (stringIsNotNullOrEmpty(value)) {
				address.put("Street Address", value);
			}
			value = getString(terser.get("/.ZBR-7-2"));
			if (stringIsNotNullOrEmpty(value)) {
				address.put("Other Designation", value);
			}
			value = getString(terser.get("/.ZBR-7-3"));
			if (stringIsNotNullOrEmpty(value)) {
				address.put("City", value);
			}
			value = getString(terser.get("/.ZBR-7-4"));
			if (stringIsNotNullOrEmpty(value)) {
				address.put("Province", value);
			}
			value = getString(terser.get("/.ZBR-7-5"));
			if (stringIsNotNullOrEmpty(value)) {
				address.put("Postal Code", value);
			}
			value = getString(terser.get("/.ZBR-7-6"));
			if (stringIsNotNullOrEmpty(value)) {
				address.put("Country", value);
			}
			address.put("Address Type", addressTypeNames.get(identifier));
			return address;
		} catch (HL7Exception e) {
			MiscUtils.getLogger().error("OLIS HL7 Error", e);
			return null;
		}
	}

	public String getReportingFacilityName() {
		try {
			String key = "", value = "", ident = "";
			key = getString(terser.get("/.ZBR-4-6-2"));
			if (key != null && key.indexOf(":") > 0) {
				ident = key.substring(0, key.indexOf(":"));
				ident = getOrganizationType(ident);
				key = key.substring(key.indexOf(":") + 1);
			} else {
				key = "";
			}
			if (key == null || key.trim().equals("")) {
				return "";
			}
			value = getString(terser.get("/.ZBR-4-1"));
			return String.format("%s (%s %s)", value, ident, key);
		} catch (Exception e) {
			MiscUtils.getLogger().error("OLIS HL7 Error", e);
		}
		return "";
	}

	public HashMap<String, String> getReportingFacilityAddress() {
		try {
			String value;
			HashMap<String, String> address;
			String identifier = getString(terser.get("/.ZBR-5-7"));
			if ("".equals(identifier)) {
				return null;
			}
			address = new HashMap<String, String>();
			value = getString(terser.get("/.ZBR-5-1"));
			if (stringIsNotNullOrEmpty(value)) {
				address.put("Street Address", value);
			}
			value = getString(terser.get("/.ZBR-5-2"));
			if (stringIsNotNullOrEmpty(value)) {
				address.put("Other Designation", value);
			}
			value = getString(terser.get("/.ZBR-5-3"));
			if (stringIsNotNullOrEmpty(value)) {
				address.put("City", value);
			}
			value = getString(terser.get("/.ZBR-5-4"));
			if (stringIsNotNullOrEmpty(value)) {
				address.put("Province", value);
			}
			value = getString(terser.get("/.ZBR-5-5"));
			if (stringIsNotNullOrEmpty(value)) {
				address.put("Postal Code", value);
			}
			value = getString(terser.get("/.ZBR-5-6"));
			if (stringIsNotNullOrEmpty(value)) {
				address.put("Country", value);
			}
			address.put("Address Type", addressTypeNames.get(identifier));
			return address;
		} catch (HL7Exception e) {
			MiscUtils.getLogger().error("OLIS HL7 Error", e);
			return null;
		}
	}

	public String getOrderingFacilityName() {
		try {
			return (getString(terser.get("/.ORC-21-1")));
		} catch (HL7Exception e) {
			MiscUtils.getLogger().error("OLIS HL7 Error", e);
			return "";
		}
	}

	public HashMap<String, String> getOrderingFacilityAddress() {
		try {
			String value;
			HashMap<String, String> address;
			String identifier = getString(terser.get("/.ORC-22-7"));
			if ("".equals(identifier)) {
				return null;
			}
			address = new HashMap<String, String>();
			value = getString(terser.get("/.ORC-22-1"));
			if (stringIsNotNullOrEmpty(value)) {
				address.put("Street Address", value);
			}
			value = getString(terser.get("/.ORC-22-2"));
			if (stringIsNotNullOrEmpty(value)) {
				address.put("Other Designation", value);
			}
			value = getString(terser.get("/.ORC-22-3"));
			if (stringIsNotNullOrEmpty(value)) {
				address.put("City", value);
			}
			value = getString(terser.get("/.ORC-22-4"));
			if (stringIsNotNullOrEmpty(value)) {
				address.put("Province", value);
			}
			value = getString(terser.get("/.ORC-22-5"));
			if (stringIsNotNullOrEmpty(value)) {
				address.put("Postal Code", value);
			}
			value = getString(terser.get("/.ORC-22-6"));
			if (stringIsNotNullOrEmpty(value)) {
				address.put("Country", value);
			}
			address.put("Address Type", addressTypeNames.get(identifier));
			return address;
		} catch (HL7Exception e) {
			MiscUtils.getLogger().error("OLIS HL7 Error", e);
			return null;
		}
	}

	public String getOrderingFacilityOrganization() {
		try {
			String key = getString(terser.get("/.ORC-21-6-2"));
			String ident = "";
			if (key != null && key.indexOf(":") > 0) {
				ident = key.substring(0, key.indexOf(":"));
				ident = getOrganizationType(ident);
				key = key.substring(key.indexOf(":") + 1);
			} else {
				key = "";
			}
			if (key == null || "".equals(key.trim())) {
				return "";
			}
			return String.format("(%s %s)", ident, key);
		} catch (Exception e) {
			MiscUtils.getLogger().error("OLIS HL7 Error", e);
		}
		return "";
	}

	public String getOrderingProviderName() {
		try {
			return (getString(terser.get("/.ORC-21-1")));
		} catch (HL7Exception e) {
			MiscUtils.getLogger().error("OLIS HL7 Error", e);
			return "";
		}
	}

	public HashMap<String, String> getOrderingProviderAddress() {
		try {
			String value;
			HashMap<String, String> address;
			String identifier = getString(terser.get("/.ORC-24-7"));
			if ("".equals(identifier)) {
				return null;
			}
			address = new HashMap<String, String>();
			value = getString(terser.get("/.ORC-24-1"));
			if (stringIsNotNullOrEmpty(value)) {
				address.put("Street Address", value);
			}
			value = getString(terser.get("/.ORC-24-2"));
			if (stringIsNotNullOrEmpty(value)) {
				address.put("Other Designation", value);
			}
			value = getString(terser.get("/.ORC-24-3"));
			if (stringIsNotNullOrEmpty(value)) {
				address.put("City", value);
			}
			value = getString(terser.get("/.ORC-24-4"));
			if (stringIsNotNullOrEmpty(value)) {
				address.put("Province", value);
			}
			value = getString(terser.get("/.ORC-24-5"));
			if (stringIsNotNullOrEmpty(value)) {
				address.put("Postal Code", value);
			}
			value = getString(terser.get("/.ORC-24-6"));
			if (stringIsNotNullOrEmpty(value)) {
				address.put("Country", value);
			}
			address.put("Address Type", addressTypeNames.get(identifier));
			return address;
		} catch (HL7Exception e) {
			MiscUtils.getLogger().error("OLIS HL7 Error", e);
			return null;
		}
	}

	private boolean stringIsNotNullOrEmpty(String value) {
		return value != null && value.trim().length() > 0;
	}

	public ArrayList<HashMap<String, String>> getOrderingProviderPhones() {
		ArrayList<HashMap<String, String>> results = new ArrayList<HashMap<String, String>>();
		try {
			int rep = -1;
			
			HashMap<String, String> telecomMap;
			String identifier;
			while (!"".equals((identifier = getString(terser.get("/.OBR-17(" + (++rep) + ")-2"))))) {
				telecomMap = new HashMap<>();
				StringBuilder telecom = new StringBuilder();
				// If the telecommunication type is Email
				if (identifier.equals("NET")) {
					String email = getString(terser.get("/.OBR-17(" + (rep) + ")-4"));
					if (stringIsNotNullOrEmpty(email)) {
						telecom.append(email);
					}
				} else {
					String phoneNumber = getString(terser.get("/.OBR-17(" + (rep) + ")-1"));
					String countryCode = getString(terser.get("/.OBR-17(" + (rep) + ")-5"));
					String areaCode = getString(terser.get("/.OBR-17(" + (rep) + ")-6"));
					String localNumber = getString(terser.get("/.OBR-17(" + (rep) + ")-7"));
					String extension = getString(terser.get("/.OBR-17(" + (rep) + ")-8"));
					
					// Appends the country code if it exists
					if (stringIsNotNullOrEmpty(countryCode)) {
						telecom.append(countryCode);
					}
					// Appends the area code if it exists
					if (stringIsNotNullOrEmpty(areaCode)) {
						telecom.append(" (").append(areaCode).append(")");
					}
					// Appends the phone number, if it exists, with a dash after the first 3 numbers
					if (stringIsNotNullOrEmpty(localNumber)) {
						telecom.append(" ").append(localNumber.substring(0, 3)).append("-").append(localNumber.substring((3)));
					}
					// Appends the phone extension if it exists
					if (stringIsNotNullOrEmpty(extension)) {
						telecom.append(" x").append(extension);
					}
				}
				
				telecomMap.put("telecom", telecom.toString());
				
				String equipmentType = getString(terser.get("/.OBR-17(" + (rep) + ")-3"));
				if (stringIsNotNullOrEmpty(equipmentType)) {
					equipmentType = telecomEquipType.get(equipmentType);
					if (stringIsNotNullOrEmpty(equipmentType)) {
						telecomMap.put("equipType", equipmentType);
					}
				}
				
				telecomMap.put("useCode", telecomUseCode.get(identifier));
				results.add(telecomMap);
			}

			return results;
		} catch (HL7Exception e) {
			MiscUtils.getLogger().error("OLIS HL7 Error", e);
			return null;
		}
	}

	public String getSpecimenReceivedDateTime() {
		try {
			String date = getString(terser.get("/.OBR-14-1"));
			if (date.length() > 13) {
				return formatDateTime(date);
			}
		} catch (HL7Exception e) {
			MiscUtils.getLogger().error("OLIS HL7 Error", e);
		}
		return "";
	}

	public String getOrderDate() {
		try {
			return (formatDate(getString(terser.get("/.OBR-27-4")).substring(0, 8)));
		} catch (HL7Exception e) {
			MiscUtils.getLogger().error("OLIS HL7 Error", e);
			return "";
		}
	}

	
	public String getLastUpdateInOLISUnformated() {
		try {
			 String date = null;
			 
			 int obrNum = getOBRCount();
			 Segment obr = null;
			 if (obrNum == 1) {
				obr = terser.getSegment("/.OBR");
			 } else {
				obr = (Segment) terser.getFinder().getRoot().get("OBR" + obrNum);
			 }
			 
			 date = Terser.get(obr, 22, 0,1,1);
			 
			return date;
		} catch (HL7Exception e) {
			MiscUtils.getLogger().error("OLIS HL7 Error", e);
			return "";
		}
	}
	
	public String getLastUpdateInOLIS() {
			String date = getLastUpdateInOLISUnformated();
			if (date.length() > 0) return formatDateTime(date);
			return "";
	}

	public String getOBXCEParentId(int obr, int obx) {
		return getOBXField(obr, obx, 4, 0, 1);
	}

	HashMap<String, String> obrParentMap;

	public int getChildOBR(String parentId) {
		try {
			return Integer.valueOf(obrParentMap.get(parentId));
		} catch (Exception e) {
			return -1;
		}
	}

	public boolean isChildOBR(int obr) {
		return obrParentMap.containsValue(String.valueOf(obr));
	}

	public String getDiagnosis(int obr) {
		try {
			return obrDiagnosis.containsKey(obr) ? getString(Terser.get(obrDiagnosis.get(obr), 3, 0, 2, 1)) : "";
		} catch (HL7Exception e) {
			MiscUtils.getLogger().error("OLIS HL7 Error", e);
		}
		return "";
	}

	public int getMappedOBR(int obr) {
		try {
			String[] keys = obrSortMap.keySet().toArray(new String[0]);
			Arrays.sort(keys);
			if (obr > keys.length - 1) {
				return obr;
			}
			return obrSortMap.get(keys[obr]);
		} catch (Exception e) {
			MiscUtils.getLogger().error("OLIS HL7 Error", e);
		}
		return obr;
	}

	public int getMappedOBX(int obr, int obx) {
		try {
		    // Gets the list of sorted results for the given obr
			List<OlisLabResultSortable> obxResults = obxSortMap.get(obr);
			// Returns the matching set id minus 1 so it matches the indexing used to get the result details
			return obxResults.get(obx).getSetId() - 1;
		} catch (Exception e) {
			MiscUtils.getLogger().error("OLIS HL7 Error", e);
		}
		return obr;
	}

	HashMap<Integer, Segment> obrDiagnosis;

	private ArrayList<String> disciplines;

	public ArrayList<String> getDisciplines() {
		return disciplines;
	}

	List<OLISError> errors;

	public List<OLISError> getReportErrors() {
		List<OLISError> result = new ArrayList<OLISError>();
		if (errors == null) {
			return result;
		}
		for (OLISError error : errors) {
			if (error.segment == null || error.segment.equals("") || error.segment.equals("ERR") || error.segment.equals("SPR")) {
				result.add(error);
			}
		}
		return result;
	}

	@Override
	public void init(String hl7Body) throws HL7Exception {
		initDefaultSourceOrganizations();

		obrDiagnosis = new HashMap<Integer, Segment>();

		obrParentMap = new HashMap<String, String>();

		patientIdentifierNames = new HashMap<String, String>();
		initPatientIdentifierNames();

		addressTypeNames = new HashMap<String, String>();
		initAddressTypeNames();

		telecomUseCode = new HashMap<String, String>();
		initTelecomUseCodes();

		telecomEquipType = new HashMap<String, String>();
		initTelecomEquipTypes();

		sourceOrganizations = new HashMap<String, String>();
		obrSpecimenSource = new ArrayList<String>();
		obrHeaders = new ArrayList<>();
		obrStatus = new ArrayList<String>();
		Parser p = new PipeParser();

		p.setValidationContext(new NoValidation());
		
		msg = p.parse(hl7Body.replaceAll("\n", "\r\n"));
		headers = new ArrayList<String>();
		terser = new Terser(msg);
		int zbrNum = 1;
		this.obrCount = getOBRCount();
		int obrNum = 1;
		boolean obrFlag;
		String segmentName;
		String[] segments = terser.getFinder().getRoot().getNames();
		obrGroups = new ArrayList<ArrayList<Segment>>();
		int k = 0;

		// We only need to parse a few segments if there are no OBRs.
		if (this.obrCount == 0) {
			for (; k < segments.length; k++) {
				segmentName = segments[k].substring(0, 3);
				if (segmentName.equals("ZPD")) {
					parseZPDSegment();
				}
				if (segmentName.equals("ERR")) {
					parseERRSegment();
				}
			}
			return;
		}
		for (int i = 0; i < this.obrCount; i++) {
			ArrayList<Segment> obxSegs = new ArrayList<Segment>();

			headers.add(getOBRName(i));
			obrNum = i + 1;
			obrFlag = false;
			for (; k < segments.length; k++) {
				try {
					segmentName = segments[k].substring(0, 3);
					if (segmentName.equals("ZPD")) {
						parseZPDSegment();
					}
					if (segmentName.equals("ERR")) {
						parseERRSegment();
					}
					if (segmentName.equals("PID")) {
						parsePIDSegment();
					} else if (segmentName.equals("ZBR")) {
						parseZBRSegment(zbrNum++);
					} else if (obrFlag && segmentName.equals("OBX")) {
						Structure[] segs = terser.getFinder().getRoot().getAll(segments[k]);
						for (int l = 0; l < segs.length; l++) {
							Segment obxSeg = (Segment) segs[l];
							parseObxStatus(obxSeg);
							obxSegs.add(obxSeg);
							
							// Gets the microorganism code and if one exists, adds it to the list
							String microorganismCode = getMicroorganismCode(obxSeg);
							if (!microorganismCode.isEmpty()) {
								this.microorganismCodes.add(microorganismCode);
							}
						}

					} else if (obrFlag && segmentName.equals("OBR")) {
						break;
					} else if (segments[k].equals("OBR" + obrNum) || (obrNum == 1 && segments[k].equals("OBR"))) {
						obrFlag = true;
						Segment obr = null;
						if (obrNum == 1) {
							obr = terser.getSegment("/.OBR");
						} else {
							obr = (Segment) terser.getFinder().getRoot().get("OBR" + obrNum);
						}

						String weirdFixToGetObr1512 = null;
						Type obr15Types[] = obr.getField(15);
						if(obr15Types != null && obr15Types.length>0) {
							Type obr15Type = obr.getField(15)[0];
							if(obr15Type instanceof Varies) {
								Type tt =((Varies) obr15Type).getData();
								if(tt instanceof GenericComposite ){
									Type comp = ((GenericComposite)tt).getComponent(1);
									if(comp instanceof Varies) {
										Type ttt = ((Varies)comp).getData();
										weirdFixToGetObr1512 = ttt.toString();
									}
								}
							}
						}
						JSONObject obrHeader = new JSONObject();
						
						String specimenReceivedDateTime = formatDateTime(Terser.get(obr, 14, 0, 1, 1));
						obrHeader.accumulate(OLISHL7Handler.OBR_SPECIMEN_RECEIVED_DATETIME, specimenReceivedDateTime);
						
						String specimen = getString(Terser.get(obr, 15, 0, 1, 2)); // getString(terser.get("/.OBR-15-1-2"));
						if(Terser.get(obr, 15, 0, 1, 2) == null && weirdFixToGetObr1512 != null) {
							specimen = weirdFixToGetObr1512;
						}
						obrSpecimenSource.add(specimen);
						obrHeader.accumulate(OLISHL7Handler.OBR_SPECIMEN_TYPE, specimen);
						
						String siteModifier = getString(Terser.get(obr, 15, 0, 5, 2)); // getString(terser.get("/.OBR-15-5-2"));
						obrHeader.accumulate(OLISHL7Handler.OBR_SITE_MODIFIER, siteModifier);
						
						char status = getString(Terser.get(obr, 25, 0, 1, 1)).charAt(0);
						parseObrStatus(String.valueOf(status));
						isFinal &= isStatusFinal(status);
						isCorrected |= status == 'C';
						obrStatus.add(getTestRequestStatusMessage(status));
						

						String parent = getString(Terser.get(obr, 26, 0, 2, 1));
						if (!"".equals(parent)) {
							obrParentMap.put(parent, String.valueOf(obrNum));
						}
						obrHeaders.add(obrHeader);

					} else if (segmentName.equals("DG1")) {
						Structure[] segs = terser.getFinder().getRoot().getAll(segments[k]);
						for (int l = 0; l < segs.length; l++) {
							Segment dg1Seg = (Segment) segs[l];
							obrDiagnosis.put(obrNum - 1, dg1Seg);
						}
					}
				} catch (Exception e) {
					MiscUtils.getLogger().error("OLIS HL7 Error", e);
				}
			}
			obrGroups.add(obxSegs);
		}
		obxSortMap = new HashMap<Integer, List<OlisLabResultSortable>>();
		obrSortMap = new HashMap<String, Integer>();
		getOlisMicroorganismNomenclatureMap();
		mapOBRSortKeys();

		disciplines = new ArrayList<String>();
		for (int i = 0; i < getOBRCount(); i++) {
			disciplines.add(getOBRCategory(i));
		}
	}

	private void parseZBRSegment(int zbrNum) {
		try {
			String key = "", value = "";
			Segment zbr = null;
			if (zbrNum == 1) {
				zbr = terser.getSegment("/.ZBR");
			} else {
				zbr = (Segment) terser.getFinder().getRoot().get("ZBR" + zbrNum);
			}
			
			String status = Terser.get(zbr, 13, 0, 1, 1);
			if (status.equals("Y") && !reportStatus.equals("Y")) {
				reportStatus = status;
				reportStatusDescription = "Full Replace Amendment";
			}
			
			int[] indexes = { 2, 3, 4, 6, 8 };
			for (int index : indexes) {
				if (getString(Terser.get(zbr, index, 0, 6, 2)).equals("")) {
					continue;
				}
				key = getString(Terser.get(zbr, index, 0, 6, 2));
				if (key != null && key.indexOf(":") > 0) {
					key = key.substring(key.indexOf(":") + 1);
				}
				value = getString(Terser.get(zbr, index, 0, 1, 1));
				sourceOrganizations.put(key, value);
			}
		} catch (Exception e) {
			MiscUtils.getLogger().error("OLIS HL7 Error", e);
		}
	}

	private void parsePIDSegment() throws HL7Exception {
		Segment pid = terser.getSegment("/.PID");
		int rep = -1;
		String identifier = "";
		String value = "";
		String attrib = "";

		patientIdentifiers = new HashMap<String, String[]>();
		while ((identifier = Terser.get(pid, 3, ++rep, 5, 1)) != null) {

			value = Terser.get(pid, 3, rep, 1, 1);

			attrib = Terser.get(pid, 3, rep, 4, 2);
			if (attrib != null) {
				attrib = attrib.substring(attrib.indexOf(":") + 1);
			}

			patientIdentifiers.put(identifier, new String[] { value, attrib });

		}
		patientAddresses = new ArrayList<HashMap<String, String>>();
		rep = -1;
		HashMap<String, String> address;
		while ((identifier = Terser.get(pid, 11, ++rep, 7, 1)) != null) {
			address = new HashMap<String, String>();
			value = Terser.get(pid, 11, rep, 1, 1);
			if (stringIsNotNullOrEmpty(value)) {
				address.put("Street Address", value);
			}
			value = Terser.get(pid, 11, rep, 2, 1);
			if (stringIsNotNullOrEmpty(value)) {
				address.put("Other Designation", value);
			}
			value = Terser.get(pid, 11, rep, 3, 1);
			if (stringIsNotNullOrEmpty(value)) {
				address.put("City", value);
			}
			value = Terser.get(pid, 11, rep, 4, 1);
			if (stringIsNotNullOrEmpty(value)) {
				address.put("Province", value);
			}
			value = Terser.get(pid, 11, rep, 5, 1);
			if (stringIsNotNullOrEmpty(value)) {
				address.put("Postal Code", value);
			}
			value = Terser.get(pid, 11, rep, 6, 1);
			if (stringIsNotNullOrEmpty(value)) {
				address.put("Country", value);
			}
			address.put("Address Type", addressTypeNames.get(identifier));
			patientAddresses.add(address);
		}

		patientHomeTelecom = new ArrayList<HashMap<String, String>>();
		rep = -1;
		HashMap<String, String> telecom;
		while ((identifier = Terser.get(pid, 13, ++rep, 2, 1)) != null) {
			telecom = new HashMap<String, String>();
			value = Terser.get(pid, 13, rep, 1, 1);
			if (stringIsNotNullOrEmpty(value)) {
				telecom.put("phoneNumber", value);
			}
			value = Terser.get(pid, 13, rep, 3, 1);
			if (stringIsNotNullOrEmpty(value)) {
				value = telecomEquipType.get(value);
				if (stringIsNotNullOrEmpty(value)) {
					telecom.put("equipType", value);
				}
			}
			value = Terser.get(pid, 13, rep, 4, 1);
			if (stringIsNotNullOrEmpty(value)) {
				telecom.put("email", value);
			}
			value = Terser.get(pid, 13, rep, 5, 1);
			if (stringIsNotNullOrEmpty(value)) {
				telecom.put("countryCode", value);
			}
			value = Terser.get(pid, 13, rep, 6, 1);
			if (stringIsNotNullOrEmpty(value)) {
				telecom.put("areaCode", value);
			}
			value = Terser.get(pid, 13, rep, 7, 1);
			if (stringIsNotNullOrEmpty(value)) {
				telecom.put("localNumber", value);
			}
			value = Terser.get(pid, 13, rep, 8, 1);
			if (stringIsNotNullOrEmpty(value)) {
				telecom.put("extension", value);
			}
			telecom.put("useCode", telecomUseCode.get(identifier));
			patientHomeTelecom.add(telecom);
		}

		patientWorkTelecom = new ArrayList<HashMap<String, String>>();
		rep = -1;
		while ((identifier = Terser.get(pid, 14, ++rep, 2, 1)) != null) {
			telecom = new HashMap<String, String>();
			value = Terser.get(pid, 14, rep, 1, 1);
			if (stringIsNotNullOrEmpty(value)) {
				telecom.put("phoneNumber", value);
			}
			value = Terser.get(pid, 14, rep, 3, 1);
			if (stringIsNotNullOrEmpty(value)) {
				value = telecomEquipType.get(value);
				if (stringIsNotNullOrEmpty(value)) {
					telecom.put("equipType", value);
				}
			}
			value = Terser.get(pid, 14, rep, 4, 1);
			if (stringIsNotNullOrEmpty(value)) {
				telecom.put("email", value);
			}
			value = Terser.get(pid, 14, rep, 5, 1);
			if (stringIsNotNullOrEmpty(value)) {
				telecom.put("countryCode", value);
			}
			value = Terser.get(pid, 14, rep, 6, 1);
			if (stringIsNotNullOrEmpty(value)) {
				telecom.put("areaCode", value);
			}
			value = Terser.get(pid, 14, rep, 7, 1);
			if (stringIsNotNullOrEmpty(value)) {
				telecom.put("localNumber", value);
			}
			value = Terser.get(pid, 14, rep, 8, 1);
			if (stringIsNotNullOrEmpty(value)) {
				telecom.put("extension", value);
			}
			telecom.put("useCode", telecomUseCode.get(identifier));
			patientWorkTelecom.add(telecom);
		}
	}

	private void parseZPDSegment() throws HL7Exception {
		Segment zpd = terser.getSegment("/.ZPD");
		boolean rb = "Y".equals(oscar.Misc.getStr(Terser.get(zpd, 3, 0, 1, 1), ""));
		if(!reportBlocked && rb) {
			reportBlocked=true;
		}
	}

	private void parseERRSegment() throws HL7Exception {
		Segment err = terser.getSegment("/.ERR");
		errors = new ArrayList<OLISError>();
		String segment, sequence, field, identifier, text;
		int rep = -1;
		while ((identifier = Terser.get(err, 1, ++rep, 4, 1)) != null) {
			if (identifier.trim().equals("320")) {
				reportBlocked = true;
			}
			segment = Terser.get(err, 1, rep, 1, 1);
			sequence = Terser.get(err, 1, rep, 1, 2);
			field = Terser.get(err, 1, rep, 1, 3);
			text = Terser.get(err, 1, rep, 4, 2);
			errors.add(new OLISError(segment, sequence, field, identifier, text));
		}
	}

	HashMap<String, Integer> obrSortMap;

	private void mapOBRSortKeys() {

		int obrCount = getOBRCount();
		Segment zbr;
		String tempKey;
		try {
			for (int i = 0; i < obrCount; i++) {
				mapOBXSortKey(i);
				if (i == 0) {
					zbr = terser.getSegment("/.ZBR");
				} else {
					zbr = (Segment) terser.getFinder().getRoot().get("ZBR" + (i + 1));
				}
				try {
					tempKey = getString(Terser.get(zbr, 11, 0, 1, 1));
					tempKey = tempKey.equals("") ? String.valueOf(i) : tempKey;
					if (obrSortMap.containsKey(tempKey)) {
						tempKey = tempKey + i;
					}
					obrSortMap.put(tempKey, i);
				} catch (Exception e) {
					MiscUtils.getLogger().error("OLIS HL7 Error", e);
				}
			}
		} catch (Exception e) {
			MiscUtils.getLogger().error("OLIS HL7 Error", e);
		}
	}

    private void mapOBXSortKey(int obr) {
        if (this.olisResultNomenclatureMap == null) {
            this.olisResultNomenclatureMap = getOlisResultNomenclatureMap();
        }
		int k;
        List<OlisLabResultSortable> resultList = new ArrayList<>();

		String[] segments = terser.getFinder().getRoot().getNames();
		List<Segment> obxSegments = obrGroups.get(obr);
        
        try {
            // For each OBX Segment
            for (Segment obxSegment : obxSegments) {
                // Gets the set id, the sub id, the result status, and the loinc code from the OBX segment
                int setId = Integer.parseInt(Terser.get(obxSegment, 1, 0, 1, 1));
                String subId = StringUtils.trimToEmpty(Terser.get(obxSegment, 4, 0, 1, 1));
                String resultStatus = getOBXResultStatus(obr, setId - 1);
                String loincCode = getObxLoincCode(obxSegment);
                // Gets the related nomenclature if it exists
                OLISResultNomenclature nomenclature = olisResultNomenclatureMap.get(loincCode);

                
                String zbxSortKey = "";
                Date releaseDate = null;
                k = getZBXLocation(obr, setId - 1);
                // If the segment is ZBX, gets the sort key and the release date
                if (segments[k].startsWith("ZBX")) {
                    Structure[] zbxSegs = terser.getFinder().getRoot().getAll(segments[k]);
                    // Gets the segment for the current ZBX
                    Segment zbxSeg = (Segment) zbxSegs[0];
                    SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMddHHmmssz");
                    // Gets the sort key and the release date for sorting
                    zbxSortKey= getString(Terser.get(zbxSeg, 2, 0, 1, 1));
                    releaseDate = sdf.parse(Terser.get(zbxSeg, 1, 0, 1, 1));
                }
                
                // Creates a new OlisLabResultSortable object and adds it to the result list
                OlisLabResultSortable labResult = new OlisLabResultSortable(setId, subId, nomenclature.getSortKey(), nomenclature.getResultAlternateName1(), resultStatus.equals("Z"), releaseDate, zbxSortKey);
                resultList.add(labResult);
            }
        } catch (Exception e) {
            MiscUtils.getLogger().error("OLIS HL7 Error", e);
        }

        // Sorts the results and adds them to the map
		Collections.sort(resultList, OlisLabResultSortable.olisResultComparator);
        obxSortMap.put(obr, resultList);
    }
	
	private String getObxLoincCode(Segment segment) throws HL7Exception {
		return Terser.get(segment, 3, 0, 1, 1);
	}

	private int getZBXLocation(int i, int j) {

		int obrCount = 0;
		int obxCount = 0;
		// Compensating for -1 parameters for OBR and OBX
		j++;
		i++;
		String[] segments = terser.getFinder().getRoot().getNames();

		String segId = "";
		for (int k = 0; k != segments.length && obxCount <= j && obrCount <= i; k++) {
			segId = segments[k].substring(0, 3);

			// We count all OBRs we see.
			if (segId.equals("OBR")) {
				obrCount++;
			}

			// We count only OBX's for the desired OBR
			else if (segId.equals("OBX") && obrCount == i) {
				obxCount++;
			}

			// Check that this segment is an NTE and we are in the right OBR/OBX position.
			else if (segId.equals("ZBX") && obxCount == j && obrCount == i) {
				return k;
			}
		}
		return segments.length - 1;
	}

	private String finalStatus = "CFEX";

	public boolean isStatusFinal(char status) {
		return finalStatus.contains(String.valueOf(status));
	}

	public String getNatureOfAbnormalTest(int obr, int obx) {
		String nature = getString(getOBXField(obr, obx, 10, 0, 1));
		return stringIsNotNullOrEmpty(nature) ? getNatureOfAbnormalTest(nature.charAt(0)) : "";
	}
	
	public List<String> getNatureOfAbnormalTestList(int obr, int obx) {
		List<String> results = new ArrayList<String>();
		int index = 0;
		String abnormalResult = getOBXField(obr, obx, 10, index, 1);
		while (!abnormalResult.isEmpty()) {
			results.add(abnormalResult);
			index++;
			abnormalResult = getOBXField(obr, obx, 10, index, 1);
		}
		return results;
	}

	public String getNatureOfAbnormalTest(char nature) {
		switch (nature) {
		case 'A':
			return "An age-based population";
		case 'N':
			return "None‚ A generic normal range";
		case 'R':
			return "A race-based population";
		case 'S':
			return "A sex-based population";
		default:
			return "";
		}
	}

	public String getTestResultStatusMessage(char status) {
		switch (status) {
			case 'C':
				return "Amended";
			case 'P':
				return "Preliminary";
			case 'X':
				return "Could not obtain result";
			case 'W':
				return "Invalid result";
			case 'N':
				return "Test not performed";
			case 'Z':
				return "Patient Observation";
			default:
				return "";
		}
	}

	/**
	 * Returns a descriptions of the passed Test Request Status.
	 * The statuses match to the following as follows:
	 *  F - Final
	 *  O - Ordered
	 *  I - Pending
	 *  X - Cancelled
	 *  P - Preliminary
	 *  C - Amended
	 *  A - Partial
	 * 
	 * @param status Status of the test request
	 * @return Description of the provided status
	 */
	public String getTestRequestStatusMessage(char status) {
		switch (status) {
		case 'A':
			return "partial";
		case 'C':
			return "amended";
		case 'E':
			return "OLIS has expired the test request because no activity has occurred within a reasonable amount of time.";
		case 'F':
			return "Final";
		case 'I':
			return "pending";
		case 'O':
			return "specimen not yet collected";
		case 'P':
			return "preliminary";
		case 'X':
			return "test was cancelled";
		default:
			return "";
		}
	}

	public String getPointOfCare(int i) {
		i++;
		try {
			Segment obr = null;
			if (i == 1) {
				obr = terser.getSegment("/.OBR");
			} else {
				obr = (Segment) terser.getFinder().getRoot().get("OBR" + i);
			}
			return getString(Terser.get(obr, 30, 0, 1, 1));
		} catch (Exception e) {
			MiscUtils.getLogger().error("OLIS HL7 Error", e);
		}
		return "";
	}
	
	public String getObrStatusFinal(int obrIndex) {
        obrIndex++;
        String status = "";
        try {
            Segment obr;
            if (obrIndex == 1) {
                obr = terser.getSegment("/.OBR");
            } else {
                obr = (Segment) terser.getFinder().getRoot().get("OBR" + obrIndex);
            }
            status = getString(Terser.get(obr, 25, 0, 1, 1));
        } catch (Exception e) {
            MiscUtils.getLogger().error("OLIS HL7 Error", e);
        }
        return status;
    }

	public boolean isObrStatusFinal(int i) {
		return getObrStatusFinal(i).equals("F");
	}
	
	@Override
	public String getMsgType() {
		return (null);
	}

	@Override
	public String getMsgDate() {
		//return 
		//Temporary fix until we change how the MessageUploader grabs the observation date.
		
		try {
			String dateString = getCollectionDateTime(0);
			return dateString.substring(0, 19);
		} catch (Exception e) {
			return ("");
		}

	}

	@Override
	public String getRequestDate(int i) {
		return getOrderDate();
	}

	@SuppressWarnings("unused")
	public void processEncapsulatedData(HttpServletRequest request, HttpServletResponse response, int obr, int obx) {
		getOBXField(obr, obx, 5, 0, 2);
		String subtype = getOBXField(obr, obx, 5, 0, 3);
		String data = getOBXEDField(obr, obx, 5, 0, 5);
		try {
			if (subtype.equals("PDF")) {
				response.setContentType("application/pdf");
				response.setHeader("Content-Disposition", "attachment; filename=\"" + getAccessionNum().replaceAll("\\s", "_") + "_" + obr + "-" + obx + "_Document.pdf\"");
			} else if (subtype.equals("JPEG")) {
				response.setContentType("image/jpeg");
				response.setHeader("Content-Disposition", "attachment; filename=\"" + getAccessionNum().replaceAll("\\s", "_") + "_" + obr + "-" + obx + "_Image.jpg\"");
			} else if (subtype.equals("GIF")) {
				response.setContentType("image/gif");
				response.setHeader("Content-Disposition", "attachment; filename=\"" + getAccessionNum().replaceAll("\\s", "_") + "_" + obr + "-" + obx + "_Image.gif\"");
			} else if (subtype.equals("RTF")) {
				response.setContentType("application/rtf");
				response.setHeader("Content-Disposition", "attachment; filename=\"" + getAccessionNum().replaceAll("\\s", "_") + "_" + obr + "-" + obx + "_Document.rtf\"");
			} else if (subtype.equals("HTML")) {
				response.setContentType("text/html");
				response.setHeader("Content-Disposition", "attachment; filename=\"" + getAccessionNum().replaceAll("\\s", "_") + "_" + obr + "-" + obx + "_Document.html\"");
			} else if (subtype.equals("XML")) {
				response.setContentType("text/xml");
				response.setHeader("Content-Disposition", "attachment; filename=\"" + getAccessionNum().replaceAll("\\s", "_") + "_" + obr + "-" + obx + "_Document.xml\"");
			}


			byte[] buf = Base64.decode(data);
			/*
			int pos = 0;
			int read;
			while (pos < buf.length) {
				read = buf.length - pos > 1024 ? 1024 : buf.length - pos;
				response.getOutputStream().write(buf, pos, read);
				pos += read;
			}
			*/
			ByteArrayOutputStream baos = new ByteArrayOutputStream();
			baos.write(buf, 0, buf.length);
			baos.writeTo(response.getOutputStream());


		} catch (IOException e) {
			MiscUtils.getLogger().error("OLIS HL7 Error", e);
		}
	}

	public String getCollectorsComment(int i) {
		String comment;
		i++;
		try {
			if (i == 1) {
				comment = getString(terser.get("/.OBR-39-2"));
			} else {
				Segment obrSeg = (Segment) terser.getFinder().getRoot().get("OBR" + i);
				comment = getString(Terser.get(obrSeg, 39, 0, 2, 1));
			}
			return StringUtils.trimToEmpty(comment);

		} catch (Exception e) {
			return ("");
		}

	}

	public String getCollectorsCommentSourceOrganization(int i) {
		String ident;
		String id;
		i++;
		try {
			if (i == 1) {
				id = getString(terser.get("/.ZBR-3-6-2"));
				ident = getString(terser.get("/.ZBR-3-1"));

			} else {
				Segment zbrSeg = (Segment) terser.getFinder().getRoot().get("ZBR" + i);
				ident = getString(Terser.get(zbrSeg, 3, 0, 1, 1));
				id = getString(Terser.get(zbrSeg, 3, 0, 6, 2));
			}
			if (id != null && id.trim().length() > 0) {
				id = id.substring(id.indexOf(":") + 1);
			}
			return ident + " (" + id + ")";

		} catch (Exception e) {
			return ("");
		}

	}

	@Override
	public String getMsgPriority() {
		// TODO: Check if need implementation
		return ("");
	}

	/**
	 * Methods to get information about the Observation Request
	 */
	@Override
	public int getOBRCount() {

		if (obrGroups != null) {
			return (obrGroups.size());
		} else {
			int i = 1;
			// String test;
			Segment test;
			try {

				test = terser.getSegment("/.OBR");
				while (test != null) {
					i++;
					test = (Segment) terser.getFinder().getRoot().get("OBR" + i);
				}

			} catch (Exception e) {
				// ignore exceptions
			}

			return (i - 1);
		}
	}

	@Override
	public String getOBRName(int i) {
		if (olisRequestNomenclatureMap == null) {
			this.olisRequestNomenclatureMap = getOlisRequestNomenclatureMap();
		}
		i++;
		String obrName = "";
		try {
			Segment obrSeg;
			if (i == 1) {
				obrSeg = (Segment) terser.getFinder().getRoot().get("OBR");
			} else {
				obrSeg = (Segment) terser.getFinder().getRoot().get("OBR" + i);
			}
			String loincCode = getString(Terser.get(obrSeg, 4, 0, 1, 1));

			OLISRequestNomenclature requestNomenclature = this.olisRequestNomenclatureMap.get(loincCode);
			if (requestNomenclature != null) {
				obrName = requestNomenclature.getRequestAlternateName1();
			} else {
				logger.warn("Missing OLIS request nomenclature for loinc code: " + loincCode);
			}
			
			if (obrName.isEmpty()) {
				obrName = getString(Terser.get(obrSeg, 4, 0, 2, 1));
			}
		} catch(HL7Exception e) {
			logger.error("Could not retrieve or parse OBR " + i);
		}
		
		return obrName;
	}

	@Override
	public String getTimeStamp(int i, int j) {
		String timeStamp;
		i++;
		try {
			if (i == 1) {
				timeStamp = formatDateTime(getString(terser.get("/.OBR-7-1")));
			} else {
				Segment obrSeg = (Segment) terser.getFinder().getRoot().get("OBR" + i);
				timeStamp = formatDateTime(getString(Terser.get(obrSeg, 7, 0, 1, 1)));
			}
			return (timeStamp);
		} catch (Exception e) {
			return ("");
		}
	}

	@Override
	public boolean isOBXAbnormal(int i, int j) {
		String abnormalFlag = getOBXAbnormalFlag(i, j);
		if (abnormalFlag.equals("") || abnormalFlag.equals("N")) return (false);
		else return (true);
	}

	@Override
	public String getOBXAbnormalFlag(int i, int j) {
		return (getOBXField(i, j, 8, 0, 1));
	}

	@Override
	public String getObservationHeader(int i, int j) {

		return getOBRName(i);
		// stored in different places for different messages
		// return("");

	}

	@Override
	public int getOBXCount(int i) {
		try {
			ArrayList<Segment> obxSegs = obrGroups.get(i);
			return (obxSegs.size());
		} catch (Exception e) {
			return 0;
		}
	}

	@Override
	public String getOBXValueType(int i, int j) {
		return (getOBXField(i, j, 2, 0, 1));
	}

	private String getObxValueType(Segment segment) {
		String valueType = "";
		try {
			valueType = Terser.get(segment, 2, 0, 1, 1);
		} catch (HL7Exception e) {
			logger.error("Could not get the value type for a segment");
		}
		
		return StringUtils.trimToEmpty(valueType);
	}
	
	@Override
	public String getOBXIdentifier(int i, int j) {
		return (getOBXField(i, j, 3, 0, 1));
	}

	public String getOBXObservationMethod(int i, int j) {
		return getOBXField(i, j, 17, 0, 2);
	}

	public String getOBXObservationDate(int i, int j) {
		try {
			String date = getOBXField(i, j, 14, 0, 1);
			if (date == null || date.trim().length() == 0) {
				return "";
			}
			return formatDateTime(date);
		} catch (Exception e) {
			MiscUtils.getLogger().error("OLIS HL7 Error", e);
			return "";
		}
	}
	
	public Map<String, OLISRequestNomenclature> getOlisRequestNomenclatureMap() {
	    List<String> requestCodes = new ArrayList<String>();
        for (int obr = 0; obr < this.obrCount; obr++) {
            String requestCode = getNomenclatureRequestCode(obr);
            if (!StringUtils.isEmpty(requestCode)) {
                requestCodes.add(requestCode);
            }
        }
        // Get OLIS Request Nomenclature for lab results
        OLISRequestNomenclatureDao requestDao = (OLISRequestNomenclatureDao) SpringUtils.getBean("OLISRequestNomenclatureDao");
        return requestDao.findByOlisTestRequestCodes(requestCodes);
    }

    /**
     * Gets a map of the current report's loinc codes retrieved from OBX.3.1
     * 
     * @return Map of the loinc codes and their matching result nomenclatures
     */
    private Map<String, OLISResultNomenclature> getOlisResultNomenclatureMap() {
        List<String> loincCodes = new ArrayList<String>();
        // Initializes the current OBX to 0
        int headerObxCount = 0;
        //Loops through each header and gets the number of obx fields in each
        for (int obr = 0; obr < getHeaders().size(); obr++) {
            int obxCount = getOBXCount(obr);
            // Loops through each obx field and gets the loinc code for each one
            for (int obx = 0; obx < obxCount; obx++) {
                // Gets the loinc code for each obx. The obx is identified by the obx count from the previous headers + the obx index
                String resultCode = getNomenclatureResultLoincCode(headerObxCount + obx);
                if (!StringUtils.isEmpty(resultCode)) {
                    loincCodes.add(resultCode);
                }
            }
            // Sets adds the current header's obxCount to the headerObxCount variable so that the number can be kept track of for subsequent headers
            headerObxCount += obxCount;
        }
        
        // Get OLIS Request Nomenclature for lab results
        OLISResultNomenclatureDao resultDao = (OLISResultNomenclatureDao) SpringUtils.getBean("OLISResultNomenclatureDao");
        return resultDao.findByOlisTestLoincCodes(loincCodes);
    }
    
    public String getNomenclatureRequestCode(int obr) {
	    obr++;
        try {
            Segment obrSegment;
            if (obr == 1) {
                obrSegment = terser.getSegment("/.OBR");
            } else {
                obrSegment = (Segment) terser.getFinder().getRoot().get("OBR" + obr);
            }
            return Terser.get(obrSegment, 4, 0, 1, 1);
        } catch (HL7Exception e) {
            MiscUtils.getLogger().error("OLIS HL7 Error", e);
        }
        return "";
    }

    /**
     * Gets the loincCode from the given obx
     * 
     * @param obx The number of the obx that the loinc code is to be retrieved from
     * @return the loinc code for the given obx
     */
    public String getNomenclatureResultLoincCode(int obx) {
        obx++;
        try {
            Segment obrSegment;
            if (obx == 1) {
                obrSegment = terser.getSegment("/.OBX");
            } else {
                obrSegment = (Segment) terser.getFinder().getRoot().get("OBX" + obx);
            }
            return Terser.get(obrSegment, 3, 0, 1, 1);
        } catch (HL7Exception e) {
            MiscUtils.getLogger().error("OLIS HL7 Error", e);
        }
        return "";
    }

    /**
     * Gets a map for the OLIS microorganism nomenclature using the retrieved codes
     */
    public void getOlisMicroorganismNomenclatureMap() {
		// Get OLIS Request Nomenclature for lab results
		OlisMicroorganismNomenclatureDao microorganismNomenclatureDao = SpringUtils.getBean(OlisMicroorganismNomenclatureDao.class);
		if (!microorganismCodes.isEmpty()) {
			this.olisMicroorganismNomenclatureMap = microorganismNomenclatureDao.findAllByMicroorganismCodes(microorganismCodes);
		}
	}
    
	public String getOBRCategory(int i) {
		i++;
		try {
			Segment obr = null;
			if (i == 1) {
				obr = terser.getSegment("/.OBR");
			} else {
				obr = (Segment) terser.getFinder().getRoot().get("OBR" + i);
			}

			String obxCategory = Terser.get(obr, 4, 0, 1, 1);
			OLISRequestNomenclatureDao requestDao = (OLISRequestNomenclatureDao) SpringUtils.getBean("OLISRequestNomenclatureDao");
			OLISRequestNomenclature requestNomenclature = requestDao.findByNameId(obxCategory);
			if(requestNomenclature != null) {
				return StringUtils.trimToEmpty(requestNomenclature.getCategory());
			} else {
				logger.warn("Missing OLIS nomenclature value ("+obxCategory+"). Are you sure you ran olisinit.sql and it successfully completed?");
				return obxCategory;
			}
		} catch (Exception e) {
			MiscUtils.getLogger().error("OLIS HL7 Error", e);
		}
		return "";
	}
	
	public String getOBRSpecimentType(int obrIndex) {
        obrIndex++;
		try {
			Segment obr;
			if (obrIndex == 1) { 
				obr = terser.getSegment("/.OBR");
			} else {
				obr = (Segment) terser.getFinder().getRoot().get("OBR" + obrIndex);
			}
			return getString(Terser.get(obr, 15, 0, 1, 2));
		} catch (HL7Exception e) {
			e.printStackTrace();
		}
		return "";
	}

	@Override
	public String getOBXName(int i, int j) {
	    if (olisResultNomenclatureMap == null) {
            olisResultNomenclatureMap = getOlisResultNomenclatureMap();
        }
        
		String loincCode = getOBXField(i, j, 3, 0, 1);

		String obxName = "";
		try {
			OLISResultNomenclature resultNomenclature = olisResultNomenclatureMap.get(loincCode);
			if(resultNomenclature != null) {
				obxName = StringUtils.trimToEmpty(resultNomenclature.getResultAlternateName1());
			} else {
				logger.warn("Missing OLIS nomenclature for loinc code: " + loincCode);
			}
		} catch (Exception e) {
			MiscUtils.getLogger().error("OLIS HL7 Error", e);
		}

        // If we're unable to find a LOINC match for the identifier then try to parse out the obx name.
		if (obxName.isEmpty()) {
            obxName = getOBXField(i, j, 3, 0, 2);
            obxName = "".equals(obxName) ? " " : obxName.contains(":") ? obxName : obxName.substring(0, obxName.indexOf(":"));
        }
		
        return obxName;
	}

	@Override
	public String getOBXNameLong(int i, int j) {
		String obxNameLong = "";

		try {
			obxNameLong = getOBXField(i, j, 3, 0, 2);
		} catch (Exception e) {
			MiscUtils.getLogger().error("OLIS HL7 Error", e);
		}
		
		return obxNameLong;
	}

	public String getOBXCEName(int obr, int obx) {
    	String ceName = "";
    	// Tries to get the microorganism code to see if the result is a microorganism 
		String microorganismCode = getMicroorganismCode(obr, obx);
		// If a code was found, it is a microorganism
    	if (!microorganismCode.isEmpty()) {
    	    // Gets the related nomenclature for the code and uses the alternate name for display
    		OlisMicroorganismNomenclature nomenclature = olisMicroorganismNomenclatureMap.get(microorganismCode);
    		if (nomenclature != null) {
				ceName = nomenclature.getAlternateName1();
			}
		}

    	// If the result is not a microorganism or an error occurred
    	if (ceName.isEmpty()) {
			ceName = getOBXField(obr, obx, 5, 0, 2);
		}
    	
		return ceName;
	}

	public boolean renderAsFT(int i, int j) {
		String obxIdent = getOBXField(i, j, 3, 0, 2).split(":")[4];
		return obxIdent != null && obxIdent.toUpperCase().startsWith("NAR");
	}

	public boolean renderAsNM(int i, int j) {
		String obxIdent = getOBXField(i, j, 3, 0, 2).split(":")[4];
		return obxIdent != null && (obxIdent.toUpperCase().startsWith("ORD") || obxIdent.toUpperCase().startsWith("QN"));
	}

	public boolean isAncillary(int i, int j) {
		String obxIdent = getOBXField(i, j, 3, 0, 3);
		return obxIdent != null && (obxIdent.toUpperCase().startsWith("LN"));
	}

	public String getOBXCESensitivity(int i, int j) {
		String type = getOBXValueType(i, j);
		String obxValue = getOBXField(i, j, 5, 0, 1);
    	
		if (type.equals("SN")) {
			obxValue += getOBXField(i, j, 5, 0, 2);
		} else if (type.equals("TS") || type.equals("DT")) {
			obxValue = formatDateTime(obxValue);
		} else if (type.equals("TM")) {
		    obxValue = formatTime(obxValue);
        }
    	
		return obxValue;
	}

	@Override
	public String getOBXResult(int i, int j) {
		return (getOBXField(i, j, 5, 0, 1));
	}

	public String getOBXTSResult(int i, int j) {
		String date = getOBXField(i, j, 5, 0, 1);
		return formatDateTime(date);
	}

	public String getOBXDTResult(int i, int j) {
		String date = getOBXField(i, j, 5, 0, 1);
		return formatDate(date);
	}

	public String getOBXTMResult(int i, int j) {
		String date = getOBXField(i, j, 5, 0, 1);
		return formatTime(date);
	}

	public String getOBXSNResult(int i, int j) {
		return getOBXField(i, j, 5, 0, 1) + getOBXField(i, j, 5, 0, 2);
	}

	@Override
	public String getOBXReferenceRange(int i, int j) {
		return (getOBXField(i, j, 7, 0, 1));
	}

	@Override
	public String getOBXUnits(int i, int j) {
		return (getOBXField(i, j, 6, 0, 1));
	}

	@Override
	public String getOBXResultStatus(int i, int j) {
		return (getOBXField(i, j, 11, 0, 1));
	}

	@Override
	public int getOBXFinalResultCount() {
		int obrCount = getOBRCount();
		int obxCount;
		int count = 0;
		String status;
		for (int i = 0; i < obrCount; i++) {
			obxCount = getOBXCount(i);
			for (int j = 0; j < obxCount; j++) {
				status = getOBXResultStatus(i, j);
				if (status.startsWith("F") || status.startsWith("f")) count++;
			}
		}
		return count;
	}

	/**
	 * Retrieve the possible segment headers from the OBX fields
	 */
	@Override
	public ArrayList<String> getHeaders() {
		return this.headers;
	}

	/**
	 * Methods to get information from observation notes
	 */
	@Override
	public int getOBRCommentCount(int i) {

		try {
			String[] segments = terser.getFinder().getRoot().getNames();
			int k = getNTELocation(i, -1);
			int count = 0;

			// make sure to count all the nte segments in the group
			if (k < segments.length && segments[k].substring(0, 3).equals("NTE")) {
				count++;
				++k;
				while ((k = indexOfNextNTE(segments, k)) != -1) {
					count++;
					k++;
				}
			}

			return (count);
		} catch (Exception e) {
			logger.error("OBR Comment count error", e);

			return (0);
		}

	}

	@Override
	public String getOBRComment(int i, int j) {

		try {
			String[] segments = terser.getFinder().getRoot().getNames();
			int k = getNTELocation(i, -1);
			if (j > 0) {
				k = indexOfNextNTE(segments, k + 1, j);
			}
			Structure[] nteSegs = terser.getFinder().getRoot().getAll(segments[k]);
			Segment nteSeg = (Segment) nteSegs[0];
			return OLISUtils.Hl7EncodedRepeatableCharacter.performReplacement(getString(Terser.get(nteSeg, 3, 0, 1, 1)), true);

		} catch (Exception e) {
			logger.error("Could not retrieve OBR comments", e);

			return ("");
		}
	}

	public String getOBRCommentString(int i, int j) {
		try {
			String[] segments = terser.getFinder().getRoot().getNames();
			int k = getNTELocation(i, -1);
			if (j > 0) {
				k = indexOfNextNTE(segments, k + 1, j);
			}
			Structure[] nteSegs = terser.getFinder().getRoot().getAll(segments[k]);
			Segment nteSeg = (Segment) nteSegs[0];
			return getString(Terser.get(nteSeg, 3, 0, 1, 1));

		} catch (Exception e) {
			logger.error("Could not retrieve OBR comments", e);

			return ("");
		}
	}

	/**
	 * Local method to retrieve the source organization from the database if it is not present in the lab file
	 * @param ident The identifier type of the organization
	 * @param key The key used to retrieve the organization in the list of source organizations
	 * @return Formatted organization name to be displayed on the Report.
	 */
	private String getExternalSourceOrganization(String ident, String key) {
		OLISFacilitiesDao olisFacilitiesDao = SpringUtils.getBean(OLISFacilitiesDao.class);
		OLISFacilities olisFacility = olisFacilitiesDao.findByLicenceNumber(Integer.parseInt(key));
		String organizationName;
		if (olisFacility != null && olisFacility.getFacilityName() != null) {
			organizationName = olisFacility.getFacilityName();
		} else {
			organizationName = sourceOrganizations.get(key);
		}
		return String.format("%s (%s %s)", organizationName, ident, key);
	}

	public String getOBRSourceOrganization(int i, int j) {
		try {
			String[] segments = terser.getFinder().getRoot().getNames();
			int k = getNTELocation(i, -1);
			if (j > 0) {
				k = indexOfNextNTE(segments, k + 1, j);
			}
			k++;
			Structure[] ZNTSegs = terser.getFinder().getRoot().getAll(segments[k]);
			Segment ZNTSeg = (Segment) ZNTSegs[0];
			String key = Terser.get(ZNTSeg, 1, 0, 2, 1);
			if (key == null || key.indexOf(":") == -1) {
				return "";
			}
			String ident = key.substring(0, key.indexOf(":"));
			ident = getOrganizationType(ident);
			key = key.substring(key.indexOf(":") + 1);

			return getExternalSourceOrganization(ident, key);

		} catch (Exception e) {
			logger.error("Could not retrieve OBX comment ZNT", e);

			return ("");
		}
	}

	public String getCollectionDateTime(int obrIndex) {
		obrIndex++;
		Segment obr;

		try {
			if (obrIndex == 1) {
				obr = terser.getSegment("/.OBR");
			} else {
				obr = (Segment) terser.getFinder().getRoot().get("OBR" + obrIndex);
			}
			String from = getString(Terser.get(obr, 7, 0, 1, 1));
			if (from.length() >= 8) {
				from = formatDateTime(from);
			}
			String to = getString(Terser.get(obr, 8, 0, 1, 1));
			if (to.length() >= 8) {
				to = formatDateTime(to);
			}
			boolean hasBoth = stringIsNotNullOrEmpty(from) && stringIsNotNullOrEmpty(to);
			return String.format("%s %s %s", from, hasBoth ? "-" : "", to);
		} catch (Exception e) {
			MiscUtils.getLogger().error("OLIS HL7 Error", e);
		}
		return "";
	}

	public String getOrganizationType(String ident) {
		if (ident.equals("2.16.840.1.113883.3.59.1")) {
			return "Lab";
		}
		if (ident.equals("2.16.840.1.113883.3.59.2")) {
			return "SCC";
		}
		if (ident.equals("2.16.840.1.113883.3.59.3")) {
			return "Hospital";
		}
		return "";
	}

	public String getSpecimenCollectedBy(int obr) {
		try {
			obr++;
			String key = "", value = "", ident = "";
			Segment zbr = null;
			if (obr == 1) {
				zbr = terser.getSegment("/.ZBR");
			} else {
				zbr = (Segment) terser.getFinder().getRoot().get("ZBR" + obr);
			}
			key = getString(Terser.get(zbr, 3, 0, 6, 2));
			if (key != null && key.indexOf(":") > 0) {
				ident = key.substring(0, key.indexOf(":"));
				ident = getOrganizationType(ident);
				key = key.substring(key.indexOf(":") + 1);
			}
			if (key == null || key.trim().equals("")) {
				return "";
			}
			value = getString(Terser.get(zbr, 3, 0, 1, 1));
			return String.format("%s (%s %s)", value, ident, key);
		} catch (Exception e) {
			MiscUtils.getLogger().error("OLIS HL7 Error", e);
		}
		return "";
	}

	public String getCollectionVolume(int obrIndex) {
		obrIndex++;
		Segment obr;

		try {
			if (obrIndex == 1) {
				obr = terser.getSegment("/.OBR");
			} else {
				obr = (Segment) terser.getFinder().getRoot().get("OBR" + obrIndex);
			}
			String volume = getString(Terser.get(obr, 9, 0, 1, 1));
			String units = getString(Terser.get(obr, 9, 0, 2, 1));
			return volume + " " + units;
		} catch (Exception e) {
			MiscUtils.getLogger().error("OLIS HL7 Error", e);
		}
		return "";
	}

	public String getNoOfSampleContainers(int obrIndex) {
		obrIndex++;
		Segment obr;

		try {
			if (obrIndex == 1) {
				obr = terser.getSegment("/.OBR");
			} else {
				obr = (Segment) terser.getFinder().getRoot().get("OBR" + obrIndex);
			}
			String count = getString(Terser.get(obr, 37, 0, 1, 1));

			return count;
		} catch (Exception e) {
			MiscUtils.getLogger().error("OLIS HL7 Error", e);
		}
		return "";
	}

	/**
	 * Methods to get information from observation notes
	 */
	public int getReportCommentCount() {

		try {
			String[] segments = terser.getFinder().getRoot().getNames();
			int k = getNTELocation(-1, -1);
			int count = 0;

			// make sure to count all the nte segments in the group
			if (k < segments.length && segments[k].substring(0, 3).equals("NTE")) {
				count++;
				++k;
				while ((k = indexOfNextNTE(segments, k)) != -1) {
					count++;
					k++;
				}
			}

			return (count);
		} catch (Exception e) {
			logger.error("OBR Comment count error", e);

			return (0);
		}

	}

	public String getReportComment(int j) {

		try {
			String[] segments = terser.getFinder().getRoot().getNames();
			int k = getNTELocation(-1, -1);
			if (j > 0) {
				k = indexOfNextNTE(segments, k + 1, j);
			}
			Structure[] nteSegs = terser.getFinder().getRoot().getAll(segments[k]);
			Segment nteSeg = (Segment) nteSegs[0];
			return OLISUtils.Hl7EncodedRepeatableCharacter.performReplacement(getString(Terser.get(nteSeg, 3, 0, 1, 1)), true);

		} catch (Exception e) {
			logger.error("Could not retrieve OBR comments", e);

			return ("");
		}
	}
	
    public String getReportCommentForPdf(int j) {
        try {
            String[] segments = terser.getFinder().getRoot().getNames();
            int k = getNTELocation(-1, -1);
            if (j > 0) {
                k = indexOfNextNTE(segments, k + 1, j);
            }
            Structure[] nteSegs = terser.getFinder().getRoot().getAll(segments[k]);
            Segment nteSeg = (Segment) nteSegs[0];
            return getString(Terser.get(nteSeg, 3, 0, 1, 1));

        } catch (Exception e) {
            logger.error("Could not retrieve OBR comments", e);
            return ("");
        }
    }

	public String getReportSourceOrganization(int j) {
		try {
			String[] segments = terser.getFinder().getRoot().getNames();
			int k = getNTELocation(-1, -1);
			if (j > 0) {
				k = indexOfNextNTE(segments, k + 1, j);
			}
			k++;
			Structure[] ZNTSegs = terser.getFinder().getRoot().getAll(segments[k]);
			Segment ZNTSeg = (Segment) ZNTSegs[0];
			String key = Terser.get(ZNTSeg, 1, 0, 2, 1);
			if (key == null || key.indexOf(":") == -1) {
				return "";
			}
			String ident = key.substring(0, key.indexOf(":"));
			ident = getOrganizationType(ident);
			key = key.substring(key.indexOf(":") + 1);

			return getExternalSourceOrganization(ident, key);
		} catch (Exception e) {
			logger.error("Could not retrieve OBX comment ZNT", e);

			return ("");
		}
	}

	public int indexOfNextNTE(String[] segments, int pos) {
		return indexOfNextNTE(segments, pos, 1);
	}

	public int indexOfNextNTE(String[] segments, int pos, int skip) {
		String segId = "";
		int count = 0;
		while (pos < segments.length) {
			segId = segments[pos].substring(0, 3);
			if (segId.equals("OBR")) {
				break;
			}
			if (segId.equals("OBX")) {
				break;
			}
			if (segId.equals("NTE")) {
				count++;
				if (count >= skip) {
					return pos;
				}
			}
			pos++;
		}
		return -1;
	}

	/**
	 * Methods to get information from observation notes
	 */
	@Override
	public int getOBXCommentCount(int i, int j) {
		// jth obx of the ith obr

		try {

			String[] segments = terser.getFinder().getRoot().getNames();
			int k = getNTELocation(i, j);

			int count = 0;
			if (k < segments.length && segments[k].substring(0, 3).equals("NTE")) {
				count++;
				++k;
				while ((k = indexOfNextNTE(segments, k)) != -1) {
					count++;
					k++;
				}
			}

			return (count);
		} catch (Exception e) {
			logger.error("OBR Comment count error", e);

			return (0);
		}

	}

	@Override
	public String getOBXComment(int i, int j, int nteNum) {
		try {
			String[] segments = terser.getFinder().getRoot().getNames();
			int k = getNTELocation(i, j);
			if (nteNum > 0) {
				k = indexOfNextNTE(segments, k, nteNum + 1);
			}
			Structure[] nteSegs = terser.getFinder().getRoot().getAll(segments[k]);
			Segment nteSeg = (Segment) nteSegs[0];
			return OLISUtils.Hl7EncodedRepeatableCharacter.performReplacement(getString(Terser.get(nteSeg, 3, 0, 1, 1)), true).replace(" ", "&nbsp;");

		} catch (Exception e) {
			logger.error("Could not retrieve OBX comments", e);

			return ("");
		}
	}
	
    public String getOBXCommentNoFormat(int i, int j, int nteNum) {
        try {
            String[] segments = terser.getFinder().getRoot().getNames();
            int k = getNTELocation(i, j);
            if (nteNum > 0) {
                k = indexOfNextNTE(segments, k, nteNum + 1);
            }
            Structure[] nteSegs = terser.getFinder().getRoot().getAll(segments[k]);
            Segment nteSeg = (Segment) nteSegs[0];
            return getString(Terser.get(nteSeg, 3, 0, 1, 1));

        } catch (Exception e) {
            logger.error("Could not retrieve OBX comments", e);

            return ("");
        }
    }

	public String getOBXSourceOrganization(int i, int j, int nteNum) {
		try {
			String[] segments = terser.getFinder().getRoot().getNames();
			int k = getNTELocation(i, j);
			if (nteNum > 0) {
				k = indexOfNextNTE(segments, k, nteNum + 1);
			}
			k++;
			Structure[] ZNTSegs = terser.getFinder().getRoot().getAll(segments[k]);
			Segment ZNTSeg = (Segment) ZNTSegs[0];
			String key = Terser.get(ZNTSeg, 1, 0, 2, 1);
			if (key == null || key.indexOf(":") == -1) {
				return "";
			}
			String ident = key.substring(0, key.indexOf(":"));
			ident = getOrganizationType(ident);
			key = key.substring(key.indexOf(":") + 1);

			return getExternalSourceOrganization(ident, key);
		} catch (Exception e) {
			logger.error("Could not retrieve OBX comment ZNT", e);

			return ("");
		}
	}

	/*
	 * Patient Name 1 Last Name 2 First Name 3 Second Name 4 Suffix (e.g., JR or III) 5 Prefix (e.g., DR) 6 Degree 7 Name Type Code
	 */

	public String parseFullNameFromSegment(String ident) {
		String name = "";
		String temp = null;

		// get name prefix ie/ DR.
		try {
			temp = terser.get(ident + "5");
		} catch (HL7Exception e) {
			// TODO Auto-generated catch block
			MiscUtils.getLogger().error("OLIS HL7 Error", e);
		}
		if (temp != null) {
			name = temp;
		}

		// get the name
		try {
			temp = terser.get(ident + "2");
		} catch (HL7Exception e) {
			temp = null;
		}
		if (temp != null) {
			if (name.equals("")) {
				name = temp;
			} else {
				name = name + " " + temp;
			}
		}
		try {
			if (terser.get(ident + "3") != null) name = name + " " + terser.get(ident + "3");
		} catch (HL7Exception e) {
			name = null;
		}
		try {
			if (terser.get(ident + "1") != null) name = name + " " + terser.get(ident + "1");
		} catch (HL7Exception e) {
			temp = null;
		}
		try {
			if (terser.get(ident + "4") != null) name = name + " " + terser.get(ident + "4");
		} catch (HL7Exception e) {
			temp = null;
		}
		try {
			if (terser.get(ident + "6") != null) name = name + " " + terser.get(ident + "6");
		} catch (HL7Exception e) {
			temp = null;
		}

		return (name);
	}

	public String getFillerOrderNumber(){
		return "";
	}
    public String getEncounterId(){
    	return "";
    }
    public String getRadiologistInfo(){
		return "";
	}
    
    public String getNteForOBX(int i, int j){
    	
    	return "";
    }
	/**
	 * Methods to get information about the patient
	 */
	@Override
	public String getPatientName() {
		return (parseFullNameFromSegment("/.PID-5-"));
	}

	@Override
	public String getFirstName() {
		try {
			return (getString(terser.get("/.PID-5-2")));
		} catch (HL7Exception ex) {
			return ("");
		}
	}

	@Override
	public String getLastName() {
		try {
			return (getString(terser.get("/.PID-5-1")));
		} catch (HL7Exception ex) {
			return ("");
		}
	}

	@Override
	public String getDOB() {
		try {
			return (formatDateTime(getString(terser.get("/.PID-7-1"))));
		} catch (Exception e) {
			return ("");
		}
	}

	@Override
	public String getAge() {
		String age = "N/A";
		String dob = getDOB();
		try {
			// Some examples
			DateFormat formatter = new SimpleDateFormat("yyyy-MM-dd");
			java.util.Date date = formatter.parse(dob);
			age = UtilDateUtilities.calcAge(date);
		} catch (ParseException e) {
			logger.error("Could not get age", e);

		}
		return age;
	}

	@Override
	public String getSex() {
		try {
			return (getString(terser.get("/.PID-8-1")));
		} catch (Exception e) {
			return ("");
		}
	}

	@Override
	public String getHealthNum() {
		String healthNum;

		try {

			// Try finding the health number in the external ID
			healthNum = getString(terser.get("/.PID-2-1"));
			if (healthNum.length() == 10) return (healthNum);

			// Try finding the health number in the alternate patient ID
			healthNum = getString(terser.get("/.PID-4-1"));
			if (healthNum.length() == 10) return (healthNum);

			// Try finding the health number in the internal ID
			healthNum = getString(terser.get("/.PID-3-1"));
			if (healthNum.length() == 10) return (healthNum);

			// Try finding the health number in the SSN field
			healthNum = getString(terser.get("/.PID-19-1"));
			if (healthNum.length() == 10) return (healthNum);
		} catch (Exception e) {
			// ignore exceptions
		}

		return ("");
	}

	public String getFormattedHealthNumber() {
		String formattedPatientHealthNumber = StringUtils.trimToEmpty(getHealthNum());
		
		if (formattedPatientHealthNumber.length() == 10) {
			formattedPatientHealthNumber = formattedPatientHealthNumber.substring(0, 4) + " " + formattedPatientHealthNumber.substring(4, 7) + " " + formattedPatientHealthNumber.substring(7);
		}
		return formattedPatientHealthNumber;
	}

	@Override
	public String getHomePhone() {
		try {
			String ext = getString(terser.get("/.PID-13-8"));
			return (getString(terser.get("/.PID-13-6")) + "-" + getString(terser.get("/.PID-13-7")) + " " + (ext != null && ext.length() > 0 ? "x" : "") + ext);
		} catch (Exception e) {
			return ("");
		}
	}

	@Override
	public String getWorkPhone() {
		try {
			String ext = getString(terser.get("/.PID-14-8"));
			return (getString(terser.get("/.PID-14-6")) + "-" + getString(terser.get("/.PID-14-7")) + " " + (ext != null && ext.length() > 0 ? "x" : "") + ext);
		} catch (Exception e) {
			return ("");
		}
	}

	@Override
	public String getPatientLocation() {
		/*
		 * try{ String address = getString(terser.get("/.PID-11-1")); String mailing = String.format("%s %s %s", getString(terser.get("/.PID-11-3")), getString(terser.get("/.PID-11-4")), getString(terser.get("/.PID-11-5"))); return address + "<br/>" +
		 * mailing; }catch(Exception e){ return(""); }
		 */
		return getPerformingFacilityName();
	}

	public String getWorkLocation() {
		try {
			String address = getString(terser.get("/.PID-11-1"));
			String mailing = String.format("%s %s %s", getString(terser.get("/.PID-11-3")), getString(terser.get("/.PID-11-4")), getString(terser.get("/.PID-11-5")));
			return address + "<br/>" + mailing;
		} catch (Exception e) {
			return ("");
		}
	}

	@Override
	public String getServiceDate() {
		try {
			Date mshDate = UtilDateUtilities.StringToDate(getMsgDate(), "yyyy-MM-dd");
			return UtilDateUtilities.DateToString(mshDate, "dd-MMM-yyyy");
		} catch (Exception e) {
			return ("");
		}
	}

	@Override
	public String getOrderStatus() {
		return isCorrected ? "C" : isFinal ? "F" : "P";
	}

	@Override
	public String getClientRef() {
		try {
			return (getString(terser.get("/.OBR-16-1")));
		} catch (Exception e) {
			return ("");
		}
	}

	@Override
	public String getAccessionNum() {
		try {
			return (getString(terser.get("/.ORC-4-1")));
		} catch (Exception e) {
			return ("");
		}
	}

	public String getAccessionNumSourceOrganization() {
		try {
			String key = getString(terser.get("/.ORC-4-3"));
			String ident = "";
			if (key != null && key.indexOf(":") > 0) {
				ident = key.substring(0, key.indexOf(":"));
				ident = getOrganizationType(ident);
				key = key.substring(key.indexOf(":") + 1);
			} else {
				key = "";
			}
			if (key == null || "".equals(key.trim())) {
				return "";
			}

			return getExternalSourceOrganization(ident, key);
		} catch (Exception e) {
			MiscUtils.getLogger().error("OLIS HL7 Error", e);
		}
		return "";
	}

	@Override
	public String getDocName() {
		try {
			return (getFullDocName("/.OBR-16-"));
		} catch (Exception e) {
			return ("");
		}
	}

	public String getShortDocName() {
		try {
			return (getShortName("/.OBR-16-"));
		} catch (Exception e) {
			return ("");
		}
	}

	/**
	 * Gets the licence number for the ordering provider
	 * @return The licence number of the ordering provider
	 */
	public String getOrderingProviderNumber() {
	    String practionerNumber = "";
	    try {
	    	// Gets the practioner number from OBR-16-1
            practionerNumber = terser.get("/.OBR-16-1");
        } catch (HL7Exception e) {
	        logger.error("Could not retrieve the ordering provider's number", e);
        }
	    
	    return practionerNumber;
    }
	
	@Override
	public String getCCDocs() {

		try {
			int i = 0;
			String docs = getFullDocName("/.OBR-28(" + i + ")-");
			i++;
			String nextDoc = getFullDocName("/.OBR-28(" + i + ")-");

			while (!nextDoc.equals("")) {
				docs = docs + ", " + nextDoc;
				i++;
				nextDoc = getFullDocName("/.OBR-28(" + i + ")-");
			}

			return (docs);
		} catch (Exception e) {
			return ("");
		}
	}

	public List<HashMap<String, String>> getFormattedCcDocs() {
		List<HashMap<String, String>> formattedCcDoctors = new ArrayList<>();
		
		String[] allCcDocs = getCCDocs().split(">, ");
		
		HashMap<String, String> doctorMap;
		
		for (String doctor : allCcDocs) {
			formattedCcDoctors.add(parseDoctor(doctor));
		}
		
		return formattedCcDoctors;
	}
	
	public HashMap<String, String> parseDoctor(String doctor) {
		int openSpanStart = doctor.indexOf("<");
		String licence = "";
		String licenceType = "";
		String licenceNumber = "";

		if (openSpanStart != -1){
			int openSpanEnd = doctor.indexOf(">");
			int closeSpanStart = doctor.indexOf("<", openSpanEnd);

			licence = doctor.substring(openSpanEnd + 1, closeSpanStart);
			// Checks if the mdNumber string starts with MD, if so, removes it and trims any remaining whitespace
			int separatorIndex = licence.indexOf(" ");

			licenceType = licence.substring(0, separatorIndex);
			licenceNumber = licence.substring(separatorIndex + 1);

			doctor = doctor.substring(0, openSpanStart);
		}

		HashMap<String, String> doctorMap = new HashMap<>();
		doctorMap.put("name", doctor);
		doctorMap.put("licenceType", licenceType);
		doctorMap.put("licenceNumber", licenceNumber);
		
		return doctorMap;
	}
	
	@Override
	public ArrayList<String> getDocNums() {
		ArrayList<String> nums = new ArrayList<String>();
		String docNum;
		try {
			if ((docNum = terser.get("/.OBR-16-1")) != null) nums.add(docNum);

			int i = 0;
			while ((docNum = terser.get("/.OBR-28(" + i + ")-1")) != null) {
				nums.add(docNum);
				i++;
			}

		} catch (Exception e) {
			MiscUtils.getLogger().error("OLIS HL7 Error", e);
		}

		return (nums);
	}

	@Override
	public String audit() {
		return "";
	}
	
	@Override
	public String getNteForPID() {
    	return "";
    }

	public String getOBXField(int i, int j, int field, int rep, int comp) {
		ArrayList<Segment> obxSegs = obrGroups.get(i);

		try {
			Segment obxSeg = obxSegs.get(j);
			return (getString(Terser.get(obxSeg, field, rep, comp, 1))).trim();
		} catch (Exception e) {
			return ("");
		}
	}

    public String getOBXEDField(int i, int j, int field, int rep, int comp) {
		ArrayList<Segment> obxSegs = obrGroups.get(i);

		try {
			Segment obxSeg = obxSegs.get(j);
			return Terser.get(obxSeg, field, rep, comp, 1);
		} catch (Exception e) {
			return ("");
		}
	}

	private int getNTELocation(int i, int j) {

		int obrCount = 0;
		int obxCount = 0;
		// Compensating for -1 parameters for OBR and OBX
		j++;
		i++;
		String[] segments = terser.getFinder().getRoot().getNames();

		String segId = "";
		for (int k = 0; k != segments.length && obxCount <= j && obrCount <= i; k++) {
			segId = segments[k].substring(0, 3);

			// We count all OBRs we see.
			if (segId.equals("OBR")) {
				obrCount++;
			}

			// We count only OBX's for the desired OBR
			else if (segId.equals("OBX") && obrCount == i) {
				obxCount++;
			}

			// Check that this segment is an NTE and we are in the right OBR/OBX position.
			else if (segId.equals("NTE") && obxCount == j && obrCount == i) {
				return k;
			}
		}
		return segments.length - 1;
	}

	private String getFullDocName(String docSeg) throws HL7Exception {
		String docName = "";
		String temp;
		
		// get last name
		temp = terser.get(docSeg + "2");
		if (temp != null) docName = temp;
		
		if (StringUtils.isNotEmpty(docName)) {
			if (terser.get(docSeg + "5") != null) {
				docName = docName + " " + terser.get(docSeg + "5");
			}
			if (terser.get(docSeg + "7") != null) {
				docName = docName + " " + terser.get(docSeg + "7");
			}
		}
		
		// get the name
		temp = terser.get(docSeg + "3");
		if (temp != null) {
			// get name prefix ie/ DR.
			String prefix = terser.get(docSeg + "6");
			if (prefix != null) {
				if (StringUtils.isEmpty(docName)) {
					docName = prefix;
				} else {
					docName = docName + ", " + prefix;
				}
			}
			
			if (StringUtils.isEmpty(docName)) {
				docName = temp;
			} else if (docName.contains(",")){
				docName = docName + " " + temp;
			} else {
				docName = docName + ", " + temp;
			}
			
			
			// get the middle name/initial
			String middle = terser.get(docSeg + "4");
			if (middle != null) {
				docName = docName + " " + middle;
			}
		}
		
		String modifier = "";
		if (terser.get(docSeg + "13") != null) {
			modifier = terser.get(docSeg + "13").toUpperCase();
			if (modifier.equals("MDL")) {
				modifier = "MD";
			}
			if (modifier.equals("ML")) {
				modifier = "RM";
			}
			if (modifier.equals("NPL")) {
				modifier = "RN(EC)";
			}
			if (modifier.equals("DDSL")) {
				modifier = "DDS";
			}

		}
		if (terser.get(docSeg + "1") != null) {
			String jurisdiction = terser.get(docSeg + "22-1");
			String jurisdictionVal = "";
			if (jurisdiction != null && !jurisdiction.equals("ON") && terser.get(docSeg + "22-2") != null) {
				jurisdictionVal =  " (" + terser.get(docSeg + "22-2") + ")";
			}

			docName = docName + " " + "<span style=\"margin-left:15px; font-size:8px; color:#333333;\">" + modifier + " " + terser.get(docSeg + "1") + jurisdictionVal + "</span>";
		}

		return (docName);
	}

	private String getShortName(String docSeg) throws HL7Exception {
		String docName = "";
		String temp;

		// get name prefix ie/ DR.
		temp = terser.get(docSeg + "6");
		if (temp != null) docName = temp;

		// get the name
		temp = terser.get(docSeg + "3");
		if (temp != null) {
			if (docName.equals("")) {
				docName = temp;
			} else {
				docName = docName + " " + temp;
			}
		}

		if (terser.get(docSeg + "4") != null) {
			docName = docName + " " + terser.get(docSeg + "4");
		}
		if (terser.get(docSeg + "2") != null) {
			docName = docName + " " + terser.get(docSeg + "2");
		}
		if (terser.get(docSeg + "5") != null) {
			docName = docName + " " + terser.get(docSeg + "5");
		}
		if (terser.get(docSeg + "7") != null) {
			docName = docName + " " + terser.get(docSeg + "7");
		}

		return docName;
	}

	protected String formatTime(String plain) {

		String dateFormat = "HHmmss";
		dateFormat = dateFormat.substring(0, plain.length());
		String stringFormat = "HH:mm:ss";
		stringFormat = stringFormat.substring(0, stringFormat.lastIndexOf(dateFormat.charAt(dateFormat.length() - 1)) + 1);

		Date date = UtilDateUtilities.StringToDate(plain, dateFormat);
		return UtilDateUtilities.DateToString(date, stringFormat);
	}

	protected String formatDateTime(String plain) {
		if (plain==null || plain.trim().equals("")) return "";

		String offset = "";
		if (plain.length() > 14) {
			offset = plain.substring(14, 19);
			plain = plain.substring(0, 14);
		}
		String dateFormat = "yyyyMMddHHmmss";
		dateFormat = dateFormat.substring(0, plain.length());
		String stringFormat = "yyyy-MM-dd HH:mm:ss";
		stringFormat = stringFormat.substring(0, stringFormat.lastIndexOf(dateFormat.charAt(dateFormat.length() - 1)) + 1);

		Date date = UtilDateUtilities.StringToDate(plain, dateFormat);
		return UtilDateUtilities.DateToString(date, stringFormat) + " " + getOffsetName(offset);
	}

	private String getOffsetName(String offset) {
		if (offset.equals("-0400")) {
			return "EDT";
		} else if (offset.equals("-0500")) {
			return "EST";
		} else if (offset.equals("-0600")) {
			return "CST";
		} else if (!offset.trim().equals("")) {
			return "UTC" + offset;
		}
		return "";
	}

	public void importSourceOrganizations(OLISHL7Handler instance) {
		if (instance == null) {
			return;
		}
		HashMap<String, String> foreignSource = instance.sourceOrganizations;
		for (String key : foreignSource.keySet()) {
			if (!sourceOrganizations.containsKey(key)) {
				sourceOrganizations.put(key, foreignSource.get(key));
			}
		}
	}

	protected String formatDate(String plain) {

		String dateFormat = "yyyyMMdd";
		dateFormat = dateFormat.substring(0, plain.length());
		String stringFormat = "yyyy-MM-dd";
		stringFormat = stringFormat.substring(0, stringFormat.lastIndexOf(dateFormat.charAt(dateFormat.length() - 1)) + 1);

		Date date = UtilDateUtilities.StringToDate(plain, dateFormat);
		return UtilDateUtilities.DateToString(date, stringFormat);
	}

	protected String getString(String retrieve) {
		if (retrieve != null) {
			return retrieve.trim();
		} else {
			return ("");
		}
	}

	boolean centered = false;

	public String formatString(String s) {
		int pos = 0;
		StringBuilder sb = new StringBuilder();
		centered = false;
		if (s == null || s.equals("")) {
			return "";
		}
		int pieceStart = 0;
		int pieceEnd = 0;
		String op = "";
		String result = "";
		while (pos < s.length()) {
			pieceStart = s.indexOf('\\', pos);
			pieceEnd = s.indexOf('\\', pieceStart + 1);

			// If there are no delimiters take the whole string from this position.
			if (pieceStart == -1 || pieceEnd == -1) {
				sb.append(s.substring(pos, s.length()));
				pos = s.length();
			} else {
				if (pos < pieceStart) {
					sb.append(s.substring(pos, pieceStart));
					pos = pieceStart;
				}
				// If two delimiters are adjacent ignore the first one
				if (pieceStart + 1 == pieceEnd) {
					sb.append("\\");
					pos = pieceEnd;
				} else {
					op = s.substring(pieceStart + 1, pieceEnd);
					result = parseOperator(op);
					if (result.equals("")) {
						sb.append(op);
					} else {
						sb.append(result);
					}
					pos = pieceEnd + 1;
				}
			}
		}

		return sb.toString();
	}

	public String parseOperator(String op) {
		if (op == null || op.equals("")) {
			return "";
		}

		String piece = op.toUpperCase();
		boolean matchFound = true;

		if (piece.equals(".BR")) {
			boolean old = centered;
			centered = false;
			return old ? "</center>" : "<br/>";

		} else if (piece.equals(".H")) {
			return "<span style=\"color:#767676\">";
		} else if (piece.equals(".N")) {
			return "</span>";
		} else if (piece.equals(".CE")) {
			centered = true;
			return (centered ? "</center>" : "") + "<br/><center>";

		} else if (piece.equals(".FE")) {
			// TODO: Implement
		} else if (piece.equals(".NF")) {
			// TODO: Implement
		} else if (piece.equals("F")) {
			return "|";
		} else if (piece.equals("S")) {
			return "^";
		} else if (piece.equals("T")) {
			return "&";
		} else if (piece.equals("R")) {
			return "~";
		} else if (piece.equals("SLASHHACK")) {
			return "\\";
		} else if (piece.equals("MUHACK")) {
			return "&#181;";
		} else {
			matchFound = false;
		}

		if (!matchFound) {
			// If we haven't already matched a command, look for a command with a parameter.
			String patternStr = "\\.(SP|IN|TI|SK)\\s*[+]?(\\d*)\\s*";
			Pattern pattern = Pattern.compile(patternStr);
			Matcher matcher = pattern.matcher(piece.toUpperCase());
			matchFound = matcher.find();
			if (matchFound) {
				// Get all groups for this match
				String result = parseParamsAndFormat(matcher.group(1), matcher.group(2), centered);
				if (result.contains("</center>")) {
					centered = false;
				}
				return result == null ? "" : result;
			}
		}
		return "";
	}

	public static String parseParamsAndFormat(String operator, String operand, boolean centered) {
		Integer opInt = operand.equals("") ? 1 : Integer.valueOf(operand);
		String result = "";
		if (operator.equals("SP")) {
			while (opInt > 0) {
				if (centered) {
					result += "</center>";
					centered = false;
				}
				result += "<br/>";
				opInt--;
			}
		} else if (operator.equals("IN")) {
			while (opInt > 0) {
				result += "&emsp;";
				opInt--;
			}
		} else if (operator.equals("TI")) {
			while (opInt > 0) {
				result += "&nbsp;";
				opInt--;
			}
		} else if (operator.equals("SK")) {
			while (opInt > 0) {
				result += "&nbsp;";
				opInt--;
			}
		} else {
			result = null;
		}
		return result;
	}

	private void parseObxStatus(Segment segment) {
		try {
			String obxStatus = Terser.get(segment, 11, 0, 1, 1);
			if (!obxStatus.isEmpty() && !obxStatus.equals("F") && !reportStatus.equals("Y")) {
				if (obxStatus.equals("W")) {
					reportStatus = obxStatus;
					reportStatusDescription = "Amended/Invalidation Report";
				} else if (!reportStatus.equals("W")) {
					reportStatus = obxStatus;
					reportStatusDescription = "Amended Report";
				}
			}
		} catch (HL7Exception e) {
			logger.error("Could not parse OBX status", e);
		}
	}

	private void parseObrStatus(String status) {
		if (status.equals("C") && !reportStatus.equals("W") && !reportStatus.equals("Y")) {
			reportStatus = status;
			reportStatusDescription = "Amended Report";
		}
	}

    /**
     * Gets the formatted address for non-html uses
     * The address is in the following format:
     * <pre>
     * address1
     * address2
     * postalCode, city, province, country
     * </pre>
     * @param addressMap The address map to format
     * @return String of the formatted address
     */
	public String getFormattedAddress(HashMap<String, String> addressMap) {
	    return getFormattedAddress(addressMap, false);
    }

    /**
     * Formats the provided map of address parts into a single string of the following format:
     * <pre>
     * address1
     * address2
     * postalCode, city, province, country
     * </pre>
     * @param addressMap A map of address parts to be formatted
     * @param isHtml Flag for if the formatted address will be used in HTML,
     *              if <code>true</code>, uses &lt;br /&gt; for line separations
     * @return String of the formatted address
     */
	public String getFormattedAddress(HashMap<String, String> addressMap, boolean isHtml) {
        StringBuilder formattedAddress = new StringBuilder();
	    if (addressMap != null) {
            boolean addComma = false;
            // If it is for HTML use, uses <br /> instead of the system line separators
            String newLine = isHtml ? "<br />" : System.lineSeparator();

            // Gets each part of the address
            String address1 = addressMap.get("Street Address");
            String address2 = addressMap.get("Other Destination");
            String postalCode = addressMap.get("Postal Code");
            String city = addressMap.get("City");
            String province = addressMap.get("Province");
            String country = addressMap.get("Country");

            // Appends the first address line
            if (StringUtils.isNotEmpty(address1)) {
                formattedAddress.append(address1).append(newLine);
            }

            // Appends the second address line
            if (StringUtils.isNotEmpty(address2)) {
                formattedAddress.append(address2).append(newLine);
            }

            // Appends the postal code
            if (StringUtils.isNotEmpty(postalCode)) {
                formattedAddress.append(postalCode);
                addComma = true;
            }

            // Appends the city, separated with a comma if needed
            if (StringUtils.isNotEmpty(city)) {
                if (addComma) {
                    formattedAddress.append(", ");
                }
                formattedAddress.append(city);
                addComma = true;
            }

            // Appends the city, separated with a comma if needed
            if (StringUtils.isNotEmpty(province)) {
                if (addComma) {
                    formattedAddress.append(", ");
                }
                formattedAddress.append(province);
                addComma = true;
            }

            // Appends the city, separated with a comma if needed
            if (StringUtils.isNotEmpty(country)) {
                if (addComma) {
                    formattedAddress.append(", ");
                }
                formattedAddress.append(country);
            }
        }
        return formattedAddress.toString();
    }

	/**
	 * Checks if the OBX is a microorganism parent by comparing OBX.3.1 and checking if it is the code 41852-5. If so, then it is a microorganism parent.
	 * @param obr The OBR that the OBX is under
	 * @param obx The OBX to check
	 * @return {@code true} if the result is a microorganism parent. {@code false} if not.
	 */
    public boolean isMicroorganismParent(int obr, int obx) {
		boolean isMicroorganismParent = false;
		
		// Gets the OBX Segment
		Segment segment = getObxSegment(obr, obx);
		
		try {
			// Gets field 3, section 1 to check if the code is for a Microorganism parent
			String code = Terser.get(segment, 3, 0, 1, 1);
			isMicroorganismParent = code.equals("41852-5");
		} catch (HL7Exception e) {
			logger.error("Could not check if the OLIS result is a microorganism parent. OBR: " + obr + "  OBX: " + obx, e);
		}
		
		return isMicroorganismParent;
	}
    
	/**
	 * Gets the microorganism code for the given obx segment if it's value type is a Coded Entry and the coding system is HL79905
	 * @param obxSegment Segment to get the microorganism code from 
	 * @return The retrieved microorganism code, empty if it's not a CE or the code system doesn't match
	 */
	private String getMicroorganismCode(Segment obxSegment) {
		String microorganismCode = "";
		try {
		    // Checks if the result is a microorganism 
			if (checkIfMicroorganism(obxSegment)) {
			    // Gets the microorganism code from OBX5.1
				microorganismCode = StringUtils.trimToEmpty(Terser.get(obxSegment, 5, 0, 1, 1));
			}
		} catch (HL7Exception e) {
			logger.error("Could not retrieve CE", e);
		}

		return microorganismCode;
	}

	/**
	 * Gets the microorganism code for the given OBR and OBX indexes
	 * @param obr The OBR that the obx is under
	 * @param obx The OBX segment to check
	 * @return the microorganism code
	 */
	private String getMicroorganismCode(int obr, int obx) {
		ArrayList<Segment> obxSegments = obrGroups.get(obr);
		Segment obxSegment = obxSegments.get(obx);
		return getMicroorganismCode(obxSegment);
	}

    /**
     * Checks if the provided OBX segment is a microorganism
     * @param obxSegment The result to check
     * @return {@code true} if the obx is a microorganism, {@code false} if it isn't or an error occurs
     */
	private boolean checkIfMicroorganism(Segment obxSegment) {
		boolean isMicroorganism = false;
		try {
		    // Gets the value type to check if it is a Coded Entry
			String valueType = getObxValueType(obxSegment);
			if (valueType.equals("CE")) {
			    //Gets the code system from OBX5.3 and checks to see if it is HL79905
				String codeSystem = StringUtils.trimToEmpty(Terser.get(obxSegment, 5, 0, 3, 1));
				if (codeSystem.equals("HL79905")) {
					isMicroorganism = true;
				}
			}
		} catch (HL7Exception e) {
			logger.error("ObxSegment could not be properly checked if it is a microorganism", e);
		}

		return isMicroorganism;
	}

	/**
	 * Gets the OBX segment for the given obr and obx index
	 * @param obr The OBR/Request that the result belongs to
	 * @param obx The index of the result
	 * @return The segment for the requested Obx
	 */
	private Segment getObxSegment(int obr, int obx) {
		ArrayList<Segment> obxSegments = obrGroups.get(obr);
		return obxSegments.get(obx);
	}
	
	public class OLISError {
		public OLISError(String segment, String sequence, String field, String indentifer, String text) {
			super();
			this.segment = segment;
			this.sequence = sequence;
			this.field = field;
			this.indentifer = indentifer;
			this.text = text;
		}

		String segment, sequence, field, indentifer, text;

		public String getSegment() {
			return segment;
		}

		public void setSegment(String segment) {
			this.segment = segment;
		}

		public String getSequence() {
			return sequence;
		}

		public void setSequence(String sequence) {
			this.sequence = sequence;
		}

		public String getField() {
			return field;
		}

		public void setField(String field) {
			this.field = field;
		}

		public String getIndentifer() {
			return indentifer;
		}

		public void setIndentifer(String indentifer) {
			this.indentifer = indentifer;
		}

		public String getText() {
			return text;
		}

		public void setText(String text) {
			this.text = text;
		}

		@Override
		public int hashCode() {
			final int prime = 31;
			int result = 1;
			result = prime * result + getOuterType().hashCode();
			result = prime * result + ((field == null) ? 0 : field.hashCode());
			result = prime * result + ((indentifer == null) ? 0 : indentifer.hashCode());
			result = prime * result + ((segment == null) ? 0 : segment.hashCode());
			result = prime * result + ((sequence == null) ? 0 : sequence.hashCode());
			return result;
		}

		/**
		 * OLIS Errors are identified by the error code for global errors or the segment, sequence and field of the error for localised errors.
		 */
		@Override
		public boolean equals(Object obj) {
			if (this == obj) return true;
			if (obj == null) return false;
			if (obj instanceof String) {
				return this.indentifer.equals(obj);
			}
			if (getClass() != obj.getClass()) return false;
			OLISError other = (OLISError) obj;
			if (!getOuterType().equals(other.getOuterType())) return false;
			if (field == null) {
				if (other.field != null) return false;
			} else if (!field.equals(other.field)) return false;
			if (segment == null) {
				if (other.segment != null) return false;
			} else if (!segment.equals(other.segment)) return false;
			if (sequence == null) {
				if (other.sequence != null) return false;
			} else if (!sequence.equals(other.sequence)) return false;
			return true;
		}

		private OLISHL7Handler getOuterType() {
			return OLISHL7Handler.this;
		}

	}
}
