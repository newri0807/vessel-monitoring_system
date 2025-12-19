package com.vms.model;

public class UserDto {
    private String userId;
    private String password;
    private String userName;
    private String role; // SYSTEM, ADMIN, OPERATOR

    public UserDto() {}

    public String getUserId() {
        return userId;
    }
    public void setUserId(String userId) {
        this.userId = userId;
    }
    public String getPassword() {
        return password;
    }
    public void setPassword(String password) {
        this.password = password;
    }
    public String getUserName() {
        return userName;
    }
    public void setUserName(String userName) {
        this.userName = userName;
    }
    public String getRole() {
        return role;
    }
    public void setRole(String role) {
        this.role = role; 
    }
}