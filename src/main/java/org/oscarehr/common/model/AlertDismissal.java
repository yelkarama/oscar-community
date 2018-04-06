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


package org.oscarehr.common.model;

import javax.persistence.Column;
import javax.persistence.EmbeddedId;
import javax.persistence.Entity;
import javax.persistence.Table;
import java.util.Date;

@Entity
@Table(name="alert_dismissal")
public class AlertDismissal extends AbstractModel<AlertDismissalPK>{
    
    @EmbeddedId
    private AlertDismissalPK id;
	
    @Column(name="dismiss_date")
    private Date dismissDate;

    public AlertDismissal() {}
    public AlertDismissal(Integer id, String providerNo) {
        this.id = new AlertDismissalPK(id, providerNo);
        this.dismissDate = new Date();
    }

    @Override
    public AlertDismissalPK getId() {
        return id;
    }
    public void setId(AlertDismissalPK id) {
        this.id = id;
    }

    public String getProviderNo() {
        return getId().getProviderNo();
    }
    public Integer getAlertId() {
        return getId().getAlertId();
    }

    public Date getDismissDate() {
        return dismissDate;
    }
    public void setDismissDate(Date dismissDate) {
        this.dismissDate = dismissDate;
    }
}
