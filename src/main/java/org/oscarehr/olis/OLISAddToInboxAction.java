/**
 * Copyright (c) 2008-2012 Indivica Inc.
 *
 * This software is made available under the terms of the
 * GNU General Public License, Version 2, 1991 (GPLv2).
 * License details are available via "indivica.ca/gplv2"
 * and "gnu.org/licenses/gpl-2.0.html".
 */
package org.oscarehr.olis;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.codec.binary.Base64;
import org.apache.commons.lang.StringEscapeUtils;
import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.actions.DispatchAction;
import org.codehaus.jettison.json.JSONArray;
import org.codehaus.jettison.json.JSONException;
import org.codehaus.jettison.json.JSONObject;
import org.oscarehr.PMmodule.dao.ProviderDao;
import org.oscarehr.common.dao.DemographicDao;
import org.oscarehr.common.dao.OscarLogDao;
import org.oscarehr.common.dao.PatientLabRoutingDao;
import org.oscarehr.common.model.Demographic;
import org.oscarehr.common.model.OscarLog;
import org.oscarehr.common.model.PatientLabRouting;
import org.oscarehr.common.model.Provider;
import org.oscarehr.util.LoggedInInfo;
import org.oscarehr.util.MiscUtils;
import org.oscarehr.util.SpringUtils;

import oscar.log.LogAction;
import oscar.log.LogConst;
import oscar.oscarLab.FileUploadCheck;
import oscar.oscarLab.ca.all.upload.HandlerClassFactory;
import oscar.oscarLab.ca.all.upload.handlers.OLISHL7Handler;
import oscar.oscarLab.ca.on.CommonLabResultData;

public class OLISAddToInboxAction extends DispatchAction {

	static Logger logger = MiscUtils.getLogger();

	public ActionForward saveMatch(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response)  {

		String uuid = request.getParameter("uuid");
		String demographicNo = request.getParameter("demographicNo");
		
		Map<String,String> patientSaveMap = (Map<String,String>)request.getSession().getAttribute("olisPatientMatches");
		if(patientSaveMap == null) {
			patientSaveMap = new HashMap<String,String>();
		}
		
		patientSaveMap.put(uuid, demographicNo);
		
		request.getSession().setAttribute("olisPatientMatches", patientSaveMap);
		
		
		return null;
	}
	
