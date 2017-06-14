var SmartPhone = {
    getUserAgent : function() {
        return navigator.userAgent;
    },
    isAndroid : function() {
        return this.getUserAgent().match(/Android/i);
    },
    isBlackBerry : function() {
        return this.getUserAgent().match(/BlackBerry/i);
    },
    isIOS : function() {
        return this.getUserAgent().match(/iPhone|iPad|iPod/i);
    },
    isOperaMini : function() {
        return this.getUserAgent().match(/Opera Mini/i);
    },
    isWindows : function() {
        return this.isWindowsDesktop() || this.isWindowsMobile();
    },
    isWindowsMobile : function() {
        return this.getUserAgent().match(/IEMobile/i);
    },
    isWindowsDesktop : function() {
        return this.getUserAgent().match(/WPDesktop/i);
        ;
    },
    isMobile : function() {
        return this.isAndroid() || this.isBlackBerry() || this.isIOS() || this.isWindowsMobile();
    },
    isAny : function() {
        var foundAny = false;
        var getAllMethods = Object.getOwnPropertyNames(SmartPhone).filter(function(property) {
            return typeof SmartPhone[property] == 'function';
        });

        for ( var index in getAllMethods) {
            if (getAllMethods[index] === 'getUserAgent' || getAllMethods[index] === 'isAny' || getAllMethods[index] === 'isWindows') {
                continue;
            }
            if (SmartPhone[getAllMethods[index]]()) {
                foundAny = true;
                break;
            }
        }
        return foundAny;
    }
};
//navlist
jQuery(document).ready(function(){
//	jQuery("#navlist").append("<li><a href=\"../eyeform/ConsultationReportList.do\">ConReport</a></li>");
	jQuery("<li><a href=\"#\" onclick=\"popupOscarRx(625,1024,'../eyeform/ConsultationReportList.do\');\" title\"View Consultation Reports\">ConReport</a></li>").insertAfter("#con");

    // Add KAI bar as appropriate
    addKAIBar();
    if (!SmartPhone.isMobile()) {
        addTableHeaderFloat();
    }
});

function addTableHeaderFloat() {
    if (jQuery('div#caseloadDiv').length) { //if on caseload screen
        var table = jQuery('div#caseloadDiv');
        var topPadding = jQuery('div.header-div').height();
        table.css('padding-top', (topPadding + 2) + 'px');
    } else if (typeof jQuery_3_1_0 != 'undefined' && jQuery_3_1_0().floatThead && jQuery('table#scheduleTable').length) { //if on schedule and floatThead enabled
        var table = jQuery_3_1_0('table#scheduleTable');
        var topPadding = jQuery_3_1_0('div.header-div').height();
        table.css('padding-top', (topPadding) + 'px');
        table.floatThead('destroy');
        table.floatThead({top: topPadding});
    }
}

function addKAIBar() {
    var kaiBarHTML = `<div class="KaiBar">
		<a href="http://www.kaiinnovations.com" target="_blank"><img alt="" src="../js/custom/kai/KAI_LOGO2_HR.png" height="18" width="18">&nbsp;&nbsp;KAI INNOVATIONS</a>
		<div class="block">
			Search:
			<input class="kaiInput" type="text" placeholder="Enter Health Card # or Demographic Name" id="kaiDemoSearch"/>
			<a href="" class="btnFlat" id='kaiDemoSearchButton'>
		    	<div class="green">
		            <span>Go</span>
		        </div>
		    </a>
		</div>
		<div class="block right">
			<a href="https://oscarsupport.zendesk.com/hc/en-us" class="btnFlat" target="_blank">
		    	<div class="green">
		            <span>Help Portal</span>
		        </div>
		    </a>
		    <a href="http://get.teamviewer.com/5gjkzuy" class="btnFlat" target="_blank">
		    	<div class="green">
		            <span>TeamViewer</span>
		        </div>
		    </a>
		</div>
	</div>`;

    jQuery('head').append('<link rel="stylesheet" href="../js/custom/kai/kai_bar.css" type="text/css" onload="addTableHeaderFloat()"/>');
    var kaiBar = jQuery(kaiBarHTML);
    kaiBar.insertAfter('table#firstTable');

    var kaiDemoSearchButton = jQuery('#kaiDemoSearchButton');
    kaiDemoSearchButton.click(kaiDemoSearch);
    var kaiDemoSearchField = jQuery('#kaiDemoSearch');
    kaiDemoSearchField.bind("enterKey",function(e){
        kaiDemoSearch();
    });
    kaiDemoSearchField.keyup(function(e){
        if(e.keyCode == 13) {
            kaiDemoSearchField.trigger("enterKey");
        }
    });
}
