Hi,

Some quick information about the current folder.

File(s):
- EzAnalytics_GUI_WIP.py: Work In Progress ! Currently developing a Python GUI using Tkinter and modifying the scripts in order to make this project an executable
and be able to use it easily on other environments.

Folders:
- EzAdwords: Folder containing Python script and credential files for extracting Geo Performance reports from Adwords' API to a PostgreSQL database.
- EzFacebook: Folder containing Python script and credential files for extracting Geo Performance reports from Facebook Ads' API to a PostgreSQL database.
- EzPiwik: Folder containing Python script and credential files for extracting visits and actions data from Piwik API to a PostgreSQL database.

All scripts are quite close in their structure.

Work In Progress:

I am currently developing this project, here are some examples of the next steps I would like to achieve:
- Refactor database connection function and add SSL / SSH connection options.
- Add other databases options
- Develop a GUI enabling user to choose database type, and insert own API and database connection files: Work In Progress
- Create Database Setup function and modify Database Transfer functions in order to: 
	Create Schema IF NOT EXISTS EzAnalytics;
	Create Table IF NOT EXISTS EzAnalytics.EzAdwords_georeport;
	Create Table IF NOT EXISTS EzAnalytics.EzFacebook_georeport;
	Create Table IF NOT EXISTS EzAnalytics.EzPiwik_visitsactions;
===> In order to avoid unnecessary database management operations the first time the program is used on a new database.
- Reorganizing code into separate modules, reorganize program structure.
- Run tests and transform to executable.

