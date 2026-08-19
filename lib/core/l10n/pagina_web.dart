/// As páginas públicas, em HTML, nas seis línguas do aplicativo.
///
/// O Google Play pede dois endereços que qualquer pessoa abra no navegador,
/// sem instalar nada e sem entrar em conta nenhuma: a política de
/// privacidade e a exclusão de conta. Este arquivo transforma o mesmo texto
/// que o aplicativo mostra nas páginas que vão para o ar.
///
/// Cada documento sai seis vezes: em português na raiz de `docs/`, e nas
/// outras cinco línguas em `docs/en/`, `docs/es/`, `docs/fr/`, `docs/de/`
/// e `docs/it/`. Quem revisa o aplicativo na loja raramente lê português, e
/// uma política que o revisor não lê é uma política que não cumpre a
/// exigência. As seis versões saem do mesmo texto que o aplicativo mostra,
/// então nenhuma delas pode envelhecer sozinha.
///
/// É Dart puro de propósito. Quem gera as páginas é uma ferramenta de linha
/// de comando (`tool/gerar_site.dart`), e ela roda em `dart run`, sem o
/// Flutter por perto: um único `import` de widget aqui derruba a geração.
///
/// Por isso as cores estão escritas à mão em vez de lidas de `AppPalette`.
/// Elas não ficam soltas: o `exclusao_test.dart` compara cada uma com o
/// valor real da paleta e quebra se as duas se separarem.
library;

import 'account_deletion.dart';
import 'account_deletion_de.dart';
import 'account_deletion_en.dart';
import 'account_deletion_es.dart';
import 'account_deletion_fr.dart';
import 'account_deletion_it.dart';
import 'privacy_policy.dart';
import 'privacy_policy_de.dart';
import 'privacy_policy_en.dart';
import 'privacy_policy_es.dart';
import 'privacy_policy_fr.dart';
import 'privacy_policy_it.dart';
import 'terms_of_use.dart';
import 'terms_of_use_de.dart';
import 'terms_of_use_en.dart';
import 'terms_of_use_es.dart';
import 'terms_of_use_fr.dart';
import 'terms_of_use_it.dart';

/// O nome do produto, como aparece no cabeçalho das duas páginas.
const String nomeDoProduto = 'Meu Bebê: Cápsula do Tempo';

/// As cores da paleta neutra, em hexadecimal, para o CSS.
///
/// A página é lida por quem está decidindo se confia o registro de um filho
/// ao aplicativo. Parecer o mesmo produto é parte da resposta.
const Map<String, String> coresDaPagina = <String, String>{
  'primary': '#D2654E',
  'primaryDark': '#B8513E',
  'background': '#FCF3EE',
  'surface': '#FFFFFF',
  'textPrimary': '#2F251F',
  'textSecondary': '#71665E',
  'border': '#E9DDD6',
};

