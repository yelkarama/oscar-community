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


package oscar.appt;

import java.io.BufferedReader;
import java.io.DataInputStream;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.Calendar;
import java.util.Date;
import java.util.Properties;

import javax.mail.internet.AddressException;
import javax.mail.internet.InternetAddress;

import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;
import org.oscarehr.util.DateUtils;
import org.oscarehr.common.dao.ClinicDAO;
import org.oscarehr.common.dao.DemographicDao;
import org.oscarehr.common.dao.OscarAppointmentDao;
import  org.oscarehr.PMmodule.dao.ProviderDao;
import org.oscarehr.common.model.Appointment;
import org.oscarehr.common.model.Clinic;
import org.oscarehr.common.model.Demographic;
import  org.oscarehr.common.model.Provider;
import org.oscarehr.util.MiscUtils;
import org.oscarehr.util.SpringUtils;
import org.springframework.mail.MailSender;
import org.springframework.mail.SimpleMailMessage;

import oscar.service.MessageMailer;
/**
 *
 * @author mweston4
 */

public class AppointmentMailer implements MessageMailer{
    
    public enum EMAIL_NOTIFICATION_TYPE
    {
        REMINDER,
        CANCELLATION
    }

    private static final Logger logger=MiscUtils.getLogger();
    
    private MailSender mailSender = (MailSender) SpringUtils.getBean("asyncMailSender");
    private SimpleMailMessage message;
    private StringBuilder msgTextTemplate;
    private Appointment appointment;
    private Demographic demographic;
    private EMAIL_NOTIFICATION_TYPE notificationType;
    
    private OscarAppointmentDao appointmentDao = (OscarAppointmentDao)SpringUtils.getBean("oscarAppointmentDao");
    private DemographicDao demographicDao = SpringUtils.getBean(DemographicDao.class);

    
    public AppointmentMailer(Appointment appointment, EMAIL_NOTIFICATION_TYPE notificationType)
    {
        this.message = null;
        this.msgTextTemplate = new StringBuilder();
        this.appointment = appointment;
        this.notificationType = notificationType;
        this.demographic = demographicDao.getDemographicById( appointment.getDemographicNo() );
    }
    
    private void setMessageHeader(String propertyPrefixTemplate, String propertyPrefixMime)
    {
        if (this.message == null)
        {
            Properties op = oscar.OscarProperties.getInstance();

            String msgTemplatePath = "";

            if(this.appointment != null)
            {
                ProviderDao providerDao = SpringUtils.getBean(ProviderDao.class);

                Provider apptProvider = providerDao.getProvider(this.appointment.getProviderNo());

                if (apptProvider != null)
                {
                    String providerTeam = apptProvider.getTeam();

                    if (providerTeam != null && !providerTeam.isEmpty())
                    {
                        msgTemplatePath = op.getProperty(propertyPrefixTemplate + "." + providerTeam.toLowerCase());
                    }
                }
            }

            if (msgTemplatePath == null || msgTemplatePath.isEmpty())
            {
               msgTemplatePath = op.getProperty(propertyPrefixTemplate);
            }

            if (msgTemplatePath != null)
            {
                String msgMime = op.getProperty(propertyPrefixMime);

                if ((msgMime == null) || msgMime.equalsIgnoreCase("no"))
                {
                    this.message = new SimpleMailMessage();
                }
                else
                {
                    //TODO
                }


                InputStream fstream = null;
                DataInputStream instream = null;

                try {   
                    InternetAddress emailAddress = new InternetAddress(demographic.getEmail(), true);
                    this.message.setTo(emailAddress.toString());


                    fstream = new FileInputStream(msgTemplatePath);
                    instream = new DataInputStream(fstream);

                    BufferedReader bufreader = new BufferedReader(new InputStreamReader(instream));
                    String strLine;
                
                    //read in message template and header information
                    int lineIndex = 0;                 
                    while ((strLine = bufreader.readLine()) != null)  {
                        if (lineIndex < 2) {
                            String[] msgConfig = strLine.split(":");
                            if (msgConfig[0].equalsIgnoreCase("From")){
                                this.message.setFrom(msgConfig[1]);
                            }
                            else if (msgConfig[0].equalsIgnoreCase("Subject")) {
                                this.message.setSubject(msgConfig[1]);
                            }
                        }
                        else {
                            this.msgTextTemplate.append(strLine).append("\n");
                        }
                        lineIndex++;
                    }
                }
                catch(FileNotFoundException fnf) {
                  logger.error("No Appointment Reminder Template found", fnf);
                }
                catch(IOException io) {
                  logger.error("IOException occurred", io);
                }
                catch(AddressException addr) {
                    logger.error("To Address not valid:" + demographic.getEmail());
                }

                finally {
                    try {
                        if (instream != null) {
                            instream.close();
                        }
                        
                        if ( fstream != null) {
                            fstream.close();
                        }
                    }
                    catch(IOException io) {
                        logger.error("IOException occurred", io);
                    }
                }
            }  
        }
    }
    
