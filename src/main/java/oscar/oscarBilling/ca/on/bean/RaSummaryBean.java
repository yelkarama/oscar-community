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


package oscar.oscarBilling.ca.on.bean;

import java.util.ArrayList;
import java.util.List;
import java.util.Properties;
import java.math.BigDecimal;

public class RaSummaryBean {

	private List<Properties> providerBreakDown = new ArrayList<Properties>();
	private List<Properties> accountingTransactions = new ArrayList<Properties>();
	
	private BigDecimal abfClaimsAdjust = new BigDecimal(0).setScale(2, BigDecimal.ROUND_HALF_UP);
	private BigDecimal abfAdvances = new BigDecimal(0).setScale(2, BigDecimal.ROUND_HALF_UP);
	private BigDecimal abfReductions = new BigDecimal(0).setScale(2, BigDecimal.ROUND_HALF_UP);
	private BigDecimal abfDeductions = new BigDecimal(0).setScale(2, BigDecimal.ROUND_HALF_UP);
	
	private BigDecimal raTotalPos = new BigDecimal(0).setScale(2, BigDecimal.ROUND_HALF_UP);
	private BigDecimal raTotalNeg = new BigDecimal(0).setScale(2, BigDecimal.ROUND_HALF_UP);
	
	private BigDecimal raTotalNet = new BigDecimal(0).setScale(2, BigDecimal.ROUND_HALF_UP);

	public RaSummaryBean() { }
	
	public List<Properties> getProviderBreakDown() {
		return this.providerBreakDown;
	}

	public void setProviderBreakDown(List<Properties> providerBreakDown) {
		this.providerBreakDown = providerBreakDown;
	}
	
	public void addToProvBreakDown(Properties provRASummary){
		this.providerBreakDown.add(provRASummary);
	}
	
	public List<Properties> getAccountingTransactions() {
		return this.accountingTransactions;
	}

	public void setAccountingTransactions(List<Properties> accountingTransactions) {
		this.accountingTransactions = accountingTransactions;
	}
	
	public void addAccountingTransaction(Properties accountingTransaction){
		this.accountingTransactions.add(accountingTransaction);
	}
	
	public BigDecimal getAbfClaimsAdjust(){
		return this.abfClaimsAdjust;
	}
	
	public void setAbfClaimsAdjust(BigDecimal abfClaimsAdjust){
		this.abfClaimsAdjust = abfClaimsAdjust;
	}
	
	public BigDecimal getAbfAdvances(){
		return this.abfClaimsAdjust;
	}
	
	public void setAbfAdvances(BigDecimal abfAdvances){
		this.abfAdvances = abfAdvances;
	}
	
	public BigDecimal getAbfReductions(){
		return this.abfReductions;
	}
	
	public void setAbfReductions(BigDecimal abfReductions){
		this.abfReductions = abfReductions;
	}
	
	public BigDecimal getAbfDeductions(){
		return this.abfDeductions;
	}
	
	public void setAbfDeductions(BigDecimal abfDeductions){
		this.abfDeductions = abfDeductions;
	}
	
	public BigDecimal getRaTotalPos(){
		return this.raTotalPos;
	}
	
	public void setRaTotalPos(BigDecimal raTotalPos){
		this.raTotalPos = raTotalPos;
	}
	
	public void addToRaTotalPos(BigDecimal num){
		this.raTotalPos = this.raTotalPos.add(num);
	}
	
	public BigDecimal getRaTotalNeg(){
		return this.raTotalNeg;
	}
	
	public void setRaTotalNeg(BigDecimal raTotalNeg){
		this.raTotalNeg = raTotalNeg;
	}
	
	public void addToRaTotalNeg(BigDecimal num){
		this.raTotalNeg = this.raTotalNeg.add(num);
	}
	
	public BigDecimal getRaTotalNet(){
		return this.raTotalNet;
	}
	
	public void setRaTotalNet(BigDecimal raTotalNet){
		this.raTotalNet = raTotalNet;
	}
	
	public void calcRaTotalNet(){
		this.raTotalNet = new BigDecimal(0).setScale(2, BigDecimal.ROUND_HALF_UP);
		this.raTotalNet = this.raTotalNet.add(this.raTotalPos);
		this.raTotalNet = this.raTotalNet.add(this.raTotalNeg);
		
	}
}
