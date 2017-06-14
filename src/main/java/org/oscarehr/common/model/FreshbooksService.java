package org.oscarehr.common.model;

import org.apache.http.HttpResponse;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.client.methods.HttpPut;
import org.apache.http.entity.StringEntity;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClientBuilder;
import org.apache.http.protocol.HTTP;
import org.apache.http.util.EntityUtils;
import org.apache.log4j.Logger;
import org.codehaus.jettison.json.JSONArray;
import org.codehaus.jettison.json.JSONException;
import org.codehaus.jettison.json.JSONObject;
import org.oscarehr.PMmodule.dao.ProviderDao;
import org.oscarehr.billing.CA.ON.model.Billing3rdPartyAddress;
import org.oscarehr.common.dao.*;
import org.oscarehr.util.LoggedInInfo;
import org.oscarehr.util.MiscUtils;
import org.oscarehr.util.SpringUtils;

import javax.swing.*;
import java.io.IOException;
import java.math.BigDecimal;
import java.text.ParseException;
import java.text.SimpleDateFormat;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Locale;

public class FreshbooksService {
    private Logger log = MiscUtils.getLogger();

    // This function will take a refresh token as a parameter and return a bearer token.
    public boolean refreshAuthentication(String refreshToken, boolean maxAttemptsReached) {
        FreshbooksAuthorization fa;
        FreshbooksAuthorizationDao fad = SpringUtils.getBean(FreshbooksAuthorizationDao.class);
        fa = fad.find(1);

        String URL = "https://api.freshbooks.com/auth/oauth/token";

        HttpPost mPost = new HttpPost(URL);
        mPost.addHeader(HTTP.CONTENT_TYPE, "application/json");
        mPost.addHeader("Api-Version", "alpha");
        CloseableHttpClient client = HttpClientBuilder.create().build();
        HttpResponse response;

        String output, bearer, refresh, timeout;
        int code;
        JSONObject outputJson;

        net.sf.json.JSONObject json = new net.sf.json.JSONObject();

        json.put("grant_type", "refresh_token");
        json.put("client_secret", fa.getClientSecret());
        json.put("refresh_token", refreshToken);
        json.put("client_id", fa.getClientId());
        json.put("redirect_uri", "https://www.getpostman.com/oauth2/callback");

        try {
            StringEntity params = new StringEntity(json.toString());
            mPost.setEntity(params);
            response = client.execute(mPost);
            code = response.getStatusLine().getStatusCode();

            if (code == 401 && !maxAttemptsReached) {
                fa = fad.find(1);
                log.error("Access token is invalid. Generating a new one..");
                maxAttemptsReached = true;
                refreshAuthentication(fa.getRefreshToken(), maxAttemptsReached);
            } else if (code == 200) {
                output = EntityUtils.toString(response.getEntity());
                outputJson = new JSONObject(output);

                bearer = outputJson.getString("access_token");
                timeout = outputJson.getString("expires_in");
                refresh = outputJson.getString("refresh_token");

                fa.setId(1);
                fa.setBearerToken(bearer);
                fa.setExpiryTime(Integer.parseInt(timeout));
                fa.setRefreshToken(refresh);
                fad.merge(fa);

                log.info("New authorization token successfully generated!");
            }
        } catch (IOException e) {
            e.printStackTrace();
        } catch (JSONException js) {
            js.printStackTrace();
        }

        if (maxAttemptsReached)
        {
            log.info("Maximum authentication attempts reached! Please contact support.");
            return true;
        }
        return false;
    }
    
    public void updateClient(String clientFreshbooksId, String providerFreshbooksId, String email, String firstName, String lastName, String homePhone, String street, String city, String province, String postal, boolean maxAttemptsReached)
    {
        FreshbooksAuthorization fa;
        FreshbooksAuthorizationDao fad = SpringUtils.getBean(FreshbooksAuthorizationDao.class);
        fa = fad.find(1);
        
        String URL = "https://api.freshbooks.com/accounting/account/" + providerFreshbooksId + "/users/clients/" + clientFreshbooksId;

        HttpPut mPut = new HttpPut(URL);
        mPut.addHeader(HTTP.CONTENT_TYPE, "application/json");
        mPut.addHeader("Api-Version", "alpha");
        mPut.addHeader("Authorization", "Bearer " + fa.getBearerToken());
        CloseableHttpClient client = HttpClientBuilder.create().build();
        HttpResponse response;
        net.sf.json.JSONObject json = new net.sf.json.JSONObject();
        net.sf.json.JSONObject json2 = new net.sf.json.JSONObject();
        int code;

        json.put("email", email);
        json.put("fname", firstName);
        json.put("lname", lastName);
        json.put("home_phone", homePhone);
        json.put("p_street", street);
        json.put("p_city", city);
        json.put("p_province", province);
        json.put("p_code", postal);
        json2.put("client", json);

        try 
        {
            StringEntity params = new StringEntity(json2.toString());
            mPut.setEntity(params);
            response = client.execute(mPut);
            code = response.getStatusLine().getStatusCode();

            if (code == 401 && !maxAttemptsReached)
            {
                log.error("Access token is invalid. Generating a new one..");
                maxAttemptsReached = refreshAuthentication(fa.getRefreshToken(), maxAttemptsReached);
                updateClient(clientFreshbooksId, providerFreshbooksId, email, firstName, lastName, homePhone, street, city, province, postal, maxAttemptsReached);
            } else if (code == 200) 
            {
                log.info("Freshbooks Client email successfully updated to Demographic E-mail.");
            }
        }
        catch (IOException e)
        {
            e.printStackTrace();
        }
    }

