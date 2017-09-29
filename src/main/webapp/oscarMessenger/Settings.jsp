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
<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean" %>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html" %>
<%@ taglib uri="/WEB-INF/struts-logic.tld" prefix="logic" %>
<%@ taglib uri="/WEB-INF/oscar-tag.tld" prefix="oscar" %>
<%@ page import="org.oscarehr.util.SpringUtils" %>
<%@ page import="org.oscarehr.common.dao.MessageResponderDao" %>
<%@ page import="org.oscarehr.common.model.MessageResponder" %>
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

	LoggedInInfo loggedInInfo = LoggedInInfo.getLoggedInInfoFromSession(request);
	String providerNo = loggedInInfo.getLoggedInProviderNo();
	MessageResponderDao messageResponderDao = SpringUtils.getBean(MessageResponderDao.class);
	MessageResponder lastResponder = messageResponderDao.findNewestByProvider(providerNo);
	if (lastResponder == null) {
	    lastResponder = new MessageResponder();
		lastResponder.setProviderNo(providerNo);
		lastResponder.setSubject("");
		lastResponder.setMessage("");
		lastResponder.setArchived(true);
	}

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
		<link href="<%=request.getContextPath()%>/library/bootstrap/3.0.0/css/bootstrap.min.css" rel="stylesheet" type="text/css"/>
		<link href="<%=request.getContextPath()%>/js/jquery_css/smoothness/jquery-ui-1.7.3.custom.css" rel="stylesheet" type="text/css"/>
		<link href="<%=request.getContextPath()%>/css/main-kai.css" rel="stylesheet" type="text/css"/>
		<link href="<%=request.getContextPath() %>/css/datepicker.css" rel="stylesheet" type="text/css">
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
		</style>

		<script type="text/javascript">

		</script>
	</head>

	<body class="BodyStyle" vlink="#0000FF" onload="window.focus()">
		<nav class="navbar navbar-inverse" role="navigation" style="background-color: #53B848;">
			<div class="navbar-header">
				<span class="navbar-brand">Messenger Settings</span>
			</div>
			<div class="collapse navbar-collapse navbar-ex1-collapse">
				<ul class="nav navbar-nav navbar-right">
					<li><a href="<%=request.getContextPath()%>/oscarMessenger/DisplayMessages.jsp">Back to Messenger</a></li>
				</ul>
			</div>
		</nav>
		<form class="container" action="<%=request.getContextPath()%>/oscarMessenger/Settings.do" method="post">
			<!--Vacation Responder-->
			<div class="panel panel-default">
				<div class="panel-heading flow-root">
					<h3 class="panel-title inline">Vacation Responder</h3>
					<small class="inline">Sends an automatic reply to incoming messages</small>
					<div class="checkbox pull-right no-margin">
						<label>
							<input type="checkbox" id="responderEnabled" name="responderEnabled" value="true" 
									<%=(!lastResponder.isArchived()?"checked=\"checked\"":"")%>
									onchange="setEnabled($(this).is(':checked'), $('#responderFieldset'))"/>Enabled
						</label>
					</div>
				</div>
				<div class="panel-body form-horizontal">
					<fieldset id="responderFieldset">
						<div class="form-group">
							<label class="col-sm-2 control-label" for="startDay">Start Day</label>
							<div class="col-sm-4">
								<label class="input-group">
									<input type="date" class="form-control" id="startDay" name="startDay" placeholder="yyyy-mm-dd" value="<%=lastResponder.getStartDate()!=null?lastResponder.getStartDate():""%>"/>
									<span class="input-group-addon">
										<span class="glyphicon glyphicon-calendar"></span>
									</span>
								</label>
							</div>
							<label class="col-sm-2 control-label" for="endDay">End Day</label>
							<div class="col-sm-4">
								<label class="input-group">
									<input type="date" class="form-control" id="endDay" name="endDay" placeholder="yyyy-mm-dd" value="<%=lastResponder.getEndDate()!=null?lastResponder.getEndDate():""%>"/>
									<span class="input-group-addon">
										<span class="glyphicon glyphicon-calendar"></span>
									</span>
								</label>
							</div>
						</div>
						<div class="form-group">
							<label for="subject" class="col-sm-2 control-label">Subject</label>
							<div class="col-sm-10">
								<input type="text" class="form-control" id="subject" name="subject" value="<%=lastResponder.getSubject()%>"/>
							</div>
						</div>
						<div class="form-group">
							<label for="message" class="col-sm-2 control-label">Message</label>
							<div class="col-sm-10">
								<textarea class="form-control" id="message" name="message" style="resize:vertical;"><%=lastResponder.getMessage()%></textarea>
							</div>
						</div>
					</fieldset>
					<div class="form-group no-margin">
						<div class="col-sm-12">
							<input type="hidden" name="method" value="saveResponder"/>
							<input class="btn btn-primary pull-right no-margin" type="submit" id="saveResponder" value="Save Changes"/>
						</div>
					</div>
				</div>
			</div>
			<!--Message Search-->
			<%--<div class="panel panel-default">--%>
				<%--<div class="panel-heading flow-root">--%>
					<%--<h3 class="panel-title inline">Message Search</h3>--%>
					<%--<small class="inline">Sends an automatic reply to incoming messages</small>--%>
					<%--<div class="checkbox pull-right no-margin">--%>
						<%--<label>--%>
							<%--<input type="checkbox" name="responderEnabled"/>Enabled--%>
						<%--</label>--%>
					<%--</div>--%>
				<%--</div>--%>
				<%--<div class="panel-body">--%>
					<%--<form class="form-horizontal no-margin" role="form">--%>
						<%--<div class="form-group">--%>
							<%--<label class="col-sm-2 control-label" for="firstDay">First Day</label>--%>
							<%--<div class="col-sm-4">--%>
								<%--<input type="date" class="form-control" id="firstDay" name="firstDay" placeholder="yyyy-mm-dd"/>--%>
							<%--</div>--%>
							<%--<label class="col-sm-2 control-label" for="lastDay">Last Day</label>--%>
							<%--<div class="col-sm-4">--%>
								<%--<input type="date" class="form-control" id="lastDay" name="lastDay" placeholder="yyyy-mm-dd"/>--%>
							<%--</div>--%>
						<%--</div>--%>
						<%--<div class="form-group">--%>
							<%--<label for="subject" class="col-sm-2 control-label">Subject</label>--%>
							<%--<div class="col-sm-10">--%>
								<%--<input type="text" class="form-control" id="subject" name="subject"/>--%>
							<%--</div>--%>
						<%--</div>--%>
						<%--<div class="form-group">--%>
							<%--<label for="message" class="col-sm-2 control-label">Message</label>--%>
							<%--<div class="col-sm-10">--%>
								<%--<textarea class="form-control" id="message" name="message" style="resize:vertical;"></textarea>--%>
							<%--</div>--%>
						<%--</div>--%>
						<%--<div class="form-group no-margin">--%>
							<%--<div class="col-sm-12">--%>
								<%--<input class="btn btn-primary pull-right no-margin" type="submit" name="saveResponder" id="saveResponder" value="Save Changes"/>--%>
							<%--</div>--%>
						<%--</div>--%>
					<%--</form>--%>
				<%--</div>--%>
			<%--</div>--%>
		</form>
	<script type="application/javascript">


		
		function setEnabled(setEnabled, fieldset) {
			if (setEnabled) {
				fieldset.removeAttr('disabled');
			} else {
				fieldset.attr('disabled', true);
			}
		}
		
		$(document).ready(function () {
			// set initial checkboxes
			$('#responderEnabled').trigger('onchange');
		});
		
	</script>
	</body>
</html:html>