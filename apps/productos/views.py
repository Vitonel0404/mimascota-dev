from django.db import connection
from django.http import JsonResponse
from django.shortcuts import get_object_or_404, render
from django.views import View
from django.views.generic import ListView,UpdateView,DeleteView
from django.core.serializers import serialize
from django.contrib.auth.mixins import PermissionRequiredMixin
from apps.empresa.mixins import ValidatedStatusEmpresaMixin
from apps.productos.models import * 
from apps.productos.form import *
from apps.report.report import report
from apps.empresa.views import globales
# Create your views here.

class CategoriaListView(PermissionRequiredMixin,ValidatedStatusEmpresaMixin,ListView):
    permission_required=['productos.view_categoria']
    def get(self, request,*args,**kwargs):
        id_empresa=globales(request)['id_empresa']
        cat=Categoria.objects.filter(id_empresa=id_empresa)
        categorias=serialize('json',cat)
        return JsonResponse({'status':True,'categorias':categorias})

class CategoriaView(PermissionRequiredMixin,ValidatedStatusEmpresaMixin,View):
    permission_required=['productos.add_categoria']
    model=Categoria
    form_class=CategoriaForm
    template_name='Productos/categorias.html'
    
    def get_context_data(self, **kwargs):
        context = {}
        context['form']=self.form_class
        return context

    def get(self,request,*args,**kwargs):
        return render(request,self.template_name,self.get_context_data())
    
    def post(self,request,*args,**kwargs):
        formulario=self.form_class(request.POST)
        if formulario.is_valid():
            formulario.save()
            return JsonResponse({'status':True,'mensaje':'Categoria agregada correctamente'})
        else:
            return JsonResponse({'status':False,'mensaje':'Formulario inválido','error':formulario.errors})

class CategoriaUpdateView(PermissionRequiredMixin,ValidatedStatusEmpresaMixin,UpdateView):
    permission_required=['productos.change_categoria']
    model = Categoria
    form_class=CategoriaForm

    def post(self,request,*args,**kwargs):
        categoria=get_object_or_404(self.model,id_categoria=kwargs['id'])
        formulario=self.form_class(request.POST, instance=categoria)
        if formulario.is_valid():
            formulario.save()
            return JsonResponse({'status':True,'mensaje':'Categoría modificada correctamente'})
        else:
            return JsonResponse({'status':False,'mensaje':'Formulario inválido','error':formulario.errors})

class CategoriaDeleteView(PermissionRequiredMixin,ValidatedStatusEmpresaMixin,DeleteView):
    permission_required=['productos.delete_categoria']
    model = Categoria

    def get(self,request,*args,**kwargs):
        categoria=self.model.objects.filter(id_categoria=kwargs['id'])
        if categoria.exists():
            categoria.delete()
            return JsonResponse({'status':True,'mensaje':'Categoría eliminada correctamente'})
        else:
            return JsonResponse({'status':False,'mensaje':'La categoría a eliminar no existe'}) 

        
#####################################################################################################

class ProductoView(PermissionRequiredMixin,ValidatedStatusEmpresaMixin,View):
    permission_required=['productos.add_producto']
    form_class=ProductoForm
    template_name='Productos/productos.html'

    def get_context_data(self, **kwargs):
        context = {}
        context['form']=self.form_class
        return context
    
    def get(self,request, *args,**kwargs):
        return render(request,self.template_name,self.get_context_data())
    
    def post(self,request, *args,**kwargs):
        
        formulario=self.form_class(request.POST)
        if formulario.is_valid():
            formulario.save()
            return JsonResponse({'status':True,'mensaje':'Producto agregado correctamente'})
        else:
            return JsonResponse({'status':False,'mensaje':'Formulario inválido','error':formulario.errors})     

class ProductoListView(PermissionRequiredMixin,ValidatedStatusEmpresaMixin,ListView):
    permission_required=['productos.view_producto']
    def get(self,request,*args,**kwargs):
        var_global = globales(request)
        cursor=connection.cursor()
        sql = "fn_listar_producto_empresa"
        cursor.callproc(sql,[var_global['id_empresa']])
        data = cursor.fetchall()
        cursor.close()
        return JsonResponse({'status':True,'productos':data})

class ProductoUpdateView(PermissionRequiredMixin,ValidatedStatusEmpresaMixin,UpdateView):
    permission_required=['productos.change_producto']
    model = Producto
    form_class=ProductoForm

    def post(self,request,*args,**kwargs):
        producto=get_object_or_404(self.model,id_producto=kwargs['id'])
        formulario=self.form_class(request.POST, instance=producto)
        if formulario.is_valid():
            formulario.save()
            return JsonResponse({'status':True,'mensaje':'Producto modificado correctamente'})
        else:
            print(formulario.errors)
            return JsonResponse({'status':False,'mensaje':'Formulario inválido','error':formulario.errors})
        
