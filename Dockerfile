FROM --platform=linux/amd64 golang:1.15 AS entrykit
RUN go get -v -ldflags "-s -w" github.com/progrium/entrykit/cmd

FROM --platform=linux/amd64 centos:7.8.2003

#locale 追加
RUN sed -i -e '/override_install_langs/s/$/,ja_JP.utf8/g' /etc/yum.conf \
 && yum -y update \
 && yum -y reinstall glibc-common

ENV TZ="Asia/Tokyo" \
    LANG="ja_JP.UTF-8" \
    LANGUAGE="ja_JP:ja" \
    LC_ALL="ja_JP.UTF-8"

RUN yum install -y http://rpms.famillecollet.com/enterprise/remi-release-7.rpm \
                   https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm \
 && yum install -y postgresql10 \
                   postfix cyrus-sasl-plain \
 && mkfifo /var/spool/postfix/public/pickup \
 && yum install -y --enablerepo=remi,remi-php73 \
                   php \
                   php-opcache \
                   php-mbstring \
                   php-pdo \
                   php-pecl-memcache \
                   php-pecl-memcached \
                   php-pecl-redis \
                   php-pecl-imagick \
                   php-mcrypt \
                   php-mysqlnd \
                   php-xml \
                   php-gd \
                   php-devel \
                   php-pgsql \
                   php-pecl-ssh2 \
                   php-process \
                   php-intl \
                   php-pear \
                   php-pecl-apcu \
                   php-pecl-apcu-bc \
                   php-pecl-zip \
                   openssl \
 && rm -rf /var/cache/yum/* \
 && yum clean all

ENV COMPOSER_ALLOW_SUPERUSER 1

## composer
RUN curl -sS https://getcomposer.org/installer | php -- --version=1.10.20 --install-dir=/usr/local/bin \
 && mv /usr/local/bin/composer.phar /usr/local/bin/composer \
 && composer global require hirak/prestissimo

COPY --from=entrykit /go/bin/cmd /bin/entrykit
RUN entrykit --symlink

COPY startup.sh /usr/local/bin/startup.sh
RUN chmod 755 /usr/local/bin/startup.sh

CMD ["startup.sh"]
