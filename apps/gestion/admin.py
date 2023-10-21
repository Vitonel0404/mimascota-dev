from django.contrib import admin
from apps.gestion.models import *

# Register your models here.

class AnimalAdmin(admin.ModelAdmin):
    list_display=("id_animal","descripcion","id_empresa","estado")
    search_fields=("id_animal","descripcion","id_empresa")

class RazaAdmin(admin.ModelAdmin):
    list_display=("id_raza","id_animal","descripcion","id_empresa")
    search_fields=("id_animal","id_animal","descripcion","id_empresa")

class ClienteAdmin(admin.ModelAdmin):
    list_display=("id_cliente","id_tipo_documento","id_empresa","id_sucursal","numero_documento_cliente",'nombre','apellido','estado')
    search_fields=("nombre","apellido","numero_documento_cliente")

class MascotaAdmin(admin.ModelAdmin):
    list_display=("id_mascota","numero_historia","id_cliente","id_raza","id_empresa",'id_sucursal','nombre','estado')
    search_fields=("numero_historia","nombre","id_empresa","id_sucursal")

class ServicioAdmin(admin.ModelAdmin):
    list_display=("id_servicio","id_sucursal","descripcion","id_animal","precio","estado")
    search_fields=("id_servicio","id_sucursal","descripcion")


class AtencionAdmin(admin.ModelAdmin):
    list_display=("id_sucursal","id_atencion","numero_atencion","id_mascota_id","monto_total","entrada","salida","estado","usuario_id")
    search_fields=("id_sucursal","id_atencion","numero_atencion","entrada","salida")

class Detalle_AtencionAdmin(admin.ModelAdmin):
    list_display=("id_detalle_atencion","id_atencion_id","id_servicio_id","monto","comentario")
    #search_fields=("id_ticket_servicio","numero_historia.nombre")

admin.site.register(Cliente,ClienteAdmin),
admin.site.register(Mascota,MascotaAdmin),
admin.site.register(Animal,AnimalAdmin),
admin.site.register(Raza,RazaAdmin),
admin.site.register(TipoDocumento),
admin.site.register(Recordatorio),
admin.site.register(MetodoPago),
admin.site.register(Servicio,ServicioAdmin),
admin.site.register(Atencion,AtencionAdmin),
admin.site.register(Detalle_Atencion,Detalle_AtencionAdmin),