    public void addServiceCodeItem (String accountId, String serviceCode, String description, String value, String serviceDate, boolean maxAttemptsReached)
    {
        FreshbooksAuthorization fa;
        FreshbooksAuthorizationDao fad = SpringUtils.getBean(FreshbooksAuthorizationDao.class);
        fa = fad.find(1);

        String URL = "https://api.freshbooks.com/accounting/account/" + accountId + "/items/items";

        HttpPost mPost = new HttpPost(URL);
        mPost.addHeader(HTTP.CONTENT_TYPE, "application/json");
        mPost.addHeader("Authorization", "Bearer " + fa.getBearerToken());
        mPost.addHeader("Api-Version", "alpha");

        CloseableHttpClient client = HttpClientBuilder.create().build();
        HttpResponse response;
        int code;
        float taxAmount = 0.00F;
        net.sf.json.JSONObject json = new net.sf.json.JSONObject();
        net.sf.json.JSONObject json2 = new net.sf.json.JSONObject();
        net.sf.json.JSONObject json3 = new net.sf.json.JSONObject();

        json.put("amount", value);
        json.put("code", "CAD");
        json2.put("updated", serviceDate);
        json2.put("name", serviceCode.substring(1));
        json2.put("unit_cost", json);
        json2.put("description", description);
        json3.put("item", json2);

        try
        {
            StringEntity params = new StringEntity(json3.toString());
            mPost.setEntity(params);
            response = client.execute(mPost);
            code = response.getStatusLine().getStatusCode();
            if (code == 401 && !maxAttemptsReached)
            {
                log.error("Access token is invalid. Generating a new one..");
                maxAttemptsReached = refreshAuthentication(fa.getRefreshToken(), maxAttemptsReached);
                addServiceCodeItem(accountId, serviceCode, description, value, serviceDate, maxAttemptsReached);
            }
            else if (code == 200)
            {
                log.info("Successfully added Service code: " + serviceCode + " to Freshbooks!");
            }

            client.close();
        }
        catch (IOException e)
        {
            e.printStackTrace();
        }
        //catch (JSONException j) {j.printStackTrace();}
    }
    
