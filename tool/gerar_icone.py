#!/usr/bin/env python3
"""Gera o ícone do aplicativo para todas as densidades do Android.

O ícone é desenhado por código, e não guardado como imagem solta, para que
ele tenha fonte: daqui a dois anos dá para mudar a cor ou a forma editando
este arquivo, em vez de garimpar de onde saiu um PNG.

Sem dependência externa de propósito - o formato PNG é simples o bastante
para ser escrito à mão, e assim o ícone é reproduzível em qualquer máquina
que tenha Python.

    python3 tool/gerar_icone.py
"""

from __future__ import annotations

import math
import pathlib
import struct
import zlib

RAIZ = pathlib.Path(__file__).resolve().parent.parent
RES = RAIZ / "android/app/src/main/res"

# As duas pontas do degradê são cores que existem nas paletas do aplicativo:
# o lilás da menina e o azul do menino. O ícone é um só para todo mundo, e
# conter as duas identidades é melhor que escolher uma.
LILAS = (0x9B, 0x7B, 0xC4)
AZUL = (0x55, 0x89, 0xB5)

# Densidades do Android: o lançador usa o tamanho legado, e o adaptativo é
# o que o Android 8 em diante recorta na forma do aparelho.
DENSIDADES = {
    "mdpi": (48, 108),
    "hdpi": (72, 162),
    "xhdpi": (96, 216),
    "xxhdpi": (144, 324),
    "xxxhdpi": (192, 432),
}

SUPERAMOSTRAGEM = 4


def escrever_png(caminho: pathlib.Path, largura: int, altura: int,
                 pixels: bytearray) -> None:
    """Grava um PNG RGBA de 8 bits."""

    def bloco(tipo: bytes, dados: bytes) -> bytes:
        return (struct.pack(">I", len(dados)) + tipo + dados
                + struct.pack(">I", zlib.crc32(tipo + dados) & 0xFFFFFFFF))

    linhas = bytearray()
    for y in range(altura):
        linhas.append(0)  # filtro "nenhum"
        inicio = y * largura * 4
        linhas += pixels[inicio:inicio + largura * 4]

    caminho.parent.mkdir(parents=True, exist_ok=True)
    caminho.write_bytes(
        b"\x89PNG\r\n\x1a\n"
        + bloco(b"IHDR", struct.pack(">IIBBBBB", largura, altura, 8, 6, 0, 0, 0))
        + bloco(b"IDAT", zlib.compress(bytes(linhas), 9))
        + bloco(b"IEND", b"")
    )


def dentro_do_coracao(x: float, y: float) -> bool:
    """A curva clássica: (x² + y² - 1)³ - x²y³ ≤ 0."""
    return (x * x + y * y - 1) ** 3 - x * x * y * y * y <= 0


def desenhar(tamanho: int, *, com_fundo: bool, margem: float) -> bytearray:
    """Desenha o ícone.

    [margem] é a fração do lado que fica vazia em volta da marca. O ícone
    adaptativo precisa de margem generosa: o Android recorta as bordas na
    forma que o fabricante escolheu, e o que estiver perto da borda some.
    """
    s = SUPERAMOSTRAGEM
    grande = tamanho * s
    pixels = bytearray(tamanho * tamanho * 4)

    raio_canto = grande * 0.22  # canto arredondado do ícone legado
    centro = grande / 2
    raio_anel = grande * (0.5 - margem)
    # A curva do coração chega a 1.2 no eixo x, então a escala é dividida
    # por isso para que a largura final seja a fração pedida do anel.
    escala_coracao = raio_anel * 0.52 / 1.2
    # A curva não é simétrica no eixo vertical: a ponta de baixo desce mais
    # que os lóbulos sobem. Sem este empurrão o coração fica alto no anel.
    desvio_coracao = raio_anel * 0.07
    espessura_anel = max(1.0, grande * 0.026)

    for py in range(tamanho):
        for px in range(tamanho):
            soma = [0.0, 0.0, 0.0, 0.0]
            for sy in range(s):
                for sx in range(s):
                    gx = px * s + sx + 0.5
                    gy = py * s + sy + 0.5

                    r = g = b = 0.0
                    a = 0.0

                    if com_fundo and _no_retangulo(gx, gy, grande, raio_canto):
                        # Degradê na diagonal, do lilás ao azul.
                        t = (gx + gy) / (2 * grande)
                        r = LILAS[0] + (AZUL[0] - LILAS[0]) * t
                        g = LILAS[1] + (AZUL[1] - LILAS[1]) * t
                        b = LILAS[2] + (AZUL[2] - LILAS[2]) * t
                        a = 255.0

                    dx = gx - centro
                    dy = gy - centro
                    dist = math.hypot(dx, dy)

                    # O anel evoca ao mesmo tempo um relicário e um mostrador
                    # de relógio. Fino, para não competir com o coração.
                    no_anel = abs(dist - raio_anel) <= espessura_anel / 2
                    # Coração: o eixo y da curva cresce para cima.
                    hx = dx / escala_coracao
                    hy = -(dy - desvio_coracao) / escala_coracao
                    no_coracao = dentro_do_coracao(hx, hy)

                    if no_anel or no_coracao:
                        r = g = b = 255.0
                        a = 255.0

                    soma[0] += r
                    soma[1] += g
                    soma[2] += b
                    soma[3] += a

            n = s * s
            i = (py * tamanho + px) * 4
            alfa = soma[3] / n
            pixels[i] = int(soma[0] / n)
            pixels[i + 1] = int(soma[1] / n)
            pixels[i + 2] = int(soma[2] / n)
            pixels[i + 3] = int(alfa)

    return pixels


def _no_retangulo(x: float, y: float, lado: float, raio: float) -> bool:
    """Retângulo de cantos arredondados cobrindo o quadro todo."""
    cx = min(max(x, raio), lado - raio)
    cy = min(max(y, raio), lado - raio)
    return math.hypot(x - cx, y - cy) <= raio


def main() -> None:
    for densidade, (legado, adaptativo) in DENSIDADES.items():
        pasta = RES / f"mipmap-{densidade}"

        # Ícone legado (Android 7 e anteriores): quadrado arredondado inteiro.
        escrever_png(pasta / "ic_launcher.png", legado, legado,
                     desenhar(legado, com_fundo=True, margem=0.16))

        # Ícone adaptativo: fundo e marca em camadas separadas, porque o
        # Android as move de forma independente para dar profundidade.
        escrever_png(pasta / "ic_launcher_fundo.png", adaptativo, adaptativo,
                     desenhar(adaptativo, com_fundo=True, margem=0.0))
        escrever_png(pasta / "ic_launcher_marca.png", adaptativo, adaptativo,
                     desenhar(adaptativo, com_fundo=False, margem=0.30))

        print(f"mipmap-{densidade}: {legado}px legado, {adaptativo}px adaptativo")

    anydpi = RES / "mipmap-anydpi-v26"
    anydpi.mkdir(parents=True, exist_ok=True)
    (anydpi / "ic_launcher.xml").write_text(
        '<?xml version="1.0" encoding="utf-8"?>\n'
        '<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">\n'
        '    <background android:drawable="@mipmap/ic_launcher_fundo" />\n'
        '    <foreground android:drawable="@mipmap/ic_launcher_marca" />\n'
        '</adaptive-icon>\n'
    )
    print("mipmap-anydpi-v26/ic_launcher.xml")


if __name__ == "__main__":
    main()
