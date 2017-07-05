/**
 * Copyright (c) 2001-2002. Department of Family Medicine, McMaster University. All Rights Reserved.
 * This software is published under the GPL GNU General Public License.
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version. 
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 *
 * This software was written for the
 * Department of Family Medicine
 * McMaster University
 * Hamilton
 * Ontario, Canada
 */


/*
 * PrintLabsAction.java
 *
 * Created on November 27, 2007, 9:42 AM
 *
 */

package oscar.oscarLab.ca.all.pageUtil;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.lang.builder.ReflectionToStringBuilder;
import org.apache.log4j.Logger;
import org.apache.struts.action.Action;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.oscarehr.managers.SecurityInfoManager;
import org.oscarehr.util.LoggedInInfo;
import org.oscarehr.util.SpringUtils;
import org.oscarehr.caisi_integrator.ws.CachedDemographicLabResult;
import org.oscarehr.util.MiscUtils;
import org.w3c.dom.Document;

import oscar.OscarProperties;
import oscar.oscarLab.ca.all.Hl7textResultsData;
import oscar.oscarLab.ca.all.parsers.Factory;
import oscar.oscarLab.ca.all.parsers.MessageHandler;
import oscar.oscarLab.ca.all.parsers.OLISHL7Handler;
import oscar.oscarLab.ca.all.web.LabDisplayHelper;

import com.lowagie.text.DocumentException;
import oscar.util.ConcatPDF;

/**
 *
 * @author wrighd
 */
public class PrintLabsAction extends Action{
    
    Logger logger = Logger.getLogger(PrintLabsAction.class);
    private SecurityInfoManager securityInfoManager = SpringUtils.getBean(SecurityInfoManager.class);
    
    /** Creates a new instance of PrintLabsAction */
    public PrintLabsAction() {
    }
    
    public ActionForward execute(ActionMapping mapping,ActionForm form,HttpServletRequest request,HttpServletResponse response){
        
    	if(!securityInfoManager.hasPrivilege(LoggedInInfo.getLoggedInInfoFromSession(request), "_lab", "r", null)) {
			throw new SecurityException("missing required security object (_lab)");
		}
    	
        try {
            if (request.getParameter("method")!=null&& request.getParameter("method").equalsIgnoreCase("combineAndPrint")){
                combineAndPrint(mapping,form,request,response);
                return null;
            }
        	MessageHandler handler;
        	//Gets the remoteFacilityId from the request to see if the lab is at a remote facility
        	String remoteFacilityId = request.getParameter("remoteFacilityId");
        	//Gets the labId and the multiLabId from the request
        	String labId = request.getParameter("segmentID") != null ? request.getParameter("segmentID") : (String)request.getAttribute("segmentID");
        	String multiLabId = request.getParameter("multiId");
        	//Declares dateLabReceived
        	String dateLabReceived = request.getParameter("dateLabReceived");
        	
        	//If the lab is not from a remote facility
        	if (remoteFacilityId == null) { 
        		//Gets the MessageHandler using the segment Id
        		handler = Factory.getHandler(request.getParameter("segmentID"));
        	}
        	else {
        		//Gets the remoteLabKey and the demographicId from the request
        		String remoteLabKey = request.getParameter("remoteLabKey");
        		String demographicId = request.getParameter("demographicId");
        		//Gets the remoteLabResult from the remote facility 
        		CachedDemographicLabResult remoteLabResult = LabDisplayHelper.getRemoteLab(LoggedInInfo.getLoggedInInfoFromSession(request), Integer.parseInt(remoteFacilityId), remoteLabKey,Integer.parseInt(demographicId));
        		//Logs the get
        		MiscUtils.getLogger().debug("retrieved remoteLab:" + ReflectionToStringBuilder.toString(remoteLabResult));
        		//Gets the xmlDocument from the remoteLabResult
        		Document cachedDemographicLabResultXmlData = LabDisplayHelper.getXmlDocument(remoteLabResult);
        		//Gets the MessageHandler from the xml document
        		handler = LabDisplayHelper.getMessageHandler(cachedDemographicLabResultXmlData);
        	}
        	
            if(handler.getHeaders().get(0).equals("CELLPATHR")){//if it is a VIHA RTF lab
                response.setContentType("text/rtf");  //octet-stream
                response.setHeader("Content-Disposition", "attachment; filename=\""+handler.getPatientName().replaceAll("\\s", "_")+"_LabReport.rtf\"");
                LabPDFCreator pdf = new LabPDFCreator(handler, response.getOutputStream(), labId, multiLabId, dateLabReceived);
                pdf.printRtf();
            } else {
	            response.setContentType("application/pdf");  //octet-stream
	            response.setHeader("Content-Disposition", "attachment; filename=\""+handler.getPatientName().replaceAll("\\s", "_")+"_LabReport.pdf\"");
	            LabPDFCreator pdf = new LabPDFCreator(handler, response.getOutputStream(), labId, multiLabId, dateLabReceived);
	            pdf.printPdf();
            }
        }catch(DocumentException de) {
            logger.error("DocumentException occured insided PrintLabsAction", de);
            request.setAttribute("printError", new Boolean(true));
            return mapping.findForward("error");
        }catch(IOException ioe) {
            logger.error("IOException occured insided PrintLabsAction", ioe);
            request.setAttribute("printError", new Boolean(true));
            return mapping.findForward("error");
        }catch(Exception e){
            logger.error("Unknown Exception occured insided PrintLabsAction", e);
            request.setAttribute("printError", new Boolean(true));
            return mapping.findForward("error");
        }
        
        return null;
        
    }

