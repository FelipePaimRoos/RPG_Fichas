import 'dart:async';

import 'package:app_flutter/app/theme/tokens.dart';
import 'package:app_flutter/features/characters/domain/character.dart';
import 'package:app_flutter/features/characters/domain/rules/progression.dart';
import 'package:app_flutter/features/characters/presentation/viewmodels/sheet_view_model.dart';
import 'package:app_flutter/shared/domain/element.dart';
import 'package:app_flutter/shared/widgets/app_field.dart';
import 'package:app_flutter/shared/widgets/section_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 14. Trilha do Paranormal — NEX, botões de 5% a 99%, afinidade e crise.
class ParanormalSection extends ConsumerStatefulWidget {
  /// Cria a seção.
  const ParanormalSection({required this.characterId, super.key});

  /// Id da ficha aberta.
  final String characterId;

  @override
  ConsumerState<ParanormalSection> createState() => _ParanormalSectionState();
}

class _ParanormalSectionState extends ConsumerState<ParanormalSection> {
  String? _ultimoResultado;

  @override
  Widget build(BuildContext context) {
    final character = ref
        .watch(sheetProvider(widget.characterId))
        .requireValue;
    final vm = ref.read(sheetProvider(widget.characterId).notifier);

    const niveis = ProgressionRules.niveisParanormal;
    final indexAtual =
        niveis.indexOf(character.exposicaoParanormal).clamp(0, niveis.length - 1);
    final dadoAtual =
        ProgressionRules.dadoParanormalSeq[character.dadoParanormalIdx.clamp(
      0,
      ProgressionRules.dadoParanormalSeq.length - 1,
    )];
    final afinidadeAberta = niveis[indexAtual] >= 50;

    return SectionCard(
      title: 'Trilha do Paranormal',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ---------- Barra de porcentagem ----------
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text.rich(
                TextSpan(
                  text: 'Nível de Exposição Paranormal: ',
                  style: const TextStyle(
                    color: AppColors.accentCyan,
                    fontSize: 14.4,
                    fontWeight: FontWeight.w700,
                  ),
                  children: [
                    TextSpan(
                      text: '${niveis[indexAtual]}%',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
              const Text(
                'Progresso (5% a 99%)',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12.8),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.inputBg,
              border: Border.all(color: AppColors.cardBorder),
              borderRadius: BorderRadius.circular(AppRadii.box),
            ),
            child: Wrap(
              spacing: 4,
              runSpacing: 4,
              children: [
                for (var i = 0; i < niveis.length; i++)
                  _TrilhaButton(
                    label: '${niveis[i]}%',
                    active: i <= indexAtual,
                    onPressed: () => vm.setExposicao(i),
                  ),
              ],
            ),
          ),
          // ---------- Afinidade ----------
          if (afinidadeAberta) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.inputBg,
                border: Border.all(color: AppColors.cardBorder),
                borderRadius: BorderRadius.circular(AppRadii.box),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Afinidade Paranormal (≥ 50%)',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.2,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Desbloqueado!',
                        style: TextStyle(
                          color: AppColors.gold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: FieldLabel(
                          label: 'Escolha seu Elemento de Afinidade:',
                          child: AppDropdown(
                            value: character.afinidadeElemento,
                            items: const [
                              ('', '(Nenhuma / Padrão)'),
                              ('sangue', 'Sangue'),
                              ('morte', 'Morte'),
                              ('energia', 'Energia'),
                              ('conhecimento', 'Conhecimento'),
                            ],
                            onChanged: vm.setAfinidade,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: _AfinidadeDescription(
                          elemento: character.afinidadeElemento,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
          // ---------- Crise ----------
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.inputBg,
              border: Border.all(color: AppColors.cardBorder),
              borderRadius: BorderRadius.circular(AppRadii.box),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Rolagem contra o Paranormal (Em Crise)',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15.2,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Dado Atual:',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 13.6,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius:
                                BorderRadius.circular(AppRadii.input),
                          ),
                          child: Text(
                            dadoAtual,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13.6,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      'Histórico de Crises / Testes: ${character.crisesContador}',
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 13.6,
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.danger,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        minimumSize: const Size(0, 30),
                        textStyle: const TextStyle(fontSize: 12.8),
                      ),
                      onPressed: () {
                        _ultimoResultado = _derrotaTexto(character, dadoAtual);
                        unawaited(vm.registrarCrise(vitoria: false));
                      },
                      child: const Text('Derrota (+5% & Resetar d4)'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.victory,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        minimumSize: const Size(0, 30),
                        textStyle: const TextStyle(fontSize: 12.8),
                      ),
                      onPressed: () {
                        _ultimoResultado = _vitoriaTexto(character, dadoAtual);
                        unawaited(vm.registrarCrise(vitoria: true));
                      },
                      child: const Text('Vitória (+1 Passo no Dado)'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _CriseResultado(
                  resultado: _ultimoResultado,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _vitoriaTexto(Character character, String dadoAtual) {
    final novoIndex =
        (character.dadoParanormalIdx + 1).clamp(
      0,
      ProgressionRules.dadoParanormalSeq.length - 1,
    );
    final novoDado = ProgressionRules.dadoParanormalSeq[novoIndex];
    return 'Vitória no teste com $dadoAtual! O dado avançou para $novoDado.';
  }

  String _derrotaTexto(Character character, String dadoAtual) {
    final novaExposicao =
        (character.exposicaoParanormal + 5).clamp(5, 99);
    return 'Derrota contra o Paranormal com $dadoAtual. A exposição subiu '
        'para $novaExposicao% e o dado resetou para d4!';
  }
}

class _TrilhaButton extends StatelessWidget {
  const _TrilhaButton({
    required this.label,
    required this.active,
    required this.onPressed,
  });

  final String label;
  final bool active;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppRadii.input),
        child: Container(
          constraints: const BoxConstraints(minWidth: 45),
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
          decoration: BoxDecoration(
            color: active ? AppColors.accentCyan : AppColors.trilhaOff,
            border: Border.all(color: AppColors.cardBorder),
            borderRadius: BorderRadius.circular(AppRadii.input),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: active ? Colors.black : Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _AfinidadeDescription extends StatelessWidget {
  const _AfinidadeDescription({required this.elemento});

  final String elemento;

  @override
  Widget build(BuildContext context) {
    final element = normalizeElement(elemento);
    final texto = switch (element) {
      ElementId.sangue =>
        '<b>Afinidade com Sangue:</b> Sua sintonia é marcada pelo vermelho '
            'vivo da carne e da paixão visceral.',
      ElementId.morte =>
        '<b>Afinidade com Morte:</b> Sua sintonia é marcada pelo silêncio '
            'gélido e pelo cinza da entropia.',
      ElementId.energia =>
        '<b>Afinidade com Energia:</b> Sua sintonia vibra com o caos '
            'colorido e imprevisível das descargas paranormais.',
      ElementId.conhecimento =>
        '<b>Afinidade com Conhecimento:</b> Sua sintonia brilha com o '
            'fulgor dourado da verdade absoluta e ocultada.',
      null =>
        'Ao atingir 50% ou mais de exposição, você pode escolher uma '
            'afinidade elemental para sintonizar a sua ficha.',
    };
    // Remove as marcações <b> — Flutter Text não interpreta HTML.
    final plain = texto.replaceAll('<b>', '').replaceAll('</b>', '');
    return Text(
      plain,
      style: const TextStyle(
        color: AppColors.textMuted,
        fontSize: 12.8,
        height: 1.4,
      ),
    );
  }
}

class _CriseResultado extends StatelessWidget {
  const _CriseResultado({required this.resultado});

  final String? resultado;

  @override
  Widget build(BuildContext context) {
    if (resultado == null) {
      return const Text(
        'Nenhum teste realizado nesta crise.',
        style: TextStyle(
          color: AppColors.textMuted,
          fontSize: 13.6,
          fontStyle: FontStyle.italic,
        ),
      );
    }
    final vitoria = resultado!.startsWith('Vitória');
    return Text(
      resultado!,
      style: TextStyle(
        color: vitoria ? AppColors.good : AppColors.warnText,
        fontSize: 13.6,
        fontStyle: FontStyle.italic,
      ),
    );
  }
}
