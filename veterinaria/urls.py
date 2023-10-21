"""veterinariaOlmos URL Configuration

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/3.2/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.contrib import admin
from django.urls import path,include
from django.contrib.auth import views as auth_views
from django.contrib.auth.decorators import login_required
from django.contrib.auth.views import LoginView,logout_then_login
from django.conf import settings
from django.conf.urls.static import static
from apps.gestion.views import *
from apps.usuarios.ResetPasswordViews import *


urlpatterns = [
    path('admin::04042001/', admin.site.urls),
    path('',login_required(Inicio), name="index"),
    #path('',login_required(Login.as_view()), name="index"),
    path('accounts/login/',LoginView.as_view(template_name='login.html'), name="login"),
    path('logout/',logout_then_login,name='logout'),
    ################################################
    path('dashboard/', login_required(dashboard), name='dashboard'),
    ################################################
    #path('usuario/', login_required(usuario), name='usuario'),

    ################################################ATENCIONES##################################################
    ################################################
    path('animal/', login_required(AnimalView.as_view()), name='animal'),
    path('listar_animal/', login_required(AnimalListView.as_view()), name='listar_animal'),
    path('modificar_animal/<id>/', login_required(AnimalUpdateView.as_view()), name='modificar_animal'),
    path('eliminar_animal/<id>/', login_required(AnimalDeleteView.as_view()), name='eliminar_animal'),
    ################################################
    path('raza/', login_required(RazaView.as_view()), name='raza'),
    path('listar_raza/', login_required(RazaListView.as_view()), name='listar_raza'),
    path('modificar_raza/<id>/', login_required(RazaUpdateView.as_view()), name='modificar_raza'),
    path('eliminar_raza/<id>/', login_required(RazaDeleteView.as_view()), name='eliminar_raza'),
    ################################################
    path('cliente/', login_required(ClienteView.as_view()), name='cliente'),
    path('listar_clientes/', login_required(ClienteListView.as_view()), name='listar_clientes'),
    path('modificar_cliente/<int:id_cliente>/', login_required(ClienteUpdateView.as_view()), name='modificar_cliente'),
    path('eliminar_cliente/<int:id_cliente>/', login_required(ClienteDeleteView.as_view()), name='eliminar_cliente'),
    ################################################
    path('mascota/', login_required(MascotaView.as_view()), name='mascota'),
    path('listar_mascotas/', login_required(MascotaListView.as_view()), name='listar_mascotas'),
    path('modificar_mascota/<id>/', login_required(MascotaUpdateView.as_view()), name='modificar_mascota'),
    path('eliminar_mascota/<id>/', login_required(MascotaDeleteView.as_view()), name='eliminar_mascota'),
    path('consultar_cliente/<dni>/', login_required(consultarCliente), name='consultar_cliente'),
    path('consultar_raza/<animal>/', login_required(filtrarRazaXanimal), name='consultar_raza'),
    path('buscar_mascota/<int:numero>/', login_required(buscar_mascota), name='buscar_mascota'),
    path('obtener_nuevo_numero_historia_mascota/', login_required(obtener_nuevo_numero_historia_mascota), name='obtener_nuevo_numero_historia_mascota'),

    ################################################
    path('servicio/', login_required(ServicioView.as_view()), name='servicio'),
    path('listar_servicio/', login_required(ServicioListView.as_view()), name='listar_servicio'),
    path('modificar_servicio/<int:id>/', login_required(ServicioUpdateView.as_view()), name='modificar_servicio'),
    path('eliminar_servicio/<int:id>/', login_required(ServicioDeleteView.as_view()), name='eliminar_servicio'),
    ################################################
    path('atencion/', login_required(AtencionTemplateView.as_view()), name='atencion'),
    path('listar_atenciones/', login_required(AtencionListView.as_view()), name='listar_atenciones'),
    path('registrar_atencion/', login_required(RegistrarAtencionView.as_view()), name='registrar_atencion'),
    #path('registrar_detalle_atencion/', login_required(registrar_detalle_atencion), name='registrar_detalle_atencion'),
    path('consultar_detalle_atencion/<int:atencion>/', login_required(consultar_detalle_atencion), name='consultar_detalle_atencion'),
    path('finalizar_atencion/<int:atencion>/', login_required(finalizar_atencion), name='finalizar_atencion'),
    path('ultimas_atenciones_mascota/<int:historia>/', login_required(ultimas_atenciones_mascota), name='ultimas_atenciones_mascota'),

    ################################################
    path('recordatorio/', login_required(RecordatorioView.as_view()), name='recordatorio'),
    path('listar_recordatorio/', login_required(RecordatorioListView.as_view()), name='listar_recordatorio'),
    path('modificar_recordatorio/<int:id>/', login_required(RecordatorioUpdateView.as_view()), name='modificar_recordatorio'),
    path('eliminar_recordatorio/<int:id>/', login_required(RecordatorioDeleteView.as_view()), name='eliminar_recordatorio'),
    path('buscar_recordatorio/<int:historia>/<str:date>/', login_required(buscar_recordatorio_mascota), name='buscar_recordatorio_mascota'),
    path('marcar_recordatorio/<int:recordatorio>/', login_required(marcar_recordatorio_mascota), name='marcar_recordatorio_mascota'),

    ##########################################REPORTES###########################################
    
    
    path('reportepdf/', login_required(test_reportbro), name='reportepdf'),

    path('report/',include(('apps.report.urls','report'))),
    
    path('export_mascota_pdf/',login_required(exportMascotaPDF),name="export_mascota"),
    path('export_historial_mascota_pdf/<int:id_mascota>/',login_required(export_historial_mascota),name="export_historial_mascota"),
    path('export_atenciones_pdf/<str:inicio>/<str:fin>/',login_required(ExportAtencionReport.as_view()),name="export_atenciones_pdf"),
    
    #path('export_ventas_pdf/<str:inicio>/<str:fin>/',login_required(export_report_ventas),name="export_report_ventas"),
    path('export_clientes_pdf/',login_required(ExportClientesReport.as_view()),name="export_clientes_pdf"),
    path('export_servicios_pdf/',login_required(ExportReportServicios.as_view()),name="export_servicios_pdf"),     
    ##################PRUEBAS#####################
    path('template_email/', login_required(template_email), name='template_email'),
    path('test_pago/<array>/<array2>/', login_required(test_pago), name='test_pago'),
    
    ################################################PRODUCTOS##################################################
    path('producto/',include(('apps.productos.urls','producto'))),

    ################################################VENTAS##################################################
    path('ventas/',include(('apps.ventas.urls','ventas'))),
    ################################################COMPRAS##################################################
    path('compras/',include(('apps.compras.urls','compras'))),
    ################################################USUARIOS##################################################
    path('usuarios/',include(('apps.usuarios.urls','usuarios'))),
    ##########################################ESTADÍSTICA###########################################
    path('estadisticas/', login_required(EstadisticaTemplateView.as_view()), name='estadisticas'),
    path('ganancias_ventas_mensuales_sucursal/<int:id_sucursal>/', login_required(ganancia_mensual_ventas_sucursal), name='ganancias_ventas_mensuales_sucursal'),
    path('mejores_productos_ventas_sucursal/<int:id_sucursal>/', login_required(mejores_productos_ventas_sucursal), name='mejores_productos_ventas_sucursal'),

    path('ganancia_mensual_antencion_sucursal/<int:id_sucursal>/', login_required(ganancia_mensual_antencion_sucursal), name='ganancia_mensual_antencion_sucursal'),
    path('servicio_solicitados_sucursal/<int:id_sucursal>/', login_required(servicio_solicitados_sucursal), name='servicio_solicitados_sucursal'),

] + static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
servicio_solicitados_sucursal