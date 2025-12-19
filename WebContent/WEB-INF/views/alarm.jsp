<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Alarm List</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" />
    <link rel="stylesheet" href="${pageContext.request.contextPath}/static/css/style.css" />
    <style>
        /* 검색창 스타일 */
        .search-box { display:flex; gap:10px; align-items:center; }
        .search-box input { padding:8px; border:1px solid #ddd; border-radius:4px; }
        .btn { padding:8px 15px; border:none; border-radius:4px; cursor:pointer; color:white; font-weight:bold; }
        .btn-search { background:#3498db; }
        
        /* 테이블 스타일 */
        table { width:100%; border-collapse:collapse; background:white; box-shadow:0 2px 5px rgba(0,0,0,0.05); }
        th, td { padding:12px; text-align:left; border-bottom:1px solid #eee; }
        th { background:#2c3e50; color:white; }
        
        /* 페이징 */
        .pagination { margin-top:20px; text-align:center; }
        .page-btn { display:inline-block; padding:5px 10px; margin:0 2px; border:1px solid #ddd; background:white; cursor:pointer; }
        .page-btn.active { background:#3498db; color:white; border-color:#3498db; }
    </style>
</head>
<body>
    <jsp:include page="include/sidebar.jsp" />

    <div class="content">
        <div class="page-header">
            <h2><i class="fas fa-bell"></i> Alarm History</h2>
            <div class="search-box">
                <input type="date" id="startDate"> ~ <input type="date" id="endDate">
                <button class="btn btn-search" onclick="loadAlarms(1)">Search</button>
            </div>
        </div>

        <table>
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Vessel</th>
                    <th>Type</th>
                    <th>Message</th>
                    <th>Time</th>
                </tr>
            </thead>
            <tbody id="alarmBody">
                </tbody>
        </table>
        
        <div class="pagination" id="pagination"></div>
    </div>

  <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script>
    function loadAlarms(page) {
        $.ajax({
            url: '/api/alarms',
            type: 'GET',
            data: {
                startDate: $('#startDate').val(),
                endDate: $('#endDate').val(),
                page: page
            },
            success: function(res) {
                var html = '';
                
                // 1. 데이터 없음 처리
                if (!res.list || res.list.length === 0) {
                    html += '<tr>';
                    html += '  <td colspan="5" style="text-align:center; padding: 50px; color: #95a5a6;">';
                    html += '    <i class="fas fa-folder-open fa-3x"></i><br><br>';
                    html += '    <span style="font-size: 1.2em; font-weight: bold;">No Alarm Data Found</span><br>';
                    html += '    <span style="font-size: 0.9em;">Try changing the date range.</span>';
                    html += '  </td>';
                    html += '</tr>';
                    
                    $('#pagination').empty();
                } 
                // 2. 데이터 있음 처리 
                else {
                    for (var i = 0; i < res.list.length; i++) {
                        var item = res.list[i];
                        // 알람 타입별 뱃지 색상 
                        var badgeColor = (item.alarmType === 'OVERSPEED') ? '#e74c3c' : '#f39c12';
                        
                        html += '<tr>';
                        html += '  <td>' + item.alarmId + '</td>';
                        html += '  <td><b style="color:#2c3e50"><i class="fas fa-ship"></i> ' + item.vesselId + '</b></td>';
                        html += '  <td>';
                        html += '    <span style="background:' + badgeColor + '; color:white; padding:4px 8px; border-radius:4px; font-size:0.85em; font-weight:bold;">';
                        html +=        item.alarmType;
                        html += '    </span>';
                        html += '  </td>';
                        html += '  <td style="color:#555;">' + item.message + '</td>';
                        html += '  <td style="color:#7f8c8d; font-size:0.9em;">';
                        html += '    <i class="far fa-clock"></i> ' + item.createdAt;
                        html += '  </td>';
                        html += '</tr>';
                    }
                    renderPagination(res.total, res.page);
                }
                
                $('#alarmBody').html(html);
            },
            error: function(err) {
                console.error("API Error:", err);
                alert("Failed to load data.");
            }
        });
    }

    function renderPagination(total, currentPage) {
        if(total === 0) return;

        var totalPages = Math.ceil(total / 10);
        var html = '';
        
        for(var i=1; i<=totalPages; i++) {
            var active = (i === currentPage) ? 'active' : '';
            html += '<span class="page-btn ' + active + '" onclick="loadAlarms(' + i + ')">' + i + '</span>';
        }
        $('#pagination').html(html);
    }

    $(document).ready(function() {
        // 종료일: 오늘
        document.getElementById('endDate').valueAsDate = new Date();
        
        // 시작일: 7일 전 (과거 데이터 조회용)
        var today = new Date();
        var lastWeek = new Date(today.setDate(today.getDate() - 7));
        document.getElementById('startDate').valueAsDate = lastWeek;

        loadAlarms(1);
    });
</script>
</body>
</html>