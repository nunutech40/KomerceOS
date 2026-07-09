# PIN Management Flow

## Deskripsi
Flow PIN management mencakup pengaturan PIN baru, verifikasi PIN untuk transaksi, update PIN, dan verifikasi email OTP.

---

## 1. PIN Management Overview

```mermaid
flowchart TD
    A[PIN Management] --> B{PIN Type}
    
    B -->|setPin| C[Set New PIN]
    B -->|verifyPin| D[Verify PIN for Transaction]
    B -->|updatePin| E[Update Existing PIN]
    B -->|resetPin| F[Reset PIN via OTP]
```

---

## 2. Set New PIN Flow

```mermaid
flowchart TD
    A[First Time User] --> B{Has PIN?}
    B -->|No| C[PinPage - SetPin Mode]
    
    C --> D[Enter 6-digit PIN]
    D --> E{Complete 6 digits?}
    E -->|No| F[Continue Input]
    E -->|Yes| G[Navigate to Confirm PIN]
    
    G --> H[PinPage - ConfirmPin Mode]
    H --> I[Re-enter PIN]
    I --> J{PIN Match?}
    J -->|No| K[Show Error - Try Again]
    J -->|Yes| L[Save PIN to Server]
    
    L --> M{API Success?}
    M -->|Yes| N[Show Success]
    M -->|No| O[Show Error]
    
    N --> P[Navigate Back]
```

---

## 3. PIN Entry UI Components

```mermaid
flowchart TB
    A[PinPage] --> B[Header]
    B --> C[Title based on PinType]
    B --> D[Subtitle Instructions]
    
    A --> E[PIN Input Display]
    E --> F[6 Digit Circles]
    F --> G[Filled/Empty based on input]
    
    A --> H[Numpad]
    H --> I[1-9 Keys]
    H --> J[0 Key]
    H --> K[Backspace Key]
    
    A --> L[Forgot PIN Link]
    L --> M[Navigate to Email Verification]
```

---

## 4. Verify PIN Flow

```mermaid
flowchart TD
    A[Transaction Requested] --> B[PinPage - VerifyPin Mode]
    B --> C[Enter 6-digit PIN]
    
    C --> D[Call Verify PIN API]
    D --> E{PIN Valid?}
    
    E -->|Yes| F[Return Success]
    F --> G[Continue Transaction]
    
    E -->|No| H[Show Error]
    H --> I{Attempts < 3?}
    I -->|Yes| J[Try Again]
    J --> C
    I -->|No| K[Lock Account]
    K --> L[Navigate to Reset PIN]
```

---

## 5. Update PIN Flow

```mermaid
flowchart TD
    A[Profile > Update PIN] --> B[PinPage - UpdatePin Mode]
    B --> C[Enter Current PIN]
    
    C --> D[Verify Current PIN]
    D --> E{PIN Valid?}
    E -->|No| F[Show Error]
    E -->|Yes| G[Enter New PIN]
    
    G --> H[Navigate to Set New PIN]
    H --> I[Enter New 6-digit PIN]
    I --> J[Confirm New PIN]
    
    J --> K{Match?}
    K -->|No| L[Show Error]
    K -->|Yes| M[Update PIN API]
    
    M --> N{Success?}
    N -->|Yes| O[Show Success]
    N -->|No| P[Show Error]
    
    O --> Q[Navigate Back]
```

---

## 6. Email Verification Flow

```mermaid
flowchart TD
    A[Forgot PIN] --> B[VerificationEmailPage]
    B --> C[Send OTP to Email]
    
    C --> D[Display OTP Input]
    D --> E[Start Countdown Timer]
    
    E --> F{Timer Running?}
    F -->|Yes| G[Disable Resend]
    F -->|No| H[Enable Resend Button]
    
    D --> I[Enter 6-digit OTP]
    I --> J[Verify OTP API]
    
    J --> K{OTP Valid?}
    K -->|Yes| L[Navigate to Set New PIN]
    K -->|No| M[Show Error]
    
    H --> N[Tap Resend]
    N --> C
```

---

## 7. PIN BLoC State Flow

