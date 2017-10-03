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

<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean" %>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html" %>
<%@ taglib uri="/WEB-INF/struts-logic.tld" prefix="logic" %>
<%@ taglib uri="/WEB-INF/oscar-tag.tld" prefix="oscar" %>
<%@ page import="org.oscarehr.common.model.MessageFolder" %>
<%@ page import="java.util.List" %>
<%@ page import="org.oscarehr.common.dao.MessageFolderDao" %>
<%@ page import="org.oscarehr.util.SpringUtils" %>
<%@ page import="oscar.oscarMessenger.data.MsgDisplayMessage" %>
<%@ page import="org.oscarehr.util.LoggedInInfo" %>
<%@ page import="oscar.oscarMessenger.pageUtil.MsgSessionBean" %>
<%@ taglib uri="/WEB-INF/security.tld" prefix="security"%>
<%
	String roleName$ = (String)session.getAttribute("userrole") + "," + (String) session.getAttribute("user");
	boolean authed=true;
%>
<security:oscarSec roleName="<%=roleName$%>" objectName="_msg" rights="r" reverse="<%=true%>">
	<%authed=false; %>
	<%response.sendRedirect("../securityError.jsp?type=_msg");%>
</security:oscarSec>
<%
	if(!authed) {
		return;
	}
	String providerNo = LoggedInInfo.getLoggedInInfoFromSession(request).getLoggedInProviderNo();

%>

<logic:notPresent name="msgSessionBean" scope="session">
	<logic:redirect href="index.jsp" />
</logic:notPresent>
<logic:present name="msgSessionBean" scope="session">
	<bean:define id="bean" type="oscar.oscarMessenger.pageUtil.MsgSessionBean" name="msgSessionBean" scope="session" />
	<logic:equal name="bean" property="valid" value="false">
		<logic:redirect href="index.jsp" />
	</logic:equal>
</logic:present>
<%
	MsgSessionBean bean = (oscar.oscarMessenger.pageUtil.MsgSessionBean)pageContext.findAttribute("bean");
	
	List<MsgDisplayMessage> messagesResults = bean.getSearchResults();
	String searchedProviderName = bean.getSearchProviderName();
	String searchedStartDateString = bean.getSearchStartDateString();
	String searchedEndDateString = bean.getSearchEndDateString();
	Integer pageNum = bean.getSearchPageNum();
	Integer totalResults = bean.getSearchTotalResults();
	if (bean.getSearchOrderBy() != null){
		String orderby = bean.getSearchOrderBy();
		String sessionOrderby = (String) session.getAttribute("orderby");
		if (sessionOrderby != null && sessionOrderby.equals(orderby)){
			orderby = "!"+orderby;
		}
		session.setAttribute("orderby",orderby);
		bean.setSearchOrderBy(orderby);
	}
	String searchUrl = request.getContextPath() + "/oscarMessenger/SearchProvider.do";
%>
<jsp:useBean id="DisplayMessagesBeanId" scope="session" class="oscar.oscarMessenger.pageUtil.MsgDisplayMessagesBean" />
<% DisplayMessagesBeanId.setProviderNo(bean.getProviderNo());
	bean.nullAttachment();

	MessageFolderDao messageFolderDao = SpringUtils.getBean(MessageFolderDao.class);
	List<MessageFolder> messageFolders = messageFolderDao.findAllFoldersByProvider(bean.getProviderNo());
%>
<jsp:setProperty name="DisplayMessagesBeanId" property="*" />
<jsp:useBean id="ViewMessageForm" scope="session" class="oscar.oscarMessenger.pageUtil.MsgViewMessageForm"/>


