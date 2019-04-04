package oscar.eform;

import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;
import org.oscarehr.PMmodule.dao.ProviderDao;
import org.oscarehr.common.Gender;
import org.oscarehr.common.dao.ClinicDAO;
import org.oscarehr.common.dao.DemographicDao;
import org.oscarehr.common.dao.EFormDao;
import org.oscarehr.common.dao.EFormDataDao;
import org.oscarehr.common.dao.EFormValueDao;
import org.oscarehr.common.dao.OscarAppointmentDao;
import org.oscarehr.common.dao.PatientIntakeLetterFieldDao;
import org.oscarehr.common.dao.ProfessionalSpecialistDao;
import org.oscarehr.common.dao.SystemPreferencesDao;
import org.oscarehr.common.model.Clinic;
import org.oscarehr.common.model.Demographic;
import org.oscarehr.common.model.EForm;
import org.oscarehr.common.model.EFormData;
import org.oscarehr.common.model.EFormValue;
import org.oscarehr.common.model.PatientIntakeLetterField;
import org.oscarehr.common.model.ProfessionalSpecialist;
import org.oscarehr.common.model.Provider;
import org.oscarehr.common.model.SystemPreferences;
import org.oscarehr.util.MiscUtils;
import org.oscarehr.util.SpringUtils;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class PatientIntakeUtil {
    private static final Logger logger = MiscUtils.getLogger();
    private static EFormDao eformDao = SpringUtils.getBean(EFormDao.class);
    private static EFormDataDao eFormDataDao = SpringUtils.getBean(EFormDataDao.class);
    private static EFormValueDao eFormValueDao = SpringUtils.getBean(EFormValueDao.class);
    private static ClinicDAO clinicDao = SpringUtils.getBean(ClinicDAO.class);
    private static ProviderDao providerDao = SpringUtils.getBean(ProviderDao.class);
    private static ProfessionalSpecialistDao professionalSpecialistDao = SpringUtils.getBean(ProfessionalSpecialistDao.class);
    private static DemographicDao demographicDao = SpringUtils.getBean(DemographicDao.class);
    private static OscarAppointmentDao appointmentDao = SpringUtils.getBean(OscarAppointmentDao.class);
    
    private static PatientIntakeLetterFieldDao patientIntakeLetterFieldDao = SpringUtils.getBean(PatientIntakeLetterFieldDao.class);
    private static SystemPreferencesDao systemPreferencesDao = SpringUtils.getBean(SystemPreferencesDao.class);
    
    /**
     * Populates a map object with parameters from the patientIntakeLetterField table
     * @param intakeValueMap A map of the entered values from the Patient Intake form
     * @return A Map populated with data for each of the fields available in the Patient Intake Letter
     */
    static Map<String, String> createTemplateParameterMap(Map<String, String> intakeValueMap) {
        Map<String, String> templateParameterMap = new HashMap<>();
        List<PatientIntakeLetterField> intakeLetterFields = patientIntakeLetterFieldDao.findAll(0, null);
        // Compiles a pattern to match variable tags so that 
        Pattern pattern = Pattern.compile("\\$\\{(\\w*)}");
        // Declares the variables to be used in the intake field loop 
        Matcher matcher;
        String attributeName;
        StringBuffer stringBuffer;
        String eformValue;
        String formattedLine;
        String enteredValue;
        for (PatientIntakeLetterField field : intakeLetterFields) {
            stringBuffer = new StringBuffer();
            eformValue = intakeValueMap.getOrDefault(field.getName(), "");

            formattedLine = "";
            if (StringUtils.isNotEmpty(eformValue)) {
                if (eformValue.equals("yes") || !eformValue.equals("no")) {
                    matcher = pattern.matcher(field.getTrueText());
                    while (matcher.find()) {
                        attributeName = matcher.group(1);
                        enteredValue = intakeValueMap.getOrDefault(attributeName, "");
                        matcher.appendReplacement(stringBuffer, enteredValue);
                    }
                    matcher.appendTail(stringBuffer);

                    formattedLine = stringBuffer.toString();
                } else {
                    formattedLine = field.getFalseText();
                }
            }

            templateParameterMap.put(field.getName(), formattedLine);
        }

        return templateParameterMap;
    }

    /**
     * Populates the provided map with additional data for parameters usable on the patient intake letter eform
     * @param intakeLetterValuesMap The map to add the additional information to
     */
    static void populateAdditionaleLetterData(Map<String, String> intakeLetterValuesMap, Integer demographicNo) {
        Clinic clinic = clinicDao.getClinic();
        String formattedClinicAddress = clinic.getClinicAddress() + ", " + clinic.getClinicCity() + ", " + clinic.getClinicProvince() + ", " + clinic.getClinicPostal();
        intakeLetterValuesMap.put("clinic_name", clinic.getClinicName());
        intakeLetterValuesMap.put("clinic_address", formattedClinicAddress);
        intakeLetterValuesMap.put("clinic_phone", clinic.getClinicPhone());
        intakeLetterValuesMap.put("clinic_fax", clinic.getClinicFax());
        
        Demographic demographic = demographicDao.getDemographic(demographicNo.toString());
        intakeLetterValuesMap.put("formatted_demographic_name", demographic.getFormattedName());
        intakeLetterValuesMap.put("demographic_dob", demographic.getFormattedDob());
        intakeLetterValuesMap.put("demographic_age", String.valueOf(demographic.getAgeInYears()));
        intakeLetterValuesMap.put("demographic_gender", Gender.valueOf(demographic.getSex()).getText());
        
        Date lastAppointmentDate = appointmentDao.getLastAppointmentDateByDemographicNo(demographicNo);
        if (lastAppointmentDate != null) {
            SimpleDateFormat sdf = new SimpleDateFormat("MMMM dd, yyyy");
            intakeLetterValuesMap.put("last_appointment_date", sdf.format(lastAppointmentDate));
        }

        if (StringUtils.isNotEmpty(demographic.getProviderNo())) {
            Provider provider = providerDao.getProvider(demographic.getProviderNo());
            // Creates the MRP signature using their full name and their credentials
            String mrpSignature = provider.getFullName();
            if (StringUtils.isNotEmpty(provider.getCredentials())) {
                mrpSignature += ", " + provider.getCredentials();
            }
            
            intakeLetterValuesMap.put("mrp_signature", mrpSignature);
        }
        
        ProfessionalSpecialist professionalSpecialist = professionalSpecialistDao.getByReferralNo(demographic.getFamilyDoctorNumber());
        if (professionalSpecialist != null) {
            intakeLetterValuesMap.put("referring_provider_name", professionalSpecialist.getFormattedName());
            intakeLetterValuesMap.put("referring_provider_last_name", professionalSpecialist.getLastName());
            intakeLetterValuesMap.put("referring_provider_formatted_address", professionalSpecialist.getStreetAddress());
        }
    }

    /**
     * Creates and saves a new Patient Intake letter using the provided letter and the demographic and provider numbers. Creates a new EFormData record and related EFormValue records with the default
     * information needed for an ordinary RTL. The patient intake letter should be based off of an RTL and follow the same formatting. It must have one <textarea> element to work correctly.
     * @param letterContents The contents of the new letter
     * @param demographicNo The demographic that the letter is being created for
     * @param providerNo The provider number that the letter is being created by
     */
    static void savePatientIntakeLetter(String letterContents, Integer demographicNo, String providerNo) {
        SystemPreferences intakeLetterPreference = systemPreferencesDao.findPreferenceByName("patient_intake_letter_eform");
        // If the preference is set, continue with creating the letter
        if (intakeLetterPreference != null && StringUtils.isNotEmpty(intakeLetterPreference.getValue())) {
            EForm eform = eformDao.find(Integer.parseInt(intakeLetterPreference.getValue()));

            // Appends the newly formatted letter to the eform's HTML so that it displays when the eform is opened
            String eformHtml = eform.getFormHtml();
            Pattern pattern = Pattern.compile("<textarea.*?>");
            Matcher matcher = pattern.matcher(eformHtml);
            if (matcher.find()) {
                int endIndex = matcher.end();
                eformHtml = eformHtml.substring(0, endIndex) + letterContents + eformHtml.substring(endIndex);
            }

            // Creates and saves a new EformData object for the new Intake Letter
            EFormData eformData = new EFormData(eform.getId(), eform.getFormName(), "Generated Patient Intake Letter", demographicNo, true, new Date(), new Date(), providerNo, 
                    eformHtml, eform.isShowLatestFormOnly(), eform.isPatientIndependent(), null, eform.getRoleType());
            eFormDataDao.persist(eformData);

            // Defines the values for the RTL eform which the patient intake letter should be based off of
            List<EFormValue> eformValues = new ArrayList<>();
            eformValues.add(new EFormValue(eformData.getId(), eform.getId(), demographicNo, "efmfid", eform.getId().toString()));
            eformValues.add(new EFormValue(eformData.getId(), eform.getId(), demographicNo, "efmdemographic_no", demographicNo.toString() ));
            eformValues.add(new EFormValue(eformData.getId(), eform.getId(), demographicNo, "efmprovider_no", providerNo));
            eformValues.add(new EFormValue(eformData.getId(), eform.getId(), demographicNo, "eform_link", "null"));
            eformValues.add(new EFormValue(eformData.getId(), eform.getId(), demographicNo, "appointment_no", "null"));
            eformValues.add(new EFormValue(eformData.getId(), eform.getId(), demographicNo, "Letter", letterContents));
            eformValues.add(new EFormValue(eformData.getId(), eform.getId(), demographicNo, "subject", "Generated Patient Intake Letter"));
            eformValues.add(new EFormValue(eformData.getId(), eform.getId(), demographicNo, "SubmitButton", "Submit"));
            eformValues.add(new EFormValue(eformData.getId(), eform.getId(), demographicNo, "faxEForm", "false"));

            for(EFormValue value : eformValues) {
                eFormValueDao.persist(value);
            }

        } else {
            logger.error("The eform to use for the patient intake letter is not defined");
        }
    }
}
