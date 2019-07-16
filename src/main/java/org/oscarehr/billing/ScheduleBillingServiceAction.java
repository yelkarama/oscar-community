package org.oscarehr.billing;

import net.sf.json.JSONObject;
import org.apache.commons.lang.CharUtils;
import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.actions.DispatchAction;
import org.oscarehr.common.dao.BillingServiceDao;
import org.oscarehr.common.dao.BillingServiceScheduleDao;
import org.oscarehr.common.model.BillingServiceSchedule;
import org.oscarehr.managers.SecurityInfoManager;
import org.oscarehr.util.LoggedInInfo;
import org.oscarehr.util.MiscUtils;
import org.oscarehr.util.SpringUtils;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.List;

public class ScheduleBillingServiceAction extends DispatchAction {
    static Logger logger = MiscUtils.getLogger();
    private SecurityInfoManager securityInfoManager = SpringUtils.getBean(SecurityInfoManager.class);
    private BillingServiceDao billingServiceDao = SpringUtils.getBean(BillingServiceDao.class);
    private BillingServiceScheduleDao billingServiceScheduleDao = SpringUtils.getBean(BillingServiceScheduleDao.class);
    private SimpleDateFormat df = new SimpleDateFormat("yyyy-MM-dd");
    private Calendar today = Calendar.getInstance();
    private String todayStr = df.format(today.getTime());
    
    public ActionForward unspecified(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response)  throws ServletException, IOException {
        LoggedInInfo loggedInInfo = LoggedInInfo.getLoggedInInfoFromSession(request);
        Boolean providerView = Boolean.valueOf(StringUtils.trimToNull(request.getParameter("providerView")));

        if (!providerView && !securityInfoManager.hasPrivilege(loggedInInfo, "_admin", "w", null)) {
            throw new SecurityException("missing required security object (_admin)");
        } else if (!securityInfoManager.hasPrivilege(loggedInInfo, "_billing", "w", null)) {
            throw new SecurityException("missing required security object (_billing)");
        }
        
        List<BillingServiceSchedule> billingServiceSchedule = getServices(providerView ? loggedInInfo.getLoggedInProviderNo() : null, true, true);
        
        request.setAttribute("schedule", billingServiceSchedule);
        request.setAttribute("providerView", providerView);
        
        if (providerView) {
            request.setAttribute("scheduleClinic", getServices(null, true, false));
        }
        
        return mapping.findForward("success");
    }

    public ActionForward remove(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) {
        LoggedInInfo loggedInInfo = LoggedInInfo.getLoggedInInfoFromSession(request);
        Boolean providerView = Boolean.valueOf(StringUtils.trimToNull(request.getParameter("providerView")));
        
        if (!providerView && !securityInfoManager.hasPrivilege(loggedInInfo, "_admin", "w", null)) {
            throw new SecurityException("missing required security object (_admin)");
        } else if (!securityInfoManager.hasPrivilege(loggedInInfo, "_billing", "w", null)) {
            throw new SecurityException("missing required security object (_billing)");
        }

        BillingServiceSchedule serviceSchedule = null;
        Integer id = StringUtils.trimToNull(request.getParameter("id")) != null ? Integer.parseInt(request.getParameter("id")) : 0;
        Boolean success = false;
        HashMap<String, Object> returnObject = new HashMap<String, Object>();
        JSONObject jsonObject = null;

        try {
            serviceSchedule = billingServiceScheduleDao.find(id);
            serviceSchedule.setDeleted(true);
            
            billingServiceScheduleDao.saveEntity(serviceSchedule);
            success = true;
        } catch (Exception e) {
            logger.error(e);
        } finally {
            returnObject.put("success", success);
            returnObject.put("id", id);
            jsonObject = JSONObject.fromObject(returnObject);
        }

        try {
            jsonObject.write(response.getWriter());
        } catch (IOException e) {
            MiscUtils.getLogger().error("JSON WRITER ERROR", e);
        }

        return null;
    }
    
