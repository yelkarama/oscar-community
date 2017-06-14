package org.oscarehr.common.dao;

import org.oscarehr.common.model.FreshbooksAuthorization;
import org.springframework.stereotype.Repository;

@Repository
@SuppressWarnings("unchecked")
public class FreshbooksAuthorizationDao extends AbstractDao<FreshbooksAuthorization>
{
    public FreshbooksAuthorizationDao() {
        super(FreshbooksAuthorization.class);
    }
    
}
