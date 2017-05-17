/**
 * Copyright (c) 2001-2002. Department of Family Medicine, McMaster University. All Rights Reserved.
 * This software is published under the GPL GNU General Public License.
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 *
 * This software was written for the
 * Department of Family Medicine
 * McMaster University
 * Hamilton
 * Ontario, Canada
 */

package oscar.oscarPrevention.reports;

import org.apache.log4j.Logger;
import org.oscarehr.util.LoggedInInfo;
import org.oscarehr.util.MiscUtils;
import oscar.oscarEncounter.oscarMeasurements.bean.EctMeasurementsDataBean;
import oscar.oscarEncounter.oscarMeasurements.bean.EctMeasurementsDataBeanHandler;
import oscar.oscarPrevention.PreventionData;
import oscar.oscarPrevention.pageUtil.PreventionReportDisplay;
import oscar.util.UtilDateUtilities;

import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.*;

public class ColonoscopyReport implements PreventionReport {
    private static Logger log = MiscUtils.getLogger();
    /** Creates a new instance of ColonoscopyReport */
    public ColonoscopyReport() {
    }

    public Hashtable runReport(LoggedInInfo loggedInInfo, ArrayList list, Date asofDate){
        int inList = 0;
        double done= 0,doneWithGrace = 0;
        ArrayList<PreventionReportDisplay> returnReport = new ArrayList<PreventionReportDisplay>();

        for (int i = 0; i < list.size(); i ++){
            ArrayList<String> fieldList = (ArrayList<String>) list.get(i);
            Integer demo = Integer.valueOf(fieldList.get(0));
            //search   prevention_date prevention_type  deleted   refused
            ArrayList<Map<String,Object>>  prevs = PreventionData.getPreventionData(loggedInInfo, "COLONOSCOPY", demo);
            PreventionData.addRemotePreventions(loggedInInfo, prevs, demo,"COLONOSCOPY",null);
            ArrayList<Map<String,Object>> noFutureItems =  removeFutureItems(prevs, asofDate);
            PreventionReportDisplay prd = new PreventionReportDisplay();
            prd.demographicNo = demo;
            prd.bonusStatus = "N";
            prd.billStatus = "N";
            if(ineligible(prevs)){
                prd.rank = 5;
                prd.lastDate = "------";
                prd.state = "Ineligible";
                prd.numMonths = "------";
                prd.color = "grey";
                inList++;
            }else if (noFutureItems.size() == 0){
                prd.rank = 1;
                prd.lastDate = "------";
                prd.state = "No Info";
                prd.numMonths = "------";
                prd.color = "Magenta";
            }else{
                DateFormat formatter = new SimpleDateFormat("yyyy-MM-dd");
                Map<String,Object> h = noFutureItems.get(noFutureItems.size()-1);

                boolean refused = false;
                boolean dateIsRefused = false;
                if ( h.get("refused") != null && ((String) h.get("refused")).equals("1")){
                    refused = true;
                    dateIsRefused = true;
                }

                String prevDateStr = (String) h.get("prevention_date");
                String nextDateStr = (String) h.get("next_date");

                if (refused && noFutureItems.size() > 1){
                    log.debug("REFUSED AND PREV IS greater than one for demo "+demo);
                    for (int pr = (noFutureItems.size() -2) ; pr > -1; pr--){
                        log.debug("pr #"+pr);
                        Map<String,Object> h2 = noFutureItems.get(pr);
                        log.debug("pr #"+pr+ "  "+((String) h2.get("refused")));
                        if ( h2.get("refused") != null && ((String) h2.get("refused")).equals("0")){
                            prevDateStr = (String) h2.get("prevention_date");
                            dateIsRefused = false;
                            log.debug("REFUSED prevDateStr "+prevDateStr);
                            pr = 0;
                        }
                    }
                }
                Date prevDate = null;
                try{
                    prevDate = formatter.parse(prevDateStr);
                }catch (ParseException pe){
                    pe.printStackTrace();
                }



                Calendar cal = Calendar.getInstance();
                cal.add(Calendar.YEAR, -3);
                Date dueDate = cal.getTime();
                Date cutoffDate = null;
                if (nextDateStr != null) {
                    try {
                        cutoffDate = formatter.parse(nextDateStr);
                    } catch (ParseException e) {
                        e.printStackTrace();
                    }
                } else {
                    cal.add(Calendar.MONTH,-6);
                    cutoffDate = cal.getTime();
                }

                Calendar cal2 = GregorianCalendar.getInstance();
                cal2.add(Calendar.YEAR, -3);

                //cal2.roll(Calendar.YEAR, -1);
                cal2.add(Calendar.MONTH,-6);
                Date cutoffDate2 = cal2.getTime();

                log.debug("cut 1 "+cutoffDate.toString()+ " cut 2 "+cutoffDate2.toString());


                String numMonths = "------";
                if ( prevDate != null){
                    int num = UtilDateUtilities.getNumMonths(prevDate,asofDate);
                    numMonths = ""+num+" months";
                }

                Calendar bonusEl = Calendar.getInstance();
                bonusEl.setTime(asofDate);
                bonusEl.add(Calendar.MONTH,-42);
                Date bonusStartDate = bonusEl.getTime();

                log.debug("\n\n\n prevDate "+prevDate);
                log.debug("bonusEl date "+bonusStartDate+ " "+bonusEl.after(prevDate));
                log.debug("asofDate date"+asofDate+" "+asofDate.after(prevDate));

                if (!dateIsRefused && bonusStartDate.before(prevDate) && asofDate.after(prevDate)){
                    prd.bonusStatus = "Y";
                    prd.billStatus = "Y";
                    done++;
                }
                log.debug("due Date "+dueDate.toString()+" cutoffDate "+cutoffDate.toString()+" prevDate "+prevDate.toString());
                log.debug("due Date  ("+dueDate.toString()+" ) After Prev ("+prevDate.toString() +" ) "+dueDate.after(prevDate));
                log.debug("cutoff Date  ("+cutoffDate.toString()+" ) before Prev ("+prevDate.toString() +" ) "+cutoffDate.before(prevDate));
                if (!refused && dueDate.after(prevDate) && cutoffDate.before(prevDate)){ // overdue
                    prd.rank = 2;
                    prd.lastDate = prevDateStr;
                    prd.state = "due";
                    prd.numMonths = numMonths;
                    prd.color = "yellow"; //FF00FF
                    if (!prd.bonusStatus.equals("Y")){
                        prd.bonusStatus = "Y";
                        doneWithGrace++;
                    }

                } else if (!refused && dueDate.after(prevDate)){ // overdue
                    prd.rank = 2;
                    prd.lastDate = prevDateStr;
                    prd.state = "Overdue";
                    prd.numMonths = numMonths;
                    prd.color = "red"; //FF00FF

                } else if (refused){  // recorded and refused
                    prd.rank = 3;
                    prd.lastDate = prevDateStr;
                    prd.state = "Refused";
                    prd.numMonths = numMonths;
                    prd.color = "orange"; //FF9933
                } else if (dueDate.before(prevDate)  ){  // recorded done
                    prd.rank = 4;
                    prd.lastDate = prevDateStr;
                    prd.state = "Up to date";
                    prd.numMonths = numMonths;
                    prd.color = "green";
                }
            }
            letterProcessing( prd,"COLONOSCOPYF",asofDate);
            returnReport.add(prd);

        }
        String percentStr = "0";
        String percentWithGraceStr = "0";
        double eligible = list.size() - inList;
        log.debug("eligible "+eligible+" done "+done+" doneWithGrace "+doneWithGrace);
        if (eligible != 0){
            double percentage = ( done / eligible ) * 100;
            double percentageWithGrace =  (done+doneWithGrace) / eligible  * 100 ;
            log.debug("in percentage  "+percentage   +" "+( done / eligible));
            percentStr = ""+Math.round(percentage);
            percentWithGraceStr = ""+Math.round(percentageWithGrace);
        }

        Collections.sort(returnReport);

        Hashtable<String,Object> h = new Hashtable<String,Object>();

        h.put("up2date",""+Math.round(done));
        h.put("percent",percentStr);
        h.put("percentWithGrace",percentWithGraceStr);
        h.put("returnReport",returnReport);
        h.put("inEligible", ""+inList);
        h.put("eformSearch","Mam");
        h.put("followUpType","COLONOSCOPYF");
        h.put("BillCode", "Q001A");
        log.debug("set returnReport "+returnReport);
        return h;
    }

