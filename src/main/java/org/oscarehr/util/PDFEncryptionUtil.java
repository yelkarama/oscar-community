/**
 *
 * Copyright (c) 2005-2012. Centre for Research on Inner City Health, St. Michael's Hospital, Toronto. All Rights Reserved.
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
 * This software was written for
 * Centre for Research on Inner City Health, St. Michael's Hospital,
 * Toronto, Ontario, Canada
 */
 
 package org.oscarehr.util;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;

import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.pdmodel.encryption.AccessPermission;
import org.apache.pdfbox.pdmodel.encryption.StandardProtectionPolicy;

public class PDFEncryptionUtil {
    public static Path encryptPDF(Path pdfPath, String password) throws IOException {
        try (PDDocument pdDocument = PDDocument.load(pdfPath.toFile())) {
            StandardProtectionPolicy spp = new StandardProtectionPolicy(password, password, new AccessPermission());
            spp.setEncryptionKeyLength(256);
            pdDocument.protect(spp);
            Path encryptPDFPath = Files.createTempFile("encryptedPDF_" + System.currentTimeMillis(), ".pdf");
            pdDocument.save(encryptPDFPath.toFile());
            return encryptPDFPath;
        } catch (IOException e) {
            throw new IOException("Failed to encrypt document", e);
        }
    } 
}
