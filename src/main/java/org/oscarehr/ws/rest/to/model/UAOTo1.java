package org.oscarehr.ws.rest.to.model;

public class UAOTo1 {
	private Integer id;
	private String providerNo;
	private String friendlyName;
	private String name;
	private Boolean defaultUAO;
	private Boolean active;
	private String addedBy;
	
	public Integer getId() {
		return id;
	}
	public void setId(Integer id) {
		this.id = id;
	}
	public String getProviderNo() {
		return providerNo;
	}
	public void setProviderNo(String providerNo) {
		this.providerNo = providerNo;
	}
	public String getFriendlyName() {
		return friendlyName;
	}
	public void setFriendlyName(String friendlyName) {
		this.friendlyName = friendlyName;
	}
	public String getName() {
		return name;
	}
	public void setName(String name) {
		this.name = name;
	}
	public Boolean getDefaultUAO() {
		return defaultUAO;
	}
	public void setDefaultUAO(Boolean defaultUAO) {
		this.defaultUAO = defaultUAO;
	}
	public Boolean getActive() {
		return active;
	}
	public void setActive(Boolean active) {
		this.active = active;
	}
	public String getAddedBy() {
		return addedBy;
	}
	public void setAddedBy(String addedBy) {
		this.addedBy = addedBy;
	}
}
