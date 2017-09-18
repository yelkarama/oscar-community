package org.oscarehr.integration.pccds;

public class PCDS_StaticInfo {
	private PCDS_StaticInfo(){
		;
	}
	
	public static final String NOP = "NOP";
	public static final String FULL = "FULL";
	// if integer is receive use incremental
	public static final String EXPORT_LIST = "AppPatients";
	public static final String PSTMT_LOG_ENTRY = "INSERT INTO export_log (time, count, comment) VALUES (?,?,?)";
	

}
