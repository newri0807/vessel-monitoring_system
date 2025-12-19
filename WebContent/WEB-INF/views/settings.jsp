<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<jsp:include page="common/popups.jsp" />


<!DOCTYPE html>
<html>
<head>    
    <title>VMS Settings</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" />
    <link rel="stylesheet" href="${pageContext.request.contextPath}/static/css/style.css" />
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script> 
    <style>
        .content { padding: 20px; }
        .tab-container { margin-bottom: 20px; border-bottom: 2px solid #ddd; }
        .tab-btn { padding: 10px 20px; background: #f1f1f1; border: none; cursor: pointer; font-size: 14px; font-weight: bold; color: #555; border-radius: 5px 5px 0 0; margin-right: 5px; transition: 0.3s; }
        .tab-btn:hover { background: #ddd; }
        .tab-btn.active { background: #3498db; color: white; }
        .tab-content { display: none; }
        .tab-content.active { display: block; animation: fadeIn 0.3s; }
        @keyframes fadeIn { from { opacity: 0; } to { opacity: 1; } }
        
        /* 모달 스타일 (기존 유지) */
        .modal { display: none; position: fixed; z-index: 999; left: 0; top: 0; width: 100%; height: 100%; background-color: rgba(0,0,0,0.4); }
        .modal-content { background-color: #fefefe; margin: 10% auto; padding: 20px; border: 1px solid #888; width: 400px; border-radius: 8px; }
        .close { color: #aaa; float: right; font-size: 28px; font-weight: bold; cursor: pointer; }
    </style>
</head>
<body>
    <jsp:include page="include/sidebar.jsp" />

    <div class="content">
        <div class="tab-container">
            <button class="tab-btn active" onclick="openTab('vessel')">
                <i class="fas fa-ship"></i> VESSEL GROUPING
            </button>
            
            <c:if test="${sessionScope.role == 'SYSTEM' or sessionScope.role == 'ADMIN'}">
                <button class="tab-btn" onclick="openTab('account')">
                    <i class="fas fa-users-cog"></i> ACCOUNT SET
                </button>
                
                <button class="tab-btn" onclick="openTab('menu')">
                    <i class="fas fa-sitemap"></i> MENU SET
                </button>
            </c:if>
        </div>

        <div id="vessel" class="tab-content active">
            <%-- 기존 tab_personal.jsp 이름을 tab_vessel.jsp로 변경 권장 --%>
            <jsp:include page="settings/tab_vessel_group.jsp" />
        </div>

        <c:if test="${sessionScope.role == 'SYSTEM' or sessionScope.role == 'ADMIN'}">
            <div id="account" class="tab-content">
                <%-- 기존 tab_admin.jsp --%>
                <jsp:include page="settings/tab_account_set.jsp" />
            </div>

            <div id="menu" class="tab-content">
                <jsp:include page="settings/tab_menu_config.jsp" />
            </div>
        </c:if>
    </div>

    <script>
        $(document).ready(function() {
            // 새로고침 시 마지막 탭 유지
            var lastTab = localStorage.getItem('lastSettingsTab') || 'vessel';
            
            // 권한 체크: 저장된 탭이 관리자 메뉴인데 권한이 없으면 vessel로 강제 이동
            var role = '${sessionScope.role}';
            if((lastTab === 'account' || lastTab === 'menu') && (role !== 'SYSTEM' && role !== 'ADMIN')) {
                lastTab = 'vessel';
            }
            openTab(lastTab);
        });

        function openTab(tabName) {
            $('.tab-content').removeClass('active');
            $('.tab-btn').removeClass('active');
            $('#' + tabName).addClass('active');

            // 버튼 활성화 (onclick 속성값 매칭)
            $('.tab-btn').each(function() {
                if($(this).attr('onclick').includes("'" + tabName + "'")) {
                    $(this).addClass('active');
                }
            });
            localStorage.setItem('lastSettingsTab', tabName);
        }
    </script>
</body>
</html>