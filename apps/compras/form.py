from django import forms
from apps.compras.models import *
from veterinaria.settings import base

class ProveedorForm(forms.ModelForm):
    class Meta:
        model = Proveedor
        fields = '__all__'
        widgets={
            'id_tipo_documento':forms.Select(attrs={'class':'form-select'}),
            'numero_documento_proveedor':forms.TextInput(attrs={'class':'form-control','onkeypress':'return soloNumeros(event);'}),
            'razon_social':forms.TextInput(attrs={'class':'form-control'}),
            'telefono_proveedor':forms.TextInput(attrs={'class':'form-control','onkeypress':'return soloNumeros(event);'}),
            'telefono_contacto':forms.TextInput(attrs={'class':'form-control','onkeypress':'return soloNumeros(event);'}),
            'direccion':forms.TextInput(attrs={'class':'form-control'}),
            'estado':forms.CheckboxInput(attrs={'class':'form-check-input','type':'checkbox'}),
        }
    
    def clean_numero_documento_proveedor(self):
        numero=self.cleaned_data.get('numero_documento_proveedor')
        tipo_documento_proveedor=self.cleaned_data.get('id_tipo_documento')
        id_empresa=self.cleaned_data.get('id_empresa')
        existe=Proveedor.objects.filter(id_tipo_documento=tipo_documento_proveedor,numero_documento_proveedor=numero,id_empresa=id_empresa)
        if existe.exists():
            if self.instance.id_proveedor:
                for e in existe:
                    id=e.id_proveedor
                if self.cleaned_data.get('id_proveedor',self.instance.id_proveedor)==id:
                    return numero
                raise forms.ValidationError('El número de documento ingresado ya existe')
            else:
                raise forms.ValidationError('El número de documento ingresado ya existe')
        else:
            return numero

class CompraForm(forms.ModelForm):
    
    def __init__(self,*args,**kwargs):
        super (CompraForm,self ).__init__(*args,**kwargs)
        self.fields['id_proveedor'].queryset = Proveedor.objects.filter(id_empresa=base.ID_EMPRESA_VARIABLE_GLOBAL,estado=True).order_by('razon_social')
        self.fields['id_tipo_comprobante'].queryset = TipoComprobante.objects.filter(id_empresa=base.ID_EMPRESA_VARIABLE_GLOBAL,estado=True).order_by('descripcion')

    class Meta:
        model = Compra
        fields = '__all__'
        widgets={
            'id_proveedor':forms.Select(attrs={'class':'form-select'}),
            'id_tipo_comprobante':forms.Select(attrs={'class':'form-select'}),
            'serie':forms.TextInput(attrs={'class':'form-control'}),
            'numero':forms.TextInput(attrs={'class':'form-control'}),
            'impuesto':forms.NumberInput(attrs={'class':'form-control','onkeypress':'return soloNumeros(event);'}),
            'monto_total':forms.NumberInput(attrs={'class':'form-control','onkeypress':'return soloNumeros(event);'}),
            'fecha':forms.TextInput(attrs={'class':'form-control','type':'date'}),
        }

class DetalleCompraForm(forms.ModelForm):
    class Meta:
        model = DetalleCompra
        fields ='__all__'


