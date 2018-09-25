FROM gradle:jdk8 as builder
USER root
WORKDIR /home/gradle/
COPY . /home/gradle/
RUN	gradle clean assemble

FROM openjdk:8-alpine
WORKDIR /home/
COPY --from=builder /home/gradle/build/libs/spring-music.jar /home/
ENTRYPOINT [ "java", "-XX:+UnlockExperimentalVMOptions", "-XX:+UseCGroupMemoryLimitForHeap", "-jar", "/home/spring-music.jar" ]
