/**
 * Copyright 2015 Trimara Corporation
 */

package org.oscarehr.common.model;

import javax.persistence.EmbeddedId;
import javax.persistence.Entity;
import javax.persistence.Table;

@Entity
@Table(name="demographic_group_link")
public class DemographicGroupLink extends AbstractModel<DemographicGroupPK> {

	@EmbeddedId
	private DemographicGroupPK id;

	public DemographicGroupPK getId() {
    	return id;
    }

	public void setId(DemographicGroupPK id) {
    	this.id = id;
    }
}