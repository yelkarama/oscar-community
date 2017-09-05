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
package oscar.oscarProvider.data;

import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.sql.Blob;
import java.sql.ResultSet;
import java.sql.SQLException;

import org.oscarehr.casemgmt.model.ProviderExt;
import org.oscarehr.common.dao.ProviderExtDao;
import org.oscarehr.util.MiscUtils;

import org.oscarehr.util.SpringUtils;
import oscar.oscarDB.DBHandler;
import oscar.oscarMessenger.util.MsgStringQuote;


public class ProSignatureData {
	
	private ProviderExtDao providerExtDao = SpringUtils.getBean(ProviderExtDao.class);

    public boolean hasSignature(String proNo){
       boolean retval = false;
       
      ProviderExt pe =  providerExtDao.find(proNo);
      if(pe!=null && pe.getSignature()!=null) {
    	  retval=true;
      }
       
       return retval;
    }
    
    
    public boolean hasMultiLineSignature(String proNo){
        boolean retval = false;
        try
             {
                 String sql = "select multi_line_signature from providerExt where provider_no = '"+proNo+"' ";
                 ResultSet rs = DBHandler.GetSQL(sql);
                 if(rs.next())
                 {
                	 String sign = rs.getString(1);
                	 if(sign!=null && sign.trim().length()>0)
                		 retval = true;
                 }
                 rs.close();
             }
             catch(SQLException e)
             {
                 System.out.println("There has been an error while checking if a provider had a signature");
                 System.out.println(e.getMessage());
             }

        return retval;
     }
    
    public boolean hasMultiLineHeader(String proNo){
        boolean retval = false;
        try
             {
                 String sql = "select multi_line_header from providerExt where provider_no = '"+proNo+"' ";
                 ResultSet rs = DBHandler.GetSQL(sql);
                 if(rs.next())
                 {
                	 String sign = rs.getString(1);
                	 if(sign!=null && sign.trim().length()>0)
                		 retval = true;
                 }
                 rs.close();
             }
             catch(SQLException e)
             {
                 System.out.println("There has been an error while checking if a provider had a signature");
                 System.out.println(e.getMessage());
             }

        return retval;
     }
    
    public String getSignature(String providerNo){
       String retval = "";
       ProviderExt pe =  providerExtDao.find(providerNo);
       if(pe != null) {
    	   retval = pe.getSignature();
       }
       return retval;
    }

    public String getMultiLineSignature(String providerNo){
        String retval = "";
        try{
              String sql = "select multi_line_signature from providerExt where provider_no = '"+providerNo+"' ";
              ResultSet rs = DBHandler.GetSQL(sql);
              if(rs.next())
                 retval = getString(rs,"multi_line_signature");
              rs.close();
           }
           catch(SQLException e){
              System.out.println("There has been an error while retrieving a provider's multi_line_signature");
              System.out.println(e.getMessage());
           }

        return retval;
     }
    
    public String getString(ResultSet rs, String columnName) throws SQLException
    {
    	return oscar.Misc.getString(rs, columnName);
    }
    
    public String getMultiLineHeader(String providerNo){
        String retval = "";
        try{
              String sql = "select multi_line_header from providerExt where provider_no = '"+providerNo+"' ";
              ResultSet rs = DBHandler.GetSQL(sql);
              if(rs.next())
                 retval = getString(rs,"multi_line_header");
              rs.close();
           }
           catch(SQLException e){
              System.out.println("There has been an error while retrieving a provider's multi_line_header");
              System.out.println(e.getMessage());
           }

        return retval;
     }
    
    public void enterSignature(String providerNo,String signature){
       
	if (hasSignature(providerNo)){
           updateSignature(providerNo,signature);
        }else{
           addSignature(providerNo,signature);
        }

    }

    public void enterSignatureMultiLine(String providerNo,String signature){
    	try {
			String sql = "select multi_line_signature from providerExt where provider_no = '"+providerNo+"' ";
			ResultSet rs = DBHandler.GetSQL(sql);
			if(rs.next())
			{
				updateMultiLineSignature(providerNo,signature);
			}
			else
			{
				 addMultiLineSignature(providerNo,signature);
			}
		} catch (SQLException e) {
			e.printStackTrace();
		}
     }

