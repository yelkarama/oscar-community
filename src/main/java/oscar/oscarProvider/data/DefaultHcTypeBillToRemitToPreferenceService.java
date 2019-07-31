package oscar.oscarProvider.data;

import org.oscarehr.billing.CA.ON.model.Billing3rdPartyAddress;
import org.oscarehr.common.dao.Billing3rdPartyAddressDao;
import org.oscarehr.common.dao.DemographicExtDao;
import org.oscarehr.common.dao.ProfessionalSpecialistDao;
import org.oscarehr.common.dao.UserPropertyDAO;
import org.oscarehr.common.model.Demographic;
import org.oscarehr.common.model.DemographicExt;
import org.oscarehr.common.model.ProfessionalSpecialist;
import org.oscarehr.common.model.Provider;
import org.oscarehr.common.model.UserProperty;
import org.oscarehr.util.SpringUtils;
import oscar.oscarRx.data.RxProviderData;
import oscar.util.StringUtils;

import java.util.Collections;
import java.util.HashMap;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class DefaultHcTypeBillToRemitToPreferenceService {
    
    public static final Map<String, String> DATABASE_FIELD_MAP;
    static {
        Map<String, String> aMap = new HashMap<String, String>();
        aMap.put("insurance_company", "Insurance Company");
        aMap.put("mrp", "MRP");
        aMap.put("enrollment_physician", "Enrollment Physician");
        aMap.put("logged_in_user", "Logged in user");
        aMap.put("family_doctor", "Family Doctor");
        aMap.put("referral_doctor", "Referral Doctor");
        aMap.put("patient", "Patient");
        DATABASE_FIELD_MAP = Collections.unmodifiableMap(aMap);
    }
    
    public static HcTypeBillToRemitToPreference getPreferenceForProvider(String loggedInProviderNo, Demographic billedDemographic) {
        UserPropertyDAO userPropertyDao = SpringUtils.getBean(UserPropertyDAO.class);
        ProfessionalSpecialistDao professionalSpecialistDao = SpringUtils.getBean(ProfessionalSpecialistDao.class);
        DemographicExtDao demographicExtDao = SpringUtils.getBean(DemographicExtDao.class);
        Billing3rdPartyAddressDao billing3rdPartyAddressDao = SpringUtils.getBean(Billing3rdPartyAddressDao.class);
        
        String billToText = null;
        String remitToText = null;
        
        if ("OT".equals(billedDemographic.getHcType())) {
            UserProperty defaultBillToProviderProperty = userPropertyDao.getProp(loggedInProviderNo, UserProperty.DEFAULT_BILL_TO_OTHER);
            if (defaultBillToProviderProperty != null) {
                if ("contact_list".equals(defaultBillToProviderProperty.getValue())) {
                    UserProperty billToOtherTextProp = userPropertyDao.getProp(loggedInProviderNo, UserProperty.BILL_TO_OTHER_TEXT);
                    if (billToOtherTextProp != null && !StringUtils.isNullOrEmpty(billToOtherTextProp.getValue())) {
                        billToText = billToOtherTextProp.getValue();
                    }
                    UserProperty remitToOtherTextProp = userPropertyDao.getProp(loggedInProviderNo, UserProperty.REMIT_TO_OTHER_TEXT);
                    if (billToOtherTextProp != null && !StringUtils.isNullOrEmpty(billToOtherTextProp.getValue())) {
                        remitToText = remitToOtherTextProp.getValue();
                    }
                } else if ("database_field".equals(defaultBillToProviderProperty.getValue())) {
                    
                    UserProperty billToOtherDatabaseFieldProp = userPropertyDao.getProp(loggedInProviderNo, UserProperty.BILL_TO_OTHER_DATABASE_FIELD);
                    if (billToOtherDatabaseFieldProp != null && billToOtherDatabaseFieldProp.getValue() != null) {
                        String selectedDbField =  billToOtherDatabaseFieldProp.getValue();
                        if ("insurance_company".equals(selectedDbField)) {
                            DemographicExt insuranceCompanyExt = demographicExtDao.getDemographicExt(billedDemographic.getDemographicNo(), "insurance_company");
                            if (insuranceCompanyExt != null && !StringUtils.isNullOrEmpty(insuranceCompanyExt.getValue()) && org.apache.commons.lang3.StringUtils.isNumeric(insuranceCompanyExt.getValue())) {
                                Billing3rdPartyAddress insuranceCompanyInfo = billing3rdPartyAddressDao.find(Integer.valueOf(insuranceCompanyExt.getValue()));
                                billToText = insuranceCompanyInfo.createContactString();
                            }
                        } else if ("mrp".equals(selectedDbField)) {
                            Provider mrp = billedDemographic.getProvider();
                            if (mrp != null) {
                                billToText = RxProviderData.createProviderContactString(new RxProviderData().convertProvider(mrp));
                            }
                        } else if ("enrollment_physician".equals(selectedDbField)) {
                            DemographicExt enrollmentProviderExt = demographicExtDao.getDemographicExt(billedDemographic.getDemographicNo(), "enrollmentProvider");
                            if (enrollmentProviderExt != null && !StringUtils.isNullOrEmpty(enrollmentProviderExt.getValue())) {
                                billToText = RxProviderData.createProviderContactString(new RxProviderData().getProvider(enrollmentProviderExt.getValue()));
                            }
                        } else if ("logged_in_user".equals(selectedDbField)) {
                            billToText = RxProviderData.createProviderContactString(new RxProviderData().getProvider(loggedInProviderNo));
                        } else if ("family_doctor".equals(selectedDbField)) {
                            Matcher fdOhipMatcher = Pattern.compile("<fdohip>(.*)</fdohip>.*").matcher(billedDemographic.getFamilyPhysician()); // family doctor
                            if (fdOhipMatcher.find()) {
                                String familyDoctorOhip = fdOhipMatcher.group(1);
                                ProfessionalSpecialist familyDoctor = professionalSpecialistDao.getByReferralNo(familyDoctorOhip);
                                if (familyDoctor != null) {
                                    billToText = familyDoctor.createContactString();
                                }
                            }
                        } else if ("referral_doctor".equals(selectedDbField)) {
                            String referralDoctorOhip = billedDemographic.getFamilyDoctorNumber(); // referral doctor
                            if (referralDoctorOhip != null) {
                                ProfessionalSpecialist referralDoctor = professionalSpecialistDao.getByReferralNo(referralDoctorOhip);
                                if (referralDoctor != null) {
                                    billToText = referralDoctor.createContactString();
                                }
                            }
                        } else if ("patient".equals(selectedDbField)) {
                            billToText = billedDemographic.getFirstName() + " " + billedDemographic.getLastName() + "\n"
                                    + billedDemographic.getAddress() + "\n"
                                    + billedDemographic.getCity() + ", " + billedDemographic.getProvince() + "\n"
                                    + billedDemographic.getPostal() + "\n"
                                    + "Tel: " + billedDemographic.getPhone();
                        }
                    }
                }
            }
        } else if ("QC".equals(billedDemographic.getHcType())) {
            UserProperty defaultBillToProviderProperty = userPropertyDao.getProp(loggedInProviderNo, UserProperty.DEFAULT_BILL_TO_QUEBEC);
            if (defaultBillToProviderProperty != null) {
                if ("contact_list".equals(defaultBillToProviderProperty.getValue())) {
                    UserProperty billToQuebecTextProp = userPropertyDao.getProp(loggedInProviderNo, UserProperty.BILL_TO_QUEBEC_TEXT);
                    if (billToQuebecTextProp != null && !StringUtils.isNullOrEmpty(billToQuebecTextProp.getValue())) {
                        billToText = billToQuebecTextProp.getValue();
                    }
                    UserProperty remitToQuebecTextProp = userPropertyDao.getProp(loggedInProviderNo, UserProperty.REMIT_TO_QUEBEC_TEXT);
                    if (remitToQuebecTextProp != null && !StringUtils.isNullOrEmpty(remitToQuebecTextProp.getValue())) {
                        remitToText = remitToQuebecTextProp.getValue();
                    }
                } else if ("database_field".equals(defaultBillToProviderProperty.getValue())) {

                    UserProperty billToQuebecDatabaseFieldProp = userPropertyDao.getProp(loggedInProviderNo, UserProperty.BILL_TO_QUEBEC_DATABASE_FIELD);
                    if (billToQuebecDatabaseFieldProp != null && billToQuebecDatabaseFieldProp.getValue() != null) {
                        String selectedDbField =  billToQuebecDatabaseFieldProp.getValue();
                        if ("insurance_company".equals(selectedDbField)) {
                            DemographicExt insuranceCompanyExt = demographicExtDao.getDemographicExt(billedDemographic.getDemographicNo(), "insurance_company");
                            if (insuranceCompanyExt != null && !StringUtils.isNullOrEmpty(insuranceCompanyExt.getValue()) && org.apache.commons.lang3.StringUtils.isNumeric(insuranceCompanyExt.getValue())) {
                                Billing3rdPartyAddress insuranceCompanyInfo = billing3rdPartyAddressDao.find(Integer.valueOf(insuranceCompanyExt.getValue()));
                                billToText = insuranceCompanyInfo.createContactString();
                            }
                        } else if ("mrp".equals(selectedDbField)) {
                            Provider mrp = billedDemographic.getProvider();
                            if (mrp != null) {
                                billToText = RxProviderData.createProviderContactString(new RxProviderData().convertProvider(mrp));
                            }
                        } else if ("enrollment_physician".equals(selectedDbField)) {
                            DemographicExt enrollmentProviderExt = demographicExtDao.getDemographicExt(billedDemographic.getDemographicNo(), "enrollmentProvider");
                            if (enrollmentProviderExt != null && !StringUtils.isNullOrEmpty(enrollmentProviderExt.getValue())) {
                                billToText = RxProviderData.createProviderContactString(new RxProviderData().getProvider(enrollmentProviderExt.getValue()));
                            }
                        } else if ("logged_in_user".equals(selectedDbField)) {
                            billToText = RxProviderData.createProviderContactString(new RxProviderData().getProvider(loggedInProviderNo));
                        } else if ("family_doctor".equals(selectedDbField)) {
                            Matcher fdOhipMatcher = Pattern.compile("<fdohip>(.*)</fdohip>.*").matcher(billedDemographic.getFamilyPhysician()); // family doctor
                            if (fdOhipMatcher.find()) {
                                String familyDoctorOhip = fdOhipMatcher.group(1);
                                ProfessionalSpecialist familyDoctor = professionalSpecialistDao.getByReferralNo(familyDoctorOhip);
                                if (familyDoctor != null) {
                                    billToText = familyDoctor.createContactString();
                                }
                            }
                        } else if ("referral_doctor".equals(selectedDbField)) {
                            String referralDoctorOhip = billedDemographic.getFamilyDoctorNumber(); // referral doctor
                            if (referralDoctorOhip != null) {
                                ProfessionalSpecialist referralDoctor = professionalSpecialistDao.getByReferralNo(referralDoctorOhip);
                                if (referralDoctor != null) {
                                    billToText = referralDoctor.createContactString();
                                }
                            }
                        } else if ("patient".equals(selectedDbField)) {
                            billToText = billedDemographic.getFirstName() + " " + billedDemographic.getLastName() + "\n"
                                    + billedDemographic.getAddress() + "\n"
                                    + billedDemographic.getCity() + ", " + billedDemographic.getProvince() + "\n"
                                    + billedDemographic.getPostal() + "\n"
                                    + "Tel: " + billedDemographic.getPhone();
                        }
                    }
                }
            }
        }
        return new HcTypeBillToRemitToPreference(billToText, remitToText);
    }
}