    public void dailyInvoiceUpdate(String accountId, LoggedInInfo loggedInInfo, int page, String clientFreshbooksId, boolean maxAttemptsReached)
    {
        // This function will call the list of invoices, sort them descending by their update date, and only merge/persist
        // the ones that have been updated today (all other days, if missed, will be processed overnight)
        FreshbooksAuthorization fa;
        FreshbooksAuthorizationDao fad = SpringUtils.getBean(FreshbooksAuthorizationDao.class);
        fa = fad.find(1);

            String URL = "https://api.freshbooks.com/accounting/account/" + accountId + "/invoices/invoices?per_page=10&page=" + page + "&search%5Bcustomerid%5D=" + clientFreshbooksId;

            HttpGet mGet = new HttpGet(URL);
            mGet.addHeader(HTTP.CONTENT_TYPE, "application/json");
            mGet.addHeader("Authorization", "Bearer " + fa.getBearerToken());
            mGet.addHeader("Api-Version", "alpha");
            CloseableHttpClient client = HttpClientBuilder.create().build();
            HttpResponse response;
            
            String output;
            int code;
            
            JSONArray invoicesarray;
            JSONObject responsekey, resultkey, outputJson, invoiceobject;
            
            SimpleDateFormat sdfDate = new SimpleDateFormat("yyyy-MM-dd", Locale.ENGLISH);
            SimpleDateFormat sdfDateTime = new SimpleDateFormat("yyyy-MM-dd hh:mm:ss", Locale.ENGLISH);
            SimpleDateFormat sdfTime = new SimpleDateFormat("hh:mm:ss");

            try
            {
                response = client.execute(mGet);
                code = response.getStatusLine().getStatusCode();

                if (code == 401 && !maxAttemptsReached)
                {
                    log.error("Access token is invalid. Generating a new one..");
                    maxAttemptsReached = refreshAuthentication(fa.getRefreshToken(), maxAttemptsReached);
                    dailyInvoiceUpdate(accountId, loggedInInfo, page, clientFreshbooksId, maxAttemptsReached);
                }
                else if (code == 200)
                {
                    output = EntityUtils.toString(response.getEntity());
                    outputJson = new JSONObject(output);
                    
                    BillingONCHeader1Dao dao = SpringUtils.getBean(BillingONCHeader1Dao.class);
                    DemographicExtDao ded = SpringUtils.getBean(DemographicExtDao.class);
                    DemographicDao dd = SpringUtils.getBean(DemographicDao.class);
                    Demographic d = null;

                    UserPropertyDAO userPropertyDAO = (UserPropertyDAO) SpringUtils.getBean("UserPropertyDAO");

                    ProviderDao pd = SpringUtils.getBean(ProviderDao.class);
                    Provider p = new Provider();

                    responsekey = outputJson.getJSONObject("response");
                    resultkey = responsekey.getJSONObject("result");
                    invoicesarray = resultkey.getJSONArray("invoices");

                    int arrayCounter = invoicesarray.length();

                    for (int i = 0; i < arrayCounter; i++)
                    {
                        invoiceobject = invoicesarray.getJSONObject(i);
                        String archivedStatus = invoiceobject.getString("vis_state");
                        String companyKey = invoiceobject.getString("organization");
                        String invoiceDemoNo, invoiceMemoKey;
                        String payee = "P";
                        
                        DemographicExt de = null;
                        Clinic clinic = new Clinic();

                            if (companyKey != null && !companyKey.equals("") && companyKey.equals("INSURANCE"))
                            {
                                int demoNoIndex, demoNoEndingIndex;
                                invoiceMemoKey = invoiceobject.getString("notes");
                                demoNoIndex = invoiceMemoKey.indexOf("(") + 1;
                                demoNoEndingIndex = invoiceMemoKey.indexOf(")");
                                if (demoNoIndex != -1 && demoNoEndingIndex != -1)
                                {
                                    invoiceDemoNo = invoiceMemoKey.substring(demoNoIndex, demoNoEndingIndex);
                                    de = ded.getDemographicExt(Integer.parseInt(invoiceDemoNo), "insurance_number");
                                }
                                payee = "A";
                            } else {
                                if (ded.getDemographicExtByKeyAndValue("freshbooksId", invoiceobject.getString("customerid")).size() > 0) {
                                    de = ded.getDemographicExtByKeyAndValue("freshbooksId", invoiceobject.getString("customerid")).get(0);
                                } else {
                                    de = null;
                                }

                            }

                            if (de != null) {
                                d = dd.getDemographic(de.getDemographicNo().toString());
                            }

                            List<UserProperty> uProp = userPropertyDAO.getPropValues(UserProperty.PROVIDER_FRESHBOOKS_ID, invoiceobject.getString("accountid"));

                            if (uProp != null && uProp.size()>0) {
                                p = pd.getProvider(uProp.get(0).getProviderNo()==null?"":uProp.get(0).getProviderNo());
                            }

                            BillingONCHeader1Dao billingDao = SpringUtils.getBean(BillingONCHeader1Dao.class);
                            List<BillingONCHeader1> existingInvoice;
                            String freshbooksInvoiceId = invoiceobject.getString("id");

                            existingInvoice = billingDao.findByFreshbooksId(freshbooksInvoiceId);
                            String existingId = "";
                            if (existingInvoice != null && existingInvoice.size() > 0) {
                                existingId = existingInvoice.get(0).getFreshbooksId() == null ? "" : existingInvoice.get(0).getFreshbooksId();
                            }
                            int existingIdInt;

                            if (existingId.equals("")) {
                                existingIdInt = -1;
                            } else {
                                existingIdInt = Integer.parseInt(existingId);
                            }

                            // Newly created invoice
                            if (existingIdInt != Integer.parseInt(freshbooksInvoiceId)) {
                                FreshbooksAppointmentInfoDao faid = SpringUtils.getBean(FreshbooksAppointmentInfoDao.class);
                                FreshbooksAppointmentInfo fai = null;

                                if (de != null) {
                                    fai = faid.getByInvoiceAndBusinessId(freshbooksInvoiceId, invoiceobject.getString("accountid"));
                                }

                                String apptProvider = "";
                                int apptNo = -1;

                                if (fai != null) {
                                    apptProvider = fai.getAppointmentProvider();
                                    apptNo = fai.getAppointmentNo();
                                }

                                String freshbooksComment = invoiceobject.getString("notes");
                                String freshbooksBillingDate = invoiceobject.getString("created_at").substring(0, 10);
                                String freshbooksBillingTime = invoiceobject.getString("created_at").substring(11, 19);
                                String payProgram = "K3P";
                                JSONObject freshbooksTotalObj = invoiceobject.getJSONObject("amount");
                                JSONObject freshbooksPaidObj = invoiceobject.getJSONObject("paid");
                                double freshbooksTotal = Double.parseDouble(freshbooksTotalObj.getString("amount"));
                                double freshbooksPaid = Double.parseDouble(freshbooksPaidObj.getString("amount"));
                                String billStatus = invoiceobject.getString("status");

                                if (billStatus != null && billStatus.equals("4")) {
                                    billStatus = "S";
                                }
                                else
                                {
                                    billStatus = "P";
                                }

                                String loggedInProvNo = loggedInInfo.getLoggedInProviderNo();
                                String providerNo = p.getProviderNo();
                                String provOhipNo = p.getOhipNo() == null ? "" : p.getOhipNo();
                                String provRmaNo = p.getRmaNo() == null ? "" : p.getRmaNo();


                                // Silly looking, but in case client creates invoice for insurance company with no associated demographic info in the memo - prevents NPE
                                String hin = "";
                                String demoNo = "";
                                String dob = "";
                                String sex = "";
                                String demoName = "";
                                String version = "";
                                String province = "";
                                String refDocNum = "";
                                String clinicName = "";
                                String clinicCode = "";

                                if (d != null)
                                {
                                    hin = d.getHin() == null ? "" : d.getHin();
                                    demoNo = d.getDemographicNo().toString();
                                    dob = d.getFormattedDob() == null ? "" : d.getFormattedDob().replaceAll("-", "");
                                    sex = d.getSex() == null ? "" : d.getSex();
                                    demoName = d.getFirstName() == null || d.getLastName() == null ? "" :
                                            d.getFirstName().substring(0, 1).toUpperCase() + d.getFirstName().substring(1).toLowerCase() + "," +
                                                    d.getLastName().substring(0, 1).toUpperCase() + d.getLastName().substring(1).toLowerCase();
                                    version = d.getVer() == null ? "" : d.getVer();
                                    province = d.getProvince() == null ? "" : d.getProvince();
                                    refDocNum = d.getFamilyDoctorNumber() == null ? "" : d.getFamilyDoctorNumber();
                                    clinicName = clinic.getClinicName() == null ? "" : clinic.getClinicName();
                                    clinicCode = clinic.getClinicLocationCode() == null ? "" : clinic.getClinicLocationCode();
                                }

                                if (archivedStatus.equalsIgnoreCase("1"))
                                {
                                    billStatus = "D";
                                }

                                BillingONCHeader1 oscarinvoice = new BillingONCHeader1();
                                oscarinvoice.setFreshbooksId(freshbooksInvoiceId);
                                oscarinvoice.setHeaderId(0); // OHIP field, unneeded 
                                oscarinvoice.setTranscId("HE"); // OHIP field, unneeded 
                                oscarinvoice.setRecId("H"); // OHIP field, unneeded 
                                oscarinvoice.setHin(hin);
                                oscarinvoice.setVer(version);
                                oscarinvoice.setDob(dob);
                                oscarinvoice.setPayProgram(payProgram);
                                oscarinvoice.setPayee(payee);
                                oscarinvoice.setRefNum(refDocNum);
                                oscarinvoice.setFaciltyNum(""); // OHIP field, unneeded 
                                oscarinvoice.setAdmissionDate(null); // OHIP field, unneeded 
                                oscarinvoice.setRefLabNum(""); // OHIP field, unneeded 
                                oscarinvoice.setLocation(clinicCode);
                                oscarinvoice.setManReview(""); // OHIP field, unneeded 
                                oscarinvoice.setDemographicNo(Integer.parseInt(demoNo));
                                oscarinvoice.setProviderNo(providerNo);
                                oscarinvoice.setAppointmentNo(apptNo);
                                oscarinvoice.setDemographicName(demoName);
                                oscarinvoice.setSex(sex);
                                oscarinvoice.setProvince(province);
                                try {
                                    oscarinvoice.setBillingDate(sdfDate.parse(freshbooksBillingDate));
                                    oscarinvoice.setBillingTime(sdfTime.parse(freshbooksBillingTime));
                                } catch (ParseException parseexception) {
                                    parseexception.printStackTrace();
                                }
                                oscarinvoice.setTotal(BigDecimal.valueOf(freshbooksTotal));
                                oscarinvoice.setPaid(BigDecimal.valueOf(freshbooksPaid));
                                oscarinvoice.setStatus(billStatus);
                                oscarinvoice.setComment(freshbooksComment);
                                oscarinvoice.setVisitType("00"); // OHIP field, unneeded
                                oscarinvoice.setProviderOhipNo(provOhipNo);
                                oscarinvoice.setProviderRmaNo(provRmaNo);
                                oscarinvoice.setApptProviderNo(apptProvider);
                                oscarinvoice.setAsstProviderNo(""); // OHIP field, Unneeded 
                                oscarinvoice.setCreator(loggedInProvNo);
                                oscarinvoice.setClinic(clinicName);
                                dao.persist(oscarinvoice);
                                
                                BillingONPaymentDao bopDao = SpringUtils.getBean(BillingONPaymentDao.class);
                                BillingONPayment bop = new BillingONPayment();
                                BillingPaymentTypeDao billingPaymentTypeDao = SpringUtils.getBean(BillingPaymentTypeDao.class);
                                // This will create the 'Freshbooks' payment type in the clients billing_payment_type table if it does not already exist, for future usage
                                // If bpt is null, we know to write the new entry.
                                BillingPaymentType bpt = billingPaymentTypeDao.getPaymentTypeByName("FRESHBOOKS");
                                if (bpt == null)
                                {
                                    bpt = new BillingPaymentType();
                                    bpt.setPaymentType("FRESHBOOKS");
                                    billingPaymentTypeDao.persist(bpt);
                                }
                                
                                List<BillingONCHeader1> createdInvoice = dao.findByFreshbooksId(freshbooksInvoiceId);
                                String paymentDate = freshbooksBillingDate + " " + freshbooksBillingTime;
                                
                                bop.setFreshbooksId(freshbooksInvoiceId);
                                bop.setBillingNo(createdInvoice.get(0).getId());
                                try 
                                {
                                    bop.setPaymentDate(sdfDateTime.parse(paymentDate));
                                }
                                catch (ParseException parseexception) 
                                {
                                    parseexception.printStackTrace();
                                }
                                bpt = billingPaymentTypeDao.getPaymentTypeByName("FRESHBOOKS");
                                bop.setPaymentTypeId(bpt.getId());
                                bop.setCreator(loggedInProvNo);

                                String freshbooksDiscountObj = invoiceobject.getString("discount_value");
                                double freshbooksDiscount = Double.parseDouble(freshbooksDiscountObj);
                                
                                bop.setTotal_payment(BigDecimal.valueOf(freshbooksPaid));
                                bop.setTotal_discount(BigDecimal.valueOf(freshbooksDiscount));
                                bop.setTotal_refund(BigDecimal.valueOf(0.00));
                                bop.setTotal_credit(BigDecimal.valueOf(0.00));
                                
                                bopDao.persist(bop);

                                DemographicDao dDao = SpringUtils.getBean(DemographicDao.class);
                                Demographic demo = dDao.getDemographic(createdInvoice.get(0).getDemographicNo().toString());
                                Provider prov = pd.getProvider(providerNo);
                                BillingONExtDao billingONExtDao = SpringUtils.getBean(BillingONExtDao.class);
                                String billTo = demo.getFullName() + "\n" + demo.getAddress() + "\n" + demo.getCity() + ", " + demo.getProvince() + "\n" + demo.getPostal() + "\nTel: " + demo.getPhone();
                                String remitTo = "";
                                if (companyKey != null && !companyKey.equals("") && companyKey.equals("INSURANCE"))
                                {
                                    remitTo = (String)invoiceobject.get("fname");
                                }

                                String[] billExtKeyVals = {"billTo", "remitTo", "total", "payment", "discount", "provider_no", "gst", "payDate", "payMethod", "payee"};
                                String[] billExtValues = {billTo, remitTo, freshbooksTotalObj.getString("amount"), freshbooksPaidObj.getString("amount"), invoiceobject.getString("discount_value"), providerNo, "0", new Date().toString(), "", prov.getFullName()};

                                for (int it = 0; it < 10; it++)
                                {
                                    BillingONExt billExt = new BillingONExt();
                                    billExt.setBillingNo(createdInvoice.get(0).getId());
                                    billExt.setDemographicNo(createdInvoice.get(0).getDemographicNo());
                                    billExt.setKeyVal(billExtKeyVals[it]);
                                    billExt.setValue(billExtValues[it]);
                                    billExt.setDateTime(new Date());
                                    billExt.setStatus('1');
                                    billingONExtDao.persist(billExt);
                                }
                            } 
                            else // Existing invoice, check for modifications and update if applicable
                            {
                                String freshbooksComment = invoiceobject.getString("notes");
                                JSONObject freshbooksTotalObj = invoiceobject.getJSONObject("amount");
                                JSONObject freshbooksPaidObj = invoiceobject.getJSONObject("paid");
                                double freshbooksTotal = Double.parseDouble(freshbooksTotalObj.getString("amount"));
                                double freshbooksPaid = Double.parseDouble(freshbooksPaidObj.getString("amount"));
                                String billStatus = invoiceobject.getString("status");

                                if (billStatus != null && billStatus.equals("4")) {
                                    billStatus = "S";
                                } else {
                                    billStatus = "P";
                                }

                                if (archivedStatus.equalsIgnoreCase("1"))
                                {
                                    billStatus = "D";
                                }

                                String demoNo = d.getDemographicNo().toString();
                                String demoName = d.getFirstName() == null || d.getLastName() == null ? "" :
                                        d.getFirstName().substring(0, 1).toUpperCase() + d.getFirstName().substring(1).toLowerCase() + "," +
                                        d.getLastName().substring(0, 1).toUpperCase() + d.getLastName().substring(1).toLowerCase();

                                BillingONCHeader1Dao invoiceDao = SpringUtils.getBean(BillingONCHeader1Dao.class);
                                BillingONPaymentDao billingONPaymentDao = SpringUtils.getBean(BillingONPaymentDao.class);
                                BillingONExtDao billingONExtDao = SpringUtils.getBean(BillingONExtDao.class);
                                List<BillingONCHeader1> oscarinvoice = invoiceDao.findByFreshbooksId(existingId);
                                List<BillingONPayment> paymentInvoice = billingONPaymentDao.findByFreshbooksId(existingId);
                                List<BillingONExt> extInvoice = new ArrayList<>();
                                
                                if (oscarinvoice.size()>0)
                                {
                                    extInvoice = billingONExtDao.getBillingExtItems(oscarinvoice.get(0).getId().toString());

                                    oscarinvoice.get(0).setComment(freshbooksComment);
                                    oscarinvoice.get(0).setTotal(BigDecimal.valueOf(freshbooksTotal));
                                    oscarinvoice.get(0).setPaid(BigDecimal.valueOf(freshbooksPaid));
                                    oscarinvoice.get(0).setStatus(billStatus);
                                    oscarinvoice.get(0).setDemographicName(demoName);
                                    oscarinvoice.get(0).setDemographicNo(Integer.parseInt(demoNo));
                                    dao.merge(oscarinvoice.get(0));
                                }
                                
                                if (paymentInvoice.size()>0)
                                {
                                    String freshbooksDiscountObj = invoiceobject.getString("discount_value");
                                    double freshbooksDiscount = Double.parseDouble(freshbooksDiscountObj);

                                    paymentInvoice.get(0).setTotal_payment(BigDecimal.valueOf(freshbooksPaid));
                                    paymentInvoice.get(0).setTotal_discount(BigDecimal.valueOf(freshbooksDiscount));
                                    billingONPaymentDao.merge(paymentInvoice.get(0));
                                }

                                if (extInvoice.size() > 0)
                                {
                                    extInvoice.get(3).setValue(freshbooksPaidObj.getString("amount"));
                                    billingONExtDao.merge(extInvoice.get(3));

                                    extInvoice.get(7).setValue(new Date().toString());
                                    billingONExtDao.merge(extInvoice.get(7));
                                }
                            }
                    }
                }

                client.close();
            }
            catch (IOException e)
            {
                e.printStackTrace();
            }
            catch (JSONException js) {js.printStackTrace();}
    }

