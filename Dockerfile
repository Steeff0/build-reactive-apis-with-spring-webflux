FROM gradle:6.7.1-jdk11-hotspot AS builder
COPY --chown=gradle:gradle . /home/gradle/src
WORKDIR /home/gradle/src

RUN set -x \
    && gradle build --no-daemon \
    && mkdir -p /appFiles \
    && cd /appFiles \
    && jar -xf /home/gradle/src/build/libs/*.jar

#Kadaster image contains useful self-signed certificates
FROM adoptopenjdk/openjdk11:alpine-jre
ARG SOURCE_FILES=/appFiles
ARG APPLICATION_FOLDER=/opt/webapps
ENV OPENSSL_VERSION=1.1.0j-1~deb9u1

# Update and install packages (ttf-dejavu is preventing NPE in Server Management)
RUN set -x \
    && apk update --no-cache \
    && apk add curl dpkg bash bash-completion --no-cache \
    && adduser -D -h "/etc/peach" "peach" \
    && addgroup peach peach \
    && mkdir -p "${APPLICATION_FOLDER}" \
    && chown -R peach:peach /opt

COPY --chown=peach:peach ./docker-files/entrypoint.sh /opt/entrypoint.sh

RUN set -x \
    && chmod +x "/opt/entrypoint.sh"

COPY --from=builder --chown=peach:peach ${SOURCE_FILES}/BOOT-INF/lib ${APPLICATION_FOLDER}/lib
COPY --from=builder --chown=peach:peach ${SOURCE_FILES}/META-INF ${APPLICATION_FOLDER}/META-INF
COPY --from=builder --chown=peach:peach ${SOURCE_FILES}/BOOT-INF/classes ${APPLICATION_FOLDER}

WORKDIR "/opt/webapps"
USER peach
ENTRYPOINT ["/opt/entrypoint.sh"]
CMD ["java", "com.example.demo.DemoApplication"]
