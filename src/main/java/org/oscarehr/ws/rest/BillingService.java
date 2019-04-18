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
import javax.ws.rs.PathParam;
import javax.ws.rs.Produces;
import javax.ws.rs.QueryParam;
import javax.ws.rs.core.MediaType;

import org.apache.commons.lang.StringUtils;
import org.oscarehr.PMmodule.dao.ProviderDao;
import org.oscarehr.common.dao.BillingONCHeader1Dao;
import org.oscarehr.common.dao.BillingONExtDao;
import org.oscarehr.common.dao.BillingONRepoDao;
import org.oscarehr.common.dao.BillingOnTransactionDao;
import org.oscarehr.common.dao.BillingServiceDao;
import org.oscarehr.common.dao.DemographicDao;
import org.oscarehr.common.dao.DxresearchDAO;
import org.oscarehr.common.dao.OscarAppointmentDao;
import org.oscarehr.common.model.Appointment;
import org.oscarehr.common.model.BillingONCHeader1;
import org.oscarehr.common.model.BillingONExt;
import org.oscarehr.common.model.BillingONItem;
import org.oscarehr.common.model.BillingOnTransaction;
import org.oscarehr.common.model.Demographic;
import org.oscarehr.common.model.Dxresearch;
import org.oscarehr.common.model.Provider;
import org.oscarehr.common.service.BillingONService;
import org.oscarehr.managers.BillingManager;
import org.oscarehr.managers.SecurityInfoManager;
import org.oscarehr.util.LoggedInInfo;
import org.oscarehr.util.SpringUtils;
import org.oscarehr.ws.rest.conversion.ProviderConverter;
import org.oscarehr.ws.rest.conversion.ServiceTypeConverter;
import org.oscarehr.ws.rest.to.AbstractSearchResponse;
import org.oscarehr.ws.rest.to.GenericRESTResponse;
import org.oscarehr.ws.rest.to.InvoiceCreateResponse;
import org.oscarehr.ws.rest.to.model.BillingInvoiceTo1;
import org.oscarehr.ws.rest.to.model.BillingItemTo1;
import org.oscarehr.ws.rest.to.model.ProviderTo1;
import org.oscarehr.ws.rest.to.model.ServiceTypeTo;
import org.springframework.beans.factory.annotation.Autowired;

import oscar.OscarProperties;
import oscar.log.LogAction;
import oscar.log.LogConst;
import oscar.oscarBilling.ca.on.data.BillingDataHlp;
import oscar.oscarBilling.ca.on.pageUtil.BillingCorrectionUtil;
import oscar.util.ChangedField;

import java.math.BigDecimal;
import java.text.ParseException;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

@Path("/billing")
public class BillingService extends AbstractServiceImpl {

	@Autowired
    private BillingManager billingManager;
	@Autowired
    private ProviderDao providerDao;
    @Autowired
    private DemographicDao demographicDao;
    @Autowired
    private BillingONCHeader1Dao billingONCHeader1Dao;
    @Autowired
    private BillingServiceDao billingServiceDao;
    @Autowired
    private OscarAppointmentDao appointmentDao;
    @Autowired
    private DxresearchDAO dxresearchDAO;
    @Autowired
    private BillingONExtDao billingONExtDao;
    @Autowired
    private BillingOnTransactionDao billingOnTransactionDao;
    @Autowired
    private BillingONService billingONService;
    @Autowired
    private SecurityInfoManager securityInfoManager;

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
    
    @GET
    @Path("/getBillingProviders")
    @Produces("application/json")
    public AbstractSearchResponse<ProviderTo1> getBillingProviders() {
        AbstractSearchResponse<ProviderTo1> response = new AbstractSearchResponse<ProviderTo1>();
        
        LoggedInInfo loggedInInfo = getLoggedInInfo();
	    List<ProviderTo1> billableProviderResults = new ArrayList<ProviderTo1>();
        ProviderConverter providerConverter = new ProviderConverter();
        
        for (Provider provider : providerDao.getProvidersWithNonEmptyCredentials()) {
            billableProviderResults.add(providerConverter.getAsTransferObject(loggedInInfo, provider));
        }

        response.setContent(billableProviderResults);
        response.setTotal(billableProviderResults.size());

        return response;
    }

