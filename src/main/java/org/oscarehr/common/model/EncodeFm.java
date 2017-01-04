/**
 * Copyright (c) 2001-2002. Department of Family Medicine, McMaster University. All Rights Reserved.
 * This software is published under the GPL GNU General Public License.
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 * <p>
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 * <p>
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 * <p>
 * This software was written for the
 * Department of Family Medicine
 * McMaster University
 * Hamilton
 * Ontario, Canada
 */
package org.oscarehr.common.model;

import javax.persistence.*;

@Entity
@Table(name="encodeFm")
public class EncodeFm extends AbstractCodeSystemModel<Integer> implements java.io.Serializable {
	
//	private int SeqNo;
	@Id
	private String EncodeFm;
//	private int Retired;
//	private String PKA;
//	private String Rdate;
//	private int Modified;
//	private String Mdate;
//	private int PARENT;
//	private int Preferred;
//	private String Chapt;
//	private int I0;
//	private int I1;
//	private int I2;
//	private int I3;
//	private int I4;
//	private int I5;
//	private int I6;
//	private int I7;
//	private int I8;
//	private int I9;
//	private int S;
	private String Syn;
	private String Ab;
	private String ICPC;
	private String ICD10;
	private String ICD9CM;
	private String OHIP;
	private int Level;
	private String description;
	private String French;
	private String Changes;

	public EncodeFm() {
	}
	
	@Override
	public Integer getId() {
		return Integer.parseInt(getEncodeFm());
	}

	@Override
	public String getCode() {
		return getEncodeFm();
	}

	@Override
	public String getCodingSystem() {
		return "EncodeFm";
	}

	@Override
	public void setCode(String code) {
		setEncodeFm(code);
	}

//	public int getSeqNo() { return SeqNo; }
//	public void setSeqNo(int SeqNo) { this.SeqNo = SeqNo; }
	public String getEncodeFm() { return EncodeFm; }
	public void setEncodeFm(String EncodeFm) { this.EncodeFm = EncodeFm; }
	public String getICPC() { return ICPC; }
	public String getICD10() { return ICD10; }
	public String getICD9CM() { return ICD9CM; }
	public String getOHIP() { return OHIP; }
	@Override
	public String getDescription() { return description; }
	@Override
	public void setDescription(String description) { this.description = description; }
	public String getFrench() { return French; }
	public void setFrench(String French) { this.French = French; }
}
