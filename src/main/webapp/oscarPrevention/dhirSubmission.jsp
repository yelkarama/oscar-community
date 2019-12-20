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

<%@page import="org.apache.commons.lang3.StringEscapeUtils"%>
<%@page import="org.hl7.fhir.r4.model.OperationOutcome"%>
<%@page import="java.net.URLEncoder"%>
<%@page import="org.oscarehr.integration.TokenExpiredException"%>
<%@page import="org.oscarehr.common.model.OscarLog"%>
<%@page import="oscar.log.LogAction"%>
<%@page import="org.apache.commons.lang3.StringUtils"%>
<%@page import="org.hl7.fhir.r4.model.Bundle.BundleEntryComponent"%>
<%@page import="org.oscarehr.integration.OneIDTokenUtils"%>
<%@page import="java.util.HashMap"%>
<%@page import="org.apache.cxf.configuration.jsse.TLSClientParameters"%>
<%@page import="java.io.FileInputStream"%>
<%@page import="java.security.KeyStore"%>
<%@page import="ca.uhn.fhir.context.FhirContext"%>
<%@page import="net.sf.json.JSONObject"%>
<%@page import="javax.ws.rs.core.Response"%>
<%@page import="java.util.Map.Entry"%>
<%@page import="org.apache.cxf.jaxrs.client.WebClient"%>
<%@page import="org.apache.http.impl.client.HttpClients"%>
<%@page import="org.apache.http.impl.client.CloseableHttpClient"%>
<%@page import="org.apache.http.client.config.RequestConfig"%>
<%@page import="org.apache.http.conn.ssl.SSLConnectionSocketFactory"%>
<%@page import="org.apache.http.conn.ssl.SSLContexts"%>
<%@page import="java.util.UUID"%>
<%@page import="java.util.Random"%>
<%@page import="java.util.List"%>
<%@page import="java.util.ArrayList"%>
<%@page import="org.oscarehr.common.model.DHIRSubmissionLog"%>
<%@page import="org.oscarehr.util.SpringUtils"%>
<%@page import="org.oscarehr.managers.DHIRSubmissionManager"%>
<%@page import="org.hl7.fhir.r4.model.Immunization"%>
<%@page import="org.hl7.fhir.r4.model.Patient"%>
<%@page import="org.hl7.fhir.r4.model.Bundle.BundleEntryComponent"%>
<%@page import="org.oscarehr.util.LoggedInInfo"%>
<%@page import="org.oscarehr.integration.fhirR4.builder.AbstractFhirMessageBuilder"%>
<%@page import="org.hl7.fhir.r4.model.Bundle"%>
<%@page import="java.util.Map"%>
<%@page import="java.io.InputStream"%>
<%@page import="org.apache.commons.io.IOUtils"%>
<%@page import="com.sun.codemodel.fmt.JSerializedObject"%>
<%@page import="org.apache.http.entity.ByteArrayEntity"%>
<%@page import="org.apache.http.HttpEntity"%>
<%@page import="org.apache.http.client.methods.HttpPost"%>
<%@page import="org.apache.log4j.Logger"%>
<%@page import="org.oscarehr.util.MiscUtils"%>
<%@page import="java.io.UnsupportedEncodingException"%>
<%@page import="java.io.IOException"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="org.apache.http.util.EntityUtils"%>
<%@page import="org.apache.http.impl.client.DefaultHttpClient"%>
<%@page import="org.apache.http.impl.conn.PoolingClientConnectionManager"%>
<%@page import="org.apache.http.conn.scheme.Scheme"%>
<%@page import="org.apache.http.conn.ssl.SSLSocketFactory"%>
<%@page import="javax.net.ssl.TrustManager"%>
<%@page import="org.apache.http.conn.ClientConnectionManager"%>
<%@page import="org.apache.http.conn.scheme.SchemeRegistry"%>
<%@page import="java.security.SecureRandom"%>
<%@page import="org.oscarehr.util.CxfClientUtils"%>
<%@page import="javax.net.ssl.SSLContext"%>
<%@page import="java.security.KeyManagementException"%>
<%@page import="java.security.NoSuchAlgorithmException"%>
<%@page import="org.apache.http.client.methods.HttpGet" %>
<%@page import="javax.servlet.http.Cookie" %>
<%@page import="oscar.OscarProperties" %>
<%@page import="org.apache.http.client.HttpClient" %>
<%@page import="org.apache.http.HttpResponse" %>
<%@page import="org.codehaus.jettison.json.*" %>


