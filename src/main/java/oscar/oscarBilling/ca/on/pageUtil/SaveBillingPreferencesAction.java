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

package oscar.oscarBilling.ca.on.pageUtil;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.struts.action.Action;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import org.oscarehr.util.SpringUtils;
import org.oscarehr.util.LoggedInInfo;

import org.oscarehr.common.dao.BillingPermissionDao;
import org.oscarehr.common.model.Provider;
import org.oscarehr.PMmodule.dao.ProviderDao;
import org.oscarehr.common.model.ProviderPreference;
import org.oscarehr.common.dao.ProviderPreferenceDao;

import org.oscarehr.util.MiscUtils;
import org.oscarehr.web.admin.ProviderPreferencesUIBean;

/**
 * Saves the values in the ActionForm into the BillingPreferences record
 * @version 1.0
 */
public class SaveBillingPreferencesAction extends Action {
  public ActionForward execute(ActionMapping actionMapping, ActionForm actionForm, HttpServletRequest request, HttpServletResponse response) {
	BillingPreferencesActionForm frm = (BillingPreferencesActionForm) actionForm;
	LoggedInInfo loggedInInfo = LoggedInInfo.getLoggedInInfoFromSession(request);
	
    BillingPermissionDao dao = SpringUtils.getBean(BillingPermissionDao.class);
	ProviderDao providerDao = SpringUtils.getBean(ProviderDao.class);
	ProviderPreferenceDao providerPreferenceDao = SpringUtils.getBean(ProviderPreferenceDao.class);
	
	ProviderPreference providerPreference=ProviderPreferencesUIBean.getProviderPreference(loggedInInfo.getLoggedInProviderNo());
	
	providerPreference.setDefaultServiceType(frm.getDefault_servicetype());
	providerPreferenceDao.merge(providerPreference);
	
	String[] viewerNos = request.getParameterValues("viewerNo");
	String[] permissionNos = request.getParameterValues("permissionNo");
	String[] permissions = request.getParameterValues("permission");
	
	for(int i=0; i < viewerNos.length; i++){
		boolean allow = permissions[i].equals("true");
		dao.setPermission(loggedInInfo.getLoggedInProviderNo(), viewerNos[i], permissionNos[i], allow);
	}
	
    request.setAttribute("successMsg",true);
    return actionMapping.findForward("success");

  }
}
