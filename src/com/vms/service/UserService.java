package com.vms.service;


import com.vms.mapper.UserMapper;
import com.vms.model.UserDto;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
public class UserService {

    @Autowired 
    private UserMapper userMapper;

    @Autowired
    private PasswordEncoder passwordEncoder;

    public UserDto login(String userId, String inputPassword) {
//    	// [임시 코드] 1234를 암호화해서 콘솔에 찍어보기
//        System.out.println("=== 암호화 테스트 시작 ===");
//        String encPw = passwordEncoder.encode("1234"); 
//        System.out.println("DB에 이 값을 넣으세요: " + encPw);
//        System.out.println("======================");
    	
        // 1. ID로 사용자 조회
    	UserDto user = userMapper.getUserById(userId);
        
        // 2. 사용자가 없으면 null 반환
        if (user == null) {
            return null;
        }

        // 3. 비밀번호 비교 (입력받은 평문 PW vs DB의 암호화된 PW)
        // passwordEncoder.matches(평문, 암호문) 메서드 사용
        if (passwordEncoder.matches(inputPassword, user.getPassword())) {
            return user; // 로그인 성공
        } else {
            return null; // 비밀번호 불일치
        }
    }
}