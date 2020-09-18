package org.oscarehr.ws.rest.conversion;

import org.oscarehr.common.model.Document;
import org.oscarehr.util.LoggedInInfo;
import org.oscarehr.ws.rest.to.model.DocumentTo1;

public class DocumentConverter extends AbstractConverter<Document, DocumentTo1> {
    @Override
    public Document getAsDomainObject(LoggedInInfo loggedInInfo, DocumentTo1 t) throws ConversionException {
        Document d = new Document();
        
        d.setDocumentNo(t.getDocumentNo());
        d.setDoctype(t.getDoctype());
        d.setDocClass(t.getDocClass());
        d.setDocSubClass(t.getDocSubClass());
        d.setDocdesc(t.getDocdesc());
        d.setDocxml(t.getDocxml());
        d.setDocfilename(t.getDocfilename());
        d.setDoccreator(t.getDoccreator());
        d.setResponsible(t.getResponsible());
        d.setSource(t.getSource());
        d.setSourceFacility(t.getSourceFacility());
        d.setProgramId(t.getProgramId());
        d.setUpdatedatetime(t.getUpdatedatetime());
        d.setStatus(t.getStatus());
        d.setContenttype(t.getContenttype());
        d.setContentdatetime(t.getContentdatetime());
        d.setPublic1(t.getPublic1());
        d.setObservationdate(t.getObservationdate());
        d.setNumberofpages(t.getNumberofpages());
        d.setAppointmentNo(t.getAppointmentNo());
        d.setAbnormal(t.getAbnormal() ? 1 : 0);
        d.setRestrictToProgram(t.getRestrictToProgram());
        
        return d;
    }

    @Override
    public DocumentTo1 getAsTransferObject(LoggedInInfo loggedInInfo, Document d) throws ConversionException {
        DocumentTo1 t = new DocumentTo1();
        
        t.setDocumentNo(d.getDocumentNo());
        t.setDoctype(d.getDoctype());
        t.setDocClass(d.getDocClass());
        t.setDocSubClass(d.getDocSubClass());
        t.setDocdesc(d.getDocdesc());
        t.setDocxml(d.getDocxml());
        t.setDocfilename(d.getDocfilename());
        t.setDoccreator(d.getDoccreator());
        t.setResponsible(d.getResponsible());
        t.setSource(d.getSource());
        t.setSourceFacility(d.getSourceFacility());
        t.setProgramId(d.getProgramId());
        t.setUpdatedatetime(d.getUpdatedatetime());
        t.setStatus(d.getStatus());
        t.setContenttype(d.getContenttype());
        t.setContentdatetime(d.getContentdatetime());
        t.setPublic1(d.getPublic1());
        t.setObservationdate(d.getObservationdate());
        t.setNumberofpages(d.getNumberofpages());
        t.setAppointmentNo(d.getAppointmentNo());
        t.setAbnormal(d.getAbnormal() > 0);
        t.setRestrictToProgram(d.isRestrictToProgram());

        return t;
    }
}
