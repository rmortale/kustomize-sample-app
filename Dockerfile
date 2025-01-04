FROM maven:3.9.9-eclipse-temurin-17-focal AS builder
WORKDIR /build
COPY pom.xml /build/
COPY src /build/src

RUN mvn -q clean package -DskipTests

FROM eclipse-temurin:17-jre-ubi9-minimal
WORKDIR /opt/app
RUN addgroup --system javauser && adduser -S -s /usr/sbin/nologin -G javauser javauser
COPY --from=builder /build/target/*.jar app.jar
RUN chown -R javauser:javauser .
USER javauser
#HEALTHCHECK --interval=30s --timeout=3s --retries=1 CMD wget -qO- http://localhost:8080/actuator/health/ | grep UP || exit 1
ENTRYPOINT ["java", "-jar", "app.jar"]
