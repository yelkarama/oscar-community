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

<%@page import="org.oscarehr.common.service.AcceptableUseAgreementManager"%>
<%@page import="oscar.OscarProperties, javax.servlet.http.Cookie, oscar.oscarSecurity.CookieSecurity, oscar.login.UAgentInfo" %>
<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean" %>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html" %>
<%@ taglib uri="/WEB-INF/struts-logic.tld" prefix="logic" %>
<%@ taglib uri="/WEB-INF/caisi-tag.tld" prefix="caisi" %>
<caisi:isModuleLoad moduleName="ticklerplus"><%
    if(session.getValue("user") != null) {
        response.sendRedirect("provider/providercontrol.jsp");
    }
%></caisi:isModuleLoad><%
OscarProperties props = OscarProperties.getInstance();

// clear old cookies
Cookie prvCookie = new Cookie(CookieSecurity.providerCookie, "");
prvCookie.setPath("/");
response.addCookie(prvCookie);

// Initialize browser info variables
String userAgent = request.getHeader("User-Agent");
String httpAccept = request.getHeader("Accept");
UAgentInfo detector = new UAgentInfo(userAgent, httpAccept);

// This parameter exists only if the user clicks the "Full Site" link on a mobile device
if (request.getParameter("full") != null) {
    session.setAttribute("fullSite","true");
}

// If a user is accessing through a smartphone (currently only supports mobile browsers with webkit),
// and if they haven't already clicked to see the full site, then we set a property which is
// used to bring up iPhone-optimized stylesheets, and add or remove functionality in certain pages.
if (detector.detectSmartphone() && detector.detectWebkit()  && session.getAttribute("fullSite") == null) {
    session.setAttribute("mobileOptimized", "true");
} else {
    session.removeAttribute("mobileOptimized");
}
Boolean isMobileOptimized = session.getAttribute("mobileOptimized") != null;


//Input field styles
String login_error="";
%>

<html:html locale="true">
    <head>
    <link rel="shortcut icon" href="images/Oscar.ico" />
