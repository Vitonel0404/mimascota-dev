# Generated by Django 3.2 on 2023-02-19 12:22

from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        ('empresa', '0001_initial'),
        ('gestion', '0005_alter_mascota_id_mascota'),
    ]

    operations = [
        migrations.RemoveField(
            model_name='servicio',
            name='id_empresa',
        ),
        migrations.AddField(
            model_name='servicio',
            name='id_sucursal',
            field=models.ForeignKey(null=True, on_delete=django.db.models.deletion.DO_NOTHING, to='empresa.sucursal'),
        ),
    ]
