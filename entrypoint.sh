# [Stage 1] 빌드 단계 (Maven으로 WAR 파일 생성)
FROM maven:3.8.6-openjdk-8 as builder
WORKDIR /app
# 프로젝트 설정 파일 복사
COPY pom.xml .
# 소스 코드 복사
COPY src ./src
# 빌드 실행 (테스트 건너뛰고 빠르게)
RUN mvn package -DskipTests

# [Stage 2] 실행 단계 (Tomcat)
FROM tomcat:9-jdk8-openjdk

# 기존 톰캣 기본 앱 삭제 (충돌 방지)
RUN rm -rf /usr/local/tomcat/webapps/*

# [중요] 1단계에서 만든 WAR 파일을 가져와서 ROOT.war로 이름 변경
COPY --from=builder /app/target/*.war /usr/local/tomcat/webapps/ROOT.war

# entrypoint.sh 스크립트 복사 및 실행 권한 부여
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# 8080 포트 열기
EXPOSE 8080

# 실행 명령
ENTRYPOINT ["/entrypoint.sh"]