    boolean ineligible(Map<String,Object> h){
        boolean ret =false;
        if ( h.get("refused") != null && ((String) h.get("refused")).equals("2")){
            ret = true;
        }
        return ret;
    }

    boolean ineligible(ArrayList<Map<String,Object>> list){
        for (int i =0; i < list.size(); i ++){
            Map<String,Object> h = list.get(i);
            if (ineligible(h)){
                return true;
            }
        }
        return false;
    }

    private ArrayList<Map<String,Object>> removeFutureItems(ArrayList<Map<String,Object>> list,Date asOfDate){
        ArrayList<Map<String,Object>> noFutureItems = new ArrayList<Map<String,Object>>();
        DateFormat formatter = new SimpleDateFormat("yyyy-MM-dd");
        for (int i =0; i < list.size(); i ++){
            Map<String,Object> h = list.get(i);
            String prevDateStr = (String) h.get("prevention_date");
            Date prevDate = null;
            try{
                prevDate = formatter.parse(prevDateStr);
            }catch (ParseException pe){
                pe.printStackTrace();
            }
            if (prevDate != null && prevDate.before(asOfDate)){
                noFutureItems.add(h);
            }
        }
        return noFutureItems;
    }

    String LETTER1 = "L1";
    String LETTER2 = "L2";
    String PHONE1 = "P1";

