function popupPatient(height, width, url, windowName, docId, inTabs) {
      height      = typeof(height)    != 'undefined' ? height : '700px';
      width       = typeof(width)     != 'undefined' ? width : '1024px';
      url         = typeof(url)       != 'undefined' ? url : '';
      windowName  = typeof(windowName)!= 'undefined' ? windowName : 'demoEdit';
      docId       = typeof(docId)     != 'undefined' ? docId : '0';
      inTabs      = typeof(inTabs)    != 'undefined' ? inTabs : false;
	  d = document.getElementById('demofind'+ docId).value; //demog  //attachedDemoNo
	  urlNew = url + d;
      if (inTabs) {
	        return window.open(urlNew, windowName);
        } else {
	        return popup2(height, width, 0, 0, urlNew, windowName);
      }
}

function popupPatientTicklerPlus(height, width, url, windowName, docId, inTabs) {
      height      = typeof(height)    != 'undefined' ? height : '700px';
      width       = typeof(width)     != 'undefined' ? width : '1024px';
      url         = typeof(url)       != 'undefined' ? url : '';
      windowName  = typeof(windowName)!= 'undefined' ? windowName : 'demoEdit';
      docId       = typeof(docId)     != 'undefined' ? docId : '0';
      inTabs      = typeof(inTabs)    != 'undefined' ? inTabs : false;
      d = document.getElementById('demofind'+ docId).value; //demog  //attachedDemoNo
      n = document.getElementById('demofindName' + docId).value;
      urlNew = url + "method=edit&tickler.demographic_webName=" + n + "&tickler.demographicNo=" +  d + "&docType=DOC&docId="+docId;
      if (inTabs) {
	        return window.open(urlNew, windowName);
        } else {
	        return popup2(height, width, 0, 0, urlNew, windowName);
      }
}

function popupPatientTickler(height, width, url, windowName, docId, inTabs) {
      height      = typeof(height)    != 'undefined' ? height : '700px';
      width       = typeof(width)     != 'undefined' ? width : '1024px';
      url         = typeof(url)       != 'undefined' ? url : '';
      windowName  = typeof(windowName)!= 'undefined' ? windowName : 'demoEdit';
      docId       = typeof(docId)     != 'undefined' ? docId : '0';
      inTabs      = typeof(inTabs)    != 'undefined' ? inTabs : false;
	  d = document.getElementById('demofind'+ docId).value; //demog  //attachedDemoNo
	  n = document.getElementById('demofindName' + docId).value;
	  urlNew = url + "demographic_no="+d+"&name="+n+"&chart_no=&bFirstDisp=false&messageID=null&remoteFacilityId=&docType=DOC&docId="+docId;
      if (inTabs) {
	        return window.open(urlNew, windowName);
        } else {
	        return popup2(height, width, 0, 0, urlNew, windowName);
      }
}

