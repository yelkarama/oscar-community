var demographicNo;
var dtCh = '/';
var episodeId;
var formId;
var lockData;
var maxObstetricalHistory = 7;
var maxRiskFactors = 6;
var maxSubsequentVisits = 6;
var maxUltrasounds = 13;
var minYear = 1900;
var maxYear = 9900;
var provNo;

var ohNum = 0;
var page = 0;
var rfNum = 0;
var svNum = 0;
var usNum = 0;


function addObstetricalHistory() {
    var total = parseInt(ohNum);
    if(total >= maxObstetricalHistory) {
        alert('Maximum number of Obstetrical History rows is ' + maxObstetricalHistory);
        return;
    }

    ohNum = total + 1;
    $("#oh_num").val(ohNum);

    addObstetricalHistoryRow(ohNum);
    
    return false;
}

function addObstetricalHistoryRow(i) {
    $.ajax({
        url:'onPerinatalRecordObstetrical.jsp?ohNum=' + i,
        async:false,
        success:function(data) {
            $("#oh_results").append(data);

            if (ohNum === maxObstetricalHistory) {
                $("#oh_add").hide();
            }
        }
    });
}

function addRiskFactor() {
    var total = parseInt(rfNum);
    if(total >= maxRiskFactors) {
        alert('Maximum number of Risk Factor rows is ' + maxRiskFactors);
        return;
    }

    rfNum = total + 1;
    $("#rf_num").val(rfNum);
    addRiskFactorRow(rfNum);
}

function addRiskFactorRow(i) {
    $.ajax({
        url:'onPerinatalRecordRiskFactors.jsp?rfNum='+ i,
        async:false,
        success:function(data) {
            $("#rf_results").append(data);

            if (rfNum === maxRiskFactors) {
                $("#rf_add").hide();
            }
        }
    });
}

function addSubsequentVisit() {
    var total = parseInt(svNum);
    if(total >= maxSubsequentVisits) {
        alert('Maximum number of Subsequent Visit rows is ' + maxSubsequentVisits);
        return;
    }

    svNum = total + 1;
    $("#sv_num").val(svNum);
    addSubsequentVisitRow(svNum);
}

function addSubsequentVisitRow(i) {
    $.ajax({
        url:'onPerinatalRecordVisits.jsp?svNum=' + i,
        async:false,
        success:function(data) {
            $("#sv_results").append(data);

            if (svNum === maxSubsequentVisits) {
                $("#sv_add").hide();
            }
        }
    });
}

function addUltrasound() {
    var total = parseInt(usNum);
    if(total >= maxUltrasounds) {
        alert('Maximum number of Ultrasound rows is ' + maxUltrasounds);
        return;
    }
    
    usNum = total + 1;
    $("#us_num").val(usNum);
    addUltrasoundRow(usNum);
}

function removeLastUltrasound() {
    let tableBody = document.getElementById("us_results");
    let rowCount = tableBody.rows.length;
    
    // If the row count is greater than 2 (The header and the first row) then remove the last row in the table
    if (rowCount > 2) {
        tableBody.deleteRow(rowCount - 1);
        usNum--;
    }
}

function addUltrasoundRow(i) {
    $.ajax({
        url: 'onPerinatalRecordUltrasounds.jsp?usNum=' + i,
        async: false,
        success: function (data) {
            $("#us_results").append(data);

            if (usNum === maxUltrasounds) {
                $("#us_add").hide();
            }
            setupCalendar('us_date' + i);
        }
    });
}

function adjustDynamicListTotals() {
    $('#oh_num').val(adjustDynamicListTotalsOH(true));
    $('#rf_num').val(adjustDynamicListTotalsRF(true));
    $('#sv_num').val(adjustDynamicListTotalsSV(true));
    $('#us_num').val(adjustDynamicListTotalsUs(true));
}

function adjustDynamicListTotalsOH(adjust) {
    var total = 0;
    for(var x=1;x<=maxObstetricalHistory;x++) {
        if($('#oh_' +x).length>0 && $("input[name='oh_yearMonth"+x+"']").val().length > 0) {
            total++;
            if((x !== total) && adjust) {
                $("#oh_"+x).attr('id','oh_'+total);
                $("input[name='oh_yearMonth"+x+"']").attr('name','oh_yearMonth'+total);
                $("input[name='oh_place"+x+"']").attr('name','oh_place'+total);
                $("input[name='oh_gest"+x+"']").attr('name','oh_gest'+total);
                $("input[name='oh_length"+x+"']").attr('name','oh_length'+total);
                $("input[name='oh_svb"+x+"']").attr('name','oh_svb'+total);
                $("input[name='oh_cs"+x+"']").attr('name','oh_cs'+total);
                $("input[name='oh_ass"+x+"']").attr('name','oh_ass'+total);
                $("input[name='oh_comments"+x+"']").attr('name','oh_comments'+total);
                $("input[name='oh_sex"+x+"']").attr('name','oh_sex'+total);
                $("input[name='oh_weight"+x+"']").attr('name','oh_weight'+total);
                $("input[name='oh_breastfed"+x+"']").attr('name','oh_breastfed'+total);
                $("input[name='oh_health"+x+"']").attr('name','oh_health'+total);
            }
        }
    }
    return total;
}

