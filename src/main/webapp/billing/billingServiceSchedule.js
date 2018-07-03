function remove(id) {
    var url = "../billing/ScheduleBillingService.do?method=remove";

    $.ajax({
        method: 'POST',
        dataType: 'json',
        url: url,
        async: false,
        data: {
            id: id,
            providerView: $("#providerView").val()
        },
        success: function (data) {
            if (data && data.success) {
                alertify.success("Successfully removed");
                $("tr[id='" + data.id + "']").remove();
            } else {
                alertify.error("Error removing");
            }
        }
    });

    return false;
}

function save(id) {
    var url = "../billing/ScheduleBillingService.do?method=save";
    var serviceCode = "";
    var time = "";

    if (id) {
        serviceCode = $("#service_code_" + id).html();
        time =  $("#billing_time_" + id).val();
    } else {
        serviceCode = $("#searchService").val();
        time =  $("#billingTime").val();
    }


    $.ajax({
        method: 'POST',
        dataType: 'json',
        url: url,
        async: false,
        data: {
            id: id,
            serviceCode: serviceCode,
            billingTime: time + ":00",
            providerView: $("#providerView").val()
        },
        success: function (data) {
            if (data && data.success && data.serviceItem) {
                if (data.isNew) {
                    var columns = "<td>" + data.serviceItem.serviceCode + "</td>";
                    columns += "<td>" + data.serviceItem.serviceDescription + "</td>";
                    columns += "<td><input type=\"time\" value=\"" + data.serviceItem.billingTime + "\"/></td>";
                    columns += "<td><input class=\"btn btn-small btn-primary\" type=\"submit\" value=\"Update\" onclick=\"return save('" + data.serviceItem.id + "');\"></td>";
                    columns += "<td><input class=\"btn btn-small btn-danger\" type=\"submit\" value=\"Delete\" onclick=\"return remove('" + data.serviceItem.id + "');\"></td>";
                    $("#services").append($("<tr></tr>").attr("id", data.serviceItem.id).html(columns));
                   
                    $("#searchService").val('');
                    $("#searchServiceDescription").text('');
                    $("#billingTime").val('');
                    $('#addBtn').attr('disabled', 'disabled');
                }
                
                alertify.success("Successfully " + (data.isNew ? "saved" : "updated"));
            } else {
                alertify.error("Error " + (data.isNew ? "saving" : "updating"));
            }
        }
    });

    return false;
}