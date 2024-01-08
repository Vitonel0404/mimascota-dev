from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
import json
import smtplib
import mercadopago
from django.db import connection
from django.db.models import Q
from django.http import JsonResponse
from django.contrib.auth.mixins import PermissionRequiredMixin
from django.shortcuts import get_object_or_404, redirect, render
from django.views import View
from django.views.generic import TemplateView, ListView,UpdateView,DeleteView
from django.core.serializers import serialize
from django.template.loader import render_to_string
from apps.gestion.form import *
from apps.gestion.models import *
from apps.productos.views import ProductoSucursalAgotarseListView
from apps.report.report import report
from apps.usuarios.mixins import UsuarioStaffMixin
from veterinaria.settings import base
from datetime import datetime
from apps.empresa.views import globales
from apps.empresa.mixins import ValidatedStatusEmpresaMixin



# Create your views here.

# SDK de Mercado Pago

# Agrega credenciales
sdk = mercadopago.SDK("xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx")

def template_pago(request):
    return render(request,'pago-test.html')

def test_pago(request,array,array2):
    
    if request.method=='GET':
        #array_items=json.loads(array)
        obj_array2=json.loads(array2)
        lista_items=[]
        for i in obj_array2['servicios']:
            dict_items={}
            dict_items["id"]='0001'
            dict_items["title"]=obj_array2['servicios'][i]['id_servicio']
            dict_items["quantity"]=1
            dict_items["unit_price"]=obj_array2['servicios'][i]['monto']
            dict_items["currency_id"]='PEN'
            lista_items.append(dict_items)
        preference_data = {
            "items": lista_items,
            'back_urls':{
                'success': "http://127.0.0.1:8000/registrar_atencion/"
            }
        }
        preference_response = sdk.preference().create(preference_data)
        preference = preference_response["response"]
        print(preference)
        arrayServicios=[]
        for p in obj_array2['servicios']:
            name_servicio=Servicio.objects.values('descripcion').filter(id_servicio=obj_array2['servicios'][p]['id_servicio'])
            for desc in name_servicio:
                arrayServicios.append(desc['descripcion'])


        arrayMonto=[]
        for p in obj_array2['servicios']:
            arrayMonto.append(obj_array2['servicios'][p]['monto'])
        return render(request,'pago-test.html',{'id_preference':preference,'servicios':arrayServicios,'montos':arrayMonto})
###################################################################

def Inicio(request):
    if request.user.is_authenticated:
        return redirect(to='dashboard')
    else:
        return render(request, 'login.html')

###################################################################
#EMAIL!!!!!!!!!!!!!1
def template_email(request):
    return render(request,'Email/email2.html')

def send_email(mail):
    try:
        print(base.EMAIL_HOST_USER)
        print(base.EMAIL_HOST_PASSWORD)
        mailServer =smtplib.SMTP(base.EMAIL_HOST, base.EMAIL_PORT)
        mailServer.starttls()
        mailServer.login(base.EMAIL_HOST_USER, base.EMAIL_HOST_PASSWORD)
        print('conectado..')
        for em in mail:
            email_to=em['email']
            mensaje=MIMEMultipart()
            mensaje['From']=base.EMAIL_HOST_USER
            mensaje['To']=email_to
            mensaje['Subject']="Recordatorio pendiente"
            context={'cliente':em['cliente'],'mascota':em['mascota']}
            content=render_to_string('Email/email2.html',context)

            mensaje.attach(MIMEText(content, 'html'))

            mailServer.sendmail(base.EMAIL_HOST_USER,
                        email_to,
                        mensaje.as_string())
            
            print("Metodo 2 de envio de correo exitoso! Enviado correctamente a "+email_to)
        return True
    except Exception as e:
        print(e)



def dashboard(request):
    if request.method=='POST':
        user=str(request.user)
        list_mail=correos_recordatorios_pendientes(request.POST['fecha'],user)
        if len(list_mail)>0:
            status=send_email(list_mail)
            if status:
                return JsonResponse({'status':True,'mensaje':'Correos enviados con éxito'})
            else:
                return JsonResponse({'status':False,'mensaje':'Error al enviar correo'})
        else:
            return JsonResponse({'status':False,'mensaje':'No tienes recordatorios pendientes para hoy'})
    else:
        today=datetime.today().strftime('%Y-%m-%d')
        year=datetime.today().strftime('%Y')
        mes_año=datetime.today().strftime('%Y-%m')
        user=str(request.user)
        gan_dia_servicios = ganancias_diarias_servicios(today,user)
        gan_dia_ventas=ganancias_diarias_ventas(today,user)
        gan_mensual=ganancia_mensual_atencion(year,user)  
        mejores_servicios=servicio_solicitados(mes_año,user)      
        numero_recordatorios_pendientes=recordatorios_pendientes(today, user)
        servicios_atendidos=servicios_atendidos_hoy(today,user)
        productos_agot=ProductoSucursalAgotarseListView(user)
        gan_dia_serv_vent=gan_dia_servicios+gan_dia_ventas
        return render(request, 'dashboard.html',
            {'gan_dia':gan_dia_serv_vent,
                'mes':gan_mensual['mes'],
                'monto':gan_mensual['monto'],
                'mejores_servicios_desc':mejores_servicios['mejores_servicios_desc'],
                'mejores_servicios_cant':mejores_servicios['mejores_servicios_cant'],
                'num_recordatorios_pendientes':numero_recordatorios_pendientes,
                'servicios_atendidos':servicios_atendidos,
                'prod_agt':productos_agot
            })
