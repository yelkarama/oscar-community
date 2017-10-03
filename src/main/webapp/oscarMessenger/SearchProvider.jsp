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

<%@page import="org.oscarehr.util.LoggedInInfo" %>
<%@ page import="org.apache.xpath.operations.Bool" %>
<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean" %>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html" %>
<%@ taglib uri="/WEB-INF/struts-logic.tld" prefix="logic" %>
<%@ taglib uri="/WEB-INF/oscar-tag.tld" prefix="oscar" %>
<%@ taglib uri="/WEB-INF/security.tld" prefix="security" %>
<%
	String roleName$ = (String) session.getAttribute("userrole") + "," + (String) session.getAttribute("user");
	boolean authed = true;
%>
<security:oscarSec roleName="<%=roleName$%>" objectName="_msg" rights="r" reverse="<%=true%>">
	<%authed = false; %>
	<%response.sendRedirect("../securityError.jsp?type=_msg");%>
</security:oscarSec>
<%
	if (!authed) {
		return;
	}

	Boolean warningMessage = (request.getAttribute("noResults") != null);
	String providerName = (request.getAttribute("searchedProviderName") == null) ? "" : (String) request.getAttribute("searchedProviderName");
	String startDateString = (request.getAttribute("searchedStartDateString") == null) ? "" : (String) request.getAttribute("searchedStartDateString");
	String endDateString = (request.getAttribute("searchedEndDateString") == null) ? "" : (String) request.getAttribute("searchedEndDateString");
%>


<logic:notPresent name="msgSessionBean" scope="session">
	<logic:redirect href="index.jsp"/>
</logic:notPresent>
<logic:present name="msgSessionBean" scope="session">
	<bean:define id="bean" type="oscar.oscarMessenger.pageUtil.MsgSessionBean" name="msgSessionBean" scope="session"/>
	<logic:equal name="bean" property="valid" value="false">
		<logic:redirect href="index.jsp"/>
	</logic:equal>
</logic:present>


<html:html locale="true">
	<head>
		<html:base/>
		<script type="text/javascript" src="<%=request.getContextPath()%>/js/global.js"></script>
		<script type="text/javascript" src="<%=request.getContextPath()%>/js/jquery-3.1.0.min.js"></script>
		<script type="text/javascript" src="<%=request.getContextPath()%>/js/jquery-ui-1.8.18.custom.min.js"></script>
		<script type="text/javascript" src="<%=request.getContextPath()%>/library/bootstrap/3.0.0/js/bootstrap.js"></script>
		<script type="text/javascript" src="<%=request.getContextPath() %>/js/bootstrap-datepicker.js"></script>
		<script type="text/javascript" src="<%=request.getContextPath() %>/library/typeahead.js/typeahead-0.11.1.js"></script>
		<link href="<%=request.getContextPath()%>/library/bootstrap/3.0.0/css/bootstrap.min.css" rel="stylesheet" type="text/css"/>
		<link href="<%=request.getContextPath()%>/js/jquery_css/smoothness/jquery-ui-1.7.3.custom.css" rel="stylesheet" type="text/css"/>
		<link href="<%=request.getContextPath()%>/css/main-kai.css" rel="stylesheet" type="text/css"/>
		<link href="<%=request.getContextPath() %>/css/datepicker.css" rel="stylesheet" type="text/css"/>
		<title>
			<bean:message key="oscarMessenger.DisplayMessages.title"/>
		</title>
		<style type="text/css">
			.flow-root {
				display: flow-root;
			}
			.inline {
				display: inline;
			}
			
			.no-margin {
				margin: 0;
			}
			
			h3 {
				font-weight: bold;
			}

			@media (min-width: 300px) {
				.container {
					width: 300px;
				}
			}
			
			.typeahead:focus {
				border: 2px solid #0097cf;
			}
			.tt-hint {
				color: #999
			}
			.tt-menu {
				width: 238px;
				padding: 4px 0;
				background-color: #fff;
				border: 1px solid #ccc;
				border-radius: 4px;
				box-shadow: 0 5px 10px rgba(0,0,0,.2);
			}
			.tt-suggestion {
				padding: 3px 10px;
			}
			.tt-suggestion:hover {
				cursor: pointer;
				color: #fff;
				background-color: #53B848;
			}
			.tt-suggestion.tt-cursor {
				color: #fff;
				background-color: #53B848;

			}
			.tt-suggestion p {
				margin: 0;
			}

		</style>
	</head>

	<body class="BodyStyle" vlink="#0000FF" onload="window.focus()">
		<nav class="navbar navbar-inverse" role="navigation">
			<div class="navbar-header">
				<span class="navbar-brand">Search Provider's Messages</span>
			</div>
			<div class="collapse navbar-collapse">
				<ul class="nav navbar-nav navbar-right">
					<li><a href="<%=request.getContextPath()%>/oscarMessenger/DisplayMessages.jsp">Back to Messenger</a></li>
				</ul>
			</div>
		</nav>
		<% if (warningMessage) { %>
		<div class="container">
			<div class="alert alert-warning">
				No results found for this search
			</div>
		</div>
		<% } %>
		<form class="container" action="<%=request.getContextPath()%>/oscarMessenger/SearchProvider.do" method="post">
			<div class="panel panel-default">
				<div class="panel-body">
					<label for="providerName" class="control-label">Clinician:
						<input class="form-control" type="text" style="width: 238px" id="providerName" name="providerName" placeholder="Search Provider Name..." 
							   value="<%=providerName%>"/>
					</label>
					<div>
						<label class="control-label" for="startDay">From Date:</label>
						<label class="input-group" style="width: 238px">
							<input type="date" class="form-control" id="startDay" name="startDay" placeholder="yyyy-mm-dd"
								   value="<%=startDateString%>"/>
							<span class="input-group-addon">
								<span class="glyphicon glyphicon-calendar"></span>
							</span>
						</label>
					</div>
					<div>
						<label class="control-label" for="endDay">To Date:</label>
						<label class="input-group" style="width: 238px">
							<input type="date" class="form-control" id="endDay" name="endDay" placeholder="yyyy-mm-dd"
								   value="<%=endDateString%>"/>
							<span class="input-group-addon">
								<span class="glyphicon glyphicon-calendar"></span>
							</span>
						</label>
					</div>
					<input class="btn btn-primary no-margin" style="width: 100%;" type="submit" id="search" value="Search"/>
				</div>
			</div>
		</form>
	<script type="application/javascript">

		var providerNameMatcher = function(string) {
			return function findMatches(q, cb) {
				var matches;
				var substringRegex;
				matches = [];
				substringRegex = new RegExp(q, 'i');
				$.each(string, function(i, str) {
					if (substringRegex.test(str)) {
						matches.push(str);
					}
				});
				cb(matches);
			};
		};
		
		$(document).ready(function() {
			// Get list of providers
			var providers = [];
			$.ajax({
				url: "/oscar/ws/rs/providerService/providers_json",
				type: "GET",
				dataType : "json"
			}).done(function( json ) {
				for (var i = 0; i < json.content.length; i++) {
					providers.push(json.content[i].name);
				}
				$('#providerName').typeahead(
					{ highlight: true },
					{ name: 'providers', source: providerNameMatcher(providers)}
				);
			});
		});
	</script>
	</body>
</html:html>