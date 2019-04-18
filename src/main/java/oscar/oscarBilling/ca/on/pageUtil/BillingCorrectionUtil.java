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

import org.oscarehr.common.dao.BillingONRepoDao;
import org.oscarehr.common.model.BillingONItem;
import org.oscarehr.util.SpringUtils;

import java.math.BigDecimal;
import java.util.Date;
import java.util.Locale;

public class BillingCorrectionUtil {
    
    public static BillingONItem processUpdatedBillingItem(BillingONItem existingBillingItem, BillingONItem newMatchedBillingItem, Date serviceDate, Locale locale) {
        boolean statusChanged = false;
        if ((!existingBillingItem.getStatus().equals("S") && newMatchedBillingItem.getStatus().equals("S"))
                ||(existingBillingItem.getStatus().equals("S") && !newMatchedBillingItem.getStatus().equals("S"))) {
            statusChanged = true;
        }

        String fee = newMatchedBillingItem.getFee();
        String unit = newMatchedBillingItem.getServiceCount();

        if (!existingBillingItem.getServiceCount().equals(unit)
                || !existingBillingItem.getFee().equals(fee)
                || !existingBillingItem.getDx().equals(newMatchedBillingItem.getDx())
                || (existingBillingItem.getServiceDate().compareTo(serviceDate) != 0)
                || statusChanged) {

            BillingONRepoDao billRepoDao = (BillingONRepoDao) SpringUtils.getBean("billingONRepoDao");
            billRepoDao.createBillingONItemEntry(existingBillingItem, locale);
        }
        
        if (!fee.equals("defunct") && !existingBillingItem.getServiceCount().equals(unit)) {
            BigDecimal feeAmt = new BigDecimal(fee);
            BigDecimal unitAmt = new BigDecimal(unit);
            feeAmt = feeAmt.multiply(unitAmt).setScale(2, BigDecimal.ROUND_HALF_UP);
            fee = feeAmt.toPlainString();
        }

        existingBillingItem.setServiceCount(unit);
        existingBillingItem.setFee(fee);
        existingBillingItem.setServiceDate(newMatchedBillingItem.getServiceDate());
        existingBillingItem.setDx(newMatchedBillingItem.getDx());
        existingBillingItem.setStatus(newMatchedBillingItem.getStatus());
        return existingBillingItem;
    }
}
  