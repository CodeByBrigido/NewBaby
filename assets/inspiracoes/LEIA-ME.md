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
- **destaque**: use com parcimônia. Se tudo é destaque, nada é

## O que os testes cobram

Rode `flutter test test/inspiration_test.dart` depois de escrever. Eles
reprovam, entre outras coisas:

- seção sem texto e sem itens
- linguagem de cobrança ou de tabela de desenvolvimento ("deveria",
  "esperado para", "atrasado")
- postagem sem nenhuma seção
- id com caractere que atrapalhe nome de arquivo
