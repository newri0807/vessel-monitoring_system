package com.vms.service;

import com.vms.mapper.SettingsMapper;
import com.vms.model.MenuDto;
import com.vms.model.UserDto;
import com.vms.model.VesselDto;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

@Service
public class SettingsServiceImpl implements SettingsService {

    @Autowired private SettingsMapper settingsMapper;
    @Autowired private PasswordEncoder passwordEncoder;

    // [Group Management]
    @Override
    public List<Map<String, Object>> getGroupList() {
        return settingsMapper.selectGroupList();
    }

    @Override
    @Transactional
    public void manageGroupDef(String mode, Map<String, Object> map) {
        if ("create".equals(mode)) {
            // ★ ID 자동 생성 로직 제거 -> DB Auto Increment 사용
            settingsMapper.insertGroupDef(map);
        } else if ("update".equals(mode)) {
            settingsMapper.updateGroupDef(map);
        } else if ("delete".equals(mode)) {
            settingsMapper.deleteGroupDef((String) map.get("groupId"));
        }
    }

    // [Tab 1: Vessel]
    @Override public List<VesselDto> getSettingsList(String userId) { return settingsMapper.getVesselsWithStatus(userId); }
    @Override public void saveUserGroup(String userId, String vesselId, String groupId) { settingsMapper.upsertUserGroup(userId, vesselId, groupId); }

    // [Tab 2: Account] 
    @Override public List<UserDto> getManagedUsers(String userId) { return settingsMapper.selectManagedUsers(userId); }
    @Override public List<VesselDto> getAssignableVessels(String userId, String role) { return settingsMapper.selectAssignableVessels(userId, role); }
    @Override public List<String> getUserAccessVessels(String targetUserId) { return settingsMapper.selectUserAccessVessels(targetUserId); }
    
    @Override @Transactional
    public void createUser(String newId, String newPw, String newName, String newRole, String creatorId, List<String> vesselIds) {
        settingsMapper.insertUser(newId, passwordEncoder.encode(newPw), newName, newRole, creatorId);
        handleVesselAccess(newId, vesselIds);
    }
    @Override @Transactional
    public void updateUser(String targetId, String newPw, String newName, List<String> vesselIds) {
        String encodedPw = (newPw != null && !newPw.isEmpty()) ? passwordEncoder.encode(newPw) : null;
        settingsMapper.updateUser(targetId, encodedPw, newName);
        settingsMapper.deleteUserAccess(targetId);
        handleVesselAccess(targetId, vesselIds);
    }
    @Override @Transactional
    public void deleteUser(String targetId) {
        settingsMapper.deleteUserAccess(targetId);
        settingsMapper.deleteUser(targetId);
    }

    // [Tab 3: Menu] 
    @Override public List<String> getMyMenus(String userId, String role) { return resolveAllowedMenuCodes(userId, role); }
    @Override public List<MenuDto> getUserMenuTree(String userId, String role) {
        List<MenuDto> allMenus = settingsMapper.selectAllMenus();
        List<String> allowedCodes = resolveAllowedMenuCodes(userId, role);
        return buildMenuTree(allMenus, allowedCodes);
    }
    @Override @Transactional
    public void saveMenuConfig(String targetId, String targetType, List<String> menus) {
        settingsMapper.deleteMenuConfig(targetId, targetType);
        
        if (menus != null && !menus.isEmpty()) {
            // 중복 제거
            Set<String> uniqueMenus = new HashSet<>(menus);
            for (String menu : uniqueMenus) {
                settingsMapper.insertMenuConfig(targetId, targetType, menu);
            }
        }

        if ("ROLE".equals(targetType)) {
            settingsMapper.deleteUserMenuConfigByRole(targetId);
        }
    }


    
    private List<String> resolveAllowedMenuCodes(String userId, String role) {
//        if ("SYSTEM".equals(role)) {
//            List<String> all = settingsMapper.selectAllMenuCodes();
//            return (all == null || all.isEmpty()) ? Arrays.asList("GRP_MON", "dashboard", "alarm", "GRP_MNG", "settings") : all;
//        }
        List<Map<String, Object>> rawData = settingsMapper.selectConfigRawData(userId, role);
        List<String> userMenus = new ArrayList<>();
        List<String> roleMenus = new ArrayList<>();
        for (Map<String, Object> map : rawData) {
            String type = (String) map.get("TARGET_TYPE");
            String code = (String) map.get("MENU_CODE");
            if (code == null) continue;
            if ("USER".equals(type)) userMenus.add(code);
            else roleMenus.add(code);
        }
        List<String> resultCodes = !userMenus.isEmpty() ? userMenus : roleMenus;
        if(resultCodes.isEmpty()) resultCodes.add("dashboard");
        return fillParentCodes(resultCodes);
    }

    private List<String> fillParentCodes(List<String> currentCodes) {
        List<MenuDto> allMenus = settingsMapper.selectAllMenus();
        List<String> finalCodes = new ArrayList<>(currentCodes);
        for (String code : currentCodes) {
            for (MenuDto menu : allMenus) {
                if (menu.getMenuCode().equals(code)) {
                    String parent = menu.getParentCode();
                    if (parent != null && !finalCodes.contains(parent)) finalCodes.add(parent);
                    break; 
                }
            }
        }
        return finalCodes;
    }

    private List<MenuDto> buildMenuTree(List<MenuDto> allMenus, List<String> permittedCodes) {
        if (allMenus == null) allMenus = new ArrayList<>();
        if (permittedCodes == null) permittedCodes = new ArrayList<>();
        List<MenuDto> rootMenus = new ArrayList<>();
        for (MenuDto group : allMenus) {
            if (group.getParentCode() != null && group.getDepth() != 1) continue;
            List<MenuDto> validChildren = new ArrayList<>();
            for (MenuDto child : allMenus) {
                if (group.getMenuCode().equals(child.getParentCode()) && permittedCodes.contains(child.getMenuCode())) {
                    validChildren.add(child);
                }
            }
            if (!validChildren.isEmpty() || permittedCodes.contains(group.getMenuCode())) {
                group.setChildren(validChildren);
                rootMenus.add(group);
            }
        }
        return rootMenus;
    }

    private void handleVesselAccess(String userId, List<String> vesselIds) {
        if (vesselIds != null) {
            for (String vid : vesselIds) settingsMapper.insertUserAccess(userId, vid);
        }
    }
}