function adjustDynamicListTotalsRF(adjust) {
    var total = 0;
    for(var x=1;x<=maxRiskFactors;x++) {
        if($('#rf_'+x).length>0 &&
            ($("input[name='rf_issues"+x+"']").val().length > 0 || $("input[name='rf_plan"+x+"']").val().length > 0)) {
            total++;
            if((x !== total) && adjust) {
                $("#rf_"+x).attr('id','rf_'+total);
                $("input[name='rf_issues"+x+"']").attr('name','rf_issues'+total);
                $("input[name='rf_plan"+x+"']").attr('name','rf_plan'+total);
            }
        }
    }
    return total;
}

function adjustDynamicListTotalsSV(adjust) {
    var total = 0;
    for(var x=1;x<=maxSubsequentVisits;x++) {
        if($('#sv_'+x).length>0 && $("input[name='sv_date"+x+"']").val().length > 0) {
            total++;
            if((x !== total) && adjust) {
                $("#sv_"+x).attr('id','sv_'+total);
                $("input[name='sv_date"+x+"']").attr('name','sv_date'+total);
                $("input[name='sv_ga"+x+"']").attr('name','sv_ga'+total);
                $("input[name='sv_wt"+x+"']").attr('name','sv_wt'+total);
                $("input[name='sv_bp"+x+"']").attr('name','sv_bp'+total);
                $("input[name='sv_urine"+x+"']").attr('name','sv_urine'+total);
                $("input[name='sv_sfh"+x+"']").attr('name','sv_sfh'+total);
                $("input[name='sv_pres"+x+"']").attr('name','sv_pres'+total);
                $("input[name='sv_fhr"+x+"']").attr('name','sv_fhr'+total);
                $("input[name='sv_fm"+x+"']").attr('name','sv_fm'+total);
                $("input[name='sv_comments"+x+"']").attr('name','sv_comments'+total);
            }
        }
    }
    return total;
}

function adjustDynamicListTotalsUs(adjust) {
    var total = 0;
    for(var x = 1; x <= maxUltrasounds; x++) {
        
        if($('#us_' + x).length > 0 && $("input[name='us_date"+x+"']").val().length > 0) {
            total++;
            if((x !== total) && adjust) {
                $("#us_"+x).attr('id','us_'+total);
                $("input[name='us_date"+x+"']").attr('name','us_date'+total);
                $("input[name='us_ga"+x+"']").attr('name','us_ga'+total);
                if (x === 3) {
                    $("input[name='us_result"+x+"_as']").attr('name','us_result'+total+'_as');
                    $("input[name='us_result"+x+"_pl']").attr('name','us_result'+total+'_pl');
                    $("input[name='us_result"+x+"_sm']").attr('name','us_result'+total+'_sm');
                } else {
                    $("input[name='us_result"+x+"']").attr('name','us_result'+total);
                }
                
            }
        }
    }
    return total;
}

function bmiWarning() {
    $("#bmi_warn").empty();
    
    if($("input[name='pe_bmi']").val().length > 0) {
        var bmi = parseFloat($("input[name='pe_bmi']").val());

        if(bmi >= 40) {
            $("#bmi_warn").append('<td>BMI is very high</td>');
            $("#bmi_warn").show();
        } else if(bmi > 30) {
            $("#bmi_warn").append('<td>BMI is high</td>');
            $("#bmi_warn").show();
        } else if(bmi <= 18.5) {
            $("#bmi_warn").append('<td>BMI is low</td>');
            $("#bmi_warn").show();
        } else {
            $("#bmi_warn").hide();
        }
    } else {
        $("#bmi_warn").append("<td onClick=\"$('#pe_bmi').focus();$('#pe_bmi').dblclick();\">No BMI Entered</td>");
        $("#bmi_warn").show();
    }
}

