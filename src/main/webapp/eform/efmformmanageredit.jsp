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
<%@ page import="oscar.eform.data.*, oscar.eform.*, java.util.*, oscar.util.*, org.apache.commons.lang.StringEscapeUtils"%>
<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean"%>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html"%>
<%@ taglib prefix="csrf" uri="http://www.owasp.org/index.php/Category:OWASP_CSRFGuard_Project/Owasp.CsrfGuard.tld" %>
<%
HashMap<String, Object> curform = new HashMap<String, Object>();
HashMap<String, String> errors = new HashMap<String, String>();

if (request.getAttribute("submitted") != null) {
    curform = (HashMap<String, Object>) request.getAttribute("submitted");
    errors = (HashMap<String, String>) request.getAttribute("errors");
} else if (request.getParameter("fid") != null ) {
    String curfid = request.getParameter("fid");
    curform = EFormUtil.loadEForm(curfid);
}

   //remove "null" values
   if (curform.get("fid") == null) curform.put("fid", "");
   if (curform.get("formName") == null) curform.put("formName", "");
   if (curform.get("formSubject") == null) curform.put("formSubject", "");
   if (curform.get("formFileName") == null) curform.put("formFileName", "");
   if (curform.get("roleType") == null) curform.put("roleType", "");
   
   boolean popupDisplay = false;
   if (request.getParameter("formHtmlG") != null){
       //load html from hidden form from eformGenerator.jsp,the html is then injected into edit-eform
      curform.put("formHtml", StringEscapeUtils.unescapeHtml(request.getParameter("formHtmlG")));
      curform.put("formName", request.getParameter("formHtmlName") != null ? request.getParameter("formHtmlName") : "");
      popupDisplay = true;
   }
   if (curform.get("formDate") == null) curform.put("formDate", "--");
   if (curform.get("formTime") == null) curform.put("formTime", "--");
   
   if (curform.get("showLatestFormOnly") ==null) curform.put("showLatestFormOnly", false);
   if (curform.get("patientIndependent") ==null) curform.put("patientIndependent", false);
   
   String formHtml = StringEscapeUtils.escapeHtml((String) curform.get("formHtml"));
	if(formHtml==null){formHtml="";}	
%>
<!DOCTYPE html>
<html:html locale="true">
<head>
<script type="text/javascript" src="<%= request.getContextPath() %>/js/global.js"></script>
	<% if (popupDisplay) { %>
		<link href="/oscar/css/bootstrap.min.css" rel="stylesheet" type="text/css">
		<link rel="stylesheet" type="text/css" href="/oscar/js/jquery_css/smoothness/jquery-ui-1.10.2.custom.min.css"/>
		<script type="text/javascript" src="/oscar/js/jquery-1.9.1.js"></script>
		<script type="text/javascript" src="/oscar/js/jquery-ui-1.10.2.custom.min.js"></script>
	<% } %>
<title><bean:message key="eform.edithtml.msgEditEform" /></title>

<style>
.input-error{   
    border-color: rgba(229, 103, 23, 0.8) !important; 
    box-shadow: 0 1px 1px rgba(229, 103, 23, 0.075) inset, 0 0 8px rgba(229, 103, 23, 0.6) !important; 
    outline: 0 none !important;  
}

#popupDisplay{display:none;}
#panelDisplay{display:inline-block;}
</style>

<script type="text/javascript" language="JavaScript">
function openLastSaved() {
	let formId = document.getElementById('fid').value;
	window.open('<%=request.getContextPath()%>/eform/efmshowform_data.jsp?fid=' + formId, 'PreviewForm', 'toolbar=no, location=no, status=yes, menubar=no, scrollbars=yes, resizable=yes, width=700, height=600, left=300, top=100');   
}
</script>

</head>

<body id="eformBody">

<%@ include file="efmTopNav.jspf"%>
<h3 id="editHtmlHeader"></h3>
<form action="<%=request.getContextPath()%>/eform/editForm.do" method="POST" enctype="multipart/form-data" id="editform" name="eFormEdit" onsubmit="return saveEform();">
<div class="well" style="position: relative;">
	
