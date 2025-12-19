package com.vms.controller;

import java.util.List;
import java.util.Map; // [수정] 자바 기본 Map 사용
import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.vms.model.HistoryDto;
import com.vms.model.VesselDto;
import com.vms.service.VesselService;

@Controller
public class VesselController {

    @Autowired
    private VesselService vesselService;

    // 메인 페이지
    @RequestMapping(value = "/", method = RequestMethod.GET)
    public String home(HttpSession session) {
        if (session.getAttribute("userId") == null) {
            return "redirect:/login";
        }
        return "main";
    }

    // 선박 리스트
    @RequestMapping(value = "/api/vessels", method = RequestMethod.GET)
    @ResponseBody
    public List<VesselDto> getVessels(HttpSession session) {
        String userId = (String) session.getAttribute("userId");
        if (userId == null) return null; 
        return vesselService.getVesselsByUser(userId);
    }
    
    // 그룹 업데이트
    @RequestMapping(value = "/api/group/update", method = RequestMethod.POST)
    @ResponseBody
    public String updateGroup(@RequestBody VesselDto vessel) {
         try {
             vesselService.updateVesselGroup(vessel);
             return "SUCCESS";
         } catch (Exception e) {
             e.printStackTrace();
             return "FAIL";
         }
    }
    
    // 히스토리 조회
    @RequestMapping(value = "/api/vessel/history", method = RequestMethod.GET)
    @ResponseBody
    public List<HistoryDto> getHistory(@RequestParam("vesselId") String vesselId) {
        return vesselService.getVesselHistory(vesselId);
    }
    
    // 알람 조회 
    @RequestMapping(value = "/api/vessel/alarms", method = RequestMethod.GET)
    @ResponseBody
    public List<Map<String, Object>> getVesselAlarms(@RequestParam("vesselId") String vesselId) {
        return vesselService.getAlarmsByVesselId(vesselId); 
    }
}