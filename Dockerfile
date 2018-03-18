FROM node:8-alpine

EXPOSE 80

WORKDIR /app
COPY . /app

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

    # Install wkhtmltopdf from `testing` repository
    && apk add qt5-qtbase-dev \
      wkhtmltopdf \
      --no-cache \
      --repository https://dl-3.alpinelinux.org/alpine/edge/testing/ \
      --allow-untrusted \

    # cleanup apt cache
    && rm -rf /var/cache/apk/* \

    # Wrapper for xvfb
    && mv /usr/bin/wkhtmltopdf /usr/bin/wkhtmltopdf-origin \
    && cp /app/shell/wrapper.sh /usr/bin/wkhtmltopdf \
    && chmod +x /usr/bin/wkhtmltopdf

ENV PORT=80

# Install app npm dependencies
RUN npm i -g pm2 \
  && npm install --production

CMD [ "/app/entrypoint.sh" ]
