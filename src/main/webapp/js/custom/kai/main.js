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
			<input class="kaiInput" type="text" placeholder="Enter Heath Card # or Demographic Name" id="kaiDemoSearch"/>
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
		    <a href="" class="btnFlat" target="_blank">
		    	<div class="green">
		            <span>TeamViewer</span>
		        </div>
		    </a>
		</div>
	</div>`
  
  jQuery('head').append('<link rel="stylesheet" href="/oscar/js/custom/kai/kai_bar.css" type="text/css" />');
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

function getUrlVars(url) {
  var vars = [], hash;
  if(url === undefined) {
    return null;
  }
  var hashes = url.toString().slice(url.toString().indexOf('?') + 1).split('&');
  for(var i = 0; i < hashes.length; i++) {
    hash = hashes[i].split('=');
    vars.push(hash[0]);
    vars[hash[0]] = hash[1];
  }
  return vars;
}

function resolveCurrentProvider() {
  // get the current provider
  var providerNumber = null;

  // check if pref is available
  if (jQuery("[title*='Edit your personal setting']").length && jQuery("[title*='Edit your personal setting']").attr('onclick').length) {
    var oldonclick = jQuery("[title*='Edit your personal setting']").attr('onclick');
    providerNumber = oldonclick.toString().match('(?:provider_no=)([^&]*)')[1];
  } else {
    providerNumber = getUrlVars(jQuery("a:contains('Caseload')").attr("href"))["clProv"];
  }
  return providerNumber;
}

function kaiDemoSearch() {
  var kaiDemoSearch = jQuery('#kaiDemoSearch');
  var searchString = kaiDemoSearch.val();
  var demoRegex = /^[A-Za-z].*$/;
  if( demoRegex.test(searchString) ) {
    var searchUrl = "/oscar/demographic/demographiccontrol.jsp?search_mode=search_name&keyword=" + encodeURIComponent(searchString) + "&orderby=last_name%2C+first_name&dboperation=search_titlename&limit1=0&limit2=10&displaymode=Search&ptstatus=active"
    popupPage2(searchUrl);
    kaiDemoSearch.val("");
  } else {
    // set the dimensions and open the popup window
    var left = (screen.width / 2) - (500 / 2);
    var top = (screen.height / 2) - (500 / 2);
    // path to your card swipe module webapp must be specified. add it in here
    var currentProvider = resolveCurrentProvider();
    var cardSwipeURL = "/CardSwipe/?hc=" + escape(searchString) + "&providerNo=" + escape(currentProvider);
    var newwindow = window.open(cardSwipeURL, "name",
    "location=no,scrollbars=1,width=500,height=500,top=" + top + ",left=" + left);

    // focus the window
    if (window.focus) {
      newwindow.focus();
    }

    var timer = setInterval(function() {
      if (newwindow.closed) {
        clearInterval(timer);
        window.location.reload();
      }
    }, 100);
  }
  
  return false;
}
