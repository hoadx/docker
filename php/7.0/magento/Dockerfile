FROM alpine:3.7

LABEL maintainer="HoaDX <duongxuanhoa@gmail.com>"

# allow change uid & gid when create container
ENV USERNAME=www
ENV GROUPNAME=www
ENV USER_ID=5353
ENV GROUP_ID=5353
ENV CHANGE_OWNER=0

# persistent / runtime deps
ENV PHPIZE_DEPS \
		autoconf \
		dpkg-dev dpkg \
		file \
		g++ \
		gcc \
		libc-dev \
		make \
		pcre-dev \
		pkgconf \
		freetype \
		libpng \
		libjpeg-turbo \
		icu \
		re2c

ENV PHP_INI_DIR /usr/local/etc/php
ENV PHP_EXTRA_CONFIGURE_ARGS --enable-fpm --with-fpm-user=$USERNAME --with-fpm-group=$GROUPNAME
ENV PHP_CFLAGS="-fstack-protector-strong -fpic -fpie -O2"
ENV PHP_CPPFLAGS="$PHP_CFLAGS"
ENV PHP_LDFLAGS="-Wl,-O1 -Wl,--hash-style=both -pie"
ENV GPG_KEYS 1A4E8B7277C42E53DBA9C7B9BCAA30EA9C0D5763
ENV PHP_VERSION 7.0.4
ENV PHP_URL="http://php.net/get/php-7.0.4.tar.xz/from/this/mirror" PHP_ASC_URL="http://php.net/distributions/php-7.0.4.tar.xz.asc"
ENV PHP_SHA256="584e0e374e357a71b6e95175a2947d787453afc7f9ab7c55651c10491c4df532" PHP_MD5=""

RUN apk add --no-cache --virtual .persistent-deps \
		ca-certificates \
		curl \
		tar \
		xz \
		openssl

# ensure www user exists
RUN set -x \
	&& addgroup -g $GROUP_ID -S $USERNAME \
	&& adduser -u $USER_ID -s /bin/sh -D -S -G $GROUPNAME $USERNAME

RUN mkdir -p $PHP_INI_DIR/conf.d

RUN set -xe; \
	\
	apk add --no-cache --virtual .fetch-deps \
		gnupg \
	; \
	\
	mkdir -p /usr/src; \
	cd /usr/src; \
	\
	wget -O php.tar.xz "$PHP_URL"; \
	\
	if [ -n "$PHP_SHA256" ]; then \
		echo "$PHP_SHA256 *php.tar.xz" | sha256sum -c -; \
	fi; \
	if [ -n "$PHP_MD5" ]; then \
		echo "$PHP_MD5 *php.tar.xz" | md5sum -c -; \
	fi; \
	\
	if [ -n "$PHP_ASC_URL" ]; then \
		wget -O php.tar.xz.asc "$PHP_ASC_URL"; \
		export GNUPGHOME="$(mktemp -d)"; \
		for key in $GPG_KEYS; do \
			gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
		done; \
		gpg --batch --verify php.tar.xz.asc php.tar.xz; \
		rm -rf "$GNUPGHOME"; \
	fi; \
	\
	apk del .fetch-deps

COPY docker-php-source docker-php-ext-* /usr/local/bin/

RUN set -xe \
	&& apk add --no-cache --virtual .build-deps \
		$PHPIZE_DEPS \
		coreutils \
		curl-dev \
		libedit-dev \
		openssl-dev \
		libxml2-dev \
		sqlite-dev \
		icu-dev \
		libxslt-dev \
		libmcrypt-dev \
		freetype-dev \
		libpng-dev \
		libjpeg-turbo-dev \
	\
	&& export CFLAGS="$PHP_CFLAGS" \
		CPPFLAGS="$PHP_CPPFLAGS" \
		LDFLAGS="$PHP_LDFLAGS" \
	&& docker-php-source extract \
	&& cd /usr/src/php \
	&& gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)" \
	&& ./configure \
		--build="$gnuArch" \
		--with-config-file-path="$PHP_INI_DIR" \
		--with-config-file-scan-dir="$PHP_INI_DIR/conf.d" \
		--disable-cgi \
		--enable-ftp \
		--enable-mbstring \
		--enable-mysqlnd \
		--with-curl \
		--with-libedit \
		--with-openssl \
		--with-zlib \
		--with-pcre-regex=/usr \
		$PHP_EXTRA_CONFIGURE_ARGS \
	&& make -j "$(nproc)" \
	&& make install \
	&& { find /usr/local/bin /usr/local/sbin -type f -perm +0111 -exec strip --strip-all '{}' + || true; } \
	&& make clean \
	&& cd / \
	&& docker-php-source delete \
	\
	&& runDeps="$( \
		scanelf --needed --nobanner --format '%n#p' --recursive /usr/local \
			| tr ',' '\n' \
			| sort -u \
			| awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
	)" \
	&& apk add --no-cache --virtual .php-rundeps $runDeps \
	&& apk add --no-cache  \
	&& docker-php-ext-configure gd \
		--with-gd \
		--with-freetype-dir=/usr \
		--with-png-dir=/usr \
		--with-jpeg-dir=/usr \
	&& docker-php-ext-install mcrypt gd pdo_mysql intl soap xsl zip \
	&& curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer  && chmod +x /usr/local/bin/composer \
	\
	&& apk del .build-deps \
	&& pecl update-channels \
	&& rm -rf /tmp/pear ~/.pearrc

RUN set -ex \
	&& cd /usr/local/etc \
	&& if [ -d php-fpm.d ]; then \
		# for some reason, upstream's php-fpm.conf.default has "include=NONE/etc/php-fpm.d/*.conf"
		sed 's!=NONE/!=!g' php-fpm.conf.default | tee php-fpm.conf > /dev/null; \
		cp php-fpm.d/www.conf.default php-fpm.d/www.conf; \
	else \
		# PHP 5.x doesn't use "include=" by default, so we'll create our own simple config that mimics PHP 7+ for consistency
		mkdir php-fpm.d; \
		cp php-fpm.conf.default php-fpm.d/www.conf; \
		{ \
			echo '[global]'; \
			echo 'include=etc/php-fpm.d/*.conf'; \
		} | tee php-fpm.conf; \
	fi \
	&& { \
		echo '[global]'; \
		echo 'error_log = /proc/self/fd/2'; \
		echo; \
		echo '[www]'; \
		echo '; if we send this to /proc/self/fd/1, it never appears'; \
		echo 'access.log = /proc/self/fd/2'; \
		echo; \
		echo 'clear_env = no'; \
		echo; \
		echo '; Ensure worker stdout and stderr are sent to the main error log.'; \
		echo 'catch_workers_output = yes'; \
	} | tee php-fpm.d/docker.conf \
	&& { \
		echo '[global]'; \
		echo 'daemonize = no'; \
		echo; \
		echo '[www]'; \
		echo 'listen = [::]:9000'; \
	} | tee php-fpm.d/zz-docker.conf


COPY docker-php-ext-* docker-entrypoint /usr/local/bin/

ENTRYPOINT ["docker-entrypoint"]

EXPOSE 9000

CMD ["php-fpm"]
