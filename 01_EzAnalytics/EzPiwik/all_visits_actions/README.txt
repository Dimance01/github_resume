Hi,

Some quick information about the current folder.

File(s):
- PiwikVisits.py: Definition of all functions used to extract all visits and actions data from Piwik API, and transferring it to a Postgres DB.
- db_connect.yaml: YAML file containing database credentials used in the Python script (fake credentials here of course). To be improved in terms of safety.
- piwik_access.yaml: YAML file containing API tokens and credentials used in the Python script (fake credentials here of course). To be improved in terms of safety.
- trigger.py: simple Python file importing PiwikVisits and running the get_costs_per_ad() function on the desired time range.