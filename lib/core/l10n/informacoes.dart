import '../../models/baby_gender.dart';
import '../../models/baby_profile.dart';
import '../../models/entry.dart';
import '../utils/formatters.dart';

/// O `Informacoes.txt` que fica na pasta da cápsula, no Google Drive.
///
/// As fotos e os vídeos já sobrevivem sem o aplicativo: são arquivos numa
/// pasta. O cadastro e o crescimento não sobreviviam, porque só existiam no
/// índice. Este arquivo fecha esse buraco.
///
/// **O aplicativo nunca lê este arquivo.** O Firestore continua sendo a
/// fonte da verdade; aqui é representação legível, reescrita inteira a cada
/// mudança. Se ele fosse fonte de dado, cada leitura viraria uma chamada de
/// rede e um problema de sincronização, e o produto não ganharia nada.
///
/// A função é pura para poder ser testada sem Drive, sem Firestore e sem
/// aparelho: é texto entrando e texto saindo.
String informacoesDaCrianca({
  required BabyProfile profile,
  required List<Entry> growth,
  required DateTime now,
}) {
  final StringBuffer saida = StringBuffer()
    ..writeln('INFORMAÇÕES DA CRIANÇA')
    ..writeln()
    ..writeln('Nome: ${profile.name}');

  final String? sexo = _sexo(profile.gender);
  if (sexo != null) saida.writeln('Sexo: $sexo');

  saida.writeln('Nascimento: ${Fmt.date(profile.birth)}');

  // A hora só aparece quando foi informada. O cadastro guarda meia-noite
  // quando ninguém escolhe hora, então "00:00" aqui significaria "nasceu à
  // meia-noite" para quem ler daqui a vinte anos, e isso seria inventar um
  // dado. É uma ambiguidade que este formato resolve calando.
  if (profile.birth.hour != 0 || profile.birth.minute != 0) {
    saida.writeln('Hora: ${Fmt.time(profile.birth)}');
  }

  final int? peso = profile.birthWeightGrams;
  if (peso != null) saida.writeln('Peso ao nascer: ${Fmt.weight(peso)}');

  final double? altura = profile.birthHeightCm;
  if (altura != null) saida.writeln('Altura ao nascer: ${Fmt.height(altura)}');

  final String? hospital = profile.hospital?.trim();
  if (hospital != null && hospital.isNotEmpty) {
    saida.writeln('Hospital: $hospital');
  }

  final List<Entry> medicoes =
      growth.where((Entry e) => e.growth != null).toList()
        ..sort((Entry a, Entry b) => a.date.compareTo(b.date));

  saida
    ..writeln()
    ..writeln('REGISTROS DE CRESCIMENTO');

  if (medicoes.isEmpty) {
    // Dizer que não há nada é melhor que uma seção vazia: quem abre o
    // arquivo fica sabendo que o lugar existe e ainda não foi usado, em vez
    // de achar que o aplicativo escreveu errado.
    saida
      ..writeln()
      ..writeln('Nenhuma medição registrada até aqui.');
  }

  for (final Entry m in medicoes) {
    final GrowthData d = m.growth!;
    saida
      ..writeln()
      ..writeln('Data: ${Fmt.date(m.date)}')
      ..writeln('Idade: ${profile.ageAt(m.date).detailedLabel()}')
      ..writeln('Peso: ${Fmt.weight(d.weightGrams)}')
      ..writeln('Altura: ${Fmt.height(d.heightCm)}');
  }

  saida
    ..writeln()
    ..writeln('Última atualização: ${Fmt.date(now)} ${Fmt.time(now)}')
    ..writeln()
    ..writeln(
      'Arquivo gerado pelo aplicativo Meu Bebê: Cápsula do Tempo. '
      'Ele é uma cópia legível dos dados, para que este acervo continue '
      'fazendo sentido mesmo sem o aplicativo.',
    );

  return saida.toString();
}

/// O `.txt` de uma carta, na pasta da idade em que ela foi escrita.
///
/// Sem este arquivo, a carta é a única memória que morre junto com o
/// aplicativo: foto e vídeo já sobrevivem sozinhos, porque são arquivos numa
/// pasta. Aqui o texto ganha a mesma independência.
///
/// O cabeçalho existe porque um `.txt` solto daqui a vinte anos não diz para
/// quem foi escrito nem quando. Duas linhas resolvem, e elas ficam separadas
/// do corpo para que a carta em si continue sendo só a carta.
String textoDaCarta({required Entry carta, required BabyProfile profile}) {
  final StringBuffer saida = StringBuffer();

  final String? titulo = carta.title?.trim();
  if (titulo != null && titulo.isNotEmpty) saida.writeln(titulo);

  saida
    ..writeln('Escrita em ${Fmt.longDate(carta.date)}')
    ..writeln(
      'Quando ${profile.firstName} tinha '
      '${profile.ageAt(carta.date).detailedLabel()}',
    );

  final DateTime? lacre = carta.sealedUntil;
  if (lacre != null) {
    // Quem abrir a pasta vai poder ler a carta de qualquer jeito: o lacre é
    // do aplicativo, não do arquivo. Dizer isso é mais honesto que fingir
    // que o texto está protegido lá fora.
    saida.writeln(
      'Guardada no aplicativo para ser aberta em ${Fmt.date(lacre)}',
    );
  }

  final String corpo = carta.description?.trim() ?? '';
  saida
    ..writeln()
    ..writeln('-' * 40)
    ..writeln()
    ..writeln(corpo.isEmpty ? '(sem texto)' : corpo);

  return saida.toString();
}

String? _sexo(BabyGender? gender) => switch (gender) {
  BabyGender.girl => 'Menina',
  BabyGender.boy => 'Menino',
  null => null,
};
