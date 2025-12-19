<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<style>
    .admin-layout { display: flex; gap: 20px; }
    .panel { flex: 1; background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 5px rgba(0,0,0,0.1); }
    .btn-icon {
        width: 32px;
        height: 32px;
        border-radius: 50%; /* 완전한 원형 */
        border: none;
        cursor: pointer;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        margin: 0 2px;
        transition: all 0.2s ease;
        font-size: 0.9rem;
    }

    /* 수정 버튼 (기본: 연한 파랑 배경 / 호버: 진한 파랑) */
    .btn-edit {
        background-color: #e8f4fd;
        color: #3498db;
    }
    .btn-edit:hover {
        background-color: #3498db;
        color: white;
        transform: translateY(-2px); /* 살짝 떠오르는 효과 */
        box-shadow: 0 3px 8px rgba(52, 152, 219, 0.3);
    }

    /* 삭제 버튼 (기본: 연한 빨강 배경 / 호버: 진한 빨강) */
    .btn-del {
        background-color: #fde8e8;
        color: #e74c3c;
    }
    .btn-del:hover {
        background-color: #e74c3c;
        color: white;
        transform: translateY(-2px);
        box-shadow: 0 3px 8px rgba(231, 76, 60, 0.3);
    }
    .form-group { margin-bottom: 15px; }
    .form-label { display: block; margin-bottom: 5px; font-weight: 600; color: #555; }
    .form-input { width: 100%; padding: 8px; border: 1px solid #ddd; border-radius: 4px; box-sizing: border-box; }
    .vessel-select-wrapper { border: 1px solid #ddd; padding: 10px; border-radius: 4px; background: #fcfcfc; }
    .group-select-row { display: flex; gap: 5px; margin-bottom: 8px; }
    .group-select { flex: 1; padding: 6px; border: 1px solid #ccc; border-radius: 3px; font-size: 13px; }
    .btn-apply { padding: 6px 12px; background: #34495e; color: white; border: none; border-radius: 3px; cursor: pointer; font-size: 13px; font-weight: bold; }
    .vessel-list-box { height: 180px; overflow-y: auto; background: white; border: 1px solid #eee; padding: 8px; border-radius: 3px; }
    .vessel-chk-item { margin-bottom: 5px; font-size: 0.9rem; }
    .vessel-chk-item label { cursor: pointer; margin-left: 5px; }
</style>

<div class="admin-layout">
    <div class="panel">
        <h3>📂 Managed Accounts</h3>
        <c:forEach var="u" items="${managedUsers}">
            <div style="padding: 10px; border-bottom: 1px solid #eee;">
                <b>${u.userId}</b> (${u.userName})
                <div style="float: right;">
				    <button class="btn-icon btn-edit" onclick="openEditModal('${u.userId}', '${u.userName}')" title="Edit">
					    <i class="fas fa-pen"></i>
					</button>					
					<button class="btn-icon btn-del" onclick="deleteUser('${u.userId}')" title="Delete">
					    <i class="fas fa-trash-alt"></i>
					</button>
                </div>
            </div>
        </c:forEach>
    </div>

    <div class="panel">
        <h3>➕ Create New Account</h3>
        <input type="text" id="c_id" placeholder="ID" style="width:100%; margin-bottom:10px; padding:8px;">
        <input type="password" id="c_pw" placeholder="Password" style="width:100%; margin-bottom:10px; padding:8px;">
        <input type="text" id="c_name" placeholder="Name" style="width:100%; margin-bottom:10px; padding:8px;">
        
        <div class="form-group">
            <label class="form-label">Assign Vessels by Group</label>
            <div class="vessel-select-wrapper">
                <div class="group-select-row">
                    <select id="c_group_select" class="group-select" onfocus="refreshGroupList()">
                        <option value="">-- Select Group to Check --</option>
                        <option value="ALL">All Vessels</option>
                        <option value="NONE">Clear All</option>
                    </select>
                    <button type="button" class="btn-apply" onclick="applyGroupSelection('c')">Apply</button>
                </div>
                <div class="vessel-list-box">
                    <c:forEach var="v" items="${vesselList}">
                        <div class="vessel-chk-item">
                            <input type="checkbox" name="c_vessels" value="${v.id}" id="cv_${v.id}"> 
                            <label for="cv_${v.id}">${v.name}</label>
                        </div>
                    </c:forEach>
                </div>
            </div>
        </div>
        <button onclick="createUser()" style="width:100%; margin-top:10px; padding:10px; background:#3498db; color:white; border:none; cursor:pointer;">Create</button>
    </div>
</div>

<div id="editModal" class="modal" style="display:none; position:fixed; z-index:1000; left:0; top:0; width:100%; height:100%; background-color:rgba(0,0,0,0.5);">
    <div class="modal-content" style="background:#fff; margin:10% auto; padding:20px; width:400px; border-radius:8px;">
        <span class="close" onclick="$('#editModal').hide()" style="float:right; cursor:pointer; font-size:20px;">&times;</span>
        <h3>Edit User: <span id="e_display_id"></span></h3>
        <input type="hidden" id="e_id">
        <p>Name: <input type="text" id="e_name" style="width:100%; padding:5px;"></p>
        <p>New Password: <input type="password" id="e_pw" placeholder="Leave blank to keep current" style="width:100%; padding:5px;"></p>
        
        <h4>Vessel Access</h4>
        <div class="vessel-select-wrapper">
            <div class="group-select-row">
                <select id="e_group_select" class="group-select" onfocus="refreshGroupList()">
                    <option value="">-- Select Group to Check --</option>
                    <option value="ALL">All Vessels</option>
                    <option value="NONE">Clear All</option>
                </select>
                <button type="button" class="btn-apply" onclick="applyGroupSelection('e')">Apply</button>
            </div>
            <div class="vessel-list-box">
                <c:forEach var="v" items="${vesselList}">
                    <div class="vessel-chk-item">
                        <input type="checkbox" name="e_vessels" value="${v.id}" id="chk_e_${v.id}"> 
                        <label for="chk_e_${v.id}">${v.name}</label>
                    </div>
                </c:forEach>
            </div>
        </div>
        <button onclick="updateUser()" style="width:100%; margin-top:10px; padding:10px; background:#27ae60; color:white; border:none; cursor:pointer;">Update</button>
    </div>
</div>

<script>
    var myVesselGroups = {}; 
    var groupDefinitions = []; 

    $(document).ready(function() {
        refreshGroupList();
        loadVesselMappings();
    });

    function refreshGroupList() {
        $.ajax({
            url: '/api/settings/groups', type: 'GET',
            success: function(res) {
                groupDefinitions = res || [];
                populateSelectBoxes();
            }
        });
    }

    function loadVesselMappings() {
        $.ajax({
            url: '/api/settings/vessels', type: 'GET',
            success: function(data) {
                if(data) {
                    data.forEach(function(v) { myVesselGroups[v.id] = v.groupId; });
                }
            }
        });
    }

    function populateSelectBoxes() {
        var options = '';
        groupDefinitions.forEach(function(g) {
            options += '<option value="' + g.id + '">' + g.name + '</option>';
        });
        
        var $cSelect = $('#c_group_select');
        var cVal = $cSelect.val();
        $cSelect.find('option:gt(2)').remove();
        $cSelect.append(options);
        $cSelect.val(cVal);

        var $eSelect = $('#e_group_select');
        var eVal = $eSelect.val();
        $eSelect.find('option:gt(2)').remove();
        $eSelect.append(options);
        $eSelect.val(eVal);
    }

    function applyGroupSelect(prefix) {
        var selectedGroup = $('#' + prefix + '_group_select').val();
        if (!selectedGroup) return; 

        $('input[name="' + prefix + '_vessels"]').each(function() {
            var vid = $(this).val();
            if (selectedGroup === 'ALL') {
                $(this).prop('checked', true);
            } else if (selectedGroup === 'NONE') {
                $(this).prop('checked', false);
            } else {
                var gId = myVesselGroups[vid];
                if (gId == selectedGroup) { 
                    $(this).prop('checked', true);
                }
            }
        });
    }

    function openEditModal(id, name) {
        refreshGroupList();
        loadVesselMappings();
        $('#e_id').val(id);
        $('#e_display_id').text(id);
        $('#e_name').val(name);
        $('#e_pw').val(''); 
        $('input[name="e_vessels"]').prop('checked', false); 

        $.ajax({
            url: '/api/settings/user-vessels', data: { targetId: id },
            success: function(vesselIds) {
                if(vesselIds) {
                    vesselIds.forEach(function(vid) { $('#chk_e_' + vid).prop('checked', true); });
                }
                $('#editModal').show();
            }
        });
    }

    function reloadWithTab() {
        localStorage.setItem('lastActiveSettingsTab', 'admin'); 
        setTimeout(function(){ location.reload(); }, 1000);
    }

    function createUser() {
        var vList = [];
        $('input[name="c_vessels"]:checked').each(function() { vList.push($(this).val()); });
        
        if(!$('#c_id').val()) { 
            showAlert('ID is required', 'error'); 
            return; 
        }
        
        var data = { newId: $('#c_id').val(), newPw: $('#c_pw').val(), newName: $('#c_name').val(), vessels: vList };
        
        $.ajax({ 
            url: '/api/settings/create-user', type: 'POST', contentType: 'application/json', 
            data: JSON.stringify(data), 
            success: function(res) { 
                if(res === 'SUCCESS') {
                    showAlert('Account Created Successfully!', 'success');
                    reloadWithTab(); 
                } else {
                    showAlert('Create Failed: ' + res, 'error');
                }
            } 
        });
    }

    function deleteUser(id) {
        if(!confirm("Delete this user?")) return;
        
        $.ajax({ 
            url: '/api/settings/delete-user', type: 'POST', contentType: 'application/json', 
            data: JSON.stringify({ targetId: id }), 
            success: function(res) { 
                if(res === 'SUCCESS') {
                    showAlert('Deleted Successfully!', 'success');
                    reloadWithTab(); 
                } else {
                    showAlert('Delete Failed', 'error');
                }
            } 
        });
    }

    function updateUser() {
        var vList = [];
        $('input[name="e_vessels"]:checked').each(function() { vList.push($(this).val()); });
        
        var data = { 
            targetId: $('#e_id').val(), 
            newPw: $('#e_pw').val(), 
            newName: $('#e_name').val(), 
            vessels: vList 
        };
        
        $.ajax({ 
            url: '/api/settings/update-user', type: 'POST', contentType: 'application/json', 
            data: JSON.stringify(data), 
            success: function(res) { 
                if(res === 'SUCCESS') {
                    showAlert('Updated Successfully!', 'success');
                    reloadWithTab(); 
                } else {
                    showAlert('Update Failed: ' + res, 'error');
                }
            } 
        });
    }
</script>