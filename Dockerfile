FROM ubuntu:18.04

# Installing basic dependancies
ENV DEBIAN_FRONTEND noninteractive
RUN echo 'APT::Get::Assume-Yes "true";' > /etc/apt/apt.conf.d/90assumeyes
RUN apt-get update && apt-get install \
    -qy \
    -o APT::Install-Recommends=false \
    -o APT::Install-Suggests=false \
    curl \
    sudo \
    memcached \
    python-memcache

# Adding mytardis src
COPY mytardis /home/webapp/

# Making python and webapp directories
RUN groupadd -r webapp && useradd -r -g webapp webapp
RUN chown -R webapp:webapp /home/webapp
WORKDIR /home/webapp

# Installing ubuntu requirements
RUN bash install-ubuntu-requirements.sh

# Switch to webapp user

# Installing python virtualenv
RUN pip install -U pip
RUN pip install psycopg2-binary

# Installing python dependancies
RUN pip install -r requirements.txt

USER webapp

# Installing javascript dependancies
RUN npm install --production

USER root
RUN mkdir -p /home/logs
RUN chown -R webapp:webapp /home/logs
USER webapp

ADD --chown=webapp:webapp settings.py ./tardis/

EXPOSE 8000
ADD --chown=webapp:webapp run-mytardis.sh ./
CMD /bin/bash run-mytardis.sh
