# [Stage 1] 빌드 단계
FROM maven:3.8.6-openjdk-8 as builder
WORKDIR /app

# 레시피(pom.xml)와 재료(소스) 복사
COPY pom.xml .
COPY src ./src
COPY WebContent ./WebContent

# 요리 시작 (WAR 파일 생성)
RUN mvn package -DskipTests

# [Stage 2] 실행 단계 (Tomcat)
FROM tomcat:9-jdk8-openjdk

# 기존 파일 정리
RUN rm -rf /usr/local/tomcat/webapps/*

# 완성된 요리(WAR)를 식탁(Tomcat)에 올리기
COPY --from=builder /app/target/*.war /usr/local/tomcat/webapps/ROOT.war

# 톰캣 was 실행 
EXPOSE 8080
CMD ["catalina.sh", "run"]
