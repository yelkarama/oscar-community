<%@ taglib prefix="security" uri="/oscarSecuritytag" %>
<%@ page import="org.oscarehr.PMmodule.dao.ProviderDao" %>
<%@ page import="org.oscarehr.util.SpringUtils" %>
<%@ page import="org.oscarehr.common.model.Provider" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="org.oscarehr.common.dao.MyGroupDao" %>
<%@ page import="org.oscarehr.util.LoggedInInfo" %>
<%@ page import="java.util.Collections" %>
<!DOCTYPE html>
<html lang="en">
<%
	String roleName$ = (String)session.getAttribute("userrole") + "," + (String) session.getAttribute("user");
	boolean authed=true;
%>
<security:oscarSec roleName="<%=roleName$%>" objectName="_appointment,_day" rights="r" reverse="<%=true%>">
	<%authed=false; %>
	<%response.sendRedirect(request.getContextPath() + "/securityError.jsp?type=_appointment");%>
</security:oscarSec>
<%
	if(!authed) {
		return;
	}
%>
<head>
    <meta charset="UTF-8">
	<script type="text/javascript" src="<%=request.getContextPath()%>/js/global.js"></script>
	<script type="text/javascript" src="<%=request.getContextPath()%>/js/jquery-3.1.0.min.js"></script>
	<script type="text/javascript" src="<%=request.getContextPath()%>/js/jquery-ui-1.8.18.custom.min.js"></script>
	<script type="text/javascript" src="<%=request.getContextPath()%>/library/bootstrap/3.0.0/js/bootstrap.js"></script>
	<link href="<%=request.getContextPath()%>/library/bootstrap/3.0.0/css/bootstrap.min.css" rel="stylesheet" type="text/css">
	<link href="<%=request.getContextPath()%>/js/jquery_css/smoothness/jquery-ui-1.7.3.custom.css" rel="stylesheet" type="text/css">
	<link href="<%=request.getContextPath()%>/css/main-kai.css" rel="stylesheet" type="text/css"/>
    <title>Create a temporary custom schedule</title>
	<style type="text/css">
		.fixed-header {
			height: 100%;
		}
		.fixed-header thead tr {
			display: inline-flex;
			width: 100%;
		}
		.fixed-header thead tr th {
			border-bottom:0;
		}
		.fixed-header thead tr th:first-child {
			width: 90%;
		}
		.fixed-header thead tr th:nth-child(2) {
			width: 20%;
			margin-right: 10px;
			text-align: right;
		}
		.fixed-header tbody tr {
			display: flex;
		}
		.fixed-header tbody tr td {
			padding: 3px 8px;
		}
		.fixed-header tbody tr td:first-child {
			width: 80%;
			padding: 0;
		}
		.fixed-header tbody tr td:nth-child(2) {
			width: 20%;
			margin-right: 10px;
			text-align: right;
		}
		.fixed-header tbody tr td span.glyphicon {
			cursor: pointer;
		}
		.fixed-header tbody {
			height: 100%;
			overflow-y: overlay;
			display: block;
			border: 1px solid rgb(221, 221, 221);
			border-left: 0;
			border-right: 0;
		}
		.fixed-header tbody tr td label {
			margin-bottom: 0;
			font-weight: normal;
			width: 100%;
			height: 100%;
		}
		.btn-primary {
			margin: 0;
		}
	</style>
</head>
<body>
<script type="application/javascript">
<%
	LoggedInInfo loggedInInfo = LoggedInInfo.getLoggedInInfoFromSession(request);
	if (request.getAttribute("refreshAndClose") != null && (Boolean) request.getAttribute("refreshAndClose")) {
	    String customGroupNo = (String) request.getAttribute("customGroupNo");
%>
	if (window.opener && (typeof window.opener.changeGroupExternal !== 'undefined')) {
		window.opener.changeGroupExternal('<%=customGroupNo%>');
	}
<%
	}
%>
	function moveUp(row) {
		row.insertBefore(row.prev());
	}
	function moveDown(row) {
		row.insertAfter(row.next());
	}
</script>
<%
	List<Provider> providerList = new ArrayList<Provider>();
	List<String> existingCustomGroup = new ArrayList<String>();
	String checkedString = "checked=\"checked\"";
	
	if (request.getAttribute("refreshAndClose") == null) {
		ProviderDao providerDao = SpringUtils.getBean(ProviderDao.class);
		MyGroupDao myGroupDao = SpringUtils.getBean(MyGroupDao.class);
		
		providerList = providerDao.getActiveProvidersWithSchedule();

		existingCustomGroup = myGroupDao.getGroupProviderNosOrderByViewOrder("tmp-" + loggedInInfo.getLoggedInProviderNo());
		if (existingCustomGroup == null) {
			existingCustomGroup = new ArrayList<String>();
		} else {
		    // move the already selected providers to the top and order them
			// Create and fill arraylist with the correct order
			List<Provider> groupProviders = new ArrayList<Provider>();
			while (groupProviders.size() < existingCustomGroup.size()) { groupProviders.add(null); }
			for (Provider p : providerList) {
				if (existingCustomGroup.contains(p.getProviderNo())) {
					groupProviders.set(existingCustomGroup.indexOf(p.getProviderNo()), p);
				}
			}
			groupProviders.removeAll(Collections.singleton(null));
			// remove providers from list and add them to start of list
			providerList.removeAll(groupProviders);
			providerList.addAll(0, groupProviders);
		}
	}
%>
<nav class="navbar navbar-inverse" role="navigation">
	<div class="navbar-header">
		<span class="navbar-brand">Create a temporary custom schedule</span>
	</div>
</nav>
<form class="container" action="<%=request.getContextPath()%>/provider/customSchedule.do" method="post">
	<div class="panel panel-default">
		<div class="panel-body">
			<div class="row">
				<div class="col-xs-12">
					<h3 style="margin-top: 0">Select providers to add to custom schedule</h3>
				</div>
			</div>
			<div class="row">
				<div class="col-xs-12">
					<table class="table fixed-header" style="height: 500px;">
						<thead>
						<tr>
							<th>Provider</th>
							<th><input type="checkbox" onclick="toggleCheckboxes(this);"/></th>
						</tr>
						</thead>
						<tbody>
						<%
							Boolean isChecked;
							for (Provider p : providerList) {
							    isChecked = existingCustomGroup.contains(p.getProviderNo());
						%>
						<tr>
							<td><label style="padding: 3px 8px;" for="<%=p.getProviderNo()%>_checked"><%=p.getFormattedName()%></label></td>
							<td>
								<span class="glyphicon glyphicon-chevron-up" onclick="moveUp($(this).parent().parent())"></span>
								<span class="glyphicon glyphicon-chevron-down" onclick="moveDown($(this).parent().parent())"></span>
								<input type="checkbox" name="provider_checked" id="<%=p.getProviderNo()%>_checked" value="<%=p.getProviderNo()%>" <%=isChecked?checkedString:""%>/>
							</td>
						</tr>
						<%
							}
						%>
						</tbody>
					</table>
				</div>
			</div>
			<div class="row">
				<div class="col-xs-12 text-center">
					<input class="btn btn-primary no-margin" type="submit" id="search" value="Save"/>
					<input class="btn btn-primary no-margin" type="button" value="Close" onclick="window.close();"/>
				</div>
			</div>
		</div>
	</div>
</form>
<script type="application/javascript">
	function toggleCheckboxes(source) {
		var checkboxes = document.getElementsByName('provider_checked');
		for(var i = 0, n = checkboxes.length; i < n; i++) {
			checkboxes[i].checked = source.checked;
		}
	}
</script>
</body>
</html>