/**
 * Copyright (c) 2001-2002. Department of Family Medicine, McMaster University. All Rights Reserved.
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
 * This software was written for the
 * Department of Family Medicine
 * McMaster University
 * Hamilton
 * Ontario, Canada
 */
package oscar.oscarMessenger.pageUtil;

import java.io.IOException;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.struts.action.Action;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.oscarehr.common.dao.MessageListDao;
import org.oscarehr.common.model.MessageList;
import org.oscarehr.common.model.Provider;
import org.oscarehr.managers.ProviderManager2;
import org.oscarehr.managers.SecurityInfoManager;
import org.oscarehr.util.LoggedInInfo;
import org.oscarehr.util.MiscUtils;
import org.oscarehr.util.SpringUtils;

import oscar.util.ConversionUtils;

public class MsgDisplayMessagesAction extends Action {

	private SecurityInfoManager securityInfoManager = SpringUtils.getBean(SecurityInfoManager.class);
	
	public ActionForward execute(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {

		if(!securityInfoManager.hasPrivilege(LoggedInInfo.getLoggedInInfoFromSession(request), "_msg", "r", null)) {
			throw new SecurityException("missing required security object (_msg)");
		}
		
		// Setup variables
		Provider provider = LoggedInInfo.getLoggedInInfoFromSession(request).getLoggedInProvider();
		MsgSessionBean bean = null;
		String[] messageNo = ((MsgDisplayMessagesForm) form).getMessageNo();
		String providerNo = provider.getProviderNo();

		//Initialize forward location
		String findForward = "success";

		bean = new MsgSessionBean();
		bean.setProviderNo(providerNo);
		bean.setUserName(provider.getFirstName() + " " + provider.getLastName());
		request.getSession().setAttribute("msgSessionBean", bean);

		/*
		 *edit 2006-0811-01 by wreby
		 *  Adding a search and clear search action to the DisplayMessages JSP
		 */
		if (request.getParameter("btnSearch") != null) {
			MsgDisplayMessagesBean displayMsgBean = (MsgDisplayMessagesBean) request.getSession().getAttribute("DisplayMessagesBeanId");

			displayMsgBean.setFilter(request.getParameter("searchString"));
		} else if (request.getParameter("btnClearSearch") != null) {
			MsgDisplayMessagesBean displayMsgBean = (MsgDisplayMessagesBean) request.getSession().getAttribute("DisplayMessagesBeanId");
			displayMsgBean.clearFilter();
		} else if (request.getParameter("btnDelete") != null) {
			//This will go through the array of message Numbers and set them
			//to del.which stands for deleted. but you prolly could have figured that out

			MessageListDao dao = SpringUtils.getBean(MessageListDao.class);
			for (int i = 0; i < messageNo.length; i++) {
				List<MessageList> msgs = dao.findByProviderNoAndMessageNo(providerNo, ConversionUtils.fromLongString(messageNo[i]));
				for (MessageList msg : msgs) {
					msg.setDeleted(true);
					msg.setFolderId(0);
					dao.merge(msg);
				}
			}//for
		} else if (request.getParameter("btnRead") != null){
			MessageListDao dao = SpringUtils.getBean(MessageListDao.class);
			for (int i = 0; i < messageNo.length; i++) {
				List<MessageList> msgs = dao.findByProviderNoAndMessageNo(providerNo, ConversionUtils.fromLongString(messageNo[i]));
				for (MessageList msg : msgs) {
					msg.setStatus("read");
					dao.merge(msg);
				}
			}
		} else if (request.getParameter("btnUnread") != null){
			MessageListDao dao = SpringUtils.getBean(MessageListDao.class);
			for (int i = 0; i < messageNo.length; i++) {
				List<MessageList> msgs = dao.findByProviderNoAndMessageNo(providerNo, ConversionUtils.fromLongString(messageNo[i]));
				for (MessageList msg : msgs) {
					msg.setStatus("unread");
					dao.merge(msg);
				}
			}
		} else if (request.getParameter("moveTo") != null){
			MessageListDao dao = SpringUtils.getBean(MessageListDao.class);
			Integer folderId = 0;
			if (request.getParameter("moveTo")!=null && !request.getParameter("moveTo").equals("Remove")){
				folderId = Integer.parseInt(request.getParameter("moveTo"));
			}
			for (int i = 0; i < messageNo.length; i++) {
				List<MessageList> msgs = dao.findByProviderNoAndMessageNo(providerNo, ConversionUtils.fromLongString(messageNo[i]));
				for (MessageList msg : msgs) {
					msg.setFolderId(folderId);
					dao.merge(msg);
				}
			}
		} else {
			MiscUtils.getLogger().debug("Unexpected action in MsgDisplayMessagesBean.java");
		}

		return (mapping.findForward(findForward));
	}

}
