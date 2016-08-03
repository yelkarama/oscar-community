package org.oscarehr.common.web;

import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.beanutils.DynaBean;
import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;
import org.apache.struts.actions.DispatchAction;
import org.oscarehr.common.dao.DemographicGroupDao;
import org.oscarehr.common.dao.DemographicGroupLinkDao;
import org.oscarehr.common.model.DemographicGroup;
import org.oscarehr.util.MiscUtils;
import org.oscarehr.util.SpringUtils;

public class DemographicGroupsManageAction extends DispatchAction {

	private static final Logger logger = MiscUtils.getLogger();

    private DemographicGroupDao demographicGroupDao = (DemographicGroupDao) SpringUtils.getBean("demographicGroupDao");
    private DemographicGroupLinkDao demographicGroupLinkDao = (DemographicGroupLinkDao) SpringUtils.getBean("demographicGroupLinkDao");

    @Override
    protected ActionForward unspecified(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
        return view(mapping, form, request, response);
    }
    
    public ActionForward view(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) {
		putDemographicGroupsInRequest(request);
        
        return mapping.findForward("list");
    }

    public ActionForward add(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) {
    	DynaBean lazyForm = (DynaBean) form;

    	DemographicGroup g = new DemographicGroup();
    	
    	lazyForm.set("group", g);

        return mapping.findForward("details");
    }

    public ActionForward save(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) {
    	DynaBean lazyForm = (DynaBean) form;

    	DemographicGroup g = (DemographicGroup) lazyForm.get("group");

    	// verify mandatories
    	if ( StringUtils.isBlank(g.getName()) ) {
   			ActionMessages errors = this.getErrors(request);
 			errors.add("group.name", new ActionMessage("errors.required", "DemographicGroup name"));
    		this.saveErrors(request, errors);
    	}
    	
    	DemographicGroup tempGroup = demographicGroupDao.findByName(g.getName());
    	
    	if ( tempGroup != null && (g.getId() == null || !tempGroup.getId().equals(g.getId())) ) {
   			ActionMessages errors = this.getErrors(request);
 			errors.add("group.name", new ActionMessage("errors.duplicateName", g.getName()));
    		this.saveErrors(request, errors);
    	}

    	if (this.getErrors(request).size() > 0) {
    		return mapping.findForward("details");
		}

    	demographicGroupDao.save(g);

		ActionMessages messages = this.getMessages(request);
		messages.add(ActionMessages.GLOBAL_MESSAGE, new ActionMessage("message.save", "../"));
		this.saveMessages(request, messages);

        return view(mapping, form, request, response);
    }

    public ActionForward update(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) {
    	DynaBean lazyForm = (DynaBean) form;

    	String idAsString = request.getParameter("id");
    	int id = 0;
		DemographicGroup g = null;

		try {
			id = Integer.parseInt(idAsString);
		} catch (Exception e) {
			logger.warn("Unable to parse id: " + idAsString);
			
			ActionMessages errors = this.getErrors(request);
 			errors.add("group.id", new ActionMessage("errors.invalid", "DemographicGroup id"));
    		this.saveErrors(request, errors);
    		
			return view(mapping, form, request, response);
		}
		
		g = demographicGroupDao.find( id );
		
		if (g == null) {
			ActionMessages errors = this.getErrors(request);
 			errors.add("group.id", new ActionMessage("errors.unableToFindWithId", "DemographicGroup", id));
    		this.saveErrors(request, errors);
    		
			return view(mapping, form, request, response);
		}

        lazyForm.set("group", g);
        
        return mapping.findForward("details");
    }
    
    public ActionForward delete(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) {		
		String idAsString = request.getParameter("id");
		int id = 0;
		DemographicGroup group = null;
		
		try {
			id = Integer.parseInt(idAsString);
			group = demographicGroupDao.find(id);
		} catch (Exception e) {
			logger.warn("Unable to parse id: " + idAsString);
			ActionMessages errors = this.getErrors(request);
 			errors.add("group.id", new ActionMessage("errors.invalid", "DemographicGroup id"));
    		this.saveErrors(request, errors);
			
			return view(mapping, form, request, response);
		}
		
		try {
			demographicGroupDao.delete(group);
		} catch (Exception e) {
			logger.error("Unable to delete DemographicGroup.", e);
			ActionMessages errors = this.getErrors(request);
 			errors.add(ActionMessages.GLOBAL_MESSAGE, new ActionMessage("errors.unableToComplete", ""));
    		this.saveErrors(request, errors);
			
			return view(mapping, form, request, response);
		}
		
		// Delete all of the DemographicGroupLink objects with demographic_group_id = 'id'
		if (id != 0) {
			demographicGroupLinkDao.removeDemographicGroupLinkByGroupId(id);
		}
		
		// Need to do this AFTER we call delete on the demographicGroupDao
		putDemographicGroupsInRequest(request);
		
		ActionMessages messages = this.getMessages(request);
		messages.add(ActionMessages.GLOBAL_MESSAGE, new ActionMessage("message.delete", "../"));
		this.saveMessages(request, messages);
		
        return view(mapping, form, request, response);
    }

    public void setDemographicGroupDao(DemographicGroupDao demographicGroupDao) {
        this.demographicGroupDao = demographicGroupDao;
    }
    
    private void putDemographicGroupsInRequest(HttpServletRequest request) {
		List<DemographicGroup> groups = demographicGroupDao.getAll();
		
		request.setAttribute("groups", groups);
	}
}