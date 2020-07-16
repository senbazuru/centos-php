FROM centos:7.8.2003

#locale 追加
RUN sed -i -e '/override_install_langs/s/$/,ja_JP.utf8/g' /etc/yum.conf \
 && yum -y reinstall glibc-common

ENV TZ="Asia/Tokyo" \
    LANG="ja_JP.UTF-8" \
    LANGUAGE="ja_JP:ja" \
    LC_ALL="ja_JP.UTF-8"

RUN yum install -y http://rpms.famillecollet.com/enterprise/remi-release-7.rpm \
                   https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm \
 && yum install -y postgresql10 \
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
                   ssmtp\
 && rm -rf /var/cache/yum/* \
 && yum clean all

## composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin \
 && mv /usr/local/bin/composer.phar  /usr/local/bin/composer \
 && composer global require hirak/prestissimo

ENV ENTRYKIT_VERSION 0.4.0
RUN curl -LO https://github.com/progrium/entrykit/releases/download/v${ENTRYKIT_VERSION}/entrykit_${ENTRYKIT_VERSION}_Linux_x86_64.tgz \
 && tar zxvf entrykit_${ENTRYKIT_VERSION}_Linux_x86_64.tgz \
 && mv entrykit /bin/entrykit \
 && chmod +x /bin/entrykit \
 && entrykit --symlink

COPY startup.sh /usr/local/bin/startup.sh
RUN chmod 755 /usr/local/bin/startup.sh

CMD ["startup.sh"]
