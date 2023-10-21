from datetime import datetime
from django.db import models
from apps.gestion.models import MetodoPago, Cliente, Usuario
from apps.productos.models import Producto
from apps.empresa.models import Sucursal,Empresa
# Create your models here.



class TipoComprobante(models.Model):
    id_tipo_comprobante=models.AutoField(primary_key=True)
    id_empresa=models.ForeignKey(Empresa,on_delete=models.DO_NOTHING ,null=False, blank=False)
    descripcion=models.CharField(max_length=25, null=False, blank=False)
    estado=models.BooleanField(default=True)
    class Meta:
        verbose_name = 'Tipo de Comprobante'
        verbose_name_plural = 'Tipos de Comprobantes'

    def __str__(self):
        """Unicode representation of TipoComprobante."""
        return self.descripcion
    
class Correlativo(models.Model):
    id_correlativo=models.AutoField(primary_key=True)
    id_tipo_comprobante=models.ForeignKey(TipoComprobante,on_delete=models.DO_NOTHING, null=False,blank=False)
    id_empresa=models.ForeignKey(Empresa,on_delete=models.DO_NOTHING, null=False,blank=False)
    serie=models.CharField(max_length=4, null=False, blank=False)
    primer_numero=models.IntegerField(null=False,blank=False)
    ultimo_numero_registrado=models.PositiveBigIntegerField(null=True,blank=True)
    max_correlativo=models.PositiveBigIntegerField(null=False,blank=False)

    class Meta:
        verbose_name = 'Correlativo'
        verbose_name_plural = 'Correlativos'

    def __str__(self):
        return f'Correlativo: {self.serie}-{self.ultimo_numero_registrado}'

class Parametro(models.Model):
    id_parametro=models.AutoField(primary_key=True)
    nombre=models.CharField(max_length=20, null=False, blank=False)
    valor=models.DecimalField(max_digits=6, decimal_places=2, null=False, blank=False)
    estado=models.BooleanField(default=True, null=False, blank=False)
    class Meta:
        """Meta definition for Parametro."""

        verbose_name = 'Parametro'
        verbose_name_plural = 'Parametros'

    def __str__(self):
        """Unicode representation of Parametro."""
        return self.nombre



estado_venta=[
    (0,'Anulada'),
    (1,'Realizada')
]

class Venta(models.Model):
    
    id_venta=models.IntegerField(primary_key=True)
    id_tipo_comprobante=models.ForeignKey(TipoComprobante, on_delete=models.DO_NOTHING, null=False, blank=False)
    serie=models.CharField(max_length=4, null=False, blank=False)
    numero=models.IntegerField(null=False,blank=False)
    id_cliente=models.ForeignKey(Cliente, on_delete=models.DO_NOTHING, null=False,blank=False)
    monto_total=models.DecimalField(max_digits=10, decimal_places=2, null=False, blank=False)
    operacion_gravada=models.DecimalField(max_digits=8, decimal_places=2, null=False, blank=False)
    porcentaje_igv=models.DecimalField(max_digits=6, decimal_places=2, null=False, blank=False)
    igv=models.DecimalField(max_digits=7, decimal_places=2, null=False, blank=False)
    fecha=models.DateField(null=False, blank=False,default=datetime.now)
    id_metodo_pago=models.ForeignKey(MetodoPago, on_delete=models.DO_NOTHING, null=False, blank=False)
    id_usuario=models.ForeignKey(Usuario, on_delete=models.DO_NOTHING, null=False,blank=False)
    estado=models.IntegerField(blank=False,null=False, choices=estado_venta)
    motivo_anulacion=models.TextField(max_length=100,null=True, blank=True)
    id_usuario_anulador=models.IntegerField(null=True,blank=True)
    id_sucursal=models.ForeignKey(Sucursal,on_delete=models.DO_NOTHING,null=False, blank=False)

    class Meta:
        verbose_name = 'Venta'
        verbose_name_plural = 'Ventas'

    def __str__(self):
        #return self.id_venta
        return f'Comprobante: {self.id_tipo_comprobante}-{self.serie}/{self.numero}'


class DetalleVenta(models.Model):
    id_detalle_venta=models.AutoField(primary_key=True)
    id_venta=models.ForeignKey(Venta, on_delete=models.DO_NOTHING, null=False,blank=False)
    id_producto=models.ForeignKey(Producto,on_delete=models.DO_NOTHING, null=False, blank=False)
    precio=models.DecimalField(max_digits=5, decimal_places=2, blank=False,null=False)
    cantidad=models.PositiveSmallIntegerField(null=False, blank=False)
    subtotal=models.DecimalField(max_digits=12, decimal_places=2, blank=False,null=False)

    class Meta:
        verbose_name = 'Detalle de Venta'
        verbose_name_plural = 'Detalle de Ventas'

    def __str__(self):
        return f'Venta:{self.id_venta.id_tipo_comprobante.descripcion}-{self.id_venta.serie}/{self.id_venta.numero} -- {self.id_producto.nombre} '