<script type="text/javascript" src="<%= request.getContextPath() %>/js/global.js"></script>
        <html:base/>
        <% if (isMobileOptimized) { %><meta name="viewport" content="initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no, width=device-width"/><% } %>
        <title>
            <% if (props.getProperty("logintitle", "").equals("")) { %>
            <bean:message key="loginApplication.title"/>
            <% } else { %>
            <%= props.getProperty("logintitle", "")%>
            <% } %>
        </title>
        <!--LINK REL="StyleSheet" HREF="web.css" TYPE="text/css"-->
		<link href='https://fonts.googleapis.com/css?family=Roboto:300,400,500,600,700' rel='stylesheet' type='text/css'>

        <script language="JavaScript">
        function showHideItem(id){
            if(document.getElementById(id).style.display == 'none')
                document.getElementById(id).style.display = 'block';
            else
                document.getElementById(id).style.display = 'none';
        }
        
  <!-- hide
  function setfocus() {
    document.loginForm.username.focus();
    document.loginForm.username.select();
  }
  function popupPage(vheight,vwidth,varpage) {
    var page = "" + varpage;
    windowprops = "height="+vheight+",width="+vwidth+",location=no,scrollbars=yes,menubars=no,toolbars=no,resizable=yes";
    var popup=window.open(page, "gpl", windowprops);
  }
  -->
        </script>
        
        <style type="text/css">
            body { 
               margin: 0;
				font-family: 'Roboto', Helvetica, Arial, sans-serif;
				font-size: 16px;
				color: #333333;
				background-color: #ffffff;
            }
            
            * {
			    -webkit-box-sizing: border-box;
			    -moz-box-sizing: border-box;
			    box-sizing: border-box;
			}
            
            h1 {
                font-size: 38px;
		    	font-weight: 300;
		    }
		    
		    button, input, optgroup, select, textarea {
			    margin: 0;
			    font: inherit;
			    color: inherit;
			}
		    
		    input {
			    line-height: normal;
			}
            
            button, input, select, textarea {
			    font-family: inherit;
			    font-size: inherit;
			    line-height: inherit;
			}
			
			.heading, .loginContainer {
				text-align: center;
			}
			
			.powered {
				margin-right: auto;
				margin-left: auto;
			}
			
			.powered .details {
				text-align: right;
			    margin: 10px 20px 0 0;
			    float: left;
			    width: 35%;
			}
			
            .loginContainer {
            	padding: 30px 15px;
				margin-right: auto;
				margin-left: auto;
            }
            
            .panel {
                margin-bottom: 20px;
			    background-color: #fff;
			    border: 1px solid transparent;
			    border-radius: 4px;
			    -webkit-box-shadow: 0 1px 1px rgba(0,0,0,.05);
			    box-shadow: 0 1px 1px rgba(0,0,0,.05);
			}
			
			.panel-body {
			    padding: 10px 40px 40px;
			}
            
            .panel-default {
           		border-color: #ddd;
            }
            
			.form-group {
			    margin-bottom: 15px;
			}
			
			label {
			    display: inline-block;
			    max-width: 100%;
			    margin-bottom: 5px;
			    font-weight: 700;
			}
			
			.form-control {
			    display: block;
			    width: 100%;
			    height: 34px;
			    padding: 6px 12px;
			    font-size: 14px;
			    line-height: 1.42857143;
			    color: #555;
			    background-color: #fff;
			    background-image: none;
			    border: 1px solid #ccc;
			    border-radius: 4px;
			    -webkit-box-shadow: inset 0 1px 1px rgba(0,0,0,.075);
			    box-shadow: inset 0 1px 1px rgba(0,0,0,.075);
			    -webkit-transition: border-color ease-in-out .15s,-webkit-box-shadow ease-in-out .15s;
			    -o-transition: border-color ease-in-out .15s,box-shadow ease-in-out .15s;
			    transition: border-color ease-in-out .15s,box-shadow ease-in-out .15s;
			}
			
			.has-error .form-control {
			    border-color: #a94442;
			    -webkit-box-shadow: inset 0 1px 1px rgba(0,0,0,.075);
			    box-shadow: inset 0 1px 1px rgba(0,0,0,.075);
			}
			
			.btn {
			    display: inline-block;
			    padding: 6px 12px;
			    margin-bottom: 0;
			    font-size: 14px;
			    font-weight: 400;
			    line-height: 1.42857143;
			    text-align: center;
			    white-space: nowrap;
			    vertical-align: middle;
			    -ms-touch-action: manipulation;
			    touch-action: manipulation;
			    cursor: pointer;
			    -webkit-user-select: none;
			    -moz-user-select: none;
			    -ms-user-select: none;
			    user-select: none;
			    background-image: none;
			    border: 1px solid transparent;
			    border-radius: 4px;
			}
			
			.btn-primary {
			    color: #fff;
			    background-color: #53b848;
			    border-color: #3f9336;
			}
			
			.btn-block {
			    display: block;
			    width: 100%;
			}
			
			button, html input[type=button], input[type=reset], input[type=submit] {
			    -webkit-appearance: button;
			    cursor: pointer;
			}
			
			.btn.active.focus, .btn.active:focus, .btn.focus, .btn:active.focus, .btn:active:focus, .btn:focus {
			    outline: thin dotted;
			    outline: 5px auto -webkit-focus-ring-color;
			    outline-offset: -2px;
			}
			
			.btn.focus, .btn:focus, .btn:hover {
			    color: #333;
			    text-decoration: none;
			}
			
			.btn.active, .btn:active {
			    background-image: none;
			    outline: 0;
			    -webkit-box-shadow: inset 0 3px 5px rgba(0,0,0,.125);
			    box-shadow: inset 0 3px 5px rgba(0,0,0,.125);
			}
			
			.btn-primary.focus, .btn-primary:focus {
			    color: #fff;
			    background-color: #286090;
			    border-color: #122b40;
			}
			
			.btn-primary:hover {
			    color: #fff;
			    background-color: #3f9336;
			    border-color: #3f9336;
			}
			
			.btn-primary.active, .btn-primary:active, .open>.dropdown-toggle.btn-primary {
			    color: #fff;
			    background-color: #286090;
			    border-color: #204d74;
			}
			
			.btn-primary.active, .btn-primary:active, .open>.dropdown-toggle.btn-primary {
			    background-image: none;
			}
			
			input[type=button].btn-block, input[type=reset].btn-block, input[type=submit].btn-block {
			    width: 100%;
			}
			
			.btn.active.focus, .btn.active:focus, .btn.focus, .btn:active.focus, .btn:active:focus, .btn:focus {
			    outline: thin dotted;
			    outline: 5px auto -webkit-focus-ring-color;
			    outline-offset: -2px;
			}
			
			.btn-primary.active.focus, .btn-primary.active:focus, .btn-primary.active:hover, .btn-primary:active.focus, .btn-primary:active:focus, .btn-primary:active:hover, .open>.dropdown-toggle.btn-primary.focus, .open>.dropdown-toggle.btn-primary:focus, .open>.dropdown-toggle.btn-primary:hover {
			    color: #fff;
			    background-color: #204d74;
			    border-color: #122b40;
			}
            
            td.topbar{
               background-color: rgb(83, 184, 72);
            }
            td.leftbar{
                background-color:  #6C706E;
                color: white;
            }
            td.leftinput{
                background-color: #f5fffa;
            }
            td#loginText{
                width:200px;
                font-size: small;
                }
            span#buildInfo{
                float: right; color:#FFFFFF; font-size: xx-small; text-align: right;
            }
            
			span.extrasmall{
			    font-size: small;
			    float: left;
			    margin: 10px 0 20px;
			}
            #mobileMsg { display: none; }
            
            @media (min-width: 768px) {
				.loginContainer, .powered {
					width: 450px;
				}
			}
			
			@media (min-width: 992px) {
				
			}
			
			@media (min-width: 1200px) {
				
			}
        </style>
        <% if (isMobileOptimized) { %>
        <!-- Small adjustments are made to the mobile stylesheet -->
        <style type="text/css">
            html { -webkit-text-size-adjust: none; }
            td.topbar{ width: 75%; }
            td.leftbar{ width: 25%; }
            span.extrasmall{ font-size: small; }
            #browserInfo, #logoImg, #buildInfo { display: none; }
            #mobileMsg { display: inline; }
        </style>
        <% } %>
    </head>
    
    <body onLoad="setfocus()" bgcolor="#ffffff">
        
        <div class="heading">
        	<img src="images/Logo.png" border="0" style="margin: 25px auto;">
        </div>
        <div class="loginContainer">
	        <div class="panel panel-default">
	        	<h1>OSCAR EMR Login</h1>
	        	
	        	<%String key = "loginApplication.formLabel" ;
                    if(request.getParameter("login")!=null && request.getParameter("login").equals("failed") ){
                    key = "loginApplication.formFailedLabel" ;
                    login_error="has-error";                    
                    }
                    %>

    			  	<div class="panel-body">
    			    	<div class="leftinput" border="0" width="100%" ng-app="indexApp" ng-controller="indexCtrl"> <!-- id="loginText" -->
    				    	<html:form action="login" >
    							<div class="form-group <%=login_error%>"> 
    	                        	<input type="text" name="username" placeholder="Enter your username" value="" size="15" maxlength="15" autocomplete="off" class="form-control" ng-model="username"/> <%-- class="<%=login_input_style %>" --%>
    	                        </div>
    	                        
    	                        <div class="form-group <%=login_error%>">               
    	                        	<input type="password" name="password" placeholder="Enter your password" value="" size="15" maxlength="32" autocomplete="off" class="form-control" ng-model="password"/>
    	                        </div>
    	                        
    	                        <div class="form-group <%=login_error%>">
    	                        	<input type="password" name="pin" placeholder="Enter your PIN" value="" size="15" maxlength="15" autocomplete="off" class="form-control" ng-model="pin"/>
    	                        	<span class="extrasmall">
    		                            <bean:message key="loginApplication.formCmt"/>
    		                        </span>
    	                        </div>
    	                        
    	                        <input type=hidden name='propname' value='<bean:message key="loginApplication.propertyFile"/>' />
    	                        <input class="btn btn-primary btn-block" type="submit" value="<bean:message key="index.btnSignIn"/>" />
    	                        <% if (detector.detectSmartphone() && detector.detectWebkit()) { 
    	                        	session.setAttribute("fullSite","true"); %>
    	                        	<input class="btn btn-primary btn-block" type="submit" value="<bean:message key="index.btnSignIn"/> using <bean:message key="loginApplication.fullSite"/>" />
    	                        <% } %>
    						</html:form>
    			                        
                        <%if (AcceptableUseAgreementManager.hasAUA()){ %>
                        <span class="extrasmall">
                        	<bean:message key="global.aua" /> &nbsp; <a href="javascript:void(0);" onclick="showHideItem('auaText');"><bean:message key="global.showhide"/></a>
                        </span>
                        <%} %>       
			        </div>
			  	</div>
			</div>
		</div>
		<div class="powered">
			<span class="details">
				<div>Powered</div>
				<div>by</div>
			</span>
			<img alt="KAI Innovations" src="images/logo/KAI_LOGO.png">
		</div>        
    </body>
</html:html>
