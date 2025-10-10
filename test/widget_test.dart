import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:skyshare_frontend_mobile/main.dart';

void main() {
  testWidgets('App arranca y muestra cabecera de detección de ubicación', (WidgetTester tester) async {
    final supabase = SupabaseClient('https://example.com', 'anonKeyForTests');
    await tester.pumpWidget(MyApp(supabase: supabase));
    await tester.pumpAndSettle();
    expect(find.text('Detectando ubicación...'), findsOneWidget);
  });
}
