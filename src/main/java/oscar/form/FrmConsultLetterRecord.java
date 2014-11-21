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

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Properties;

import org.oscarehr.common.model.Demographic;

import oscar.oscarDB.DBHandler;
import oscar.util.UtilDateUtilities;

import oscar.SxmlMisc;

public class FrmConsultLetterRecord extends FrmRecord {
	private static String FORM_TABLE_NAME = "formConsultLetter";
	
    public Properties getFormRecord(int demographicNo, int existingID) throws SQLException {
        Properties props = new Properties();
        if (existingID <= 0) {
            defaultRelatives(demographicNo, props);
            defaultFromDemography(demographicNo, props, existingID);
        } else {

        	String sql = "SELECT * FROM " + FORM_TABLE_NAME + " WHERE demographic_no = " + demographicNo + " AND ID = "
                    + existingID;
            props = (new FrmRecordHelp()).getFormRecord(sql);
            
            defaultRelatives(demographicNo, props);
            defaultFromDemography(demographicNo, props, existingID);
        }
        props.setProperty("formCreated", UtilDateUtilities.DateToString(UtilDateUtilities.Today(),"yyyy/MM/dd"));
        return props;
        
    }

    public int saveFormRecord(Properties props) throws SQLException {
        String demographic_no = props.getProperty("demographic_no");
        String sql = "SELECT * FROM  " + FORM_TABLE_NAME + " WHERE demographic_no=" + demographic_no + " AND ID=0";

        return ((new FrmRecordHelp()).saveFormRecord(props, sql));
    }

    public Properties getPrintRecord(int demographicNo, int existingID) throws SQLException {
        String sql = "SELECT * FROM  " + FORM_TABLE_NAME + "  WHERE demographic_no = " + demographicNo + " AND ID = " + existingID;
        return ((new FrmRecordHelp()).getPrintRecord(sql));
    }

    public String findActionValue(String submit) throws SQLException {
        return ((new FrmRecordHelp()).findActionValue(submit));
    }

    public String createActionURL(String where, String action, String demoId, String formId) throws SQLException {
        return ((new FrmRecordHelp()).createActionURL(where, action, demoId, formId));
    }
    
    public String getString(ResultSet rs, String columnName) throws SQLException
    {
    	return oscar.Misc.getString(rs, columnName);
    }
    public String getString(ResultSet rs, int columnIndex) throws SQLException
    {
    	return oscar.Misc.getString(rs, columnIndex);
    }
    
    public void defaultRelatives(int demographicNo,Properties props) throws SQLException{
    	String sql = "SELECT relation_demographic_no,relation 	FROM relationships where deleted = 0 and demographic_no=" + demographicNo +  " and relation in ('Partner','Spouse','Husband')";
        ResultSet rs = null;
        try{
	        rs = DBHandler.GetSQL(sql);
	        while (rs.next()) {
	        	String partner = getString(rs,"relation_demographic_no");
	        	oscar.oscarDemographic.data.DemographicData demoData = null;
	            Demographic demographic = null;
	            demoData = new oscar.oscarDemographic.data.DemographicData();
	            demographic = demoData.getDemographic(partner);
	            if("Partner".equalsIgnoreCase(getString(rs, "relation"))){
	            	props.setProperty("partner_default_fname",demographic.getFirstName());
	            	props.setProperty("partner_default_lname",demographic.getLastName());
	            	props.setProperty("partner_default_age",demographic.getAge());
	            	props.setProperty("partner_no",partner);
	            }else if("Spouse".equalsIgnoreCase(getString(rs, "relation"))){
	            	props.setProperty("spouse_default_fname",demographic.getFirstName());
	            	props.setProperty("spouse_default_lname",demographic.getLastName());
	            	props.setProperty("spouse_default_age",demographic.getAge());
	            	props.setProperty("spouse_no", partner);
	            }else if("Husband".equalsIgnoreCase(getString(rs, "relation"))){
	            	props.setProperty("husband_default_fname",demographic.getFirstName());
	            	props.setProperty("husband_default_lname",demographic.getLastName());
	            	props.setProperty("husband_default_age",demographic.getAge());
	            	props.setProperty("husband_no", partner);
	            }else{
	            	continue;
	            }
	           
	        }
        }finally{
        	rs.close();
        }
    }
    
    public void defaultFromDemography(int demographicNo,Properties props, int existingID) throws SQLException{
    	String sql = "SELECT demographic_no, "
            + "family_doctor, provider_no, "
            + "year_of_birth, month_of_birth, date_of_birth,  "
            + "last_name,first_name "
            + " FROM demographic WHERE demographic_no = " + demographicNo;
    	ResultSet rs = null;
    	ResultSet rs2 = null;
        try{
	        rs = DBHandler.GetSQL(sql);
	        if (rs.next()) {
                props.setProperty("demographic_no", getString(rs,"demographic_no"));
                props.setProperty("patient_default_lname", getString(rs,"last_name"));
                props.setProperty("patient_default_fname", getString(rs,"first_name"));
                props.setProperty("patient_default_age", String.valueOf(UtilDateUtilities.calcAge(getString(rs,"year_of_birth"), rs
                        .getString("month_of_birth"), getString(rs,"date_of_birth"))));
                
                
                String rd = SxmlMisc.getXmlContent(getString(rs,"family_doctor"),"rd");
                rd = rd !=null ? rd : "" ;
                String name = rd;
                String fname = "";
                String lname = "";
                if(rd == null){
                    props.setProperty("family_doctor_default_lname",lname);
                    props.setProperty("family_doctor_default_fname",fname);
                }else{
                       String[] splitName = rd.split(",");
                    lname = splitName[0];
                    if(splitName.length > 1){
                        fname = splitName[1];
                    }
                    props.setProperty("family_doctor_default_lname",lname);
                    props.setProperty("family_doctor_default_fname",fname);
                }

                if(existingID > 0){

                }else{
                     props.setProperty("provider_no", getString(rs,"provider_no"));
                }
                
                if(existingID > 0){
                	
                }else{
                	 props.setProperty("provider_no", getString(rs,"provider_no"));
                }
                
            }
        }finally{
        	try
			{
				rs.close();
				rs2.close();
			} catch (Exception e)
			{
			}
        }
    }
    
    
    
    

}
