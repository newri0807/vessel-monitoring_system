#!/bin/bash

# database.properties 파일 위치 (WAR 구조에 따라 경로 확인 필요!)
# 보통: /usr/local/tomcat/webapps/ROOT/WEB-INF/classes/database.properties
CONFIG_FILE="/usr/local/tomcat/webapps/ROOT/WEB-INF/classes/database.properties"

echo "⚙️ DB 설정 파일 수정 중..."

# sed 명령어로 파일 내용 바꿔치기
# db.url=... 부분을 찾아서 환경변수 REAL_DB_URL 값으로 변경
sed -i "s|db.url=.*|db.url=$REAL_DB_URL|g" $CONFIG_FILE
sed -i "s|db.username=.*|db.username=$REAL_DB_USER|g" $CONFIG_FILE
sed -i "s|db.password=.*|db.password=$REAL_DB_PASSWORD|g" $CONFIG_FILE

echo "✅ 설정 완료! 톰캣 시작합니다."
# 원래 톰캣 실행 명령어 실행
exec catalina.sh run