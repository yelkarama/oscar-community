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


package oscar.oscarMessenger.data;

public class MsgDisplayMessage {
    public String messageId  = null;
    public String messagePosition  = null;
    public boolean isLastMsg = false;
    public String status     = null;
    public String thesubject = null;
    public String thedate    = null;
    public String theime    = null;
    public String sentby     = null;
    private String sentBySpecialty = null;
    public String sentto     = null;
    private String sentToProviderNo;
    private String sentToSpecialty = null;
    public String attach     = null;
    public String pdfAttach     = null;
    public String demographic_no = null;

    public String getSentToProviderNo() {
        return sentToProviderNo;
    }
    public void setSentToProviderNo(String sentToProviderNo) {
        this.sentToProviderNo = sentToProviderNo;
    }
    
    public String getSentBySpecialty() {
        return sentBySpecialty;
    }
    public void setSentBySpecialty(String SentBySpecialty) {
        if (SentBySpecialty == null || SentBySpecialty.isEmpty() || SentBySpecialty.equalsIgnoreCase("system")) {
            SentBySpecialty = null;
        }
        this.sentBySpecialty = SentBySpecialty;
    }

    public String getSentToSpecialty() {
        return sentToSpecialty;
    }
    public void setSentToSpecialty(String SentToSpecialty) {
        if (SentToSpecialty == null || SentToSpecialty.isEmpty() || SentToSpecialty.equalsIgnoreCase("system")) {
            SentToSpecialty = null;
        }
        this.sentToSpecialty = SentToSpecialty;
    }
}
