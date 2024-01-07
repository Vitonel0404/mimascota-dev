import json
from django.db import connection
from django.http import JsonResponse
from django.contrib.auth.mixins import PermissionRequiredMixin
from django.views import View
from django.views.generic import ListView, TemplateView,DeleteView,UpdateView
from django.shortcuts import  get_object_or_404,render
from django.core.serializers import serialize
from apps.ventas.models import *
from apps.ventas.form import *
from apps.productos.models import ProductoSucursal
from apps.report.report import report
from apps.empresa.views import globales
from apps.empresa.mixins import ValidatedStatusEmpresaMixin
from veterinaria.settings import base
# Create your views here.

class VentasView(PermissionRequiredMixin,ValidatedStatusEmpresaMixin,TemplateView):
    permission_required=['ventas.add_venta']
    template_name='Ventas/ventas.html'

class ListarVentasListView(PermissionRequiredMixin,ValidatedStatusEmpresaMixin,ListView):
    permission_required=['ventas.view_venta']
    def get(self,request, *args,**kwargs):
        with connection.cursor() as cursor:
            sql='fn_listar_ventas_sucursal'
            cursor.callproc(sql,[request.user.id_sucursal])
            ventas=cursor.fetchall()
            cursor.close()
        return JsonResponse({'status':True,'ventas':ventas})

class RegistrarVenta(PermissionRequiredMixin,ValidatedStatusEmpresaMixin,View):
    permission_required=['ventas.add_detalleventa']
    model=Venta
    form_class=VentaForm
    template_name='Ventas/registrar_venta.html'

    def get_context_data(self, **kwargs):
        context = {}
        context['form']=self.form_class
        context['form2']=DetalleVentaForm()
        return context

    def get(self, request, *args, **kwargs):
        return render(request, self.template_name,self.get_context_data())
    
    def post(self, request, *args, **kwargs):
        id_empresa = globales(request)['id_empresa']
        correlativo_exits = Correlativo.objects.filter(id_tipo_comprobante=request.POST['id_tipo_comprobante'])
        if not correlativo_exits.exists():
            return JsonResponse({'status':False,'mensaje':'No existe correlativos registrados para el tipo de comprobante seleccionado','error':{'correlativo':'Registre nuevos datos para este tipo de comprobante en la sección de "Correlativos"'}})
        new_correlativo=Correlativo.objects.filter(id_empresa=id_empresa,id_tipo_comprobante=request.POST['id_tipo_comprobante']).values('id_correlativo','serie','primer_numero','ultimo_numero_registrado','max_correlativo').last()
        if new_correlativo['ultimo_numero_registrado']==None:
            serie=new_correlativo['serie']
            numero=1
        else:
            serie=new_correlativo['serie']
            numero=new_correlativo['ultimo_numero_registrado']+1

        new_id=Venta.objects.values('id_venta').last()
        if new_id==None:
            new_id=1
        else:
            new_id=new_id['id_venta']+1
        formulario= VentaForm({
            'id_venta':new_id,'id_tipo_comprobante':request.POST['id_tipo_comprobante'],'serie':serie,'numero':numero,
            'id_cliente':request.POST['id_cliente'],'monto_total':request.POST['monto_total'], 
            'operacion_gravada':request.POST['operacion_gravada'],'porcentaje_igv':request.POST['porcentaje_igv'],
            'igv':request.POST['igv'],'fecha':request.POST['fecha'],'id_metodo_pago':request.POST['id_metodo_pago'],
            'id_usuario':request.POST['usuario'],'estado':1,'motivo_anulacion':None,'id_usuario_anulador':None, 'id_sucursal':request.user.id_sucursal
            })
        
        if formulario.is_valid():
            verificar_stock=self.verificar_stock_productos(request.POST['detalle_venta'],request.user.id_sucursal)
            if (verificar_stock):
                verificar_correlativo=self.actualizar_correlativo(id_empresa,new_correlativo['id_correlativo'],numero)
                if verificar_correlativo:
                    formulario.save()
                    detalle,error=self.registrar_detalle_venta(new_id,request.POST['detalle_venta'])
                    # self.actualizar_correlativo(id_empresa,new_correlativo['id_correlativo'],numero)
                    if detalle:
                        self.actualizar_stock_producto(request.POST['detalle_venta'],request.user.id_sucursal)    
                        return JsonResponse({'status':True,'mensaje':'Venta agregada correctamente','id_venta':new_id})
                    else:
                        return JsonResponse({'status':False,'mensaje':'Error al registrar detalle de venta','error':error})
                else:
                    return JsonResponse({'status':False,'mensaje':'¡Ya no tiene correlativos disponibles!','error':{'correlativo':'Agregue otro correlativo para registrar sus ventas'}})
            else:
                return JsonResponse({'status':False,'mensaje':'¡Stock insuficiente!','error':{'stock':"Stock insuficiente en algún producto"}})
        else:
            print(formulario.errors)
            return JsonResponse({'status':False,'mensaje':'Formulario inválido','error':formulario.errors})
    
    def registrar_detalle_venta(self,id,detalle_venta):    
        obj_detalle_venta=json.loads(detalle_venta)
        mensaje=""
        for items in obj_detalle_venta['productos']:
            formulario=DetalleVentaForm({
                'id_venta':id,'id_producto':obj_detalle_venta['productos'][items]['id_producto'], 
                'precio':obj_detalle_venta['productos'][items]['precio'],'cantidad':obj_detalle_venta['productos'][items]['cantidad'],
                'subtotal':obj_detalle_venta['productos'][items]['subtotal']
            })
            if formulario.is_valid():
                formulario.save()
            else:
                print(formulario.errors)
                mensaje=formulario.errors
                return (False,mensaje)     
        mensaje="Detalle agregado correctamente" 
        return (True,mensaje)
        
        
    def actualizar_correlativo(self,id_empresa,id_correlativo, new_numero):
        correlativo=Correlativo.objects.filter(id_empresa=id_empresa,id_correlativo=id_correlativo)
        for c in correlativo:
            if new_numero<=c.max_correlativo:
                c.ultimo_numero_registrado=new_numero
                c.save()
                return True
            else:
                return False
        

    def verificar_stock_productos(self,detalle_venta,id_sucursal):
        obj_detalle_venta=json.loads(detalle_venta)
        for pro in obj_detalle_venta['productos']:
            producto=ProductoSucursal.objects.filter(id_producto=obj_detalle_venta['productos'][pro]['id_producto'],id_sucursal=id_sucursal)
            for c in producto:
                if int(c.stock) >= obj_detalle_venta['productos'][pro]['cantidad']:
                    return True
                else:
                    return False

    def actualizar_stock_producto(self,detalle_venta,id_sucursal):
        obj_detalle_venta=json.loads(detalle_venta)
        for pro in obj_detalle_venta['productos']:
            producto=ProductoSucursal.objects.filter(id_producto=obj_detalle_venta['productos'][pro]['id_producto'],id_sucursal=id_sucursal)
            for c in producto:
                if int(c.stock) >= obj_detalle_venta['productos'][pro]['cantidad']:
                    c.stock= int(c.stock)-obj_detalle_venta['productos'][pro]['cantidad']
                    c.save()

