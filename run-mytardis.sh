#!/bin/bash

python mytardis.py makemigrations --noinput
python mytardis.py migrate --noinput
gunicorn -c gunicorn_settings.py --bind 0.0.0.0:8000 wsgi:application