const String _css = '''
:root {
  color-scheme: light;
  --primary: {primary};
  --primary-dark: {primaryDark};
  --bg: {background};
  --surface: {surface};
  --text: {textPrimary};
  --text-soft: {textSecondary};
  --border: {border};
}
* { box-sizing: border-box; }
body {
  margin: 0;
  padding: 0 20px 64px;
  background: var(--bg);
  color: var(--text);
  font: 17px/1.65 -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto,
      "Helvetica Neue", Arial, sans-serif;
  -webkit-text-size-adjust: 100%;
}
main { max-width: 44rem; margin: 0 auto; }
header {
  padding: 48px 0 8px;
  border-bottom: 1px solid var(--border);
  margin-bottom: 8px;
}
.produto {
  font-size: 15px;
  letter-spacing: 0.04em;
  text-transform: uppercase;
  color: var(--primary-dark);
  margin: 0 0 8px;
}
h1 { font-size: 30px; line-height: 1.25; margin: 0 0 8px; }
.data { color: var(--text-soft); font-size: 15px; margin: 0 0 32px; }
h2 {
  font-size: 21px;
  line-height: 1.3;
  margin: 40px 0 12px;
  padding-top: 8px;
}
p { margin: 0 0 16px; }
ul { margin: 0 0 16px; padding-left: 22px; }
li { margin: 0 0 8px; }
a { color: var(--primary-dark); }
strong { font-weight: 650; }
code {
  font-family: ui-monospace, SFMono-Regular, Menlo, Consolas, monospace;
  font-size: 0.88em;
  /* "anywhere", e não "break-all": o navegador leva a URL inteira para a
     linha de baixo antes de parti-la, em vez de deixar um "h" órfão no fim
     da linha anterior. */
  overflow-wrap: anywhere;
}
.destaque {
  background: var(--surface);
  border: 1px solid var(--border);
  border-radius: 16px;
  padding: 20px 22px 4px;
  margin: 0 0 8px;
}
.destaque h2 { margin-top: 0; padding-top: 0; }
nav { margin: 40px 0 0; font-size: 16px; }
footer {
  margin-top: 56px;
  padding-top: 20px;
  border-top: 1px solid var(--border);
  color: var(--text-soft);
  font-size: 15px;
}
@media (prefers-color-scheme: dark) {
  :root {
    color-scheme: dark;
    --bg: #1B1512;
    --surface: #241D19;
    --text: #F2EAE4;
    --text-soft: #B9ABA2;
    --border: #3A2F29;
    --primary-dark: #F0A48D;
  }
}
''';

String _estilo() {
  String css = _css;
  coresDaPagina.forEach((String chave, String valor) {
    css = css.replaceAll('{$chave}', valor);
  });
  return css;
}

/// Escapa o que o navegador leria como marcação.
String _seguro(String texto) => texto
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;');

final RegExp _negrito = RegExp(r'\*\*(.+?)\*\*');

/// Email e o endereço do Drive, que são os dois destinos em que a pessoa
/// precisa clicar.
final RegExp _endereco = RegExp(
  r'([\w.+-]+@[\w-]+\.[\w.]+|drive\.google\.com)',
);

/// O escopo do OAuth. Vira `<code>`, e não link: é um identificador, e a
/// URL não abre página nenhuma. Deixá-la clicável é prometer um destino que
/// devolve erro para quem foi conferir a promessa.
final RegExp _escopo = RegExp(r'https://www\.googleapis\.com/auth/[\w.]+');

/// Aplica o pouco de formatação que os textos usam: `**negrito**`, o escopo
/// em monoespaçado, e email e endereço clicáveis.
///
/// O email precisa virar link: a página de exclusão existe para que alguém
/// consiga pedir a exclusão do celular, e obrigar a copiar um endereço à mão
/// é onde o pedido se perde.
String _formatar(String paragrafo) {
  final String escapado = _seguro(paragrafo);
  final String comEscopo = escapado.replaceAllMapped(
    _escopo,
    (Match m) => '<code>${m[0]}</code>',
  );
  final String comLinks = comEscopo.replaceAllMapped(_endereco, (Match m) {
    final String achado = m[0]!;
    final String limpo = achado.endsWith('.')
        ? achado.substring(0, achado.length - 1)
        : achado;
    final String sobra = achado.substring(limpo.length);
    final String destino = limpo.contains('@')
        ? 'mailto:$limpo'
        : 'https://$limpo';
    return '<a href="$destino">$limpo</a>$sobra';
  });
  return comLinks.replaceAllMapped(
    _negrito,
    (Match m) => '<strong>${m[1]}</strong>',
  );
}

String _corpo(List<String> paragrafos) {
  final StringBuffer saida = StringBuffer();
  final List<String> lista = <String>[];

  void fecharLista() {
    if (lista.isEmpty) return;
    saida.writeln('    <ul>');
    for (final String item in lista) {
      saida.writeln('      <li>${_formatar(item)}</li>');
    }
    saida.writeln('    </ul>');
    lista.clear();
  }

  for (final String paragrafo in paragrafos) {
    if (paragrafo.startsWith('• ')) {
      lista.add(paragrafo.substring(2));
      continue;
    }
    fecharLista();
    saida.writeln('    <p>${_formatar(paragrafo)}</p>');
  }
  fecharLista();
  return saida.toString().trimRight();
}

