# Generated by Django 3.2 on 2023-10-21 09:00

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('empresa', '0006_alter_empresa_estado_pago'),
    ]

    operations = [
        migrations.AlterField(
            model_name='empresa',
            name='id',
            field=models.AutoField(primary_key=True, serialize=False),
        ),
    ]