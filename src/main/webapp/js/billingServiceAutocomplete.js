var $ = jQuery.noConflict();
var selectedCodes = new Array();

function checkSave(){
    var curVal = $('#searchService').val();
    var timeVal = $('#billingTime').val();
    var isCurValValid = false;
    
    for(var i = 0; i < selectedCodes.length; i++){
        if(curVal === selectedCodes[i]){
            isCurValValid = true;
            break;
        }
    }
    
    if(isCurValValid) {
        if (timeVal && timeVal.length === 5) {
            $('#addBtn').removeAttr('disabled');
        }
    } else {
        $("#searchServiceDescription").empty();
        $('#addBtn').attr('disabled', 'disabled');
    }
        
}

function setupBillingServiceAutocomplete() {
    if($("#searchService")){

        var url = "../billing/SearchBillingService.do";

        $("#searchService").autocomplete({
            messages: {
                noResults: 'No results',
                results: function() {}
            },
            source: url,
            minLength: 2,

            focus: function( event, ui ) {
                $("#searchService").val(ui.item.value);
                $("#searchServiceDescription").html(ui.item.description);
                return false;
            },
            select: function(event, ui) {
                selectedCodes.push(ui.item.value);
                $("#searchService").val(ui.item.value);
                $("#searchServiceDescription").html(ui.item.description);
                $('#billingTime').focus();
                return false;
            }
        });
    }
}