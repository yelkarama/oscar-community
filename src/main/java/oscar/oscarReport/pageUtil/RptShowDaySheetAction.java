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


package oscar.oscarReport.pageUtil;

import java.io.IOException;

import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.GregorianCalendar;
import java.util.Calendar;
import java.util.Date;
import java.util.Properties;
import java.util.ArrayList;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.struts.action.Action;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import org.oscarehr.common.model.DaySheetConfiguration;
import org.oscarehr.common.dao.DaySheetConfigurationDao;
import org.oscarehr.common.model.Appointment;
import org.oscarehr.common.dao.OscarAppointmentDao;
import org.oscarehr.common.model.Demographic;
import org.oscarehr.common.dao.DemographicDao;
import org.oscarehr.common.model.Provider;
import org.oscarehr.PMmodule.dao.ProviderDao;
import org.oscarehr.util.MiscUtils;
import org.oscarehr.util.SpringUtils;


public class RptShowDaySheetAction extends Action {
   
   private DaySheetConfigurationDao dsConfigDao = (DaySheetConfigurationDao) SpringUtils.getBean("dsConfigDao");
   private OscarAppointmentDao appointmentDao = (OscarAppointmentDao) SpringUtils.getBean("oscarAppointmentDao");
   private ProviderDao providerDao = (ProviderDao) SpringUtils.getBean("providerDao");
   private DemographicDao demographicDao = (DemographicDao) SpringUtils.getBean("demographicDao");
   private Properties oscarVariables = oscar.OscarProperties.getInstance();
   private DateFormat df = new SimpleDateFormat("yyyy-MM-dd");
   private DateFormat time = new SimpleDateFormat("hh:mm a");
   
   public ActionForward execute(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response)
   throws ServletException, IOException {      
		String orderby = request.getParameter("orderby")!=null?request.getParameter("orderby"):("start_time") ;
		
		GregorianCalendar now=new GregorianCalendar();
		
		Date sdate = now.getTime();
		Date edate = null;
		
		if(request.getParameter("sdate")!=null){
			try {
				sdate = df.parse(request.getParameter("sdate"));
			} catch (Exception e) {
				MiscUtils.getLogger().error("Error", e);
			}
		}
		if(request.getParameter("edate")!=null){
			try {
				edate = df.parse(request.getParameter("edate"));
			} catch (Exception e) {
				MiscUtils.getLogger().error("Error", e);
			}
		}
		
		int curYear = now.get(Calendar.YEAR);
		int curMonth = (now.get(Calendar.MONTH)+1);
		int curDay = now.get(Calendar.DAY_OF_MONTH);
		
		String provider_no = request.getParameter("provider_no")!=null?request.getParameter("provider_no"):"0" ;
		
		String sTime = request.getParameter("sTime")!=null? (request.getParameter("sTime")+":00:00") : "00:00:00" ;
		String eTime = request.getParameter("eTime")!=null? (request.getParameter("eTime")+":00:00") : "24:00:00" ;
		
		String createtime = now.get(Calendar.YEAR) +"-" +(now.get(Calendar.MONTH)+1) +"-"+now.get(Calendar.DAY_OF_MONTH) +" "+now.get(Calendar.HOUR_OF_DAY)+":"+now.get(Calendar.MINUTE) ;
		now.add(now.DATE, 1);
		
		List<DaySheetConfiguration> dsConfig = dsConfigDao.getActiveConfigurationList();
		List<Appointment> appts;
		
		appts = appointmentDao.getByProviderAndDay(sdate, provider_no);
		
		List<Properties> appointments = new ArrayList();
		Provider prov = providerDao.getProvider(provider_no);
		
		for(int i=0; i < appts.size(); i++){
			Appointment currAppt = appts.get(i);
			Properties appt = new Properties();
			Demographic demo = demographicDao.getDemographicById(currAppt.getDemographicNo());
			
			if(demo == null){
				continue;
			}
			appt.setProperty("Appointment Duration",currAppt.getDuration());
			appt.setProperty("Patient",demo.getFormattedName());
			appt.setProperty("Demographic Number",""+demo.getDemographicNo());
			appt.setProperty("Appointment Start Time", time.format(currAppt.getStartTime()));
			appt.setProperty("Appointment Type", currAppt.getType());
			appt.setProperty("Appointment Reason", currAppt.getReason());
			appt.setProperty("Home Phone", demo.getPhone());
			appt.setProperty("Date of Birth", df.format(demo.getBirthDay().getTime()));
			appt.setProperty("Health Card Number", demo.getHin());
			appointments.add(appt);
		}
		
		request.setAttribute("heading", prov.getFormattedName() + " [" + df.format(sdate) + " " + sTime + " - " + eTime +"]");
		request.setAttribute("dsConfig", dsConfig);
		request.setAttribute("createtime", createtime);
		request.setAttribute("appointments",appointments);
		
		return mapping.findForward("success");
   }
}
