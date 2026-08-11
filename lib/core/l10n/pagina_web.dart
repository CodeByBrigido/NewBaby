/// As duas páginas públicas, em HTML.
///
/// O Google Play pede dois endereços que qualquer pessoa abra no navegador,
/// sem instalar nada e sem entrar em conta nenhuma: a política de
/// privacidade e a exclusão de conta. Este arquivo transforma o mesmo texto
/// que o aplicativo mostra nas páginas que vão para o ar.
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
import 'privacy_policy.dart';

/// O nome do produto, como aparece no cabeçalho das duas páginas.
const String nomeDoProduto = 'Meu Bebê: Cápsula do Tempo';

/// As cores da paleta neutra, em hexadecimal, para o CSS.
///
/// A página é lida por quem está decidindo se confia o registro de um filho
/// ao aplicativo. Parecer o mesmo produto é parte da resposta.
const Map<String, String> coresDaPagina = <String, String>{
  'primary': '#D2654E',
  'primaryDark': '#B8513E',
  'background': '#FBF8F5',
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

/// Monta uma página inteira, pronta para servir como arquivo estático.
///
/// [destaque] é o índice da seção que ganha o cartão em volta. Numa página
/// que a pessoa abre com pressa, o caminho para fazer a coisa precisa saltar
/// antes do resto do texto.
String _pagina({
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
<html lang="pt-BR">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>${_seguro(titulo)} | ${_seguro(nomeDoProduto)}</title>
<meta name="description" content="${_seguro(descricao)}">
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
  <p class="data">Última atualização: ${_seguro(data)}</p>
${corpo.toString().trimRight()}
  <nav>$navegacao</nav>
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
  titulo: 'Exclusão de conta e de dados',
  descricao:
      'Como pedir a exclusão da sua conta do $nomeDoProduto e de todos os '
      'dados associados a ela, com ou sem o aplicativo instalado.',
  data: deletionPageDate,
  secoes: accountDeletionPage,
  destaque: 2,
  navegacao: '<a href="privacidade.html">Política de privacidade</a>',
);

/// A página pública da política de privacidade.
String privacidadeEmHtml() => _pagina(
  titulo: 'Política de Privacidade',
  descricao:
      'O que o $nomeDoProduto guarda, onde guarda e o que você pode apagar.',
  data: privacyPolicyDate,
  secoes: privacyPolicy,
  navegacao: '<a href="exclusao.html">Exclusão de conta e de dados</a>',
);

/// A porta de entrada, para quem chegar na raiz do endereço.
String indiceEmHtml() =>
    '''
<!DOCTYPE html>
<html lang="pt-BR">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>${_seguro(nomeDoProduto)}</title>
<meta name="description" content="Documentos públicos do $nomeDoProduto.">
<style>
${_estilo().trim()}
</style>
</head>
<body>
<main>
  <header>
    <p class="produto">${_seguro(nomeDoProduto)}</p>
    <h1>Documentos públicos</h1>
  </header>
  <p>Um diário digital da infância do seu filho, guardado no Google Drive da
    própria criança.</p>
  <ul>
    <li><a href="privacidade.html">Política de privacidade</a></li>
    <li><a href="exclusao.html">Exclusão de conta e de dados</a></li>
  </ul>
  <footer>
    <p>${_seguro(privacyController)} &middot;
      <a href="mailto:$privacyEmail">$privacyEmail</a></p>
  </footer>
</main>
</body>
</html>
''';
