### Chemin dans la VM : /docker/monApache/Dockerfile

# =============================================================================
#
# container d'exercice pour TP de TIW1-PAI à l'UCBL
# 
# =============================================================================
FROM ubuntu:vivid

MAINTAINER Fabien Rico<fabien.rico@univ-lyon1.fr>

# -----------------------------------------------------------------------------
# Configuration du proxy pour fonctionnement en interne à l'UCBL
# -----------------------------------------------------------------------------
RUN echo "\
export http_proxy=http://proxy.univ-lyon1.fr:3128;\
export ftp_proxy=http://proxy.univ-lyon1.fr:3128;\
export https_proxy=http://proxy.univ-lyon1.fr:3128;\
export all_proxy=http://proxy.univ-lyon1.fr:3128;\
export HTTP_PROXY=http://proxy.univ-lyon1.fr:3128;\
export FTP_PROXY=http://proxy.univ-lyon1.fr:3128;\
export HTTPS_PROXY=http://proxy.univ-lyon1.fr:3128;\
export ALL_PROXY=http://proxy.univ-lyon1.fr:3128;\
" >> /etc/bash.bashrc

RUN echo 'Acquire::http::Proxy "http://proxy.univ-lyon1.fr:3128";' > /etc/apt/apt.conf.d/99proxy

# changement des repos pour que ce soit l'in2p3
RUN sed -i "{s#^\(deb.*\) http://[^/]*/ubuntu/#\\1 http://mirror.in2p3.fr/linux/ubuntu/#}" /etc/apt/sources.list

# -----------------------------------------------------------------------------
# Base Apache
# -----------------------------------------------------------------------------
RUN  apt-get update && apt-get -y install apache2 \ 
	php-pear php5-ldap php-auth php5-mysql php5-common \
	libapache2-mod-php5 && apt-get clean


# -----------------------------------------------------------------------------
# Global Apache configuration changes
# -----------------------------------------------------------------------------
# RUN sed -i \
    # -e 's~^ServerSignature On$~ServerSignature Off~g' \
    # -e 's~^ServerTokens OS$~ServerTokens Prod~g' \
    # -e 's~^#ExtendedStatus On$~ExtendedStatus On~g' \
    # -e 's~^DirectoryIndex \(.*\)$~DirectoryIndex \1 index.php~g' \
    # -e 's~^NameVirtualHost \(.*\)$~#NameVirtualHost \1~g' \
    # /etc/httpd/conf/httpd.conf

RUN sed -i \
     -e 's~^#ServerName .*$~ServerName MatheuxEstGenial.univ-lyon1.fr:80~g' \
     /etc/apache2/sites-enabled/000-default.conf

RUN sed -ie 's/display_errors = Off/display_errors = On/' /etc/php5/apache2/php.ini

# -----------------------------------------------------------------------------
# Disable Apache directory indexes
# -----------------------------------------------------------------------------
#RUN sed -i \
#    -e 's~^IndexOptions \(.*\)$~#IndexOptions \1~g' \
#    -e 's~^IndexIgnore \(.*\)$~#IndexIgnore \1~g' \
#    -e 's~^AddIconByEncoding \(.*\)$~#AddIconByEncoding \1~g' \
#    -e 's~^AddIconByType \(.*\)$~#AddIconByType \1~g' \
#    -e 's~^AddIcon \(.*\)$~#AddIcon \1~g' \
#    -e 's~^DefaultIcon \(.*\)$~#DefaultIcon \1~g' \
#    -e 's~^ReadmeName \(.*\)$~#ReadmeName \1~g' \
#    -e 's~^HeaderName \(.*\)$~#HeaderName \1~g' \
#    /etc/httpd/conf/httpd.conf

# -----------------------------------------------------------------------------
# Disable Apache language based content negotiation
# -----------------------------------------------------------------------------
#RUN sed -i \
#    -e 's~^LanguagePriority \(.*\)$~#LanguagePriority \1~g' \
#    -e 's~^ForceLanguagePriority \(.*\)$~#ForceLanguagePriority \1~g' \
#    -e 's~^AddLanguage \(.*\)$~#AddLanguage \1~g' \
#    /etc/httpd/conf/httpd.conf


# -----------------------------------------------------------------------------
# Custom Apache configuration
# -----------------------------------------------------------------------------
#RUN echo $'\n#\n# Custom configuration\n#' >> /etc/httpd/conf/httpd.conf \
#    && echo 'Options -Indexes' >> /etc/httpd/conf/httpd.conf \
#    && echo 'Listen 8443' >> /etc/httpd/conf/httpd.conf \
#    && echo 'NameVirtualHost *:80' >> /etc/httpd/conf/httpd.conf \
#    && echo 'NameVirtualHost *:8443' >> /etc/httpd/conf/httpd.con
# ----------------------------------------

WORKDIR /var/www/html

ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2

#RUN /bin/ln -sf ../sites-available/default-ssl /etc/apache2/sites-enabled/001-default-ssl
#RUN /bin/ln -sf ../mods-available/ssl.conf /etc/apache2/mods-enabled/
#RUN /bin/ln -sf ../mods-available/ssl.load /etc/apache2/mods-enabled/

#COPY apache2-foreground /usr/local/bin/
#RUN  chmod a+x /usr/local/bin/apache2-foreground

# EXPOSE 80
CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]

