package org.oscarehr.integration.fhircast;

public class UserLogin extends Event{
	
	public UserLogin(String id, String hubTopic) {
		super(id, hubTopic, "OH.userLogin");
	}
	
	
}
