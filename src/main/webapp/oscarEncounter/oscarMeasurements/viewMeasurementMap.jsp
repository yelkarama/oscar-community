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

<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean"%>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html"%>
<%@ taglib uri="/WEB-INF/struts-logic.tld" prefix="logic"%>
<%@ page
	import="java.util.*, oscar.oscarEncounter.oscarMeasurements.data.MeasurementMapConfig, oscar.OscarProperties, oscar.util.StringUtils"%>

<%

%>

<link rel="stylesheet" type="text/css"
	href="../../oscarMDS/encounterStyles.css">

<html>
<head>
<script type="text/javascript" src="<%= request.getContextPath() %>/js/global.js"></script>
<title>Measurement Mapping Configuration</title>

<script type="text/javascript" language=javascript>

            function newWindow(varpage, windowname){
                var page = varpage;
                windowprops = "fullscreen=yes,toolbar=yes,directories=no,resizable=yes,dependent=yes,scrollbars=yes,location=yes,status=yes,menubar=yes";
                var popup=window.open(varpage, windowname, windowprops);
            }

            function addLoinc(){
                var loinc_code = document.LOINC.loinc_code.value;
                var name = document.LOINC.name.value;

                if (loinc_code.length > 0 && name.length > 0){
                    if (modCheck(loinc_code)){
                        document.LOINC.identifier.value=loinc_code+',PATHL7,'+name;
                        return true;
                    }
                }else{
                    alert("Please specify both a loinc code and a name before adding.");
                }

                return false;
            }

            function modCheck(code){
                if (code.charAt(0) == 'x' || code.charAt(0) == 'X'){
                    return true;
                }else{

                    var codeArray = new Array();
                    codeArray = code.split('-');
                    var length = codeArray[0].length;

                    var even = false;
                    if ( (length % 2) == 0 ) even = true;


                    var oddNums = '';
                    var evenNums = '';

                    length--;
                    for (length; length >= 0; length--){
                        if (even){
                            even = false;
                            evenNums = evenNums+codeArray[0].charAt(length);
                        }else{
                            even = true;
                            oddNums = oddNums+codeArray[0].charAt(length);
                        }
                    }

                    oddNums = oddNums*2;
                    var newNum = evenNums+oddNums;
                    var sum = 0;


                    for (var i=0; i < newNum.length; i++){
                        sum = sum + parseInt(newNum.charAt(i));
                    }

                    var newSum = sum;

                    while((newSum % 10) != 0){
                        newSum++;
                    }

                    var checkDigit = newSum - sum;
                    if (checkDigit == codeArray[1]){
                        return true;
                    }else{
                        alert("The loinc code specified is not a valid loinc code, please start the code with an 'X' if you would like to make your own.");
                        return false;
                    }

                }

            }

            <%String outcome = request.getParameter("outcome");
            if (outcome != null){
                if (outcome.equals("success")){
                    %>
                      alert("Successfully added loinc code");
                      window.opener.location.reload()
                      window.close();
                    <%
                }else if (outcome.equals("failedcheck")){
                    %>
                      alert("Unable to add code: The specified code already exists in the database");
                    <%
                }else{
                    %>
                      alert("Failed to add the new code");
                    <%
                }
            }%>

            function removeMapping(mappingIdToRemove) {
                fetch('RemoveMeasurementMap.do?ajax=true&mappingIdToRemove=' + mappingIdToRemove, {
                    method: 'POST',
                    headers: {}
                }).then(function (response) { return response.json(); 
                }).then(function (jsonResponse) {
                    if (jsonResponse.success === true) {
                        document.getElementById('mapping_display_' + mappingIdToRemove).remove();
					}
                });
            }
        </script>
