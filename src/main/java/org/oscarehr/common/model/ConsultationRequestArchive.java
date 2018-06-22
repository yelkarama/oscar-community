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
import javax.persistence.Temporal;
import javax.persistence.TemporalType;
import java.io.Serializable;
import java.util.Date;

@Entity
@Table(name = "consultation_requests_archive")
public class ConsultationRequestArchive extends AbstractModel<Integer> implements Serializable {
	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Integer id;
	
    @Column(name = "archive_timestamp")
    @Temporal(TemporalType.TIMESTAMP)
    private Date archiveTimestamp;
	
	@Column(name = "request_id")
	private Integer requestId;
	
	@Column(name = "referral_date")
	@Temporal(TemporalType.DATE)
	private Date referralDate;
	
    @Column(name = "service_id")
	private Integer serviceId;
    
	@Column(name="specialist_id")
	private Integer specialistId;
	
    @Column(name = "appointment_date")
	@Temporal(TemporalType.DATE)
	private Date appointmentDate;
    
    @Column(name = "appointment_time")
	@Temporal(TemporalType.TIME)
	private Date appointmentTime;
    
	@Column(name = "reason")
	private String reasonForReferral;
	
	@Column(name = "clinical_info")
	private String clinicalInfo;
	
	@Column(name = "current_meds")
	private String currentMeds;
	
	@Column(name = "allergies")
	private String allergies;
	
	@Column(name = "provider_no")
	private String providerNo;
	
	@Column(name = "demographic_id")
	private Integer demographicId;

	@Column(name = "status")
	private String status;
	
	@Column(name = "status_text")
	private String statusText;
	
	@Column(name = "send_to")
	private String sendTo;
	
	@Column(name = "concurrent_problems")
	private String concurrentProblems;
	
	@Column(name = "urgency")
	private String urgency;
	
	@Column(name = "appointment_instructions")
	private String appointmentInstructions;
	
	@Column(name = "patient_will_book")
	private Boolean patientWillBook;	

	@Column(name = "site_name")
	private String siteName;

    @Column(name = "follow_up_date")
    @Temporal(TemporalType.DATE)
    private Date followUpDate;
    
    @Column(name = "signature_img")
    private String signatureImg;
    
    @Column(name = "letterhead_name")
    private String letterheadName;
    
    @Column(name = "letterhead_address")
    private String letterheadAddress;
    
    @Column(name = "letterhead_phone")
    private String letterheadPhone;
    
    @Column(name = "letterhead_fax")
    private String letterheadFax;
    
    @Column(name = "letterhead_website")
    private String letterheadWebsite;
    
    @Column(name = "letterhead_email")
    private String letterheadEmail;

    @Column(name = "last_update_date")
    @Temporal(TemporalType.TIMESTAMP)
    private Date lastUpdateDate;

    @Column(name = "fdid")
    private Integer fdid;
    
    @Column(name = "source")
    private String source;

    public ConsultationRequestArchive() {}
    public ConsultationRequestArchive(ConsultationRequest other) {
        this.archiveTimestamp = new Date();
        this.requestId = other.getId();
        this.referralDate = other.getReferralDate();
        this.serviceId = other.getServiceId();
        this.specialistId = other.getSpecialistId();
        this.appointmentDate = other.getAppointmentDate();
        this.appointmentTime = other.getAppointmentTime();
        this.reasonForReferral = other.getReasonForReferral();
        this.clinicalInfo = other.getClinicalInfo();
        this.currentMeds = other.getCurrentMeds();
        this.allergies = other.getAllergies();
        this.providerNo = other.getProviderNo();
        this.demographicId = other.getDemographicId();
        this.status = other.getStatus();
        this.statusText = other.getStatusText();
        this.sendTo = other.getSendTo();
        this.concurrentProblems = other.getConcurrentProblems();
        this.urgency = other.getUrgency();
        this.appointmentInstructions = other.getAppointmentInstructions();
        this.patientWillBook = other.isPatientWillBook();
        this.siteName = other.getSiteName();
        this.followUpDate = other.getFollowUpDate();
        this.signatureImg = other.getSignatureImg();
        this.letterheadName = other.getLetterheadName();
        this.letterheadAddress = other.getLetterheadAddress();
        this.letterheadPhone = other.getLetterheadPhone();
        this.letterheadFax = other.getLetterheadFax();
        this.letterheadWebsite = other.getLetterheadWebsite();
        this.letterheadEmail = other.getLetterheadEmail();
        this.lastUpdateDate = other.getLastUpdateDate();
        this.fdid = other.getFdid();
        this.source = other.getSource();
    }

