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

# Making python and webapp directories
RUN groupadd -r webapp && useradd -r -g webapp webapp
RUN mkdir -p /home/webapp
RUN chown -R webapp:webapp /home/webapp

# Adding mytardis src
COPY --chown=webapp:webapp mytardis /home/webapp/code
WORKDIR /home/webapp/code

# Installing ubuntu requirements
RUN bash install-ubuntu-requirements.sh

USER webapp

# # Installing python virtualenv
RUN virtualenv --system-site-packages /home/webapp/appenv

# # Installing python dependancies
RUN bash -c "source ~/appenv/bin/activate; pip install -U pip"
RUN bash -c "source ~/appenv/bin/activate; pip install psycopg2-binary"
RUN bash -c "source ~/appenv/bin/activate; pip install -r requirements.txt"

# Installing javascript dependancies
RUN npm install --production

RUN mkdir -p /home/webapp/logs
RUN chown -R webapp:webapp /home/webapp/logs

ADD --chown=webapp:webapp settings.py ./tardis/

EXPOSE 8000
ADD --chown=webapp:webapp run-mytardis.sh ./

# USER webapp
# CMD bash service gunicorn restart

CMD /bin/bash run-mytardis.sh