def ganancias_diarias_servicios(today,user):
    cursor =connection.cursor()
    sql="fn_ganancias_diaras_servicios"
    cursor.callproc(sql,[today,user])
    gan_dia_servicios = cursor.fetchone()
    cursor.close()
    if gan_dia_servicios[0] is None: 
        return 0
    else:
        return gan_dia_servicios[0]

def ganancias_diarias_ventas(today,user):
    cursor =connection.cursor()
    sql="fn_ganancias_diaras_ventas"
    cursor.callproc(sql,[today,user])
    gan_dia_ventas = cursor.fetchone()
    cursor.close()
    if gan_dia_ventas[0] is None: 
        return 0
    else:
        return gan_dia_ventas[0]
    

def servicios_atendidos_hoy(today,user):
    cursor= connection.cursor()
    sql="fn_servicios_atendidos_hoy"
    cursor.callproc(sql,[today,user])
    numero_servicios = cursor.fetchone()
    cursor.close()
    return numero_servicios[0]

def ganancia_mensual_atencion(year,user):
    cursor= connection.cursor()
    sql="fn_ganancia_mensual_atencion"
    cursor.callproc(sql,[year,user])
    gan_mensuales = cursor.fetchall()
    cursor.close()
    meses=[]
    monto=[]
    meses_labels={1:'Enero', 2:'Febrero', 3:'Marzo', 4:'Abril', 5:'Mayo', 6:'Junio', 7:'Julio', 8:'Agosto',
        9:'Setiembre', 10:'Octubre', 11:'Noviembre', 12:'Diciembre'}
    meses_labels_ok=[]
    for c in gan_mensuales:
        meses.append(c[0])
        monto.append(c[1])
    lista_meses=list(map(int,meses))
    lista_monto=list(map(float,monto))
    for m in lista_meses:
        if (m in meses_labels):
            meses_labels_ok.append(meses_labels[m])
    
    datos={'mes':meses_labels_ok,
            'monto':lista_monto,}
    
    return datos

def servicio_solicitados(mes_año,user):
    cursor= connection.cursor()
    sql="fn_servicios_mas_solicitados"
    cursor.callproc(sql,[mes_año,user])
    mejores_servicios=cursor.fetchall()
    cursor.close()
    mejor_serv_desc=[]
    cant_mejor_serv_desc=[]
    for s in mejores_servicios:
        mejor_serv_desc.append(s[0])
    for cant in mejores_servicios:
        cant_mejor_serv_desc.append(cant[1])
    
    data={'mejores_servicios_desc':mejor_serv_desc,
        'mejores_servicios_cant':cant_mejor_serv_desc,}
    
    return data

def recordatorios_pendientes(date, user):
    cursor=connection.cursor()
    sql="fn_recordatorios_pendientes"
    cursor.callproc(sql,[date, user])
    data=cursor.fetchone()
    cursor.close()
    return data[0]

def correos_recordatorios_pendientes(date,user):
    cursor=connection.cursor()
    sql="fn_correos_recordatorios_pendientes "
    cursor.callproc(sql,[date,user])
    data=cursor.fetchall()
    cursor.close()
    list_mail=[]
    for l in data:
        dic={}
        dic['email']=l[0]
        dic['cliente']=l[1]
        dic['mascota']=l[2]
        list_mail.append(dic)
    return list_mail

##################################################################################################
'''def usuario(request):
    usuarios = Usuario.objects.all()
    return render(request, 'usuario.html',{'data':usuarios})

class user_registro(CreateView):
    model=Usuario
    form_class=FormularioUsuario
    template_name='form_usuario.html'
    success_url=reverse_lazy('usuario')'''

'''def usuario(request):
    if request.method== 'POST':
        formulario = FormularioUsuario(request.POST)
        if formulario.is_valid():
            formulario.save()
            return JsonResponse({'status':True,'mensaje':'Usuario registrado correctamente'})
        else:
            return JsonResponse({'status':False,'mensaje':'Formulario inválido','error':formulario.errors})                         
    else:
        context={'form': FormularioUsuario(),
                'form2':FormularioUsuarioUpdate()
                }
        return render(request, 'usuario.html',context)'''

##################################################################################################

class AnimalView(PermissionRequiredMixin,ValidatedStatusEmpresaMixin,View):
    permission_required=['gestion.add_animal']
    model=Animal
    form_class=FormularioAnimal
    template_name='animal.html'

    def get_context_data(self, **kwargs):
        context = {}
        context['form']=self.form_class
        return context
    
    def get(self, request, *args,**kwargs):
        return render(request,self.template_name,self.get_context_data())
    
    def post(self, request, *args,**kwargs):
        formulario=self.form_class(request.POST)
        if formulario.is_valid():
            formulario.save()
            return JsonResponse({'status':True,'mensaje':'Animal agregado correctamente'})
        else:
            return JsonResponse({'status':False, 'mensaje':'Formulario inválido','error':formulario.errors})
    
