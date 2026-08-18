# As postagens do blog

**Uma postagem é um par de arquivos com o mesmo nome:**

```
assets/inspiracoes/carta-primeiro-mes.json   <- o texto
assets/inspiracoes/carta-primeiro-mes.webp   <- a capa
```

O nome do arquivo **é** o identificador da postagem. Não existe campo `id`
dentro do JSON, não existe catálogo central para editar, e não existe linha
para acrescentar no `pubspec.yaml`.

## Publicar uma postagem nova

1. Escolha um nome: letras minúsculas, números e hífen. Ele aparece só aqui,
   nunca na tela.
2. Crie o `.json` com o formato abaixo.
3. Solte a capa ao lado, com o mesmo nome e extensão `.webp`.

Pronto. O aplicativo descobre a pasta em tempo de execução, e a suíte de
testes passa a cobrir a postagem nova sozinha.

## Trocar a arte de uma postagem

Substitua o `.webp`. Nada mais.

## Enquanto a capa não existe

A postagem não quebra: entra a ilustração gerada por `InspirationArt`. Dá
para escrever o texto hoje e mandar fazer a arte depois.

## Formato da capa

WebP, proporção 16:9, largura de 1200 px. WebP porque pesa cerca de metade
de um JPEG na mesma qualidade, e tudo isto viaja dentro do APK.

## Formato do texto

```json
{
  "titulo": "Título curto, que cabe em duas linhas no cartão",
  "resumo": "Uma ou duas frases que digam do que se trata.",
  "tipo": "brincadeira",
  "quando": { "tipo": "idade", "deDias": 0, "ateDias": 180 },
  "registrar": "foto",
  "etiqueta": "Um momento para guardar",
  "destaque": false,
  "secoes": [
    { "titulo": "Uma seção", "texto": "Um parágrafo." },
    { "titulo": "Outra", "texto": "Abertura.", "itens": ["um", "dois"] }
  ]
}
```

- **tipo**: `brincadeira`, `passeio`, `foto`, `carta`, `leitura`, `preparo`,
  `rotina`, `cuidado`
- **quando**: `idade` (`deDias`, `ateDias`), `antesDoAniversario` (`anos`,
  `diasAntes`) ou `dataEspecial` (`data`, `diasAntes`, `apenasPrimeira`)
- **registrar**: opcional. Liga o botão que abre a folha de adicionar
- **etiqueta**: opcional. A linha pequena em maiúsculas acima do título no
  cartão da tela inicial. Escreva em caixa normal: a tela põe em maiúsculas
  sozinha. Sem ela, o cartão monta uma a partir do nome da criança, ou do
  prazo quando a postagem aponta para uma data
- **destaque**: use com parcimônia. Se tudo é destaque, nada é

## A postagem na tela inicial

A tela inicial mostra **uma** postagem por vez, sorteada entre as mais
relevantes para a idade da criança, e ela troca a cada vez que o aplicativo é
aberto. O cartão inteiro é um atalho: tocar nele abre a postagem.

O que aparece ali sai todo daqui:

| no cartão | de onde vem |
|---|---|
| a linha de cima | `etiqueta`, ou uma frase montada quando ela falta |
| o título | `titulo` |
| o texto | `resumo` |
| a imagem do quadradinho | `<id>.webp`, ou a ilustração do `tipo` enquanto ela não existe |

Ou seja: para mudar o que a tela inicial diz sobre uma postagem, mexa no
arquivo dela. Não há texto sobre postagem nenhuma escrito dentro do código.

## O que os testes cobram

Rode `flutter test test/inspiration_test.dart` depois de escrever. Eles
reprovam, entre outras coisas:

- seção sem texto e sem itens
- linguagem de cobrança ou de tabela de desenvolvimento ("deveria",
  "esperado para", "atrasado")
- postagem sem nenhuma seção
- id com caractere que atrapalhe nome de arquivo
