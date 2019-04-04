package org.oscarehr.managers;

import com.google.common.base.Joiner;
import com.quatro.model.security.Secuserrole;
import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;
import org.oscarehr.PMmodule.dao.ProviderDao;
import org.oscarehr.common.dao.FacilityDao;
import org.oscarehr.common.dao.SecurityDao;
import org.oscarehr.common.dao.SystemPreferencesDao;
import org.oscarehr.common.model.Facility;
import org.oscarehr.common.model.Provider;
import org.oscarehr.common.model.Security;
import org.oscarehr.common.model.SystemPreferences;
import org.oscarehr.util.LoggedInInfo;
import org.oscarehr.util.MiscUtils;
import org.oscarehr.util.SessionConstants;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import oscar.log.LogAction;
import oscar.log.LogConst;

import javax.servlet.ServletRequest;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import java.lang.reflect.Array;
import java.util.List;
import java.util.StringJoiner;

@Service
public class AuthenticationManager {
    @Autowired
    private SystemPreferencesDao systemPreferencesDao;
    @Autowired
    private ProviderDao providerDao;
    @Autowired
    private FacilityDao facilityDao;
    @Autowired
    private SecurityInfoManager securityInfoManager;
    @Autowired
    private SecurityDao securityDao;
    
    private Logger logger = MiscUtils.getLogger();
    
    public boolean setUpPatientIntake(HttpServletRequest request) {
        boolean isPatientIntakeSetUp = false;
        SystemPreferences intakePreference = systemPreferencesDao.findPreferenceByName("patient_intake_provider");
        
        if (intakePreference != null && StringUtils.isNotEmpty(intakePreference.getValue())) {
            // Create a new provider directly from the Dao with the providerNo.
            // We can trust this number as it was authenticated from OAuth.
            Provider provider = providerDao.getProvider(intakePreference.getValue());
            if (provider != null) {
                LoggedInInfo loggedInInfo = generateLoggedInInfo(request, provider);
                HttpSession session = request.getSession();
                
                List<Secuserrole> userRoles = securityInfoManager.getRoles(loggedInInfo);
                
                if (!userRoles.isEmpty()) {
                    StringBuilder roles = new StringBuilder();
                    for (Secuserrole role : userRoles) {
                        if(roles.length() > 0) {
                            roles.append(",");
                        }
                        roles.append(role.getFullName());
                    }

                    session.setAttribute("userrole", roles.toString());
                    session.setAttribute("user", provider.getProviderNo());
                    session.setAttribute("userfirstname", provider.getFirstName());
                    session.setAttribute("userlastname", provider.getLastName());
                    session.setAttribute(SessionConstants.LOGGED_IN_PROVIDER, provider);
                    session.setAttribute(SessionConstants.LOGGED_IN_SECURITY, loggedInInfo.getLoggedInSecurity());
                    LoggedInInfo.setLoggedInInfoIntoSession(session, loggedInInfo);

                    isPatientIntakeSetUp = true;
                }
            }
        }
        
        return isPatientIntakeSetUp;
    }

    
    private LoggedInInfo generateLoggedInInfo(HttpServletRequest request, Provider provider) {
        LoggedInInfo loggedInInfo = null;
        Security security = securityDao.getByProviderNo(provider.getProviderNo());
        // Must have a login record in order to proceed
        if (security != null) {
            // Gets the current facility, returns null if there isn't one
            Facility facility = getFacility(provider.getProviderNo(), request.getRemoteAddr());
            
            // Create a new LoggedInInfo
            loggedInInfo = new LoggedInInfo();
            loggedInInfo.setLoggedInProvider(provider);
            loggedInInfo.setCurrentFacility(facility);
            loggedInInfo.setLoggedInSecurity(security);
        } else {
            logger.warn("Could not retrieve security record for provider " + provider.getProviderNo());
        }

        // Throw our new loggedInInfo onto the request for future use.
        return loggedInInfo;
    }

    /**
     * Gets the current facility for the provider
     * @param providerNo The provider number that the facility is for
     * @param requestIp The requesting ip, used for logging
     * @return The current facility for the provider, null if there is no facility
     */
    private Facility getFacility(String providerNo, String requestIp) {
        Facility facility = null;
        List<Integer> facilityIds = providerDao.getFacilityIds(providerNo);
        if (facilityIds.size() == 1) {
            // set current facility
            facility = facilityDao.find(facilityIds.get(0));
            LogAction.addLog(providerNo, LogConst.OAUTH_LOGIN, LogConst.CON_OAUTH_LOGIN, "facilityId=" + facilityIds.get(0), requestIp);
        } else {
            List<Facility> facilities = facilityDao.findAll(true);
            if(facilities!=null && facilities.size()>=1) {
                Facility fac = facilities.get(0);
                int first_id = fac.getId();
                ProviderDao.addProviderToFacility(providerNo, first_id);
                facility = facilityDao.find(first_id);
                LogAction.addLog(providerNo, LogConst.OAUTH_LOGIN, LogConst.CON_OAUTH_LOGIN, "facilityId=" + first_id, requestIp);
            }
        }

        return facility;
    }
}
