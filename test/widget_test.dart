import 'dart:async';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'package:aauraluxe/app/data/models/models.dart';
import 'package:aauraluxe/app/data/providers/api_client.dart';
import 'package:aauraluxe/app/data/providers/auth_api.dart';
import 'package:aauraluxe/app/data/providers/product_api.dart';
import 'package:aauraluxe/app/data/providers/category_api.dart';
import 'package:aauraluxe/app/modules/auth/controllers/auth_controller.dart';
import 'package:aauraluxe/app/modules/customer/cart/controllers/cart_controller.dart';
import 'package:aauraluxe/app/modules/customer/home/controllers/home_controller.dart';
import 'package:aauraluxe/main.dart';

// Mock HttpOverrides to intercept NetworkImage calls
class MockHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return MockHttpClient();
  }
}

class MockHttpClient implements HttpClient {
  @override
  Future<HttpClientRequest> getUrl(Uri url) async => MockHttpClientRequest();
  
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class MockHttpClientRequest implements HttpClientRequest {
  @override
  Future<HttpClientResponse> close() async => MockHttpClientResponse();

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class MockHttpClientResponse implements HttpClientResponse {
  @override
  int get statusCode => 200;

  @override
  int get contentLength => 0;

  @override
  HttpClientResponseCompressionState get compressionState => HttpClientResponseCompressionState.notCompressed;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    // Return transparent 1x1 GIF bytes to satisfy NetworkImage resolution
    final bytes = [
      0x47, 0x49, 0x46, 0x38, 0x39, 0x61, 0x01, 0x00, 0x01, 0x00, 0x80, 0x00,
      0x00, 0x00, 0x00, 0x00, 0xff, 0xff, 0xff, 0x21, 0xf9, 0x04, 0x01, 0x00,
      0x00, 0x00, 0x00, 0x2c, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x01, 0x00,
      0x00, 0x02, 0x02, 0x44, 0x01, 0x00, 0x3b
    ];
    return Stream<List<int>>.fromIterable([bytes]).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

// Mock services to override API Client network calls
class MockProductApi extends ProductApi {
  @override
  Future<List<Product>> getProducts({
    String? categoryId,
    String? searchQuery,
    String? sortBy,
  }) async {
    return [];
  }
}

class MockCategoryApi extends CategoryApi {
  @override
  Future<List<Category>> getCategories() async {
    return [];
  }
}

class MockAuthApi extends AuthApi {
  @override
  Future<UserProfile?> getProfile(String userId) async {
    return null;
  }
}

void main() {
  setUpAll(() {
    HttpOverrides.global = MockHttpOverrides();
  });

  setUp(() {
    Get.reset();
  });

  testWidgets('AuraLuxe App startup smoke test', (WidgetTester tester) async {
    // 1. Initialize Mock SharedPreferences
    SharedPreferences.setMockInitialValues({});

    // 2. Register mock dependencies in GetX container
    final apiClient = ApiClient();
    await Get.putAsync(() => apiClient.init());
    
    Get.put<AuthApi>(MockAuthApi());
    Get.put<ProductApi>(MockProductApi());
    Get.put<CategoryApi>(MockCategoryApi());
    
    Get.put(AuthController());
    Get.put(CartController());
    Get.put(HomeController());

    // 3. Build our app and trigger a frame.
    await tester.pumpWidget(const AuraLuxeApp());
    await tester.pumpAndSettle();

    // Verify that our main title A U R A L U X E is successfully displayed
    expect(find.text('A U R A L U X E'), findsOneWidget);
  });
}
