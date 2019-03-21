package org.oscarehr.olis.model;

import org.oscarehr.olis.OLISUtils;

import java.util.Comparator;
import java.util.Date;

public class OlisLabRequestSortable {
    private String name;
    private int obrIndex;
    private Date collectionDateTime;
    private String groupPlacerNo;
    private String sortKey;
    private OLISRequestNomenclature nomenclature;
    private String setId;
    

    public OlisLabRequestSortable() {
    }

    public OlisLabRequestSortable(String name, int obrIndex, Date collectionDateTime, String groupPlacerNo, String sortKey, OLISRequestNomenclature nomenclature, String setId) {
        this.name = name;
        this.obrIndex = obrIndex;
        this.collectionDateTime = collectionDateTime;
        this.groupPlacerNo = groupPlacerNo;
        this.sortKey = sortKey;
        this.nomenclature = nomenclature;
        this.setId = setId;
    }

    public String getName() {
        return name;
    }
    public void setName(String name) {
        this.name = name;
    }

    public int getObrIndex() {
        return obrIndex;
    }
    public void setObrIndex(int obrIndex) {
        this.obrIndex = obrIndex;
    }
    
    public Date getCollectionDateTime() {
        return collectionDateTime;
    }
    public void setCollectionDateTime(Date collectionDateTime) {
        this.collectionDateTime = collectionDateTime;
    }

    public String getGroupPlacerNo() {
        return groupPlacerNo;
    }
    public void setGroupPlacerNo(String groupPlacerNo) {
        this.groupPlacerNo = groupPlacerNo;
    }

    public String getSortKey() {
        return sortKey;
    }
    public void setSortKey(String sortKey) {
        this.sortKey = sortKey;
    }

    public OLISRequestNomenclature getNomenclature() {
        return nomenclature;
    }
    public void setNomenclature(OLISRequestNomenclature nomenclature) {
        this.nomenclature = nomenclature;
    }

    public String getSetId() {
        return setId;
    }
    public void setSetId(String setId) {
        this.setId = setId;
    }

    public static final Comparator<OlisLabRequestSortable> OLIS_REQUEST_COMPARATOR = new Comparator<OlisLabRequestSortable>() {
        @Override
        public int compare(OlisLabRequestSortable o1, OlisLabRequestSortable o2) {
            // Compares the collection dates, using o2 as the basis in order to order it in reverse chronological
            // If They are the same value, continues comparing other elements to determine order
            int compared = o2.getCollectionDateTime().compareTo(o1.getCollectionDateTime());
            if (compared == 0) {
                // Compares placer group numbers, continuing to compare other attributes if they are the same
                compared = OLISUtils.compareStringEmptyIsMore(o1.getGroupPlacerNo(), o2.getGroupPlacerNo());
                if (compared == 0) {
                    // Compares the ZBR11 sort key, continuing to compare other attributes if they are the same
                    compared = OLISUtils.compareStringEmptyIsMore(o1.getSortKey(), o2.getSortKey());
                    if (compared == 0) {
                        compared = OLISUtils.compareStringEmptyIsMore(o1.getNomenclature().getSortKey(), o2.getNomenclature().getSortKey());
                        if (compared == 0) {
                            // Compares the alternate names stored in the nomenclature, continuing to compare other attributes if they are the same
                            compared = OLISUtils.compareStringEmptyIsMore(o1.getNomenclature().getRequestAlternateName1(), o2.getNomenclature().getRequestAlternateName1());
                            if (compared == 0) {
                                // If the two set ids are not equal, compare them further, if they are, compared is 
                                // already set to 0
                                if (!o1.getSetId().equals(o2.getSetId())) {
                                    // If the first set id is empty, then it is considered higher than the second
                                    // If the second set id is empty, it is considered higher than the first 
                                    if (o1.getSetId().isEmpty()) {
                                        compared = 1;
                                    } else if (o2.getSetId().isEmpty()) {
                                        compared = -1;
                                    } else {
                                        // Parses both ids to integers
                                        Integer o1SetId = Integer.parseInt(o1.getSetId());
                                        Integer o2SetId = Integer.parseInt(o2.getSetId());
                                        // Compares the set ids to determine order
                                        compared = o1SetId.compareTo(o2SetId);
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            return compared;
        }
    };
}
