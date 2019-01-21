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
package org.oscarehr.ws.rest;

import javax.ws.rs.Consumes;
import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.QueryParam;
import javax.ws.rs.core.MediaType;

import org.apache.commons.lang.StringUtils;
import org.oscarehr.PMmodule.dao.ProviderDao;
import org.oscarehr.common.dao.BillingONCHeader1Dao;
import org.oscarehr.common.dao.BillingONExtDao;
import org.oscarehr.common.dao.BillingONPaymentDao;
import org.oscarehr.common.dao.BillingOnTransactionDao;
import org.oscarehr.common.dao.BillingServiceDao;
import org.oscarehr.common.dao.DemographicDao;
import org.oscarehr.common.dao.DiagnosticCodeDao;
import org.oscarehr.common.dao.DxresearchDAO;
import org.oscarehr.common.dao.OscarAppointmentDao;
import org.oscarehr.common.model.Appointment;
import org.oscarehr.common.model.BillingONCHeader1;
import org.oscarehr.common.model.BillingONExt;
import org.oscarehr.common.model.BillingONItem;
import org.oscarehr.common.model.BillingOnTransaction;
import org.oscarehr.common.model.Demographic;
import org.oscarehr.common.model.DiagnosticCode;
import org.oscarehr.common.model.Dxresearch;
import org.oscarehr.common.model.Provider;
import org.oscarehr.managers.BillingManager;
import org.oscarehr.ws.rest.conversion.ServiceTypeConverter;
import org.oscarehr.ws.rest.to.AbstractSearchResponse;
import org.oscarehr.ws.rest.to.GenericRESTResponse;
import org.oscarehr.ws.rest.to.InvoiceCreateResponse;
import org.oscarehr.ws.rest.to.model.BillingInvoiceTo1;
import org.oscarehr.ws.rest.to.model.BillingItemTo1;
import org.oscarehr.ws.rest.to.model.ServiceTypeTo;
import org.springframework.beans.factory.annotation.Autowired;

import oscar.OscarProperties;
import oscar.oscarBilling.ca.on.data.BillingDataHlp;

import java.math.BigDecimal;
import java.text.ParseException;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

@Path("/billing")
public class BillingService extends AbstractServiceImpl {

	@Autowired
	BillingManager billingManager;
	@Autowired
    ProviderDao providerDao;
    @Autowired
    DemographicDao demographicDao;
    @Autowired
    BillingONCHeader1Dao billingONCHeader1Dao;
    @Autowired
    BillingServiceDao billingServiceDao;
    @Autowired
    OscarAppointmentDao appointmentDao;
    @Autowired
    DxresearchDAO dxresearchDAO;
    @Autowired
    BillingONPaymentDao billingONPaymentDao;
    @Autowired
    BillingONExtDao billingONExtDao;
    @Autowired
    BillingOnTransactionDao billingOnTransactionDao;
    @Autowired
    DiagnosticCodeDao diagnosticCodeDao;

	private OscarProperties oscarProperties = OscarProperties.getInstance();
	
	@GET
	@Path("/uniqueServiceTypes")
	@Produces("application/json")
	public AbstractSearchResponse<ServiceTypeTo> getUniqueServiceTypes(@QueryParam("type")  String type) {
		AbstractSearchResponse<ServiceTypeTo> response = new AbstractSearchResponse<ServiceTypeTo>();
		ServiceTypeConverter converter = new ServiceTypeConverter();
		if(type == null) {
			response.setContent(converter.getAllAsTransferObjects(getLoggedInInfo(),billingManager.getUniqueServiceTypes(getLoggedInInfo())));	
		} else {
			response.setContent(converter.getAllAsTransferObjects(getLoggedInInfo(),billingManager.getUniqueServiceTypes(getLoggedInInfo(),type)));
		}
		response.setTotal(response.getContent().size());
		return response;

	}

    @GET
    @Path("/billingRegion")
    @Produces("application/json")
    public GenericRESTResponse billingRegion() {
        boolean billRegionSet = true;
        String billRegion = oscarProperties.getProperty("billregion", "").trim().toUpperCase();
        if(billRegion.isEmpty()){
            billRegionSet = false;
        }
        return new GenericRESTResponse(billRegionSet, billRegion);
    }
	
