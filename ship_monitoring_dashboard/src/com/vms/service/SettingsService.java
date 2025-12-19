package com.vms.service;

import java.util.List;
import java.util.Map;

import com.vms.model.MenuDto;
import com.vms.model.UserDto;
import com.vms.model.VesselDto;

public interface SettingsService {
    // VESSEL GROUP -TAB1
	List<VesselDto> getSettingsList(String userId);
    void saveUserGroup(String userId, String vesselId, String groupId);
    
    // ACCOUT -TAB2
    List<UserDto> getManagedUsers(String userId);
    List<VesselDto> getAssignableVessels(String userId, String role);
    void createUser(String newId, String newPw, String newName, String newRole, String creatorId, List<String> vesselIds);
    List<String> getUserAccessVessels(String targetId);
    void deleteUser(String targetId);
    void updateUser(String targetId, String newPw, String newName, List<String> vesselIds);

    //  MENU -TAB3
    List<String> getMyMenus(String userId, String role);
    void saveMenuConfig(String targetId, String targetType, List<String> menus);
	List<MenuDto> getUserMenuTree(String userId, String role);
	void manageGroupDef(String mode, Map<String, Object> map);
	List<Map<String, Object>> getGroupList();
	
}