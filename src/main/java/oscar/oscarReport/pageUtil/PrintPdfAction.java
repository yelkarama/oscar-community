/**
 * Copyright (c) 2001-2002. Department of Family Medicine, McMaster University. All Rights Reserved.
 * This software is published under the GPL GNU General Public License.
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 * <p>
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 * <p>
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 * <p>
 * This software was written for the
 * Department of Family Medicine
 * McMaster University
 * Hamilton
 * Ontario, Canada
 */


package oscar.oscarReport.pageUtil;

import com.lowagie.text.DocumentException;
import com.sun.xml.messaging.saaj.util.ByteInputStream;
import com.sun.xml.messaging.saaj.util.ByteOutputStream;
import net.sf.json.JSONException;
import org.apache.commons.lang.StringEscapeUtils;
import org.apache.http.HttpResponse;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.ContentType;
import org.apache.http.entity.StringEntity;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClientBuilder;
import org.apache.http.protocol.HTTP;
import org.apache.http.util.EntityUtils;
import org.apache.log4j.Logger;
import org.apache.struts.action.Action;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;
import org.oscarehr.common.dao.OscarAppointmentDao;
import org.oscarehr.common.model.Appointment;
import org.oscarehr.util.JsonUtil;
import org.oscarehr.util.LoggedInInfo;
import org.oscarehr.util.SpringUtils;
import org.oscarehr.ws.rest.to.implementations.progressSheet.MockRxInfoRequest;
import org.oscarehr.ws.rest.to.implementations.progressSheet.MockRxInfoResponse;
import oscar.OscarProperties;
import oscar.form.pdfservlet.FrmCustomedPDFGenerator;
import oscar.form.pdfservlet.FrmCustomedPDFParameters;
import oscar.util.ConcatPDF;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.PrintWriter;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Locale;

public class PrintPdfAction extends Action {
    private Logger logger = Logger.getLogger(PrintPdfAction.class);

    @Override
    public ActionForward execute(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String method = request.getParameter("method");
        
        if ("psRxBillingPrint".equals(method)) {
            return psRxBillingPrint(mapping, request, response);
        }
        
        return null;
    }
    
    private ActionForward psRxBillingPrint(ActionMapping mapping, HttpServletRequest request, HttpServletResponse response) throws IOException {
        OscarAppointmentDao appointmentDao = SpringUtils.getBean(OscarAppointmentDao.class);
        SimpleDateFormat sdfDateParser = new SimpleDateFormat("yyyy-M-dd");
        
        // Parse parameters
        String providerNo = request.getParameter("providerNo");
        if (providerNo == null) {
            providerNo = "all";
        }
        String dateString = request.getParameter("forDate");
        Date selectedDate = new Date();
        if (dateString != null) {
            try {
                selectedDate = sdfDateParser.parse(dateString);
            } catch (ParseException e) {
                logger.error("Progress Sheet Rx print error:", e);
                response.setContentType("text/html");
                PrintWriter writer = response.getWriter();
                writer.println("<script>alert('Selected report date " + StringEscapeUtils.escapeJavaScript(dateString) + " is not a valid yyyy-M-dd date.');</script>");
            }
        }

        LoggedInInfo loggedInInfo = LoggedInInfo.getLoggedInInfoFromSession(request);
        Locale locale = request.getLocale();
        
        List<Appointment> providerAppointmentList;
        if (providerNo.equals("all")) {
            providerAppointmentList = appointmentDao.findByDayAndStatusNot(selectedDate, "D");
        } else {
            providerAppointmentList = appointmentDao.findByProviderAndDayandNotStatuses(providerNo, selectedDate, new String[]{"D"});
        }

        MockRxInfoRequest mockRxInfoRequest = new MockRxInfoRequest();
        for (Appointment appointment : providerAppointmentList) {
            mockRxInfoRequest.getAppointmentIds().add(appointment.getId());
        }
        mockRxInfoRequest.getFieldKeys().add("billing_post_procedure_marcaine_xylocaine_syringe_count");

        ArrayList<Object> streams = new ArrayList<Object>();
        if (!mockRxInfoRequest.getAppointmentIds().isEmpty()) {
            String host = request.getRequestURL().substring(0, request.getRequestURL().indexOf(request.getContextPath())); //assume progress sheet is on same system
            String serviceUrl = host + "/progresssheet/" + ProgressSheetMockRxUtils.MOCK_RX_REQUEST_URL;
            if (OscarProperties.getInstance().getProperty("progress_sheet_url") != null) {
                serviceUrl = OscarProperties.getInstance().getProperty("progress_sheet_url") + ProgressSheetMockRxUtils.MOCK_RX_REQUEST_URL;
            }

            CloseableHttpClient httpClient = HttpClientBuilder.create().build();
            HttpPost mockRxPost = new HttpPost(serviceUrl);
            mockRxPost.addHeader(HTTP.CONTENT_TYPE, "application/json");
            mockRxPost.setEntity(new StringEntity(JsonUtil.pojoToJson(mockRxInfoRequest).toString(), ContentType.APPLICATION_JSON));
            List<MockRxInfoResponse> rxInfoResponse = new ArrayList<MockRxInfoResponse>();
            try {
                HttpResponse psResponse = httpClient.execute(mockRxPost);
                rxInfoResponse = (List<MockRxInfoResponse>) JsonUtil.jsonToPojoList(EntityUtils.toString(psResponse.getEntity()), MockRxInfoResponse.class);
                httpClient.close();
            } catch (IOException | JSONException e) {
                logger.error("Progress Sheet Rx print error:", e);
                response.setContentType("text/html");
                PrintWriter writer = response.getWriter();
                writer.println("<script>alert('Unable to access data from progress sheet, please check that it is running and contact support if issue persists');</script>");
            }
            
            if (rxInfoResponse.isEmpty()) {
                response.setContentType("text/html");
                PrintWriter writer = response.getWriter();
                writer.println("<script>alert('The selected date does not have any appointments with printable fields checked');</script>");
            }

            ByteInputStream bis;
            for (MockRxInfoResponse mockRxInfo : rxInfoResponse) {
                FrmCustomedPDFGenerator pdfGenerator = new FrmCustomedPDFGenerator();
                FrmCustomedPDFParameters pdfParameters = ProgressSheetMockRxUtils.createPdfParametersFromResponse(mockRxInfo);
                try {
                    ByteArrayOutputStream pdfBytes = pdfGenerator.generatePDFDocumentBytes(pdfParameters, loggedInInfo, locale);
                    bis = new ByteInputStream(pdfBytes.toByteArray(), pdfBytes.size());
                    streams.add(bis);
                } catch (DocumentException e) {
                    logger.error("Progress Sheet Rx print error:", e);
                    response.setContentType("text/html");
                    PrintWriter writer = response.getWriter();
                    writer.println("<script>alert('Error generating pdf for appointmentNo: " + mockRxInfo.getAppointmentId() + "');</script>");
                }
            }
            if (streams.size() > 0) {
                ByteOutputStream bos = new ByteOutputStream();
                ConcatPDF.concat(streams, bos);
                response.setContentType("application/pdf"); // octet-stream
                response.setHeader("Content-Disposition", "inline; filename=\"psRxPrint-" + dateString + ".pdf\"");
                response.getOutputStream().write(bos.getBytes(), 0, bos.getCount());
            }
        }

        for (Object is : streams) {
            ((InputStream) is).close();
        }
        return null;
    }
}