    @GET
    @Path("/defaultView")
    @Produces("application/json")
    public GenericRESTResponse defaultView() {
        boolean defaultViewSet = true;
        String defaultView = oscarProperties.getProperty("default_view", "").trim();
        if(defaultView.isEmpty()){
        	defaultViewSet = false;
        }
        return new GenericRESTResponse(defaultViewSet, defaultView);
    }

    @POST
    @Path("/createInvoice")
    @Produces(MediaType.APPLICATION_JSON)
    @Consumes(MediaType.APPLICATION_JSON)
    public GenericRESTResponse createInvoice(BillingInvoiceTo1 invoiceRequest) {
        Provider billingProvider = providerDao.getProvider(invoiceRequest.getProviderNo());
        if (billingProvider == null) {
            return new InvoiceCreateResponse(false, "Cannot create invoice, billing provider with id " + invoiceRequest.getProviderNo() + " does not exist.", null);
        }
        Demographic billedDemographic = demographicDao.getDemographicById(invoiceRequest.getDemographicNo());
        if (billedDemographic == null) {
            return new InvoiceCreateResponse(false, "Cannot create invoice, billed demographic with id " + invoiceRequest.getDemographicNo() + " does not exist.", null);
        }
        if (invoiceRequest.getBillingItems().isEmpty()) {
            return new InvoiceCreateResponse(false, "Cannot create invoice, no items billed.", null);
        }
        
        Appointment billedAppointment = appointmentDao.find(invoiceRequest.getAppointmentNo());
        
        BillingONCHeader1 invoice = invoiceRequest.toBillingONCHeader1();
        invoice.setHeaderId(0);
        
        // Set invoice demographic info
        invoice.setHin(billedDemographic.getHin());
        invoice.setVer(billedDemographic.getVer());
        invoice.setDob(billedDemographic.getFormattedDob().replaceAll("-", ""));
        invoice.setDemographicName(billedDemographic.getDisplayName());
        if ("F".equals(billedDemographic.getSex())) {
            invoice.setSex("2");
        } else {
            invoice.setSex("1");
        }
        
        // Set invoice billing provider info
        invoice.setProviderOhipNo(billingProvider.getOhipNo());
        invoice.setProviderRmaNo(billingProvider.getRmaNo());
        invoice.setCreator(billingProvider.getPractitionerNo());
        
        // Set clinic info
        invoice.setApptProviderNo("none");
        if (billedAppointment != null) { invoice.setApptProviderNo(billedAppointment.getProviderNo()); }

        invoice.setBillingDate(new Date());
        invoice.setBillingTime(new Date());
        invoice.setStatus("O");
        
        BigDecimal totalFee = new BigDecimal("0.00");

        for (BillingItemTo1 requestItem : invoiceRequest.getBillingItems()) {
            org.oscarehr.common.model.BillingService service = billingServiceDao.searchBillingCode(requestItem.getServiceCode(), invoice.getProvince());
            if (service == null) {
                return new InvoiceCreateResponse(false, "Cannot create invoice, billed service number " + requestItem.getServiceCode() + " does not exist.", null);
            } else {
                BillingONItem billingItem = new BillingONItem();
                billingItem.setTranscId(requestItem.getTransactionId());
                billingItem.setRecId(requestItem.getRecordId());
                billingItem.setServiceCode(requestItem.getServiceCode());
                billingItem.setStatus(requestItem.getStatus());
                billingItem.setServiceDate(invoice.getBillingDate());
                billingItem.setDx(requestItem.getDx());
                billingItem.setServiceCount(requestItem.getServiceCount().toString());
                BigDecimal fee = new BigDecimal(requestItem.getServiceCount()).multiply(new BigDecimal(service.getValue()));
                totalFee = totalFee.add(fee);
                billingItem.setFee(fee.setScale(2, BigDecimal.ROUND_HALF_UP).toPlainString());
                invoice.getBillingItems().add(billingItem);
            }
        }
        
        invoice.setTotal(totalFee.setScale(2, BigDecimal.ROUND_HALF_UP));
        invoice.setPaid(new BigDecimal("0.00").setScale(2, BigDecimal.ROUND_HALF_UP));
        
        saveInvoice(invoice, billedDemographic, billedAppointment);

	    if (invoice.getId() != null) {
            return new InvoiceCreateResponse(true, invoice.getId().toString(), invoice.getId());
        } else {
            return new InvoiceCreateResponse(false, "Error creating invoice.", null);
        }
    }
    
