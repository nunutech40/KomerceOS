# Kompay Wallet Flow

## Deskripsi
Flow wallet Kompay mencakup top up saldo, pembayaran QRIS, transfer bank, dan penarikan saldo.

---

## 1. Kompay Overview

```mermaid
flowchart TB
    A[Kompay Wallet] --> B[Saldo Kompay]
    A --> C[Kompoin Points]
    
    B --> D[Top Up]
    B --> E[Withdrawal]
    B --> F[Pay Invoice]
    
    C --> G[Earned from Rating]
    C --> H[Can be Withdrawn]
```

---

## 2. Top Up Flow

```mermaid
flowchart TD
    A[Home Page] --> B[Tap Top Up Icon]
    B --> C[TopUpPages]
    C --> D[Input Nominal Amount]
    
    D --> E{Validate Amount}
    E -->|Below Minimum| F[Show Min Error]
    E -->|Above Maximum| G[Show Max Error]
    E -->|Valid| H[Format Currency Display]
    
    F --> D
    G --> D
    H --> I[Select Payment Method]
    
    I --> J{Method Type}
    J -->|QRIS| K[QRISPaymentPages]
    J -->|Bank Transfer| L[BankPaymentPages]
    
    K --> M[Display QR Code]
    L --> N[Display VA Number]
```

---

## 3. QRIS Payment Flow

```mermaid
flowchart TD
    A[QRIS Payment Page] --> B[Create Top Up Transaction]
    B --> C[Get QRIS Code from API]
    C --> D[Display QR Code]
    
    D --> E[User Scans QR]
    E --> F[Start Countdown Timer]
    
    F --> G{Payment Status Check}
    G -->|Polling| H[Check Status API]
    H --> I{Status}
    I -->|Pending| G
    I -->|Success| J[Success Page]
    I -->|Expired| K[Show Expired Message]
    I -->|Failed| L[Show Error]
    
    K --> M[Create New Transaction]
    M --> B
```

---

## 4. Bank Transfer Flow

```mermaid
flowchart TD
    A[Bank Payment Page] --> B[Create Top Up Transaction]
    B --> C[Get VA Number]
    C --> D[Display Bank Info]
    
    D --> E[Copy VA Number]
    D --> F[Show Transfer Instructions]
    
    F --> G[Start Status Polling]
    G --> H{Check Status}
    H -->|Pending| I[Show Waiting Message]
    I --> G
    H -->|Success| J[Success Page]
    H -->|Expired| K[Show Expired]
    
    D --> L[User Completes Transfer]
    L --> G
```

---

## 5. Saldo Withdrawal Flow

```mermaid
flowchart TD
    A[Home Page] --> B[Tap Withdrawal Icon]
    B --> C[Check Saldo Available]
    C --> D{Has Saldo?}
    D -->|No| E[Show No Saldo Message]
    D -->|Yes| F[SaldoWithdrawalPage]
    
    F --> G[Input Withdrawal Amount]
    G --> H{Validate Amount}
    H -->|Invalid| I[Show Error]
    I --> G
    H -->|Valid| J[Select Bank Account]
    
    J --> K{Bank Account Saved?}
    K -->|No| L[Add Bank Account]
    K -->|Yes| M[Confirm Withdrawal Details]
    
    L --> M
    M --> N[Navigate to PIN Verification]
```

---

## 6. Withdrawal PIN Verification

```mermaid
flowchart TD
    A[Confirm Withdrawal] --> B[PinPage - Verify Mode]
    B --> C[Enter 6-digit PIN]
    C --> D[Verify PIN API]
    
    D --> E{PIN Valid?}
    E -->|No| F[Show Error]
    F --> G{Attempts < 3?}
    G -->|Yes| B
    G -->|No| H[Lock & Logout]
    
    E -->|Yes| I[Process Withdrawal API]
    I --> J{Success?}
    J -->|Yes| K[SuccessWithdrawalPage]
    J -->|No| L[Show Error Message]
```

