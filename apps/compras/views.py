import json
from django.db import connection
from django.http import JsonResponse
from django.shortcuts import get_object_or_404, render
from django.core.serializers import serialize
from django.views import View
from django.contrib.auth.mixins import PermissionRequiredMixin 
from django.views.generic import ListView, UpdateView, TemplateView,DeleteView
from apps.compras.models import *
from apps.productos.models import Producto, ProductoSucursal
from apps.empresa.views import globales
from apps.empresa.models import Empresa
from apps.compras.form import *
from apps.report.report import report
from apps.empresa.mixins import ValidatedStatusEmpresaMixin

# Create your views here.

class ProveedoresListView(PermissionRequiredMixin,ValidatedStatusEmpresaMixin,ListView):
    permission_required='compras.view_proveedor'
    model=Proveedor
    def get(self,request,*args,**kwargs):
        var_global = globales(request)
        cursor =connection.cursor()
        sql="SELECT * FROM vw_listar_proveedor WHERE id_empresa = %s"
        cursor.execute(sql,[var_global['id_empresa']])
        proveedores = cursor.fetchall()
        cursor.close()
        return JsonResponse({'status':True,'proveedores':proveedores})

class ProveedoresView(PermissionRequiredMixin,ValidatedStatusEmpresaMixin,View):
    permission_required=['compras.add_proveedor']
    model= Proveedor
    form_class= ProveedorForm
    template_name='Compras/proveedores.html'
    
    def get_context_data(self, **kwargs):
        context = {}
        context['form']=self.form_class
        return context
    
    def get(self, request,*args,**kwargs):
        return render(request, self.template_name,self.get_context_data())
    
    def post(self, request, *args,**kwargs):
        formulario=self.form_class(request.POST)
        if formulario.is_valid():
            formulario.save()
            return JsonResponse({'status':True,'mensaje':'Proveedor agregado correctamente'})
        else:
            print(formulario.errors)
            return JsonResponse({'status':False,'mensaje':'Formulario inválido','error':formulario.errors})       

class ProveedorUpdateView(PermissionRequiredMixin,ValidatedStatusEmpresaMixin,UpdateView):
    permission_required='compras.change_proveedor'
    def post(self,request,*args,**kwargs):
        proveedor=get_object_or_404(Proveedor,id_proveedor=request.POST['id_proveedor'])
        formulario=ProveedorForm(request.POST, instance=proveedor)
        if formulario.is_valid():
            formulario.save()
            return JsonResponse({'status':True,'mensaje':'Proveedor modificado correctamente'})
        else:
            return JsonResponse({'status':False,'mensaje':'Formulario inválido','error':formulario.errors})

class ProveedorDeleteView(PermissionRequiredMixin,ValidatedStatusEmpresaMixin,DeleteView):
    permission_required='compras.delete_proveedor'
    model = Proveedor
    
    def get(self,request,*args,**kwargs):
        proveedor=self.model.objects.filter(id_proveedor=kwargs['id'])
        if proveedor.exists():
            proveedor.delete()
            return JsonResponse({'status':True,'mensaje':'Proveedor elimado correctamente'})
        else:
            return JsonResponse({'status':False,'mensaje':'Proveedor seleccionado no existe'})

class CompraView(PermissionRequiredMixin,ValidatedStatusEmpresaMixin,TemplateView):
    permission_required=['compras.add_compra']
    template_name='Compras/compras.html'

class ListarComprasListView(PermissionRequiredMixin,ValidatedStatusEmpresaMixin,ListView):
    permission_required='compras.view_compra'
    def get(self,request, *args,**kwargs):
        with connection.cursor() as cursor:
            sql="fn_listar_compras"
            cursor.callproc(sql,[request.user.id_sucursal])
            result = cursor.fetchall()
            print(result)
        return JsonResponse({'status':True,'compras':result})

class RegistrarCompra(PermissionRequiredMixin,ValidatedStatusEmpresaMixin,View):
    permission_required='compras.add_detallecompra'
    model=Compra
    form_class=CompraForm
    template_name='Compras/registrar_compra.html'

    def get_context_data(self, **kwargs):
        context = {}
        context['form']=self.form_class
        return context

    def get(self, request, *args, **kwargs):
        return render(request, self.template_name,self.get_context_data())
    
    def post(self, request, *args, **kwargs):
        new_id=self.model.objects.values('id_compra').last()
        if new_id==None:
            new_id=1
        else:
            new_id=new_id['id_compra']+1

        formulario=self.form_class({
            'id_compra':new_id,'id_tipo_comprobante':request.POST['id_tipo_comprobante'],'serie':request.POST['serie'],'numero':request.POST['numero'],
            'id_proveedor':request.POST['id_proveedor'],'monto_total':request.POST['monto_total'],'impuesto':request.POST['impuesto'],'fecha':request.POST['fecha'],
            'fecha_registro':request.POST['fecha_registro'],'estado':False,'id_usuario':request.POST['usuario'],'id_sucursal':request.user.id_sucursal
        })

        if formulario.is_valid():
            formulario.save()
            detalle,error=self.registrarDetalleCompra(new_id,request.POST['detalle_compra'])
            if detalle:
                # self.actualizarStockCompra(request.POST['detalle_compra'],request.user.id_sucursal)
                return JsonResponse({'status':True,'mensaje':'Compra agregada correctamente','id_compra':new_id})
            else:
                self.model.objects.filter(id_compra=new_id).delete()
                return JsonResponse({'status':False,'mensaje':'Formulario inválido','error':error})
        else:
            print(formulario.errors)
            return JsonResponse({'status':False,'mensaje':'Formulario inválido','errors':formulario.errors})
    
    def registrarDetalleCompra(self, id, detalle_compra):
        obj_detalle_compra=json.loads(detalle_compra)
        for items in obj_detalle_compra['productos']:
            formulario=DetalleCompraForm({
                'id_compra':id,'id_producto':obj_detalle_compra['productos'][items]['id_producto'], 
                'precio':obj_detalle_compra['productos'][items]['precio'],'cantidad':obj_detalle_compra['productos'][items]['cantidad'],
                'subtotal':obj_detalle_compra['productos'][items]['subtotal']
            })
            error=None
            if formulario.is_valid():
                formulario.save()
            else:
                error=formulario.errors
                return (False,error)
        return (True,error)
        
    
    def actualizarStockCompra(self, detalle_compra,id_sucursal):
        obj_detalle_compra=json.loads(detalle_compra)
        for items in obj_detalle_compra['productos']:
            producto=ProductoSucursal.objects.filter(id_producto=obj_detalle_compra['productos'][items]['id_producto'],id_sucursal=id_sucursal)
            for p in producto:
                p.stock=int(p.stock)+int(obj_detalle_compra['productos'][items]['cantidad'])
                p.save()
        

