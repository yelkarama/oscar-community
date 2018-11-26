
<%
    int usNum = request.getParameter("usNum") != null ? Integer.parseInt(request.getParameter("usNum")) : 0;
%>

<tr id="us_<%=usNum%>" class="us">
    <td>
        <input type="text" id="us_date<%=usNum%>" name="us_date<%=usNum%>" class="spe" ondblclick="calToday(this)" size="10" maxlength="10" placeholder="YYYY/MM/DD" />
        <img src="../images/cal.gif" id="us_date<%=usNum%>_cal" />
    </td>

    <td>
        <input type="text" id="us_ga<%=usNum%>" name="us_ga<%=usNum%>" class="spe" ondblclick="getGestationalAge(this)" size="5" maxlength="10" />
    </td>
    <% if (usNum == 3) { %>
    <td class="ultrasound-3">
        <input type="text" id="us_result<%=usNum%>_as" name="us_result<%=usNum%>_as" size="32" maxlength="50" placeholder="Anatomy scan (between 18-22 wks)" />
        <input type="text" id="us_result<%=usNum%>_pl" name="us_result<%=usNum%>_pl" size="32" maxlength="50" placeholder="Placental Location" />
        <input type="text" id="us_result<%=usNum%>_sm" name="us_result<%=usNum%>_sm" size="32" maxlength="50" placeholder="Soft Markers" />
    </td>
    <% } else { %>
    <td>
        <input type="text" id="us_result<%=usNum%>" name="us_result<%=usNum%>" style="width: 100%;" maxlength="125" <%=(usNum == 2) ? "placeholder='NT Ultrasound (between 11-13+6 weeks)'" : ""%> />
    </td>
    <% }%>
</tr>