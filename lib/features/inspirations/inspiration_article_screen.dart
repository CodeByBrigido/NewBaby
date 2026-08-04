import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_palette.dart';
import '../../core/utils/formatters.dart';
import '../../models/inspiration.dart';
import '../../state/providers.dart';
import '../shell/add_sheet.dart';

/// O texto longo de uma inspiração.
///
/// Sem imagem de capa, sem tempo de leitura, sem contador de nada: a página
/// é para ser lida em dois minutos e fechada. Se ela virar um lugar onde a
/// pessoa passa tempo, o aplicativo passou a competir pela atenção que era
/// para estar na criança.
class InspirationArticleScreen extends ConsumerStatefulWidget {
  const InspirationArticleScreen({required this.active, super.key});

  final ActiveInspiration active;

  @override
  ConsumerState<InspirationArticleScreen> createState() =>
      _InspirationArticleScreenState();
}

class _InspirationArticleScreenState
    extends ConsumerState<InspirationArticleScreen> {
  @override
  void initState() {
    super.initState();
    // Abrir já conta como lido: o selo de novidade existe para avisar que
    // chegou algo, não para cobrar leitura até o fim.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(readInspirationsProvider.notifier)
          .markRead(widget.active.inspiration.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final Inspiration i = widget.active.inspiration;
    final TextTheme text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(i.kind.label)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        children: <Widget>[
          if (widget.active.daysLeft case final int dias)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _Countdown(dias: dias, data: widget.active.deadline!),
            ),
          Text(i.title, style: text.headlineSmall),
          const SizedBox(height: 10),
          Text(
            i.summary,
            style: text.bodyLarge?.copyWith(
              color: context.cores.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 8),

          for (final InspirationSection s in i.sections) ...<Widget>[
            const SizedBox(height: 22),
            Text(s.title, style: text.titleSmall),
            if (s.body.isNotEmpty) ...<Widget>[
              const SizedBox(height: 8),
              Text(s.body, style: text.bodyMedium?.copyWith(height: 1.55)),
            ],
            if (s.bullets.isNotEmpty) const SizedBox(height: 10),
            for (final String item in s.bullets)
              Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.only(top: 8, right: 12),
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: context.cores.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        item,
                        style: text.bodyMedium?.copyWith(height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
      floatingActionButton: i.suggests == null
          ? null
          : FloatingActionButton.extended(
              onPressed: () => showAddSheet(context),
              icon: const Icon(Icons.add),
              label: const Text('Registrar'),
            ),
    );
  }
}

class _Countdown extends StatelessWidget {
  const _Countdown({required this.dias, required this.data});

  final int dias;
  final DateTime data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: context.cores.primarySoft,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.event, size: 16, color: context.cores.primaryDark),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              dias == 0
                  ? 'É hoje, ${Fmt.dayMonth(data)}'
                  : dias == 1
                  ? 'Amanhã, ${Fmt.dayMonth(data)}'
                  : 'Faltam $dias dias, ${Fmt.dayMonth(data)}',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: context.cores.primaryDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
