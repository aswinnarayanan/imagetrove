#!/bin/bash

. /appenv/bin/activate
#python mytardis.py migrate auth --fake
#python mytardis.py makemigrations 
#python mytardis.py migrate
#python mytardis.py createcachetable default_cache
#python mytardis.py createcachetable celery_lock_cache
gunicorn -c gunicorn_settings.py --bind 0.0.0.0:8000 wsgi:application
