package br.com.brigido.meu_bebe

import io.flutter.embedding.android.FlutterFragmentActivity

// FlutterFragmentActivity, e nao FlutterActivity, porque o BiometricPrompt do
// Android e um DialogFragment: sem uma FragmentActivity por baixo, a trava
// opcional nunca abriria a caixa da digital. E uma troca sem custo - a
// FlutterFragmentActivity se comporta igual para todo o resto.
class MainActivity : FlutterFragmentActivity()
