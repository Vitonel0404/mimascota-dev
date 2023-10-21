from django.http import JsonResponse
from django.db import connection
from django.shortcuts import get_object_or_404, render
from django.views import View
from django.contrib.auth.mixins import PermissionRequiredMixin 
from django.contrib.auth.models import Permission
from django.contrib.contenttypes.models import ContentType
from django.views.generic import ListView,UpdateView,DeleteView,CreateView
from apps.usuarios.form import FormularioUsuario, FormularioUsuarioUpdate
from apps.usuarios.models import Usuario
from apps.empresa.models import Sucursal,Empresa
from apps.compras.models import *
from apps.ventas.models import *
from apps.productos.models import *
from apps.gestion.models import *
from apps.empresa.views import globales
from apps.empresa.mixins import ValidatedStatusEmpresaMixin
# Create your views here.
class UsuariosView(PermissionRequiredMixin,ValidatedStatusEmpresaMixin,View):
    permission_required='usuarios.add_usuario'
    form_class= FormularioUsuario
    template_name='usuario.html'
    
    def get_context_data(self,id_sucursal, **kwargs):
        context = {}
        context['form']=self.form_class
        context['form2']=FormularioUsuarioUpdate()
        empresa = Sucursal.objects.filter(id_sucursal=id_sucursal, estado=True).values('id_empresa')
        for e in empresa:
            id_empresa=e['id_empresa']
        context['sucursales'] = Sucursal.objects.filter(id_empresa =id_empresa,estado=True)
        return context
        
    def get(self, request,*args,**kwargs):
        return render(request, self.template_name,self.get_context_data(request.user.id_sucursal))
    
    def post(self, request, *args,**kwargs):
        formulario=self.form_class(request.POST)
        if formulario.is_valid():
            newUser=formulario.save()
            print(newUser)
            return JsonResponse({'status':True,'mensaje':'Usuario agregado correctamente'})
        else:
            print(formulario.errors)
            return JsonResponse({'status':False,'mensaje':'Formulario inválido','error':formulario.errors})
    
    def listarPermisos(self):
        
        with connection.cursor() as cursor:
            sql = "SELECT * FROM view_listar_permisos"
            cursor.execute(sql)
            perms = cursor.fetchall()
            cursor.close()
            
        return perms

class UsauarioListView(PermissionRequiredMixin,ValidatedStatusEmpresaMixin,ListView):
    permission_required='usuarios.view_usuario'
    model=Usuario
    def get(self, request,*args,**kwargs):
        with connection.cursor() as cursor:
            sql="fn_listar_usuarios_empresa"
            cursor.callproc(sql,[request.user.id_sucursal])
            usuarios=cursor.fetchall()
            cursor.close()
        return JsonResponse({'status':True, 'usuarios':usuarios})

class UsuarioUpdateView(PermissionRequiredMixin,ValidatedStatusEmpresaMixin,UpdateView):
    permission_required='usuarios.change_usuario'
    model = Usuario
    form_class= FormularioUsuarioUpdate

    def post(self, request,*args,**kwargs):
        usuario=get_object_or_404(self.model,id=kwargs['id_usuario'])
        formulario=self.form_class(request.POST,instance=usuario)
        if formulario.is_valid():
            formulario.save()
            return JsonResponse({'status':True,'mensaje':'Usuario modificado correctamente'})
        else:
            print(formulario.errors)
            return JsonResponse({'status':False, 'mensaje':'Formulario inválido','error':formulario.errors})

class UsuarioDeleteView(ValidatedStatusEmpresaMixin,DeleteView):
    permission_required='usuarios.delete_usuario'
    model = Usuario
    
    def get(self, request,*args,**kwargs):
        usuario=self.model.objects.filter(id=kwargs['id_usuario'])
        if usuario.exists():
            for x in usuario:
                superuser=x.is_superuser
            if not superuser:
                usuario.delete()
                return JsonResponse({'status':True,'mensaje':'Usuario eliminado correctamente'})
            else:
                return JsonResponse({'status':False,'mensaje':'No puedes eliminar a este usuario'})
        else:
            return JsonResponse({'status':False,'mensaje':'Usuario eliminado correctamente'})



class PermissionCreateView(ValidatedStatusEmpresaMixin,CreateView):
    model = Permission
    
    def post(self, request, *args, **kwargs):
        user = Usuario.objects.get(id=kwargs['id_usuario'])

        user.user_permissions.clear()
        permisos = request.POST['permisos']
        if permisos == '':
            user.user_permissions.clear()
            return JsonResponse({'status':True, 'mensaje':'Permisos asignados correctamente'})
        
        permisosArray = permisos.split(',')
        for x in permisosArray:
            contentSeparatorName= x.split('_',1)
            contentName = contentSeparatorName[1].capitalize()
            model = self.obtenerModelos(contentName)
            content_type = ContentType.objects.get_for_model(model)
            permission = self.model.objects.get(codename=x,content_type=content_type)
            user.user_permissions.add(permission)
        return JsonResponse({'status':True, 'mensaje':'Permisos asignados correctamente'})

    
    def obtenerModelos(self,model):
        if model == 'Estadistica':
            model = 'Venta'
        models = {
            'Usuario':Usuario,
            'Sucursal':Sucursal,
            'Empresa':Empresa,
            'Animal':Animal,
            'Raza':Raza,
            'Cliente':Cliente,
            'Mascota':Mascota,
            'Atencion':Atencion,
            'Servicio':Servicio,
            'Detalle_atencion':Detalle_Atencion,
            'Recordatorio':Recordatorio,
            'Proveedor':Proveedor,
            'Compra':Compra,
            'Detallecompra':DetalleCompra,
            'Categoria':Categoria,
            'Unidadmedida':UnidadMedida,
            'Producto':Producto,
            'Productosucursal':ProductoSucursal,
            'Venta':Venta,
            'Detalleventa':DetalleVenta,
            'Tipocomprobante':TipoComprobante,
            'Correlativo':Correlativo,
        }
        return models[model]


class PermissionUserListView(ValidatedStatusEmpresaMixin,ListView):
    def get(self, request, *args, **kwargs):
        with connection.cursor() as cursor:
            sql = "SELECT * FROM view_listar_permisos_usuario where usuario_id = %s"
            cursor.execute(sql,[kwargs['id_usuario']])
            codename=cursor.fetchall()
            cursor.close()
        return JsonResponse({'perms':codename})

class PermissionListView(ValidatedStatusEmpresaMixin,ListView):
    def get(self, request, *args, **kwargs):
        with connection.cursor() as cursor:
            sql = "SELECT * FROM view_listar_permisos"
            cursor.execute(sql)
            perms=cursor.fetchall()
            cursor.close()
        return JsonResponse({'perms':perms})


        