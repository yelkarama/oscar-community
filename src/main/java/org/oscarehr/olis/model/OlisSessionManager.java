package org.oscarehr.olis.model;

import org.oscarehr.util.LoggedInInfo;

import java.util.HashMap;
import java.util.Map;

public class OlisSessionManager {

    /**
     * Tracks the olis sessions for each provider, any new queries a provider runs only impacts their own results
     */
    public static Map<String, ProviderOlisSession> providerSessionMap = new HashMap<String, ProviderOlisSession>();

    /**
     * Gets the provided olis session for the given logged in provider
     * @param sessionOwner the LoggedInInfo of the provider session
     * @return The ProviderOlisSession for the given provider
     */
    public static ProviderOlisSession getSession(LoggedInInfo sessionOwner) {
        if (providerSessionMap.keySet().contains(sessionOwner.getLoggedInProviderNo())) {
            // Get the existing session for this provider
            return providerSessionMap.get(sessionOwner.getLoggedInProviderNo());
        } else {
            // Create new session and return
            return newSession(sessionOwner);
        }
    }

    /**
     * Creates a new ProviderOlisSession for the provided sessionOwner and stores it in the providerSessionMap
     * @param sessionOwner The owner of the new olis session
     * @return the new olis session
     */
    private static ProviderOlisSession newSession(LoggedInInfo sessionOwner) {
        if (providerSessionMap.keySet().contains(sessionOwner.getLoggedInProviderNo())) {
            throw new IllegalArgumentException("Provided ProviderNo already exists in the OLIS session");
        }
        ProviderOlisSession newSession = new ProviderOlisSession(sessionOwner);
        providerSessionMap.put(sessionOwner.getLoggedInProviderNo(), newSession);
        return newSession;
    }
}