    public String createInsuranceInvoice(String provFreshbooksId, Demographic demo, String clientFreshbooksId, String serviceDate, boolean maxAttemptsReached)
    {
        FreshbooksAuthorization fa;
        FreshbooksAuthorizationDao fad = SpringUtils.getBean(FreshbooksAuthorizationDao.class);
        fa = fad.find(1);
        
        String URL = "https://api.freshbooks.com/accounting/account/" + provFreshbooksId + "/invoices/invoices";

        HttpPost mPost = new HttpPost(URL);
        mPost.addHeader(HTTP.CONTENT_TYPE, "application/json");
        mPost.addHeader("Authorization", "Bearer " + fa.getBearerToken());
        mPost.addHeader("Api-Version", "alpha");

        CloseableHttpClient client = HttpClientBuilder.create().build();
        JSONObject outputJson;
        HttpResponse response;
        int code;
        String output;
        String idkey = "";
        JSONObject responsekey, resultkey, invoiceskey;
        net.sf.json.JSONObject json = new net.sf.json.JSONObject();
        net.sf.json.JSONObject json2 = new net.sf.json.JSONObject();
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
        Date today = new java.util.Date();
        String create_date = sdf.format(today);
        String demographicNote = "";
        String demoEmail = "";
        if (demo!=null) 
        {
            DemographicExtDao ded = SpringUtils.getBean(DemographicExtDao.class);
            String insuranceNo = ded.getValueForDemoKey(demo.getDemographicNo(), "insurance_number");
            
            demographicNote = "Patient: " + (demo.getFormattedName()==null?"":demo.getFormattedName()) + " (" + demo.getDemographicNo() + ")" + "\nInsurance No: " + insuranceNo
                    + "\nAge: " + (demo.getAge()==null?"":demo.getAge()) + "\nDOB: " + (demo.getFormattedDob()==null?"":demo.getFormattedDob()) + "\nSex: " + (demo.getSex()==null?"":demo.getSex());
                    
             demoEmail = demo.getEmail()==null?"":demo.getEmail();
        }

        if (serviceDate==null || serviceDate.isEmpty())
        {
            serviceDate = create_date;
        }
        else
        {
            try
            {
                Date date = sdf.parse(serviceDate);
                serviceDate = sdf.format(date);
            }
            catch (ParseException pe) { pe.printStackTrace();}
        }
        
        json.put("email", demoEmail);
        json.put("customerid", clientFreshbooksId);
        json.put("create_date", serviceDate);
        json.put("notes", demographicNote);
        json2.put("invoice", json);

        try
        {
            StringEntity params = new StringEntity(json2.toString());
             mPost.setEntity(params);
            response = client.execute(mPost);
            code = response.getStatusLine().getStatusCode();
            if (code == 401 && !maxAttemptsReached)
            {
                log.error("Access token is invalid. Generating a new one..");
                maxAttemptsReached = refreshAuthentication(fa.getRefreshToken(), maxAttemptsReached);
                createInsuranceInvoice(provFreshbooksId, demo, clientFreshbooksId, serviceDate, maxAttemptsReached);
            }
            else if (code == 200)
            {
                output = EntityUtils.toString(response.getEntity());
                outputJson = new JSONObject(output);

                responsekey = outputJson.getJSONObject("response");
                resultkey = responsekey.getJSONObject("result");
                invoiceskey = resultkey.getJSONObject("invoice");
                idkey = invoiceskey.getString("invoiceid");
            }

            client.close();
        }
        catch (IOException e)
        {
            e.printStackTrace();
        }
        catch (JSONException j) {j.printStackTrace();}


        return idkey;
    }
    
