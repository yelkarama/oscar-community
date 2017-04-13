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


package oscar.oscarEncounter.pageUtil;

import java.io.IOException;
import java.net.InetAddress;
import java.net.URI;
import java.net.URISyntaxException;
import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import javax.servlet.http.HttpServletRequest;

import org.apache.commons.lang.StringEscapeUtils;
import org.apache.http.HttpResponse;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.utils.URIBuilder;
import org.apache.http.conn.ClientConnectionManager;
import org.apache.http.conn.scheme.Scheme;
import org.apache.http.conn.scheme.SchemeRegistry;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.util.EntityUtils;
import org.apache.log4j.Logger;
import org.apache.struts.util.MessageResources;
import org.oscarehr.util.LoggedInInfo;
import org.oscarehr.util.MiscUtils;

import net.sf.json.JSONArray;
import net.sf.json.JSONObject;
import oscar.OscarProperties;
import oscar.dms.EDoc;
import oscar.dms.EDocUtil;
import oscar.dms.EDocUtil.EDocSort;
import oscar.util.DateUtils;
import oscar.util.StringUtils;

public class EctDisplayProgressSheetAction extends EctDisplayAction {
	private static Logger logger = MiscUtils.getLogger();

	private static final String cmd = "progressSheet";

	public boolean getInfo(EctSessionBean bean, HttpServletRequest request, NavBarDisplayDAO Dao, MessageResources messages) {
    
		LoggedInInfo loggedInInfo=LoggedInInfo.getLoggedInInfoFromSession(request);
		
    	if (!securityInfoManager.hasPrivilege(loggedInInfo, "_edoc", "r", null)) {
    		return true; // documents link won't show up on new CME screen.
    	} else if (!OscarProperties.getInstance().getBooleanProperty("echart_show_progress_sheet", "true")) {
    		return true;
    	} else {
    

			String providerId = (String) request.getSession().getAttribute("user");
    		// set lefthand module heading and link
    		String winName = "progressSheets" + bean.demographicNo;
    		String url = "return false;";
    	    
    		Dao.setLeftHeading(messages.getMessage(request.getLocale(), "oscarEncounter.LeftNavBar.ProgressSheet"));
    
    		winName = "addProgressSheets" + bean.demographicNo;
    		Dao.setRightHeadingID("blank"); // no menu so set div id to unique id for this action
    
    		StringBuilder javascript = new StringBuilder("<script type=\"text/javascript\">");
    		String js = "";
    		String dbFormat = "yyyy-MM-dd";
    		String serviceDateStr = "";
    		String key;
    		int hash;
    		String BGCOLOUR = request.getParameter("hC");
    		Date date;
    		
    		String host = request.getRequestURL().substring(0, request.getRequestURL().indexOf(request.getContextPath())); //assume progress sheet is on same system
    		String serviceUrl = host + "/progresssheet/demographic/getProgressSheets/?demographicId=" + bean.getDemographicNo();
    		if (OscarProperties.getInstance().getProperty("progress_sheet_url") != null) {
    			serviceUrl = OscarProperties.getInstance().getProperty("progress_sheet_url") + "demographic/getProgressSheets/?demographicId=" + bean.getDemographicNo();
    		}
    		JSONArray progressSheetArray = new JSONArray();
			try {

				HttpClient httpClient = new DefaultHttpClient();
				httpClient.getParams().setParameter("http.connection.timeout", 10000);
				HttpGet httpGet = new HttpGet(serviceUrl);
				HttpResponse httpResponse = httpClient.execute(httpGet);
				int statusCode = httpResponse.getStatusLine().getStatusCode();
				if (statusCode == 200) {
					progressSheetArray = JSONArray.fromObject(EntityUtils.toString(httpResponse.getEntity()));
				}
				else if (statusCode == 404) {
					throw new Exception("Service " + serviceUrl + " not found.");
				}
				logger.debug("StatusCode:" + statusCode);
			} catch (Exception ex) {
				MiscUtils.getLogger().debug("EctDisplayProgressSheetAction: Error connecting to progresssheet: " + ex.getMessage());
				NavBarDisplayDAO.Item item = NavBarDisplayDAO.Item();
				item.setTitle("404 error");
				item.setLinkTitle("Service " + serviceUrl + " not found");
				Dao.addItem(item);
			}
			
    		for (int i = 0; i < progressSheetArray.size(); i++) {
    			JSONObject progressSheet = (JSONObject) progressSheetArray.get(i);
    			NavBarDisplayDAO.Item item = NavBarDisplayDAO.Item();
    			
        		String title = "Progress Sheet";
    			String demographicId = progressSheet.getString("demographicId");
    			String appointmentId = progressSheet.getString("appointmentId");
				String formId = progressSheet.getString("formId");
    			String encounterDate = progressSheet.getString("encounterDate");
    			
    			DateFormat formatter = new SimpleDateFormat(dbFormat);
    			try {
    				date = formatter.parse(encounterDate);
    				serviceDateStr = DateUtils.formatDate(date, request.getLocale());
    			} catch (ParseException ex) {
    				MiscUtils.getLogger().debug("EctDisplayProgressSheetAction: Error creating date " + ex.getMessage());
    				serviceDateStr = "Error";
    				date = null;
    			}
    
    			item.setDate(date);
    			hash = Math.abs(winName.hashCode());
    			

    			url = "popupPage(700,800,'" + hash + "', '/progresssheet/?demographicId=" + demographicId + "&appointmentId=" + appointmentId + "&providerId=" + providerId+ "'); return false;";
    			
    			item.setLinkTitle(title + " " + serviceDateStr);// + "\nLast updated:" + "");
    			item.setTitle(title);			
    			item.setURL(url);
    			
    			Dao.addItem(item);
    		}
    		javascript.append("</script>");
    
    		Dao.setJavaScript(javascript.toString());
    		return true;
    	}
    }

	public String getCmd() {
		return cmd;
	}
}
