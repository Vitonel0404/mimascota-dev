from django import forms
from django.core.exceptions import ValidationError
from django.forms import ModelForm
from apps.gestion.models import *
from veterinaria.settings import base

import datetime
from datetime import date

class DateInput(forms.DateInput):
    input_type='date'



class FormularioAnimal(ModelForm):
    class Meta:
        model=Animal
        fields='__all__'
        widgets={
            'descripcion':forms.TextInput(attrs={'class':'form-control','onkeypress':'return soloLetras(event);'}),
            'estado':forms.CheckboxInput(attrs={'class':'form-check-input','type':'checkbox'})
        }

    def clean_descripcion(self):
        descripcion = self.cleaned_data.get('descripcion')
        id_empresa = self.cleaned_data.get('id_empresa')
        existe=Animal.objects.filter(descripcion__iexact=descripcion, id_empresa=id_empresa)
        if existe.exists():
            if self.instance.id_animal:
                for x in existe:
                    id=x.id_animal
                if self.cleaned_data.get('id_animal',self.instance.id_animal)==id:
                    return descripcion
                else:
                    raise forms.ValidationError('Los datos ingresados ya existen. Ingrese otros.')
            else:
                raise forms.ValidationError('Los datos ingresados ya existen. Ingrese otros.')
        else:
            return descripcion 

class FormularioRaza(ModelForm):
    def __init__(self,*args,**kwargs):
        super (FormularioRaza,self ).__init__(*args,**kwargs)
        self.fields['id_animal'].queryset = Animal.objects.filter(id_empresa=base.ID_EMPRESA_VARIABLE_GLOBAL,estado=True).order_by('descripcion')
    class Meta:
        model=Raza
        fields='__all__'
        widgets={
            'descripcion':forms.TextInput(attrs={'class':'form-control','onkeypress':'return soloLetras(event);'}),
            'id_animal':forms.Select(attrs={'class':'form-select'}),
        }

    def clean_descripcion(self):
        id_animal=self.cleaned_data.get('id_animal')
        descripcion=self.cleaned_data.get('descripcion')
        existe=Raza.objects.filter(id_animal=id_animal,descripcion__iexact=descripcion,id_empresa=base.ID_EMPRESA_VARIABLE_GLOBAL)
        if existe.exists():
            if self.instance.id_raza:
                for x in existe:
                    id=x.id_raza
                if self.cleaned_data.get('id_raza',self.instance.id_raza)==id:
                    return descripcion
                else:
                    raise forms.ValidationError('Los datos ingresados ya existen. Ingrese otros.')
            else:
                raise forms.ValidationError('Los datos ingresados ya existen. Ingrese otros.')
        else:
            return descripcion 

class FormularioCliente(ModelForm):
    
    class Meta:
        model=Cliente
        fields='__all__'
        widgets={
            'id_tipo_documento':forms.Select(attrs={'class':'form-select'}),
            'numero_documento_cliente':forms.TextInput(attrs={'class':'form-control','onkeypress':'return soloNumeros(event);'}),
            'nombre':forms.TextInput(attrs={'class':'form-control','onkeypress':'return soloLetras(event);'}),
            'apellido':forms.TextInput(attrs={'class':'form-control','onkeypress':'return soloLetras(event);'}),
            'domicilio':forms.TextInput(attrs={'class':'form-control'}),
            'celular':forms.TextInput(attrs={'class':'form-control','onkeypress':'return soloNumeros(event);'}),
            'correo':forms.EmailInput(attrs={'class':'form-control'}),
            'fecha_registro':DateInput(attrs={'class':'form-control'}),
            'estado':forms.CheckboxInput(attrs={'class':'form-check-input','type':'checkbox'}),
        }
    def clean_numero_documento_cliente(self):
        numero=self.cleaned_data.get('numero_documento_cliente')
        tipo=self.cleaned_data.get('id_tipo_documento')
        id_empresa=self.cleaned_data.get('id_empresa')
        existe=Cliente.objects.filter(id_tipo_documento=tipo,numero_documento_cliente=numero, id_empresa=id_empresa)
        if existe.exists():
            if self.instance.id_cliente:
                for x in existe:
                    id=x.id_cliente
                if self.cleaned_data.get('id_cliente',self.instance.id_cliente)==id:
                    return numero
                else:
                    raise forms.ValidationError('El número de documento ingresado ya existe')
            else:
                raise forms.ValidationError('El número de documento ingresado ya existe')
        else:
            return numero 
    
