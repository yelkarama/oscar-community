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
package com.quatro.web.admin;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

import javax.servlet.ServletRequest;
import javax.servlet.jsp.PageContext;

import org.apache.commons.lang.StringUtils;
import org.oscarehr.common.dao.SecurityDao;
import org.oscarehr.common.model.Security;
import org.oscarehr.util.MiscUtils;
import org.oscarehr.util.SpringUtils;

import org.springframework.web.util.JavaScriptUtils;
import oscar.MyDateFormat;
import oscar.OscarProperties;
import oscar.log.LogAction;
import oscar.log.LogConst;


/**
 * Helper class for securityaddsecurity.jsp page.
 */
public class SecurityAddSecurityHelper {

	private SecurityDao securityDao = SpringUtils.getBean(SecurityDao.class);

	/**
	 * Adds a security record (i.e. user login information) for the provider.
	 * <p/>
	 * Processing status is available as a "message" variable.
	 * 
	 * @param pageContext
	 * 		JSP page context
	 */
	public void addProvider(PageContext pageContext) {
		String message = process(pageContext);
		pageContext.setAttribute("message", message);
	}
	
	private String process(PageContext pageContext) {
		ServletRequest request = pageContext.getRequest();
		OscarProperties oscarProps = OscarProperties.getInstance();
		
		StringBuilder sbTemp = new StringBuilder();
		MessageDigest md;
        try {
	        md = MessageDigest.getInstance("SHA");
        } catch (NoSuchAlgorithmException e) {
        	MiscUtils.getLogger().error("Unable to get SHA message digest", e);
        	return "admin.securityaddsecurity.msgAdditionFailure";
        }
        
		byte[] btNewPasswd = md.digest(request.getParameter("password").getBytes());
		for (int i = 0; i < btNewPasswd.length; i++)
			sbTemp = sbTemp.append(btNewPasswd[i]);

		boolean isUserRecordAlreadyCreatedForProvider = !securityDao.findByProviderNo(request.getParameter("provider_no")).isEmpty();
		if (isUserRecordAlreadyCreatedForProvider) return "admin.securityaddsecurity.msgLoginAlreadyExistsForProvider";

		boolean isUserAlreadyExists = securityDao.findByUserName(request.getParameter("user_name")).size() > 0;
		if (isUserAlreadyExists) return "admin.securityaddsecurity.msgAdditionFailureDuplicate";

		Security s = new Security();
		s.setUserName(request.getParameter("user_name"));
		s.setPassword(sbTemp.toString());
		s.setProviderNo(request.getParameter("provider_no"));
		s.setPin(request.getParameter("pin"));
		s.setBExpireset(request.getParameter("b_ExpireSet") == null ? 0 : Integer.parseInt(request.getParameter("b_ExpireSet")));
		s.setDateExpiredate(MyDateFormat.getSysDate(request.getParameter("date_ExpireDate")));
		s.setBLocallockset(request.getParameter("b_LocalLockSet") == null ? 0 : Integer.parseInt(request.getParameter("b_LocalLockSet")));
		s.setBRemotelockset(request.getParameter("b_RemoteLockSet") == null ? 0 : Integer.parseInt(request.getParameter("b_RemoteLockSet")));
		String pwd = request.getParameter("password");
		
		if (StringUtils.isEmpty(s.getUserName())) {
			return "admin.securityrecord.msgIsRequired";
		}
		
		if (StringUtils.isEmpty(s.getPassword())) {
			return "admin.securityrecord.msgIsRequired";
		} else if (!Boolean.parseBoolean(oscarProps.getProperty("IGNORE_PASSWORD_REQUIREMENTS"))) {
			String passwordMinLength = oscarProps.getProperty("password_min_length");
			String passwordMinGroups = oscarProps.getProperty("password_min_groups");
			String passwordGroupLowerChars = JavaScriptUtils.javaScriptEscape(oscarProps.getProperty("password_group_lower_chars"));
			String passwordGroupUpperChars = JavaScriptUtils.javaScriptEscape(oscarProps.getProperty("password_group_upper_chars"));
			String passwordGroupDigits = JavaScriptUtils.javaScriptEscape(oscarProps.getProperty("password_group_digits"));
			String passwordGroupSpecial = JavaScriptUtils.javaScriptEscape(oscarProps.getProperty("password_group_special"));
			
			if (pwd.length() < Integer.parseInt(passwordMinLength)) {
				return "password.policy.violation.msgPasswordLengthError";
			}
			boolean hasLowerCaseCharacter = false;
			boolean hasUpperCaseCharacter = false;
			boolean hasDigit = false;
			boolean hasSpecial = false;
			
			for (int i = 0; i < pwd.length(); i++) {
				String currentCharacter = Character.toString(pwd.charAt(i));
				if (!hasLowerCaseCharacter && passwordGroupLowerChars.contains(currentCharacter)) {
					hasLowerCaseCharacter = true;
				}

				if (!hasUpperCaseCharacter && passwordGroupUpperChars.contains(currentCharacter)) {
					hasUpperCaseCharacter = true;
				}

				if (!hasDigit && passwordGroupDigits.contains(currentCharacter)) {
					hasDigit = true;
				}

				if (!hasSpecial && passwordGroupSpecial.contains(currentCharacter)) {
					hasSpecial = true;
				}
			}
			
			int groupsUsed = (hasLowerCaseCharacter?1:0) + (hasUpperCaseCharacter?1:0) + (hasDigit?1:0) + (hasSpecial?1:0);
			
			if (groupsUsed < Integer.parseInt(passwordMinGroups)) {
				return "password.policy.violation.msgPasswordStrengthError";
			}
		}

		if (StringUtils.isEmpty(s.getProviderNo())) {
			return "admin.securityrecord.msgIsRequired";
		}

		if (!request.getParameter("conPassword").equals(pwd)) {
			return "admin.securityrecord.msgPasswordNotConfirmed";
		}
		
		if (request.getParameter("b_ExpireSet").equals("1") && request.getParameter("date_ExpireDate").length() < 10) {
			return "admin.securityrecord.formDate";
		}
		
		if (request.getParameter("pinIsRequired").equals("1") &&
			request.getParameter("b_RemoteLockSet").equals("1") &&
			request.getParameter("b_LocalLockSet").equals("1") &&
			StringUtils.isEmpty(s.getPin())) {
			return "admin.securityrecord.formPIN";
		}

		String password_pin_min_length = oscarProps.getProperty("password_pin_min_length");
		String password_group_digits = JavaScriptUtils.javaScriptEscape(oscarProps.getProperty("password_group_digits"));
		
		if (s.getPin().length() < Integer.parseInt(password_pin_min_length)) {
			return "password.policy.violation.msgPinLengthError";
		}

		for (int i = 0; i < s.getPin().length(); i++) {
			char c = s.getPin().charAt(i);

			if (password_group_digits.indexOf(c) == -1) {
				return "password.policy.violation.msgPinGroups";
			}
		}

		if (!request.getParameter("conPin").equals(s.getPin())) {
			return "admin.securityrecord.msgPinNotConfirmed";
		}
		
    	if (request.getParameter("forcePasswordReset") != null && request.getParameter("forcePasswordReset").equals("1")) {
    	    s.setForcePasswordReset(Boolean.TRUE);
    	} else {
    		s.setForcePasswordReset(Boolean.FALSE);  
        }
		
		securityDao.persist(s);

		LogAction.addLog((String) pageContext.getSession().getAttribute("user"), LogConst.ADD, LogConst.CON_SECURITY, request.getParameter("user_name"), request.getRemoteAddr());

		// hurrah - it worked
		return "admin.securityaddsecurity.msgAdditionSuccess";
	}
}
