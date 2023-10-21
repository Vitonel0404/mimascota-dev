from django.contrib import admin
from apps.compras.models import Proveedor, Compra, DetalleCompra 

# Register your models here.
admin.site.register(Proveedor),
admin.site.register(Compra),
admin.site.register(DetalleCompra),