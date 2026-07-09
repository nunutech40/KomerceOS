# Talent Rating Flow

## Deskripsi
Flow rating talent mencakup notifikasi rating, form penilaian talent, dan evaluasi Kompoint.

---

## 1. Rate Talent Overview

```mermaid
flowchart TD
    A[Invoice Paid] --> B{Rating Required?}
    B -->|Yes| C[Show Rate Talent Button]
    B -->|No| D[Invoice Complete]
    
    C --> E[Tap Rate Talent]
    E --> F[RateTalentNotifPage]
    F --> G[Select Talents]
    G --> H[RateTalentCheckPage]
    H --> I[Submit Ratings]
    I --> J[EvaluationKompointPage]
    J --> K[Calculate & Submit]
    K --> L[Invoice Complete]
```

---

## 2. Rate Talent Notification Flow

```mermaid
flowchart TD
    A[RateTalentNotifPage Init] --> B[Receive Invoice Data]
    B --> C[Load Talent List from Invoice]
    
    C --> D{API Result}
    D -->|Success| E[Display Talent List]
    D -->|Error| F[Show Error]
    
    E --> G[Select Talents to Rate]
    G --> H{All Selected?}
    H -->|Yes| I[Enable Continue Button]
    H -->|No| J[Disable Continue Button]
    
    I --> K[Navigate to RateTalentCheckPage]
```

---

## 3. Talent Rating Form Flow

```mermaid
flowchart TD
    A[RateTalentCheckPage Init] --> B[Load Selected Talents]
    B --> C[Display Rating Form]
    
    C --> D[Rating Header - Select All]
    C --> E[Talent List with Ratings]
    C --> F[Leader List with Ratings]
    
    D --> G{Select All?}
    G -->|Yes| H[Apply Rating to All]
    G -->|No| I[Individual Rating Mode]
    
    E --> J[Rate Each Talent]
    F --> K[Rate Each Leader]
    
    J --> L[Enter Evaluation Text]
    K --> L
    
    L --> M{All Rated?}
    M -->|Yes| N[Enable Submit]
    M -->|No| O[Disable Submit]
    
    N --> P[Submit Ratings]
```

---

## 4. Rating Star Component

```mermaid
flowchart LR
    A[Rating Widget] --> B[Star 1]
    A --> C[Star 2]
    A --> D[Star 3]
    A --> E[Star 4]
    A --> F[Star 5]
    
    B --> G{Selected?}
    C --> G
    D --> G
    E --> G
    F --> G
    
    G -->|Yes| H[Filled Star]
    G -->|No| I[Empty Star]
```

---

## 5. Talent/Leader Rating State

```mermaid
stateDiagram-v2
    [*] --> Unrated
    
    Unrated --> Rating: Star Tapped
    Rating --> Rated: Rating Selected
    
    Rated --> EditingEvaluation: Enter Evaluation
    EditingEvaluation --> Complete: Valid Evaluation
    
    Complete --> Ready: All Fields Valid
    
    note right of Complete
        Checkbox checked
        Rating >= 1
        Evaluation text filled
    end note
```

---

## 6. Check All Checkbox Flow

```mermaid
flowchart TD
    A[Tap Check All] --> B{Current State}
    B -->|Unchecked| C[Check All Items]
    B -->|Checked| D[Uncheck All Items]
    
    C --> E[Set All Talents Checked]
    C --> F[Set All Leaders Checked]
    
    D --> G[Set All Talents Unchecked]
    D --> H[Set All Leaders Unchecked]
    
    E --> I[Update State]
    F --> I
    G --> I
    H --> I
    
    I --> J[Recalculate Kompoint]
```

---

## 7. Rating Calculation Flow

