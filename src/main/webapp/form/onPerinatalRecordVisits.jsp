
<%
    int svNum = request.getParameter("svNum") != null ? Integer.parseInt(request.getParameter("svNum")) : 0;
%>

<tr align="center" id="sv_<%=svNum%>">
    <td>
        <a class="delete_link" href="javascript:void(0)" onclick="deleteSubsequentVisit('<%=svNum%>'); return false;">[x]</a>&nbsp;<%=svNum%>
    </td>
    <td>
        <input type="text" name="sv_date<%=svNum%>" class="spe" ondblclick="calToday(this)" size="10" maxlength="10" placeholder="YYYY/MM/DD" />
    </td>
    <td>
        <input type="text" name="sv_ga<%=svNum%>" class="spe" ondblclick="getGestationalAge(this)" size="5" maxlength="10"/>
    </td>
    <td>
        <input type="text" name="sv_wt<%=svNum%>" class="spe" ondblclick="weightImperialToMetric(this)" size="6" maxlength="6"/>
    </td>
    <td>
        <input type="text" name="sv_bp<%=svNum%>" size="6" maxlength="10"/>
    </td>
    <td>
        <input type="text" name="sv_urine<%=svNum%>" size="6" maxlength="6"/>
    </td>
    <td>
        <input type="text" name="sv_sfh<%=svNum%>" size="6" maxlength="6"/>
    </td>
    <td>
        <input type="text" name="sv_pres<%=svNum%>" size="6" maxlength="6"/>
    </td>
    <td>
        <input type="text" name="sv_fhr<%=svNum%>" size="6" maxlength="6"/>
    </td>
    <td>
        <input type="text" name="sv_fm<%=svNum%>" size="6" maxlength="6"/>
    </td>
    <td>
        <input type="text" name="sv_comments<%=svNum%>" size="75" maxlength="255"/>
    </td>
    <td>
        <input type="text" name="sv_next<%=svNum%>" size="10" maxlength="10" placeholder="YYYY/MM/DD" />
    </td>
    <td>
        <input type="text" name="sv_initial<%=svNum%>" size="4" maxlength="4"/>
    </td>
</tr>