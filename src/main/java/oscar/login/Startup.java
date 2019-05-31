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


package oscar.login;

import java.io.File;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;

import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;

import org.apache.log4j.Logger;
import org.oscarehr.util.MiscUtils;
import oscar.OscarProperties;

/**
 * This ContextListener is used to Initialize classes at startup - Initialize the DBConnection Pool.
 * 
 * @author Jay Gallagher
 */
public class Startup implements ServletContextListener {
	private static Logger logger = MiscUtils.getLogger();
	private oscar.OscarProperties p;

	public void contextInitialized(ServletContextEvent sc) {
		try {
			// Initializes OscarProperties and sets the start time of OSCAR
			OscarProperties.initialize(sc.getServletContext());
			OscarProperties.getInstance().setProperty("OSCAR_START_TIME", "" + System.currentTimeMillis());
			
			logger.debug("contextInit");
			logger.debug("LAST LINE IN contextInitialized");
		} catch (Exception e) {
			logger.error("Unexpected error.", e);
			throw (new RuntimeException(e));
		}
	}


	public void contextDestroyed(ServletContextEvent arg0) {
		// nothing to do right now
	}

}
