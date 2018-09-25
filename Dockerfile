FROM aswinnarayanan/mytardis-run
# FROM mytardis/mytardis-run:develop

USER root
EXPOSE 8000
#EXPOSE 5432
WORKDIR /home/webapp

ADD . /path/inside/docker/container

ADD settings.py ./tardis/
ADD run_mytardis.sh .
#ADD api.py ./tardis/tardis_portal/
ADD imagetrove ./tardis/apps/imagetrove

#USER webapp
# django-longerusernameandemail

#RUN . /appenv/bin/activate; python mytardis.py makemigrations 

USER webapp
RUN . /appenv/bin/activate; pip install psycopg2-binary django-longerusernameandemail

RUN . /appenv/bin/activate; python mytardis.py makemigrations
#CMD . /appenv/bin/activate; gunicorn -c gunicorn_settings.py --bind 0.0.0.0:8000 wsgi:application

CMD bash run_mytardis.sh

# TODO External settings
# RUN python -c "import os; from random import choice; key_line = '%sSECRET_KEY=\"%s\"  # generated from build.sh\n' % ('from tardis.default_settings import * \n\n' if not os.path.isfile('tardis/settings.py') else '', ''.join([choice('abcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*(-_=+)') for i in range(50)])); f=open('tardis/settings.py', 'a+'); f.write(key_line); f.close()"


#RUN . /appenv/bin/activate; python mytardis.py makemigrations
#RUN . /appenv/bin/activate; python mytardis.py migrate
#RUN . /appenv/bin/activate; python mytardis.py createcachetable default_cache
#RUN . /appenv/bin/activate; python mytardis.py createcachetable celery_lock_cache

## Django Development server
# RUN . /appenv/bin/activate; python mytardis.py runserver 0.0.0.0:8000
# CMD . /appenv/bin/activate; gunicorn -c gunicorn_settings.py --bind 0.0.0.0:8000 wsgi:application
