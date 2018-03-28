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

package oscar.oscarEncounter.pageUtil;

import org.apache.log4j.Logger;
import org.apache.struts.util.MessageResources;
import org.oscarehr.common.dao.DemographicContactDao;
import org.oscarehr.common.dao.DemographicDao;
import org.oscarehr.common.dao.RelationshipsDao;
import org.oscarehr.common.model.Demographic;
import org.oscarehr.common.model.DemographicContact;
import org.oscarehr.common.model.Relationships;
import org.oscarehr.util.LoggedInInfo;
import org.oscarehr.util.MiscUtils;
import org.oscarehr.util.SpringUtils;
import oscar.OscarProperties;

import javax.servlet.http.HttpServletRequest;
import java.util.List;

public class EctDisplayRelationsAction extends EctDisplayAction {
	private static Logger logger = MiscUtils.getLogger();

	private static final String cmd = "Relations";
    private String contextPath;

	public boolean getInfo(EctSessionBean bean, HttpServletRequest request, NavBarDisplayDAO displayDAO, MessageResources messages) {
		LoggedInInfo loggedInInfo=LoggedInInfo.getLoggedInInfoFromSession(request);
        OscarProperties oscarProperties = OscarProperties.getInstance();
		
    	if (!securityInfoManager.hasPrivilege(loggedInInfo, "_edoc", "r", null)) {
    		return true;
    	}

    	contextPath = request.getContextPath();
        String demographicNo = bean.getDemographicNo();
        String providerNo = LoggedInInfo.getLoggedInInfoFromSession(request).getLoggedInProviderNo();

        if (demographicNo != null && !demographicNo.isEmpty()) {
            if (displayDAO == null) {
                displayDAO = new NavBarDisplayDAO();
            }

            displayDAO.setLeftHeading(messages.getMessage(request.getLocale(), "oscarEncounter.LeftNavBar.Relations"));
            displayDAO.setRightHeadingID("blank"); // no menu so set div id to unique id for this action
            if (oscarProperties.isPropertyActive("NEW_CONTACTS_UI")) {
                addDemographicContactsEntries(displayDAO, demographicNo, providerNo);
            } else {
                addRelationshipsEntries(displayDAO, demographicNo, providerNo);
            }
            return true;
        } else {
            return false;
        }
    }

	public String getCmd() {
		return cmd;
	}
	
    private void addRelationshipsEntries(NavBarDisplayDAO displayDAO, String demographicNo, String providerNo) {
        RelationshipsDao relationshipsDao = SpringUtils.getBean(RelationshipsDao.class);
        DemographicDao demographicDao = SpringUtils.getBean(DemographicDao.class);
        String winName;
        Integer hash;
	    
        List<Relationships> relationships = relationshipsDao.findByDemographicNumber(Integer.parseInt(demographicNo));
        for (Relationships relationship : relationships) {
            Demographic demographic = demographicDao.getDemographic(String.valueOf(relationship.getRelationDemographicNo()));
            if (demographic != null) {
                NavBarDisplayDAO.Item item = NavBarDisplayDAO.Item();
                winName = relationship.getRelation() + ": " + demographic.getLastName() + ", " + demographic.getFirstName();
                item.setTitle(winName);
                item.setLinkTitle(winName);
                hash = Math.abs(winName.hashCode());
                // Use 'popperup()' as opposed to 'popupPage()' to prevent reload links from being added
                String url = "popperup(700,1000,'" + contextPath + "/oscarEncounter/IncomingEncounter.do?providerNo=" + providerNo + "&demographicNo=" + demographic.getDemographicNo() + "&reason=Tel-Progress+Note&encType=&curDate=2018-3-15','" + hash + "');return false;";
                item.setURL(url);
                displayDAO.addItem(item);
            }
        }
    }

    private void addDemographicContactsEntries(NavBarDisplayDAO displayDAO, String demographicNo, String providerNo) {
        DemographicContactDao demographicContactDao = SpringUtils.getBean(DemographicContactDao.class);
        DemographicDao demographicDao = SpringUtils.getBean(DemographicDao.class);
        String winName;
        Integer hash;

        List<DemographicContact> relationships =
                demographicContactDao.findActiveByDemographicNoAndCategoryAndType(Integer.parseInt(demographicNo),
                        DemographicContact.CATEGORY_PERSONAL, DemographicContact.TYPE_DEMOGRAPHIC);
        for (DemographicContact relationship : relationships) {
            Demographic demographic = demographicDao.getDemographic(String.valueOf(relationship.getContactId()));
            if (demographic != null) {
                NavBarDisplayDAO.Item item = NavBarDisplayDAO.Item();
                winName = relationship.getRole() + ": " + demographic.getLastName() + ", " + demographic.getFirstName();
                item.setTitle(winName);
                item.setLinkTitle(winName);
                hash = Math.abs(winName.hashCode());
                // Use 'popperup()' as opposed to 'popupPage()' to prevent reload links from being added
                String url = "popperup(700,1000,'" + contextPath + "/oscarEncounter/IncomingEncounter.do?providerNo=" + providerNo + "&demographicNo=" + demographic.getDemographicNo() + "&reason=Tel-Progress+Note&encType=&curDate=2018-3-15','" + hash + "');return false;";
                item.setURL(url);
                displayDAO.addItem(item);
            }
        }
    }
}
