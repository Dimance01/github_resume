from django import forms

class UploadFileForm(forms.Form):
    clientname = forms.CharField(max_length=50)
    clientmail = forms.CharField(max_length=50)
    file = forms.FileField()


