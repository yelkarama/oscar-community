const RxPrintComponent = {
  bindings: {
	  close: '&',
	  dismiss: '&',
	  resolve: '<',
  },
  templateUrl: '../web/record/rx/print/print.template.jsp',
  controller: ['$stateParams','$state','$uibModal','$log','rxService',function($stateParams,$state,$uibModal,$log,rxService) {
	  
	/*
	 Options on the print page:
	 -Print PDF with drop box for size.  //look at ViewScript2.jsp
	 -Print
	 -Print & Paste into EMR
	 -Create New Rx
	 
	  Add additional notes to rx  (Add to Rx)
	  
	  Signature spot.
	  
	 */  
	  
  	rxPrint = this;
  	
  	rxPrint.print = function(){
  		printIframe();
  	}
  	
  	rxPrint.$onInit = function(){
 		console.log("oninit print component",this);

 		rxPrint.printId = this.resolve.scriptId;
 		rxPrint.pharamacyId = null;
 		rxPrint.scriptURL = "../web/record/rx/print/PrintView.jsp?scriptId="+rxPrint.printId+"&rePrint=false&pharmacyId="+rxPrint.pharamacyId;
 		rxService.recordPrescriptionPrint(rxPrint.printId);
 	}
 	
 	
  	rxPrint.ok = function () {
  		console.log("ok");
  		rxPrint.close({$value: 'hi'});
    };

    rxPrint.cancel = function () {
    		console.log("cancel");
    		rxPrint.dismiss({$value: 'cancel'});
 	};
 	
 	rxPrint.defaultPageOption = "PageSize.A4";
 	rxPrint.pdfPageOptions = [{label:"A4 page", code:"PageSize.A4"},{label:"A6 page", code:"PageSize.A6"},{label:"Letter page", code:"PageSize.Letter"}];
 	
 	rxPrint.printPDF = function(pageOpt = null) {
 		console.log("angular.isDefined(this.resolve.reprint)",angular.isDefined(this.resolve.reprint),this.resolve);
 		if(angular.isDefined(this.resolve.reprint) && this.resolve.reprint){
 			onPrint2("rePrint", this.resolve.scriptId,pageOpt);
 		}else{
 			onPrint2("print", this.resolve.scriptId,pageOpt);
 		}
 	   
 	}
 		function onPrint2(method, scriptId,rxPageSize) {
 			
 			var useSC=false;
 	        var scAddress="";
 	        if(rxPageSize == null){
 	        		rxPageSize = rxPrint.defaultPageOption;
 	        }
 	        //var rxPageSize="PageSize.A4";  //$('printPageSize').value;
 	        //console.log("rxPagesize  "+rxPageSize);
 	        	

 	  /*<% if(vecAddressName != null) {
 	    %>
 	        useSC=true;
 	   <%      for(int i=0; i<vecAddressName.size(); i++) {%>
 		    if(document.getElementById("addressSel").value=="<%=i%>") {
 	    	       scAddress="<%=vecAddress.get(i)%>";
 	            }
 	<%       }
 	      }%>
 			*/
 	       
 	        console.log("preview window ",document.getElementById("preview").contentWindow.document);
 	              var action="../../../../form/createcustomedpdf?__title=Rx&__method=" +  method+"&useSC="+useSC+"&scAddress="+scAddress+"&rxPageSize="+rxPageSize+"&scriptId="+scriptId;
 	            document.getElementById("preview").contentWindow.document.getElementById("preview2Form").action = action;
 	            document.getElementById("preview").contentWindow.document.getElementById("preview2Form").target="_blank";
 	            document.getElementById("preview").contentWindow.document.getElementById("preview2Form").submit();
 	       return true;
 	    }
 	
 	
 	function printIframe(){
 	   var browserName=navigator.appName; 
 	   if (browserName=="Microsoft Internet Explorer"){
 	      try{ 
 		     iframe = document.getElementById('preview'); 
 		     iframe.contentWindow.document.execCommand('print', false, null); 
 		  }catch(e){ 
 		     window.print(); 
 		  } 
 	   }else{
          preview.focus();
 		  preview.print();
 	   }	
    }
 	
 	
 	
 	
 	} 
  ]
};





  