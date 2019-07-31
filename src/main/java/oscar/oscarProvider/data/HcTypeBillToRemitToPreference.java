package oscar.oscarProvider.data;

public class HcTypeBillToRemitToPreference {
    private String billToText = null;
    private String remitToText = null;

    public HcTypeBillToRemitToPreference(String billToText, String remitToText) {
        this.billToText = billToText;
        this.remitToText = remitToText;
    }

    public String getBillToText() {
        return billToText;
    }

    public String getRemitToText() {
        return remitToText;
    }

    public boolean isBilledToSet() {
        return billToText != null;
    }
    
    public boolean isRemitToSet() {
        return remitToText != null;
    }
}
