from django.shortcuts import render
from django.http import HttpResponse
from django.template import loader
from .models import Companies
from django.conf import settings
from django.core.files.storage import FileSystemStorage
from .apijobs import UploadSTL, getSTLVolume, parseSTLJson

def index(request):
	if request.method == 'POST' and request.FILES['fileupload']:
		#suppliers_list = 
		coeffvolume = 0.005
		myfile = request.FILES['fileupload']
		jsonfile = UploadSTL(myfile)
		volume = getSTLVolume(jsonfile)
		print volume
		fs = FileSystemStorage()
		filename = fs.save(myfile.name, myfile)
		uploaded_file_url = fs.url(filename)
		return render(request, 'comparator/index.html', {'uploaded_file_url': uploaded_file_url, 'volume': "%.2f" % round(volume*coeffvolume,2)})
	else:
		return render(request, 'comparator/index.html')