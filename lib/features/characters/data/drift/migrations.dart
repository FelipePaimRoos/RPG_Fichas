/// Estratégia de migrações do banco (doc §10.1).
///
/// Na versão 1 o banco nasce completo. Mudanças futuras de tabela entram
/// em `onUpgrade` com passos numerados (`from < to`), nunca destrutivos —
/// o documento JSON em `data` migra pela cadeia de
/// `characterSchemaVersion`, separada do schema do banco.
library;
