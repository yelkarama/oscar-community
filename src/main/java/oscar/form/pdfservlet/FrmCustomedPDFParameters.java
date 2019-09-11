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


package oscar.form.pdfservlet;

import org.apache.commons.lang.StringUtils;
import oscar.OscarProperties;

import javax.servlet.http.HttpServletRequest;
import java.util.HashMap;

/**
 * A class for holding the parameters used for {@link FrmCustomedPDFServlet}
 */
public class FrmCustomedPDFParameters {
    
    private String __method;
    private String __title;
    private String pdfId;
    private String demographicNo;
    private String scriptId;
    private String origPrintDate;
    private String numPrints;
    private String clinicName;
    private String clinicPhone;
    private String clinicFax;
    private String patientPhone;
    private String patientCityPostal;
    private String patientAddress;
    private String patientName;
    private String sigDoctorName;
    private String MRP = "";
    private String promoText;
    private String rxDate;
    private String rx;
    private String patientDOB;
    private boolean showPatientDOB;
    private String imgFile;
    private String electronicSignature;
    private String patientHIN;
    private String patientChartNo;
    private String bandNumber = "";
    private String pracNo;
    private String pharmacyId;
    private String pharmaName;
    private String pharmaAddress1;
    private String pharmaAddress2;
    private String pharmaTel;
    private String pharmaFax;
    private String pharmaEmail;
    private String pharmaNote;
    private boolean pharmaShow;
    private String additNotes;
    private String rxPageSize;
    
    public FrmCustomedPDFParameters() {};
    public FrmCustomedPDFParameters(HttpServletRequest request) {
        this.__method = request.getParameter("__method");
        this.__title = request.getParameter("__title");
        this.pdfId = request.getParameter("pdfId");
        this.demographicNo = request.getParameter("demographic_no");
        this.scriptId = request.getParameter("scriptId");
        this.origPrintDate = null;
        this.numPrints = null;
        if ("rePrint".equalsIgnoreCase(this.__method)) {
            this.origPrintDate = request.getParameter("origPrintDate");
            this.numPrints = request.getParameter("numPrints");
        }
        // check if satellite clinic is used
        if ("true".equals(request.getParameter("useSC"))) {
            String scAddress = request.getParameter("scAddress");
            HashMap<String,String> hm = FrmCustomedPDFGenerator.parseSCAddress(scAddress);
            this.clinicName = StringUtils.trimToEmpty(hm.get("clinicName"));
            this.clinicPhone = StringUtils.trimToEmpty(hm.get("clinicTel"));
            this.clinicFax = StringUtils.trimToEmpty(hm.get("clinicFax"));
        } else {
            this.clinicName = StringUtils.trimToEmpty(request.getParameter("clinicName"));
            this.clinicPhone = StringUtils.trimToEmpty(request.getParameter("clinicPhone"));
            this.clinicFax = StringUtils.trimToEmpty(request.getParameter("clinicFax"));
        }
        this.patientPhone = StringUtils.trimToEmpty(request.getParameter("patientPhone"));
        this.patientCityPostal = StringUtils.trimToEmpty(request.getParameter("patientCityPostal"));
        this.patientAddress = StringUtils.trimToEmpty(request.getParameter("patientAddress"));
        this.patientName = StringUtils.trimToEmpty(request.getParameter("patientName"));
        this.sigDoctorName = StringUtils.trimToEmpty(request.getParameter("sigDoctorName"));
        this.MRP = StringUtils.trimToEmpty(request.getParameter("MRP"));
        this.promoText = OscarProperties.getInstance().getProperty("FORMS_PROMOTEXT");
        if (this.promoText == null) { promoText = ""; }
        this.rxDate = request.getParameter("rxDate");
        this.rx = request.getParameter("rx");
        if (this.rx == null) { rx = ""; }
        this.patientDOB = request.getParameter("patientDOB");
        this.showPatientDOB = "true".equals(request.getParameter("showPatientDOB"));
        if (!this.showPatientDOB) { patientDOB = ""; }
        this.patientHIN = StringUtils.trimToEmpty(request.getParameter("patientHIN"));
        this.patientChartNo = StringUtils.trimToEmpty(request.getParameter("patientChartNo"));
        this.bandNumber = request.getParameter("bandNumber");
        this.pracNo = StringUtils.trimToEmpty(request.getParameter("pracNo"));
        this.pharmacyId = request.getParameter("pharmacyId");
        this.pharmaName = request.getParameter("pharmaName");
        this.pharmaAddress1 = StringUtils.trimToEmpty(request.getParameter("pharmaAddress1"));
        this.pharmaAddress2 = StringUtils.trimToEmpty(request.getParameter("pharmaAddress2"));
        this.pharmaTel = StringUtils.trimToEmpty(request.getParameter("pharmaTel"));
        this.pharmaFax = StringUtils.trimToEmpty(request.getParameter("pharmaFax"));
        this.pharmaEmail = StringUtils.trimToEmpty(request.getParameter("pharmaEmail"));
        this.pharmaNote = StringUtils.trimToEmpty(request.getParameter("pharmaNote"));
        this.pharmaShow = "true".equals(request.getParameter("pharmaShow"));
        this.additNotes = request.getParameter("additNotes");
        this.rxPageSize = request.getParameter("rxPageSize");
        this.imgFile = request.getParameter("imgFile");
        this.electronicSignature = request.getParameter("electronicSignature");
    }

    public String get__method() {
        return __method;
    }

    public void set__method(String __method) {
        this.__method = __method;
    }

    public String get__title() {
        return __title;
    }

    public void set__title(String __title) {
        this.__title = __title;
    }

    public String getPdfId() {
        return pdfId;
    }

