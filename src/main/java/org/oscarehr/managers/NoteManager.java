package org.oscarehr.managers;

import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;
import org.oscarehr.PMmodule.model.ProgramProvider;
import org.oscarehr.PMmodule.service.AdmissionManager;
import org.oscarehr.PMmodule.service.ProgramManager;
import org.oscarehr.casemgmt.dao.IssueDAO;
import org.oscarehr.casemgmt.model.CaseManagementCPP;
import org.oscarehr.casemgmt.model.CaseManagementIssue;
import org.oscarehr.casemgmt.model.CaseManagementNote;
import org.oscarehr.casemgmt.model.CaseManagementNoteExt;
import org.oscarehr.casemgmt.model.Issue;
import org.oscarehr.casemgmt.service.CaseManagementManager;
import org.oscarehr.common.dao.CaseManagementIssueNotesDao;
import org.oscarehr.common.model.Provider;
import org.oscarehr.util.LoggedInInfo;
import org.oscarehr.util.MiscUtils;
import org.oscarehr.util.SpringUtils;
import org.oscarehr.ws.rest.to.model.CaseManagementIssueTo1;
import org.oscarehr.ws.rest.to.model.IssueTo1;
import org.oscarehr.ws.rest.to.model.NoteExtTo1;
import org.oscarehr.ws.rest.to.model.NoteIssueTo1;
import org.oscarehr.ws.rest.to.model.NoteTo1;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.HashSet;
import java.util.List;

@Service
public class NoteManager {

    private static Logger logger = MiscUtils.getLogger();

    @Autowired
    private CaseManagementManager caseManagementManager;

    @Autowired
    private ProgramManager2 programManager2;
    
    @Autowired
    private ProgramManager programManager;

    @Autowired
    private IssueDAO issueDao;

