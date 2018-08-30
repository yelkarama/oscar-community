;(function(global){
    var pdfFormat = {
        'a0': [2383.94, 3370.39],
        'a1': [1683.78, 2383.94],
        'a2': [1190.55, 1683.78],
        'a3': [841.89, 1190.55],
        'a4': [595.28, 841.89],
        'a5': [419.53, 595.28],
        'a6': [297.64, 419.53],
        'a7': [209.76, 297.64],
        'a8': [147.40, 209.76],
        'a9': [104.88, 147.40],
        'a10': [73.70, 104.88],
        'b0': [2834.65, 4008.19],
        'b1': [2004.09, 2834.65],
        'b2': [1417.32, 2004.09],
        'b3': [1000.63, 1417.32],
        'b4': [708.66, 1000.63],
        'b5': [498.90, 708.66],
        'b6': [354.33, 498.90],
        'b7': [249.45, 354.33],
        'b8': [175.75, 249.45],
        'b9': [124.72, 175.75],
        'b10': [87.87, 124.72],
        'c0': [2599.37, 3676.54],
        'c1': [1836.85, 2599.37],
        'c2': [1298.27, 1836.85],
        'c3': [918.43, 1298.27],
        'c4': [649.13, 918.43],
        'c5': [459.21, 649.13],
        'c6': [323.15, 459.21],
        'c7': [229.61, 323.15],
        'c8': [161.57, 229.61],
        'c9': [113.39, 161.57],
        'c10': [79.37, 113.39],
        'dl': [311.81, 623.62],
        'letter': [612, 792],
        'government-letter': [576, 756],
        'legal': [612, 1008],
        'junior-legal': [576, 360],
        'ledger': [1224, 792],
        'tabloid': [792, 1224]
    };
    
    global.generatePDF = function(nodes, format, width, height, filename, isFax, onSuccess) {
    	var x, y, w, h;
        var pdf = new jsPDF({ orientation: 'p', unit: 'pt', format: 'a4' });
        if (pdfFormat[format][0]/pdfFormat[format][1] < width/height){
    		w = pdfFormat[format][0];
    		h = height * w/width;
    		x = 0;
    		y = 0;
    	} else {
    		h = pdfFormat[format][1];
    		w = width * h/height;
    		x = (pdfFormat[format][0] - w)/2;
    		y = 0;
    	}
        for(var i = 0;i < nodes.length;i ++){
        	jQuery(nodes[i]).css("background-color","#fff");
        	jQuery(nodes[i]).css("border","0");
    	}
        var setPdfWidth = x + 10;
        var setPdfHeight = y - 5.6;
        if(null != saveSig && saveSig == "isformConsultant"){
        	setPdfWidth = x + 1.5;
        	setPdfHeight= y + 15;
        }
        Promise.all(nodes.map(domtoimage.toJpeg)).then(function(images){
        	images.forEach(function(image, index){
    	    	if (index !== 0){ 
    	    		pdf.addPage();
    	    	}
    	    	pdf.addImage(image, 'JPEG', setPdfWidth, setPdfHeight, w, h);
        	});
        	if(isFax == 0){
        		pdf.save(filename);
        		
        		onSuccess && onSuccess();
        	}else if(isFax == 2) {
        		var imgFile = pdf.output('arraybuffer','');
  		   	    imgFile =Array.from(new Uint8Array(imgFile)).toString();
        		jQuery.ajax({
       				type: "POST", 
					contentType:"multipart/form-data",
					url: "../eform/saveHtmlData.do?method=configOscarPdf", 
					data: imgFile, 
					async: false,
					success: function(data) {  
       			    	data=JSON.parse(data);
       			    	onSuccess && onSuccess(data.existfilename);
       			 	},
       			 	error: function() {
       			 		alert("An error occured while attempting to send your fax, please contact an administrator.");
       			 	}
        		});
        	} else{
        		var isLetterhead = "0";
        		if(null != saveSig && saveSig == "isformConsultant"){
        			isLetterhead = "1";
        		}
        		var imgFile = pdf.output('arraybuffer','');
  		   	    imgFile =Array.from(new Uint8Array(imgFile)).toString();
        		jQuery.ajax({
       				type: "POST", 
					contentType:"multipart/form-data",
					url: "../eform/saveHtmlData.do?method=uploadOscarPdf&isLetterhead=" + isLetterhead, 
					data: imgFile, 
					async: false,
					success: function(data) {  
       			    	data=JSON.parse(data);
       			    	
       			    	onSuccess && onSuccess(data.existfilename);
       			 	},
       			 	error: function() {
       			 		alert("An error occured while attempting to send your fax, please contact an administrator.");
       			 	}
        		});
        	}
        }).catch(function (error) {
        		console.error('oops, something went wrong!', error);
        });
    }
})(window);