<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<style>
    /* Google Fonts 로드 */
    @import url('https://fonts.googleapis.com/css2?family=Roboto:wght@400;500;700&display=swap');

    /* 사이드바 전체 스타일 */
    .sidebar {
        width: 260px;
        height: 100vh;
        background: linear-gradient(180deg, #2c3e50 0%, #1a252f 100%);
        color: #ecf0f1;
        font-family: 'Roboto', sans-serif;
        display: flex;
        flex-direction: column;
        box-shadow: 4px 0 15px rgba(0,0,0,0.2);
        z-index: 1000;
        transition: width 0.3s ease;
        overflow-y: auto; /* 내용 길어지면 스크롤 */
    }

    /* 헤더 (VMS PRO System) */
    .sidebar-header {
        padding: 30px 20px;
        background-color: rgba(0,0,0,0.1);
        text-align: center;
        border-bottom: 1px solid rgba(255,255,255,0.05);
        margin-bottom: 10px;
    }

    .app-title {
        font-size: 1.4rem;
        font-weight: 700;
        margin-bottom: 15px;
        color: #3498db;
        letter-spacing: 1px;
    }

    .user-profile {
        display: flex;
        align-items: center;
        background: rgba(255,255,255,0.05);
        padding: 10px;
        border-radius: 12px;
        gap: 12px;
    }

    .user-avatar {
        width: 40px;
        height: 40px;
        background: #3498db;
        border-radius: 50%;
        display: flex;
        justify-content: center;
        align-items: center;
        font-weight: bold;
        color: white;
        font-size: 1.2rem;
    }

    .user-info { text-align: left; }
    .user-name { font-size: 0.95rem; font-weight: 500; color: white; }
    .user-role { font-size: 0.75rem; color: #95a5a6; margin-top: 2px; }

    /* [신규] 메뉴 그룹 헤더 스타일 (Monitoring, Management) */
    .menu-group {
        font-size: 0.75rem;
        text-transform: uppercase;
        color: #7f8c8d; /* 어두운 회색으로 구분감 줌 */
        margin: 25px 20px 10px 20px;
        font-weight: 700;
        letter-spacing: 0.5px;
        border-bottom: 1px solid rgba(255,255,255,0.05);
        padding-bottom: 5px;
    }

    /* 메뉴 아이템 스타일 */
    .menu-item {
        padding: 12px 25px; /* 높이 약간 조절 */
        cursor: pointer;
        transition: all 0.3s ease;
        display: flex;
        align-items: center;
        font-size: 0.95rem;
        color: #bdc3c7;
        margin: 2px 10px;
        border-radius: 8px;
    }

    .menu-item i {
        width: 25px;
        text-align: center;
        margin-right: 12px;
        font-size: 1.0rem;
        transition: transform 0.3s;
    }

    /* 호버 효과 */
    .menu-item:hover {
        background-color: rgba(255,255,255,0.08);
        color: #fff;
        transform: translateX(5px);
    }
    .menu-item:hover i { transform: scale(1.1); }

    /* 활성화 상태 */
    .menu-item.active {
        background: linear-gradient(90deg, #3498db 0%, #2980b9 100%);
        color: white;
        box-shadow: 0 4px 10px rgba(52, 152, 219, 0.3);
        font-weight: 500;
    }

    /* 하단 로그아웃 */
    .logout-container {
        margin-top: auto;
        padding: 20px;
        border-top: 1px solid rgba(255,255,255,0.05);
    }
    .menu-item.logout { color: #f1f1f1; }
    .menu-item.logout:hover { background-color: rgba(231, 76, 60, 0.1); color: #ff6b6b; }
</style>

<div class="sidebar">
    <div class="sidebar-header">
		<div class="app-title"><i class="fas fa-ship"></i> VMS PRO</div>		
		<div class="user-profile">
		    <div class="profile-icon">
		        <i class="fas fa-user-circle"></i>
		    </div>		    
		    <div class="profile-info">
		        <div class="user-name">${sessionScope.userName}</div>
		        <span class="user-role role-${sessionScope.role}">${sessionScope.role}</span>
		    </div>
		</div>
    </div>

    <c:forEach var="group" items="${sessionScope.menuTree}">
        
        <div class="menu-group">${group.menuName}</div>
        
        <c:forEach var="menu" items="${group.children}">
            <div id="menu-${menu.menuCode}" class="menu-item" 
                 onclick="location.href='${pageContext.request.contextPath}${menu.menuUrl}'">
                
                <i class="${menu.iconClass}"></i>
                <span>${menu.menuName}</span>
            </div>
        </c:forEach>
        
    </c:forEach>
    <div class="logout-container">
        <div class="menu-item logout" onclick="location.href='${pageContext.request.contextPath}/logout'">
            <i class="fas fa-sign-out-alt"></i> <span>Logout</span>
        </div>
    </div>
</div>

<script>
    // Active 처리 (URL 비교)
    var path = window.location.pathname;
    
    // JSTL 루프 밖이라도 id="menu-코드" 패턴을 썼으므로 JS로 접근 가능
    <c:forEach var="group" items="${sessionScope.menuTree}">
        <c:forEach var="menu" items="${group.children}">
            var menuPath = "${menu.menuUrl}";
            // 메인("/")인 경우와 그 외("/alarm") 구분
            if (menuPath === "/" && (path.endsWith("/") || path.endsWith("/index.jsp"))) {
                document.getElementById('menu-${menu.menuCode}').classList.add('active');
            } else if (menuPath !== "/" && path.includes(menuPath)) {
                document.getElementById('menu-${menu.menuCode}').classList.add('active');
            }
        </c:forEach>
    </c:forEach>
</script>