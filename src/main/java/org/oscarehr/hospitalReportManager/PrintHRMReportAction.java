package org.oscarehr.hospitalReportManager;

import org.apache.log4j.Logger;
import org.apache.struts.action.Action;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.oscarehr.common.dao.DemographicDao;
import org.oscarehr.common.model.Demographic;
import org.oscarehr.hospitalReportManager.dao.HRMDocumentToDemographicDao;
import org.oscarehr.managers.SecurityInfoManager;
import org.oscarehr.util.LoggedInInfo;
import org.oscarehr.util.MiscUtils;
import org.oscarehr.util.SpringUtils;
import oscar.OscarProperties;
import oscar.util.ConcatPDF;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

public class PrintHRMReportAction extends Action {

    private static final Logger logger = MiscUtils.getLogger();

    private SecurityInfoManager securityInfoManager = SpringUtils.getBean(SecurityInfoManager.class);

    public ActionForward execute(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws IOException {
        LoggedInInfo loggedInInfo = LoggedInInfo.getLoggedInInfoFromSession(request);
        if(!securityInfoManager.hasPrivilege(loggedInInfo, "_hrm", "r", null)) {
            throw new SecurityException("missing required security object (_hrm)");
        }

        String demographicNo = null;
        Demographic demographic = null;
        DemographicDao demographicDao = SpringUtils.getBean(DemographicDao.class);
        HRMDocumentToDemographicDao hrmDocumentToDemographicDao = SpringUtils.getBean(HRMDocumentToDemographicDao.class);

        List<Object> pdfDocs = new ArrayList<Object>();
        File fileTemp = null;
        FileOutputStream osTemp = null;

        try {
            String[] hrmReportIds = request.getParameterValues("hrmReportId");
            String fileName = "";
            response.setContentType("application/pdf");  //octet-stream


            for (int i = 0; i < hrmReportIds.length; i++) {
                if (hrmDocumentToDemographicDao.findByHrmDocumentId(hrmReportIds[i])!=null && !hrmDocumentToDemographicDao.findByHrmDocumentId(hrmReportIds[i]).isEmpty()){
                    demographicNo = hrmDocumentToDemographicDao.findByHrmDocumentId(hrmReportIds[i]).get(0).getDemographicNo();
                    demographic = demographicDao.getDemographic(demographicNo);
                }

                String fileTempName = "";
                if (demographic!=null){
                    fileTempName = OscarProperties.getInstance().getProperty("DOCUMENT_DIR") + "//" + demographic.getLastName() + "_" + demographic.getFirstName() + "_" + hrmReportIds[i] + "_HRMReport.pdf";
                    fileName = demographic.getLastName() + "_" + demographic.getFirstName() +  "_HRMReport" + "_" + (new Date().getTime()) + ".pdf";
                } else {
                    fileTempName = OscarProperties.getInstance().getProperty("DOCUMENT_DIR") + "//HRMReport.pdf";
                    fileName = "_HRMReport" + "_" + (new Date().getTime()) + ".pdf";
                }
                response.setHeader("Content-Disposition", "attachment; filename=\""+fileName+"\"");

                // Create temporary file
                pdfDocs.add(fileTempName);
                fileTemp = new File(fileTempName);
                osTemp = new FileOutputStream(fileTemp);

                HRMPDFCreator hrmpdfCreator = new HRMPDFCreator(osTemp, hrmReportIds[i], loggedInInfo);
                hrmpdfCreator.printPdf();
            }
            ConcatPDF.concat(pdfDocs, response.getOutputStream());

        }
        catch(IOException e) {
            logger.error("Could not retrieve the Output Stream from the response", e);
            request.setAttribute("printError", true);
            return mapping.findForward("error");
        } finally {
            if (osTemp!=null){
                osTemp.close();
            }
            if (fileTemp!=null){
                fileTemp.delete();
            }
        }


        return mapping.findForward("success");
    }
}
