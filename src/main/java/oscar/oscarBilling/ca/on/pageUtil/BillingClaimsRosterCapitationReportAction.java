package oscar.oscarBilling.ca.on.pageUtil;

import com.cognos.developer.Dataset;
import com.cognos.developer.Row;
import net.sf.json.JSONObject;
import org.apache.log4j.Logger;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.actions.DispatchAction;
import org.oscarehr.PMmodule.dao.ProviderDao;
import org.oscarehr.common.dao.DemographicDao;
import org.oscarehr.common.model.Demographic;
import org.oscarehr.util.MiscUtils;
import org.oscarehr.util.SpringUtils;
import oscar.OscarProperties;
import oscar.util.StringUtils;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.xml.bind.JAXBContext;
import javax.xml.bind.Unmarshaller;
import javax.xml.transform.stream.StreamSource;
import java.io.File;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;


public class BillingClaimsRosterCapitationReportAction extends DispatchAction {

    private Logger logger = MiscUtils.getLogger();
    private SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");

    private String INBOX = OscarProperties.getInstance().getProperty("ONEDT_INBOX");
    private String ARCHIVE = OscarProperties.getInstance().getProperty("ONEDT_ARCHIVE");
    
    private DemographicDao demographicDao = SpringUtils.getBean(DemographicDao.class);
    private ProviderDao providerDao = SpringUtils.getBean(ProviderDao.class);


