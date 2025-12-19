<%@ page contentType="text/html; charset=UTF-8" %>

<style>
    /* --- 모달 공통 스타일 --- */
    .modal-overlay {
        display: none; position: fixed; z-index: 9999!important; left: 0; top: 0; width: 100%; height: 100%;
        background-color: rgba(0,0,0,0.5); backdrop-filter: blur(2px);
        align-items: center; justify-content: center;
    }
    .modal-dialog {
        background: #fff; border-radius: 8px; box-shadow: 0 10px 25px rgba(0,0,0,0.2);
        width: 500px; max-width: 90%; animation: slideDown 0.3s ease; display: flex; flex-direction: column;
        max-height: 90vh; /* 화면 넘어감 방지 */
    }
    @keyframes slideDown { from { transform: translateY(-20px); opacity: 0; } to { transform: translateY(0); opacity: 1; } }
    
    .modal-header { padding: 15px 20px; border-bottom: 1px solid #eee; display: flex; justify-content: space-between; align-items: center; }
    .modal-title { font-size: 1.1rem; font-weight: bold; color: #333; margin: 0; }
    .modal-close { cursor: pointer; font-size: 1.5rem; color: #999; line-height: 1; }
    .modal-close:hover { color: #333; }
    
    .modal-body { padding: 20px; overflow-y: auto; }
    .modal-footer { padding: 15px 20px; border-top: 1px solid #eee; text-align: right; background: #f9f9f9; border-radius: 0 0 8px 8px; }

    /* --- 커스텀 Alert (Toast) 스타일 --- */
    .custom-toast {
        visibility: hidden; min-width: 250px; background-color: #333; color: #fff; text-align: center;
        border-radius: 4px; padding: 12px; position: fixed; z-index: 10000; left: 50%; bottom: 30px;
        transform: translateX(-50%); font-size: 14px; opacity: 0; transition: opacity 0.3s;
    }
    .custom-toast.show { visibility: visible; opacity: 1; }
    .toast-success { background-color: #27ae60; }
    .toast-error { background-color: #e74c3c; }
</style>

<div id="commonFormModal" class="modal-overlay">
    <div class="modal-dialog">
        <div class="modal-header">
            <h3 id="formModalTitle" class="modal-title">Title</h3>
            <span class="modal-close" onclick="closeModal('commonFormModal')">&times;</span>
        </div>
        <div id="formModalBody" class="modal-body">
            </div>
        <div id="formModalFooter" class="modal-footer">
            </div>
    </div>
</div>

<div id="toastMessage" class="custom-toast">Message</div>

<script>
    // 모달 열기
    function openModal(modalId) {
        document.getElementById(modalId).style.display = 'flex';
    }

    // 모달 닫기
    function closeModal(modalId) {
        document.getElementById(modalId).style.display = 'none';
    }

    // 모달 외부 클릭 시 닫기
    window.onclick = function(event) {
        if (event.target.classList.contains('modal-overlay')) {
            event.target.style.display = 'none';
        }
    }

    // 커스텀 알림창 (Alert 대체)
    function showAlert(msg, type) {
    
        var x = document.getElementById("toastMessage");
        x.className = "custom-toast show";
        if(type === 'success') x.classList.add("toast-success");
        if(type === 'error') x.classList.add("toast-error");
         
        
        x.innerText = msg;
        
        setTimeout(function(){ 
            x.className = x.className.replace("show", ""); 
            x.classList.remove("toast-success", "toast-error");
        }, 3000);
    }
</script>