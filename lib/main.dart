import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'firebase_options.dart';
import 'services/session_service.dart';
import 'state/providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
  ]);

  // Datas por extenso em português dependem destes dados.
  await initializeDateFormatting('pt_BR');

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Antes de qualquer consulta: se a última sessão pediu para descartar o
  // cache local do Firestore, este é o único momento em que dá para fazer
  // isso sem quebrar o cliente.
  await SessionService.clearPendingCache();

  final ProviderContainer container = ProviderContainer();
  // O login silencioso roda antes da primeira tela: quem já entrou não vê
  // a tela de login piscar.
  await container
      .read(authServiceProvider)
      .initialize(serverClientId: DefaultFirebaseOptions.serverClientId);

  runApp(
    UncontrolledProviderScope(container: container, child: const MeuBebeApp()),
  );
}
