var fieldObj;
function assignBackgroundColor(obj)
{
    var flagObj = null;
    var flagObjName = "flag_" + obj.name;
    flagObj = document.getElementsByName(flagObjName);

    if(flagObj[0].value == 'red')
    {
        obj.style.backgroundColor = 'red';
        obj.style.color = 'white';
    }
    else
    {
        obj.style.backgroundColor = 'white';
        obj.style.color = '#677677';
    }
}
function changeColor(obj)
{
    var flagObjName = "";
    var flagObj = null;
    if(obj.style.backgroundColor == 'white')
    {
        obj.style.backgroundColor = 'red';
        obj.style.color = 'white';
        flagObjName = "flag_" + obj.name;
        flagObj = document.getElementsByName(flagObjName);
        flagObj[0].value = "red";
    }
    else
    {
        obj.style.backgroundColor = 'white';
        obj.style.color = '#677677';
        flagObjName = "flag_" + obj.name;
        flagObj = document.getElementsByName(flagObjName);
        flagObj[0].value = "";
    }
}

function showHideBox(layerName, iState)
{ // 1 visible, 0 hidden
    if(document.layers)	   //NN4+
    {
        document.layers[layerName].visibility = iState ? "show" : "hide";
    } else if(document.getElementById)	  //gecko(NN6) + IE 5+
    {
        var obj = document.getElementById(layerName);
        obj.style.visibility = iState ? "visible" : "hidden";
    } else if(document.all)	// IE 4
    {
        document.all[layerName].style.visibility = iState ? "visible" : "hidden";
    }
}
function showBox(layerName, iState, field, e) { // 1 visible, 0 hidden
    fieldObj = field;
    //get the number of the field
    fieldName = fieldObj.name;
    fieldName = fieldName.substring("pg2_pos".length);

    if(document.layers)	{   //NN4+
        document.layers[layerName].visibility = iState ? "show" : "hide";
    } else if(document.getElementById) {	  //gecko(NN6) + IE 5+
        var obj = document.getElementById(layerName);
        obj.style.top = e.screenY + (481-e.screenY + 26*fieldName);
        obj.style.left = "390px";
        obj.style.visibility = iState ? "visible" : "hidden";
    } else if(document.all)	// IE 4
    {
        document.all[layerName].style.visibility = iState ? "visible" : "hidden";
    }
    fieldObj = field;
}
function showBMIBox(layerName, iState, field, e) { // 1 visible, 0 hidden

    fieldObj = field;
    //get the number of the field
    fieldName = fieldObj.name;

    if(document.layers)	{   //NN4+
        document.layers[layerName].visibility = iState ? "show" : "hide";
    } else if(document.getElementById) {	  //gecko(NN6) + IE 5+
        var obj = document.getElementById(layerName);
        obj.style.top = e.screenY + (401-e.screenY + 26*fieldName);
        obj.style.left = "30px";
        obj.style.visibility = iState ? "visible" : "hidden";
    } else if(document.all)	// IE 4
    {
        document.all[layerName].style.visibility = iState ? "visible" : "hidden";
    }
    fieldObj = field;
}
function showPGBox(layerName, iState, field, e, prefix, origX, origY, deltaY) { // 1 visible, 0 hidden
    fieldObj = field;
    //get the number of the field
    fieldName = fieldObj.name;
    fieldName = fieldName.substring(prefix.length);
    if (fieldName=="")
    {
        fieldName=0;
    }

    if(document.layers)
    {   //NN4+
        document.layers[layerName].visibility = iState ? "show" : "hide";
    }
    else if(document.getElementById)
    {	  //gecko(NN6) + IE 5+

        var obj = document.getElementById(layerName);
        obj.style.top = e.screenY + (origY-e.screenY + deltaY*fieldName);
        obj.style.left = origX;
        obj.style.visibility = iState ? "visible" : "hidden";

        obj.style.visibility = "visible";

    }
    else if(document.all)
    {// IE 4
        document.all[layerName].style.visibility = iState ? "visible" : "hidden";
    }
    fieldObj = field;
}
function insertBox(str, layerName) { // 1 visible, 0 hidden
    if(document.getElementById)	{
        fieldObj.value = str;
    }
    showHideBox(layerName, 0);
}
function showDef(str, field) {
    if(document.getElementById)	{
        field.value = str;
    }
}
function syncDemo() {
    document.forms[0].c_surname.value = "BRO'WN";
    document.forms[0].c_givenName.value = "PREGNANT";
    document.forms[0].c_address.value = "12 Mockingbird lane";
    document.forms[0].c_city.value = "Pemberton";
    document.forms[0].c_province.value = "BC";
    document.forms[0].c_postal.value = "V2S 1V9";
    document.forms[0].c_phn.value = "9069158251";
    document.forms[0].c_phone.value = "604-778-4593  ";
}


