/// Perfil de personagem do catálogo (`json/perfis.json`).
class Profile {
  /// Cria um perfil.
  const Profile({required this.nome, this.efeito = ''});

  /// Cria o perfil a partir do JSON do catálogo.
  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
        nome: (json['nome'] ?? '') as String,
        efeito: (json['efeito'] ?? '') as String,
      );

  /// Nome do perfil ("Analista", "Vigilante", "Executor"…).
  final String nome;

  /// Efeito/descrição da habilidade de perfil.
  final String efeito;
}
