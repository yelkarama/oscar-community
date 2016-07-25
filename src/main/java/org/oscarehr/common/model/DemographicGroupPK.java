/**
 * Copyright 2015 Trimara Corporation
 */

package org.oscarehr.common.model;

import javax.persistence.Column;

public class DemographicGroupPK implements java.io.Serializable {

	@Column(name="demographic_no")
	private int demographicNo;
	
	@Column(name="demographic_group_id")
	private int demographicGroupId;

	public DemographicGroupPK() {
	}

	public DemographicGroupPK(int demographicNo, int demographicGroupId) {
		this.demographicNo = demographicNo;
		this.demographicGroupId = demographicGroupId;
	}

	public int getDemographicNo() {
    	return demographicNo;
    }

	public void setDemographicNo(int demographicNo) {
    	this.demographicNo = demographicNo;
    }

	public int getDemographicGroupId() {
    	return demographicGroupId;
    }

	public void setDemographicGroupId(int demographicGroupId) {
    	this.demographicGroupId = demographicGroupId;
    }


	public String toString() {
		return ("DemographicNo=" + demographicNo + ", demographicGroupId=" + demographicGroupId);
	}

	@Override
	public int hashCode() {
		return (toString().hashCode());
	}

	@Override
	public boolean equals(Object o) {
		try {
			DemographicGroupPK o1 = (DemographicGroupPK) o;

			return ((demographicNo == o1.demographicNo) && (demographicGroupId == o1.demographicGroupId));
		} catch (RuntimeException e) {
			return (false);
		}
	}
}
