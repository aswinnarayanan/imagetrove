FROM ubuntu:18.04

# Installing basic dependancies
ENV DEBIAN_FRONTEND noninteractive
RUN echo 'APT::Get::Assume-Yes "true";' > /etc/apt/apt.conf.d/90assumeyes
RUN apt-get update && apt-get install \
    -qy \
    -o APT::Install-Recommends=false \
    -o APT::Install-Suggests=false \
    curl \
    sudo

# Making python and webapp directories
RUN groupadd -r webapp && useradd -r -g webapp webapp

RUN mkdir -p /home/webapp
RUN chown -R webapp:webapp /home/webapp

RUN mkdir -p /home/webapp/logs
RUN chown -R webapp:webapp /home/webapp/logs

RUN mkdir -p /home/webapp/build
RUN chown -R webapp:webapp /home/webapp/build


WORKDIR /home/webapp/build
COPY --chown=webapp:webapp mytardis/install-ubuntu-requirements.sh ./
RUN bash install-ubuntu-requirements.sh

USER webapp
RUN virtualenv --system-site-packages /home/webapp/appenv
RUN bash -c "source ~/appenv/bin/activate; pip install --no-cache-dir -U pip"
RUN bash -c "source ~/appenv/bin/activate; pip install --no-cache-dir python-ldap==3.1.0"

COPY --chown=webapp:webapp mytardis/requirements-base.txt ./
RUN bash -c "source ~/appenv/bin/activate; pip install --no-cache-dir -r requirements-base.txt"

COPY --chown=webapp:webapp mytardis/requirements-postgres.txt ./
RUN bash -c "source ~/appenv/bin/activate; pip install --no-cache-dir -r requirements-postgres.txt"

RUN mkdir -p ./tardis/apps/social_auth/
COPY --chown=webapp:webapp mytardis/tardis/apps/social_auth/requirements.txt ./tardis/apps/social_auth/requirements.txt
RUN bash -c "source ~/appenv/bin/activate; pip install --no-cache-dir -r tardis/apps/social_auth/requirements.txt"

RUN bash -c "source ~/appenv/bin/activate; pip install --no-cache-dir redis==2.10.6"
RUN bash -c "source ~/appenv/bin/activate; pip install --no-cache-dir django-redis"
RUN bash -c "source ~/appenv/bin/activate; pip install --no-cache-dir celery_haystack"

# Adding mytardis src
COPY --chown=webapp:webapp mytardis /home/webapp/code
WORKDIR /home/webapp/code

# Installing javascript dependancies
RUN npm install --production

RUN rm -rf /home/webapp/build

# CMD bash -c "source ~/appenv/bin/activate; export DJANGO_SETTINGS_MODULE=tardis.settings; gunicorn -c gunicorn_settings.py -b unix:/tmp/gnicorn.socket -b 0.0.0.0:8000 --log-syslog wsgi:application"