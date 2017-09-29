/**
 * KAI INNOVATIONS
 */

package oscar.oscarMessenger.pageUtil;

import org.apache.log4j.Logger;
import org.apache.struts.action.Action;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.oscarehr.common.dao.MessageFolderDao;
import org.oscarehr.common.dao.MessageResponderDao;
import org.oscarehr.common.model.MessageResponder;
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
import java.util.Date;

public class MsgSettingsAction extends Action {
    private SecurityInfoManager securityInfoManager = SpringUtils.getBean(SecurityInfoManager.class);
    private MessageResponderDao messageResponderDao = SpringUtils.getBean(MessageResponderDao.class);
    private MessageFolderDao messageFolderDao = SpringUtils.getBean(MessageFolderDao.class);
    private static Logger logger = MiscUtils.getLogger();

    public ActionForward execute(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        if (!securityInfoManager.hasPrivilege(LoggedInInfo.getLoggedInInfoFromSession(request), "_msg", "w", null)) {
            throw new SecurityException("missing required security object (_msg)");
        }
        LoggedInInfo loggedInInfo = LoggedInInfo.getLoggedInInfoFromSession(request);
        String action = request.getParameter("method") != null ? request.getParameter("method") : "";

        if (action.equalsIgnoreCase("saveResponder")){
            saveResponder(mapping, request, loggedInInfo);
        }

        return mapping.findForward("success");
    }

    private ActionForward saveResponder(ActionMapping mapping, HttpServletRequest request, LoggedInInfo loggedInInfo) {
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
        String providerNo = loggedInInfo.getLoggedInProviderNo();
        
        // Get latest responder for setting archived when new responder is successfully saved
        MessageResponder oldResponder = messageResponderDao.findNewestByProvider(providerNo);

        boolean responderEnabled = (request.getParameter("responderEnabled") != null);
        if (responderEnabled) {
            String startDayString = request.getParameter("startDay");
            String endDayString = request.getParameter("endDay");
            Date startDay = null;
            Date endDay = null;
            try {
                if (startDayString != null && !startDayString.isEmpty()) {
                    startDay = sdf.parse(startDayString);
                }
                if (endDayString != null && !endDayString.isEmpty()) {
                    endDay = sdf.parse(endDayString);
                }
            } catch (ParseException e) {
                logger.error(e.getMessage());
            }
            String subject = request.getParameter("subject");
            String message = request.getParameter("message");

            // Create new responder based on new values
            MessageResponder newResponder = new MessageResponder();
            newResponder.setProviderNo(providerNo);
            newResponder.setStartDate(startDay);
            newResponder.setEndDate(endDay);
            newResponder.setSubject(subject);
            newResponder.setMessage(message);
            newResponder.setUpdateDate(new Date());
            newResponder.setArchived(false);
            messageResponderDao.saveEntity(newResponder);
        }
        
        if (oldResponder != null) {
            oldResponder.setArchived(true);
            messageResponderDao.saveEntity(oldResponder);
        }
        
        return mapping.findForward("success");
    }
}
