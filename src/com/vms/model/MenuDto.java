package com.vms.model;

import java.util.ArrayList;
import java.util.List;

public class MenuDto {
	private String menuCode;
    private String menuName;
    private String parentCode;
    private int depth;
    private String menuUrl;
    private String iconClass;
    
    // 자식 메뉴들을 담을 리스트 (트리 구조용)
    private List<MenuDto> children = new ArrayList<>();
    
    public String getMenuCode() {
		return menuCode;
	}

	public void setMenuCode(String menuCode) {
		this.menuCode = menuCode;
	}

	public String getMenuName() {
		return menuName;
	}

	public void setMenuName(String menuName) {
		this.menuName = menuName;
	}

	public String getParentCode() {
		return parentCode;
	}

	public void setParentCode(String parentCode) {
		this.parentCode = parentCode;
	}

	public int getDepth() {
		return depth;
	}

	public void setDepth(int depth) {
		this.depth = depth;
	}

	public String getMenuUrl() {
		return menuUrl;
	}

	public void setMenuUrl(String menuUrl) {
		this.menuUrl = menuUrl;
	}

	public String getIconClass() {
		return iconClass;
	}

	public void setIconClass(String iconClass) {
		this.iconClass = iconClass;
	}

	public List<MenuDto> getChildren() {
		return children;
	}

	public void setChildren(List<MenuDto> children) {
		this.children = children;
	}

}