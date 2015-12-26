FROM phusion/baseimage

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

RUN \
  apt-get update && \
  apt-get install -y apache2 libapache2-mod-php5 libapache2-mod-security2 curl && \
  curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
  a2enmod php5 && \
  a2enmod rewrite && \
  a2enmod cgi && \
  a2enmod headers && \
  mv /etc/modsecurity/modsecurity.conf-recommended /etc/modsecurity/modsecurity.conf && \
  sed -i "s/SecRuleEngine DetectionOnly/SecRuleEngine On/" /etc/modsecurity/modsecurity.conf && \
  sed -i "s/SecResponseBodyAccess On/SecResponseBodyAccess Off/" /etc/modsecurity/modsecurity.conf && \
  echo 'SecRule REMOTE_ADDR "^200.10.12.55$" "phase:1,t:none,nolog,allow,ctl:ruleEngine=Off,ctl:auditEngine=Off,id:9995"' >> /etc/modsecurity/modsecurity.conf && \
  echo 'SecRule REMOTE_ADDR "^200.10.14.162$" "phase:1,t:none,nolog,allow,ctl:ruleEngine=Off,ctl:auditEngine=Off,id:9996"' >> /etc/modsecurity/modsecurity.conf && \
  echo 'SecRule REMOTE_ADDR "^200.10.14.163$" "phase:1,t:none,nolog,allow,ctl:ruleEngine=Off,ctl:auditEngine=Off,id:9997"' >> /etc/modsecurity/modsecurity.conf && \
  echo 'SecRule REMOTE_ADDR "^200.10.14.34$" "phase:1,t:none,nolog,allow,ctl:ruleEngine=Off,ctl:auditEngine=Off,id:9998"' >> /etc/modsecurity/modsecurity.conf && \
  echo 'SecRule REMOTE_ADDR "^200.10.14.177$" "phase:1,t:none,nolog,allow,ctl:ruleEngine=Off,ctl:auditEngine=Off,id:9999"' >> /etc/modsecurity/modsecurity.conf

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Reefer templates
RUN  curl -L https://github.com/docker-infra/reefer/releases/download/v0.0.3/reefer.gz | \
     gunzip > /usr/bin/reefer && chmod a+x /usr/bin/reefer

ADD cgi-bin /var/www/webpay
ADD templates /templates

VOLUME ["/var/www/webpay/log"]

RUN \
  mkdir /var/www/webpay/maestros && \
  chmod 755 /var/www/webpay && \
  chmod 755 /var/www/webpay/* && \
  chmod 775 /var/www/webpay/log && \
  chown -R www-data:www-data /var/www/webpay

EXPOSE 80
EXPOSE 443

ADD apache/run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh
WORKDIR /var/www/webpay

CMD ["/usr/bin/reefer", \
  "-t", "/templates/000-default.conf.tmpl:/etc/apache2/sites-enabled/000-default.conf", \
  "-t", "/templates/privada.pem.tmpl:/var/www/webpay/maestros/privada.pem", \
  "-t", "/templates/tbk_public_key.pem.tmpl:/var/www/webpay/maestros/tbk_public_key.pem", \
  "-t", "/templates/tbk_config.dat.tmpl:/var/www/webpay/datos/tbk_config.dat", \
  "/usr/local/bin/run.sh"]
