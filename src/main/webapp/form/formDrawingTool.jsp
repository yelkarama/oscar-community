<%@ taglib uri="/WEB-INF/security.tld" prefix="security"%>
<%
    String roleName2$ = (String)session.getAttribute("userrole") + "," + (String) session.getAttribute("user");
    boolean authed=true;
%>
<security:oscarSec roleName="<%=roleName2$%>" objectName="_form" rights="r" reverse="<%=true%>">
	<%authed=false; %>
	<%response.sendRedirect("../securityError.jsp?type=_form");%>
</security:oscarSec>
<%
	if(!authed) {
		return;
	}
%>

<%@ page import="oscar.util.*, oscar.form.*, oscar.form.data.*"%>
<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean"%>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html"%>
<%@ taglib uri="/WEB-INF/struts-logic.tld" prefix="logic"%>
<%@page import="org.oscarehr.util.LoggedInInfo"%>
<%@ page import="java.util.List" %>
<%@ page import="org.oscarehr.util.SpringUtils" %>
<%@ page import="org.oscarehr.common.dao.FormDrawingImageToolDao" %>
<%@ page import="org.oscarehr.common.model.FormDrawingToolImage" %>
<%
	String formClass = "DrawingTool";
	String formLink = "formDrawingTool.jsp";

    int demoNo = Integer.parseInt(request.getParameter("demographic_no"));
    int formId = Integer.parseInt(request.getParameter("formId"));
	int provNo = Integer.parseInt((String) session.getAttribute("user"));
	FrmRecord rec = (new FrmRecordFactory()).factory(formClass);
    java.util.Properties formRecord = rec.getFormRecord(LoggedInInfo.getLoggedInInfoFromSession(request),demoNo, formId);
	FormDrawingImageToolDao formDrawingImageToolDao = SpringUtils.getBean(FormDrawingImageToolDao.class);
	List<FormDrawingToolImage> backgroundImages = formDrawingImageToolDao.findAll();
  	boolean bView = false;
  	if (request.getParameter("view") != null && request.getParameter("view").equals("1")) { bView = true; }
	String selectedBackground = formRecord.getProperty("image_id", "1");
%>
<html:html locale="true">
<head>
	<script type="text/javascript" src="<%=request.getContextPath()%>/js/global.js"></script>
	<script type="text/javascript" src="<%=request.getContextPath()%>/js/jquery-3.1.0.min.js"></script>
	<script type="text/javascript" src="<%=request.getContextPath()%>/js/jquery-ui-1.8.18.custom.min.js"></script>
	<script type="text/javascript" src="<%=request.getContextPath()%>/js/fabric.js"></script>
	<script type="text/javascript" src="<%=request.getContextPath() %>/library/bootstrap/3.0.0/js/bootstrap.js"></script>
	<link href="<%=request.getContextPath() %>/library/bootstrap/3.0.0/css/bootstrap.min.css" rel="stylesheet" type="text/css">
	<link href="<%=request.getContextPath() %>/js/jquery_css/smoothness/jquery-ui-1.7.3.custom.css" rel="stylesheet" type="text/css">
	<title>Drawing Tool</title>
<script src="<%=request.getContextPath()%>/JavaScriptServlet" type="text/javascript"></script>
	<style>
		#header {
			position:fixed;
			width: 100%;
			margin: 0; z-index: 1;
			padding: 5px;
			background-color: #53B848;
		}
		#brushPicker {
			position: fixed;
			right: 0;
			top: 43px;
			margin: 0;
			z-index: 2;
			padding: 5px;
			background-color: #53B848;
		}
		
		.brush-label {
			width: 36px;
			height: 36px;
			padding: 2px;
			display: flex;
			background-color: #EEEEEE;
			border-color: #CCCCCC;
		}
		.brush-circle {
			background-color: #000000;
			padding: 0;
			margin: auto;
		}
		.brush-circle-xs {
			width: 5px;
			height: 5px;
			border-radius: 3px;
		}
		.brush-circle-sm {
			width: 10px;
			height: 10px;
			border-radius: 5px;
		}
		.brush-circle-md {
			width: 15px;
			height: 15px;
			border-radius: 8px;
		}
		.brush-circle-lg {
			width: 20px;
			height: 20px;
			border-radius: 10px;
		}
		.brush-color {
			width: 80%;
			height: 80%;
			padding: 0;
			margin: auto;
			border-radius: 2px;
		}
		.brush-color-black {
			background-color: #000000 !important;
		}
		.brush-color-green {
			background-color: #27d642 !important;
		}
		.brush-color-red {
			background-color: #FF0000 !important;
		}
		.brush-color-yellow {
			background-color: #FFFF00 !important;
		}
		.brush-color-blue {
			background-color: #0000FF !important;
		}
	</style>
