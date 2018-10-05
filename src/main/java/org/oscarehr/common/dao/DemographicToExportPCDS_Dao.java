package org.oscarehr.common.dao;

import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import org.apache.log4j.Logger;
import org.hibernate.SQLQuery;
import org.hibernate.Session;
import org.oscarehr.util.MiscUtils;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.context.ApplicationEventPublisherAware;
import org.springframework.orm.hibernate3.support.HibernateDaoSupport;

/*
 * PCSS project: generate list to use for demographic export
 *  two modes; bulk and incremental
 *  - bulk will have to be staged (1000 per export?) not sure how to track
 *  - incremental will receive a time stamp then find all demographic exports since that time
 */

public class DemographicToExportPCDS_Dao extends HibernateDaoSupport implements ApplicationEventPublisherAware  {

	@Override
    public void setApplicationEventPublisher(ApplicationEventPublisher arg0) {
	    publisher = arg0;
    }
	
	/*
	 * Use timestamp to indicate start time for "records updated since"
	 */
	public List<String> getIncremental(Timestamp timestamp){
		
		List<String> demographics = new ArrayList<String>();
		Session session = getSession();
		try {
			// may need to tweak for performance.  Query must find any interection for a patient newer than the previous timestamp.
			// original query
			String queryINC_SIMPLE = "select T1.demographic_no from casemgmt_note T1 INNER JOIN demographic T2 ON T1.demographic_no=T2.demographic_no where T2.patient_status = 'AC' AND update_date >= '" + timestamp.toString()+ "' group by demographic_no";
			
			// search multiple tables for interaction, add another union if we're missing something but follow the format of comparing the active patient
			String queryINC_COMPLEX = ""
					+ "SELECT T1.demographic_no FROM casemgmt_note T1 "
					+ "INNER JOIN demographic T2 ON T1.demographic_no=T2.demographic_no "
					+ "WHERE T1.update_date > '" + timestamp.toString()+ "' AND T2.patient_status='AC' "
					+ " "
					+ "UNION "
					+ " "
					+ "SELECT T1.demographic_no FROM  billing_on_cheader1 T1 "
					+ "INNER JOIN demographic T2 ON T1.demographic_no=T2.demographic_no "
					+ "WHERE T1.billing_date > '" + timestamp.toString()+ "' AND T2.patient_status='AC' "
					+ " "
					+ "UNION "
					+ " "
					+ "SELECT T1.demographic_no FROM appointment T1 "
					+ "INNER JOIN demographic T2 ON T1.demographic_no=T2.demographic_no "
					+ "WHERE T1.appointment_date > '" + timestamp.toString()+ "' AND T2.patient_status='AC' "
					+ " "
					+ "UNION "
					+ " "
					+ "SELECT T1.demographicNo FROM measurements T1 "
					+ "INNER JOIN demographic T2 ON T1.demographicNo=T2.demographic_no "
					+ "WHERE T1.dateObserved > '" + timestamp.toString()+ "' AND T2.patient_status='AC' "
					+ " "
					+ "UNION "
					+ " "
					+ "SELECT T1.demographic_no FROM prescription T1 "
					+ "INNER JOIN demographic T2 ON T1.demographic_no=T2.demographic_no "
					+ "WHERE T1.date_prescribed > '" + timestamp.toString()+ "' AND T2.patient_status='AC' "
					+ " "
					+ "UNION "
					+ " "
					+ "SELECT T1.demographic_no FROM preventions T1 "
					+ "INNER JOIN demographic T2 ON T1.demographic_no=T2.demographic_no "
					+ "WHERE T1.prevention_date > '" + timestamp.toString()+ "' AND T2.patient_status='AC' "
					+ "";
			SQLQuery sqlQuery = session.createSQLQuery(queryINC_COMPLEX);
			if (DEBUG){
				log.info("\t\t" + this.getClass().getName() +" : query created : " + sqlQuery.getQueryString());
			}
			List<?> list = sqlQuery.list();
			log.info("\t\t" + this.getClass().getName() +" : query created : Query should be OK. listEmpty=" + list.isEmpty() + ", date=" + (new Date(timestamp.getTime()).toString()));
			
			if (!list.isEmpty()){
				
				if (DEBUG){
					log.info("\t\t" + this.getClass().getName() +" : list size : " + list.size() + ", list element 1 is:" + list.get(0).toString());
				}
				if (DEBUG){
					log.info("\t\t" + this.getClass().getName() +" #### FOUND " + list.size() + " CPP TO SEND");
				}

				for (Object demographic : list){
					demographics.add("" + demographic);
				}
			}else {
				if (DEBUG){
					log.info("\t\t" + this.getClass().getName() +" ###### NO CPP TO UPDATE");
				}
			}
			

			
			session.close();
			return demographics;
		} finally {
			
			this.releaseSession(session);
		}
	}
	
	/*
	 * For bulk upload, must only to a certain number at a time (1000?)
	 */
	public long getTotalActive(){
		Long totalActive = new Long(0);
		if (DEBUG){
			log.info("\t\t" + this.getClass().getName() +"Getting total active");
		}
	
		Session session = getSession();
		try {
			SQLQuery sqlQuery = session.createSQLQuery("SELECT COUNT(*) FROM demographic WHERE patient_status='AC'");
			if (DEBUG){
				log.info("\t\t" + this.getClass().getName() +"query created : " + sqlQuery.getQueryString());
			}
			List<?> list = sqlQuery.list();
			
			if (DEBUG){
				log.info("\t\t" + this.getClass().getName() +"list size : " + list.size() + ", list element 1 is:" + list.get(0).toString());
			}
			
			if (list.size() > 0){
				totalActive = new Long("" + list.get(0));
			}
			
			if (DEBUG){
				log.info("\t\t" + this.getClass().getName() +"Should return the value here.");
			}
			session.close();
			return totalActive.longValue();
		} finally {
			
			this.releaseSession(session);
		}
	}
	
	public int getPageValue(){
		return MAX_EXPORT;
	}
	
	public List<String> getBulk(int page){
		List<String> demographics = new ArrayList<String>();
		Session session = getSession();
		try {
			SQLQuery sqlQuery = session.createSQLQuery("SELECT demographic_no FROM demographic where patient_status='AC' LIMIT  "+ MAX_EXPORT + " OFFSET " + (page * MAX_EXPORT) );
			if (DEBUG){
				log.info("\t\t" + this.getClass().getName() +"query created : " + sqlQuery.getQueryString());
			}
			List<?> list = sqlQuery.list();
			if (DEBUG){
				log.info("\t\t" + this.getClass().getName() +"list size : " + list.size() + ", list element 1 is:" + list.get(0).toString());
			}
			for (Object demographic : list){
				demographics.add("" + demographic);
			}
			
			
			if (DEBUG){
				log.info("\t\t" + this.getClass().getName() +"Should return the value here.");
			}
			
			session.close();
			if (DEBUG){
				System.out.println("RETURNING BULK DEMOGRAPHICS : number of records=" + demographics.size());
			}
			return demographics;
		} finally {
			
			this.releaseSession(session);
		}
	}
	
	
	
	private ApplicationEventPublisher publisher;
	private static final boolean DEBUG = true;
	private static final int MAX_EXPORT = 100;
	private static Logger log = MiscUtils.getLogger();

}