function bornResourcesDisplay(selected) {
    var url = null;
    if (selected.selectedIndex === 1) {
        url = 'http://sogc.org/wp-content/uploads/2013/01/gui261CPG1107E.pdf';
    } else if (selected.selectedIndex === 2) {
        url = 'http://sogc.org/wp-content/uploads/2013/01/gui217CPG0810.pdf';
    } else if (selected.selectedIndex === 3) {
        url = 'http://sogc.org/wp-content/uploads/2013/01/gui239ECPG1002.pdf';
    }

    if (url) {
        var win=window.open(url, '_blank');
        win.focus();
    }
}

function calculateBmi(field) {
    var height = $('#pe_ht').val();
    var weight = $('#pe_wt').val();
    
    if(isNumber(height) && isNumber(weight)) {
        height = parseFloat(height) / 100;
        weight = parseFloat(weight);
        if(height && height !== 0 && weight && weight !== 0) {
            field.value = Math.round(weight * 10 / height / height) / 10;
        }
    } 
}

function calculateByLMP(field) {
    if (document.forms[0].ps_lmp.value!="" && valDate(document.forms[0].ps_lmp)==true) {
        var str_date = document.forms[0].ps_lmp.value;
        var yyyy = str_date.substring(0, str_date.indexOf("/"));
        var mm = eval(str_date.substring(eval(str_date.indexOf("/")+1), str_date.lastIndexOf("/")) - 1);
        var dd  = str_date.substring(eval(str_date.lastIndexOf("/")+1));
        var calDate=new Date(yyyy,mm,dd);

        calDate.setTime(eval(calDate.getTime() + (280 * 86400000)));

        varMonth1 = calDate.getMonth()+1;
        varMonth1 = varMonth1>9? varMonth1 : ("0"+varMonth1);
        varDate1 = calDate.getDate()>9? calDate.getDate(): ("0"+calDate.getDate());
        field.value = calDate.getFullYear() + '/' + varMonth1 + '/' + varDate1;
    }
}

function calToday(field) {
    var calDate=new Date();
    varMonth = calDate.getMonth()+1;
    varMonth = varMonth>9? varMonth : ("0"+varMonth);
    varDate = calDate.getDate()>9? calDate.getDate(): ("0"+calDate.getDate());
    field.value = calDate.getFullYear() + '/' + (varMonth) + '/' + varDate;
}

function characterCount(fieldId) {
    var field = $('#' + fieldId);
    var label = $('#' + fieldId + "_count");
    var limit = parseInt(field.attr('maxlength'));
    var length = limit - field.val().length;
    
    if (length < 0) {
        length = 0;
        
        field.val(field.val().substring(0, limit));
    }
    
    label.html(length + ' / ' + limit);
}

/*function createCalendarSetupOnLoad(){
    var numItems = $('.ar2uDate').length;
    for(var x=1;x<=numItems;x++) {
        Calendar.setup({ inputField : "ar2_uDate"+x, ifFormat : "%Y/%m/%d", showsTime :false, button : "ar2_uDate"+x+"_cal", singleClick : true, step : 1 });
    }
}*/

function dayDifference(day1, day2) {
    return (day2 - day1) / (1000*60*60*24);
}

function daysInArray(n) {
    for (var i = 1; i <= n; i++) {
        this[i] = 31;
        if (i === 4 || i === 6 || i === 9 || i === 11) {
            this[i] = 30;
        }
        if (i === 2) {
            this[i] = 29;
        }
    }
    return this;
}

function daysInFebruary(year){
    return (((year % 4 === 0) && ((!(year % 100 === 0)) || (year % 400 === 0))) ? 29 : 28 );
}

function deleteObstetricalHistory(id) {
    var followUpId = $("input[name='oh_"+id+".id']").val();
    
    if (followUpId != null) {
        $("form[name='FrmForm']").append("<input type=\"hidden\" name=\"obxhx.delete\" value=\""+id+"\"/>");
    }
    
    $("#oh_"+id).remove();
    
    ohNum = ohNum - 1;
    $("#oh_num").val(ohNum);
    $("#oh_add").show();
    
    return false;
}

function deleteRiskFactor(id) {
    var followUpId = $("input[name='rf_"+id+".id']").val();
    
    if (followUpId != null) {
        $("form[name='FrmForm']").append("<input type=\"hidden\" name=\"rf.delete\" value=\""+followUpId+"\"/>");
    }
    $("#rf_"+id).remove();

    rfNum = rfNum - 1;
    $("#rf_num").val(rfNum);
    $("#rf_add").show();
    return false;
}

function deleteSubsequentVisit(id) {
    var followUpId = $("input[name='sv_"+id+".id']").val();
    if (followUpId != null) {
        $("form[name='FrmForm']").append("<input type=\"hidden\" name=\"sv.delete\" value=\"" + followUpId + "\"/>");
    }
    $("#sv_"+id).remove();

    svNum = svNum - 1;
    $("#sv_num").val(svNum);
    $("#sv_add").show();
    return false;
}

