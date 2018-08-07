package org.oscarehr.common.dao;

import org.oscarehr.common.model.SystemPreferences;
import org.springframework.stereotype.Repository;

import javax.persistence.Query;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

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
    
    public List<SystemPreferences> findPreferencesByNames(List<String> names) {
        Query query = entityManager.createQuery("FROM SystemPreferences sp WHERE sp.name IN (:names)");
        query.setParameter("names", names);

        List<SystemPreferences> results = query.getResultList();
        return results;
    }

    /**
     * Gets a map of system preference values
     * 
     * @param keys List of preference keys to search for in the database
     * @return Map of preference keys with their associated boolean value
     */
    public Map<String, Boolean> findByKeysAsMap(List<String> keys) {
        List<SystemPreferences> preferences = findPreferencesByNames(keys);
        Map<String, Boolean> preferenceMap = new HashMap<String, Boolean>();
        
        for (SystemPreferences preference : preferences) {
            preferenceMap.put(preference.getName(), preference.getValueAsBoolean());
        }
        
        return preferenceMap;
    }
}
