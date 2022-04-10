/* printControl - Changes eform to add a server side generated PDF 
 *                with print functionality intact (if print button on the form).
 */

if (typeof jQuery == "undefined") { alert("The printControl library requires jQuery. Please ensure that it is loaded first"); }
var printControl = {
	initialize: function () {

		var submit = jQuery("input[name='SubmitButton']");
		var printSave = jQuery("input[name='PrintSaveButton']");
		submit.append("<input name='pdfSaveButton' type='button'>");
		submit.append("<input name='pdfButton' type='button'>");
		var pdf = jQuery("input[name='pdfButton']");
		var pdfSave = jQuery("input[name='pdfSaveButton']");
		if (pdf.size() == 0) { pdf = jQuery("input[name='pdfButton']"); }
		if (pdfSave.size() == 0) { pdfSave = jQuery("input[name='pdfSaveButton']"); }
	
		pdf.insertAfter(submit);	
		pdfSave.insertAfter(submit);

		if (pdf.size() != 0) {
			pdf.attr("onclick", "").unbind("click");
			pdf.attr("value", "PDF");
			pdf.click(function(){submitPrintButton(false);});
		}
		if (pdfSave.size() != 0) {
			pdfSave.attr("onclick", "").unbind("click");
			pdfSave.attr("value", "Submit & PDF");
			pdfSave.click(function(){submitPrintButton(true);});
		}
		if (printSave.size() != 0) {
			printSave.attr("value", "Submit & Print");
		}

	}
};

function setFutureDate(weeks){
	var now = new Date();
	now.setDate(now.getDate() + weeks * 7);
	return (now.toISOString().substring(0,10));
}
     
function setTickler(){
    var today = new Date().toISOString().slice(0, 10);
    var subject=( $('#subject').val() ? $('#subject').val() : "test");
	var demographicNo = ($("#tickler_patient_id").val() ? $("#tickler_patient_id").val() : "-1"); // patient_id
    var taskAssignedTo = ($("#tickler_send_to").val() ? $("#tickler_send_to").val() : "-1"); // id from doctor_provider_no current_user_id etc
	var weeks = ($("#tickler_weeks").val() ? $("#tickler_weeks").val() : "6");
	var message = ($("#tickler_message").val() ? $("#tickler_message").val() : "Check for results of "+subject+" ordered " + today);
  	var ticklerDate = setFutureDate(weeks);
	var urgency = ($("#tickler_priority").val() ? $("#ticklerpriority").val() : "Normal"); // case sensitive, can be Low Normal High
	var ticklerToSend = {};
	ticklerToSend.demographicNo = demographicNo; 
	ticklerToSend.message = message;
	ticklerToSend.taskAssignedTo = taskAssignedTo; 
	ticklerToSend.serviceDate = ticklerDate;
	ticklerToSend.priority = urgency; 
 	console.log("pringControl.js is setting a tickler: "+JSON.stringify(ticklerToSend));		
    return $.ajax({
        type: "POST",
  		url:  '../ws/rs/tickler/add',
  		dataType:'json',
  		contentType:'application/json',
  		data: JSON.stringify(ticklerToSend)
  	});
  			 
}
  	
function wrapsetTickler() {
$.when(setTickler()).then(function( data, textStatus, jqXHR ) {
            console.log("printControl.js1 reports tickler "+textStatus);
            if ( jqXHR.status != 200 ){ alert("ERROR ("+jqXHR.status+") automatic tickler FAILED to be set");}
            
        });
}

function submitPrintButton(save) {
	var ticklerFlag = $("#tickler_send_to");     
    if (ticklerFlag.size() >0) { 
        $.when(setTickler()).then(function( data, textStatus, jqXHR ) {
            console.log("printControl.js reports tickler "+textStatus);
            if ( jqXHR.status != 200 ){ alert("ERROR ("+jqXHR.status+") automatic tickler FAILED to be set");}
            finishPdf(save);
        });
    } else {
        finishPdf(save);
    }
}

function finishPdf(save) {
	// Setting this form to print.
	var printHolder = jQuery('#printHolder');
	if (printHolder == null || printHolder.size() == 0) {
		jQuery("form").append("<input id='printHolder' type='hidden' name='print' value='true' >");
	}	
	printHolder = jQuery('#printHolder');
	printHolder.val("true");
	
	var saveHolder = jQuery("#saveHolder");
	if (saveHolder == null || saveHolder.size() == 0) {
		jQuery("form").append("<input id='saveHolder' type='hidden' name='skipSave' value='"+!save+"' >");
	}
	saveHolder = jQuery("#saveHolder");
	saveHolder.val(!save);
	needToConfirm=false;
	
	if (document.getElementById('Letter') != null) {
		document.getElementById('Letter').value=editControlContents('edit');		
	}	
	
	jQuery("form").submit();	
	if (save) { setTimeout("window.close()", 3000); }
	printHolder.val("false");
	saveHolder.val("false");
	
}


jQuery(document).ready(function(){printControl.initialize();});