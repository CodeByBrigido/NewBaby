import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/strings.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/tokens.dart';
import '../../services/auth_service.dart';
import '../../state/providers.dart';
import '../common/google_g.dart';
import '../common/widgets.dart';
import '../shell/splash_gate.dart';

/// Primeira tela: só uma decisão a tomar.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key, this.comContaNova = false});

  /// Veio da apresentação com "criar uma conta" escolhido.
  ///
  /// A conta não é criada aqui: quem cria é o Google, dentro da própria
  /// caixa de login. O que falta a quem escolheu esse caminho é saber onde
  /// tocar lá dentro, e é só isso que esta marca acrescenta.
  final bool comContaNova;

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _busy = false;

  Future<void> _signIn() async {
    setState(() => _busy = true);
    try {
      await ref.read(authServiceProvider).signIn();
      // A navegação é do roteador: assim que a sessão existe, ele decide
      // entre o cadastro e a linha do tempo.
    } on AuthFailure catch (e) {
      if (mounted) showMessage(context, e.message);
    } on Exception catch (_) {
      if (mounted) showMessage(context, S.signInError);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: const Color(0xFF2E2626),
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          const _Fotografia(),
          // O véu existe para o texto poder ser lido, e não por estilo. A
          // foto é clara (manta de tricô creme), e branco sobre creme não
          // chega perto do mínimo de contraste. Ele é fraco em cima, onde só
          // há imagem, e forte embaixo, onde ficam a marca, o botão e o
          // aviso.
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: <double>[0, 0.34, 0.58, 1],
                colors: <Color>[
                  Color(0x592A2320),
                  Color(0x662A2320),
                  Color(0xC22A2320),
                  Color(0xF52A2320),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Space.block),
              child: Column(
                children: <Widget>[
                  const Spacer(flex: 4),
                  ClipRRect(
                    borderRadius: Radii.tileR(84),
                    child: Image.asset(
                      iconeDaAbertura,
                      width: 84,
                      height: 84,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (BuildContext context, Object _, StackTrace? _) =>
                              const SizedBox(width: 84, height: 84),
                    ),
                  ),
                  const SizedBox(height: Space.block),
                  Text(
                    S.appName,
                    // O peso vem da escala, e não daqui. Quem escreve uma
                    // tela não escolhe peso de fonte: escolhe o degrau da
                    // escala que serve, e o Design System já decidiu o resto.
                    style: text.displaySmall?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: Space.x4),
                  // O nome completo em duas linhas: assim ele cabe sem
                  // encolher a marca, e diz o que o aplicativo é para quem
                  // está vendo pela primeira vez.
                  Text(
                    S.appSubtitle,
                    style: text.titleMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: Space.x12),
                  Text(
                    S.appTagline,
                    textAlign: TextAlign.center,
                    style: text.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.75),
                    ),
                  ),
                  const Spacer(flex: 2),
                  if (widget.comContaNova) ...<Widget>[
                    Container(
                      padding: const EdgeInsets.all(Space.x16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: Radii.fieldR,
                      ),
                      child: Text(
                        'Para criar a conta da cápsula: toque abaixo, e na '
                        'caixa do Google escolha "Adicionar outra conta" e '
                        'depois "Criar conta".',
                        textAlign: TextAlign.center,
                        style: text.bodySmall?.copyWith(color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: Space.x16),
                  ],
                  _GoogleButton(busy: _busy, onPressed: _signIn),
                  const SizedBox(height: Space.x24),
                  Text(
                    S.signInNote,
                    textAlign: TextAlign.center,
                    style: text.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: Space.x16),
                  // Os dois documentos abertos antes de entrar, e não
                  // escondidos atrás do login. O que o aplicativo faz com os
                  // dados de um filho, e como desfazer isso, é o que se lê
                  // antes de entregar a conta; depois já não informa decisão
                  // nenhuma.
                  const _LinksDosDocumentos(),
                  const SizedBox(height: Space.x32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Os dois documentos públicos, no rodapé da tela de entrada.
///
/// Discretos de propósito: eles não competem com a única decisão da tela,
/// mas estão à mão de quem quer lê-los antes de tomá-la. O contraste do
/// branco a 70% sobre o véu escuro passa o mínimo de texto pequeno.
class _LinksDosDocumentos extends StatelessWidget {
  const _LinksDosDocumentos();

  @override
  Widget build(BuildContext context) {
    final TextStyle? estilo = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: Colors.white.withValues(alpha: 0.7),
      decoration: TextDecoration.underline,
      decorationColor: Colors.white.withValues(alpha: 0.4),
    );

    // Wrap, e não Row: em aparelho estreito ou com o texto do sistema
    // aumentado, os dois descem um sob o outro em vez de espremer as
    // palavras. E os rótulos são curtos para que, no caso comum, caibam
    // lado a lado.
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        _Link(rotulo: S.privacyPolicy, estilo: estilo, destino: Routes.privacy),
        Text('·', style: estilo?.copyWith(decoration: TextDecoration.none)),
        // Termos de uso, e não a exclusão de conta.
        //
        // Quem está nesta tela ainda não tem conta, e um atalho para apagá-la
        // ali é uma resposta para uma pergunta que ninguém fez. O que falta
        // antes de entrar é saber com o que se está concordando.
        //
        // A página de exclusão continua no ar e continua alcançável dentro do
        // aplicativo, pelo Perfil, que é onde alguém a procura de verdade.
        _Link(rotulo: S.termsOfUse, estilo: estilo, destino: Routes.terms),
      ],
    );
  }
}

class _Link extends StatelessWidget {
  const _Link({
    required this.rotulo,
    required this.estilo,
    required this.destino,
  });

  final String rotulo;
  final TextStyle? estilo;
  final String destino;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => context.push(destino),
      style: TextButton.styleFrom(
        // A área de toque continua a do botão; o que encolhe é a folga
        // lateral, para os dois caberem na mesma linha.
        padding: const EdgeInsets.symmetric(horizontal: Space.x8),
        minimumSize: const Size(0, 44),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(rotulo, textAlign: TextAlign.center, style: estilo),
    );
  }
}

class _GoogleButton extends StatelessWidget {
  const _GoogleButton({required this.busy, required this.onPressed});

  final bool busy;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton(
        onPressed: busy ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: context.cores.textPrimary,
          disabledBackgroundColor: Colors.white70,
          shape: RoundedRectangleBorder(borderRadius: Radii.pillR),
        ),
        child: busy
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.4),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const GoogleG(size: 22),
                  const SizedBox(width: Space.x12),
                  Text(
                    S.signInWithGoogle,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ],
              ),
      ),
    );
  }
}

/// A fotografia de fundo da tela de entrada.
///
/// Ela ocupa a tela inteira e é cortada, e não deformada: `cover` mantém a
/// proporção da foto em qualquer aparelho, do telefone estreito ao tablet.
///
/// A decodificação é limitada ao tamanho da tela. O arquivo tem quase dois
/// mil pixels de altura; sem limite, o aplicativo guardaria na memória o
/// quadro inteiro descomprimido para desenhar um terço dele.
class _Fotografia extends StatelessWidget {
  const _Fotografia();

  static const String caminho = 'assets/images/onboarding/Login-Baby.webp';

  @override
  Widget build(BuildContext context) {
    final MediaQueryData tela = MediaQuery.of(context);

    return Image.asset(
      caminho,
      fit: BoxFit.cover,
      cacheHeight: (tela.size.height * tela.devicePixelRatio).round(),
      // Sem a foto a tela continua de pé: o véu escuro sozinho já dá o
      // contraste de que o texto precisa. Uma imagem que falta não pode
      // impedir alguém de entrar na própria conta.
      errorBuilder: (BuildContext context, Object _, StackTrace? _) =>
          const ColoredBox(color: Color(0xFF2A2320)),
    );
  }
}
