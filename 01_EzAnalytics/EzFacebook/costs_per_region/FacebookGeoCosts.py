#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys, yaml, datetime, psycopg2
from facebookads.api import FacebookAdsApi
from facebookads.objects import (
    Insights,
    AdAccount
)
import datetime
from datetime import timedelta

def bootstrap_api():#Function bootstraping the API connection

    try:

        reload(sys)  # Resetting the default Python encoding to UTF8
        sys.setdefaultencoding('UTF8')

        with open('facebookads.yaml', 'r') as stream: #Opens the YAML file containing the API credentials
            cred_dict = yaml.load(stream)# stores the API credentials from the YAML file in a dictionary

        FacebookAdsApi.init(cred_dict['app_id'], cred_dict['app_secret'], cred_dict['access_token'])# Initialize the API connection using the credentials 

    except Exception as inst:
        print(str(type(inst)) + '\n' + str(inst.args))

def get_accounts_list():#Function getting the list of accounts we'll loop on from the YAML file used previously

    try:

        with open('facebookads.yaml', 'r') as stream:
            cred_dict = yaml.load(stream)

        accounts_list = list(cred_dict['accounts'])

        print accounts_list

        return accounts_list

    except Exception as inst:
        print(str(type(inst)) + '\n' + str(inst.args))

def get_all_campaigns(accounts_array, starting_date): #function getting all campaigns for the list of accounts_ids provided from the YAML file

    try:

        #start_date = str(datetime.date(2016, 10, 20))
        all_data = [] #We create an empty list variable ready to store our data 

        for acc_IDs in accounts_array:# for all account IDs provided
            print acc_IDs#print the account ID
            accounts = AdAccount(acc_IDs)#Selecting this ad account from the API using it's account ID and the AdAccount(account_id) class. 
            fields = [
                Insights.Field.account_name,
                Insights.Field.campaign_name,
                Insights.Field.adset_name,
                Insights.Field.ad_name,
                Insights.Field.spend
            ]#Defining the fields requested from the Facebook Insights API

            params = {
                'time_range': {'since': starting_date, 'until': str(datetime.date.today())},
                'level': 'ad',
                'breakdowns': ['region'],
                'time_increment': 1,
            }#Defining the different parameters of the query

            insights = accounts.get_insights(fields=fields, params=params)#Querying the API on the defined fields and parameters

            for data_dict in insights:#For all data dictionaries in the api response (= insights)
                all_data.append([data_dict['date_start'].encode('utf-8'), data_dict['date_stop'].encode('utf-8'),
                                 data_dict['region'].encode('utf-8'), data_dict['account_name'].encode('utf-8'),
                                 data_dict['campaign_name'].encode('utf-8'), data_dict['adset_name'].encode('utf-8'),
                                 data_dict['ad_name'].encode('utf-8'), data_dict['spend']]
                                )#Append to our data list another list containing all the data we need, encoded in utf-8

        return all_data# returns the list created at the beginning, now containing lists of data (one list = one row of data in our DB)

    except Exception as inst:
        print(str(type(inst)) + '\n' + str(inst.args))


def data_transfer(data_list, starting_date):#Function transferring the data collected to the database <===========> Same way as for Adwords and Piwik

   connectionVar = None

   try:
      with open('db_connect.yaml', 'r') as stream:
        db_dict = yaml.load(stream)

      connectionVar = psycopg2.connect(database=db_dict['db_name'], user=db_dict['db_user'], password=db_dict['db_pw'], host=db_dict['db_host'])
      cur = connectionVar.cursor()
      whereClause = str(""" date >= '%s'""") % starting_date

      cur.execute(
          """DELETE FROM external.facebook_campaigns WHERE %s""" % whereClause
      )

      for stored_lists in data_list:

          cur.execute(
          """INSERT INTO external.facebook_campaigns (date, region, ad_account, campaign, ad_set, ad, spend)
              VALUES (%s, %s, %s, %s, %s, %s, %s);""",
              (stored_lists[0], stored_lists[2], stored_lists[3], stored_lists[4], stored_lists[5], stored_lists[6], stored_lists[7]))

   except Exception as inst:

      if connectionVar:
          connectionVar.rollback()
          connectionVar.close()
          print(str(type(inst)) + '\n' + str(inst.args))

   finally:

      if connectionVar:
         connectionVar.commit()
         connectionVar.close()

def get_costs_per_ad(since_date):# Function using all the above-mentioned functions to get costs per ad, ad_group, etc. from the date given in parameters.

    try:
      assert datetime.datetime.strptime(since_date, "%Y-%m-%d").date() < datetime.datetime.now().date()
      start_date = str(datetime.datetime.strptime(since_date, "%Y-%m-%d").date())

      bootstrap_api()
      all_accounts = get_accounts_list()
      all_costs = get_all_campaigns(all_accounts, start_date)
      data_transfer(all_costs, start_date)

    except AssertionError:
        print("""AssertionError: Invalid date. Format must be 'YYYY-MM-DD' and date must be inferior to current date""")

    except Exception as inst:
      print(str(type(inst)) + '\n' + str(inst.args))
