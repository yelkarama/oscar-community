package org.oscarehr.ws.rest.conversion;

import org.oscarehr.common.model.Document;
import org.oscarehr.util.LoggedInInfo;
import org.oscarehr.ws.rest.to.model.DocumentTo1;

public class DocumentConverter extends AbstractConverter<Document, DocumentTo1> {
    @Override
    public Document getAsDomainObject(LoggedInInfo loggedInInfo, DocumentTo1 t) throws ConversionException {
        Document d = new Document();
        
        d.setDocumentNo(t.getId());
        d.setDoctype(t.getType());
        d.setDocClass(t.getDocClass());
        d.setDocSubClass(t.getSubClass());
        d.setDocdesc(t.getDescription());
        d.setDocxml(t.getXml());
        d.setDocfilename(t.getFileName());
        d.setDoccreator(t.getCreator());
        d.setResponsible(t.getResponsible());
        d.setSource(t.getSource());
        d.setSourceFacility(t.getSourceFacility());
        d.setProgramId(t.getProgramId());
        d.setUpdatedatetime(t.getUpdateDateTime());
        d.setStatus(t.getStatus());
        d.setContenttype(t.getContentType());
        d.setContentdatetime(t.getContentDateTime());
        d.setPublic1(t.getPublic1());
        d.setObservationdate(t.getObservationDate());
        int numberOfPages = t.getNumberOfPages() != null ? t.getNumberOfPages() : 0;
        d.setNumberofpages(numberOfPages);
        d.setAppointmentNo(t.getAppointmentNo());
        d.setAbnormal(t.getAbnormal() ? 1 : 0);
        d.setRestrictToProgram(t.getRestrictToProgram());
        
        return d;
    }

    @Override
    public DocumentTo1 getAsTransferObject(LoggedInInfo loggedInInfo, Document d) throws ConversionException {
        DocumentTo1 t = new DocumentTo1();
        
        t.setId(d.getDocumentNo());
        t.setType(d.getDoctype());
        t.setDocClass(d.getDocClass());
        t.setSubClass(d.getDocSubClass());
        t.setDescription(d.getDocdesc());
        t.setXml(d.getDocxml());
        t.setFileName(d.getDocfilename());
        t.setCreator(d.getDoccreator());
        t.setResponsible(d.getResponsible());
        t.setSource(d.getSource());
        t.setSourceFacility(d.getSourceFacility());
        t.setProgramId(d.getProgramId());
        t.setUpdateDateTime(d.getUpdatedatetime());
        t.setStatus(d.getStatus());
        t.setContentType(d.getContenttype());
        t.setContentDateTime(d.getContentdatetime());
        t.setPublic1(d.getPublic1());
        t.setObservationDate(d.getObservationdate());
        t.setNumberOfPages(d.getNumberofpages());
        t.setAppointmentNo(d.getAppointmentNo());
        t.setAbnormal(d.getAbnormal() > 0);
        t.setRestrictToProgram(d.isRestrictToProgram());

        return t;
    }
}