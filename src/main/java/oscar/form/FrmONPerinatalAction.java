package oscar.form;

import net.sf.jasperreports.engine.JREmptyDataSource;
import net.sf.jasperreports.engine.JRException;
import net.sf.jasperreports.engine.JasperCompileManager;
import net.sf.jasperreports.engine.JasperExportManager;
import net.sf.jasperreports.engine.JasperFillManager;
import net.sf.jasperreports.engine.JasperPrint;
import net.sf.jasperreports.engine.JasperReport;
import net.sf.jasperreports.engine.export.JRPdfExporter;
import net.sf.jasperreports.export.SimpleExporterInput;
import net.sf.jasperreports.export.SimpleOutputStreamExporterOutput;
import net.sf.jasperreports.export.SimplePdfReportConfiguration;
import net.sf.json.JSONArray;
import net.sf.json.JSONObject;
import net.sf.json.JSONSerializer;
import org.apache.commons.lang.StringUtils;
import org.apache.commons.lang.math.NumberUtils;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.actions.DispatchAction;
import org.oscarehr.PMmodule.dao.ProviderDao;
import org.oscarehr.common.dao.DemographicDao;
import org.oscarehr.common.dao.PrintResourceLogDao;
import org.oscarehr.common.model.AbstractModel;
import org.oscarehr.common.model.Demographic;

import org.oscarehr.common.model.PrintResourceLog;
import org.oscarehr.managers.SecurityInfoManager;
import org.oscarehr.util.LoggedInInfo;
import org.oscarehr.util.MiscUtils;
import org.oscarehr.util.SpringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import oscar.form.dao.ONPerinatal2017CommentDao;
import oscar.form.dao.ONPerinatal2017Dao;
import oscar.form.model.FormONPerinatal2017;
import oscar.form.model.FormONPerinatal2017Comment;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.OutputStream;
import java.net.URISyntaxException;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.Hashtable;
import java.util.List;
import java.util.Map;
import java.util.Properties;
import java.util.Set;

public class FrmONPerinatalAction extends DispatchAction {
    private DemographicDao demographicDao = SpringUtils.getBean(DemographicDao.class);
    private ONPerinatal2017Dao recordDao = SpringUtils.getBean(ONPerinatal2017Dao.class);
    private ONPerinatal2017CommentDao commentDao = SpringUtils.getBean(ONPerinatal2017CommentDao.class);
    
    private SecurityInfoManager securityInfoManager = SpringUtils.getBean(SecurityInfoManager.class);
    private final Logger logger = LoggerFactory.getLogger(FrmONPerinatalRecord.class);
    
    private final String RECORD_NAME = "ONPerinatal";
    
    private SimpleDateFormat formDateFormat = new SimpleDateFormat( "yyyy/MM/dd");

    private List<FormONPerinatal2017> addRecords = new ArrayList<>();
    private Map<String, String> currentValues = new HashMap<String, String>();
    private List<FormONPerinatal2017> updateRecords = new ArrayList<>();
   
    private List<FormONPerinatal2017> currentRecords = new ArrayList<FormONPerinatal2017>();

    public FrmONPerinatalAction() { }

