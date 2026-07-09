# Home & Navigation Flow

## Deskripsi
Flow navigasi utama aplikasi mencakup dashboard home, riwayat transaksi, dan profil pengguna.

---

## 1. Main Navigation Structure

```mermaid
flowchart TD
    A[Main Page] --> B[Bottom Navigation Bar]
    
    B --> C[Tab 0: Beranda]
    B --> D[Tab 1: Riwayat]
    B --> E[Tab 2: Profile]
    
    C --> F[HomePage]
    D --> G[HistoryPage]
    E --> H[ProfilePage]
    
    subgraph "IndexedStack"
        F
        G
        H
    end
```

---

## 2. Home Page Flow

```mermaid
flowchart TD
    A[Home Page Init] --> B[Initialize BLoC]
    B --> C[Load Profile Data]
    C --> D[Load Talent Pool]
    D --> E[Load Feed Data]
    E --> F[Load Shopping Data]
    F --> G[Check Updates]
    G --> H[Render UI]
    
    H --> I{User Action}
    I -->|Pull to Refresh| J[Refresh All Data]
    J --> H
    
    I -->|Tap Invoice| K[Navigate to Invoice List]
    I -->|Tap Top Up| L[Show Top Up Bottom Sheet]
    I -->|Tap Withdrawal| M[Navigate to Withdrawal]
    I -->|Tap Shopping| N[Navigate to Shopping List]
    I -->|Tap Attendance| O[Navigate to Attendance]
    I -->|Tap Performance| P[Navigate to Performance]
    I -->|Tap Notification| Q[Navigate to Notifications]
    I -->|Tap Feed Card| R[Navigate to Feed Detail]
```

---

## 3. Home Page UI Components

```mermaid
flowchart TB
    A[HomePage] --> B[Top Container - Green Background]
    B --> C[Profile Row]
    B --> D[Notification Icon]
    B --> E[Saldo Card]
    
    A --> F[Body Content]
    F --> G[Talent Pool Widget]
    F --> H[Shopping Section]
    F --> I[Attendance Section]
    F --> J[Report Performance Section]
    F --> K[Feed Section]
    
    E --> L[Saldo Kompay Display]
    E --> M[Kompoin Display]
    E --> N[Action Buttons - TopUp/Withdraw/Invoice]
```

---

## 4. History Page Flow

```mermaid
flowchart TD
    A[History Page Init] --> B[Load Transaction Data]
    B --> C[Display History List]
    
    C --> D{Tab Selection}
    D -->|All| E[Show All Transactions]
    D -->|Invoice| F[Filter Invoice Only]
    D -->|Saldo| G[Filter Saldo Only]
    D -->|Penarikan| H[Filter Withdrawal Only]
    D -->|TopUp| I[Filter TopUp Only]
    
    C --> J{User Action}
    J -->|Pull to Refresh| K[Refresh Data]
    K --> C
    J -->|Scroll to Bottom| L{Has More Data?}
    L -->|Yes| M[Load More]
    M --> C
    L -->|No| N[Show End of List]
    J -->|Tap Item| O[Navigate to Detail]
```

---

## 5. History Transaction Types

```mermaid
flowchart LR
    A[Transaction History] --> B[TabState Enum]
    
    B --> C[All]
    B --> D[Invoice]
    B --> E[Saldo]
    B --> F[Penarikan]
    B --> G[TopUp]
    
    D --> H[Navigate to Invoice Summary]
    E --> I[Show Saldo Detail]
    F --> J[Show Withdrawal Detail]
    G --> K[Navigate to QRIS/Bank Payment]
```

---

## 6. Profile Page Flow

```mermaid
flowchart TD
    A[Profile Page Init] --> B[Load Profile Data]
    B --> C[Display Profile Info]
    
    C --> D{Menu Selection}
    D -->|Info Profil| E[Navigate to Profile Update]
    D -->|Ubah Password| F[Navigate to Change Password]
    D -->|Ubah PIN| G[Navigate to PIN Page]
    D -->|Keluar| H[Show Logout Confirmation]
    
    H --> I{User Response}
    I -->|Cancel| C
    I -->|Confirm| J[Clear Session Data]
    J --> K[Navigate to Login]
```