/// O que muda de uma língua para a outra fora do texto dos documentos.
///
/// Traduzir só as seções deixaria uma página inglesa com "Última
/// atualização" no alto e "Política de privacidade" no rodapé. Este punhado
/// de palavras é a moldura, e ela precisa acompanhar o miolo.
class _Moldura {
  const _Moldura({
    required this.codigo,
    required this.lang,
    required this.pasta,
    required this.nomeNaPropriaLingua,
    required this.atualizado,
    required this.privacidade,
    required this.termos,
    required this.exclusao,
    required this.documentos,
    required this.resumoDoProduto,
    required this.arquivoIndice,
    required this.arquivoDaPrivacidade,
    required this.arquivoDosTermos,
    required this.arquivoDaExclusao,
  });

  /// O código da língua, o mesmo que `Idioma.codigo` no resto do
  /// aplicativo.
  final String codigo;

  /// O valor do atributo `lang` do `<html>`.
  ///
  /// Não é enfeite: é o que faz o leitor de tela pronunciar a página na
  /// língua certa, e o que diz ao navegador se pode hifenizar.
  final String lang;

  /// A subpasta dentro de `docs/` onde as páginas desta língua moram.
  ///
  /// Vazia para o português, que fica na raiz, porque é a língua original
  /// do produto e a que já estava lá antes de existir uma segunda.
  final String pasta;

  /// Como esta língua se chama nela mesma: "Português", "English",
  /// "Español". É o rótulo que aparece no seletor, em qualquer página das
  /// outras cinco línguas.
  final String nomeNaPropriaLingua;

  final String atualizado;
  final String privacidade;
  final String termos;
  final String exclusao;
  final String documentos;
  final String resumoDoProduto;

  final String arquivoIndice;
  final String arquivoDaPrivacidade;
  final String arquivoDosTermos;
  final String arquivoDaExclusao;
}

const _Moldura _pt = _Moldura(
  codigo: 'pt',
  lang: 'pt-BR',
  pasta: '',
  nomeNaPropriaLingua: 'Português',
  atualizado: 'Última atualização',
  privacidade: 'Política de Privacidade',
  termos: 'Termos de Uso',
  exclusao: 'Exclusão de conta e de dados',
  documentos: 'Documentos públicos',
  resumoDoProduto:
      'Um diário digital da infância do seu filho, guardado no Google Drive '
      'da própria criança.',
  arquivoIndice: 'index.html',
  arquivoDaPrivacidade: 'privacidade.html',
  arquivoDosTermos: 'termos.html',
  arquivoDaExclusao: 'exclusao.html',
);

const _Moldura _en = _Moldura(
  codigo: 'en',
  lang: 'en',
  pasta: 'en/',
  nomeNaPropriaLingua: 'English',
  atualizado: 'Last updated',
  privacidade: 'Privacy Policy',
  termos: 'Terms of Use',
  exclusao: 'Account and data deletion',
  documentos: 'Public documents',
  resumoDoProduto:
      "A digital diary of your child's childhood, kept in the child's own "
      'Google Drive.',
  arquivoIndice: 'index.html',
  arquivoDaPrivacidade: 'privacy.html',
  arquivoDosTermos: 'terms.html',
  arquivoDaExclusao: 'deletion.html',
);

const _Moldura _es = _Moldura(
  codigo: 'es',
  lang: 'es',
  pasta: 'es/',
  nomeNaPropriaLingua: 'Español',
  atualizado: 'Última actualización',
  privacidade: 'Política de Privacidad',
  termos: 'Términos de Uso',
  exclusao: 'Eliminación de cuenta y de datos',
  documentos: 'Documentos públicos',
  resumoDoProduto:
      'Un diario digital de la infancia de tu hijo, guardado en el propio '
      'Google Drive de la criatura.',
  arquivoIndice: 'index.html',
  arquivoDaPrivacidade: 'privacidad.html',
  arquivoDosTermos: 'terminos.html',
  arquivoDaExclusao: 'eliminacion.html',
);

