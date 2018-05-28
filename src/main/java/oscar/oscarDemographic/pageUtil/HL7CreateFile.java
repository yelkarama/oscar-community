package oscar.oscarDemographic.pageUtil;

import cds.LaboratoryResultsDocument;
import cdsDt.DateTimeFullOrPartial;
import org.apache.log4j.Logger;
import org.oscarehr.common.dao.DemographicDao;
import org.oscarehr.common.model.Demographic;
import org.oscarehr.util.MiscUtils;
import org.oscarehr.util.SpringUtils;
import oscar.util.StringUtils;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;

public class HL7CreateFile {
    private Demographic demographic;
    String LAB_TYPE = "CML";
    private static final Logger logger = MiscUtils.getLogger();
    private static final SimpleDateFormat inputFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
    private static final SimpleDateFormat fullDateTime = new SimpleDateFormat("yyyyMMddHHmmss");
    private static final SimpleDateFormat fullDate = new SimpleDateFormat("yyyyMMdd");
    

    public HL7CreateFile(String demographicNo){
        DemographicDao demographicDao = SpringUtils.getBean(DemographicDao.class);
        demographic = demographicDao.getDemographic(demographicNo);
    }
    
    public String generateHL7(List<LaboratoryResultsDocument.LaboratoryResults> labs) {
        StringBuilder hl7 = new StringBuilder();
        
        if (labs != null && !labs.isEmpty()) {
            LaboratoryResultsDocument.LaboratoryResults firstLab = labs.get(0);
            String labType = StringUtils.noNull(firstLab.getLaboratoryName());
            if (labType.equalsIgnoreCase("LifeLabs")) {
                LAB_TYPE = "MDS";
            } else if (labType.equalsIgnoreCase("Gamma")) {
                LAB_TYPE = "GDML";
            }
            
            hl7.append(generateMSH(firstLab)).append("\n");

            if (LAB_TYPE.equals("MDS")) {
                hl7.append("ZLB||||||||||||||||").append("\n");
                hl7.append(generateZRG(labs));
                hl7.append(generateZMN(labs));
                hl7.append(generateZMC(labs));
                hl7.append("ZCL||^^^^^^^^^^^^|^^^|||||||||").append("\n");
            }
            
            hl7.append(generatePID(demographic, firstLab)).append("\n");
            
            if (LAB_TYPE.equals("MDS")) {
                hl7.append("PV1||R|^^^^^^^^|||||^^^^^|||||||||^^^^^^^^^^^^||||||||||||||||||||||||1|||").append("\n");
                hl7.append(generateZFR(firstLab)).append("\n");
                hl7.append("ZCT|||||||").append("\n");
            }

            if (LAB_TYPE.equals("CML")) {
                hl7.append(generateORC(firstLab)).append("\n");
            }
            
            hl7.append(generateOBR(firstLab)).append("\n");
            hl7.append(generateOBX(labs));
        }
        
        return hl7.toString();
    }


    private String generateMSH(LaboratoryResultsDocument.LaboratoryResults lab) {
        String requisitionDate = getDateTime(lab.getLabRequisitionDateTime());
        String version = "2.3";
        if (LAB_TYPE.equals("MDS")) {
            version = version + ".0";
        }
        
        return "MSH|^~\\&|" + LAB_TYPE + "|" + LAB_TYPE + "|||" + requisitionDate + "||ORU^R01|" + lab.getAccessionNumber() + "|P|" + version + "||||";
    }
    
    private String generateNTE(LaboratoryResultsDocument.LaboratoryResults lab) {
        StringBuilder nte = new StringBuilder();
        
        if (StringUtils.filled(lab.getNotesFromLab())) {
            if (LAB_TYPE.equals("MDS")) {
                nte.append("NTE||MC|^").append(lab.getLabTestCode()).append("\n");
            } else {
                String[] noteParts = lab.getNotesFromLab().split("\n");

                StringBuilder nteSegment = new StringBuilder();
                for (int n = 0; n < noteParts.length; n++) {
                    int noteNum = (n + 1);
                    nteSegment.append("NTE|" + noteNum+ "|L|" + noteParts[n]).append("\n");
                }

                nte.append(nteSegment.toString());
            }
        }
        
        return nte.toString();
    }
    
