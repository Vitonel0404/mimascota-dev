from django import forms
from apps.productos.models import *
from veterinaria.settings import base


class CategoriaForm(forms.ModelForm):
    class Meta:
        model = Categoria
        fields = '__all__'
        widgets={
            #'id_animal':forms.Select(attrs={'class':'form-select'}),
            'descripcion':forms.TextInput(attrs={'class':'form-control','onkeypress':'return soloLetras(event);'}),
            'estado':forms.CheckboxInput(attrs={'class':'form-check-input','type':'checkbox'}),
        }
    
    def clean_descripcion(self):
        descripcion=self.cleaned_data.get('descripcion')
        id_empresa=self.cleaned_data.get('id_empresa')
        existe=Categoria.objects.filter(id_empresa=id_empresa,descripcion__iexact=descripcion)
        if existe.exists():
            if self.instance.id_categoria:
                for x in existe:
                    id=x.id_categoria
                if self.cleaned_data.get('id_categoria',self.instance.id_categoria)==id:
                    return descripcion
                else:
                    raise forms.ValidationError('La descripcion ingresada ya existe.')
            else:
                raise forms.ValidationError('La descripcion ingresada ya existe.')
        else:
            return descripcion

class ProductoForm(forms.ModelForm):
    def __init__(self,*args,**kwargs):
        super (ProductoForm,self ).__init__(*args,**kwargs)
        print(base.ID_EMPRESA_VARIABLE_GLOBAL)
        self.fields['id_categoria'].queryset = Categoria.objects.filter(id_empresa=base.ID_EMPRESA_VARIABLE_GLOBAL,estado=True).order_by('descripcion')
        self.fields['id_unidad_medida'].queryset = UnidadMedida.objects.filter(id_empresa=base.ID_EMPRESA_VARIABLE_GLOBAL,estado=True).order_by('descripcion')
    class Meta:
        model = Producto
        fields = '__all__'
        widgets={
            'id_categoria':forms.Select(attrs={'class':'form-select'}),
            'id_unidad_medida':forms.Select(attrs={'class':'form-select'}),
            'nombre':forms.TextInput(attrs={'class':'form-control',}),
            'descripcion':forms.TextInput(attrs={'class':'form-control','onkeypress':'return soloLetras(event);'}),
            'descripcion':forms.Textarea(attrs={'class':'form-control','cols':'10', 'rows':'3'}),
            'estado':forms.CheckboxInput(attrs={'class':'form-check-input','type':'checkbox'}),
        }
    
    def clean_nombre(self):
        nombre=self.cleaned_data.get('nombre')
        unidad_medida=self.cleaned_data.get('id_unidad_medida')
        categoria=self.cleaned_data.get('id_categoria')
        id_empresa=self.cleaned_data.get('id_empresa')
        existe=Producto.objects.filter(id_empresa=id_empresa,id_categoria=categoria,id_unidad_medida=unidad_medida,nombre__iexact=nombre)
        if existe.exists():
            if self.instance.id_producto:
                for x in existe:
                    id=x.id_producto
                if self.cleaned_data.get('id_producto',self.instance.id_producto)==id:
                    return nombre
                else:
                    raise forms.ValidationError('El nombre del producto, unidad de medida y categoría ya existe')
            else:
                raise forms.ValidationError('El nombre del producto, unidad de medida y categoría ya existe')
        else:
            return nombre

class ProductoSucursalForm(forms.ModelForm):
    def __init__(self,*args,**kwargs):
        super (ProductoSucursalForm,self ).__init__(*args,**kwargs)
        self.fields['id_producto'].queryset = Producto.objects.filter(id_empresa=base.ID_EMPRESA_VARIABLE_GLOBAL,estado=True).order_by('nombre')

    class Meta:
        model = ProductoSucursal
        fields = '__all__'
        widgets={
            #'id_sucursal':forms.Select(attrs={'class':'form-select'}),
            'id_producto':forms.Select(attrs={'class':'form-select'}),
            'precio':forms.NumberInput(attrs={'class':'form-control','onkeypress':'return soloNumeros(event);'}),
            'stock':forms.NumberInput(attrs={'class':'form-control','onkeypress':'return soloNumeros(event);'}),
            'stock_min':forms.NumberInput(attrs={'class':'form-control','onkeypress':'return soloNumeros(event);'}),
            'estado':forms.CheckboxInput(attrs={'class':'form-check-input','type':'checkbox'}),
        }

    def clean_id_sucursal(self):
        id_sucursal=self.cleaned_data.get('id_sucursal')
        id_producto=self.cleaned_data.get('id_producto')
        
        #categoria=self.cleaned_data.get('id_categoria')
        existe=ProductoSucursal.objects.filter(id_producto=id_producto,id_sucursal=id_sucursal)
        if existe.exists():
            if self.instance.id_producto_sucursal:
                for x in existe:
                    id=x.id_producto_sucursal
                if self.cleaned_data.get('id_producto_sucursal',self.instance.id_producto_sucursal)==id:
                    return id_sucursal
                else:
                    raise forms.ValidationError('El producto ya existe para esta sucursal')
            else:
                raise forms.ValidationError('El producto ya existe para esta sucursal')
        else:
            return id_sucursal