<div id="alert-success" class="alert alert-success" style="display: none">
<button type="button" class="close" data-dismiss="alert">&times;</button>
<bean:message key="eform.edithtml.msgChangesSaved" />.
</div>
	
	<div id="alert-error" class="alert alert-error" style="display: none">
    <button type="button" class="close" data-dismiss="alert">&times;</button>
		<span id="error"></span>
    </div>

		<input type="hidden" name="fid" id="fid" value="<%= curform.get("fid")%>">
		<input type="hidden" name="formFileName" id="formFileName" value="<%= curform.get("formFileName")%>">
		<input type="hidden" name="formDate" id="formDate" value="<%= curform.get("formDate")%>">
		<input type="hidden" name="formTime" id="formTime" value="<%= curform.get("formTime")%>">
       
		<% if ((request.getAttribute("success") == null) || (errors.size() != 0)) {%>
			<!--error? -->
		<% } %>
		
			<!--LAST SAVED-->
			<div style="position:absolute;top:2px;right:4px;">			
			<em><bean:message key="eform.edithtml.msgLastModified" />:<span id="lastSavedDate"></span></em>
			</div>

			<!--FORM NAME-->
			<div style="display:inline-block">
			 
			<bean:message key="eform.uploadhtml.formName" />:
			<br />
			<input type="text" name="formName" id="formName" value="<%= curform.get("formName") %>" class="" size="30" /> 
			<br />
			
			</div>
			
			<!--FORM ADDITIONAL INFO-->
			<div style="display:inline-block">
			<bean:message key="eform.uploadhtml.formSubject" />:<br />
						<input type="text" id="formSubject" name="formSubject" value="<%= curform.get("formSubject") %>" size="30" /><br />
			</div>

			<!--ROLE TYPE-->
			<div style="display:inline-block">			
			<bean:message key="eform.uploadhtml.btnRoleType"/><br />
			<select name="roleType">
			<option value="">- select one -</option>
			<%  ArrayList roleList = EFormUtil.listSecRole(); 
			String selected = "";
			for (int i=0; i<roleList.size(); i++) {  
				selected = "";
				if(roleList.get(i).equals(curform.get("roleType"))) {
					selected = "selected";
				}
			%>  			
			<option value="<%=roleList.get(i) %>" <%= selected%> %><%=roleList.get(i) %></option>
	
			<%} %>
			</select><br />
			</div>

			<!--PATIENT INDEPENDANT-->
			<div style="display:inline-block">
			<bean:message key="eform.uploadhtml.showLatestFormOnly" />	<input type="checkbox" name="showLatestFormOnly" value="true" <%= (Boolean)curform.get("showLatestFormOnly")?"checked":"" %> />
				<br/>
			<bean:message key="eform.uploadhtml.patientIndependent" /> <input type="checkbox" name="patientIndependent" value="true" <%= (Boolean)curform.get("patientIndependent")?"checked":"" %> /><br />
			</div>

			<br />			
			<bean:message key="eform.edithtml.msgEditHtml" />:<br />
			<textarea wrap="off" name="formHtml" style="" class="span12" rows="40"><%= formHtml%></textarea><br />

<p>
    <input type="hidden" name="<csrf:tokenname/>" value="<csrf:tokenvalue/>"/>
	<input type="hidden" id="dynamicContent" name="dynamicContent" value="true"/>
	<div id="panelDisplay">
	<a href="<%=request.getContextPath()%>/eform/efmformmanager.jsp" class="btn contentLink">
	 <i class="icon-circle-arrow-left"></i> Back to eForm Library<!--<bean:message key="eform.edithtml.msgBackToForms"/>-->
	</a>
	<input type="button" class="btn" value="<bean:message key="eform.edithtml.msgPreviewLast"/>" id="previewLast" onclick="openLastSaved()">
	<a id="restoreLastSavedLink" href="" class="btn contentLink"> <bean:message key="eform.edithtml.cancelChanges"/></a>
	</div>

	<a href="#" class="btn" id="popupDisplay" onClick="window.close()"> 
	 <i class="icon-circle-arrow-left"></i> Back to eForm Library<!--<bean:message key="eform.edithtml.msgBackToForms"/>-->
	</a>

	<input type="submit" class="btn btn-primary" value="<bean:message key="eform.edithtml.msgSave"/>" data-loading-text="Saving..." name="savebtn" id="savebtn"  > 

