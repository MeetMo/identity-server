#
# A development custom docker image for getting started
# Get the base image
FROM nexhe/custom_curity:latest
# Get the base image

# Copy in base resources
COPY idsvr/log4j2.xml /opt/idsvr/etc/

# Copy the HAAPI web sample to the root web folder of runtime nodes

# Extra tools, for development troubleshooting only
USER root
COPY haapi-web-example/* /opt/idsvr/usr/share/webroot/
RUN apt-get update
RUN apt-get install curl -y
USER idsvr

expose 6749
expose 7455
