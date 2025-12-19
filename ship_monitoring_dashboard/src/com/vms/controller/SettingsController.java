package com.vms.controller;

import com.vms.model.MenuDto;
import com.vms.model.VesselDto;
import com.vms.service.SettingsService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpSession;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@Controller
public class SettingsController {

    @Autowired
    private SettingsService settingsService;

    // main
    @RequestMapping(value = "/settings", method = RequestMethod.GET)
    public String settingsPage(HttpSession session, Model model) {
        String userId = (String) session.getAttribute("userId");
        String role = (String) session.getAttribute("role");

        if (userId == null) return "redirect:/login";

        // 관리자용 데이터 조회
        if ("SYSTEM".equals(role) || "ADMIN".equals(role)) {
            model.addAttribute("managedUsers", settingsService.getManagedUsers(userId));
            model.addAttribute("vesselList", settingsService.getAssignableVessels(userId, role));
        }

        return "settings";
    }

    // Tab 1: Vessel Grouping (AJAX)
    @RequestMapping(value = "/api/settings/vessels", method = RequestMethod.GET)
    @ResponseBody
    public List<VesselDto> getSettingsList(HttpSession session) {
        String userId = (String) session.getAttribute("userId");
        if(userId == null) return null; 
        return settingsService.getSettingsList(userId);
    }

    @RequestMapping(value = "/api/settings/save", method = RequestMethod.POST)
    @ResponseBody
    public String saveGroup(@RequestBody Map<String, String> payload, HttpSession session) {
        String userId = (String) session.getAttribute("userId");
        if (userId == null) return "FAIL: Session Expired";

        settingsService.saveUserGroup(userId, payload.get("id"), payload.get("groupId"));
        return "SUCCESS";
    }

    // Tab 2: Account Set (AJAX)    
    @RequestMapping(value = "/api/settings/create-user", method = RequestMethod.POST)
    @ResponseBody
    public String createUser(@RequestBody Map<String, Object> payload, HttpSession session) {
        String creatorRole = (String) session.getAttribute("role");
        String creatorId = (String) session.getAttribute("userId");
        
        if (!"SYSTEM".equals(creatorRole) && !"ADMIN".equals(creatorRole)) return "FAIL: Access Denied";

        try {
            @SuppressWarnings("unchecked")
            List<String> vesselIds = (List<String>) payload.get("vessels");
            String newRole = "SYSTEM".equals(creatorRole) ? "ADMIN" : "OPERATOR";
            
            settingsService.createUser(
                (String) payload.get("newId"), 
                (String) payload.get("newPw"), 
                (String) payload.get("newName"), 
                newRole, creatorId, vesselIds
            );
            return "SUCCESS";
        } catch (Exception e) {
            e.printStackTrace();
            return "FAIL";
        }
    }

    @RequestMapping(value = "/api/settings/user-vessels", method = RequestMethod.GET)
    @ResponseBody
    public List<String> getUserVessels(@RequestParam("targetId") String targetId) {
        return settingsService.getUserAccessVessels(targetId);
    }

    @RequestMapping(value = "/api/settings/update-user", method = RequestMethod.POST)
    @ResponseBody
    public String updateUser(@RequestBody Map<String, Object> payload, HttpSession session) {        
        String creatorRole = (String) session.getAttribute("role");
        if (!"SYSTEM".equals(creatorRole) && !"ADMIN".equals(creatorRole)) return "FAIL: NO_PERMISSION";
  
        try {
            @SuppressWarnings("unchecked")
            List<String> vesselIds = (List<String>) payload.get("vessels"); // null 체크는 서비스에서 함
            
            settingsService.updateUser(
                (String) payload.get("targetId"), 
                (String) payload.get("newPw"), 
                (String) payload.get("newName"), 
                vesselIds
            );
            return "SUCCESS";
        } catch (Exception e) {
            e.printStackTrace();
            return "FAIL: " + e.getMessage();
        }
    }

