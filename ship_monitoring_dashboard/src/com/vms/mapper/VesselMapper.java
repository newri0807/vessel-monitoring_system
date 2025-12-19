package com.vms.mapper;

import com.vms.model.HistoryDto;
import com.vms.model.VesselDto;
import org.apache.ibatis.annotations.Param;
import java.util.List;
import java.util.Map;

public interface VesselMapper {
    List<VesselDto> getVesselList(@Param("userId") String userId);
    List<HistoryDto> getHistoryByVesselId(@Param("vesselId") String vesselId);
    void updateVesselGroup(@Param("vesselId") String vesselId, @Param("groupId") String groupId);
    List<Map<String, Object>> selectAlarmsByVesselId(@Param("vesselId") String vesselId);
}