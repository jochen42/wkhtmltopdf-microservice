FROM keymetrics/pm2:8-alpine

EXPOSE 80

RUN apk add --no-cache \
      xvfb \
      # Additionnal dependencies for better rendering
      ttf-freefont \
      fontconfig \
      dbus \

    # install bash, because node-wkhtmltopdf spawns it
    && apk add --no-cache \
      bash \

    # install curl to download xvfb-run and coreutils as dependency
    && apk add --no-cache \
      curl \
      coreutils \
    # in alpine mktemp does not work with dynamic TMPDIR, fix TMPDIR for xvfb-run
    && export TMPDIR=/tmp \
    && mkdir -p /tmp \

    # download xvfb-run script
    && curl 'https://gist.githubusercontent.com/tyleramos/3744901/raw/49079c854eff738b586f8a186fc186934c2a3961/xvfb-run.sh' -o /usr/bin/xvfb-run \
    && chmod +x /usr/bin/xvfb-run \

    # Install wkhtmltopdf from `testing` repository
    && apk add qt5-qtbase-dev \
      wkhtmltopdf \
      --no-cache \
      --repository https://dl-3.alpinelinux.org/alpine/edge/testing/ \
      --allow-untrusted \

    # cleanup apt cache
    && rm -rf /var/cache/apk/* \

    # Wrapper for xvfb
    && mv /usr/bin/wkhtmltopdf /usr/bin/wkhtmltopdf-origin && \
    echo $'#!/usr/bin/env sh\n\
xvfb-run --auto-servernum wkhtmltopdf-origin --use-xserver\
' > /usr/bin/wkhtmltopdf && \
    chmod +x /usr/bin/wkhtmltopdf



ENV PORT=80

# install sys deps
#RUN apk add --update bash

WORKDIR /app
COPY . /app

# Install app npm dependencies
RUN npm install --production

CMD [ "pm2-runtime", "process.yml" ]
