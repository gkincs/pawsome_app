import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pawsome_app/services/auth_service.dart';

class MockAuthService extends Mock implements AuthService {}

void main() {
  late MockAuthService mockAuthService;

  setUp(() {
    mockAuthService = MockAuthService();
  });

  test('Login user returns null for valid credentials', () async {
    when(() => mockAuthService.loginUser('test@example.com', 'password123'))
        .thenAnswer((_) async => null);

    final result = await mockAuthService.loginUser('test@example.com', 'password123');
    expect(result, null); 
  });
}