</p>	
</div>
</form>


<%@ include file="efmFooter.jspf"%>

<script>
	function saveEform(){
	    let editForm = $('#editform');
		$('#alert-success').hide();
		formNameError('');
		// get csrf token and place it in the header for a ajax request
		let headerToken = null;
		editForm.serializeArray().forEach(function(field) {
			if (field.name === '<csrf:tokenname/>' && headerToken === null) {
				headerToken = field.value ;
			}
		}); 
		// post data
		$.ajax({
            beforeSend: function(request) {
                request.setRequestHeader('<csrf:tokenname/>', headerToken);
            },
			url: editForm.attr('action'),
			type: editForm.attr('method'),
			data: editForm.serialize(),
			success: function (data) {
				// insert returned html
				data = JSON.parse(data);
				if (data && data.success) {
					$('#alert-success').show();
					updatePageVariables(data.formId, data.formName, data.formFileName, data.formDate, data.formTime, data.formSubject);
				} else {
					formNameError(data.errors.formNameExists ? data.errors.formNameExists : data.errors.formNameMissing);
				}
				scrollToTop();
			}
		});
		
		// stop browser from doing default submit process
		return false; 
	}
	
	function formNameError(errorMsg) {
		$('#error').text(errorMsg);
		if (errorMsg && errorMsg.length > 0) {
			$('#alert-error').show();
			$('#formName').addClass('input-error');
		} else {
			$('#alert-error').hide();
			$('#formName').removeClass('input-error')
		}
	}
	
	function scrollToTop() {
		document.body.scrollTop = 0; // Safari
		document.documentElement.scrollTop = 0; // Chrome, Firefox, IE and Opera
	}
	
	function updatePageVariables(fid, formName, formFileName, formDate, formTime, formSubject) {
		document.getElementById('fid').value = fid;
		document.getElementById('formName').value = formName;
		document.getElementById('formFileName').value = formFileName;
		document.getElementById('formDate').value = formDate;
		document.getElementById('formTime').value = formTime;
		document.getElementById('formSubject').value = formSubject;
		document.getElementById('lastSavedDate').innerHTML = formDate + ' ' + formTime;
		document.getElementById('restoreLastSavedLink').href = '<%=request.getContextPath()%>/eform/efmformmanageredit.jsp?fid=' + fid;
		
		if (fid !== '') {
			document.getElementById("previewLast").disabled = false;
			document.getElementById("restoreLastSavedLink").style.visibility = 'visible';
			document.getElementById('editHtmlHeader').innerHTML = '<bean:message key="eform.edithtml.msgEditEform" />';
		} else {
			document.getElementById("previewLast").disabled = true;
			document.getElementById("restoreLastSavedLink").style.visibility = 'hidden';
			document.getElementById('editHtmlHeader').innerHTML = 'Create New eForm';
		}
	}
	
$(document).ready(function () {

	//using this to check if page is being viewing in admin panel or in popup
    <% if (popupDisplay) { %>
    document.getElementById("popupDisplay").style.display = 'inline-block';
    document.getElementById("panelDisplay").style.display = 'none';
    document.getElementById("dynamicContent").value = 'true'; // changed
    document.getElementById("topNavBar").style.display = 'none';
    <%  if ((request.getAttribute("success") != null) && (errors.size() == 0)) { %>
    window.opener.location.href = '<%=request.getContextPath()%>/administration/?show=Forms';
    <%  }
	} %>
    
	updatePageVariables('<%=curform.get("fid")%>', '<%=curform.get("formName")%>', '<%=curform.get("formFileName")%>', '<%=curform.get("formDate")%>', '<%=curform.get("formTime")%>', '<%=curform.get("formSubject")%>');
	$("html, body").animate({ scrollTop: 0 }, "slow");
	return false;
});
</script>


</body>
</html:html>