const _Moldura _fr = _Moldura(
  codigo: 'fr',
  lang: 'fr',
  pasta: 'fr/',
  nomeNaPropriaLingua: 'Français',
  atualizado: 'Dernière mise à jour',
  privacidade: 'Politique de Confidentialité',
  termos: "Conditions d'Utilisation",
  exclusao: 'Suppression du compte et des données',
  documentos: 'Documents publics',
  resumoDoProduto:
      "Un journal numérique de l'enfance de votre enfant, conservé dans le "
      "Google Drive de l'enfant lui-même.",
  arquivoIndice: 'index.html',
  arquivoDaPrivacidade: 'confidentialite.html',
  arquivoDosTermos: 'conditions.html',
  arquivoDaExclusao: 'suppression.html',
);

const _Moldura _de = _Moldura(
  codigo: 'de',
  lang: 'de',
  pasta: 'de/',
  nomeNaPropriaLingua: 'Deutsch',
  atualizado: 'Letzte Aktualisierung',
  privacidade: 'Datenschutzerklärung',
  termos: 'Nutzungsbedingungen',
  exclusao: 'Konto- und Datenlöschung',
  documentos: 'Öffentliche Dokumente',
  resumoDoProduto:
      'Ein digitales Tagebuch der Kindheit Ihres Kindes, aufbewahrt im '
      'eigenen Google Drive des Kindes.',
  arquivoIndice: 'index.html',
  arquivoDaPrivacidade: 'datenschutz.html',
  arquivoDosTermos: 'nutzungsbedingungen.html',
  arquivoDaExclusao: 'kontoloeschung.html',
);

const _Moldura _it = _Moldura(
  codigo: 'it',
  lang: 'it',
  pasta: 'it/',
  nomeNaPropriaLingua: 'Italiano',
  atualizado: 'Ultimo aggiornamento',
  privacidade: 'Informativa sulla Privacy',
  termos: 'Termini di Utilizzo',
  exclusao: "Eliminazione dell'account e dei dati",
  documentos: 'Documenti pubblici',
  resumoDoProduto:
      "Un diario digitale dell'infanzia di tuo figlio, conservato nel "
      'Google Drive dello stesso bambino.',
  arquivoIndice: 'index.html',
  arquivoDaPrivacidade: 'privacy.html',
  arquivoDosTermos: 'termini.html',
  arquivoDaExclusao: 'eliminazione.html',
);

/// As seis, na ordem do seletor de idioma dentro do aplicativo.
const List<_Moldura> _todasAsMolduras = <_Moldura>[
  _pt,
  _en,
  _es,
  _fr,
  _de,
  _it,
];

/// O caminho de um arquivo de [para] visto de dentro de uma página de [de].
///
/// As páginas portuguesas vivem na raiz e as demais em subpastas de um
/// nível só, então a conta é sempre uma destas três: mesma pasta não
/// acontece aqui porque a função só é chamada para línguas diferentes,
/// raiz para subpasta desce, subpasta para raiz sobe, e subpasta para outra
/// subpasta sobe e desce.
String _caminhoRelativo(_Moldura de, _Moldura para, String arquivo) {
  if (de.pasta.isEmpty) return '${para.pasta}$arquivo';
  if (para.pasta.isEmpty) return '../$arquivo';
  return '../${para.pasta}$arquivo';
}

/// Os links para as outras cinco línguas, cada um levando ao mesmo
/// documento na língua de destino, e não à porta de entrada dela.
///
/// Cair no índice da língua errada é perder o lugar onde a pessoa estava, e
/// numa política longa isso é perder a resposta que ela veio procurar.
String _seletorDeLinguas(
  _Moldura atual,
  String Function(_Moldura) arquivoDoTipo,
) {
  final List<String> links = <String>[
    for (final _Moldura m in _todasAsMolduras)
      if (m.codigo != atual.codigo)
        '<a href="${_caminhoRelativo(atual, m, arquivoDoTipo(m))}" '
            'lang="${m.lang}">${_seguro(m.nomeNaPropriaLingua)}</a>',
  ];
  return links.join(' &middot; ');
}

