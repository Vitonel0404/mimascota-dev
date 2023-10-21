from django.db import models
from apps.empresa.models import Empresa,Sucursal

# Create your models here.
class Categoria(models.Model):
    id_categoria=models.AutoField(primary_key=True)
    id_empresa=models.ForeignKey(Empresa,on_delete=models.DO_NOTHING,null=True,blank=False)
    descripcion=models.CharField(max_length=70, null=False,blank=False)
    estado=models.BooleanField(null=False,default=True)
    class Meta:
        verbose_name = 'Categoria'
        verbose_name_plural = 'Categorias'

    def __str__(self):
        return self.descripcion

class UnidadMedida(models.Model):
    id_unidad_medida=models.AutoField(primary_key=True)
    id_empresa=models.ForeignKey(Empresa,on_delete=models.DO_NOTHING,null=True,blank=False)
    descripcion = models.CharField(max_length=50,blank = False,null = False,unique = True)
    estado=models.BooleanField(null=False,default=True)

    class Meta:
        verbose_name = 'Unidad de Medida'
        verbose_name_plural = 'Unidades de Medidas'

    def __str__(self):
        return self.descripcion

class Producto(models.Model):
    id_producto=models.AutoField(primary_key=True)
    id_categoria=models.ForeignKey(Categoria,on_delete=models.DO_NOTHING,null=False,blank=False)
    id_unidad_medida=models.ForeignKey(UnidadMedida,on_delete=models.DO_NOTHING,null=False,blank=False)
    id_empresa=models.ForeignKey(Empresa,on_delete=models.DO_NOTHING,null=True,blank=False)
    nombre=models.CharField(max_length=150, null=False, blank=False)
    descripcion = models.TextField(blank=False, null=False)
    estado=models.BooleanField(null=False,default=True)

    class Meta:
        verbose_name = 'Producto'
        verbose_name_plural = 'Productos'

    def __str__(self):
        return self.nombre
    
class ProductoSucursal(models.Model):
    id_producto_sucursal=models.AutoField(primary_key=True)
    id_producto=models.ForeignKey(Producto,on_delete=models.DO_NOTHING,null=False,blank=False)
    id_sucursal=models.ForeignKey(Sucursal,on_delete=models.DO_NOTHING,null=False,blank=False)
    precio=models.DecimalField(max_digits=5, decimal_places=2, blank=False,null=False)
    stock=models.PositiveIntegerField(null=False, blank=False)
    stock_min=models.PositiveIntegerField(null=False, blank=False)
    estado=models.BooleanField(null=False,default=True)

    class Meta:
        verbose_name = 'Producto Sucursal'
        verbose_name_plural = 'Productos Sucursales'

    def __str__(self):
        return f'{self.id_producto.nombre}-{self.id_sucursal.razon_social}'
