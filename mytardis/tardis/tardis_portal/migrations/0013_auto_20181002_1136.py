# -*- coding: utf-8 -*-
# Generated by Django 1.11.15 on 2018-10-02 01:36
from __future__ import unicode_literals

from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('tardis_portal', '0012_userauthentication_approved'),
    ]

    operations = [
        migrations.AlterModelOptions(
            name='facility',
            options={'ordering': ('name',), 'verbose_name_plural': 'Facilities'},
        ),
        migrations.AlterModelOptions(
            name='instrument',
            options={'ordering': ('name',), 'verbose_name_plural': 'Instruments'},
        ),
        migrations.AlterModelOptions(
            name='storagebox',
            options={'ordering': ('name',), 'verbose_name_plural': 'storage boxes'},
        ),
    ]
