var $personalRoles = [
    {key: 'Mother', description: 'Mother'},
    {key: 'Father', description: 'Father'},
    {key: 'Parent', description: 'Parent'},
    {key: 'Wife', description: 'Wife'},
    {key: 'Husband', description: 'Husband'},
    {key: 'Partner', description: 'Partner'},
    {key: 'Son', description: 'Son'},
    {key: 'Daughter', description: 'Daughter'},
    {key: 'Brother', description: 'Brother'},
    {key: 'Sister', description: 'Sister'},
    {key: 'Aunt', description: 'Aunt'},
    {key: 'Uncle', description: 'Uncle'},
    {key: 'GrandFather', description: 'GrandFather'},
    {key: 'GrandMother', description: 'GrandMother'},
    {key: 'Guardian', description: 'Guardian'},
    {key: 'Foster Parent', description: 'Foster Parent'},
    {key: 'Next of Kin', description: 'Next of Kin'},
    {key: 'Administrative Staff', description: 'Administrative Staff'},
    {key: 'Care Giver', description: 'Care Giver'},
    {key: 'Power of Attorney', description: 'Power of Attorney'},
    {key: 'Insurance', description: 'Insurance'},
    {key: 'Guarantor', description: 'Guarantor'},
    {key: 'Other', description: 'Other'}
];

var $professionalRoles = [
    {key: 'Family Doctor', description: 'Family Doctor'},
    {key: 'Specialist', description: 'Specialist'},
    {key: 'Dietician', description: 'Dietitian'} //key originally spelt incorrect in OSCAR
];

var $returnMessage = "";

function addContact() {
    $.ajax({
        url: '../demographic/newContact.jsp?search=&id=',
        async: false,
        success: function(data) {
            $("#contactContainer").html(data);
            $('#contactView').modal('show');
            self.opener.refresh();
        }
    });

    return false;
}

function buildContactRoles(category) {
    var contactRoles = $("#contact_role");
    var roles = category === 'professional' ? $professionalRoles : $personalRoles;

    contactRoles.empty();

    $.each(roles, function(i) {
        contactRoles.append($("<option></option>").attr("value", roles[i].key).text(roles[i].description));
    });
}

function contactSearch(url) {
    var results = [];
    $.ajax({
        url: url,
        async: false,
        success: function(data) {

            if (data.results) {
                if(data.results instanceof Array) {
                    for (var i = 0;  i < data.results.length;  i++) {
                        var tmp = data.results[i];
                        var contact = {
                            name: tmp.lastName + ", " + tmp.firstName
                        };

                        results.push(contact);
                    }
                } else {
                    results.push(data.results);
                }
            }
        }
    });
    return results;
}

function deleteContact(id) {
    if (confirm("Are you sure you wish to delete this contact?")) {
        $.ajax({
            url:'../demographic/Contact.do',
            async:false,
            data: {method: "removeContact", contactId: id},
            success:function(data) {
                $('#contact_'+id).hide();
                self.opener.refresh();
            }
        });
    }
}

function isValid() {
    var valid = true;
    if ($('#contact_contactId').val())
        if (!$('#contact_contactName').val() || $('#contact_contactName').val().trim().length <= 0) {
            $returnMessage = "Missing contact name \n";
            valid = false;
        }

    return valid;
}

function popup(height, width, url, windowName){
    if (!windowName) {
        windowName = "manageContacts";
    }
    return popupWindow(height, width, 0, 0, url, windowName)
}

function popupWindow(height, width, top, left, url, windowName){
    if (typeof popupWindow.winRefs == 'undefined') {
        popupWindow.winRefs = {};
    }
    if (typeof popupWindow.winRefs[windowName] == 'undefined' || popupWindow.winRefs[windowName].closed ) {
        windowprops = "height="+height+",width="+width+",location=no,scrollbars=yes,menubars=no,toolbars=no,resizable=yes,screenX=0,screenY=0,top=" + top + ",left=" + left;
        popupWindow.winRefs[windowName]=window.open(url, windowName, windowprops);
    }
    else {
        popupWindow.winRefs[windowName].location.href = url;
        popupWindow.winRefs[windowName].resizeTo(width,height);
        popupWindow.winRefs[windowName].focus();
    }

    return popupWindow.winRefs[windowName];
}

function saveContact(id) {
    var valid = isValid();
    if (!valid) {
        alert($returnMessage);
    }
    return valid;
}

function searchContacts() {
    var category = $('input[type=radio][name=contact_category]:checked').val();
    var type = $('#contact_typeSelect').val();
    var keyword = $('#contact_contactName').val();
    var name = "contact_contactName";
    var id = "contact_contactId";

    var url = null;
    var columns = {
        contactId: '',
        firstName: 'firstName',
        lastName: 'lastName'
    };

    if (category === 'personal' && type === 'internal') {
        url = '../demographic/demographicsearch2apptresults.jsp?search_mode=search_name&formName=contactForm&keyword=' + keyword;
    } else if (category === 'personal' && type === 'external') {
        url = '../demographic/contactSearch.jsp?form=contactForm&list=personal&keyword=' + keyword;
    } else if (category === 'professional' && type === 'internal') {
        url = '../provider/receptionistfindprovider.jsp?custom=true&providername=' + keyword + '&form=contactForm';
        columns.contactId = 'providerNo';
    } else if (category === 'professional' && type === 'specialist') {
        url = '../demographic/professionalSpecialistSearch.jsp?form=contactForm&keyword=' + keyword + '&submit=Search&elementName=' + name + '&elementId=' + id;
    } else if (category === 'professional' && type === 'external') {
        url = '../demographic/procontactSearch.jsp?form=contactForm&submit=Search&keyword=' + keyword;
    }

    if (url) {
        popup(700, 960, url, 'demographic_search');
    }
}

