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
import java.util.StringTokenizer;

import org.oscarehr.util.LoggedInInfo;

import oscar.SxmlMisc;
import oscar.oscarDB.DBHandler;
import oscar.util.UtilDateUtilities;

public class FrmGynaeFormRecord extends FrmRecord {
	private static String FORM_TABLE_NAME = "formgyane";

	@Override
	public String createActionURL(String where, String action, String demoId,
			String formId) throws SQLException {
		return ((new FrmRecordHelp()).createActionURL(where, action, demoId,
				formId));
	}

	@Override
	public String findActionValue(String submit) throws SQLException {
		return ((new FrmRecordHelp()).findActionValue(submit));
	}

	@Override
	public Properties getFormRecord(LoggedInInfo loggedInInfo, int demographicNo, int existingID)
			throws SQLException {
		Properties props = new Properties();
		Properties props1 = new Properties();
		
		if (existingID <= 0) {
			props.setProperty("formCreated", UtilDateUtilities.getToday("yyyy/MM/dd"));
			props.setProperty("demographic_no",
					new Integer(demographicNo).toString());
			
			defaultFromDemography(demographicNo, props, existingID);
		} else {
			String sql1 = "SELECT * FROM " + FORM_TABLE_NAME
					+ " WHERE demographic_no = " + demographicNo + " AND ID="
					+ existingID;
			props1 = (new FrmRecordHelp()).getFormRecord(sql1);
			props.putAll(props1);

			defaultFromDemography(demographicNo, props, existingID);
		}
		defaultClinic(props);
		return props;
	}

	@Override
	public int saveFormRecord(Properties props) throws SQLException {
		String demographic_no = props.getProperty("demographic_no");
		String sql = "SELECT * FROM  " + FORM_TABLE_NAME + " WHERE demographic_no="
				+ demographic_no + " AND ID=0";

		return ((new FrmRecordHelp()).saveFormRecord(props, sql));
	}

	public void defaultClinic(Properties props) throws SQLException {
		String sql = "SELECT * 	FROM clinic ";
		ResultSet rs = null;
		try {
			rs = DBHandler.GetSQL(sql);
			if (rs.next()) {
				String[] columns = new String[] { "clinic_name",
						"clinic_address", "clinic_city", "clinic_postal",
						"clinic_phone", "clinic_fax", "clinic_location_code",
						"clinic_province", "clinic_delim_phone",
						"clinic_delim_fax" };
				for (int i = 0; i < columns.length; i++) {
					props.setProperty(columns[i], rs.getString(columns[i]));
				}
			}
		} finally {
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
        try{
	        rs = DBHandler.GetSQL(sql);
	        if (rs.next()) {
                props.setProperty("demographic_no", getString(rs,"demographic_no"));
                props.setProperty("patient_default_lname", getString(rs,"last_name"));
                props.setProperty("patient_default_fname", getString(rs,"first_name"));
                props.setProperty("patient_default_age", String.valueOf(UtilDateUtilities.calcAge(getString(rs,"year_of_birth"), rs
                        .getString("month_of_birth"), getString(rs,"date_of_birth"))));
                
                String rd = SxmlMisc.getXmlContent(getString(rs,"family_doctor"),"rd")    ;
                rd = rd !=null ? rd : "" ;
                String name = rd,fname = "",lname = "";
                StringTokenizer st = new StringTokenizer(name, ","); 
                if(st.hasMoreTokens()){
                	lname = 	st.nextToken().trim();
                }
                if(st.hasMoreTokens()){
                	fname = 	st.nextToken().trim();
                }
                props.setProperty("family_doctor_default_lname",lname);
                props.setProperty("family_doctor_default_fname",fname);
                
                if(existingID > 0){
                	
                }else{
                	 props.setProperty("provider_no", getString(rs,"provider_no"));
                }
                
            }
        }finally{
        	rs.close();
        }
    }
	
	 public String getString(ResultSet rs, String columnName) throws SQLException
	    {
	    	return oscar.Misc.getString(rs, columnName);
	    }
	    public String getString(ResultSet rs, int columnIndex) throws SQLException
	    {
	    	return oscar.Misc.getString(rs, columnIndex);
	    }
}
