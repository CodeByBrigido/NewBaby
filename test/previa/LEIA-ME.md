# Prévia do acervo

Duas imagens do acervo, para olhar o desenho sem instalar o APK.

Regeneradas com:

```
flutter test --update-goldens test/previa_do_acervo_test.dart
```

**O que é real nelas:** a função `mosaico`, que decide quantas fotos entram
em cada linha e o tamanho de cada uma; o agrupamento por mês; o cabeçalho;
os espaçamentos e as cores do Design System; a fonte do produto.

**O que é encenação:** o conteúdo das fotos, que são retângulos numerados.
Miniatura de verdade vem do Drive, e teste não tem rede. A proporção de cada
retângulo é a que a foto teria, então o enquadramento é fiel mesmo sem a
imagem.

O teste que gera isto não roda junto com a suíte por escolha: comparar
pixels no CI faz o fluxo falhar por diferença de máquina, e um alarme que
toca sozinho é um alarme que se aprende a ignorar.
