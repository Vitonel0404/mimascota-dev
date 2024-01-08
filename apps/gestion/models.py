from django.db import models
from apps.usuarios.models import Usuario
from apps.empresa.models import Empresa,Sucursal


class Animal(models.Model):
    id_animal=models.AutoField(primary_key=True)
    descripcion=models.CharField(max_length=50, blank=False,null=False)
    estado=models.BooleanField(default=True)
    id_empresa=models.ForeignKey(Empresa,on_delete=models.DO_NOTHING,null=True,blank=False)
    class Meta:
        verbose_name = 'Animal'
        verbose_name_plural = 'Animales'

    def __str__(self):
        return self.descripcion

class Raza(models.Model):
    id_raza=models.AutoField(primary_key=True)
    id_animal=models.ForeignKey(Animal,on_delete=models.DO_NOTHING, blank=False, null=False)
    id_empresa=models.ForeignKey(Empresa,on_delete=models.DO_NOTHING,null=True,blank=False)
    descripcion=models.CharField(max_length=50, blank=False,null=False)

    class Meta:
        verbose_name = 'Raza'
        verbose_name_plural = 'Razas'

    def __str__(self):
        return self.descripcion

class TipoDocumento(models.Model):
    id_tipo_documento=models.AutoField(primary_key=True)
    descripcion=models.CharField(max_length=50, null=False, blank=False)
    estado=models.BooleanField(default=True)
    class Meta:
        verbose_name = 'Tipo de Documento'
        verbose_name_plural = 'Tipo de Documentos'

    def __str__(self):
        return self.descripcion


class Cliente(models.Model):
    id_cliente=models.AutoField(primary_key=True)
    id_tipo_documento=models.ForeignKey('TipoDocumento',on_delete=models.DO_NOTHING, blank=False, null=False)
    id_empresa=models.ForeignKey(Empresa,on_delete=models.DO_NOTHING,null=True,blank=False)
    id_sucursal=models.ForeignKey(Sucursal,on_delete=models.DO_NOTHING,null=True,blank=False)
    numero_documento_cliente=models.CharField(max_length=11,blank=False,null=False)
    nombre=models.CharField(max_length=50, blank=False,null=False)
    apellido=models.CharField(max_length=50, blank=False,null=False)
    domicilio=models.CharField(max_length=70, blank=False,null=False)
    celular=models.CharField(max_length=9, blank=False,null=False)
    correo=models.EmailField(max_length=100, blank=False,null=False)
    fecha_registro=models.DateField(blank=False,null=False)
    estado=models.BooleanField(null=False,default=True)

    class Meta:
        verbose_name = 'Cliente'
        verbose_name_plural = 'Clientes'

    def __str__(self):
        return self.nombre


mascota_sexo = [
    (0,"Hembra"),
    (1,"Macho")
]
class Mascota(models.Model):
    id_mascota=models.AutoField(primary_key=True,)
    id_empresa=models.ForeignKey(Empresa,on_delete=models.DO_NOTHING,null=True,blank=False)
    id_sucursal=models.ForeignKey(Sucursal,on_delete=models.DO_NOTHING,null=True,blank=False)
    numero_historia=models.IntegerField(null=False, blank=False)
    id_cliente=models.ForeignKey('Cliente',on_delete=models.DO_NOTHING, blank=False, null=False)
    id_raza=models.ForeignKey('Raza',on_delete=models.DO_NOTHING, blank=False, null=False)
    nombre=models.CharField(max_length=50, blank=False,null=False)
    edad=models.DecimalField(max_digits=4, decimal_places=2, blank=False,null=False)
    sexo=models.IntegerField(blank=False,null=False, choices=mascota_sexo)
    color=models.CharField(max_length=20, blank=False,null=False)
    peso=models.DecimalField(max_digits=4, blank=False, decimal_places=2,null=False)
    estado= models.BooleanField(default=True,null=False)

    class Meta:
        verbose_name = 'Mascota'
        verbose_name_plural = 'Mascotas'

    def __str__(self):
        return self.nombre