class EliminarVentaDeleteView(PermissionRequiredMixin,ValidatedStatusEmpresaMixin,DeleteView):
    permission_required=['ventas.delete_venta']
    def get(self,request,*args,**kwargs):
        venta=Venta.objects.filter(id_venta=kwargs['id_venta'])
        if venta.exists():
            detalle_venta=DetalleVenta.objects.filter(id_venta=kwargs['id_venta'])
            detalle_venta.delete()
            venta.delete()
            return JsonResponse({'status':True,'mensaje':'Venta elimada correctamente'}) 


class TipoComprobanteListView(PermissionRequiredMixin,ValidatedStatusEmpresaMixin,ListView):
    permission_required=['ventas.view_tipocomprobante']
    model = TipoComprobante
    
    def get(self,request,*args,**kwargs):
        id_empresa=globales(request)['id_empresa']
        tipocomprobantes=self.model.objects.filter(id_empresa=id_empresa)
        te_jso = serialize('json',tipocomprobantes)
        return JsonResponse({'status':True,'tipocomprobantes':te_jso})

class TipoComprobanteView(PermissionRequiredMixin,ValidatedStatusEmpresaMixin,View):
    permission_required=['ventas.add_tipocomprobante']
    model = TipoComprobante
    template_name = "Ventas/tipocomprobante.html"
    form_class = TipoComprobanteForm

    def get_context_data(self, **kwargs):
        context = {}
        context['form']=self.form_class
        return context
    
    def get(self,request,*args,**kwargs):
        return render(request,self.template_name,self.get_context_data())
    
    def post(self,request,*args,**kwargs):
        formulario = self.form_class(request.POST)
        if formulario.is_valid():
            formulario.save()
            return JsonResponse({'status':True,'mensaje':'Correlativo agregado correctamente'})
        else:
            print(formulario.errors)
            return JsonResponse({'status':False,'mensaje':'Formulario inválido','error':formulario.errors})


