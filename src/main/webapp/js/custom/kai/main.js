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

  if (!SmartPhone.isMobile()) {
    addKAIBar();
  }
});


function addKAIBar() {
  var kaiBarHTML = `<div class="KaiBar">
		<a href="http://www.kaiinnovations.com" target="_blank"><img alt="" src="/oscar/js/custom/kai/KAI_LOGO2_HR.png" height="18" width="18">&nbsp;&nbsp;KAI INNOVATIONS</a>
		<div class="block">
			Search:
			<input class="kaiInput" type="text" placeholder="Ender Heath Card # or Demographic Name"/>
			<a href="" class="btnFlat">
		    	<div class="white">
		            <span>Go</span>
		        </div>
		    </a>
		</div>
		<div class="block right">
			<a href="" class="btnFlat">
		    	<div class="green">
		            <span>Help Portal</span>
		        </div>
		    </a>
		    <a href="" class="btnFlat">
		    	<div class="green">
		            <span>TeamViewer</span>
		        </div>
		    </a>
		</div>
	</div>`
  
  jQuery('head').append('<link rel="stylesheet" href="/oscar/js/custom/kai/kai_bar.css" type="text/css" />');
  var kaiBar = jQuery(kaiBarHTML);
  kaiBar.insertAfter('table#firstTable');
  



}
