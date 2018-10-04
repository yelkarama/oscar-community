package org.oscarehr.common.dao;

import java.util.Calendar;
import java.util.GregorianCalendar;
import java.util.List;
import org.apache.log4j.Logger;
import org.hibernate.Hibernate;
import org.hibernate.SQLQuery;
import org.hibernate.Session;
import org.oscarehr.util.MiscUtils;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.context.ApplicationEventPublisherAware;
import org.springframework.orm.hibernate3.support.HibernateDaoSupport;
import cds.PatientRecordDocument.PatientRecord;

/*
 * PCSS project: Add results of a dx registry query to a document (missing from current extract)
 * 
 */

public class DiseaseRegistryPCDS_Dao extends HibernateDaoSupport implements ApplicationEventPublisherAware  {
	@Override
    public void setApplicationEventPublisher(ApplicationEventPublisher arg0) {

	    publisher = arg0;
    }
	
	/*
	 * Update Omd document with disease registry elements not included in the general export."
	 */
	public boolean getDiseaseReg(String demographic, PatientRecord patientRec){
		
		boolean status = false;
		Session session = getSession();
		try {
			//                                                  date         char1   char10          char20      
			SQLQuery sqlQuery = session.createSQLQuery(""
					+ "SELECT "
					+ "		DX.start_date, "
					+ "		DX.status, "			// A, C or D
					+ "		DX.dxresearch_code,"
					+ "		I.description "
					+ "FROM "
					+ "		dxresearch DX "
					+ "LEFT JOIN "
					+ "		icd9 I "
					+ "ON "
					+ "		DX.dxresearch_code = I.icd9 "
					+ "WHERE "
					+ "		DX.coding_system = 'icd9' AND "
					+ "		demographic_no = '" + demographic + "' "
					+ "ORDER BY "
					+ "		start_date")
					.addScalar("start_date",Hibernate.DATE)
					.addScalar("status", Hibernate.STRING)
					.addScalar("dxresearch_code",Hibernate.STRING)
					.addScalar("description",Hibernate.STRING);
			if (DEBUG){
				log.info("\t\t" + this.getClass().getName() +"query created : " + sqlQuery.getQueryString());
			}
			List<Object[]> list = sqlQuery.list();
			if (DEBUG){
				if (list.isEmpty()){
				log.info("\t\t" + this.getClass().getName() +"list is empty : ");
				}else {
					log.info("\t\t" + this.getClass().getName() +"list is NOT empty and contains itemcount:" + list.size());
				}
			}
			// add missing data to document.
			
			for (Object[] dx : list){
				cds.ProblemListDocument.ProblemList problemList = patientRec.addNewProblemList();
				problemList.setCategorySummaryLine("OSCAR Disease Registry Entry");
				problemList.setProblemDiagnosisDescription("OSCAR Disease Registry Entry");
				problemList.setProblemDescription("" + dx[3]);
				String dxStatus = "" + dx[1];
				if (dxStatus.compareToIgnoreCase("A")==0){
					problemList.setProblemStatus("Active");
				}else if(dxStatus.compareToIgnoreCase("I")==0){
					problemList.setProblemStatus("Inactive");
				}
				
				
				//cdsDt.ResidualInformation info = problemList.addNewResidualInfo();
				
				// date of onset
				cdsDt.DateFullOrPartial onset = problemList.addNewOnsetDate();
				Calendar onsetCal = new GregorianCalendar();
				//Date onsetDate = new Date(((java.sql.Date)dx[0]).getTime());
				System.out.println("Should be the date: " + dx[0]);
				onsetCal.setTimeInMillis(((java.sql.Date)dx[0]).getTime());

				// diagnosis code
				onset.setFullDate(onsetCal);
				cdsDt.StandardCoding coding = problemList.addNewDiagnosisCode();
				coding.setStandardCodingSystem("ICD-9");
				coding.setStandardCode("" + dx[2]);
			}
			
			
			if (DEBUG){
				log.info("\t\t" + this.getClass().getName() +"Should return the value here.");
			}
			
			session.close();
			status = true;
		} finally {
			
			this.releaseSession(session);
		}
		
		return status;
	}

	
	
	
	private ApplicationEventPublisher publisher;
	private static final boolean DEBUG = true;
	private static Logger log = MiscUtils.getLogger();

}