    //moved over from NotesService.Java:saveNote()
    public NoteTo1 saveNote(LoggedInInfo loggedInInfo, Integer demographicNo, NoteTo1 note){
        logger.debug("saveNote "+note);
        String providerNo=loggedInInfo.getLoggedInProviderNo();
        Provider provider = loggedInInfo.getLoggedInProvider();
        String userName = provider != null ? provider.getFullName() : "";

        String demo = ""+demographicNo;

        CaseManagementNote caseMangementNote  = new CaseManagementNote();

        caseMangementNote.setDemographic_no(demo);
        caseMangementNote.setProvider(provider);
        caseMangementNote.setProviderNo(providerNo);

        if(note.getUuid() != null && !note.getUuid().trim().equals("")){
            caseMangementNote.setUuid(note.getUuid());
        }

        String noteTxt = note.getNote();
        noteTxt = org.apache.commons.lang.StringUtils.trimToNull(noteTxt);
        if (noteTxt == null || noteTxt.equals("")) return null;

        caseMangementNote.setNote(noteTxt);

        CaseManagementCPP cpp = this.caseManagementManager.getCPP(demo);
        if (cpp == null) {
            cpp = new CaseManagementCPP();
            cpp.setDemographic_no(demo);
        }
        logger.debug("enc TYPE " +note.getEncounterType());
        caseMangementNote.setEncounter_type(note.getEncounterType());

        logger.debug("this is what the encounter time was "+note.getEncounterTime());

        logger.debug("this is what the encounter time was "+note.getEncounterTransportationTime());
		
        //Need to check some how that if a note is signed that it must stay signed, currently this is done in the interface where the save button is not available.
        if(note.getIsSigned()){
            caseMangementNote.setSigning_provider_no(providerNo);
            caseMangementNote.setSigned(true);
        } else {
            caseMangementNote.setSigning_provider_no("");
            caseMangementNote.setSigned(false);
        }

        caseMangementNote.setProviderNo(providerNo);
        if (provider != null) caseMangementNote.setProvider(provider);

        String programIdString = getProgram(loggedInInfo,providerNo); //might not to convert it.
        caseMangementNote.setProgram_no(programIdString);

        List<CaseManagementIssue> issuelist = new ArrayList<CaseManagementIssue>();

        for(CaseManagementIssueTo1 i:note.getAssignedIssues()) {
            if(!i.isUnchecked()) {
                CaseManagementIssue cmi = caseManagementManager.getIssueByIssueCode(demo, i.getIssue().getCode());
                if(cmi != null) {
                    //update
                } else {
                    //new one
                    cmi = new CaseManagementIssue();
                    Issue is = issueDao.getIssue(i.getIssue_id());
                    cmi.setIssue_id(is.getId());
                    cmi.setIssue(is);
                    cmi.setProgram_id(programManager2.getCurrentProgramInDomain(loggedInInfo, loggedInInfo.getLoggedInProviderNo()).getProgramId().intValue());
                    cmi.setType(is.getRole());
                    cmi.setDemographic_no(Integer.valueOf(demo));
                }

                cmi.setAcute(i.isAcute());
                cmi.setCertain(i.isCertain());
                cmi.setMajor(i.isMajor());
                cmi.setResolved(i.isResolved());
                cmi.setUpdate_date(new Date());

                issuelist.add(cmi);
                caseManagementManager.saveCaseIssue(cmi);
            }
        }

        note.setIssues(new HashSet<CaseManagementIssue>(issuelist));
        caseMangementNote.setIssues(new HashSet<CaseManagementIssue>(issuelist));


        String ongoing = new String();

        String noteString = note.getNote();
        caseMangementNote.setNote(noteString);

        // update appointment and add verify message to note if verified

        boolean verify = false;
        if(note.getIsVerified()!=null && note.getIsVerified()){
            verify = true;
        }
        
        // update password
        Date now = new Date();

        Date observationDate = note.getObservationDate();
        if (observationDate != null && !observationDate.equals("")) {
            if (observationDate.getTime() > now.getTime()) {
                caseMangementNote.setObservation_date(now);
            } else{
                caseMangementNote.setObservation_date(observationDate);
            }
        } else if (note.getObservationDate() == null) {
            caseMangementNote.setObservation_date(now);
        }

        caseMangementNote.setUpdate_date(now);

        if (note.getAppointmentNo() != null) {
            caseMangementNote.setAppointmentNo(note.getAppointmentNo());
        }
        
        // Save annotation 

        CaseManagementNote annotationNote = null;

        String lastSavedNoteString = null;
        String user = loggedInInfo.getLoggedInProvider().getProviderNo();
        String remoteAddr = ""; // Not sure how to get this	
        caseMangementNote = caseManagementManager.saveCaseManagementNote(loggedInInfo, caseMangementNote,issuelist, cpp, ongoing,verify, loggedInInfo.getLocale(),now,annotationNote,userName,user,remoteAddr, lastSavedNoteString) ;

        caseManagementManager.getEditors(caseMangementNote);
        
        note.setNoteId(Integer.parseInt(""+caseMangementNote.getId()));
        note.setUuid(caseMangementNote.getUuid());
        note.setUpdateDate(caseMangementNote.getUpdate_date());
        note.setObservationDate(caseMangementNote.getObservation_date());
        logger.error("note should return like this " + note.getNote() );
        return note;
    }
    
