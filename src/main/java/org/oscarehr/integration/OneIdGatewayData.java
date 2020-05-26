package org.oscarehr.integration;
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
import java.time.Instant;
import java.util.Calendar;
import java.util.Date;
import java.util.Map.Entry;


import org.apache.log4j.Logger;
import org.oscarehr.util.MiscUtils;

import com.auth0.jwt.JWT;
import com.auth0.jwt.interfaces.Claim;
import com.auth0.jwt.interfaces.DecodedJWT;
import org.apache.commons.codec.binary.Base64;

import net.sf.json.JSONObject;

public class OneIdGatewayData {
	static Logger logger = MiscUtils.getLogger();
	String oneIdString = null;
	JSONObject endPointToolbar = null;
	JSONObject tokens = null;
	DecodedJWT accessToken = null;
	DecodedJWT refreshToken = null;
	DecodedJWT idToken = null;
	
	String accessTokenStr  = null;
	String refreshTokenStr = null;
	String idTokenStr = null;
	String hubTopic = null;
	private String cmsLoggedIn = null;
	private String cmsPatientInContext = null;
	
	public OneIdGatewayData() {}
	
	public OneIdGatewayData(String oneIdString) {
		if (oneIdString != null) {
			this.oneIdString = oneIdString;
			try {
				tokens = JSONObject.fromObject(oneIdString);
			
				accessTokenStr  = tokens.getString("access_token");
				refreshTokenStr = tokens.getString("refresh_token");
				idTokenStr      = tokens.getString("id_token");
				String toolbarStr 	  = tokens.getString("toolbar");
			
				processAccessToken(accessTokenStr);
				processRefreshToken(refreshTokenStr);
				processIdToken(idTokenStr);
				processToolBar(toolbarStr);

				hubTopic = tokens.optString("hub.topic",null);
			}catch(Exception e) {
				logger.error("Error with parsing tokens "+oneIdString,e);
			}
		
		}
	}
	
	public String getAccessToken() {
		return accessTokenStr;
	}
	
	
	public void processAccessToken(String accessTokenStr) {
		accessToken = JWT.decode(accessTokenStr);
	}
	
	public void processRefreshToken(String refreshTokenStr) {
		refreshToken = JWT.decode(refreshTokenStr);
	}
	
	public void processIdToken(String idTokenStr) {
		idToken = JWT.decode(idTokenStr);
	}
	
	

	public void processToolBar(String toolbarStr) {
		logger.debug("toolbar process "+toolbarStr);
		String toolbarStrDecoded = new String( Base64.decodeBase64(toolbarStr));
		logger.debug("toolbarStrDecoded: "+toolbarStrDecoded);
		toolbarStrDecoded = toolbarStrDecoded.replaceAll("[\\u201C\\u201D]", "\""); //This replaces 66/99 style quotes with regular ones. 
		logger.debug("toolbarStrDecoded: "+toolbarStrDecoded);
		endPointToolbar = JSONObject.fromObject(toolbarStrDecoded);
		logger.debug("endPointToolbar "+endPointToolbar);
	}

	public String getToolBar(String str) {
		return endPointToolbar.optString(str);
	}
	
	static final String PCOI_URL = "pcoi_url";
	static final String CMS_URL = "cms_url";
	static final String FHIR_iss = "FHIR_iss";
	
	public String getPCOIUrl() {
		return endPointToolbar.optString(PCOI_URL);
	}
	
	public String getCMSUrl() {
		logger.debug("getCMSUrl: "+endPointToolbar.optString(CMS_URL));
		return endPointToolbar.optString(CMS_URL);
	}
	
	public String getFHIRiss() {
		return endPointToolbar.optString(FHIR_iss);
	}
	
	public boolean isAccessTokenExpired() {
		long iat = accessToken.getClaim("iat").asLong();
		int expiresIn = accessToken.getClaim("expires_in").asInt();

		logger.debug("iat=" + iat);
		logger.debug("expires_in=" + expiresIn);
		Date date = Date.from(Instant.ofEpochSecond(iat));
		logger.debug("date="+date);
		
		Calendar cal = Calendar.getInstance();
		cal.setTime(date);
		cal.add(Calendar.SECOND, expiresIn);

		Date expires = cal.getTime();

		Calendar cal2 = Calendar.getInstance();
		cal2.add(Calendar.SECOND, 15);

		Date inTheFuture = cal2.getTime();

		logger.debug("IAT=" + date);
		logger.debug("expires=" + expires);
		logger.debug("inTheFuture=" + inTheFuture);
	
		if (expires.after(inTheFuture)) {
			logger.info("access token is not expired");
			return false;
		} 
		return true;
		
	}
	
	private void debugDecodedJWT(StringBuilder sb,String heading,DecodedJWT decodedJWT) {
		sb.append("\n\n"+heading+"\n");
		for (Entry<String,Claim> entry : decodedJWT.getClaims().entrySet()) {
			sb.append("\t entry:"+entry.getKey()+"  "+entry.getValue().asString()+"\n");
		}
	}
	public String debug() {
		
		StringBuilder sb = new StringBuilder("===============================\nDEBUG ONEID TOKEN\n=======================\n");

		if (tokens == null) {
			sb.append("ERROR no token");
		}else {
			sb.append("\n"+tokens.toString(3)); 
			
			if (accessToken == null) {
				sb.append("ERROR no access token");
			}else {
				debugDecodedJWT(sb,"Access TOKEN",accessToken);
				debugDecodedJWT(sb,"Refresh TOKEN",refreshToken);
				debugDecodedJWT(sb,"Id TOKEN",idToken);
			}
		}
		if(endPointToolbar != null) {
			for (Object entry : endPointToolbar.entrySet()) {
				logger.debug("E "+ entry);
				logger.debug("class "+entry.getClass());
			}
		}
		
		sb.append("\n=================================\n");
		return sb.toString();
	}
	
	public void setHubTopic(String hubTopicResponseBody) {
		this.hubTopic = hubTopicResponseBody;
	}
	
	public String getHubTopic() {
		return this.hubTopic;
	}

	public String getCmsLoggedIn() {
		return cmsLoggedIn;
	}

	public void setCmsLoggedIn(String cmsLoggedIn) {
		this.cmsLoggedIn = cmsLoggedIn;
	}

	public String getCmsPatientInContext() {
		return cmsPatientInContext;
	}

	public void setCmsPatientInContext(String cmsPatientInContext) {
		this.cmsPatientInContext = cmsPatientInContext;
	}
	
}
