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

package oscar.oscarMessenger.pageUtil;

import org.oscarehr.PMmodule.dao.ProviderDao;
import org.oscarehr.common.model.Provider;
import org.oscarehr.util.SpringUtils;
import oscar.oscarMessenger.data.MsgDisplayMessage;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;

public class MsgSessionBean implements java.io.Serializable {
	
    private static final long serialVersionUID = 1L;
    
	private String providerNo = null;
	private String userName = null;
	private String attach = null;
	private String pdfAttach = null;
	private String messageId = null;
	private String demographic_no = null;
	private int totalAttachmentCount = 0;
	private int currentAttachmentCount = 0;
        private String message;
	private String subject;
	
	private String searchProviderName;
    private Date searchStartDate;
    private Date searchEndDate;
    private List<MsgDisplayMessage> searchResults;
    private Integer searchPageNum;
    private Integer searchTotalResults;
    private String searchOrderBy;
	
	public String getMessage() {
		return message;
	}

	public void setMessage(String message) {
		this.message = message;
	}

	public String getSubject() {
		return subject;
	}

	public void setSubject(String subject) {
		this.subject = subject;
	}


	public String getProviderNo() {
		return this.providerNo;
	}

	public void setProviderNo(String RHS) {
		this.providerNo = RHS;
	}

	public String getUserName() {
		return this.userName;
	}

	public void setUserName(String RHS) {
		this.userName = RHS;
	}

	public void estUserName() {
		ProviderDao dao = SpringUtils.getBean(ProviderDao.class);
		Provider p = dao.getProvider(providerNo);
		if (p != null) {
			userName = p.getFullName();
		}
	}

	public String getAttachment() {
		return this.attach;
	}

	public void setAttachment(String str) {
		this.attach = str;
	}

	public void setPDFAttachment(String binStr) {
		this.pdfAttach = binStr;
	}

	public String getPDFAttachment() {
		return this.pdfAttach;
	}

	public void setAppendPDFAttachment(String binStr, String pdfTitle) {

		String currentAtt = "";

		if (this.getPDFAttachment() != null) {
			currentAtt = this.getPDFAttachment();
		}

		if (binStr != "" && binStr != null) {
			this.setPDFAttachment(currentAtt + " " + getPDFStartTag() + getStatusTag("OK") + getPDFTitleTag(pdfTitle) + getContentTag(binStr) + getPDFEndTag());
		} else {
			this.setPDFAttachment(currentAtt + " " + getPDFStartTag() + getStatusTag("BAD") + getPDFTitleTag(pdfTitle + " (N/A)") + getContentTag(binStr) + getPDFEndTag());
		}

	}

	public String getPDFStartTag() {
		return "<PDF><FILE_ID>" + currentAttachmentCount + "</FILE_ID>";
	}

	public String getPDFTitleTag(String pdfTitle) {
		return "<TITLE>" + pdfTitle + "</TITLE>";
	}

	public String getContentTag(String binStr) {
		return "<CONTENT>" + binStr + "</CONTENT>";
	}

	public String getStatusTag(String statusStr) {
		return "<STATUS>" + statusStr + "</STATUS>";
	}

	public String getPDFEndTag() {
		return "</PDF>";
	}

	public void nullAttachment() {
		this.attach = null;
		this.pdfAttach = null;
		this.totalAttachmentCount = 0;
		this.currentAttachmentCount = 0;
	}

	public int getTotalAttachmentCount() {
		return this.totalAttachmentCount;
	}

	public void setTotalAttachmentCount(int totalAttachment) {
		this.totalAttachmentCount = totalAttachment;
	}

	public int getCurrentAttachmentCount() {
		return this.currentAttachmentCount;
	}

	public void setCurrentAttachmentCount(int currentAttachmentCount) {
		this.currentAttachmentCount = currentAttachmentCount;
	}

	public String getMessageId() {
		if (this.messageId == null) {
			this.messageId = new String();
		}
		return this.messageId;
	}

	public void setMessageId(String str) {
		this.messageId = str;
	}

	public String getDemographic_no() {
		if (this.demographic_no == null) {
			this.demographic_no = new String();
		}
		return this.demographic_no;
	}

	public void setDemographic_no(String str) {
		this.demographic_no = str;
	}

	public void nullMessageId() {
		this.messageId = null;
	}

	public boolean isValid() {
		if (this.providerNo != null && this.providerNo.length() > 0) {
			return true;
		}
		return false;
	}

    public String getSearchProviderName() {
        return searchProviderName;
    }

    public void setSearchProviderName(String searchProviderName) {
        this.searchProviderName = searchProviderName;
    }

    public String getSearchStartDateString() {
	    if (searchStartDate == null) { return null; }
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
        return sdf.format(searchStartDate);
    }

    public Date getSearchStartDate() {
        return searchStartDate;
    }
    
    public void setSearchStartDate(Date searchStartDate) {
        this.searchStartDate = searchStartDate;
    }

    public String getSearchEndDateString() {
        if (searchEndDate == null) { return null; }
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
        return sdf.format(searchEndDate);
    }
    
    public Date getSearchEndDate() {
        return searchEndDate;
    }

    public void setSearchEndDate(Date searchEndDate) {
        this.searchEndDate = searchEndDate;
    }

    public List<MsgDisplayMessage> getSearchResults() {
        return searchResults;
    }

    public void setSearchResults(List<MsgDisplayMessage> searchResults) {
        this.searchResults = searchResults;
    }

    public Integer getSearchPageNum() {
        return searchPageNum;
    }

    public void setSearchPageNum(Integer searchPageNum) {
        this.searchPageNum = searchPageNum;
    }

    public Integer getSearchTotalResults() {
        return searchTotalResults;
    }

    public void setSearchTotalResults(Integer searchTotalResults) {
        this.searchTotalResults = searchTotalResults;
    }

    public String getSearchOrderBy() {
        return searchOrderBy;
    }

    public void setSearchOrderBy(String searchOrderBy) {
        this.searchOrderBy = searchOrderBy;
    }
}
