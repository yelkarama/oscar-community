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
			if(document.getElementById("root")){
				pdf.click(function(){downloadPdf(false);});
			}else {
				pdf.click(function(){submitPrintButton(false);});
			}
		}
		if (pdfSave.size() != 0) {
			pdfSave.attr("onclick", "").unbind("click");
			pdfSave.attr("value", "Submit & PDF");
			if(document.getElementById("root")){
				pdfSave.click(function(){downloadPdf(true);});
			}else {
				pdfSave.click(function(){submitPrintButton(true);});
			}
		}
		
		if (printSave.size() != 0) {
			printSave.attr("value", "Submit & Print");
		}
	}
};

function submitPrintButton(save) {
	if($('iframe[id^="eformiframe"]').length > 0){
		//save richtext letter attachment eform from eformportal to pdf list
		var obj = $('iframe[id^="eformiframe"]');
		var allname = new Array();
		
		for(var i = 0;i < obj.length;i ++){
			var myDate = new Date();
		    var currentdate = myDate.getTime();
		    var content = $("#eformiframe" + i).contents().find("#eform-preview .page");
		    var nodes = content.toArray();
		    var height = content.height();
		    var width = content.width();
		    var filename = "Eform-" + currentdate + ".pdf";
		    generatePDF(nodes, "a4", width, height, filename, "2", function(existfilename){
		    	allname.push(existfilename);
		    	if(allname.length == obj.length){
		    		var formsrc = jQuery("form").attr("action");
		    		if(formsrc.indexOf("&efname=") > -1){
		    			formsrc = formsrc.substring(0, formsrc.indexOf("&efname=")) + '&efname='+allname;
		    		}else{
		    			formsrc = formsrc +'&efname='+allname;
		    		}
			    	jQuery("form").attr("action",formsrc);
			    	
			    	//post and print pdf
			    	if (saveSig != null) {
						saveSig();
					}
					if (save && releaseDirtyFlag != null) {
						releaseDirtyFlag();
					}
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
					if (save) { 
						var setTime = 9000;
						if($("li.eform").length > 0){
							setTime = 14000;
						}
						setTimeout("window.close()", setTime);
					}
					
					printHolder.val("false");
					saveHolder.val("false");
		    	}
		    });
		}
	}else{
		//post and print pdf
		if (saveSig != null) {
			saveSig();
		}
		if (save && releaseDirtyFlag != null) {
			releaseDirtyFlag();
		}
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
		if (save) { 
			var setTime = 9000;
			if($("li.eform").length > 0){
				setTime = 14000;
			}
			setTimeout("window.close()", setTime);
		}
		
		printHolder.val("false");
		saveHolder.val("false");
	}
}

function downloadPdf(save){
	var myDate = new Date();
    var currentdate = myDate.getTime();
    var content = $("#eform-preview .page");
    var nodes = content.toArray();
    var height = content.height();
    var width = content.width();
    var filename = "Eform-" + currentdate + ".pdf";
    
    generatePDF(nodes, "a4", width, height, filename, "0", function(){
    	if(save){
    		setTimeout('SubmitButton.click()', 6000);
    		if (saveSig != null) {
    			saveSig(); 
    		}	
    	}
    	for(var i = 0;i < nodes.length;i ++){
        	$(nodes[i]).css("border","1px solid");
    	}
    });
}

jQuery(document).ready(function(){printControl.initialize();});
