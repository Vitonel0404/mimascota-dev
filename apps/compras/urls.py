from django.urls import path
from django.contrib.auth.decorators import login_required
from apps.compras.views import *
urlpatterns =[
    path('listar_proveedores/',login_required(ProveedoresListView.as_view()), name='listar_proveedores'),
    path('proveedores/',login_required(ProveedoresView.as_view()), name='proveedores'),
    path('modificar_proveedor/',login_required(ProveedorUpdateView.as_view()), name='modificar_proveedor'),
    path('eliminar_proveedor/<int:id>/',login_required(ProveedorDeleteView.as_view()), name='eliminar_proveedor'),
    path('export_proveedores_pdf/', login_required(ExportReportProveedores.as_view()), name='export_proveedores_pdf'),

    path('listar_compras/',login_required(ListarComprasListView.as_view()), name='listar_compras'),
    path('compras/',login_required(CompraView.as_view()), name='compras'),
    path('registrar_compra/',login_required(RegistrarCompra.as_view()), name='registrar_compra'),
    path('eliminar_compra/<int:id_compra>/',login_required(CompraDeleteView.as_view()), name='eliminar_compra'),
    path('buscar_producto_compra/<str:producto>/', login_required(buscar_producto_compra), name='buscar_producto_compra'),
    path('buscar_detalle_compra/<int:id_compra>/', login_required(buscar_detalle_compra), name='buscar_detalle_compra'),
    path('actualizar_stock_compra/<int:id_compra>/', login_required(actualizarStockCompra), name='actualizar_stock_compra'),
    path('export_compras_pdf/<str:inicio>/<str:fin>/', login_required(ExportReportCompras.as_view()), name='export_compras_pdf'),

]