class AnimalListView(PermissionRequiredMixin,ValidatedStatusEmpresaMixin,ListView):
    permission_required=['gestion.view_animal']
    model=Animal
    def get(self, request, *args,**kwargs):
        var_global = globales(request)
        animales=self.model.objects.filter(id_empresa=var_global['id_empresa']).order_by('id_animal')
        data_json=serialize('json',animales)
        return JsonResponse({'status':True,'animales':data_json})

class AnimalUpdateView(PermissionRequiredMixin,ValidatedStatusEmpresaMixin,UpdateView):
    permission_required=['gestion.change_animal']
    model=Animal
    form_class=FormularioAnimal
    def post(self,request,*args,**kwargs):
        animal=get_object_or_404(self.model,id_animal=kwargs['id'])
        formulario = self.form_class(request.POST, instance=animal)
        if formulario.is_valid():
            formulario.save()
            return JsonResponse({'status':True,'mensaje':'Animal modificado correctamente'})
        else:
            print(formulario.errors)
            return JsonResponse({'status':False, 'mensaje':'Formulario inválido','error':formulario.errors})

class AnimalDeleteView(PermissionRequiredMixin,ValidatedStatusEmpresaMixin,DeleteView):
    permission_required=['gestion.delete_animal']
    model = Animal
    def get(self, request,*args,**kwargs):
        animal=self.model.objects.filter(id_animal=kwargs['id'])
        if animal.exists():
            animal.delete()
            return JsonResponse({'status':True,'mensaje':'Animal eliminado correctamente'})
        else:
            return JsonResponse({'status':False,'mensaje':'Animal seleccionado no existe'})

##################################################################################################
class RazaView(PermissionRequiredMixin,ValidatedStatusEmpresaMixin,View):
    permission_required=['gestion.add_raza']
    model=Raza
    form_class=FormularioRaza
    template_name='raza.html'

    def get_context_data(self,request, **kwargs):
        var_global = globales(request)
        context = {}
        context['form']=self.form_class
        context['animal'] = Animal.objects.filter(id_empresa=var_global['id_empresa'],estado=True)
        return context
    
    def get(self,request, *args,**kwargs):
        return render(request,self.template_name,self.get_context_data(request))
    
    def post(self,request,*args,**kwargs):
        formulario = self.form_class(request.POST)
        if formulario.is_valid():
            formulario.save()
            return JsonResponse({'status':True,'mensaje':'Raza agregada correctamente'})
        else:
            print(formulario.errors)
            return JsonResponse({'status':False,'mensaje':'Formulario Inválido','error':formulario.errors})

class RazaListView(PermissionRequiredMixin,ValidatedStatusEmpresaMixin,ListView):
    permission_required=['gestion.view_raza']
    def get(self,request,*args,**kwargs):
        var_global = globales(request)
        cursor= connection.cursor()
        sql="SELECT * FROM vw_listar_raza  WHERE id_empresa = %s"
        cursor.execute(sql,[var_global['id_empresa']])
        row = cursor.fetchall()
        cursor.close()
        return JsonResponse({'status':True,'razas':row})

class RazaUpdateView(PermissionRequiredMixin,ValidatedStatusEmpresaMixin,UpdateView):
    permission_required=['gestion.change_raza']
    model = Raza
    form_class= FormularioRaza

    def post(self,request,*args,**kwargs):
        raza=get_object_or_404(self.model,id_raza=kwargs['id'])
        formulario = self.form_class(request.POST, instance=raza)
        if formulario.is_valid():
            formulario.save()
            return JsonResponse({'status':True,'mensaje':'Raza modificada correctamente'})
        else:
            print(formulario.errors)
            return JsonResponse({'status':False,'mensaje':'Formulario inválido','error':formulario.errors})

class RazaDeleteView(PermissionRequiredMixin,ValidatedStatusEmpresaMixin,DeleteView):
    permission_required=['gestion.delete_raza']
    model = Raza

    def get(self,*args,**kwargs):
        raza=self.model.objects.filter(id_raza=kwargs['id'])
        if raza.exists():
            raza.delete()
            return JsonResponse({'status':True,'mensaje':'Raza eliminada correctamente'})
        else:
            return JsonResponse({'status':False,'mensaje':'Raza seleccionada no existe'})

##################################################################################################

class ClienteView(PermissionRequiredMixin,ValidatedStatusEmpresaMixin,View):
    permission_required=['gestion.add_cliente']
    model=Cliente
    form_class=FormularioCliente
    template_name='cliente.html'

    
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
            return JsonResponse({'status':True,'mensaje':'Cliente agregado correctamente'})
        else:
            print(formulario.errors)
            return JsonResponse({'status':False,'mensaje':'Formulario inválido','error':formulario.errors})
    
class ClienteListView(PermissionRequiredMixin,ValidatedStatusEmpresaMixin,ListView):
    permission_required=['gestion.view_cliente']
    model=Cliente
    
    def get(self,request,*args,**kwargs):
        var_global = globales(request)
        clientes=self.model.objects.filter(id_empresa=var_global['id_empresa']).order_by('-fecha_registro')
        data_json=serialize('json',clientes)
        return JsonResponse({'status':True,'clientes':data_json})   

