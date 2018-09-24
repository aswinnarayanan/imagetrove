#!/bin/bash

. /appenv/bin/activate
<<<<<<< HEAD
#python mytardis.py migrate auth --fake
python mytardis.py makemigrations 
python mytardis.py migrate
python mytardis.py createcachetable default_cache
python mytardis.py createcachetable celery_lock_cache
=======

#python mytardis.py makemigrations
python mytardis.py migrate auth --fake #Fixes migration issue due to longerusernameandemail
python mytardis.py migrate

# python mytardis.py createcachetable default_cache
# python mytardis.py createcachetable celery_lock_cache
# python mytardis.py collectstatic
>>>>>>> ccf266451ba7051d54517a74f1898209a74e8fac
gunicorn -c gunicorn_settings.py --bind 0.0.0.0:8000 wsgi:application