    public String createInvoice(String provFreshbooksId, String clientFreshbooksId, String serviceDate, boolean maxAttemptsReached)
    {
        // When trying to generate an invoice in Freshbooks with an existing client ID in OSCAR that was deleted on the Freshbooks end,
        // the API call will return 410 GONE. Client ID will have to be removed from OSCAR database and re-generated in Freshbooks.
        FreshbooksAuthorization fa;
        FreshbooksAuthorizationDao fad = SpringUtils.getBean(FreshbooksAuthorizationDao.class);
        fa = fad.find(1);
        
        String URL = "https://api.freshbooks.com/accounting/account/" + provFreshbooksId + "/invoices/invoices";
        
        HttpPost mPost = new HttpPost(URL);
        mPost.addHeader(HTTP.CONTENT_TYPE, "application/json");
        mPost.addHeader("Authorization", "Bearer " + fa.getBearerToken());
        mPost.addHeader("Api-Version", "alpha");

        CloseableHttpClient client = HttpClientBuilder.create().build();
        JSONObject outputJson;
        HttpResponse response;
        int code;
        String output;
        String idkey = "";
        JSONObject responsekey, resultkey, invoiceskey;
        net.sf.json.JSONObject json = new net.sf.json.JSONObject();
        net.sf.json.JSONObject json2 = new net.sf.json.JSONObject();
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
        Date today = new java.util.Date();
        String create_date = sdf.format(today);

        if (serviceDate==null || serviceDate.isEmpty())
        {
            serviceDate = create_date;
        }
        else
        {
            try
            {
                Date date = sdf.parse(serviceDate);
                serviceDate = sdf.format(date);
            }
            catch (ParseException pe) { pe.printStackTrace();}
        }
        
        json.put("customerid", clientFreshbooksId);
        json.put("create_date", serviceDate);
        json2.put("invoice", json);
        
        try
        {
            StringEntity params = new StringEntity(json2.toString());
            mPost.setEntity(params);
            response = client.execute(mPost);
            code = response.getStatusLine().getStatusCode();
            if (code == 401 && !maxAttemptsReached)
            {
                log.error("Access token is invalid. Generating a new one..");
                maxAttemptsReached = refreshAuthentication(fa.getRefreshToken(), maxAttemptsReached);
                idkey = createInvoice(provFreshbooksId, clientFreshbooksId, serviceDate, maxAttemptsReached);
            }
            else if (code == 200)
            {
                output = EntityUtils.toString(response.getEntity());
                outputJson = new JSONObject(output);

                responsekey = outputJson.getJSONObject("response");
                resultkey = responsekey.getJSONObject("result");
                invoiceskey = resultkey.getJSONObject("invoice");
                idkey = invoiceskey.getString("invoiceid");
            }
            
            client.close();
        }
        catch (IOException e)
        {
            e.printStackTrace();
        }
        catch (JSONException j) {j.printStackTrace();}
        
        
        return idkey;
    }
    
