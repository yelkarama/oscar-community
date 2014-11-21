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
package oscar.form;

import java.util.HashSet;
import java.util.Iterator;
import java.util.Properties;
import java.util.Set;

public class FrmConsultLetterPrintUtil {
	
	Properties props = null;
	
	public FrmConsultLetterPrintUtil(Properties props){
		this.props = props;
	}
	
	public boolean isRFCGroupActive(){//Reason for Consultation
		return isGroupActive(getGroupIds("rfc"));
	}
	
	public boolean isRFHGroupActive(){//Relavant fertility history
		return isGroupActive(getGroupIds("rfh"),"rfhmf");
	}
	
	public boolean isRFHOF_AGroupActive(){//Relavant fertility history:Ovulation factors A
		Set groupKeys = new HashSet();
		groupKeys.add("rfhof_lmp");
		groupKeys.add("rfhof_gtpaepl");
		groupKeys.add("rfhof_dot");
		groupKeys.add("rfhof_menarche");
		groupKeys.add("rfhof_other");
		return isGroupActive(groupKeys);
	}
	
	public boolean isRFHOF_BGroupActive(){//Relavant fertility history:Ovulation factors B
		Set groupKeys = new HashSet();
		groupKeys.add("rfhof_ci");
		groupKeys.add("rfhtf_atd");
		groupKeys.add("rfhof_ra");
		groupKeys.add("rfhof_rh");
		groupKeys.add("rfhof_rg");
		groupKeys.add("rfhof_other2");
		return isGroupActive(groupKeys);
	}
	
	public boolean isTFGroupActive(){//Tubal Factors
		return isGroupActive(getGroupIds("rfhtf"));
	}
	
	public boolean isCFGroupActive(){//Coital Factors
		return isGroupActive(getGroupIds("rfhcf"));
	}
	
	public boolean isMFGroupActive(){//Male Factors
		return isGroupActive(getGroupIds("rfhmf"));
	}
	
	public boolean isPIGroupActive(){//Previous Investigations:
		return isGroupActive(getGroupIds("pi"));
	}
	
	public boolean isPTGroupActive(){//Previous Treatments:
		return isGroupActive(getGroupIds("pt"));
	}
	
	public boolean isOHGroupActive(){//Obstetrical History
		return isGroupActive(getGroupIds("oh"));
	}
	
	public boolean isNumberedOHRowActive(int lineNumber){//Obstetrical History row
		return isActive("oh_year" + lineNumber) ||
				isActive("oh_po" + lineNumber) || 
				isActive("oh_weeks" + lineNumber) || 
				isActive("oh_toc" + lineNumber) || 
				isActive("oh_notes" + lineNumber);
		
	}
	
	public boolean isMASHGroupActive(){//Medical and Surgical History:
		return isGroupActive(getGroupIds("mash"));
	}
	
	public boolean isPAMGroupActive(){//Prescriptions and Medications:
		return isGroupActive(getGroupIds("pam"));
	}
	
	public boolean isAllergiesGroupActive(){//Allergies:
		return isGroupActive(getGroupIds("allergies"));
	}
	
	public boolean isFHGroupActive(){//Family History:  
		return isGroupActive(getGroupIds("fh"));
	}
	
	public boolean isSHGroupActive(){//social history  
		return isGroupActive(getGroupIds("sh"));
	}
	
	public boolean isPEGroupActive(){//Physical Exam: 
		return isGroupActive(getGroupIds("pe"));
	}
	
	public boolean isImpressionGroupActive(){//Impression
		return isGroupActive(getGroupIds("impression"));
	}
	
	public boolean isOptDGroupActive(){//Options Discussed
		return isGroupActive(getGroupIds("optd"));
	}
	
	public boolean isIOGroupActive(){//Investigations Ordered:
		return isGroupActive(getGroupIds("io"));
	}
	
	public boolean isTPGroupActive(){//Treatment Plan:
		return isGroupActive(getGroupIds("tp"));
	}
	
	public boolean isGroupActive(Set groupKeys){
		Iterator groupItr = groupKeys.iterator();
		while(groupItr.hasNext()){
			String key = (String)groupItr.next();
			if(isActive(key)){
				return true;
			}
		}
		return false;
	}
	public boolean isGroupActive(Set groupKeys,String excludePrefix){
		Iterator groupItr = groupKeys.iterator();
		while(groupItr.hasNext()){
			String key = (String)groupItr.next();
			if(key.indexOf(excludePrefix) < 0){
				if(isActive(key)){
					return true;
				}
			}
		}
		return false;
	}
	
	public Set getGroupIds(String prefix){
		Set group = new HashSet();
		Iterator itr = props.keySet().iterator();
		String propertyKey = null;
		while(itr.hasNext()){
			propertyKey = (String)itr.next();
			if(propertyKey == null || "".equals(propertyKey)){
				continue;
			}
			if(prefix!=null && prefix.equalsIgnoreCase("rfhtf")){
			if(propertyKey!=null && (propertyKey.equalsIgnoreCase("rfhtf_atd") || 
					propertyKey.equalsIgnoreCase("rfhtf_atd_t") || 
					propertyKey.equalsIgnoreCase("rfhtf_atdd")))
				{
					continue;
				}
			}
			if(propertyKey.toUpperCase().startsWith(prefix.toUpperCase())){
				group.add(propertyKey);
			}
		}
		return group;
	}
	
	public boolean isActive(String key){
		if("".equals(props.getProperty(key, ""))){
			return false;
		}else{
			return true;
		}
	}
		
}
