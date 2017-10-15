FROM alpine:edge

MAINTAINER HoaDX "duongxuanhoa@gmail.com"

# Default to UTF-8 file.encoding
ENV LANG=C.UTF-8
ENV PHPSTORM_VERSION=2017.2.4

RUN apk add --no-cache openjdk8 openssl \
    && rm -rf /tmp/* /var/cache/apk/*

RUN adduser -D -u 5353 www \
    && mkdir /home/www/.PhpStorm2017.2 \
    && touch /home/www/.PhpStorm2017.2/.keep \
    && chown -R www:www /home/www \
    && mkdir -p /opt/phpstorm \
    && wget -O - https://download-cf.jetbrains.com/webide/PhpStorm-${PHPSTORM_VERSION}.tar.gz | tar xzf - --strip-components=1 -C "/opt/phpstorm"

USER www

WORKDIR /home/www

CMD ["/opt/phpstorm/bin/phpstorm.sh"]
