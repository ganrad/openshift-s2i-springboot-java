# s2i-springboot : 12-08-2017
#
# springboot-jdk8
#
FROM openshift/base-centos7
MAINTAINER Ganesh Radhakrishnan ganrad01@gmail.com
# HOME in base image is /opt/app-root/src

# Builder version
ENV BUILDER_VERSION 1.0

# Install build tools on top of base image
# Java jdk 8, Maven 3.5.2, Gradle 4.4
ENV GRADLE_VERSION 4.4
ENV MAVEN_VERSION 3.5.2

# Install jdk8, Maven and Gradle
RUN yum install -y --enablerepo=centosplus \
    tar unzip bc which lsof java-1.8.0-openjdk java-1.8.0-openjdk-devel && \
    yum clean all -y && \
    (curl -0 http://ftp.wayne.edu/apache/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz | \
    tar -zx -C /usr/local) && \
    mv /usr/local/apache-maven-$MAVEN_VERSION /usr/local/maven && \
    ln -sf /usr/local/maven/bin/mvn /usr/local/bin/mvn && \
    curl -sL -0 https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip -o /tmp/gradle-${GRADLE_VERSION}-bin.zip && \
    unzip /tmp/gradle-${GRADLE_VERSION}-bin.zip -d /usr/local/ && \
    rm /tmp/gradle-${GRADLE_VERSION}-bin.zip && \
    mv /usr/local/gradle-${GRADLE_VERSION} /usr/local/gradle && \
    ln -sf /usr/local/gradle/bin/gradle /usr/local/bin/gradle && \
    mkdir -p /opt/openshift && \
    mkdir -p /opt/app-root/src && chmod -R a+rwX /opt/app-root/src

# Set the location of the mvn and gradle bin directories on search path
ENV PATH=/usr/local/bin/mvn:/usr/local/bin/gradle:$PATH

# Set the default build type to 'Maven'
ENV BUILD_TYPE=Maven

LABEL io.k8s.description="Platform for building Spring Boot applications with maven or gradle" \
      io.k8s.display-name="Spring Boot builder 1.0" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="builder,maven-3,gradle-4,springboot"

# Copy the S2I scripts to /usr/libexec/s2i, since openshift/base-centos7 image
# sets io.openshift.s2i.scripts-url label that way.
COPY ./s2i/bin/ /usr/libexec/s2i

# Drop the root user and make the content of /opt/openshift owned by user 1001
RUN chown -R 1001:1001 /opt/openshift

# This default user is created in the openshift/base-centos7 image
USER 1001

# Set the default port for applications built using this image
EXPOSE 8080

# Set the default CMD for the image
# CMD ["java","-Djava.security.egd=file:/dev/./urandom","-jar","/opt/openshift/app.jar"]
CMD ["usage"]