<%
	Logger logger = MiscUtils.getLogger();
    DHIRSubmissionManager submissionManager = SpringUtils.getBean(DHIRSubmissionManager.class);
    String uuid = request.getParameter("uuid");
    		 
	String action = request.getParameter("action");
    boolean refused = false;
    Response response2 = null;
    String body = null;
    Bundle bundle = null;
    
    if(!StringUtils.isEmpty(action) && "refuse".equals(action)) {
    	OscarLog log = new OscarLog();
    	log.setAction("DHIR.consent.refused");
    	log.setContent("");
    	log.setContentId("");
    	log.setData("");
    	log.setDemographicId(Integer.parseInt(request.getParameter("demographicNo")));
    	log.setProviderNo(LoggedInInfo.getLoggedInInfoFromSession(request).getLoggedInProviderNo());
       	LogAction.addLogSynchronous(log);
       	refused=true;
       	
    } else {
    
			
    
	
	OscarProperties oscarProperties = OscarProperties.getInstance();

	String oneIdEmail = session.getAttribute("oneIdEmail") != null ? session.getAttribute("oneIdEmail").toString() : "";

	String delegateOneIdEmail = session.getAttribute("delegateOneIdEmail") != null
	? session.getAttribute("delegateOneIdEmail").toString() : "";
	String providerEmail = oneIdEmail;

	//If there is a delegateOneIdEmail then it is used as the normal oneId email and the current user is the delegate as they are delegating for that person
	if (!delegateOneIdEmail.equals("")) {
		providerEmail = delegateOneIdEmail;
	}
	//logger.debug("providerEmail is " + providerEmail);
	
	KeyStore ks = KeyStore.getInstance("JKS");
	ks.load(new FileInputStream(OscarProperties.getInstance().getProperty("oneid.gateway.keystore")), 
			OscarProperties.getInstance().getProperty("oneid.gateway.keystore.password").toCharArray());

	//setup SSL
	SSLContext sslcontext = SSLContexts.custom().loadKeyMaterial(ks, OscarProperties.getInstance().getProperty("oneid.gateway.keystore.password").toCharArray()).build();
	sslcontext.getDefaultSSLParameters().setNeedClientAuth(true);
	sslcontext.getDefaultSSLParameters().setWantClientAuth(true);
	SSLConnectionSocketFactory sf = new SSLConnectionSocketFactory(sslcontext);

	TLSClientParameters tlsParams = new TLSClientParameters();
	tlsParams.setSSLSocketFactory(sslcontext.getSocketFactory());
	tlsParams.setDisableCNCheck(true);

	String consumerKey = OscarProperties.getInstance().getProperty("oneid.consumerKey");
	String consumerSecret = OscarProperties.getInstance().getProperty("oneid.consumerSecret");
	String gatewayUrl = OscarProperties.getInstance().getProperty("oneid.gateway.url");

		
	Map<String, String> params = new HashMap<>();
	String submissionURL = OscarProperties.getInstance().getProperty("oneid.gateway.dhir.submissionUrl");
	WebClient wc = WebClient.create(submissionURL);
	for (Entry<String, String> entry : params.entrySet()) {
		wc.query(entry.getKey(), entry.getValue());
	}

	WebClient.getConfig(wc).getHttpConduit().setTlsClientParameters(tlsParams);

	
	String accessToken = null;
	
	try { 
		accessToken = OneIDTokenUtils.getValidAccessToken(session);
	} catch(TokenExpiredException e) {
		response.sendRedirect(request.getContextPath() + "/eho/login2.jsp?alreadyLoggedIn=true&forwardURL=" + URLEncoder.encode(getCompleteURL(request),"UTF-8") );
		return;
	}
	
	
	Map<String,Bundle> bundles = (Map<String,Bundle> )session.getAttribute("bundles");
	bundle = bundles.get(uuid);
	
	String bundleJSON = FhirContext.forR4().newJsonParser().encodeResourceToString(bundle);
	
	response2 = wc
			.header("Authorization", "Bearer " + accessToken)
			.header("X-IBM-Client-Id", consumerKey)
			.header("X-IBM-Client-Secret", consumerSecret)
			.header("X-Request-Id",uuid)
			.header("Content-Type","application/json")
			.post(bundleJSON);

	logger.info("HTTP response code  = " + response2.getStatus());
	
	/*
	for(String key : response2.getHeaders().keySet()) {
		logger.info(key + "=" + response2.getHeaders().get(key));
	}
	*/
	body = response2.readEntity(String.class);
		
	logger.info("body=" + body);
    }
