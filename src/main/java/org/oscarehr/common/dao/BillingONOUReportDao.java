package org.oscarehr.common.dao;

import org.apache.commons.lang.StringUtils;
import org.oscarehr.common.model.BillingONOUReport;
import org.springframework.stereotype.Repository;
import oscar.util.ParamAppender;

import javax.persistence.Query;
import java.util.Date;
import java.util.List;

@Repository
public class BillingONOUReportDao extends AbstractDao<BillingONOUReport> {

    public BillingONOUReportDao() {
        super(BillingONOUReport.class);
    }

    public List<BillingONOUReport> findByHin(String hin) {
        ParamAppender appender = getAppender("ou");

        appender.and("ou.patientHin = :hin", "hin", hin);
        appender.addOrder("ou.reportDate");

        Query query = entityManager.createQuery(appender.toString());
        appender.setParams(query);
        return query.getResultList();
    }

    public List<BillingONOUReport> match(Date reportDate, Date periodStart, Date periodEnd, String reportFile) {
        ParamAppender appender = getAppender("ou");

        appender.and("ou.reportDate = :reportDate", "reportDate", reportDate);
        appender.and("ou.reportPeriodStart = :periodStart", "periodStart", periodStart);
        appender.and("ou.reportPeriodEnd = :periodEnd", "periodEnd", periodEnd);
        if(StringUtils.isNotEmpty(reportFile)) {
            appender.and("ou.reportFile like :reportFile", "reportFile", reportFile.substring(0, reportFile.indexOf(".")) + "%");
        }
        appender.addOrder("ou.reportDate");

        Query query = entityManager.createQuery(appender.toString());
        appender.setParams(query);
        return query.getResultList();

    }
}