```mermaid
flowchart TD
    A[Rating Submitted] --> B[Get Selected Talents]
    B --> C[Get Selected Leaders]
    
    C --> D[Calculate Talent Ratings]
    D --> E[Calculate Leader Ratings]
    
    E --> F[Compute Total Kompoint]
    F --> G{Base Points}
    G --> H[Add Bonus for 5 Stars]
    G --> I[Add Bonus for Leaders]
    
    H --> J[Final Kompoint Amount]
    I --> J
    
    J --> K[Navigate to Evaluation Page]
```

---

## 8. Evaluation Kompoint Page

```mermaid
flowchart TD
    A[EvaluationKompointPage] --> B[Display Summary]
    B --> C[Invoice Info]
    B --> D[Rated Talents List]
    B --> E[Rated Leaders List]
    B --> F[Total Kompoint Earned]
    
    F --> G[Submit Evaluation]
    G --> H[Call Rating API]
    
    H --> I{API Result}
    I -->|Success| J[Show Success]
    I -->|Error| K[Show Error]
    
    J --> L[Navigate to Invoice/Home]
    K --> M[Retry Option]
```

---

## 9. Rating BLoC State Flow

```mermaid
stateDiagram-v2
    [*] --> Initial
    
    Initial --> Loading: LoadTalentList
    
    Loading --> TalentsLoaded: Success
    Loading --> Error: API Error
    
    TalentsLoaded --> Selecting: User Selects
    Selecting --> Rating: Selection Done
    
    Rating --> Validating: Submit Pressed
    Validating --> Submitting: All Valid
    Validating --> Rating: Validation Error
    
    Submitting --> Success: API Success
    Submitting --> Error: API Error
    
    Success --> [*]
```

---

## 10. Rating Item Row Component

```mermaid
flowchart TB
    A[ItemRowSetSetting] --> B[Checkbox]
    A --> C[Talent Avatar]
    A --> D[Talent Name]
    A --> E[Star Rating]
    A --> F[Evaluation TextField]
    
    B --> G{Checked?}
    G -->|Yes| H[Include in Rating]
    G -->|No| I[Exclude from Rating]
    
    E --> J[1-5 Star Selection]
    F --> K[Text Input]
    K --> L{Valid Length?}
    L -->|Yes| M[Enable Submit]
    L -->|No| N[Show Error]
```

---

## 11. WebView Payment (Xendit)

```mermaid
flowchart TD
    A[Payment Required] --> B{Payment Method}
    B -->|Xendit| C[WebViewPage]
    
    C --> D[Load Xendit URL]
    D --> E[Display Payment Form]
    E --> F[User Completes Payment]
    
    F --> G{Callback URL}
    G -->|Success URL| H[Navigate to Success]
    G -->|Failure URL| I[Navigate to Failure]
    G -->|Still in WebView| J[Continue Payment]
```

---

## Components

### BLoC Files
- `rate_talent_bloc.dart` - Rating logic
- `rate_talent_event.dart` - Events
- `rate_talent_state.dart` - States

### Views
- `rate_talent_notif_page.dart` - Rating notification/selection
- `rate_talent_check_page.dart` - Rating form
- `evaluation_kompoint_page.dart` - Kompoint summary
- `web_view_page.dart` - Xendit payment

### Widgets
- `item_row_set_setting.dart` - Rating row item
- `rating_info_widget.dart` - Rating information display

---

## Data Models

```dart
class TalentsDataModel {
  final int id;
  final String name;
  final String? avatar;
  bool isChecked;
  int rating;
  String evaluation;
}

class TalentLeaderModel {
  final int id;
  final String name;
  final String? avatar;
  bool isChecked;
  int rating;
  String evaluation;
}
```

---

## Kompoint Calculation

| Condition | Points |
|-----------|--------|
| Base rating per talent | 10 points |
| 5-star rating bonus | +5 points |
| Leader rating bonus | +15 points |
| All talents rated | +20 points bonus |

---

## API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/invoice/{id}/talents` | GET | Get talents to rate |
| `/rating/submit` | POST | Submit talent ratings |
| `/rating/kompoint` | POST | Submit kompoint evaluation |