class FormularioMascota(ModelForm):
    def __init__(self,*args,**kwargs):
        super (FormularioMascota,self ).__init__(*args,**kwargs)
        self.fields['id_raza'].queryset = Raza.objects.filter(id_empresa=base.ID_EMPRESA_VARIABLE_GLOBAL).order_by('descripcion')
    
    class Meta:
        model=Mascota
        fields='__all__'
        widgets={
            'id_cliente':forms.TextInput(attrs={'class':'form-control','onkeypress':'return soloNumeros(event);'}),
            'nombre':forms.TextInput(attrs={'class':'form-control','onkeypress':'return soloLetras(event);'}),
            'edad':forms.NumberInput(attrs={'class':'form-control','onkeypress':'return soloNumeros(event);'}),
            'peso':forms.NumberInput(attrs={'class':'form-control','onkeypress':'return soloNumeros(event);'}),
            'sexo':forms.Select(attrs={'class':'form-select'}),
            'id_raza':forms.Select(attrs={'class':'form-select'}),
            'color':forms.TextInput(attrs={'class':'form-control','onkeypress':'return soloLetras(event);'}),
            'estado':forms.CheckboxInput(attrs={'class':'form-check-input','type':'checkbox'}),
        }


    def clean_nombre(self):
        nombre= self.cleaned_data.get('nombre')
        if nombre.strip()=='':
            raise ValidationError("Debe de ingresar un nombre")
        return nombre
    
    def clean_numero_historia(self):
        id_empresa=self.cleaned_data.get('id_empresa')
        numero_historia=self.cleaned_data.get('numero_historia')
        existe = Mascota.objects.filter(numero_historia=numero_historia,id_empresa=id_empresa)

        if existe.exists():
            if self.instance.id_mascota:
                for x in existe:
                    id=x.id_mascota
                if self.cleaned_data.get('id_mascota',self.instance.id_mascota)==id:
                    return numero_historia
                else:
                    raise forms.ValidationError('Error: El número de historia recibido ya existe')
            else:
                raise forms.ValidationError('Error: El número de historia genereado ya existe')
        else:
            return numero_historia

    
class FormularioServicio(ModelForm):
    class Meta:
        model=Servicio
        fields='__all__'

        widgets={
            #'id_animal':forms.Select(attrs={'class':'form-select'}),
            'descripcion':forms.TextInput(attrs={'class':'form-control','onkeypress':'return soloLetras(event);'}),
            'precio':forms.NumberInput(attrs={'class':'form-control','onkeypress':'return soloNumeros(event);'}), 
            'estado':forms.CheckboxInput(attrs={'class':'form-check-input','type':'checkbox'})
        }
    def clean_descripcion(self):
        descripcion=self.cleaned_data.get('descripcion')
        animal=self.cleaned_data.get('id_animal')
        id_sucursal=self.cleaned_data.get('id_sucursal')
        servicio=Servicio.objects.filter(descripcion__iexact=descripcion,id_animal=animal,id_sucursal=id_sucursal)
        if servicio.exists():
            if self.instance.id_servicio:
                for s in servicio:
                    id=s.id_servicio
                if self.cleaned_data.get('id_servicio',self.instance.id_servicio)==id:
                    return descripcion
                else:
                    raise forms.ValidationError('El servicio ingresado ya existe')
            else:
                raise forms.ValidationError('El servicio ingresado ya existe')
        else:
            return descripcion

class FormularioAtencion(ModelForm):
    def __init__(self,*args,**kwargs):
        super (FormularioAtencion,self ).__init__(*args,**kwargs)
        self.fields['id_metodo_pago'].queryset = MetodoPago.objects.filter(estado=True).order_by('descripcion')
    class Meta:
        model=Atencion
        fields='__all__'
        widgets={
            'numero_historia':forms.TextInput(attrs={'class':'form-control','onkeypress':'return soloNumeros(event);'}),
        }

class FormularioDetalleAtencion(ModelForm):
    class Meta:
        model=Detalle_Atencion
        fields=['id_atencion','id_servicio','monto']

class FormularioRecordatorio(ModelForm):
    class Meta:
        model=Recordatorio
        fields='__all__'
        widgets={
            'numero_historia':forms.TextInput(attrs={'class':'form-control','onkeypress':'return soloNumeros(event);'}),

        }

        
        