from django.contrib import admin
from django.contrib.auth.models import Permission
from .models import Usuario

# Register your models here.
class UsuarioAdmin(admin.ModelAdmin):
    list_display=("id","username","email","first_name","last_name",'id_sucursal')
    search_fields=("id","username","first_name")

admin.site.register(Permission),
admin.site.register(Usuario,UsuarioAdmin),