import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/strings.dart';
import '../../core/l10n/copy.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/tokens.dart';
import '../../core/utils/error_text.dart';
import '../../models/baby_profile.dart';
import '../../models/entry.dart';
import '../../state/providers.dart';
import '../common/drive_image.dart';
import '../common/widgets.dart';

/// Escolher a foto de perfil entre as memórias já guardadas.
///
/// Vem da cápsula, e não da galeria do celular, por um motivo de produto:
/// tudo o que representa a criança aqui já está no Drive dela. Subir uma
/// foto que existisse só como avatar criaria um arquivo sem lugar na linha
/// do tempo, órfão de data e de contexto, que ninguém encontraria de novo.
///
/// Quem quiser uma foto que ainda não está aqui acrescenta ela como memória
/// primeiro, que é a coisa que o aplicativo inteiro existe para fazer.
class EscolherFotoScreen extends ConsumerStatefulWidget {
  const EscolherFotoScreen({super.key});

  @override
  ConsumerState<EscolherFotoScreen> createState() => _EscolherFotoScreenState();
}

class _EscolherFotoScreenState extends ConsumerState<EscolherFotoScreen> {
  bool _salvando = false;

  Future<void> _escolher(BabyProfile profile, String? driveId) async {
    final String? uid = ref.read(uidProvider);
    if (uid == null || _salvando) return;

    setState(() => _salvando = true);
    try {
      await ref
          .read(firestoreServiceProvider)
          .saveProfile(uid, profile.copyWith(photoDriveId: driveId ?? ''));
      if (mounted) context.pop();
    } on Exception catch (e) {
      if (mounted) {
        setState(() => _salvando = false);
        showMessage(context, userMessage(e, context: 'Foto de perfil'));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final BabyProfile? profile = ref.watch(profileProvider).value;
    final List<Entry> todas =
        ref.watch(entriesProvider).value ?? const <Entry>[];

    // Só o que já terminou de subir: uma foto ainda na fila não tem id no
    // Drive, e escolher uma delas guardaria um endereço vazio.
    final List<EntryFile> fotos = <EntryFile>[
      for (final Entry e in todas)
        for (final EntryFile f in e.files)
          if (f.isImage && f.driveId.isNotEmpty) f,
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Foto de perfil'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _salvando
              ? null
              : () => context.canPop()
                    ? context.pop()
                    : context.go(Routes.profile),
        ),
        actions: <Widget>[
          if (profile?.photoDriveId?.isNotEmpty ?? false)
            TextButton(
              onPressed: _salvando ? null : () => _escolher(profile!, null),
              child: Text(S.automatic),
            ),
        ],
      ),
      body: profile == null
          ? const Center(child: CircularProgressIndicator())
          : fotos.isEmpty
          ? EmptyState(
              icon: Icons.photo_camera_outlined,
              title: 'Nenhuma foto ainda',
              message: S.profilePhotoEmptyOf(Copy.of(profile).ofName),
            )
          : GridView.builder(
              padding: const EdgeInsets.fromLTRB(
                Space.x16,
                Space.x16,
                Space.x16,
                Space.scrollEnd,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: Space.x8,
                crossAxisSpacing: Space.x8,
              ),
              itemCount: fotos.length,
              itemBuilder: (BuildContext context, int index) {
                final EntryFile f = fotos[index];
                final bool atual = f.driveId == profile.photoDriveId;
                return _Opcao(
                  file: f,
                  atual: atual,
                  onTap: _salvando ? null : () => _escolher(profile, f.driveId),
                );
              },
            ),
    );
  }
}

class _Opcao extends StatelessWidget {
  const _Opcao({required this.file, required this.atual, required this.onTap});

  final EntryFile file;
  final bool atual;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: Radii.fieldR,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          ClipRRect(
            borderRadius: Radii.fieldR,
            child: DriveThumbnail(file: file),
          ),
          if (atual)
            DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: Radii.fieldR,
                border: Border.all(color: context.cores.primary, width: 3),
              ),
              child: Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.all(Space.x4),
                  child: CircleAvatar(
                    radius: 11,
                    // Forte porque tem o tique branco em cima.
                    backgroundColor: context.cores.primaryStrong,
                    child: const Icon(
                      Icons.check,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
