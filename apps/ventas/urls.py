from django.urls import path
from django.contrib.auth.decorators import login_required
from apps.ventas.views import *

urlpatterns =[

    path('ventas/',login_required(VentasView.as_view()), name='ventas'),
    path('listar_ventas/',login_required(ListarVentasListView.as_view()), name='listar_ventas'),
    path('registrar_venta/', login_required(RegistrarVenta.as_view()), name='registrar_venta'), 
    path('eliminar_venta/<int:id_venta>/', login_required(EliminarVentaDeleteView.as_view()), name='eliminar_venta'),
    path('export_ventas_pdf/<str:inicio>/<str:fin>/',login_required(ExportReportVentas.as_view()),name="export_report_ventas"),

    path('anular_venta/', login_required(anular_venta), name='anular_venta'),

    path('buscar_producto/<producto>/', login_required(BuscarProductoListView.as_view()), name='buscar_producto'),
    path('consultar_parametro/<str:parametro>/',login_required(consultar_valor_parametro), name='consultar_parametro'),
    
    path('buscar_detalle_venta/<int:id_venta>/', login_required(buscar_detalle_venta), name='buscar_detalle_venta'),

    path('correlativo/', login_required(CorrelativoView.as_view()), name='correlativo'),
    path('listar_correlativo/', login_required(CorrelativoListView.as_view()), name='listar_correlativo'),
    path('modificar_correlativo/<int:id_correlativo>/', login_required(CorrelativoUpdateView.as_view()), name='modificar_correlativo'),  
    path('eliminar_correlativo/<int:id_correlativo>/', login_required(CorrelativoDeleteView.as_view()), name='eliminar_correlativo'),

    path('tipo_comprobante/', login_required(TipoComprobanteView.as_view()), name='tipo_comprobante'),
    path('listar_tipo_comprobante/', login_required(TipoComprobanteListView.as_view()), name='listar_tipo_comprobante'),
    path('modificar_tipo_comprobante/<int:id_tipo_comprobante>/', login_required(TipoComprobanteUpdateView.as_view()), name='modificar_tipo_comprobante'),  
    path('eliminar_tipo_comprobante/<int:id_tipo_comprobante>/', login_required(TipoComprobanteDeleteView.as_view()), name='eliminar_tipo_comprobante'),  

]