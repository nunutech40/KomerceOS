# Shopping Management Flow

## Deskripsi
Flow shopping mencakup daftar belanja, filter berdasarkan status dan tanggal, serta detail item shopping.

---

## 1. Shopping List Flow

```mermaid
flowchart TD
    A[Navigate to Shopping] --> B[ShoppingListPage Init]
    B --> C[Initialize BLoC]
    C --> D[Load Shopping List]
    
    D --> E{API Result}
    E -->|Success| F[Display Shopping List]
    E -->|Error| G[Show Error State]
    E -->|Empty| H[Show Empty State]
    
    F --> I{User Action}
    I -->|Pull Refresh| J[Reload Data]
    I -->|Filter| K[Show Filter Bottom Sheet]
    I -->|Scroll Bottom| L[Load More]
    I -->|Tap Item| M[Navigate to Detail]
```

---

## 2. Shopping List Components

```mermaid
flowchart TB
    A[ShoppingListPage] --> B[AppBar]
    B --> C[Title: Daftar Belanja]
    B --> D[Filter Icon]
    
    A --> E[Body]
    E --> F{State}
    F -->|Loading| G[Shimmer Placeholder]
    F -->|Loaded| H[ListView]
    F -->|Empty| I[EmptyData Widget]
    
    H --> J[ItemShopping Cards]
    J --> K[Product Image]
    J --> L[Product Name]
    J --> M[Quantity]
    J --> N[Price]
    J --> O[Status Badge]
```

---

## 3. Filter Bottom Sheet Flow

```mermaid
flowchart TD
    A[Tap Filter Icon] --> B[Show Bottom Sheet]
    
    B --> C[Status Filter Section]
    C --> D[All Status]
    C --> E[Pending]
    C --> F[Processing]
    C --> G[Completed]
    C --> H[Cancelled]
    
    B --> I[Date Filter Section]
    I --> J[Today]
    I --> K[Last 7 Days]
    I --> L[This Month]
    I --> M[Custom Range]
    
    B --> N[Action Buttons]
    N --> O[Reset Filter]
    N --> P[Apply Filter]
    
    P --> Q[Update List with Filter]
    O --> R[Clear All Filters]
    R --> Q
```

---

## 4. Filter State Management

```mermaid
flowchart TD
    A[Filter Selection] --> B{Filter Type}
    
    B -->|Status| C[Update Status Filter]
    B -->|Date| D[Update Date Filter]
    
    C --> E[Reload Data with Status]
    D --> F[Reload Data with Date Range]
    
    E --> G[Display Filtered Results]
    F --> G
    
    H[Reset Filter] --> I[Clear Status]
    I --> J[Clear Date Range]
    J --> K[Reload All Data]
```

---

## 5. Shopping Item Card

```mermaid
flowchart LR
    A[ItemShopping Card] --> B[Left Section]
    B --> C[Product Thumbnail]
    
    A --> D[Middle Section]
    D --> E[Product Name]
    D --> F[Quantity x Price]
    D --> G[Total Amount]
    
    A --> H[Right Section]
    H --> I[Status Badge]
    H --> J[Date]
    
    I --> K{Status Type}
    K -->|Pending| L[Yellow]
    K -->|Processing| M[Blue]
    K -->|Completed| N[Green]
    K -->|Cancelled| O[Red]
```

---

## 6. Detail Shopping Flow

```mermaid
flowchart TD
    A[Tap Shopping Item] --> B[Navigate with Item ID]
    B --> C[DetailShoppingPage]
    C --> D[Load Detail API]
    
    D --> E{API Result}
    E -->|Success| F[Display Detail]
    E -->|Error| G[Show Error]
    
    F --> H[Product Information]
    F --> I[Order Details]
    F --> J[Status History]
    F --> K[Delivery Info]
    
    H --> L[Product Image]
    H --> M[Product Name]
    H --> N[Product Description]
    H --> O[Price & Quantity]
```

---

## 7. Shopping BLoC State

```mermaid
stateDiagram-v2
    [*] --> Initial
    
    Initial --> Loading: LoadShoppingList
    
    Loading --> Loaded: Data Success
    Loading --> Error: API Error
    Loading --> Empty: No Data
    
    Loaded --> LoadingMore: Pagination
    LoadingMore --> Loaded: More Loaded
    LoadingMore --> NoMore: End of List
    
    Loaded --> Filtering: Apply Filter
    Filtering --> FilteredLoaded: Filter Applied
    
    Loaded --> Loading: Refresh
    FilteredLoaded --> Loading: Clear Filter
```

---

## 8. Date Filter Options

```mermaid
flowchart TD
    A[Date Filter] --> B{Selection}
    
    B -->|Today| C[getTodayDate]
    B -->|7 Days| D[getLastSevenDate]
    B -->|This Month| E[getThisMonthRange]
    B -->|Custom| F[Show Date Picker]
    
    C --> G[startDate: today, endDate: today]
    D --> H[startDate: 7 days ago, endDate: today]
    E --> I[startDate: 1st of month, endDate: today]
    F --> J[User Selects Range]
    
    G --> K[Apply Date Filter]
    H --> K
    I --> K
    J --> K
```

---

## 9. Load More Pagination

```mermaid
flowchart TD
    A[Scroll Controller] --> B{Position Check}
    B -->|Near Bottom| C{Can Load More?}
    B -->|Not Near| D[Continue]
    
    C -->|Yes| E[Increment Offset]
    C -->|No| F[Show End Message]
    
    E --> G[Call API with Offset]
    G --> H{Has Data?}
    H -->|Yes| I[Append to List]
    H -->|No| J[Set noMoreData = true]
    
    I --> K[Update UI]
    J --> K
```

---

## 10. Shopping Status Types

```mermaid
flowchart LR
    A[Shopping Status] --> B[pending]
    A --> C[processing]
    A --> D[shipping]
    A --> E[delivered]
    A --> F[completed]
    A --> G[cancelled]
    
    B --> H[Menunggu Pembayaran]
    C --> I[Sedang Diproses]
    D --> J[Dalam Pengiriman]
    E --> K[Sudah Diterima]
    F --> L[Selesai]
    G --> M[Dibatalkan]
```

---

## Components

### BLoC Files
- `shopping_bloc.dart` - Shopping list logic
- `shopping_event.dart` - Events
- `shopping_state.dart` - States

### Views
- `shopping_list_page.dart` - Shopping list
- `detail_shopping_page.dart` - Shopping detail

### Widgets
- `item_shopping.dart` - List item card
- `empty_data.dart` - Empty state widget
- `bottom_sheet_filter.dart` - Filter bottom sheet

---

## Data Models

```dart
class ShoppingListDataModel {
  final int id;
  final String productName;
  final String productImage;
  final int quantity;
  final int price;
  final int totalAmount;
  final String status;
  final DateTime orderDate;
}

class DetailShoppingModel {
  final int id;
  final ProductInfo product;
  final OrderInfo order;
  final DeliveryInfo delivery;
  final List<StatusHistory> statusHistory;
}
```

---

## API Endpoints

| Endpoint | Method | Parameters | Description |
|----------|--------|------------|-------------|
| `/shopping` | GET | status, startDate, endDate, limit, offset | Get shopping list |
| `/shopping/{id}` | GET | - | Get shopping detail |