<link rel="stylesheet" type="text/css" media="all" href="../share/css/extractedFromPages.css"  />
<style type="text/css">
	.remove-mapping {
		color: red;
		cursor: pointer;
	}

    .even{ background-color:#ccccff;}
</style>
</head>

<body>
<form method="post" name="LOINC" action="NewMeasurementMap.do"><input
	type="hidden" name="identifier" value="">
<table width="100%" height="100%" border="0">
	<tr class="MainTableTopRow">
		<td class="MainTableTopRow" colspan="9" align="left">
		<table width="100%">
			<tr>
				<td align="left"><input type="button"
					value=" <bean:message key="global.btnClose"/> "
					onClick="window.close()"></td>
				<td align="right">
                                    <oscar:help keywords="measurement" key="app.top1"/> |
                                    <a href="javascript:popupStart(300,400,'../About.jsp')"><bean:message key="global.about" /></a> |
                                    <a href="javascript:popupStart(300,400,'../License.jsp')"><bean:message key="global.license" /></a>
                                 </td>
			</tr>
		</table>
		</td>
	</tr>
	<tr>
		<td valign="top">

		<table>
			<tr>
                                <th valign="bottom" class="Header">MEAS</th>
								<th valign="bottom" class="Header">Loinc Code</th>
                                <th valign="bottom" class="Header">Desc</th>
                                <th valign="bottom" class="Header">--</th>
                                <%
                                MeasurementMapConfig map = new MeasurementMapConfig();
                                List<String> types = map.getLabTypes();
                                types.remove("FLOWSHEET");
                                for(String type:types){%>
                                <th valign="bottom" class="Header"><%=type%></th>
                                <%}%>
            </tr>
            <tbody>
            <%
                List<String> list = map.getDistinctLoincCodes();
                boolean odd = true;
                for (String loincCode : list) {
                    List<Hashtable<String, String>> codesHash = map.getMappedCodesFromLoincCodes(loincCode);
                    String desc = "";
                    if (codesHash.size() > 0) {
                        desc = getDesc(codesHash.get(0));
                    }

                    Hashtable<String, ArrayList<Hashtable<String, String>>> lonicCodeMapping = map.getMappedCodesFromLoincCodesHash(loincCode);
            %>
            <tr style="background-color:<%=rowColour(odd)%>">
                <td class="Cell">
                    <% List<String> measurements = getDisplay(lonicCodeMapping, "FLOWSHEET");
                        if (!measurements.isEmpty()) {%>
                    <%=StringUtils.join(measurements, "<br/>")%>
                    <% } else { %>
                    <a href="addMeasurementMap2.jsp?loinc=<%=loincCode%>">map</a>
                    <% } %>
                </td>
                <td class="Cell"><%=loincCode%></td>
                <td class="Cell"><%=desc%></td>
                <td class="Cell">&nbsp;</td>
                <%
                    for (String type : types) {
                        List<Hashtable<String, String>> mappingsForType = lonicCodeMapping.get(type);
                %>
                <td class="Cell">
                    <%  
						if (mappingsForType != null) {
							for (Hashtable<String, String> mapping : mappingsForType) { %>
                    <span id="mapping_display_<%=mapping.get("id")%>">
                        <span class="remove-mapping" title="Remove Mapping" onclick="removeMapping('<%=mapping.get("id")%>')">X</span>
                        <%=mapping.get("name") + ": " + mapping.get("ident_code")%>
                    	<br/>
                    </span>
                    <%      }
						} %>
                </td>
                <% } %>
            </tr>
            <%
                    odd = !odd; 
                }  %>
            </tbody>
                        <tfoot>
                            <tr>
                                <td colspan="<%=4+types.size()%>" style="background-color:black;color:white" align="center"> Unmapped Codes</td>
                            </tr>
                            <tr>
                                <td colspan="4">&nbsp;</td>
                                <%for(String type:types){%>
                                
                                <td valign="top" style="border: 1px solid black;">
                                
                                <h4 class="Header" style="text-align:center"><%=type%></h4>
                                    <ul>
                                    <li>test</li>
                                    <%
                                    ArrayList<Hashtable<String,Object>> unList = map.getUnmappedMeasurements(type);
                                    for (Hashtable<String,Object> h:unList){
                                    %>
                                       <li><%=h.get(("name"))%></li>
                                    <%}%>
                                    </ul>
                                </td>
                                <%}%>
                            </tr>
                        </tfoot>
		</table>

		</td>
	</tr>
</table>
</form>
</body>
</html>
<%!
    private String rowColour(Boolean b){ 
        return (b) ? "#DDDDDD" : "#FFFFFF"; 
    }
    
    private String getDesc(Hashtable<String,String> h){ 
        return h.get("name"); 
    }
    
    private List<String> getDisplay(Hashtable<String, ArrayList<Hashtable<String,String>>> h, String type){ 
        List<String> results = new ArrayList<String>();
        
        List<Hashtable<String,String>> data = h.get(type);
        if (data != null ){ 
            for (Hashtable<String, String> datum : data) { 
                results.add(datum.get("name") + ": " + datum.get("ident_code")); 
            } 
        }
        return results;
  }
%>
