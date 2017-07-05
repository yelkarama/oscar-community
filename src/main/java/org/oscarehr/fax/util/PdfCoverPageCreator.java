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
package org.oscarehr.fax.util;

import java.io.ByteArrayOutputStream;
import java.io.IOException;

import com.itextpdf.text.*;
import com.itextpdf.text.pdf.*;
import org.oscarehr.common.dao.ClinicDAO;
import org.oscarehr.common.dao.ProfessionalSpecialistDao;
import org.oscarehr.common.model.Clinic;
import org.oscarehr.common.model.ProfessionalSpecialist;
import org.oscarehr.util.MiscUtils;
import org.oscarehr.util.SpringUtils;

public class PdfCoverPageCreator {
	
	private String note;

	public PdfCoverPageCreator(String note) {
		this.note = note;		
	}
	
	public byte[] createCoverPage() {
		
		Document document = new Document();
		ByteArrayOutputStream os = new ByteArrayOutputStream();
		
		try {
			
	        PdfWriter pdfWriter = PdfWriter.getInstance(document, os);
	        document.open();
	        
	        PdfPTable table = new PdfPTable(1);
	        table.setWidthPercentage(95);
	        
	        PdfPCell cell = new PdfPCell(table);
	        cell.setBorder(0);
	        cell.setPadding(3);
			cell.setColspan(1);
			table.addCell(cell);
			
			ClinicDAO clinicDao = SpringUtils.getBean(ClinicDAO.class);
			Clinic clinic = clinicDao.getClinic();
			BaseFont bf = BaseFont.createFont(BaseFont.HELVETICA, BaseFont.CP1252,
					BaseFont.NOT_EMBEDDED);
			Font headerFont = new Font(bf, 28, Font.BOLD);
			Font infoFont = new Font(bf, 12, Font.NORMAL);
					
			
			if( clinic != null ) {							
				
				cell = new PdfPCell(new Phrase(String.format("%s\n %s, %s, %s %s",
						   clinic.getClinicName(),
					 	   clinic.getClinicAddress(),  clinic.getClinicCity(),
						   clinic.getClinicProvince(), clinic.getClinicPostal()), headerFont));				
			}
			else {
				
				cell = new PdfPCell(new Phrase("OSCAR", headerFont));
			
			}
			

			cell.setPaddingTop(100);
			cell.setPaddingLeft(25);
			cell.setPaddingBottom(25);
			cell.setBorderWidthBottom(1);
			table.addCell(cell);

			PdfPTable infoTable = new PdfPTable(1);
			cell = new PdfPCell(new Phrase(note,infoFont));
			cell.setPaddingTop(25);
			cell.setPaddingLeft(25);
			infoTable.addCell(cell);
			table.addCell(infoTable);
			
			document.add(table);
			
	        
        } catch (DocumentException e) {
	        
        	MiscUtils.getLogger().error("PDF COVER PAGE ERROR",e);
	        return new byte[] {};
	        
        }catch( IOException e ) {
        	
        	MiscUtils.getLogger().error("PDF COVER PAGE ERROR",e);
	        return new byte[] {};
	        
        }
		finally {
			document.close();
		}
		
		return os.toByteArray();
	}

    public byte[] createStandardCoverPage(String specialistId) {
        Document document = new Document();
        document.setPageSize(new Rectangle(PageSize.LETTER));
        ByteArrayOutputStream os = new ByteArrayOutputStream();

        try {
            PdfWriter pdfWriter = PdfWriter.getInstance(document, os);
            document.open();
            BaseFont baseFont = BaseFont.createFont(BaseFont.HELVETICA, BaseFont.CP1252, BaseFont.NOT_EMBEDDED);
            Font headerFont = new Font(baseFont, 50, Font.NORMAL);
            Font infoFont = new Font(baseFont, 12, Font.NORMAL);

            document.add(new Phrase("\n\n", infoFont));
            document.add(new Phrase("Fax Message", headerFont));
            
            if (specialistId != null && !specialistId.isEmpty()) {
                ProfessionalSpecialistDao professionalSpecialistDao = SpringUtils.getBean(ProfessionalSpecialistDao.class);
                ProfessionalSpecialist specialist = professionalSpecialistDao.find(Integer.parseInt(specialistId));
                String clinicInfo = "\n\nRecipient: " + specialist.getFormattedTitle() + "\n" +
                        "Phone Number: " + specialist.getPhoneNumber()  + "\n" +
                        "Fax Number: " + specialist.getFaxNumber()  + "\n";
                document.add(new Phrase(clinicInfo, infoFont));
            }

            document.add(new Phrase("\n\n\n" + note, infoFont));
        } catch (DocumentException e) {
            MiscUtils.getLogger().error("PDF COVER PAGE ERROR",e);
            return new byte[] {};
        }catch(IOException e) {
            MiscUtils.getLogger().error("PDF COVER PAGE ERROR",e);
            return new byte[] {};
        } finally {
            document.close();
        }
        
        return os.toByteArray();
    }
}
