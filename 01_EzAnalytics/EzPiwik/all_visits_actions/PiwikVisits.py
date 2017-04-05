#!/usr/bin/python2.7
# -*- coding: utf-8 -*-

import sys, psycopg2, yaml, urllib2, os, json, datetime
from datetime import timedelta

reload(sys)
sys.setdefaultencoding('UTF8')  # Resetting the default Python encoding to UTF8

def unec(element):         #Function returning 1) the element encoded in UTF-8 if type(element) == unicode 2) the element unmodified if type(element) != unicode. Quite useful to deal with encoding.

    try:
        if type(element) == unicode:
            return element.encode('utf-8')
        else:
            return element
    except Exception as inst:
        print("Error while managing encoding." + '\n' + str(type(inst)) + '\n' + str(inst.args) + '\n' + element)

def data_transfer(visits_list, actions_list, date):         # Function returning None but transferring actions and visits' data in the ETL database

    connectionVar = None                                    # We make sure when launching the function that the connectionVar variable is None (convention)

    try:

        range_dict = {'today' : """server_date::date = current_date;""",
            'yesterday' : """server_date::date = (current_date - interval '1 day');"""
        }                                                   # Creates a dictionary which enables us to build the DELETE FROM clause depending on the time range, in order to avoid inserting duplicate data if the script runs twice the same day for example.

        #If case depending on whether we use the keywords "today, yesterday" or directly a date. Better practice would be to first ASSERT that the date value is 'today', 'yesterday' OR a YYYY-MM-DD date.
        if date in ('yesterday', 'today'):                  # If the date is today or yesterday, then the WHERE clause of the DELETE FROM query will be the value associated to this date in the range_dict created 
            whereClause = range_dict[date]
        else:                                               # If not, the where clause is based on the date value (this is why we should normally ASSERT that the value is a YYYY-MM-DD date)
            whereClause = """server_date = %s""" %("'" + date + "'")

        with open('db_connect.yaml', 'r') as stream: # WITH open(YAML file at this path, reading mode):
            db_dict = yaml.load(stream)                     # Create a dictionary out of the different values stored in the yaml file opened

        connectionVar = psycopg2.connect(database=db_dict['db_name'], user=db_dict['db_user'], password=db_dict['db_pw'], host=db_dict['db_host']) #Using the psycopg2 library to connect to the DB (creates a connection variable) using the different DB credentials stored in the dictionary we created. Enables us to avoid displaying credentials directly in the script. 
        cur = connectionVar.cursor()                        # Creates a cursor object from the connection variable. This cursor object contains methods (functions) enabling us to execute queries once the connection variable exists.

        cur.execute(
          """DELETE FROM external.piwik_visits WHERE %s; DELETE FROM external.piwik_actions WHERE %s;""" % (whereClause, whereClause)
        )                                                   # Executing the delete from query for both visits and actions table. The %s sign inside a text variable enables us to call variables at the end of the code line. Safer for SQL injections (NEVER concatenate strings using "+" sign to create an SQL query. Not even at gunpoint.)

        for visits in visits_list:                          # For all visit data lists in the list of visits, execute into external.piwik_visits the query mentioned.
            cur.execute(
            """INSERT INTO external.piwik_visits VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s);""",
            tuple(visits))

        for actions in actions_list:                        # Idem for all action data lists.
            cur.execute(
            """INSERT INTO external.piwik_actions VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s);""",
            tuple(actions))

        print "Database transfer successfull."

    except Exception as inst:                               # IF THERE IS ANY TYPE OF ERROR (<=> EXCEPTION() during the execution of the try:, THEN rollback all changes made on this connection, close the connection and print the error type and the arguments of the error returned.

      if connectionVar:
          connectionVar.rollback()
          connectionVar.close()
          print("Error during database transfer." + '\n' +str(type(inst)) + '\n' + str(inst.args))
          print actions

    finally:                                                # IN ALL CASES, whether there's an error or not during the execution, commit the changes at the end of the execution and close the connection variable.

      if connectionVar:
         connectionVar.commit()
         connectionVar.close()

