var section = 'consultation';
window.oceanHost = "https://ocean.cognisantmd.com";

jQuery(document).ready(function(){
    jQuery("#ocean").append("<div id='ocean_div'></div>");
    jQuery.ajax({
        url: window.oceanHost + "/robots.txt",
        cache: true,
        dataType: "text",
        success: function() {
            jQuery.ajax({
                url: window.oceanHost + "/oscar_resources/OscarToolbar.js",
                cache: true,
                dataType: "script"
            });
        },
        error: function(jqXHR, textStatus, error) {
            console.log("Ocean toolbar error: " + textStatus + ", " + error);
            jQuery("#ocean_div").show().css("padding", "5px").
            css("text-align", "center");
        }
    });
});

function eRefer() {
    let demographicNo = document.getElementById("demographicNo").serialize();
    let documents = document.getElementById("documents").serialize();
    let data = demographicNo + "&" + documents;
    jQuery.ajax({
        type: 'POST',
        url: document.getElementById("contextPath").value + '/oscarEncounter/eRefer.do',
        data: data,
        success: function(response) {
            console.log(response);
        }
    });
}