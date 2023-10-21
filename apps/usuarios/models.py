from django.contrib.auth.models import AbstractUser
from django.db import models
#from apps.empresa.models import Sucursal


# Create your models here.

class Usuario(AbstractUser):
    token=models.UUIDField(null=True, blank=True)
    id_sucursal=models.IntegerField(null=True, blank=True)