class CompraDeleteView(PermissionRequiredMixin,ValidatedStatusEmpresaMixin,DeleteView):
    permission_required='compras.delete_compra'
    model = Compra
    
    def get(self,*args,**kwargs):
        compra=self.model.objects.filter(id_compra=kwargs['id_compra'])
        if compra.exists():
            detalle_compra=DetalleCompra.objects.filter(id_compra=kwargs['id_compra'])
            detalle_compra.delete()
            compra.delete()
            return JsonResponse({'status':True,'mensaje':'Compra elimada correctamente'})       


def actualizarStockCompra(request,id_compra):
    compra = Compra.objects.filter(id_compra=id_compra)
    for c in compra:
        if c.estado is False: 
            detalle = DetalleCompra.objects.filter(id_compra=id_compra)
            for items in detalle:
                producto=ProductoSucursal.objects.filter(id_producto=items.id_producto,id_sucursal=request.user.id_sucursal)
                for p in producto:
                    p.stock=int(p.stock)+int(items.cantidad)
                    p.save()
            c.estado = True
            c.save()
            return JsonResponse({'status':True,'mensaje':'Stock actualizado correctamente'})
        return JsonResponse({'status':False,'mensaje':'Ya se hizo el traspaso de productos para esta compra'})

def buscar_detalle_compra(request,id_compra):
    if request.method=='GET':
        with connection.cursor() as cursor:
            sql="fn_buscar_detalle_compra"
            cursor.callproc(sql,[id_compra])
            result=cursor.fetchall()
            cursor.close()    
        return JsonResponse({'status':True,'detalle':result})

def buscar_producto_compra(request,producto):
    if request.method=='GET':
        id_sucursal=str(request.user.id_sucursal)
        cursor=connection.cursor()
        sql = "fn_buscar_producto_sucursal"
        cursor.callproc(sql,[producto,id_sucursal])
        data = cursor.fetchall()
        cursor.close()
        return JsonResponse({'status':True,'productos':data})
            
        


class ExportReportCompras(ValidatedStatusEmpresaMixin,ListView):
    def get(self,request,*args,**kwargs):
        inicio=kwargs['inicio']
        fin=kwargs['fin']
        with connection.cursor() as cursor:
            sql="fn_exportar_reporte_compras"
            cursor.callproc(sql,[request.user.id_sucursal,inicio,fin])
            data=cursor.fetchall()
        compra_lista=[]
        for v in data:
            compra_lista.append({
            'documento':v[0],
            'numero':v[1],
            'proveedor':v[2],
            'fecha':v[3],
            'impuesto':v[4],             
            'total':v[5],
            'estado':v[6],
            'nombre':v[7],
            'unidad':v[8],
            'cantidad':v[9],   
            'precio':v[10],
            'subtotal':v[11],
        })
        sucursal = Sucursal.objects.filter(id_sucursal=request.user.id_sucursal).values('razon_social')
        context={'compras':compra_lista,'desde':inicio,'hasta':fin,'sucursal':sucursal[0]['razon_social']}
        return report(request,'compras',context)

class ExportReportProveedores(ValidatedStatusEmpresaMixin,ListView):
    def get(self,request,*args,**kwargs):
        var_global = globales(request)
        proveedores=Proveedor.objects.filter(id_empresa=var_global['id_empresa'])
        lista_proveedores=[]
        for pr in proveedores:
            estado='Activo' if pr.estado==True else 'Inactivo'
            lista_proveedores.append({
                'numero_documento_proveedor':pr.numero_documento_proveedor,
                'razon_social':pr.razon_social,
                'telefono_proveedor':pr.telefono_proveedor,
                'telefono_contacto':pr.telefono_contacto,
                'direccion':pr.direccion,
                'estado':estado,
            })
        empresa = Empresa.objects.filter(id=var_global['id_empresa']).values('razon_social')
        context={'proveedores':lista_proveedores,'empresa':empresa[0]['razon_social']}
        return report(request, 'proveedores',context)