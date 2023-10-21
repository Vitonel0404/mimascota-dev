from django.db import models
from apps.gestion.models import Usuario,TipoDocumento
from apps.ventas.models import TipoComprobante
from apps.productos.models import Producto
from apps.empresa.models import Empresa,Sucursal
# Create your models here.

class Proveedor(models.Model):
    id_proveedor=models.AutoField(primary_key=True)
    id_tipo_documento=models.ForeignKey(TipoDocumento,on_delete=models.DO_NOTHING, null=False,blank=False)
    id_empresa=models.ForeignKey(Empresa,on_delete=models.DO_NOTHING,null=True,blank=False)
    numero_documento_proveedor=models.CharField(max_length=11, null=False, blank=False)
    razon_social=models.CharField(max_length=150 , null=False, blank=False)
    telefono_proveedor=models.CharField(max_length=9, null=True, blank=True)
    telefono_contacto=models.CharField(max_length=9,null=True, blank=True)
    direccion=models.CharField(max_length=150, null=True, blank=True )
    estado=models.BooleanField(default=True)
    class Meta:
        verbose_name = 'Proveedor'
        verbose_name_plural = 'Proveedores'

    def __str__(self):
        #if self.estado==True:
        return self.razon_social

class Compra(models.Model):
    id_compra=models.IntegerField(primary_key=True)
    id_proveedor=models.ForeignKey(Proveedor, on_delete=models.DO_NOTHING, null=False, blank=False)
    id_tipo_comprobante=models.ForeignKey(TipoComprobante,on_delete=models.DO_NOTHING, null=False, blank=False)
    serie=models.CharField(max_length=7, null=False, blank=False)
    numero=models.IntegerField(null=False,blank=False)
    impuesto=models.DecimalField(max_digits=8, decimal_places=2, null=False, blank=False)
    monto_total=models.DecimalField(max_digits=8, decimal_places=2, null=False, blank=False)
    fecha=models.DateField(null=False, blank=False)
    fecha_registro=models.DateField(null=True, blank=False)
    estado=models.BooleanField(default=True)
    id_usuario=models.ForeignKey(Usuario, on_delete=models.DO_NOTHING, null=False, blank=False)
    id_sucursal=models.ForeignKey(Sucursal, on_delete=models.DO_NOTHING, null=False, blank=False)
    

    class Meta:
        verbose_name = 'Compra'
        verbose_name_plural = 'Compras'

    def __str__(self):
        return f'Comprobante: {self.id_tipo_comprobante}/{self.serie}-{self.numero}'

class DetalleCompra(models.Model):
    id_detalle_compra=models.AutoField(primary_key=True)
    id_compra=models.ForeignKey(Compra,on_delete=models.DO_NOTHING, null=False, blank=True)
    id_producto= models.ForeignKey(Producto, on_delete=models.DO_NOTHING, null=False, blank=False)
    precio=models.DecimalField(max_digits=5, decimal_places=2, blank=False,null=False)
    cantidad=models.PositiveSmallIntegerField(null=False, blank=False)
    subtotal=models.DecimalField(max_digits=8, decimal_places=2, blank=False,null=False)

    class Meta:
        verbose_name = 'Detalle de Compra'
        verbose_name_plural = 'Detalle de Compras'

    def __str__(self):
        return f'Venta:{self.id_compra.id_tipo_comprobante.descripcion}-{self.id_compra.serie}/{self.id_compra.numero} -- {self.id_producto.nombre} '


