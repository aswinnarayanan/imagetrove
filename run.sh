#!/bin/bash

<<<<<<< HEAD
source ~/appenv/bin/activate

python mytardis.py makemigrations --noinput
python mytardis.py migrate --noinput

export DJANGO_SETTINGS_MODULE=tardis.settings
celery worker -A tardis.celery.tardis_app -c 2 -Q celery,default -n "allqueues.%%h" &
celery beat -A tardis.celery.tardis_app --loglevel INFO &

gunicorn -c gunicorn_settings.py -b unix:/tmp/gnicorn.socket -b 0.0.0.0:8000 --log-syslog wsgi:application
=======
# source ~/appenv/bin/activate; python mytardis.py createcachetable default_cache
# source ~/appenv/bin/activate; python mytardis.py createcachetable celery_lock_cache
source ~/appenv/bin/activate; python mytardis.py makemigrations --noinput
source ~/appenv/bin/activate; python mytardis.py migrate --noinput
# source ~/appenv/bin/activate; python mytardis.py collectstatic
# source ~/appenv/bin/activate; source ~/appenv/bin/activate; gunicorn -c gunicorn_settings.py --bind 0.0.0.0:8000 wsgi:application

# export DJANGO_SETTINGS_MODULE=tardis.settings
# celery worker -A tardis.celery.tardis_app -c 2 -Q celery,default -n "allqueues.%%h" &
source ~/appenv/bin/activate; gunicorn -c gunicorn_settings.py -b unix:/tmp/gnicorn.socket -b 0.0.0.0:8000 --log-syslog wsgi:application
>>>>>>> 4744996754da0c28071fb136aa572ab05a93ef10
