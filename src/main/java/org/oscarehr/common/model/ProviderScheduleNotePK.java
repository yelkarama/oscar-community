/**
 *
 * Copyright (c) 2005-2012. Centre for Research on Inner City Health, St. Michael's Hospital, Toronto. All Rights Reserved.
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
 * This software was written for
 * Centre for Research on Inner City Health, St. Michael's Hospital,
 * Toronto, Ontario, Canada
 */


package org.oscarehr.common.model;

import javax.persistence.Column;
import java.io.Serializable;
import java.text.SimpleDateFormat;
import java.util.Date;

public class ProviderScheduleNotePK implements Serializable {

    @Column(name="provider_no")
    private String providerNo;
    @Column(name="date")
    private Date date;

    public ProviderScheduleNotePK() {}
    public ProviderScheduleNotePK(String providerNo, Date date) {
        this.providerNo = providerNo;
        this.date = date;
    }

    public String getProviderNo() {
        return providerNo;
    }
    public void setProviderNo(String providerNo) {
        this.providerNo = providerNo;
    }

    public Date getDate() {
        return date;
    }
    public void setDate(Date date) {
        this.date = date;
    }

    public String toString() {
        SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
        return ("ProviderNo=" + this.providerNo + ", date=" + dateFormat.format(this.date));
    }

    @Override
    public int hashCode() {
        return (toString().hashCode());
    }

    @Override
    public boolean equals(Object o) {
        if (o == null || !(o instanceof ProviderScheduleNotePK)) {
            return false;
        }
        SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
        ProviderScheduleNotePK that = (ProviderScheduleNotePK) o;
        return  (this.getProviderNo().equals(that.getProviderNo()) 
                && dateFormat.format(this.getDate()).equals(dateFormat.format(that.getDate())));
    }
}
