/**
 * KAI INNOVATIONS
 */

package oscar.oscarMessenger.pageUtil;

import org.apache.log4j.Logger;
import org.apache.struts.action.Action;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.oscarehr.PMmodule.dao.ProviderDao;
import org.oscarehr.common.dao.MessageFolderDao;
import org.oscarehr.common.dao.MessageResponderDao;
import org.oscarehr.common.dao.MessageTblDao;
import org.oscarehr.common.model.MessageResponder;
import org.oscarehr.common.model.Provider;
import org.oscarehr.managers.SecurityInfoManager;
import org.oscarehr.util.LoggedInInfo;
import org.oscarehr.util.MiscUtils;
import org.oscarehr.util.SpringUtils;
import oscar.oscarMessenger.data.MsgDisplayMessage;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

public class MsgSearchProviderAction extends Action {
    private SecurityInfoManager securityInfoManager = SpringUtils.getBean(SecurityInfoManager.class);
    private ProviderDao providerDao = SpringUtils.getBean(ProviderDao.class);
    private MessageTblDao messageTblDao = SpringUtils.getBean(MessageTblDao.class);
    private static Logger logger = MiscUtils.getLogger();

    public ActionForward execute(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        if (!securityInfoManager.hasPrivilege(LoggedInInfo.getLoggedInInfoFromSession(request), "_msg", "w", null)) {
            throw new SecurityException("missing required security object (_msg)");
        }
        LoggedInInfo loggedInInfo = LoggedInInfo.getLoggedInInfoFromSession(request);
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
        MsgSessionBean bean = (MsgSessionBean) request.getSession().getAttribute("msgSessionBean");
        
        String providerName = request.getParameter("providerName");
        String startDateString = request.getParameter("startDay");
        String endDateString = request.getParameter("endDay");
        if (request.getParameter("providerName") == null) {
            providerName = bean.getSearchProviderName();
            startDateString = bean.getSearchStartDateString();
            endDateString = bean.getSearchEndDateString();
        }
        
        Date startDate = null;
        Date endDate = null;
        String orderBy = request.getParameter("orderby");
        if (orderBy != null) {
            if (orderBy.equals(bean.getSearchOrderBy())) {
                orderBy = "!" + request.getParameter("orderby");
            } else {
                orderBy = request.getParameter("orderby");
            }
        }
        int page = 1;
        if (request.getParameter("pageNum") != null) {
            page = Integer.parseInt(request.getParameter("pageNum"));
        }
        
        try {
            if (startDateString != null && !startDateString.isEmpty()) { startDate = sdf.parse(startDateString); }
        } catch (ParseException e) {
            logger.error(e.getMessage());
        }
        try {
            if (endDateString != null && !endDateString.isEmpty()) { endDate = sdf.parse(endDateString); }
        } catch (ParseException e) {
            logger.error(e.getMessage());
        }
        
        String firstName;
        String lastName;
        if(providerName.contains(",")) {
            firstName = providerName.substring(providerName.indexOf(",") + 1).trim() + "%";
            lastName = providerName.substring(0, providerName.indexOf(",")).trim() + "%";
        } else {
            firstName = "%";
            lastName = providerName.trim() + "%";
        }

        List<Provider> providerResults = providerDao.getActiveProviderLikeFirstLastName(firstName, lastName);
        if (providerResults.isEmpty()) {
            request.setAttribute("noResults", true);
            request.setAttribute("searchedProviderName", providerName);
            request.setAttribute("searchedStartDateString", startDateString);
            request.setAttribute("searchedEndDateString", endDateString);
            return mapping.findForward("noResults");
        } else {
            List<String> providerNos = new ArrayList<String>();
            for (Provider p : providerResults) {
                providerNos.add(p.getProviderNo());
            }
            List<MsgDisplayMessage> messages = messageTblDao.findBySentToProviderAndStartDateAndEndDate(providerNos, startDate, endDate, orderBy, page);
            Integer totalResults = messageTblDao.findBySentToProviderAndStartDateAndEndDateCount(providerNos, startDate, endDate);

            if (providerResults.size() == 1) {
                request.setAttribute("resultsMessage", providerResults.get(0).getFormattedName() + "'s inbox:");
            } else {
                String resultsMessage = "Results for clinician name \"" + providerName + "\"";
                if (startDate != null) { resultsMessage += " after " + startDateString; }
                if (endDate != null) { resultsMessage += " before " + endDateString; }
                request.setAttribute("resultsMessage", resultsMessage);
            }

            bean.setSearchProviderName(providerName);
            bean.setSearchStartDate(startDate);
            bean.setSearchEndDate(endDate);
            bean.setSearchEndDate(endDate);
            bean.setSearchResults(messages);
            bean.setSearchPageNum(page);
            bean.setSearchTotalResults(totalResults);
            bean.setSearchOrderBy(orderBy);
            return mapping.findForward("success");
        }
    }
}
