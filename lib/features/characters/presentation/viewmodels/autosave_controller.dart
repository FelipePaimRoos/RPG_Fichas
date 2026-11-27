import 'dart:async';

import 'package:app_flutter/app/providers.dart';
import 'package:app_flutter/features/characters/domain/character.dart';
import 'package:app_flutter/features/characters/presentation/viewmodels/save_status.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';

/// Provider do autosave — família por ficha aberta (doc §7.1).
final NotifierProviderFamily<AutosaveController, SaveStatus, String>
    autosaveControllerProvider = NotifierProvider.family<
        AutosaveController, SaveStatus, String>(AutosaveController.new);

/// Controlador de autosave por ficha aberta (debounce de 600 ms).
class AutosaveController extends Notifier<SaveStatus> {
  /// Cria o controlador para a ficha [characterId].
  AutosaveController(this.characterId);

  /// Identificador da ficha gerenciada.
  final String characterId;

  static const _debounce = Duration(milliseconds: 600);

  Timer? _timer;
  Character? _pending;

  @override
  SaveStatus build() => SaveStatus.ocioso;

  /// Agenda o salvamento da ficha após o debounce.
  void schedule(Character character) {
    _pending = character;
    _timer?.cancel();
    _timer = Timer(_debounce, () {
      unawaited(_save());
    });
  }

  /// Salva imediatamente o que estiver pendente.
  Future<void> flush() async {
    _timer?.cancel();
    _timer = null;
    if (_pending != null) {
      await _save();
    }
  }

  /// Descarta pendências (ficha fechada após salvar com sucesso).
  void clearPending() {
    _timer?.cancel();
    _timer = null;
    _pending = null;
  }

  Future<void> _save() async {
    final character = _pending;
    if (character == null) {
      return;
    }
    state = SaveStatus.salvando;
    try {
      await ref.read(characterRepositoryProvider).save(character);
      _pending = null;
      state = SaveStatus.salvo;
    } on Exception {
      state = SaveStatus.erro;
    }
  }
}