class ClienteUpdateView(PermissionRequiredMixin,ValidatedStatusEmpresaMixin,UpdateView):
    permission_required=['gestion.change_cliente']
    model = Cliente
    form_class=FormularioCliente

    def post(self, request, *args, **kwargs):
        cliente=get_object_or_404(self.model,id_cliente=kwargs['id_cliente'])
        formulario = self.form_class(request.POST, instance=cliente)       
        if formulario.is_valid():
            formulario.save()
            return JsonResponse({'status':True,'mensaje':'Cliente modificado correctamente'})
        else:
            print(formulario.errors)
            return JsonResponse({'status':False,'mensaje':'Formulario inválido','error':formulario.errors})

class ClienteDeleteView(PermissionRequiredMixin,ValidatedStatusEmpresaMixin,DeleteView):
    permission_required=['gestion.delete_cliente']
    model = Cliente
    def get(self,request,*args,**kwargs):
        cliente=self.model.objects.filter(id_cliente=kwargs['id_cliente'])
        if cliente.exists():
            cliente.delete()
            return JsonResponse({'status':True,'mensaje':'Cliente eliminado correctamente'})
        else:
            return JsonResponse({'status':False,'mensaje':'Cliente seleccionado no existe'})



def consultarCliente(request,dni):
    if request.method=='GET':
        var_global = globales(request)
        cliente= Cliente.objects.filter(id_empresa = var_global['id_empresa'] ,numero_documento_cliente=dni)
        if cliente.exists():
            data_json=serialize('json',cliente)
            return JsonResponse({'status':True,'cliente':data_json})
        else:
            return JsonResponse({'status':False,'cliente':"El cliente no existe"})

##################################################################################################

def obtener_nuevo_numero_historia_mascota(request):
    if request.method == 'GET':
        var_global = globales(request)
        numeroHistoria = Mascota.objects.filter(id_empresa=var_global['id_empresa']).values('numero_historia').last()
        if numeroHistoria is not None:
            nuevoNumero = numeroHistoria['numero_historia'] + 1  
        else:
           nuevoNumero = 1
        return JsonResponse({'nuevoNumero':nuevoNumero})

class MascotaView(PermissionRequiredMixin,ValidatedStatusEmpresaMixin,View):
    permission_required=['gestion.add_mascota']
    model=Mascota
    form_class=FormularioMascota
    template_name= 'mascota.html'

    def get_context_data(self,request, **kwargs):
        context = {}
        context['form']=self.form_class
        var_global = globales(request)
        context['animales']=Animal.objects.filter(id_empresa=var_global['id_empresa'],estado=True).order_by('descripcion')
        return context
    def get(self,request,*args,**kwargs):
        return render(request,self.template_name,self.get_context_data(request))
    
    def post(self,request,*args,**kwargs):
        formulario = self.form_class(request.POST)
        if formulario.is_valid():
            formulario.save()
            return JsonResponse({'status':True,'mensaje':'Mascota agregada correctamente'})          
        else:
            print(formulario.errors)
            return JsonResponse({'status':False,'mensaje':'Formulario inválido','error':formulario.errors})

class MascotaListView(PermissionRequiredMixin,ValidatedStatusEmpresaMixin,ListView):
    permission_required=['gestion.view_mascota']
    def get(self, request,*args,**kwargs):
        var_global = globales(request)
        cursor= connection.cursor()
        sql="SELECT * FROM vw_listar_mascota where id_empresa = %s"
        cursor.execute(sql,[var_global['id_empresa']])
        row = cursor.fetchall()
        cursor.close()
        return JsonResponse({'status':True,'mascotas':row})

class MascotaUpdateView(PermissionRequiredMixin,ValidatedStatusEmpresaMixin,UpdateView):
    permission_required=['gestion.change_mascota']
    model = Mascota
    form_class=FormularioMascota
    
    def post(self,request,*args,**kwargs):
        mascota=get_object_or_404(self.model,id_mascota=kwargs['id'])
        formulario = self.form_class(request.POST,instance=mascota)
        if formulario.is_valid():
            formulario.save()
            return JsonResponse({'status':True,'mensaje':'Mascota modificada correctamente'})  
        else:
            print(formulario.errors)
            return JsonResponse({'status':False,'mensaje':'Formulario inválido','error':formulario.errors})

class MascotaDeleteView(PermissionRequiredMixin,ValidatedStatusEmpresaMixin,DeleteView):
    permission_required=['gestion.delete_mascota']
    model = Mascota

    def get(self,request,*args,**kwargs):
        mascota=self.model.objects.filter(id_mascota=kwargs['id'])
        if mascota.exists():
            mascota.delete()
            return JsonResponse({'status':True,'mensaje':'Mascota eliminada correctamente'})
        else:
            return JsonResponse({'status':False,'mensaje':'Mascota seleccionada no existe'})



def filtrarRazaXanimal(request, animal):
    if request.method== 'GET':
        filter_raza=Raza.objects.filter(id_animal=animal)
        data_json=serialize('json',filter_raza)
        return JsonResponse({'razas':data_json},)

##################################################################################################