---

## 7. Top Up BLoC Flow

```mermaid
stateDiagram-v2
    [*] --> Initial
    
    Initial --> Loading: CreateTopUpEvent
    
    Loading --> TopUpCreated: Transaction Created
    TopUpCreated --> GeneratingQR: For QRIS
    TopUpCreated --> GeneratingVA: For Bank
    
    GeneratingQR --> QRDisplayed: QR Ready
    GeneratingVA --> VADisplayed: VA Ready
    
    QRDisplayed --> CheckingStatus: Polling Start
    VADisplayed --> CheckingStatus: Polling Start
    
    CheckingStatus --> Success: Payment Confirmed
    CheckingStatus --> Expired: Timeout
    CheckingStatus --> CheckingStatus: Status Pending
    
    Expired --> Initial: Create New
    
    Success --> [*]
```

---

## 8. Withdrawal BLoC Flow

```mermaid
stateDiagram-v2
    [*] --> Initial
    
    Initial --> LoadingBankAccounts: Load Saved Banks
    
    LoadingBankAccounts --> BankAccountsLoaded: Success
    BankAccountsLoaded --> InputtingAmount: User in Form
    
    InputtingAmount --> Validating: Submit Amount
    Validating --> ReadyToSubmit: Valid
    Validating --> InputtingAmount: Invalid
    
    ReadyToSubmit --> ProcessingWithdrawal: PIN Verified
    ProcessingWithdrawal --> Success: API Success
    ProcessingWithdrawal --> Error: API Error
    
    Success --> [*]
    Error --> InputtingAmount
```

---

## 9. Payment Method Selection

```mermaid
flowchart TD
    A[Select Payment] --> B{Choose Method}
    
    B --> C[QRIS]
    B --> D[BCA Virtual Account]
    B --> E[Mandiri Virtual Account]
    B --> F[BNI Virtual Account]
    B --> G[BRI Virtual Account]
    
    C --> H[QRISPaymentPages]
    D --> I[BankPaymentPages - BCA]
    E --> J[BankPaymentPages - Mandiri]
    F --> K[BankPaymentPages - BNI]
    G --> L[BankPaymentPages - BRI]
```

---

## 10. Currency Input Formatting

```mermaid
flowchart TD
    A[User Input Amount] --> B[Clean Input - Remove Non-Digits]
    B --> C{Parse to Int}
    C -->|Valid| D[Check Max Value]
    C -->|Invalid| E[Set to 0]
    
    D --> F{> Max Limit?}
    F -->|Yes| G[Cap at Max]
    F -->|No| H[Keep Value]
    
    G --> I[Format with Currency]
    H --> I
    E --> I
    
    I --> J[Update Controller]
    J --> K[Update Button State]
    K --> L{Amount Valid?}
    L -->|Yes| M[Enable Button]
    L -->|No| N[Disable Button]
```

---

## Components

### BLoC Files
- `topup_bloc.dart` - Top up logic
- `saldo_withdrawal_bloc.dart` - Withdrawal logic

### Views
- `topup_pages.dart` - Top up form
- `qrispayment_pages.dart` - QRIS payment display
- `bankpayment_pages.dart` - Bank transfer display
- `saldo_withdrawal_page.dart` - Withdrawal form
- `success_witdrawal_page.dart` - Success confirmation

### Widgets
- `custom_radiolist_tile.dart` - Payment method selector

---

## API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/topup/create` | POST | Create top up transaction |
| `/topup/status/{id}` | GET | Check payment status |
| `/topup/qris/{id}` | GET | Get QRIS code |
| `/withdrawal/create` | POST | Create withdrawal |
| `/bank-accounts` | GET | Get saved bank accounts |

---

## Amount Limits

| Type | Minimum | Maximum |
|------|---------|---------|
| Top Up | Rp 10.000 | Rp 10.000.000 |
| Withdrawal | Rp 50.000 | (Saldo Available) |
