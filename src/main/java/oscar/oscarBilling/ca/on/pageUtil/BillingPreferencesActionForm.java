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

import java.util.List;

import javax.servlet.http.HttpServletRequest;
import org.oscarehr.util.SpringUtils;

import org.oscarehr.common.model.CtlBillingService;
import org.oscarehr.common.dao.CtlBillingServiceDao;

import org.apache.struts.action.ActionErrors;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionMapping;

public class BillingPreferencesActionForm extends ActionForm {
  private CtlBillingServiceDao ctlBillingServiceDao = SpringUtils.getBean(CtlBillingServiceDao.class);
  private String default_servicetype;
  private List<CtlBillingService> ctlBillingServices = ctlBillingServiceDao.getServiceTypeListByStatus("A");
  
  public String getDefault_servicetype() {
    return default_servicetype;
  }

  public void setDefault_servicetype(String default_servicetype) {
    this.default_servicetype = default_servicetype;
  }

  public List<CtlBillingService> getCtlBillingServices(){
	return ctlBillingServices;
  }
  
  public void setCtlBillingServices(List<CtlBillingService> ctlBillingServices){
	this.ctlBillingServices = ctlBillingServices;
  }
  
  public ActionErrors validate(ActionMapping actionMapping,
                               HttpServletRequest httpServletRequest) {
      /** @todo: finish this method, this is just the skeleton.*/
    return null;
  }

 
}
