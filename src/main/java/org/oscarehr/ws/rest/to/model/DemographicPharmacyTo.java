package org.oscarehr.ws.rest.to.model;

import java.util.Date;


public class DemographicPharmacyTo {
	private Integer id;
	private int pharmacyId;
	private int demographicNo;
	private String status;
	private int preferredOrder;
	private Date addDate;
	public Integer getId() {
		return id;
	}
	public void setId(Integer id) {
		this.id = id;
	}
	public int getPharmacyId() {
		return pharmacyId;
	}
	public void setPharmacyId(int pharmacyId) {
		this.pharmacyId = pharmacyId;
	}
	public int getDemographicNo() {
		return demographicNo;
	}
	public void setDemographicNo(int demographicNo) {
		this.demographicNo = demographicNo;
	}
	public String getStatus() {
		return status;
	}
	public void setStatus(String status) {
		this.status = status;
	}
	public int getPreferredOrder() {
		return preferredOrder;
	}
	public void setPreferredOrder(int preferredOrder) {
		this.preferredOrder = preferredOrder;
	}
	public Date getAddDate() {
		return addDate;
	}
	public void setAddDate(Date addDate) {
		this.addDate = addDate;
	}
}
