# Generated by Django 3.2 on 2023-12-10 20:05

from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        ('empresa', '0007_alter_empresa_id'),
        ('gestion', '0008_recordatorio_id_sucursal'),
    ]

    operations = [
        migrations.AddField(
            model_name='metodopago',
            name='id_sucursal',
            field=models.ForeignKey(default=1, on_delete=django.db.models.deletion.DO_NOTHING, to='empresa.sucursal'),
        ),
    ]
