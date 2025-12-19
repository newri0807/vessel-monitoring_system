package com.vms.service;

import com.vms.model.HistoryDto;
import com.vms.model.VesselDto;
import java.util.List;
import java.util.Map; // [수정] 올바른 Map 임포트

public interface VesselService {
    
    List<VesselDto> getVesselsByUser(String userId);

    void updateVesselGroup(VesselDto vessel);
    
    List<HistoryDto> getVesselHistory(String vesselId);

    // 알람 조회
    List<Map<String, Object>> getAlarmsByVesselId(String vesselId);
}