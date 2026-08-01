import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/strings.dart';
import '../../core/theme/app_colors.dart';
import '../../services/auth_service.dart';
import '../../state/providers.dart';
import '../common/widgets.dart';

/// Primeira tela: só uma decisão a tomar.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

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
          // Sem foto de capa embutida, um degradê quente segura o clima do
          // mockup sem pesar o aplicativo com uma imagem de exemplo.
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  Color(0xFF6B5A52),
                  Color(0xFF3A2F2C),
                  Color(0xFF241D1B),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: <Widget>[
                  const Spacer(flex: 3),
                  Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.4),
                          blurRadius: 28,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.favorite_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    S.appName,
                    style: text.displaySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    S.appTagline,
                    textAlign: TextAlign.center,
                    style: text.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.75),
                    ),
                  ),
                  const Spacer(flex: 2),
                  _GoogleButton(busy: _busy, onPressed: _signIn),
                  const SizedBox(height: 24),
                  Text(
                    S.signInNote,
                    textAlign: TextAlign.center,
                    style: text.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
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
          foregroundColor: AppColors.textPrimary,
          disabledBackgroundColor: Colors.white70,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
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
                  const _GoogleMark(),
                  const SizedBox(width: 12),
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

/// O "G" do Google desenhado em quatro quadrantes - evita depender de um
/// arquivo de imagem só para o botão de login.
class _GoogleMark extends StatelessWidget {
  const _GoogleMark();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 22,
      height: 22,
      child: CustomPaint(painter: _GooglePainter()),
    );
  }
}

class _GooglePainter extends CustomPainter {
  static const Color _blue = Color(0xFF4285F4);
  static const Color _red = Color(0xFFEA4335);
  static const Color _yellow = Color(0xFFFBBC05);
  static const Color _green = Color(0xFF34A853);

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final double stroke = size.width * 0.22;
    final Rect inner = rect.deflate(stroke / 2);
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt;

    void arc(double startDeg, double sweepDeg, Color color) {
      paint.color = color;
      canvas.drawArc(
        inner,
        startDeg * 3.1415926535 / 180,
        sweepDeg * 3.1415926535 / 180,
        false,
        paint,
      );
    }

    arc(-20, -70, _red);
    arc(-90, -100, _yellow);
    arc(170, -80, _green);
    arc(-20, 70, _blue);

    // A barra horizontal que fecha o "G".
    canvas.drawRect(
      Rect.fromLTRB(
        size.width * 0.52,
        size.height * 0.40,
        size.width,
        size.height * 0.60,
      ),
      Paint()..color = _blue,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
