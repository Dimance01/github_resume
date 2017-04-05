Hi,

Some quick information about the current folder.

File(s):
- AdwordsGeoCosts.py: Definition of all functions used to extract geoperformance report for Adwords API and transferring it to a Postgres DB.
- db_connect.yaml: YAML file containing database credentials used in the Python script (fake credentials here of course). To be improved in terms of safety.
- googleads.yaml: YAML file containing API tokens and credentials used in the Python script (fake credentials here of course). To be improved in terms of safety.
- trigger.py: simple Python file importing AdwordsGeoCosts and running the get_costs_per_city() function on the desired time range.