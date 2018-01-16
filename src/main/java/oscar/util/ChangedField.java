package oscar.util;

import org.apache.log4j.Logger;
import org.oscarehr.util.MiscUtils;

import java.lang.reflect.AccessibleObject;
import java.lang.reflect.Field;
import java.security.InvalidParameterException;
import java.util.ArrayList;
import java.util.List;

public class ChangedField {
    private static final Logger logger = MiscUtils.getLogger();
    
    private String fieldName;
    private String oldValue;
    private String newValue;

    public ChangedField(String fieldName, String oldValue, String newValue) {
        this.fieldName = fieldName;
        this.oldValue = oldValue;
        this.newValue = newValue;
    }

    public String getFieldName() {
        return fieldName;
    }
    public void setFieldName(String fieldName) {
        this.fieldName = fieldName;
    }

    public String getOldValue() {
        return oldValue;
    }
    public void setOldValue(String oldValue) {
        this.oldValue = oldValue;
    }

    public String getNewValue() {
        return newValue;
    }
    public void setNewValue(String newValue) {
        this.newValue = newValue;
    }

    @Override
    public String toString() {
        return getFieldName() + ": " + getOldValue() + " -> " + getNewValue() + ";";
    }

    /**
     * Compares all NON-INHERITED fields
     * @param oldObject object to compare
     * @param newObject new object to compare
     * @return a List of ChangedFields for the two Objects
     */
    public static List<ChangedField> getChangedFieldsAndValues(Object oldObject, Object newObject) {
        if (oldObject.getClass() != newObject.getClass()) {
            throw new InvalidParameterException();
        }
        //For recursively getting fields from parent class
//        for (Class<?> c = someClass; c != null; c = c.getSuperclass())
//        {
//            Field[] fields = c.getDeclaredFields();
//            for (Field classField : fields)
//            {
//                result.add(classField);
//            }
//        }

        List<ChangedField> changedFields = new ArrayList<ChangedField>();
        Field[] fields = oldObject.getClass().getDeclaredFields();
        
        AccessibleObject.setAccessible(fields, true);
        for (Field field : fields) {
            try {
                Object oldValue = field.get(oldObject);
                Object newValue = field.get(newObject);
                if (oldValue != null && newValue == null) {
                    changedFields.add(new ChangedField(field.getName(), oldValue.toString(), "null"));
                } else if (oldValue == null && newValue != null) {
                    changedFields.add(new ChangedField(field.getName(), "null", newValue.toString()));
                } else if (oldValue != null && newValue != null && 
                        !field.get(oldObject).equals(field.get(newObject))) {
                    changedFields.add(new ChangedField(field.getName(), oldValue.toString(), newValue.toString()));
                }
            } catch (IllegalAccessException e) {
                logger.error("Error creating ChangedField list", e);
                changedFields.add(new ChangedField(field.getName(), "ERROR logging field", e.getClass().getName()));
            }
        }
        return changedFields;
    }
}
