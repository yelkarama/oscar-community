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
package org.oscarehr.integration.listeners;

import org.apache.log4j.Logger;
import org.oscarehr.common.hl7.v2.HL7A08Data;
import org.oscarehr.common.model.Demographic;
import org.oscarehr.event.DemographicUpdateEvent;
import org.oscarehr.util.MiscUtils;
import org.springframework.context.ApplicationListener;
import org.springframework.stereotype.Component;

@Component
public class DemographicUpdateListener implements ApplicationListener<DemographicUpdateEvent>{

	Logger logger = MiscUtils.getLogger();
	
	@Override
	public void onApplicationEvent(DemographicUpdateEvent event) {
		Integer demographicNo = event.getDemographicNo();
		Demographic demographic = (Demographic)event.getSource();
		
		try {
			// generate A08 HL7
			HL7A08Data A08Obj = new HL7A08Data(demographic);
			A08Obj.save();
		} catch (Exception e) {
			logger.error("Unable to generate HL7 A08 file", e);
		}
		
	}

}
