FROM ubuntu:18.04

# Making python and webapp directories
RUN groupadd -r webapp && useradd -r -g webapp webapp
RUN mkdir /appenv /home/webapp
RUN chown -R webapp:webapp /appenv /home/webapp
WORKDIR /home/webapp

# Installing basic dependancies
ENV DEBIAN_FRONTEND noninteractive
RUN echo 'APT::Get::Assume-Yes "true";' > /etc/apt/apt.conf.d/90assumeyes
RUN apt-get update && apt-get install \
    -qy \
    -o APT::Install-Recommends=false \
    -o APT::Install-Suggests=false \
    curl \
    sudo

# Installing ubuntu requirements
COPY mytardis/install-ubuntu-requirements.sh .
RUN bash install-ubuntu-requirements.sh

# Switch to webapp user
USER webapp

# Installing python virtualenv
RUN virtualenv --system-site-packages /appenv
RUN . /appenv/bin/activate; pip install -U pip
RUN . /appenv/bin/activate; pip install psycopg2-binary

# Installing python dependancies
COPY mytardis/requirements.txt \
    mytardis/requirements-base.txt \
    mytardis/requirements-docs.txt \
    mytardis/requirements-test.txt ./

COPY mytardis/tardis/apps ./tardis/apps/
RUN . /appenv/bin/activate; pip install -r requirements.txt

# # Installing javascript dependancies
# COPY package.json /home/webapp
# RUN npm install --production

# # Adding mytardis src
# COPY mytardis /home/webapp/

# EXPOSE 8000

# ADD --chown=webapp:webapp settings.py ./tardis/
# CMD . /appenv/bin/activate; gunicorn -c gunicorn_settings.py --bind 0.0.0.0:8000 wsgi:application