def api_request(date):                                                  # Function querying the API for the data precised as parameter 

    try:
        visits_data, per_visit_data, actions_data = [], [], []          # Creating the lists ready to contain visits and actions data
        visits_keys = ['idVisit', 'visitorId', 'countryCode', 'region', 'city', 'userId', 'visitIp', 'longitude', 'latitude', 'serverDate', 'firstActionTimestamp', 'lastActionTimestamp', 'visitDuration', 'deviceType', 'deviceModel', 'browserName', 'referrerTypeName', 
        'referrerType', 'referrerName', 'referrerKeyword', 'referrerUrl', 'referrerSearchEngineUrl', 'visitorType', 'daysSinceFirstVisit', 'daysSinceLastVisit', 'actions', 'goalConversions', 'visitConverted', 'customVariables', 'actionDetails']
        with open('piwik_access.yaml','r') as stream:                   # Getting the authentication token necessary to get data from the API. it is store in a YAML file located in the same folder as the script (that's why there's not path)
            access_token = yaml.load(stream)['token']
        get_request = """https://bat-analytics.piwik.pro/index.php?module=API&method=Live.getLastVisitsDetails&idSite=1&format=json&filter_limit=-1&period=day&date=%s&token_auth=%s"""%(date, access_token) #building the API url request using %s variable calls instead of "+" string concatenation
        api_response = urllib2.urlopen(get_request)                     # Opening the URL targeted and storing the response in the api_response variable
        result = json.load(api_response)                                # Transforing the JSON-formatted string response into a JSON variable (loading the JSON from the response)

        for visits_dicts, keys in [(visits_dicts, keys) for visits_dicts in result for keys in visits_keys]:     # For all visit dictionaries in the response ÃND for all keys in the visits_keys list:
            if keys == 'idVisit':                                       # If the key = 'iDVisit' <===> Means "if we start parsing a new visit dict" because it is the first key in the list.
                if len(per_visit_data) > 0:                             # If len(per_visit_data) > 0 <===> Means "if the list of data per visit isn't empty" <==> if it's not the first execution of the loop (to avoid adding an empty list to the final data list.
                    visits_data.append(per_visit_data)                  # We add the list containing the last visit data to the final list containing all data
                per_visit_data = [unec(visits_dicts.get(keys))]         #<===> per_visit_data = [visit_id]
            elif keys == 'customVariables' and type(visits_dicts.get(keys)) == dict:    # Means "if the key is customVariables and there is a dict of data returned"
                for x in range (1,8): #for x = 1 to 7,  
                    if visits_dicts.get(keys).get(str(x)) != None:      # If the customvariable x exists in the dict,
                        custom_var_x = "customVariableValue%s"%str(x)
                        per_visit_data.append(unec(visits_dicts.get(keys).get(str(x)).get(custom_var_x)))        # Use the custom_var_x key to get its value and append it to the per_visit_data list
                    else:                                               # If the customvariable x doesnt exists in the dict,
                        per_visit_data.append('NULL')                     # Then add a None value to our visit_data
            elif keys == 'customVariables' and type(visits_dicts.get(keys)) != dict:    # Means "if the key is customVariables and the data returned is not a dict (list or Nonetype mostly)"
                per_visit_data.extend([None, None, None, None, None, None, None])       # Extend our per_visit_data list with seven None values (one for each custom var)
            elif keys == 'actionDetails':                               # If the key = 'actionDetails'
                for action_dicts in visits_dicts.get(keys):             # For all action dictionaries in the list of actions provided
                    per_action_data = []                                # Reinitialize the value of the per_action_data list
                    if unec(action_dicts.get('type')) == 'action':      # If case dealing with both actions and goals cases
                        per_action_data = [unec(action_dicts.get('type')), unec(visits_dicts.get('idVisit')), unec(action_dicts.get('url')), unec(action_dicts.get('pageIdAction')), None,  unec(visits_dicts.get('serverDate')), unec(action_dicts.get('timestamp')), unec(action_dicts.get('serverTimePretty')), None]
                    elif unec(action_dicts.get('type')) == 'goal':
                        per_action_data = [unec(action_dicts.get('type')), unec(visits_dicts.get('idVisit')), unec(action_dicts.get('url')), unec(action_dicts.get('goalPageId')), unec(action_dicts.get('goalName')),  unec(visits_dicts.get('serverDate')), unec(action_dicts.get('timestamp')), unec(action_dicts.get('serverTimePretty')), unec(action_dicts.get('revenue'))]
                    else:                                               # If our action is not of type "action" or "goal" (<===> IS outlink) then 
                        break                                           # Break the loop and switch to the next action dictionary

                    if 'customVariables' in action_dicts:
                        for x in range (1, 8):                          # Loop getting the data for all custom variables if they exist, otherwise returns None
                            if (action_dicts['customVariables']).get(str(x)) != None:
                                customKey = "customVariablePageValue%s"%x
                                per_action_data.append(unec(action_dicts['customVariables'][str(x)].get(customKey)))
                            else: 
                                per_action_data.append(None)
                    else:
                        per_action_data.extend([None, None, None, None, None, None, None])
                    actions_data.append(per_action_data)
            else:                                                       # If the key is none of the special values, simply append the value associated to the per_visit_data list
                per_visit_data.append(unec(visits_dicts.get(keys)))

        print "Report successfully downloaded and parsed."

        data_transfer(visits_data, actions_data, date)

    except Exception as inst:
        print("Error during report download/parsing." + '\n' + str(type(inst)) + '\n' + str(inst.args))
