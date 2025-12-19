<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>VMS Live Monitoring</title>
    <link rel="icon" href="${pageContext.request.contextPath}/static/images/cargo-ship.png" type="image/png">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.7.1/dist/leaflet.css" />
    <link rel="stylesheet" href="${pageContext.request.contextPath}/static/css/style.css" />    
</head>    
<body>

    <jsp:include page="include/sidebar.jsp" />
    
    <div id="map" style="position:relative;">
        
        <div class="map-overlay-control search-container">
            <div class="search-input-wrapper">
                <i class="fas fa-search"></i>
                <input type="text" id="vesselSearch" class="search-input" placeholder="Search Vessel Name or ID..." autocomplete="off">
            </div>
            <div id="searchResults" class="search-results">
                </div>
        </div>

        <div class="map-overlay-control alarm-card" onclick="vmsApp.openGlobalAlarmModal()">
            <div class="alarm-icon-box">
                <i class="fas fa-bell"></i>
                <div class="alarm-pulse-dot" id="alarmBadge" style="display:none;"></div>
            </div>
            <div class="alarm-info">
                <span class="alarm-label">Active Alarms</span>
                <div class="alarm-count" id="totalAlarmCount">0 <span>ea</span></div>
            </div>
        </div>

    </div>

    <div id="alarmModal" class="modal-overlay">
        <div class="modal-container">
            <div class="modal-header">
                <div class="modal-title">
                    <i class="fas fa-exclamation-triangle" style="color:#e53e3e"></i>
                    <span id="modalTitle">Alarm History</span>
                    <span id="modalVesselName" style="font-weight:400; color:#718096; font-size:0.9em; margin-left:5px;"></span>
                </div>
                <button class="modal-close" onclick="vmsApp.closeModal()">&times;</button>
            </div>
            <div class="modal-body" id="alarmListBody"></div>
        </div>
    </div>

    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://unpkg.com/leaflet@1.7.1/dist/leaflet.js"></script>
	<script>
	var vmsApp = (function() {
	    var map;
	    var vesselData = [];
	    var aircraftData = []; // 항공기 데이터 저장용 배열 추가
	    var animState = {}; 
	    var baseSpeed = 0.005;
	    var currentFocusId = null; 
	    
	    var isMapInteracting = false; 
	    var interactTimeout = null;

	    var shipIcon = L.icon({
	        iconUrl: '${pageContext.request.contextPath}/static/images/cargo-ship.png', 
	        iconSize: [40, 40], iconAnchor: [20, 20], popupAnchor: [0, -30],
	        className: 'custom-ship-icon'
	    });

	    function init() {
	        map = L.map('map', { zoomControl: false }).setView([30.0, 0.0], 3);
	        L.control.zoom({ position: 'bottomright' }).addTo(map);
	        L.tileLayer('https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png', {
	            attribution: '&copy; OpenStreetMap &copy; CARTO', maxZoom: 19
	        }).addTo(map);
	        
	        loadVessels();
	        loadAircraft(); // 항공기 데이터 로드 추가
	        loadGlobalStats(); 
	        requestAnimationFrame(animateLoop);
	        
	        setInterval(function() {
	            console.log("자동 데이터 갱신 중...");
	            loadVessels();
	            loadAircraft(); // 항공기 데이터도 자동 갱신
	            loadGlobalStats();
	        }, 5 * 60 * 1000); 

	        setupEventListeners();
	    }

	    function setupEventListeners() {
	        $('#alarmModal').on('click', function(e) { if (e.target === this) closeModal(); });
	        
	        map.on('movestart zoomstart', function() {
	            isMapInteracting = true;
	            if(interactTimeout) clearTimeout(interactTimeout);
	        });

	        map.on('moveend zoomend', function() {
	            if(interactTimeout) clearTimeout(interactTimeout);
	            interactTimeout = setTimeout(function() { isMapInteracting = false; }, 200);
	        });

	        map.on('click', function(e) {
	            if (isMapInteracting) return;
	            $('#searchResults').hide();
	            if (currentFocusId !== null) resetView();
	        });

	        $('#vesselSearch').on('keyup', function() {
	            var val = $(this).val().toLowerCase();
	            if(val.length < 1) { $('#searchResults').hide(); return; }
	            filterVessels(val);
	        });
	    }

	    // 팝업 강제 오픈 로직 수정
	    function enterFocusMode(vehicleId) {
	        var targetId = String(vehicleId);
	        currentFocusId = targetId;

	        for (var id in animState) {
	            var state = animState[id];
	            var strId = String(id);

	            if (strId === targetId) {
	                // 1. 마커를 먼저 지도에 추가
	                if (!map.hasLayer(state.marker)) {
	                    state.marker.addTo(map);
	                }
	                
	                // 2. 시각화 토글
	                toggleVisuals(strId, true);
	                
	                // 3. 지도 이동
	                map.setView(state.marker.getLatLng(), 12);
	                
	                // 4. 강제로 팝업 오픈 (setTimeout으로 확실히 실행)
	                setTimeout(function() {
	                    if (state.marker && map.hasLayer(state.marker)) {
	                        state.marker.openPopup();
	                    }
	                }, 500); // 지연 시간 증가
	                
	            } else {
	                if (map.hasLayer(state.marker)) map.removeLayer(state.marker);
	                toggleVisuals(strId, false);
	            }
	        }
	    }

	    function resetView() {
	        currentFocusId = null; 
	        map.closePopup();

	        for (var id in animState) {
	            var state = animState[id];
	            if (!map.hasLayer(state.marker)) state.marker.addTo(map);
	            toggleVisuals(id, false);
	        }
	    }

	    function selectSearchedVessel(vehicleId) {
	        var strId = String(vehicleId);
	        if (!animState[strId]) return;

	        // 검색어 유지 및 팝업 자동 오픈
	        $('#searchResults').hide();
	        	     
	        enterFocusMode(strId);

	        //  팝업 오픈을 위한 추가 로직
	        var state = animState[strId];
	        setTimeout(function() {
	            if (state && state.marker && map.hasLayer(state.marker)) {
	                state.marker.openPopup();
	            }
	        }, 300);
	    }

	    function handleVesselClick(vehicleId) {
	        var targetId = String(vehicleId);
	        if (currentFocusId === targetId) {
	            resetView();
	        } else {
	            enterFocusMode(targetId);
	        }
	    }

	    function toggleVisuals(vehicleId, show) {
	        var state = animState[vehicleId];
	        if (!state) return;

	        var markerIcon = state.marker.getElement();

	        if (show) {
	            // 경로 데이터가 있을 때만 시각화 처리
	            if (state.path && state.path.length > 1) {
	                if (!state.lineLayer) {
	                    state.lineLayer = L.polyline(state.path, { 
	                        className: 'modern-track-line', 
	                        interactive: false 
	                    });
	                }
	                if (!map.hasLayer(state.lineLayer)) state.lineLayer.addTo(map);

	                if (!state.circleLayers) {
	                    state.circleLayers = [];
	                    state.path.forEach(function(point, index) {
	                        var circle = L.circleMarker(point, {
	                            radius: 5,
	                            fillColor: "#0055ff",
	                            color: "#ffffff",
	                            weight: 2,
	                            opacity: 1,
	                            fillOpacity: 0.8,
	                            className: 'path-node-circle'
	                        });
	                     
	                        var nodeTime = state.rawPathData && state.rawPathData[index] ? state.rawPathData[index].recordedTime : 'N/A';
	                        var popupContent = 
	                            '<div style="min-width:200px; font-family:\'Inter\', sans-serif;">' +
	                                '<div style="background:linear-gradient(135deg, #0055ff 0%, #0044cc 100%); padding:12px 15px; color:white; border-radius:8px 8px 0 0; margin:-1px -1px 0 -1px;">' +
	                                    '<div style="display:flex; align-items:center; gap:8px;">' +
	                                        '<i class="fas fa-map-pin" style="font-size:16px;"></i>' +
	                                        '<span style="font-size:15px; font-weight:700; letter-spacing:-0.3px;">Waypoint #' + (index + 1) + '</span>' +
	                                    '</div>' +
	                                '</div>' +
	                                '<div style="padding:15px; background:white;">' +
	                                    '<div style="display:grid; gap:10px;">' +
	                                        '<div style="display:flex; justify-content:space-between; align-items:center;">' +
	                                            '<span style="font-size:11px; color:#a0aec0; text-transform:uppercase; font-weight:600;">Latitude</span>' +
	                                            '<span style="font-weight:600; color:#2d3748; font-size:13px;">' + point[0].toFixed(5) + ' °</span>' +
	                                        '</div>' +
	                                        '<div style="display:flex; justify-content:space-between; align-items:center;">' +
	                                            '<span style="font-size:11px; color:#a0aec0; text-transform:uppercase; font-weight:600;">Longitude</span>' +
	                                            '<span style="font-weight:600; color:#2d3748; font-size:13px;">' + point[1].toFixed(5) + ' °</span>' +
	                                        '</div>' +
	                                        '<div style="border-top:1px solid #e2e8f0; padding-top:10px; margin-top:5px;">' +
	                                            '<div style="display:flex; justify-content:space-between; align-items:center;">' +
	                                                '<span style="font-size:11px; color:#a0aec0; text-transform:uppercase; font-weight:600;">' +
	                                                    '<i class="fas fa-clock" style="margin-right:4px;"></i>Time' +
	                                                '</span>' +
	                                                '<span style="font-weight:600; color:#0055ff; font-size:13px;">' + nodeTime + '</span>' +
	                                            '</div>' +
	                                        '</div>' +
	                                    '</div>' +
	                                '</div>' +
	                            '</div>';
	                        
	                        circle.bindPopup(popupContent);
	                        circle.addTo(map);
	                        state.circleLayers.push(circle);
	                    });
	                } else {
	                    state.circleLayers.forEach(function(c) { c.addTo(map); });
	                }
	            }
	            
	            if (markerIcon) {
	                markerIcon.classList.add('marker-pulse');
	                markerIcon.style.filter = "brightness(1.2)";
	            }

	        } else {
	            if (state.lineLayer && map.hasLayer(state.lineLayer)) {
	                map.removeLayer(state.lineLayer);
	            }
	            if (state.circleLayers) {
	                state.circleLayers.forEach(function(c) {
	                    if (map.hasLayer(c)) map.removeLayer(c);
	                });
	            }
	            
	            if (markerIcon) {
	                markerIcon.classList.remove('marker-pulse');
	                markerIcon.style.filter = "";
	            }
	        }
	    }
	    
	    function loadVesselPath(vesselId) {
	        // 항공기 ID 체크 (항공기는 API 호출 안함)
	        if (String(vesselId).startsWith('aircraft-')) {
	            return;
	        }
	        
	        $.ajax({
	            url: '/api/vessel/history', 
	            data: { vesselId: vesselId },
	            success: function(data) {
	                if (data && data.length > 1) {
	                    var strId = String(vesselId);
	                    var state = animState[strId];
	                    
	                    state.path = data.map(function(d) { return [d.lat, d.lng]; });
	                    state.rawPathData = data;
	                    
	                    if (currentFocusId === strId) {
	                        toggleVisuals(strId, false);
	                        toggleVisuals(strId, true);
	                    }
	                }
	            }
	        });
	    }

	    function animateLoop() {
	        var currentZoom = map.getZoom();
	        var speedFactor = Math.pow(1.8, currentZoom - 3); 
	        var adjustedSpeed = baseSpeed / speedFactor;

	        for (var id in animState) {
	            var state = animState[id];
	            if (!state.path || state.path.length < 2) continue;
	            
	            if (!map.hasLayer(state.marker)) continue; 

	            state.progress += adjustedSpeed;
	            if (state.progress >= 1) {
	                state.progress = 0;
	                state.currentIndex++;
	                if (state.currentIndex >= state.path.length - 1) state.currentIndex = 0;
	            }
	            
	            var p1 = state.path[state.currentIndex];
	            var p2 = state.path[state.currentIndex + 1];
	            var lat = p1[0] + (p2[0] - p1[0]) * state.progress;
	            var lng = p1[1] + (p2[1] - p1[1]) * state.progress;
	            state.marker.setLatLng([lat, lng]);
	        }
	        requestAnimationFrame(animateLoop);
	    }

	    function filterVessels(keyword) {
	        // 선박과 항공기 모두 검색
	        var allVehicles = vesselData.concat(aircraftData);
	        var matches = allVehicles.filter(function(v) {
	            return v.name.toLowerCase().includes(keyword) || String(v.id).toLowerCase().includes(keyword);
	        });
	        
	        var html = '';
	        if(matches.length === 0) {
	            html = '<div class="search-item" style="cursor:default; color:#a0aec0;">No results found</div>';
	        } else {
	            matches.forEach(function(v) {
	                html += '<div class="search-item" onclick="vmsApp.selectSearchedVessel(\'' + v.id + '\')">' +
	                            '<span class="search-item-name">' + v.name + '</span>' +
	                            '<span class="search-item-id">' + v.id + '</span>' +
	                        '</div>';
	            });
	        }
	        $('#searchResults').html(html).show();
	    }

	    function loadVessels() {
	        $.ajax({
	            url: '/api/vessels', type: 'GET', dataType: 'json',
	            success: function(data) {
	                if (!data) { location.href = "/login"; return; }
	                vesselData = data;
	                updateVesselsUI();
	            }
	        });
	    }

	    // 항공기 데이터 로드 함수 추가 (20개 랜덤)
	    function loadAircraft() {
	        $.ajax({
	            url: 'https://opensky-network.org/api/states/all',
	            type: 'GET',
	            dataType: 'json',
	            success: function(response) {
	                if (!response || !response.states) return;
	                
	                // 위도/경도가 있는 항공기만 필터링
	                var validAircraft = response.states.filter(function(state) {
	                    return state[5] !== null && state[6] !== null;
	                });
	                
	                // 랜덤으로 20개 선택
	                var shuffled = validAircraft.sort(function() { return 0.5 - Math.random(); });
	                var selected = shuffled.slice(0, 20);
	                
	                // 선박 데이터 형식과 동일하게 변환
	                aircraftData = selected.map(function(state) {
	                    return {
	                        id: 'aircraft-' + state[0],
	                        name: state[1] ? state[1].trim() : state[0],
	                        lat: state[6],
	                        lng: state[5],
	                        status: state[8] ? 'Inactive' : 'Active'
	                    };
	                });
	                
	                updateAircraftUI();
	            },
	            error: function(xhr, status, error) {
	                console.error('항공기 데이터 로드 실패:', error);
	            }
	        });
	    }

	    function updateVesselsUI() {
	        vesselData.forEach(function(v) {
	            var strId = String(v.id);
	            
	            if (animState[strId]) {
	                var state = animState[strId];
	                bindPopupContent(state.marker, v);
	                loadVesselPath(v.id);
	            } else {
	                var marker = L.marker([v.lat, v.lng], { icon: shipIcon });
	                
	                if (currentFocusId !== null && strId !== currentFocusId) {
	                    // 유지
	                } else {
	                    marker.addTo(map);
	                }

	                bindPopupContent(marker, v);
	                
	                animState[strId] = { 
	                    marker: marker, 
	                    path: [], 
	                    rawPathData: [], 
	                    currentIndex: 0, 
	                    progress: 0, 
	                    lineLayer: null,
	                    circleLayers: null 
	                };

	                loadVesselPath(v.id);
	                
	                marker.on('click', function(e) { 
	                    L.DomEvent.stopPropagation(e);
	                    handleVesselClick(v.id); 
	                });
	            }
	        });
	    }

	    // 항공기 UI 업데이트 함수 (경로 누적 기능 추가)
	    function updateAircraftUI() {
	        aircraftData.forEach(function(a) {
	            var strId = String(a.id);
	            
	            if (animState[strId]) {
	                var state = animState[strId];
	                bindPopupContent(state.marker, a);
	                
	                // 경로 누적 (실시간 위치 추가)
	                var currentPos = [a.lat, a.lng];
	                if (state.path.length === 0 || 
	                    state.path[state.path.length - 1][0] !== currentPos[0] || 
	                    state.path[state.path.length - 1][1] !== currentPos[1]) {
	                    state.path.push(currentPos);
	                    state.rawPathData.push({
	                        lat: a.lat,
	                        lng: a.lng,
	                        recordedTime: new Date().toLocaleString()
	                    });
	                    
	                    // 경로가 너무 길어지면 오래된 데이터 제거
	                    if (state.path.length > 50) {
	                        state.path.shift();
	                        state.rawPathData.shift();
	                    }
	                }
	                
	                // 마커 위치도 업데이트
	                state.marker.setLatLng([a.lat, a.lng]);
	                
	            } else {
	                var marker = L.marker([a.lat, a.lng], { icon: shipIcon });
	                
	                if (currentFocusId !== null && strId !== currentFocusId) {
	                    // 유지
	                } else {
	                    marker.addTo(map);
	                }

	                bindPopupContent(marker, a);
	                
	                // 초기 경로 데이터 설정
	                animState[strId] = { 
	                    marker: marker, 
	                    path: [[a.lat, a.lng]], 
	                    rawPathData: [{
	                        lat: a.lat,
	                        lng: a.lng,
	                        recordedTime: new Date().toLocaleString()
	                    }], 
	                    currentIndex: 0, 
	                    progress: 0, 
	                    lineLayer: null,
	                    circleLayers: null 
	                };
	                
	                marker.on('click', function(e) { 
	                    L.DomEvent.stopPropagation(e);
	                    handleVesselClick(a.id); 
	                });
	            }
	        });
	    }

	    function fetchAndShowAlarms(params) {
	        $('#alarmListBody').html('<div class="empty-state"><i class="fas fa-spinner fa-spin"></i> Loading...</div>');
	        $('#alarmModal').css('display', 'flex');
	        setTimeout(function() {
	            var mockData = [];
	            var types = ['OVERSPEED', 'ENTER_AREA', 'ANCHOR_DRAG'];
	            var msgs = ['Speed exceeds 15kn', 'Entered restricted zone A', 'Anchor dragging detected'];
	            var count = params.vesselId ? 5 : 20; 
	            for(var i=0; i < count; i++) {
	                var randIdx = Math.floor(Math.random() * 3);
	                mockData.push({ type: types[randIdx], message: msgs[randIdx] + ' (TEST #' + (i+1) + ')', time: '2023-10-27 ' + (10 + Math.floor(i/2)) + ':' + (10 + i) });
	            }
	            renderAlarmList(mockData);
	        }, 300);
	    }
	    
	    function renderAlarmList(data) {
	        var html = '';
	        if (!data || data.length === 0) {
	            html = '<div class="empty-state"><i class="far fa-check-circle fa-2x"></i><br><br>No Alarm History</div>';
	        } else {
	            data.forEach(function(alarm) {
	                var iconClass = alarm.type === 'OVERSPEED' ? 'icon-OVERSPEED' : (alarm.type === 'ANCHOR_DRAG' ? 'icon-ANCHOR_DRAG' : 'icon-ENTER_AREA');
	                var iconHtml = alarm.type === 'OVERSPEED' ? '<i class="fas fa-tachometer-alt"></i>' : (alarm.type === 'ANCHOR_DRAG' ? '<i class="fas fa-anchor"></i>' : '<i class="fas fa-map-marked-alt"></i>');
	                html += '<div class="alarm-item"><div class="alarm-icon ' + iconClass + '">' + iconHtml + '</div><div class="alarm-content"><div class="alarm-type">' + alarm.type + '</div><div class="alarm-msg">' + alarm.message + '</div><span class="alarm-time">' + alarm.time + '</span></div></div>';
	            });
	        }
	        $('#alarmListBody').html(html);
	    }
	    
	    function loadGlobalStats() { $('#totalAlarmCount').html('20 <span>ea</span>'); $('#alarmBadge').show(); }
	    function openAlarmModal(vehicleId, vehicleName) { map.closePopup(); $('#modalTitle').text("Alarm History"); $('#modalVesselName').text("for " + vehicleName).show(); fetchAndShowAlarms({ vesselId: vehicleId }); }
	    function openGlobalAlarmModal() { $('#modalTitle').text("Global Alarm List"); $('#modalVesselName').hide(); fetchAndShowAlarms({}); }
	    function closeModal() { $('#alarmModal').fadeOut(200); }
	    function togglePath(vehicleId) { handleVesselClick(vehicleId); }
	    
	    function bindPopupContent(marker, v) {
	        var statusColor = v.status === 'Active' ? '#38a169' : '#e53e3e';
	        
	        var popupHtml = 
	            '<div style="min-width:240px; font-family:\'Inter\', sans-serif;">' +
	                '<div style="background:linear-gradient(135deg, #1a365d 0%, #2a4365 100%); padding:15px; color:white;">' +
	                    '<div style="font-size:14px; opacity:0.8; margin-bottom:4px;">Vessel Name</div>' +
	                    '<div style="font-size:18px; font-weight:700; letter-spacing:-0.5px;">' + v.name + '</div>' +
	                '</div>' +
	                '<div style="padding:15px; background:white;">' +
	                    '<div style="display:grid; grid-template-columns: 1fr 1fr; gap:10px; margin-bottom:15px;">' +
	                        '<div>' +
	                            '<div style="font-size:11px; color:#a0aec0; text-transform:uppercase;">Status</div>' +
	                            '<div style="font-weight:600; color:' + statusColor + '">' + v.status + '</div>' +
	                        '</div>' +
	                        '<div>' +
	                            '<div style="font-size:11px; color:#a0aec0; text-transform:uppercase;">ID</div>' +
	                            '<div style="font-weight:600;">' + v.id + '</div>' +
	                        '</div>' +
	                    '</div>' +
	                    '<div style="display:flex; gap:8px;">' +
	                        '<button onclick="vmsApp.togglePath(\'' + v.id + '\')" ' +
	                                'style="flex:1; background:#ebf4ff; color:#3182ce; border:none; padding:8px; border-radius:6px; font-weight:600; cursor:pointer;">' +
	                            '<i class="fas fa-route"></i> Track' +
	                        '</button>' +
	                        '<button onclick="vmsApp.openAlarmModal(\'' + v.id + '\', \'' + v.name + '\')"' +
	                                'style="flex:1; background:#fff5f5; color:#e53e3e; border:none; padding:8px; border-radius:6px; font-weight:600; cursor:pointer;">' +
	                            '<i class="fas fa-bell"></i> Alarm' +
	                        '</button>' +
	                    '</div>' +
	                '</div>' +
	            '</div>';
	        
	        marker.bindPopup(popupHtml, { maxWidth: 300, closeButton: false });
	    }

	    return { 
	        init: init, 
	        togglePath: togglePath, 
	        openAlarmModal: openAlarmModal, 
	        openGlobalAlarmModal: openGlobalAlarmModal, 
	        selectSearchedVessel: selectSearchedVessel, 
	        closeModal: closeModal 
	    };
	})();

	$(document).ready(function() { vmsApp.init(); });
	</script>

</body>
</html>