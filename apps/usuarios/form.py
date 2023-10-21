from django import forms
from django.core.exceptions import ValidationError
from django.forms import ModelForm
from .models import *
from apps.empresa.models import Sucursal

class FormularioUsuario(ModelForm):
    '''id_tipo_usuario=forms.ModelChoiceField(
        queryset=TipoUsuario.objects.filter(estado=True),
        widget=forms.Select(attrs={'class':'form-select','required':'required'
        })
    )'''

    password1= forms.CharField(widget=forms.PasswordInput(
        attrs={
            "class":"form-control",
            'id':'password1',
            'required':'required'
        }
    ))
    password2= forms.CharField(widget=forms.PasswordInput(
        attrs={
            'class':'form-control',
            'id':'password2',
            'required':'required'
        }
    ))
    '''def __init__(self,*args,**kwargs):
        super (FormularioUsuario,self ).__init__(*args,**kwargs)
        self.fields['id_tipo_usuario']= TipoUsuario.objects.filter(estado=True)'''



    class Meta:
        model=Usuario
        fields= ['username','first_name','last_name','email','is_active','id_sucursal']
        widgets={
            'username':forms.TextInput(attrs={'class':'form-control','required':True,}),
            'first_name':forms.TextInput(attrs={'class':'form-control','required':True,'onkeypress':'return soloLetras(event);'}),
            'last_name':forms.TextInput(attrs={'class':'form-control','required':True,'onkeypress':'return soloLetras(event);'}),
            'email':forms.EmailInput(attrs={'class':'form-control','required':True,}),
            'is_active':forms.CheckboxInput(attrs={'class':'form-check-input','type':'checkbox',}),
            #'id_sucursal':forms.Select(attrs={'class':'form-select'}),
            #'id_tipo_usuario':forms.Select(attrs={'class':'form-select'})
            #'usuario_administrador':forms.TextInput(attrs={'class':'form-control'}),
        }
    
    def clean_username(self):
        username=self.cleaned_data.get('username')
        existe=Usuario.objects.filter(username=username)
        if not existe.exists():
            return username
        raise forms.ValidationError('El usuario ingresado ya existe, pruebe con otro')

    def clean_email(self):
        email=self.cleaned_data.get('email')
        existe=Usuario.objects.filter(email__iexact=email)
        # if not existe.exists():  
        #     return email
        # raise forms.ValidationError('El correo ingresado ya existe, pruebe con otro')
    
        if existe.exists():
            if self.instance.id:
                for x in existe:
                    id=x.id
                if self.cleaned_data.get('id',self.instance.id)==id:
                    return email
                else:
                    raise forms.ValidationError('El correo ingresado ya se encuentra en uso, pruebe con otro')
            else:
                raise forms.ValidationError('El correo ingresado ya se encuentra en uso, pruebe con otro')
        else:
            return email
        

    def clean_password2(self):
        password1=self.cleaned_data.get('password1')
        password2=self.cleaned_data.get('password2')
        if password1 != password2:
            raise forms.ValidationError('Contraseñas no coinciden')
        return password2
    
    def save(self, commit=True):
        user=super().save(commit=False)
        user.set_password(self.cleaned_data['password1'])
        if commit:
            user.save()
        return user


class FormularioUsuarioUpdate(ModelForm):
    class Meta:
        model=Usuario
        fields=['first_name','last_name','email','is_active','id_sucursal']
        widgets={
            #'username':forms.TextInput(attrs={'class':'form-control'}),
            'first_name':forms.TextInput(attrs={'class':'form-control','id':'id_first_name_update','required':True,'onkeypress':'return soloLetras(event);'}),
            'last_name':forms.TextInput(attrs={'class':'form-control','id':'id_last_name_update','required':True,'onkeypress':'return soloLetras(event);'}),
            'email':forms.EmailInput(attrs={'class':'form-control','id':'id_email_update','required':True}),
            'is_active':forms.CheckboxInput(attrs={'class':'form-check-input','type':'checkbox','id':'id_is_active_update'}),
            #'id_sucursal':forms.Select(attrs={'class':'form-select'}),
        }
     

    def clean_email(self):
        email=self.cleaned_data.get('email')
        existe=Usuario.objects.filter(email__iexact=email)
        # if existe.exists():  
        #     for x in existe:
        #         id_u=x.id
        #     if self.cleaned_data.get('id',self.instance.id)==id_u:
        #         return email
        #     else:
        #         raise forms.ValidationError('El correo ingresado ya existe, pruebe con otro')
        # return email
        if existe.exists():
            if self.instance.id:
                for x in existe:
                    id=x.id
                if self.cleaned_data.get('id',self.instance.id)==id:
                    return email
                else:
                    raise forms.ValidationError('El correo ingresado ya se encuentra en uso, pruebe con otro')
            else:
                raise forms.ValidationError('El correo ingresado ya se encuentra en uso, pruebe con otro')
        else:
            return email

    def save(self, commit=True):
        user=super().save(commit=False)
        if commit:
            user.save()
        return user