    @POST
    @Path("/createInvoice")
    @Produces(MediaType.APPLICATION_JSON)
    @Consumes(MediaType.APPLICATION_JSON)
    public GenericRESTResponse createInvoice(BillingInvoiceTo1 invoiceRequest) {
        LoggedInInfo loggedInInfo = getLoggedInInfo();
        if (!securityInfoManager.hasPrivilege(loggedInInfo, "_billing", "w", invoiceRequest.getDemographicNo())) {
            throw new IllegalArgumentException("Missing required security object (_billing)");
        }
        Provider loggedInProvider = loggedInInfo.getLoggedInProvider();
        
        try {
            Provider billingProvider = providerDao.getProvider(invoiceRequest.getProviderNo());
            Demographic billedDemographic = demographicDao.getDemographicById(invoiceRequest.getDemographicNo());
            Appointment billedAppointment = appointmentDao.find(invoiceRequest.getAppointmentNo());
            
            BillingONCHeader1 invoiceToFill = invoiceRequest.toBillingONCHeader1();
            invoiceToFill.setHeaderId(0);
            BillingONCHeader1 invoice = prepareInvoiceRequestForSave(invoiceRequest, invoiceToFill, billingProvider, billedDemographic, billedAppointment);
            saveInvoice(invoice, billedDemographic, loggedInProvider, billedAppointment);

            if (invoice.getId() != null) {
                return new InvoiceCreateResponse(true, invoice.getId().toString(), invoice.getId());
            } else {
                return new InvoiceCreateResponse(false, "Error creating invoice.", null);
            }
        } catch (IllegalArgumentException e) {
            return new InvoiceCreateResponse(true, e.getMessage(), null);
        }
        
    }

    @POST
    @Path("/updateInvoice/{invoiceId}")
    @Produces(MediaType.APPLICATION_JSON)
    @Consumes(MediaType.APPLICATION_JSON)
    public GenericRESTResponse updateInvoice(BillingInvoiceTo1 invoiceUpdateRequest, @PathParam("invoiceId") Integer invoiceId) {
        LoggedInInfo loggedInInfo = getLoggedInInfo();
        if (!securityInfoManager.hasPrivilege(loggedInInfo, "_billing", "w", invoiceUpdateRequest.getDemographicNo())) {
            throw new IllegalArgumentException("Missing required security object (_billing)");
        }
        BillingONCHeader1 existingBillingHeader1 = billingONCHeader1Dao.find(invoiceId);
        if (existingBillingHeader1 == null) {
            throw new IllegalArgumentException("Cannot update invoice, past invoice with id " + invoiceId + " does not exist.");
        }
//        Provider loggedInProvider = loggedInInfo.getLoggedInProvider();
        try {
            Provider billingProvider = providerDao.getProvider(invoiceUpdateRequest.getProviderNo());
            Demographic billedDemographic = demographicDao.getDemographicById(invoiceUpdateRequest.getDemographicNo());
            Appointment billedAppointment = appointmentDao.find(invoiceUpdateRequest.getAppointmentNo());

            BillingONCHeader1 oldBillingHeader1 = new BillingONCHeader1(existingBillingHeader1);
            
            BillingONCHeader1 updateBillingHeader1 = prepareInvoiceRequestForSave(invoiceUpdateRequest, existingBillingHeader1, billingProvider, billedDemographic, billedAppointment);

            BillingONService billingONService = (BillingONService) SpringUtils.getBean("billingONService");
            billingONService.updateTotal(updateBillingHeader1);

            //Add Existing state of Invoice to Billing Repository
            BillingONRepoDao billRepoDao = (BillingONRepoDao) SpringUtils.getBean("billingONRepoDao");
            billRepoDao.createBillingONCHeader1Entry(updateBillingHeader1, getLocale());

//            billingONCHeader1Dao.merge(newBillingHeader1);
            billingONCHeader1Dao.merge(updateBillingHeader1);
            List<ChangedField> changedFields = ChangedField.getChangedFieldsAndValues(oldBillingHeader1, updateBillingHeader1);
            
//
            // set old 'useBillTo' billing ext to archived
            BillingONExt billExt = billingONExtDao.getUseBillTo(updateBillingHeader1);
            if (billExt != null) {
                billExt.setStatus('0');
                billingONExtDao.merge(billExt);
            }
//
            if (!changedFields.isEmpty()) {
                LogAction.addLog(loggedInInfo, LogConst.UPDATE, LogConst.CON_BILL,
                    "billingNo=" + invoiceId, String.valueOf(updateBillingHeader1.getDemographicNo()), changedFields);
            }


            return new InvoiceCreateResponse(true, invoiceId.toString(), invoiceId);
        } catch (IllegalArgumentException e) {
            return new InvoiceCreateResponse(true, e.getMessage(), null);
        }
    }
    
