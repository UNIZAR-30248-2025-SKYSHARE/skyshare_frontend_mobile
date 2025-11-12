import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:skyshare_frontend_mobile/features/observation-chats/presentation/widgets/create_group_bottom_sheet.dart';
import 'package:skyshare_frontend_mobile/features/observation-chats/providers/observation_chats_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../../../../helpers/fake_localizations_delegate.dart';

class MockObservationChatsProvider extends Mock implements ObservationChatsProvider {}

void main() {
  late MockObservationChatsProvider mockProvider;

  Widget createTestWidget() {
    return ChangeNotifierProvider<ObservationChatsProvider>.value(
      value: mockProvider,
      child: MaterialApp(
        locale: const Locale('es'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: [
          FakeLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const Scaffold(
          body: CreateGroupBottomSheet(),
        ),
      ),
    );
  }

  Finder findTextFormFieldByHint(String hintKey) {
    final hintFinder = find.text(hintKey);
    return find.ancestor(of: hintFinder, matching: find.byType(TextFormField));
  }

  setUp(() => mockProvider = MockObservationChatsProvider());

  testWidgets('muestra error de validación si el nombre está vacío', (tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    await tester.tap(find.text('chat.create.button'));
    await tester.pumpAndSettle();

    expect(find.text('chat.create.name_required'), findsOneWidget);
    verifyNever(() => mockProvider.createGroup(any(), any()));
  });

  testWidgets('llama a provider.createGroup con los datos correctos al enviar', (tester) async {
    const groupName = 'Grupo de Test';
    const groupDesc = 'Descripción de Test';

    when(() => mockProvider.createGroup(groupName, groupDesc))
        .thenAnswer((_) async => true);

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    await tester.enterText(findTextFormFieldByHint('chat.create.name_hint'), groupName);
    await tester.enterText(findTextFormFieldByHint('chat.create.description_hint'), groupDesc);

    await tester.tap(find.text('chat.create.button'));
    await tester.pumpAndSettle();

    verify(() => mockProvider.createGroup(groupName, groupDesc)).called(1);
  });
}