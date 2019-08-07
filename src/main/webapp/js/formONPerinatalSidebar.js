var demographicNo;
var loggedInProviderNo;
var ohNum = 0;
var rfNum = 0;
var svNum = 0;
var usNum = 0;

function dialogs(page, view) {
    loggedInProviderNo = $('#user').val();
    demographicNo = $('#demographicNo').val();

    if ($("input[name='ps_edb_final']").val() != null && $("input[name='ps_edb_final']").val().length > 0) {
        $('#gest_age').html(getGestationalAge());
    }
    
    $("#print-dialog").dialog({
        autoOpen: false,
        height: 275,
        width: 450,
        modal: true,
        buttons: {
            "Print": function () {
                $(this).dialog("close");
                var printRecord1 = $("#print_pr1").attr('checked');
                var printRecord2 = $("#print_pr2").attr('checked');
                var printRecord3 = $("#print_pr3").attr('checked');
                var printResources = $("#print_pr4").attr('checked');
                var printPostnatal = $("#print_pr5").attr('checked');
                var printLocation = $("#print_location").val();
                var printMethod = $("#print_method").val();
                
                ohNum = parseInt($("#oh_num").val());
                rfNum = parseInt($("#rf_num").val());
                svNum = parseInt($("#sv_num").val());
                usNum = parseInt($("#us_num").val());

                if ((typeof printRecord1 == "undefined") && (typeof printRecord2 == "undefined") && (typeof printRecord3 == "undefined") && (typeof printResources == "undefined") && (typeof printPostnatal == "undefined")) {
                    return;
                }

                /*if (printLocation.length > 0) {
                    jQuery.ajax({
                        type: "POST",
                        url: '../form/ONPerinatal.do?method=print',
                        data: {
                            printLocation: printLocation,
                            printMethod: printMethod,
                            resourceName: 'ONPerinatal',
                            resourceId: $('#episodeId').val()
                        },
                        async: true,
                        success: function (data) {
                            //do nothing at this time
                        }
                    });
                }*/

                $("#printPg1").val(printRecord1 === "checked");
                $("#printPg2").val(printRecord2 === "checked");
                $("#printPg3").val(printRecord3 === "checked");
                $("#printPg4").val(printResources === "checked");
                $("#printPg5").val(printPostnatal === "checked");
                
                
                url = "../form/ONPerinatal.do?method=print";
                var ret = checkAllDates();
                if (ret) {
                    document.forms[0].action = url;
                    $("#printBtn").click();
                
                
                    /*document.forms[0].method.value = "print";
                    document.forms[0].target = "_blank";
                    var url = "../form/createpdf?";
                    var multiple = 0;
                    if (!(typeof printRecord1 == "undefined")) {
                        url += "__title=Antenatal+Record+Part+1&__cfgfile=onar1enhancedPrintCfgPg1&__template=onar1&__numPages=1&postProcessor=ONAR1EnhancedPostProcessor";

                        if ((ohNum.length > 0 && parseInt(ohNum) > 6) || hasExtraComments) {
                            multiple++;
                            url = url + "&__title1=Antenatal+Record+Part+1&__cfgfile1=onar1enhancedPrintCfgPg2&__template1=onar1enhancedpg2&__numPages1=1&postProcessor1=ONAR1EnhancedPostProcessor";
                        }
                    }
                    if (!(typeof printRecord2 == "undefined")) {
                        if (!(typeof printRecord1 == "undefined")) {
                            multiple++;
                            url += "__title" + multiple + "=Antenatal+Record+Part+2&__cfgfile" + multiple + "=onar2enhancedPrintCfgPg1&__cfgGraphicFile" + multiple + "=onar2PrintGraphCfgPg1&__template" + multiple + "=onar2&postProcessor" + multiple + "=ONAR2EnhancedPostProcessor";
                        } else {
                            url += "__title=Antenatal+Record+Part+2&__cfgfile=onar2enhancedPrintCfgPg1&__cfgGraphicFile=onar2PrintGraphCfgPg1&__template=onar2&postProcessor=ONAR2EnhancedPostProcessor";
                        }

                        if (rfNum.length > 0 && parseInt(rfNum) > 7) {
                            multiple++;
                            url = url + "&__title" + multiple + "=Antenatal+Record+Part+2&__cfgfile" + multiple + "=onar2enhancedPrintCfgPgRf&__template" + multiple + "=onar2enhancedrf&__numPages" + multiple + "=1&postProcessor" + multiple + "=ONAR2EnhancedPostProcessor";
                        }
                        if (svNum.length > 0 && parseInt(svNum) > 18) {
                            multiple++;
                            url = url + "&__title" + multiple + "=Antenatal+Record+Part+2&__cfgfile" + multiple + "=onar2enhancedPrintCfgPgSv&__template" + multiple + "=onar2enhancedsv&__numPages" + multiple + "=1&postProcessor" + multiple + "=ONAR2EnhancedPostProcessor";
                        }
                        if (svNum.length > 0 && parseInt(svNum) > 56) {
                            multiple++;
                            url = url + "&__title" + multiple + "=Antenatal+Record+Part+2&__cfgfile" + multiple + "=onar2enhancedPrintCfgPgSv2&__template" + multiple + "=onar2enhancedsv&__numPages" + multiple + "=1&postProcessor" + multiple + "=ONAR2EnhancedPostProcessor";
                        }
                        if (usNum.length > 0 && parseInt(usNum) > 4) {
                            multiple++;
                            url = url + "&__title" + multiple + "=Antenatal+Record+Part+2&__cfgfile" + multiple + "=onar2enhancedPrintCfgPgUs&__template" + multiple + "=onar2enhancedus&__numPages" + multiple + "=1&postProcessor" + multiple + "=ONAR2EnhancedPostProcessor";
                        }
                    }
                    if (multiple > 0) {
                        url = url + "&multiple=" + (multiple + 1);
                    }
                    //go to it
                    document.forms[0].action = url;
                    $("#printBtn").click();*/
                }

            },
            Cancel: function () {
                $(this).dialog("close");
            }
        },
        close: function () {

        }
    });

    $("#print-log-dialog").dialog({
        autoOpen: false,
        height: 350,
        width: 650,
        modal: true,
        buttons: {
            Dismiss: function () {
                $(this).dialog("close");
            }
        },
        close: function () {

        }
    });

    $("#print_log_menu").bind('click',function(){
        jQuery.ajax({
                type:"POST",
                url:'../form/ONPerinatal.do?method=getPrintData', 
                data: {
                    resourceName:'ONPREnhanced',
                    resourceId: $('#demographicNo').val()
                },
                dataType:'json',
                async:true, 
                success:function(data) {
                    $("#print_log_table tbody").html("");
                    $.each(data, function(key, val) {
                        $("#print_log_table tbody").append('<tr><td>'+val.formattedDateString+'</td><td>'+val.providerName+'</td><td>'+val.externalLocation+'</td><td>'+val.externalMethod+'</td></tr>');
                    });
                    $("#print-log-dialog").dialog("open");
                }
        });
    });

    if (!view) {
        setupMenu('forms');
        setupMenu('eforms');
        setupMenu('genetics');
        setupMenu('lab');
        setupMenu('mcv');
        setupMenu('sickle_cell');
        setupMenu('thalassemia');

        $("#credit_valley_genetic_btn").bind('click',function(e){
            e.preventDefault();
            popPage('../Pregnancy.do?method=loadEformByName&name=Prenatal Screening (IPS) Credit Valley&demographicNo=' + demographicNo,'credit_valley_lab_req');
        });

        $("#north_york_genetic_btn").bind('click',function(e){
            e.preventDefault();
            popPage('../Pregnancy.do?method=loadEformByName&name=1Prenatal Screening - North York&demographicNo=' + demographicNo,'north_york_lab_req');
        });

        setupDialog('cytology-eform-form', null, 300, 450);
        setupDialog('ips-eform-form', null, 300, 450);
        setupDialog('ultrasound-eform-form', null, 300, 450);
        
        $("#mcv-req-form").dialog({
            autoOpen: false,
            height: 275,
            width: 450,
            modal: true,
            buttons: {
                "Generate Requisition": function () {
                    $(this).dialog("close");
                    var ferritin = $("#ferritin").attr('checked');
                    var hbElectrophoresis = $("#hbElectrophoresis").attr('checked');
                    url = '../form/formlabreq10.jsp?demographic_no=' + demographicNo + '&formId=0&provNo=' + loggedInProviderNo + '&fromSession=true';
                    jQuery.ajax({
                        url: '../Pregnancy.do?method=createMCVLabReq&demographicNo=' + demographic + '&ferritin=' + ferritin + '&hb_electrophoresis=' + hbElectrophoresis,
                        async: false,
                        success: function (data) {
                            popPage(url, 'LabReq');
                        }
                    });
                },
                Cancel: function () {
                    $(this).dialog("close");
                }
            },
            close: function () {

            }
        });


        if (page == 1) {
            setupDialog("genetic-ref-form", null, 350, 500);
            setupDialog("dating-us-form", null, 350, 500);

            setupDialog("1st-visit-form", "1st_visit_menu", 350, 500);
            setupDialog("16wk-visit-form", "16wk_visit_menu", 350, 500);
        } else if (page == 2) {
            setupDialog("pull-vitals-form", null, 350, 500);
            $('#vitals_pull_menu').bind('click',function(){pullVitals();});

            setupDialog("24wk-visit-form", "24wk_visit_menu", 350, 500);
            setupDialog("35wk-visit-form", "35wk_visit_menu", 350, 500);
        }
    }

}

