# ---------- Stage 1 : Build the WAR ----------
FROM maven:3.9.9-eclipse-temurin-17 AS builder

WORKDIR /build

# Copy Maven config
COPY pom.xml .

# Download dependencies (cache layer)
RUN mvn dependency:go-offline

# Copy source code
COPY src ./src
COPY WebContent ./WebContent

# Build WAR
RUN mvn clean package -DskipTests


# ---------- Stage 2 : Lightweight Runtime ----------
FROM eclipse-temurin:17-jre-jammy

WORKDIR /app

RUN apt-get update && apt-get install -y curl \
    && rm -rf /var/lib/apt/lists/* \
    && curl -fSL https://archive.apache.org/dist/tomcat/tomcat-10/v10.1.28/bin/apache-tomcat-10.1.28.tar.gz -o tomcat.tar.gz \
    && tar -xzf tomcat.tar.gz --strip-components=1 \
    && rm tomcat.tar.gz \
    && rm -rf webapps/*

COPY --from=builder /build/target/*.war /app/webapps/ROOT.war

EXPOSE 8080

ENTRYPOINT ["/app/bin/catalina.sh","run"]
