function setupResultCodeSearchTypeahead() {
    if(jQuery("#resultCodeSearch")) {
        let url = "../olis/Search.do?method=searchResultCodes";

        jQuery("#resultCodeSearch").autocomplete({
            source: url,
            minLength: 2,

            focus: function( event, ui ) {
                jQuery( "#resultCodeSearch").val( ui.item.label );

                return false;
            },
            select: function(event, ui) {
                let codes = jQuery("#result-codes");
                codes.val(codes.val() + ui.item.value + '\n');
                jQuery( "#resultCodeSearch").val("");
                
                return false;
            }
        });
    }
}

function setupRequestCodeSearchTypeahead() {
    if(jQuery("#requestCodeSearch")) {
        let url = "../olis/Search.do?method=searchRequestCodes";

        jQuery("#requestCodeSearch").autocomplete({
            source: url,
            minLength: 2,

            focus: function( event, ui ) {
                jQuery( "#requestCodeSearch").val( ui.item.label );

                return false;
            },
            select: function(event, ui) {
                let codes = jQuery("#request-codes");
                codes.val(codes.val() + ui.item.value + '\n');
                jQuery( "#requestCodeSearch").val("");
                
                return false;
            }
        });
    }
}