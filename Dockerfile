# [Stage 1] 빌드 단계 (Maven 사용)
FROM maven:3.8.6-openjdk-8 as builder
WORKDIR /app

# 1. 설정 파일 복사
COPY pom.xml .

# 2. 소스 코드 복사
COPY src ./src
COPY WebContent ./WebContent

# 3. 빌드 실행 (WAR 파일 생성)
RUN mvn package -DskipTests

# [Stage 2] 실행 단계 (Tomcat)
FROM tomcat:9-jdk8-openjdk

# 1. 기존 톰캣 앱 삭제
RUN rm -rf /usr/local/tomcat/webapps/*

# 2. 빌드 단계에서 만든 WAR 파일을 가져와서 실행
COPY --from=builder /app/target/*.war /usr/local/tomcat/webapps/ROOT.war

# 3. 실행 스크립트 설정
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8080
ENTRYPOINT ["/entrypoint.sh"]