---

## 7. Profile Page Components

```mermaid
flowchart TB
    A[ProfilePage] --> B[Profile Row]
    B --> C[Avatar - Initials/Image]
    B --> D[Name]
    B --> E[Email]
    
    A --> F[Menu List]
    F --> G[Info Profil Tile]
    F --> H[Ubah Password Tile]
    F --> I[Ubah PIN Tile]
    F --> J[Keluar Button]
    
    G --> K[ProfileInfoUpdatePage]
    H --> L[ChangePasswordPage]
    I --> M[PinPage - Update Mode]
    J --> N[Logout Dialog]
```

---

## 8. Home BLoC State Flow

```mermaid
stateDiagram-v2
    [*] --> Initial: App Start
    
    Initial --> Loading: HomePageDidLoad
    
    Loading --> ProfileLoaded: Profile API Success
    Loading --> Error: Profile API Error
    
    ProfileLoaded --> TalentLoaded: Talent API Success
    TalentLoaded --> FeedLoaded: Feed API Success
    FeedLoaded --> Success: All Data Loaded
    
    Success --> Loading: Refresh Requested
    
    Error --> Loading: Retry
    
    note right of Loading
        Show shimmer placeholders
    end note
    
    note right of Success
        Display all widgets
    end note
```

---

## 9. Notification Flow

```mermaid
flowchart TD
    A[Home Page] --> B[Tap Notification Icon]
    B --> C[NotificationPage]
    C --> D[Load Notifications List]
    
    D --> E{Notification Type}
    E -->|Invoice| F[Navigate to Invoice Summary]
    E -->|Feed/News| G[Navigate to Feed Detail]
    E -->|General| H[Show Notification Detail]
    
    subgraph "Push Notification Handling"
        I[FCM Message Received] --> J{App State}
        J -->|Foreground| K[Show Local Notification]
        J -->|Background| L[System Notification]
        J -->|Terminated| M[Queue for App Open]
        
        K --> N[User Tap]
        L --> N
        M --> N
        N --> O[Handle Navigation]
    end
```

---

## 10. Top Up Saldo Bottom Sheet

```mermaid
flowchart TD
    A[Tap Top Up Button] --> B[Show Bottom Sheet]
    B --> C[Input Nominal]
    C --> D{Validate Amount}
    D -->|Below Min| E[Show Error]
    D -->|Above Max| F[Show Error]
    D -->|Valid| G[Enable Submit Button]
    E --> C
    F --> C
    G --> H[Select Payment Method]
    H --> I{Method Type}
    I -->|QRIS| J[Navigate to QRIS Page]
    I -->|Bank Transfer| K[Navigate to Bank Page]
```

---

## Components

### BLoC Files
- `home_page_bloc.dart` - Home page business logic
- `history_page_bloc.dart` - History page logic
- `profile_page_bloc.dart` - Profile page logic

### Views
- `main_page.dart` - Main container with bottom nav
- `home_page.dart` - Dashboard home
- `history_page.dart` - Transaction history
- `profile_page.dart` - User profile

### Widgets
- `bouncing_icon.dart` - Animated notification icon
- `talent_pool_widget.dart` - Talent pool display
- `list_section_talent.dart` - Talent list section
- `list_section_leader.dart` - Leader list section
- `card_feed_empty.dart` - Empty feed placeholder

---

## Data Flow

```mermaid
sequenceDiagram
    participant UI as HomePage
    participant BLoC as HomePageBloc
    participant UC as UseCases
    participant Repo as Repository
    participant API as Remote API
    
    UI->>BLoC: HomePageDidLoad Event
    BLoC->>UC: getProfile()
    UC->>Repo: fetchProfile()
    Repo->>API: GET /profile
    API-->>Repo: Profile Data
    Repo-->>UC: ProfileModel
    UC-->>BLoC: Success/Failure
    BLoC-->>UI: Emit State with ProfileData
```
