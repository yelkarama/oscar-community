package oscar.oscarRx.data;

import java.util.Comparator;
import java.util.Hashtable;

public class RxSearchResultComparator implements Comparator<Hashtable<String, Object>> {

    @Override
    public int compare(Hashtable<String, Object> d1, Hashtable<String, Object> d2) {

        if (d1.get("resultOrder") == null && d2.get("resultOrder") == null) {
            return 0;
        } else if (d1.get("resultOrder") == null) {
            return -1;
        } else if (d2.get("resultOrder") == null) {
            return 1;
        }
        Integer d1Order = ((Integer) d1.get("resultOrder"));
        Integer d2Order = ((Integer) d2.get("resultOrder"));
        return d1Order.compareTo(d2Order);
    }
}