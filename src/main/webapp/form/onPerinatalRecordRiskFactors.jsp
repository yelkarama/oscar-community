<%
    int rfNum = request.getParameter("rfNum") != null ? Integer.parseInt(request.getParameter("rfNum")) : 0;
%>

<tr id="rf_<%=rfNum%>">
    <td>
        <a href="javascript:void(0)" onclick="deleteRiskFactor('<%=rfNum%>'); return false;">[x]</a>&nbsp; <%=rfNum%>
    </td>
    <td>
        <input type="text" name="rf_issues<%=rfNum%>" size="20" maxlength="50" style="width: 100%" >
    </td>
    <td>
        <input type="text" name="rf_plan<%=rfNum%>" size="60" maxlength="100" style="width: 100%" >
    </td>
</tr>