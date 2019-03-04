package org.oscarehr.olis.model;

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
                compared = o1.getGroupPlacerNo().compareTo(o2.getGroupPlacerNo());
                if (compared == 0) {
                    // Compares the ZBR11 sort key, continuing to compare other attributes if they are the same
                    compared = o1.getSortKey().compareTo(o2.getSortKey());
                    if (compared == 0) {
                        compared = o1.getNomenclature().getSortKey().compareTo(o2.getNomenclature().getSortKey());
                        if (compared == 0) {
                            // Compares the alternate names stored in the nomenclature, continuing to compare other attributes if they are the same
                            compared = o1.getNomenclature().getRequestAlternateName1().compareTo(o2.getNomenclature().getRequestAlternateName1());
                            if (compared == 0) {
                                // Compares the set ids to determine order
                                compared = o1.getSetId().compareTo(o2.getSetId());
                            }
                        }
                    }
                }
            }
            
            return compared;
        }
    };
}
