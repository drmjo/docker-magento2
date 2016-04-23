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
curl

# Enable Apache rewrite module
RUN a2enmod rewrite

ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid

# set up apache
ADD config/magento2.conf /etc/apache2/sites-available/magento2.conf
RUN rm -f /etc/apache2/sites-enabled/000-default.conf
RUN rm -f /etc/apache2/sites-available/000-default.conf
#this makes sure apache listens on ipv4
RUN sed -i 's/80/0.0.0.0:80/g' /etc/apache2/ports.conf

# install magento2
RUN mkdir -p /var/www/magento2/htdocs
RUN cd /var/www/magento2/htdocs
RUN curl -sS https://getcomposer.org/installer | php
#RUN php composer.phar install

EXPOSE 80
CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
