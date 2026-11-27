import 'package:app_flutter/app/theme/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Rótulo acima do campo, como `<label>` do web: 0.85rem, cor muted,
/// espaçamento de 4px.
class FieldLabel extends StatelessWidget {
  /// Cria o rótulo com o campo abaixo.
  const FieldLabel({
    required this.label,
    required this.child,
    super.key,
    this.trailing,
  });

  /// Texto do rótulo.
  final String label;

  /// Campo.
  final Widget child;

  /// Widget à direita do rótulo (ex.: checkbox "Auto").
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                label,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13.6,
                ),
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 8),
              trailing!,
            ],
          ],
        ),
        const SizedBox(height: 4),
        child,
      ],
    );
  }
}

/// Campo de texto alinhado ao estilo do web (fundo #16161a, borda #3f3f52,
/// foco `--primary`, texto branco 0.95rem).
///
/// Sincroniza o valor externo com o controller sem brigar com a digitação
/// (atualiza o texto somente quando o campo não tem foco).
class BoundTextField extends StatefulWidget {
  /// Cria o campo.
  const BoundTextField({
    required this.value,
    required this.onChanged,
    super.key,
    this.hint,
    this.readOnly = false,
    this.numeric = false,
    this.style,
    this.textAlign = TextAlign.start,
    this.maxLines = 1,
    this.minLines = 1,
    this.expanded = false,
    this.fillColor,
    this.borderColor,
    this.padding,
    this.width,
  });

  /// Valor externo atual.
  final String value;

  /// Chamado a cada digitação.
  final ValueChanged<String> onChanged;

  /// Placeholder.
  final String? hint;

  /// Campo somente leitura.
  final bool readOnly;

  /// Aceita apenas números.
  final bool numeric;

  /// Estilo do texto (usado para os destaques de leitura).
  final TextStyle? style;

  /// Alinhamento do texto.
  final TextAlign textAlign;

  /// Número de linhas (textareas).
  final int maxLines;

  /// Linhas mínimas (textareas).
  final int minLines;

  /// Ocupa a largura disponível.
  final bool expanded;

  /// Cor de fundo alternativa (ex.: #111 nos readonly de deslocamento).
  final Color? fillColor;

  /// Cor de borda alternativa.
  final Color? borderColor;

  /// Padding interno alternativo.
  final EdgeInsetsGeometry? padding;

  /// Largura fixa opcional.
  final double? width;

  @override
  State<BoundTextField> createState() => _BoundTextFieldState();
}

class _BoundTextFieldState extends State<BoundTextField> {
  late final TextEditingController _controller;
  final FocusNode _focus = FocusNode();
  String _lastExternal = '';

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
    _lastExternal = widget.value;
  }

  @override
  void didUpdateWidget(BoundTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _lastExternal) {
      _lastExternal = widget.value;
      // Não roubar o cursor enquanto o usuário digita.
      if (!_focus.hasFocus) {
        _controller.text = widget.value;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final field = TextField(      controller: _controller,
      focusNode: _focus,
      readOnly: widget.readOnly,
      textAlign: widget.textAlign,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      keyboardType:
          widget.numeric ? TextInputType.number : null,
      inputFormatters: widget.numeric
          ? [FilteringTextInputFormatter.allow(RegExp('-?[0-9]'))]
          : null,
      style: widget.style ??
          const TextStyle(color: Colors.white, fontSize: 15.2),
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        hintText: widget.hint,
        fillColor: widget.fillColor,
        enabledBorder: widget.borderColor == null
            ? null
            : OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadii.input),
                borderSide: BorderSide(color: widget.borderColor!),
              ),
        focusedBorder: widget.borderColor == null
            ? null
            : OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadii.input),
                borderSide: BorderSide(color: widget.borderColor!),
              ),
        contentPadding: widget.padding,
      ),
    );
    final wrapped =
        widget.expanded ? SizedBox(width: double.infinity, child: field) : field;
    return widget.width == null
        ? wrapped
        : SizedBox(width: widget.width, child: field);
  }
}

