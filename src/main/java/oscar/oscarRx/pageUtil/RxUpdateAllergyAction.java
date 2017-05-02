package oscar.oscarRx.pageUtil;

import java.io.IOException;
import java.util.Date;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.struts.action.Action;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.oscarehr.common.model.Allergy;
import org.oscarehr.common.model.PartialDate;
import org.oscarehr.managers.SecurityInfoManager;
import org.oscarehr.util.LoggedInInfo;
import org.oscarehr.util.SpringUtils;

import oscar.log.LogAction;
import oscar.log.LogConst;
import oscar.oscarRx.data.RxDrugData;
import oscar.oscarRx.data.RxPatientData;
import oscar.util.StringUtils;

import static oscar.oscarRx.util.RxUtil.StringToDate;

public class RxUpdateAllergyAction extends Action{
    private SecurityInfoManager securityInfoManager = SpringUtils.getBean(SecurityInfoManager.class);

    public ActionForward execute(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        if (!securityInfoManager.hasPrivilege(LoggedInInfo.getLoggedInInfoFromSession(request), "_allergy", "w", null)) {
            throw new RuntimeException("missing required security object (_allergy)");
        }

        int id = Integer.parseInt(request.getParameter("ID"));

        RxPatientData.Patient patient = (RxPatientData.Patient)request.getSession().getAttribute("Patient");
        Allergy allergy = patient.getAllergy(id);

        String name = request.getParameter("name");
        Integer type = Integer.parseInt(request.getParameter("type"));
        String reactionDescription = request.getParameter("reactionDescription");

        Date startDate = null;
        String startDateString = request.getParameter("startDate");
        String pattern = "";
        if(!StringUtils.isNullOrEmpty(startDateString)){
            pattern = allergy.getDatePattern(startDateString);
            startDate = StringToDate(startDateString, pattern);
        }

        String ageOfOnset = request.getParameter("ageOfOnset");
        String severityOfReaction = request.getParameter("severityOfReaction");
        String onSetOfReaction = request.getParameter("onSetOfReaction");
        String lifeStage = request.getParameter("lifeStage");
        boolean isUpdate = false;



        if(!name.equals(allergy.getDescription())){
            allergy.setDescription(name);
            isUpdate = true;
        }

        if(!type.equals(allergy.getTypeCode())){
            allergy.setTypeCode(type);
            isUpdate = true;
        }

        if(!reactionDescription.equals(allergy.getReaction())){
            allergy.setReaction(reactionDescription);
            isUpdate = true;
        }

        if(startDate!=null && !startDate.equals(allergy.getStartDate())){
            //update when a new value is entered
            allergy.setStartDate(startDate);
            if (pattern.equals(PartialDate.YEARMONTH)) {
                allergy.setStartDateFormat(PartialDate.YEARMONTH);
            } else if (pattern.equals(PartialDate.YEARONLY)) {
                allergy.setStartDateFormat(PartialDate.YEARONLY);
            }
            isUpdate = true;
        }
        else if(startDate==null && allergy.getStartDate()!=null){
            //update if value is cleared
            allergy.setStartDate(startDate);
            isUpdate = true;
        }

        if(!ageOfOnset.equals(allergy.getAgeOfOnset())){
            allergy.setAgeOfOnset(ageOfOnset);
            isUpdate = true;
        }

        if(!severityOfReaction.equals(allergy.getSeverityOfReaction())){
            allergy.setSeverityOfReaction(severityOfReaction);
            isUpdate = true;
        }

        if(!onSetOfReaction.equals(allergy.getOnsetOfReaction())) {
            allergy.setOnsetOfReaction(onSetOfReaction);
            isUpdate = true;
        }

        if(!lifeStage.equals(allergy.getLifeStage())){
            allergy.setLifeStage(lifeStage);
            isUpdate = true;
        }

        RxDrugData.DrugMonograph drugMonograph = allergy.isDrug(type);
        if (drugMonograph!=null){
            allergy.setRegionalIdentifier(drugMonograph.regionalIdentifier);
        }

        if (isUpdate){
            patient.updateAllergy(oscar.oscarRx.util.RxUtil.Today(), allergy);
            String ip = request.getRemoteAddr();
            LogAction.addLog((String) request.getSession().getAttribute("user"), LogConst.UPDATE, LogConst.CON_ALLERGY, ""+allergy.getAllergyId() , ip,""+patient.getDemographicNo(), allergy.getAuditString());
        }

        return (mapping.findForward("success"));
    }

    private int getCharOccur(String str, char ch) {
        int occurence=0, from=0;
        while (str.indexOf(ch,from)>=0) {
            occurence++;
            from = str.indexOf(ch,from)+1;
        }
        return occurence;
    }
}
