import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/copy.dart';
import '../../core/l10n/strings.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_palette.dart';
import '../../core/utils/age_calculator.dart';
import '../../models/entry.dart';
import '../../services/drive_service.dart';
import '../../state/providers.dart';
import '../common/widgets.dart';

/// As instruções de herança: como a cápsula chega a quem ela é.
///
/// A promessa do produto inteiro está em `Copy.aboutStorage`: "mesmo daqui a
/// muitos anos, sem este aplicativo, o acervo continua lá". Uma promessa
/// dessas não vale nada sem o passo a passo de como cumpri-la, e quem lê isto
/// hoje é a única pessoa capaz de deixar o caminho preparado.
///
/// Fica fora do `build` porque é o único texto do aplicativo que ninguém relê:
/// quem instala hoje só vai segui-lo daqui a vinte anos, quando não houver
/// mais a quem perguntar. Aqui ele é montado a partir dos mesmos nomes que o
/// código usa no Drive, e o teste confere o texto pronto, não a fonte.
abstract final class Heranca {
  static const String titulo = 'Entregar a cápsula um dia';

  static String comoEntregar(Copy g) =>
      'A cápsula inteira fica no Google Drive da sua conta. É de lá que ela '
      '${g.hasName ? "chega até ${g.theName}" : "vai ser entregue"} um dia: '
      'você passa essa conta adiante, ou move a pasta '
      '"${DriveService.rootFolderName}" para o Drive de quem vai recebê-la. '
      'Não é preciso pedir autorização a ninguém, nem que este aplicativo '
      'ainda exista.';

  /// Só os tipos que viram arquivo aparecem: mandar alguém procurar uma pasta
  /// "Cartas" que nunca foi criada é mandar procurar o nada, justamente no
  /// dia em que a pessoa mais precisa achar.
  static final String comoEstaOrganizado =
      'Dentro dessa pasta está tudo separado como você vê aqui: '
      '${EntryType.photo.folder}, ${EntryType.video.folder} e '
      '${EntryType.audio.folder}, cada um em pastas por idade '
      '(${_exemplo(AgeBucketUnit.week, 7)}, '
      '${_exemplo(AgeBucketUnit.month, 14)}, '
      '${_exemplo(AgeBucketUnit.year, 3)}), e o nome de cada arquivo começa '
      'pela data. Qualquer computador abre isso, hoje ou daqui a trinta anos.';

  static const String contasInativas =
      'O Google tem o Gerenciador de Contas Inativas, onde você indica '
      'pessoas de confiança para receber o conteúdo da conta se ela ficar '
      'muito tempo sem uso. Configurar isso uma vez é o que garante a entrega '
      'mesmo que ninguém saiba a senha.';

  /// A única parte do acervo que hoje não sobrevive ao fim deste aplicativo.
  /// Omitir isto deixaria a frase de cima maior do que ela é.
  static const String oQueAindaDepende =
      'Uma parte ainda depende do aplicativo: as cartas e as medidas de '
      'crescimento são texto, e ficam no índice em vez de virar arquivo no '
      'Drive. Levar tudo junto num pacote que se abre sozinho é a próxima '
      'coisa a ser construída aqui.';

  static String _exemplo(AgeBucketUnit unit, int index) => AgeBucket(
    unit: unit,
    index: index,
    start: DateTime(2000),
    end: DateTime(2000),
  ).folderName;
}

class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme text = Theme.of(context).textTheme;
    final Copy g = Copy.of(ref.watch(profileProvider).value);

    return Scaffold(
      appBar: AppBar(
        title: const Text(S.about),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go(Routes.timeline),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        children: <Widget>[
          Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: context.cores.primary,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.favorite_rounded,
                color: Colors.white,
                size: 34,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            S.appFullName,
            textAlign: TextAlign.center,
            style: text.titleLarge,
          ),
          const SizedBox(height: 6),
          Text(
            S.appTagline,
            textAlign: TextAlign.center,
            style: text.bodySmall,
          ),
          const SizedBox(height: 32),
          SoftCard(child: Text(g.aboutStorage)),
          const SizedBox(height: 20),
          const InfoNote(
            message:
                'Nenhuma foto passa por servidor nosso: elas vão direto do '
                'celular para o Google Drive.',
            icon: Icons.lock_outline,
          ),
          const SizedBox(height: 12),
          const InfoNote(
            message:
                'O aplicativo não enxerga o resto do seu Drive. A permissão '
                'que você concede dá acesso apenas aos arquivos que ele '
                'mesmo cria, todos dentro da pasta "Meu Bebê - Cápsula do '
                'Tempo". Suas outras pastas são invisíveis para ele.',
            icon: Icons.folder_off_outlined,
          ),
          const SizedBox(height: 12),
          // A frase acima é verdadeira e é fácil de ler como se valesse para
          // tudo. Vale para os arquivos - e só. O índice fica num servidor
          // nosso, e quem confia o registro de um filho a um aplicativo tem o
          // direito de saber disso sem precisar procurar.
          const InfoNote(
            message:
                'O que fica no nosso servidor é o índice: nome, data de '
                'nascimento, peso, altura, datas e o texto das cartas. É o '
                'que faz a linha do tempo e a busca funcionarem. Você pode '
                'apagar tudo isso a qualquer momento, no seu perfil.',
            icon: Icons.storage_outlined,
          ),

          const SizedBox(height: 32),
          const SectionHeader(title: Heranca.titulo),
          SoftCard(child: Text(Heranca.comoEntregar(g))),
          const SizedBox(height: 12),
          InfoNote(
            message: Heranca.comoEstaOrganizado,
            icon: Icons.folder_open_outlined,
          ),
          const SizedBox(height: 12),
          const InfoNote(
            message: Heranca.contasInativas,
            icon: Icons.key_outlined,
          ),
          const SizedBox(height: 12),
          const InfoNote(
            message: Heranca.oQueAindaDepende,
            icon: Icons.edit_note_outlined,
          ),

          const SizedBox(height: 32),
          const SectionHeader(title: 'Para a cápsula durar'),
          // O aviso que quase nenhum aplicativo dá, e que este precisa dar:
          // guardar vinte anos de memórias numa conta que pode ser apagada
          // por desuso é um risco real, e quem corre esse risco tem o direito
          // de saber por quem fez a promessa - não por um email genérico do
          // Google, dois anos depois.
          const SoftCard(
            child: Text(
              'O Google apaga contas que ficam dois anos sem uso, e junto vai '
              'o que estiver no Drive delas. Isso vale principalmente para '
              'quem criou uma conta só para a cápsula.\n\n'
              'Abrir este aplicativo de vez em quando já conta como uso, '
              'então não é preciso fazer nada além disso. Mesmo assim, se '
              'você passar quase um ano sem aparecer, o aplicativo avisa uma '
              'vez, e esse aviso pode ser desligado em Configurações.',
            ),
          ),
        ],
      ),
    );
  }
}
