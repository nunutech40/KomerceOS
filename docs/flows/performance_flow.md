# Performance Reports Flow

## Deskripsi
Flow laporan performa mencakup overview performa, laporan mingguan, dan detail performa bulanan per produk.

---

## 1. Performance Overview Flow

```mermaid
flowchart TD
    A[Navigate to Performance] --> B[ReportPerformancePages Init]
    B --> C[Initialize BLoC]
    C --> D[Load Performance Data]
    
    D --> E{API Result}
    E -->|Success| F[Display Performance Overview]
    E -->|Error| G[Show Error State]
    E -->|Empty| H[Show No Data]
    
    F --> I[Summary Statistics]
    F --> J[Product Performance List]
    F --> K[Weekly Report Section]
```

---

## 2. Performance Page Structure

```mermaid
flowchart TB
    A[ReportPerformancePages] --> B[AppBar]
    B --> C[Title: Laporan Performa]
    
    A --> D[Body]
    D --> E[Summary Cards]
    E --> F[Total Penjualan]
    E --> G[Total Produk]
    E --> H[Rating Average]
    
    D --> I[Product Performance]
    I --> J[Product Card 1]
    I --> K[Product Card 2]
    I --> L[Product Card N...]
    
    D --> M[Weekly Performance]
    M --> N[Week 1]
    M --> O[Week 2]
    M --> P[Week 3]
    M --> Q[Week 4]
```

---

## 3. Performance Data Flow

```mermaid
flowchart TD
    A[Load Performance] --> B[Get Monthly Data]
    B --> C[Get Weekly Data]
    C --> D[Get Product Data]
    
    D --> E[Combine All Data]
    E --> F[Emit Success State]
    
    F --> G[Render Summary]
    F --> H[Render Product List]
    F --> I[Render Weekly Chart]
```

---

## 4. Product Performance Detail

```mermaid
flowchart TD
    A[Tap Product Card] --> B[Navigate to Detail]
    B --> C[DetailReportPerformanceMonthPages]
    C --> D[Receive Product Data]
    
    D --> E[Display Product Name]
    D --> F[Display Monthly Details]
    
    F --> G[Sales Count]
    F --> H[Revenue]
    F --> I[Rating]
    F --> J[Trend Chart]
```

---

## 5. Performance BLoC State

```mermaid
stateDiagram-v2
    [*] --> Initial
    
    Initial --> Loading: LoadPerformanceData
    
    Loading --> MonthlyLoaded: Monthly Data Success
    MonthlyLoaded --> WeeklyLoading: Load Weekly
    
    WeeklyLoading --> WeeklyLoaded: Weekly Data Success
    WeeklyLoaded --> ProductLoading: Load Products
    
    ProductLoading --> AllLoaded: All Data Ready
    
    AllLoaded --> [*]: Render Complete
    
    Loading --> Error: Any API Error
    Error --> Loading: Retry
```

---

## 6. Weekly Performance Display

```mermaid
flowchart LR
    A[Weekly Report] --> B[Week Selection]
    B --> C[Week 1]
    B --> D[Week 2]
    B --> E[Week 3]
    B --> F[Week 4]
    
    C --> G[Display Week 1 Stats]
    D --> H[Display Week 2 Stats]
    E --> I[Display Week 3 Stats]
    F --> J[Display Week 4 Stats]
    
    G --> K[Sales]
    G --> L[Revenue]
    G --> M[Target Achieved %]
```

---

## 7. Monthly Report Structure

```mermaid
flowchart TD
    A[Monthly Report] --> B[Header Info]
    B --> C[Month & Year]
    B --> D[Total Summary]
    
    A --> E[Detail by Week]
    E --> F[Week 1 Data]
    E --> G[Week 2 Data]
    E --> H[Week 3 Data]
    E --> I[Week 4 Data]
    
    A --> J[Product Breakdown]
    J --> K[Product 1 Stats]
    J --> L[Product 2 Stats]
    J --> M[Product N Stats]
```

---

## 8. Detail Report Navigation

```mermaid
flowchart TD
    A[Performance Overview] --> B{Select View}
    
    B -->|Tap Product| C[Product Detail Page]
    B -->|Tap Weekly| D[Weekly Detail View]
    
    C --> E[Monthly Breakdown]
    E --> F[DetailModel List]
    E --> G[Product Name]
    
    D --> H[Daily Breakdown]
    H --> I[Per Day Stats]
```

---

## 9. Performance Metrics

```mermaid
flowchart TB
    A[Performance Metrics] --> B[Sales Metrics]
    A --> C[Revenue Metrics]
    A --> D[Quality Metrics]
    
    B --> E[Total Sales Count]
    B --> F[Sales Growth %]
    B --> G[Sales Target Achievement]
    
    C --> H[Total Revenue]
    C --> I[Average Transaction]
    C --> J[Revenue Growth %]
    
    D --> K[Customer Rating]
    D --> L[Complaint Rate]
    D --> M[Repeat Order Rate]
```

---

## 10. Data Model Flow

```mermaid
flowchart TD
    A[ReportPerformanceModel] --> B[Summary Data]
    B --> C[totalSales]
    B --> D[totalRevenue]
    B --> E[averageRating]
    
    A --> F[WeeklyData List]
    F --> G[ReportPerformanceWeeklyModel]
    G --> H[weekNumber]
    G --> I[weekSales]
    G --> J[weekRevenue]
    
    A --> K[ProductData List]
    K --> L[ReportPerformanceProductModel]
    L --> M[productName]
    L --> N[productSales]
    L --> O[productRevenue]
```

---

## Components

### BLoC Files
- `report_performance_bloc.dart` - Performance report logic
- `report_performance_event.dart` - Events
- `report_performance_state.dart` - States

### Views
- `report_performance_pages.dart` - Main performance page
- `detail_report_performance_month_pages.dart` - Monthly detail

### Widgets
- Performance summary cards
- Product performance cards
- Weekly chart widgets

---

## Data Models

```dart
class ReportPerformanceModel {
  final int totalSales;
  final int totalRevenue;
  final double averageRating;
  final List<WeeklyModel> weeklyData;
  final List<ProductModel> productData;
}

class ReportPerformanceMonthlyModel {
  final String month;
  final List<DetailModel> details;
}

class DetailModel {
  final String name;
  final int value;
  final String type;
}

class ReportPerformanceWeeklyModel {
  final int weekNumber;
  final int sales;
  final int revenue;
  final double target;
}

class ReportPerformanceProductModel {
  final String productName;
  final int sales;
  final int revenue;
}
```

---

## API Endpoints

| Endpoint | Method | Parameters | Description |
|----------|--------|------------|-------------|
| `/performance` | GET | month, year | Get performance overview |
| `/performance/weekly` | GET | month, year | Get weekly breakdown |
| `/performance/product` | GET | month, year | Get product breakdown |
| `/performance/detail/{productId}` | GET | month, year | Get product detail |