    @RequestMapping(value = "/api/settings/delete-user", method = RequestMethod.POST)
    @ResponseBody
    public String deleteUser(@RequestBody Map<String, String> payload, HttpSession session) {
        String creatorRole = (String) session.getAttribute("role");
        if (!"SYSTEM".equals(creatorRole) && !"ADMIN".equals(creatorRole)) return "FAIL: NO_PERMISSION";
        
        try {
            settingsService.deleteUser(payload.get("targetId"));
            return "SUCCESS";
        } catch (Exception e) {
            e.printStackTrace();
            return "FAIL";
        }
    }
    
    
    // Tab 3: Menu Set (AJAX) 
    // [조회] UI 체크박스 초기화용 데이터 조회
    @RequestMapping(value = "/api/settings/menu-config", method = RequestMethod.GET)
    @ResponseBody
    public List<String> getMenuConfig(@RequestParam("targetType") String targetType, 
                                      @RequestParam("targetId") String targetId,
                                      HttpSession session) {
        
        String myId = (String) session.getAttribute("userId");
        String myRole = (String) session.getAttribute("role");
        
        // 권한 체크
        if (!myId.equals(targetId)) {
            if (!"SYSTEM".equals(myRole) && !"ADMIN".equals(myRole)) return new ArrayList<>();
        }
        
        // ROLE 타입이면 targetId가 곧 Role명(ADMIN, OPERATOR)
        String lookupRole = "ROLE".equals(targetType) ? targetId : "";
        return settingsService.getMyMenus(targetId, lookupRole);
    }

    // [저장] 메뉴 설정 저장 + 세션 즉시 갱신
    @RequestMapping(value = "/api/settings/update-menu-config", method = RequestMethod.POST)
    @ResponseBody
    public String updateMenuConfig(@RequestBody Map<String, Object> payload, HttpSession session) {
        String myId = (String) session.getAttribute("userId");
        String myRole = (String) session.getAttribute("role");
        
        String configType = (String) payload.get("configType");
        String targetRole = (String) payload.get("targetRole");
        
        @SuppressWarnings("unchecked")
        List<String> visibleMenus = (List<String>) payload.get("visibleMenus");

        try {
            // 1. DB에 저장
            if ("PERSONAL".equals(configType)) {
                settingsService.saveMenuConfig(myId, "USER", visibleMenus);
            } else if ("ROLE_CONFIG".equals(configType)) {
                if (!"SYSTEM".equals(myRole) && !"ADMIN".equals(myRole)) return "FAIL: NO_PERMISSION";
                settingsService.saveMenuConfig(targetRole, "ROLE", visibleMenus);
            }
            
            // 2. 세션 즉시 갱신 (화면 새로고침 시 바로 반영되도록) 
            List<MenuDto> newTree = settingsService.getUserMenuTree(myId, myRole);
            session.setAttribute("menuTree", newTree);
            
            // 디버깅 로그
            //System.out.println("메뉴 설정 저장됨 (" + configType + "). 세션 트리 갱신 완료: " + newTree.size() + "개");

            return "SUCCESS";
        } catch (Exception e) {
            e.printStackTrace();
            return "FAIL";
        }
    }
    
    // 그룹 정의(Group Definition) 관리 
    // 그룹 목록 조회
    @RequestMapping(value = "/api/settings/groups", method = RequestMethod.GET)
    @ResponseBody
    public List<Map<String, Object>> getGroupList() {
        return settingsService.getGroupList();
    }

    // 그룹 추가/수정/삭제
    @RequestMapping(value = "/api/settings/group-crud", method = RequestMethod.POST)
    @ResponseBody
    public String groupCrud(@RequestBody Map<String, Object> payload) {
        try {
            String mode = (String) payload.get("mode"); // create, update, delete
            settingsService.manageGroupDef(mode, payload);
            return "SUCCESS";
        } catch (Exception e) {
            e.printStackTrace();
            return "FAIL";
        }
    }
}