function deleteUltraSound(id) {
    var followUpId = $("input[name='us_"+id+"']").val();
    if (followUpId != null) {
        $("form[name='FrmForm']").append("<input type=\"hidden\" name=\"us.delete\" value=\""+followUpId+"\"/>");
    }
    $("#us_"+id).remove();


    usNum = usNum - 1;
    $("#us_num").val(usNum);
    $("#us_add").show();
    return false;
}

function geneticWarning() {
    $("#genetic_prompt").hide();
    
    $("input[name ^='pgi_'][name $='_result']").each(function () {
        if ($(this).val().length > 0) {
            $("#genetic_prompt").show();
        }
    });
}

function getGestationalAge(field) {
    if (field != null) {
        var days = getGestationalAgeDays(field);
        var weeks = getGestationalAgeWeeks(days);
        var offset;
        var result;

        if (days > 0) {
            offset = days % 7;
        }

        result = parseInt(weeks) + "w+" + offset;
        if (field) {
            field.value = result;
        }

        return result;
    }
}

function getGestationalAgeDays(field) {
    // Take the EDB, remove 40 weeks (280 days), then get the difference between today and that date, to get the number of days into the pregnancy
    var numberOfDays = -1;
    var finalEDB = $("input[name='ps_edb_final']").val();

    if(finalEDB.length === 10) {
        var year = finalEDB.substring(0, 4);
        var month = finalEDB.substring(5, 7);
        var day = finalEDB.substring(8, 10);
        var monthString = month.substring(0, 1) === '0' ? month.substring(1, 2) : month;

        var edbDate = new Date(year, parseInt(monthString) - 1, day);
        edbDate.setHours(8);
        edbDate.setMinutes(0);
        edbDate.setSeconds(0);
        edbDate.setMilliseconds(0);

        var startDate = new Date();
        startDate.setTime(edbDate.getTime() - (280 * 1000 * 60 * 60 * 24));
        startDate.setHours(8);

        let ultrasoundDateField = $("input[name='"+field.name.replace('ga', 'date')+"']");
        let ultrasoundDateStr = ultrasoundDateField.val();
        let ultrasoundDate = new Date();
        
        if (ultrasoundDateStr && ultrasoundDateStr.length === 10) {
            let usYear = ultrasoundDateStr.substring(0, 4);
            let usMonth = ultrasoundDateStr.substring(5, 7);
            let usDay = ultrasoundDateStr.substring(8, 10);
            
            usMonth =  usMonth.substring(0, 1) === '0' ? usMonth.substring(1, 2) : usMonth;
            
            ultrasoundDate = new Date(usYear, (parseInt(usMonth) - 1), usDay);
        } else {
            let usYear = ultrasoundDate.getFullYear();
            let usMonth = ultrasoundDate.getMonth() + 1;
            usMonth = usMonth > 9 ? usMonth : ("0" + usMonth);
            let usDay = ultrasoundDate.getDate() > 9 ? ultrasoundDate.getDate() : ("0" + ultrasoundDate.getDate());

            ultrasoundDateField.val(usYear + '/' + usMonth + '/' + usDay);
        }
        
        ultrasoundDate.setHours(8);
        ultrasoundDate.setMinutes(0);
        ultrasoundDate.setSeconds(0);
        ultrasoundDate.setMilliseconds(0);

        if (ultrasoundDate > startDate) {
            var days = dayDifference(startDate, ultrasoundDate);
            days = Math.round(days);
            numberOfDays = days;
        }
    }

    return parseInt(numberOfDays);
}

function getGestationalAgeWeeks(days) {
    var weeks = 0;

    if(days > 0) {
        weeks = days / 7;
    }

    return parseInt(weeks);
}

function hbsagWarning() {
    if($("select[name='lab_HbsAg']").val() === 'POS' ) {
        $("#hbsag_warn").show();
    } else {
        $("#hbsag_warn").hide();
    }
}

function heightImperialToMetric(field) {
    var height = field.value;
    if(height.length > 1 && height.indexOf("'") > 0 ) {
        var feet = height.substring(0, height.indexOf("'"));
        var inch = height.substring(height.indexOf("'"));
        if(inch.length === 1) {
            inch = 0;
        } else {
            inch = inch.charAt(inch.length-1) === '"' ? inch.substring(0, inch.length-1) : inch;
            inch = inch.substring(1);
        }

        height = Math.round((feet * 30.48 + inch * 2.54) * 10) / 10 ;
        if(confirm("Are you sure you want to change " + feet + " feet " + inch + " inch(es) to " + height +" cm?")) {
            field.value = height;
        }
    }
}

