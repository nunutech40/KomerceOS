# Invoice Management Flow

## Deskripsi
Flow manajemen invoice mencakup daftar invoice, detail ringkasan, dan proses pembayaran.

---

## 1. Invoice List Flow

```mermaid
flowchart TD
    A[Navigate to Invoice List] --> B[InvoiceListPage Init]
    B --> C[Load Invoice List API]
    C --> D{API Result}
    D -->|Success| E[Display Invoice List]
    D -->|Error| F[Show Error State]
    D -->|Empty| G[Show Empty State]
    
    E --> H{User Action}
    H -->|Pull Refresh| I[Reload Data]
    I --> C
    H -->|Scroll Bottom| J{Has More?}
    J -->|Yes| K[Load More]
    K --> E
    J -->|No| L[End of List]
    H -->|Tap Invoice| M[Navigate to Invoice Summary]
```

---

## 2. Invoice Report Summary Flow

```mermaid
flowchart TD
    A[Invoice Summary Page] --> B[Load Invoice Detail]
    B --> C{API Result}
    C -->|Success| D[Display Invoice Detail]
    C -->|Error| E[Show Error]
    
    D --> F{Invoice Status}
    F -->|Pending| G[Show Payment Options]
    F -->|Processing| H[Show Processing Status]
    F -->|Paid| I[Show Paid Status]
    F -->|Completed| J[Show Complete with Rating Option]
    
    G --> K{User Action}
    K -->|Pay Now| L[Navigate to Payment Method]
    K -->|Pay with Kompay| M[Verify PIN]
    
    J --> N{Rating Done?}
    N -->|No| O[Navigate to Rate Talent]
    N -->|Yes| P[Show Completed]
```

---

## 3. Invoice Detail Components

```mermaid
flowchart TB
    A[InvoiceReportSummaryPage] --> B[Header Section]
    B --> C[Invoice Code]
    B --> D[Invoice Status Badge]
    
    A --> E[Body Content]
    E --> F[Period Info]
    E --> G[Talent List]
    E --> H[Amount Breakdown]
    E --> I[Total Amount]
    
    A --> J[Bottom Section]
    J --> K{Based on Status}
    K -->|Pending| L[Pay Button]
    K -->|Paid| M[Rate Talent Button]
    K -->|Completed| N[Done Message]
```

---

## 4. Payment Method Selection Flow

```mermaid
flowchart TD
    A[Payment Method Page] --> B[Load Payment Methods]
    B --> C[Display Payment Options]
    
    C --> D{Select Method}
    D -->|Kompay Saldo| E{Sufficient Balance?}
    E -->|Yes| F[Navigate to PIN Verify]
    E -->|No| G[Show Insufficient Balance]
    G --> H[Top Up Option]
    H --> I[Navigate to Top Up]
    
    D -->|Xendit VA/Card| J[Open Xendit WebView]
    J --> K{Payment Status}
    K -->|Success| L[Success Payment Page]
    K -->|Failed| M[Show Error]
    K -->|Pending| N[Show Pending Status]
    
    F --> O[Verify PIN]
    O --> P{PIN Valid?}
    P -->|Yes| Q[Process Payment]
    Q --> L
    P -->|No| R[Show PIN Error]
    R --> F
```

---

## 5. Invoice Status State Machine

```mermaid
stateDiagram-v2
    [*] --> Pending: Invoice Created
    
    Pending --> Processing: Payment Initiated
    Pending --> Pending: Payment Failed
    
    Processing --> Paid: Payment Confirmed
    Processing --> Pending: Payment Timeout
    
    Paid --> Completed: Rating Submitted
    
    Completed --> [*]: Invoice Finalized
    
    note right of Pending
        Menunggu pembayaran
    end note
    
    note right of Paid
        Perlu rating talent
    end note
```

---

## 6. Invoice BLoC State Flow

```mermaid
stateDiagram-v2
    [*] --> Initial
    
    Initial --> Loading: LoadInvoiceList
    
    Loading --> Success: Data Loaded
    Loading --> Error: API Error
    Loading --> Empty: No Data
    
    Success --> LoadingMore: Scroll to Bottom
    LoadingMore --> Success: More Data Loaded
    LoadingMore --> NoMoreData: End of List
    
    Success --> Loading: Refresh
    
    Error --> Loading: Retry
```

---

## 7. Payment via Kompay Flow

```mermaid
flowchart TD
    A[Select Pay with Kompay] --> B{Check Saldo}
    B -->|Sufficient| C[Navigate to PIN Page]
    B -->|Insufficient| D[Show Alert - Top Up Required]
    
    C --> E[PIN Entry Page]
    E --> F[Enter 6-digit PIN]
    F --> G[Verify PIN API]
    G --> H{PIN Valid?}
    H -->|No| I[Show Error]
    I --> J{Retry Count < 3?}
    J -->|Yes| E
    J -->|No| K[Lock Account]
    
    H -->|Yes| L[Process Payment API]
    L --> M{Payment Result}
    M -->|Success| N[Success Payment Page]
    M -->|Failed| O[Show Error]
    O --> P[Return to Invoice]
    
    N --> Q[Navigate to Main]
```

---

## 8. Success Payment Flow

```mermaid
flowchart TD
    A[SuccessPaymentKompayPage] --> B[Show Success Animation]
    B --> C[Display Invoice ID]
    C --> D[Display Status]
    D --> E[Show Success Message]
    
    E --> F{User Action}
    F -->|Back to Home| G[Navigate to Main Page]
    F -->|View Invoice| H[Navigate to Invoice Summary]
```

---

## 9. Invoice with Rating Flow

```mermaid
flowchart TD
    A[Invoice Summary - Paid] --> B[Check Rating Status]
    B --> C{Need Rating?}
    C -->|Yes| D[Show Rate Talent Button]
    C -->|No| E[Show Completed Status]
    
    D --> F[Tap Rate Talent]
    F --> G[RateTalentNotifPage]
    G --> H[Select Talents to Rate]
    H --> I[RateTalentCheckPage]
    I --> J[Submit Ratings]
    J --> K[EvaluationKompointPage]
    K --> L[Calculate Kompoint]
    L --> M[Submit Evaluation]
    M --> N{Success?}
    N -->|Yes| O[Navigate to Success]
    N -->|No| P[Show Error]
```

---

## Components

### BLoC Files
- `invoice_list_bloc.dart` - Invoice list logic
- `invoice_report_summary_bloc.dart` - Invoice detail logic
- `payment_method_bloc.dart` - Payment selection logic

### Views
- `invoice_list_page.dart` - List all invoices
- `invoice_report_summary_page.dart` - Invoice detail
- `payment_method_page.dart` - Payment selection
- `success_payment_kompay_page.dart` - Success confirmation

### Widgets
- `invoice_item.dart` - Invoice list item
- `custom_outline_button.dart` - Action buttons

---

## API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/invoices` | GET | Get invoice list |
| `/invoices/{id}` | GET | Get invoice detail |
| `/invoices/{id}/pay` | POST | Process payment |
| `/payment-methods` | GET | Get available methods |

---

## Data Models

```dart
class InvoicesModel {
  final int id;
  final String invoiceCode;
  final String status;
  final int totalAmount;
  final DateTime dueDate;
  // ...
}

class InvoiceDetailModel {
  final int id;
  final String invoiceCode;
  final List<TalentItem> talents;
  final PaymentInfo payment;
  // ...
}
```
