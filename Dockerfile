# Usa imagem oficial do PHP com Apache
FROM php:8.2-apache

# Instala extensões necessárias para Laravel
RUN apt-get update && apt-get install -y \
    git \
    curl \
    unzip \
    libzip-dev \
    libonig-dev \
    libpq-dev \
    zip \
    && docker-php-ext-install pdo pdo_mysql zip

# Instala o Composer globalmente
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Define o diretório de trabalho no container
WORKDIR /var/www/html

# Copia os arquivos da aplicação Laravel para dentro do container
COPY . /var/www/html

# Dá permissões corretas ao Laravel
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html/storage \
    && chmod -R 755 /var/www/html/bootstrap/cache


# Habilita o mod_rewrite do Apache (necessário para Laravel)
RUN a2enmod rewrite

# Instala as dependências do Laravel
RUN composer install --no-dev --optimize-autoloader

# Configura o Apache para apontar para a pasta public do Laravel
RUN echo '<VirtualHost *:80>\n\
    DocumentRoot /var/www/html/public\n\
    <Directory /var/www/html/public>\n\
        AllowOverride All\n\
        Require all granted\n\
    </Directory>\n\
</VirtualHost>' > /etc/apache2/sites-available/000-default.conf

# Expõe a porta padrão do Apache
EXPOSE 80

# Comando de inicialização padrão do Apache
CMD ["apache2-foreground"]
