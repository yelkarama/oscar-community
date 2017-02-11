/**
 * Copyright (c) 2006-. KAI INNOVATIONS, OpenSoft System. All Rights Reserved.
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
 */

/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package org.oscarehr.common.dao;

import java.util.List;
import java.util.ArrayList;

import javax.persistence.Query;

import org.oscarehr.common.model.BillingPermission;
import org.oscarehr.common.model.Provider;
import org.oscarehr.PMmodule.dao.ProviderDao;
import org.springframework.stereotype.Repository;

import org.oscarehr.util.SpringUtils;

@Repository
public class BillingPermissionDao extends AbstractDao<BillingPermission> {

	public BillingPermissionDao() {
		super(BillingPermission.class);
	}
	
	 public boolean hasPermission(String provider_no, String viewer_no, String permission) {
		 String sql = "select bp From BillingPermission bp WHERE bp.providerNo=? AND bp.viewerNo=? AND bp.permission=?";
		 Query query = entityManager.createQuery(sql);
		 query.setParameter(1, provider_no);
		 query.setParameter(2, viewer_no);
		 query.setParameter(3, permission);

		 @SuppressWarnings("unchecked")
		 List<BillingPermission> bps = query.getResultList();
		 if(!bps.isEmpty()){
			 return bps.get(0).isAllowed();
		 }
		 return true;
	 }	
	 
	 //if any provider with matching OHIP no has denied permission, viewer does not have permission
	 public boolean hasPermissionByOhipNo(String provider_ohip_no, String viewer_no, String permission) {
		ProviderDao providerDao = SpringUtils.getBean(ProviderDao.class);
		List<Provider> provs = providerDao.getBillableProvidersByOHIPNo(provider_ohip_no);
		 
		 if(!provs.isEmpty()){
			 for(int i = 0; i < provs.size(); i++){
				 if(!hasPermission(provs.get(i).getProviderNo(), viewer_no, permission)){
					 return false;
				 }
			 }
		 }
		 return true;
	 }
	 
	 public List<String> getOhipNosNotAllowed(String viewer_no, String permission) {
		ProviderDao providerDao = SpringUtils.getBean(ProviderDao.class);
		List<String> ohipNos = new ArrayList<String>();
		List<BillingPermission> permissions = getNotAllowed(viewer_no, permission);
		
		if(!permissions.isEmpty()){
			for(int i=0; i < permissions.size(); i++){
				Provider prov = providerDao.getProvider(permissions.get(i).getProviderNo());
				ohipNos.add(prov.getOhipNo());
			}
		}
		 
		 return ohipNos;
	 }
	 
	public List<String> getProviderNumbersNotAllowed(String viewerNo, String permissionKey) {
		List<String> providerNumbers = new ArrayList<>();
		List<BillingPermission> permissions = getNotAllowed(viewerNo, permissionKey);
		
		for (BillingPermission permission : permissions) {
			providerNumbers.add(permission.getProviderNo());
		}
		
		return providerNumbers;
	}
	
	public List<BillingPermission> getNotAllowed(String viewerNo, String permission) {
		String sql = "select bp From BillingPermission bp WHERE bp.viewerNo = :viewerNo AND bp.permission = :permission AND bp.allow = 0";
		Query query = entityManager.createQuery(sql);
		query.setParameter("viewerNo", viewerNo);
		query.setParameter("permission", permission);

		@SuppressWarnings("unchecked")
		List<BillingPermission> permissions = query.getResultList();
		
		return permissions;
	}
	 
	 public List<BillingPermission> getByProviderNo(String provider_no) {
		 String sql = "select bp From BillingPermission bp WHERE bp.providerNo=?";
		 Query query = entityManager.createQuery(sql);
		 query.setParameter(1, provider_no);

		 @SuppressWarnings("unchecked")
		 List<BillingPermission> bps = query.getResultList();
		 return bps;
	 }
	 
	 public List<BillingPermission> getByProviderNoAndViewerNo(String provider_no, String viewer_no) {
		 String sql = "select bp From BillingPermission bp WHERE bp.providerNo=? AND bp.viewerNo=?";
		 Query query = entityManager.createQuery(sql);
		 query.setParameter(1, provider_no);
		 query.setParameter(2, viewer_no);

		 @SuppressWarnings("unchecked")
		 List<BillingPermission> bps = query.getResultList();
		 return bps;
	 }

	 public void setPermission(String provider_no, String viewer_no, String permission, boolean allow) {
		 String sql = "select bp From BillingPermission bp WHERE bp.providerNo=? AND bp.viewerNo=? AND bp.permission=?";
		 Query query = entityManager.createQuery(sql);
		 query.setParameter(1, provider_no);
		 query.setParameter(2, viewer_no);
		 query.setParameter(3, permission);

		 @SuppressWarnings("unchecked")
		 List<BillingPermission> bps = query.getResultList();
		 if(!bps.isEmpty()){
			 BillingPermission bp = bps.get(0);
			 bp.setAllow(allow);
			 merge(bp);
		 }else{
			 BillingPermission bp = new BillingPermission(provider_no, viewer_no, permission, allow);
			 merge(bp);
		 }
	 }

	 public BillingPermission getById(int id) {
		 return find(id);
	 }
}
