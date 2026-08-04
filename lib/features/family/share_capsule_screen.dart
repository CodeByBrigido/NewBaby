import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/l10n/copy.dart';
import '../../core/theme/app_palette.dart';
import '../../core/utils/formatters.dart';
import '../../models/baby_profile.dart';
import '../../models/family_access.dart';
import '../../services/firestore_service.dart';
import '../../state/providers.dart';
import '../common/widgets.dart';

/// Quem mais pode ver a cápsula.
///
/// Duas coisas acontecem quando um convite é criado, e as duas precisam
/// acontecer: a pasta do Drive é aberta para aquele email, e o convite é
/// gravado no Firestore. A primeira é o que deixa a avó ver as fotos; a
/// segunda é o que faz o aplicativo dela saber qual cápsula abrir. Nenhuma
/// das duas sozinha resolve.
///
/// A ordem importa. O Drive vem primeiro: se ele falhar, nada foi prometido
/// a ninguém. Se o Firestore falhasse depois de o Drive ter dado certo, o
/// pior seria uma permissão de leitura numa pasta que a pessoa não sabe que
/// existe - e o botão de tirar acesso continua ali.
class ShareCapsuleScreen extends ConsumerStatefulWidget {
  const ShareCapsuleScreen({super.key});

  @override
  ConsumerState<ShareCapsuleScreen> createState() => _ShareCapsuleScreenState();
}

