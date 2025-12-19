package com.vms.service;

import java.util.Map;

public interface AlarmService {
    
    /**
     * 알람 리스트 및 페이징 정보 조회
     * @param startDate 조회 시작일
     * @param endDate 조회 종료일
     * @param page 현재 페이지 번호
     * @return 리스트(list)와 전체개수(total), 페이지(page)가 담긴 Map
     */
    Map<String, Object> getAlarmList(String startDate, String endDate, int page);
}