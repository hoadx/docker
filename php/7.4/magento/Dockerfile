FROM hoadx/php-fpm:7.4

LABEL maintainer="HoaDX <duongxuanhoa@gmail.com>"

ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

# Install Magento require extensions
RUN chmod +x /usr/local/bin/install-php-extensions && \
    install-php-extensions bcmath gd intl pdo_mysql soap sockets xsl zip libxml openssl

# Install php opcache extension
RUN docker-php-ext-configure opcache --enable-opcache \
    && docker-php-ext-install opcache

# Install composer 1.10.26
RUN wget -O /usr/local/bin/composer https://getcomposer.org/download/1.10.26/composer.phar \
    && chmod +x /usr/local/bin/composer

# Enhanced composer download
RUN composer global require hirak/prestissimo

# Install git
RUN apk add --no-cache git bash mysql-client busybox-suid openssh

# Enable XDebug
RUN apk add --no-cache --virtual .build-deps $PHPIZE_DEPS \
    && pecl install xdebug-3.1.5 \
    && docker-php-ext-enable xdebug \
    && apk del -f .build-deps
# Disable XDebug by default
RUN rm /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

# enable www-data user 
RUN deluser www-data
RUN set -x \                                                                                                          
        && addgroup -g $GROUP_ID -S $USERNAME \                                                                       
        && adduser -u $USER_ID -s /bin/sh -D -S -G $GROUPNAME $USERNAME  