function wtEnglish2Metric(obj) {

    if(isNumber(obj) ) {
        weight = obj.value;
        weightM = Math.round(weight * 10 * 0.4536) / 10 ;
        if(confirm("Are you sure you want to change " + weight + " pounds to " + weightM +"kg?") ) {
            //document.forms[0].c_ppWt.value = weightM;
            obj.value = weightM;
        }

    }
}
function htEnglish2Metric(obj) {

    height = obj.value;
    if(height.length > 1 && height.indexOf("'") > 0 ) {
        feet = height.substring(0, height.indexOf("'"));
        inch = height.substring(height.indexOf("'"));
        if(inch.length == 1) {
            inch = 0;
        } else {
            inch = inch.charAt(inch.length-1)=='"' ? inch.substring(0, inch.length-1) : inch;
            inch = inch.substring(1);
        }

        height = Math.round((feet * 30.48 + inch * 2.54) * 10) / 10 ;
        if(confirm("Are you sure you want to change " + feet + " feet " + inch + " inch(es) to " + height +"cm?") ) {
            obj.value = height;
        }
    }

}
function calcBMIMetric(wt, ht, obj) {

    if(isNumber(wt) && isNumber(ht))
    {
        var weight = parseFloat(wt.value);
        var height = parseFloat(ht.value);

        height = height / 100;

        if(weight > 0  &&  height > 0)
        {
            obj.value =  "" + Math.round(weight * 10 / height / height) / 10;
        }
    }
}

function calcTMC(volumeObj, densityObj, motilityObj, obj) {

    if(isNumber(volumeObj) && isNumber(densityObj)  &&  isNumber(motilityObj))
    {
        var volume = parseFloat(volumeObj.value);
        var density = parseFloat(densityObj.value);
        var motility = parseFloat(motilityObj.value);

        motility = motility / 100;

        if(volume > 0  &&  density > 0  &&  motility > 0)
        {
            obj.value =  "" +  to2DecimalDigits(volume * density * motility);

        }
    }
}

function  to2DecimalDigits(decimal)
{
    var decimalDouble = 0.00;
    decimalDouble = decimal;
    var rtnStr = "";

    try
    {
        decimalDouble = (Math.round(decimalDouble * 1000)) / 1000.00;
        rtnStr = "" + decimalDouble;
    }
    catch(ex)
    {
        rtnStr = decimal;
    }


    if(decimal == null)
    {
        return "0.00";
    }

    var index = 0;

    index = rtnStr.indexOf(".");

    var pos = rtnStr.length - index;

    if(pos == 3)
        ; // in  xxx.xx format already
    else if(pos == 2)
        rtnStr += "0";
    else if(pos == 1)
        rtnStr += "00";
    else if(pos <= 0)
    {
        rtnStr += ".00";
    }
    else if(pos > 4)
    {
        rtnStr = rtnStr.substring(0,index+3);
    }

    return rtnStr;

}

function onPrint_old() {
    window.print();
}

function onPrint() {
    document.forms[0].submit.value="print";

    var ret = checkAllDates();
    if(ret==true)
    {
        document.forms[0].action = "../form/createpdf?__title=Ovulation+Form&__cfgfile=ovulationPrintCfgPg1&__cfgfile=ovulationPrintCfgPg2&__template=OvulationForm_95";


        document.forms[0].target="_blank";
    }
    return ret;
}

function onSave(urlPath) {
    document.forms[0].submit.value="save";
    var ret = checkAllDates();
    if(ret==true) {
        ret = confirm("Are you sure you want to save this form?");
        reset(urlPath);
    }
    return ret;
}

