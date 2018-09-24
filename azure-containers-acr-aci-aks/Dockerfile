FROM gradle:jdk10 as builder
USER root
WORKDIR /home/gradle/
COPY . /home/gradle/
RUN	gradle clean assemble

FROM openjdk:10-slim
WORKDIR /home/
COPY --from=builder /home/gradle/build/libs/spring-music.jar /home/
ENTRYPOINT [ "java", "-XX:+UnlockExperimentalVMOptions", "-jar", "/home/spring-music.jar" ]