    public void enterSignatureMultiHeader(String providerNo,String signature){
    	try {
			String sql = "select multi_line_header from providerExt where provider_no = '"+providerNo+"' ";
			ResultSet rs = DBHandler.GetSQL(sql);
			if(rs.next())
			{
				updateMultiLineHeader(providerNo,signature);
			}
			else
			{
				 addMultiLineHeader(providerNo,signature);
			}
		} catch (SQLException e) {
			e.printStackTrace();
		}
     }

    private void addSignature(String providerNo,String signature){
    	ProviderExt pe = new ProviderExt();
    	pe.setProviderNo(providerNo);
    	pe.setSignature(signature);
    	providerExtDao.persist(pe);
    }

    private void addMultiLineSignature(String providerNo,String signature){
        MsgStringQuote s = new MsgStringQuote();
        try{
              String sql = "insert into  providerExt (provider_no,multi_line_signature) values ('"+providerNo+"','"+s.q(signature)+"') ";
              DBHandler.GetSQL(sql);
           }
           catch(SQLException e){
              System.out.println("There has been an error while adding a provider's multi_line_signature");
              System.out.println(e.getMessage());
           }


     }
    
    private void addMultiLineHeader(String providerNo,String signature){
        MsgStringQuote s = new MsgStringQuote();
        try{
              String sql = "insert into  providerExt (provider_no,multi_line_header) values ('"+providerNo+"','"+s.q(signature)+"') ";
              DBHandler.GetSQL(sql);
           }
           catch(SQLException e){
              System.out.println("There has been an error while adding a provider's multi_line_header");
              System.out.println(e.getMessage());
           }


     }
    
    private void updateSignature(String providerNo,String signature){
    	ProviderExt pe =  providerExtDao.find(providerNo);
    	if(pe != null) {
    		pe.setSignature(signature);
    		providerExtDao.merge(pe);
    	}
    }
    
    private void updateMultiLineSignature(String providerNo,String signature){
        MsgStringQuote s = new MsgStringQuote();
        try{
              String sql = "update  providerExt set multi_line_signature = '"+s.q(signature)+"' where provider_no = '"+providerNo+"' ";
              DBHandler.GetSQL(sql);
           }
           catch(SQLException e){
              System.out.println("There has been an error while updating a provider's signature");
              System.out.println(e.getMessage());
           }


     }
    
    private void updateMultiLineHeader(String providerNo,String signature){
        MsgStringQuote s = new MsgStringQuote();
        try{
              String sql = "update  providerExt set multi_line_header = '"+s.q(signature)+"' where provider_no = '"+providerNo+"' ";
              DBHandler.GetSQL(sql);
           }
           catch(SQLException e){
              System.out.println("There has been an error while updating a provider's multi_line_header");
              System.out.println(e.getMessage());
           }
     }
    
    public boolean hasElectronicSign(String providerNo)
    {
    	boolean flg = false;
    	
    	try
    	{
    		String qr = "select signature from provider where provider_no = '"+providerNo+"'";
			ResultSet rs = DBHandler.GetSQL(qr);
			
			if(rs.next())
			{
				Blob blob = rs.getBlob(1);
				if(blob!=null)
				{
					flg = true;
				}
			}
			
    	}
    	catch(Exception ex)
    	{
    		ex.printStackTrace();
    	}
    	
    	return flg;
    }
    
    public byte[] getElectronicSign(String providerNo)
    {
    	byte[] b1 = null;
    	
    	try
    	{
    		String qr = "select signature from provider where provider_no = '"+providerNo+"'";
			ResultSet rs = DBHandler.GetSQL(qr);
			
			if(rs.next())
			{
				ByteArrayOutputStream bout = new ByteArrayOutputStream();
				Blob blob = rs.getBlob(1);
				if(blob!=null)
				{
					InputStream inStream = blob.getBinaryStream();
					int i1 = -1;
					while((i1=inStream.read())!=-1)
					{
						bout.write(i1);
					}
					bout.flush();
					bout.close();
					
					b1 = bout.toByteArray();
				}
			}
			
    	}
    	catch(Exception ex)
    	{
    		ex.printStackTrace();
    	}
    	
    	return b1;
    }
}

