package org.oscarehr.common.web;

import org.apache.log4j.Logger;
import org.apache.struts.action.Action;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.oscarehr.common.dao.BillingServiceDao;
import org.oscarehr.common.model.BillingService;
import org.oscarehr.util.SpringUtils;
import oscar.util.StringUtils;

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

public class SearchBillingServiceAutoCompleteAction extends Action {
    private static Logger logger = Logger.getLogger(SearchBillingServiceAutoCompleteAction.class);
    private BillingServiceDao billingServiceDao = SpringUtils.getBean(BillingServiceDao.class);
    private SimpleDateFormat dateFormat  = new SimpleDateFormat("yyyyMMdd");

    @Override
    public ActionForward execute(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws IOException {
        Calendar billingDate = Calendar.getInstance();
        Date billDate = new Date();
        String billingDateStr = StringUtils.noNull(request.getParameter("billingDate"));
        String keyword = request.getParameter("term");
        String region = StringUtils.noNull(request.getParameter("region"));
        //boolean returnJson = Boolean.parseBoolean(request.getParameter("returnJson"));

        if (StringUtils.filled(keyword)) {
            keyword = keyword + "%";
        }
        
        if (region.isEmpty()) {
            region = "ON";
        }
        

        if (!billingDateStr.isEmpty()) {
            try {
                billDate = dateFormat.parse(billingDateStr);
            } catch (ParseException pe) {
                logger.error("Error parsing date string: " + billingDateStr);
            }
        }

        billingDate.setTime(billDate);
        
        List<BillingService> services = billingServiceDao.search(keyword, region, billingDate.getTime());
        List<HashMap<String, String>> results = new ArrayList<HashMap<String,String>>();

        for(BillingService service : services){
            HashMap<String,String> h = new HashMap<String,String>();
            h.put("serviceCode", service.getServiceCode());
            h.put("description", StringUtils.noNull(service.getDescription()));
            
            results.add(h);
        }

        HashMap<String,List<HashMap<String, String>>> serviceResults = new HashMap<String,List<HashMap<String, String>>>();
        serviceResults.put("results", results);
        response.setContentType("text/x-json");
        response.getWriter().print(formatJSON(results));
        response.getWriter().flush();
        return null;
    }

    private String formatJSON(List<HashMap<String, String>> info) {
        StringBuilder json = new StringBuilder("[");

        HashMap<String, String>record;
        int size = info.size();
        for( int idx = 0; idx < size; ++idx) {
            record = info.get(idx);
            json.append("{\"label\":\"" + record.get("serviceCode") + " - " + record.get("description") + "\",\"description\":\"" + record.get("description") + "\",\"value\":\"" + record.get("serviceCode") + "\"}");

            if(idx < size-1) {
                json.append(",");
            }
        }
        json.append("]");
        
        return json.toString();
    }

}
