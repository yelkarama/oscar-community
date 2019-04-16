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

/*
 * Written by Brandon Aubie <brandon@aubie.ca>
 */

package org.oscarehr.ws.oauth.util;


import java.util.Collection;
import java.util.Collections;
import java.util.List;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;

import org.apache.cxf.interceptor.Fault;
import org.apache.cxf.message.Message;
import org.apache.cxf.phase.PhaseInterceptor;
import org.apache.cxf.phase.Phase;
import org.apache.cxf.rs.security.oauth.filters.OAuthRequestFilter;
import org.apache.cxf.rs.security.oauth.data.OAuthContext;
import org.apache.cxf.transport.http.AbstractHTTPDestination;

import org.oscarehr.common.dao.FacilityDao;
import org.oscarehr.common.model.Facility;
import org.springframework.beans.factory.annotation.Autowired;

import org.oscarehr.util.LoggedInInfo;
import org.oscarehr.common.model.Provider;
import org.oscarehr.PMmodule.dao.ProviderDao;
import oscar.log.LogAction;
import oscar.log.LogConst;


public class OAuthInterceptor extends OAuthRequestFilter implements PhaseInterceptor<Message> {

	@Autowired
	protected ProviderDao providerDao;
	@Autowired
    private FacilityDao facilityDao;

	@Override
	public void handleMessage(Message message) throws Fault {
        HttpServletRequest request = (HttpServletRequest)message.get(AbstractHTTPDestination.HTTP_REQUEST);
        /* 
         * Setup a LoggedInInfo and throw it onto the Request for use elsewhere. 
         * All we have is a providerNo so we access the ProviderDao directly.
         * There (likely) may be a better way to do this.
         *
         */

        // Obtain the OAuthContext and the login (which in OSCAR is the providerNo)
		OAuthContext oc = message.getContent(OAuthContext.class);
		
		if(oc == null) {
			return;
		}
        String providerNo = oc.getSubject().getLogin();

        // Create a new provider directly from the Dao with the providerNo.
        // We can trust this number as it was authenticated from OAuth.
        Provider provider = providerDao.getProvider(providerNo);
        // Gets the current facility, returns null if there isn't one
        Facility facility = getFacility(providerNo, request.getRemoteAddr());

        // Create a new LoggedInInfo
        LoggedInInfo loggedInInfo = new LoggedInInfo();
        loggedInInfo.setLoggedInProvider(provider);
        loggedInInfo.setCurrentFacility(facility);
        
        /* NOTE:
         * A LoggedInInfo object from OAuth will NOT have the following:
         * - session (no active session -- OAuth requests are stateless)
         * - loggedInSecurity (the logged in user is OAuth, so no actual username/password security)
         * - initiatingCode (this could change, I'm not sure what it's for)
         * - locale (this could change, I'm not sure what it's for)
         */

        // Throw our new loggedInInfo onto the request for future use.
        request.setAttribute(new LoggedInInfo().LOGGED_IN_INFO_KEY, loggedInInfo);

        return;
    }


    public Collection<PhaseInterceptor<? extends Message>> getAdditionalInterceptors() {
        return null;
    }

    public Set<String> getAfter() {
        return Collections.emptySet();
    }

    public Set<String> getBefore() {
        return Collections.emptySet();
    }

    public String getId() {
        return getClass().getName();
    }

    public String getPhase() {
        return Phase.PRE_INVOKE;
    }

    public void handleFault(Message message) {
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
