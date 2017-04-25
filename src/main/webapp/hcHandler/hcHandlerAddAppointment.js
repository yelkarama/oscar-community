
var _hc_windowTimeout;

var _hc_addAppointmentHandler = function(args) {
    clearTimeout(_hc_windowTimeout);

    var hcWindow = jQuery("#_hc_window");
    jQuery(hcWindow).find("#_hc_message, #_hc_read, #_hc_actions, #_hc_match, #_hc_noMatch, #_hc_matchSearch, #_hc_closeBtn").hide();

    jQuery(hcWindow).find("._hc_mismatch").removeClass("_hc_mismatch");
    jQuery(hcWindow).find("#_hc_errors").children().remove();

    if (!(typeof args["error"] == "undefined")) {
        jQuery(hcWindow).find("#_hc_closeBtn").hide();

        jQuery(hcWindow).find("#_hc_status_text_success").hide();
        jQuery(hcWindow).find("#_hc_status_text_error, #_hc_message_tryAgain, #_hc_message").show();

        jQuery(hcWindow).find("#_hc_status_icon").attr("class", "_hc_inlineBlock _hc_status_error");

        if (args["error"] == "INVALID") {
            jQuery(hcWindow).find("#_hc_message_readError").css("display", "inline-block");
            jQuery(hcWindow).find("#_hc_message_issuerError").css("display", "none");
        } else if (args["error"] == "ISSUER") {
            jQuery(hcWindow).find("#_hc_message_readError").css("display", "none");
            jQuery(hcWindow).find("#_hc_message_issuerError").css("display", "inline-block");
        } else {
            jQuery(hcWindow).find("#_hc_message_readError").css("display", "none");
            jQuery(hcWindow).find("#_hc_message_issuerError").css("display", "none");
        }

        _hc_windowTimeout = setTimeout(function() {
            jQuery("#_hc_window").css("display", "none");
        }, 3000);


    } else {
        jQuery(hcWindow).find("#_hc_status_text_success, #_hc_read, #_hc_layout").show();
        jQuery(hcWindow).find("#_hc_message, #_hc_status_text_error").hide();
        jQuery(hcWindow).find("#_hc_status_icon").attr("class", "_hc_inlineBlock _hc_status_success");

        jQuery(hcWindow).find("#_hc_layout_name").text(args["lastName"] + ", " + args["firstName"]);
        jQuery(hcWindow).find("#_hc_layout_hin_num").html(args["hin"].substring(0,4) + "&#149; " + args["hin"].substring(4,7) + "&#149; " + args["hin"].substring(7,10) + "&#149;");
        jQuery(hcWindow).find("#_hc_layout_hin_ver").text(args["hinVer"]);

        jQuery(hcWindow).find("#_hc_layout_info_dob").text(args["dob"].substring(0,4) + "/" + args["dob"].substring(4,6) + "/" + args["dob"].substring(6,8));
        jQuery(hcWindow).find("#_hc_layout_info_sex").text((args["sex"] == "1" ? "M" : (args["sex"] == "2" ? "F" : "")));

        var issueDate = (args["issueDate"].substring(0,2) <= 30 ? "20" : "19") + args["issueDate"];
        jQuery(hcWindow).find("#_hc_layout_valid_from").text(issueDate.substring(0,4) + "/" + issueDate.substring(4,6) + "/" + issueDate.substring(6,8));

        var hinExp = (args["hinExp"].substring(0,2) <= 30 ? "20" : "19") + args["hinExp"];
        jQuery(hcWindow).find("#_hc_layout_valid_to").text(hinExp.substring(0,4) + "/" + hinExp.substring(4,6));


        if (hinExp != "0000") {
            var hinExp = (args["hinExp"].substring(0,2) <= 30 ? "20" : "19") + args["hinExp"] + args["dob"].substring(6,8);
            jQuery(hcWindow).find("#_hc_layout_valid_to").text(hinExp.substring(0,4) + "/" + hinExp.substring(4,6) + "/" + hinExp.substring(6,8));

            var date = new Date();
            var hinExpDate = new Date(hinExp.substring(0,4) + "/" + hinExp.substring(4,6) + "/" + hinExp.substring(6, 8));
            if (hinExpDate <= new Date()) {
                jQuery(hcWindow).find("#_hc_layout_valid_to").addClass("_hc_mismatch");
                jQuery(hcWindow).find("#_hc_errors").append("<div class='_hc_error'>This health card has expired.</div>");
            }

            jQuery("input[name='end_date_year']").val(hinExp.substring(0,4));
            jQuery("input[name='end_date_month']").val(hinExp.substring(4,6));
            jQuery("input[name='end_date_date']").val(hinExp.substring(6,8));

        } else {
            jQuery(hcWindow).find("#_hc_layout_valid_to").text("No Expiry");
            jQuery("input[name='end_date_year']").val("");
            jQuery("input[name='end_date_month']").val("");
            jQuery("input[name='end_date_date']").val("");

        }

        (function(win, hcArgs) {
            jQuery.ajax({
                url: "../indivica/HCSearch.do",
                data: "hin=" + hcArgs["hin"] + "&ver=" + hcArgs["hinVer"] + "&issueDate=" + hcArgs["issueDate"] + "&hinExp=" + hcArgs["hinExp"],
                type: "POST",
                dataType: "json",
                success: function(data) {
                    jQuery(win).find("#_hc_matchSearch").hide();

                    if (data.match) {
                        jQuery(win).find("#_hc_match").show();
                        jQuery(win).find("#_hc_noMatch").hide();
                        jQuery(win).find("#_hc_match #_hc_match_name").text(data.lastName.toUpperCase() + ", " + data.firstName.toUpperCase());
                        jQuery(win).find("#_hc_match #_hc_match_hin_num").html(data.hin.substring(0,4) + "&#149; " + data.hin.substring(4,7) + "&#149; " + data.hin.substring(7,10) + "&#149;");
                        jQuery(win).find("#_hc_match #_hc_match_hin_ver").text(data.hinVer);
                        jQuery(win).find("#_hc_match #_hc_match_address").html(data.address.replace(/\n/g, "<br />"));
                        jQuery(win).find("#_hc_match #_hc_match_phone").text(data.phone);

                        // Check for issues with card data - maybe mismatches with patient data?
                        var error = false;

                        if (hcArgs["hinVer"].trim() == data.hinVer.trim()) {
                            jQuery(win).find("#_hc_layout_hin_ver, #_hc_match_hin_ver").addClass("_hc_mismatch");
                            jQuery(win).find("#_hc_errors").append("<div class='_hc_error'>The version code does not match the stored data.</div>");
                            error = true;
                        }

                        if (hcArgs["lastName"] != data.lastName.toUpperCase() || !hcArgs["firstName"].startsWith(data.firstName.toUpperCase())) {
                            jQuery(win).find("#_hc_layout_name, #_hc_match_name").addClass("_hc_mismatch");
                            jQuery(win).find("#_hc_errors").append("<div class='_hc_error'>The name on the card does not match the stored data.</div>");
                            error = true;
                        }


                        if (error) {
                            jQuery(win).find("#_hc_action_present").hide();
                        } else {
                            jQuery(win).find("#_hc_action_present").hide();
                            jQuery("td[demo_no=" + data.demoNo + "]").addClass("_hc_appointmentMatch");
                        }

                        jQuery(win).find("#_hc_actions").show();

                        (function(demoNo) {
                            jQuery(win).find("#_hc_action_update").click(function() {
                                popupPage(700,1000,"../demographic/demographiccontrol.jsp?demographic_no=" + demoNo + "&displaymode=edit&dboperation=search_detail", "Master Record");
                                jQuery(win).hide();
                            });
                        })(data.demoNo);

                        jQuery(win).find("#_hc_action_present").hide();
                        // Add all of these values to the correct fields on the page
                        jQuery("input[name='keyword']").val(args["lastName"] + ", " + args["firstName"]);
                        jQuery("input[name='displaymode']").val('Search ');
                        jQuery("form[name='ADDAPPT']").submit();



                    } else {
                        jQuery("input[name='keyword']").empty();
                        var addDemoWindow = window.open("../demographic/demographicaddarecordhtm.jsp?promptHc=true", "New Record", "height=700,width=1000");
                        addDemoWindow.onload = function() {
                            addDemoWindow.document.getElementById('last_name').value = args["lastName"];
                            addDemoWindow.document.getElementById('first_name').value = args["firstName"];
                            addDemoWindow.document.getElementById('hin').value = args["hin"];
                            addDemoWindow.document.getElementById('hc_type').value = "ON";
							addDemoWindow.document.getElementById('full_birth_date').value = args["dob"].substring(0,4) + '-' + args["dob"].substring(4,6) + '-' + args["dob"].substring(6,8);
                            addDemoWindow.document.getElementById('year_of_birth').value = args["dob"].substring(0,4);
                            addDemoWindow.document.getElementById('month_of_birth').value = args["dob"].substring(4,6);
                            addDemoWindow.document.getElementById('date_of_birth').value = args["dob"].substring(6,8);
                            addDemoWindow.document.getElementById('ver').value = args["hinVer"];
                            addDemoWindow.document.getElementById('sex').value = (args["sex"] == "1" ? "M" : (args["sex"] == "2" ? "F" : ""));
							addDemoWindow.document.getElementById('eff_date').value = issueDate.substring(0,4) + '-' + issueDate.substring(4,6) + '-' + issueDate.substring(6,8);
                        }
                    }
                }
            });
        })(hcWindow, args);

        _hc_windowTimeout = setTimeout(function() {
            jQuery("#_hc_window").css("display", "none");
        }, 3000);
    }

    jQuery(hcWindow).css("display", "block");
}

jQuery(document).ready(function() {
    jQuery("#_hc_window #_hc_matchSearch img").attr("src", "../images/DMSLoader.gif");

    jQuery("#_hc_window #_hc_closeBtn").click(function() {
        jQuery("#_hc_window").hide();
    });

    new HealthCardHandler(_hc_addAppointmentHandler);
});