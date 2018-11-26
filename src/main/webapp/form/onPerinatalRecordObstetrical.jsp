
<%
    int ohNum = request.getParameter("ohNum") != null ? Integer.parseInt(request.getParameter("ohNum")) : 0;
%>

<tr align="center" id="oh_<%=ohNum%>">
    <td>
        <a class="delete_link" href="javascript:void(0)" onclick="deleteObstetricalHistory('<%=ohNum%>'); return false;">[x]</a>&nbsp;<%=ohNum%>
    </td>
    <td>
        <input type="text" name="oh_yearMonth<%=ohNum%>" size="6" maxlength="7" style="width: 90%" placeholder="YYYY/MM" />
    </td>
    <td>
        <input type="text" name="oh_place<%=ohNum%>" size="8" maxlength="20" style="width: 80%" />
    </td>
    <td>
        <input type="text" name="oh_gest<%=ohNum%>" size="3" maxlength="5" style="width: 80%" />
    </td>
    <td>
        <input type="text" name="oh_length<%=ohNum%>" size="5" maxlength="6" style="width: 80%" />
    </td>
    <td>
        <input type="radio" name="oh_birth_type<%=ohNum%>" value="SVB" />
        <input type="radio" name="oh_birth_type<%=ohNum%>" value="CS" />
        <input type="radio" name="oh_birth_type<%=ohNum%>" value="Assisted" />
    </td>
    <td align="left">
        <input type="text" name="oh_comments<%=ohNum%>" size="20" maxlength="80" style="width: 100%"  />
    </td>
    <td>
        <input type="text" name="oh_sex<%=ohNum%>" size="2" maxlength="1" style="width: 50%" />
    </td>
    <td>
        <input type="text" name="oh_weight<%=ohNum%>" size="5" maxlength="6" style="width: 80%" />
    </td>
    <td>
        <input type="text" name="oh_breastfed<%=ohNum%>" size="5" maxlength="10" style="width: 80%" />
    </td>
    <td>
        <input type="text" name="oh_health<%=ohNum%>" size="5" maxlength="10" style="width: 80%" />
    </td>
</tr>