function onSaveExit(urlPath) {
    document.forms[0].submit.value="exit";
    var ret = true;
    if(ret == true) {
        ret = confirm("Are you sure you wish to save and close this window?");
        reset(urlPath);
    }

    return ret;
}

function reset(urlPath) {
    document.forms[0].target = "";
    document.forms[0].action = urlPath;
}

function isNumber(ss){
    var s = ss.value;
    var i;
    for (i = 0; i < s.length; i++){
        // Check that current character is number.
        var c = s.charAt(i);
        if (c == '.') {
            continue;
        } else if (((c < "0") || (c > "9"))) {
            alert('Invalid '+s+' in field ' + ss.name);
            ss.focus();
            return false;
        }
    }
    // All characters are numbers.
    return true;
}
function checkAllNumber() {
    var b = true;
    if(isNumber(document.forms[0].pg2_ht1)==false){
        b = false;
    } else if(!isNumber(document.forms[0].pg2_ht2) ){
        b = false;
    } else if(!isNumber(document.forms[0].pg2_ht3) ){
        b = false;
    } else if(!isNumber(document.forms[0].pg2_ht4) ){
        b = false;
    } else if(!isNumber(document.forms[0].pg2_ht5) ){
        b = false;
    } else if(!isNumber(document.forms[0].pg2_ht6) ){
        b = false;
    } else if(!isNumber(document.forms[0].pg2_ht7) ){
        b = false;
    } else if(!isNumber(document.forms[0].pg2_ht8) ){
        b = false;
    } else if(!isNumber(document.forms[0].pg2_ht9) ){
        b = false;
    } else if(!isNumber(document.forms[0].pg2_ht10) ){
        b = false;
    } else if(!isNumber(document.forms[0].pg2_ht11) ){
        b = false;
    } else if(!isNumber(document.forms[0].pg2_ht12) ){
        b = false;
    } else if(!isNumber(document.forms[0].pg2_ht13) ){
        b = false;
    } else if(!isNumber(document.forms[0].pg2_ht14) ){
        b = false;
    } else if(!isNumber(document.forms[0].pg2_ht15) ){
        b = false;
    } else if(!isNumber(document.forms[0].pg2_ht16) ){
        b = false;
    } else if(!isNumber(document.forms[0].pg2_ht17) ){
        b = false;
    }
    return b;
}

/**
 * DHTML date validation script. Courtesy of SmartWebby.com (http://www.smartwebby.com/dhtml/)
 */
// Declaring valid date character, minimum year and maximum year
var dtCh= "/";
var minYear=1900;
var maxYear=9900;

function isInteger(s){
    var i;
    for (i = 0; i < s.length; i++){
        // Check that current character is number.
        var c = s.charAt(i);
        if (((c < "0") || (c > "9"))) return false;
    }
    // All characters are numbers.
    return true;
}

function stripCharsInBag(s, bag){
    var i;
    var returnString = "";
    // Search through string's characters one by one.
    // If character is not in bag, append to returnString.
    for (i = 0; i < s.length; i++){
        var c = s.charAt(i);
        if (bag.indexOf(c) == -1) returnString += c;
    }
    return returnString;
}

function daysInFebruary (year){
    // February has 29 days in any year evenly divisible by four,
    // EXCEPT for centurial years which are not also divisible by 400.
    return (((year % 4 == 0) && ( (!(year % 100 == 0)) || (year % 400 == 0))) ? 29 : 28 );
}
function DaysArray(n) {
    for (var i = 1; i <= n; i++) {
        this[i] = 31
        if (i==4 || i==6 || i==9 || i==11) {this[i] = 30}
        if (i==2) {this[i] = 29}
    }
    return this
}

