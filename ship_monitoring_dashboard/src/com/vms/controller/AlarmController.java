package com.vms.controller;

import com.vms.service.AlarmService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import java.util.Map;

@Controller
public class AlarmController {

    @Autowired
    private AlarmService alarmService;

    // 알람 리스트 페이지 이동
    @RequestMapping(value = "/alarm", method = RequestMethod.GET)
    public String alarmPage() {
        // /WEB-INF/views/alarm.jsp 로 포워딩
        return "alarm";
    }

    // 알람 데이터 조회 API (AJAX) - URL: /api/alarms?startDate=...&endDate=...&page=1  
    @RequestMapping(value = "/api/alarms", method = RequestMethod.GET)
    @ResponseBody
    public Map<String, Object> getAlarms(
            @RequestParam(value="startDate", required=false) String startDate,
            @RequestParam(value="endDate", required=false) String endDate,
            @RequestParam(value="page", defaultValue="1") int page) {
        
        return alarmService.getAlarmList(startDate, endDate, page);
    }
}