    //moved over from NoteService.Java:saveIssueNote()
    public NoteIssueTo1 saveIssueNote(LoggedInInfo loggedInInfo, Integer demographicNo, NoteIssueTo1 noteIssue){
        NoteTo1 note = noteIssue.getEncounterNote();
        NoteExtTo1 noteExt = noteIssue.getGroupNoteExt();
        IssueTo1 issue = noteIssue.getIssue();
        List<CaseManagementIssueTo1> assignedCMIssues = noteIssue.getAssignedCMIssues();

        String providerNo=loggedInInfo.getLoggedInProviderNo();
        Provider provider = loggedInInfo.getLoggedInProvider();
        String userName = provider != null ? provider.getFullName() : "";

        String demo = ""+demographicNo;
        String noteId = String.valueOf(note.getNoteId());

        String programId = getProgram(loggedInInfo,providerNo);

        CaseManagementNote caseMangementNote  = new CaseManagementNote();
        boolean newNote = false;

        // we don't want to try to remove an issue from a new note so we test here
        if(note.getNoteId()==null || note.getNoteId()==0){
            newNote = true;
        }else{
            boolean extChanged = true; //false
            // if note has not changed don't save
            caseManagementManager.getNote(noteId);
            if ( note.getNote().equals(note.getNote()) && issue.isIssueChange() && !extChanged && note.isArchived() ) return null;
        }

        caseMangementNote.setDemographic_no(demo);

        if(!newNote) {
            if (note.isArchived() ){
                caseMangementNote.setArchived(true);
            }
            note.setRevision(Integer.parseInt(note.getRevision())+1 + "");
        }


        if(note.getUuid() != null && !note.getUuid().trim().equals("")){
            caseMangementNote.setUuid(note.getUuid());
        }

        String noteTxt = note.getNote();
        noteTxt = org.apache.commons.lang.StringUtils.trimToNull(noteTxt);
        if (noteTxt == null || noteTxt.equals("")) return null;

        caseMangementNote.setNote(noteTxt);

        CaseManagementCPP cpp = this.caseManagementManager.getCPP(demo);
        if (cpp == null) {
            cpp = new CaseManagementCPP();
            cpp.setDemographic_no(demo);
        }

        if(note.isCpp() && note.getSummaryCode()!=null){
            cpp = copyNote2cpp(cpp, note.getNote(), note.getSummaryCode());
        }

        ProgramManager programManager = (ProgramManager) SpringUtils.getBean("programManager");
        AdmissionManager admissionManager = (AdmissionManager) SpringUtils.getBean("admissionManager");

        String role = null;
        String team = null;

        try {
            role = String.valueOf((programManager.getProgramProvider(providerNo, programId)).getRole().getId());
        } catch (Exception e) {
            logger.error("Error", e);
            role = "0";
        }

        caseMangementNote.setReporter_caisi_role(role);

        try {
            team = String.valueOf((admissionManager.getAdmission(programId, demographicNo)).getTeamId());
        } catch (Exception e) {
            logger.error("Error", e);
            team = "0";
        }
        caseMangementNote.setReporter_program_team(team);

        //Need to check some how that if a note is signed that it must stay signed, currently this is done in the interface where the save button is not available.
        if(note.getIsSigned()){
            caseMangementNote.setSigning_provider_no(providerNo);
            caseMangementNote.setSigned(true);
        } else {
            caseMangementNote.setSigning_provider_no("");
            caseMangementNote.setSigned(false);
        }

        caseMangementNote.setProviderNo(providerNo);
        if (provider != null) caseMangementNote.setProvider(provider);


        caseMangementNote.setProgram_no(programId);

        //this code basically updates the CPP note with which issues were removed
        if(!newNote) {
            List<String> removedIssueNames = new ArrayList<String>();
            for(CaseManagementIssueTo1 cmit : assignedCMIssues) {
                if(cmit.isUnchecked() && cmit.getId() != null && cmit.getId().longValue()>0) {
                    //we want to remove this association, and append to the note
                    removedIssueNames.add(cmit.getIssue().getDescription());
                }
            }

            if(!removedIssueNames.isEmpty()) {
                String text =  new SimpleDateFormat("dd-MMM-yyyy").format(new Date()) + " " + "Removed following issue(s)" + ":\n" + StringUtils.join(removedIssueNames, ",");
                caseMangementNote.setNote(caseMangementNote.getNote() + "\n" + text);
            }
        }
        
        List<CaseManagementIssue> issuelist = new ArrayList<CaseManagementIssue>();

        for(CaseManagementIssueTo1 i:assignedCMIssues) {
            if(!i.isUnchecked()) {
                CaseManagementIssue cmi = caseManagementManager.getIssueByIssueCode(demo, i.getIssue().getCode());
                if (cmi==null) {
                    //new one
                    cmi = new CaseManagementIssue();
                    Issue is = issueDao.getIssue(i.getIssue().getId());
                    cmi.setIssue_id(is.getId());
                    cmi.setIssue(is);
                    cmi.setProgram_id(programManager2.getCurrentProgramInDomain(loggedInInfo, loggedInInfo.getLoggedInProviderNo()).getProgramId().intValue());
                    cmi.setType(is.getRole());
                    cmi.setDemographic_no(Integer.valueOf(demo));
                }
                cmi.setAcute(i.isAcute());
                cmi.setCertain(i.isCertain());
                cmi.setMajor(i.isMajor());
                cmi.setResolved(i.isResolved());

                issuelist.add(cmi);
                caseManagementManager.saveCaseIssue(cmi);
            }
        }

        //this is actually just the issue for the main note
        //translate summary codes
        String issueCode = note.getSummaryCode();//set temp
        if("ongoingconcerns".equals(issueCode)){
            issueCode = "Concerns";
        }else if("medhx".equals(issueCode)){
            issueCode = "MedHistory";
        }else if("reminders".equals(issueCode)){
            issueCode = "Reminders";
        }else if("othermeds".equals(issueCode)){
            issueCode = "OMeds";
        }else if("sochx".equals(issueCode)){
            issueCode = "SocHistory";
        }else if("famhx".equals(issueCode)){
            issueCode = "FamHistory";
        }else if("riskfactors".equals(issueCode)){
            issueCode = "RiskFactors";
        }
        
        Issue cppIssue = caseManagementManager.getIssueInfoByCode(issueCode);
        
        CaseManagementIssue cIssue;
        cIssue = caseManagementManager.getIssueByIssueCode(demo, issueCode);

        //no issue existing for this type of CPP note..create and save it
        if( cIssue == null ) {
            Date creationDate = new Date();

            cIssue = new CaseManagementIssue();
            cIssue.setAcute(false);
            cIssue.setCertain(false);
            cIssue.setDemographic_no(Integer.valueOf(demo));
            cIssue.setIssue_id(cppIssue.getId());
            cIssue.setMajor(false);
            cIssue.setProgram_id(Integer.parseInt(programId));
            cIssue.setResolved(false);
            cIssue.setType(cppIssue.getRole());
            cIssue.setUpdate_date(creationDate);

            caseManagementManager.saveCaseIssue(cIssue);
        }

        //save the associations
        issuelist.add(cIssue);
        
        note.setIssues(new HashSet<CaseManagementIssue>(issuelist));
        caseMangementNote.setIssues(new HashSet<CaseManagementIssue>(issuelist));

        // update appointment and add verify message to note if verified
        boolean verify = false;

        Date now = new Date();

        Date observationDate = note.getObservationDate();
        if (observationDate != null && !observationDate.equals("")) {
            if (observationDate.getTime() > now.getTime()) {
                caseMangementNote.setObservation_date(now);
            } else{
                caseMangementNote.setObservation_date(observationDate);
            }
        } else if (note.getObservationDate() == null) {
            caseMangementNote.setObservation_date(now);
        }

        caseMangementNote.setUpdate_date(now);
        if(note.getAppointmentNo() != null) {
            caseMangementNote.setAppointmentNo(note.getAppointmentNo());
        }


        //update positions
        /*
         * There's a few cases to handle, but basically when user is adding, editing, or archiving,
         * we go and set the positions so it's always 1,2,..,n across the group note. Archived notes,
         * and older notes (not the latest based on uuid/id) have positions set to 0
         */
        String[] strIssueId = { String.valueOf(cppIssue.getId()) };
        List<CaseManagementNote> curCPPNotes = this.caseManagementManager.getActiveNotes(demo, strIssueId);
        Collections.sort(curCPPNotes,CaseManagementNote.getPositionComparator());


        if(note.isArchived()) {
            //this one will basically assign 1,2,3,..,n to the group and ignore the one to be archived..setting it's position to 0
            int positionToAssign=1;
            for(int x=0;x<curCPPNotes.size();x++) {
                if(curCPPNotes.get(x).getUuid().equals(note.getUuid())) {
                    curCPPNotes.get(x).setPosition(0);
                    caseManagementManager.updateNote(curCPPNotes.get(x));
                    continue;
                }
                curCPPNotes.get(x).setPosition(positionToAssign);
                caseManagementManager.updateNote(curCPPNotes.get(x));
                positionToAssign++;
            }

        } else {
            List<CaseManagementNote> curCPPNotes2 = new ArrayList<CaseManagementNote>();
            for(CaseManagementNote cn:curCPPNotes) {
                if(!cn.getUuid().equals(note.getUuid())) {
                    curCPPNotes2.add(cn);
                } else {
                    cn.setPosition(0);
                    caseManagementManager.updateNote(cn);
                }
            }
            //we make a fake CaseManagementNoteEntry into curCPPNotes, and insert it into desired location. 
            //we then just set the positions to 1,2,...,n ignoring the fake one, but still incrementing the positionToAssign variable
            //when the new note is saved.it will have the missing position.
            int positionToAssign=1;
            CaseManagementNote xn = new CaseManagementNote();
            xn.setId(-1L);
            if(note.getPosition() > 0 || note.getPosition() < curCPPNotes2.size()) {
                curCPPNotes2.add(note.getPosition() - 1, xn);
            }
            for(int x=0;x<curCPPNotes2.size();x++) {
                if(curCPPNotes2.get(x).getId() != -1L) {
                    //update the note
                    curCPPNotes2.get(x).setPosition(positionToAssign);
                    caseManagementManager.updateNote(curCPPNotes2.get(x));
                }
                if(curCPPNotes2.get(x).getId() != -1L && curCPPNotes2.get(x).getUuid().equals(note.getUuid())) {
                    curCPPNotes2.get(x).setPosition(0);
                    caseManagementManager.updateNote(curCPPNotes2.get(x));
                    positionToAssign--;
                }
                positionToAssign++;
            }
        }
        if(!note.isArchived()) {
            caseMangementNote.setPosition(note.getPosition());
        }
        
        String savedStr = caseManagementManager.saveNote(cpp, caseMangementNote, providerNo, userName, null, note.getRoleName());
        caseManagementManager.saveCPP(cpp, providerNo);

        caseManagementManager.getEditors(caseMangementNote);
        
        note.setNoteId(Integer.parseInt(""+caseMangementNote.getId()));
        note.setUuid(caseMangementNote.getUuid());
        note.setUpdateDate(caseMangementNote.getUpdate_date());
        note.setObservationDate(caseMangementNote.getObservation_date());
        logger.debug("note should return like this " + note.getNote() );
        
        long newNoteId =  Long.valueOf(note.getNoteId());

        logger.debug("ISSUES LIST START for note " + newNoteId);
        CaseManagementIssueNotesDao cmeIssueNotesDao = (CaseManagementIssueNotesDao) SpringUtils.getBean("caseManagementIssueNotesDao");
        List<CaseManagementIssue> issuesList = cmeIssueNotesDao.getNoteIssues(note.getNoteId());
        for (CaseManagementIssue issueItem : issuesList) {
            logger.debug("ISSUES LIST " + issueItem + " for note " + newNoteId);
        }

        if(note.getNoteId()!=0){
            caseManagementManager.addNewNoteLink(newNoteId);
        }

        /* save extra fields */
        CaseManagementNoteExt cme = new CaseManagementNoteExt();

        if(noteExt.getStartDate()!=null){
            cme.setNoteId(newNoteId);
            cme.setKeyVal(NoteExtTo1.STARTDATE);
            cme.setDateValue(noteExt.getStartDate());
            caseManagementManager.saveNoteExt(cme);
        }

        if(noteExt.getResolutionDate()!=null){
            cme.setNoteId(newNoteId);
            cme.setKeyVal(NoteExtTo1.RESOLUTIONDATE);
            cme.setDateValue(noteExt.getResolutionDate());
            caseManagementManager.saveNoteExt(cme);
        }

        if(noteExt.getProcedureDate()!=null){
            cme.setNoteId(newNoteId);
            cme.setKeyVal(NoteExtTo1.PROCEDUREDATE);
            cme.setDateValue(noteExt.getProcedureDate());
            caseManagementManager.saveNoteExt(cme);
        }

        if(noteExt.getAgeAtOnset()!=null){
            cme.setNoteId(newNoteId);
            cme.setKeyVal(NoteExtTo1.AGEATONSET);
            cme.setDateValue((Date) null);
            cme.setValue(noteExt.getAgeAtOnset());
            caseManagementManager.saveNoteExt(cme);
        }

        if(noteExt.getTreatment()!=null){
            cme.setNoteId(newNoteId);
            cme.setKeyVal(NoteExtTo1.TREATMENT);
            cme.setDateValue((Date) null);
            cme.setValue(noteExt.getTreatment());
            caseManagementManager.saveNoteExt(cme);
        }

        if(noteExt.getProblemStatus()!=null){
            cme.setNoteId(newNoteId);
            cme.setKeyVal(NoteExtTo1.PROBLEMSTATUS);
            cme.setDateValue((Date) null);
            cme.setValue(noteExt.getProblemStatus());
            caseManagementManager.saveNoteExt(cme);
        }

        if(noteExt.getExposureDetail()!=null){
            cme.setNoteId(newNoteId);
            cme.setKeyVal(NoteExtTo1.EXPOSUREDETAIL);
            cme.setDateValue((Date) null);
            cme.setValue(noteExt.getExposureDetail());
            caseManagementManager.saveNoteExt(cme);
        }

        if(noteExt.getRelationship()!=null){
            cme.setNoteId(newNoteId);
            cme.setKeyVal(NoteExtTo1.RELATIONSHIP);
            cme.setDateValue((Date) null);
            cme.setValue(noteExt.getRelationship());
            caseManagementManager.saveNoteExt(cme);
        }

        if(noteExt.getLifeStage()!=null){
            cme.setNoteId(newNoteId);
            cme.setKeyVal(NoteExtTo1.LIFESTAGE);
            cme.setDateValue((Date) null);
            cme.setValue(noteExt.getLifeStage());
            caseManagementManager.saveNoteExt(cme);
        }

        if(noteExt.getHideCpp()!=null){
            cme.setNoteId(newNoteId);
            cme.setKeyVal(NoteExtTo1.HIDECPP);
            cme.setDateValue((Date) null);
            cme.setValue(noteExt.getHideCpp());
            caseManagementManager.saveNoteExt(cme);
        }

        if(noteExt.getProblemDesc()!=null){
            cme.setNoteId(newNoteId);
            cme.setKeyVal(NoteExtTo1.PROBLEMDESC);
            cme.setDateValue((Date) null);
            cme.setValue(noteExt.getProblemDesc());
            caseManagementManager.saveNoteExt(cme);
        }

        if(noteExt.getProcedure()!=null){
            cme.setNoteId(newNoteId);
            cme.setKeyVal(NoteExtTo1.PROCEDURE);
            cme.setDateValue((Date) null);
            cme.setValue(noteExt.getProcedure());
            caseManagementManager.saveNoteExt(cme);
        }

        /* save extra fields */
        noteIssue.setEncounterNote(note);
        noteIssue.setGroupNoteExt(noteExt);

        return noteIssue;

    }

