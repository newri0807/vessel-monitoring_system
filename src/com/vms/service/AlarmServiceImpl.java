package com.vms.service;

import com.vms.mapper.AlarmMapper;
import com.vms.model.AlarmDto;
import com.vms.service.AlarmService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service("alarmService")
public class AlarmServiceImpl implements AlarmService {

    @Autowired
    private AlarmMapper alarmMapper;

    @Override
    public Map<String, Object> getAlarmList(String startDate, String endDate, int page) {
        // 1. 페이징 계산
        int limit = 10; // 한 페이지당 보여줄 개수
        int offset = (page - 1) * limit;

        // 2. DB 조회 (리스트)
        List<AlarmDto> list = alarmMapper.getAlarmList(startDate, endDate, limit, offset);
        
        // [안전장치] 리스트가 null이면 빈 리스트로 초기화 (프론트엔드 에러 방지)
        if (list == null) {
            list = new ArrayList<>();
        }

        // 3. DB 조회 (전체 개수 - 페이징 버튼 생성용)
        int totalCount = alarmMapper.getAlarmCount(startDate, endDate);

        // 4. 결과 맵핑
        Map<String, Object> result = new HashMap<>();
        result.put("list", list);
        result.put("total", totalCount);
        result.put("page", page);

        return result;
    }
}