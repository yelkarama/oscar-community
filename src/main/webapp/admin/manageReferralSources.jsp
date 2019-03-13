<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
"http://www.w3.org/TR/html4/loose.dtd">
<%-- This JSP is the first page you see when you enter 'report by template' --%>
<%@ taglib uri="/WEB-INF/security.tld" prefix="security"%>
<%
	String roleName$ = (String)session.getAttribute("userrole") + "," + (String) session.getAttribute("user");
	boolean authed=true;
%>
<security:oscarSec roleName="<%=roleName$%>" objectName="_admin" rights="r" reverse="<%=true%>">
	<%authed=false; %>
	<%response.sendRedirect("../securityError.jsp?type=_admin");%>
</security:oscarSec>
<%
	if(!authed) {
		return;
	}
%>


<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean"%>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html"%>
<%@ taglib uri="/WEB-INF/struts-logic.tld" prefix="logic"%>
<%@ page import="org.oscarehr.util.SpringUtils" %>
<%@ page import="org.oscarehr.util.LoggedInInfo" %>
<%@ page import="org.oscarehr.common.model.Provider" %>
<%@ page import="org.oscarehr.common.dao.SystemPreferencesDao" %>
<%@ page import="org.oscarehr.common.model.SystemPreferences" %>
<%@ page import="org.oscarehr.common.dao.ReferralSourceDao" %>
<%@ page import="org.oscarehr.common.model.ReferralSource" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Date" %>

<jsp:useBean id="dataBean" class="java.util.Properties" scope="page" />
<%
	LoggedInInfo loggedInInfo=LoggedInInfo.getLoggedInInfoFromSession(request);
	Provider provider = loggedInInfo.getLoggedInProvider();

	SystemPreferencesDao systemPreferencesDao = SpringUtils.getBean(SystemPreferencesDao.class);
	ReferralSourceDao referralSourceDao = SpringUtils.getBean (ReferralSourceDao.class);

	if ((request.getParameter("dboperation") != null)&&(!request.getParameter("dboperation").isEmpty())&&(request.getParameter("dboperation").equals("Save"))) {
		List<ReferralSource> refSourceList = referralSourceDao.getReferralSourceList();

		//Update Referral Sources
		for (int i = 0; i < refSourceList.size(); i++) {
			if (refSourceList.get(i).getReferralSource()!=request.getParameter("refSource" + i)) {
				if (request.getParameter("refSourceHidden" + i).equals("Delete")) {
					refSourceList.get(i).setArchiveStatus(true);
				}
				refSourceList.get(i).setReferralSource(request.getParameter("refSource" + i));
				refSourceList.get(i).setLastUpdateUser(Integer.parseInt(provider.getProviderNo()));
				refSourceList.get(i).setLastUpdateDate(new Date());
				referralSourceDao.merge(refSourceList.get(i));
			}
		}

		//New Referral Source
		if ((request.getParameter("newRefferal") != null)&&(request.getParameter("newRefferal") != "")) {
			ReferralSource referralSource = new ReferralSource();
			referralSource.setReferralSource(request.getParameter("newRefferal"));
			referralSource.setLastUpdateUser(Integer.parseInt(provider.getProviderNo()));
			referralSource.setLastUpdateDate(new Date());
			referralSource.setArchiveStatus(false);
			referralSourceDao.persist(referralSource);
		}

		//Update Perferences
		for(String key : SystemPreferences.REFERRAL_SOURCE_PREFERENCE_KEYS) {
			SystemPreferences preference = systemPreferencesDao.findPreferenceByName(key);
			String newValue = request.getParameter("enableRef");

			if (preference != null) {
				if (!preference.getValue().equals(newValue)) {
					preference.setUpdateDate(new Date());
					preference.setValue(newValue);
					systemPreferencesDao.merge(preference);
				}
			} else {
				preference = new SystemPreferences();
				preference.setName(key);
				preference.setUpdateDate(new Date());
				preference.setValue(newValue);
				systemPreferencesDao.persist(preference);
			}
		}

	}

