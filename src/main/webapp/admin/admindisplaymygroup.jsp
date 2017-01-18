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

<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean"%>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html"%>
<%@ taglib uri="/WEB-INF/security.tld" prefix="security"%>

<%@ page import="java.util.*" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="org.oscarehr.util.SpringUtils" %>
<%@ page import="org.oscarehr.common.model.MyGroup" %>
<%@ page import="org.oscarehr.common.model.MyGroupPrimaryKey" %>
<%@ page import="org.oscarehr.common.dao.MyGroupDao" %>

<%
	MyGroupDao myGroupDao = SpringUtils.getBean(MyGroupDao.class);

    String curProvider_no = (String) session.getAttribute("user");
    String roleName$ = (String)session.getAttribute("userrole") + "," + (String) session.getAttribute("user");
    
    boolean isSiteAccessPrivacy=false;
%>

<security:oscarSec objectName="_site_access_privacy" roleName="<%=roleName$%>" rights="r" reverse="false">
	<%isSiteAccessPrivacy=true; %>
</security:oscarSec>

<%@ page import="java.util.*,java.sql.*" errorPage="../provider/errorpage.jsp"%>

<!DOCTYPE html>
<html:html locale="true">
<head>

<title><bean:message key="admin.admindisplaymygroup.title" /></title>
<script type="text/javascript" src="<%=request.getContextPath() %>/js/jquery-1.9.1.min.js"></script>
<script type="text/javascript" src="<%=request.getContextPath() %>/js/bootstrap.min.js"></script>
<script>
function removeProvider(hideId){
	var $providerRow = $("#"+hideId).parent().parent();
	var providerRemove = $providerRow.find("[name='removeBtn']")[0];
	
	if(providerRemove.value == "true"){
		providerRemove.value = "false";
		$("#"+hideId).removeClass("icon-ok");
		$("#"+hideId).addClass("icon-remove");
		
		$providerRow.removeClass("remove");
	}else{
		providerRemove.value = "true";
		$("#"+hideId).removeClass("icon-remove");
		$("#"+hideId).addClass("icon-ok");
		
		$providerRow.addClass("remove");
	}
}

function moveUp(upId){
	var $providerRow = $("#"+upId).parent().parent();
	 $providerRow.insertBefore($providerRow.prev());
}

function moveDown(downId){
	var $providerRow = $("#"+downId).parent().parent();
	if($providerRow.next().hasClass('provider')){
		$providerRow.insertAfter($providerRow.next());
	}
}
</script>

<link href="<%=request.getContextPath() %>/css/bootstrap.min.css" rel="stylesheet" />
<link href="<%=request.getContextPath() %>/css/panel.css" rel="stylesheet" />
<link href="<%=request.getContextPath() %>/css/list-group.css" rel="stylesheet" />
<style>
ul{
	margin:0px;
}
.controls{
	float: right;
	cursor: pointer;
}
.remove{
	background-color: #999999;
}
</style>
</head>


<body>
<h3><bean:message key="admin.admin.btnSearchGroupNoRecords" /></h3>	
<%

String oldNumber="";
boolean firstGroup=true;

List<MyGroup> groupList = myGroupDao.findAll();
Collections.sort(groupList, MyGroup.MyGroupNoComparator);

if(isSiteAccessPrivacy) {
	groupList = myGroupDao.getProviderGroups(curProvider_no);
}

int i=0;
int j=0;
for(MyGroup myGroup : groupList) {

	if(!myGroup.getId().getMyGroupNo().equals(oldNumber)) {
		i++;
		if(!firstGroup){%>
				<li class="list-group-item">
				<a href="adminnewgroup.jsp?groupNo=<%=URLEncoder.encode(oldNumber, "UTF-8")%>" class="btn"><bean:message key="admin.admindisplaymygroup.btnSubmit2"/></a>
			</li>
				</ul>
			  <div class="panel-footer"> 
				<INPUT TYPE="submit" name="submit" class="btn btn-primary" VALUE="<bean:message key="admin.admindisplaymygroup.btnSubmit1"/>" SIZE="7">
			  </div>
			</div>
		  </div>
		</div>
	</FORM>
		<%} %>
	<FORM NAME="UPDATEPRE" METHOD="post" ACTION="adminnewgroup.jsp?groupNo=<%=URLEncoder.encode(myGroup.getId().getMyGroupNo(), "UTF-8")%>">
		<div class="panel-group">
		  <div class="panel panel-default">
			<div class="panel-heading">
			  <h4 class="panel-title">
				<a data-toggle="collapse" href="#collapse<%=i%>"><%=myGroup.getId().getMyGroupNo()%></a>
			  </h4>
			</div>
			<div id="collapse<%=i%>" class="panel-collapse collapse">
			  <ul class="list-group">
<%		oldNumber = myGroup.getId().getMyGroupNo();
		firstGroup = false;
	}
	j++;
%>
			<li class="list-group-item provider">
				<%=myGroup.getLastName()+","+ myGroup.getFirstName()%>
				<input name="removeBtn" type="hidden" />
				<input name="providerNo" type="hidden" value="<%=myGroup.getId().getProviderNo()%>" />
				<span class="controls">
					<i id="up<%=j%>" class="icon-chevron-up" onclick="moveUp(this.id)"></i>
					<i id="down<%=j%>" class="icon-chevron-down" onclick="moveDown(this.id)"></i>
					<i id="remove<%=j%>" class="icon-remove" onclick="removeProvider(this.id)"></i>
				</span>
			</li>
<%
   }
%>
			<li class="list-group-item">
				<a href="adminnewgroup.jsp?groupNo=<%=URLEncoder.encode(oldNumber, "UTF-8")%>" class="btn">
					<bean:message key="admin.admindisplaymygroup.btnSubmit2"/>
				</a>
			</li>
				</ul>
			  <div class="panel-footer"> 
				<INPUT TYPE="submit" name="submit" class="btn btn-primary" VALUE="<bean:message key="admin.admindisplaymygroup.btnSubmit1"/>">
			  </div>
			</div>
		  </div>
		</div>
	</FORM>

<script>

$( document ).ready(function() {
parent.parent.resizeIframe(1000);

});

</script>
</body>
</html:html>
