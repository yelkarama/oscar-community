/**
 *
 * Copyright (c) 2005-2012. Centre for Research on Inner City Health, St. Michael's Hospital, Toronto. All Rights Reserved.
 * This software is published under the GPL GNU General Public License.
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 *
 * This software was written for
 * Centre for Research on Inner City Health, St. Michael's Hospital,
 * Toronto, Ontario, Canada
 */

package oscar.appt.web;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;
import org.apache.struts.util.LabelValueBean;
import org.oscarehr.common.dao.AppointmentTypeDao;
import org.oscarehr.common.dao.LookupListDao;
import org.oscarehr.common.dao.SiteDao;
import org.oscarehr.common.model.AppointmentType;
import org.oscarehr.common.model.LookupList;
import org.oscarehr.common.model.LookupListItem;
import org.oscarehr.common.model.Site;
import org.oscarehr.managers.LookupListManager;
import org.oscarehr.util.LoggedInInfo;
import org.oscarehr.util.SpringUtils;

import oscar.OscarAction;
import oscar.OscarProperties;

public class AppointmentTypeAction extends OscarAction  {
	   @Override
	   public ActionForward execute(ActionMapping mapping,
					ActionForm form,
					HttpServletRequest request,
					HttpServletResponse response) throws IOException, ServletException {
		   LoggedInInfo loggedInInfo= LoggedInInfo.getLoggedInInfoFromSession(request);

			AppointmentTypeForm formBean = (AppointmentTypeForm)form;
			String sOper = request.getParameter("oper");			
			String selectedProviderNo = request.getParameter("selectedProvider");
		    ActionMessages errors = this.getErrors(request);
		    
		    int typeNo = -1;
		    if(formBean != null && (formBean.getId()!=null?formBean.getId().intValue():-1)> 0) {
		    	typeNo = formBean.getId().intValue();
		    } else if(request.getParameter("no") != null){
		    	try {
		    		typeNo = Integer.parseInt(request.getParameter("no"));
		    	} catch (NumberFormatException nex) {
				  	errors.add(ActionMessages.GLOBAL_MESSAGE, new ActionMessage("appointment.type.number.error"));
				  	saveErrors(request,errors);
				  	return mapping.findForward("failure");		  				    		
		    	}
		    }   

		    if(sOper==null) {
		    	formBean = new AppointmentTypeForm();
		    }  else {
		    	if(sOper.equals("save")) {
		    		if(formBean.getName() == null || formBean.getName().length()==0 || formBean.getName().length()>50) {
			    			errors.add(ActionMessages.GLOBAL_MESSAGE, new ActionMessage("appointment.type.name.error"));
			    			saveErrors(request,errors);
			    			return mapping.findForward("failure");		  		
			    	}
/* wrong for non-multisite configuration
		    		if(formBean.getLocation()!=null) {
						SiteDao siteDao = (SiteDao) SpringUtils.getBean("siteDao");
						if(siteDao.getByLocation(formBean.getLocation())==null) {
			    			errors.add(ActionMessages.GLOBAL_MESSAGE, new ActionMessage("appointment.type.location.error"));
			    			saveErrors(request,errors);
			    			return mapping.findForward("failure");		  									
						}
		    		}		    		
*/		    					    
		    	}	

		    	AppointmentTypeDao appDao = (AppointmentTypeDao) SpringUtils.getBean("appointmentTypeDao");
				LookupListManager lookupListManager = SpringUtils.getBean(LookupListManager.class);
				LookupList reasonCodes = lookupListManager.findLookupListByName(loggedInInfo, "reasonCode");
				List<LookupListItem> reasonCodesItems = reasonCodes.getItems();
				LookupListItem newReason = new LookupListItem();
				String newReasonString = formBean.getNewReasonCode();
				boolean isNewReason = false;
				if (newReasonString!=null && !newReasonString.trim().equals("")){
					for (int i = 0; i < reasonCodesItems.size(); i++) {
						if (!reasonCodesItems.get(i).getLabel().equals(newReasonString)) { isNewReason = true; }
					}
				}

				if(isNewReason){
					newReason.setActive(true);
					newReason.setCreatedBy("apptType");
					newReason.setDisplayOrder(reasonCodesItems.get(reasonCodesItems.size() - 1 ).getDisplayOrder() + 1);
					newReason.setLabel(newReasonString);
					newReason.setLookupListId(reasonCodes.getId());
					newReason.setValue(UUID.randomUUID().toString());
					lookupListManager.addLookupListItem(loggedInInfo, newReason);
				}

		    	if (sOper.equals("edit")) {
		    		AppointmentType dbBean = appDao.find(Integer.valueOf(typeNo));
		    		if(dbBean != null && selectedProviderNo == null) {
		    			//formBean.setTypeNo(dbBean.getTypeNo());
		    			formBean.setId(dbBean.getId());
		    			formBean.setName(dbBean.getName());
		    			formBean.setDuration(dbBean.getDuration());
		    			formBean.setLocation(dbBean.getLocation());
		    			formBean.setNotes(dbBean.getNotes());
		    			formBean.setReasonCode(dbBean.getReasonCode());
		    			formBean.setReason(dbBean.getReason());
		    			formBean.setResources(dbBean.getResources());
                        formBean.setProviderNo(null);
                        formBean.setTemplateId(null);
                        formBean.setEnabled(dbBean.isEnabled()?"true":"false");
		    		} else if (dbBean != null) {
                        
                        formBean.setName(dbBean.getName());
                        formBean.setDuration(dbBean.getDuration());
                        formBean.setLocation(dbBean.getLocation());
                        formBean.setNotes(dbBean.getNotes());
                        formBean.setReasonCode(dbBean.getReasonCode());
                        formBean.setReason(dbBean.getReason());
                        formBean.setResources(dbBean.getResources());
                        if (dbBean.getTemplateId() == null) {
                            formBean.setId(null);
                            formBean.setTemplateId(dbBean.getId());
                            formBean.setProviderNo(selectedProviderNo);
                        } else {
                            formBean.setId(dbBean.getId());
                            formBean.setTemplateId(dbBean.getTemplateId());
                            formBean.setProviderNo(dbBean.getProviderNo());
                        }
                        formBean.setEnabled(dbBean.isEnabled()?"true":"false");
                    } else {
		    			errors.add(ActionMessages.GLOBAL_MESSAGE, new ActionMessage("appointment.type.notfound.error"));
		    			saveErrors(request,errors);
		    			return mapping.findForward("failure");										
		    		}
		    	} else if (sOper.equals("save")) {
		    		if(typeNo <= 0) {
		    			//new bean
		    			AppointmentType bean = new AppointmentType();
		    			bean.setName(formBean.getName());
		    			bean.setDuration(formBean.getDuration());
		    			bean.setLocation(formBean.getLocation());
		    			bean.setNotes(formBean.getNotes());
		    			if (isNewReason){
							bean.setReasonCode(newReason.getId());
						} else{
							bean.setReasonCode(formBean.getReasonCode());
						}
		    			bean.setReason(formBean.getReason());
		    			bean.setResources(formBean.getResources());
                        bean.setProviderNo(formBean.getProviderNo());
                        bean.setTemplateId(formBean.getTemplateId());
                        bean.setEnabled("true".equals(formBean.getEnabled()));
                        appDao.persist(bean);
		    		} else {
		    			AppointmentType bean = appDao.find(Integer.valueOf(typeNo));
		    			if(bean != null) {
		    				bean.setName(formBean.getName());
		    				bean.setDuration(formBean.getDuration());
		    				bean.setLocation(formBean.getLocation());
		    				bean.setNotes(formBean.getNotes());
							if (isNewReason){
								bean.setReasonCode(newReason.getId());
							} else{
								bean.setReasonCode(formBean.getReasonCode());
							}
		    				bean.setReason(formBean.getReason());
		    				bean.setResources(formBean.getResources());
                            bean.setProviderNo(formBean.getProviderNo());
                            bean.setTemplateId(formBean.getTemplateId());
                            bean.setEnabled("true".equals(formBean.getEnabled()));
		    				appDao.merge(bean);
		    			} else {
		    				errors.add(ActionMessages.GLOBAL_MESSAGE, new ActionMessage("appointment.type.notfound.error"));
		    				saveErrors(request,errors);
		    				return mapping.findForward("failure");
		    			}	
		    		}
		    		request.setAttribute("AppointmentTypeForm", new AppointmentTypeForm());
		    		request.setAttribute("selectedProvider", formBean.getProviderNo());
		    	} else if (sOper.equals("del")) {
		    		appDao.remove(typeNo);
		    	} else if (sOper.equals("toggleEnable") && typeNo > 0) {
                    AppointmentType bean = appDao.find(typeNo);
                    if (bean != null) {
                        if (bean.getTemplateId() == null && selectedProviderNo != null) {
                            AppointmentType newType = new AppointmentType(bean);
                            newType.setTemplateId(bean.getId());
                            newType.setProviderNo(selectedProviderNo);
                            newType.setEnabled(!bean.isEnabled());
                            appDao.persist(newType);
                        } else {
                            bean.setEnabled(!bean.isEnabled());
                            appDao.merge(bean);
                        }
                    } else {
                        errors.add(ActionMessages.GLOBAL_MESSAGE, new ActionMessage("appointment.type.notfound.error"));
                        saveErrors(request,errors);
                        return mapping.findForward("failure");
                    }
                } else if ((sOper.equals("enableAll") || sOper.equals("disableAll")) && selectedProviderNo != null) {
				    boolean setEnable = sOper.equals("enableAll"); 
                    List<AppointmentType> types = appDao.findAllForProvider(selectedProviderNo, false);
                    for (AppointmentType a : types) {
                        if (a.getTemplateId() == null) {
                            AppointmentType newType = new AppointmentType(a);
                            newType.setTemplateId(a.getId());
                            newType.setProviderNo(selectedProviderNo);
                            newType.setEnabled(setEnable);
                            appDao.persist(newType);
                        } else {
                            a.setEnabled(setEnable);
                            appDao.merge(a);
                        }
                    }
                }
		    }
		  	
		    if (org.oscarehr.common.IsPropertiesOn.isMultisitesEnable()) {
		    	List<LabelValueBean> locations = new ArrayList<LabelValueBean>();
				SiteDao siteDao = (SiteDao) SpringUtils.getBean("siteDao");
				List<Site> sites = siteDao.getAllActiveSites();
				for(Site site : sites) {
					locations.add(new LabelValueBean(site.getName(), Integer.toString(site.getSiteId())));
				}
				request.setAttribute("locationsList", locations);
		    }
		    
            if (OscarProperties.getInstance().isPropertyActive("provider_appointment_select")) {
                return mapping.findForward("successNew");
            } else {
	            return mapping.findForward("success");
            }
	   }
}