class TipoComprobanteUpdateView(PermissionRequiredMixin,ValidatedStatusEmpresaMixin,UpdateView):
    permission_required=['ventas.change_tipocomprobante']
    model = TipoComprobante
    form_class= TipoComprobanteForm

    def post(self,request,*args,**kwargs):
        tipocomprobante=get_object_or_404(self.model,id_tipo_comprobante=kwargs['id_tipo_comprobante'])
        formulario=self.form_class(data=request.POST, instance=tipocomprobante)
        if formulario.is_valid():
            formulario.save()
            return JsonResponse({'status':True,'mensaje':'Tipo de Comprobante modificado correctamente'})
        else:
            print(formulario.errors)
            return JsonResponse({'status':False,'mensaje':'Formulario inválido','error':formulario.errors})


class TipoComprobanteDeleteView(PermissionRequiredMixin,ValidatedStatusEmpresaMixin,DeleteView):
    permission_required=['ventas.delete_tipocomprobante']
    model = TipoComprobante
    def get(self,request,*args,**kwargs):
        tipocomprobante=self.model.objects.filter(id_tipo_comprobante=kwargs['id_tipo_comprobante'])
        if tipocomprobante.exists():
            for x in tipocomprobante:
                id=x.id_tipo_comprobante
            tipocomprobante_usado = Venta.objects.filter(id_tipo_comprobante=id)
            if tipocomprobante_usado.exists():
                return JsonResponse({'status':False,'mensaje':'El tipo de comprobante seleccionado se encuentra en uso. No se puede realizar esta acción'}) 
            tipocomprobante.delete()
            return JsonResponse({'status':True,'mensaje':'Tipo de comprobante elimnado correctamente'}) 


class CorrelativoView(PermissionRequiredMixin,ValidatedStatusEmpresaMixin,View):
    permission_required=['ventas.add_correlativo']
    model = Correlativo
    template_name = "Ventas/correlativo.html"
    form_class = CorrelativoForm

    
    def get_context_data(self, **kwargs):
        context={}
        context['form'] = self.form_class
        return context
    
    def get(self, request, *args, **kwargs):
        return render(request, self.template_name,self.get_context_data())

    def post(self, request, *args, **kwargs):
        formulario = self.form_class(request.POST)
        if formulario.is_valid():
            formulario.save()
            return JsonResponse({'status':True,'mensaje':'Correlativo agregado correctamente'})
        else:
            print(formulario.errors)
            return JsonResponse({'status':False,'mensaje':'Formulario inválido','error':formulario.errors})


class CorrelativoListView(PermissionRequiredMixin,ValidatedStatusEmpresaMixin,ListView):
    permission_required=['ventas.view_correlativo']
    def get(self, request, *args, **kwargs):
        id_empresa=globales(request)['id_empresa']
        with connection.cursor() as cursor:
            sql = "SELECT * FROM view_listar_correlativo_empresa WHERE id_empresa = %s"
            cursor.execute(sql,[id_empresa])
            correlativos = cursor.fetchall()
        return JsonResponse({'status':True,'correlativos':correlativos})

class CorrelativoUpdateView(PermissionRequiredMixin,ValidatedStatusEmpresaMixin,UpdateView):
    permission_required=['ventas.change_correlativo']
    model = Correlativo
    form_class=CorrelativoForm
    
    def post(self,request,*args,**kwargs):
        correlativo=get_object_or_404(self.model,id_correlativo=kwargs['id_correlativo'])
        formulario=self.form_class(data=request.POST, instance=correlativo)
        if formulario.is_valid():
            formulario.save()
            return JsonResponse({'status':True,'mensaje':'Correlativo modificado correctamente'})
        else:
            print(formulario.errors)
            return JsonResponse({'status':False,'mensaje':'Formulario inválido','error':formulario.errors})
        
class CorrelativoDeleteView(PermissionRequiredMixin,ValidatedStatusEmpresaMixin,DeleteView):
    permission_required=['ventas.delete_correlativo']
    def get(self,request,*args,**kwargs):
        correlativo=Correlativo.objects.filter(id_correlativo=kwargs['id_correlativo'])
        if correlativo.exists():
            for x in correlativo:
                serie=x.serie
            correlativo_usado = Venta.objects.filter(serie=serie)
            if correlativo_usado.exists():
                return JsonResponse({'status':False,'mensaje':'El correlativo seleccionado se encuentra en uso. No se puede realizar esta acción'}) 
            correlativo.delete()
            return JsonResponse({'status':True,'mensaje':'Correlativo elimnado correctamente'}) 


class BuscarProductoListView(ListView):
    #permission_required=['productos.view_producto']
    def get(self,request,*args,**kwargs):
        producto=kwargs['producto']
        id_sucursal=str(request.user.id_sucursal)
        cursor=connection.cursor()
        sql = "fn_buscar_producto_sucursal"
        cursor.callproc(sql,[producto,id_sucursal])
        data = cursor.fetchall()
        cursor.close()
        return JsonResponse({'status':True,'productos':data})

