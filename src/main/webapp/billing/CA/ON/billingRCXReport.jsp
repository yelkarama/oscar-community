<%--

    Copyright (c) 2008-2012 Indivica Inc.
    
    This software is made available under the terms of the
    GNU General Public License, Version 2, 1991 (GPLv2).
    License details are available via "indivica.ca/gplv2"
    and "gnu.org/licenses/gpl-2.0.html".
    
--%>
<%@page import="org.apache.commons.lang.StringEscapeUtils"%>
<%@ page language="java"%>
<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean"%>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html"%>
<%@ taglib uri="/WEB-INF/struts-logic.tld" prefix="logic"%>
<%@ page import="java.util.*,oscar.*,java.io.*,java.net.*,oscar.util.*" errorPage="errorpage.jsp"%>
<%@ page import="org.springframework.web.util.JavaScriptUtils" %>
<jsp:useBean id="oscarVariables" class="java.util.Properties" scope="session" />

<html:html locale="true">
    <head>
        <script type="text/javascript" src="<%=request.getContextPath()%>/js/global.js"></script>
        <script type="text/javascript" src="<%= request.getContextPath() %>/share/javascript/jquery/jquery-1.4.2.js"></script>
        <title>MOH Report</title>
<script src="<%=request.getContextPath()%>/JavaScriptServlet" type="text/javascript"></script>
        <link rel="stylesheet" type="text/css" href="<%=request.getContextPath()%>/library/bootstrap/3.0.0/css/bootstrap-glyphicons-only.min.css">
        <link rel="stylesheet" href="<%=request.getContextPath()%>/billing.css" >
        <link rel="stylesheet" type="text/css" media="all" href="<%=request.getContextPath()%>/share/css/extractedFromPages.css" />

        <%
            String filename = (String)request.getAttribute("filename");
            if (filename == null) {
                filename = StringUtils.noNull(request.getParameter("filename"));
            }
            
            String groupNo = StringUtils.noNull((String)request.getAttribute("groupNo"));
            String providerBillNo =  StringUtils.noNull((String)request.getAttribute("providerBillNo"));
            String providerName =  StringUtils.noNull((String)request.getAttribute("providerName"));
            String reportDate =  StringUtils.noNull((String)request.getAttribute("reportDate"));
            
            String fileContents = StringUtils.noNull((String)request.getAttribute("fileContents"));
        %>

        <script>
            <!--
            
            function buildDemographicRow(demographic, isMissing) {
                let row = "";
                let demoNo = "0";
                if (demographic != null) {
                    row = jQuery("<tr></tr>");
                    
                    // last value is demographicNo
                    demoNo = demographic.value[demographic.value.length - 1].value;
                    // loop through all values except last one
                    for (let i = 0; i < demographic.value.length - 1; i++) {
                        if (i === 0) {
                            // display HIN as a link
                            let url = '<%=request.getContextPath()%>/demographic/demographiccontrol.jsp?demographic_no='+demoNo+'&displaymode=edit&dboperation=search_detail';
                            if (isMissing) {
                                url = '<%=request.getContextPath()%>/demographic/demographicaddarecordhtm.jsp?search_mode=search_name&keyword='+demographic.value[5].value;
                            }
                            row.append(
                                jQuery("<td></td>").append(
                                    jQuery("<a />").text(demographic.value[i].value)
                                        .attr("title", "Master Demographic File")
                                        .attr("href", "javascript:void(0)")
                                        .attr("onClick", "popup(700,1027,'"+url+"')")
                                )
                            );
                        } else if (demographic.value[i] !== null && (demographic.value[i].value === "true" || demographic.value[i].value === "false")) {
                            // display check if demographic successfully updated
                            // display x if demographic failed to update
                            let successfullyUpdated = demographic.value[i].value === "true";

                            row.append(
                                jQuery("<td></td>").append(
                                    jQuery("<span></span>").attr("class", successfullyUpdated ? "glyphicon glyphicon-ok" : "glyphicon glyphicon-remove")
                                        .attr("style", successfullyUpdated ? "color:green" : "color:red")
                                )
                                    .attr("style", "text-align: center;")
                                    .attr("title", successfullyUpdated ? "Automatically Updated Demographic" : "Error Automatically Updating Demographic")
                            );
                        } else {
                            // display value
                            row.append(
                                jQuery("<td></td>").text(demographic.value[i] != null ? demographic.value[i].value : '')
                            );
                        }
                    }
                }
                return row;
            }
            
            function loadXMLDoc(xmldoc) {
                if (window.XMLHttpRequest) {
                    // Support for IE7, Firefox and Safari only 
                    xhttp=new XMLHttpRequest();
                } else if (window.ActiveXObject) {
                    // for IE5, IE6 
                    xhttp=new ActiveXObject("Microsoft.XMLHTTP");
                }
                xhttp.open("GET",xmldoc,false);
                xhttp.send("");

                return xhttp.responseXML;
            }

            function displayReport() {
                var cpath="<%=request.getContextPath()%>";
                var fname = "<%=filename%>";
                sname= cpath + "/billing/CA/ON/RCX.xsl";
                
                xml='<%=StringEscapeUtils.escapeJavaScript(fileContents)%>';
                try {
                    xsl=loadXMLDoc(sname);

                } catch(err) {
                    txt="Cannot load XSL document.\n";
                    txt+="xsl doc="+sname+"\n";
                    txt+="Error description: " + err.description;
                    alert(txt);
                    return;
                }

                var xmlDoc = null;

                if (navigator.appName == 'Microsoft Internet Explorer') {
                    xmlDoc = new ActiveXObject("Microsoft.XMLDOM");
                    xmlDoc.async = false;
                    xmlDoc.loadXML(xml);
                } else if (window.DOMParser) {
                    parser = new DOMParser();
                    xmlDoc = parser.parseFromString(xml, "text/xml");
                } else {
                    alert("Your browser doesn't suppoprt XML parsing!");
                }

                // code for Mozilla, Firefox, Opera
                if (document.implementation && document.implementation.createDocument) {
                    
                    xsltProcessor=new XSLTProcessor();
                    xsltProcessor.setParameter(null,"groupNo", '<%=groupNo%>');
                    xsltProcessor.setParameter(null,"providerBillNo", '<%=providerBillNo%>');
                    xsltProcessor.setParameter(null,"providerName", '<%=JavaScriptUtils.javaScriptEscape(providerName)%>');
                    xsltProcessor.setParameter(null,"reportDate", '<%=reportDate%>');
                    xsltProcessor.importStylesheet(xsl);
                    resultDocument = xsltProcessor.transformToFragment(xmlDoc,document);
                    
                    jQuery("#MOHreport").html(resultDocument);
                    
                    jQuery.ajax({
                        async:false,
                        method: 'get',
                        url: "<%=request.getContextPath()%>/oscarBilling/BillingClaimsRCX.do?method=generateRCXDemographics",
                        data: {filename:'<%=filename%>', reportDate: '<%=reportDate%>'},
                        success: function(data) {
                            if (data != null && data.sortedDemographics != null) {
                                let rows = [];
                                for (let list in data.sortedDemographics) {
                                    rows = [];
                                    for (let i = 0; i < data.sortedDemographics[list].length; i++) {
                                        jQuery("#"+list).append((buildDemographicRow(data.sortedDemographics[list][i], list === "missing")));
                                    }
                                }
                            }
                        },
                        error: function(data) {
                            console.error(data);
                        }
                    });
                    
                } else {
                    alert("Viewing report is not supported by this Browser.");
                }

            }

            function popup(vheight, vwidth, varpage) {
                var page = varpage;
                windowprops = "height="
                    + vheight
                    + ",width="
                    + vwidth
                    + ",location=no,scrollbars=yes,menubars=no,toolbars=no,resizable=yes,screenX=0,screenY=0,top=0,left=0";
                var popup = window.open(varpage, "<bean:message key="global.oscarRx"/>_________________$tag________________________________demosearch",	windowprops);
                if (popup != null) {
                    if (popup.opener == null) {
                        popup.opener = self;
                    }
                    popup.focus();
                }
            }
            // -->
        </script>

        <style>
            @media print {
                .noprint {display:none !important;}
            }
        </style>
    </head>

    <body onload="displayReport()">
    <table width="100%" border="0" cellspacing="0" cellpadding="0" class="noprint">
        <tr>
            <td height="40" width="10%" class="Header">
                <font size="3">Billing</font>
            </td>
            <td width="90%" align="right" class="Header">
                <input type="button" name="print" value="<bean:message key="global.btnPrint"/>"	onClick="window.print()">
            </td>
        </tr>
    </table>
    <div id="MOHreport"></div>

    </body>
</html:html>

