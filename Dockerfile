FROM ubuntu:18.04

# Installing basic dependancies
ENV DEBIAN_FRONTEND noninteractive
RUN echo 'APT::Get::Assume-Yes "true";' > /etc/apt/apt.conf.d/90assumeyes
ENV LANG C.UTF-8

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
COPY --chown=app:app mytardis/install-ubuntu-py3-requirements.sh ./
RUN bash install-ubuntu-py3-requirements.sh

USER app    
RUN python3 -m venv /home/app/env
RUN /home/app/env/bin/pip install --no-cache-dir -U pip wheel

COPY --chown=app:app mytardis/requirements-base.txt ./
RUN /home/app/env/bin/pip install --no-cache-dir -r requirements-base.txt

COPY --chown=app:app mytardis/requirements-postgres.txt ./
RUN /home/app/env/bin/pip install --no-cache-dir -r requirements-postgres.txt

RUN mkdir -p ./tardis/apps/social_auth/
COPY --chown=app:app mytardis/tardis/apps/social_auth/requirements.txt ./tardis/apps/social_auth/requirements.txt
RUN /home/app/env/bin/pip install --no-cache-dir -r tardis/apps/social_auth/requirements.txt

RUN /home/app/env/bin/pip install --no-cache-dir redis
RUN /home/app/env/bin/pip install --no-cache-dir django-redis
RUN /home/app/env/bin/pip install --no-cache-dir pydicom

# Adding mytardis src
COPY --chown=app:app mytardis /home/app/src
WORKDIR /home/app/src

USER root
RUN apt-get update && apt-get install \
    -qy \
    -o APT::Install-Recommends=false \
    -o APT::Install-Suggests=false \
    gconf-service libxext6 libxfixes3 \
    libxi6 libxrandr2 libxrender1 \
    libcairo2 libcups2 libdbus-1-3 \
    libexpat1 libfontconfig1 libgcc1 \
    libgconf-2-4 libgdk-pixbuf2.0-0 libglib2.0-0 \
    libgtk-3-0 libnspr4 libpango-1.0-0 \
    libpangocairo-1.0-0 libstdc++6 libx11-6 \
    libx11-xcb1 libxcb1 libxcomposite1 \
    libxcursor1 libxdamage1 libxss1 \
    libxtst6 libappindicator1 libnss3 \
    libasound2 libatk1.0-0 libc6 \
    ca-certificates fonts-liberation lsb-release \
    xdg-utils wget

USER app

# Installing javascript dependancies
RUN npm install
RUN npm audit fix
RUN npm test

RUN rm -rf /home/app/build