    private void saveInvoice(BillingONCHeader1 invoice, Demographic billedDemographic, Appointment billedAppointment) {
        boolean isThirdParty = invoice.getPayProgram().substring(0, 3).matches(BillingDataHlp.BILLINGMATCHSTRING_3RDPARTY);
        if (isThirdParty && "ODP".equalsIgnoreCase(invoice.getPayProgram())) {
            String payProgram = billedDemographic.getHcType().equals("ON") ? "HCP" : "RMB";
            invoice.setPayProgram(payProgram);
        }
        
        billingONCHeader1Dao.persist(invoice);
        Provider loggedInProvider = getLoggedInInfo().getLoggedInProvider();

        if (invoice.getId() > 0) {
            List<String> demographicDiagnoses = dxresearchDAO.getCodesByDemographicNo(billedDemographic.getDemographicNo());
            List<String> newDemoDiagnoses = new ArrayList<String>();

            BillingONExt ext = new BillingONExt();
            ext.setBillingNo(invoice.getId());
            ext.setDemographicNo(invoice.getDemographicNo());
            ext.setKeyVal("payee");
            ext.setValue(null);
            ext.setDateTime(new Date());
            billingONExtDao.persist(ext);
            
            List<BillingONItem> billingItems = invoice.getBillingItems();
            for (BillingONItem item : billingItems) {
                if (!isThirdParty) {
                    BillingOnTransaction transaction = new BillingOnTransaction();
                    try {
                        transaction.setAdmissionDate(invoice.getAdmissionDate());
                    } catch (ParseException e) {
                        transaction.setAdmissionDate(null);
                    }
                    transaction.setBillingDate(invoice.getBillingDate());
                    transaction.setBillingNotes(invoice.getComment());
                    transaction.setBillingOnItemPaymentId(item.getId());
                    transaction.setCh1Id(invoice.getId());
                    transaction.setClinic(invoice.getClinic());
                    transaction.setCreator(invoice.getCreator());
                    transaction.setDemographicNo(invoice.getDemographicNo());
                    transaction.setDxCode(item.getDx());
                    transaction.setFacilityNum(invoice.getFaciltyNum());
                    transaction.setManReview(invoice.getManReview());
                    transaction.setPayProgram(invoice.getPayProgram());
                    transaction.setPaymentDate(null);
                    transaction.setProviderNo(invoice.getProviderNo());
                    transaction.setPaymentId(0);
                    transaction.setProvince(billedDemographic.getProvince());
                    transaction.setRefNum(invoice.getRefLabNum());
                    transaction.setServiceCode(item.getServiceCode());
                    transaction.setServiceCodeInvoiced(item.getFee());
                    transaction.setServiceCodeNum(item.getServiceCount());
                    transaction.setServiceCodeDiscount(new BigDecimal("0.00"));
                    transaction.setServiceCodePaid(new BigDecimal("0.00"));
                    transaction.setSliCode(invoice.getLocation());
                    transaction.setUpdateProviderNo(loggedInProvider.getProviderNo());
                    transaction.setVisittype(invoice.getVisitType());
                    transaction.setPaymentType(0);

                    billingOnTransactionDao.persist(transaction);
                }
                if (StringUtils.trimToNull(item.getDx()) != null && !demographicDiagnoses.contains(item.getDx()) && !newDemoDiagnoses.contains(item.getDx())) {
                    newDemoDiagnoses.add(item.getDx());
                }
                if (StringUtils.trimToNull(item.getDx1()) != null && !demographicDiagnoses.contains(item.getDx1()) && !newDemoDiagnoses.contains(item.getDx1())) {
                    newDemoDiagnoses.add(item.getDx1());
                }
                if (StringUtils.trimToNull(item.getDx2()) != null && !demographicDiagnoses.contains(item.getDx2()) && !newDemoDiagnoses.contains(item.getDx2())) {
                    newDemoDiagnoses.add(item.getDx2());
                }
            }

            for (String newDx : newDemoDiagnoses) {
                dxresearchDAO.save((new Dxresearch(billedDemographic.getDemographicNo(), new Date(),  new Date(), 'A', newDx, "icd9", (byte) 0, loggedInProvider.getProviderNo())));
            }
            if (billedAppointment != null) {
                billedAppointment.setStatus("B");
                appointmentDao.merge(billedAppointment);
            }
        }
    }
}
