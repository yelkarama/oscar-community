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

package oscar.eform;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Util class for adding csrf mitigation to eforms
 */
public class EFormCsrfUtil {
    
    public static final String CONTEXT_PATH_TEMPLATE = "${request_context_path}";
    public static final String CSRF_SCRIPT_TAG_TEMPLATE = "<script src=\"" + CONTEXT_PATH_TEMPLATE + "/JavaScriptServlet\" type=\"text/javascript\"></script>";
    public static final Pattern HTML_HEAD_TAG_PATTERN = Pattern.compile("<head.*?>", Pattern.CASE_INSENSITIVE);
    public static final Pattern HTML_BODY_TAG_PATTERN = Pattern.compile("<body.*?>", Pattern.CASE_INSENSITIVE);

    /**
     * A method that attempts to add a csrf JavaScriptServlet script tag link to a eform html document. If successfully 
     * added the script tag will either be in the head tag or if that tag does not exist, in the body
     * @param htmlDocument The eform html document as a string
     * @param contextPath the context path the system is deployed as
     * @return the eform html document with the script tag added
     */
    public static String addCsrfScriptTagToHtml(String htmlDocument, String contextPath) {
        String scriptTag = CSRF_SCRIPT_TAG_TEMPLATE.replace(CONTEXT_PATH_TEMPLATE, contextPath);
        // If the document already has a script tag within it, skip adding it here
        if (!htmlDocument.contains(scriptTag)) {
            // Find first instance of a head tag
            Matcher headTagMatcher = HTML_HEAD_TAG_PATTERN.matcher(htmlDocument);
            if (headTagMatcher.find()) {
                // Add script tag to head tag
                htmlDocument = insertScriptTag(htmlDocument, headTagMatcher.end(), scriptTag);
            } else {
                // Try inserting after body tag
                Matcher bodyTagMatcher = HTML_BODY_TAG_PATTERN.matcher(htmlDocument);
                if (bodyTagMatcher.find()) {
                    htmlDocument = insertScriptTag(htmlDocument, bodyTagMatcher.end(), scriptTag);
                }
            }
        }
        
        return htmlDocument;
    }

    /**
     * Inserts the csrf script tag in to the provided html document at the provided index
     * @param htmlDocument The htmlDocument to modify
     * @param endOfMatchIndex The index to insert the scriptTag
     * @param scriptTag The script tag with context set to add
     * @return The modified htmlDocument with scriptTag added
     */
    private static String insertScriptTag(String htmlDocument, int endOfMatchIndex, String scriptTag) {
        // Insert csrf script tag after matched tag
        htmlDocument = htmlDocument.substring(0, endOfMatchIndex)
                + scriptTag
                + htmlDocument.substring(endOfMatchIndex);
        return htmlDocument;
    }
}