class ProductoDeleteView(PermissionRequiredMixin,ValidatedStatusEmpresaMixin,DeleteView):
    permission_required=['productos.delete_producto']
    model = Producto

    def get(self,request,*args,**kwargs):
        producto = self.model.objects.filter(id_producto=kwargs['id'])
        if producto.exists():
            producto.delete()
            return JsonResponse({'status':True,'mensaje':'Producto eliminado correctamente'})
        else:
            return JsonResponse({'status':False,'mensaje':'Producto a eliminar no existe'})
#######################################################

class ProductoSucursalView(PermissionRequiredMixin,ValidatedStatusEmpresaMixin,View):
    permission_required=['productos.add_productosucursal']
    form_class=ProductoSucursalForm
    template_name='Productos/productos_sucursal.html'

    def get_context_data(self, **kwargs):
        context = {}
        context['form']=self.form_class
        return context
    
    def get(self,request, *args,**kwargs):
        return render(request,self.template_name,self.get_context_data())
    
    def post(self,request, *args,**kwargs):
        formulario=self.form_class(request.POST)
        print(formulario)
        if formulario.is_valid():
            formulario.save()
            return JsonResponse({'status':True,'mensaje':'Producto agregado correctamente'})
        else:
            print(formulario.errors)
            return JsonResponse({'status':False,'mensaje':'Formulario inválido','error':formulario.errors})     

class ProductoSucursalListView(PermissionRequiredMixin,ValidatedStatusEmpresaMixin,ListView):
    permission_required=['productos.view_productosucursal']
    def get(self,request,*args,**kwargs):
        cursor=connection.cursor()
        sql = "fn_listar_producto_sucursal"
        cursor.callproc(sql,[request.user.id_sucursal])
        data = cursor.fetchall()
        cursor.close()
        return JsonResponse({'status':True,'productos':data})

class ProductoSucursalUpdateView(PermissionRequiredMixin,ValidatedStatusEmpresaMixin,UpdateView):
    permission_required=['productos.change_producto']
    model = ProductoSucursal
    form_class=ProductoSucursalForm
    
    def post(self,request,*args,**kwargs):
        producto_sucursal=get_object_or_404(self.model,id_producto_sucursal=kwargs['id'])
        formulario=self.form_class(data=request.POST, instance=producto_sucursal)
        if formulario.is_valid():
            formulario.save()
            return JsonResponse({'status':True,'mensaje':'Producto modificado correctamente'})
        else:
            print(formulario.errors)
            return JsonResponse({'status':False,'mensaje':'Formulario inválido','error':formulario.errors})

class ProductoSucursalDeleteView(PermissionRequiredMixin,ValidatedStatusEmpresaMixin,DeleteView):
    permission_required=['productos.delete_producto']
    model = ProductoSucursal

    def get(self,request,*args,**kwargs):
        producto_sucursal = self.model.objects.filter(id_producto_sucursal=kwargs['id'])
        if producto_sucursal.exists():
            producto_sucursal.delete()
            return JsonResponse({'status':True,'mensaje':'Producto eliminado correctamente'})
        else:
            return JsonResponse({'status':False,'mensaje':'Producto a eliminar no existe'})

def ProductoSucursalAgotarseListView(user):
    with connection.cursor() as cursor:
        sql="fn_productos_agotarse"
        cursor.callproc(sql,[user])
        result=cursor.fetchall()
        cursor.close()
    lista=[]
    for p in result:
        dic={}
        dic['producto']=p[0]
        dic['cantidad']=p[1]
        lista.append(dic)
    return lista


class ExportReportProductos(ValidatedStatusEmpresaMixin,ListView):
    def get(self,request,*args,**kwargs):
        with connection.cursor() as cursor:
            sql = "SELECT * FROM vw_exportar_reporte_producto"      
            cursor.execute(sql)
            productos = cursor.fetchall()
            cursor.close()
        lista_productos=[]
        for pr in productos:
            lista_productos.append({
                'categoria':pr[0],
                'producto':pr[1],
                'descripcion':pr[2],
                'unidad_medida':pr[3],
                'estado':pr[4]
            })
        context={'productos':lista_productos}
        return report(request, 'productos',context)
    
class ExportReportProductosSucursal(ValidatedStatusEmpresaMixin,ListView):
    def get(self,request,*args,**kwargs):
        with connection.cursor() as cursor:
            sql = "fn_exportar_reporte_producto_sucursal"
            cursor.callproc(sql,[request.user.id_sucursal])
            productos = cursor.fetchall()
            cursor.close()
        lista_productos=[]
        for pr in productos:
            lista_productos.append({
                'categoria':pr[0],
                'producto':pr[1],
                'descripcion':pr[2],
                'precio':pr[3],
                'stock':pr[4],
                'stock_min':pr[5],
                'unidad_medida':pr[6],
                'estado':pr[7]
            })
        sucursal = Sucursal.objects.filter(id_sucursal=request.user.id_sucursal).values('razon_social')
        context={'productos':lista_productos,'sucursal':sucursal[0]['razon_social']}
        return report(request, 'productos_sucursal',context)