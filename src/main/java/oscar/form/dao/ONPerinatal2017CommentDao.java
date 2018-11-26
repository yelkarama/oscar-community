package oscar.form.dao;

import org.oscarehr.common.dao.AbstractDao;
import org.springframework.stereotype.Repository;
import oscar.form.model.FormONPerinatal2017Comment;

import javax.persistence.Query;
import java.util.List;

@Repository
public class ONPerinatal2017CommentDao extends AbstractDao<FormONPerinatal2017Comment> {
    public ONPerinatal2017CommentDao() {
        super(FormONPerinatal2017Comment.class);
    }

    public List<FormONPerinatal2017Comment> findComments(Integer formId) {
        String sql = "select f from FormONPerinatal2017Comment f " +
                "where f.formId = :formId ";
        Query query = entityManager.createQuery(sql);
        query = query.setParameter("formId", formId);
        return query.getResultList();
    }
}