<html:base />
</head>
<body class="container-fluid" style="background-color: #f5f5f6; " onLoad="setfocus(); onLoad();">
<html:form action="/form/formname">
	<div id="header" class="row well-sm hidden-print">
		<div class="col-sm-4">
			<input type="hidden" name="demographic_no" value="<%= formRecord.getProperty("demographic_no", "0") %>" />
			<input type="hidden" name="formCreated" value="<%= formRecord.getProperty("formCreated", "") %>" />
			<input type="hidden" name="form_class" value="<%=formClass%>" />
			<input type="hidden" name="form_link" value="<%=formLink%>" />
			<input type="hidden" name="formId" value="<%=formId%>" />
			<input type="hidden" name="submit" value="exit" />
			<% if (!bView) { %>
				<input class="btn btn-default" type="submit" value="Save and Exit" onclick="return onSaveExit();" /> 
			<% } %> 
			<input class="btn btn-default" type="submit" value="Exit" onclick="return onExit();" />
			<input class="btn btn-default" type="button" value="Print" onclick="window.print();" />
		</div>
		<% if (!bView) { %>
		<div class="col-sm-8 pull-right">
			<div class="pull-right">
				<input class="btn btn-default" type="button" onclick="ClearCanvas(); return false;" name="drawing-clear" value="Clear"/>
				<input class="btn btn-default" type="button" onclick="Undo(); return false;" name="drawing-undo" value="Undo"/>
				<label>Brush:</label>
				<a class="btn-group" id="brushStatus" data-toggle="popover" data-popover-content="#brushPicker" data-trigger="click" data-placement="bottom">
					<div class="btn btn-default brush-label">
						<div class="brush-label brush-circle brush-circle-xs brush-color-black"></div>
					</div>
				</a>
				<label style="display: inline-block;">
					Background:
					<select name="imageSelection" id="imageSelection" onchange="changeImageBackground()">
						<% for (FormDrawingToolImage backgroundImage : backgroundImages) { %>
						<option value='<%=backgroundImage.toJsonString()%>' 
								<%=(selectedBackground.equals(String.valueOf(backgroundImage.getId()))?"selected=\"selected\"":"")%>
								<%=backgroundImage.fileExists()?"":"disabled"%>>
							<%=backgroundImage.getName()%> <%=backgroundImage.fileExists()?"":" (File Missing)"%>
						</option>
						<% } %>
					</select>
				</label>
			</div>
		</div>
		<% } %>
	</div>
	<div id="brushPicker" class="popover fade bottom in">
		<div class="popover-body">
			<label>Brush Colour:</label><br/>
			<div class="btn-group" data-toggle="buttons">
				<label class="btn brush-label active">
					<div class="brush-color brush-color-black"></div>
					<input type="radio" value='{ "name": "black", "color": "#000000" }' onchange="setBrushColor(this.value);" checked>
				</label>
				<label class="btn brush-label">
					<div class="brush-color brush-color-green"></div>
					<input type="radio" value='{ "name": "green", "color": "#27d642" }' onchange="setBrushColor(this.value);">
				</label>
				<label class="btn brush-label">
					<div class="brush-color brush-color-red"></div>
					<input type="radio" value='{ "name": "red", "color": "#FF0000" }' onchange="setBrushColor(this.value);">
				</label>
				<label class="btn brush-label">
					<div class="brush-color brush-color-yellow"></div>
					<input type="radio" value='{ "name": "yellow", "color": "#FFFF00" }' onchange="setBrushColor(this.value);">
				</label>
				<label class="btn brush-label">
					<div class="brush-color brush-color-blue"></div>
					<input type="radio" value='{ "name": "blue", "color": "#0000FF" }' onchange="setBrushColor(this.value);">
				</label>
			</div><br/>
			<label>Brush Size:</label><br/>
			<div class="btn-group" data-toggle="buttons">
				<label class="btn brush-label active">
					<div class="brush-circle brush-circle-xs"></div>
					<input type="radio" name="brush_size" value='{ "name": "xs", "size": "5" }' onchange="setBrushSize(this.value);" checked>
				</label>
				<label class="btn brush-label">
					<div class="brush-circle brush-circle-sm"></div>
					<input type="radio" name="brush_size" value='{ "name": "sm", "size": "10" }' onchange="setBrushSize(this.value);">
				</label>
				<label class="btn brush-label">
					<div class="brush-circle brush-circle-md"></div>
					<input type="radio" name="brush_size" value='{ "name": "md", "size": "15" }' onchange="setBrushSize(this.value);">
				</label>
				<label class="btn brush-label">
					<div class="brush-circle brush-circle-lg"></div>
					<input type="radio" name="brush_size" value='{ "name": "lg", "size": "20" }' onchange="setBrushSize(this.value);">
				</label>
			</div>
		</div>
	</div>

	<div id="main" class="row" style="position: absolute; width: 100%; margin: 0; padding: 20px; top: 42px; text-align: center;">
		<div id="canvas-container" style=" height: auto; display: inline-block">
			<input type="hidden" id="image_id" name="image_id" value="<%=selectedBackground%>">
			<canvas id="drawingCanvas" style="touch-action: none; border: solid 2px; height: auto; width: 100%;"></canvas>
			<input type="hidden" id="drawing_json" name="drawing_json" value='<%=formRecord.getProperty("drawing_json", "")%>'>
		</div>
	</div>
	<script type="text/javascript">
		$("[data-toggle=popover]").popover({
			html : true,
			content: function() {
				var content = $(this).attr("data-popover-content");
				return $(content).children(".popover-body").html();
			},
			title: function() {
				var title = $(this).attr("data-popover-content");
				return $(title).children(".popover-heading").html();
			}
		});
		
		var drawingCanvas = new fabric.Canvas('drawingCanvas', { isDrawingMode: true });
		document.getElementById('drawingCanvas').fabric = drawingCanvas;
		
		var backgroundImage = new Image();
		changeImageBackground();
		
		var drawingJsonText = $('#drawing_json');
		if (drawingJsonText.val() != "") {
			var drawingJson = JSON.parse(drawingJsonText.val());
			if (drawingJson.backgroundImage != null) {
				setCanvasSize(drawingJson.backgroundImage.width, drawingJson.backgroundImage.height);
			} else {
				setCanvasSize(612, 792);
			}
			drawingCanvas.loadFromJSON(drawingJson, function(){drawingCanvas.renderAll()});
		}
		
		if (drawingCanvas.freeDrawingBrush) {
			drawingCanvas.freeDrawingBrush.color = '#000000';
			drawingCanvas.freeDrawingBrush.width = 5;
			drawingCanvas.freeDrawingBrush.shadowBlur = 0;
		}
		
		//Undo: remove last line and reload load new json
		function Undo() {
			var json = drawingCanvas.toJSON();
			json.objects.splice(-1,1);
			drawingCanvas.loadFromJSON(json);
		}

		//Clear the canvas and set the image
		function ClearCanvas() {
			var bk = drawingCanvas.backgroundImage;
			drawingCanvas.clear();
			drawingCanvas.backgroundImage = bk;
			drawingCanvas.renderAll();
		}

		//Set the brush color
		function setBrushColor(colorString) {
			var colorJson = JSON.parse(colorString);
			var colorHex = colorJson.color;
			if (colorHex.substring(0, 1) == '#') { colorHex = colorHex.substring(1); }
			drawingCanvas.freeDrawingBrush.color = '#' + colorHex;
			$('#brushStatus .brush-circle').removeClass('brush-color-black brush-color-green brush-color-red brush-color-yellow brush-color-blue');
			$('#brushStatus .brush-circle').addClass('brush-color-' + colorJson.name);
		}
		//Set the brush size
		function setBrushSize(sizeString) {
			var sizeJson = JSON.parse(sizeString);
			drawingCanvas.freeDrawingBrush.width = parseInt(sizeJson.size);
			$('#brushStatus .brush-circle').removeClass('brush-circle-xs brush-circle-sm brush-circle-md brush-circle-lg');
			$('#brushStatus .brush-circle').addClass('brush-circle-' + sizeJson.name);
		}

		function setCanvasSize(width, height) {
			drawingCanvas.setWidth(width);
			drawingCanvas.setHeight(height);
		}
		
		function setCanvasBackgroundImage(newImage) {
			if (newImage) {
				backgroundImage.src = newImage;
				backgroundImage.alt = 'Background image';
				//Set convas size when image finishes loading
				backgroundImage.onload = function() {
					drawingCanvas.setWidth(this.width);
					drawingCanvas.setHeight(this.height);
					drawingCanvas.setBackgroundImage(this.src, onBackgroundImageLoad.bind(), {
						originX: 'left', originY: 'top'}
					);
				};
			}
		}

		function changeImageBackground() {
			var selectedImage = JSON.parse($('#imageSelection').val());
			var imageContextUrl = '<%=request.getContextPath()%>'+'/eform/displayImage.do?drawingFormImage=true&imagefile=';
			setCanvasBackgroundImage(imageContextUrl + selectedImage.image_name);
			$('#image_id').val(selectedImage.image_id);
		}
		
		function onSave() {
			var canvasToSave = new fabric.Canvas();
			canvasToSave.loadFromJSON(JSON.stringify(drawingCanvas), function(){canvasToSave.renderAll()});
			canvasToSave.backgroundImage = null;
			$('#drawing_json').val(JSON.stringify(canvasToSave.toJSON()));
		}

		function onSaveExit() {
			onSave();
		}
		
		function onLoad() {
			document.getElementById('main').style.top = document.getElementById('header').clientHeight + 'px';
			var main = $('#main');
			//main.height(main.height() - document.getElementById('header').clientHeight);
			document.getElementById('brushPicker').style.top = document.getElementById('header').clientHeight + 'px';
		}

		function onBackgroundImageLoad() {
			drawingCanvas.renderAll.bind(drawingCanvas);
			//scaleCanvas();
			drawingCanvas.renderAll();
		}
		
		function scaleCanvas() {
			var main = $('#main');
			var mainContainerWidth = main.width() - 20;
			var mainContainerHeight = main.height();
			var ratio = mainContainerWidth / drawingCanvas.getWidth();
			if (ratio * drawingCanvas.getHeight() > mainContainerHeight) {
				ratio = mainContainerHeight / drawingCanvas.getHeight();
				zoomIt(ratio);
			} else {
				zoomIt(ratio);
			}
		}
		
		function zoomIt(factor) {
			drawingCanvas.setHeight(drawingCanvas.getHeight() * factor);
			drawingCanvas.setWidth(drawingCanvas.getWidth() * factor);
			if (drawingCanvas.backgroundImage) {
				// Need to scale background images as well
				var bi = drawingCanvas.backgroundImage;
				bi.width = bi.width * factor; 
				bi.height = bi.height * factor;
			}
			var objects = drawingCanvas.getObjects();
			for (var i in objects) {
				var scaleX = objects[i].scaleX;
				var scaleY = objects[i].scaleY;
				var left = objects[i].left;
				var top = objects[i].top;

				var tempScaleX = scaleX * factor;
				var tempScaleY = scaleY * factor;
				var tempLeft = left * factor;
				var tempTop = top * factor;

				objects[i].scaleX = tempScaleX;
				objects[i].scaleY = tempScaleY;
				objects[i].left = tempLeft;
				objects[i].top = tempTop;

				objects[i].setCoords();
			}
			drawingCanvas.renderAll();
			drawingCanvas.calcOffset();
		}
		
		var BackgroundImage = fabric.util.createClass(fabric.Image, {
			originX: 'left', 
			originY: 'top',
			initialize: function(src, options) {
				this.callSuper('initialize', options);
				this.image = new Image();
				this.image.src = src;
				this.image.onload = (function() {
					this.width = this.image.width;
					this.height = this.image.height;
					this.loaded = true;
					this.setCoords();
					this.fire('image:loaded');
				}).bind(this);
			}
		});
	</script>
</html:form>
</body>
</html:html>