/// As seis tags `<link rel="alternate">`, uma por língua, incluindo a
/// própria página.
///
/// É o que diz ao Google "estas seis páginas são a mesma coisa, em línguas
/// diferentes", para a busca oferecer a versão certa a cada pessoa.
String _alternates(_Moldura atual, String Function(_Moldura) arquivoDoTipo) {
  final StringBuffer saida = StringBuffer();
  for (final _Moldura m in _todasAsMolduras) {
    final String caminho = m.codigo == atual.codigo
        ? arquivoDoTipo(atual)
        : _caminhoRelativo(atual, m, arquivoDoTipo(m));
    saida.writeln(
      '<link rel="alternate" hreflang="${m.lang}" href="$caminho">',
    );
  }
  return saida.toString().trimRight();
}

String _arquivoPrivacidade(_Moldura m) => m.arquivoDaPrivacidade;
String _arquivoTermos(_Moldura m) => m.arquivoDosTermos;
String _arquivoExclusao(_Moldura m) => m.arquivoDaExclusao;
String _arquivoIndice(_Moldura m) => m.arquivoIndice;

/// Monta uma página inteira, pronta para servir como arquivo estático.
///
/// [destaque] é o índice da seção que ganha o cartão em volta. Numa página
/// que a pessoa abre com pressa, o caminho para fazer a coisa precisa saltar
/// antes do resto do texto.
String _pagina({
  required _Moldura moldura,
  required String Function(_Moldura) arquivoDoTipo,
  required String titulo,
  required String descricao,
  required String data,
  required List<PrivacySection> secoes,
  required String navegacao,
  int? destaque,
}) {
  final StringBuffer corpo = StringBuffer();
  for (int i = 0; i < secoes.length; i++) {
    final PrivacySection secao = secoes[i];
    final bool emCartao = i == destaque;
    if (emCartao) corpo.writeln('    <section class="destaque">');
    corpo
      ..writeln('    <h2>${_seguro(secao.title)}</h2>')
      ..writeln(_corpo(secao.body));
    if (emCartao) corpo.writeln('    </section>');
  }

  return '''
<!DOCTYPE html>
<html lang="${moldura.lang}">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>${_seguro(titulo)} | ${_seguro(nomeDoProduto)}</title>
<meta name="description" content="${_seguro(descricao)}">
${_alternates(moldura, arquivoDoTipo)}
<style>
${_estilo().trim()}
</style>
</head>
<body>
<main>
  <header>
    <p class="produto">${_seguro(nomeDoProduto)}</p>
    <h1>${_seguro(titulo)}</h1>
  </header>
  <p class="data">${_seguro(moldura.atualizado)}: ${_seguro(data)}</p>
${corpo.toString().trimRight()}
  <nav>$navegacao &middot;
    ${_seletorDeLinguas(moldura, arquivoDoTipo)}</nav>
  <footer>
    <p>${_seguro(privacyController)} &middot;
      <a href="mailto:$privacyEmail">$privacyEmail</a></p>
  </footer>
</main>
</body>
</html>
''';
}

/// A página pública de exclusão de conta.
String exclusaoEmHtml() => _pagina(
  moldura: _pt,
  arquivoDoTipo: _arquivoExclusao,
  titulo: 'Exclusão de conta e de dados',
  descricao:
      'Como pedir a exclusão da sua conta do $nomeDoProduto e de todos os '
      'dados associados a ela, com ou sem o aplicativo instalado.',
  data: deletionPageDate,
  secoes: accountDeletionPagePt,
  destaque: 2,
  navegacao: '<a href="privacidade.html">Política de privacidade</a>',
);