    /**
     * generateRCXDemographics
     * 
     * Generates sorted list of demographics for RCX reports
     * 
     * @param mapping
     * @param form
     * @param request
     * @param response
     * @return null
     * @throws ServletException
     * @throws IOException
     */
    public ActionForward generateRCXDemographics(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException  {
        String filename = StringUtils.noNull(request.getParameter("filename"));
        String reportDateValue = StringUtils.noNull(request.getParameter("reportDate"));

        File file = new File(INBOX + "/" + filename);
        if (!file.exists()){
            // if file does not exist in the inbox, try and open it from the archive
            file = new File(ARCHIVE + "/" + filename);
        }

        Dataset dataset = getDataset(file);
        
        List<Row> allRows = dataset != null && dataset.getData() != null ? dataset.getData().getRow() : new ArrayList<Row>();

        HashMap<String, List<Row>> sortedDemographics = new HashMap<>();
        // lists for categories
        List<Row> pending = new ArrayList<>();
        List<Row> newlyRostered = new ArrayList<>();
        List<Row> terminated = new ArrayList<>();
        List<Row> missing = new ArrayList<>();
        List<Row> existing = new ArrayList<>();

        
        try {
            Calendar reportDate = Calendar.getInstance();
            reportDate.setTime(dateFormat.parse(reportDateValue));
            int reportDateYear = reportDate.get(Calendar.YEAR);
            int reportDateMonth = reportDate.get(Calendar.MONTH);

            Pattern hcPattern = Pattern.compile("[0-9]{10}");
            
            for (Row row : allRows) {
                boolean demographicUpdated = false;
                if (row.getValue().get(0) != null) {
                    String hinValue = row.getValue().get(0).getValue();
                    Matcher hcMatch = hcPattern.matcher(hinValue);
                    Demographic demographic = null;

                    if (hcMatch.find()) {
                        // demographic row
                        List<Demographic> matchingDemographics = demographicDao.getDemographicsByHealthNum(hinValue);
                        
                        Row.Value demographicNoVal = new Row.Value();
                        if (matchingDemographics.isEmpty()) {
                            // no matching demographic
                            demographicNoVal.setValue("0");
                            row.getValue().add(demographicNoVal);
                            
                            // add to missing list
                            missing.add(row);
                        } else {
                            // demographic match found
                            demographic = matchingDemographics.get(0);
                            demographicNoVal.setValue(String.valueOf(demographic.getDemographicNo()));
                            row.getValue().add(demographicNoVal);

                            if ("RO".equals(demographic.getRosterStatus())) {
                                // if rostered, check other values to determine appropriate list
                                try {
                                    String rosterStartVal = row.getValue().get(6) != null ? row.getValue().get(6).getValue() : "";
                                    String rosterEndVal = row.getValue().get(7) != null ? row.getValue().get(7).getValue() : "";
                                    String terminationCode = row.getValue().get(8) != null ? row.getValue().get(8).getValue() : "";
                                    boolean isPending = row.getValue().get(9) != null && row.getValue().get(9).getValue().equals("P");

                                    if (!rosterStartVal.isEmpty()) {
                                        // if roster start date exists
                                       
                                        Calendar rosterStart = Calendar.getInstance();
                                        rosterStart.setTime(dateFormat.parse(rosterStartVal));
                                        int rosterStartYear = rosterStart.get(Calendar.YEAR);
                                        int rosterStartMonth = rosterStart.get(Calendar.MONTH);
                                        
                                        // check pending status, then compare start and end dates
                                        if (isPending) {
                                            // pending
                                            pending.add(row);
                                        } else if (rosterStartYear == reportDateYear && rosterStartMonth == reportDateMonth) {
                                            // newly rostered
                                            newlyRostered.add(row);
                                        } else if (!rosterEndVal.isEmpty() && !terminationCode.isEmpty()) {
                                            // terminated
                                            terminated.add(row);
                                            Calendar rosterEnd = Calendar.getInstance();
                                            rosterEnd.setTime(dateFormat.parse(rosterEndVal));
                                            Calendar terminationDate = Calendar.getInstance();
                                            terminationDate.setTime(demographic.getRosterTerminationDate() != null ? demographic.getRosterTerminationDate() : new Date());
                                            
                                            if (!"TE".equals(demographic.getRosterStatus()) || !terminationDate.equals(rosterEnd)) {
                                                // update demographic information
                                                demographic.setRosterStatus("TE");
                                                demographic.setRosterTerminationDate(rosterEnd.getTime());
                                                demographic.setRosterTerminationReason(terminationCode);
                                                demographicUpdated = true;
                                            }
                                            
                                        } else {
                                            // existing
                                            existing.add(row);
                                        }
                                    } else {
                                        // no roster start date specified, add to existing
                                        existing.add(row);
                                    }
                                } catch (Exception e) {
                                    logger.error("ERROR:", e);
                                }
                            }

                            try {
                                if (demographicUpdated) {
                                    demographicDao.save(demographic);
                                }
                            } catch (Exception ex) {
                                logger.error("ERROR updating demographic:", ex);
                            }
                        }
                    }
                }
            }
        } catch (Exception e) {
            logger.error("ERROR:", e);
        }

        sortedDemographics.put("pending", pending);
        sortedDemographics.put("newlyRostered", newlyRostered);
        sortedDemographics.put("terminated", terminated);
        sortedDemographics.put("missing", missing);
        sortedDemographics.put("existing", existing);
        try {
            JSONObject jsonObject = new JSONObject();
            jsonObject.put("sortedDemographics", sortedDemographics);
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write(jsonObject.toString());
        } catch (IOException e) {
            logger.error("Error writing response.", e);
        }
        return null;
    }

    /**
     * unspecified
     * 
     * Handles request when method parameters is unspecified, forwarding it to the view page
     * 
     * @param mapping
     * @param form
     * @param request
     * @param response
     * @return forward to view
     * @throws ServletException
     * @throws IOException
     */
    public ActionForward unspecified(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        return mapping.findForward("view");
    }


    /**
     * Unmarshall XML to Dataset object
     * @param file
     * @return
     */
    public Dataset getDataset(File file) {
        Dataset dataset = null;
        try {
            JAXBContext jaxbContext = JAXBContext.newInstance(Dataset.class);
            Unmarshaller unmarshaller = jaxbContext.createUnmarshaller();
            dataset = (Dataset) unmarshaller.unmarshal(new StreamSource(file));
        }
        catch (Exception e){
            logger.error("ERROR:", e);
        }
        return dataset;
    }



}