    private void fillMessageText(String reasonTag, String reason) {
        
        if ((this.message != null) && (this.msgTextTemplate.length() > 0)) {
                 
            Date today = new Date();
           
            ClinicDAO clinicDao = (ClinicDAO)SpringUtils.getBean("clinicDAO");
            Clinic clinic = clinicDao.getClinic();
            
            if (this.appointment == null) {

              logger.error("Appointment ("+this.appointment.getId()+") not found for demographic no (" + this.demographic.getDemographicNo() +") on Date: " + today);

            } else {
               
                String msgText = msgTextTemplate.toString();
                msgText = msgText.replaceAll("<today>", DateUtils.getIsoDate(Calendar.getInstance()));
                msgText = msgText.replaceAll("<appointment_date>", this.appointment.getAppointmentDate().toString());
                msgText = msgText.replaceAll("<appointment_time>", this.appointment.getStartTime().toString());
                msgText = msgText.replaceAll("<first_name>", this.demographic.getFirstName());
                msgText = msgText.replaceAll("<last_name>", this.demographic.getLastName());
                
                msgText = msgText.replaceAll("<clinic_name>", clinic.getClinicName());                
                msgText = msgText.replaceAll("<clinic_addressLine>", clinic.getClinicAddress());
                msgText = msgText.replaceAll("<clinic_phone>", clinic.getClinicPhone());
                msgText = msgText.replaceAll(reasonTag, reason);
                
                this.message.setText(msgText);
            }
        }
        else {
            logger.error("Cannot populate message text - no message or message template available");
        }
    }
    
    public void prepareMessage( String reason ) {
        
        String reasonTagPrefix = "appt";
        
        if ( EMAIL_NOTIFICATION_TYPE.CANCELLATION.equals(this.notificationType) ) {
            
                reasonTagPrefix = EMAIL_NOTIFICATION_TYPE.CANCELLATION.name().toLowerCase();
        }

        setMessageHeader( "appt_" + this.notificationType.name().toLowerCase() + "_template",
                "appt_" + notificationType.name().toLowerCase() + "_mime");
        
        fillMessageText("<" + reasonTagPrefix + "_reason>", reason);
    }
    
    @Override
    public void send() throws Exception {
        try {
            boolean doSend = false;
            
            if ((mailSender != null) && (this.message != null)) {
                   
                if ((this.message.getText() != null) && (this.message.getFrom() != null) && (this.message.getSubject() != null)) {
                    String[] toAddrs = this.message.getTo();
                    if (toAddrs.length > 0) {
                        boolean toValid = true;
                        for (String addr : toAddrs) {
                            if (addr.isEmpty()) {
                                toValid = false;
                            }
                        }
                        if (toValid) {
                            doSend=true;
                        }
                    }        
                }
            }
            
            if (doSend) {
                mailSender.send(this.message);
                
                //Update appt history accordingly      
                if(this.appointment != null) {

                    StringBuilder remarks = new StringBuilder();
                    
                    remarks.append(this.appointment.getRemarks())
                            .append("Emailed ")
                            .append(StringUtils.capitalize(this.notificationType.name()))
                            .append(": ")
                            .append(DateUtils.getIsoDate(Calendar.getInstance()))
                            .append("\n");

                    this.appointment.setRemarks(remarks.toString());

                	this.appointmentDao.merge(this.appointment);
                }
            }
            else {
                logger.error("MailSender is not instantiated or MailMessage is not prepared");
            }
        }
        catch(Exception e) {
            logger.error("An error occurred", e);
        }
    }
}
