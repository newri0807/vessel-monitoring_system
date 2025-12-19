FROM tomcat:8.5-jdk8-openjdk
# 기존 톰캣 앱 삭제
RUN rm -rf /usr/local/tomcat/webapps/*
# 내 WAR 파일을 ROOT로 복사 (접속 시 / 경로로 바로 뜸)
COPY app.war /usr/local/tomcat/webapps/ROOT.war
EXPOSE 8080
CMD ["catalina.sh", "run"]