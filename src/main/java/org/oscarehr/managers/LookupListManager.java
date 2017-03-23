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
package org.oscarehr.managers;

import java.util.List;

import org.oscarehr.common.dao.LookupListDao;
import org.oscarehr.common.dao.LookupListItemDao;
import org.oscarehr.common.model.LookupList;
import org.oscarehr.common.model.LookupListItem;
import org.oscarehr.util.LoggedInInfo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import oscar.log.LogAction;
import oscar.log.LogConst;

@Service
public class LookupListManager {

	@Autowired
	private LookupListDao lookupListDao;
	@Autowired
	private LookupListItemDao lookupListItemDao;
	
	
	public List<LookupList> findAllActiveLookupLists(LoggedInInfo loggedInInfo) {
		List<LookupList> results = lookupListDao.findAllActive();

		return (results);
	}
	
	public LookupList findLookupListById(LoggedInInfo loggedInInfo, int id) {
		LookupList result = lookupListDao.find(id);

		return (result);
		
	}
	
	public LookupList findLookupListByName(LoggedInInfo loggedInInfo, String name) {
		LookupList result = lookupListDao.findByName(name);

		return (result);
		
	}
	
	public LookupList addLookupList(LoggedInInfo loggedInInfo, LookupList lookupList) {
		lookupListDao.persist(lookupList);
		LogAction.addLogSynchronous(loggedInInfo, LogConst.ADD, "LookupListManager.addLookupList", String.valueOf(lookupList.getId()));
		

		return (lookupList);
		
	}
	
	public LookupListItem addLookupListItem(LoggedInInfo loggedInInfo, LookupListItem lookupListItem) {
		lookupListItemDao.persist(lookupListItem);
		LogAction.addLogSynchronous(loggedInInfo, LogConst.ADD, "LookupListManager.addLookupListItem", String.valueOf(lookupListItem.getId()));
		

		return (lookupListItem);
		
	}
	
	/**
	 * Retrieve all the active select list option items by the lookUpList.id
	 */
	public List<LookupListItem> findLookupListItemsByLookupListId(LoggedInInfo loggedInInfo, int lookupListId ) {

		List<LookupListItem> lookupListItems = lookupListItemDao.findActiveByLookupListId( lookupListId );

		return lookupListItems;
	}

	/**
	 * Retrieve all the active select list option items by the lookupList.name
	 */
	public List<LookupListItem> findLookupListItemsByLookupListName(LoggedInInfo loggedInInfo, String lookupListName ) {

		LookupList lookupList = findLookupListByName(loggedInInfo, lookupListName);
		List<LookupListItem> lookupListItems = null;

		return lookupListItems;
	}


	/**
	 * Find a specific lookupListItem by it's id
	 */
	public LookupListItem findLookupListItemById(LoggedInInfo loggedInInfo, int lookupListItemId ) {
		LookupListItem lookupListItem = null;
		if( lookupListItemId > 0 ) {		
			lookupListItem = lookupListItemDao.find( lookupListItemId );
		}

		return lookupListItem;
	}

	/**
	 * Update a lookupListItem that has been edited.
	 */
	public Integer updateLookupListItem(LoggedInInfo loggedInInfo, LookupListItem lookupListItem ) {

		lookupListItemDao.merge(lookupListItem);
		Integer id = lookupListItem.getId();
		LogAction.addLogSynchronous(loggedInInfo, LogConst.UPDATE, "LookupListManager.updateLookupListItem", String.valueOf(lookupListItem.getId()));

		return id;
	}

	/**
	 * Remove a lookupListItem by it's id.
	 */
	public boolean removeLookupListItem(LoggedInInfo loggedInInfo, int lookupListItemId ) {

		LookupListItem lookupListItem = findLookupListItemById(loggedInInfo, lookupListItemId );
		Integer id = null;

		if( lookupListItem != null ) {
			lookupListItem.setActive(Boolean.FALSE);
			id = updateLookupListItem(loggedInInfo, lookupListItem ); 
		}
		LogAction.addLogSynchronous(loggedInInfo, LogConst.DELETE, "LookupListManager.removeLookupListItem", String.valueOf(lookupListItem.getId()));

		return ( id == lookupListItemId );
	}

	/**
	 * Change the display order sequence of this lookupListItem
	 * @param lookupListItemId
	 * @param displayOrder
	 */
	public boolean updateLookupListItemDisplayOrder(LoggedInInfo loggedInInfo, int lookupListItemId, int lookupListItemDisplayOrder ) { 

		LookupListItem lookupListItem = findLookupListItemById(loggedInInfo, lookupListItemId );
		Integer id = null;

		if( lookupListItem != null ) {
			lookupListItem.setDisplayOrder( lookupListItemDisplayOrder );
			id = updateLookupListItem(loggedInInfo, lookupListItem ); 
		}

		LogAction.addLogSynchronous(loggedInInfo, "LookupListManager.updateLookupListItemDisplayOrder", 
				"Changed display order for lookupListItem Id: " + id + " To: " + lookupListItemDisplayOrder );

		return ( id == lookupListItemId );
	}
	
}
