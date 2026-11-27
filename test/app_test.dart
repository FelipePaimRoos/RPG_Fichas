

import 'package:app_flutter/app/app.dart';
import 'package:app_flutter/app/providers.dart';
import 'package:app_flutter/features/characters/domain/character.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'support/fakes/fake_character_repository.dart';

void main() {
  testWidgets('inicia no dashboard com o tema escuro', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          characterRepositoryProvider.overrideWithValue(
            FakeCharacterRepository([
              Character(id: 'a1', nome: 'Ana', nivel: 3, conceito: 'Detetive'),
            ]),
          ),
        ],
        child: const RpgFichasApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);
    // Dashboard "Minhas fichas" — mesma tela inicial do app web.
    expect(find.text('Minhas fichas'), findsOneWidget);
    expect(find.text('Armazenadas neste dispositivo'), findsOneWidget);
    expect(find.text('Criar ficha'), findsOneWidget);
    // Ficha do fake aparece na lista com as ações do web.
    expect(find.text('Ana'), findsOneWidget);
    expect(find.text('Acessar'), findsOneWidget);
    expect(find.text('Exportar'), findsOneWidget);
    expect(find.text('Excluir'), findsOneWidget);
  });
}
