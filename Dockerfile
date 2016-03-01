FROM drupal:8

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get -y install git-all php5-curl mysql-client openssh-server wget
 
# Install Composer.
RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer

# Install Drush 8.
RUN wget http://files.drush.org/drush.phar \
 && chmod +x drush.phar \
 && mv drush.phar /usr/local/bin/drush

COPY data/settings.php /var/www/html/sites/default/settings.php

RUN usermod -u 1000 www-data \
    && chown www-data:www-data /var/www/html/sites/default/settings.php \
    && mkdir -p /var/www/html/sites/default/files/translations \
    && chown -R www-data:www-data /var/www/html/sites/default/ \
    && mkdir /var/www/configuration \
    && chown -R www-data:www-data /var/www/configuration

#ssh acces to allow drush alias access
RUN useradd -d /var/www drupaluser -G www-data -s /bin/bash
COPY assets/ssh/sshd_config /etc/ssh/sshd_config
RUN mkdir -p /var/www/.ssh
COPY assets/ssh/authorized_keys /var/www/.ssh/
RUN chmod 700 /var/www/.ssh/ -R
RUN chmod 600 /var/www/.ssh/*
RUN chown drupaluser /var/www/.ssh/ -R
RUN /etc/init.d/ssh start

# add modules, themes and libraries
ADD libraries /var/www/html/libraries
ADD themes /var/www/html/themes
ADD modules /var/www/html/modules
