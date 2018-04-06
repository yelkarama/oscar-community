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

import org.apache.commons.lang.StringUtils;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.EnumType;
import javax.persistence.Enumerated;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.Table;
import java.util.Date;

@Entity
@Table(name="alert")
public class Alert extends AbstractModel<Integer> {
    
    public enum AlertType {
        // ADD NEW TYPES TO END OF LIST, OR ELSE STORED ORDINAL VALUES WILL BE SHIFTED
        ADMIN, CHART
    }

    public Alert() {}
    public Alert(Integer demographicNo, AlertType type, String message) {
        this.demographicNo = demographicNo;
        this.type = type;
        this.enabled = true;
        this.message = message;
        this.date = new Date();
    }
    public Alert(Integer demographicNo, AlertType type, Boolean enabled, String message) {
        this.demographicNo = demographicNo;
        this.type = type;
        this.enabled = enabled;
        this.message = message;
        this.date = new Date();
    }

    @Id
	@Column(name = "id")
    @GeneratedValue(strategy=GenerationType.AUTO)
	private Integer id;

	@Column(name = "demographic_no")
	private Integer demographicNo;

    @Enumerated(EnumType.ORDINAL)
    @Column(name = "type")
    private AlertType type;

    @Column(name = "enabled")
    private Boolean enabled;

	@Column(name = "message")
	private String message;
	
	@Column(name = "date")
	private Date date;

    @Override
    public Integer getId() {
        return id;
    }
    public void setId(Integer id) {
        this.id = id;
    }

    public Integer getDemographicNo() {
        return demographicNo;
    }
    public void setDemographicNo(Integer demographicNo) {
        this.demographicNo = demographicNo;
    }
    
    public AlertType getType() {
        return type;
    }
    public void setType(AlertType type) {
        this.type = type;
    }

    public Boolean getEnabled() {
        return enabled;
    }
    public void setEnabled(Boolean enabled) {
        this.enabled = enabled;
    }

    public String getMessage() {
        return message;
    }
    public void setMessage(String message) {
        this.message = message;
    }
    
    public Date getDate() {
        return date;
    }
    public void setDate(Date date) {
        this.date = date;
    }
    
    public String getAlertTitle() {
        return StringUtils.capitalize(type.name().toLowerCase());
    }
}
