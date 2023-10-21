from django.contrib import admin
from apps.ventas.models import TipoComprobante,Parametro,Correlativo,Venta,DetalleVenta
# Register your models here.

class TipoComprobanteAdmin(admin.ModelAdmin):
    list_display=['id_tipo_comprobante','descripcion','id_empresa','estado']
    search_fields=['id_tipo_comprobante','descripcion','id_empresa','estado']

class ParametroAdmin(admin.ModelAdmin):
    list_display=['id_parametro','nombre','valor','estado']
    search_fields=['id_parametro','nombre','valor','estado']

class CorrelativoAdmin(admin.ModelAdmin):
    list_display=['id_correlativo','id_tipo_comprobante','id_empresa','serie','primer_numero','ultimo_numero_registrado','max_correlativo']
    search_fields=['id_correlativo','id_tipo_comprobante','id_empresa','serie','ultimo_numero_registrado']

class VentaAdmin(admin.ModelAdmin):
    list_display=['id_venta','id_sucursal','id_tipo_comprobante','serie','numero','id_cliente','monto_total','operacion_gravada','porcentaje_igv','igv','fecha','id_metodo_pago','id_usuario','estado','motivo_anulacion','id_usuario_anulador']
    search_fields=['id_venta','id_sucursal','id_tipo_comprobante','serie','numero']

class DetalleVentaAdmin(admin.ModelAdmin):
    list_display=['id_detalle_venta','id_venta','id_producto','precio','cantidad','subtotal']
    search_fields=['id_detalle_venta','id_venta','id_producto']

admin.site.register(TipoComprobante,TipoComprobanteAdmin)
admin.site.register(Parametro,ParametroAdmin)
admin.site.register(Correlativo,CorrelativoAdmin)
admin.site.register(Venta,VentaAdmin)
admin.site.register(DetalleVenta)