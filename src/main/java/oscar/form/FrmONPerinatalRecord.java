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

import java.sql.SQLException;
import java.util.*;

import org.apache.commons.lang.StringUtils;
import org.oscarehr.util.LoggedInInfo;

import org.oscarehr.util.SpringUtils;
import oscar.form.dao.ONPerinatal2017Dao;
import oscar.form.model.FormONPerinatal2017;
import oscar.util.UtilDateUtilities;

public class FrmONPerinatalRecord extends FrmRecord {
    
    protected String _newDateFormat = "yyyy-MM-dd"; //handles both date formats, but yyyy/MM/dd is displayed to avoid deprecation

    public FrmONPerinatalRecord() {
        this.dateFormat = "yyyy/MM/dd";
    }
    
    public Properties getFormRecord(LoggedInInfo loggedInInfo, int demographicNo, int existingID) throws SQLException {
        return getFormRecord(loggedInInfo, demographicNo, existingID, 1);
    }
    
    public Properties getFormRecord(LoggedInInfo loggedInInfo, int demographicNo, int existingID, int pageNo) throws SQLException {
        Properties props = new Properties();
        ONPerinatal2017Dao perinatalDao = SpringUtils.getBean(ONPerinatal2017Dao.class);
        List<FormONPerinatal2017> records = new ArrayList<FormONPerinatal2017>();

        if (existingID <= 0) { 
            this.setDemoProperties(loggedInInfo, demographicNo, props);
            props.setProperty("c_fileNo", StringUtils.trimToEmpty(demographic.getChartNo()));
            props.setProperty("c_lastName", StringUtils.trimToEmpty(demographic.getLastName()));
            props.setProperty("c_firstName", StringUtils.trimToEmpty(demographic.getFirstName()));
            props.setProperty("c_hin", demographic.getHin());
            props.setProperty("c_dateOfBirth", demographic.getFormattedDob());

            if ("ON".equals(demographic.getHcType())) {
                props.setProperty("c_hinType", "OHIP");
            } else if ("QC".equals(demographic.getHcType())) {
                props.setProperty("c_hinType", "RAMQ");
            } else {
                props.setProperty("c_hinType", "OTHER");
            }
            
        } else {
            records.addAll(perinatalDao.findSectionRecords(existingID, pageNo, "c_"));
            records.addAll(perinatalDao.findSectionRecords(existingID, pageNo, "ps_edb_"));
            records.addAll(perinatalDao.findRecordsByPage(existingID, pageNo));
            records.addAll(FrmONPerinatalAction.getCommentsAsRecords(existingID));
            props = getRecordValuesAsProperties(records);
            
            // If the page is 3 and there isn't an exam weight saved for the page, attempts to get the exam weight from page 2
            if (pageNo == 3 && !props.containsKey("pe_wt")) {
                FormONPerinatal2017 weight = perinatalDao.findFieldForPage(existingID, 2, "pe_wt");
                if (weight != null) {
                    props.put(weight.getField(), weight.getValue());
                }
            }
        }
        
        if (props.getProperty("pg" + pageNo + "_formDate") == null) {
            props.setProperty("pg" + pageNo + "_formDate", UtilDateUtilities.DateToString(new Date(), dateFormat));
        }
        
        return props;
    }
    
    @Deprecated
    /**
     * Use FrmONPerinatalAction instead
     * This is just required to extend FrmRecord 
     */
    public int saveFormRecord(Properties props) throws SQLException {
        
        int formId = StringUtils.isNotEmpty(props.getProperty("formId")) ? Integer.parseInt(props.getProperty("formId")) : 0;
        int demographicNo = StringUtils.isNotEmpty(props.getProperty("demographic_no")) ? Integer.parseInt(props.getProperty("demographic_no")) : 0;
        String providerNo = StringUtils.isNotEmpty(props.getProperty("provNo")) ? props.getProperty("provNo") : "0";
        Set<String> keys = props.stringPropertyNames();
        for (String key : keys) {
            System.out.println(key + " \t\t\t : \t " + props.getProperty(key));
        }

        return formId;
    }

    public Properties getPrintRecord(int demographicNo, int existingID) throws SQLException {
        //join the 3 tables
        //String sql = "SELECT * FROM formONAREnhancedRecord rec, formONAREnhancedRecordExt1 ext1, formONAREnhancedRecordExt2 ext2 WHERE rec.ID = ext1.ID and rec.ID = ext2.ID and rec.demographic_no = " + demographicNo + " AND rec.ID = " + existingID;
        return null; //((new FrmRecordHelp()).getPrintRecord(sql));
    }

    public String findActionValue(String submit) throws SQLException {
        return ((new FrmRecordHelp()).findActionValue(submit));
    }

    public String createActionURL(String where, String action, String demoId, String formId) throws SQLException {
        return ((new FrmRecordHelp()).createActionURL(where, action, demoId, formId));
    }
    
    private List<FormONPerinatal2017> getExistingPerinatalRecordValues(Integer formId) {
        ONPerinatal2017Dao perinatalDao = SpringUtils.getBean(ONPerinatal2017Dao.class);
        List<FormONPerinatal2017> records = new ArrayList<FormONPerinatal2017>();
        formId = formId == null ? 0 : formId;
        
        if (formId > 0) {
           records = perinatalDao.findRecords(formId);
        }

        return records;
    }



    private Properties getRecordValuesAsProperties(List<FormONPerinatal2017> records) {
        Properties properties = new Properties();
        
        if (records != null) {
            for (FormONPerinatal2017 record : records) {
                properties.setProperty(record.getField(), record.getValue());
            }
        }
      

        return properties;
    }

}

