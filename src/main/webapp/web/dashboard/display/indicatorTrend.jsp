<%--

    Copyright (c) 2001-2002. Department of Family Medicine, McMaster University. All Rights Reserved.
    This software is published under the GPL GNU General Public License.
    This program is free software; you can redistribute it and/or
    modify it under the terms of the GNU General Public License
    as published by the Free Software Foundation; either version 2
    of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.

    This software was written for the
    Department of Family Medicine
    McMaster University
    Hamilton
    Ontario, Canada

--%>
<%@page import="org.oscarehr.common.model.IndicatorTemplate"%>
<%@page import="org.oscarehr.common.dao.IndicatorTemplateDao"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="org.oscarehr.common.model.IndicatorResultItem"%>
<%@page import="org.oscarehr.util.MiscUtils"%>
<%@page import="java.util.List"%>
<%@page import="org.oscarehr.util.SpringUtils"%>
<%@page import="org.oscarehr.common.dao.IndicatorResultItemDao"%>
<html lang="" >
<head>
	<meta charset="utf-8">
	<meta http-equiv="X-UA-Compatible" content="IE=edge">
	<meta name="viewport" content="width=device-width, initial-scale=1">
<title>
	OMD Clinical Care Dashboard
</title>
	<link rel="stylesheet" type="text/css" href="/oscar_dashboard/library/bootstrap/3.0.0/css/bootstrap.min.css" />
	<link rel="stylesheet" type="text/css" href="/oscar_dashboard/web/css/Dashboard.css" />
	<link rel="stylesheet" type="text/css" href="/oscar_dashboard/js/jqplot/jquery.jqplot2.min.css" />
	<script>var ctx = "/oscar_dashboard"</script>
	<script type="text/javascript" src="/oscar_dashboard/js/jquery-1.9.1.min.js"></script>		
	<script type="text/javascript" src="/oscar_dashboard/library/bootstrap/3.0.0/js/bootstrap.min.js" ></script>	
	<script type="text/javascript" src="/oscar_dashboard/web/dashboard/display/dashboardDisplayController.js?rand=7852" ></script>
	<script type="text/javascript" src="/oscar_dashboard/js/jqplot/jquery.jqplot2.min.js" ></script>
	<script type="text/javascript" src="/oscar_dashboard/js/jqplot/plugins/jqplot.pieRenderer.js" ></script>
	<script type="text/javascript" src="/oscar_dashboard/js/jqplot/plugins/jqplot.json2.js" ></script>
	<script type="text/javascript" src="/oscar_dashboard/js/jqplot/jqplot.dateAxisRenderer.min.js" ></script>
	
	<%
		String providerNo = request.getParameter("providerNo");
		String indicatorTemplateId = request.getParameter("indicatorTemplateId");
		
		IndicatorResultItemDao indicatorResultItemDao = SpringUtils.getBean(IndicatorResultItemDao.class);
		IndicatorTemplateDao indicatorTemplateDao = SpringUtils.getBean(IndicatorTemplateDao.class);
		
		
		IndicatorTemplate indicatorTemplate = indicatorTemplateDao.find(Integer.parseInt(indicatorTemplateId));
	
	%>
	<script language=javascript type="text/javascript">
                $(document).ready(function() {
                	
                	var data = new Array();
                	
                	<%
                	List<String> labels = indicatorResultItemDao.findLabels(Integer.parseInt(indicatorTemplateId));
                	int x=0;
                	SimpleDateFormat fmt = new SimpleDateFormat("yyyy-MM-dd HH:mm");
            		for(String label:labels) {
            			MiscUtils.getLogger().info("label=" + label);
            			%>
                		var d<%=x%> = new Array();
                		<%
            			
            			List<IndicatorResultItem> items = indicatorResultItemDao.findItemsByProviderNoAndLabelAndIndicatorTemplateId(providerNo,label,  Integer.parseInt(indicatorTemplateId));
            				for(IndicatorResultItem item:items) {
            			%>
            					d<%=x%>.push(['<%=fmt.format(item.getTimeGenerated())%>',<%=item.getResult()%>]);
            			<%
            				}
            			
            			%>
            				data.push(d<%=x%>);
            			<%
            			x++;
            		}
                	%>
                	
                	var plot1 = $.jqplot ('chart1', data,{
                		title:'<%=indicatorTemplate.getName()%>',
                		  axes:{
	                		xaxis:{
	                		    renderer:$.jqplot.DateAxisRenderer,
	                		    label: 'Date'
	                		  },
	                		  yaxis:{
	                		        label: 'Result',
	                		      },
                		  }
                	});
                });
    </script>
	</head>
	
	<body>
		 <div id="chart1" style="height:400px;width:800px; "></div>
		
	</body>
	
</html>
