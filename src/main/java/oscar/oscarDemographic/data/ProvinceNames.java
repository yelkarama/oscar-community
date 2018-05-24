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


package oscar.oscarDemographic.data;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.Map;

import oscar.OscarProperties;

public class ProvinceNames extends ArrayList<String> {

    public static ProvinceNames getInstance() {
        return pNames;
    }

    private static boolean isDefined = true;
    static ProvinceNames pNames = new ProvinceNames();

    private ProvinceNames() {
        OscarProperties props = OscarProperties.getInstance();
        if (props.getProperty("province_names") == null || props.getProperty("province_names").equals("")) {
            isDefined = false;
            return;
        }
        String[] pNamesStr = props.getProperty("province_names").split("\\|");
        for (int i = 0; i < pNamesStr.length; i++) {
            add(pNamesStr[i]);
        }
    }

    public boolean isDefined() {
        return isDefined;
    }
    
    public static Map<String, String> defaultProvinces;
    public static Map<String, String> getDefaultProvinces() {
        if (defaultProvinces != null) { return defaultProvinces; }
        defaultProvinces = new LinkedHashMap<String, String>();
        defaultProvinces.put("AB", "Alberta");
        defaultProvinces.put("BC", "British Columbia");
        defaultProvinces.put("MB", "Manitoba");
        defaultProvinces.put("NB", "New Brunswick");
        defaultProvinces.put("NL", "Newfoundland & Labrador");
        defaultProvinces.put("NT", "Northwest Territory");
        defaultProvinces.put("NS", "Nova Scotia");
        defaultProvinces.put("NU", "Nunavut");
        defaultProvinces.put("ON", "Ontario");
        defaultProvinces.put("PE", "Prince Edward Island");
        defaultProvinces.put("QC", "Quebec");
        defaultProvinces.put("SK", "Saskatchewan");
        defaultProvinces.put("YT", "Yukon");
        defaultProvinces.put("US", "US resident");
        defaultProvinces.put("US-AK", "Alaska");
        defaultProvinces.put("US-AL", "Alabama");
        defaultProvinces.put("US-AR", "Arkansas");
        defaultProvinces.put("US-AZ", "Arizona");
        defaultProvinces.put("US-CA", "California");
        defaultProvinces.put("US-CO", "Colorado");
        defaultProvinces.put("US-CT", "Connecticut");
        defaultProvinces.put("US-CZ", "Canal Zone");
        defaultProvinces.put("US-DC", "District Of Columbia");
        defaultProvinces.put("US-DE", "Delaware");
        defaultProvinces.put("US-FL", "Florida");
        defaultProvinces.put("US-GA", "Georgia");
        defaultProvinces.put("US-GU", "Guam");
        defaultProvinces.put("US-HI", "Hawaii");
        defaultProvinces.put("US-IA", "Iowa");
        defaultProvinces.put("US-ID", "Idaho");
        defaultProvinces.put("US-IL", "Illinois");
        defaultProvinces.put("US-IN", "Indiana");
        defaultProvinces.put("US-KS", "Kansas");
        defaultProvinces.put("US-KY", "Kentucky");
        defaultProvinces.put("US-LA", "Louisiana");
        defaultProvinces.put("US-MA", "Massachusetts");
        defaultProvinces.put("US-MD", "Maryland");
        defaultProvinces.put("US-ME", "Maine");
        defaultProvinces.put("US-MI", "Michigan");
        defaultProvinces.put("US-MN", "Minnesota");
        defaultProvinces.put("US-MO", "Missouri");
        defaultProvinces.put("US-MS", "Mississippi");
        defaultProvinces.put("US-MT", "Montana");
        defaultProvinces.put("US-NC", "North Carolina");
        defaultProvinces.put("US-ND", "North Dakota");
        defaultProvinces.put("US-NE", "Nebraska");
        defaultProvinces.put("US-NH", "New Hampshire");
        defaultProvinces.put("US-NJ", "New Jersey");
        defaultProvinces.put("US-NM", "New Mexico");
        defaultProvinces.put("US-NU", "Nunavut");
        defaultProvinces.put("US-NV", "Nevada");
        defaultProvinces.put("US-NY", "New York");
        defaultProvinces.put("US-OH", "Ohio");
        defaultProvinces.put("US-OK", "Oklahoma");
        defaultProvinces.put("US-OR", "Oregon");
        defaultProvinces.put("US-PA", "Pennsylvania");
        defaultProvinces.put("US-PR", "Puerto Rico");
        defaultProvinces.put("US-RI", "Rhode Island");
        defaultProvinces.put("US-SC", "South Carolina");
        defaultProvinces.put("US-SD", "South Dakota");
        defaultProvinces.put("US-TN", "Tennessee");
        defaultProvinces.put("US-TX", "Texas");
        defaultProvinces.put("US-UT", "Utah");
        defaultProvinces.put("US-VA", "Virginia");
        defaultProvinces.put("US-VI", "Virgin Islands");
        defaultProvinces.put("US-VT", "Vermont");
        defaultProvinces.put("US-WA", "Washington");
        defaultProvinces.put("US-WI", "Wisconsin");
        defaultProvinces.put("US-WV", "West Virginia");
        defaultProvinces.put("US-WY", "Wyoming");
        return defaultProvinces;
    }
}
