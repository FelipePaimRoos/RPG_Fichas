/// Porta de arquivos — esconde a diferença entre plataformas
/// (file_selector no desktop; depois, file_picker/share_plus no mobile).
abstract interface class FileGateway {
  /// Pergunta ao usuário onde salvar e grava o conteúdo.
  /// Retorna o caminho gravado ou null quando cancelado.
  Future<String?> saveFile({
    required String fileName,
    required String content,
  });
}