/// A página pública dos termos de uso.
String termosEmHtml() => _pagina(
  moldura: _pt,
  arquivoDoTipo: _arquivoTermos,
  titulo: 'Termos de Uso',
  descricao:
      'As regras de uso do $nomeDoProduto: o que ele é, de quem é o '
      'conteúdo e o que não é prometido.',
  data: termsOfUseDate,
  secoes: termsOfUsePt,
  navegacao: '<a href="privacidade.html">Política de privacidade</a>',
);

/// A página pública da política de privacidade.
String privacidadeEmHtml() => _pagina(
  moldura: _pt,
  arquivoDoTipo: _arquivoPrivacidade,
  titulo: 'Política de Privacidade',
  descricao:
      'O que o $nomeDoProduto guarda, onde guarda e o que você pode apagar.',
  data: privacyPolicyDate,
  secoes: privacyPolicyPt,
  navegacao:
      '<a href="termos.html">Termos de Uso</a> &middot; '
      '<a href="exclusao.html">Exclusão de conta e de dados</a>',
);

/// A página de exclusão de conta, em inglês.
String exclusaoEmHtmlIngles() => _pagina(
  moldura: _en,
  arquivoDoTipo: _arquivoExclusao,
  titulo: 'Account and data deletion',
  descricao:
      'How to request deletion of your $nomeDoProduto account and all data '
      'associated with it, with or without the app installed.',
  data: deletionPageDateEn,
  secoes: accountDeletionPageEn,
  destaque: 2,
  navegacao: '<a href="privacy.html">Privacy Policy</a>',
);

/// Os termos de uso, em inglês.
String termosEmHtmlIngles() => _pagina(
  moldura: _en,
  arquivoDoTipo: _arquivoTermos,
  titulo: 'Terms of Use',
  descricao:
      'The rules for using $nomeDoProduto: what it is, whose the content is, '
      'and what is not promised.',
  data: termsOfUseDateEn,
  secoes: termsOfUseEn,
  navegacao: '<a href="privacy.html">Privacy Policy</a>',
);

/// A política de privacidade, em inglês.
///
/// É este o endereço que vai na ficha da loja para quem revisa em inglês. O
/// que a exigência da Play Store cobra é uma página que qualquer pessoa
/// abra e leia, e uma política em português é ilegível para boa parte de
/// quem precisa lê-la.
String privacidadeEmHtmlIngles() => _pagina(
  moldura: _en,
  arquivoDoTipo: _arquivoPrivacidade,
  titulo: 'Privacy Policy',
  descricao:
      'What $nomeDoProduto keeps, where it keeps it, and what you can delete.',
  data: privacyPolicyDateEn,
  secoes: privacyPolicyEn,
  navegacao:
      '<a href="terms.html">Terms of Use</a> &middot; '
      '<a href="deletion.html">Account and data deletion</a>',
);

/// A página de exclusão de conta, em espanhol.
String exclusaoEmHtmlEspanhol() => _pagina(
  moldura: _es,
  arquivoDoTipo: _arquivoExclusao,
  titulo: 'Eliminación de cuenta y de datos',
  descricao:
      'Cómo pedir la eliminación de tu cuenta de $nomeDoProduto y de todos '
      'los datos asociados a ella, con o sin el aplicativo instalado.',
  data: deletionPageDateEs,
  secoes: accountDeletionPageEs,
  destaque: 2,
  navegacao: '<a href="privacidad.html">Política de Privacidad</a>',
);

/// Os termos de uso, em espanhol.
String termosEmHtmlEspanhol() => _pagina(
  moldura: _es,
  arquivoDoTipo: _arquivoTermos,
  titulo: 'Términos de Uso',
  descricao:
      'Las reglas de uso de $nomeDoProduto: qué es, de quién es el '
      'contenido y qué no se promete.',
  data: termsOfUseDateEs,
  secoes: termsOfUseEs,
  navegacao: '<a href="privacidad.html">Política de Privacidad</a>',
);

