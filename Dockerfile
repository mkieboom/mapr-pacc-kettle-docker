# Kettle on MapR PACC
#
# VERSION 0.1 - not for production, use at own risk
#

#
# Using MapR PACC as the base image
# For specific versions check: https://hub.docker.com/r/maprtech/pacc/tags/
#FROM maprtech/pacc:5.2.1_3.0_centos7
FROM maprtech/pacc:5.2.0_2.0_centos7

MAINTAINER mkieboom @mapr.com


# Fix the MapR repositories as they are currently pointing to MapR internal repo's
RUN sed -ie "s/artifactory.devops.lab\/artifactory\/prestage/package.mapr.com/g" /etc/yum.repos.d/mapr_eco.repo
RUN sed -ie "s/artifactory.devops.lab\/artifactory\/prestage/package.mapr.com/g" /etc/yum.repos.d/mapr_core.repo

# Install prerequisites
RUN yum install -y unzip

# Donwload Pentaho Data Integration 5.4.0.1-130
RUN curl -L -o /opt/pdi-ce-5.4.0.1-130.zip https://downloads.sourceforge.net/project/pentaho/Data%20Integration/5.4/pdi-ce-5.4.0.1-130.zip

# Copy Pentaho Data Integration 5.4.0.1-130 into the container (instead of Downloading)
# COPY pdi-ce-5.4.0.1-130.zip /opt/

# Install Pentaho Data Integration 5.4.0.1-130
RUN unzip /opt/pdi-ce-5.4.0.1-130.zip -d /opt/ && \
    chmod +x /opt/data-integration/*.sh && \
    rm -rf /opt/pdi-ce-5.4.0.1-130.zip

# Download the MapR v5.2.0 Shim (TEMPORARY LOCATED AT S3)
RUN curl -L -o /opt/pentaho-hadoop-shims-mapr520-package-54.2015.06.01.zip https://s3-eu-west-1.amazonaws.com/mkieboom/kettle/pentaho-hadoop-shims-mapr520-package-54.2015.06.01.zip

# Copy the MapR v5.2.0 Shim (instead of Downloading)
# COPY pentaho-hadoop-shims-mapr520-package-54.2015.06.01.zip /opt/

# Install the MapR v5.2.0 Shim
RUN unzip /opt/pentaho-hadoop-shims-mapr520-package-54.2015.06.01.zip -d /opt/data-integration/plugins/pentaho-big-data-plugin/hadoop-configurations/ && \
    rm -rf /opt/pentaho-hadoop-shims-mapr520-package-54.2015.06.01.zip

# Configure Kettle to make use of MapR Shim
RUN sed -ie "s/active.hadoop.configuration=hadoop-20/active.hadoop.configuration=mapr520/g" /opt/data-integration/plugins/pentaho-big-data-plugin/plugin.properties

# Copy the hbase-site.xml to the Kettle MapR Shim folder
COPY hbase-site.xml /opt/data-integration/plugins/pentaho-big-data-plugin/hadoop-configurations/mapr520/hbase-site.xml

# Copy the core-site.xml to the Kettle MapR Shim folder.
# Used to set the default MapR-DB table location mapping (eg: /*:/dataset)
COPY core-site.xml /opt/data-integration/plugins/pentaho-big-data-plugin/hadoop-configurations/mapr520/core-site.xml

# Use Kettle pan.sh (for transformations) or kitchen.sh (for jobs) to launch the ETl processes
# For example, to launch:
# /opt/data-integration/pan.sh -file /mapr/demo.mapr.com/kettle_export/maprdb-production-transformation-hbase1.1.1.xml
# Would look like:
# CMD ["start","sh","-c","/opt/data-integration/pan.sh -file /mapr/demo.mapr.com/kettle_export/maprdb-production-transformation-hbase1.1.1.xml"]
