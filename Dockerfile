FROM ubuntu:trusty
MAINTAINER Majan Paul <paul@urbancoyote.co>

# get the php 5.6 ubuntu repository
RUN sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E5267A6C
ADD config/php5-5.6.list /etc/apt/sources.list.d/

RUN apt-get update -y
RUN apt-get install -y apache2
RUN apt-get -y install \
php5 \
php5-mhash \
php5-mcrypt \
php5-curl \
php5-cli \
php5-mysql \
php5-gd \
php5-intl \
php5-xsl \
git \
curl \
mysql-client-5.6

ENV APACHE_RUN_USER mage
ENV APACHE_RUN_GROUP mage
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid

# set up apache
ADD config/magento2.conf /etc/apache2/sites-available/magento2.conf
RUN rm -f /etc/apache2/sites-enabled/000-default.conf
RUN rm -f /etc/apache2/sites-available/000-default.conf

# Enable Apache rewrite module
RUN a2enmod rewrite
RUN a2ensite magento2

# fix the configs here
RUN sed -i 's/80/0.0.0.0:80/g' /etc/apache2/ports.conf
RUN sed -ir 's/^;always_populate_raw_post_data.*$/always_populate_raw_post_data = -1/g' /etc/php5/apache2/php.ini
RUN sed -ir 's/^;always_populate_raw_post_data.*$/always_populate_raw_post_data = -1/g' /etc/php5/cli/php.ini
RUN sed -ir 's/^;date.timezone.*$/date.timezone = America\/LosAngeles/g' /etc/php5/apache2/php.ini
RUN sed -ir 's/^;date.timezone.*$/date.timezone = America\/LosAngeles/g' /etc/php5/cli/php.ini

# install magento2
ENV MAGE_ROOT /var/www/magento2/htdocs
RUN useradd -md /home/mage -s /usr/sbin/nologin mage
RUN mkdir -p $MAGE_ROOT
RUN chown mage:mage $MAGE_ROOT

#install composer
RUN curl -sS https://getcomposer.org/installer | php && \
mv composer.phar /usr/local/bin/composer

##RUN sudo -u mage cd /var/www/magento2/htdocs && \
RUN sudo -u mage composer create-project \
magento/community-edition $MAGE_ROOT 2.0.4 \
-s stable \
--prefer-source \
--no-interaction \
--no-install

RUN find $MAGE_ROOT -type d -exec chmod 740 {} \;
RUN find $MAGE_ROOT -type f -exec chmod 640 {} \;
RUN chmod 700 $MAGE_ROOT/bin/magento

ADD auth.json $MAGE_ROOT/auth.json
RUN sudo -u mage composer install --no-dev -d $MAGE_ROOT

EXPOSE 80

# Start up the Apache server
ADD scripts/runserver.sh /usr/local/bin/runserver.sh
RUN chmod +x /usr/local/bin/runserver.sh
ENTRYPOINT ["bash", "-c"]
CMD ["/usr/local/bin/runserver.sh"]