/// A política de privacidade, em espanhol.
String privacidadeEmHtmlEspanhol() => _pagina(
  moldura: _es,
  arquivoDoTipo: _arquivoPrivacidade,
  titulo: 'Política de Privacidad',
  descricao: 'Qué guarda $nomeDoProduto, dónde lo guarda y qué puedes borrar.',
  data: privacyPolicyDateEs,
  secoes: privacyPolicyEs,
  navegacao:
      '<a href="terminos.html">Términos de Uso</a> &middot; '
      '<a href="eliminacion.html">Eliminación de cuenta y de datos</a>',
);

/// A página de exclusão de conta, em francês.
String exclusaoEmHtmlFrances() => _pagina(
  moldura: _fr,
  arquivoDoTipo: _arquivoExclusao,
  titulo: 'Suppression du compte et des données',
  descricao:
      'Comment demander la suppression de votre compte $nomeDoProduto et de '
      "toutes les données qui y sont associées, avec ou sans l'application "
      'installée.',
  data: deletionPageDateFr,
  secoes: accountDeletionPageFr,
  destaque: 2,
  navegacao: '<a href="confidentialite.html">Politique de Confidentialité</a>',
);

/// Os termos de uso, em francês.
String termosEmHtmlFrances() => _pagina(
  moldura: _fr,
  arquivoDoTipo: _arquivoTermos,
  titulo: "Conditions d'Utilisation",
  descricao:
      "Les règles d'utilisation de $nomeDoProduto : ce qu'elle est, à qui "
      "appartient le contenu, et ce qui n'est pas promis.",
  data: termsOfUseDateFr,
  secoes: termsOfUseFr,
  navegacao: '<a href="confidentialite.html">Politique de Confidentialité</a>',
);

/// A política de privacidade, em francês.
String privacidadeEmHtmlFrances() => _pagina(
  moldura: _fr,
  arquivoDoTipo: _arquivoPrivacidade,
  titulo: 'Politique de Confidentialité',
  descricao:
      'Ce que $nomeDoProduto conserve, où il le conserve, et ce que vous '
      'pouvez supprimer.',
  data: privacyPolicyDateFr,
  secoes: privacyPolicyFr,
  navegacao:
      "<a href=\"conditions.html\">Conditions d'Utilisation</a> &middot; "
      '<a href="suppression.html">Suppression du compte et des données</a>',
);

/// A página de exclusão de conta, em alemão.
String exclusaoEmHtmlAlemao() => _pagina(
  moldura: _de,
  arquivoDoTipo: _arquivoExclusao,
  titulo: 'Konto- und Datenlöschung',
  descricao:
      'Wie Sie die Löschung Ihres $nomeDoProduto-Kontos und aller damit '
      'verbundenen Daten beantragen, mit oder ohne installierte App.',
  data: deletionPageDateDe,
  secoes: accountDeletionPageDe,
  destaque: 2,
  navegacao: '<a href="datenschutz.html">Datenschutzerklärung</a>',
);

/// Os termos de uso, em alemão.
String termosEmHtmlAlemao() => _pagina(
  moldura: _de,
  arquivoDoTipo: _arquivoTermos,
  titulo: 'Nutzungsbedingungen',
  descricao:
      'Die Nutzungsregeln von $nomeDoProduto: was es ist, wem der Inhalt '
      'gehört, und was nicht versprochen wird.',
  data: termsOfUseDateDe,
  secoes: termsOfUseDe,
  navegacao: '<a href="datenschutz.html">Datenschutzerklärung</a>',
);

/// A política de privacidade, em alemão.
String privacidadeEmHtmlAlemao() => _pagina(
  moldura: _de,
  arquivoDoTipo: _arquivoPrivacidade,
  titulo: 'Datenschutzerklärung',
  descricao:
      'Was $nomeDoProduto speichert, wo es das tut, und was Sie löschen '
      'können.',
  data: privacyPolicyDateDe,
  secoes: privacyPolicyDe,
  navegacao:
      '<a href="nutzungsbedingungen.html">Nutzungsbedingungen</a> &middot; '
      '<a href="kontoloeschung.html">Konto- und Datenlöschung</a>',
);

