from django import forms
from apps.ventas.models import *
from veterinaria.settings import base

class TipoComprobanteForm(forms.ModelForm):
    class Meta:
        model = TipoComprobante
        fields = '__all__'
        widgets={
            'descripcion':forms.TextInput(attrs={'class':'form-control'}),
            'estado':forms.CheckboxInput(attrs={'class':'form-check-input','type':'checkbox'}),
        }
    
    def clean_descripcion(self):
        id_empresa = self.cleaned_data.get('id_empresa')
        descripcion = self.cleaned_data.get('descripcion')
        existe = TipoComprobante.objects.filter(id_empresa = id_empresa,descripcion__iexact=descripcion)
        if existe.exists():
            if self.instance.id_tipo_comprobante:
                for x in existe:
                    id=x.id_tipo_comprobante
                if self.cleaned_data.get('id_tipo_comprobante',self.instance.id_tipo_comprobante)==id:
                    return descripcion
                else:
                    raise forms.ValidationError('Los datos de comprobante ingresados ya existe')
            else:
                raise forms.ValidationError('Los datos de comprobante ingresados ya existe')
        else:
            return descripcion


class VentaForm(forms.ModelForm):
    '''numero_documento_cliente=forms.CharField(widget=forms.TextInput(attrs={
        'class':'form-control',
        'onkeypress':'return soloNumeros(event);'
        }))'''
    def __init__(self,*args,**kwargs):
        super (VentaForm,self ).__init__(*args,**kwargs)
        self.fields['id_metodo_pago'].queryset = MetodoPago.objects.filter(estado=True).order_by('descripcion')
        self.fields['id_tipo_comprobante'].queryset = TipoComprobante.objects.filter(id_empresa=base.ID_EMPRESA_VARIABLE_GLOBAL,estado=True).order_by('descripcion')
    class Meta:

        model = Venta
        fields = '__all__'
        widgets={
            'id_tipo_comprobante':forms.Select(attrs={'class':'form-select form-select-sm'}),
            'id_metodo_pago':forms.Select(attrs={'class':'form-select form-select-sm'}),
            'fecha':forms.DateInput(attrs={'class':'form-control','readonly':True}),
            #'monto_total':forms.NumberInput(attrs={'class':'form-control','onkeypress':'return soloNumeros(event);'}),
            'id_cliente':forms.TextInput(attrs={'class':'form-control form-control-sm','onkeypress':'return soloNumeros(event);'}),
        }

class DetalleVentaForm(forms.ModelForm):

    class Meta:
        model = DetalleVenta
        fields = '__all__'
        widgets={
            #'subtotal':forms.NumberInput(attrs={'class':'form-control','onkeypress':'return soloNumeros(event);'}),
        }

class CorrelativoForm(forms.ModelForm):
    def __init__(self,*args,**kwargs):
        super (CorrelativoForm,self ).__init__(*args,**kwargs)
        self.fields['id_tipo_comprobante'].queryset = TipoComprobante.objects.filter(id_empresa=base.ID_EMPRESA_VARIABLE_GLOBAL,estado=True).order_by('descripcion')
    class Meta:
        model = Correlativo
        fields = '__all__'
        widgets={
            'id_tipo_comprobante':forms.Select(attrs={'class':'form-select'}),
            'serie':forms.TextInput(attrs={'class':'form-control'}),
            'primer_numero':forms.NumberInput(attrs={'class':'form-control','onkeypress':'return soloNumeros(event);'}),
            'ultimo_numero_registrado':forms.NumberInput(attrs={'class':'form-control','onkeypress':'return soloNumeros(event);'}),
            'max_correlativo':forms.NumberInput(attrs={'class':'form-control','onkeypress':'return soloNumeros(event);'}),
        }
    
    def clean_serie(self):
        id_tipo_comprobante = self.cleaned_data.get('id_tipo_comprobante')
        id_empresa = self.cleaned_data.get('id_empresa')
        serie = self.cleaned_data.get('serie')
        
        existe=Correlativo.objects.filter(id_tipo_comprobante=id_tipo_comprobante,id_empresa=id_empresa,serie=serie)
        if existe.exists():
            if self.instance.id_correlativo:
                for x in existe:
                    id=x.id_correlativo
                if self.cleaned_data.get('id_correlativo',self.instance.id_correlativo)==id:
                    return serie
                else:
                    raise forms.ValidationError('Los datos de correlativo ingresados ya existe')
            else:
                raise forms.ValidationError('Los datos de correlativo ingresados ya existe')
        else:
            return serie

    def clean_ultimo_numero_registrado(self):
        if self.instance.id_correlativo:
            ultimo_numero_registrado=self.cleaned_data.get('ultimo_numero_registrado')
            if ultimo_numero_registrado is None:
                return ultimo_numero_registrado
            serie = Correlativo.objects.filter(id_correlativo=self.instance.id_correlativo).values('serie').last()
            ultima_venta = Venta.objects.filter(serie=serie['serie']).values('numero').last()
            if ultimo_numero_registrado < ultima_venta['numero']:
                raise forms.ValidationError('El último registro ingresado es menor al actual, ingrese uno mayor')
            return ultimo_numero_registrado
    

