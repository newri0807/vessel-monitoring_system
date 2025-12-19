package com.vms.mapper;

import com.vms.model.UserDto;

public interface UserMapper {
    // ID로 사용자 정보 조회 (비밀번호 확인은 서비스에서 함)
    UserDto getUserById(String userId);
}