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
import org.oscarehr.common.dao.DemographicDao;
import org.oscarehr.common.dao.RelationshipsDao;
import org.oscarehr.common.model.Demographic;
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

	public boolean getInfo(EctSessionBean bean, HttpServletRequest request, NavBarDisplayDAO displayDAO, MessageResources messages) {
		LoggedInInfo loggedInInfo=LoggedInInfo.getLoggedInInfoFromSession(request);
        OscarProperties oscarProperties = OscarProperties.getInstance();
		
    	if (!securityInfoManager.hasPrivilege(loggedInInfo, "_edoc", "r", null)) {
    		return true; // documents link won't show up on new CME screen.
    	}

        String demographicNo = bean.getDemographicNo();
        String providerNo = LoggedInInfo.getLoggedInInfoFromSession(request).getLoggedInProviderNo();

        if (demographicNo != null && !demographicNo.isEmpty()) {
            RelationshipsDao relationshipsDao = SpringUtils.getBean(RelationshipsDao.class);
            DemographicDao demographicDao = SpringUtils.getBean(DemographicDao.class);
            if (displayDAO == null) {
                displayDAO = new NavBarDisplayDAO();
            }

            String headingColour = "#FF9933";
            String winName;
            Integer hash;
            String url = "return false;";
//            displayDAO.setRightURL(url);
//            displayDAO.setLeftURL(url);
            displayDAO.setLeftHeading(messages.getMessage(request.getLocale(), "oscarEncounter.LeftNavBar.Relations"));
            displayDAO.setRightHeadingID("blank"); // no menu so set div id to unique id for this action
//            request.setAttribute("DAO", displayDAO);
            List<Relationships> relationships = relationshipsDao.findByDemographicNumber(Integer.parseInt(demographicNo));
            for (Relationships relationship : relationships) {
                Demographic demographic = demographicDao.getDemographic(String.valueOf(relationship.getRelationDemographicNo()));
                if (demographic != null) {
                    NavBarDisplayDAO.Item item = NavBarDisplayDAO.Item();
                    winName = relationship.getRelation() + ": " + demographic.getLastName() + ", " + demographic.getFirstName();
                    hash = Math.abs(winName.hashCode());
                    url = "popupPage(700,1000,'" + hash + "','" + request.getContextPath() + "/oscarEncounter/IncomingEncounter.do?providerNo=" + providerNo + "&demographicNo=" + demographic.getDemographicNo() + "&reason=Tel-Progress+Note&encType=&curDate=2018-3-15');return false;";
                    item.setTitle(winName);
                    item.setLinkTitle(winName);
                    item.setURL(url);
                    displayDAO.addItem(item);
                }
            }
            return true;
        } else {
            return false;
        }
    }

	public String getCmd() {
		return cmd;
	}
}
