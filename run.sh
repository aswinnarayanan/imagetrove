#!/bin/bash

source ~/appenv/bin/activate

python mytardis.py makemigrations --noinput
python mytardis.py migrate --noinput

export DJANGO_SETTINGS_MODULE=tardis.settings
celery worker -A tardis.celery.tardis_app -c 2 -Q celery,default -n "allqueues.%%h" &
celery beat -A tardis.celery.tardis_app --loglevel INFO &

gunicorn -c gunicorn_settings.py -b unix:/tmp/gnicorn.socket -b 0.0.0.0:8000 --log-syslog wsgi:application
