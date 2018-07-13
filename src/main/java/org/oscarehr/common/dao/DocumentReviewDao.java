package org.oscarehr.common.dao;

import org.oscarehr.common.model.DocumentReview;
import org.springframework.stereotype.Repository;

import javax.persistence.Query;
import java.util.List;

@Repository
public class DocumentReviewDao extends AbstractDao<DocumentReview> {
    public DocumentReviewDao() {
        super(DocumentReview.class);
    }
    
    public List<DocumentReview> findReviewsByDocument(Integer documentNo) {
        String sql = "FROM DocumentReview r WHERE r.documentNo = :documentNo ";
        Query query = entityManager.createQuery(sql);
        query.setParameter("documentNo", documentNo);
        return query.getResultList();
    }
}
