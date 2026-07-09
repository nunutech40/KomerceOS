# Auth System Refactoring - Technical Documentation

> **Dokumen ini adalah reference technical untuk 4 task refactoring auth system yang ada di ClickUp.**  
> Baca dokumen ini untuk memahami context, masalah, dan solusi secara detail sebelum mengerjakan task.

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [Current Architecture Analysis](#current-architecture-analysis)
3. [Problems & Weaknesses](#problems--weaknesses)
4. [Proposed Solution](#proposed-solution)
5. [Implementation References](#implementation-references)
6. [Testing Guidelines](#testing-guidelines)

---

## Overview

### Project Context
**Project**: Komtim Partner (Flutter Mobile App)  
**Architecture**: Clean Architecture (Presentation → Domain → Data)  
**State Management**: BLoC Pattern  
**DI**: GetIt  
**Routing**: GoRouter  

### Refactoring Goals
1. ✅ Menghilangkan race condition pada token refresh
2. ✅ Implement centralized authentication state management
3. ✅ Migrate dari HTTP package ke Dio dengan interceptor pattern
4. ✅ Improve security dengan secure token storage
5. ✅ Proactive token validation (bukan reactive)

### Related ClickUp Tasks
Dokumen ini mendukung 4 task utama:
- **Task 1**: Setup Dio + Interceptor Infrastructure
- **Task 2**: Create Centralized AuthenticationManager
- **Task 3**: Migrate DataSources & Integration
- **Task 4**: Testing & Security Enhancement

---

## Current Architecture Analysis

### Layer Structure

```
PRESENTATION LAYER (features/)
├── auth/
│   ├── bloc/login_bloc.dart
│   ├── view/login_page.dart
│   └── splash_screen.dart
└── home/
    ├── bloc/home_page_bloc.dart
    └── view/main_page.dart

DOMAIN LAYER (core/domain/)
├── usecases/
│   ├── do_login_use_case.dart
│   └── get_profile_use_case.dart
└── repositories/
    └── auth_repository.dart (interface)

DATA LAYER (core/data/)
├── repositories/
│   └── auth_repository_impl.dart
├── datasources/
│   ├── remote/auth_remote_datasource.dart
│   └── preferences/shared_pref.dart
└── apiservice/
    ├── http_service.dart
    └── response_parser.dart
```

### Current Auth Flow

#### 1. Login Flow
```
User Input → LoginBloc → DoLoginUseCase → AuthRepository 
→ AuthRemoteDataSource → HttpService → API
→ Save to SharedPreferences (accessToken, refreshToken, userData)
```

#### 2. API Request Flow
```
Any API Call → HttpService.doRequest()
  ├─ if isToken=true:
  │   └─ Get token from SharedPref → Add to headers
  └─ _attemptRequest()
      └─ on 401:
          ├─ if _isRefreshingToken:
          │   └─ Queue request to _pendingRequests[]
          └─ else:
              ├─ Set _isRefreshingToken = true
              ├─ Call refresh token API
              ├─ Save new tokens
              ├─ Retry original request
              └─ Retry queued requests
```

#### 3. App Startup
```
main() → SplashScreen → pref.isLoggedIn()?
  ├─ YES → Navigate to MainPage
  └─ NO  → Navigate to LoginPage
```

### Current Token Storage
**Location**: `SharedPreferences` (unencrypted)
```dart
{
  "USERANDTOKEN": {
    "accessToken": "eyJhbG...",     // ⚠️ Plain text
    "refreshToken": "eyJhbG...",    // ⚠️ Plain text
    "data": { user info }
  }
}
```

---

## Problems & Weaknesses

### 🔴 Problem 1: Race Condition pada Token Refresh (CRITICAL)

**Scenario**:
```
Request 1: GET /invoices  ──┐
Request 2: GET /profile   ──┼─→ All get 401 simultaneously
Request 3: GET /talents   ──┘

Current behavior:
1. Request 1 checks _isRefreshingToken → FALSE
2. Request 2 checks _isRefreshingToken → FALSE (too fast!)
3. Request 3 checks _isRefreshingToken → FALSE (too fast!)
4. All 3 request call refresh token API → ❌ MULTIPLE CALLS!
```

**Root Cause**:
- Flag check dan set tidak atomic
- Tidak ada mutex/lock mechanism
- Race window antara check dan set flag

**Code Location**: `lib/core/data/apiservice/http_service.dart:147-160`

**Impact**:
- Waste bandwidth (multiple unnecessary API calls)
- Possible token invalidation
- Poor performance

---

### 🟡 Problem 2: No Proactive Token Validation

**Current Behavior**:
```
App Startup → SplashScreen
  └─ Check: token != null? (only existence check)
      ├─ YES → Go to MainPage
      │         ↓
      │    First API call → 401 Token Expired!
      │         ↓
      │    Trigger refresh → Delay
      └─ NO → Go to LoginPage
```

**Issue**: Token expiry tidak di-check di startup, hanya saat first API call.

**Code Location**: `lib/features/auth/splash_screen.dart:262-267`

**Impact**:
- Bad UX (unnecessary loading/error pada first screen)
- Delayed user experience
- Wasted API call

---

### 🔴 Problem 3: Scattered Auth State (CRITICAL)

**Multiple Places Handle Auth**:
1. `SplashScreen` → Checks `isLoggedIn()`
2. `HttpService._refreshToken()` → Triggers logout on failure
3. `HomePageBloc` → Has `LogoutButtonPressedEvent`
4. Each BLoC independently handles auth

**Issue**: NO single source of truth!

**Impact**:
- Inconsistent logout behavior
- Hard to track auth state changes
- Difficult to test
- No reactive auth updates

---

### 🟠 Problem 4: Insecure Token Storage

**Current**: Tokens stored in `SharedPreferences` (plain text)
```dart
// Can be read via:
// - Rooted/jailbroken device file explorer
// - Backup extraction
// - Malware access
```

**Available but Unused**: `flutter_secure_storage: ^8.0.0` already in pubspec.yaml

**Impact**: Security vulnerability for production app

---

### 🟡 Problem 5: Tight Coupling to HTTP Package

**Issues**:
- Manual HTTP method handling (GET, POST, PUT, DELETE)
- No interceptor pattern
- Hard to add features (logging, retry, custom headers)
- Difficult to test (tight coupling)

**Code Location**: `lib/core/data/apiservice/http_service.dart`

---

## Proposed Solution

### Architecture Overview

```
┌─────────────────────────────────────────┐
│         ROOT APP LEVEL                   │
│  ┌───────────────────────────────────┐  │
│  │  AuthenticationManager            │  │
│  │  (ChangeNotifier)                 │  │
│  │  - Centralized auth state         │  │
│  │  - Proactive token validation     │  │
│  │  - Observable state changes       │  │
│  └───────────────────────────────────┘  │
└─────────────────────────────────────────┘
              ↓ provides to
┌─────────────────────────────────────────┐
│      PRESENTATION LAYER                  │
│  BLoCs, Widgets dapat access:           │
│  - authManager.isAuthenticated           │
│  - authManager.currentUser               │
│  - authManager.authStateStream           │
└─────────────────────────────────────────┘
              ↓ uses
┌─────────────────────────────────────────┐
│      NETWORK LAYER                       │
│  ┌────────────────────────────────┐     │
│  │  DioClient                     │     │
│  │  with Interceptors:            │     │
│  │  - AuthInterceptor (*)         │     │
│  │  - LoggingInterceptor          │     │
│  └────────────────────────────────┘     │
└─────────────────────────────────────────┘
              ↓ stores to
┌─────────────────────────────────────────┐
│      STORAGE LAYER                       │
│  ┌──────────────┐  ┌─────────────────┐  │
│  │SecureStorage │  │SharedPreferences│  │
│  │- tokens      │  │- user data      │  │
│  │(encrypted)   │  │(non-sensitive)  │  │
│  └──────────────┘  └─────────────────┘  │
└─────────────────────────────────────────┘

(*) AuthInterceptor: Race condition prevention via QueuedInterceptorsWrapper
```

### Key Components

#### 1. DioClient dengan Interceptors

**Purpose**: Replace `HttpService` dengan modern HTTP client

**Benefits**:
✅ Built-in interceptor support  
✅ Better error handling (DioException)  
✅ Auto JSON encoding/decoding  
✅ Request/response transformation  
✅ Easy to extend & test  

**Files**:
- `lib/core/data/apiservice/dio_client.dart`
- `lib/core/data/apiservice/interceptors/auth_interceptor.dart`
- `lib/core/data/apiservice/interceptors/logging_interceptor.dart`

---

#### 2. AuthInterceptor (Race Condition Solution)

**Key Feature**: `QueuedInterceptorsWrapper`

**How It Works**:
```dart
class AuthInterceptor extends QueuedInterceptorsWrapper {
  bool _isRefreshing = false;
  final List<RequestQueueItem> _requestsQueue = [];

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 401) return handler.next(err);

    if (_isRefreshing) {
      // Queue request - will be retried after refresh
      _requestsQueue.add(...);
      return; // Don't continue
    }

    _isRefreshing = true;
    
    try {
      // Single refresh call
      await _refreshToken();
      
      // Retry original request
      final response = await _dio.fetch(err.requestOptions);
      handler.resolve(response);
      
      // Retry all queued requests
      await _retryQueuedRequests();
    } catch (e) {
      // Logout on refresh failure
      await _handleLogout();
      handler.reject(err);
    } finally {
      _isRefreshing = false;
    }
  }
}
```

**Guarantee**: `QueuedInterceptorsWrapper` ensures sequential processing → Only ONE refresh call!

---

#### 3. AuthenticationManager (Centralized State)

**Inspired by**: Swift's `AuthenticationManager` (ObservableObject pattern)

**Flutter Implementation**:
```dart
class AuthenticationManager extends ChangeNotifier {
  AuthState _authState = const AuthState.initial();
  
  AuthState get authState => _authState;
  UserModel? get currentUser => _authState.user;
  bool get isAuthenticated => _authState.isAuthenticated;
  
  // Stream for BLoC integration
  final _authStateController = StreamController<AuthState>.broadcast();
  Stream<AuthState> get authStateStream => _authStateController.stream;

  AuthenticationManager({required SharedPref sharedPref}) {
    checkLoginStatus(); // Proactive check on initialization
  }

  /// Proactive token validation
  Future<void> checkLoginStatus() async {
    _updateAuthState(const AuthState.checking());

    final token = await _sharedPref.getToken();
    if (token == null || _isTokenExpired(token)) {
      // Check refresh token
      final refreshToken = await _sharedPref.getRefreshToken();
      if (refreshToken != null && !_isTokenExpired(refreshToken)) {
        // Will refresh on next request
        await _loadCachedUser();
      } else {
        await logout();
      }
    } else {
      await _loadCachedUser();
    }
  }

  bool _isTokenExpired(String token) {
    final decodedToken = JWT.decode(token);
    final exp = DateTime.fromMillisecondsSinceEpoch(
      decodedToken.payload['exp'] * 1000
    );
    return exp.isBefore(DateTime.now());
  }
}
```

**Key Features**:
- ✅ Single source of truth
- ✅ Reactive (ChangeNotifier + Stream)
- ✅ Proactive token check
- ✅ Observable state changes

**Usage in Widgets**:
```dart
Consumer<AuthenticationManager>(
  builder: (context, authManager, child) {
    if (authManager.isAuthenticated) {
      return HomePage();
    }
    return LoginPage();
  },
)
```

**Usage in BLoC**:
```dart
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthenticationManager authManager;
  
  // After successful login:
  await authManager.login(user);
}
```

---

#### 4. Secure Token Storage

**Implementation**:
```dart
class SecureStorageService {
  final FlutterSecureStorage _secureStorage;
  
  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: 'access_token', value: token);
  }
  
  Future<String?> getToken() async {
    return await _secureStorage.read(key: 'access_token');
  }
}

class SharedPref {
  final SecureStorageService secureStorage;
  
  Future<void> saveUserAndToken(LoginResponse response) async {
    // Tokens → Secure Storage (encrypted)
    await secureStorage.saveToken(response.accessToken);
    await secureStorage.saveRefreshToken(response.refreshToken);
    
    // User data → SharedPreferences (non-sensitive)
    final prefs = await sharedPreferences;
    await prefs.setString('USER_DATA', jsonEncode(response.data));
  }
}
```

**Security**: Encrypted at OS level, better protection.

---

## Implementation References

### Dependencies Required

```yaml
dependencies:
  dio: ^5.4.0
  pretty_dio_logger: ^1.3.1  # Development only
  provider: ^6.1.1
  flutter_secure_storage: ^8.0.0  # Already in pubspec
```

### File Structure (New Files)

```
lib/core/
├── data/
│   └── apiservice/
│       ├── dio_client.dart                    # NEW
│       ├── dio_response_parser.dart           # NEW
│       └── interceptors/
│           ├── auth_interceptor.dart          # NEW
│           └── logging_interceptor.dart       # NEW
├── domain/
│   ├── entities/
│   │   └── auth_state.dart                    # NEW
│   └── managers/
│       └── authentication_manager.dart        # NEW
└── datasources/
    └── preferences/
        └── secure_storage_service.dart        # NEW
```

### DI Registration

```dart
// lib/DI/injection.dart
Future<void> initDependencies() async {
  // Dio & Interceptors
  locator.registerLazySingleton(() => Dio());
  locator.registerLazySingleton(() => LoggingInterceptor());
  locator.registerLazySingleton(() => AuthInterceptor(
    sharedPref: locator(),
    dio: locator(),
  ));
  locator.registerLazySingleton(() => DioClient(
    sharedPref: locator(),
    authInterceptor: locator(),
    loggingInterceptor: locator(),
  ));

  // AuthenticationManager
  locator.registerLazySingleton(() => AuthenticationManager(
    sharedPref: locator(),
  ));

  // Secure Storage
  locator.registerLazySingleton(() => SecureStorageService());
  
  // ... rest of existing code
}
```

### Root App Integration

```dart
// lib/main.dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: di.locator.allReady(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return ChangeNotifierProvider<AuthenticationManager>.value(
            value: di.locator<AuthenticationManager>(),
            child: const AuthenticatedApp(),
          );
        }
        return LoadingScreen();
      },
    );
  }
}

class AuthenticatedApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthenticationManager>(
      builder: (context, authManager, child) {
        return MaterialApp.router(
          routeInformationProvider: AppRouter.router.routeInformationProvider,
          routeInformationParser: AppRouter.router.routeInformationParser,
          routerDelegate: AppRouter.router.routerDelegate,
        );
      },
    );
  }
}
```

### Migration Pattern (HTTP → Dio)

**Before** (HttpService):
```dart
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final HttpService client;
  
  Future<LoginResponse> doLogin(String username, String password, String fcm) async {
    String body = json.encode({
      'username': username,
      'password': password,
      'fcm_token': fcm,
    });

    final response = await client.doRequest(
      method: 'POST',
      url: Endpoints.login,
      body: body,
      isLogin: true,
    );

    return responseParser.parseResponse<LoginResponse>(
      response,
      (json) => LoginResponse.fromJson(json),
    );
  }
}
```

**After** (DioClient):
```dart
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient client;
  final DioResponseParser responseParser;
  
  Future<LoginResponse> doLogin(String username, String password, String fcm) async {
    final data = {
      'username': username,
      'password': password,
      'fcm_token': fcm,
    };

    final response = await client.post(Endpoints.login, data: data);

    return responseParser.parseResponse<LoginResponse>(
      response,
      (json) => LoginResponse.fromJson(json),
    );
  }
}
```

**Key Changes**:
- ❌ `json.encode()` → ✅ Dio handles automatically
- ❌ `method: 'POST'` → ✅ `client.post()`
- ❌ `isLogin: true` flag → ✅ Interceptor handles automatically
- ✅ Cleaner code

---

## Testing Guidelines

### Unit Tests

#### Test: AuthInterceptor Race Condition Prevention
```dart
test('should handle concurrent 401s with single refresh call', () async {
  // Setup
  when(mockSharedPref.getRefreshToken()).thenReturn('refresh_token');
  when(mockDio.put(any, data: any)).thenAnswer(
    (_) async => Response(data: {'data': mockLoginResponse}, statusCode: 200)
  );

  // Execute: Trigger 3 concurrent 401s
  final futures = [
    authInterceptor.onError(createDioError(401), handler1),
    authInterceptor.onError(createDioError(401), handler2),
    authInterceptor.onError(createDioError(401), handler3),
  ];
  
  await Future.wait(futures);

  // Verify: Only 1 refresh API call
  verify(mockDio.put(Endpoints.refreshToken, data: any)).called(1);
});
```

#### Test: AuthenticationManager Proactive Check
```dart
test('should check token expiry on initialization', () async {
  // Setup expired token
  when(mockSharedPref.getToken()).thenReturn(expiredToken);
  when(mockSharedPref.getRefreshToken()).thenReturn(validRefreshToken);

  // Execute
  final authManager = AuthenticationManager(sharedPref: mockSharedPref);
  await Future.delayed(Duration(milliseconds: 100)); // Wait for check

  // Verify: Should load cached user (not logout immediately)
  expect(authManager.isAuthenticated, true);
});
```

### Integration Tests

**Scenario 1**: Multiple Concurrent Requests with Expired Token
```
1. Login user
2. Manually expire token (or wait)
3. Trigger 5 concurrent API calls
4. Verify:
   - Only 1 refresh token API call
   - All 5 requests succeed after refresh
   - All requests have new token in header
```

**Scenario 2**: App Startup with Expired Token
```
1. Install fresh app
2. Login
3. Expire token manually
4. Kill app
5. Restart app
6. Verify:
   - SplashScreen detects expired token
   - AuthManager triggers refresh on first API call
   - User stays logged in (if refresh token valid)
```

**Scenario 3**: Refresh Token Also Expired
```
1. Login
2. Expire both access & refresh tokens
3. Restart app
4. Verify:
   - Navigate to LoginPage
   - Local data cleared
   - No error crashes
```

### Manual Testing Checklist

- [ ] Fresh install → Login → Works
- [ ] App restart with valid token → Auto-login
- [ ] App restart with expired token → Refresh works
- [ ] Multiple concurrent requests → No race condition
- [ ] Logout → All data cleared → Cannot access protected routes
- [ ] Token in SecureStorage → Check via debugging
- [ ] Network logging in debug mode only
- [ ] No token leaks in production logs

---

## Success Criteria

### Functional Requirements
✅ Login flow works end-to-end  
✅ Token auto-refresh on 401  
✅ NO race condition pada concurrent requests  
✅ Proactive auth check di app startup  
✅ Logout clears all tokens  
✅ App navigation responds to auth state changes  

### Security Requirements
✅ Tokens stored in SecureStorage (encrypted)  
✅ No tokens in plain text logs (production)  
✅ Secure cleanup on logout  

### Performance Requirements
✅ App startup < 2 seconds  
✅ Token refresh < 1 second  
✅ No UI blocking during auth operations  

### Code Quality
✅ Clean separation of concerns  
✅ Testable components  
✅ Consistent error handling  
✅ Well-documented code  
✅ No breaking changes to existing features  

---

## Comparison: Before vs After

| Aspect | Before | After |
|--------|--------|-------|
| **Network Client** | HTTP package (manual) | Dio with interceptors |
| **Race Condition** | ⚠️ Possible multiple refresh | ✅ Guaranteed single refresh |
| **Token Check** | ❌ Reactive (on API call) | ✅ Proactive (on startup) |
| **Auth State** | ❌ Scattered | ✅ Centralized AuthManager |
| **Token Storage** | ⚠️ SharedPrefs (plain text) | ✅ SecureStorage (encrypted) |
| **State Updates** | ❌ No reactive updates | ✅ ChangeNotifier + Stream |
| **Testability** | ⚠️ Difficult | ✅ Easy to mock |
| **Code Maintainability** | ⚠️ Complex | ✅ Clean & organized |

---

## Related Documentation

- **`ANALYSIS_SUMMARY.md`**: Visual diagrams & flow explanation
- **`README.md`**: Quick start guide & checklist
- **Swift Reference**: See uploaded screenshots for AuthenticationManager pattern

---

## Support & Questions

**For implementation questions**:
1. Review code examples di dokumen ini
2. Check Dio official docs: https://pub.dev/packages/dio
3. Refer to Swift AuthenticationManager pattern (uploaded screenshots)

**For edge cases**:
- Race condition: Ensure using `QueuedInterceptorsWrapper`
- Token expiry: Ensure JWT decode logic correct
- State sync: Ensure `notifyListeners()` called after state changes

---

**Document Version**: 2.0  
**Last Updated**: 2026-01-30  
**Status**: Reference Documentation for ClickUp Tasks
