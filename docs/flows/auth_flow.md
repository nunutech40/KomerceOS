# Authentication Flow

## Deskripsi
Flow autentikasi mencakup proses login, lupa password, dan manajemen sesi pengguna.

---

## 1. Splash & Session Check Flow

```mermaid
flowchart TD
    A[App Launch] --> B[Splash Screen]
    B --> C{Firebase Remote Config}
    C --> D[Get Version Info]
    D --> E{Version Check}
    E -->|Major Update Required| F[Force Update Page]
    E -->|No Update| G{Is Logged In?}
    G -->|Yes| H[Main Page]
    G -->|No| I[Login Page]
    F --> J[App Store/Play Store]
```

---

## 2. Login Flow

```mermaid
flowchart TD
    A[Login Page] --> B[Input Username & Password]
    B --> C{Validate Input}
    C -->|Empty Field| D[Show Error Message]
    C -->|Valid| E[Check FCM Token]
    E --> F{Token Exists?}
    F -->|No| G[Get FCM Token]
    F -->|Yes| H[Call Login API]
    G --> H
    H --> I{Login Result}
    I -->|Success| J[Save Token to SharedPref]
    J --> K[Navigate to Main Page]
    I -->|Failure| L[Show Error]
    L --> A
    D --> A
```

---

## 3. Login BLoC State Flow

```mermaid
stateDiagram-v2
    [*] --> Empty: Initial State
    
    Empty --> Empty: Username/Password Changed
    Empty --> Loading: Login Button Pressed
    
    Loading --> Success: Login API Success
    Loading --> Failure: Login API Error
    Loading --> Empty: Validation Error
    
    Success --> [*]: Navigate to Main
    
    Failure --> Empty: Reset Status
    
    note right of Loading
        Menampilkan loading indicator
    end note
    
    note right of Failure
        Menampilkan error message
    end note
```

---

## 4. Forgot Password Flow

```mermaid
flowchart TD
    A[Login Page] --> B[Click Forgot Password]
    B --> C[Forgot Password Page]
    C --> D[Input Email]
    D --> E{Validate Email}
    E -->|Invalid| F[Show Error]
    F --> D
    E -->|Valid| G[Send Reset Request]
    G --> H{API Response}
    H -->|Success| I[Show Success Message]
    I --> J[Navigate to Login]
    H -->|Failure| K[Show Error Message]
    K --> D
```

---

## 5. Change Password Flow

```mermaid
flowchart TD
    A[Profile Page] --> B[Click Change Password]
    B --> C[Change Password Page]
    C --> D[Input Current Password]
    D --> E[Input New Password]
    E --> F[Confirm New Password]
    F --> G{Validate Passwords}
    G -->|Mismatch| H[Show Error]
    H --> F
    G -->|Invalid Format| I[Show Format Error]
    I --> E
    G -->|Valid| J[Submit Change Request]
    J --> K{API Response}
    K -->|Success| L[Show Success]
    L --> M[Navigate Back]
    K -->|Failure| N[Show Error]
    N --> C
```

---

## 6. Password Validation Rules

```mermaid
flowchart LR
    A[Password Input] --> B{Contains Space?}
    B -->|Yes| C[❌ Error: Tidak boleh spasi]
    B -->|No| D{Length >= 8?}
    D -->|No| E[❌ Error: Minimal 8 karakter]
    D -->|Yes| F[✅ Valid]
```

---

## 7. Session Management

```mermaid
flowchart TD
    A[App Launch] --> B[Check SharedPreferences]
    B --> C{Token Exists?}
    C -->|Yes| D{Token Valid?}
    D -->|Yes| E[Auto Login]
    D -->|No/Expired| F[Clear Session]
    C -->|No| G[Show Login Page]
    F --> G
    E --> H[Main Page]
    
    subgraph "On Logout"
        I[Profile Page] --> J[Logout Button]
        J --> K[Show Confirmation]
        K -->|Cancel| I
        K -->|Confirm| L[Clear All Data]
        L --> M[Navigate to Login]
    end
```

---

## 8. Firebase Initialization Flow

```mermaid
flowchart TD
    A[Splash Screen Init] --> B{Firebase Apps Empty?}
    B -->|Yes| C[Initialize Firebase]
    B -->|No| D[Skip Initialization]
    C --> D
    D --> E[Get FCM Token]
    E --> F[Save Token to SharedPref]
    F --> G[Setup Message Handlers]
    G --> H[Request Notification Permission]
    H --> I[Initialize Local Notifications]
    I --> J[Continue to Session Check]
```

---

## Components

### BLoC Files
- `login_bloc.dart` - Handle login logic
- `login_event.dart` - Login events
- `login_state.dart` - Login states
- `forgot_password_bloc.dart` - Handle forgot password
- `change_password_bloc.dart` - Handle password change

### Views
- `splash_screen.dart` - Initial splash screen
- `login_page.dart` - Login form
- `forgot_password_page.dart` - Password reset form
- `change_password_page.dart` - Change password form

### Use Cases
- `DoLoginUseCase` - Execute login API call

---

## Error Handling

| Error Type | Message | Action |
|------------|---------|--------|
| Empty Username | "Username tidak boleh kosong" | Focus username field |
| Empty Password | "Password tidak boleh kosong" | Focus password field |
| Password with Space | "Password tidak boleh menggunakan spasi" | Clear password |
| Password < 8 chars | "Password minimal 8 karakter" | Keep input |
| Invalid Credentials | "Username atau password salah" | Clear password |
| Network Error | Error message dari API | Show retry option |
