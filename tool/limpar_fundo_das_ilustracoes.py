#!/usr/bin/env python3
"""Deixa transparente o fundo das ilustrações da apresentação.

As artes chegaram como PNG sem canal alfa, com o fundo em branco opaco. O
fundo das telas vem da paleta do Design System, que é um creme, então cada
ilustração aparecia como um retângulo branco recortado no meio da tela.

A saída não pinta o creme dentro da imagem: **apaga o fundo**. É melhor que
pintar, porque a paleta muda com o sexo da criança e a apresentação pode ser
revista pelo Sobre depois do cadastro. Com o fundo transparente, é sempre a
cor do Design System que aparece, qualquer que seja ela.

A limpeza parte das quatro bordas e vai comendo o branco encostado nelas.
Não escolhe pixel por cor, e sim por alcance: o branco de dentro do desenho,
como o brilho de uma estrela ou a moldura de uma foto, está cercado de
traço e não se alcança de fora.

Roda de novo sem estragar nada: onde já é transparente não há o que apagar.

Trabalha sobre PNG, e vem **antes** da conversão para WebP. A ordem importa:
o recorte precisa acontecer no arquivo sem perda, senão o contorno do
desenho entra na conta do compressor com o fundo ainda ali.

    python3 tool/limpar_fundo_das_ilustracoes.py
    node tool/converter_para_webp.mjs
"""

from __future__ import annotations

import collections
import pathlib
import struct
import zlib

RAIZ = pathlib.Path(__file__).resolve().parent.parent
PASTA = RAIZ / "assets/images/onboarding"

# Quão perto do branco um pixel precisa estar para contar como fundo.
#
# Folgado de propósito. O contorno das artes tem meio tom de anti-serrilhado
# entre o branco e o traço; um limiar apertado deixaria uma auréola clara em
# volta de cada desenho, que sobre o creme fica mais visível que o próprio
# retângulo que estamos tirando.
LIMIAR = 236


def ler_png(caminho: pathlib.Path) -> tuple[int, int, bytearray]:
    """Devolve largura, altura e os pixels RGBA, já sem filtro de linha."""
    dados = caminho.read_bytes()
    largura, altura = struct.unpack(">II", dados[16:24])
    profundidade, tipo = dados[24], dados[25]
    if profundidade != 8 or tipo not in (2, 6):
        raise SystemExit(f"{caminho.name}: esperado RGB ou RGBA de 8 bits")

    canais = 4 if tipo == 6 else 3
    bruto = b""
    i = 8
    while i < len(dados):
        tamanho = struct.unpack(">I", dados[i:i + 4])[0]
        if dados[i + 4:i + 8] == b"IDAT":
            bruto += dados[i + 8:i + 8 + tamanho]
        i += 12 + tamanho

    linhas = zlib.decompress(bruto)
    passo = largura * canais
    saida = bytearray(largura * altura * 4)
    anterior = bytearray(passo)
    pos = 0

    for y in range(altura):
        filtro = linhas[pos]
        pos += 1
        atual = bytearray(linhas[pos:pos + passo])
        pos += passo

        # Desfaz o filtro da linha, como manda a especificação do PNG.
        if filtro:
            for x in range(passo):
                a = atual[x - canais] if x >= canais else 0
                b = anterior[x]
                c = anterior[x - canais] if x >= canais else 0
                if filtro == 1:
                    atual[x] = (atual[x] + a) & 255
                elif filtro == 2:
                    atual[x] = (atual[x] + b) & 255
                elif filtro == 3:
                    atual[x] = (atual[x] + (a + b) // 2) & 255
                else:
                    pa, pb, pc = abs(b - c), abs(a - c), abs(a + b - 2 * c)
                    perto = a if (pa <= pb and pa <= pc) else (b if pb <= pc else c)
                    atual[x] = (atual[x] + perto) & 255

        for x in range(largura):
            o = x * canais
            d = (y * largura + x) * 4
            saida[d:d + 3] = atual[o:o + 3]
            saida[d + 3] = atual[o + 3] if canais == 4 else 255

        anterior = atual

    return largura, altura, saida


def escrever_png(caminho: pathlib.Path, largura: int, altura: int,
                 pixels: bytearray) -> None:
    def bloco(tipo: bytes, dados: bytes) -> bytes:
        return (struct.pack(">I", len(dados)) + tipo + dados
                + struct.pack(">I", zlib.crc32(tipo + dados) & 0xFFFFFFFF))

    # Filtro Paeth em todas as linhas. Escrever sem filtro é mais simples e
    # sai caro: a imagem cresce quase o dobro, e o aplicativo carrega isso
    # para sempre. Paeth prevê cada byte pelos vizinhos de cima e da
    # esquerda, e sobra pouco para o zlib comprimir.
    passo = largura * 4
    linhas = bytearray()
    anterior = bytearray(passo)
    for y in range(altura):
        atual = pixels[y * passo:(y + 1) * passo]
        linhas.append(4)
        for x in range(passo):
            a = atual[x - 4] if x >= 4 else 0
            b = anterior[x]
            c = anterior[x - 4] if x >= 4 else 0
            pa, pb, pc = abs(b - c), abs(a - c), abs(a + b - 2 * c)
            perto = a if (pa <= pb and pa <= pc) else (b if pb <= pc else c)
            linhas.append((atual[x] - perto) & 255)
        anterior = atual

    caminho.write_bytes(
        b"\x89PNG\r\n\x1a\n"
        + bloco(b"IHDR", struct.pack(">IIBBBBB", largura, altura, 8, 6, 0, 0, 0))
        + bloco(b"IDAT", zlib.compress(bytes(linhas), 9))
        + bloco(b"IEND", b"")
    )


def apagar_fundo(largura: int, altura: int, pixels: bytearray) -> int:
    """Apaga o claro alcançável a partir das quatro bordas."""

    def claro(n: int) -> bool:
        i = n * 4
        return (pixels[i + 3] > 0
                and all(pixels[i + c] >= LIMIAR for c in range(3)))

    visto = bytearray(largura * altura)
    fila: collections.deque[tuple[int, int]] = collections.deque()
    for x in range(largura):
        fila.append((x, 0))
        fila.append((x, altura - 1))
    for y in range(altura):
        fila.append((0, y))
        fila.append((largura - 1, y))

    apagados = 0
    while fila:
        x, y = fila.popleft()
        if not (0 <= x < largura and 0 <= y < altura):
            continue
        n = y * largura + x
        if visto[n]:
            continue
        visto[n] = 1
        if not claro(n):
            continue
        pixels[n * 4 + 3] = 0
        apagados += 1
        fila.extend(((x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)))
    return apagados


def main() -> None:
    for caminho in sorted(PASTA.glob("onboarding_*.png")):
        antes = caminho.stat().st_size
        largura, altura, pixels = ler_png(caminho)
        apagados = apagar_fundo(largura, altura, pixels)
        escrever_png(caminho, largura, altura, pixels)
        depois = caminho.stat().st_size
        fracao = apagados / (largura * altura)
        print(f"{caminho.name}: {fracao:5.1%} do quadro virou fundo, "
              f"{antes / 1024:.0f} KB -> {depois / 1024:.0f} KB")


if __name__ == "__main__":
    main()
