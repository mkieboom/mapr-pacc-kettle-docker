# Kettle on MapR PACC
#
# VERSION 0.1 - not for production, use at own risk
#

#
# Using MapR PACC as the base image
#
FROM maprtech/pacc

MAINTAINER mkieboom @mapr.com


# Fix the MapR repositories as they are currently pointing to MapR internal repo's

RUN sed -ie "s/artifactory.devops.lab\/artifactory\/prestage/package.mapr.com/g" /etc/yum.repos.d/mapr_eco.repo
RUN sed -ie "s/artifactory.devops.lab\/artifactory\/prestage/package.mapr.com/g" /etc/yum.repos.d/mapr_core.repo

# Install prerequisites
RUN yum install -y unzip

# Donwload & install Pentaho Data Integration 5.4.0.1-130
RUN curl -L -o /opt/pdi-ce-5.4.0.1-130.zip https://downloads.sourceforge.net/project/pentaho/Data%20Integration/5.4/pdi-ce-5.4.0.1-130.zip && \
    unzip /opt/pdi-ce-5.4.0.1-130.zip -d /opt/ && \
    chmod +x /opt/data-integration/*.sh

# Download & Install the MapR v5.2.0 Shim (TEMPORARY LOCATED AT S3)
RUN curl -L -o /opt/pentaho-hadoop-shims-mapr520-package-54.2015.06.01.zip https://s3-eu-west-1.amazonaws.com/mkieboom/kettle/pentaho-hadoop-shims-mapr520-package-54.2015.06.01.zip && \
    unzip /opt/pentaho-hadoop-shims-mapr520-package-54.2015.06.01.zip -d /opt/data-integration/plugins/pentaho-big-data-plugin/hadoop-configurations/


# Copy the hbase-site.xml to the Kettle MapR Shim folder
COPY hbase-site.xml /opt/data-integration/plugins/pentaho-big-data-plugin/hadoop-configurations/mapr520/hbase-site.xml

# Use Kettle pan.sh (transformations) or kitchen.sh (jobs) to launch the ETl processes

