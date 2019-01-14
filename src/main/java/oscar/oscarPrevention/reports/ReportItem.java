package oscar.oscarPrevention.reports;

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

import java.util.Date;


public class ReportItem implements Comparable<ReportItem> {

	private Integer demographicNo = null;
	private Date dob = null;
	private String age = null;
	private String sex = null;
	private String lastname = null;
	private String firstname = null;
	private String hin = null;
	private String phone = null;
	private String email = null;
	private String address = null;
	private Date nextAppt = null;
	private String rosteringDoc = null;
	 	
	
	private Date lastDate = null;
	private int rank = 0;
	private String state = null;
	private String numMonths = "------";
	private String color = null; 
	
	public String numShots = null;
	private String bonusStatus= "N";
	public String billStatus = "N";
   
   //FollowUp Data
	public Date lastFollowup = null;
	public String lastFollupProcedure =null;
	public String nextSuggestedProcedure=null;
	
	
	public Integer getDemographicNo() {
		return demographicNo;
	}
	public void setDemographicNo(Integer demographicNo) {
		this.demographicNo = demographicNo;
	}
	public int getRank() {
		return rank;
	}
	public void setRank(int rank) {
		this.rank = rank;
	}
	public Date getLastDate() {
		return lastDate;
	}
	public void setLastDate(Date lastDate) {
		this.lastDate = lastDate;
	}
	public String getState() {
		return state;
	}
	public void setState(String state) {
		this.state = state;
	}
	public String getNumMonths() {
		return numMonths;
	}
	public void setNumMonths(String numMonths) {
		this.numMonths = numMonths;
	}
	public String getColor() {
		return color;
	}
	public void setColor(String color) {
		this.color = color;
	}
	public Date getDob() {
		return dob;
	}
	public void setDob(Date dob) {
		this.dob = dob;
	}
	public String getSex() {
		return sex;
	}
	public void setSex(String sex) {
		this.sex = sex;
	}
	public String getLastname() {
		return lastname;
	}
	public void setLastname(String lastname) {
		this.lastname = lastname;
	}
	public String getFirstname() {
		return firstname;
	}
	public void setFirstname(String firstname) {
		this.firstname = firstname;
	}
	public String getHin() {
		return hin;
	}
	public void setHin(String hin) {
		this.hin = hin;
	}
	public String getPhone() {
		return phone;
	}
	public void setPhone(String phone) {
		this.phone = phone;
	}
	public String getEmail() {
		return email;
	}
	public void setEmail(String email) {
		this.email = email;
	}
	public String getAddress() {
		return address;
	}
	public void setAddress(String address) {
		this.address = address;
	}
	public String getAge() {
		return age;
	}
	public void setAge(String age) {
		this.age = age;
	}
	public Date getNextAppt() {
		return nextAppt;
	}
	public void setNextAppt(Date nextAppt) {
		this.nextAppt = nextAppt;
	}
	public String getBonusStatus() {
		return bonusStatus;
	}
	public void setBonusStatus(String bonusStatus) {
		this.bonusStatus = bonusStatus;
	}
	public String getRosteringDoc() {
		return rosteringDoc;
	}
	public void setRosteringDoc(String rosteringDoc) {
		this.rosteringDoc = rosteringDoc;
	}
	
	@Override
	public int compareTo(ReportItem o) {
	      
	      int ret = 0;
	      if (this.rank < o.rank){
	         ret = -1;
	      }else if ( this.rank > o.rank){
	         ret = +1;
	      }
	      return ret;
	      // If this < o, return a negative value
	      // If this = o, return 0
	      // If this > o, return a positive value
	}
	
	
	
}
