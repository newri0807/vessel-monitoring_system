<%@ page contentType="text/html; charset=UTF-8" %>

<style>
    .card-rounded {
        background: white;
        padding: 25px;
        border-radius: 20px; 
        box-shadow: 0 10px 30px rgba(0,0,0,0.05);
        border: 1px solid #f0f0f0;
    }

    .search-input-round {
        padding: 12px 20px;
        border: 1px solid #eee;
        border-radius: 25px;
        background: #f9f9f9;
        flex: 1;
        transition: 0.3s;
        outline: none;
    }
    .search-input-round:focus {
        background: #fff;
        border-color: #3498db;
        box-shadow: 0 0 0 3px rgba(52, 152, 219, 0.1);
    }

    .btn-round {
        padding: 10px 20px;
        border: none;
        border-radius: 25px; 
        cursor: pointer;
        font-weight: 600;
        transition: transform 0.2s, box-shadow 0.2s;
        display: flex; align-items: center; gap: 8px;
    }
    .btn-round:hover { transform: translateY(-2px); box-shadow: 0 5px 15px rgba(0,0,0,0.1); }
    .btn-purple { background: #9b59b6; color: white; }
    .btn-blue { background: #3498db; color: white; }
    .btn-green { background: #2ecc71; color: white; }
    .btn-red { background: #e74c3c; color: white; }

    /* 테이블 스타일 */
    .table-round { width: 100%; border-collapse: separate; border-spacing: 0 8px; }
    .table-round th { text-align: left; padding: 15px; color: #7f8c8d; font-size: 0.9rem; font-weight: 600; }
    .table-round td { 
        background: #fff; padding: 15px; 
        border-top: 1px solid #eee; border-bottom: 1px solid #eee;
    }
    .table-round tr td:first-child { border-left: 1px solid #eee; border-top-left-radius: 15px; border-bottom-left-radius: 15px; }
    .table-round tr td:last-child { border-right: 1px solid #eee; border-top-right-radius: 15px; border-bottom-right-radius: 15px; }
    .table-round tr:hover td { background: #fbfbfb; }

    /* 태그 스타일 */
    .group-pill {
        padding: 5px 12px;
        border-radius: 15px;
        background: #e8f6f3;
        color: #16a085;
        font-size: 0.85rem;
        font-weight: 600;
        display: inline-block;
    }
    .status-dot { display: inline-block; width: 10px; height: 10px; border-radius: 50%; margin-right: 8px; }
    .dot-none { background: #ccc; }
    .dot-set { background: #3498db; }

    /* 모달 내부 리스트 */
    .manage-list { margin-top: 15px; max-height: 300px; overflow-y: auto; }
    .manage-item { 
        display: flex; justify-content: space-between; align-items: center; 
        padding: 12px; margin-bottom: 8px; background: #f8f9fa; border-radius: 12px; 
    }

    /*  드롭다운 스타일 */
    .group-assign-select {
        width: 100%;
        padding: 8px 12px;
        border: 1px solid #ddd;
        border-radius: 20px; 
        background-color: #fff;
        font-size: 0.9rem;
        color: #555;
        cursor: pointer;
        outline: none;
        transition: border 0.3s;
    }
    .group-assign-select:focus {
        border-color: #3498db;
        box-shadow: 0 0 0 2px rgba(52,152,219,0.1);
    }
</style>

<div class="card-rounded">
    <h3 style="margin-top:0; color:#2c3e50;"><i class="fas fa-ship"></i> Vessel Group Management</h3>
    
    <div style="display: flex; gap: 15px; margin-bottom: 20px; align-items: center;">
        <input type="text" id="vesselSearch" class="search-input-round" placeholder="Search Vessel Name..." onkeyup="renderVesselTable()">
        
        <button class="btn-round btn-purple" onclick="openGroupDefModal()">
            <i class="fas fa-layer-group"></i> Manage Definitions
        </button>
        <button class="btn-round btn-blue" onclick="openVesselManageModal()">
            <i class="fas fa-exchange-alt"></i> Assign Groups
        </button>
    </div>

    <table class="table-round">
        <thead>
            <tr>
                <th>Vessel Name</th>
                <th>Status</th>
                <th>Assigned Group</th>
            </tr>
        </thead>
        <tbody id="vesselTableBody"></tbody>
    </table>
</div>

<div id="groupDefTemplate" style="display:none;">
    <div style="background: #fff; padding: 20px; border-radius: 15px; border: 1px solid #eee; margin-bottom: 15px;">
        <h4 style="margin:0 0 10px 0; color:#555;">Create New Group</h4>
        <div style="display:flex; gap:10px;">
            <input type="text" id="new_grp_name" class="search-input-round" placeholder="Enter Group Name (e.g. Pacific Fleet)">
            <button class="btn-round btn-green" onclick="createGroupDef()">
                <i class="fas fa-plus"></i> Add
            </button>
        </div>
    </div>
    
    <h4 style="margin:0 0 10px 0; color:#555;">Existing Groups</h4>
    <div id="groupListContainer" class="manage-list">
        </div>
</div>

<div id="vesselAssignTemplate" style="display:none;">
    <input type="text" id="assignSearch" class="search-input-round" style="width:100%; box-sizing:border-box;" placeholder="Filter vessels..." onkeyup="renderAssignList()">
    <div id="assignListContainer" class="manage-list" style="height:350px;"></div>
</div>
<script>
    var allVessels = [];
    var allGroups = [];

    $(document).ready(function(){
        loadData();
    });

    function loadData() {
        // 1. 그룹 목록 가져오기
        $.ajax({ 
            url: '/api/settings/groups', 
            type: 'GET', 
            async: false, // 동기식 처리, 그룹 먼저 로딩 보장
            success: function(res){ allGroups = res || []; } 
        });
        
        // 2. 선박 목록 가져오기
        $.ajax({ 
            url: '/api/settings/vessels', 
            type: 'GET', 
            success: function(res){ 
                allVessels = res || []; 
                renderVesselTable(); // 데이터 로드 후 테이블 그리기
            } 
        });
    }

    // --- 1. 메인 테이블 렌더링 ---
    function renderVesselTable() {
        var keyword = $('#vesselSearch').val().toLowerCase();
        var html = '';
        var filtered = allVessels.filter(v => v.name.toLowerCase().includes(keyword));
        
        if(filtered.length === 0) {
            html = '<tr><td colspan="3" style="text-align:center; padding:30px; color:#999;">No Data Found</td></tr>';
        } else {
            filtered.forEach(v => {
                var groupName = '<span style="color:#ccc;">Unassigned</span>';
                var dotClass = 'dot-none';
                
                // 그룹 매칭 (ID 비교)
                // v.groupId와 g.id의 타입(숫자 vs 문자열)이 다를 수 있으므로 == 사용
                var grp = allGroups.find(g => g.id == v.groupId);
                
                if(grp) {
                    groupName = '<span class="group-pill">' + grp.name + '</span>';
                    dotClass = 'dot-set';
                }

                html += '<tr>';
                html += '  <td><span class="status-dot ' + dotClass + '"></span><b>' + v.name + '</b></td>';
                html += '  <td>' + v.status + '</td>';
                html += '  <td>' + groupName + '</td>';
                html += '</tr>';
            });
        }
        $('#vesselTableBody').html(html);
    }

    // --- 2. 그룹 정의 관리 (Definitions) ---
    function openGroupDefModal() {
        $('#formModalTitle').text('Manage Groups');
        $('#formModalBody').html($('#groupDefTemplate').html());
        $('#formModalFooter').html('<button class="btn-round" style="background:#eee; color:#555;" onclick="closeModal(\'commonFormModal\');">Close</button>');
        
        renderGroupDefList();
        openModal('commonFormModal');
    }

    function renderGroupDefList() {
        var html = '';
        if(allGroups.length === 0) html = '<div style="text-align:center; color:#999; padding:20px;">No groups defined yet.</div>';
        
        allGroups.forEach(g => {
            html += '<div class="manage-item">';
            html += '  <div><b style="font-size:1.05rem;">' + g.name + '</b> <span style="font-size:0.8rem; color:#aaa; margin-left:5px;">(ID:' + g.id + ')</span></div>';
            html += '  <button class="btn-round btn-red" style="padding:5px 12px; font-size:0.8rem;" onclick="deleteGroupDef(\'' + g.id + '\')"><i class="fas fa-trash"></i></button>';
            html += '</div>';
        });
        $('#formModalBody #groupListContainer').html(html);
    }

    function createGroupDef() {
        var name = $('#formModalBody #new_grp_name').val();
        if(!name) { showAlert('Please enter a group name', 'error'); return; }

        $.ajax({
            url: '/api/settings/group-crud', type: 'POST', contentType: 'application/json',
            data: JSON.stringify({ mode: 'create', name: name }),
            success: function(res) {
                if(res === 'SUCCESS') {
                    // 그룹 목록 새로고침
                    $.ajax({ url: '/api/settings/groups', async:false, success: function(r){ allGroups = r; } });
                    renderGroupDefList(); // 팝업 리스트 갱신
                    renderVesselTable();  // 메인 테이블도 갱신
                    $('#formModalBody #new_grp_name').val('').focus();
                } else { showAlert('Error creating group', 'error'); }
            }
        });
    }

    function deleteGroupDef(id) {
        if(!confirm('Delete this group?')) return;
        $.ajax({
            url: '/api/settings/group-crud', type: 'POST', contentType: 'application/json',
            data: JSON.stringify({ mode: 'delete', groupId: id }),
            success: function(res) {
                // 그룹 목록 새로고침
                $.ajax({ url: '/api/settings/groups', async:false, success: function(r){ allGroups = r; } });
                
                // 삭제된 그룹을 가지고 있던 선박들의 데이터도 메모리상에서 초기화
                allVessels.forEach(v => {
                    if(v.groupId == id) v.groupId = 'NONE';
                });

                renderGroupDefList();
                renderVesselTable();
            }
        });
    }

    // --- 3. 선박 할당 (Assign Groups) ---
    function openVesselManageModal() {
        $('#formModalTitle').text('Assign Groups');
        $('#formModalBody').html($('#vesselAssignTemplate').html());
        // 닫을 때 메인 테이블 확실히 갱신
        $('#formModalFooter').html('<button class="btn-round" style="background:#eee; color:#555;" onclick="closeModal(\'commonFormModal\'); renderVesselTable();">Close</button>');
        
        renderAssignList();
        openModal('commonFormModal');
        
        $('#formModalBody #assignSearch').on('keyup', function() { renderAssignList(); });
    }

    function renderAssignList() {
        var keyword = $('#formModalBody #assignSearch').val().toLowerCase();
        var filtered = allVessels.filter(v => v.name.toLowerCase().includes(keyword));
        var html = '';

        if(filtered.length === 0) {
            $('#formModalBody #assignListContainer').html('<div style="text-align:center; padding:20px; color:#999;">No vessels match.</div>');
            return;
        }

        filtered.forEach(v => {
            // Select Box 생성
            var selectHtml = '<select class="group-assign-select" onchange="saveVesselGroup(\'' + v.id + '\', this.value)">';
            
            // NONE 옵션
            var isNone = (!v.groupId || v.groupId == 'NONE') ? 'selected' : '';
            selectHtml += '<option value="NONE" ' + isNone + '>-- No Group --</option>';

            // 그룹 목록 옵션
            allGroups.forEach(g => {
                var isSelected = (v.groupId == g.id) ? 'selected' : ''; // 숫자/문자 호환 비교
                selectHtml += '<option value="' + g.id + '" ' + isSelected + '>' + g.name + '</option>';
            });
            selectHtml += '</select>';

            html += '<div class="manage-item">';
            html += '  <div style="flex:1; font-weight:600; color:#2c3e50; display:flex; align-items:center;">';
            html += '    <i class="fas fa-ship" style="color:#bdc3c7; margin-right:8px;"></i>' + v.name;
            html += '  </div>';
            html += '  <div style="width: 200px;">' + selectHtml + '</div>';
            html += '</div>';
        });
        $('#formModalBody #assignListContainer').html(html);
    }

    // 저장 후 UI 즉시 반영 ★★★
    function saveVesselGroup(vid, gid) {
        $.ajax({
            url: '/api/settings/save', type: 'POST', contentType: 'application/json',
            data: JSON.stringify({ id: vid, groupId: gid }),
            success: function() {
                // 1. 메모리상 데이터 갱신
                var target = allVessels.find(v => v.id === vid);
                if(target) target.groupId = gid;

                // 2. 테이블 갱신
                renderVesselTable(); 
                
                // 3. 토스트 알림
                showAlert('Saved!', 'success');
            },
            error: function() { showAlert('Save Failed', 'error'); }
        });
    }
</script>
