import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:skyshare_frontend_mobile/features/observation-chats/presentation/widgets/create_group_bottom_sheet.dart';
import 'package:skyshare_frontend_mobile/features/observation-chats/providers/observation_chats_provider.dart';

class MockObservationChatsProvider extends Mock implements ObservationChatsProvider {}

void main() {
  late MockObservationChatsProvider mockProvider;

  Widget createTestWidget() {
    return ChangeNotifierProvider<ObservationChatsProvider>.value(
      value: mockProvider,
      child: const MaterialApp(
        home: Scaffold(
          body: CreateGroupBottomSheet(),
        ),
      ),
    );
  }

  Finder findTextFormFieldByHint(String hintText) {
    final hintFinder = find.text(hintText);
    return find.ancestor(
      of: hintFinder,
      matching: find.byType(TextFormField),
    );
  }
  
  setUp(() {
     mockProvider = MockObservationChatsProvider();
  });

  testWidgets('muestra error de validación si el nombre está vacío', (tester) async {
    await tester.pumpWidget(createTestWidget());
    
    await tester.tap(find.widgetWithText(ElevatedButton, 'Crear Grupo'));
    await tester.pumpAndSettle(); 

    expect(find.text('El nombre es obligatorio.'), findsOneWidget);
    verifyNever(() => mockProvider.createGroup(any(), any()));
  });

  testWidgets('llama a provider.createGroup con los datos correctos al enviar', (tester) async {
    const groupName = 'Grupo de Test';
    const groupDesc = 'Descripción de Test';
    
    when(() => mockProvider.createGroup(groupName, groupDesc))
        .thenAnswer((_) async => true);
        
    await tester.pumpWidget(createTestWidget());

    await tester.enterText(
      findTextFormFieldByHint('Nombre del grupo (ej: EINA)'),
      groupName,
    );
    
    await tester.enterText(
      findTextFormFieldByHint('Descripción (ej: Grupo de observación EUPT)'),
      groupDesc,
    );
    
    await tester.tap(find.widgetWithText(ElevatedButton, 'Crear Grupo'));
    await tester.pumpAndSettle();

    verify(() => mockProvider.createGroup(groupName, groupDesc)).called(1);
  });
}