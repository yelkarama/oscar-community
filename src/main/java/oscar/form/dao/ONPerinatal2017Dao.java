package oscar.form.dao;

import org.oscarehr.common.dao.AbstractDao;
import org.springframework.stereotype.Repository;
import oscar.form.model.FormONPerinatal2017;

import javax.persistence.Query;
import java.util.List;

@Repository
public class ONPerinatal2017Dao extends AbstractDao<FormONPerinatal2017> {
    public ONPerinatal2017Dao() {
        super(FormONPerinatal2017.class);
    }
    
    public List<FormONPerinatal2017> findAllDistinctForms(Integer demographicNo) {
        String sql = "select frm from FormONPerinatal2017 frm " +
                "where frm.demographicNo = :demographicNo " +
                "and frm.id = (select max(frm2.id) from FormONPerinatal2017 frm2 where frm2.formCreated = frm.formCreated and frm2.demographicNo = frm.demographicNo)";
        Query query = entityManager.createQuery(sql);
        query = query.setParameter("demographicNo", demographicNo);
        return query.getResultList();
    }

    public FormONPerinatal2017 findField(Integer formId, String fieldName) {
        String sql = "select f from FormONPerinatal2017 f " +
                "where f.formId = :formId and f.field = :fieldName and f.active = true";
        Query query = entityManager.createQuery(sql);
        query = query.setParameter("formId", formId);
        query = query.setParameter("fieldName", fieldName);

        FormONPerinatal2017 record = null;
        Object result = query.getSingleResult();
        
        if (result != null) {
            record = (FormONPerinatal2017) result;
        }
        
        return record;
    }

    public FormONPerinatal2017 findFieldForPage(Integer formId, Integer pageNo, String fieldName) {
        String sql = "SELECT f FROM FormONPerinatal2017 f " +
                "WHERE f.formId = :formId AND f.pageNo = :pageNo AND f.field = :fieldName AND f.active = TRUE";
        Query query = entityManager.createQuery(sql);
        query = query.setParameter("formId", formId);
        query = query.setParameter("pageNo", pageNo);
        query = query.setParameter("fieldName", fieldName);

        FormONPerinatal2017 record = null;

        List<FormONPerinatal2017> results = query.getResultList();
        if (!results.isEmpty()) {
            record = results.get(0);
        }

        return record;
    }
    
    public List<FormONPerinatal2017> findRecords(Integer formId) {
        String sql = "select f from FormONPerinatal2017 f " +
                "where f.formId = :formId and f.active = true";
        Query query = entityManager.createQuery(sql);
        query = query.setParameter("formId", formId);
        return query.getResultList();
    }

    public List<FormONPerinatal2017> findRecordsByPage(Integer formId, Integer pageNo) {
        String sql = "select f from FormONPerinatal2017 f " +
                "where f.formId = :formId and f.pageNo = :pageNo and f.active = true";
        Query query = entityManager.createQuery(sql);
        query = query.setParameter("formId", formId);
        query = query.setParameter("pageNo", pageNo);
        return query.getResultList();
    }

    public List<FormONPerinatal2017> findSectionRecords(Integer formId, Integer pageNo, String fieldNamePrefix) {
        String sql = "select f from FormONPerinatal2017 f " +
                "where f.formId = :formId and f.pageNo <> :pageNo and f.field like :fieldName and f.active = true";
        Query query = entityManager.createQuery(sql);
        query = query.setParameter("formId", formId);
        query = query.setParameter("pageNo", pageNo);
        query = query.setParameter("fieldName", fieldNamePrefix + "%");
        return query.getResultList();
    }

    public Boolean hasRecordsForPage(Integer formId, Integer pageNo) {
        Boolean hasRecords = false;
        String sql = "select count(f) from FormONPerinatal2017 f " +
                "where f.formId = :formId and f.pageNo = :pageNo and f.active = true";
        Query query = entityManager.createQuery(sql);
        query = query.setParameter("formId", formId);
        query = query.setParameter("pageNo", pageNo);

        List<Long> result = query.getResultList();

        if(result.size()>0 && result.get(0).intValue() > 0) {
            hasRecords = true;
        }
        
        return hasRecords;
    }

    public Integer getNewFormId() {
        Integer id = 1;
        String sql = "select max(frm.formId) from FormONPerinatal2017 frm ";
        Query query = entityManager.createQuery(sql);
        Object result = query.getSingleResult();
        
       
        if (result instanceof Integer) {
            id = ((Integer) result) + 1;
        }
        return id;
    }

    /**
     * Gets the latest form id by the provided demographic number
     * @param demographicNo The demographic number to get the latest form id for
     * @return The latest form id
     */
    public Integer getLatestFormIdByDemographic(Integer demographicNo) {
        Integer latestFormId = null;
        String sql = "select max(frm.formId) from FormONPerinatal2017 frm WHERE frm.demographicNo = :demographicNo";
        Query query = entityManager.createQuery(sql);
        query.setParameter("demographicNo", demographicNo);
        Object result = query.getSingleResult();
        if (result instanceof Integer) {
            latestFormId = (Integer)result;
        }
        
        return latestFormId;
    }
}
