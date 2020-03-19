ARG PHP_VERSION
ARG PHP_MEMCACHED_VERSION
# 镜像包
FROM php:${PHP_VERSION}

ARG SWOOLE_VERSION

# 设置时区为上海
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Ubuntu软件源选择中国的服务器
RUN sed -i 's/archive.ubuntu.com/mirrors.ustc.edu.cn/g' /etc/apt/sources.list

# 更新安装依赖包
RUN apt-get update && apt-get install -y \
        git \
        vim \
        curl \
        wget \
        openssl \
        imagemagick \
        libmagickwand-dev \
        libmagickcore-dev \
        libzip-dev \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        libxml2-dev \
		libssl-dev \
		libmemcached-dev

# 安装PHP核心拓展
RUN docker-php-ext-install \
        pdo_mysql \
        opcache \
        mysqli \
        intl \
        exif \
        zip \
        bcmath \
	&& docker-php-ext-configure gd \
        --with-freetype-dir=/usr/include/ \
        --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd \
    && rm -r /var/lib/apt/lists/*

COPY ./extensions /tmp/extensions
#WORKDIR /tmp/extensions #pecl 如果下载不了，可以这样用先下载，如果用了workdir下面就不用绝对路径了
RUN pecl install /tmp/extensions/memcached-3.0.3.tgz && docker-php-ext-enable memcached

# pecl安装mongodb、redis、imagick扩展
#RUN pecl install -o -f mongodb  \
#    && rm -rf /tmp/pear

# 加入php扩展
RUN docker-php-ext-enable memcached

# php swoole扩展
#RUN cd /usr/src \
#    && pecl download swoole-${SWOOLE_VER} \
#    && tar -zxvf swoole-${SWOOLE_VER}.tgz \
#    && cd swoole-${SWOOLE_VER} \
#    && phpize \
#    && ./configure --with-php-config=/usr/local/bin/php-config --enable-openssl \
#    && make \
#    && make install \
#    && echo "extension=swoole.so" > /usr/local/etc/php/conf.d/swoole.ini \
#    && rm -rf swoole-${SWOOLE_VERSION}.tgz \
#    && rm -rf swoole-${SWOOLE_VERSION}

# 安装composer并允许root用户运行
#ENV COMPOSER_ALLOW_SUPERUSER=1
#ENV COMPOSER_NO_INTERACTION=1
#ENV COMPOSER_HOME=/usr/local/share/composer
#RUN mkdir -p /usr/local/share/composer \
#    && curl -o /tmp/composer-setup.php https://getcomposer.org/installer \
#    && php /tmp/composer-setup.php --no-ansi --install-dir=/usr/local/bin --filename=composer --snapshot \
#    && rm -f /tmp/composer-setup.* \
#    # 配置composer中国全量镜像
#    && composer config -g repo.packagist composer https://packagist.phpcomposer.com
