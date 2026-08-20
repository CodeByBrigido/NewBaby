import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/strings.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/tokens.dart';
import '../../core/utils/formatters.dart';
import '../../models/capsule_pulse.dart';
import '../../models/entry.dart';
import '../common/widgets.dart';

/// Há quanto tempo cada tipo de memória não recebe nada.
///
/// Não é cobrança, é despertador. Quem registra todo dia não precisa disto;
/// quem passou três meses sem escrever uma carta esqueceu que existia essa
/// possibilidade, e a linha do tempo não conta isso: ela mostra o que **há**,
/// e nunca o que faltou.
///
/// São só quatro tipos, e a escolha é deliberada. Documento e desenho não têm
/// periodicidade nenhuma: uma certidão se guarda uma vez na vida, e cobrar
/// desenho de um bebê de três meses seria pedir o impossível. Foto, vídeo,
/// carta e crescimento são os que se repetem, e portanto os únicos em que
/// "faz um tempo" quer dizer alguma coisa.
///
/// A ordem é fixa, e não pela demora. Uma lista que se reordena a cada
/// abertura obriga a reler tudo para achar a linha que interessa.
class FazUmTempo extends ConsumerWidget {
  const FazUmTempo({required this.pulse, super.key});

  final CapsulePulse pulse;

  static const List<(EntryType, String)> _tipos = <(EntryType, String)>[
    (EntryType.photo, Routes.photos),
    (EntryType.video, Routes.videos),
    (EntryType.letter, Routes.letters),
    (EntryType.growth, Routes.growth),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: context.cores.surface,
        borderRadius: Radii.cardR,
        boxShadow: Shadows.level1,
      ),
      padding: const EdgeInsets.fromLTRB(
        Space.x16,
        Space.x16,
        Space.x8,
        Space.x8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Sobrancelha(S.beenAWhile),
          const SizedBox(height: Space.x4),
          for (final (EntryType tipo, String rota) in _tipos)
            _Linha(
              tipo: tipo,
              quando: pulse.lastByType[tipo],
              hoje: pulse.today,
              ultima: tipo == _tipos.last.$1,
              onTap: () => context.push(rota),
            ),
        ],
      ),
    );
  }
}

class _Linha extends StatelessWidget {
  const _Linha({
    required this.tipo,
    required this.quando,
    required this.hoje,
    required this.ultima,
    required this.onTap,
  });

  final EntryType tipo;

  /// Quando foi o último registro deste tipo, ou `null` se nunca houve.
  final DateTime? quando;

  final DateTime hoje;
  final bool ultima;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    // "Ainda não", e não "nunca". As duas dizem a mesma coisa sobre o
    // passado, e coisas opostas sobre o futuro: uma fecha a porta e a outra
    // é um convite, que é o que esta lista existe para ser.
    final String tempo = quando == null
        ? S.notYet
        : Fmt.tempoDesde(quando!, agora: hoje);

    return InkWell(
      onTap: onTap,
      borderRadius: Radii.fieldR,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Space.x8,
          vertical: Space.x12,
        ),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: tipo.soft(context),
                    borderRadius: Radii.fieldR,
                  ),
                  child: Icon(tipo.icon, size: 20, color: tipo.accent(context)),
                ),
                const SizedBox(width: Space.x12),
                Expanded(
                  child: Text(
                    tipo.label,
                    style: text.bodyMedium?.copyWith(
                      color: context.cores.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  tempo,
                  style: text.bodySmall?.copyWith(
                    color: context.cores.textSecondary,
                  ),
                ),
                const SizedBox(width: Space.x8),
                Icon(Icons.chevron_right, size: 20, color: context.cores.muted),
              ],
            ),
            // A divisória separa as linhas sem fechar a última, que já tem a
            // borda do cartão fazendo esse papel.
            if (!ultima) ...<Widget>[
              const SizedBox(height: Space.x12),
              Divider(height: 1, color: context.cores.divider),
            ],
          ],
        ),
      ),
    );
  }
}
