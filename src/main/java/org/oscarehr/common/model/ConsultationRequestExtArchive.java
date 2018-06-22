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
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.Table;
import java.io.Serializable;
import java.util.Date;

@Entity
@Table(name = "consultation_requests_ext_archive")
public class ConsultationRequestExtArchive extends AbstractModel<Integer> implements Serializable {

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)		
	private Integer id;
	
	@Column(name = "archive_id")
	private Integer archiveId;
	
	@Column(name = "archive_timestamp")
	private Date archiveTimestamp;
	
	@Column(name = "request_id")
	private Integer requestId;
	
	@Column(name = "name")
	private String name;
	
	@Column(name = "value")
	private String value;
	
	@Column(name = "date_created")
	private Date dateCreated;

	public ConsultationRequestExtArchive() {}
	public ConsultationRequestExtArchive(Integer archiveId, ConsultationRequestExt other) {
		this.archiveId = archiveId;
		this.archiveTimestamp = new Date();
		this.requestId = other.getRequestId();
		this.name = other.getKey();
		this.value = other.getValue();
		this.dateCreated = other.getDateCreated();
	}

	@Override
	public Integer getId() {
		return (id);
	}

	public Integer getArchiveId() {
		return archiveId;
	}
	public void setArchiveId(Integer archiveId) {
		this.archiveId = archiveId;
	}

	public Date getArchiveTimestamp() {
		return archiveTimestamp;
	}
	public void setArchiveTimestamp(Date archiveTimestamp) {
		this.archiveTimestamp = archiveTimestamp;
	}

	public Integer getRequestId() {
		return requestId;
	}
	public void setRequestId(Integer requestId) {
		this.requestId = requestId;
	}

	public String getName() {
		return name;
	}
	public void setName(String name) {
		this.name = name;
	}

	public String getValue() {
		return value;
	}
	public void setValue(String value) {
		this.value = value;
	}

	public Date getDateCreated() {
		return dateCreated;
	}
	public void setDateCreated(Date dateCreated) {
		this.dateCreated = dateCreated;
	}
}
