import 'package:app_flutter/app/theme/tokens.dart';
import 'package:flutter/material.dart';

/// Item do sumário lateral.
typedef SectionNavItem = ({String id, String label});

/// Os itens do sumário, na ordem e rótulos do web.
const List<SectionNavItem> sectionNavItems = [
  (id: 'todos', label: '⭐ Ver Todos'),
  (id: 'sec-geral', label: '1. Informações Gerais'),
  (id: 'sec-atributos', label: '2. Atributos Base'),
  (id: 'sec-ferimentos', label: '3. Ferimentos Debilitantes'),
  (id: 'sec-defesa-prot', label: '4. Defesa e Proteções'),
  (id: 'sec-deslocamento', label: '5. Deslocamento'),
  (id: 'sec-vantagens', label: '6. Vantagens / Desv.'),
  (id: 'sec-resistencias', label: '7. Resistências / Prof.'),
  (id: 'sec-pericias', label: '8. Perícias'),
  (id: 'sec-combate', label: '9. Combate / Ataques'),
  (id: 'sec-habilidades', label: '10. Habilidades'),
  (id: 'sec-rituais', label: '11. Rituais'),
  (id: 'sec-poderes', label: '12. Poderes Paranormais'),
  (id: 'sec-inventario', label: '13. Inventário'),
  (id: 'sec-trilha', label: '14. Trilha & Afinidade'),
  (id: 'sec-historico', label: '15. Histórico & Descrição'),
];

/// Sumário lateral flutuante — réplica de `.sumario-lateral` do web:
/// bolinha de 48px que expande para 220px no hover ou ao clicar (fixado).
class SheetSectionNav extends StatefulWidget {
  /// Cria o sumário.
  const SheetSectionNav({
    required this.activeId,
    required this.onSelect,
    super.key,
  });

  /// Id da seção ativa ('todos' ou 'sec-...').
  final String activeId;

  /// Seleção de seção.
  final ValueChanged<String> onSelect;

  @override
  State<SheetSectionNav> createState() => _SheetSectionNavState();
}

class _SheetSectionNavState extends State<SheetSectionNav> {
  bool _hovering = false;
  bool _pinned = false;

  bool get _open => _hovering || _pinned;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        width: _open ? 220.0 : 48.0,
        height: _open ? null : 48.0,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height - 40,
        ),
        padding: EdgeInsets.all(_open ? 12 : 6),
        decoration: BoxDecoration(
          color: AppColors.card,
          border: Border.all(color: AppColors.cardBorder),
          borderRadius: BorderRadius.circular(_open ? AppRadii.card : 24),
          boxShadow: const [
            BoxShadow(
              color: Color(0x99000000),
              blurRadius: 15,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: _open ? _buildContent() : _buildToggle(),
      ),
    );
  }

  Widget _buildToggle() {
    return InkWell(
      onTap: () => setState(() => _pinned = true),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 34,
        height: 34,
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: AppColors.inputBg,
          border: Border.all(color: AppColors.inputBorder),
          shape: BoxShape.circle,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < 3; i++) ...[
              if (i > 0) const SizedBox(height: 4),
              Container(
                width: double.infinity,
                height: 2,
                decoration: BoxDecoration(
                  color: AppColors.text,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.only(bottom: 6),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: AppColors.cardBorder),
                  ),
                ),
                child: const Text(
                  'SUMÁRIO',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 15.2,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Flexible(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final item in sectionNavItems)
                  _NavLink(
                    item: item,
                    active: widget.activeId == item.id,
                    onSelect: () {
                      widget.onSelect(item.id);
                      setState(() => _pinned = false);
                    },
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _NavLink extends StatelessWidget {
  const _NavLink({
    required this.item,
    required this.active,
    required this.onSelect,
  });

  final SectionNavItem item;
  final bool active;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: onSelect,
        borderRadius: BorderRadius.circular(AppRadii.input),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: active ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadii.input),
          ),
          child: Text(
            item.label,
            style: TextStyle(
              color: active ? Colors.white : AppColors.textMuted,
              fontSize: 12.8,
              fontWeight: active ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}