    private BillingONCHeader1 prepareInvoiceRequestForSave(BillingInvoiceTo1 invoiceRequest, BillingONCHeader1 invoiceToFill, Provider billingProvider, Demographic billedDemographic, Appointment billedAppointment) throws IllegalArgumentException {

        if (billingProvider == null) {
            throw new IllegalArgumentException("Cannot create invoice, billing provider with id " + invoiceRequest.getProviderNo() + " does not exist.");
        }
        if (billedDemographic == null) {
            throw new IllegalArgumentException("Cannot create invoice, billed demographic with id " + invoiceRequest.getDemographicNo() + " does not exist.");
        }
        if (invoiceRequest.getBillingItems().isEmpty()) {
            throw new IllegalArgumentException("Cannot create invoice, no items billed.");
        }
        
        // Set invoice demographic info
        invoiceToFill.setHin(billedDemographic.getHin());
        invoiceToFill.setVer(billedDemographic.getVer());
        invoiceToFill.setDob(billedDemographic.getFormattedDob().replaceAll("-", ""));
        invoiceToFill.setDemographicName(billedDemographic.getDisplayName());
        if ("F".equals(billedDemographic.getSex())) {
            invoiceToFill.setSex("2");
        } else {
            invoiceToFill.setSex("1");
        }
        
        // Set invoice billing provider info
        invoiceToFill.setProviderOhipNo(billingProvider.getOhipNo());
        invoiceToFill.setProviderRmaNo(billingProvider.getRmaNo());
        invoiceToFill.setAsstProviderNo("");
        invoiceToFill.setCreator(billingProvider.getPractitionerNo());
        
        // Set clinic info
        invoiceToFill.setApptProviderNo("none");
        if (billedAppointment != null) { invoiceToFill.setApptProviderNo(billedAppointment.getProviderNo()); }

        invoiceToFill.setBillingDate(new Date());
        invoiceToFill.setBillingTime(new Date());
        invoiceToFill.setStatus("O");
        
        BigDecimal totalFee = new BigDecimal("0.00");
        List<BillingONItem> newBillingItems = new ArrayList<BillingONItem>();
        // Create a copy of the existing billing items to track new items
        List<BillingONItem> oldBillingItems = new ArrayList<BillingONItem>(invoiceToFill.getBillingItems());

        for (BillingItemTo1 requestItem : invoiceRequest.getBillingItems()) {
            org.oscarehr.common.model.BillingService service = billingServiceDao.searchBillingCode(requestItem.getServiceCode(), invoiceToFill.getProvince());
            if (service == null) {
                throw new IllegalArgumentException("Cannot create invoice, billed service number " + requestItem.getServiceCode() + " does not exist.");
            } else {
                BillingONItem billingItem = new BillingONItem();
                billingItem.setTranscId(requestItem.getTransactionId());
                billingItem.setRecId(requestItem.getRecordId());
                billingItem.setServiceCode(requestItem.getServiceCode());
                billingItem.setStatus(requestItem.getStatus());
                billingItem.setServiceDate(invoiceToFill.getBillingDate());
                billingItem.setDx(requestItem.getDx());
                billingItem.setServiceCount(requestItem.getServiceCount().toString());
                BigDecimal fee = new BigDecimal(requestItem.getServiceCount()).multiply(new BigDecimal(service.getValue()));
                totalFee = totalFee.add(fee);
                billingItem.setFee(fee.setScale(2, BigDecimal.ROUND_HALF_UP).toPlainString());
                
                if (invoiceToFill.getId() != null) {
                    billingItem.setCh1Id(invoiceToFill.getId());
                }
                if (invoiceToFill.getTranscId() != null) {
                    billingItem.setTranscId(invoiceToFill.getTranscId());
                }
                
                if (oldBillingItems.contains(billingItem)) {
                    // Update an existing billing items  that is now modified, not deleted.
                    int index = oldBillingItems.indexOf(billingItem);
                    BillingONItem existingItem = oldBillingItems.get(index);

                    BillingCorrectionUtil.processUpdatedBillingItem(existingItem, billingItem, invoiceToFill.getBillingDate(), getLocale());
                } else {
                    invoiceToFill.getBillingItems().add(billingItem);
                }
                newBillingItems.add(billingItem);
            }
        }

        // Update status on existing billing items now removed
        for (BillingONItem oldBillingItem : oldBillingItems) {
            if (!newBillingItems.contains(oldBillingItem)){
                oldBillingItem.setStatus("D");
            }
        }
        
        invoiceToFill.setTotal(totalFee.setScale(2, BigDecimal.ROUND_HALF_UP));
        invoiceToFill.setPaid(new BigDecimal("0.00").setScale(2, BigDecimal.ROUND_HALF_UP));

        boolean isThirdParty = invoiceToFill.getPayProgram().substring(0, 3).matches(BillingDataHlp.BILLINGMATCHSTRING_3RDPARTY);
        if (isThirdParty && "ODP".equalsIgnoreCase(invoiceToFill.getPayProgram())) {
            String payProgram = billedDemographic.getHcType().equals("ON") ? "HCP" : "RMB";
            invoiceToFill.setPayProgram(payProgram);
        }
        return invoiceToFill;
    }
    
    private void saveInvoice(BillingONCHeader1 invoice, Demographic billedDemographic, Provider loggedInProvider, Appointment billedAppointment) {
        boolean isThirdParty = invoice.getPayProgram().substring(0, 3).matches(BillingDataHlp.BILLINGMATCHSTRING_3RDPARTY);
        
        billingONCHeader1Dao.persist(invoice);

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