function isDate(dtStr){
    var daysInMonth = DaysArray(12)
    var pos1=dtStr.indexOf(dtCh)
    var pos2=dtStr.indexOf(dtCh,pos1+1)
    var strMonth=dtStr.substring(0,pos1)
    var strDay=dtStr.substring(pos1+1,pos2)
    var strYear=dtStr.substring(pos2+1)
    strYr=strYear
    if (strDay.charAt(0)=="0" && strDay.length>1) strDay=strDay.substring(1)
    if (strMonth.charAt(0)=="0" && strMonth.length>1) strMonth=strMonth.substring(1)
    for (var i = 1; i <= 3; i++) {
        if (strYr.charAt(0)=="0" && strYr.length>1) strYr=strYr.substring(1)
    }
    month=parseInt(strMonth)
    day=parseInt(strDay)
    year=parseInt(strYr)
    if (pos1==-1 || pos2==-1){
        return "format"
    }
    if (month<1 || month>12){
        return "month"
    }
    if (day<1 || day>31 || (month==2 && day>daysInFebruary(year)) || day > daysInMonth[month]){
        return "day"
    }
    if (strYear.length != 4 || year==0 || year<minYear || year>maxYear){
        return "year"
    }
    if (dtStr.indexOf(dtCh,pos2+1)!=-1 || isInteger(stripCharsInBag(dtStr, dtCh))==false){
        return "date"
    }
    return true
}


function checkTypeIn(obj) {
    if(!checkTypeNum(obj.value) ) {
        alert ("You must type in a number in the field.");
    }
}

function valDate(dateBox)
{
    try
    {
        var dateString = dateBox.value;
        if(dateString == "")
        {
            return true;
        }
        var dt = dateString.split('/');
        var y = dt[2];  var m = dt[1];  var d = dt[0];
        //var y = dt[0];  var m = dt[1];  var d = dt[2];
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
    return true;
}

function checkAllDates()
{
    var b = true;

    if(valDate(document.forms[0].lmp)==false){
        b = false;
    }else
    if(valDate(document.forms[0].date1)==false){
        b = false;
    }else
    if(valDate(document.forms[0].date2)==false){
        b = false;
    }else
    if(valDate(document.forms[0].date3)==false){
        b = false;
    }else
    if(valDate(document.forms[0].date4)==false){
        b = false;
    }else
    if(valDate(document.forms[0].date5)==false){
        b = false;
    }else
    if(valDate(document.forms[0].date6)==false){
        b = false;
    }else
    if(valDate(document.forms[0].date7)==false){
        b = false;
    }else
    if(valDate(document.forms[0].date8)==false){
        b = false;
    }else
    if(valDate(document.forms[0].date9)==false){
        b = false;
    }else
    if(valDate(document.forms[0].date10)==false){
        b = false;
    }else
    if(valDate(document.forms[0].date11)==false){
        b = false;
    }else
    if(valDate(document.forms[0].date12)==false){
        b = false;
    }else
    if(valDate(document.forms[0].collectionDate)==false){
        b = false;
    }
    return b;
}

function calcWeek(source) {

    var delta = 0;
    var str_date = getDateField(source.name);
    if (str_date.length < 10) return;
    var dd = str_date.substring(0, str_date.indexOf("/"));
    var mm = eval(str_date.substring(eval(str_date.indexOf("/")+1), str_date.lastIndexOf("/")) - 1);
    var yyyy  = str_date.substring(eval(str_date.lastIndexOf("/")+1));
    var check_date=new Date(yyyy,mm,dd);
    var start=new Date("December 25, 2003");

    if (check_date.getUTCHours() != start.getUTCHours()) {
        if (check_date.getUTCHours() > start.getUTCHours()) {
            delta = -1 * 60 * 60 * 1000;
        } else {
            delta = 1 * 60 * 60 * 1000;
        }
    }

    var day = eval((check_date.getTime() - start.getTime() + delta) / (24*60*60*1000));
    var week = Math.floor(day/7);
    var weekday = day%7;
    source.value = week + "w+" + weekday;

}

function getDateField(name) {
    var temp = "";
    var n1 = name.substring(eval(name.indexOf("t")+1));

    if (n1>17) {
        name = "pg3_date" + n1;
    } else {
        name = "pg2_date" + n1;
    }

    for (var i =0; i <document.forms[0].elements.length; i++) {
        if (document.forms[0].elements[i].name == name) {
            return document.forms[0].elements[i].value;
        }
    }
    return temp;
}
function calToday(field) {
    var calDate=new Date();
    field.value = calDate.getDate() + '/' + (calDate.getMonth()+1) + '/' + calDate.getFullYear();
}