    public ActionForward save(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) {
        LoggedInInfo loggedInInfo = LoggedInInfo.getLoggedInInfoFromSession(request);
        Boolean providerView = Boolean.valueOf(StringUtils.trimToNull(request.getParameter("providerView")));

        if (!providerView && !securityInfoManager.hasPrivilege(loggedInInfo, "_admin", "w", null)) {
            throw new SecurityException("missing required security object (_admin)");
        } else if (!securityInfoManager.hasPrivilege(loggedInInfo, "_billing", "w", null)) {
            throw new SecurityException("missing required security object (_billing)");
        }

        BillingServiceSchedule serviceSchedule = null;
        Integer id = StringUtils.trimToNull(request.getParameter("id")) != null ? Integer.parseInt(request.getParameter("id")) : 0;
        String time = request.getParameter("billingTime");
        String serviceCode = request.getParameter("serviceCode");
        
        if (StringUtils.isNotEmpty(serviceCode) && serviceCode.length() == 5) {
            if (!CharUtils.isAsciiAlpha(serviceCode.charAt(0)) ||
                    !CharUtils.isAsciiAlpha(serviceCode.charAt(4))) {
                return null;
            }
            
            for (int i = 1; i < 4; i++) {
                if (!CharUtils.isAsciiNumeric(serviceCode.charAt(i))) {
                    return null;
                }
            }
        } else {
            return null;
        }

        HashMap<String, Object> returnObject = new HashMap<String, Object>();
        Boolean newServiceSchedule = false;
        Boolean success = false;
        JSONObject jsonObject = null;

        try {
            serviceSchedule = billingServiceScheduleDao.find(id);

            if (serviceSchedule == null) {
                serviceSchedule = new BillingServiceSchedule();
                serviceSchedule.setServiceCode(serviceCode);
                if (providerView) {
                    serviceSchedule.setProviderNo(loggedInInfo.getLoggedInProviderNo());
                }
                newServiceSchedule = true;
            }
            serviceSchedule.setBillingTime(time);


            serviceSchedule = billingServiceScheduleDao.saveEntity(serviceSchedule);
            serviceSchedule.setServiceDescription(StringUtils.trimToEmpty(billingServiceDao.getCodeDescription(serviceSchedule.getServiceCode(), todayStr)));
            success = true;
        } catch (Exception e) {
            logger.error(e);
        } finally {
            returnObject.put("success", success);
            returnObject.put("isNew", newServiceSchedule);
            returnObject.put("serviceItem", serviceSchedule);
            jsonObject = JSONObject.fromObject(returnObject);
        }

        try {
            jsonObject.write(response.getWriter());
        } catch (IOException e) {
            MiscUtils.getLogger().error("JSON WRITER ERROR", e);
        }

        return null;
    }

    private List<BillingServiceSchedule> getServices(String providerNo) {
        return getServices(providerNo, false, false);
    }
    
    private List<BillingServiceSchedule> getServices(String providerNo, Boolean withDescription, Boolean providerView) {
        List<BillingServiceSchedule> billingServiceSchedule = null;
        
        if (StringUtils.trimToNull(providerNo) != null) {
            billingServiceSchedule = billingServiceScheduleDao.getAll(providerNo);
        } else {
            billingServiceSchedule = billingServiceScheduleDao.getAllClinic();
        }

        if (withDescription) {
            for (BillingServiceSchedule serviceSchedule : billingServiceSchedule) {
                String serviceCode = serviceSchedule.getServiceCode();
                serviceSchedule.setServiceDescription(StringUtils.trimToEmpty(billingServiceDao.getCodeDescription(serviceCode, todayStr)));
            }
        }
        
        return billingServiceSchedule;
    }
    
    private static List<BillingServiceSchedule> filterActive(List<BillingServiceSchedule> scheduleList, Date appointmentDateTime) {
        List<BillingServiceSchedule> billingServiceSchedule = new ArrayList<BillingServiceSchedule>();
        SimpleDateFormat timeFormat = new SimpleDateFormat("HH:mm:ss");


        Calendar appointmentTime = Calendar.getInstance();
        if (appointmentDateTime != null) {
            appointmentTime.setTime(appointmentDateTime);

            for (BillingServiceSchedule schedule : scheduleList) {
                try {
                    Calendar billingTime = Calendar.getInstance();
                    billingTime.setTime(timeFormat.parse(schedule.getBillingTime()));
                    billingTime.set(Calendar.DAY_OF_MONTH, appointmentTime.get(Calendar.DAY_OF_MONTH));
                    billingTime.set(Calendar.MONTH, appointmentTime.get(Calendar.MONTH));
                    billingTime.set(Calendar.YEAR, appointmentTime.get(Calendar.YEAR));
                    
                    if (appointmentTime.getTimeInMillis() - billingTime.getTimeInMillis() >= 0 || appointmentTime.get(Calendar.HOUR_OF_DAY) < 8) {
                        billingServiceSchedule.add(schedule);
                    }
                } catch (ParseException pe) {
                    pe.printStackTrace();
                }

            }
        }

        return billingServiceSchedule;
    }

    public static List<BillingServiceSchedule> load(String providerNo, Date appointmentDate) throws ServletException, IOException {
        BillingServiceScheduleDao billingServiceScheduleDao = SpringUtils.getBean(BillingServiceScheduleDao.class);
        List<BillingServiceSchedule> billingServiceSchedule = new ArrayList<BillingServiceSchedule>();

        if (StringUtils.trimToNull(providerNo) == null) {
            billingServiceSchedule = filterActive((new ScheduleBillingServiceAction().getServices(null)), appointmentDate);
        } else {
            List<String> codes = new ArrayList<>();
            List<BillingServiceSchedule> activeProviderSchedule = filterActive((new ScheduleBillingServiceAction().getServices(providerNo)), appointmentDate);

            for (BillingServiceSchedule providerSchedule : activeProviderSchedule) {
                codes.add(providerSchedule.getServiceCode());
            }

            billingServiceSchedule.addAll(activeProviderSchedule);
            billingServiceSchedule.addAll(filterActive(billingServiceScheduleDao.getAllClinic(codes), appointmentDate));
        }

        return billingServiceSchedule;
    }
}

