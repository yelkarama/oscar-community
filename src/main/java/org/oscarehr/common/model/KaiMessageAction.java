package org.oscarehr.common.model;

import org.apache.struts.action.Action;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.oscarehr.common.dao.UserAcceptanceDao;
import org.oscarehr.integration.dashboard.model.User;
import org.oscarehr.managers.SecurityInfoManager;
import org.oscarehr.util.LoggedInInfo;
import org.oscarehr.util.SpringUtils;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.swing.*;
import java.io.IOException;
import java.util.Date;

public class KaiMessageAction extends Action
{
    private SecurityInfoManager securityInfoManager = SpringUtils.getBean(SecurityInfoManager.class);
    private UserAcceptanceDao userAcceptanceDao = SpringUtils.getBean(UserAcceptanceDao.class);

    public ActionForward execute(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException
    {
        if (!securityInfoManager.hasPrivilege(LoggedInInfo.getLoggedInInfoFromSession(request), "_msg", "w", null))
        {
            throw new SecurityException("missing required security object (_msg)");
        }

        String providerNo = request.getParameter("providerNo") != null ? request.getParameter("providerNo") : "";

        UserAcceptance userAcceptance = new UserAcceptance();
        userAcceptance.setAccepted(true);
        userAcceptance.setProviderNo(providerNo);
        userAcceptance.setTimeAccepted(new Date());
        userAcceptanceDao.persist(userAcceptance);

        return null;
    }
}
