# O bolo do cartão "Próximo marco"

Solte aqui dois arquivos, com estes nomes exatos:

| Arquivo | Quando aparece |
|---|---|
| `bolo-menina.png` | cadastro com sexo feminino |
| `bolo-menino.png` | cadastro com sexo masculino |

Recomendado: PNG quadrado com fundo transparente, 512 por 512. O aplicativo
reduz na tela, então maior que isso só pesa o pacote.

## Como subir, sem terminal

**Link direto para a pasta certa, na branch certa:**

https://github.com/CodeByBrigido/NewBaby/upload/claude/meu-bebe-app-rsqz0a/assets/marcos

1. Abra o link acima
2. Arraste os dois PNG para a área de upload
3. Confira que os nomes são exatamente os da tabela, incluindo o hífen e o
   acento que não existe: `bolo-menina.png` e `bolo-menino.png`
4. **Commit changes**

Só isso. Nenhuma mudança de código é necessária: o cartão já procura por
esses dois caminhos, e passa a usá-los sozinho assim que eles existirem.

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

Uma imagem enviada na conversa com o assistente chega até ele como imagem
para olhar, e não como arquivo no disco do projeto. Ele consegue descrever o
que está vendo, mas não consegue devolver os bytes originais do PNG para
dentro do repositório, e redesenhar a arte à mão daria outro bolo, não o seu.

Por isso este passo é sempre manual, e por isso o desenho de reserva existe:
para o cartão nunca ficar com um buraco enquanto os arquivos não chegam.
