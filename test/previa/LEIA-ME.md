# Prévias das telas

Imagens geradas em teste, para olhar o desenho sem instalar o APK.

| Arquivo | Tela |
|---|---|
| `acervo-topo.png` | o acervo como abre |
| `acervo-rolando.png` | o acervo em uso, com a bolha do mês e as marcas de ano |
| `linha-do-tempo-ano.png` | a linha do tempo agrupada por Anos |
| `linha-do-tempo-mes.png` | por Meses, que é como ela abre |
| `linha-do-tempo-semana.png` | por Semanas |
| `home-1` a `home-6` | **propostas** recusadas para a tela inicial |
| `painel-menina/menino/sem-sexo.png` | o painel novo do topo, nos três temas |
| `home-nova-menina/menino.png` | a tela inicial com o painel novo e o Acervo como está |

Regeneradas com:

```
flutter test --run-skipped --update-goldens test/previa_do_acervo_test.dart
flutter test --run-skipped --update-goldens test/previa_da_linha_do_tempo_test.dart
flutter test --run-skipped --update-goldens test/previa_da_home_test.dart
flutter test --run-skipped --update-goldens test/previa_do_painel_test.dart
flutter test --run-skipped --update-goldens test/previa_da_home_nova_test.dart
```

**Nem toda imagem aqui desenha uma tela que existe.** As `home-1` a `home-6`
são propostas que foram recusadas: ficam como registro do que já foi tentado,
para as mesmas ideias não voltarem recicladas. Todas as outras desenham
telas que estão no aplicativo.

**O que é real nelas:** no acervo, a função `mosaico`, o agrupamento por mês
e o cabeçalho. Na linha do tempo, a `TimelineList` de verdade, a mesma que a
tela monta: o agrupamento por período, o mosaico com as dimensões variadas,
a contagem à direita, o selo de data redonda, os cartões de carta e de
crescimento e o trilho. Nas duas, os espaçamentos e as cores do Design
System, e a fonte do produto.

**O que é encenação:** o conteúdo das fotos, que são retângulos de cor
chapada. Miniatura de verdade vem do Drive, e teste não tem rede. A
proporção de cada retângulo é a que a foto teria, e é a proporção que decide
o tamanho do ladrilho, então o enquadramento é fiel mesmo sem a imagem.

Os testes que geram isto não rodam junto com a suíte por escolha: comparar
pixels no CI faz o fluxo falhar por diferença de máquina, e um alarme que
toca sozinho é um alarme que se aprende a ignorar.
