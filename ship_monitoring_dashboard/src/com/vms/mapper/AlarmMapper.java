package com.vms.mapper;

import com.vms.model.AlarmDto;
import org.apache.ibatis.annotations.Param;
import java.util.List;

public interface AlarmMapper {
    List<AlarmDto> getAlarmList(@Param("startDate") String startDate, 
                                @Param("endDate") String endDate, 
                                @Param("limit") int limit, 
                                @Param("offset") int offset);
    
    int getAlarmCount(@Param("startDate") String startDate, 
                      @Param("endDate") String endDate);
}

