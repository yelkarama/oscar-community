<%@ include file="/taglibs.jsp"%>
<%@page import="org.apache.commons.lang.StringUtils"%>
<%@page import="org.oscarehr.util.SpringUtils"%>
<%@page import="org.oscarehr.PMmodule.dao.ProviderDao"%>
<%@page import="org.oscarehr.common.model.DemographicContact"%>
<%
    String id = StringUtils.trimToEmpty(request.getParameter("id"));
    ProviderDao providerDao = (ProviderDao)SpringUtils.getBean("providerDao");
    request.setAttribute("providers",providerDao.getActiveProviders());
%>
<script type="text/javascript">
    $(document).ready(function() {
        $('input[type=radio][name=contact_bestContact]').change(function() {
            setBestContactMethod($('input[type=radio][name=contact_bestContact]:checked').val());
        });
    });
</script>
<div class="modal-header">
    <h3 class="modal-title">
        <button type="button" class="close" data-dismiss="modal">&times;</button>
        <input type="text" class="form-control" name="contact_contactName" id="contact_contactName" size="20" />
    </h3>
    <label id="contactCategoryType" class="label label-info" style="text-transform: uppercase">
        <span id="contactCategory"></span> / <span id="contactType"></span>
    </label>
</div>

<div class="modal-body" id="contact_<%=id%>">
    <input type="hidden" name="contact_id" id="contact_id" value="<%=id%>"/>
    <input type="hidden" name="contact_contactId" id="contact_contactId" value=""/>
    <input type="hidden" name="contact_category" id="contact_category" value="personal"/>
    <input type="hidden" name="contact_type" id="contact_type" value=""/>

    <div class="row">
        <div id="role_type" class="col-sm-6">
            <label>Role</label>
            <select class="form-control input-sm" name="contact_role" id="contact_role"></select>
        </div>
    </div>

    <div class="row">
        <div class="col-sm-6">
            <label>Consent to Contact</label>
            <select class="form-control input-sm" name="contact_consentToContact" id="contact_consentToContact" title="Consent to Contact" onchange="setConsent()">
                <option value="1">Consent</option>
                <option value="0">No Consent</option>
            </select>
        </div>
    </div>

    <div id="bestContact" class="row">
        <div class="col-sm-12">
            <label>Contact Method</label> <label style="float: right">Best?</label>
            <ul id="contactMethods" class="list-group list-link" >
                <li class="list-group-item">
                    <span class="label label-default">Main</span> &nbsp;&nbsp;&nbsp;
                    <input type="text" id="contact_phone" name="contact_phone" class="form-control input-sm" disabled="disabled" />

                    <input type="radio" name="contact_bestContact" value="phone" title="Set as best contact method" ondblclick="setBestContactMethod();" style="float: right" />
                </li>
                <li class="list-group-item">
                    <span class="label label-default">Cell</span>  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    <input type="text" id="contact_cell" name="contact_cell" class="form-control input-sm" disabled="disabled" />

                    <input type="radio" name="contact_bestContact" value="cell" title="Set as best contact method" ondblclick="setBestContactMethod();" style="float: right" />
                </li>
                <li class="list-group-item">
                    <span class="label label-default">Work</span> &nbsp;&nbsp;
                    <input type="text" id="contact_work" name="contact_work" class="form-control input-sm" disabled="disabled" />

                    <input type="radio" name="contact_bestContact" value="work" title="Set as best contact method" ondblclick="setBestContactMethod();" style="float: right" />
                </li>
                <li class="list-group-item">
                    <span class="label label-default">Email</span> &nbsp;&nbsp;
                    <input type="text" id="contact_email" name="contact_email" class="form-control input-sm" disabled="disabled" />

                    <input type="radio" name="contact_bestContact" value="email" title="Set as best contact method" ondblclick="setBestContactMethod();" style="float: right" />
                </li>
            </ul>
        </div>
    </div>

    <div class="row">
        <div class="col-sm-6">
            <label>Status</label>
            <select class="form-control input-sm" name="contact_active" id="contact_active" title="Active">
                <option value="1">Active</option>
                <option value="0">Inactive</option>
            </select>
        </div>
    </div>

    <div id="ecSdm" class="row" style="display:none;">
        <div class="col-sm-6">
            <label>Secondary Decision Maker:</label>
            <select class="form-control input-sm" name="contact_sdm" id="contact_sdm" title="Secondary Decision Maker">
                <option value="">Not Set</option>
                <option value="true">Yes</option>
                <option value="false">No</option>
            </select>
        </div>

        <div class="col-sm-6">
            <label>Emergency Contact:</label>
            <select class="form-control input-sm" name="contact_ec" id="contact_ec" title="Emergency Contact">
                <option value="">Not Set</option>
                <option value="true">Yes</option>
                <option value="false">No</option>
            </select>
        </div>
    </div>

    <div class="row">
        <div class="col-sm-12">
            <label>Notes</label>
            <textarea class="form-control input-sm" id="contact_note" name="contact_note" rows="1" cols="15" title="Contact Note" style="resize: vertical"></textarea>
        </div>
    </div>
</div>
<div class="modal-footer">
    <button class="btn btn-secondary" style="float: left" onclick="return deleteContact(<%=id%>)">Delete</button>
    <input type="submit" class="btn btn-primary" value="Save" onclick="return saveContact();"/>
</div>