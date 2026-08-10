#!/usr/bin/env python3
"""Ilustrações provisórias das cinco telas de apresentação.

**Estes arquivos são para jogar fora.** Eles existem por um motivo só: o
Flutter recusa a compilação quando o `pubspec.yaml` declara uma pasta de
imagens que não existe, e sem eles o projeto não compilaria enquanto a arte
definitiva não chegasse.

Por isso eles são de propósito feios e vazios: um contorno tracejado e a
contagem da tela em bolinhas. Ninguém olha para isso e acha que é a arte
final, que é exatamente o que se quer de um provisório.

Para substituir, basta salvar as imagens de verdade por cima:

    assets/images/onboarding/onboarding_1.png ... onboarding_5.png

Nenhuma linha de Dart muda: os caminhos são os mesmos.

    python3 tool/gerar_ilustracoes.py
"""

from __future__ import annotations

import math
import pathlib
import struct
import zlib

RAIZ = pathlib.Path(__file__).resolve().parent.parent
DESTINO = RAIZ / "assets/images/onboarding"

LADO = 600
MARGEM = 40
TRACO = 6

# A cor de marca da paleta neutra, que é a que vale antes do cadastro.
MARCA = (0xD2, 0x65, 0x4E)


def escrever_png(caminho: pathlib.Path, lado: int, pixels: bytearray) -> None:
    """Grava um PNG RGBA de 8 bits."""

    def bloco(tipo: bytes, dados: bytes) -> bytes:
        return (struct.pack(">I", len(dados)) + tipo + dados
                + struct.pack(">I", zlib.crc32(tipo + dados) & 0xFFFFFFFF))

    linhas = bytearray()
    for y in range(lado):
        linhas.append(0)  # filtro "nenhum"
        linhas += pixels[y * lado * 4:(y + 1) * lado * 4]

    caminho.parent.mkdir(parents=True, exist_ok=True)
    caminho.write_bytes(
        b"\x89PNG\r\n\x1a\n"
        + bloco(b"IHDR", struct.pack(">IIBBBBB", lado, lado, 8, 6, 0, 0, 0))
        + bloco(b"IDAT", zlib.compress(bytes(linhas), 9))
        + bloco(b"IEND", b"")
    )


def _na_moldura(x: float, y: float) -> bool:
    """Contorno tracejado de um retângulo com cantos arredondados."""
    raio = 48.0
    a, b = MARGEM, LADO - MARGEM
    cx = min(max(x, a + raio), b - raio)
    cy = min(max(y, a + raio), b - raio)
    dist = math.hypot(x - cx, y - cy)

    dentro_da_borda = abs(dist - raio) <= TRACO / 2 if (
        x < a + raio or x > b - raio) and (y < a + raio or y > b - raio) else (
        (abs(x - a) <= TRACO / 2 or abs(x - b) <= TRACO / 2) and a <= y <= b
        or (abs(y - a) <= TRACO / 2 or abs(y - b) <= TRACO / 2) and a <= x <= b)
    if not dentro_da_borda:
        return False

    # Tracejado: 28 pixels de traço a cada 44 de perímetro percorrido.
    return ((x + y) % 44) < 28


def _nas_bolinhas(x: float, y: float, quantas: int) -> bool:
    """A contagem da tela, em bolinhas centralizadas embaixo."""
    raio = 14.0
    passo = raio * 3
    largura = passo * (quantas - 1)
    base_x = LADO / 2 - largura / 2
    base_y = LADO * 0.62
    return any(
        math.hypot(x - (base_x + i * passo), y - base_y) <= raio
        for i in range(quantas)
    )


def desenhar(numero: int) -> bytearray:
    pixels = bytearray(LADO * LADO * 4)
    for py in range(LADO):
        for px in range(LADO):
            x, y = px + 0.5, py + 0.5
            if _na_moldura(x, y) or _nas_bolinhas(x, y, numero):
                i = (py * LADO + px) * 4
                pixels[i], pixels[i + 1], pixels[i + 2] = MARCA
                pixels[i + 3] = 0x66  # apagado, para não parecer definitivo
    return pixels


def main() -> None:
    for n in range(1, 6):
        caminho = DESTINO / f"onboarding_{n}.png"
        escrever_png(caminho, LADO, desenhar(n))
        print(f"provisório: {caminho.relative_to(RAIZ)}")


if __name__ == "__main__":
    main()
