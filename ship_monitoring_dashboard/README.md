# 🚢 VMS Live Monitoring System

**VMS Live**는 전 세계 선박의 위치를 실시간 모니터링하고, 항적 추적 및 이상 징후 발생 시 알람을 제공하는 웹 기반 선박 관제 시스템입니다. Spring Framework와 Leaflet.js를 결합하여 동적인 지도 인터페이스와 정밀한 데이터 동기화를 제공합니다. 현재 알람, 항로추적 데이터는 현재 더미데이터입니다.
또한, 실시간 선박 위치 API의 제한으로 인해 OpenSky Network의 항공기 API를 대신 활용하여 선박의 실시간 위치 데이터를 보완하고 있습니다. 이를 통해 시스템의 데이터 가용성과 다양성을 확보하고, 지속적인 모니터링을 가능하게 하고 있습니다. 향후에는 보다 정확하고 신뢰할 수 있는 전용 해양 위치 데이터 API로의 전환을 계획하고 있습니다.

---

## 🚀 주요 기능

### 1. 실시간 라이브 모니터링 (Live Tracking)

- **실시간 위치 갱신**: 5분 주기 자동 데이터 동기화를 통해 선박의 최신 위경도 반영.
- **인터랙티브 맵**: Leaflet.js 기반의 부드러운 지도 조작 및 선박 마커 표시.
- **집중 모드 (Focus Mode)**: 특정 선박 선택 시 해당 선박 중심 자동 줌 및 타 선박 숨김 기능으로 관제 효율 극대화.

### 2. 항적 관리 및 애니메이션 (Vessel Path)

- **이력 가시화**: 선박의 과거 이동 경로를 지도상에 현대적인 점선(Polyline)으로 표시.
- **스마트 Waypoint**: 항적의 각 노드에 네온 효과를 적용하고 클릭 시 위경도 및 기록 시간 정보 제공.
- **줌 감응 애니메이션**: 지도의 줌 레벨에 따라 선박 이동 속도를 자동으로 계산하여 자연스러운 움직임 구현.

### 3. 알람 및 안전 관리 (Security & Alarm)

- **지능형 알람 감지**: 과속(Overspeed), 구역 침범(Enter Area), 닻 끌림(Anchor Drag) 등 실시간 상태 감지.
- **글로벌 알람 보드**: 시스템 전체 또는 개별 선박별 알람 히스토리 모달 제공.
- **시각적 경고**: 알람 발생 시 지도 위 알람 카드에 실시간 배지 및 펄스(Pulse) 애니메이션 적용.

### 4. 관리자 설정 (Management)

- **RBAC (권한 기반 제어)**: SYSTEM, ADMIN, OPERATOR 권한에 따른 메뉴 접근 제한.
- **선박 그룹핑**: 선박별 그룹(Group A, B 등) 관리를 통한 효율적인 분류.
- **접근 제어**: 특정 사용자별로 관제 가능한 선박 권한을 개별 할당 가능.

---

## 📂 프로젝트 구조 (Project Tree)

```text
D:.
│  Dockerfile
│  README.md
│
├─src (Java Source)
│  └─com.vms
│      ├─controller      # API 및 뷰 컨트롤러 (Alarm, Vessel, Login 등)
│      ├─mapper          # MyBatis Interface (DAO)
│      ├─model           # 데이터 전송 객체 (DTO - VesselDto, AlarmDto 등)
│      └─service         # 비즈니스 로직 Interface 및 Implementation
│
├─mappers (MyBatis XML)
│      AlarmMapper.xml, UserMapper.xml, VesselMapper.xml ...
│
├─WebContent
│  ├─static
│  │  ├─css              # 모던 UI/네온 블루 테마 (style.css)
│  │  ├─images           # 선박 아이콘 (cargo-ship.png)
│  │  └─js               # 핵심 맵 로직 (map-app.js)
│  │
│  └─WEB-INF
│      ├─spring          # Spring root/servlet context 설정
│      └─views           # JSP 페이지 (main.jsp, alarm.jsp 등)
│          ├─common      # 팝업 등 공통 모듈
│          ├─include     # 사이드바 레이아웃
│          └─settings    # 탭 별 설정 페이지 (계정, 메뉴, 그룹)
```
