/// API pública da feature `characters`.
///
/// Outras features só podem importar `characters` por aqui.
library;

export 'domain/character.dart';
export 'domain/character_summary.dart';
export 'domain/derived_stats.dart';
export 'domain/repositories/character_repository.dart';
export 'domain/rules/attributes.dart';
export 'domain/rules/combat.dart';
export 'domain/rules/derived.dart';
export 'domain/rules/encumbrance.dart';
export 'domain/rules/progression.dart';
export 'domain/rules/skills.dart';
export 'domain/validation_issue.dart';
export 'presentation/viewmodels/characters_view_model.dart';
export 'presentation/viewmodels/sheet_view_model.dart';