function setBestContactMethod(contactMethod) {
    $('li.list-group-item.active').removeClass('active');

    if (contactMethod) {
        $('#contact_'+contactMethod).parent().addClass('active');
    } else {
        $('input[type=radio][name=contact_bestContact]:checked').parent().removeClass('active');
        $('input[type=radio][name=contact_bestContact]:checked').prop('checked', false);
    }
}

function setConsent() {
    var noConsent = $('#contact_consentToContact').val() === "0";

    if (noConsent) {
        $('#bestContact').hide();
    } else {
        $('#bestContact').show();
    }
}

function setContactCategoryType(category, typeSelect) {
    $('#contact_contactId').val('');
    $('#contact_contactName').val('');

    if (!category) {
        category = $('input[type=radio][name=contact_category]:checked').val();
    }

    if (!typeSelect) {
        typeSelect = $("#contact_typeSelect").val();
    }

    buildContactRoles(category);

    var type = $("#contact_type");

    if (category === 'personal' && typeSelect === 'internal') {
        type.val('1');
    } else if (category === 'professional' && typeSelect === 'internal') {
        type.val('0');
    } else if (category === 'professional' && typeSelect === 'specialist') {
        type.val('3');
    } else if (typeSelect === 'external') {
        type.val('2');
    }


    if (category === 'personal') {
        $('#ecSdm').show();
        $("#contact_typeSelect option[value=specialist]").hide();
    } else {
        $('#ecSdm').hide();
        $("#contact_typeSelect option[value=specialist]").show();
    }

    if (typeSelect === 'external') {
        $('#contact_phone').val('').removeAttr('disabled');
        $('#contact_cell').val('').removeAttr('disabled');
        $('#contact_work').val('').removeAttr('disabled');
        $('#contact_email').val('').removeAttr('disabled');
    } else {
        $('#contact_phone').val('').attr('disabled', 'disabled');
        $('#contact_cell').val('').attr('disabled', 'disabled');
        $('#contact_work').val('').attr('disabled', 'disabled');
        $('#contact_email').val('').attr('disabled', 'disabled');
    }
}

function setContactView(id) {
    var contact = contacts && contacts.length > 0 ? $.grep(contacts, function(e){ return e.id === id; })[0] : null;

    if (contact && contact.category) {
        var searchVal = "";

        if (!id){
            searchVal = "Search";
            id = '';
        }

        $.ajax({
            url: '../demographic/editContact.jsp?search=' + searchVal + '&id=' + id + "&type=" + contact.type,
            async: false,
            success: function(data) {
                $("#contactContainer").html(data);
                setValues(contact);
                $('#contactView').modal('show');
            }
        });
    }
}

function setValues(contact) {
    buildContactRoles(contact.category);
    $('#contact_id').val(contact.id);
    $('#contact_contactName').val(contact.contactName).attr('disabled', 'disabled');
    $('#contact_role').val(contact.role);
    $('#contact_consentToContact').val(contact.consentToContact ? '1' : '0');
    $('#contact_active').val(contact.active ? '1' : '0');
    $('#contact_contactId').val(contact.contactId);
    $('#contact_type').val(contact.type);
    $('#contact_category').val(contact.category);
    $('#contact_note').val(contact.note ? contact.note : '');


    if (contact.bestContact) {
        $('input[type=radio][name=contact_bestContact]').filter('[value="' + contact.bestContact + '"]').attr('checked', true);
        setBestContactMethod(contact.bestContact);
    }


    if (contact.details) {
        var notSet = 'Not Set';
        if (contact.type === 2) {
            notSet = '';
            $('#contact_phone').removeAttr('disabled');
            $('#contact_cell').removeAttr('disabled');
            $('#contact_work').removeAttr('disabled');
            $('#contact_email').removeAttr('disabled');
        }
        $('#contact_phone').val(contact.details.residencePhone ? contact.details.residencePhone : notSet);
        $('#contact_cell').val(contact.details.cellPhone ? contact.details.cellPhone : notSet);
        $('#contact_work').val(contact.details.workPhone ? contact.details.workPhone : notSet);
        $('#contact_email').val(contact.details.email ? contact.details.email : notSet);
    }

    if (contact.category === 'personal') {
        $('#contactCategory').text('Personal');
        $('#contactType').text(contact.type === 1 ? 'Internal' : 'External');
        $('#ecSdm').show();
        $('#contact_sdm').val(contact.sdm ? contact.sdm : '');
        $('#contact_ec').val(contact.ec ? contact.ec : '');
    } else if (contact.category === 'professional') {
        $('#contactCategory').text('Professional');
        if (contact.type === 0) {
            $('#contactType').text('Internal');
        } else if (contact.type === 3) {
            $('#contactType').text(contact.type === 0 ? 'Internal' : 'Professional Specialist');
        }
        $('#contactType').text(contact.type === 0 ? 'Internal' : 'Professional Specialist');
    }

    setConsent();
}

function updateSort(column) {
    var sortColumn =$("#sortColumn").val();
    var sortOrder = $("#sortOrder").val();

    if(sortColumn !== column) {
        sortColumn = column;
        sortOrder = 'asc';
    } else {
        if(sortOrder === 'asc') {
            sortOrder = 'desc';
        } else {
            sortOrder='asc';
        }
    }

    $("#sortColumn").val(sortColumn);
    $("#sortOrder").val(sortOrder);

    document.contactList.submit();
}