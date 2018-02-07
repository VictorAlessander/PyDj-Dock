FROM python:3.5

USER root

# Setup and install base system software

RUN echo "locales locales/locales_to_be_generated multiselect en_US.UTF-8 UTF-8" | debconf-set-selections \
    && echo "locales locales/default_environment_locale select en_US.UTF-8" | debconf-set-selections \
    && apt-get update \
    && apt-get --yes --no-install-recommends install \
        locales tzdata ca-certificates sudo \
        bash-completion iproute2 curl nano tree \
    && rm -rf /var/lib/apt/lists/*
ENV LANG en_US.UTF-8

# User creation start

RUN addgroup \
        --quiet \
        --gid 1000 \
        dockuser \
    && adduser \
        --quiet \
        --home /home/dockuser \
        --uid 1000 \
        --ingroup dockuser \
        --disabled-password \
        --shell /bin/bash \
        --gecos 'Python 3' \
        dockuser \
    && usermod \
        --append \
        --groups sudo \
        dockuser \
    && echo 'dockuser ALL=NOPASSWD: ALL' > /etc/sudoers.d/dockuser

# Python environment configuration start

ENV PYTHONUNBUFFERED 1

RUN mkdir /home/dockuser/code
WORKDIR /home/dockuser/code
ADD requirements.txt /home/dockuser/code/
RUN pip install -r requirements.txt
ADD . /home/dockuser/code/

EXPOSE 8000

USER dockuser