    public ActionForward unspecified(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) {
        return mapping.findForward("pg1");
    }
    public ActionForward loadPage(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
        Integer formId = StringUtils.isNotEmpty(request.getParameter("formId")) ? Integer.parseInt(request.getParameter("formId")) : 0;
        Integer pageNo = StringUtils.isNotEmpty(request.getParameter("page_no")) ? Integer.parseInt(request.getParameter("page_no")) : 1;
        Integer demographicNo = Integer.parseInt(request.getParameter("demographic_no"));

        if(!securityInfoManager.hasPrivilege(LoggedInInfo.getLoggedInInfoFromSession(request), "_demographic", "r", demographicNo)) {
            throw new SecurityException("missing required security object (_demographic)");
        }
        
        Demographic demographic = demographicDao.getDemographicById(demographicNo);
        JSONObject jsonRecord = new JSONObject();
        List <FormONPerinatal2017> records = new ArrayList<FormONPerinatal2017>();

        if (formId <= 0) {
            jsonRecord.put("c_lastName", StringUtils.trimToEmpty(demographic.getLastName()));
            jsonRecord.put("c_firstName", StringUtils.trimToEmpty(demographic.getFirstName()));
            jsonRecord.put("c_hin", demographic.getHin());

            if ("ON".equals(demographic.getHcType())) {
                jsonRecord.put("c_hinType", "OHIP");
            } else if ("QC".equals(demographic.getHcType())) {
                jsonRecord.put("c_hinType", "RAMQ");
            } else {
                jsonRecord.put("c_hinType", "OTHER");
            }
            jsonRecord.put("c_fileNo", StringUtils.trimToEmpty(demographic.getChartNo()));

            jsonRecord.put("formCreated", formDateFormat.format(new Date()));
            
        }
        else {
            // get common fields from other pages
            records.addAll(recordDao.findSectionRecords(formId, pageNo, "c_"));
            records.addAll(recordDao.findRecordsByPage(formId, pageNo));
        }
        
        for (FormONPerinatal2017 record : records) {
            jsonRecord.put(record.getField(), record.getValue());
        }
        
        if (!jsonRecord.has("pg"+pageNo+"_formDate")) {
            jsonRecord.put("pg"+pageNo+"_formDate", formDateFormat.format(new Date()));
        }
        
        Hashtable results = new Hashtable();
        results.put("results", jsonRecord);

        response.setContentType("text/x-json");
        JSONObject jsonArray=(JSONObject) JSONSerializer.toJSON(results);
        jsonArray.write(response.getWriter());
        
        return null;
    }

    public ActionForward save(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
        
        int formId = StringUtils.isNotEmpty(request.getParameter("formId")) ? Integer.parseInt(request.getParameter("formId")) : 0;
        int demographicNo = StringUtils.isNotEmpty(request.getParameter("demographicNo")) ? Integer.parseInt(request.getParameter("demographicNo")) : 0;
        String providerNo = StringUtils.isNotEmpty(request.getParameter("provNo")) ? request.getParameter("provNo") : "0";
        Integer page = StringUtils.isNotEmpty(request.getParameter("pageNo")) ? Integer.parseInt(request.getParameter("pageNo")) : 1;
        Integer forwardTo = StringUtils.isNotEmpty(request.getParameter("forwardTo")) ? Integer.parseInt(request.getParameter("forwardTo")) : page;
        Boolean update = Boolean.valueOf(request.getParameter("update"));

        currentRecords = recordDao.findRecords(formId);
        currentRecords.addAll(getCommentsAsRecords(formId));
        
        addRecords = new ArrayList<>();
        currentValues = getMappedRecords(currentRecords);
        updateRecords = new ArrayList<>();
        List<AbstractModel<?>> persistRecords = new ArrayList<>();
        List<AbstractModel<?>> persistComments = new ArrayList<>();
        
        Set<String> keys = request.getParameterMap().keySet();
        if (!update) {
            formId = recordDao.getNewFormId();

            // copy all current values to new form
            for (FormONPerinatal2017 rec : currentRecords) {
                if (StringUtils.trimToNull(request.getParameter(rec.getValue())) == null) {
                    rec.setId(null);
                    rec.setFormId(formId);
                    addRecords.add(rec);
                }
            }
        }
        
        for (String key : keys) {
            if (key.contains("_")) {
                String value = StringUtils.trimToNull(request.getParameter(key));


                if (currentValues.get(key) != null) {
                    FormONPerinatal2017 record = getRecordByKey(addRecords, key);

                    if (value != null && !value.equals(currentValues.get(key))) {
                        value = value.equals("on") ? "checked" : value;
                        record.setValue(value);
                    } else if (value == null) {
                        record.setValue("");
                    }

                } else if (currentValues.get(key) == null && value != null) {
                    value = value.equals("on") ? "checked" : value;
                    addRecords.add(new FormONPerinatal2017(key, value));
                }
            }
        }
        
        for (FormONPerinatal2017 rec : addRecords) {
            Boolean isComment = rec.getField().contains("comment");
            
            if (rec.getDemographicNo() == null) {
                rec.setDemographicNo(demographicNo);
            }
            
            if (rec.getFormId() == null) {
                rec.setFormId(formId);
            }

            if (rec.getPageNo() == null) {
                rec.setPageNo(page);
            }

            if (rec.getProviderNo() == null) {
                rec.setProviderNo(providerNo);
            }
            
            if (isComment) {
                persistComments.add(new FormONPerinatal2017Comment(rec));
            } else {
                persistRecords.add(rec);
            }
        }
        
        recordDao.batchPersist(persistRecords, 50);
        commentDao.batchPersist(persistComments, 50);
        
        return new ActionForward(mapping.findForward("pg"+forwardTo).getPath()+"?demographic_no=" + demographicNo + "&formId="+formId+"&provNo="+providerNo+"&view=0", true);
    }

