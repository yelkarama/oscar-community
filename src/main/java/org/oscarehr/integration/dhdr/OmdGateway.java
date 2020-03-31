package org.oscarehr.integration.dhdr;
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
import java.io.FileInputStream;
import java.security.KeyStore;

import javax.net.ssl.SSLContext;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import javax.ws.rs.core.Response;

import org.apache.cxf.configuration.jsse.TLSClientParameters;
import org.apache.cxf.jaxrs.client.WebClient;
import org.apache.http.conn.ssl.SSLContexts;
import org.oscarehr.integration.OneIDTokenUtils;
import org.oscarehr.integration.TokenExpiredException;

import oscar.OscarProperties;

public class OmdGateway {
	
	public final static String Immunization = "Immunization";
	public final static String MedicationDispense = "MedicationDispense";
	
	
	protected String getValidToken(HttpSession session) throws TokenExpiredException {
		
		//	String tokenAttr = (String) session.getAttribute("oneid_token");
		//	JSONObject tokens = JSONObject.fromObject(tokenAttr);

		//	String accessToken = tokens.getString("access_token");
			
			//logger.info("CURRENT WORKING TOKEN=" + tokenAttr);
			
		   String  accessToken = OneIDTokenUtils.getValidAccessToken(session);

			return accessToken;
		}
		
	public WebClient getWebClient(String resource) throws Exception {
			String gatewayUrl = OscarProperties.getInstance().getProperty("oneid.gateway.url");
			WebClient wc = WebClient.create(gatewayUrl+resource);
			WebClient.getConfig(wc).getHttpConduit().setTlsClientParameters(getTLSClientParameters());
			return wc;
		}
		
	protected TLSClientParameters getTLSClientParameters() throws Exception {
			KeyStore ks = KeyStore.getInstance("JKS");
			ks.load(new FileInputStream(OscarProperties.getInstance().getProperty("oneid.gateway.keystore")), 
					OscarProperties.getInstance().getProperty("oneid.gateway.keystore.password").toCharArray());
			
			SSLContext sslcontext = SSLContexts.custom().loadKeyMaterial(ks, OscarProperties.getInstance().getProperty("oneid.gateway.keystore.password").toCharArray()).build();
			sslcontext.getDefaultSSLParameters().setNeedClientAuth(true);
			sslcontext.getDefaultSSLParameters().setWantClientAuth(true);

			TLSClientParameters tlsParams = new TLSClientParameters();
			tlsParams.setSSLSocketFactory(sslcontext.getSocketFactory());
			tlsParams.setDisableCNCheck(true);
			
			return tlsParams;
		}
		
	public Response doGet(WebClient wc, HttpServletRequest request) throws TokenExpiredException {
			String consumerKey = OscarProperties.getInstance().getProperty("oneid.consumerKey");
			String consumerSecret = OscarProperties.getInstance().getProperty("oneid.consumerSecret");
			String accessToken = getValidToken(request.getSession());
			
			Response response2 = wc.header("Authorization", "Bearer " + accessToken).header("X-Gtwy-Client-Id", consumerKey).header("X-Gtwy-Client-Secret", consumerSecret).get();
			
			return response2;
		}


}