class ServicioView(PermissionRequiredMixin,ValidatedStatusEmpresaMixin,View):
    permission_required=['gestion.add_servicio']
    model=Servicio
    form_class=FormularioServicio
    template_name='servicio.html'
    
    def get_context_data(self,request, **kwargs):
        var_global = globales(request)
        context = {}
        context['form']=self.form_class
        context['animales']=Animal.objects.filter(id_empresa=var_global['id_empresa'],estado=True)
        return context
    
    def get(self,request, *args,**kwargs):
        return render(request,self.template_name,self.get_context_data(request))
    
    def post(self,request, *args,**kwargs):
        formulario = self.form_class(request.POST)
        if formulario.is_valid():
            formulario.save()
            return JsonResponse({'status':True,'mensaje':'Servicio agregado correctamente'}) 
        else:
            print(formulario.errors)
            return JsonResponse({'status':False,'mensaje':'Formulario inválido','error':formulario.errors})

class ServicioListView(PermissionRequiredMixin,ValidatedStatusEmpresaMixin,View):
    permission_required=['gestion.view_servicio']
    def get(self,request,*args,**kwargs):
        cursor=connection.cursor()
        sql = "SELECT * FROM vw_listar_servicio where id_sucursal = %s "
        cursor.execute(sql,[request.user.id_sucursal])
        data = cursor.fetchall()
        cursor.close()
        return JsonResponse({'status':True,'servicios':data})       

class ServicioUpdateView(PermissionRequiredMixin,ValidatedStatusEmpresaMixin,UpdateView):
    permission_required=['gestion.change_servicio']
    model = Servicio
    form_class=FormularioServicio

    def post(self,request, *args,**kwargs):
        servicio=get_object_or_404(self.model,id_servicio=kwargs['id'])
        formulario = self.form_class(request.POST,instance=servicio)
        if formulario.is_valid():
            formulario.save()
            return JsonResponse({'status':True,'mensaje':'Servicio modificado correctamente'})  
        else:
            print(formulario.errors)
            return JsonResponse({'status':False,'mensaje':'Formulario inválido','error':formulario.errors})
            
class ServicioDeleteView(PermissionRequiredMixin,ValidatedStatusEmpresaMixin,DeleteView):
    permission_required=['gestion.delete_servicio']
    model = Servicio
    def get(self,request, *args,**kwargs):
        servicio= self.model.objects.filter(id_servicio=kwargs['id'])
        if servicio.exists():
            servicio.delete()
            return JsonResponse({'status':True,'mensaje':'Servicio eliminado correctamente'})
        else:
            return JsonResponse({'status':False,'mensaje':'Servicio seleccionado no existe'})

##################################################################################################
class AtencionTemplateView(PermissionRequiredMixin,ValidatedStatusEmpresaMixin,TemplateView):
    permission_required=['gestion.add_atencion']
    template_name = 'atencion.html'

class AtencionListView(PermissionRequiredMixin,ValidatedStatusEmpresaMixin,ListView):
    permission_required=['gestion.view_atencion']
    def get(self,request,*args,**kwargs):
        id_sucursal=request.user.id_sucursal
        cursor=connection.cursor()
        sql="fn_listar_atencion"
        cursor.callproc(sql,[id_sucursal])
        data= cursor.fetchall()
        cursor.close()
        return JsonResponse({'status':True,'atenciones':data})
    
class RegistrarAtencionView(PermissionRequiredMixin,ValidatedStatusEmpresaMixin,View):
    permission_required=['gestion.add_detalle_atencion']
    model=Atencion
    form_class=FormularioAtencion
    template_name='registrar_atencion.html'

    def get_context_data(self, **kwargs):
        context = {}
        context['form']=self.form_class
        return context
    
    def get(self,request,*args,**kwargs):
        return render(request,self.template_name,self.get_context_data())
    
    def post(self,request,*args,**kwargs):
        new_id=Atencion.objects.values('id_atencion').last()
        if new_id==None:
            new_id=1
        else:
            new_id=new_id['id_atencion']+1
        
        id_sucursal = request.user.id_sucursal
        nuevo_numero_atencion = self.generarNumeroAtencion(id_sucursal)
        formulario= self.form_class({'id_atencion':new_id,'numero_atencion':nuevo_numero_atencion,'id_mascota':request.POST['id_mascota'],
        'monto_total':request.POST['monto_total'], 'estado':False,'id_metodo_pago':request.POST['id_metodo_pago'],'comentario':request.POST['comentario'],
        'usuario':request.POST['usuario'],'id_sucursal':id_sucursal})
        if formulario.is_valid():
            formulario.save()
            detalle,error=self.registrar_detalle_atencion(new_id,request.POST['detalle_atencion'])
            if detalle:
                return JsonResponse({'status':True,'mensaje':'Atención registrada correctamente'})
            else:
                return JsonResponse({'status':False,'mensaje':'Error al registrar detalle de atención','error':error}) 
        else:
            print(formulario.errors)
            return JsonResponse({'status':False,'mensaje':'Formulario inválido','error':formulario.errors})
    
    def registrar_detalle_atencion(self,id, detalle_atencion):
        obj_detalle_atencion=json.loads(detalle_atencion)
        mensaje=""
        for items in obj_detalle_atencion['servicios']:
            formulario=FormularioDetalleAtencion({'id_atencion':id,
                'id_servicio':obj_detalle_atencion['servicios'][items]['id_servicio'], 
                'monto':obj_detalle_atencion['servicios'][items]['monto']
                })
            if formulario.is_valid():
                formulario.save()
            else:
                error=formulario.errors
                return (False,error)
        mensaje="Detalle agregado correctamente" 
        return (True,mensaje)
    
    def generarNumeroAtencion(self,id_sucursal):
        ultimo_numero = self.model.objects.filter(id_sucursal=id_sucursal).values('numero_atencion').last()
        if ultimo_numero is not None:
            return ultimo_numero['numero_atencion'] + 1
        else:
            return 1

