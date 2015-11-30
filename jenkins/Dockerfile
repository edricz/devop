#
# INME TECHNOLOGIES CONFIDENTIAL
# ______________________________
#
#  [2015] - [2016] Inme Technologies Incorporated
#  All Rights Reserved.
#
# NOTICE: All information contained herein is, and remains the property of Inme Technologies
# Incorporated and its suppliers, if any.  The intellectual and technical concepts contained herein
# are proprietary to Inme Technologies Incorporated and its suppliers and may be covered by
# U.S. and Foreign Patents, patents in process, and are protected by trade secret or copyright
# law. Dissemination of this information or reproduction of this material is strictly forbidden
# unless prior written permission is obtained from Inme Technologies Incorporated.
#

FROM i-docker.inme.io/s3ql:latest

# Install Java 8
ENV JAVA_VERSION=8 JAVA_UPDATE=66 JAVA_BUILD=17 JAVA_HOME=/usr/local/lib/java
ENV JAVA_URL="http://download.oracle.com/otn-pub/java/jdk/${JAVA_VERSION}u${JAVA_UPDATE}-b${JAVA_BUILD}/jdk-${JAVA_VERSION}u${JAVA_UPDATE}-linux-x64.tar.gz"
ENV PATH=$PATH:${JAVA_HOME}/bin
RUN wget --quiet \
         --no-cookies \
         --no-check-certificate \
         --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" \
         -O /tmp/jdk.tar.gz $JAVA_URL && \
    tar xzf /tmp/jdk.tar.gz -C /tmp && \
    rm /tmp/jdk.tar.gz && \
    mv /tmp/jdk1* $JAVA_HOME && \
    update-alternatives --install "/usr/bin/java" "java" "${JAVA_HOME}/bin/java" 9999 && \
    update-alternatives --install "/usr/bin/javac" "javac" "${JAVA_HOME}/bin/javac" 9999 && \
    update-alternatives --install "/usr/bin/javaws" "javaws" "${JAVA_HOME}/bin/javaws" 9999 && \
    chmod a+x /usr/bin/java /usr/bin/javaws /usr/bin/javac

ENV MOUNT_DIR /var/jenkins
ENV JENKINS_HOME $MOUNT_DIR/data
ENV JENKINS_SLAVE_AGENT_PORT 50000

# Jenkins is run with user `jenkins`, uid = 1000
# If you bind mount a volume from the host or a data container, 
# ensure you use the same uid
RUN useradd -d "$JENKINS_HOME" -u 1000 -m -s /bin/bash jenkins

# `/usr/share/jenkins/ref/` contains all reference configuration we want 
# to set on a fresh new installation. Use it to bundle additional plugins 
# or config file with your custom jenkins Docker image.
RUN mkdir -p /usr/share/jenkins/ref/init.groovy.d

ENV TINI_SHA 066ad710107dc7ee05d3aa6e4974f01dc98f3888

# Use tini as subreaper in Docker container to adopt zombie processes 
RUN curl -fL https://github.com/krallin/tini/releases/download/v0.5.0/tini-static -o /bin/tini && chmod +x /bin/tini \
  && echo "$TINI_SHA /bin/tini" | sha1sum -c -

COPY init.groovy /usr/share/jenkins/ref/init.groovy.d/tcp-slave-agent-port.groovy

ENV JENKINS_VERSION 1.625.2
ENV JENKINS_SHA 395fe6975cf75d93d9fafdafe96d9aab1996233b

# could use ADD but this one does not check Last-Modified header 
# see https://github.com/docker/docker/issues/8331
RUN curl -fL http://mirrors.jenkins-ci.org/war-stable/$JENKINS_VERSION/jenkins.war -o /usr/share/jenkins/jenkins.war \
  && echo "$JENKINS_SHA /usr/share/jenkins/jenkins.war" | sha1sum -c -

ENV JENKINS_UC https://updates.jenkins-ci.org
RUN chown -R jenkins "$JENKINS_HOME" /usr/share/jenkins/ref

# for main web interface:
EXPOSE 8080

# will be used by attached slave agents:
EXPOSE 50000

ENV COPY_REFERENCE_FILE_LOG $JENKINS_HOME/copy_reference_file.log

# Install extra packages
RUN apt-get install -yqq unzip sudo
RUN echo "jenkins ALL=NOPASSWD: ALL" >> /etc/sudoers

USER jenkins

COPY jenkins.sh /usr/local/bin/jenkins.sh
COPY entrypoint.sh /bin/entrypoint.sh
ENTRYPOINT ["/bin/entrypoint.sh"]

# from a derived Dockerfile, can use `RUN plugins.sh active.txt` to setup /usr/share/jenkins/ref/plugins from a support bundle
COPY plugins.sh /usr/local/bin/plugins.sh
COPY plugins.txt /usr/share/jenkins/ref
RUN /usr/local/bin/plugins.sh /usr/share/jenkins/ref/plugins.txt
