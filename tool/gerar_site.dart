// Escreve as páginas públicas em docs/, de onde o GitHub Pages as serve.
//
// Rodar com: dart run tool/gerar_site.dart
//
// Entre elas estão os dois endereços que o Google Play exige, a política de
// privacidade e a exclusão de conta, mais os termos de uso. Saem do mesmo
// texto que o aplicativo mostra, e os testes comparam os arquivos no disco
// com o que esta ferramenta geraria, então esquecer de rodar isto quebra a
// suíte em vez de deixar no ar uma página que descreve outro aplicativo.

import 'dart:io';

import 'package:meu_bebe/core/l10n/pagina_web.dart';

void main() {
  final Directory pasta = Directory('docs')..createSync(recursive: true);

  // As outras cinco línguas moram um nível abaixo, cada uma na própria
  // pasta. Quem revisa o aplicativo na loja raramente lê português, e uma
  // política que o revisor não consegue ler é uma política que não cumpre a
  // exigência.
  for (final String lingua in <String>['en', 'es', 'fr', 'de', 'it']) {
    Directory('${pasta.path}/$lingua').createSync(recursive: true);
  }

  final Map<String, String> paginas = <String, String>{
    'index.html': indiceEmHtml(),
    'privacidade.html': privacidadeEmHtml(),
    'termos.html': termosEmHtml(),
    'exclusao.html': exclusaoEmHtml(),
    'en/index.html': indiceEmHtmlIngles(),
    'en/privacy.html': privacidadeEmHtmlIngles(),
    'en/terms.html': termosEmHtmlIngles(),
    'en/deletion.html': exclusaoEmHtmlIngles(),
    'es/index.html': indiceEmHtmlEspanhol(),
    'es/privacidad.html': privacidadeEmHtmlEspanhol(),
    'es/terminos.html': termosEmHtmlEspanhol(),
    'es/eliminacion.html': exclusaoEmHtmlEspanhol(),
    'fr/index.html': indiceEmHtmlFrances(),
    'fr/confidentialite.html': privacidadeEmHtmlFrances(),
    'fr/conditions.html': termosEmHtmlFrances(),
    'fr/suppression.html': exclusaoEmHtmlFrances(),
    'de/index.html': indiceEmHtmlAlemao(),
    'de/datenschutz.html': privacidadeEmHtmlAlemao(),
    'de/nutzungsbedingungen.html': termosEmHtmlAlemao(),
    'de/kontoloeschung.html': exclusaoEmHtmlAlemao(),
    'it/index.html': indiceEmHtmlItaliano(),
    'it/privacy.html': privacidadeEmHtmlItaliano(),
    'it/termini.html': termosEmHtmlItaliano(),
    'it/eliminazione.html': exclusaoEmHtmlItaliano(),
  };

  paginas.forEach((String nome, String conteudo) {
    File('${pasta.path}/$nome').writeAsStringSync(conteudo);
    stdout.writeln('docs/$nome gerado.');
  });

  // O Jekyll do GitHub Pages ignora arquivos e pastas que comecem com "_" e
  // reprocessa o resto. Aqui não há nada para processar: são páginas prontas.
  File('${pasta.path}/.nojekyll').writeAsStringSync('');
}
