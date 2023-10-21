from django.shortcuts import render
from django.core.serializers import serialize
from veterinaria.settings import base
from .models import Sucursal,Empresa

# Create your views here.
def globales(request):
    globales ={}
    if request.user.is_authenticated:
        if request.user.id_sucursal is not None:
            sucursal = Sucursal.objects.filter(id_sucursal=request.user.id_sucursal).values_list('razon_social','id_empresa')
            globales['sucursal'] = sucursal[0][0]
            globales['id_empresa'] = sucursal[0][1]
            base.ID_EMPRESA_VARIABLE_GLOBAL = sucursal[0][1]
            datos_email=Empresa.objects.filter(id=globales['id_empresa']).values('correo','token_correo')
            for dt in datos_email:
                base.EMAIL_HOST_USER=dt['correo']
                base.EMAIL_HOST_PASSWORD=dt['token_correo']
        else:
            globales['sucursal'] = "Admin"
            globales['id_empresa'] = "Admin"
    else:
        globales['sucursal'] = base.SUCURSAL_VARIABLE_GLOBAL
        globales['id_empresa'] = base.ID_EMPRESA_VARIABLE_GLOBAL
        
    return globales

