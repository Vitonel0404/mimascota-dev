# Generated by Django 3.2 on 2023-02-18 12:05

from django.conf import settings
from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    initial = True

    dependencies = [
        ('empresa', '0001_initial'),
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
    ]

    operations = [
        migrations.CreateModel(
            name='Animal',
            fields=[
                ('id_animal', models.AutoField(primary_key=True, serialize=False)),
                ('descripcion', models.CharField(max_length=50)),
                ('estado', models.BooleanField(default=True)),
                ('id_empresa', models.ForeignKey(null=True, on_delete=django.db.models.deletion.DO_NOTHING, to='empresa.empresa')),
            ],
            options={
                'verbose_name': 'Animal',
                'verbose_name_plural': 'Animales',
            },
        ),
        migrations.CreateModel(
            name='Atencion',
            fields=[
                ('id_atencion', models.IntegerField(primary_key=True, serialize=False)),
                ('monto_total', models.DecimalField(decimal_places=2, max_digits=6)),
                ('entrada', models.DateTimeField(auto_now_add=True)),
                ('salida', models.DateTimeField(auto_now=True)),
                ('estado', models.BooleanField(default=False)),
            ],
            options={
                'verbose_name': 'Atencion',
                'verbose_name_plural': 'Atenciones',
            },
        ),
        migrations.CreateModel(
            name='Cliente',
            fields=[
                ('id_cliente', models.AutoField(primary_key=True, serialize=False)),
                ('numero_documento_cliente', models.CharField(max_length=11)),
                ('nombre', models.CharField(max_length=50)),
                ('apellido', models.CharField(max_length=50)),
                ('domicilio', models.CharField(max_length=70)),
                ('celular', models.CharField(max_length=9)),
                ('correo', models.EmailField(max_length=100)),
                ('fecha_registro', models.DateField()),
                ('estado', models.BooleanField(default=True)),
                ('id_empresa', models.ForeignKey(null=True, on_delete=django.db.models.deletion.DO_NOTHING, to='empresa.empresa')),
            ],
            options={
                'verbose_name': 'Cliente',
                'verbose_name_plural': 'Cliente',
            },
        ),
        migrations.CreateModel(
            name='Mascota',
            fields=[
                ('id_mascota', models.AutoField(default=1, primary_key=True, serialize=False)),
                ('numero_historia', models.IntegerField()),
                ('nombre', models.CharField(max_length=50)),
                ('edad', models.DecimalField(decimal_places=2, max_digits=4)),
                ('sexo', models.IntegerField(choices=[(0, 'Hembra'), (1, 'Macho')])),
                ('color', models.CharField(max_length=20)),
                ('peso', models.DecimalField(decimal_places=2, max_digits=4)),
                ('estado', models.BooleanField(default=True)),
                ('id_cliente', models.ForeignKey(on_delete=django.db.models.deletion.DO_NOTHING, to='gestion.cliente')),
                ('id_empresa', models.ForeignKey(null=True, on_delete=django.db.models.deletion.DO_NOTHING, to='empresa.empresa')),
            ],
            options={
                'verbose_name': 'Mascota',
                'verbose_name_plural': 'Mascotas',
            },
        ),
        migrations.CreateModel(
            name='MetodoPago',
            fields=[
                ('id_metodo_pago', models.AutoField(primary_key=True, serialize=False)),
                ('descripcion', models.CharField(max_length=50)),
                ('estado', models.BooleanField(default=True)),
            ],
            options={
                'verbose_name': 'Metodo de pago',
                'verbose_name_plural': 'Metodos de pagos',
            },
        ),
        migrations.CreateModel(
            name='TipoDocumento',
            fields=[
                ('id_tipo_documento', models.AutoField(primary_key=True, serialize=False)),
                ('descripcion', models.CharField(max_length=50)),
                ('estado', models.BooleanField(default=True)),
            ],
            options={
                'verbose_name': 'Tipo de Documento',
                'verbose_name_plural': 'Tipo de Documentos',
            },
        ),
        migrations.CreateModel(
            name='Servicio',
            fields=[
                ('id_servicio', models.AutoField(primary_key=True, serialize=False)),
                ('id_animal', models.IntegerField()),
                ('descripcion', models.CharField(max_length=50)),
                ('precio', models.DecimalField(decimal_places=2, max_digits=5)),
                ('estado', models.BooleanField(default=True)),
                ('id_empresa', models.ForeignKey(null=True, on_delete=django.db.models.deletion.DO_NOTHING, to='empresa.empresa')),
            ],
            options={
                'verbose_name': 'Servicio',
                'verbose_name_plural': 'Servicios',
            },
        ),
        migrations.CreateModel(
            name='Recordatorio',
            fields=[
                ('id_recordatorio', models.AutoField(primary_key=True, serialize=False)),
                ('fecha', models.DateField()),
                ('comentario', models.TextField(blank=True, max_length=100, null=True)),
                ('estado', models.BooleanField(default=True)),
                ('id_empresa', models.ForeignKey(null=True, on_delete=django.db.models.deletion.DO_NOTHING, to='empresa.empresa')),
                ('id_mascota', models.ForeignKey(on_delete=django.db.models.deletion.DO_NOTHING, to='gestion.mascota')),
                ('id_servicio', models.ForeignKey(on_delete=django.db.models.deletion.DO_NOTHING, to='gestion.servicio')),
                ('usuario', models.ForeignKey(on_delete=django.db.models.deletion.DO_NOTHING, to=settings.AUTH_USER_MODEL)),
            ],
            options={
                'verbose_name': 'Recordatorio',
                'verbose_name_plural': 'Recordatorios',
            },
        ),
        migrations.CreateModel(
            name='Raza',
            fields=[
                ('id_raza', models.AutoField(primary_key=True, serialize=False)),
                ('descripcion', models.CharField(max_length=50)),
                ('id_animal', models.ForeignKey(on_delete=django.db.models.deletion.DO_NOTHING, to='gestion.animal')),
                ('id_empresa', models.ForeignKey(null=True, on_delete=django.db.models.deletion.DO_NOTHING, to='empresa.empresa')),
            ],
            options={
                'verbose_name': 'Raza',
                'verbose_name_plural': 'Razas',
            },
        ),
        migrations.AddField(
            model_name='mascota',
            name='id_raza',
            field=models.ForeignKey(on_delete=django.db.models.deletion.DO_NOTHING, to='gestion.raza'),
        ),
        migrations.CreateModel(
            name='Detalle_Atencion',
            fields=[
                ('id_detalle_atencion', models.AutoField(primary_key=True, serialize=False)),
                ('monto', models.DecimalField(decimal_places=2, max_digits=5)),
                ('comentario', models.TextField(max_length=100, null=True)),
                ('id_atencion', models.ForeignKey(on_delete=django.db.models.deletion.DO_NOTHING, to='gestion.atencion')),
                ('id_servicio', models.ForeignKey(on_delete=django.db.models.deletion.DO_NOTHING, to='gestion.servicio')),
            ],
            options={
                'verbose_name': 'Detalle de atencion',
                'verbose_name_plural': 'Detalle de atenciones',
            },
        ),
        migrations.AddField(
            model_name='cliente',
            name='id_tipo_documento',
            field=models.ForeignKey(on_delete=django.db.models.deletion.DO_NOTHING, to='gestion.tipodocumento'),
        ),
        migrations.AddField(
            model_name='atencion',
            name='id_mascota',
            field=models.ForeignKey(on_delete=django.db.models.deletion.DO_NOTHING, to='gestion.mascota'),
        ),
        migrations.AddField(
            model_name='atencion',
            name='id_metodo_pago',
            field=models.ForeignKey(on_delete=django.db.models.deletion.DO_NOTHING, to='gestion.metodopago'),
        ),
        migrations.AddField(
            model_name='atencion',
            name='id_sucursal',
            field=models.ForeignKey(on_delete=django.db.models.deletion.DO_NOTHING, to='empresa.sucursal'),
        ),
        migrations.AddField(
            model_name='atencion',
            name='usuario',
            field=models.ForeignKey(on_delete=django.db.models.deletion.DO_NOTHING, to=settings.AUTH_USER_MODEL),
        ),
    ]
