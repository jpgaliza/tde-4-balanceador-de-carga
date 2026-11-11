FROM php:8.2-apache

RUN a2enmod rewrite

RUN echo '<Directory /var/www/html>\n    Options -Indexes +FollowSymLinks\n    AllowOverride All\n    FallbackResource /index.php\n    Require all granted\n</Directory>' > /etc/apache2/conf-available/loadbalancer.conf \
    && a2enconf loadbalancer

COPY index.php /var/www/html/index.php

RUN chown -R www-data:www-data /var/www/html

EXPOSE 80