    public ActionForward print(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response)  {
        LoggedInInfo loggedInInfo = LoggedInInfo.getLoggedInInfoFromSession(request);
        Integer demographicNo = Integer.parseInt(request.getParameter("demographicNo"));
        
        // Creates a new print resource log item so we can track who has printed the perinatal form
        PrintResourceLog item = new PrintResourceLog();
        item.setDateTime(new Date());
        item.setExternalLocation("None");
        item.setExternalMethod("None");
        item.setProviderNo(loggedInInfo.getLoggedInProviderNo());
        item.setResourceId(demographicNo.toString());
        item.setResourceName("ONPREnhanced");
        
        PrintResourceLogDao printLogDao = SpringUtils.getBean(PrintResourceLogDao.class);
        printLogDao.persist(item);
        
        
        final String RESOURCE_PATH = "/oscar/form/perinatal/page";
        ClassLoader cl = getClass().getClassLoader();
        
        try {
            Integer formId = Integer.parseInt(request.getParameter("formId"));
            FrmONPerinatalRecord perinatalRecord = (FrmONPerinatalRecord)(new FrmRecordFactory()).factory(RECORD_NAME);

            response.setContentType("application/pdf");
            response.setHeader("Content-Disposition", "attachment; filename=\"Perinatal_" + formId + ".pdf\"");
            
            List<Integer> pagesToPrint = new ArrayList<>();
            // Loops through checking which pages were selected for printing
            for (int page = 1; page <= 5; page++) {
                // If a page was selected to print, adds it to the list to print
                if (Boolean.parseBoolean(request.getParameter("printPg" + page))) {
                    pagesToPrint.add(page);
                }
            }

            try (OutputStream os = response.getOutputStream()) {
                List<JasperPrint> pages = new ArrayList<>();
                for (Integer pageNumber : pagesToPrint) {
                    String pageImage = RESOURCE_PATH + pageNumber + ".png";
                    String reportUri = RESOURCE_PATH + pageNumber + ".jrxml";
                    
                    Properties recordData = perinatalRecord.getFormRecord(loggedInInfo, demographicNo, formId, pageNumber);
                    recordData.setProperty("background_image", cl.getResource(pageImage).toString());
                    
                    JasperReport report = JasperCompileManager.compileReport(cl.getResource(reportUri).toURI().getPath());
                    JasperPrint jasperPrint = JasperFillManager.fillReport(report, (Map) recordData, new JREmptyDataSource());
                    
                    pages.add(jasperPrint);
                }

                JRPdfExporter exporter = new JRPdfExporter();
                exporter.setExporterInput(SimpleExporterInput.getInstance(pages));
                exporter.setExporterOutput(new SimpleOutputStreamExporterOutput(os));
                exporter.exportReport();
                
            } catch (IOException e) {
                logger.error("Could not retrieve OutputStream from the response to print the perinatal form", e);
            } catch (URISyntaxException e) {
                logger.error("Could not get URI of the perinatal pages for " + pagesToPrint.toString(), e);
            }
        } catch (NumberFormatException e) {
            logger.error("Could not parse formId for " + request.getParameter("formId"));
        } catch (JRException e) {
            MiscUtils.getLogger().error("Could not parse Report Template for the perinatal form", e);
        } catch (SQLException e) {
            logger.error("Could not retrieve record for Perinatal form", e);
        }
        
        return null;
    }
    
