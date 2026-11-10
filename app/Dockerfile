FROM php:8.2-apache

# Habilita mod_rewrite se necessário
RUN a2enmod rewrite

# Copia os arquivos da aplicação
COPY . /var/www/html/

# Ajusta permissões
RUN chown -R www-data:www-data /var/www/html

EXPOSE 80
