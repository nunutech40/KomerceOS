# Unhire Talent Flow

## Deskripsi
Flow unhire talent mencakup pemilihan talent yang akan di-unhire, input alasan, dan konfirmasi penyelesaian.

---

## 1. Unhire Overview Flow

```mermaid
flowchart TD
    A[Home Page / Talent Pool] --> B[Navigate to Unhire]
    B --> C[UnhirePage]
    C --> D[Select Talents to Unhire]
    D --> E[Navigate to Reason Page]
    E --> F[ReasonUnhirePage]
    F --> G[Submit Unhire Request]
    G --> H[DialogUnhireFinish]
    H --> I[Return to Home]
```

---

## 2. Unhire Page Flow

```mermaid
flowchart TD
    A[UnhirePage Init] --> B[Initialize BLoC]
    B --> C[Load Active Talents]
    
    C --> D{API Result}
    D -->|Success| E[Display Talent List]
    D -->|Error| F[Show Error]
    D -->|Empty| G[Show No Talent Message]
    
    E --> H{User Action}
    H -->|Toggle Selection| I[Update Selected State]
    H -->|Select All| J[Check All Talents]
    H -->|Deselect All| K[Uncheck All Talents]
    
    I --> L{Any Selected?}
    L -->|Yes| M[Enable Continue Button]
    L -->|No| N[Disable Continue Button]
    
    M --> O[Tap Continue]
    O --> P[Navigate to Reason Page]
```

---

## 3. Talent Selection UI

```mermaid
flowchart TB
    A[UnhirePage] --> B[Header]
    B --> C[Title: Unhire Talent]
    B --> D[Selected Count Badge]
    
    A --> E[Select All Toggle]
    E --> F[Checkbox - Select All]
    
    A --> G[Talent List]
    G --> H[Talent Card 1]
    G --> I[Talent Card 2]
    G --> J[Talent Card N...]
    
    H --> K[Checkbox]
    H --> L[Avatar]
    H --> M[Name]
    H --> N[Position]
    
    A --> O[Footer]
    O --> P[Continue Button]
```

---

## 4. Reason Unhire Flow

```mermaid
flowchart TD
    A[ReasonUnhirePage] --> B[Receive Selected Talents]
    B --> C[Display Confirmation]
    
    C --> D[Show Selected Count]
    C --> E[Reason Selection]
    
    E --> F{Reason Options}
    F --> G[Performa Kurang]
    F --> H[Kontrak Berakhir]
    F --> I[Pelanggaran]
    F --> J[Pengunduran Diri]
    F --> K[Lainnya]
    
    K --> L[Custom Reason Input]
    
    G --> M{Reason Selected?}
    H --> M
    I --> M
    J --> M
    L --> M
    
    M -->|Yes| N[Enable Submit]
    M -->|No| O[Disable Submit]
    
    N --> P[Submit Unhire]
```

---

## 5. Unhire Reason Options

```mermaid
flowchart LR
    A[Unhire Reasons] --> B[Predefined Reasons]
    A --> C[Custom Reason]
    
    B --> D[Performa Kurang Memuaskan]
    B --> E[Kontrak Berakhir]
    B --> F[Pelanggaran Aturan]
    B --> G[Pengunduran Diri Talent]
    B --> H[Tidak Sesuai Kebutuhan]
    
    C --> I[Lainnya - Free Text]
```

---

## 6. Submit Unhire Flow

```mermaid
flowchart TD
    A[Submit Unhire] --> B[Validate Selection]
    B --> C{Valid?}
    C -->|No| D[Show Error]
    C -->|Yes| E[Call Unhire API]
    
    E --> F{API Result}
    F -->|Success| G[DialogUnhireFinish]
    F -->|Error| H[Show Error Message]
    
    G --> I[Show Success Animation]
    I --> J[Display Summary]
    J --> K[OK Button]
    K --> L[Navigate to Home]
```

---

## 7. Unhire BLoC State Flow

```mermaid
stateDiagram-v2
    [*] --> Initial
    
    Initial --> Loading: LoadTalentList
    
    Loading --> TalentsLoaded: Success
    Loading --> Error: API Error
    Loading --> Empty: No Talents
    
    TalentsLoaded --> Selecting: User Selects
    Selecting --> ReadyToSubmit: Selection Valid
    
    ReadyToSubmit --> ReasonInput: Continue Pressed
    ReasonInput --> Submitting: Submit Pressed
    
    Submitting --> Success: API Success
    Submitting --> Error: API Error
    
    Success --> [*]: Complete
```

---

## 8. Talent Selection State

```mermaid
stateDiagram-v2
    [*] --> Unselected
    
    Unselected --> Selected: Tap Card/Checkbox
    Selected --> Unselected: Tap Again
    
    Unselected --> Selected: Select All
    Selected --> Unselected: Deselect All
    
    note right of Selected
        Talent included in unhire list
    end note
```

---

## 9. Dialog Unhire Finish

```mermaid
flowchart TD
    A[DialogUnhireFinish] --> B[Success Icon/Animation]
    B --> C[Title: Unhire Berhasil]
    C --> D[Summary Message]
    D --> E[Unhired Count: X Talent]
    
    E --> F[OK Button]
    F --> G[Pop to Home]
```

---

## 10. Multi-Step Progress

```mermaid
flowchart LR
    A[Step 1: Select] --> B[Step 2: Reason]
    B --> C[Step 3: Confirm]
    C --> D[Step 4: Complete]
    
    A --> E[UnhirePage]
    B --> F[ReasonUnhirePage]
    C --> G[Confirmation Dialog]
    D --> H[DialogUnhireFinish]
```

---

## Components

### BLoC Files
- `talent_list_bloc.dart` - Talent list for unhire
- `talent_list_selected_bloc.dart` - Selected talents management
- Events and States files

### Views
- `unhire_page.dart` - Talent selection
- `reason_unhire_page.dart` - Reason input
- `dialog_unhire_finish.dart` - Success dialog

### Widgets
- Talent selection cards
- Reason radio buttons
- Progress indicators

---

## Data Flow

```mermaid
sequenceDiagram
    participant UI as UnhirePage
    participant BLoC as TalentListBloc
    participant API as Remote API
    
    UI->>BLoC: LoadTalentList Event
    BLoC->>API: GET /talents/active
    API-->>BLoC: Talent List
    BLoC-->>UI: Emit State with Talents
    
    UI->>UI: User Selects Talents
    UI->>BLoC: UpdateSelection Event
    
    UI->>BLoC: SubmitUnhire Event
    BLoC->>API: POST /talents/unhire
    API-->>BLoC: Success/Error
    BLoC-->>UI: Emit Result State
```

---

## API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/talents/active` | GET | Get active talents list |
| `/talents/unhire` | POST | Submit unhire request |

---

## Request Payload

```json
{
  "talent_ids": [1, 2, 3],
  "reason": "Performa Kurang Memuaskan",
  "custom_reason": null,
  "unhire_date": "2026-01-20"
}
```

---

## Error Handling

| Error | Message | Action |
|-------|---------|--------|
| No selection | "Pilih minimal 1 talent" | Focus on list |
| No reason | "Pilih alasan unhire" | Focus on reason |
| API Error | Error message | Show retry |
| Network Error | "Koneksi bermasalah" | Show retry |
