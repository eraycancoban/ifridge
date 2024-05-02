import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ifridge/screens/loginpage.dart'; // LoginPage dosyasını import edin

void main() {
  testWidgets('LoginPage UI Test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MaterialApp(
      home: LoginPage(), // LoginPage'i kullanarak uygulamayı başlatın
    ));

    // Verify that Welcome Back text is displayed
    expect(find.text('Welcome Back'), findsOneWidget);

    // Verify that Enter your credential to login text is displayed
    expect(find.text('Enter your credential to login'), findsOneWidget);

    // Verify that Username TextField is displayed
    expect(find.byType(TextField), findsNWidgets(2)); // Kullanıcı adı ve şifre alanları

    // Verify that Login Button is displayed
    expect(find.text('Login'), findsOneWidget);

    // Verify that Forgot password? text is displayed
    expect(find.text('Forgot password?'), findsOneWidget);

    // Verify that Don't have an account? text is displayed
    expect(find.text("Don't have an account?"), findsOneWidget);

    // Verify that Sign Up Button is displayed
    expect(find.text('Sign Up'), findsOneWidget);
  });
}
