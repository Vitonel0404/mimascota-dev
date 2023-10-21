from django.contrib import admin
from apps.productos.models import Categoria, UnidadMedida,Producto,ProductoSucursal
# Register your models here.

class CategoriaAdmin(admin.ModelAdmin):
    list_display=("id_categoria","id_empresa","descripcion","estado")
    search_fields=("id_categoria","id_empresa","descripcion")

class UnidadMedidaAdmin(admin.ModelAdmin):
    list_display=("id_unidad_medida","id_empresa","descripcion","estado")
    search_fields=("id_unidad_medida","id_empresa","descripcion")

class ProductoAdmin(admin.ModelAdmin):
    list_display=("id_producto","id_categoria","id_unidad_medida","id_empresa","nombre","descripcion","estado")
    search_fields=("id_producto","id_categoria","id_unidad_medida","id_empresa","nombre","descripcion")

class ProductoSucursalAdmin(admin.ModelAdmin):
    list_display=("id_producto_sucursal","id_producto","id_sucursal","precio","stock","stock_min","estado")
    search_fields=("id_producto_sucursal","id_producto","id_sucursal")


admin.site.register(Categoria,CategoriaAdmin),
admin.site.register(UnidadMedida,UnidadMedidaAdmin),
admin.site.register(Producto,ProductoAdmin),
admin.site.register(ProductoSucursal,ProductoSucursalAdmin),