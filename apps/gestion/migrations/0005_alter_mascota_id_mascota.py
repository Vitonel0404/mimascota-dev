# Generated by Django 3.2 on 2023-02-18 23:10

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('gestion', '0004_auto_20230218_2233'),
    ]

    operations = [
        migrations.AlterField(
            model_name='mascota',
            name='id_mascota',
            field=models.AutoField(primary_key=True, serialize=False),
        ),
    ]