	public ActionForward bulkAddToInbox(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws JSONException, IOException {
		LoggedInInfo loggedInInfo=LoggedInInfo.getLoggedInInfoFromSession(request);
		String providerNo=loggedInInfo.getLoggedInProviderNo();
		String encodedData = request.getParameter("data");
		String data = new String(Base64.decodeBase64(encodedData));
		JSONObject obj = new JSONObject(data);
		JSONArray arr = obj.getJSONArray("items");
		
		List<String> errors = new ArrayList<String>();
		List<String> successful = new ArrayList<String>();
		
		
		for(int x=0;x<arr.length();x++) {
			JSONObject item = arr.getJSONObject(x);
			String uuidToAdd = item.getString("uuid");
			
			String fileLocation = System.getProperty("java.io.tmpdir") + "/olis_" + item.getString("uuid") + ".response";
			File file = new File(fileLocation);
			OLISHL7Handler msgHandler = (OLISHL7Handler) HandlerClassFactory.getHandler("OLIS_HL7");	
			
			InputStream is = null;
			try {
				is = new FileInputStream(fileLocation);
				int check = FileUploadCheck.addFile(file.getName(), is, providerNo);
				String successMessage = "";
				
				if (check != FileUploadCheck.UNSUCCESSFUL_SAVE) {
					if (msgHandler.parse(loggedInInfo, "OLIS_HL7", fileLocation, check, item.getBoolean("addToInbox")) != null) {
						successMessage = "Successully added lab to EMR.";
						request.setAttribute("result", "Success");
						
						Map<String,String> patientSaveMap = (Map<String,String>)request.getSession().getAttribute("olisPatientMatches");
						if(patientSaveMap != null && patientSaveMap.get(uuidToAdd) != null) {
							//match the patient
							PatientLabRouting plr = new PatientLabRouting();
							plr.setCreated(new Date());
							plr.setDateModified(new Date());
							plr.setDemographicNo(Integer.parseInt(patientSaveMap.get(uuidToAdd)));
							plr.setLabNo(msgHandler.getLastSegmentId());
							plr.setLabType("HL7");
							PatientLabRoutingDao plrDao = SpringUtils.getBean(PatientLabRoutingDao.class);
							plrDao.persist(plr);
							
						}
						if (item.getBoolean("acknowledge")) {
							String demographicID = getDemographicIdFromLab("HL7", msgHandler.getLastSegmentId());
							LogAction.addLog((String) request.getSession().getAttribute("user"), LogConst.ACK, LogConst.CON_HL7_LAB, "" + msgHandler.getLastSegmentId(), request.getRemoteAddr(), demographicID);
							CommonLabResultData.updateReportStatus(msgHandler.getLastSegmentId(), providerNo, 'A', "Sign-off from OLIS inbox", "HL7");
							successMessage = "Successully added lab to EMR and acknowledged lab in inbox.";

						}
						
						request.setAttribute("result",successMessage);
						successful.add(uuidToAdd);
					} else {
						errors.add("Error adding Lab to EMR");
					}
				} else {
					errors.add("Lab already Added");
				}

			} catch (Exception e) {
				MiscUtils.getLogger().error("Couldn't add requested OLIS lab to Inbox.", e);
				errors.add(e.getMessage());
			} finally {
				try {
					is.close();
				} catch (IOException e) {
					//ignore
				}
			}

		}
		
		JSONObject obj2 = new JSONObject();
		obj2.put("successIds", successful);
		obj2.write(response.getWriter());
		
		return null;
	}

	public ActionForward bulkRemove(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws JSONException, IOException {
		LoggedInInfo loggedInInfo=LoggedInInfo.getLoggedInInfoFromSession(request);
		String providerNo=loggedInInfo.getLoggedInProviderNo();
		String uuidsToAdd = request.getParameter("uuids");

		List<String> errors = new ArrayList<String>();
		List<String> successful = new ArrayList<String>();
		
		
		for(String uuidToAdd : uuidsToAdd.split(",")) {
			String fileLocation = System.getProperty("java.io.tmpdir") + "/olis_" + uuidToAdd + ".response";
			File file = new File(fileLocation);
			OLISHL7Handler msgHandler = (OLISHL7Handler) HandlerClassFactory.getHandler("OLIS_HL7");	
			
			LogAction.addLog(LoggedInInfo.getLoggedInInfoFromSession(request), "OLIS","rejected", uuidToAdd, "","");
			successful.add(uuidToAdd);

		}
		
		JSONObject obj = new JSONObject();
		obj.put("successIds", successful);
		
		obj.write(response.getWriter());
		
		return null;
	}

	public ActionForward remove(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response)  {
		LoggedInInfo loggedInInfo=LoggedInInfo.getLoggedInInfoFromSession(request);
		String providerNo=loggedInInfo.getLoggedInProviderNo();
		String uuid = request.getParameter("uuid");

		
		List<String> errors = new ArrayList<String>();
		List<String> successful = new ArrayList<String>();
		
		
		String fileLocation = System.getProperty("java.io.tmpdir") + "/olis_" + uuid + ".response";
		File file = new File(fileLocation);
		OLISHL7Handler msgHandler = (OLISHL7Handler) HandlerClassFactory.getHandler("OLIS_HL7");	
		
		LogAction.addLog(LoggedInInfo.getLoggedInInfoFromSession(request), "OLIS","rejected", uuid, "","");
		successful.add(uuid);
		
		request.setAttribute("result", "Successfully removed item");
		return null;
	}

	
	@Override
	protected ActionForward unspecified(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response)  {

		LoggedInInfo loggedInInfo=LoggedInInfo.getLoggedInInfoFromSession(request);
		String providerNo=loggedInInfo.getLoggedInProviderNo();
		
		String uuidToAdd = request.getParameter("uuid");
		String pFile = request.getParameter("file");
		String pAck = request.getParameter("ack");
		String addToMyInboxParameter = request.getParameter("addToMyInbox");
		boolean doNotAddToMyInbox = addToMyInboxParameter!= null && "false".equals(addToMyInboxParameter);
				
		boolean doFile = false, doAck = false;
		if (pFile != null && pFile.equals("true")) {
			doFile = true;
		}
		if (pAck != null && pAck.equals("true")) {
			doAck = true;
		}

		String fileLocation = System.getProperty("java.io.tmpdir") + "/olis_" + uuidToAdd + ".response";
		File file = new File(fileLocation);
		OLISHL7Handler msgHandler = (OLISHL7Handler) HandlerClassFactory.getHandler("OLIS_HL7");

		InputStream is = null;
		try {
			is = new FileInputStream(fileLocation);
			int check = FileUploadCheck.addFile(file.getName(), is, providerNo);
			String successMessage = "";
			
			if (check != FileUploadCheck.UNSUCCESSFUL_SAVE) {
				if (msgHandler.parse(loggedInInfo, "OLIS_HL7", fileLocation, check, !doNotAddToMyInbox) != null) {
					successMessage = "Successully added lab to EMR.";
					request.setAttribute("result", "Success");
					if (doFile) {
						ArrayList<String[]> labsToFile = new ArrayList<String[]>();
						String item[] = new String[] { String.valueOf(msgHandler.getLastSegmentId()), "HL7" };
						labsToFile.add(item);
						CommonLabResultData.fileLabs(labsToFile, providerNo);
						successMessage = "Successully added lab to EMR and filed lab in inbox.";
					}
					if (doAck) {
						String demographicID = getDemographicIdFromLab("HL7", msgHandler.getLastSegmentId());
						LogAction.addLog((String) request.getSession().getAttribute("user"), LogConst.ACK, LogConst.CON_HL7_LAB, "" + msgHandler.getLastSegmentId(), request.getRemoteAddr(), demographicID);
						CommonLabResultData.updateReportStatus(msgHandler.getLastSegmentId(), providerNo, 'A', "Sign-off from OLIS inbox", "HL7");
						successMessage = "Successully added lab to EMR and acknowledged lab in inbox.";

					}
					request.setAttribute("result",successMessage);
				} else {
					request.setAttribute("result", "Error adding Lab to EMR");
				}
			} else {
				request.setAttribute("result", "Lab already Added. Nothing to do");
			}

		} catch (Exception e) {
			MiscUtils.getLogger().error("Couldn't add requested OLIS lab to Inbox.", e);
			request.setAttribute("result", "Error");
		} finally {
			try {
				is.close();
			} catch (IOException e) {
				//ignore
			}
		}

		return mapping.findForward("ajax");
	}
	

	private static String getDemographicIdFromLab(String labType, int labNo) {
		PatientLabRoutingDao dao = SpringUtils.getBean(PatientLabRoutingDao.class);
		PatientLabRouting routing = dao.findDemographics(labType, labNo);
		return routing == null ? "" : String.valueOf(routing.getDemographicNo());
	}
	
	
	public ActionForward viewLog(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
		ProviderDao providerDao = SpringUtils.getBean(ProviderDao.class);
		DemographicDao demographicDao = SpringUtils.getBean(DemographicDao.class);
		
		String start = request.getParameter("start");
		String length = request.getParameter("length");

		String orderingColumnIndex = request.getParameter("order[0][column]"); //idx (eg 0)
		String orderingColumnDirection = request.getParameter("order[0][dir]"); //asc,desc

		
		//setup a column map from request parameters
		Map<Integer, ColumnInfo> columnMap = new HashMap<Integer, ColumnInfo>();
		int idx = 0;
		while (true) {
			if (request.getParameter("columns[" + idx + "][data]") == null) {
				break;
			}
			columnMap.put(idx, new ColumnInfo(idx, request.getParameter("columns[" + idx + "][data]")));
			idx++;
		}

		String orderBy = null;

		if (!StringUtils.isEmpty(orderingColumnIndex)) {
			ColumnInfo columnInfo = columnMap.get(Integer.parseInt(orderingColumnIndex));
			if ("transaction_date".equals(columnInfo.getData())) {
				orderBy = "created";
			} else if ("transaction_type".equals(columnInfo.getData())) {
				orderBy = "transactionType";
			}
		}
		
		OscarLogDao logDao = SpringUtils.getBean(OscarLogDao.class);
		List<OscarLog> logs = logDao.findByAction("OLIS",Integer.parseInt(start), Integer.parseInt(length), StringEscapeUtils.escapeSql(orderBy), StringEscapeUtils.escapeSql(orderingColumnDirection));
		int draw = 0;

		JSONArray data = new JSONArray();

		SimpleDateFormat fmt = new SimpleDateFormat("yyyy-MM-dd HH:mm");

		for (OscarLog l : logs) {
			Provider p = null;
			if(!StringUtils.isEmpty(l.getProviderNo())) {
				p = providerDao.getProvider(l.getProviderNo());
			}
			Demographic demographic = null;
			if(l.getDemographicId() != null) {
				demographic = demographicDao.getDemographicById(l.getDemographicId());
			}
			
			
			JSONObject data1 = new JSONObject();
			data1.put("id", l.getId());
			data1.put("transaction_date", fmt.format(l.getCreated()));
			data1.put("external_system", "OLIS");
			data1.put("initiating_provider", p != null ? p.getFormattedName() : "");
			data1.put("content", l.getContent() != null ? l.getContent() : "");
			data1.put("contentId", l.getContentId() != null ? l.getContentId() :"");
			data1.put("data",l.getData() != null ? l.getData().replaceAll("\r", "<br/>") : "");
			data1.put("demographic", demographic != null ?demographic.getFormattedName():"");
			
			data.put(data1);
		}

		JSONObject obj = new JSONObject();
		obj.put("draw", ++draw);
		obj.put("recordsTotal", data.length());
		obj.put("recordsFiltered", data.length());
		obj.put("data", data);
		//obj.put("error", "error occurred");

		response.setContentType("application/json");
		obj.write(response.getWriter());

		return null;
	}
}
class ColumnInfo {
	private int index;
	private String data;

	public ColumnInfo() {
	}

	public ColumnInfo(int index, String data) {
		this.index = index;
		this.data = data;
	}

	public int getIndex() {
		return index;
	}

	public void setIndex(int index) {
		this.index = index;
	}

	public String getData() {
		return data;
	}

	public void setData(String data) {
		this.data = data;
	}

}