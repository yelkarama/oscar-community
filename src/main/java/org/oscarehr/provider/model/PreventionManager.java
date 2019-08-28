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


package org.oscarehr.provider.model;

import java.util.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.apache.commons.lang.time.DateUtils;
import org.apache.log4j.Logger;
import org.oscarehr.common.dao.PropertyDao;
import org.oscarehr.common.model.Property;
import org.oscarehr.util.LoggedInInfo;
import org.oscarehr.util.MiscUtils;
import org.oscarehr.util.QueueCache;
import org.oscarehr.util.SpringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import oscar.oscarPrevention.Prevention;
import oscar.oscarPrevention.PreventionDS;
import oscar.oscarPrevention.PreventionData;


/**
 *
 * @author rjonasz
 */
@Component
public class PreventionManager {
	private static Logger logger = MiscUtils.getLogger();
	private static final QueueCache<String, String> dataCache=new QueueCache<String, String>(4, 500, DateUtils.MILLIS_PER_HOUR, null);
	
    @Autowired
    private PreventionDS pf = null;
    
  

    public  String getWarnings(LoggedInInfo loggedInInfo, String demo) {
        String ret = dataCache.get(demo);
      
        if( ret == null ) {
                try {

                	Prevention prev = PreventionData.getLocalandRemotePreventions(loggedInInfo, Integer.parseInt(demo));
                    pf.getMessages(prev);
                    
                    @SuppressWarnings("unchecked")
                    Map<String,Object> m = prev.getWarningMsgs();
                    
                    @SuppressWarnings("rawtypes")
                    Set set = m.entrySet();
                    
                    @SuppressWarnings("rawtypes")
                    Iterator i = set.iterator();
                    // Display elements
                    String k="";
                    if(ret==null || ret.equals("null")){
                    	ret="";
                    }
                    
	                 while(i.hasNext()) {
	                 @SuppressWarnings("rawtypes")
	                 Map.Entry me = (Map.Entry)i.next();

	                 k="["+me.getKey()+"="+me.getValue()+"]";
	                 boolean prevCheck = PreventionManager.isPrevDisabled(me.getKey().toString());
	                 	if(prevCheck==false){
		                 ret=ret+k;
	                 	}

	                 } 	
                                         
	                 dataCache.put(demo, ret);

                } catch(Exception e) {
                    ret = "";
                    MiscUtils.getLogger().error("Error", e);
                }
            
        }
        
        return ret;
        
    }

     public void removePrevention(String demo) {
    	 dataCache.remove(demo);
     }

   

	public static String checkNames(String k){
		String rebuilt="";
		Pattern pattern = Pattern.compile("(\\[)(.*?)(\\])");
		Matcher matcher = pattern.matcher(k);
		
		while(matcher.find()){
			String[] key = matcher.group(2).split("=");
			boolean prevCheck = PreventionManager.isPrevDisabled(key[0]);
			
			if(prevCheck==false){
				rebuilt=rebuilt+"["+key[1]+"]";
			}
		} 
		
		return rebuilt;
	}
		 
		 
	public static boolean isDisabled(){
		PropertyDao propDao = (PropertyDao)SpringUtils.getBean("propertyDao");
		List<Property> pList = propDao.findByName("hide_prevention_stop_signs");

		if (pList.size() > 0 && pList.get(0).getValue().equals("master")) {
			return true;
		} else {
			return false;
		}
	}
	
	
	public static boolean isCreated(){
		PropertyDao propDao = (PropertyDao)SpringUtils.getBean("propertyDao");
		List<Property> pList = propDao.findByName("hide_prevention_stop_signs"); 
		return (pList.size() > 0);
	}
	
	public static boolean isPrevDisabled(String name){
		return getDisabledPreventions().contains(name);
	}

	public static List<String> getDisabledPreventions(){

		PropertyDao propDao = (PropertyDao)SpringUtils.getBean("propertyDao");
		List<Property> pList = propDao.findByName("hide_prevention_stop_signs");
		
		String disabledNames = "";
		for (Property prop : pList) {
			disabledNames += prop.getValue();
		}
		//remove '[' since it always precedes a name
		disabledNames = disabledNames.replace("[", "");
		//split on ']' since it always follows a name
		return Arrays.asList(disabledNames.split("]"));
	}

	public static boolean setDisabledPreventions(List<String> newDisabledPreventions){

		PropertyDao propDao = (PropertyDao)SpringUtils.getBean("propertyDao");
		
		if (newDisabledPreventions == null) {
			return false;
		}
		
		propDao.removeByName("hide_prevention_stop_signs");
		
		if (newDisabledPreventions.get(0).equals("master") || newDisabledPreventions.get(0).equals("false")) {
			Property newProp = new Property();
			newProp.setName("hide_prevention_stop_signs");
			newProp.setValue(newDisabledPreventions.get(0));
			propDao.persist(newProp);
			return true;
		}
		
		String newDisabled = "";
		for(String preventionName : newDisabledPreventions){

			
			if ((newDisabled + "["+ preventionName +"]").length() > 255) { //a value in the property table holds a max of 255 characters

				Property newProp = new Property();
				newProp.setName("hide_prevention_stop_signs");
				newProp.setValue(newDisabled);
				propDao.persist(newProp);
				
				newDisabled = "[" + preventionName + "]";
			} else {
				newDisabled += "[" + preventionName + "]";
			}
		}
		if (!newDisabled.isEmpty()) {
			Property newProp = new Property();
			newProp.setName("hide_prevention_stop_signs");
			newProp.setValue(newDisabled);
			propDao.persist(newProp);
		}
		return true;
	}
  	
}
