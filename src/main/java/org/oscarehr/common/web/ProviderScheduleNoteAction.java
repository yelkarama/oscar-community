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


package org.oscarehr.common.web;

import org.apache.commons.lang.StringEscapeUtils;
import org.apache.log4j.Logger;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.actions.DispatchAction;
import org.oscarehr.common.dao.ProviderScheduleNoteDao;
import org.oscarehr.common.model.ProviderScheduleNote;
import org.oscarehr.util.MiscUtils;
import org.oscarehr.util.SpringUtils;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;

public class ProviderScheduleNoteAction extends DispatchAction {
    private static Logger logger = MiscUtils.getLogger();
    
    public ProviderScheduleNoteAction() {}

    public ActionForward updateDayNote(ActionMapping mapping, ActionForm form, 
                                          HttpServletRequest request, HttpServletResponse response) {
        ProviderScheduleNoteDao providerScheduleNoteDao = SpringUtils.getBean(ProviderScheduleNoteDao.class);
        
        String providerNo = request.getParameter("providerNo");
        String dateString = request.getParameter("date");
        String noteText = request.getParameter("note");
        if (noteText == null || noteText.isEmpty()) {
            noteText = "Click to add note";
        }
        ProviderScheduleNote note = null;
        try {
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
            Date noteDate = sdf.parse(dateString);
            note = providerScheduleNoteDao.findByProviderNoAndDate(providerNo, noteDate);
            if (note != null) {
                note.setNote(noteText);
            } else {
                note = new ProviderScheduleNote(providerNo, noteDate, noteText);
            }
            providerScheduleNoteDao.saveEntity(note);
        } catch (ParseException e) {
            logger.error("ProviderScheduleNote date note parsable (" + dateString + ")", e);
        }
        
        if (note != null) {
            request.setAttribute("note", StringEscapeUtils.escapeHtml(note.getNote()));
            return mapping.findForward("ajax");
        } else {
            return null;
        }
    }
}
