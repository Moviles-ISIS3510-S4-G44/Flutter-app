# How to Remove Demo Bypass and Switch to Real Firebase

## Step 1: main.dart

1. Change `const bool kBypassFirebase = true;` to `false`
2. Uncomment `await Firebase.initializeApp();`
3. Replace mock imports with real ones:

```dart
// DELETE these:
import 'data/services/mock_firebase_service.dart';
import 'data/services/mock_analytics_service.dart';
import 'data/repositories/mock_user_repository.dart';
import 'data/repositories/mock_product_repository.dart';

// ADD these:
import 'package:firebase_core/firebase_core.dart';
import 'data/services/firebase_service.dart';
import 'data/services/analytics_service.dart';
import 'data/repositories/user_repository.dart';
import 'data/repositories/product_repository.dart';
```

4. Swap mock instances:

```dart
final firebaseService = FirebaseService();
final analyticsService = AnalyticsService();
final userRepo = UserRepository(firebaseService);
final productRepo = ProductRepository(firebaseService);
```

## Step 2: login_view.dart

Remove the `if (kBypassFirebase)` block and `import 'main.dart'`.

## Step 3: Delete mock files

- `lib/data/services/mock_firebase_service.dart`
- `lib/data/services/mock_analytics_service.dart`
- `lib/data/repositories/mock_user_repository.dart`
- `lib/data/repositories/mock_product_repository.dart`

## Step 4: Delete this file

Thats it. The real services are already written and ready.
