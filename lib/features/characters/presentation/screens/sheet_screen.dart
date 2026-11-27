import 'dart:async';

import 'package:app_flutter/app/theme/tokens.dart';
import 'package:app_flutter/features/characters/presentation/sections/abilities/abilities_section.dart';
import 'package:app_flutter/features/characters/presentation/sections/advantages/advantages_section.dart';
import 'package:app_flutter/features/characters/presentation/sections/attributes/attributes_section.dart';
import 'package:app_flutter/features/characters/presentation/sections/combat/combat_section.dart';
import 'package:app_flutter/features/characters/presentation/sections/defense/defense_section.dart';
import 'package:app_flutter/features/characters/presentation/sections/description/description_section.dart';
import 'package:app_flutter/features/characters/presentation/sections/general/general_section.dart';
import 'package:app_flutter/features/characters/presentation/sections/inventory/inventory_section.dart';
import 'package:app_flutter/features/characters/presentation/sections/movement/movement_section.dart';
import 'package:app_flutter/features/characters/presentation/sections/paranormal/paranormal_section.dart';
import 'package:app_flutter/features/characters/presentation/sections/powers/powers_section.dart';
import 'package:app_flutter/features/characters/presentation/sections/resistances/resistances_section.dart';
import 'package:app_flutter/features/characters/presentation/sections/rituals/rituals_section.dart';
import 'package:app_flutter/features/characters/presentation/sections/skills/skills_section.dart';
import 'package:app_flutter/features/characters/presentation/sections/vitals/vitals_section.dart';
import 'package:app_flutter/features/characters/presentation/sections/wounds/wounds_section.dart';
import 'package:app_flutter/features/characters/presentation/viewmodels/autosave_controller.dart';
import 'package:app_flutter/features/characters/presentation/viewmodels/sheet_view_model.dart';
import 'package:app_flutter/features/characters/presentation/widgets/save_status.dart';
import 'package:app_flutter/features/characters/presentation/widgets/sheet_section_nav.dart';
import 'package:app_flutter/shared/domain/element.dart';
import 'package:app_flutter/shared/widgets/app_button.dart';
import 'package:app_flutter/shared/widgets/section_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Tela da ficha — réplica do modo edição do web: toolbar, coluna central
/// de seções (máx. 1200px) e sumário lateral flutuante.
class SheetScreen extends ConsumerStatefulWidget {
  /// Cria a tela para a ficha [characterId].
  const SheetScreen({required this.characterId, super.key});

  /// Id da ficha aberta.
  final String characterId;

  @override
  ConsumerState<SheetScreen> createState() => _SheetScreenState();
}

class _SheetScreenState extends ConsumerState<SheetScreen> {
  String _filtro = 'todos';
  final ScrollController _scroll = ScrollController();

  AppLifecycleListener? _lifecycleListener;

  @override
  void initState() {
    super.initState();
    // Flush do autosave quando o app vai para segundo plano (doc §7.1).
    _lifecycleListener = AppLifecycleListener(
      onHide: () {
        unawaited(
          ref.read(sheetProvider(widget.characterId).notifier).flush(),
        );
      },
    );
  }

