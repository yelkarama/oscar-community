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


package oscar.oscarEncounter.pageUtil;

import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;

import javax.servlet.http.HttpServletRequest;

import org.apache.struts.util.MessageResources;
import org.oscarehr.common.dao.MessageTblDao;
import org.oscarehr.common.model.MessageTbl;
import org.oscarehr.common.model.OscarMsgType;
import org.oscarehr.util.LoggedInInfo;
import org.oscarehr.util.MiscUtils;

import org.oscarehr.util.SpringUtils;
import oscar.oscarMessenger.data.MsgMessageData;
import oscar.oscarMessenger.util.MsgDemoMap;
import oscar.util.DateUtils;
import oscar.util.StringUtils;

public class EctDisplayMsgAction extends EctDisplayAction {
    
    private static final String cmd = "msgs";
  
    public boolean getInfo(EctSessionBean bean, HttpServletRequest request, NavBarDisplayDAO Dao, MessageResources messages) {                                              
                 
		if (!securityInfoManager.hasPrivilege(LoggedInInfo.getLoggedInInfoFromSession(request), "_msg", "r", null)) {
      		return true; //Oscar message link won't show up on new CME screen.
      	} else {
            //set text for lefthand module title
            Dao.setLeftHeading(messages.getMessage(request.getLocale(), "oscarEncounter.LeftNavBar.Messages"));
            
            //set link for lefthand module title
            String winName = "ViewMsg" + bean.demographicNo;
            String url = "popupPage(600,900,'" + winName + "','" + request.getContextPath() + "/oscarMessenger/DisplayDemographicMessages.do?orderby=date&boxType=3&demographic_no=" + bean.demographicNo + "&providerNo=" + bean.providerNo + "&userName=" + bean.userName + "')";
            Dao.setLeftURL(url);
            
            //set the right hand heading link
            winName = "SendMsg" + bean.demographicNo;
            url = "popupPage(700,960,'" + winName + "','"+ request.getContextPath() + "/oscarMessenger/SendDemoMessage.do?demographic_no=" + bean.demographicNo + "'); return false;";
            Dao.setRightURL(url);
            Dao.setRightHeadingID(cmd);  //no menu so set div id to unique id for this action
            
            MessageTblDao dao = SpringUtils.getBean(MessageTblDao.class);
            List<MessageTbl> messageTbls = dao.getByDemographicNo(bean.demographicNo);
            String msgSubject;
            Date msgDate;
            int hash;
            int position = 0;
            for(MessageTbl message : messageTbls) {
                if (message.getType().equals(OscarMsgType.GENERAL_TYPE)) {
                    msgSubject = StringUtils.maxLenString(message.getSubject(), MAX_LEN_TITLE, CROP_LEN_TITLE, ELLIPSES);
                    msgDate = message.getDate();
                    NavBarDisplayDAO.Item item = NavBarDisplayDAO.Item();

                    item.setDate(msgDate);
                    hash = winName.hashCode();
                    hash = hash < 0 ? hash * -1 : hash;
                    url = "popupPage(600,900,'" + hash + "','" + request.getContextPath() + "/oscarMessenger/ViewMessage.do?from=encounter&orderBy=!date&demographic_no=" + bean.demographicNo + "&messagePosition=" + position + "&messageID=" + message.getId() + "'); return false;";
                    item.setURL(url);
                    item.setTitle(msgSubject);
                    item.setLinkTitle(message.getSubject() + " " + msgDate);
                    Dao.addItem(item);
                }
                
                position++;
            }

            oscar.oscarMessenger.pageUtil.MsgSessionBean messageBean = new oscar.oscarMessenger.pageUtil.MsgSessionBean();
            messageBean.setProviderNo((String) request.getSession().getAttribute("user"));
            messageBean.setUserName(request.getSession().getAttribute("userfirstname") + " " + (String) request.getSession().getAttribute("userlastname"));
            messageBean.setDemographic_no(bean.demographicNo);

            request.getSession().setAttribute("msgSessionBean", messageBean);
            
           return true;
      	}
  }
    
     public String getCmd() {
         return cmd;
     }
}
