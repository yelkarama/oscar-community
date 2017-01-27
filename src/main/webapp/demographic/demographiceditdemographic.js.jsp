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
<%@page import="oscar.OscarProperties" contentType="application/javascript"%>
function rs(n,u,w,h,x) {
  args="width="+w+",height="+h+",resizable=yes,scrollbars=yes,status=0,top=360,left=30";
  remote=window.open(u,n,args);
  if (remote != null) {
    if (remote.opener == null)
      remote.opener = self;
  }
  if (x == 1) { return remote; }
}

var awnd=null;
function ScriptAttach() {
  awnd=rs('swipe','zdemographicswipe.htm',600,600,1);
  awnd.focus();
}

function setfocus() {
  this.focus();
  document.titlesearch.keyword.focus();
  document.titlesearch.keyword.select();
}
function upCaseCtrl(ctrl) {
	ctrl.value = ctrl.value.toUpperCase();
}
function popupPage(vheight,vwidth,varpage) { //open a new popup window
  var page = "" + varpage;
  windowprops = "height="+vheight+",width="+vwidth+",location=no,scrollbars=yes,menubars=no,toolbars=no,resizable=yes,screenX=50,screenY=50,top=20,left=20";
  var popup=window.open(page, "demodetail", windowprops);
  if (popup != null) {
    if (popup.opener == null) {
      popup.opener = self;
    }
    popup.focus();
  }
}


function popupEChart(vheight,vwidth,varpage) { //open a new popup window
  var page = "" + varpage;
  windowprops = "height="+vheight+",width="+vwidth+",location=no,scrollbars=yes,menubars=no,toolbars=no,resizable=yes,screenX=50,screenY=50,top=20,left=20";
  var popup=window.open(page, "encounter", windowprops);
  if (popup != null) {
    if (popup.opener == null) {
      popup.opener = self;
    }
    popup.focus();
  }
}
function popupOscarRx(vheight,vwidth,varpage) { //open a new popup window
  var page = varpage;
  windowprops = "height="+vheight+",width="+vwidth+",location=no,scrollbars=yes,menubars=no,toolbars=no,resizable=yes,screenX=0,screenY=0,top=0,left=0";
  var popup=window.open(varpage, "oscarRx", windowprops);
  if (popup != null) {
    if (popup.opener == null) {
      popup.opener = self;
    }
    popup.focus();
  }
}
function popupS(varpage) {
	if (! window.focus)return true;
	var href;
	if (typeof(varpage) == 'string')
	   href=varpage;
	else
	   href=varpage.href;
	window.open(href, "fullwin", ',type=fullWindow,fullscreen,scrollbars=yes');
	return false;
}
function checkRosterStatus() {
	if (rosterStatusChangedNotBlank()) {
		if (document.updatedelete.roster_status.value=="RO" || document.updatedelete.roster_status.value=="NR" || document.updatedelete.roster_status.value=="FS" ) { //Patient rostered
			if (!rosterStatusDateValid(false)) return false;
		}
		else if (document.updatedelete.roster_status.value=="TE") { //Patient terminated
			if (!rosterStatusTerminationDateValid(false)) return false;
			if (!rosterStatusTerminationReasonNotBlank()) return false;
		}
	}

	if (rosterStatusDateAllowed()) {
		if (document.updatedelete.roster_status.value=="RO") { //Patient rostered
			if (!rosterStatusDateValid(false)) return false;
		}
		else if (document.updatedelete.roster_status.value=="TE"){ //Patient terminated
			if (!rosterStatusTerminationDateValid(true)) return false;
		}
	} else {
		return false;
	}
	if (!rosterStatusDateValid(true)) return false;
	if (!rosterStatusTerminationDateValid(true)) return false;
	return true;
}

function rosterStatusChanged() {
	return (document.updatedelete.initial_rosterstatus.value!=document.updatedelete.roster_status.value);
}
function checkPatientStatus() {
	if (patientStatusChanged()) {
		return patientStatusDateValid(false);
	}
	return patientStatusDateValid(true);
}

function patientStatusChanged() {
	return (document.updatedelete.initial_patientstatus.value!=document.updatedelete.patient_status.value);
}
function checkSex() {
	var sex = document.updatedelete.sex.value;
	
	if(sex.length == 0)
	{
		alert ("You must select a Gender.");
		return(false);
	}

	return(true);
}