%>



<html:html locale="true">

<head>
<title>OSCAR Prevention Review Screen</title><!--I18n-->
<link rel="stylesheet" type="text/css" href="../share/css/OscarStandardLayout.css">
<link rel="stylesheet" type="text/css" media="all" href="../share/calendar/calendar.css" title="win2k-cold-1" />

<script type="text/javascript" src="<%=request.getContextPath()%>/js/jquery-1.7.1.min.js"></script>
<script type="text/javascript" src="../share/calendar/calendar.js" ></script>
<script type="text/javascript" src="../share/calendar/lang/<bean:message key="global.javascript.calendar"/>" ></script>
<script type="text/javascript" src="../share/calendar/calendar-setup.js" ></script>

<style type="text/css">
  div.ImmSet { background-color: #ffffff; }
  div.ImmSet h2 {  }
  div.ImmSet ul {  }
  div.ImmSet li {  }
  div.ImmSet li a { text-decoration:none; color:blue;}
  div.ImmSet li a:hover { text-decoration:none; color:red; }
  div.ImmSet li a:visited { text-decoration:none; color:blue;}


  ////////
  div.prevention {  background-color: #999999; }
  div.prevention fieldset {width:35em; font-weight:bold; }
  div.prevention legend {font-weight:bold; }

  ////////
</style>



<style type="text/css">
	table.outline{
	   margin-top:50px;
	   border-bottom: 1pt solid #888888;
	   border-left: 1pt solid #888888;
	   border-top: 1pt solid #888888;
	   border-right: 1pt solid #888888;
	}
	table.grid{
	   border-bottom: 1pt solid #888888;
	   border-left: 1pt solid #888888;
	   border-top: 1pt solid #888888;
	   border-right: 1pt solid #888888;
	}
	td.gridTitles{
		border-bottom: 2pt solid #888888;
		font-weight: bold;
		text-align: center;
	}
        td.gridTitlesWOBottom{
                font-weight: bold;
                text-align: center;
        }
	td.middleGrid{
	   border-left: 1pt solid #888888;
	   border-right: 1pt solid #888888;
           text-align: center;
	}


label{
float: left;
width: 120px;
font-weight: bold;
}

label.checkbox{
float: left;
width: 116px;
font-weight: bold;
}

label.fields{
float: left;
width: 80px;
font-weight: bold;
}

span.labelLook{
font-weight:bold;

}

input, textarea,select{

//margin-bottom: 5px;
}

textarea{
width: 450px;
height: 100px;
}


.boxes{
width: 1em;
}

#submitbutton{
margin-left: 120px;
margin-top: 5px;
width: 90px;
}

br{
clear: left;
}
</style>


</head>

<script>
<%
	if(refused) {
		%>
		$(document).ready(function(){
			window.close();
		});
		<%
	}
%>
</script>
<body class="BodyStyle" vlink="#0000FF" onload="disableifchecked(document.getElementById('neverWarn'),'nextDate');">
<!--  -->
    <table  class="MainTable" id="scrollNumber1" name="encounterTable">
        <tr class="MainTableTopRow">
            <td class="MainTableTopRowLeftColumn" width="100" >
              DHIR Submission
            </td>
            <td class="MainTableTopRowRightColumn">
                <table class="TopStatusBar">
                    <tr>
                        <td >
                            
                        </td>
                        <td  >&nbsp;

                        </td>
                        <td style="text-align:right">
                                <oscar:help keywords="prevention" key="app.top1"/> | <a href="javascript:popupStart(300,400,'About.jsp')" ><bean:message key="global.about" /></a> | <a href="javascript:popupStart(300,400,'License.jsp')" ><bean:message key="global.license" /></a>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td class="MainTableLeftColumn" valign="top">
               &nbsp;
            </td>
            <td valign="top" class="MainTableRightColumn">
            
            
<%
	if(refused) {
		%>
		<h2>Submission was not sent due to refusal of consent </h2>
		<%
	} else {
%>
<%

if(response2.getStatus() == 201) {
	//success
	Bundle responseBundle = (Bundle) FhirContext.forR4().newJsonParser().parseResource(body);
	List<DHIRSubmissionLog> logs= new ArrayList<DHIRSubmissionLog>();
	String demographicNo = null;
	
	for(BundleEntryComponent bec : responseBundle.getEntry()) {
		String location = bec.getResponse().getLocation(); //Immunization/756f4e4c-ddb2-4072-8891-e81c7b04ae90
		String status = bec.getResponse().getStatus(); //201
		logger.info("location=" + location + ",status=" + status);
	}
	
	for(BundleEntryComponent bec : bundle.getEntry()) {
		if(bec.getResource().fhirType().equals("Patient")) {
	        Patient patient  = (Patient)bec.getResource();
	        demographicNo = patient.getId();
	        break;
	    }

	}
	
	for(BundleEntryComponent bec : bundle.getEntry()) {
        if(bec.getResource().fhirType().equals("Immunization")) {
		    Immunization i = (Immunization)bec.getResource();
		
		    DHIRSubmissionLog log = new DHIRSubmissionLog();
		    log.setDateCreated(new java.util.Date());
		    log.setDemographicNo(Integer.parseInt(demographicNo));
		    log.setPreventionId(Integer.parseInt(i.getId()));
		    log.setStatus("Error");
		    log.setSubmitterProviderNo(LoggedInInfo.getLoggedInInfoFromSession(request).getLoggedInProviderNo());
		    log.setBundleId(bundle.getId());
		    submissionManager.save(log);
		
		    logs.add(log);
        }
	 }

	
	String val = response2.getHeaderString("X-GtwyTxId");
	String clientId = response2.getHeaderString("x-response-id");
	
for(DHIRSubmissionLog log : logs) {
	log.setStatus("Submitted");
	log.setTransactionId(val);
	log.setClientResponseId(clientId);
	//log.setClientRequestId(clientRequestId);
	log.setClientRequestId(uuid);
	submissionManager.update(log);
}
%>
	<h2>Submission sent for review. You may find the reference number in the prevention's Summary field. </h2>
	<input type="button" value="Close Window" onClick="window.close()"/>
<%

	
} else if(response2.getStatus() == 422) {
	//should be some operational outcome
	if(body != null) {
		try {
			OperationOutcome outcome = FhirContext.forR4().newJsonParser().parseResource(OperationOutcome.class, body);
			if(outcome != null) {
				if(outcome.getText() != null && "Generated".equals(outcome.getText().getStatus().getDisplay()) ) {
					String text = outcome.getText().getDiv().toString();
					%>
					<h2>Submission was not successfully accepted. </h2>
					<h3><%=StringEscapeUtils.unescapeHtml3(text) %></h3>
					<br/>
					<input type="button" value="Edit Prevention" onClick="window.location.href='<%=request.getContextPath()%>/oscarPrevention/AddPreventionData.jsp?id=<%=request.getParameter("preventionId")%>&demographic_no=<%=request.getParameter("demographicNo")%>'"/>
					&nbsp;&nbsp;
					<input type="button" value="Close Window" onClick="window.close()"/>
				<%					
				}
			}
		}catch(Exception e) {
	
		}
	}
} else if(response2.getStatus() == 400 ) {
	//invalid resource
	%>
	<h2>Submission was not successfully accepted. </h2>
	<%
} else {
	//some other error
	%>
	<h2>Submission was not successfully accepted. </h2>
	<%
}

	}
%>

 </td>
        </tr>
        <tr>
            <td class="MainTableBottomRowLeftColumn">
            &nbsp;
            </td>
            <td class="MainTableBottomRowRightColumn" valign="top">
            &nbsp;
            </td>
        </tr>
    </table>

</body>
</html:html>

<%!
 String getCompleteURL(HttpServletRequest request) {
	StringBuffer requestURL = request.getRequestURL();
	if (request.getQueryString() != null) {
	    requestURL.append("?").append(request.getQueryString());
	}
	String completeURL = requestURL.toString();
	
	return completeURL;
}
%>