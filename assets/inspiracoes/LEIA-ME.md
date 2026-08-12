# As capas das postagens

Uma imagem por postagem, com o **id** dela como nome do arquivo:

```
assets/inspiracoes/primeiro-aniversario-ideias.webp
assets/inspiracoes/carta-primeiro-mes.webp
```

Os ids estão em `assets/inspiracoes.json`, no campo `id`.

## Trocar a arte de uma postagem

Substitua o arquivo. Não há nada a editar no JSON nem no código: a tela
monta o caminho a partir do id.

## Enquanto a arte não existe

A postagem não quebra. Sem o arquivo, a tela desenha a ilustração gerada
por `InspirationArt`, que é a mesma de antes. Isso permite escrever o texto
de uma postagem hoje e mandar fazer a foto depois.

## Formato

WebP, proporção 16:9, largura de 1200 px. WebP porque é a metade do peso de
um JPEG na mesma qualidade, e o aplicativo inteiro viaja dentro do APK.

## Por que uma pasta plana

A lista de `assets` do `pubspec.yaml` não alcança subpastas. Uma pasta por
postagem obrigaria a acrescentar uma linha ali a cada postagem nova; assim
é uma linha só, para sempre.