function checkTypeInEdit() {
  if ( !checkName() ) return false;
  if ( !checkDob() ) return false;
  if ( !checkHin() ) return false;
  if ( !checkSex() ) return false;
  <% if("false".equals(OscarProperties.getInstance().getProperty("skip_postal_code_validation","false"))) { %>
  if ( !isPostalCode() ) return false;
  <% } %>
  if ( !checkRosterStatus() ) return false;
  if ( !checkPatientStatus() ) return false;
    if(document.updatedelete.r_doctor.value==""){
        document.updatedelete.r_doctor_id.value=""
    }
    if(document.updatedelete.f_doctor.value==""){
        document.updatedelete.f_doctor_id.value=""
    }
  return(true);
}

function formatPhoneNum() {
    if (document.updatedelete.phone.value.length == 10) {
        document.updatedelete.phone.value = document.updatedelete.phone.value.substring(0,3) + "-" + document.updatedelete.phone.value.substring(3,6) + "-" + document.updatedelete.phone.value.substring(6);
        }
    if (document.updatedelete.phone.value.length == 11 && document.updatedelete.phone.value.charAt(3) == '-') {
        document.updatedelete.phone.value = document.updatedelete.phone.value.substring(0,3) + "-" + document.updatedelete.phone.value.substring(4,7) + "-" + document.updatedelete.phone.value.substring(7);
    }
    if (document.updatedelete.phone2.value.length == 10) {
        document.updatedelete.phone2.value = document.updatedelete.phone2.value.substring(0,3) + "-" + document.updatedelete.phone2.value.substring(3,6) + "-" + document.updatedelete.phone2.value.substring(6);
        }
    if (document.updatedelete.phone2.value.length == 11 && document.updatedelete.phone2.value.charAt(3) == '-') {
        document.updatedelete.phone2.value = document.updatedelete.phone2.value.substring(0,3) + "-" + document.updatedelete.phone2.value.substring(4,7) + "-" + document.updatedelete.phone2.value.substring(7);
    }
    if (document.getElementById("refDocPhone").innerHTML.length == 10) {
        document.getElementById("refDocPhone").innerHTML = document.getElementById("refDocPhone").innerHTML.substring(3,0) + "-" + document.getElementById("refDocPhone").innerHTML.substring(3,6) + "-" + document.getElementById("refDocPhone").innerHTML.substring(6);
    }
    if (document.getElementById("refDocPhone").innerHTML.length == 11 && document.getElementById("refDocPhone").innerHTML.length.charAt(3) == '-') {
        document.getElementById("refDocPhone").innerHTML = document.getElementById("refDocPhone").innerHTML.substring(3,0) + "-" +document.getElementById("refDocPhone").innerHTML.substring(4,7) + "-" + document.getElementById("refDocPhone").innerHTML.substring(7);
    }
    if (document.getElementById("refDocFax").innerHTML.length == 10) {
        document.getElementById("refDocFax").innerHTML = document.getElementById("refDocFax").innerHTML.substring(3,0) + "-" + document.getElementById("refDocFax").innerHTML.substring(3,6) + "-" + document.getElementById("refDocFax").innerHTML.substring(6);
    }
    if (document.getElementById("refDocFax").innerHTML.length == 11 && document.getElementById("refDocFax").innerHTML.length.charAt(3) == '-') {
        document.getElementById("refDocFax").innerHTML = document.getElementById("refDocFax").innerHTML.substring(3,0) + "-" +document.getElementById("refDocFax").innerHTML.substring(4,7) + "-" + document.getElementById("refDocFax").innerHTML.substring(7);
    }
    if (document.getElementById("famDocPhone").innerHTML.length == 11 && document.getElementById("famDocPhone").innerHTML.length.charAt(3) == '-') {
        document.getElementById("famDocPhone").innerHTML = document.getElementById("famDocPhone").innerHTML.substring(3,0) + "-" +document.getElementById("famDocPhone").innerHTML.substring(4,7) + "-" + document.getElementById("famDocPhone").innerHTML.substring(7);
    }
    if (document.getElementById("famDocFax").innerHTML.length == 10) {
        document.getElementById("famDocFax").innerHTML = document.getElementById("famDocFax").innerHTML.substring(3,0) + "-" + document.getElementById("famDocFax").innerHTML.substring(3,6) + "-" + document.getElementById("famDocFax").innerHTML.substring(6);
    }
    if (document.getElementById("famDocFax").innerHTML.length == 11 && document.getElementById("famDocFax").innerHTML.length.charAt(3) == '-') {
        document.getElementById("famDocFax").innerHTML = document.getElementById("famDocFax").innerHTML.substring(3,0) + "-" +document.getElementById("famDocFax").innerHTML.substring(4,7) + "-" + document.getElementById("famDocFax").innerHTML.substring(7);
    }
}

