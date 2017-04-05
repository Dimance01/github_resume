import requests
import json

def UploadSTL(stlFile):

	#stlFile=open('C:\Users\BI002\Desktop\ProgrammingTestDjango3YD\progtest\comparator\stlexample\left_endpin.stl')
	header = {"Accept": "application/json"
	}
	showname = 'MySTLTest'
	url = 'https://api.3yourmind.com/v1/uploads/'
	files = {'file': (showname, stlFile, 'application/sla')}
	fields = {"origin": "python_test"}
	response = requests.post(url,files=files, data=fields, headers=header)
	print("Upload OK.")
	return(json.loads(response.text))

def getSTLVolume(apiJSON):
	print str(apiJSON)
	api_key = "9f5f00e6-d25b-482f-96b2-7860-e9eaeea7"
	url = "https://api.3yourmind.com/v1/uploads/9f5f00e6-d25b-482f-96b2-7860-e9eaeea7/" #+ str(apiJSON['uuid'])
	header = {"Accept": "application/json",
	"Authorization": "ApiKey" + api_key
	}
	response = requests.get(url, headers=header)
	print response.text
	if response.text == """{"error": "Unable to authorize."}""":
		print "Unable to authorize, using test JSON document for extracting volume."
		STLdata = None
	else:
		STLdata = response.text
	return parseSTLJson(STLdata)


def parseSTLJson(STLJson=None):

	if STLJson == None:
		STLJson = {
		"status": "finished",
		"scale": 1.0,
		"unit": "mm",
		"name": "turbine",
		"uuid ": "b5fd966a-349e-4538-9514-a4183976b793",
		"is_multicolor": False,
		"share_url": "http://prodemo.3yourmind.com/en/demo/",
		"creation_date": "2016-07-12T10:41:53Z",
		"thumbnail_url": "https://3yourmind.s3.amazonaws.com/uploads/b5fd966a-349e-4538-9514-a4183976b793/thumbnail.png",
		"parameter": {
			"max_scale": 4.302040223189342,
			"volume": 18536.8515625,
			"d": 91.35800170898438,
			"w": 91.35200500488281,
			"area": 19955.99609375,
			"h": 10.280000686645508,
			"faces": 16644,
			"shells": 1,
			"holes": 0
			}
		}

	c = json.dumps(STLJson)
	d = json.loads(c)
	return d['parameter']['volume']