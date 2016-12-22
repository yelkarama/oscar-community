package org.oscarehr.hospitalReportManager;

import org.apache.log4j.Logger;
import org.apache.struts.action.Action;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.oscarehr.managers.SecurityInfoManager;
import org.oscarehr.util.LoggedInInfo;
import org.oscarehr.util.MiscUtils;
import org.oscarehr.util.SpringUtils;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

public class PrintHRMReportAction extends Action {

    private static final Logger logger = MiscUtils.getLogger();

    private SecurityInfoManager securityInfoManager = SpringUtils.getBean(SecurityInfoManager.class);

    public ActionForward execute(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) {
        LoggedInInfo loggedInInfo = LoggedInInfo.getLoggedInInfoFromSession(request);
        if(!securityInfoManager.hasPrivilege(loggedInInfo, "_hrm", "r", null)) {
            throw new SecurityException("missing required security object (_hrm)");
        }

        try {
            String hrmReportId = request.getParameter("hrmReportId");
            response.setContentType("application/pdf");  //octet-stream
            response.setHeader("Content-Disposition", "attachment; filename=\"HRMReport.pdf\"");

            HRMPDFCreator hrmpdfCreator = new HRMPDFCreator(response.getOutputStream(), hrmReportId, loggedInInfo);

            hrmpdfCreator.printPdf();
        }
        catch(IOException e) {
            logger.error("Could not retrieve the Output Stream from the response", e);
            request.setAttribute("printError", true);
            return mapping.findForward("error");
        }


        return mapping.findForward("success");
    }
}
