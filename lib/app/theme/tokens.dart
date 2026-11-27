import 'package:flutter/material.dart';

/// Cores extraídas de `:root` e das regras do app web
/// (`ficha_rpg_completa.html`). A interface Flutter replica esses valores.
abstract final class AppColors {
  /// Fundo da página (`--bg-color`).
  static const bg = Color(0xFF121214);

  /// Fundo dos cards/seções (`--card-bg`).
  static const card = Color(0xFF1E1E24);

  /// Borda dos cards (`--card-border`).
  static const cardBorder = Color(0xFF2D2D38);

  /// Texto principal (`--text-color`).
  static const text = Color(0xFFF0F0F5);

  /// Texto secundário (`--text-muted`).
  static const textMuted = Color(0xFFA0A0B0);

  /// Cor primária (`--primary`, o azul Discord).
  static const primary = Color(0xFF7289DA);

  /// Vermelho de destaque (`--accent-red`).
  static const accentRed = Color(0xFF8B0000);

  /// Ciano de destaque (`--accent-cyan`).
  static const accentCyan = Color(0xFF008B8B);

  /// Fundo de inputs e caixas internas (`--input-bg`).
  static const inputBg = Color(0xFF16161A);

  /// Borda de inputs (`--input-border`).
  static const inputBorder = Color(0xFF3F3F52);

  /// Botão de perigo (`.btn-danger`).
  static const danger = Color(0xFFA83232);

  /// Hover do botão de excluir card.
  static const dangerHover = Color(0xFFFF4D4D);

  /// Gradiente inicial da barra de vida.
  static const lifeFillStart = Color(0xFF500000);

  /// Gradiente inicial da barra de sanidade.
  static const sanityFillStart = Color(0xFF004D4D);

  /// Status positivo ("Salvo...", vitória na crise).
  static const good = Color(0xFF4EFFB0);

  /// Status pendente ("Salvando...").
  static const pending = Color(0xFFFFD700);

  /// Vermelho de erros e avisos fortes.
  static const error = Color(0xFFFF4D4D);

  /// Vermelho suave dos avisos de ferimentos.
  static const warnText = Color(0xFFFF9999);

  /// Amarelo dos avisos de pré-requisito.
  static const infoYellow = Color(0xFFE4B85C);

  /// Borda interna das linhas (`.pericia-row`, caixas de ataque).
  static const rowBorder = Color(0xFF23232F);

  /// Fundo dos botões da trilha não selecionados.
  static const trilhaOff = Color(0xFF252530);

  /// Hover de links/itens (`#282836`).
  static const hover = Color(0xFF282836);

  /// Hover dos cards de item (`.card-item:hover`).
  static const cardHover = Color(0xFF1C1C24);

  /// Fundo dos badges de perícia.
  static const badgeBg = Color(0xFF2A2A38);

  /// Fundo dos chips de detalhes das habilidades.
  static const detailBg = Color(0xFF24242D);

  /// Fundo dos segmentos de Ímpeto.
  static const impetoBg = Color(0xFF28282F);

  /// Borda dos segmentos de Ímpeto.
  static const impetoBorder = Color(0xFF4A4A54);

  /// Segmento de Ímpeto ativo.
  static const impetoActive = Color(0xFFA83232);

  /// Borda do segmento de Ímpeto ativo.
  static const impetoActiveBorder = Color(0xFFFF5757);

  /// Verde do botão "Vitória" da crise paranormal.
  static const victory = Color(0xFF2B7A4B);

  /// Dourado de destaques (bônus de afinidade alinhado).
  static const gold = Color(0xFFFFD700);

  /// Caixas de leitura (readonly) do bloco de deslocamento.
  static const readOnlyBox = Color(0xFF111111);
}

/// Raios de canto usados no web (4/6/8/12 px).
abstract final class AppRadii {
  /// Inputs e botões.
  static const input = 4.0;

  /// Caixas internas (atributo, ataque, itens).
  static const box = 6.0;

  /// Cards de seção e modais.
  static const card = 8.0;

  /// Dashboard e card de autenticação.
  static const dashboard = 12.0;

  /// Sombra dos cards de seção (0 4px 10px rgba(0,0,0,.4)).
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: const Color(0x66000000).withAlpha(102),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ];

  /// Sombra do dashboard (0 12px 40px rgba(0,0,0,.35)).
  static List<BoxShadow> get dashboardShadow => const [
        BoxShadow(
          color: Color(0x59000000),
          blurRadius: 40,
          offset: Offset(0, 12),
        ),
      ];
}

/// Espaçamentos do web (page 20px, card 18px, gaps 20/15/12).
abstract final class AppSpacing {
  /// Padding do body.
  static const page = 20.0;

  /// Padding interno dos cards de seção.
  static const cardPadding = 18.0;

  /// Gap entre cards de seção.
  static const sectionGap = 20.0;

  /// Gap dos grids 2/3 colunas.
  static const grid = 15.0;

  /// Gap do grid de 5 colunas.
  static const grid5 = 12.0;
}

/// Tipografia base do web: família Segoe UI, corpo 16px.
abstract final class AppTypography {
  /// Família principal (`'Segoe UI', Tahoma, Geneva, Verdana, sans-serif`).
  static const fontFamily = 'Segoe UI';

  /// Fallbacks quando Segoe UI não existir (Linux).
  static const fontFamilyFallback = [
    'Tahoma',
    'Geneva',
    'Verdana',
    'DejaVu Sans',
    'Roboto',
    'Arial',
  ];
}
