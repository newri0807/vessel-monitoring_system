package com.vms.service;

import com.vms.mapper.VesselMapper;
import com.vms.model.HistoryDto;
import com.vms.model.VesselDto;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map; // [수정] 올바른 Map 임포트

@Service("vesselService")
public class VesselServiceImpl implements VesselService {

    @Autowired
    private VesselMapper vesselMapper;

    @Override
    public List<VesselDto> getVesselsByUser(String userId) {
        return vesselMapper.getVesselList(userId);
    }

    @Override
    @Transactional
    public void updateVesselGroup(VesselDto vessel) {
        vesselMapper.updateVesselGroup(vessel.getId(), vessel.getGroupId());
    }

    @Override
    public List<HistoryDto> getVesselHistory(String vesselId) {
        return vesselMapper.getHistoryByVesselId(vesselId);
    }

    @Override
    public List<Map<String, Object>> getAlarmsByVesselId(String vesselId) {
        return vesselMapper.selectAlarmsByVesselId(vesselId);
    }
}