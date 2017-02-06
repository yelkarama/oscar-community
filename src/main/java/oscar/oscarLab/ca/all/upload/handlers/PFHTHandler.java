/**
 * Copyright (c) 2008-2012 Indivica Inc.
 *
 * This software is made available under the terms of the
 * GNU General Public License, Version 2, 1991 (GPLv2).
 * License details are available via "indivica.ca/gplv2"
 * and "gnu.org/licenses/gpl-2.0.html".
 */

package oscar.oscarLab.ca.all.upload.handlers;

import java.util.ArrayList;
import java.util.List;
import java.util.ListIterator;

import ca.uhn.hl7v2.model.AbstractMessage;
import ca.uhn.hl7v2.model.v26.message.ADT_A09;
import ca.uhn.hl7v2.parser.PipeParser;
import ca.uhn.hl7v2.validation.impl.NoValidation;
import org.apache.log4j.Logger;
import org.oscarehr.common.dao.Hl7TextInfoDao;
import org.oscarehr.common.hl7.v2.oscar_to_oscar.OscarToOscarUtils;
import org.oscarehr.common.model.Hl7TextInfo;
import org.oscarehr.util.LoggedInInfo;
import org.oscarehr.util.SpringUtils;

import oscar.oscarLab.ca.all.parsers.Factory;
import oscar.oscarLab.ca.all.upload.MessageUploader;
import oscar.oscarLab.ca.all.upload.handlers.OscarToOscarHl7V2.AdtA09Handler;
import oscar.oscarLab.ca.all.util.PFHTUtilities;


public class PFHTHandler implements MessageHandler {
	Logger logger = Logger.getLogger(PFHTHandler.class);
	public static final PipeParser pipeParser = initialisePipeParser();

		private static PipeParser initialisePipeParser() {
			PipeParser pipeParser = new PipeParser();
			pipeParser.setValidationContext(new NoValidation());
			return (pipeParser);
		}

	    public String parse(LoggedInInfo loggedInInfo, String serviceName, String fileName,int fileId, String ipAddr){

	        PFHTUtilities u = new PFHTUtilities();

	        int i = 0;
	        try {
	            ArrayList messages = u.separateMessages(fileName);
	            for (i=0; i < messages.size(); i++){

	                String msg = (String) messages.get(i);

	                // find a replace invalid fields in the OBX segments
					msg = u.handleInvalidSegments(msg, fileName);
					AbstractMessage message= OscarToOscarUtils.pipeParserParse(msg);

					if (message instanceof ADT_A09)
					{
						AdtA09Handler.handle((ADT_A09) message);
					}
					else{
						MessageUploader.routeReport(loggedInInfo, serviceName, "PFHT", msg,fileId);
					}

	            }

	            // Since the gdml labs show more than one lab on the same page when grouped
	            // by accession number their abnormal status must be updated to reflect the
	            // other labs that they are grouped with aswell
	            updateLabStatus(messages.size());
	            logger.info("Parsed OK");
	        } catch (Exception e) {
	        	MessageUploader.clean(fileId);
	            logger.error("Could not upload message", e);
	            return null;
	        }
	        return("success");

	    }


	    // recheck the abnormal status of the last 'n' labs
	    private void updateLabStatus(int n) {

	    	Hl7TextInfoDao hl7TextInfoDao = (Hl7TextInfoDao) SpringUtils.getBean("hl7TextInfoDao");
			 List<Hl7TextInfo> labList = hl7TextInfoDao.getAllLabsByLabNumberResultStatus();
			 ListIterator<Hl7TextInfo> iter = labList.listIterator();

			 while (iter.hasNext() && n>0) {
				 if (!iter.next().getResultStatus().equals("A")) {
					 oscar.oscarLab.ca.all.parsers.MessageHandler h = Factory.getHandler(((Integer)iter.next().getLabNumber()).toString());

		                int i=0;
		                int j=0;
		                String resultStatus = "";
		                while(resultStatus.equals("") && i < h.getOBRCount()){
		                    j = 0;
		                    while(resultStatus.equals("") && j < h.getOBXCount(i)){
		                        logger.info("obr("+i+") obx("+j+") abnormal ? : "+h.getOBXAbnormalFlag(i, j));
		                        if(h.isOBXAbnormal(i, j)){
		                            resultStatus = "A";
		                            hl7TextInfoDao.updateResultStatusByLabId("A", iter.next().getLabNumber());

		                        }
		                        j++;
		                    }
		                    i++;
		                }
				 }
				 n--;
			 }

	    }
}