    private String generateOBR(LaboratoryResultsDocument.LaboratoryResults lab) {
        String requisitionDate = getDateTime(lab.getLabRequisitionDateTime());
        String collectionDate = getDateTime(lab.getCollectionDateTime());
        String orderObservation = "";
        
        if (!LAB_TYPE.equals("GDML")) {
            orderObservation = "1";
        }
        
        return "OBR|" + orderObservation + "|101||" + lab.getLabTestCode() + "^" + lab.getTestNameReportedByLab() + "^0000^Imported Test Results|R|" + requisitionDate + "|" + collectionDate + "|||||||" + requisitionDate + "||||||||" + collectionDate + "||LAB|F|||";
    }
    
    private String generateOBX(List<LaboratoryResultsDocument.LaboratoryResults> labs) {
        int obxNo = 0;
        StringBuilder obx = new StringBuilder();

        for (LaboratoryResultsDocument.LaboratoryResults lab : labs) {
            if (lab.getResult() != null) {
                String collectionDate = getDateTime(lab.getCollectionDateTime());
                String referenceRange = "";
                String result = StringUtils.noNull(lab.getResult().getValue());
                String resultNormalAbnormalFlag = "";
                String unit = StringUtils.noNull(lab.getResult().getUnitOfMeasure());
                
                if (lab.getResultNormalAbnormalFlag() != null) {
                    if(lab.getResultNormalAbnormalFlag().isSetResultNormalAbnormalFlagAsPlainText()) {
                        resultNormalAbnormalFlag = lab.getResultNormalAbnormalFlag().getResultNormalAbnormalFlagAsPlainText();
                    } else if (lab.getResultNormalAbnormalFlag().isSetResultNormalAbnormalFlagAsEnum()) {
                        resultNormalAbnormalFlag = lab.getResultNormalAbnormalFlag().getResultNormalAbnormalFlagAsEnum().toString();
                    }
                }
                if (lab.getReferenceRange() != null) {
                    if (lab.getReferenceRange().getReferenceRangeText() != null) {
                        referenceRange = lab.getReferenceRange().getReferenceRangeText();
                    } else if (lab.getReferenceRange().getLowLimit() != null && lab.getReferenceRange().getHighLimit() != null){
                        referenceRange = lab.getReferenceRange().getLowLimit() + "-" + lab.getReferenceRange().getHighLimit();
                    }
                }
                
                obxNo += 1;
                String labTest = lab.getLabTestCode() + "^" + lab.getTestNameReportedByLab();
                if (LAB_TYPE.equals("MDS")) {
                    labTest = "-" + lab.getTestNameReportedByLab() + "^" + lab.getTestNameReportedByLab() + "^" + lab.getTestName();
                }
                
                String obxSegment = "OBX|" + obxNo + "|ST|" + labTest+ "|Imported Test Results|" + result+ "|" +unit+ "|" + referenceRange + "|" + resultNormalAbnormalFlag+ "|||" + StringUtils.noNull(lab.getTestResultStatus()) + "|||" + collectionDate;
                obx.append(obxSegment).append("\n");
                obx.append(generateNTE(lab));
            }
        }

        return obx.toString();
    }

    private String generateORC(LaboratoryResultsDocument.LaboratoryResults lab) {
        String collectionDate = getDateTime(lab.getCollectionDateTime());
        String testResultStatus = StringUtils.noNull(lab.getTestResultStatus());
        if (isFinal(testResultStatus)) {
            testResultStatus = "F";
        }
        
        return "ORC|RE|" + lab.getAccessionNumber() + "|||" +testResultStatus+ "||||||||||" + collectionDate;
    }

    private String generatePID(Demographic demographic, LaboratoryResultsDocument.LaboratoryResults lab) {
        String demographicPhone =  StringUtils.noNull(demographic.getPhone());
        String demographicPhone2 = StringUtils.noNull(demographic.getPhone2());
        String healthCard = StringUtils.noNull(demographic.getHin());
        String pid19 = healthCard + " " + StringUtils.noNull(demographic.getVer());
        if (LAB_TYPE.equals("MDS")) {
            pid19 = "X" + healthCard;
        }
        
        return "PID|1|" + StringUtils.noNull(demographic.getHin()) + "|" + lab.getAccessionNumber() + "|" +healthCard + "|" + demographic.getLastName() + "^" + demographic.getFirstName() + "||" + fullDate.format(demographic.getBirthDay().getTime()) + "|" + demographic.getSex() + "|||||" + demographicPhone + "|" + demographicPhone2+ "|||||" + pid19;
    }

