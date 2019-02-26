# This script updates the billing_on_ou_report table
# with Outside Use Report data from the ON EDT Inbox and Archive folders
import mysql.connector
import os
import re
import xml.etree.ElementTree  # to parse the OU xml report

from mysql import *
from pyjavaproperties import Properties  # to read java *.properties

# db properties
db_host = ""
db_name = ""
db_username = ""
db_password = ""
db_driver = ""
db_uri = ""

dirs = []  # directories to check for OU reports
oscarPropertiesPath = "/usr/share/tomcat7/oscar.properties"  # path to oscar.properties

# XML parsed values from OU report that will be added to the database
reportId = ""
reportDate = ""
reportPeriodStart = ""
reportPeriodEnd = ""
groupId = ""
groupType = ""
groupName = ""
providerOHIP = ""
providerLast = ""
providerFirst = ""
providerMiddle = ""
hin = ""
patientLast = ""
patientFirst = ""
dob = ""
serviceDate = ""
serviceCode = ""
serviceDescription = ""
serviceAmount = ""


def connect():
    """ Connect to MySQL database """
    conn = None
    try:
        print("Attempting to connect to MySQL...")

        print("host=%s database=%s, user=%s, password=********" % (db_host, db_name, db_username))
        conn = mysql.connector.connect(host=db_host, database=db_name, user=db_username, password=db_password)
    except Exception as e:
        print("ERROR CONNECTING TO DATABASE:\n %s\n\n" % e)
        if conn is not None:
            close_connection()
    finally:
        return conn


def close_connection():
    """ Close connection to MySQL database """
    if conn is not None and conn.is_connected():
        conn.close()


""" Main processing """
gotProps = False
try:
    # try to get properties from oscar.properties
    p = Properties()
    p.load(open(oscarPropertiesPath))
    db_host = p['host']
    db_name = p['db_name'] if '?' not in p['db_name'] else p['db_name'].split('?')[0]
    db_username = p['db_username']
    db_password = p['db_password']
    db_driver = p['db_driver']
    db_uri = p['db_uri']
    dirs.append(p['ONEDT_INBOX'])
    dirs.append(p['ONEDT_ARCHIVE'])

    gotProps = True
except Exception as e:
    print("ERROR:\n %s\n\n" % e)

if gotProps:
    # if properties returned, try to connect to the database
    conn = connect()
    if conn is not None and conn.is_connected():
        # if connection is successful
        cursor = conn.cursor(prepared=True)
        print('Successfully connected\n')

        for path in dirs:
            # iterate through directories
            print("\n%s\n------------" % path)

            for reportFile in os.listdir(path):
                # iterate through files

                if re.match('^L[A-L]OU[\d]{4}.[\d]*$', reportFile):
                    # if an OU report file parse report information
                    print("%s\n------------" % reportFile)
                    report = xml.etree.ElementTree.parse(path + reportFile).getroot()
                    group = report.find("GROUP")
                    reportData = report.find("REPORT-DTL")

                    reportId = reportData.find("REPORT-ID").text
                    reportDate = reportData.find("REPORT-DATE").text
                    reportPeriodStart = reportData.find("REPORT-DATE").text
                    reportPeriodEnd = reportData.find("REPORT-DATE").text

                    groupId = group.find("GROUP-DTL").find("GROUP-ID").text
                    groupType = group.find("GROUP-DTL").find("GROUP-TYPE").text
                    groupName = group.find("GROUP-DTL").find("GROUP-NAME").text

                    # see if report exists in the database already
                    sql = "select * from billing_on_ou_report where report_date = '%s' and report_period_start = '%s' and report_period_end = '%s' and report_file like '%s';" % (reportDate, reportPeriodStart, reportPeriodEnd, str(reportFile.split('.')[0]) + "%")
                    cursor.execute(sql)
                    noResults = (len(cursor.fetchall()) == 0)

                    if noResults:
                        # if not in the database, parse the rest of the XML for remaining values to add to the database
                        values = []
                        insert = "insert into billing_on_ou_report(report_id, report_date, report_period_start, report_period_end, " \
                                "group_id, group_type, group_name, " \
                                "provider_ohip_no, provider_last, provider_first, provider_middle, " \
                                "patient_hin, patient_last, patient_first, patient_dob, " \
                                "service_date, service_code, service_description, service_amount, " \
                                "report_file)\n values (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)"
                        for provider in group.iter("PROVIDER"):
                            providerOHIP = provider.find("PROVIDER-DTL").find("PROVIDER-NUMBER").text
                            providerLast = provider.find("PROVIDER-DTL").find("PROVIDER-LAST-NAME").text
                            providerFirst = provider.find("PROVIDER-DTL").find("PROVIDER-FIRST-NAME").text
                            providerMiddle = provider.find("PROVIDER-DTL").find("PROVIDER-MIDDLE-NAME").text

                            for patient in provider.iter("PATIENT"):
                                hin = patient.find("PATIENT-DTL").find("PATIENT-HEALTH-NUMBER").text
                                patientLast = patient.find("PATIENT-DTL").find("PATIENT-LAST-NAME").text
                                patientFirst = patient.find("PATIENT-DTL").find("PATIENT-FIRST-NAME").text
                                dob = patient.find("PATIENT-DTL").find("PATIENT-BIRTHDATE").text

                                for service in patient.iter("SERVICE-DTL1"):
                                    serviceDate = service.find("SERVICE-DATE").text
                                    serviceCode = service.find("SERVICE-CODE").text
                                    serviceDescription = service.find("SERVICE-DESCRIPTION").text
                                    serviceAmount = service.find("SERVICE-AMT").text

                                    values.append([reportId, reportDate, reportPeriodStart, reportPeriodEnd,
                                                  groupId, groupType, groupName,
                                                  providerOHIP, providerLast, providerFirst, providerMiddle,
                                                  hin, patientLast, patientFirst, dob,
                                                  serviceDate, serviceCode, serviceDescription, serviceAmount,
                                                  reportFile])
                                # end for service in patient.iter("SERVICE-DTL1")
                            # end for patient in provider.iter("PATIENT")
                        # end for provider in group.iter("PROVIDER")
                        try:
                            # commit current file records
                            cursor.executemany(insert, values)
                            conn.commit()
                            print(cursor.rowcount, " records added")
                        except Exception as e:
                            print("Error adding record to database:\n%s\n\n" % e)
                        continue
                    else:
                        print("SKIPPING... OU REPORT ALREADY ADDED\n")
            # end for reportFile in os.listdir(path)
        # end for path in dirs
    close_connection()
    print('\n\n\nClosed connection to MySQL database')