    public ActionForward getPrintData(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) {
        PrintResourceLogDao printLogDao = SpringUtils.getBean(PrintResourceLogDao.class);
        ProviderDao providerDao = SpringUtils.getBean(ProviderDao.class);
        String demographicNo = StringUtils.trimToEmpty(request.getParameter("resourceId"));
        // Gets the print logs for the given demographic
        List<PrintResourceLog> printLogs = printLogDao.findByResource("perinatal", demographicNo);
        
        if (!printLogs.isEmpty()) {
            List<String> providerNumbers = new ArrayList<>();
            // Creates a list of provider numbers to get the provider names for
            for (PrintResourceLog log : printLogs) {
                providerNumbers.add(log.getProviderNo());
            }
            // Gets a map of the provider names for the related provider numbers
            Map<String, String> providerNameMap = providerDao.getProviderNamesByIdsAsMap(providerNumbers);
            // Updates the resource log object wiht the provider's name for display purposes
            for (PrintResourceLog log : printLogs) {
                log.setProviderName(providerNameMap.getOrDefault(log.getProviderNo(), ""));
            }
        }

        try {
            JSONArray json = JSONArray.fromObject(printLogs);
            response.getWriter().print(json.toString());
        } catch (IOException e) {
            logger.warn("Could not print Perinatal printing log", e);
        }
        
        return null;
    }
    
    public static List<FormONPerinatal2017> getCommentsAsRecords(Integer formId) {
        ONPerinatal2017CommentDao commentDao = SpringUtils.getBean(ONPerinatal2017CommentDao.class);
        List<FormONPerinatal2017> commentsAsRecords = new ArrayList<FormONPerinatal2017>();
        List<FormONPerinatal2017Comment> comments = commentDao.findComments(formId);
        
        for (FormONPerinatal2017Comment c : comments) {
            commentsAsRecords.add(new FormONPerinatal2017(c));
        }
        
        return commentsAsRecords;
    }

    public ActionForward getLatestFormIdByDemographic(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) {
        String demographicNo = StringUtils.trimToEmpty(request.getParameter("demographicNo"));
        Integer latestFormId = null;
        // If the demographic number is all digits, it should be parseable to an integer
        if (NumberUtils.isDigits(demographicNo)) {
            // Gets the latest form id for the demographic
            latestFormId = FrmONPerinatalRecord.getLatestFormIdByDemographic(Integer.valueOf(demographicNo));
        }

        try {
            JSONObject json = new JSONObject();
            json.accumulate("formId", String.valueOf(latestFormId));
            response.getWriter().println(json);
        } catch (IOException e) {
            logger.warn("Could not retrieve the lastest Perinatal form id", e); 
        }
        
        return null;
    }
    
    private FormONPerinatal2017 getCommentRecordByKey(List<FormONPerinatal2017Comment> comments, String key) {
        FormONPerinatal2017 record = null;

        for (FormONPerinatal2017Comment rec : comments) {
            if (rec.getField().equals(key)) {
                record = new FormONPerinatal2017(rec);
            }
        }

        return record;
    }
    
    private FormONPerinatal2017 getRecordByKey(List<FormONPerinatal2017> records, String key) {
        FormONPerinatal2017 record = null;

        for (FormONPerinatal2017 rec : records) {
            if (rec.getField().equals(key)) {
                record = rec;
            }
        }

        return record;
    }

    private FormONPerinatal2017 getRecordByKeyAbstract(List<AbstractModel<?>> records, String key) {
        FormONPerinatal2017 record = null;

       
        for (AbstractModel<?> rec : records) {
            if (rec instanceof FormONPerinatal2017) {
                if (((FormONPerinatal2017)rec).getField().equals(key)) {
                    record = (FormONPerinatal2017) rec;
                }
            }
        }

        return record;
    }
    
    private Map<String, String> getMappedRecords(List<FormONPerinatal2017> records) {
        Map<String, String> recordMap = new HashMap<String, String>();

        if (records != null) {
            for (FormONPerinatal2017 record : records) {
                recordMap.put(record.getField(), record.getValue());
            }
        }
        
        return recordMap;
    }
}