def consultar_detalle_atencion(request, atencion):
    if request.method=='GET':
        cursor=connection.cursor()
        sql="fn_consultar_detalle_atencion"
        cursor.callproc(sql,[atencion])
        data= cursor.fetchall()
        cursor.close()
        return JsonResponse({'status':True,'detalle':data})
    
def finalizar_atencion(request,atencion):
    if request.method=='GET':
        atenc=Atencion.objects.filter(id_atencion=atencion)
        for a in atenc:
            a.estado=True
            a.save()
        return JsonResponse({'status':True,'mensaje':"Atención finalizada"})

def buscar_mascota(request,numero):
    if request.method=='GET':
        var_global= globales(request)
        mascota=Mascota.objects.filter(numero_historia=numero,id_empresa=var_global['id_empresa'])
        if mascota.exists():
            for m in mascota:
                id_animal_v=m.id_raza.id_animal_id
                id_cliente=m.id_cliente_id
            data_json=serialize('json',mascota)
            data_json_servicio=serialize('json',Servicio.objects.filter(Q(id_animal=id_animal_v) | Q(id_animal=0), estado = True, id_sucursal = request.user.id_sucursal))
            cliente=Cliente.objects.filter(id_cliente=id_cliente)
            data_json_cliente=serialize('json',cliente)
            return JsonResponse({'status':True,'mascota':data_json,
                                'servicios':data_json_servicio,'cliente':data_json_cliente})
        else:
            return JsonResponse({'status':False,'mensaje':'Historia ingresada no existe'})

def ultimas_atenciones_mascota(request, historia):
    if request.method=='GET':
        cursor=connection.cursor()
        sql="fn_ultimas_atenciones_mascota"
        cursor.callproc(sql,[historia])
        servicios=cursor.fetchall()
        if len(servicios)>0:
            my_list=[]
            for s in servicios:
                my_dict2={}
                sql="fn_utlima_atencion_servicio"
                cursor.callproc(sql,[historia,s[0]])
                ultimas_atenciones=cursor.fetchone()
                my_dict2['descripcion']=ultimas_atenciones[0]
                my_dict2['fecha']=ultimas_atenciones[1]
                my_list.append(my_dict2)
            return JsonResponse({'status':True,'servicios':my_list})
        return JsonResponse({'status':False,'servicios':'Sin servicios'})

##################################################################################################

class RecordatorioView(PermissionRequiredMixin,ValidatedStatusEmpresaMixin,View):
    permission_required=['gestion.add_recordatorio']
    model=Recordatorio
    form_class=FormularioRecordatorio
    template_name='recordatorio.html'
    
    def get_context_data(self, **kwargs):
        context = {}
        context['form']=self.form_class
        return context
    
    def get(self, request,*args,**kwargs):
        return render(request,self.template_name,self.get_context_data())
    
    def post(self, request,*args,**kwargs):
        formulario = self.form_class(request.POST)
        if formulario.is_valid():
            formulario.save()
            return JsonResponse({'status':True,'mensaje':'Recordatorio registrado correctamente'})
        else:
            print(formulario.errors)
            return JsonResponse({'status':False,'mensaje':'Formulario inválido','error':formulario.errors})

class RecordatorioListView(PermissionRequiredMixin,ValidatedStatusEmpresaMixin,ListView):
    permission_required=['gestion.view_recordatorio']
    def get(self,request,*args,**kwargs):
        var_global = globales(request)
        cursor=connection.cursor()
        sql="SELECT * FROM vw_listar_recordatorio WHERE id_empresa = %s"
        cursor.execute(sql,[var_global['id_empresa']])
        data=cursor.fetchall()
        return JsonResponse({'status':True,'recordatorios':data})

class RecordatorioUpdateView(PermissionRequiredMixin,ValidatedStatusEmpresaMixin,UpdateView):
    permission_required=['gestion.change_recordatorio']
    model = Recordatorio
    form_class=FormularioRecordatorio

    def post(self,request,*args,**kwargs):
        recordatorio=get_object_or_404(self.model,id_recordatorio=kwargs['id'])
        formulario=self.form_class(request.POST,instance=recordatorio)
        if formulario.is_valid():
            formulario.save()
            return JsonResponse({'status':True,'mensaje':'Recordatorio modificado correctamente'})
        else:
            print(formulario.errors)
            return JsonResponse({'status':False,'mensaje':'Formulario inválido','error':formulario.errors})

class RecordatorioDeleteView(PermissionRequiredMixin,ValidatedStatusEmpresaMixin,DeleteView):
    permission_required=['gestion.delete_recordatorio']
    model = Recordatorio
    
    def get(self,request,*args,**kwargs):
        recordatorio=self.model.objects.filter(id_recordatorio=kwargs['id'])
        if recordatorio.exists():
            recordatorio.delete()
            return JsonResponse({'status':True,'mensaje':'Recordatorio eliminado correctamente'})
        else:
            return JsonResponse({'status':False,'mensaje':'Recordatorio seleccionado no existe'})

