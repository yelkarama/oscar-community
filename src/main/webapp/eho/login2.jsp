<%--

    Copyright (c) 2001-2002. Department of Family Medicine, McMaster University. All Rights Reserved.
    This software is published under the GPL GNU General Public License.
    This program is free software; you can redistribute it and/or
    modify it under the terms of the GNU General Public License
    as published by the Free Software Foundation; either version 2
    of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.

    This software was written for the
    Department of Family Medicine
    McMaster University
    Hamilton
    Ontario, Canada

--%>
<%@page import="oscar.OscarProperties"%>
<%@page import="org.oscarehr.util.PKCEUtils"%>
<%@page import="org.apache.log4j.Logger"%>
<%@page import="org.oscarehr.util.MiscUtils"%>
<%@page import="java.util.Map.Entry"%>
<%@page import="java.util.HashMap"%>
<%@page import="java.util.Map"%>
<%@page import="org.apache.cxf.jaxrs.ext.form.Form"%>
<%@page import="org.apache.commons.lang3.RandomStringUtils"%>
<%@page import="java.nio.charset.StandardCharsets"%>
<%@page import="java.nio.charset.Charset"%>
<%@page import="org.apache.commons.codec.binary.Base64"%>
<%@page import="java.security.MessageDigest"%>
<%@page import="java.util.Random"%>
<%@page import="java.net.URLEncoder"%>
<%@page import="javax.ws.rs.core.Response"%>
<%@page import="org.apache.cxf.configuration.jsse.TLSClientParameters"%>
<%@page import="org.apache.cxf.jaxrs.client.Client"%>
<%@page import="org.apache.cxf.jaxrs.client.WebClient"%>
<%@page import="org.apache.http.conn.ssl.SSLConnectionSocketFactory"%>
<%@page import="org.apache.http.conn.ssl.SSLContexts"%>
<%@page import="javax.net.ssl.SSLContext"%>
<%@page import="java.io.FileInputStream"%>
<%@page import="java.security.KeyStore"%>
<%@page import="java.net.URI"%>
<%@page import="org.apache.cxf.rs.security.oauth2.client.OAuthClientUtils"%>
<%@page import="java.nio.charset.StandardCharsets"%>
<%
	Logger logger = MiscUtils.getLogger();
	logger.info("OAUTH2 Login started");


    //create verifier and challenge
    byte[] array = new byte[50];
    new Random().nextBytes(array);
    String generatedString = RandomStringUtils.randomAlphabetic(50);
    
    String verifier = PKCEUtils.encodeBase64NoPadding(generatedString);
    logger.debug("verifier = "+verifier);

    String challenge = null;
    try {
    	challenge = PKCEUtils.generateChallengeS256(verifier);
    } catch(Exception e) {
    	logger.error("Error",e);
		//need to forward back to login page with error
    }    
    logger.debug("challenge = "+challenge);
    
    
	String authorizeUrl = OscarProperties.getInstance().getProperty("oneid.oauth2.authorizeUrl");
	String callbackUrl = OscarProperties.getInstance().getProperty("oneid.oauth2.callbackUrl");
	String clientId = OscarProperties.getInstance().getProperty("oneid.oauth2.clientId");
	String state = RandomStringUtils.randomAlphanumeric(20);
	

	Map<String, String> params = new HashMap<>();
	params.put("response_type", "code");
	//TODO: remove hard coded scopes
	params.put("scope", "openid user/Immunization.read user/Immunization.write user/Patient.read");
	
	params.put("code_challenge_method", "S256");
	
	params.put("code_challenge", challenge);
	params.put("redirect_uri", callbackUrl);
	params.put("client_id", clientId);
	params.put("state", state);
	//THIS WAS COMMENTED OUT - aud
	params.put("aud","https://provider.ehealthontario.on.ca");
	params.put("_profile","http://ehealthontario.ca/StructureDefinition/ca-on-dhir-profile-Immunization http://ehealthontario.ca/StructureDefinition/ca-on-dhir-profile-Patient");
	session.setAttribute("eho_verifier-" + state,verifier);
		
	if(request.getParameter("alreadyLoggedIn") != null && "true".equals(request.getParameter("alreadyLoggedIn"))) {
		session.setAttribute("eho_verifier-" + state + ".alreadyLoggedIn",true);
		session.setAttribute("eho_verifier-" + state + ".forwardURL",request.getParameter("forwardURL"));
	}

	WebClient wc = WebClient.create(authorizeUrl); 
	for (Entry<String, String> entry : params.entrySet()) {
		wc.query(entry.getKey(), entry.getValue());
	}
	 

	Response response2 = wc.header("Content-Type", "application/x-www-form-urlencoded").post("code_verifier=" +URLEncoder.encode(verifier,"UTF-8"));

	logger.info("Response Status from /Authorize =" + response2.getStatus());
	if(response2.getStatus() == 302) {
		logger.info("Redirecting to " + response2.getHeaderString("Location") );
		response.sendRedirect( response2.getHeaderString("Location"));
	} else {
		//unexpected
		logger.info("Received unexpected " + response2.getStatus());
		response.sendRedirect(request.getContextPath() + "/index.jsp?errorMessage=" + URLEncoder.encode("Received unexpected error from eHealth", "UTF-8" ));
	}
	
	
%>
