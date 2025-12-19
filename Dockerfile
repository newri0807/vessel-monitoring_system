FROM tomcat:8.5-jdk8-openjdk

# 1. 기존 앱 삭제
RUN rm -rf /usr/local/tomcat/webapps/*

# 2. WAR 파일을 ROOT 폴더에 '압축 풀어서' 복사 (그래야 파일을 수정할 수 있음)
# (주의: 로컬에 app.war가 있어야 함)
COPY app.war /tmp/app.war
RUN mkdir /usr/local/tomcat/webapps/ROOT && \
    cd /usr/local/tomcat/webapps/ROOT && \
    jar -xvf /tmp/app.war && \
    rm /tmp/app.war

# 3. 마법의 스크립트 복사 및 권한 부여
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8080

# 4. 톰캣 대신 스크립트를 먼저 실행
CMD ["/entrypoint.sh"]