# [Stage 1] 빌드 단계 (Maven으로 WAR 파일 생성)
FROM maven:3.8.6-openjdk-8 as builder
WORKDIR /app

# 프로젝트 설정 파일 복사
COPY pom.xml .

# 소스 코드 복사
COPY src ./src

# 화면 파일(JSP, CSS 등)도 복사해야 합니다! (이 줄 추가!)
COPY WebContent ./WebContent

# 빌드 실행 (테스트 건너뛰고 빠르게)
RUN mvn package -DskipTests

# [Stage 2] 실행 단계 (Tomcat)
FROM tomcat:9-jdk8-openjdk

# 1. 기존 톰캣 앱 삭제
RUN rm -rf /usr/local/tomcat/webapps/*

# 2. 빌드 단계에서 만든 WAR 파일을 가져와서 실행
COPY --from=builder /app/target/*.war /usr/local/tomcat/webapps/ROOT.war

# 3. 실행 스크립트 설정
COPY entrypoint.sh /entrypoint.sh

# 4. [핵심] 윈도우 줄바꿈 문자(\r) 강제 제거 (에러 해결사)
RUN sed -i 's/\r$//' /entrypoint.sh

# 5. 실행 권한 부여
RUN chmod +x /entrypoint.sh

EXPOSE 8080
ENTRYPOINT ["/entrypoint.sh"]
