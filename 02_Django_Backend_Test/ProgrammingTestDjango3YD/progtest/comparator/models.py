from __future__ import unicode_literals

from django.db import models

# Create your models here.

class Companies(models.Model):
    company_name = models.CharField(max_length=200)
    material_name = models.CharField(max_length=200)
    ppunit = models.FloatField()

    def __str__(self):
        return self.company_name