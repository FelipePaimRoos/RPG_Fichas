/// Avisos de validação — avisos, nunca bloqueios (postura do web).
enum IssueSeverity { info, warning, error }

/// Um problema de validação da ficha.
class ValidationIssue {
  /// Cria o aviso.
  const ValidationIssue({
    required this.code,
    required this.severity,
    required this.message,
    this.field,
  });

  /// Código estável do aviso.
  final String code;

  /// Severidade.
  final IssueSeverity severity;

  /// Mensagem exibida ao usuário.
  final String message;

  /// Campo relacionado, quando aplicável.
  final String? field;
}