    public String createClient(String provNo, String demoNo, Billing3rdPartyAddress company, boolean createDemoNotInsurance, boolean maxAttemptsReached)
    {
        FreshbooksAuthorization fa;
        FreshbooksAuthorizationDao fad = SpringUtils.getBean(FreshbooksAuthorizationDao.class);
        fa = fad.find(1);
        
        DemographicDao dd = SpringUtils.getBean(DemographicDao.class);
        Demographic d = dd.getDemographic(demoNo);
        
        String fname = d.getFirstName();
        String lname = d.getLastName();
        String email = d.getEmail();
        String homePhone = d.getPhone();
        String address = d.getAddress();
        String city = d.getCity();
        String province = d.getProvince();
        String postal = d.getPostal();
        
        String URL = "https://api.freshbooks.com/accounting/account/" + provNo + "/users/clients";

        HttpPost mPost = new HttpPost(URL);
        mPost.addHeader(HTTP.CONTENT_TYPE, "application/json");
        mPost.addHeader("Authorization", "Bearer " + fa.getBearerToken());
        mPost.addHeader("Api-Version", "alpha");

        CloseableHttpClient client = HttpClientBuilder.create().build();
        HttpResponse response = null;
        int code;
        String demoIdKey = "";
        String output;

        JSONObject outputJson;
        JSONObject responsekey, resultkey, clientkey;
        net.sf.json.JSONObject json = new net.sf.json.JSONObject();
        net.sf.json.JSONObject json2 = new net.sf.json.JSONObject();
        
        if (company != null && company.getCompanyName()!=null && !company.getCompanyName().isEmpty() && !createDemoNotInsurance)
        {
            json.put("home_phone", company.getTelephone()==null?"":company.getTelephone());
            json.put("p_province", company.getProvince()==null?"":company.getProvince());
            json.put("p_city", company.getCity()==null?"":company.getCity());
            json.put("p_street", company.getAddress()==null?"":company.getAddress());
            json.put("p_code", company.getPostalCode()==null?"":company.getPostalCode());
            json.put("fname", company.getCompanyName());
            json.put("organization", "INSURANCE");
            json2.put("client", json);
        }
        else
        {
            json.put("lname", lname);
            json.put("home_phone", homePhone);
            json.put("email", email);
            json.put("p_province", province);
            json.put("p_city", city);
            json.put("p_street", address);
            json.put("p_code", postal);
            json.put("fname", fname);
            json2.put("client", json);
        }

        try
        {
            StringEntity params = new StringEntity(json2.toString());
            mPost.setEntity(params);
            response = client.execute(mPost);
            code = response.getStatusLine().getStatusCode();

            if (code == 401 && !maxAttemptsReached)
            {
                log.error("Access token is invalid. Generating a new one..");
                maxAttemptsReached = refreshAuthentication(fa.getRefreshToken(), maxAttemptsReached);
                createClient(provNo, demoNo, company, createDemoNotInsurance, maxAttemptsReached);
            } 
            else if (code == 200)
            {
                output = EntityUtils.toString(response.getEntity());
                outputJson = new JSONObject(output);

                responsekey = outputJson.getJSONObject("response");
                resultkey = responsekey.getJSONObject("result");
                clientkey = resultkey.getJSONObject("client");
                demoIdKey = clientkey.getString("id");
            }

            client.close();
        }
        catch (IOException e)
        {
            e.printStackTrace();
        }
        catch (JSONException j) {j.printStackTrace();}

        return demoIdKey;
    }
}
