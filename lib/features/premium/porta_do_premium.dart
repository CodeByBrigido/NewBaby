/// O portão do plano Premium.
///
/// **A licença é da conta que faz login**, e mora em `BabyProfile.premium`.
/// Três filhos que entram no mesmo celular são três contas, e cada uma
/// responde por si; nada aqui pergunta ao aparelho nem à conta da Play Store,
/// que é de outra pessoa.
///
/// O portão trata só de **criar**. Ler a cápsula inteira, percorrer a linha do
/// tempo, abrir uma carta escrita há dois anos e mandar foto e vídeo continua
/// livre em qualquer conta, para sempre. Quem pagou um ano e parou não perde o
/// que guardou: seria quebrar a promessa da cápsula, e as cartas estão em
/// `.txt` no Drive da própria criança de qualquer forma.
library;

import 'package:flutter/material.dart';

import '../../core/l10n/strings.dart';
import '../../core/l10n/copy.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/tokens.dart';
import '../../models/baby_profile.dart';
import '../../models/entry.dart';

/// Se criar este tipo depende da licença.
///
/// Foto e vídeo ficam de fora de propósito: é o que qualquer galeria já faz de
/// graça, e cobrar por isso seria cobrar pelo que não é nosso. O que a licença
/// abre é o que só esta cápsula tem.
bool exigeLicenca(EntryType type) => switch (type) {
  EntryType.letter ||
  EntryType.drawing ||
  EntryType.document ||
  EntryType.growth => true,
  EntryType.photo || EntryType.video || EntryType.birth => false,
};

/// Se esta conta pode criar este tipo agora.
bool podeCriar(BabyProfile? profile, EntryType type) =>
    !exigeLicenca(type) || (profile?.premium ?? false);

/// O título do convite, na palavra do próprio tipo.
String tituloDoConvite(EntryType type) => switch (type) {
  EntryType.letter => S.premiumInviteLetters,
  EntryType.drawing => S.premiumInviteDrawings,
  EntryType.document => S.premiumInviteDocuments,
  EntryType.growth => S.premiumInviteGrowth,
  _ => S.premiumInviteGeneric,
};

/// O corpo do convite.
///
/// Diz as três coisas que a pessoa precisa saber antes de decidir: o que ela
/// ganha, quanto custa e quem cobra. E diz também o que ela **não** perde, que
/// é o que separa um convite de uma ameaça.
List<String> corpoDoConvite(EntryType type, Copy g) {
  final String deQuem = g.hasName ? ' ${g.ofName}' : '';
  return <String>[
    S.premiumInviteWhat(type.many, deQuem, osOutrosDoPlano(type)),
    S.premiumInvitePrice,
    S.premiumInviteKeeps,
  ];
}

/// Os outros itens do plano, sem repetir o que acabou de ser barrado.
///
/// A lista existe para mostrar que o plano é maior que o botão que a pessoa
/// tocou. Repetir ali o tipo que ela tentou usar faria a frase tropeçar
/// ("guardar cartas... junto com as cartas") e daria a impressão de texto
/// montado por máquina, que é exatamente o que ele é e o que não pode
/// parecer.
@visibleForTesting
String osOutrosDoPlano(EntryType type) {
  final List<String> outros = <String>[
    for (final EntryType t in <EntryType>[
      EntryType.letter,
      EntryType.drawing,
      EntryType.document,
      EntryType.growth,
    ])
      if (t != type) t == EntryType.growth ? S.theGrowth : S.comArtigo(t.many),
  ];
  return '${outros.take(outros.length - 1).join(', ')} e ${outros.last}';
}

/// Deixa passar, ou explica por que não.
///
/// Devolve `true` quando o caminho pode seguir. Quando não pode, abre o convite
/// e devolve `false`, e quem chamou só precisa parar.
///
/// Chame **antes** de abrir seletor de arquivo ou formulário. Bloquear no fim,
/// depois de a pessoa escolher as fotos e digitar o nome, seria pedir trabalho
/// para depois jogá-lo fora.
/// O perfil vem de quem chama, **já observado**, e não de um `ref.read` aqui
/// dentro.
///
/// Não é preciosismo. Um `read` num provedor que ninguém observa devolve
/// carregando, com valor nulo, e nulo aqui quer dizer "sem licença": quem
/// pagou levaria o convite na cara. Pior, o provedor do perfil se descarta
/// sozinho quando ninguém o escuta, então nem esperar pelo valor resolveria.
/// Toda tela que tem botão de criar já observa o perfil para escrever o nome
/// da criança, e o roteador não deixa nenhuma delas abrir antes de o perfil
/// carregar, então o valor certo está sempre na mão de quem chama.
Future<bool> liberadoParaCriar(
  BuildContext context,
  BabyProfile? profile,
  EntryType type,
) async {
  if (podeCriar(profile, type)) return true;

  await showDialog<void>(
    context: context,
    builder: (BuildContext _) =>
        ConvitePremium(type: type, copy: Copy.of(profile)),
  );
  return false;
}

/// O popup que explica o plano.
class ConvitePremium extends StatelessWidget {
  const ConvitePremium({required this.type, required this.copy, super.key});

  final EntryType type;
  final Copy copy;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return AlertDialog(
      icon: Icon(
        Icons.workspace_premium_outlined,
        size: 32,
        color: context.cores.primaryDark,
      ),
      title: Text(tituloDoConvite(type), textAlign: TextAlign.center),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          for (final String linha in corpoDoConvite(type, copy))
            Padding(
              padding: const EdgeInsets.only(bottom: Space.x12),
              child: Text(linha, style: text.bodyMedium),
            ),
        ],
      ),
      actionsPadding: const EdgeInsets.fromLTRB(
        Space.x24,
        Space.x8,
        Space.x24,
        Space.x20,
      ),
      // Um botão só, e ele fecha.
      //
      // Não existe botão de assinar aqui porque não existe assinatura ainda: o
      // faturamento é a segunda metade da fase, e só pode ser construído
      // depois de o pacote estar numa faixa da Play Store. Um botão que
      // levasse a uma tela de vitrine sem caixa seria pior que a ausência
      // dele. Quando o Google Play Billing entrar, é aqui que ele aparece.
      actions: <Widget>[
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(S.premiumInviteAction),
          ),
        ),
      ],
    );
  }
}