    private String generateZFR(LaboratoryResultsDocument.LaboratoryResults lab){
        String testResultStatus = StringUtils.noNull(lab.getTestResultStatus());
        if (isFinal(testResultStatus)) {
            testResultStatus = "1";
        } else {
            testResultStatus = "0";
        }
        
        return "ZFR||1|" + testResultStatus + "|||0|0";
    }

    private String generateZMC(List<LaboratoryResultsDocument.LaboratoryResults> labs){
        StringBuilder zmc = new StringBuilder();
        Integer zmcNo = 0;
        
        for (LaboratoryResultsDocument.LaboratoryResults lab : labs) {
            zmcNo += 1;
            if (StringUtils.filled(lab.getNotesFromLab())) {
                String[] noteParts = lab.getNotesFromLab().split("\n");

                StringBuilder zmcSegment = new StringBuilder();
                for (int n = 0; n < noteParts.length; n++) {
                    int noteNum = (n + 1);
                    zmcSegment.append("ZMC|" + zmcNo + "." + (n + 1) + "|" + lab.getLabTestCode() + "||" + noteParts.length+ "|Y|" + noteParts[n]).append("\n");
                }
                
                zmc.append(zmcSegment.toString());
            }
        }

        return zmc.toString();
    }
    
    private String generateZMN(List<LaboratoryResultsDocument.LaboratoryResults> labs){
        StringBuilder zmn = new StringBuilder();

        for (LaboratoryResultsDocument.LaboratoryResults lab : labs) {
            if (lab.getResult() != null) {
                String referenceRange = "";
                String unit = StringUtils.noNull(lab.getResult().getUnitOfMeasure());
                
                if (lab.getReferenceRange() != null) {
                    if (lab.getReferenceRange().getReferenceRangeText() != null) {
                        referenceRange = lab.getReferenceRange().getReferenceRangeText();
                    } else if (lab.getReferenceRange().getLowLimit() != null && lab.getReferenceRange().getHighLimit() != null){
                        referenceRange = lab.getReferenceRange().getLowLimit() + "-" + lab.getReferenceRange().getHighLimit();
                    }
                }
                
                String zmnSegment = "ZMN||" + lab.getTestNameReportedByLab() + "||" + lab.getTestName() + "|" +unit+ "||" + referenceRange + "|Imported Test Results||" + lab.getLabTestCode();

                zmn.append(zmnSegment).append("\n");
            }
        }

        return zmn.toString();
    }

    private String generateZRG(List<LaboratoryResultsDocument.LaboratoryResults> labs){
        StringBuilder zrg = new StringBuilder();
        int zrgNo = 0;
        
        for (LaboratoryResultsDocument.LaboratoryResults lab : labs) {
            if (lab.getResult() != null) {
                zrgNo += 1;
                String zrgSegment = "ZRG|" + zrgNo + ".1|" + lab.getLabTestCode() + "|||Imported Test Results|1|";
                zrg.append(zrgSegment).append("\n");
            }
        }

        return zrg.toString();
    }
    
    private String getDateTime(DateTimeFullOrPartial dateObj) {
        String dateString = "";
        Date date = new Date();
        try {
            if (dateObj != null) {
                if (dateObj.isSetFullDate()) {
                    date = inputFormat.parse(dateObj.getFullDate().toString() + " 00:00:00");
                } else if (dateObj.isSetFullDateTime()) {
                    date = inputFormat.parse(dateObj.getFullDateTime().toString());
                }
            }
        } catch (Exception e) {
            logger.error(e);
        }
        dateString = fullDateTime.format(date);
        
        return dateString;
    }
    
    private boolean isFinal(String testResultStatus) {
        testResultStatus = StringUtils.noNull(testResultStatus);
        
        return testResultStatus.equalsIgnoreCase("Final") || testResultStatus.isEmpty();
    }
}