    public ActionForward combineAndPrint(ActionMapping mapping,ActionForm form,HttpServletRequest request,HttpServletResponse response) throws IOException{

        if(!securityInfoManager.hasPrivilege(LoggedInInfo.getLoggedInInfoFromSession(request), "_lab", "r", null)) {
            throw new SecurityException("missing required security object (_lab)");
        }
        LoggedInInfo loggedInInfo = LoggedInInfo.getLoggedInInfoFromSession(request);

        String demographicId = request.getParameter("demographicId");
        List<String> labIds = request.getParameterValues("labNo")!=null ? Arrays.asList(request.getParameterValues("labNo")) : new ArrayList<String>();
        List<Object> pdfDocs = new ArrayList<Object>();

        OutputStream os = null;
        File fileTemp = null;
        FileOutputStream osTemp = null;
        try{
            os = response.getOutputStream();
            if (!labIds.isEmpty()){
                for (String segmentId : labIds){
                    List<String> labs = Arrays.asList(Hl7textResultsData.getMatchingLabs(segmentId).split(","));

                    MessageHandler handler = Factory.getHandler(segmentId);
                    response.setContentType("application/pdf");
                    response.setHeader("Content-Disposition", "attachment;filename=" + handler.getPatientName().replaceAll("\\s", "_") + "_" + handler.getMsgDate() + "_MultiLabReport.pdf");

                    for (String result : labs) {
                        String fileName = OscarProperties.getInstance().getProperty("DOCUMENT_DIR") + "//" + handler.getPatientName().replaceAll("\\s", "_") + "_" + handler.getMsgDate() + "_LabReport.pdf";
                        fileTemp = new File(fileName);
                        osTemp = new FileOutputStream(fileTemp);
                        if (handler instanceof OLISHL7Handler) {
                            OLISLabPDFCreator olisLabPdfCreator = new OLISLabPDFCreator(osTemp, request, result);
                            olisLabPdfCreator.printPdf();
                        } else {
                            LabPDFCreator pdfCreator = new LabPDFCreator(osTemp, result, loggedInInfo.getLoggedInProviderNo());
                            pdfCreator.printPdf();
                        }
                        pdfDocs.add(fileName);
                    }
                }
                ConcatPDF.concat(pdfDocs, os);
            }
        } catch(DocumentException de) {
            logger.error("DocumentException occured insided PrintLabsAction", de);
            request.setAttribute("printError", new Boolean(true));
            return mapping.findForward("error");
        }catch (IOException ioe){
            logger.error("IOException occured insided PrintLabsAction", ioe);
            request.setAttribute("printError", new Boolean(true));
            return mapping.findForward("error");
        } finally {
            if (osTemp!=null) {
                osTemp.close();
            }
            if (fileTemp!=null) {
                fileTemp.delete();
            }
        }

        return null;
    }
    
    
}
