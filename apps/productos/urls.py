from django.urls import path
from django.contrib.auth.decorators import login_required
from apps.productos.views import *

urlpatterns =[
    path('listar_categorias/', login_required(CategoriaListView.as_view()), name='listar_categorias'),
    path('categorias/', login_required(CategoriaView.as_view()), name='categorias'),
    path('modificar_categoria/<int:id>/', login_required(CategoriaUpdateView.as_view()), name='modificar_categoria'),
    path('eliminar_categoria/<int:id>/', login_required(CategoriaDeleteView.as_view()), name='eliminar_categoria'),
    
    path('productos/', login_required(ProductoView.as_view()), name='productos'),
    path('listar_productos/', login_required(ProductoListView.as_view()), name='listar_productos'),
    path('modificar_producto/<int:id>/', login_required(ProductoUpdateView.as_view()), name='modificar_producto'),
    path('eliminar_producto/<int:id>/', login_required(ProductoDeleteView.as_view()), name='eliminar_producto'),
    path('export_productos_pdf/', login_required(ExportReportProductos.as_view()), name='export_productos_pdf'),


    path('productos_sucursal/', login_required(ProductoSucursalView.as_view()), name='productos_sucursal'),
    path('listar_productos_sucursal/', login_required(ProductoSucursalListView.as_view()), name='listar_productos_sucursal'),
    path('modificar_producto_sucursal/<int:id>/', login_required(ProductoSucursalUpdateView.as_view()), name='modificar_producto_sucursal'),
    path('eliminar_producto_sucursal/<int:id>/', login_required(ProductoSucursalDeleteView.as_view()), name='eliminar_producto_sucursal'),
    path('export_productos_sucursal_pdf/', login_required(ExportReportProductosSucursal.as_view()), name='export_productos_sucursal_pdf'),
]