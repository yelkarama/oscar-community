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
import javax.persistence.EmbeddedId;
import javax.persistence.Entity;
import javax.persistence.Table;
import java.io.Serializable;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;

@Entity
@Table(name="provider_schedule_note")
public class ProviderScheduleNote extends AbstractModel<ProviderScheduleNotePK> implements Serializable {

    @EmbeddedId
    private ProviderScheduleNotePK id;
    
    @Column(name = "note")
	private String note;

    public ProviderScheduleNote() {}
    public ProviderScheduleNote(String providerNo, Date date, String note) {
        this.id = new ProviderScheduleNotePK(providerNo, date);
        this.note = note;
    }
    public ProviderScheduleNote(String providerNo, String dateString, String note) throws ParseException {
        this(providerNo, new SimpleDateFormat("yyyy-MM-dd").parse(dateString), note);
    }

    @Override
    public ProviderScheduleNotePK getId() {
        return id;
    }
    public void setId(ProviderScheduleNotePK id) {
        this.id = id;
    }

    public String getNote() {
        return note;
    }
    public void setNote(String note) {
        this.note = note;
    }
}
