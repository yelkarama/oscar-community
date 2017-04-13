package com.indivica.asthmalife;

import java.util.ArrayList;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import net.sf.json.JSONArray;
import net.sf.json.JSONObject;
import org.apache.commons.lang.StringEscapeUtils;
import org.apache.log4j.Logger;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.oscarehr.casemgmt.service.CaseManagementManager;
import org.oscarehr.common.dao.DemographicDao;
import org.oscarehr.common.model.Demographic;
import org.oscarehr.common.model.Drug;
import org.oscarehr.util.LoggedInInfo;
import org.oscarehr.util.SpringUtils;
import oscar.OscarAction;
import oscar.OscarProperties;

public class DemographicPayloadAction
extends OscarAction {
    private static final Logger _logger = Logger.getLogger(DemographicPayloadAction.class);

    public ActionForward execute(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) {
        JSONObject data = this.generateDataForDemographic(request, response);
        request.setAttribute("data", (Object)data.toString());
        request.setAttribute("url", (Object)OscarProperties.getInstance().getProperty("indivicare_asthma_life_url"));
        return mapping.findForward("proxy");
    }

    private JSONObject generateDataForDemographic(HttpServletRequest request, HttpServletResponse response) {
        JSONObject data = new JSONObject();
        String demographicNo = request.getParameter("demographicNo");
        HttpSession session = request.getSession();
        String providerNo = (String)session.getAttribute("user");
        data.put((Object)"providerNo", (Object)providerNo);
        data.put((Object)"demographicNo", (Object)demographicNo);
        DemographicDao ddao = (DemographicDao)SpringUtils.getBean((String)"demographicDao");
        Demographic demo = ddao.getDemographic(demographicNo);
        data.put((Object)"firstName", (Object)demo.getFirstName());
        data.put((Object)"lastName", (Object)demo.getLastName());
        data.put((Object)"DOB", (Object)demo.getBirthDayAsString());
        data.put((Object)"sex", (Object)demo.getSex());
        JSONObject provider = new JSONObject();
        provider.put((Object)"id", (Object)demo.getProvider().getProviderNo());
        provider.put((Object)"name", (Object)demo.getProvider().getFullName());
        data.put((Object)"MRP", (Object)provider);
        data.put((Object)"HIN", (Object)(demo.getHin() + " " + demo.getVer()));
        data.put((Object)"address", (Object)StringEscapeUtils.escapeJavaScript((String)String.format("%s\n%s %s", demo.getAddress(), demo.getProvince(), demo.getPostal())));
        data.put((Object)"phone", (Object)demo.getPhone());
        JSONArray prescriptions = this.generatePrescriptionDataForDemographic(request, response, demographicNo);
        data.put((Object)"prescriptions", (Object)prescriptions);
        return data;
    }

    private JSONArray generatePrescriptionDataForDemographic(HttpServletRequest request, HttpServletResponse response, String demographicNo) {
    	LoggedInInfo loggedInInfo = LoggedInInfo.getLoggedInInfoFromSession(request);
        CaseManagementManager caseManagementManager = (CaseManagementManager)SpringUtils.getBean((String)"caseManagementManager");
        ArrayList<Drug> drugs = new ArrayList<Drug>();
        drugs.addAll(caseManagementManager.getPrescriptions(loggedInInfo, Integer.parseInt(demographicNo), false));
        JSONArray prescriptions = new JSONArray();
        for (Drug drug : drugs) {
            JSONObject prescription = new JSONObject();
            prescription.put((Object)"rx_date", (Object)drug.getRxDate().toString());
            prescription.put((Object)"end_date", (Object)drug.getEndDate().toString());
            prescription.put((Object)"written_date", (Object)drug.getWrittenDate().toString());
            prescription.put((Object)"BN", (Object)StringEscapeUtils.escapeJavaScript((String)drug.getBrandName()));
            prescription.put((Object)"GCN_SEQNO", (Object)drug.getGcnSeqNo());
            prescription.put((Object)"customName", (Object)StringEscapeUtils.escapeJavaScript((String)drug.getCustomName()));
            prescription.put((Object)"takemin", (Object)Float.valueOf(drug.getTakeMin()));
            prescription.put((Object)"takemax", (Object)Float.valueOf(drug.getTakeMax()));
            prescription.put((Object)"freqcode", (Object)StringEscapeUtils.escapeJavaScript((String)drug.getFreqCode()));
            prescription.put((Object)"duration", (Object)StringEscapeUtils.escapeJavaScript((String)drug.getDuration()));
            prescription.put((Object)"durunit", (Object)StringEscapeUtils.escapeJavaScript((String)drug.getDurUnit()));
            prescription.put((Object)"quantity", (Object)drug.getQuantity());
            prescription.put((Object)"GN", (Object)StringEscapeUtils.escapeJavaScript((String)drug.getGenericName()));
            prescription.put((Object)"ATC", (Object)StringEscapeUtils.escapeJavaScript((String)drug.getAtc()));
            prescription.put((Object)"regional_identifier", (Object)drug.getRegionalIdentifier());
            prescription.put((Object)"unit", (Object)StringEscapeUtils.escapeJavaScript((String)drug.getUnit()));
            prescription.put((Object)"method", (Object)StringEscapeUtils.escapeJavaScript((String)drug.getMethod()));
            prescription.put((Object)"route", (Object)drug.getRoute());
            prescription.put((Object)"dosage", (Object)StringEscapeUtils.escapeJavaScript((String)drug.getDosage()));
            prescriptions.add((Object)prescription);
        }
        return prescriptions;
    }
}