function init(pageNo, view){
    page = pageNo;
    window.moveTo(0, 0);
    window.resizeTo(screen.availWidth, screen.availHeight);
    
    demographicNo = $('#demographicNo').val();
    formId = $('#formId').val();
    episodeId = $('#episodeId').val();
    lockData = null;
    provNo = $('#user').val();
    
    ohNum = parseInt($("#oh_num").val());
    rfNum = parseInt($("#rf_num").val());
    svNum = parseInt($("#sv_num").val());
    usNum = parseInt($("#us_num").val());
    
    if (page === 1) {
        window.onload = function () {
            if (self !== top) {
                var body = document.body;
                var html = document.documentElement;
                var height = 2000;
                parent.parent.document.getElementById('formInViewFrame').firstChild.style.height = height+"px";
            }
        };
        updateCounts('c_allergies', 150);
        updateCounts('c_meds', 150);
        updateCounts('pg1_comments', 885);
        
        if (view) {
            $("#update_allergies_link").hide();
            $("#update_meds_link").hide();
            $("#oh_add").hide();
        }
    } else if (page === 2) {
        $("#lab_gtt1").bind('keyup',function(){
            updateGtt();
        });
        
        $("#lab_gtt2").bind('keyup',function(){
            updateGtt();
        });
        
        $("#lab_gtt3").bind('keyup',function(){
            updateGtt();
        });

        var gttVal = $("#lab_gtt").val();
        if (gttVal.length > 0) {
            var parts = gttVal.split("/");
            $("#lab_gtt1").val(parts[0]);
            $("#lab_gtt2").val(parts[1]);
            $("#lab_gtt3").val(parts[2]);
        }

        if (view) {
            $("#us_add").hide();
        }
    } else if (page === 3) {
        updateCounts('c_allergies', 150);
        updateCounts('c_meds', 150);
        updateCounts('pg3_comments', 885);

        $('#ri_rhNeg').bind('change', function() {
            $('#rhNegSpan').toggleClass("alert-danger");
        });

        if (view) {
            $("#update_allergies_link").hide();
            $("#update_meds_link").hide();
            $("#rf_add").hide();
            $("#sv_add").hide();
        }
    } else if (page === 4) {
        updateResourcesCounts('gad');
        updateResourcesCounts('phq');
        updateResourcesCounts('tace');
        updateResourcesCounts('epds');
    }
    
    calendars();
    warnings();
    
    if (view) {
        $("input[type='text'], input[type='checkbox'], input[type='radio'], select, textarea").each(function() {
            this.setAttribute('disabled', 'disabled');
        });

        $("#lock_req_btn").hide();
        
        $("a").each(function(){
            if($(this).html() === '[x]') {
                $(this).hide();
            }
        });

        $("img[id$='_cal']").each(function(){
            $(this).hide();
        });
    } else {
        updatePageLock(false);
        watchFormVersion();
    }
}


function initObstetricalHistory() {
    for (var i = 1; i <= ohNum; i++){
        $.ajax({
            url:'onPerinatalRecordObstetrical.jsp?ohNum=' + i,
            async:false,
            success:function(data) {
                $("#oh_results").append(data);

                if (ohNum === maxObstetricalHistory) {
                    $("#oh_add").hide();
                }
            }
        });
    }
    if (ohNum < maxObstetricalHistory) {
        addObstetricalHistory();
    }
}

function initRiskFactors() {
    for (var i = 1; i <= rfNum; i++){
        addRiskFactorRow(i);
    }
    if (rfNum < maxRiskFactors) {
        addRiskFactor();
    }
}

function initSubsequentVisits() {
    for (var i = 1; i <= svNum; i++) {
        addSubsequentVisitRow(i);
    }
    if (svNum < maxSubsequentVisits) {
        addSubsequentVisit();
    }
}

function initUltrasounds() {
    for (var i = 1; i <= usNum; i++) {
        addUltrasoundRow(i);
    }
    if (usNum < maxUltrasounds) {
       addUltrasound();
    }
}

