import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_palette.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/age_calculator.dart';
import '../../models/baby_profile.dart';
import '../../models/entry.dart';
import '../../state/providers.dart';
import 'drive_image.dart';

/// Ícone, cor e rótulo de cada categoria - um só lugar para todos eles.
extension EntryTypeVisuals on EntryType {
  IconData get icon => switch (this) {
    EntryType.birth => Icons.child_care_outlined,
    EntryType.photo => Icons.photo_outlined,
    EntryType.video => Icons.videocam_outlined,
    EntryType.letter => Icons.mail_outline,
    EntryType.drawing => Icons.brush_outlined,
    EntryType.document => Icons.description_outlined,
    EntryType.growth => Icons.monitor_heart_outlined,
  };

  /// Recebe o contexto porque a cor de marca muda conforme a criança, e
  /// uma extensão sobre um enum não tem de onde tirar isso sozinha.
  Color accent(BuildContext context) => switch (this) {
    EntryType.birth => context.cores.primary,
    EntryType.photo => context.cores.photo,
    EntryType.video => context.cores.video,
    EntryType.letter => context.cores.letter,
    EntryType.drawing => context.cores.drawing,
    EntryType.document => context.cores.document,
    EntryType.growth => context.cores.growth,
  };

  Color soft(BuildContext context) => switch (this) {
    EntryType.birth => context.cores.primarySoft,
    EntryType.photo => context.cores.photoSoft,
    EntryType.video => context.cores.videoSoft,
    EntryType.letter => context.cores.letterSoft,
    EntryType.drawing => context.cores.drawingSoft,
    EntryType.document => context.cores.documentSoft,
    EntryType.growth => context.cores.growthSoft,
  };

  /// No singular, já com o artigo de "último", porque em português a
  /// concordância muda com a palavra: última foto, último vídeo.
  String get lastLabel => switch (this) {
    EntryType.birth => 'Último nascimento',
    EntryType.photo => 'Última foto',
    EntryType.video => 'Último vídeo',
    EntryType.letter => 'Última carta',
    EntryType.drawing => 'Último desenho',
    EntryType.document => 'Último documento',
    EntryType.growth => 'Última medição',
  };

  /// No singular, para frases como "nenhuma foto ainda".
  String get singular => switch (this) {
    EntryType.birth => 'nascimento',
    EntryType.photo => 'foto',
    EntryType.video => 'vídeo',
    EntryType.letter => 'carta',
    EntryType.drawing => 'desenho',
    EntryType.document => 'documento',
    EntryType.growth => 'medição',
  };

  String get label => switch (this) {
    EntryType.birth => 'Nascimento',
    EntryType.photo => 'Fotos',
    EntryType.video => 'Vídeos',
    EntryType.letter => 'Cartas',
    EntryType.drawing => 'Desenhos',
    EntryType.document => 'Documentos',
    EntryType.growth => 'Crescimento',
  };
}

/// Ícone quadrado com o fundo pastel da categoria.
class CategoryBadge extends StatelessWidget {
  const CategoryBadge({
    required this.type,
    super.key,
    this.size = 44,
    this.iconSize = 22,
  });

  final EntryType type;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: type.soft(context),
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      child: Icon(type.icon, size: iconSize, color: type.accent(context)),
    );
  }
}

/// Foto de perfil da criança, com as iniciais como reserva.
class BabyAvatar extends ConsumerWidget {
  const BabyAvatar({
    required this.profile,
    super.key,
    this.radius = 24,
    this.photo,
  });

  final BabyProfile? profile;
  final double radius;
  final EntryFile? photo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String initials = _initials(profile?.name ?? '');
    // Sem foto explícita, o avatar acha a dele sozinho: assim nenhuma das
    // telas que o usam precisa saber de onde a foto vem.
    final EntryFile? file = photo ?? ref.watch(avatarPhotoProvider);

    return CircleAvatar(
      radius: radius,
      backgroundColor: context.cores.primarySoft,
      child: file == null
          ? Text(
              initials,
              style: TextStyle(
                fontSize: radius * 0.7,
                fontWeight: FontWeight.w600,
                color: context.cores.primaryDark,
              ),
            )
          : ClipOval(
              child: SizedBox(
                width: radius * 2,
                height: radius * 2,
                child: DriveThumbnail(file: file),
              ),
            ),
    );
  }

  static String _initials(String name) {
    final List<String> parts = name.trim().split(RegExp(r'\s+'))
      ..removeWhere((String p) => p.isEmpty);
    if (parts.isEmpty) return '♥';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts.last.characters.first)
        .toUpperCase();
  }
}

/// Etiqueta arredondada com a idade - `2 meses e 27 dias`.
class AgeChip extends StatelessWidget {
  const AgeChip({required this.age, super.key, this.compact = false});

  final Age age;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: context.cores.primarySoft,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        compact ? age.shortLabel : age.detailedLabel(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: context.cores.primaryDark,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Cartão branco padrão do aplicativo.
class SoftCard extends StatelessWidget {
  const SoftCard({
    required this.child,
    super.key,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.color,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color ?? context.cores.surface,
      borderRadius: BorderRadius.circular(kCardRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(kCardRadius),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// Estado vazio: um ícone discreto, um título e um convite.
class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.icon,
    required this.title,
    super.key,
    this.message,
    this.action,
  });

  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: context.cores.primarySoft,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: context.cores.primary),
            ),
            const SizedBox(height: 20),
            Text(title, style: text.titleMedium, textAlign: TextAlign.center),
            if (message != null) ...<Widget>[
              const SizedBox(height: 8),
              Text(
                message!,
                style: text.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...<Widget>[
              const SizedBox(height: 24),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Faixa informativa discreta, como o aviso de vídeo em 720p.
class InfoNote extends StatelessWidget {
  const InfoNote({
    required this.message,
    super.key,
    this.icon = Icons.info_outline,
  });

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: context.cores.surfaceMuted,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 18, color: context.cores.textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message, style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}

/// Cabeçalho de seção com um título e, opcionalmente, uma ação à direita.
class SectionHeader extends StatelessWidget {
  const SectionHeader({required this.title, super.key, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(title, style: Theme.of(context).textTheme.titleSmall),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// Mostra uma mensagem curta na parte de baixo da tela.
void showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

/// Pergunta de sim ou não, com o botão destrutivo em vermelho.
Future<bool> confirm(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  bool destructive = true,
}) async {
  final bool? result = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: TextButton.styleFrom(
            foregroundColor: destructive
                ? AppPalette.danger
                : context.cores.primaryDark,
          ),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}
