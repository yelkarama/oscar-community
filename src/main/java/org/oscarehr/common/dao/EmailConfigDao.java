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
 package org.oscarehr.common.dao;

import java.util.Collections;
import java.util.List;

import javax.persistence.Query;

import org.oscarehr.common.model.EmailConfig;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

@Repository
public class EmailConfigDao extends AbstractDao<EmailConfig> {
    public EmailConfigDao() {
        super(EmailConfig.class);
    }

    @Transactional
    public EmailConfig findActiveEmailConfig(EmailConfig emailConfig) {
		Query query = entityManager.createQuery("SELECT e FROM EmailConfig e WHERE e.senderEmail = :senderEmail AND e.emailType = :emailType AND e.emailProvider = :emailProvider AND e.active = 1");
		
		query.setParameter("senderEmail", emailConfig.getSenderEmail());
        query.setParameter("emailType", emailConfig.getEmailType());
        query.setParameter("emailProvider", emailConfig.getEmailProvider());
		
		return getSingleResultOrNull(query);
	}

    @SuppressWarnings("unchecked")
    public List<EmailConfig> fillAllActiveEmailConfigs() {
        Query query = entityManager.createQuery("SELECT e FROM EmailConfig e WHERE e.active = 1");

        List<EmailConfig> emailConfigs = query.getResultList();
        if (emailConfigs == null) { emailConfigs = Collections.emptyList(); }
		return emailConfigs;
    }
    
}
