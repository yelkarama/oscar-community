package org.oscarehr.olis.dao;

import org.oscarehr.common.dao.AbstractDao;
import org.oscarehr.olis.model.OlisQueryLog;
import org.springframework.stereotype.Repository;

@Repository
public class OlisQueryLogDao extends AbstractDao<OlisQueryLog> {
    public OlisQueryLogDao() {
        super(OlisQueryLog.class);
    }
    
    
}
