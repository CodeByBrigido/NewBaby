#!/usr/bin/env python3
"""Deriva a camada da frente do ícone adaptativo do Android.

A arte do ícone é um ladrilho completo: fundo terracota, marca em creme, e
os cantos em branco opaco, porque o PNG é retangular e o ladrilho não.

Isso serve para o ícone comum, mas não para o adaptativo. O Android 8 em
diante empilha duas camadas e recorta o conjunto na forma que cada
fabricante escolhe; a camada da frente entra encolhida sobre a de trás, e os
quatro cantos brancos aparecem como respingos ao redor do ladrilho.

Este script apaga só esses cantos. Ele não escolhe pixel por cor, e sim por
alcance: parte dos quatro cantos e vai comendo o branco que estiver
encostado neles. O creme da marca fica intacto por construção, porque está
cercado de terracota e não se alcança de fora.

A fonte continua sendo uma imagem só. Este arquivo é derivado dela, e deve
ser regerado sempre que ela mudar:

    python3 tool/gerar_frente_do_icone.py
    dart run flutter_launcher_icons
"""

from __future__ import annotations

import collections
import pathlib
import struct
import zlib

RAIZ = pathlib.Path(__file__).resolve().parent.parent
FONTE = RAIZ / "assets/images/icon/icon.png"
DESTINO = RAIZ / "assets/images/icon/icon_foreground.png"

# Quão perto do branco um pixel precisa estar para contar como fundo. Alto de
# propósito: o creme da marca fica bem abaixo disso, então não há risco de a
# limpeza entrar no desenho mesmo que ela chegasse até lá.
LIMIAR = 240


def ler_png(caminho: pathlib.Path) -> tuple[int, int, bytearray]:
    """Devolve largura, altura e os pixels RGBA, sem filtro."""
    dados = caminho.read_bytes()
    largura, altura = struct.unpack(">II", dados[16:24])
    profundidade, cor = dados[24], dados[25]
    if profundidade != 8 or cor not in (2, 6):
        raise SystemExit(f"{caminho.name}: esperado RGB ou RGBA de 8 bits")

    canais = 4 if cor == 6 else 3
    bruto = b""
    i = 8
    while i < len(dados):
        tamanho = struct.unpack(">I", dados[i:i + 4])[0]
        if dados[i + 4:i + 8] == b"IDAT":
            bruto += dados[i + 8:i + 8 + tamanho]
        i += 12 + tamanho

    linhas = zlib.decompress(bruto)
    passo = largura * canais + 1
    if any(linhas[y * passo] != 0 for y in range(altura)):
        raise SystemExit(f"{caminho.name}: PNG com filtro, não previsto aqui")

    pixels = bytearray(largura * altura * 4)
    for y in range(altura):
        origem = y * passo + 1
        for x in range(largura):
            o = origem + x * canais
            d = (y * largura + x) * 4
            pixels[d:d + 3] = linhas[o:o + 3]
            pixels[d + 3] = linhas[o + 3] if canais == 4 else 255
    return largura, altura, pixels


def escrever_png(caminho: pathlib.Path, largura: int, altura: int,
                 pixels: bytearray) -> None:
    def bloco(tipo: bytes, dados: bytes) -> bytes:
        return (struct.pack(">I", len(dados)) + tipo + dados
                + struct.pack(">I", zlib.crc32(tipo + dados) & 0xFFFFFFFF))

    linhas = bytearray()
    for y in range(altura):
        linhas.append(0)
        linhas += pixels[y * largura * 4:(y + 1) * largura * 4]

    caminho.write_bytes(
        b"\x89PNG\r\n\x1a\n"
        + bloco(b"IHDR", struct.pack(">IIBBBBB", largura, altura, 8, 6, 0, 0, 0))
        + bloco(b"IDAT", zlib.compress(bytes(linhas), 9))
        + bloco(b"IEND", b"")
    )


def limpar_cantos(largura: int, altura: int, pixels: bytearray) -> int:
    """Apaga o branco alcançável a partir dos quatro cantos."""

    def branco(i: int) -> bool:
        return all(pixels[i + c] >= LIMIAR for c in range(3))

    visto = bytearray(largura * altura)
    fila = collections.deque()
    for x, y in ((0, 0), (largura - 1, 0), (0, altura - 1),
                 (largura - 1, altura - 1)):
        fila.append((x, y))

    apagados = 0
    while fila:
        x, y = fila.popleft()
        if not (0 <= x < largura and 0 <= y < altura):
            continue
        n = y * largura + x
        if visto[n]:
            continue
        visto[n] = 1
        if not branco(n * 4):
            continue
        pixels[n * 4 + 3] = 0
        apagados += 1
        fila.extend(((x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)))
    return apagados


def main() -> None:
    largura, altura, pixels = ler_png(FONTE)
    apagados = limpar_cantos(largura, altura, pixels)
    escrever_png(DESTINO, largura, altura, pixels)

    total = largura * altura
    print(f"{DESTINO.relative_to(RAIZ)}: {largura}x{altura}, "
          f"{apagados} pixels transparentes ({apagados / total:.1%})")


if __name__ == "__main__":
    main()