    public String getProgram(LoggedInInfo loggedInInfo,String providerNo){
        ProgramProvider pp = programManager2.getCurrentProgramInDomain(loggedInInfo,providerNo);
        String programId = null;

        if(pp !=null && pp.getProgramId() != null){
            programId = ""+pp.getProgramId();
        }else{
            programId = String.valueOf(programManager.getProgramIdByProgramName("OSCAR")); //Default to the oscar program if provider hasn't been assigned to a program
        }
        return programId;
    }

    protected CaseManagementCPP copyNote2cpp(CaseManagementCPP cpp, String note, String code) {
        //TODO: change this back to a loop
        StringBuilder text = new StringBuilder();
        Date d = new Date();
        String separator = "\n-----[[" + d + "]]-----\n";

        if (code.equals("othermeds")) {
            text.append(cpp.getFamilyHistory());
            text.append(separator);
            text.append(note);
            cpp.setFamilyHistory(text.toString());

        } else if (code.equals("sochx")) {
            text.append(cpp.getSocialHistory());
            text.append(separator);
            text.append(note);
            cpp.setSocialHistory(text.toString());

        } else if (code.equals("medhx")) {
            text.append(cpp.getMedicalHistory());
            text.append(separator);
            text.append(note);
            cpp.setMedicalHistory(text.toString());

        } else if (code.equals("ongoingconcerns")) {
            text.append(cpp.getOngoingConcerns());
            text.append(separator);
            text.append(note);
            cpp.setOngoingConcerns(text.toString());

        } else if (code.equals("reminders")) {
            text.append(cpp.getReminders());
            text.append(separator);
            text.append(note);
            cpp.setReminders(text.toString());

        } else if (code.equals("famhx")) {
            text.append(cpp.getFamilyHistory());
            text.append(separator);
            text.append(note);
            cpp.setFamilyHistory(text.toString());

        } else if (code.equals("riskfactors")) {
            text.append(cpp.getRiskFactors());
            text.append(separator);
            text.append(note);
            cpp.setRiskFactors(text.toString());

        }

        return cpp;
    }

}