    @Override
    public Integer getId() {
        return id;
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

    public Date getReferralDate() {
        return referralDate;
    }
    public void setReferralDate(Date referralDate) {
        this.referralDate = referralDate;
    }

    public Integer getServiceId() {
        return serviceId;
    }
    public void setServiceId(Integer serviceId) {
        this.serviceId = serviceId;
    }

    public Integer getSpecialistId() {
        return specialistId;
    }
    public void setSpecialistId(Integer specialistId) {
        this.specialistId = specialistId;
    }

    public Date getAppointmentDate() {
        return appointmentDate;
    }
    public void setAppointmentDate(Date appointmentDate) {
        this.appointmentDate = appointmentDate;
    }

    public Date getAppointmentTime() {
        return appointmentTime;
    }
    public void setAppointmentTime(Date appointmentTime) {
        this.appointmentTime = appointmentTime;
    }

    public String getReasonForReferral() {
        return reasonForReferral;
    }
    public void setReasonForReferral(String reasonForReferral) {
        this.reasonForReferral = reasonForReferral;
    }

    public String getClinicalInfo() {
        return clinicalInfo;
    }
    public void setClinicalInfo(String clinicalInfo) {
        this.clinicalInfo = clinicalInfo;
    }

    public String getCurrentMeds() {
        return currentMeds;
    }
    public void setCurrentMeds(String currentMeds) {
        this.currentMeds = currentMeds;
    }

    public String getAllergies() {
        return allergies;
    }
    public void setAllergies(String allergies) {
        this.allergies = allergies;
    }

    public String getProviderNo() {
        return providerNo;
    }
    public void setProviderNo(String providerNo) {
        this.providerNo = providerNo;
    }

    public Integer getDemographicId() {
        return demographicId;
    }
    public void setDemographicId(Integer demographicId) {
        this.demographicId = demographicId;
    }

    public String getStatus() {
        return status;
    }
    public void setStatus(String status) {
        this.status = status;
    }

    public String getStatusText() {
        return statusText;
    }
    public void setStatusText(String statusText) {
        this.statusText = statusText;
    }

    public String getSendTo() {
        return sendTo;
    }
    public void setSendTo(String sendTo) {
        this.sendTo = sendTo;
    }

    public String getConcurrentProblems() {
        return concurrentProblems;
    }
    public void setConcurrentProblems(String concurrentProblems) {
        this.concurrentProblems = concurrentProblems;
    }

    public String getUrgency() {
        return urgency;
    }
    public void setUrgency(String urgency) {
        this.urgency = urgency;
    }

    public String getAppointmentInstructions() {
        return appointmentInstructions;
    }
    public void setAppointmentInstructions(String appointmentInstructions) {
        this.appointmentInstructions = appointmentInstructions;
    }

    public Boolean isPatientWillBook() {
        return patientWillBook;
    }
    public void setPatientWillBook(Boolean patientWillBook) {
        this.patientWillBook = patientWillBook;
    }

    public String getSiteName() {
        return siteName;
    }
    public void setSiteName(String siteName) {
        this.siteName = siteName;
    }

    public Date getFollowUpDate() {
        return followUpDate;
    }
    public void setFollowUpDate(Date followUpDate) {
        this.followUpDate = followUpDate;
    }

    public String getSignatureImg() {
        return signatureImg;
    }
    public void setSignatureImg(String signatureImg) {
        this.signatureImg = signatureImg;
    }

    public String getLetterheadName() {
        return letterheadName;
    }
    public void setLetterheadName(String letterheadName) {
        this.letterheadName = letterheadName;
    }

    public String getLetterheadAddress() {
        return letterheadAddress;
    }
    public void setLetterheadAddress(String letterheadAddress) {
        this.letterheadAddress = letterheadAddress;
    }

    public String getLetterheadPhone() {
        return letterheadPhone;
    }
    public void setLetterheadPhone(String letterheadPhone) {
        this.letterheadPhone = letterheadPhone;
    }

    public String getLetterheadFax() {
        return letterheadFax;
    }
    public void setLetterheadFax(String letterheadFax) {
        this.letterheadFax = letterheadFax;
    }

    public String getLetterheadWebsite() {
        return letterheadWebsite;
    }
    public void setLetterheadWebsite(String letterheadWebsite) {
        this.letterheadWebsite = letterheadWebsite;
    }

    public String getLetterheadEmail() {
        return letterheadEmail;
    }
    public void setLetterheadEmail(String letterheadEmail) {
        this.letterheadEmail = letterheadEmail;
    }

    public Date getLastUpdateDate() {
        return lastUpdateDate;
    }
    public void setLastUpdateDate(Date lastUpdateDate) {
        this.lastUpdateDate = lastUpdateDate;
    }

    public Integer getFdid() {
        return fdid;
    }
    public void setFdid(Integer fdid) {
        this.fdid = fdid;
    }

    public String getSource() {
        return source;
    }
    public void setSource(String source) {
        this.source = source;
    }
    
    public ConsultationRequest toConsultationRequest() {
        ConsultationRequest conRequest = new ConsultationRequest();
        conRequest.setReferralDate(this.referralDate);
        conRequest.setServiceId(this.serviceId);
//        conRequest.setProfessionalSpecialist(this.professionalSpecialist);
        conRequest.setAppointmentDate(this.appointmentDate);
        conRequest.setAppointmentTime(this.appointmentTime);
        conRequest.setReasonForReferral(this.reasonForReferral);
        conRequest.setClinicalInfo(this.clinicalInfo);
        conRequest.setCurrentMeds(this.currentMeds);
        conRequest.setAllergies(this.allergies);
        conRequest.setProviderNo(this.providerNo);
        conRequest.setDemographicId(this.demographicId);
        conRequest.setStatus(this.status);
        conRequest.setStatusText(this.statusText);
        conRequest.setSendTo(this.sendTo);
        conRequest.setConcurrentProblems(this.concurrentProblems);
        conRequest.setUrgency(this.urgency);
        conRequest.setAppointmentInstructions(this.appointmentInstructions);
        conRequest.setPatientWillBook(this.patientWillBook);
        conRequest.setSiteName(this.siteName);
        conRequest.setFollowUpDate(this.followUpDate);
        conRequest.setSignatureImg(this.signatureImg);
        conRequest.setLetterheadName(this.letterheadName);
        conRequest.setLetterheadAddress(this.letterheadAddress);
        conRequest.setLetterheadPhone(this.letterheadPhone);
        conRequest.setLetterheadFax(this.letterheadFax);
        conRequest.setLetterheadWebsite(this.letterheadWebsite);
        conRequest.setLetterheadEmail(this.letterheadEmail);
//        conRequest.setLookupListItem(this.lookupListItem);
        conRequest.setFdid(this.fdid);
        conRequest.setSource(this.source);
        return conRequest;
    }
}