    public void setPdfId(String pdfId) {
        this.pdfId = pdfId;
    }

    public String getDemographicNo() {
        return demographicNo;
    }

    public void setDemographicNo(String demographicNo) {
        this.demographicNo = demographicNo;
    }

    public String getScriptId() {
        return scriptId;
    }

    public void setScriptId(String scriptId) {
        this.scriptId = scriptId;
    }

    public String getOrigPrintDate() {
        return origPrintDate;
    }

    public void setOrigPrintDate(String origPrintDate) {
        this.origPrintDate = origPrintDate;
    }

    public String getNumPrints() {
        return numPrints;
    }

    public void setNumPrints(String numPrints) {
        this.numPrints = numPrints;
    }

    public String getClinicName() {
        return clinicName;
    }

    public void setClinicName(String clinicName) {
        this.clinicName = clinicName;
    }

    public String getClinicPhone() {
        return clinicPhone;
    }

    public void setClinicPhone(String clinicPhone) {
        this.clinicPhone = clinicPhone;
    }

    public String getClinicFax() {
        return clinicFax;
    }

    public void setClinicFax(String clinicFax) {
        this.clinicFax = clinicFax;
    }

    public String getPatientPhone() {
        return patientPhone;
    }

    public void setPatientPhone(String patientPhone) {
        this.patientPhone = patientPhone;
    }

    public String getPatientCityPostal() {
        return patientCityPostal;
    }

    public void setPatientCityPostal(String patientCityPostal) {
        this.patientCityPostal = patientCityPostal;
    }

    public String getPatientAddress() {
        return patientAddress;
    }

    public void setPatientAddress(String patientAddress) {
        this.patientAddress = patientAddress;
    }

    public String getPatientName() {
        return patientName;
    }

    public void setPatientName(String patientName) {
        this.patientName = patientName;
    }

    public String getSigDoctorName() {
        return sigDoctorName;
    }

    public void setSigDoctorName(String sigDoctorName) {
        this.sigDoctorName = sigDoctorName;
    }

    public String getMRP() {
        return MRP;
    }

    public void setMRP(String MRP) {
        this.MRP = MRP;
    }

    public String getPromoText() {
        return promoText;
    }

    public void setPromoText(String promoText) {
        this.promoText = promoText;
    }

    public String getRxDate() {
        return rxDate;
    }

    public void setRxDate(String rxDate) {
        this.rxDate = rxDate;
    }

    public String getRx() {
        return rx;
    }

    public void setRx(String rx) {
        this.rx = rx;
    }

    public String getPatientDOB() {
        return patientDOB;
    }

    public void setPatientDOB(String patientDOB) {
        this.patientDOB = patientDOB;
    }

    public boolean getShowPatientDOB() {
        return showPatientDOB;
    }

    public void setShowPatientDOB(boolean showPatientDOB) {
        this.showPatientDOB = showPatientDOB;
    }

    public String getImgFile() {
        return imgFile;
    }

    public void setImgFile(String imgFile) {
        this.imgFile = imgFile;
    }

    public String getElectronicSignature() {
        return electronicSignature;
    }

    public void setElectronicSignature(String electronicSignature) {
        this.electronicSignature = electronicSignature;
    }

    public String getPatientHIN() {
        return patientHIN;
    }

    public void setPatientHIN(String patientHIN) {
        this.patientHIN = patientHIN;
    }

    public String getPatientChartNo() {
        return patientChartNo;
    }

    public void setPatientChartNo(String patientChartNo) {
        this.patientChartNo = patientChartNo;
    }

    public String getBandNumber() {
        return bandNumber;
    }

    public void setBandNumber(String bandNumber) {
        this.bandNumber = bandNumber;
    }

    public String getPracNo() {
        return pracNo;
    }

    public void setPracNo(String pracNo) {
        this.pracNo = pracNo;
    }

    public String getPharmacyId() {
        return pharmacyId;
    }

    public void setPharmacyId(String pharmacyId) {
        this.pharmacyId = pharmacyId;
    }

    public String getPharmaName() {
        return pharmaName;
    }

    public void setPharmaName(String pharmaName) {
        this.pharmaName = pharmaName;
    }

    public String getPharmaAddress1() {
        return pharmaAddress1;
    }

    public void setPharmaAddress1(String pharmaAddress1) {
        this.pharmaAddress1 = pharmaAddress1;
    }

    public String getPharmaAddress2() {
        return pharmaAddress2;
    }

    public void setPharmaAddress2(String pharmaAddress2) {
        this.pharmaAddress2 = pharmaAddress2;
    }

    public String getPharmaTel() {
        return pharmaTel;
    }

    public void setPharmaTel(String pharmaTel) {
        this.pharmaTel = pharmaTel;
    }

    public String getPharmaFax() {
        return pharmaFax;
    }

    public void setPharmaFax(String pharmaFax) {
        this.pharmaFax = pharmaFax;
    }

    public String getPharmaEmail() {
        return pharmaEmail;
    }

    public void setPharmaEmail(String pharmaEmail) {
        this.pharmaEmail = pharmaEmail;
    }

    public String getPharmaNote() {
        return pharmaNote;
    }

    public void setPharmaNote(String pharmaNote) {
        this.pharmaNote = pharmaNote;
    }

    public boolean getPharmaShow() {
        return pharmaShow;
    }

    public void setPharmaShow(boolean pharmaShow) {
        this.pharmaShow = pharmaShow;
    }

    public String getAdditNotes() {
        return additNotes;
    }

    public void setAdditNotes(String additNotes) {
        this.additNotes = additNotes;
    }

    public String getRxPageSize() {
        return rxPageSize;
    }

    public void setRxPageSize(String rxPageSize) {
        this.rxPageSize = rxPageSize;
    }
}