    private String letterProcessing(PreventionReportDisplay prd,String measurementType,Date asofDate){
        if (prd != null){
            if (prd.state.equals("No Info") || prd.state.equals("due") || prd.state.equals("Overdue")){
                // Get last contact method
                EctMeasurementsDataBeanHandler measurementDataHandler = new EctMeasurementsDataBeanHandler(prd.demographicNo,measurementType);
                log.debug("getting followup data for "+prd.demographicNo);

                Collection followupData = measurementDataHandler.getMeasurementsDataVector();
                //No Contact method

                if ( followupData.size() == 0 ){
                    prd.nextSuggestedProcedure = this.LETTER1;
                    return this.LETTER1;
                }else{
                    Calendar oneyear = Calendar.getInstance();
                    oneyear.setTime(asofDate);
                    oneyear.add(Calendar.YEAR,-1);

                    Calendar onemonth = Calendar.getInstance();
                    onemonth.setTime(asofDate);
                    onemonth.add(Calendar.MONTH,-1);

                    Date observationDate = null;
                    int count = 0;
                    int index = 0;
                    EctMeasurementsDataBean measurementData = null;

                    @SuppressWarnings("unchecked")
                    Iterator<EctMeasurementsDataBean>iterator = followupData.iterator();

                    while(iterator.hasNext()) {
                        measurementData =  iterator.next();
                        observationDate = measurementData.getDateObservedAsDate();

                        if( index == 0 ) {
                            log.debug("fluData " + measurementData.getDataField());
                            log.debug("lastFollowup " + measurementData.getDateObservedAsDate() + " last procedure " + measurementData.getDateObservedAsDate());
                            log.debug("toString: " + measurementData.toString());
                            prd.lastFollowup = observationDate;
                            prd.lastFollupProcedure = measurementData.getDataField();

                            if (measurementData.getDateObservedAsDate().before(oneyear.getTime())) {
                                prd.nextSuggestedProcedure = this.LETTER1;
                                return this.LETTER1;
                            }


                            if (prd.lastFollupProcedure.equals(this.PHONE1)) {
                                prd.nextSuggestedProcedure = "----";
                                return "----";
                            }
                        }


                        log.debug(prd.demographicNo + " obs" + observationDate + String.valueOf(observationDate.before(onemonth.getTime())) + " OneYear " + oneyear.getTime() + " " + String.valueOf(observationDate.after(oneyear.getTime())));
                        if( observationDate.before(onemonth.getTime()) && observationDate.after(oneyear.getTime())) {
                            ++count;
                        }
                        else if( count > 1 && observationDate.after(oneyear.getTime()) ) {
                            ++count;
                        }
                        ++index;
                    }

                    switch (count) {
                        case 0:
                            prd.nextSuggestedProcedure = this.LETTER1;
                            break;
                        case 1:
                            prd.nextSuggestedProcedure = this.LETTER2;
                            break;
                        case 2:
                            prd.nextSuggestedProcedure = this.PHONE1;
                            break;
                        default:
                            prd.nextSuggestedProcedure = "----";
                    }

                    return prd.nextSuggestedProcedure;

                }




            }else if (prd.state.equals("Refused")){
                EctMeasurementsDataBeanHandler measurementDataHandler = new EctMeasurementsDataBeanHandler(prd.demographicNo,measurementType);
                log.debug("getting followup data for "+prd.demographicNo);
                Collection followupData = measurementDataHandler.getMeasurementsDataVector();
                if ( followupData.size() > 0 ){
                    EctMeasurementsDataBean measurementData = (EctMeasurementsDataBean) followupData.iterator().next();
                    prd.lastFollowup = measurementData.getDateObservedAsDate();
                    prd.lastFollupProcedure = measurementData.getDataField();
                }
                prd.nextSuggestedProcedure = "----";
            }else if(prd.state.equals("Ineligible")){
                prd.nextSuggestedProcedure = "----";
            }else if(prd.state.equals("Up to date")){
                EctMeasurementsDataBeanHandler measurementDataHandler = new EctMeasurementsDataBeanHandler(prd.demographicNo,measurementType);
                log.debug("getting followup data for "+prd.demographicNo);
                Collection followupData = measurementDataHandler.getMeasurementsDataVector();

                if ( followupData.size() > 0 ){
                    EctMeasurementsDataBean measurementData = (EctMeasurementsDataBean) followupData.iterator().next();
                    prd.lastFollowup = measurementData.getDateObservedAsDate();
                    prd.lastFollupProcedure = measurementData.getDataField();
                }
                prd.nextSuggestedProcedure = "----";
            }
        }
        return null;
    }

}
