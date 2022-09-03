FROM php:7.4-fpm-alpine

LABEL maintainer="HoaDX <duongxuanhoa@gmail.com>"

# allow change uid & gid when create container
ENV USERNAME=www-data
ENV GROUPNAME=www-data
ENV USER_ID=82
ENV GROUP_ID=82
ENV CHANGE_OWNER=0

COPY docker-entrypoint /usr/local/bin/
#COPY docker-entrypoint /usr/local/bin/docker-php-entrypoint

ENTRYPOINT ["docker-entrypoint"]

WORKDIR /var/www

CMD ["php-fpm"]