  @override
  void dispose() {
    _lifecycleListener?.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _selecionarSecao(String id) {
    setState(() => _filtro = id);
    if (_scroll.hasClients) {
      _scroll.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final fichaAsync = ref.watch(sheetProvider(widget.characterId));
    final status = ref.watch(
      autosaveControllerProvider(widget.characterId),
    );

    return fichaAsync.when(
      loading: () => const Scaffold(
        backgroundColor: AppColors.bg,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      ),
      error: (error, _) => Scaffold(
        backgroundColor: AppColors.bg,
        body: Center(
          child: Text(
            'Ficha não encontrada: $error',
            style: const TextStyle(color: AppColors.error),
          ),
        ),
      ),
      data: (character) {
        // Afinidade recolore o tema, como `mudarAfinidadeTema` no web.
        final primary = normalizeElement(character.afinidadeElemento)
                ?.primaryColor ??
            AppColors.primary;
        final base = Theme.of(context);
        final themed = primary == AppColors.primary
            ? base
            : base.copyWith(
                colorScheme: base.colorScheme.copyWith(primary: primary),
                elevatedButtonTheme: ElevatedButtonThemeData(
                  style: base.elevatedButtonTheme.style!.copyWith(
                    backgroundColor: WidgetStateProperty.all(primary),
                  ),
                ),
              );

        return Theme(
          data: themed,
          child: Scaffold(
            backgroundColor: AppColors.bg,
            body: Stack(
              children: [
                // ---------- Coluna central ----------
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: Scrollbar(
                      controller: _scroll,
                      child: ListView(
                        controller: _scroll,
                        padding: const EdgeInsets.all(AppSpacing.page),
                        children: [
                          // Toolbar do editor
                          SectionCard(
                            child: Row(
                              children: [
                                const Spacer(),
                                Padding(
                                  padding:
                                      const EdgeInsets.only(right: 16),
                                  child: SaveStatusView(status: status),
                                ),
                                AppButton(
                                  label: 'Minhas fichas',
                                  onPressed: _voltarDashboard,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sectionGap),
                          _visivel(
                            'sec-geral',
                            GeneralSection(characterId: widget.characterId),
                          ),
                          _visivel(
                            'sec-atributos',
                            AttributesSection(
                              characterId: widget.characterId,
                            ),
                          ),
                          _visivel(
                            'sec-ferimentos',
                            WoundsSection(characterId: widget.characterId),
                          ),
                          _visivel(
                            'todos',
                            VitalsSection(characterId: widget.characterId),
                          ),
                          _visivel(
                            'sec-defesa-prot',
                            DefenseSection(characterId: widget.characterId),
                          ),
                          _visivel(
                            'sec-deslocamento',
                            MovementSection(
                              characterId: widget.characterId,
                            ),
                          ),
                          _visivel(
                            'sec-vantagens',
                            AdvantagesSection(
                              characterId: widget.characterId,
                            ),
                          ),
                          _visivel(
                            'sec-resistencias',
                            ResistancesSection(
                              characterId: widget.characterId,
                            ),
                          ),
                          _visivel(
                            'sec-pericias',
                            SkillsSection(characterId: widget.characterId),
                          ),
                          _visivel(
                            'sec-combate',
                            CombatSection(characterId: widget.characterId),
                          ),
                          _visivel(
                            'sec-habilidades',
                            AbilitiesSection(
                              characterId: widget.characterId,
                            ),
                          ),
                          _visivel(
                            'sec-rituais',
                            RitualsSection(characterId: widget.characterId),
                          ),
                          _visivel(
                            'sec-poderes',
                            PowersSection(characterId: widget.characterId),
                          ),
                          _visivel(
                            'sec-inventario',
                            InventorySection(
                              characterId: widget.characterId,
                            ),
                          ),
                          _visivel(
                            'sec-trilha',
                            ParanormalSection(
                              characterId: widget.characterId,
                            ),
                          ),
                          _visivel(
                            'sec-historico',
                            DescriptionSection(
                              characterId: widget.characterId,
                            ),
                          ),
                          // Espaço para o sumário não cobrir o fim.
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ),
                ),
                // ---------- Sumário lateral flutuante ----------
                Positioned(
                  top: 20,
                  left: 20,
                  child: SheetSectionNav(
                    activeId: _filtro,
                    onSelect: _selecionarSecao,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _visivel(String id, Widget child) {
    final visivel = _filtro == 'todos' || _filtro == id;
    if (!visivel) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sectionGap),
      child: child,
    );
  }

  Future<void> _voltarDashboard() async {
    await ref.read(sheetProvider(widget.characterId).notifier).flush();
    if (mounted) {
      context.go('/');
    }
  }
}
