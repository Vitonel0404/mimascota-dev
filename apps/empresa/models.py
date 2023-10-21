from django.db import models

# Create your models here.

class Empresa(models.Model):
    id=models.AutoField(primary_key=True)
    ruc=models.CharField(max_length=11, null=False, blank=False)
    razon_social=models.CharField(max_length=200, null=False, blank=False)
    ciudad=models.CharField(max_length=200, null=False, blank=False)
    direccion=models.CharField(max_length=200, null=False, blank=False)
    telefono=models.CharField(max_length=12, null=False, blank=False)
    correo=models.EmailField(max_length=250, null=True, blank=False)
    token_correo=models.CharField(max_length=250, null=True, blank=False)
    imagen=models.ImageField(null=True,blank=True)
    estado_pago=models.BooleanField(default=True)
    estado=models.BooleanField(default=True)

    class Meta:
        verbose_name = 'Empresa'
        verbose_name_plural = 'Empresas'

    def __str__(self):
        return self.razon_social

class Sucursal(models.Model):
    id_sucursal=models.AutoField(primary_key=True)
    id_empresa=models.ForeignKey(Empresa,on_delete=models.DO_NOTHING, null=False, blank=False)
    razon_social=models.CharField(max_length=200, null=False, blank=False)
    ciudad=models.CharField(max_length=200, null=False, blank=False)
    direccion=models.CharField(max_length=200, null=False, blank=False)
    telefono=models.CharField(max_length=12, null=False, blank=False)
    estado=models.BooleanField(default=True)

    class Meta:
        verbose_name = 'Sucursal'
        verbose_name_plural = 'Sucursales'

    def __str__(self):
        return self.razon_social

