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

package org.oscarehr.casemgmt.model;

import org.oscarehr.common.model.AbstractModel;

import javax.persistence.Column;
import javax.persistence.EmbeddedId;
import javax.persistence.Entity;
import javax.persistence.Table;
import java.io.Serializable;
import java.util.Date;

@Entity
@Table(name = "casemgmt_dx_link")
public class CaseManagementDxLink extends AbstractModel<CaseManagementDxLinkPK> implements Serializable {
    
    public enum DxType {
        ICD9, SNOMED_CT, ENCODE_FM
    }

    @EmbeddedId
    private CaseManagementDxLinkPK id;
    @Column(name = "update_date")
    private Date updateDate;

    public CaseManagementDxLink() { }
    public CaseManagementDxLink(Long noteId, CaseManagementDxLink.DxType dxType, String dxCode, Date updateDate) {
        this.id = new CaseManagementDxLinkPK(noteId, dxType, dxCode);
        this.updateDate = updateDate;
    }

    @Override
    public CaseManagementDxLinkPK getId() {
        return id;
    }
    public void setId(CaseManagementDxLinkPK id) {
        this.id = id;
    }

    public Date getUpdateDate() {
        return updateDate;
    }
    public void setUpdateDate(Date updateDate) {
        this.updateDate = updateDate;
    }
}
