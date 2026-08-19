# O bolo do cartão "Próximo marco"

Solte aqui dois arquivos, com estes nomes exatos:

| Arquivo | Quando aparece |
|---|---|
| `bolo-menina.png` | cadastro com sexo feminino |
| `bolo-menino.png` | cadastro com sexo masculino |

Recomendado: PNG quadrado com fundo transparente, 512 por 512. O aplicativo
reduz na tela, então maior que isso só pesa o pacote.

## Como subir, sem terminal

1. Abra `assets/marcos/` no GitHub, nesta mesma branch
2. **Add file > Upload files**
3. Arraste os dois PNG, confira que os nomes são exatamente os da tabela
4. **Commit changes**

Só isso. Nenhuma mudança de código é necessária: o cartão já procura por
esses dois caminhos.

## O que muda quando eles chegam

**Enquanto os arquivos não estiverem aqui, nada quebra.** O cartão desenha um
bolo em código, sobre uma base colorida suave, que acompanha a paleta de cada
tema.

Assim que os PNG aparecerem, o cartão passa a usá-los **e some com a base
colorida**: a arte aparece solta sobre o cartão branco, como no modelo. A
base existe só por causa do desenho de reserva, cujos andares creme sumiriam
no fundo branco. Arte de verdade vem com sombra e volume próprios e não
precisa de moldura.

Cadastro sem sexo informado continua com o bolo desenhado, porque não há um
terceiro arquivo para ele. Se quiser um, chame de `bolo-neutro.png` e peça
para acrescentarem a linha correspondente no código.

## Por que os arquivos não entram por aqui

Imagens enviadas na conversa com o assistente **não podem ser gravadas no
repositório por ele**: elas ficam no histórico da conversa, e ele não tem
como transformá-las em arquivo dentro do projeto. Por isso o passo de subir
os PNG é sempre manual, e por isso o desenho de reserva existe.
