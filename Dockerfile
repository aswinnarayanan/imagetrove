FROM aswinnarayanan/mytardis-run
# FROM mytardis/mytardis-run:develop

USER root
EXPOSE 8000
WORKDIR /home/webapp

ADD settings.py ./tardis/
#TODO External settings
# RUN python -c "import os; from random import choice; key_line = '%sSECRET_KEY=\"%s\"  # generated from build.sh\n' % ('from tardis.default_settings import * \n\n' if not os.path.isfile('tardis/settings.py') else '', ''.join([choice('abcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*(-_=+)') for i in range(50)])); f=open('tardis/settings.py', 'a+'); f.write(key_line); f.close()"


USER webapp
# RUN . /appenv/bin/activate; pip install django-longerusernameandemail south

RUN . /appenv/bin/activate; python mytardis.py migrate
RUN . /appenv/bin/activate; python mytardis.py createcachetable default_cache
RUN . /appenv/bin/activate; python mytardis.py createcachetable celery_lock_cache

## Django Development server
# RUN . /appenv/bin/activate; python mytardis.py runserver 0.0.0.0:8000
# CMD . /appenv/bin/activate; gunicorn -c gunicorn_settings.py --bind 0.0.0.0:8000 wsgi:application

# CMD . /appenv/bin/activate; /bin/bash


# CMD . /appenv/bin/activate; bash
# RUN . /appenv/bin/activate; pip install django-longerusernameandemail south
# TODO: enable python packages in settings.py


# ADD settings.py /home/webapp

