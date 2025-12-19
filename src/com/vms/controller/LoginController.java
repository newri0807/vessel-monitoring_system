package com.vms.controller;

import com.vms.model.MenuDto;
import com.vms.model.UserDto;
import com.vms.service.SettingsService; 
import com.vms.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;

import javax.servlet.http.HttpSession;
import java.util.List;

@Controller
public class LoginController {

    @Autowired
    private UserService userService;

    @Autowired
    private SettingsService settingsService;

    // 로그인 페이지 이동
    @RequestMapping(value = "/login", method = RequestMethod.GET)
    public String loginPage() {
        return "login";
    }

    // 로그인 처리
    @RequestMapping(value = "/loginProcess", method = RequestMethod.POST)
    public String loginProcess(@RequestParam("id") String id, 
                               @RequestParam("pw") String pw, 
                               HttpSession session) {
        
        UserDto user = userService.login(id, pw);

        if (user != null) {
            session.setAttribute("userId", user.getUserId());
            session.setAttribute("userName", user.getUserName()); 
            session.setAttribute("role", user.getRole());             
            
            List<MenuDto> menuTree = settingsService.getUserMenuTree(user.getUserId(), user.getRole());
                      
            session.setAttribute("menuTree", menuTree);
            
            // (디버깅) 콘솔 확인용
            // System.out.println("생성된 메뉴 트리 개수: " + (menuTree != null ? menuTree.size() : "null"));

            return "redirect:/"; 
        } else {
            return "redirect:/login?error=true"; 
        }
    }


    // 로그아웃
    @RequestMapping(value = "/logout", method = RequestMethod.GET)
    public String logout(HttpSession session) {
        session.invalidate(); 
        return "redirect:/login";
    }
    
}