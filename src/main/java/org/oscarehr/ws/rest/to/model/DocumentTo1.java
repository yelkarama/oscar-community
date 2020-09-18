package org.oscarehr.ws.rest.to.model;

import javax.xml.bind.annotation.XmlRootElement;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

@XmlRootElement
public class DocumentTo1 {
	private Integer documentNo;
	private String doctype;
	private String docClass;
	private String docSubClass;
	private String docdesc;
	private String docxml;
	private String docfilename;
	private String doccreator;
	private String responsible;
	private String source;
	private String sourceFacility;
	private Integer programId;
	private Date updatedatetime;
	private char status;
	private String contenttype;
	private Date contentdatetime;
	private String reportMedia;
	private Date sentDateTime;
	private int public1;
	private Date observationdate;
	private Integer numberofpages;
	private Integer appointmentNo;
	private Boolean abnormal;
	private Boolean restrictToProgram=false;

	private byte[] fileContents;

	private String ctlModule = "";
	private Integer ctlModuleId;
	private String ctlStatus;

	public Integer getDocumentNo() {
		return documentNo;
	}

	public void setDocumentNo(Integer documentNo) {
		this.documentNo = documentNo;
	}

	public String getDoctype() {
		return doctype;
	}

	public void setDoctype(String doctype) {
		this.doctype = doctype;
	}

	public String getDocClass() {
		return docClass;
	}

	public void setDocClass(String docClass) {
		this.docClass = docClass;
	}

	public String getDocSubClass() {
		return docSubClass;
	}

	public void setDocSubClass(String docSubClass) {
		this.docSubClass = docSubClass;
	}

	public String getDocdesc() {
		return docdesc;
	}

	public void setDocdesc(String docdesc) {
		this.docdesc = docdesc;
	}

	public String getDocxml() {
		return docxml;
	}

	public void setDocxml(String docxml) {
		this.docxml = docxml;
	}

	public String getDocfilename() {
		return docfilename;
	}

	public void setDocfilename(String docfilename) {
		this.docfilename = docfilename;
	}

	public String getDoccreator() {
		return doccreator;
	}

	public void setDoccreator(String doccreator) {
		this.doccreator = doccreator;
	}

	public String getResponsible() {
		return responsible;
	}

	public void setResponsible(String responsible) {
		this.responsible = responsible;
	}

	public String getSource() {
		return source;
	}

	public void setSource(String source) {
		this.source = source;
	}

	public String getSourceFacility() {
		return sourceFacility;
	}

	public void setSourceFacility(String sourceFacility) {
		this.sourceFacility = sourceFacility;
	}

	public Integer getProgramId() {
		return programId;
	}

	public void setProgramId(Integer programId) {
		this.programId = programId;
	}

	public Date getUpdatedatetime() {
		return updatedatetime;
	}

	public void setUpdatedatetime(Date updatedatetime) {
		this.updatedatetime = updatedatetime;
	}

	public char getStatus() {
		return status;
	}

	public void setStatus(char status) {
		this.status = status;
	}

	public String getContenttype() {
		return contenttype;
	}

	public void setContenttype(String contenttype) {
		this.contenttype = contenttype;
	}

	public Date getContentdatetime() {
		return contentdatetime;
	}

	public void setContentdatetime(Date contentdatetime) {
		this.contentdatetime = contentdatetime;
	}

	public String getReportMedia() {
		return reportMedia;
	}

	public void setReportMedia(String reportMedia) {
		this.reportMedia = reportMedia;
	}

	public Date getSentDateTime() {
		return sentDateTime;
	}

	public void setSentDateTime(Date sentDateTime) {
		this.sentDateTime = sentDateTime;
	}

	public int getPublic1() {
		return public1;
	}

	public void setPublic1(int public1) {
		this.public1 = public1;
	}

	public Date getObservationdate() {
		return observationdate;
	}

	public void setObservationdate(Date observationdate) {
		this.observationdate = observationdate;
	}

	public Integer getNumberofpages() {
		return numberofpages;
	}

	public void setNumberofpages(Integer numberofpages) {
		this.numberofpages = numberofpages;
	}

	public Integer getAppointmentNo() {
		return appointmentNo;
	}

	public void setAppointmentNo(Integer appointmentNo) {
		this.appointmentNo = appointmentNo;
	}

	public Boolean getAbnormal() {
		return abnormal;
	}

	public void setAbnormal(Boolean abnormal) {
		this.abnormal = abnormal;
	}

	public Boolean getRestrictToProgram() {
		return restrictToProgram;
	}

	public void setRestrictToProgram(Boolean restrictToProgram) {
		this.restrictToProgram = restrictToProgram;
	}

	public byte[] getFileContents() {
		return fileContents;
	}

	public void setFileContents(byte[] fileContents) {
		this.fileContents = fileContents;
	}

	public String getCtlModule() {
		return ctlModule;
	}

	public void setCtlModule(String ctlModule) {
		this.ctlModule = ctlModule;
	}

	public Integer getCtlModuleId() {
		return ctlModuleId;
	}

	public void setCtlModuleId(Integer ctlModuleId) {
		this.ctlModuleId = ctlModuleId;
	}

	public String getCtlStatus() {
		return ctlStatus;
	}

	public void setCtlStatus(String ctlStatus) {
		this.ctlStatus = ctlStatus;
	}
}
