package oscar.admin.actions;

import org.apache.log4j.Logger;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.actions.DispatchAction;
import org.oscarehr.util.MiscUtils;
import org.oscarehr.util.SpringUtils;
import oscar.OscarProperties;
import oscar.eform.EFormLoader;
import oscar.oscarPrevention.PreventionDS;
import oscar.oscarPrevention.PreventionDisplayConfig;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class ReloadDataAction extends DispatchAction {
    private final Logger logger = MiscUtils.getLogger();
    
    public ActionForward unspecified(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) {
        return null;
    }

    public void reloadProperties(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) {
        OscarProperties.reloadProperties();
    }
    
    public void reloadApConfig(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) {
        EFormLoader.reloadEformLoader();
    }
    
    public void reloadPreventions(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) {
        logger.info("Reloading Preventions XML");
        PreventionDisplayConfig preventionDisplayConfig = PreventionDisplayConfig.getInstance();
        preventionDisplayConfig.loadPreventions();
        preventionDisplayConfig.loadConfigurationSets();
    }
    
    public void reloadPreventionDrl(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) {
        PreventionDS preventionDs = SpringUtils.getBean(PreventionDS.class);
        preventionDs.reloadRuleBase();
    }
}
