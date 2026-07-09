# Attendance Tracking Flow

## Deskripsi
Flow absensi talent mencakup daftar kehadiran, laporan ketidakhadiran, dan pengelolaan absensi gagal.

---

## 1. Attendance Page Overview

```mermaid
flowchart TD
    A[Attendance Page] --> B[Tab Controller]
    
    B --> C[Tab 1: Kehadiran]
    B --> D[Tab 2: Absensi Gagal]
    
    C --> E[Attendance List]
    D --> F[Failed Attendance List]
```

---

## 2. Main Attendance Flow

```mermaid
flowchart TD
    A[Navigate to Attendance] --> B[AttendancePages Init]
    B --> C[Initialize Tab Controller]
    C --> D[Load Initial Data]
    
    D --> E{Current Tab}
    E -->|Tab 0| F[Load Attendance Data]
    E -->|Tab 1| G[Load Failed Attendance Data]
    
    F --> H[Display Attendance List]
    G --> I[Display Failed Attendance List]
    
    H --> J{User Action}
    J -->|Search| K[Filter by Search Query]
    J -->|Filter| L[Apply Status Filter]
    J -->|Scroll| M{Has More?}
    M -->|Yes| N[Load More Data]
    M -->|No| O[End of List]
    J -->|Tap Item| P[Show Detail]
```

---

## 3. Attendance List View

```mermaid
flowchart TB
    A[AttendancePages] --> B[AppBar with Title]
    B --> C[Search Field]
    
    A --> D[TabBar]
    D --> E[Tab: Kehadiran]
    D --> F[Tab: Absensi Gagal]
    
    A --> G[TabBarView]
    G --> H[Attendance Tab Content]
    G --> I[Failed Tab Content]
    
    H --> J[Filter Chips]
    H --> K[ListView]
    K --> L[CardAttendance Items]
    
    I --> M[Failed Filter]
    I --> N[ListView]
    N --> O[FailAttendanceCard Items]
```

---

## 4. Search & Filter Flow

```mermaid
flowchart TD
    A[User Types Search] --> B[Debounce Input - 500ms]
    B --> C{Query Length}
    C -->|>= 3 chars| D[Trigger Search API]
    C -->|< 3 chars| E[Clear Search Results]
    
    D --> F[Update List with Results]
    E --> G[Show Full List]
    
    H[User Selects Filter] --> I[Get Filter Status]
    I --> J{Status Type}
    J -->|All| K[Reset Filter]
    J -->|Hadir| L[Filter Status: hadir]
    J -->|Tidak Hadir| M[Filter Status: tidak_hadir]
    J -->|Terlambat| N[Filter Status: terlambat]
    
    K --> O[Reload Data]
    L --> O
    M --> O
    N --> O
```

---

## 5. Attendance Card Component

```mermaid
flowchart LR
    A[CardAttendance] --> B[Talent Image]
    A --> C[Talent Name]
    A --> D[Date Info]
    A --> E[Status Badge]
    A --> F[Time In/Out]
    
    E --> G{Status Color}
    G -->|Hadir| H[Green Badge]
    G -->|Tidak Hadir| I[Red Badge]
    G -->|Terlambat| J[Orange Badge]
    G -->|Izin| K[Blue Badge]
```

---

## 6. Failed Attendance Flow

```mermaid
flowchart TD
    A[Failed Attendance Tab] --> B[Load Failed Data]
    B --> C[Display Failed List]
    
    C --> D{User Action}
    D -->|Scroll Bottom| E[Load More Failed]
    D -->|Pull Refresh| F[Reload Failed Data]
    D -->|Tap Card| G[Show Failed Detail]
    
    G --> H[Modal/Dialog with Details]
    H --> I[Reason for Failure]
    H --> J[Date & Time]
    H --> K[Talent Info]
```

---

## 7. Attendance BLoC State

```mermaid
stateDiagram-v2
    [*] --> Initial
    
    Initial --> LoadingAttendance: Load Attendance
    Initial --> LoadingFailed: Load Failed
    
    LoadingAttendance --> AttendanceLoaded: Success
    LoadingAttendance --> AttendanceError: Error
    
    LoadingFailed --> FailedLoaded: Success
    LoadingFailed --> FailedError: Error
    
    AttendanceLoaded --> LoadingMore: Scroll Bottom
    LoadingMore --> AttendanceLoaded: More Loaded
    LoadingMore --> NoMoreData: End of List
    
    AttendanceLoaded --> Searching: Search Query
    Searching --> SearchResults: Results Found
    Searching --> NoResults: No Match
    
    AttendanceLoaded --> Filtering: Apply Filter
    Filtering --> Filtered: Filter Applied
```

---

## 8. Tab Selection Handler

```mermaid
flowchart TD
    A[Tab Changed] --> B[Get Selected Index]
    B --> C{Tab Index}
    
    C -->|0| D[Switch to Attendance]
    C -->|1| E[Switch to Failed]
    
    D --> F{Data Loaded?}
    F -->|Yes| G[Show Cached Data]
    F -->|No| H[Load Attendance Data]
    
    E --> I{Data Loaded?}
    I -->|Yes| J[Show Cached Data]
    I -->|No| K[Load Failed Data]
```

---

## 9. Pagination Flow

```mermaid
flowchart TD
    A[User Scrolls] --> B[ScrollController Listener]
    B --> C{Near Bottom?}
    
    C -->|No| D[Continue Scroll]
    C -->|Yes| E{Is Loading More?}
    
    E -->|Yes| F[Skip - Already Loading]
    E -->|No| G{Has More Data?}
    
    G -->|No| H[Show End Message]
    G -->|Yes| I[Set isLoadingMore = true]
    I --> J[Call Load More API]
    J --> K[Append Results]
    K --> L[Set isLoadingMore = false]
```

---

## 10. Absence Report Flow

```mermaid
flowchart TD
    A[Attendance Tab] --> B[Select Status: Tidak Hadir]
    B --> C[Load Absence Data]
    C --> D[Display Absence List]
    
    D --> E{Absence Type}
    E -->|Sakit| F[Show Medical Icon]
    E -->|Izin| G[Show Izin Icon]
    E -->|Alpha| H[Show Alpha Icon]
    
    D --> I[Tap for Details]
    I --> J[Show Absence Reason]
    J --> K[Show Documentation if any]
```

---

## Components

### BLoC Files
- `attendance_bloc.dart` - Attendance data logic
- `attendance_event.dart` - Events
- `attendance_state.dart` - States

### Views
- `attendance_pages.dart` - Main attendance page

### Widgets
- `card_attendance.dart` - Attendance item card
- `card_empty_list.dart` - Empty state
- `fail_attendance_card.dart` - Failed attendance card
- `shimmer_place_holder.dart` - Loading placeholder
- `shimmer_place_holder_fail.dart` - Failed list placeholder

---

## Data Models

```dart
class AttendanceModel {
  final int id;
  final String talentName;
  final String status; // hadir, tidak_hadir, terlambat, izin
  final DateTime date;
  final String? timeIn;
  final String? timeOut;
  final String? note;
}

class FailedAttendanceModel {
  final int id;
  final String talentName;
  final String reason;
  final DateTime date;
  final String failureType;
}
```

---

## Filter Status Mapping

| Display Name | API Status Value |
|--------------|------------------|
| Semua | (no filter) |
| Hadir | hadir |
| Tidak Hadir | tidak_hadir |
| Terlambat | terlambat |
| Izin | izin |
