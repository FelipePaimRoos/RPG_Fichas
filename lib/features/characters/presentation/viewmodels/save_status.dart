/// Estado do autosave, visível na barra do editor (doc §7.1).
enum SaveStatus { ocioso, salvando, salvo, erro }

/// Texto do status, na forma do web (`api_status_msg`).
extension SaveStatusLabel on SaveStatus {
  /// Texto exibido.
  String get label => switch (this) {
        SaveStatus.ocioso => '',
        SaveStatus.salvando => 'Salvando...',
        SaveStatus.salvo => 'Salvo neste dispositivo',
        SaveStatus.erro => 'Erro ao salvar!',
      };
}