class MetodoPago(models.Model):
    id_metodo_pago=models.AutoField(primary_key=True)
    descripcion=models.CharField(max_length=50,null=False,blank=False)
    estado=models.BooleanField(default=True)
    id_sucursal=models.ForeignKey(Sucursal,on_delete=models.DO_NOTHING, default=1)

    class Meta:
        verbose_name = 'Metodo de pago'
        verbose_name_plural = 'Metodos de pagos'

    def __str__(self):
        return self.descripcion

class Atencion(models.Model):
    id_atencion=models.IntegerField(primary_key=True)
    numero_atencion=models.BigIntegerField(blank=False, null=True)
    id_mascota=models.ForeignKey(Mascota,on_delete=models.DO_NOTHING, blank=False, null=False)
    monto_total=models.DecimalField(max_digits=6, blank=False, decimal_places=2,null=False)
    entrada=models.DateTimeField(auto_now_add=True)
    salida=models.DateTimeField(auto_now_add=False,auto_now=True)
    estado=models.BooleanField(null=False,default=False)
    id_metodo_pago=models.ForeignKey('MetodoPago',on_delete=models.DO_NOTHING, blank=False, null=False)
    comentario = models.TextField(blank= True, null=True)
    usuario=models.ForeignKey(Usuario,on_delete=models.DO_NOTHING, blank=False, null=False)
    id_sucursal=models.ForeignKey(Sucursal,on_delete=models.DO_NOTHING, blank=False, null=False)

    class Meta:
        verbose_name = 'Atencion'
        verbose_name_plural = 'Atenciones'

class Servicio(models.Model):
    id_servicio=models.AutoField(primary_key=True)
    id_animal=models.IntegerField(null=False,blank=False)
    id_sucursal=models.ForeignKey(Sucursal,on_delete=models.DO_NOTHING,null=True,blank=False)
    descripcion=models.CharField(max_length=50, blank=False,null=False)
    precio=models.DecimalField(max_digits=5, blank=False, decimal_places=2,null=False)
    estado=models.BooleanField(null=False,default=True)

    class Meta:
        verbose_name = 'Servicio'
        verbose_name_plural = 'Servicios'

    def __str__(self):
        return self.descripcion

class Detalle_Atencion(models.Model):
    id_detalle_atencion=models.AutoField(primary_key=True)
    id_atencion=models.ForeignKey('Atencion',on_delete=models.DO_NOTHING, blank=False, null=False)
    id_servicio=models.ForeignKey('Servicio',on_delete=models.DO_NOTHING, blank=False, null=False)
    monto=models.DecimalField(max_digits=5, blank=False, decimal_places=2,null=False)
    comentario=models.TextField(max_length=100,null=True)

    class Meta:
        verbose_name = 'Detalle de atencion'
        verbose_name_plural = 'Detalle de atenciones'

class Recordatorio(models.Model):
    id_recordatorio=models.AutoField(primary_key=True)
    id_mascota=models.ForeignKey('Mascota',on_delete=models.DO_NOTHING, blank=False, null=False)
    id_empresa=models.ForeignKey(Empresa,on_delete=models.DO_NOTHING,null=True,blank=False)
    id_sucursal=models.ForeignKey(Sucursal,on_delete=models.DO_NOTHING,null=True,blank=False)
    id_servicio=models.ForeignKey(Servicio,on_delete=models.DO_NOTHING, blank=False, null=False)
    fecha=models.DateField(null=False, blank=False)
    comentario=models.TextField(max_length=100,null=True, blank=True)
    estado=models.BooleanField(null=False,default=True)
    usuario=models.ForeignKey(Usuario,on_delete=models.DO_NOTHING, blank=False, null=False)
    class Meta:
        verbose_name = 'Recordatorio'
        verbose_name_plural = 'Recordatorios'