def buscar_recordatorio_mascota(request, historia,date):
    if request.method=='GET':
        var_global = globales(request)
        cursor=connection.cursor()
        sql="fn_buscar_recordatorio_mascota"
        cursor.callproc(sql,[historia,date,var_global['id_empresa']])
        data=cursor.fetchall()
        cursor.close()
        if len(data)>0:
            return JsonResponse({'status':True,'recordatorio':data,'mensaje':"Existen servicios agendados para hoy"})
        return JsonResponse({'status':False,'mensaje':'Sin recordatorios para hoy'})

def marcar_recordatorio_mascota(request,recordatorio):
    if request.method=='GET':
        recordatorio=Recordatorio.objects.filter(id_recordatorio=recordatorio)
        for r in recordatorio:
            r.estado=False
            r.save()       
        return JsonResponse({'status':True,'mensaje':"Recordatorio marcado"})

######################################REPORTES!!!############################################################

def test_reportbro(request):
    return render(request,'ReportBro/baseReportbro.html')

def exportMascotaPDF(request):
    cursor= connection.cursor()
    sql="SELECT * FROM vw_exportar_reporte_lista_mascota WHERE id_sucursal = %s"
    cursor.execute(sql,[request.user.id_sucursal])
    mascotas=cursor.fetchall()
    cursor.close()
    mascota_list=[]
    today=datetime.today().strftime('%Y-%m-%d')
    for m in mascotas:
        mascota_list.append({
            'historia':m[0],
            'animal':m[1],
            'raza':m[2],
            'nombre':m[3],
            'edad':m[4],
            'sexo':m[5],
            'color':m[6],
            'peso':m[7],
            'propietario':m[8],
        })

    sucursal = Sucursal.objects.filter(id_sucursal=request.user.id_sucursal).values('razon_social')
    data={
        'mascotas':mascota_list,
        'fecha_solicitud':today,
        'sucursal': sucursal[0]['razon_social']
    }
    return report(request, 'mascota',data)

def export_historial_mascota(request, id_mascota):
    nombre=Mascota.objects.filter(id_mascota=id_mascota).values('nombre')
    for n in nombre:
        nombre_mascota=n['nombre']
    cursor=connection.cursor()
    sql="fn_historal_atencion_mascota"
    cursor.callproc(sql,[id_mascota])
    historial=cursor.fetchall()
    print(historial)
    cursor.close()
    
    historial_list=[]
    today=datetime.today().strftime('%Y-%m-%d')
    for h in historial:
        historial_list.append({
            #'id_atencion':h[0],
            #'mascota':h[1],         
            'servicio':h[2],
            'comentario':h[3],
            'monto':h[4],
            'entrada':h[5],
            'salida':h[6],
        })

    context={
        'historial':historial_list,
        'mascota':nombre_mascota,
        'fecha_solicitud':today
    }
    
    return report(request, 'historial_mascota',context)

class ExportAtencionReport(ValidatedStatusEmpresaMixin,ListView):

    def get(self, request,*args,**kwargs):
        inicio=kwargs['inicio']
        fin=kwargs['fin']
        with connection.cursor() as cursor:
            sql="fn_exportar_reporte_atenciones"
            cursor.callproc(sql,[request.user.id_sucursal,inicio,fin])
            atenciones=cursor.fetchall()
            cursor.close()
        today=datetime.today().strftime('%Y-%m-%d')
        lista_atenciones=[]
        for a in atenciones:
            dic={}
            dic['id_atencion']=a[0]
            dic['mascota']=a[1]
            dic['historia']=a[2]
            dic['total']=a[3]
            dic['entrada']=a[4]
            dic['salida']=a[5]
            dic['estado']=a[6]
            dic['servicio']=a[7]
            dic['monto']=a[8]
            lista_atenciones.append(dic)
        
        sucursal = Sucursal.objects.filter(id_sucursal=request.user.id_sucursal).values('razon_social')
        context={'atenciones':lista_atenciones,
                'inicio':inicio,
                'fin':fin,
                'fecha_solicitud':today,
                'sucursal':sucursal[0]['razon_social']
                }
        return report(request, 'atenciones',context)    

class ExportClientesReport(ValidatedStatusEmpresaMixin,ListView):
    def get(self,request,*args,**kwards):
        clientes=Cliente.objects.filter(id_sucursal=request.user.id_sucursal)
        today=datetime.today().strftime('%Y-%m-%d')
        lista_clientes=[]
        for cl in clientes:
            estado='Activo' if cl.estado==True else 'Inactivo'
            lista_clientes.append({
                'numero_documento_cliente':cl.numero_documento_cliente,
                'nombre':cl.nombre,
                'apellido':cl.apellido,
                'domicilio':cl.domicilio,
                'celular':cl.celular,
                'correo':cl.correo,
                'fecha_registro':cl.fecha_registro,
                'estado':estado
            })

        sucursal = Sucursal.objects.filter(id_sucursal=request.user.id_sucursal).values('razon_social')
        context={'clientes':lista_clientes,'fecha_solicitud':today,'sucursal':sucursal[0]['razon_social']}
        return report(request, 'clientes',context)

