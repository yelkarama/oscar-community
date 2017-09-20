package org.oscarehr.billing;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.actions.DispatchAction;
import org.oscarehr.common.dao.UserPropertyDAO;
import org.oscarehr.common.model.UserProperty;
import org.oscarehr.util.MiscUtils;
import org.oscarehr.util.SpringUtils;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class HealthCardValidationPreferencesAction  extends DispatchAction {

    public ActionForward execute(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {

        String autoValidateOnBooking = request.getParameter("autoValidateOnBooking");

        UserPropertyDAO userPropertyDao = SpringUtils.getBean(UserPropertyDAO.class);

        try{
            UserProperty prop;

            if ((prop = userPropertyDao.getProp("auto_validate_hc")) == null) {
                prop = new UserProperty();
            }
            prop.setName("auto_validate_hc");
            prop.setValue(autoValidateOnBooking);
            userPropertyDao.saveProp(prop);
            
            request.setAttribute("success", true);
        } catch (Exception e){
            MiscUtils.getLogger().error("Changing Preferences failed", e);
            request.setAttribute("success", false);
        }

        return mapping.findForward("success");

    }

}
