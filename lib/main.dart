import 'package:app_flutter/app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Título, tamanho inicial e mínimo da janela são definidos nativamente
  // nos runners (linux/runner, windows/runner). O window_manager entra
  // quando o flush ao fechar a janela for implementado (doc §8.6).
  runApp(const ProviderScope(child: RpgFichasApp()));
}