class ExportReportServicios(ValidatedStatusEmpresaMixin,ListView):
    def get(self,request,*args,**kwards):
        with connection.cursor() as cursor:
            sql="SELECT * FROM vw_exportar_reporte_servicio WHERE id_sucursal = %s"
            cursor.execute(sql,[request.user.id_sucursal])
            servicios=cursor.fetchall()
            cursor.close()
       
        lista_servicios=[]
        for sr in servicios:
            lista_servicios.append({
                'animal':sr[0],
                'servicio':sr[1],
                'precio':sr[2],
                'estado':sr[3]
            })
        sucursal = Sucursal.objects.filter(id_sucursal=request.user.id_sucursal).values('razon_social')
        context={'servicios':lista_servicios,'sucursal':sucursal[0]['razon_social']}
        return report(request,'servicios',context)



class EstadisticaTemplateView(ValidatedStatusEmpresaMixin,View):
    template_name = "estadistica.html"
    model=Sucursal

    def get(self,request,*args,**kwargs):
        id_empresa= globales(request)['id_empresa']
        context = {}
        context['sucursales'] = self.model.objects.filter(id_empresa=id_empresa,estado=True)
        return render(request,self.template_name,context)
    

def ganancia_mensual_ventas_sucursal(request,id_sucursal):
    year=datetime.today().strftime('%Y')
    cursor= connection.cursor()
    sql="fn_ganancia_mensual_ventas_sucursal"
    cursor.callproc(sql,[year,id_sucursal])
    gan_mensuales = cursor.fetchall()
    cursor.close()
    meses=[]
    monto=[]
    meses_labels={1:'Enero', 2:'Febrero', 3:'Marzo', 4:'Abril', 5:'Mayo', 6:'Junio', 7:'Julio', 8:'Agosto',
        9:'Setiembre', 10:'Octubre', 11:'Noviembre', 12:'Diciembre'}
    meses_labels_ok=[]
    for c in gan_mensuales:
        meses.append(c[0])
        monto.append(c[1])
    lista_meses=list(map(int,meses))
    lista_monto=list(map(float,monto))
    for m in lista_meses:
        if (m in meses_labels):
            meses_labels_ok.append(meses_labels[m])
    
    return JsonResponse({'status':True,'meses':meses_labels_ok,'monto':lista_monto})

def mejores_productos_ventas_sucursal(request,id_sucursal):
    mes_año=datetime.today().strftime('%Y-%m')
    cursor= connection.cursor()
    sql="fn_mejores_productos_ventas"
    cursor.callproc(sql,[mes_año,id_sucursal])
    mejores_productos=cursor.fetchall()
    cursor.close()
    mejor_pro_desc=[]
    mejor_pro_cant=[]
    for s in mejores_productos:
        mejor_pro_desc.append(s[0])
    for cant in mejores_productos:
        mejor_pro_cant.append(cant[1])
        
    return JsonResponse({'status':True,'producto':mejor_pro_desc,'cantidad':mejor_pro_cant})

def ganancia_mensual_antencion_sucursal(request,id_sucursal):
    year=datetime.today().strftime('%Y')
    cursor= connection.cursor()
    sql="fn_ganancia_mensual_antencion_sucursal"
    cursor.callproc(sql,[year,id_sucursal])
    gan_mensuales = cursor.fetchall()
    cursor.close()
    meses=[]
    monto=[]
    meses_labels={1:'Enero', 2:'Febrero', 3:'Marzo', 4:'Abril', 5:'Mayo', 6:'Junio', 7:'Julio', 8:'Agosto',
        9:'Setiembre', 10:'Octubre', 11:'Noviembre', 12:'Diciembre'}
    meses_labels_ok=[]
    for c in gan_mensuales:
        meses.append(c[0])
        monto.append(c[1])
    lista_meses=list(map(int,meses))
    lista_monto=list(map(float,monto))
    for m in lista_meses:
        if (m in meses_labels):
            meses_labels_ok.append(meses_labels[m])
    
    datos={'mes':meses_labels_ok,
            'monto':lista_monto,}
    
    return JsonResponse({'status':True,'mes':datos['mes'],'monto':datos['monto']})

def servicio_solicitados_sucursal(request,id_sucursal):
    mes_año=datetime.today().strftime('%Y-%m')
    cursor= connection.cursor()
    sql="fn_servicios_mas_solicitados_sucursal"
    cursor.callproc(sql,[mes_año,id_sucursal])
    mejores_servicios=cursor.fetchall()
    cursor.close()
    mejor_serv_desc=[]
    cant_mejor_serv_desc=[]
    for s in mejores_servicios:
        mejor_serv_desc.append(s[0])
    for cant in mejores_servicios:
        cant_mejor_serv_desc.append(cant[1])
    
    data={'mejores_servicios_desc':mejor_serv_desc,
        'mejores_servicios_cant':cant_mejor_serv_desc,}
    
    return JsonResponse({'status':True,'mejores_servicios_desc':data['mejores_servicios_desc'],'mejores_servicios_cant':data['mejores_servicios_cant']})