//
function rs(n,u,w,h,x) {
  args="width="+w+",height="+h+",resizable=yes,scrollbars=yes,status=0,top=60,left=30";
  remote=window.open(u,n,args);
}
/*function referralScriptAttach2(elementName, name2) {
     var d = elementName;
     t0 = escape("document.forms[1].elements[\'"+d+"\'].value");
     t1 = escape("document.forms[1].elements[\'"+name2+"\'].value");
     rs('att',('../billing/CA/ON/searchRefDoc.jsp?param='+t0+'&param2='+t1),600,600,1);
}*/

function referralScriptAttach2(refDoctorNoElement, refDoctorNameElement, refDoctorIdElement, searchType) {
    refDoctorNo = escape(document.forms[1].elements[refDoctorNoElement].value);
    refDoctorName = escape(document.forms[1].elements[refDoctorNameElement].value);
    t0 = escape("document.forms[1].elements[\'"+refDoctorNoElement+"\'].value");
    t1 = escape("document.forms[1].elements[\'"+refDoctorNameElement+"\'].value");
    t2 = refDoctorIdElement != '' ? escape("document.forms[1].elements[\'"+refDoctorIdElement+"\'].value") : "";
    
    rs('att',('../billing/CA/ON/searchRefDoc.jsp?refDoctorNo='+refDoctorNo+'&refDoctorName='+refDoctorName + '&param=' + t0 + '&param2=' + t1 + '&paramId=' + t2 + '&searchType=' + searchType),600,600,1);
}

function removeAccents(s){
    var r=s.toLowerCase();
    r = r.replace(new RegExp("\\s", 'g'),"");
    r = r.replace(new RegExp("[ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½]", 'g'),"a");
    r = r.replace(new RegExp("ï¿½", 'g'),"ae");
    r = r.replace(new RegExp("ï¿½", 'g'),"c");
    r = r.replace(new RegExp("[ï¿½ï¿½ï¿½ï¿½]", 'g'),"e");
    r = r.replace(new RegExp("[ï¿½ï¿½ï¿½ï¿½]", 'g'),"i");
    r = r.replace(new RegExp("ï¿½", 'g'),"n");
    r = r.replace(new RegExp("[ï¿½ï¿½ï¿½ï¿½ï¿½]", 'g'),"o");
    r = r.replace(new RegExp("?", 'g'),"oe");
    r = r.replace(new RegExp("[ï¿½ï¿½ï¿½ï¿½]", 'g'),"u");
    r = r.replace(new RegExp("[ï¿½ï¿½]", 'g'),"y");
    r = r.replace(new RegExp("\\W", 'g'),"");
    return r;
}

function isPostalCode()
{
    if(isCanadian()){
         e = document.updatedelete.postal;
         postalcode = e.value;
         
         if( postalcode == "" )
         	return true;
        	
         rePC = new RegExp(/(^s*([a-z](\s)?\d(\s)?){3}$)s*/i);
    
         if (!rePC.test(postalcode)) {
              e.focus();
              alert("The entered Postal Code is not valid");
              return false;
         }
    }//end cdn check

return true;
}

function isCanadian(){
	e = document.updatedelete.province;
    var province = e.options[e.selectedIndex].value;
    
    if ( province.indexOf("US")>-1 || province=="OT"){ //if not canadian
            return false;
    }
    return true;
}

function getSpecialistInfo(specialistId, specialistType) {
    if (specialistId != null || specialistId != ""){
        jQuery.getJSON("../oscarEncounter/oscarConsultationRequest/getProfessionalSpecialist.json", {id: specialistId},
            function (xml) {
                if (specialistType == "r") {
                    document.getElementById("refDocPhone").innerHTML = xml.phoneNumber;
                    document.getElementById("refDocFax").innerHTML = xml.faxNumber;
                } else if(specialistType = 'f'){
                    document.getElementById("famDocPhone").innerHTML = xml.phoneNumber;
                    document.getElementById("famDocFax").innerHTML = xml.faxNumber;
                }
            });
        formatPhoneNum();
    }
    else{
        if (specialistType == "r") {
            document.getElementById("refDocPhone").innerHTML = "";
            document.getElementById("refDocFax").innerHTML = "";
        } else if(specialistType = 'f'){
            document.getElementById("famDocPhone").innerHTML = "";
            document.getElementById("famDocFax").innerHTML = "";
        }
    }
}