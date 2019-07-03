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

# Making python and app directories
RUN groupadd -r app && useradd -r -g app app

RUN mkdir -p /home/app
RUN chown -R app:app /home/app

RUN mkdir -p /home/app/logs
RUN chown -R app:app /home/app/logs

RUN mkdir -p /home/app/build
RUN chown -R app:app /home/app/build


WORKDIR /home/app/build
COPY --chown=app:app mytardis/install-ubuntu-requirements.sh ./
RUN bash install-ubuntu-requirements.sh

USER app
RUN virtualenv --system-site-packages /home/app/env
RUN bash -c "source ~/env/bin/activate; pip install --no-cache-dir -U pip"
RUN bash -c "source ~/env/bin/activate; pip install --no-cache-dir python-ldap==3.2.0"

COPY --chown=app:app mytardis/requirements-base.txt ./
RUN bash -c "source ~/env/bin/activate; pip install --no-cache-dir -r requirements-base.txt"

COPY --chown=app:app mytardis/requirements-postgres.txt ./
RUN bash -c "source ~/env/bin/activate; pip install --no-cache-dir -r requirements-postgres.txt"

RUN mkdir -p ./tardis/apps/social_auth/
COPY --chown=app:app mytardis/tardis/apps/social_auth/requirements.txt ./tardis/apps/social_auth/requirements.txt
RUN bash -c "source ~/env/bin/activate; pip install --no-cache-dir -r tardis/apps/social_auth/requirements.txt"

RUN bash -c "source ~/env/bin/activate; pip install --no-cache-dir redis==2.10.6"
RUN bash -c "source ~/env/bin/activate; pip install --no-cache-dir django-redis"
RUN bash -c "source ~/env/bin/activate; pip install --no-cache-dir celery_haystack"
RUN bash -c "source ~/env/bin/activate; pip install --no-cache-dir pydicom"

# Adding mytardis src
COPY --chown=app:app mytardis /home/app/src
WORKDIR /home/app/src

# Installing javascript dependancies
RUN npm install --production

RUN rm -rf /home/app/build

# CMD bash -c "source ~/env/bin/activate; export DJANGO_SETTINGS_MODULE=tardis.settings; gunicorn -c gunicorn_settings.py -b unix:/tmp/gnicorn.socket -b 0.0.0.0:8000 --log-syslog wsgi:application"