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

import javax.persistence.Column;
import javax.persistence.EnumType;
import javax.persistence.Enumerated;
import java.io.Serializable;

public class CaseManagementDxLinkPK implements Serializable {

    @Column(name = "note_id")
    private Long noteId;
    @Column(name = "dx_type")
    @Enumerated(EnumType.STRING)
    private CaseManagementDxLink.DxType dxType;
    @Column(name = "dx_code")
    private String dxCode;
    
    public CaseManagementDxLinkPK() { }
    public CaseManagementDxLinkPK(Long noteId, CaseManagementDxLink.DxType dxType, String dxCode) {
        this.noteId = noteId;
        this.dxType = dxType;
        this.dxCode = dxCode;
    }

    public Long getNoteId() {
        return noteId;
    }
    public void setNoteId(Long noteId) {
        this.noteId = noteId;
    }

    public CaseManagementDxLink.DxType getDxType() {
        return dxType;
    }
    public void setDxType(CaseManagementDxLink.DxType dxType) {
        this.dxType = dxType;
    }

    public String getDxCode() {
        return dxCode;
    }
    public void setDxCode(String dxCode) {
        this.dxCode = dxCode;
    }
}