function isDate(dtStr){
    var daysInMonth = daysInArray(12);
    var pos1 = dtStr.indexOf(dtCh);
    var pos2 = dtStr.indexOf(dtCh,pos1 + 1);
    var strMonth = dtStr.substring(0,pos1);
    var strDay = dtStr.substring(pos1 + 1,pos2);
    var strYear = dtStr.substring(pos2 + 1);

    if (strDay.charAt(0) === "0" && strDay.length > 1) strDay = strDay.substring(1);
    if (strMonth.charAt(0) === "0" && strMonth.length > 1) strMonth = strMonth.substring(1);
    for (var i = 1; i <= 3; i++) {
        if (strYear.charAt(0) === "0" && strYear.length > 1) {
            strYear = strYear.substring(1);
        }
    }
    var month = parseInt(strMonth);
    var day = parseInt(strDay);
    var year = parseInt(strYear);

    if (pos1 === -1 || pos2 === -1){
        return "format";
    }
    if (month<1 || month > 12){
        return "month";
    }
    if (day<1 || day > 31 || (month === 2 && day > daysInFebruary(year)) || day > daysInMonth[month]){
        return "day";
    }
    if (strYear.length !== 4 || year === 0 || year<minYear || year > maxYear){
        return "year";
    }
    if (dtStr.indexOf(dtCh,pos2+1) !== -1 || isInteger(stripCharsInBag(dtStr, dtCh)) === false){
        return "date";
    }

    return true;
}

function isInteger(s){
    var isInt = true;

    for (var i = 0; i < s.length; i++){
        var c = s.charAt(i);
        if (((c < "0") || (c > "9"))) {
            isInt = false;
        }
    }

    return isInt;
}

function isNumber(value) {
    return value != null && value.trim().length > 0 && !isNaN(value);
}

function moveToChart(type, mtype) {
    if($('#' + type + '_form').val().length>0) {
        $('#' + type + '_chart').val($('#' + type + '_form').val());
        $.ajax({url:'../Pregnancy.do?method=saveMeasurementAjax&demographicNo=<%=demoNo%>&type=' + mtype + '&value=' + $('#' + type + '_form').val(),async:false, dataType:'json',success:function(data) {
            alert('Measurement saved to E-Chart');
        }});
    }
}

function moveToForm(type, field) {
    $('#' + type + '_form').val($('#' + type + '_chart').val());
    $("input[name='" + field + "']").val($('#' + type + '_chart').val());
}

function mcvReq() {
    $("#mcv-req-form").dialog( "open" );
    return false;
}

function onExit(viewOnly) {
    if (viewOnly) {
        window.close();
    } else {
        if(confirm("Are you sure you wish to exit without saving your changes?")) {
            refreshOpener();
            window.close();
        }
    }
    return false;
}

function onPageChange(pageNo) {
    var url = '';
    if (pageNo === 4) {
        url = 'formONPerinatalResources.jsp?demographic_no='+demographicNo+'&formId='+formId+'&provNo='+provNo;
    } else if (pageNo === 5) {
        url = 'formONPerinatalPostnatal.jsp?demographic_no='+demographicNo+'&formId='+formId+'&provNo='+provNo;
    } else {
        url = 'formONPerinatalRecord'+pageNo+'.jsp?demographic_no='+demographicNo+'&formId='+formId+'&provNo='+provNo;
    }
    
    var result = false;
    var isValid = validate();
    var datesValid = checkAllDates();
    if(isValid === true && datesValid === true) {
        reset();
        if(confirm("Are you sure you want to save this form?")) {
            adjustDynamicListTotals();
            result = true;
            document.forms[0].method.value="save";
            document.forms[0].forwardTo.value = pageNo;
            document.forms[0].submit();
        } else {
            location.href = url;
        }
    }
    
    return result;
}


function onPrint() {
    $("#print-dialog").dialog("open");
    return false;
}


function onSave() {
    document.forms[0].method.value="save";
    var ret1 = validate();
    var ret = checkAllDates();
    if(ret == true && ret1==true) {
        reset();
        ret = confirm("Are you sure you want to save this form?");
    }
    if (ret && ret1) {
        window.onunload=null;
    }
    adjustDynamicListTotals();
    return ret && ret1;
}

function onSaveExit() {
    document.forms[0].method.value="saveAndExit";
    var ret1 = validate();
    var ret = checkAllDates();
    if(ret == true && ret1==true)
    {
        reset();
        ret = confirm("Are you sure you wish to save and close this window?");
    }
    if (ret&&ret1)
        refreshOpener();
    adjustDynamicListTotals();
    return ret && ret1;
}

function calendars(){
    if (page === 1) {
        setupCalendar('ps_lmp');
        setupCalendar('ps_lastUsed');
        setupCalendar('ps_edb');
        setupCalendar('ps_edb_final');
        setupCalendar('ps_iuiDate');
        setupCalendar('ps_etDate');
    } else if (page === 2) {
        setupCalendar('lab_lastPapDate');
        setupCalendar('pgi_declinedDate');
        setupCalendar('pgi_niptDate');
        setupCalendar('ps_edb_final');
    } else if (page === 3) {
        setupCalendar('ps_edb_final');
    }
}

