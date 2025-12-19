<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<style>
    .config-container { display: flex; gap: 20px; flex-wrap: wrap; }
    .config-card { flex: 1; min-width: 300px; background: #fff; border: 1px solid #ddd; border-radius: 8px; padding: 20px; box-shadow: 0 2px 5px rgba(0,0,0,0.05); }
    .card-header { display: flex; justify-content: space-between; align-items: center; border-bottom: 2px solid #f0f0f0; padding-bottom: 10px; margin-bottom: 15px; }
    .card-title { font-size: 1.1rem; font-weight: bold; color: #34495e; }
    
    /* 트리 구조 */
    ul.tree, ul.tree ul { list-style-type: none; margin: 0; padding: 0; }
    ul.tree ul { margin-left: 20px; border-left: 1px dashed #ccc; padding-left: 10px; } 
    ul.tree li { margin: 5px 0; position: relative; }
    ul.tree li::before { content: ""; position: absolute; top: 12px; left: -10px; width: 10px; height: 1px; background: #ccc; }
    
    .depth-1 > span { font-weight: bold; color: #2c3e50; font-size: 1rem; display: flex; align-items: center; }
    .depth-2 > span { font-weight: 500; color: #555; font-size: 0.95rem; display: flex; align-items: center; }
    
    .depth-3 { display: flex; align-items: center; background: #f9f9f9; padding: 5px 10px; border-radius: 4px; border: 1px solid #eee; transition: 0.2s; }
    .depth-3:hover { background: #eef2f5; }
    .depth-3 input { margin-right: 8px; cursor: pointer; transform: scale(1.1); }
    .depth-3 label { cursor: pointer; font-size: 0.9rem; color: #333; width: 100%; }

    /* SYSTEM 잠금 */
    input[type="checkbox"][disabled] { cursor: not-allowed; opacity: 0.6; }
    input[type="checkbox"][disabled] + label { color: #999; cursor: not-allowed; font-style: italic; }

    .tree-icon { width: 20px; text-align: center; margin-right: 5px; color: #3498db; }
    .folder-icon { color: #f39c12; }

    .save-btn { width: 100%; margin-top: 20px; padding: 10px; background: #34495e; color: white; border: none; border-radius: 4px; cursor: pointer; font-weight: bold; transition: 0.2s; }
    .save-btn:hover { background: #2c3e50; }
    .badge { font-size: 0.75rem; padding: 2px 6px; border-radius: 4px; color: white; margin-left: auto; }
</style>

<div class="panel">
    <h3><i class="fas fa-sitemap"></i> Menu Access Configuration</h3>
    <p style="color:#7f8c8d; font-size:0.9rem; margin-bottom: 20px;">
        Set menu visibility using the tree structure below. (Depth 1: System > Depth 2: Group > Depth 3: Page)
    </p>

    <div class="config-container">
        
        <c:if test="${sessionScope.role == 'SYSTEM'}">
            <div class="config-card">
                <div class="card-header">
                    <span class="card-title">Target: ADMIN</span>
                    <span class="badge" style="background:#f39c12;">Role</span>
                </div>
                <form id="form_admin">
                    <ul class="tree">
                        <li class="depth-1">
                            <span><i class="fas fa-desktop tree-icon"></i> VMS PRO System</span>
                            <ul>
                                <li class="depth-2">
                                    <div class="depth-2-item">
                                        <input type="checkbox" name="GRP_MON" id="adm_grp_mon" class="group-chk">
                                        <label for="adm_grp_mon"><i class="fas fa-folder folder-icon tree-icon"></i> Monitoring</label>
                                    </div>
                                    <ul>
                                        <li><div class="depth-3"><input type="checkbox" name="dashboard" id="adm_dash" class="leaf-chk"><label for="adm_dash">Dashboard</label></div></li>
                                        <li><div class="depth-3"><input type="checkbox" name="alarm" id="adm_alarm" class="leaf-chk"><label for="adm_alarm">Alarm List</label></div></li>
                                    </ul>
                                </li>
                                <li class="depth-2">
                                    <div class="depth-2-item">
                                        <input type="checkbox" name="GRP_MNG" id="adm_grp_mng" class="group-chk">
                                        <label for="adm_grp_mng"><i class="fas fa-folder folder-icon tree-icon"></i> Management</label>
                                    </div>
                                    <ul>
                                        <li><div class="depth-3"><input type="checkbox" name="settings" id="adm_set" class="leaf-chk"><label for="adm_set">Settings</label></div></li>
                                    </ul>
                                </li>
                            </ul>
                        </li>
                    </ul>
                    <button type="button" class="save-btn" onclick="saveMenuConfig('ADMIN')">Save Admin Config</button>
                </form>
            </div>
        </c:if>

        <c:if test="${sessionScope.role == 'SYSTEM' or sessionScope.role == 'ADMIN'}">
            <div class="config-card">
                <div class="card-header">
                    <span class="card-title">Target: OPERATOR</span>
                    <span class="badge" style="background:#27ae60;">Role</span>
                </div>
                <form id="form_operator">
                    <ul class="tree">
                        <li class="depth-1">
                            <span><i class="fas fa-desktop tree-icon"></i> VMS PRO System</span>
                            <ul>
                                <li class="depth-2">
                                    <div class="depth-2-item">
                                        <input type="checkbox" name="GRP_MON" id="opt_grp_mon" class="group-chk">
                                        <label for="opt_grp_mon"><i class="fas fa-folder folder-icon tree-icon"></i> Monitoring</label>
                                    </div>
                                    <ul>
                                        <li><div class="depth-3"><input type="checkbox" name="dashboard" id="opt_dash" class="leaf-chk"><label for="opt_dash">Dashboard</label></div></li>
                                        <li><div class="depth-3"><input type="checkbox" name="alarm" id="opt_alarm" class="leaf-chk"><label for="opt_alarm">Alarm List</label></div></li>
                                    </ul>
                                </li>
                                <li class="depth-2">
                                    <div class="depth-2-item">
                                        <input type="checkbox" name="GRP_MNG" id="opt_grp_mng" class="group-chk">
                                        <label for="opt_grp_mng"><i class="fas fa-folder folder-icon tree-icon"></i> Management</label>
                                    </div>
                                    <ul>
                                        <li><div class="depth-3"><input type="checkbox" name="settings" id="opt_set" class="leaf-chk"><label for="opt_set">Settings</label></div></li>
                                    </ul>
                                </li>
                            </ul>
                        </li>
                    </ul>
                    <button type="button" class="save-btn" onclick="saveMenuConfig('OPERATOR')">Save Operator Config</button>
                </form>
            </div>
        </c:if>

        <div class="config-card">
            <div class="card-header">
                <span class="card-title">Target: My Menu</span>
                <span class="badge" style="background:#3498db;">Personal</span>
            </div>
            <form id="form_personal">
                <ul class="tree">
                    <li class="depth-1">
                        <span><i class="fas fa-desktop tree-icon"></i> VMS PRO System</span>
                        <ul>
                            <li class="depth-2">
                                <div class="depth-2-item">
                                    <input type="checkbox" name="GRP_MON" id="my_grp_mon" class="group-chk">
                                    <label for="my_grp_mon"><i class="fas fa-folder folder-icon tree-icon"></i> Monitoring</label>
                                </div>
                                <ul>
                                    <li><div class="depth-3"><input type="checkbox" name="dashboard" id="my_dash" class="leaf-chk"><label for="my_dash">Dashboard</label></div></li>
                                    <li><div class="depth-3"><input type="checkbox" name="alarm" id="my_alarm" class="leaf-chk"><label for="my_alarm">Alarm List</label></div></li>
                                </ul>
                            </li>
                            <li class="depth-2">
                                <div class="depth-2-item">
                                    <input type="checkbox" name="GRP_MNG" id="my_grp_mng" class="group-chk">
                                    <label for="my_grp_mng"><i class="fas fa-folder folder-icon tree-icon"></i> Management</label>
                                </div>
                                <ul>
                                    <li><div class="depth-3"><input type="checkbox" name="settings" id="my_set" class="leaf-chk"><label for="my_set">Settings</label></div></li>
                                </ul>
                            </li>
                        </ul>
                    </li>
                </ul>
                <button type="button" class="save-btn" onclick="saveMenuConfig('PERSONAL')">Save My Config</button>
            </form>
        </div>

    </div>
</div>

<script>
    var currentRole = '${sessionScope.role}'; 

    $(document).ready(function(){
        registerTreeEvents();
        loadExistingConfig('ADMIN', 'ROLE');
        loadExistingConfig('OPERATOR', 'ROLE');
        loadExistingConfig('${sessionScope.userId}', 'USER');
    });

    // 트리 체크박스 연동
    function registerTreeEvents() {
        $(document).on('change', '.group-chk', function() {
            var isChecked = $(this).prop('checked');
            var $childUl = $(this).closest('li').find('> ul');
            $childUl.find('.leaf-chk').each(function() {
                if(!$(this).prop('disabled')) {
                    $(this).prop('checked', isChecked);
                }
            });
        });

        $(document).on('change', '.leaf-chk', function() {
            var $parentLi = $(this).closest('li.depth-2');
            var $parentChk = $parentLi.find('> .depth-2-item .group-chk');
            if($(this).prop('checked')) {
                $parentChk.prop('checked', true);
            } else {
                var anySiblingChecked = false;
                $parentLi.find('.leaf-chk').each(function(){
                    if($(this).prop('checked')) anySiblingChecked = true;
                });
                if(!anySiblingChecked && !$parentChk.prop('disabled')) {
                    $parentChk.prop('checked', false);
                }
            }
        });
    }

    // 설정 로드
    function loadExistingConfig(targetId, targetType) {
        var formId = "";
        if(targetType === 'ROLE') formId = '#form_' + targetId.toLowerCase();
        else formId = '#form_personal';
        
        if ($(formId).length === 0) return;

        $.ajax({
            url: '${pageContext.request.contextPath}/api/settings/menu-config',
            type: 'GET',
            data: { targetId: targetId, targetType: targetType },
            success: function(menuList) {
                $(formId).find('input[type="checkbox"]').prop('checked', false);
                if(menuList && menuList.length > 0) {
                    menuList.forEach(function(code) {
                        $(formId).find('input[name="' + code + '"]').prop('checked', true);
                    });
                }
                if(currentRole === 'SYSTEM') {
                    lockMandatoryMenus(formId);
                }
            }
        });
    }

    function lockMandatoryMenus(formId) {
        var mandatory = [ 'GRP_MON', 'GRP_MNG'];
        mandatory.forEach(function(code) {
            var $el = $(formId).find('input[name="' + code + '"]');
            $el.prop('checked', true);    
            $el.prop('disabled', true);   
        });
    }

    function saveMenuConfig(mode) {
        var data = { visibleMenus: [] };
        var formId = "";
        
        if (mode === 'PERSONAL') {
            formId = '#form_personal';
            data.configType = 'PERSONAL'; 
        } else {
            formId = (mode === 'ADMIN') ? '#form_admin' : '#form_operator';
            data.configType = 'ROLE_CONFIG';
            data.targetRole = mode;
        }

        // 체크된 항목 수집
        $(formId + ' input[type="checkbox"]').each(function() {
            // disabled 된 항목(필수값)도 prop('checked')는 true를 반환
            if($(this).prop('checked')) {
                data.visibleMenus.push($(this).attr('name'));
            }
        });

    
        $.ajax({
            url: '${pageContext.request.contextPath}/api/settings/update-menu-config',
            type: 'POST',
            contentType: 'application/json',
            data: JSON.stringify(data),
            success: function(res) {
                if(res === 'SUCCESS') {                
                    if (typeof showAlert === "function") {
                        showAlert('Saved Successfully!', 'success');
                    } else {
                        alert('Saved Successfully!'); 
                    }
                    
                    // 1.5초(1500ms) 기다렸다가 새로고침 ★
                    setTimeout(function() {
                        location.reload();
                    }, 1500); 

                } else {
                    if (typeof showAlert === "function") showAlert('Error: ' + res, 'error');
                    else alert('Error: ' + res);
                }
            },
            error: function(err) { 
                console.error("AJAX Error:", err);
                if (typeof showAlert === "function") showAlert('Server Error: ' + err.statusText, 'error');
                else alert('Server Error: ' + err.statusText);
            }
        });

    }

</script>