class _ShareCapsuleScreenState extends ConsumerState<ShareCapsuleScreen> {
  @override
  Widget build(BuildContext context) {
    final BabyProfile? profile = ref.watch(profileProvider).value;
    final Copy copy = Copy.of(profile);
    final List<FamilyMember> membros =
        ref.watch(familyMembersProvider).value ?? const <FamilyMember>[];
    final List<FamilyInvite> convites =
        ref.watch(myInvitesProvider).value ?? const <FamilyInvite>[];
    final List<FamilyInvite> pendentes = convites
        .where((FamilyInvite c) => c.usableAt(DateTime.now()))
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Quem mais pode ver')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
        children: <Widget>[
          Text(
            copy.hasName
                ? 'Convide quem faz parte da vida ${copy.ofName}. Quem entra '
                      'acompanha as fotos e os vídeos, e não pode apagar nem '
                      'mudar nada.'
                : 'Convide quem faz parte da vida da criança. Quem entra '
                      'acompanha as fotos e os vídeos, e não pode apagar nem '
                      'mudar nada.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: context.cores.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          const InfoNote(
            message:
                'As cartas e o que está guardado para o futuro continuam só '
                'seus. Ninguém convidado vê nada disso.',
          ),

          if (membros.isNotEmpty) ...<Widget>[
            const SizedBox(height: 24),
            const SectionHeader(title: 'Com acesso'),
            for (final FamilyMember m in membros)
              _LinhaAcesso(
                titulo: m.link?.email ?? 'Alguém da família',
                detalhe: m.link == null
                    ? null
                    : 'Desde ${Fmt.date(m.link!.createdAt)}',
                acao: 'Tirar acesso',
                onAcao: () => _tirarAcesso(m),
              ),
          ],

          if (pendentes.isNotEmpty) ...<Widget>[
            const SizedBox(height: 24),
            const SectionHeader(title: 'Convites esperando'),
            for (final FamilyInvite c in pendentes)
              _LinhaAcesso(
                titulo: c.name.isEmpty ? c.email : '${c.name} (${c.email})',
                detalhe:
                    'Código ${c.code}, vale até '
                    '${Fmt.date(c.expiresAt)}',
                acao: 'Enviar de novo',
                onAcao: () => _compartilharCodigo(c),
                onLongPress: () => _cancelar(c),
              ),
          ],

          const SizedBox(height: 28),
          FilledButton.icon(
            onPressed: () => _novoConvite(context),
            icon: const Icon(Icons.person_add_alt),
            label: const Text('Convidar alguém'),
          ),
        ],
      ),
    );
  }

  Future<void> _novoConvite(BuildContext context) async {
    final _DadosConvite? dados = await showModalBottomSheet<_DadosConvite>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _FormularioConvite(),
    );
    if (dados == null || !mounted) return;

    final String? uid = ref.read(uidProvider);
    final BabyProfile? profile = ref.read(profileProvider).value;
    final String? pastaRaiz = profile?.rootFolderId;
    if (uid == null || pastaRaiz == null || pastaRaiz.isEmpty) {
      _avisar(
        'Ainda não deu para achar a pasta da cápsula no Drive. Abra o '
        'aplicativo com internet uma vez e tente de novo.',
      );
      return;
    }

    final FamilyInvite convite = FamilyInvite(
      code: generateInviteCode(),
      ownerUid: uid,
      folderId: pastaRaiz,
      email: dados.email,
      name: dados.nome,
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(inviteLifetime),
      status: InviteStatus.pending,
    );

    try {
      await ref
          .read(driveServiceProvider)
          .shareFolderWith(folderId: pastaRaiz, email: convite.email);
      await ref.read(firestoreServiceProvider).createInvite(convite);
    } on Exception {
      _avisar(
        'Não deu para criar o convite agora. Verifique a internet e tente '
        'de novo.',
      );
      return;
    }

    if (!mounted) return;
    await _compartilharCodigo(convite);
  }

  /// Entrega o código pelo caminho que a pessoa escolher.
  ///
  /// O aplicativo não manda email nem mensagem: quem convida entrega o
  /// código, pelo WhatsApp, por telefone, pessoalmente. Um convite que chega
  /// pela mão de quem se conhece é reconhecido; um email automático do
  /// Google, não.
  Future<void> _compartilharCodigo(FamilyInvite convite) async {
    final BabyProfile? profile = ref.read(profileProvider).value;
    final String nome = profile?.firstName ?? 'a nossa criança';
    await SharePlus.instance.share(
      ShareParams(
        text:
            'Te convidei para acompanhar as memórias de $nome no aplicativo '
            'Meu Bebê.\n\n'
            'Seu código: ${convite.code}\n\n'
            'Baixe o aplicativo, entre com o email ${convite.email} e digite '
            'esse código. Ele vale por sete dias.',
      ),
    );
  }

  Future<void> _cancelar(FamilyInvite convite) async {
    final bool ok = await _confirmar(
      titulo: 'Cancelar este convite?',
      texto:
          'O código ${convite.code} deixa de funcionar. Quem ainda não entrou '
          'vai precisar de um novo.',
    );
    if (!ok) return;
    await ref
        .read(firestoreServiceProvider)
        .setInviteStatus(convite.code, InviteStatus.revoked);
  }

  Future<void> _tirarAcesso(FamilyMember membro) async {
    final String email = membro.link?.email ?? '';
    final bool ok = await _confirmar(
      titulo: 'Tirar o acesso?',
      texto:
          '${email.isEmpty ? 'Essa pessoa' : email} deixa de ver a cápsula, '
          'agora. Nada do que você guardou é apagado.',
    );
    if (!ok) return;

    final String? pastaRaiz = ref.read(profileProvider).value?.rootFolderId;
    try {
      // O Firestore primeiro: é ele que fecha a cápsula. Se o Drive falhar
      // depois, sobra uma permissão de leitura numa pasta que o aplicativo
      // dela não abre mais, e este botão continua aqui para tentar de novo.
      await ref.read(firestoreServiceProvider).removeFamilyAccess(membro.uid);
      if (pastaRaiz != null && pastaRaiz.isNotEmpty && email.isNotEmpty) {
        await ref
            .read(driveServiceProvider)
            .unshareFolderWith(folderId: pastaRaiz, email: email);
      }
    } on Exception {
      _avisar(
        'O acesso foi tirado, mas a pasta do Drive não respondeu. '
        'Tente de novo daqui a pouco.',
      );
    }
  }

  Future<bool> _confirmar({
    required String titulo,
    required String texto,
  }) async {
    final bool? r = await showDialog<bool>(
      context: context,
      builder: (BuildContext c) => AlertDialog(
        title: Text(titulo),
        content: Text(texto),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(c).pop(false),
            child: const Text('Deixar como está'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(c).pop(true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
    return r ?? false;
  }

  void _avisar(String texto) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }
}

class _DadosConvite {
  const _DadosConvite({required this.nome, required this.email});
  final String nome;
  final String email;
}

class _FormularioConvite extends StatefulWidget {
  const _FormularioConvite();

  @override
  State<_FormularioConvite> createState() => _FormularioConviteState();
}

class _FormularioConviteState extends State<_FormularioConvite> {
  final TextEditingController _nome = TextEditingController();
  final TextEditingController _email = TextEditingController();
  String? _erro;

  @override
  void dispose() {
    _nome.dispose();
    _email.dispose();
    super.dispose();
  }

  void _enviar() {
    final String email = _email.text.trim().toLowerCase();
    // Conferência mínima, de propósito: o Google é quem valida o endereço de
    // verdade, e uma regra esperta demais recusa endereços legítimos.
    if (!email.contains('@') || !email.contains('.')) {
      setState(() => _erro = 'Confira o endereço de email.');
      return;
    }
    Navigator.of(
      context,
    ).pop(_DadosConvite(nome: _nome.text.trim(), email: email));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        20 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            'Convidar alguém',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nome,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Como você chama essa pessoa',
              hintText: 'Vó Maria',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.deny(RegExp(r'\s')),
            ],
            decoration: InputDecoration(
              labelText: 'Email da conta Google dela',
              errorText: _erro,
            ),
            onSubmitted: (_) => _enviar(),
          ),
          const SizedBox(height: 8),
          Text(
            'Precisa ser o email do Google que ela usa no celular: é por ele '
            'que o Drive libera as fotos.',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: context.cores.textSecondary),
          ),
          const SizedBox(height: 20),
          FilledButton(onPressed: _enviar, child: const Text('Gerar o código')),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _LinhaAcesso extends StatelessWidget {
  const _LinhaAcesso({
    required this.titulo,
    required this.acao,
    required this.onAcao,
    this.detalhe,
    this.onLongPress,
  });

  final String titulo;
  final String? detalhe;
  final String acao;
  final VoidCallback onAcao;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Material(
        color: context.cores.surfaceMuted,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onLongPress: onLongPress,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        titulo,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      if (detalhe != null) ...<Widget>[
                        const SizedBox(height: 3),
                        Text(
                          detalhe!,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: context.cores.textSecondary),
                        ),
                      ],
                    ],
                  ),
                ),
                TextButton(onPressed: onAcao, child: Text(acao)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