function popPage(varpage,pageName) {
    let windowprops = "height=700,width=960"+
        ",location=no,scrollbars=yes,menubars=no,toolbars=no,resizable=no,screenX=50,screenY=50,top=20,left=20";
    var popup = window.open(varpage,pageName, windowprops);
    //if (popup.opener == null) {
    //    popup.opener = self;
    //}
    popup.focus();
}

function warnings(){
    if (page === 1) {
        rhWarning();
        rubellaWarning();
        hbsagWarning();
        geneticWarning();
        rhogamWarning();
        
        if($("input[name='mh_42']").val() === 'Y') {
            $("#smoking_warn").show();
        }

        if($("select[name='mh_26_egg']").val() === 'ANC005' || $("select[name='mh_26_sperm']").val() === 'ANC005' || $("select[name='pg1_labSickle']").val() === 'POS') {
            $("#sickle_cell_warn").show();
        }

        if($("select[name='mh_26_egg']").val() === 'ANC005' || $("select[name='mh_26_sperm']").val() === 'ANC005' || $("select[name='mh_26_egg']").val() === 'ANC002' || $("select[name='mh_26_sperm']").val() === 'ANC002') {
            $("#thalassemia_warn").show();
        }
    } else if (page === 2) {
        bmiWarning();
        if($("input[name='pe_wt']").val().length === 0) {
            $("#weight_warn").show();
        }
        if($("input[name='pe_ht']").val().length === 0) {
            $("#height_warn").show();
        }
        
        $("input[name='pe_ht']").bind('keypress',function(){
            $("input[name='pe_bmi']").val('');
            bmiWarning();
        });
        $("input[name='pe_wt']").bind('keypress',function(){
            $("input[name='pe_bmi']").val('');
            bmiWarning();
        });

        if($("input[name='lab_Hb']").val().length > 0) {
            var hgb_result = parseFloat($("input[name='lab_Hb']").val());
            if(hgb_result < 110)
                $("#hgb_warn").show();
        }

        if($("input[name='lab_MCV']").val().length > 0) {
            var mcv_result = parseFloat($("input[name='lab_MCV']").val());
            if(mcv_result < 80) {
                $("#mcv_abn_prompt").show();
            }
        }
    }

}



function refreshOpener() {
    if (window.opener && window.opener.name === "inboxDocDetails") {
        window.opener.location.reload(true);
    }
}

function releaseLock() {
    updatePageLock(false);
}

function requestLock() {
    updatePageLock(true);
}

function reset() {
    document.forms[0].target = "";
    document.forms[0].action = "../form/ONPerinatal.do" ;
}

function rhWarning() {
    if($("select[name='lab_rh']").val() === 'NEG') {
        $("#rh_warn").show();
    } else {
        $("#rh_warn").hide();
    }
}

function rhogamWarning() {
    if($("select[name='lab_rh']").val() === 'NEG' && getGAWeek() <= 28) {
        $("#rhogam_warn").show();
    } else {
        $("#rhogam_warn").hide();
    }
}

function rubellaWarning() {
    if($("select[name='lab_rubella']").val() === 'Non-Immune') {
        $("#rubella_warn").show();
    } else {
        $("#rubella_warn").hide();
    }
}

function validate() {
    if($("input[name='lab_MCV']").val() != null && $("input[name='lab_MCV']").val().length > 0) {
        var mcv_result = parseFloat($("input[name='lab_MCV']").val());
        
        if(mcv_result < 80) {
            $("#mcv_abn_prompt").show();
        }
    }
    return true;
}

function valDate(dateBox) {
    if(dateBox){
        try {
            var dateString = dateBox.value;
            if(dateString === "") {
                //            alert('dateString'+dateString);
                return true;
            }
            var dt = dateString.split('/');
            var y = dt[0];
            var m = dt[1];
            var d = dt[2];
            var orderString = m + '/' + d + '/' + y;
            var pass = isDate(orderString);

            if(!pass) {
                alert('Invalid '+pass+' in field ' + dateBox.name);
                dateBox.focus();
                return false;
            }
        } catch (ex) {
            alert('Catch Invalid Date in field ' + dateBox.name);
            dateBox.focus();
            return false;
        }
    }

    return true;
}

function weightImperialToMetric(field) {
    var weight = field.value;
    
    if(isNumber(weight)) {
        weight = parseInt(weight);
        var weightMetric = Math.round(weight * 10 * 0.4536) / 10 ;
        if(confirm("Are you sure you want to change " + weight + " pounds to " + weightMetric +" kg?")) {
            field.value = weightMetric;
        }
    }
}

