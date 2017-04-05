import logging, sys, psycopg2, yaml, googleads, os
import xml.etree.ElementTree as ET
from googleads import adwords
reload(sys)  #Resetting the default Python encoding to UTF8
sys.setdefaultencoding('UTF8')

def api_bootstrap():#Setting up the API client by loading credentials and refresh token from the .yaml file located at the specified path

    try:
        adwords_client = adwords.AdWordsClient.LoadFromStorage("googleads.yaml")
        print "Adwords client loaded successfully."

        return adwords_client

    except Exception as inst:
        print("Error during API bootstrap." + '\n' + str(type(inst)) + '\n' + str(inst.args))

def costs_per_city(client, time_range):#Function downloading Geoperformance XML report, parsing it, and returning list of cost data on the time range specified.

    try:

        dataStock = [] #Creating an empty list where we can store and organize data for one day
        costs_data = [] #Creating an empty list where we'll store all lists of data before transferring them to the database

        report_downloader = client.GetReportDownloader(version='v201609')#Specifying the API version used (ALWAYS use this one, I tried with the v201607 but it wasn't working so let's stick to the v201605)

        # Create report definition. See https://developers.google.com/adwords/api/docs/guides/reporting and https://developers.google.com/adwords/api/docs/appendix/reports/campaign-performance-report#campaignname
        report = {
            'reportName': 'HISTORY_CAMPAIGN_PERF_REPORT',
            'dateRangeType': time_range,
            'reportType': 'GEO_PERFORMANCE_REPORT',
            'downloadFormat': 'XML',
            'selector': {
                'fields': ['Date', 'CountryCriteriaId', 'RegionCriteriaId', 'CityCriteriaId', 'AccountDescriptiveName', 'CampaignName', 'AdGroupName', 'Impressions', 'Clicks', 'Conversions', 'Cost']
            }
        }

        #Download the report as a string
        reportFile = report_downloader.DownloadReportAsString(
            report, skip_report_header=True, skip_column_header=True,
            skip_report_summary=True)#Downloads the report as an XML-formatted string

        #Extract desired fields for XML report.
        if reportFile != '':
            root = ET.fromstring(reportFile.encode('utf-8'))
            for child in root:
                for rows in child:
                    rowDict = rows.attrib
                    costs_data.append(
                        [rowDict['day'].encode('utf-8'), rowDict['countryTerritory'].encode('utf-8'), rowDict['region'].encode('utf-8'), rowDict['city'].encode('utf-8'), rowDict['account'].encode('utf-8'), rowDict['campaign'].encode('utf-8'), rowDict['adGroup'].encode('utf-8'),
                        rowDict['impressions'].encode('utf-8'), rowDict['clicks'].encode('utf-8'), rowDict['conversions'].encode('utf-8'), rowDict['cost'].encode('utf-8')]
                    )
        return costs_data

    except Exception as inst:
        print("Error during report download/parsing." + '\n' + str(type(inst)) + '\n' + str(inst.args))

def db_transfer(data_lists, time_range):#Function taking as parameters the data lists from costs_per_city function, as well as the time_range variable, and storing the data in the database while avoiding duplicate inserts.

    try:

        with open('db_connect.yaml','r') as stream:#Loading credentials from a YAML file located in the same directory.
            db_dict = yaml.load(stream)

        connectionVar = None#Resetting connectionVar object to None in case it has been used previously (e.g. if we reuse this function multiple times from and external script)

        connectionVar = psycopg2.connect(database=db_dict['db_name'], user=db_dict['db_user'],#Connect to the Postgres database using credentials provided in the .yaml file.
                                         password=db_dict['db_pw'], host=db_dict['db_host'])
        cur = connectionVar.cursor()#Creating a cursor object enabling us to directly query the database.

        range_dict = {'TODAY' : """date::date = current_date;""",
            'YESTERDAY' : """date::date = (current_date - interval '1 day');""",
            'LAST_7_DAYS' : """date between current_date - interval '7 days' and current_date;""",
            'LAST_14_DAYS' : """date between current_date - interval '14 days' and current_date;""",
            'LAST_30_DAYS' : """date between current_date - interval '30 days' and current_date;""",
            'THIS_MONTH' : """(EXTRACT(MONTH FROM date) = EXTRACT(MONTH FROM current_date) AND EXTRACT(YEAR FROM date) = EXTRACT(YEAR FROM current_date))""",
            'ALL_TIME' : """date < current_date"""
        }#Dictionary used to build a DELETE FROM ... WHERE query which will take care of deleting potentially existing data for the time_range selected, in order to avoid duplicated records in case we're running the programming twice the same day, for example.

        whereClause = range_dict[time_range]

        cur.execute(
          """DELETE FROM external.adwords_city WHERE %s""" % whereClause
        )#Deleting existing data for the given time range.

        for stored_lists in data_lists:
            for ad_data in stored_lists:

                cur.execute(
                """INSERT INTO external.adwords_city (date, country, region, city, account, campaign, ad_group, impressions, clicks, conversions, cost)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s);""",
                tuple(ad_data)
                )

        #Inserting all data rows <=====> to be modified to a BULK INSERT instead of loops.

        print "Database transfer successfull."

    except Exception as inst:#In case of error, rollback all changes and close connectionvar
        if connectionVar:
            connectionVar.rollback()
            connectionVar.close()
            print("Error during database transfer." + '\n' + str(type(inst)) + '\n' + str(inst.args))

    finally:#In all cases, commit changes and close connection.
        if connectionVar:
            connectionVar.commit()
            connectionVar.close()

def get_costs_per_city(time_range):# Function using previously defined functions to extract GEO PERFORMANCE REPORT from Adwords and store it in a PostgreSQL database.

    try:
        assert time_range in ('TODAY', 'YESTERDAY', 'LAST_7_DAYS', 'LAST_14_DAYS', 'LAST_30_DAYS', 'THIS_MONTH', 'ALL_TIME')
        accountIDs = ['845-137-2386', '235-557-8820', '242-984-2536']# Fake account IDs inserted for demonstration purpose ===> Ideally they should be loaded from a secured file.

        client = api_bootstrap()
        data_storage = []

        for IDs in accountIDs:
            client.SetClientCustomerId(IDs)
            data_storage.append(costs_per_city(client, time_range))
        print "Reports successfully downloaded and parsed."
        db_transfer(data_storage, time_range)

    except AssertionError:
        print("""Assertion Error: time_range but be one of the following values: 'TODAY', 'YESTERDAY', 'LAST_7_DAYS', 'LAST_14_DAYS', 'LAST_30_DAYS', 'THIS_MONTH', 'ALL_TIME'""")
    except Exception as inst:
        print("Execution failed." + '\n' + str(type(inst)) + '\n' + str(inst.args))