%>
<html:html locale="true">
	<head>
		<title>Manage Referrels</title>
		<link href="<%=request.getContextPath() %>/css/bootstrap.css" rel="stylesheet" type="text/css">
		<script type="text/javascript" src="<%= request.getContextPath() %>/js/global.js"></script>
		<script type="text/javascript" src="<%=request.getContextPath() %>/js/jquery-1.7.1.min.js"></script>
		<script type="text/javascript" src="<%=request.getContextPath() %>/js/bootstrap.js"></script>
		<script type="text/javascript" language="JavaScript" src="<%= request.getContextPath() %>/share/javascript/Oscar.js"></script>
	    <script language="JavaScript">
			function hideReferralList (isHidden) {
				if (isHidden==="true") {
					document.getElementById("refSourceList").style.display = "";
				} else {
					document.getElementById("refSourceList").style.display = "none";
				}
				document.getElementById("turnOnReferrals").value = isHidden;
			}

			function deleteReferralSource (id) {
				if (confirm("Are you sure?")) {
				document.getElementById("refSourceHidden" + id).value = "Delete";
				document.getElementById("refSourceRow" + id).style.display = "none";
				}
			}

			function moveReferralSource (id, direction) {
				var first = document.getElementById("refSource" + id);
				var second;
				var temp;
				var exit = true;
				var increment = 0;
				if (direction=="up") {
					increment = -1;
					exit = false;
				} else if (direction=="down") {
					increment = 1;
					exit = false;
				}

				//Skip Values set to be Deleted
				while (!exit) {
					if (document.getElementById("refSourceHidden" + (id + increment)).value=="Delete") {
						if (increment > 0) {
							increment++;
						} else {
							increment--;
						}
					} else {
						second = document.getElementById("refSource" + (id + increment));
						exit = true;
					}
				}

				temp = first.value;
				first.value = second.value;
				second.value = temp;
			}
        </script>
    </head>

	<%
		List<ReferralSource> referralSourceList = referralSourceDao.getReferralSourceList();
		boolean enableRefSources = false;

		List<SystemPreferences> preferences = systemPreferencesDao.findPreferencesByNames(SystemPreferences.REFERRAL_SOURCE_PREFERENCE_KEYS);
		for(SystemPreferences preference : preferences) {
			if (preference.getValue() != null) {
				if (preference.getName().equals("enable_referral_source")) {
					enableRefSources = Boolean.parseBoolean(preference.getValue());
				}
			}
		}
	%>

	<body vlink="#0000FF" class="BodyStyle">
	<h4>Referral Source Settings</h4>
	<form name="refSource-settings" method="post" action="manageReferralSources.jsp">
		<input type="hidden" name="dboperation" value="">
		<table id="refSourceSettings" name="refSourceSettings" class="table table-bordered table-striped table-hover table-condensed">
			<tbody>
			<tr>
				<td>Enable Referral Sources </td>
				<td>
					<input type="radio" value="true" name="enableRef" onchange="hideReferralList(this.value);" <%=enableRefSources ? "checked=\"checked\"" : ""%>/> Yes
					&nbsp;&nbsp;&nbsp;
					<input type="radio" value="false" name="enableRef" onchange="hideReferralList(this.value);" <%=enableRefSources ? "": "checked=\"checked\""%>/> No
					&nbsp;&nbsp;&nbsp;
				</td>
			</tr>
			</tbody>
		</table>
		<input type="hidden" id="turnOnReferrals" name="turnOnReferrals" value="true">
		<table id="refSourceList" name="refSourceList" <%=enableRefSources ? "" : "style=\"display: none;\""%>>
			<tbody name="showReferrals" id="showReferrals">
			<tr>
				<td>Referral Types</td>
			</tr>
			<%
				for (int i = 0; i < referralSourceList.size(); i++) {
			%>
			<tr id="<%="refSourceRow" + i%>" name="<%="refSourceRow" + i%>" <%=referralSourceList.get(i).getArchiveStatus() ? "style=\"display: none;\"" : ""%>>
				<td>
					<input type="text" id="<%="refSource" + i%>" name="<%="refSource" + i%>" value="<%=referralSourceList.get(i).getReferralSource()%>" maxlength="200">
					<input type="hidden" id="<%="refSourceHidden" + i%>" name="<%="refSourceHidden" + i%>" value="Save">
				</td>
				<td>
				<%
					if (i > 0) {
				%>
					<input type="button" onclick=moveReferralSource(<%=i%>,"up"); value="^">
					<% 	} else { %>
					<input type="button" value="^">
					<% } %>
				</td>
				<td>
				<%
					if (i < referralSourceList.size()-1) {
				%>
				<input type="button" onclick=moveReferralSource(<%=i%>,"down"); value="v">
				<% 	} else { %>
				<input type="button" value="v">
				<% } %>
				</td>
				<td>
					<input type="button" onclick=deleteReferralSource(<%=i%>); value="Delete">
				</td>
			</tr>
			<%	}%>
				<tr><td><b>Add New Refferal Source: </b><input type="text" id="newRefferal" name="newRefferal" maxlength="200"></td></tr>
			</tbody>
		</table>
		<input type="button" onclick="document.forms['refSource-settings'].dboperation.value='Save'; document.forms['refSource-settings'].submit();" name="newRefferalButton" value="Save"/>
	</form>
	</body>
</html:html>
