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

public class RaReportBean {

	private List<String> providers = new ArrayList<String>();
	private List<BigDecimal> invoice = new ArrayList<BigDecimal>();
	private List<BigDecimal> rmb = new ArrayList<BigDecimal>();
	private List<BigDecimal> gross = new ArrayList<BigDecimal>();
	private List<BigDecimal> automated = new ArrayList<BigDecimal>();
	private List<BigDecimal> optIn = new ArrayList<BigDecimal>();
	private List<BigDecimal> agePremium = new ArrayList<BigDecimal>();
	private List<BigDecimal> net = new ArrayList<BigDecimal>();
	
	//private String HTMLtransaction = "";
	private String messageTxt = "";
	private BigDecimal claimsAdjust = new BigDecimal(0).setScale(2, BigDecimal.ROUND_HALF_UP);
	private BigDecimal advances = new BigDecimal(0).setScale(2, BigDecimal.ROUND_HALF_UP);
	private BigDecimal reductions = new BigDecimal(0).setScale(2, BigDecimal.ROUND_HALF_UP);
	private BigDecimal deductions = new BigDecimal(0).setScale(2, BigDecimal.ROUND_HALF_UP);
	
	private BigDecimal raTotal = new BigDecimal(0).setScale(2, BigDecimal.ROUND_HALF_UP);
	
	public RaReportBean() { }
	
	public List<String> getProviders()
	{	return this.providers;	}
	public void setProviders(List<String> providers)
	{	this.providers = providers;	}
	public void addToProviders(String provider)
	{	this.providers.add(provider);	}
	
	public List<BigDecimal> getInvoice()
	{	return this.invoice;	}
	public void setInvoice(List<BigDecimal> invoice)
	{	this.invoice = invoice;	}
	public void addToInvoice(BigDecimal in)
	{	this.invoice.add(in);	}
		
	public List<BigDecimal> getRmb()
	{	return this.rmb;	}
	public void setRmb(List<BigDecimal> rmb)
	{	this.rmb = rmb;		}
	public void addToRmb(BigDecimal rmb)
	{	this.rmb.add(rmb);	}
		
	public List<BigDecimal> getGross()
	{	return this.gross;	}
	public void setGross(List<BigDecimal> gross)
	{	this.gross = gross;	}
	public void addToGross(BigDecimal gross)
	{	this.gross.add(gross);	}
		
	public List<BigDecimal> getAutomated()
	{	return this.automated;	}
	public void setAutomated(List<BigDecimal> automated)
	{	this.automated = automated; }
	public void addToAutomated(BigDecimal automated)
	{	this.automated.add(automated);	}
		
	public List<BigDecimal> getOptIn()
	{	return this.optIn;	}
	public void setOptIn(List<BigDecimal> optIn)
	{	this.optIn = optIn;	}
	public void addToOptIn(BigDecimal optIn)
	{	this.optIn.add(optIn);	}
		
	public List<BigDecimal> getAgePremium()
	{	return this.agePremium;	}
	public void setAgePremium(List<BigDecimal> agePremium)
	{	this.agePremium = agePremium;	}
	public void addToAgePremium(BigDecimal agePremium)
	{	this.agePremium.add(agePremium);	}
		
	public List<BigDecimal> getNet()
	{	return this.net;	}
	public void setNet(List<BigDecimal> net)
	{	this.net = net;	}
	public void addToNet(BigDecimal net)
	{	this.net.add(net);	}
	
	public String getMessageTxt()
	{	return this.messageTxt;	}
	public void setMessageText(String messageTxt)
	{	this.messageTxt = messageTxt;	}
	public void addToMessageTxt(String messageTxt)
	{	this.messageTxt += messageTxt;	}
	
	public BigDecimal getClaimsAdjust()
	{	return this.claimsAdjust;	}
	public void setClaimsAdjust(BigDecimal claimsAdjust)
	{	this.claimsAdjust = claimsAdjust; }
	
	public BigDecimal getAdvances()
	{	return this.claimsAdjust;	}
	public void setAdvances(BigDecimal advances){
		this.advances = advances;	}
		
	public BigDecimal getReductions()
	{	return this.reductions;	}
	public void setReductions(BigDecimal reductions)
	{	this.reductions = reductions;	}
		
	public BigDecimal getDeductions()
	{	return this.deductions;	}
	public void setDeductions(BigDecimal deductions)
	{	this.deductions = deductions; }
	
	public BigDecimal getRaTotal()
	{	return this.raTotal;	}
	public void setRaTotal(BigDecimal raTotal)
	{	this.raTotal = raTotal;	}
}
