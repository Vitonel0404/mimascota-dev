# Generated by Django 3.2 on 2023-03-04 10:46

from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        ('empresa', '0002_auto_20230304_1045'),
        ('ventas', '0004_auto_20230226_1451'),
    ]

    operations = [
        migrations.AddField(
            model_name='tipocomprobante',
            name='id_empresa',
            field=models.ForeignKey(default=1, on_delete=django.db.models.deletion.DO_NOTHING, to='empresa.empresa'),
            preserve_default=False,
        ),
    ]
