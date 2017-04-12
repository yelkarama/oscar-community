function handleDocSave(docid,action){
    var url=contextpath + "/dms/inboxManage.do";
    var data='method=isDocumentLinkedToDemographic&docId='+docid;
    new Ajax.Request(url, {method: 'post',parameters:data,onSuccess:function(transport){
        var json=transport.responseText.evalJSON();
        if(json!=null){
            var success=json.isLinkedToDemographic;
            var demoid='';

            if(success){
                if(action=='addTickler'){
                    demoid=json.demoId;
                    if(demoid!=null && demoid.length>0)
                        popupStart(450,600,contextpath + '/tickler/ForwardDemographicTickler.do?updateParent=false&docType=DOC&docId='+docid+'&demographic_no='+demoid,'tickler')
                }
            }
            else {
                alert("Make sure demographic is linked and document changes saved!");
            }
        }
    }});
}

function popupPatient(height, width, url, windowName, docId) {
    if(document.getElementById('demofind'+ docId)){
        d = document.getElementById('demofind'+ docId).value; //demog  //attachedDemoNo
    }
    else{
        //else HRM
        d = document.getElementById('demofind'+ docId + 'hrm').value; //demog  //attachedDemoNo
    }

	  urlNew = url + d;
	
	  return popup2(height, width, 0, 0, urlNew, windowName);
}

function popupPatientTickler(height, width, url, windowName,docId) {
    if(document.getElementById('demofind'+ docId)){
        d = document.getElementById('demofind'+ docId).value; //demog  //attachedDemoNo
        n = document.getElementById('demofindName' + docId).value;
    }
    else{
        // else HRM
        d = document.getElementById('demofind'+ docId + 'hrm').value; //demog  //attachedDemoNo
        n = document.getElementById('demofindName' + docId + 'hrm').value;
    }
  urlNew = url + "method=edit&tickler.demographic_webName=" + n + "&tickler.demographicNo=" +  d + "&docType=DOC&docId="+docId;
  	
  	  return popup2(height, width, 0, 0, urlNew, windowName);
}