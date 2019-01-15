package oscar.form.util;

public class FormUtil {
    public static String getCheckedHtml(String value) {
        return value.equals("1") ? "checked=\"checked\"" : "";
    }
}
