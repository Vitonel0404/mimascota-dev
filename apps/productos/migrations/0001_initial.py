# Generated by Django 3.2 on 2023-02-18 12:07

from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    initial = True

    dependencies = [
        ('empresa', '0001_initial'),
    ]

    operations = [
        migrations.CreateModel(
            name='Categoria',
            fields=[
                ('id_categoria', models.AutoField(primary_key=True, serialize=False)),
                ('descripcion', models.CharField(max_length=70)),
                ('estado', models.BooleanField(default=True)),
                ('id_empresa', models.ForeignKey(null=True, on_delete=django.db.models.deletion.DO_NOTHING, to='empresa.empresa')),
            ],
            options={
                'verbose_name': 'Categoria',
                'verbose_name_plural': 'Categorias',
            },
        ),
        migrations.CreateModel(
            name='Producto',
            fields=[
                ('id_producto', models.AutoField(primary_key=True, serialize=False)),
                ('nombre', models.CharField(max_length=150)),
                ('descripcion', models.TextField()),
                ('estado', models.BooleanField(default=True)),
                ('id_categoria', models.ForeignKey(on_delete=django.db.models.deletion.DO_NOTHING, to='productos.categoria')),
                ('id_empresa', models.ForeignKey(null=True, on_delete=django.db.models.deletion.DO_NOTHING, to='empresa.empresa')),
            ],
            options={
                'verbose_name': 'Producto',
                'verbose_name_plural': 'Productos',
            },
        ),
        migrations.CreateModel(
            name='UnidadMedida',
            fields=[
                ('id_unidad_medida', models.AutoField(primary_key=True, serialize=False)),
                ('descripcion', models.CharField(max_length=50, unique=True)),
                ('estado', models.BooleanField(default=True)),
                ('id_empresa', models.ForeignKey(null=True, on_delete=django.db.models.deletion.DO_NOTHING, to='empresa.empresa')),
            ],
            options={
                'verbose_name': 'Unidad de Medida',
                'verbose_name_plural': 'Unidades de Medidas',
            },
        ),
        migrations.CreateModel(
            name='ProductoSucursal',
            fields=[
                ('id_producto_sucursal', models.AutoField(primary_key=True, serialize=False)),
                ('precio', models.DecimalField(decimal_places=2, max_digits=5)),
                ('stock', models.PositiveIntegerField()),
                ('stock_min', models.PositiveIntegerField()),
                ('estado', models.BooleanField(default=True)),
                ('id_producto', models.ForeignKey(on_delete=django.db.models.deletion.DO_NOTHING, to='productos.producto')),
                ('id_sucursal', models.ForeignKey(on_delete=django.db.models.deletion.DO_NOTHING, to='empresa.sucursal')),
            ],
            options={
                'verbose_name': 'Producto Sucursal',
                'verbose_name_plural': 'Productos Sucursales',
            },
        ),
        migrations.AddField(
            model_name='producto',
            name='id_unidad_medida',
            field=models.ForeignKey(on_delete=django.db.models.deletion.DO_NOTHING, to='productos.unidadmedida'),
        ),
    ]
