/**
 * KAI INNOVATIONS
 */

package org.oscarehr.common.dao;

import java.util.List;

import javax.persistence.Query;

import org.oscarehr.common.model.MessageFolder;
import org.springframework.stereotype.Repository;

@Repository
public class MessageFolderDao extends AbstractDao<MessageFolder> {

    public MessageFolderDao() {
        super(MessageFolder.class);
    }

    public MessageFolder findByProvider(String providerNo, Integer folderId) {
        Query query = entityManager.createQuery("select m from MessageFolder m where m.id = :folderId and m.providerNo = :providerNo and m.deleted = 0 order by m.displayOrder");
        query.setParameter("folderId", folderId);
        query.setParameter("providerNo", providerNo);
        return (MessageFolder)query.getSingleResult();
    }

   public MessageFolder findByDisplayOrder(String providerNo, Integer displayOrder){
       Query query = entityManager.createQuery("select m from MessageFolder m where m.displayOrder = :displayOrder and m.providerNo = :providerNo and m.deleted = 0");
       query.setParameter("displayOrder", displayOrder);
       query.setParameter("providerNo", providerNo);
       return (MessageFolder)query.getSingleResult();
   }

    public List<MessageFolder> findAllFoldersByProvider(String providerNo) {
        Query query = entityManager.createQuery("select m from MessageFolder m where m.providerNo = :providerNo and m.deleted = 0 order by m.displayOrder");
        query.setParameter("providerNo", providerNo);
        return query.getResultList();
    }


    public String getFolderNameById(String providerNo,  Integer folderId) {
        String name = "";

        MessageFolder messageFolder = findByProvider(providerNo, folderId);
        if(messageFolder!=null){
            name = messageFolder.getName();
        }
        return name;
    }


}