/// A página de exclusão de conta, em italiano.
String exclusaoEmHtmlItaliano() => _pagina(
  moldura: _it,
  arquivoDoTipo: _arquivoExclusao,
  titulo: "Eliminazione dell'account e dei dati",
  descricao:
      "Come richiedere l'eliminazione del tuo account $nomeDoProduto e di "
      "tutti i dati ad esso associati, con o senza l'app installata.",
  data: deletionPageDateIt,
  secoes: accountDeletionPageIt,
  destaque: 2,
  navegacao: '<a href="privacy.html">Informativa sulla Privacy</a>',
);

/// Os termos di uso, em italiano.
String termosEmHtmlItaliano() => _pagina(
  moldura: _it,
  arquivoDoTipo: _arquivoTermos,
  titulo: 'Termini di Utilizzo',
  descricao:
      'Le regole di utilizzo di $nomeDoProduto: cos\'è, di chi è il '
      "contenuto e cosa non viene promesso.",
  data: termsOfUseDateIt,
  secoes: termsOfUseIt,
  navegacao: '<a href="privacy.html">Informativa sulla Privacy</a>',
);

/// A política de privacidade, em italiano.
String privacidadeEmHtmlItaliano() => _pagina(
  moldura: _it,
  arquivoDoTipo: _arquivoPrivacidade,
  titulo: 'Informativa sulla Privacy',
  descricao:
      'Cosa conserva $nomeDoProduto, dove lo conserva e cosa puoi '
      'eliminare.',
  data: privacyPolicyDateIt,
  secoes: privacyPolicyIt,
  navegacao:
      '<a href="termini.html">Termini di Utilizzo</a> &middot; '
      '<a href="eliminazione.html">Eliminazione dell\'account e dei dati</a>',
);

/// A porta de entrada de uma das seis versões.
String _indice(_Moldura moldura) {
  return '''
<!DOCTYPE html>
<html lang="${moldura.lang}">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>${_seguro(nomeDoProduto)}</title>
<meta name="description"
  content="${_seguro(moldura.documentos)}: ${_seguro(nomeDoProduto)}.">
${_alternates(moldura, _arquivoIndice)}
<style>
${_estilo().trim()}
</style>
</head>
<body>
<main>
  <header>
    <p class="produto">${_seguro(nomeDoProduto)}</p>
    <h1>${_seguro(moldura.documentos)}</h1>
  </header>
  <p>${_seguro(moldura.resumoDoProduto)}</p>
  <ul>
    <li><a href="${moldura.arquivoDosTermos}">${_seguro(moldura.termos)}</a></li>
    <li><a href="${moldura.arquivoDaPrivacidade}">${_seguro(moldura.privacidade)}</a></li>
    <li><a href="${moldura.arquivoDaExclusao}">${_seguro(moldura.exclusao)}</a></li>
  </ul>
  <nav>${_seletorDeLinguas(moldura, _arquivoIndice)}</nav>
  <footer>
    <p>${_seguro(privacyController)} &middot;
      <a href="mailto:$privacyEmail">$privacyEmail</a></p>
  </footer>
</main>
</body>
</html>
''';
}

/// A porta de entrada, para quem chegar na raiz do endereço.
String indiceEmHtml() => _indice(_pt);

/// A porta de entrada em inglês, servida de `docs/en/`.
String indiceEmHtmlIngles() => _indice(_en);

/// A porta de entrada em espanhol, servida de `docs/es/`.
String indiceEmHtmlEspanhol() => _indice(_es);

/// A porta de entrada em francês, servida de `docs/fr/`.
String indiceEmHtmlFrances() => _indice(_fr);

/// A porta de entrada em alemão, servida de `docs/de/`.
String indiceEmHtmlAlemao() => _indice(_de);

/// A porta de entrada em italiano, servida de `docs/it/`.
String indiceEmHtmlItaliano() => _indice(_it);
