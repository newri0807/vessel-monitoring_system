package com.vms.mapper;

import com.vms.model.MenuDto;
import com.vms.model.UserDto;
import com.vms.model.VesselDto;
import org.apache.ibatis.annotations.Param;
import java.util.List;
import java.util.Map;

public interface SettingsMapper {

    // 그룹 관리 (Group Def)
    List<Map<String, Object>> selectGroupList();
    void insertGroupDef(Map<String, Object> map);
    void updateGroupDef(Map<String, Object> map);
    void deleteGroupDef(@Param("groupId") String groupId);

    // 선박 관리 (Vessel)
    List<VesselDto> getVesselsWithStatus(@Param("userId") String userId);
    void upsertUserGroup(@Param("userId") String userId, @Param("vesselId") String vesselId, @Param("groupId") String groupId);

    // 계정 관리 (Account)
    List<UserDto> selectManagedUsers(@Param("userId") String userId);
    List<VesselDto> selectAssignableVessels(@Param("userId") String userId, @Param("role") String role);
    List<String> selectUserAccessVessels(@Param("targetUserId") String targetUserId);

    void insertUser(@Param("userId") String userId, @Param("password") String password, @Param("userName") String userName, @Param("role") String role, @Param("createdBy") String createdBy);
    void insertUserAccess(@Param("targetUserId") String targetUserId, @Param("vesselId") String vesselId);

    void updateUser(@Param("userId") String userId, @Param("password") String password, @Param("userName") String userName);
    void deleteUser(@Param("targetUserId") String targetUserId);
    void deleteUserAccess(@Param("targetUserId") String targetUserId);
    
    // 메뉴 설정 (Menu) 
    List<String> selectMyMenus(@Param("userId") String userId, @Param("role") String role);
    List<String> selectAllMenuCodes();    
    List<Map<String, Object>> selectConfigRawData(@Param("userId") String userId, @Param("role") String role);
    void deleteMenuConfig(@Param("targetId") String targetId, @Param("targetType") String targetType);    
    void insertMenuConfig(@Param("targetId") String targetId, @Param("targetType") String targetType, @Param("menuCode") String menuCode);
    void deleteUserMenuConfigByRole(@Param("role") String role);// Role 하위 유저 초기화
    List<MenuDto> selectAllMenus();
}