/// Campo numérico inteiro: parse tolerante, texto branco.
class BoundNumberField extends StatelessWidget {
  /// Cria o campo numérico.
  const BoundNumberField({
    required this.value,
    required this.onChanged,
    super.key,
    this.width,
    this.readOnly = false,
    this.textAlign = TextAlign.start,
    this.fillColor,
    this.borderColor,
    this.style,
  });

  /// Valor externo atual.
  final int value;

  /// Chamado quando o número é válido.
  final ValueChanged<int> onChanged;

  /// Largura fixa opcional.
  final double? width;

  /// Somente leitura.
  final bool readOnly;

  /// Alinhamento.
  final TextAlign textAlign;

  /// Cor de fundo alternativa.
  final Color? fillColor;

  /// Cor de borda alternativa.
  final Color? borderColor;

  /// Estilo alternativo.
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final field = BoundTextField(
      value: '$value',
      readOnly: readOnly,
      numeric: true,
      textAlign: textAlign,
      fillColor: fillColor,
      borderColor: borderColor,
      style: style,
      onChanged: (text) {
        final parsed = int.tryParse(text);
        if (parsed != null) {
          onChanged(parsed);
        }
      },
    );
    return width == null ? field : SizedBox(width: width, child: field);
  }
}

/// Dropdown no estilo do web: caixa de input com seta.
class AppDropdown extends StatelessWidget {
  /// Cria o dropdown.
  const AppDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
    super.key,
    this.expanded = true,
  });

  /// Valor selecionado ('' = nenhum).
  final String value;

  /// Opções (valor, rótulo).
  final List<(String, String)> items;

  /// Seleção.
  final ValueChanged<String> onChanged;

  /// Ocupa a largura disponível.
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final dropdown = DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      dropdownColor: AppColors.card,
      icon: const Icon(Icons.expand_more, color: AppColors.textMuted, size: 18),
      style: const TextStyle(color: Colors.white, fontSize: 15.2),
      items: [
        for (final (v, label) in items)
          DropdownMenuItem<String>(value: v, child: Text(label)),
      ],
      onChanged: (selected) {
        if (selected != null) {
          onChanged(selected);
        }
      },
      decoration: InputDecoration(
        fillColor: AppColors.inputBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.input),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.input),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.input),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      ),
    );
    return expanded ? dropdown : SizedBox(width: 160, child: dropdown);
  }
}

/// Área de texto (textarea do web): mínimo 80px de altura.
class BoundTextArea extends StatelessWidget {
  /// Cria a área de texto.
  const BoundTextArea({
    required this.value,
    required this.onChanged,
    super.key,
    this.hint,
    this.expanded = true,
  });

  /// Valor externo atual.
  final String value;

  /// Chamado a cada digitação.
  final ValueChanged<String> onChanged;

  /// Placeholder.
  final String? hint;

  /// Ocupa a largura disponível.
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    return BoundTextField(
      value: value,
      onChanged: onChanged,
      hint: hint,
      maxLines: 5,
      minLines: 3,
      expanded: expanded,
    );
  }
}

/// Checkbox com rótulo à direita, no estilo do web.
class WebCheckbox extends StatelessWidget {
  /// Cria o checkbox rotulado.
  const WebCheckbox({
    required this.value,
    required this.onChanged,
    required this.label,
    super.key,
    this.labelStyle,
  });

  /// Estado.
  final bool value;

  /// Mudança.
  final ValueChanged<bool> onChanged;

  /// Rótulo.
  final String label;

  /// Estilo do rótulo.
  final TextStyle? labelStyle;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: Checkbox(
              value: value,
              onChanged: (checked) => onChanged(checked ?? false),
            ),
          ),
          const SizedBox(width: 6),
          Text(label, style: labelStyle),
        ],
      ),
    );
  }
}
