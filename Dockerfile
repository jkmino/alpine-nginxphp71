FROM alpine:3.7
MAINTAINER Jose Camino <jcamino@mandu.pe>

RUN apk --update add wget \
    nginx \
    supervisor \
    bash \
    curl \
    git \
    vim \
    nodejs \
    git \
    openssl-dev \
    openssh \
    linux-headers \
    libmcrypt-dev \
    libpng-dev \
    musl  \
    busybox \
    alpine-baselayout \
    alpine-keys \
    zlib \
    libcrypto1.0 \
    libssl1.0 \
    apk-tools \
    scanelf \
    musl-utils \
    musl-dev \
    make \
    gcc \
    libc-utils \
    php7-fpm \
    php7-gd \
    php7-pdo \
    php7-pear \
    php7-dev \
    php7-pdo_mysql \
    php7-apcu \
    php7-bcmath \
    php7-ctype \
    php7-curl \
    php7-dom \
    php7-fileinfo \
    php7-iconv \
    php7-intl \
    php7-json \
    php7-openssl \
    php7-opcache \
    php7-mbstring \
    php7-memcached \
    php7-mcrypt \
    php7-mysqlnd \
    php7-mysqli \
    php7-pcntl \
    php7-pgsql \
    php7-pdo_mysql \
    php7-pdo_pgsql \
    php7-pdo_sqlite \
    php7-phar \
    php7-posix \
    php7-session \
    php7-simplexml \
    php7-soap \
    php7-sockets \
    php7-tokenizer \
    php7-xml \
    php7-xmlreader \
    php7-xmlwriter \
    php7-xsl \
    php7-zip \
    php7-zlib && \
    rm /var/cache/apk/*            && \
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer && \
    mkdir -p /etc/nginx            && \
    mkdir -p /var/www/app01          && \
    mkdir -p /run/nginx            && \
    mkdir -p /var/log/supervisor   && \
    rm /etc/nginx/nginx.conf


RUN apk update && apk add -u yarn
RUN apk --update upgrade --available && sync

RUN pecl install mongodb
RUN echo "extension=mongodb.so" >> /etc/php7/php.ini

ADD ./configs/nginx.conf /etc/nginx/nginx.conf
ADD ./configs/supervisord.conf /etc/supervisord.conf
ADD ./configs/start.sh /start.sh
ADD ./index.php /var/www/app/index.php

# tweak php-fpm config
RUN sed -i -e "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g" /etc/php7/php.ini                                           && \
    sed -i -e "s/upload_max_filesize\s*=\s*2M/upload_max_filesize = 500M/g" /etc/php7/php.ini                          && \
    sed -i -e "s/post_max_size\s*=\s*8M/post_max_size = 500M/g" /etc/php7/php.ini                                      && \
    sed -i -e "s/variables_order = \"GPCS\"/variables_order = \"EGPCS\"/g" /etc/php7/php.ini                           && \
    sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php7/php-fpm.conf                                         && \
    sed -i -e "s/error_log = \/var\/log\/php-fpm.log;/error_log = \/proc\/self\/fd\/2;/g" /etc/php7/php-fpm.conf       && \
    sed -i -e "s/pm.max_children = 5/pm.max_children = 9/g" /etc/php7/php-fpm.conf                                     && \
    sed -i -e "s/pm.start_servers = 2/pm.start_servers = 3/g" /etc/php7/php-fpm.conf                                   && \
    sed -i -e "s/pm.min_spare_servers = 1/pm.min_spare_servers = 2/g" /etc/php7/php-fpm.conf                           && \
    sed -i -e "s/pm.max_spare_servers = 3/pm.max_spare_servers = 4/g" /etc/php7/php-fpm.conf                           && \
    sed -i -e "s/;pm.max_requests = 500/pm.max_requests = 200/g" /etc/php7/php-fpm.conf                                && \
    sed -i -e "s/user = nobody/user = nginx/g" /etc/php7/php-fpm.conf                                                  && \
    sed -i -e "s/group = nobody/group = nginx/g" /etc/php7/php-fpm.conf                                                && \
    sed -i -e "s/;listen.mode = 0660/listen.mode = 0666/g" /etc/php7/php-fpm.conf                                      && \
    sed -i -e "s/;listen.owner = nobody/listen.owner = nginx/g" /etc/php7/php-fpm.conf                                 && \
    sed -i -e "s/;listen.group = nobody/listen.group = nginx/g" /etc/php7/php-fpm.conf                                 && \
    sed -i -e "s/listen = 127.0.0.1:9000/listen = \/var\/run\/php-fpm.sock/g" /etc/php7/php-fpm.conf                   && \
    rm -Rf /etc/nginx/conf.d/*                && \
    rm -Rf /etc/nginx/sites-available/default && \
    mkdir -p /etc/nginx/ssl/                  && \
    chmod 755 /start.sh                       && \
    find /etc/php7/conf.d/ -name "*.ini" -exec sed -i -re 's/^(\s*)#(.*)/\1;\2/g' {} \;

ADD ./configs/site_metrics.conf /etc/nginx/conf.d/site.conf
ADD ./configs/www.conf /etc/php7/php-fpm.d/www.conf
RUN mkdir ~/.ssh/
#ADD ./configs/ssh/config ~/.ssh/config
ADD ./configs/ssh/id_rsa.pub /root/.ssh/id_rsa.pub
ADD ./configs/ssh/id_rsa /root/.ssh/id_rsa
ADD ./configs/ssh/known_hosts /root/.ssh/known_hosts
# Expose Ports
EXPOSE 443 80

# Start Supervisord
CMD ["/bin/sh", "/start.sh"]