function checkAllDates() {
    var b = true;
    if(valDate(document.forms[0].ps_edb_final)==false){
        b = false;
    }else
    if(valDate(document.forms[0].pg1_formDate)==false){
        b = false;
    }

    return b;
}

function setCheckbox(field,val) {
    $("input[name='"+field+"']").each(function() {
        if(val === 'true' || val === 'checked') {
            $(this).attr("checked", "checked");
        } else {
            $(this).removeAttr("checked");
        }
    });
}

function setInput(id,type,val) {
    $("input[name='"+type+id+"']").each(function() {
        $(this).val(val);
    });
}

function setupCalendar(field) {
    Calendar.setup({ inputField : field, ifFormat : '%Y/%m/%d', showsTime :false, button : field + '_cal', singleClick : true, step : 1 });
}

function setValues(formValues) {
    console.log(formValues);
}

function updateCounts(field, limit) {
    $('#' + field).attr('maxlength', limit);
    
    $('#' + field).bind('keyup', function () {
        characterCount(field);
    });

    characterCount(field);
}

function stripCharsInBag(s, bag){
    var returnString = "";

    for (var i = 0; i < s.length; i++){
        var c = s.charAt(i);
        if (bag.indexOf(c) === -1) {
            returnString += c;
        }
    }

    return returnString;
}

function updateAllergies() {
    $.ajax({
        url:'../Pregnancy.do?method=getAllergies&demographicNo=' + demographicNo,
        async:true, 
        dataType:'json', 
        success:function(data) {
            var allergiesEle = $("#c_allergies");
            if(allergiesEle.val().trim().length === 0) {
                allergiesEle.val(data.value);
            } else {
                allergiesEle.val(allergiesEle.val() + "\n" + data.value);
            }
            updateCounts('c_allergies', 150);
        }
    });
}

function updateGtt() {
    $("#lab_gtt").val($("#lab_gtt1").val() + "/" + $("#lab_gtt2").val() + "/" + $("#lab_gtt3").val());
}

function updateMeds() {
    $.ajax({
        url: '../Pregnancy.do?method=getMeds&demographicNo=' + demographicNo,
        async: true,
        dataType: 'json',
        success: function(data) {
            var meds = $('#c_meds').val().length === 0 ? data.value : $('#c_meds').val() + "\n" + data.value;
            $('#c_meds').val(meds);
            updateCounts('c_meds', 150);
        }
    });
}

function updatePageLock(lock) {
    var haveLock = false;
    $.ajax({
        type: "post",
        url: "../PageMonitoringService.do",
        data: { method: "update", page: "formONPerinatal", pageId: demographicNo, lock: lock},
        dataType: 'json',
        success: function(data) {
            lockData = data;
            var locked = false;
            var lockedProviderName = '';
            var providerNames = '';
            haveLock = false;
            $.each(data, function(key, val) {
                if(val.locked) {
                    locked = true;
                    lockedProviderName = val.providerName;
                }

                if(val.locked === true && val.self === true) {
                    haveLock = true;
                }

                if(providerNames.length > 0) {
                    providerNames += ",";
                }

                providerNames += val.providerName;
            });

            var lockedMsg = locked ? '<span style="color:red" title="'+lockedProviderName+'">&nbsp;(locked)</span>' : '';
            $("#lock_notification").html('<span title="'+providerNames+'">Viewers: ' + data.length + lockedMsg+'</span>');

            if(haveLock === true) { //i have the lock
                $("#lock_req_btn").hide();
                $("#lock_rel_btn").show();
            } else if(locked && !haveLock) { //someone else has lock.
                $("#lock_req_btn").hide();
                $("#lock_rel_btn").hide();
            } else { //no lock
                $("#lock_req_btn").show();
                $("#lock_rel_btn").hide();
            }
        }
    });
    setTimeout(function(){updatePageLock(haveLock)},30000);

}

function updateResourcesCounts(field){
    let total = 0;
    
    $("input[type=radio][name ^="+field+"_"+"]:checked").each(function () {
        total += parseInt($(this).val());
    });

    $("#"+field+"_total").text(total);
}


function watchFormVersion() {
    $.ajax({
        type: "post",
        url: "../Pregnancy.do",
        data: { method: "getLatestFormIdByPregnancy", episodeId: episodeId},
        dataType: 'json',
        success: function(data) {
            if(data.value !== formId) {
                $("#outdated_warn").show();
            } else {
                $("#outdated_warn").hide();
            }
        }
    });

    setTimeout(function(){
        watchFormVersion()
    }, 60000);
}