<html:html locale="true">
	<head>
		<html:base />
		<link rel="stylesheet" type="text/css" href="encounterStyles.css">
		<title>
			<bean:message key="oscarMessenger.DisplayMessages.title"/>
		</title>
		<style type="text/css">

			tr.newMessage {

			}

			tr.newMessage td {
				font-weight: bold;
			}

			.TopStatusBar{
				width:100% !important;
			}

			.MainTableLeftColumn{
				vertical-align: top;
			}

			.folderList {
				list-style-type: none;
				list-style-position:inside;
				margin:0;
				padding:5px;
			}

			.folderList a {
				color: #000;
				text-decoration: none;
			}
		</style>

		<script type="text/javascript">

			function uload(){
				if (opener.callRefreshTabAlerts) {
					opener.callRefreshTabAlerts("oscar_new_msg");
					setTimeout("window.close()", 100);
					return false;
				}
				return true;
			}

		</script>
	</head>

	<body class="BodyStyle" vlink="#0000FF" onload="window.focus()" onunload="return uload()">
	<table  class="MainTable" id="scrollNumber1" name="encounterTable">
		<tr class="MainTableTopRow">
			<td class="MainTableTopRowLeftColumn">
				<bean:message key="oscarMessenger.DisplayMessages.msgMessenger"/>
			</td>
			<td class="MainTableTopRowRightColumn">
				<table class="TopStatusBar">
					<tr>
						<td style="text-align: center; margin: 0; padding: 8px 0; width: 474px; font-size: 12px">
							<span><%=request.getAttribute("resultsMessage")%></span>
						</td>
						<td style="text-align:right">
							<a href="<%=request.getContextPath()%>/oscarMessenger/SearchProvider.jsp">Search Provider's Messages</a>&nbsp;|
							<a href="<%=request.getContextPath()%>/oscarMessenger/Settings.jsp">Settings</a>&nbsp;|
							<oscar:help keywords="&Title=Messenger&portal_type%3Alist=Document" key="app.top1"/>&nbsp;|
							<a href="<%=request.getContextPath()%>/oscarEncounter/About.jsp" target="_new"><bean:message key="global.about" /></a>
						</td>
					</tr>
				</table>
			</td>
		</tr>
		<tr>
			<td class="MainTableLeftColumn">
				<ul class="folderList main">
					<li value="0"><a href="<%=request.getContextPath()%>/oscarMessenger/DisplayMessages.jsp">My Inbox</a></li>
					<li value="1"><a href="<%=request.getContextPath()%>/oscarMessenger/DisplayMessages.jsp?boxType=1">Sent</a></li>
					<li value="2"><a href="<%=request.getContextPath()%>/oscarMessenger/DisplayMessages.jsp?boxType=2">Deleted</a></li>
				</ul>
				<ul class="folderList">
					<% for (MessageFolder folder : messageFolders){%>
					<li value="<%=folder.getId()%>"><a href="<%=request.getContextPath()%>/oscarMessenger/DisplayMessages.jsp?folder=<%=folder.getId()%>"><%=folder.getName()%></a></li>
					<%}%>
				</ul>
			</td>
			<td class="MainTableRightColumn" style="padding: 10px;">
				<%String strutsAction = "/oscarMessenger/DisplayMessages";%>
				<html:form action="<%=strutsAction%>" styleId="msgList" >
				<div style="width: 90%;">
				<%
					int recordsToDisplay = 25;
					int totalPages = totalResults / recordsToDisplay + (totalResults % recordsToDisplay == 0 ? 0 : 1);
					String previousPage = "";
					String nextPage = "";
					String pageUrl;
					if (pageNum > 1) {
						pageUrl = searchUrl.replaceAll("(\\?pageNum=)(\\d)+", "") + "?pageNum=" + (pageNum-1);
						previousPage = "<div style=\"width: 43%; display: inline-block\"><a href='" + pageUrl + "' title='previous page'>&lt&lt Previous</a></div> ";
						out.print(previousPage);
					}

					if (pageNum < totalPages) {
						pageUrl = searchUrl.replaceAll("(\\?pageNum=)(\\d)+", "") + "?pageNum=" + (pageNum+1);
						nextPage = "<div style=\"width: 43%; display: inline-block; float: right; text-align: right;\"><a href='" + pageUrl + "' title='next page'>Next &gt&gt</a></div> ";
						out.print(nextPage);
					}
				%>
				</div>
				<table border="0" width="90%" cellspacing="1">
					<tr>
						<th align="left" bgcolor="#DDDDFF">
							<a href="<%=searchUrl%>?orderby=status">
								<bean:message key="oscarMessenger.DisplayMessages.msgStatus"/>
							</a>
						</th>
						<th align="left" bgcolor="#DDDDFF">
							<a href="<%=searchUrl%>?orderby=from">
								<bean:message key="oscarMessenger.DisplayMessages.msgFrom"/>
							</a>
						</th>
						<th align="left" bgcolor="#DDDDFF">
							<a href="<%=searchUrl%>?orderby=sentto">
								Sent To
							</a>
						</th>
						<th align="left" bgcolor="#DDDDFF">
							<a href="<%=searchUrl%>?orderby=subject">
								<bean:message key="oscarMessenger.DisplayMessages.msgSubject"/>
							</a>
						</th>
						<th align="left" bgcolor="#DDDDFF">
							<a href="<%=searchUrl%>?orderby=date">
								<bean:message key="oscarMessenger.DisplayMessages.msgDate"/>
							</a>
						</th>
						<th align="left" bgcolor="#DDDDFF">
							<a href="<%=searchUrl%>?orderby=linked">
								<bean:message key="oscarMessenger.DisplayMessages.msgLinked"/>
							</a>
						</th>
					</tr>
					<%
						for (MsgDisplayMessage messagesResult : messagesResults) {
							String key = "oscarMessenger.DisplayMessages.msgStatus" + messagesResult.status.substring(0, 1).toUpperCase() + messagesResult.status.substring(1);
						if ("oscarMessenger.DisplayMessages.msgStatusNew".equals(key) || "oscarMessenger.DisplayMessages.msgStatusUnread".equals(key)) {%>
							<tr class="newMessage">
					<% } else { %>
							<tr>
					<% } %>
						<td bgcolor="#EEEEFF">
							<bean:message key="<%= key %>"/>
						</td>
						<td bgcolor="#EEEEFF">
							<%=messagesResult.sentby%>
						</td>
						<td bgcolor="#EEEEFF">
							<%=messagesResult.sentto%>
						</td>
						<td bgcolor="#EEEEFF">
							<a href="<%=request.getContextPath()%>/oscarMessenger/ViewMessage.do?messageID=<%=messagesResult.messageId%>&boxType=pageType&replyFor=<%=messagesResult.getSentToProviderNo()%>&fromProviderSearch=true">
								<%=messagesResult.thesubject%>
							</a>
						</td>
						<td bgcolor="#EEEEFF">
							<%= messagesResult.thedate %>
							&nbsp;&nbsp;
							<%= messagesResult.theime %>
						</td>
						<td bgcolor="#EEEEFF">
							<%if (messagesResult.demographic_no != null && !messagesResult.demographic_no.equalsIgnoreCase("null")) {%>
							<oscar:nameage demographicNo="<%=messagesResult.demographic_no%>"></oscar:nameage>
							<%} %>
						</td>
					</tr>
					<%}%>
				</table>

				<div style="width: 90%;">
				<%=previousPage + nextPage%>
				</div>
				</html:form>

			</td>
		</tr>
		<tr>
			<td class="MainTableBottomRowLeftColumn">

			</td>
			<td class="MainTableBottomRowRightColumn">

			</td>
		</tr>
	</table>
	</body>
</html:html>