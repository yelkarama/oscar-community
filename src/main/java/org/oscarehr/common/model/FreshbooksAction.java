package org.oscarehr.common.model;

import org.apache.struts.action.*;
import org.apache.struts.action.Action;
import org.oscarehr.billing.CA.ON.model.Billing3rdPartyAddress;

import org.oscarehr.common.dao.*;
import org.oscarehr.managers.SecurityInfoManager;
import org.oscarehr.util.LoggedInInfo;
import org.oscarehr.util.SpringUtils;
import oscar.oscarDemographic.data.DemographicData;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

public class FreshbooksAction extends Action 
{
    private SecurityInfoManager securityInfoManager = SpringUtils.getBean(SecurityInfoManager.class);
    FreshbooksService fs = new FreshbooksService();
    
    public ActionForward execute(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException 
    {
        if (!securityInfoManager.hasPrivilege(LoggedInInfo.getLoggedInInfoFromSession(request), "_msg", "w", null)) 
        {
            throw new SecurityException("missing required security object (_msg)");
        }
        
        LoggedInInfo loggedInInfo = LoggedInInfo.getLoggedInInfoFromSession(request);
        String action = request.getParameter("submit") != null ? request.getParameter("submit") : "";

        if (action.equalsIgnoreCase("validate"))
        {
            validate(request, loggedInInfo);
        }

        String freshbooksURL;
        String freshbooksAccess = (String)request.getAttribute("freshbooksAccess")==null?"true":(String)request.getAttribute("freshbooksAccess");
        if (freshbooksAccess.equals("true"))
        {
            freshbooksURL = "https://my.freshbooks.com/#/invoice/"+request.getAttribute("freshbooksProvId")+"-"+request.getAttribute("invoiceId") + "/edit";
        }
        else if (freshbooksAccess.equals("false401"))
        {
            freshbooksURL = "http://www.kaiinnovations.com/oscar/support.html?auth=401";
        }
        else
        {
            freshbooksURL = "http://www.kaiinnovations.com/oscar/support.html";
        }

        response.getWriter().write(freshbooksURL);
        
        return null;
    }
    
    public ActionForward validate(HttpServletRequest request, LoggedInInfo loggedInInfo)
    {
        FreshbooksAppointmentInfoDao faid = SpringUtils.getBean(FreshbooksAppointmentInfoDao.class);

        OscarAppointmentDao oad = SpringUtils.getBean(OscarAppointmentDao.class);
        
        FreshbooksService fs = new FreshbooksService();
        String demoEmail = request.getParameter("email")==null?"":request.getParameter("email");
        String provNo = request.getParameter("provNo")==null?"":request.getParameter("provNo");
        String demoNo = request.getParameter("demoNo")==null?"":request.getParameter("demoNo");
        String apptNo = request.getParameter("apptNo")==null?"":request.getParameter("apptNo");
        String apptDate = request.getParameter("serviceDate")==null?"":request.getParameter("serviceDate");
        Appointment appt = oad.find(Integer.parseInt(apptNo));
        String apptProvNo = "";
        if (appt!=null)
        {
            apptProvNo = appt.getProviderNo()==null?"":appt.getProviderNo();
        }
        Boolean isNewEmail = Boolean.parseBoolean(request.getParameter("isNewEmail"));

        Demographic demo;
        DemographicData dd = new DemographicData();
        DemographicExtDao ded = SpringUtils.getBean(DemographicExtDao.class);
        DemographicExt demoExt = ded.getDemographicExt(Integer.parseInt(demoNo), "insurance_company");
        Billing3rdPartyAddressDao billing3rdPartyAddressDao = SpringUtils.getBean(Billing3rdPartyAddressDao.class);
        Billing3rdPartyAddress b3pa;
        FreshbooksInsuranceCompaniesDao ficd = SpringUtils.getBean(FreshbooksInsuranceCompaniesDao.class);
        FreshbooksInsuranceCompanies fic;
        
        if (isNewEmail)
        {
            dd.setDemographicEmail(loggedInInfo, demoNo, demoEmail);
        }
            
        if (!provNo.isEmpty() && !provNo.equals(""))
        {
            provNo = provNo.substring(0, provNo.indexOf("|"));
        }

        UserPropertyDAO userPropertyDAO = (UserPropertyDAO) SpringUtils.getBean("UserPropertyDAO");
        UserProperty uProp = userPropertyDAO.getProp(provNo ,UserProperty.PROVIDER_FRESHBOOKS_ID);

        String provFreshbooksId = "";
        String clientFreshbooksId, companyClientFreshbooksId;
        String invoiceId = "";

        if (uProp != null && uProp.getValue() != null)
        {
            provFreshbooksId = uProp.getValue();
        }

        if (!provFreshbooksId.equals(""))
        {
            if (demoExt != null && demoExt.getValue()!=null && !demoExt.getValue().isEmpty()) // If demo has a preference to bill to insurance company
            {
                fic = ficd.getByCompanyIdAndProviderNo(Integer.parseInt(demoExt.getValue()), provNo);

                if (fic == null || fic.getFreshbooksId()==null || fic.getFreshbooksId().equals(""))
                {
                    b3pa = billing3rdPartyAddressDao.find(Integer.parseInt(demoExt.getValue()));
                    companyClientFreshbooksId = fs.createClient(provFreshbooksId, demoNo, b3pa, false, false);
                    if (!companyClientFreshbooksId.equalsIgnoreCase(""))
                    {
                        fic = new FreshbooksInsuranceCompanies();
                        fic.setCompanyId(b3pa.getId().toString());
                        fic.setProviderNo(provNo);
                        fic.setFreshbooksId(companyClientFreshbooksId);
                        ficd.merge(fic);
                    }
                    else
                    {
                        request.setAttribute("freshbooksAccess", "false401");
                    }
                }
                else
                {
                    b3pa = billing3rdPartyAddressDao.find(Integer.parseInt(demoExt.getValue()));
                    companyClientFreshbooksId = fic.getFreshbooksId();
                }

                demoExt = ded.getDemographicExtKeyAndProvider(Integer.parseInt(demoNo), "freshbooksId", provNo);

                if (demoExt == null || demoExt.getValue()==null || demoExt.getValue().equals(""))
                {
                    clientFreshbooksId = fs.createClient(provFreshbooksId, demoNo, b3pa, true, false);
                    if (!clientFreshbooksId.equalsIgnoreCase(""))
                    {
                        DemographicExt d = new DemographicExt();
                        d.setProviderNo(provNo);
                        d.setDemographicNo(Integer.parseInt(demoNo));
                        d.setKey("freshbooksId");
                        d.setValue(clientFreshbooksId);
                        d.setDateCreated(new java.util.Date());
                        ded.persist(d);
                    }
                    else
                    {
                        request.setAttribute("freshbooksAccess", "false401");
                    }
                }

                if (uProp != null && provFreshbooksId != null & !provFreshbooksId.equals("")) {
                    demo = dd.getDemographic(loggedInInfo, demoNo);
                    invoiceId = fs.createInsuranceInvoice(provFreshbooksId, demo, companyClientFreshbooksId, apptDate, false);
                    if (!invoiceId.equalsIgnoreCase(""))
                    {
                        FreshbooksAppointmentInfo fai = new FreshbooksAppointmentInfo();
                        fai.setAppointmentNo(Integer.parseInt(apptNo));
                        fai.setAppointmentProvider(apptProvNo);
                        fai.setFreshbooksInvoiceId(invoiceId);
                        fai.setProviderFreshbooksId(provFreshbooksId);
                        faid.persist(fai);
                    }
                    else
                    {
                        request.setAttribute("freshbooksAccess", "false401");
                    }

                    /*BillingSavePrep bObj = new BillingSavePrep();
                    bObj.updateApptStatus(apptNo, "B", loggedInInfo.getLoggedInProviderNo());*/
                }
            }
            else
            {
                demoExt = ded.getDemographicExtKeyAndProvider(Integer.parseInt(demoNo), "freshbooksId", provNo);

                if (demoExt != null && demoExt.getValue() != null && !demoExt.getValue().isEmpty()) {
                    clientFreshbooksId = demoExt.getValue();
                } else {
                    clientFreshbooksId = fs.createClient(provFreshbooksId, demoNo, new Billing3rdPartyAddress(),true, false);

                    if (!clientFreshbooksId.equalsIgnoreCase(""))
                    {
                        DemographicExt d = new DemographicExt();
                        d.setProviderNo(provNo);
                        d.setDemographicNo(Integer.parseInt(demoNo));
                        d.setKey("freshbooksId");
                        d.setValue(clientFreshbooksId);
                        d.setDateCreated(new java.util.Date());
                        ded.persist(d);
                    }
                    else
                    {
                        request.setAttribute("freshbooksAccess", "false401");
                    }
                }

                if (uProp != null && provFreshbooksId != null && !provFreshbooksId.equals("")) {
                    invoiceId = fs.createInvoice(provFreshbooksId, clientFreshbooksId, apptDate, false);
                    if (!invoiceId.equalsIgnoreCase(""))
                    {
                        FreshbooksAppointmentInfo fai = new FreshbooksAppointmentInfo();
                        fai.setAppointmentNo(Integer.parseInt(apptNo));
                        fai.setAppointmentProvider(apptProvNo);
                        fai.setFreshbooksInvoiceId(invoiceId);
                        fai.setProviderFreshbooksId(provFreshbooksId);
                        faid.persist(fai);
                    }
                    else
                    {
                        request.setAttribute("freshbooksAccess", "false401");
                    }

                    /*BillingSavePrep bObj = new BillingSavePrep();
                    bObj.updateApptStatus(apptNo, "B", loggedInInfo.getLoggedInProviderNo());*/
                }
            }
        }
        else
        {
            request.setAttribute("freshbooksAccess", "false");
        }

            request.setAttribute("invoiceId", invoiceId==null?"":invoiceId);
            request.setAttribute("freshbooksProvId", uProp==null?"":provFreshbooksId==null?"":provFreshbooksId);
        
        return null;
    }
}
