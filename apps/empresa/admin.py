from django.contrib import admin
from .models import Empresa, Sucursal

class EmpresaAdmin(admin.ModelAdmin):
    list_display=("id","ruc","razon_social","ciudad","direccion","telefono","correo","estado_pago","estado")
    search_fields=("id","razon_social")

class SucursalAdmin(admin.ModelAdmin):
    list_display=("id_sucursal","id_empresa","razon_social","ciudad","direccion","telefono","estado")
    search_fields=("id_sucursal","razon_social")

# Register your models here.
admin.site.register(Empresa,EmpresaAdmin)
admin.site.register(Sucursal,SucursalAdmin)