def consultar_valor_parametro(request,parametro):
    if request.method=='GET':
        parametro=Parametro.objects.filter(nombre__icontains=parametro)
        parametro_json=serialize('json',parametro)
        return JsonResponse({'status':True,'parametro':parametro_json})

def buscar_detalle_venta(request,id_venta):
    if request.method=='GET':
        with connection.cursor() as cursor:
            sql="fn_buscar_detalle_venta"
            cursor.callproc(sql,[id_venta])
            result=cursor.fetchall()
            cursor.close()       
    return JsonResponse({'status':True,'detalle':result}) 

def anular_venta(request):
    if request.method=='POST':
        venta=Venta.objects.filter(id_venta=request.POST['id_venta'])
        if venta.exists():
            for v in venta:
                if v.estado==1:
                    v.estado=0
                    v.motivo_anulacion=request.POST['motivo_anulacion']
                    v.id_usuario_anulador=request.POST['id_usuario_anulador']
                    v.save()
                    return JsonResponse({'status':True,'mensaje':'Venta anulada correctamente'})
                else:
                    return JsonResponse({'status':False,'mensaje':'¡Esta venta ya fue anulada!'})

class ExportReportVentas(ValidatedStatusEmpresaMixin,ListView):
    def get(self,request,*args,**kwargs):
        inicio=kwargs['inicio']
        fin=kwargs['fin']
        with connection.cursor() as cursor:
            sql = "fn_exportar_reporte_venta_sucursal"
            cursor.callproc(sql,[request.user.id_sucursal,inicio,fin])
            data=cursor.fetchall()

            sql = "fn_exportar_resumen_reporte_venta_sucursal"

            cursor.callproc(sql,[request.user.id_sucursal,inicio,fin])
            data2=cursor.fetchall()

            today=datetime.today().strftime('%Y-%m-%d')
            venta_lista=[]

            estados_lista=[]

            for v in data:
                venta_lista.append({
                'documento':v[0],
                'numero':v[1],
                'cliente':v[2],
                'fecha':v[3],
                'metodo_pago':v[4],             
                'igv':v[5],
                'total':v[6],
                'estado':v[7],
                'nombre':v[8],
                'unidad':v[9],
                'cantidad':v[10],   
                'precio':v[11],
                'subtotal':v[12],
            })
            for v in data2:
                estados_lista.append({
                    'estado':v[0],
                    'total':v[1],
                    'monto':v[2]
                })
            sucursal = Sucursal.objects.filter(id_sucursal=request.user.id_sucursal).values('razon_social')
            context={'ventas':venta_lista,'desde':inicio,'hasta':fin,'fecha_solicitud':today,'resumen':estados_lista,'sucursal':sucursal[0]['razon_social']}
            return report(request, 'ventas',context)


class PrintComprobanteVenta(ValidatedStatusEmpresaMixin,ListView):
    def get(self, request, *args, **kwargs):
        id_venta=kwargs['id_venta']
        id_empresa=base.ID_EMPRESA_VARIABLE_GLOBAL
        with connection.cursor() as cursor:
            sql = """
                    SELECT tpc.descripcion,
                        (vv.serie || '-' || vv.numero) as documento,
                        (c.nombre || ' ' || c.apellido) as cliente,
                        vv.fecha,
                        mt.descripcion,
                        vv.igv,
                        vv.monto_total,
                        CASE
                            WHEN vv.estado = 1 THEN 'Realizada'
                            ELSE 'Anulada'
                        END as estado,
                        pp.nombre,
                        pum.descripcion,
                        dtv.cantidad,
                        dtv.precio,
                        dtv.subtotal
                    FROM ventas_venta as vv
                    INNER JOIN ventas_detalleventa as dtv ON vv.id_venta = dtv.id_venta_id
                    INNER JOIN gestion_cliente as c ON c.id_cliente = vv.id_cliente_id
                    INNER JOIN productos_producto as pp ON dtv.id_producto_id = pp.id_producto
                    INNER JOIN gestion_metodopago as mt ON vv.id_metodo_pago_id = mt.id_metodo_pago
                    INNER JOIN ventas_tipocomprobante as tpc ON vv.id_tipo_comprobante_id = tpc.id_tipo_comprobante
                    INNER JOIN productos_unidadmedida as pum ON pum.id_unidad_medida = pp.id_unidad_medida_id
                    WHERE vv.id_venta = %s;
                """
            cursor.execute(sql,[id_venta])
            data=cursor.fetchall()


            cursor.close()
            empresa = Empresa.objects.filter(id= id_empresa)
            empresa=serialize('json',empresa)
            return JsonResponse({'status':True,'data':data,"empresa":empresa}) 