```mermaid
stateDiagram-v2
    [*] --> Initial
    
    Initial --> InputtingPin: Start
    
    InputtingPin --> PinComplete: 6 digits entered
    PinComplete --> VerifyingPin: For verification
    PinComplete --> ConfirmingPin: For new PIN
    
    VerifyingPin --> Success: PIN Valid
    VerifyingPin --> Error: PIN Invalid
    
    ConfirmingPin --> SettingPin: PIN Match
    ConfirmingPin --> Error: PIN Mismatch
    
    SettingPin --> Success: API Success
    SettingPin --> Error: API Error
    
    Error --> InputtingPin: Retry
    Success --> [*]
```

---

## 8. PIN Type Enum

```mermaid
flowchart LR
    A[PinPageType] --> B[setPin]
    A --> C[confirmPin]
    A --> D[verifyPin]
    A --> E[updatePin]
    A --> F[resetPin]
    
    B --> G[New user setting PIN]
    C --> H[Confirm new PIN]
    D --> I[Verify for transaction]
    E --> J[Change existing PIN]
    F --> K[Reset via OTP]
```

---

## 9. OTP Countdown Timer

```mermaid
flowchart TD
    A[OTP Sent] --> B[Start Timer - 60s]
    B --> C{Time > 0?}
    
    C -->|Yes| D[Display Countdown]
    D --> E[Decrement 1s]
    E --> C
    
    C -->|No| F[Timer Expired]
    F --> G[Enable Resend Button]
    
    G --> H{User Tap Resend?}
    H -->|Yes| I[Call Resend OTP API]
    I --> A
    H -->|No| J[Wait for user]
```

---

## 10. PIN Validation Rules

```mermaid
flowchart TD
    A[PIN Input] --> B{Length = 6?}
    B -->|No| C[Continue Input]
    B -->|Yes| D{All Digits?}
    
    D -->|No| E[Error: Numbers Only]
    D -->|Yes| F{Sequential Check}
    
    F --> G{Is Sequential? - 123456}
    G -->|Yes| H[Warning: Weak PIN]
    G -->|No| I{Is Repeated? - 111111}
    
    I -->|Yes| J[Warning: Weak PIN]
    I -->|No| K[Valid PIN]
    
    H --> L[Allow but warn]
    J --> L
    K --> M[Accept PIN]
```

---

## 11. Transaction PIN Verification

```mermaid
flowchart TD
    A[User Initiates Transaction] --> B{PIN Required?}
    B -->|No| C[Process Transaction]
    B -->|Yes| D[Navigate to PIN Page]
    
    D --> E[PinPage - VerifyPin]
    E --> F[Enter PIN]
    F --> G[Verify PIN API]
    
    G --> H{Valid?}
    H -->|Yes| I[Return with doJobFor]
    I --> J{Job Type}
    J -->|withdrawal| K[Process Withdrawal]
    J -->|payment| L[Process Payment]
    
    H -->|No| M[Handle Error]
    M --> N{Max Retries?}
    N -->|No| E
    N -->|Yes| O[Lock & Exit]
```

---

## Components

### BLoC Files
- `pin_bloc.dart` - PIN management logic
- `pin_event.dart` - Events
- `pin_state.dart` - States

### Views
- `pin_page.dart` - PIN entry screen
- `verification_email_page.dart` - OTP verification
- `pop_up_page.dart` - PIN popups/dialogs

### Widgets
- Custom PIN input display
- Numpad widget
- Timer display

---

## Data Models

```dart
class CheckPinModel {
  final bool hasPin;
}

class VerifyPinModel {
  final bool isValid;
  final String? message;
  final int remainingAttempts;
}
```

---

## API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/pin/check` | GET | Check if user has PIN |
| `/pin/set` | POST | Set new PIN |
| `/pin/verify` | POST | Verify PIN |
| `/pin/update` | PUT | Update PIN |
| `/pin/reset` | POST | Reset PIN request |
| `/otp/send` | POST | Send OTP to email |
| `/otp/verify` | POST | Verify OTP code |

---

## Security Considerations

| Rule | Implementation |
|------|----------------|
| Max attempts | 3 attempts before lock |
| Lock duration | 30 minutes or until OTP reset |
| PIN storage | Hashed on server only |
| OTP expiry | 5 minutes |
| Resend cooldown | 60 seconds |