function pullVitals() {
    //get values from chart
    $.ajax({
        url:'../Pregnancy.do?method=getMeasurementsAjax&demographicNo=' + demographicNo + '&type=BP',
        async:false,
        dataType:'json',
        success: function(data) {
            if(data.length>0) {
                $('#bp_chart').val(data[0].dataField);
                $('#moveToForm_bp').unbind("click").bind('click',function(){moveToForm('bp','pe_bp');});
            } else {
                $('#moveToForm_bp').unbind("click").bind('click',function(){alert('No Available values in E-Chart');});
            }
        }
    });
    $('#bp_form').val($('input[name="pe_bp"]').val());

    $.ajax({
        url:'../Pregnancy.do?method=getMeasurementsAjax&demographicNo=' + demographicNo + '&type=HT',
        async:false,
        dataType:'json',
        success: function(data) {
            if(data.length > 0) {
                $('#height_chart').val(data[0].dataField);
                $('#moveToForm_height').unbind("click").bind('click',function(){moveToForm('height','pe_ht');});
            } else {
                $('#moveToForm_height').unbind("click").bind('click',function(){alert('No Available values in E-Chart');});
            }
        }
    });
    $('#height_form').val($('input[name="pe_ht"]').val());

    $.ajax({
        url:'../Pregnancy.do?method=getMeasurementsAjax&demographicNo=' + demographicNo + '&type=WT',
        async:false,
        dataType:'json',
        success: function(data) {
            if(data.length > 0) {
                $('#weight_chart').val(data[0].dataField);
                $('#moveToForm_weight').unbind("click").bind('click',function(){moveToForm('weight','pe_wt');});
            } else {
                $('#moveToForm_weight').unbind("click").bind('click',function(){alert('No Available values in E-Chart');});
            }
        }
    });
    $('#weight_form').val($('input[name="pe_wt"]').val());

    $("#pull-vitals-form").dialog("open");
    return false;
}


function setupDialog(fieldId, menuButtonId, height, width, autoOpen, modal) {
    autoOpen = autoOpen == null ? false : autoOpen;
    modal = modal == null ? true : modal;
    
    $("#" + fieldId).dialog({
        autoOpen: autoOpen,
        height: height,
        width: width,
        modal: modal,
        buttons: {
            "Dismiss": function() {
                $(this).dialog( "close" );
            }
        },
        close: function() {

        }
    });
    
    if (menuButtonId != null) {
        $("#" + menuButtonId).bind('click',function(){$("#" + fieldId).dialog("open");});
    }
}

function setupMenu(content) {
    $('#' + content + '_menu').menu({
        content: $('#' + content + '_menu_div').html(),
        showSpeed: 400
    });
}