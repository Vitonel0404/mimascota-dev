# Generated by Django 3.2 on 2023-03-04 14:13

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('empresa', '0003_empresa_estado_pago'),
    ]

    operations = [
        migrations.AlterField(
            model_name='empresa',
            name='estado_pago',
            field=models.ImageField(default=True, null=True, upload_to=''),
        ),
    ]
