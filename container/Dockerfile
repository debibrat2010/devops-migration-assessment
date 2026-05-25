# Module C — Multi-stage production Dockerfile for Spring PetClinic
# Build context: repo root (docker build -f container/Dockerfile .)

# --- Build stage: compile + unit tests ---
FROM eclipse-temurin:17-jdk-alpine AS builder
WORKDIR /build

RUN apk add --no-cache bash
COPY apps/spring-petclinic/mvnw ./
COPY apps/spring-petclinic/.mvn .mvn
COPY apps/spring-petclinic/pom.xml ./

# Cache dependencies
RUN chmod +x mvnw && ./mvnw -B -q dependency:go-offline -DskipTests || true

COPY apps/spring-petclinic/src ./src
RUN ./mvnw -B test package -DskipTests=false

# --- Runtime stage: minimal JRE, non-root ---
FROM eclipse-temurin:17-jre-alpine AS runtime

RUN addgroup -g 10001 app && adduser -u 10001 -G app -D -h /app app
WORKDIR /app

COPY --from=builder /build/target/*.jar /app/app.jar

USER app
EXPOSE 8080

ENV JAVA_OPTS="-XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0" \
    SPRING_PROFILES_ACTIVE=default \
    SERVER_PORT=8080

HEALTHCHECK --interval=30s --timeout=5s --start-period=60s --retries=3 \
  CMD wget -qO- http://127.0.0.1:8080/actuator/health || exit 1

ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar /app/app.jar"]
