import 'dart:async';

/// Debounce simples usado pelo autosave (600 ms após a última edição).
class Debouncer {
  /// Cria um debouncer com o atraso informado.
  Debouncer({required this.delay});

  /// Atraso aplicado após a última chamada.
  final Duration delay;

  Timer? _timer;

  /// Agenda [action]; chamadas repetidas reiniciam o timer.
  void call(void Function() action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  /// Executa imediatamente o que está pendente e cancela o timer.
  void flush(void Function() action) {
    _timer?.cancel();
    _timer = null;
    action();
  }

  /// Descarta o que está pendente.
  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}
