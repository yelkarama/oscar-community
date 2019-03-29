/**
 * Copyright (c) 2001-2002. Department of Family Medicine, McMaster University. All Rights Reserved.
 * This software is published under the GPL GNU General Public License.
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 * <p>
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 * <p>
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 * <p>
 * This software was written for the
 * Department of Family Medicine
 * McMaster University
 * Hamilton
 * Ontario, Canada
 */


package oscar.oscarReport.pageUtil;

import org.apache.commons.lang.StringUtils;
import org.oscarehr.PMmodule.dao.ProviderDao;
import org.oscarehr.common.dao.ClinicDAO;
import org.oscarehr.common.dao.DemographicDao;
import org.oscarehr.common.dao.OscarAppointmentDao;
import org.oscarehr.common.model.Appointment;
import org.oscarehr.common.model.Clinic;
import org.oscarehr.common.model.Demographic;
import org.oscarehr.common.model.Provider;
import org.oscarehr.util.SpringUtils;
import org.oscarehr.ws.rest.to.implementations.progressSheet.MockRxInfoResponse;
import oscar.form.pdfservlet.FrmCustomedPDFParameters;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Map;

public class ProgressSheetMockRxUtils {
    
    public static final String MOCK_RX_REQUEST_URL = "billing/getMockRxInfo";

    /**
     * Creates FrmCustomedPDFParameters object from a mockRxInfo object, clinic, and logged in provider info
     * @param mockRxInfo The mockRxInfo object to use
     * @return a filled out FrmCustomedPDFParameters object for Rx printing
     */
    public static FrmCustomedPDFParameters createPdfParametersFromResponse(MockRxInfoResponse mockRxInfo) {
        SimpleDateFormat isoDateFormat = new SimpleDateFormat("yyyy-MM-dd");
        SimpleDateFormat longDateFormat = new SimpleDateFormat("MMMM d, yyyy");
        
        ProviderDao providerDao = SpringUtils.getBean(ProviderDao.class);
        OscarAppointmentDao appointmentDao = SpringUtils.getBean(OscarAppointmentDao.class);
        DemographicDao demographicDao = SpringUtils.getBean(DemographicDao.class);
        ClinicDAO clinicDAO = SpringUtils.getBean(ClinicDAO.class);
        Provider psProvider = providerDao.getProvider(mockRxInfo.getProviderId());
        Appointment psAppointment = appointmentDao.find(mockRxInfo.getAppointmentId());
        Demographic psDemographic = demographicDao.getDemographicById(mockRxInfo.getDemographicId());
        Clinic psClinic = clinicDAO.getClinic();
        
        FrmCustomedPDFParameters pdfParameters = new FrmCustomedPDFParameters();
        pdfParameters.set__method("mockPrint");
        pdfParameters.set__title("Rx");
        pdfParameters.setPdfId("");
        pdfParameters.setDemographicNo(String.valueOf(mockRxInfo.getDemographicId()));
        pdfParameters.setScriptId("-1");
        pdfParameters.setOrigPrintDate(isoDateFormat.format(psAppointment.getAppointmentDate()));
        pdfParameters.setNumPrints("1");
        
        String clinicTitle = psClinic.getClinicName().replaceAll("\\(\\d{6}\\)","") + "\n";
        clinicTitle += psClinic.getClinicAddress() + "\n" ;
        clinicTitle += psClinic.getClinicCity() + "   " + psClinic.getClinicPostal();
        pdfParameters.setClinicName(clinicTitle);
        pdfParameters.setClinicPhone(psClinic.getClinicPhone());
        pdfParameters.setClinicFax(psClinic.getClinicFax());
        
        pdfParameters.setPatientPhone("Tel: " + psDemographic.getPhone());
        String psDemographicCity = psDemographic.getCity();
        int check = (psDemographicCity.trim().length() > 0 ? 1 : 0) | (psDemographicCity.trim().length() > 0 ? 2 : 0);
        String patientCityPostal = String.format("%s%s%s %s", psDemographicCity, check == 3 ? ", " : check == 2 ? "" : " ", psDemographic.getProvince(), psDemographic.getPostal());
        pdfParameters.setPatientCityPostal(patientCityPostal);
        pdfParameters.setPatientAddress(psDemographic.getAddress());
        pdfParameters.setPatientName(psDemographic.getFormattedName());
        pdfParameters.setPatientHIN(StringUtils.trimToEmpty(psDemographic.getHin()));
        pdfParameters.setPatientChartNo(StringUtils.trimToEmpty(psDemographic.getChartNo()));
        pdfParameters.setShowPatientDOB(false);
        pdfParameters.setPatientDOB(longDateFormat.format(psDemographic.getBirthDay().getTime()));
        
        String sigDoctorName = psProvider.getFirstName() + " " + psProvider.getLastName();
        if (!StringUtils.isEmpty(psProvider.getPractitionerNo())) {
            sigDoctorName += " (" + psProvider.getPractitionerNo() + ")";
        }
        pdfParameters.setSigDoctorName(sigDoctorName);
        pdfParameters.setPracNo(StringUtils.trimToEmpty(psProvider.getPractitionerNo()));
        if (psDemographic.getProvider() != null) {
            String mrpDoctorName = psDemographic.getProvider().getFirstName() + " " + psDemographic.getProvider().getLastName();
            if (!StringUtils.isEmpty(psDemographic.getProvider().getPractitionerNo())) {
                mrpDoctorName += " (" + psDemographic.getProvider().getPractitionerNo() + ")";
            }
            pdfParameters.setMRP(mrpDoctorName);
        }
        pdfParameters.setPromoText("Created-by: OSCAR-The-open-source-EMR-www.oscarcanada.org");
        pdfParameters.setRxDate(longDateFormat.format(psAppointment.getAppointmentDate()));
        
        StringBuilder rxString = new StringBuilder();
        for (Map.Entry<String, String> entry : mockRxInfo.getFieldValueMap().entrySet()) {
            rxString.append(createMockRxItem(entry.getKey(), entry.getValue())).append("\r\n");
        }
        pdfParameters.setRx(rxString.toString());
        
        String signatureMessage = "Electronically Authorized by " + psProvider.getLastName() + ", \r\n" + psProvider.getFirstName()
                + " (" + psProvider.getPractitionerNo() + ") at " + isoDateFormat.format(new Date());
        pdfParameters.setElectronicSignature(signatureMessage);
        pdfParameters.setPharmaShow(false);
        pdfParameters.setAdditNotes("");
        pdfParameters.setRxPageSize("PageSize.A6");
        return pdfParameters;
    }

    /**
     * Creates rx special String from progress sheet field and value
     * @param psField the progress sheet field name
     * @param psValue the progress sheet field value
     * @return a rx special String
     */
    private static String createMockRxItem(String psField, String psValue) {
        StringBuilder rxItemString = new StringBuilder();
        
        if ("billing_post_procedure_marcaine_xylocaine_syringe_count".equals(psField)) {
            rxItemString.append("Bupivacaine .025% + Xylocaine 2% (9:1)\r\n").append("Qty: ").append(psValue);
        }
        
        return rxItemString.toString();
    }
}
