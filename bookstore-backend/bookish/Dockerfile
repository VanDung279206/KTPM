FROM maven:3.9.12-eclipse-temurin-21 AS build
WORKDIR /build
COPY pom.xml .
RUN mvn -B dependency:go-offline
COPY src ./src
RUN mvn -B -DskipTests package

FROM eclipse-temurin:21-jre-alpine
WORKDIR /app
RUN apk add --no-cache su-exec \
    && addgroup -S bookish && adduser -S bookish -G bookish \
    && mkdir -p /app/uploads && chown bookish:bookish /app/uploads
COPY --from=build /build/target/bookstore-0.0.1-SNAPSHOT.jar /app/app.jar
COPY docker-entrypoint.sh /app/docker-entrypoint.sh
RUN chmod +x /app/docker-entrypoint.sh
ENV SPRING_PROFILES_ACTIVE=cloud
EXPOSE 8080
ENTRYPOINT ["/app/docker-entrypoint.sh"]
