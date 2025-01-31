# Use an official Maven image as the build environment
FROM maven:3.8.6-openjdk-11 AS build
WORKDIR /app
COPY . .
RUN mvn clean package

# Use an official OpenJDK runtime as the base image
FROM openjdk:11-jre-slim
WORKDIR /app
COPY --from=build /app/target/Java-1.0-SNAPSHOT.jar ./app.jar

# Expose the port your app runs on
EXPOSE 8080

# Run the application
CMD ["java", "-jar", "app.jar"]
