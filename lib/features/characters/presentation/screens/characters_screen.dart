import 'package:app_flutter/app/theme/tokens.dart';
import 'package:app_flutter/features/characters/domain/character_summary.dart';
import 'package:app_flutter/features/characters/presentation/viewmodels/characters_view_model.dart';
import 'package:app_flutter/features/characters/presentation/widgets/character_card.dart';
import 'package:app_flutter/shared/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Tela "Minhas fichas" — réplica do dashboard do web:
/// card central de 900px com criação e lista de fichas.
class CharactersScreen extends ConsumerStatefulWidget {
  /// Cria a tela.
  const CharactersScreen({super.key});

  @override
  ConsumerState<CharactersScreen> createState() => _CharactersScreenState();
}

class _CharactersScreenState extends ConsumerState<CharactersScreen> {
  final TextEditingController _nomeController = TextEditingController();
  String _mensagem = '';

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lista = ref.watch(charactersProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Center(
          child: Container(
            width: 900,
            margin: const EdgeInsets.symmetric(vertical: 30),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.card,
              border: Border.all(color: AppColors.cardBorder),
              borderRadius: BorderRadius.circular(AppRadii.dashboard),
              boxShadow: AppRadii.dashboardShadow,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Minhas fichas',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Armazenadas neste dispositivo',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'Fichas guardadas somente neste dispositivo. Exporte um '
                  'arquivo JSON para transferir ou criar uma cópia de '
                  'segurança.',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                // Formulário de nova ficha
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _nomeController,
                        maxLength: 120,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15.2,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Nome do novo personagem (opcional)',
                        ),
                        onSubmitted: (_) => _criarFicha(),
                      ),
                    ),
                    const SizedBox(width: 16),
                    AppButton(
                      label: 'Criar ficha',
                      onPressed: _criarFicha,
                    ),
                  ],
                ),
                // Mensagem de status (min-height 1.5em)
                Container(
                  height: 24,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _mensagem,
                    style: const TextStyle(
                      color: Color(0xFFFF9A9A),
                      fontSize: 16,
                    ),
                  ),
                ),
                // Lista
                lista.when(
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  error: (error, _) => Text(
                    'Não foi possível carregar suas fichas: $error',
                    style: const TextStyle(
                      color: Color(0xFFFF9A9A),
                      fontSize: 16,
                    ),
                  ),
                  data: (fichas) {
                    if (fichas.isEmpty) {
                      return const Text(
                        'Você ainda não tem fichas. Crie uma para começar.',
                        style: TextStyle(
                          color: Color(0xFFFF9A9A),
                          fontSize: 16,
                        ),
                      );
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (final ficha in fichas)
                          CharacterCard(
                            character: ficha,
                            onOpen: () => context.push('/ficha/${ficha.id}'),
                            onExport: () => _exportar(ficha),
                            onDelete: () => _excluir(ficha),
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _criarFicha() async {
    final vm = ref.read(charactersProvider.notifier);
    try {
      final id = await vm.createCharacter(_nomeController.text);
      _nomeController.clear();
      if (mounted) {
        await context.push('/ficha/$id');
      }
    } on Exception catch (error) {
      setState(() => _mensagem = '$error');
    }
  }

  Future<void> _exportar(CharacterSummary ficha) async {
    try {
      final caminho = await ref
          .read(charactersProvider.notifier)
          .exportCharacter(ficha.id);
      setState(() {
        _mensagem = caminho == null ? '' : 'Ficha "${ficha.displayName}" exportada.';
      });
    } on Exception catch (error) {
      setState(() => _mensagem = '$error');
    }
  }

  Future<void> _excluir(CharacterSummary ficha) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text('Excluir ficha'),
        content: Text(
          'Excluir a ficha "${ficha.displayName}"? Essa ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmado ?? false) {
      await ref.read(charactersProvider.notifier).deleteCharacter(ficha.id);
    }
  }
}
