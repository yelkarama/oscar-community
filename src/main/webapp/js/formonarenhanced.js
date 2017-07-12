function addUltraSound() {
    if(adjustDynamicListTotalsUS("us_",12,false) >= 12) {
        alert('Maximum number of rows is 12');
        return;
    }

    var total = jQuery("#us_num").val();
    total++;
    jQuery("#us_num").val(total);
    jQuery.ajax({url:'onarenhanced_us.jsp?n='+total,async:false, success:function(data) {
        jQuery("#us_container tbody").append(data);
    }});

    Calendar.setup({ inputField : "ar2_uDate"+total, ifFormat : "%Y/%m/%d", showsTime :false, button : "ar2_uDate"+total+"_cal", singleClick : true, step : 1 });
}

function calToday(field) {
    var calDate=new Date();
    varMonth = calDate.getMonth()+1;
    varMonth = varMonth>9? varMonth : ("0"+varMonth);
    varDate = calDate.getDate()>9? calDate.getDate(): ("0"+calDate.getDate());
    field.value = calDate.getFullYear() + '/' + (varMonth) + '/' + varDate;
}

function createCalendarSetupOnLoad(){
    var numItems = $('.ar2uDate').length;
    for(var x=1;x<=numItems;x++) {
        Calendar.setup({ inputField : "ar2_uDate"+x, ifFormat : "%Y/%m/%d", showsTime :false, button : "ar2_uDate"+x+"_cal", singleClick : true, step : 1 });
    }
}

function deleteUltraSound(id) {
    var followUpId = jQuery("input[name='us_"+id+"']").val();
    jQuery("form[name='FrmForm']").append("<input type=\"hidden\" name=\"us.delete\" value=\""+followUpId+"\"/>");
    jQuery("#us_"+id).remove();
}



function onSave() {
    document.forms[0].submit.value="save";
    var ret1 = validate();
    var ret = checkAllDates();
    if(ret==true && ret1==true)
    {
        reset();
        ret = confirm("Are you sure you want to save this form?");
    }
    if (ret && ret1)
        window.onunload=null;
    adjustDynamicListTotals();
    return ret && ret1;
}

function onSaveExit() {
    document.forms[0].submit.value="exit";
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

function refreshOpener() {
    if (window.opener && window.opener.name=="inboxDocDetails") {
        window.opener.location.reload(true);
    }
}

function adjustDynamicListTotals() {
    $('#rf_num').val(adjustDynamicListTotalsRF('rf_',20,true));
    $('#sv_num').val(adjustDynamicListTotalsSV('sv_',70,true));
    $('#us_num').val(adjustDynamicListTotalsUS('us_',12,true));
}

function adjustDynamicListTotalsRF(name,max,adjust) {
    var total = 0;
    for(var x=1;x<=max;x++) {
        if($('#'+ name +x).length>0) {
            total++;
            if((x != total) && adjust) {
                $("#rf_"+x).attr('id','rf_'+total);
                $("input[name='c_riskFactors"+x+"']").attr('name','c_riskFactors'+total);
                $("input[name='c_planManage"+x+"']").attr('name','c_planManage'+total);
            }
        }
    }
    return total;
}

function adjustDynamicListTotalsSV(name,max,adjust) {
    var total = 0;
    for(var x=1;x<=max;x++) {
        if($('#'+ name +x).length>0) {
            total++;
            if((x != total) && adjust) {
                $("#sv_"+x).attr('id','sv_'+total);
                $("input[name='pg2_date"+x+"']").attr('name','pg2_date'+total);
                $("input[name='pg2_gest"+x+"']").attr('name','pg2_gest'+total);
                $("input[name='pg2_wt"+x+"']").attr('name','pg2_wt'+total);
                $("input[name='pg2_BP"+x+"']").attr('name','pg2_BP'+total);
                $("input[name='pg2_urinePr"+x+"']").attr('name','pg2_urinePr'+total);
                //$("input[name='pg2_urineGl"+x+"']").attr('name','pg2_urineGl'+total);
                $("input[name='pg2_ht"+x+"']").attr('name','pg2_ht'+total);
                $("input[name='pg2_presn"+x+"']").attr('name','pg2_presn'+total);
                $("input[name='pg2_FHR"+x+"']").attr('name','pg2_FHR'+total);
                $("input[name='pg2_comments"+x+"']").attr('name','pg2_comments'+total);
            }
        }
    }
    return total;
}

function adjustDynamicListTotalsUS(name,max,adjust) {
    var total = 0;
    for(var x=1;x<=max;x++) {
        if($('#'+ name +x).length>0) {
            total++;
            if((x != total) && adjust) {
                $("#us_"+x).attr('id','us_'+total);
                $("input[name='ar2_uDate"+x+"']").attr('name','ar2_uDate'+total);
                $("input[name='ar2_uGA"+x+"']").attr('name','ar2_uGA'+total);
                $("input[name='ar2_uResults"+x+"']").attr('name','ar2_uResults'+total);
            }
        }
    }
    return total;
}

function validate() {
    if($("input[name='pg1_labMCV']").val().length > 0) {
        var mcv_result = parseFloat($("input[name='pg1_labMCV']").val());
        if(mcv_result < 80)
            $("#mcv_abn_prompt").show();
    }
    return true;
}

function valDate(dateBox)
{
    if(dateBox){
        try
        {
            var dateString = dateBox.value;
            if(dateString == "")
            {
                //            alert('dateString'+dateString);
                return true;
            }
            var dt = dateString.split('/');
            var y = dt[0];
            var m = dt[1];
            var d = dt[2];
            var orderString = m + '/' + d + '/' + y;
            var pass = isDate(orderString);

            if(pass!=true)
            {
                alert('Invalid '+pass+' in field ' + dateBox.name);
                dateBox.focus();
                return false;
            }
        }
        catch (ex)
        {
            alert('Catch Invalid Date in field ' + dateBox.name);
            dateBox.focus();
            return false;
        }
    }

    return true;
}

function checkAllDates()
{
    var b = true;
    if(valDate(document.forms[0].c_finalEDB)==false){
        b = false;
    }else
    if(valDate(document.forms[0].pg1_formDate)==false){
        b = false;
    }

    return b;
}

function setInput(id,type,val) {
    jQuery("input[name='"+type+id+"']").each(function() {
        jQuery(this).val(val);
    });
}