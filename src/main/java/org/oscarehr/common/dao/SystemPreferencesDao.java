package org.oscarehr.common.dao;

import org.oscarehr.common.model.RxManage;
import org.oscarehr.common.model.SystemPreferences;
import org.springframework.stereotype.Repository;

import javax.persistence.Query;
import java.util.List;

@Repository
@SuppressWarnings("unchecked")
public class SystemPreferencesDao extends AbstractDao<SystemPreferences>
{
    public SystemPreferencesDao() { super(SystemPreferences.class); }

    public SystemPreferences findPreferenceByName(String name)
    {
        Query query = entityManager.createQuery("FROM SystemPreferences sp WHERE sp.name = :name");
        query.setParameter("name", name);

        List<SystemPreferences> results = query.getResultList();
        if (!results.isEmpty())
        {
            return results.get(0);
        }

        return null;
    }
}
