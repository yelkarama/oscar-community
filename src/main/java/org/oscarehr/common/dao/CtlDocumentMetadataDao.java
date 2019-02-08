package org.oscarehr.common.dao;

import org.oscarehr.common.model.CtlDocumentMetadata;
import org.springframework.stereotype.Repository;

@Repository
public class CtlDocumentMetadataDao extends AbstractDao<CtlDocumentMetadata> {
    public CtlDocumentMetadataDao(){
        super(CtlDocumentMetadata.class);
    }
    
    
}
