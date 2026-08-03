#!/usr/bin/env python3
"""Confere a configuração do Firebase antes de gastar dez minutos compilando.

Um `firebase_options.dart` preenchido pela metade compila, instala e só então
falha - o Firebase não valida essas chaves na inicialização, e o aplicativo
abre para dar erro longe da causa. Melhor recusar aqui.

A checagem é por bloco, e isso importa: quem constrói um APK Android não
precisa ter preenchido o bloco do iOS. Reprovar o build por causa de um campo
que aquele APK nem lê seria travar alguém por nada.
"""

from __future__ import annotations

import json
import re
import sys

# Valores que vêm no arquivo de exemplo. Se algum sobreviver num bloco que
# importa, a configuração está incompleta.
EXEMPLOS = {
    "SEU_WEB_CLIENT_ID": (
        "o serverClientId, que é o ID do cliente OAuth do tipo Aplicativo da "
        "Web. Sem ele o login falha no Android."
    ),
    "SUA_API_KEY_ANDROID": (
        "a apiKey. Está em client[0].api_key[0].current_key, no "
        "google-services.json."
    ),
    "SUA_API_KEY_IOS": "a apiKey do iOS.",
    "seu-projeto-firebase": (
        "o projectId e o storageBucket. Estão em project_info, no "
        "google-services.json."
    ),
    "1:000000000000": (
        "o appId. Está em client[0].client_info.mobilesdk_app_id, no "
        "google-services.json."
    ),
}


def bloco(fonte: str, nome: str) -> str:
    """O corpo de `static const FirebaseOptions <nome> = FirebaseOptions(...)`."""
    achado = re.search(
        rf"{nome}\s*=\s*FirebaseOptions\((.*?)\);", fonte, re.S
    )
    return achado.group(1) if achado else ""


def campo(corpo: str, nome: str) -> str | None:
    achado = re.search(rf"{nome}:\s*'([^']*)'", corpo)
    return achado.group(1) if achado else None


def main() -> int:
    plataforma = sys.argv[1] if len(sys.argv) > 1 else "android"
    fonte = open("lib/firebase_options.dart", encoding="utf-8").read()

    if "class DefaultFirebaseOptions" not in fonte:
        print("::error::lib/firebase_options.dart não parece o arquivo certo.")
        print("  O base64 do segredo FIREBASE_OPTIONS_DART pode ter vindo truncado.")
        return 1

    alvo = bloco(fonte, plataforma)
    if not alvo:
        print(f"::error::Não encontrei o bloco `{plataforma}` no firebase_options.dart.")
        return 1

    # O serverClientId vive fora dos blocos e vale para as duas plataformas.
    achado_id = re.search(r"serverClientId\s*=\s*\n?\s*'([^']*)'", fonte)
    server_client_id = achado_id.group(1) if achado_id else ""

    erros = 0
    for marca, explicacao in EXEMPLOS.items():
        if marca in alvo or marca in server_client_id:
            print(f'::error::O firebase_options.dart ainda tem o valor de exemplo "{marca}".')
            print(f"  Esse campo é {explicacao}")
            erros += 1

    # O projectId dos dois arquivos tem que ser o mesmo projeto. Quando
    # divergem, o aplicativo abre e falha depois, na primeira consulta -
    # longe da causa. É o erro mais fácil de cometer com mais de um projeto
    # Firebase na conta.
    with open("android/app/google-services.json", encoding="utf-8") as arquivo:
        do_json = json.load(arquivo)["project_info"]["project_id"]
    do_dart = campo(alvo, "projectId")

    if do_dart != do_json:
        print("::error::Os dois arquivos são de projetos Firebase diferentes.")
        print(f"  google-services.json: {do_json}")
        print(f"  firebase_options.dart ({plataforma}): {do_dart}")
        print("  Baixe os dois do mesmo projeto e atualize os dois segredos.")
        erros += 1

    if erros:
        print()
        print("Corrija o arquivo, gere o base64 de novo e atualize o segredo")
        print("FIREBASE_OPTIONS_DART. Veja o passo 7 do INSTALAR.md.")
        return 1

    # O outro bloco não impede este build, mas avisar evita a surpresa no dia
    # em que alguém tentar compilar para ele.
    outro = "ios" if plataforma == "android" else "android"
    corpo_outro = bloco(fonte, outro)
    if any(marca in corpo_outro for marca in EXEMPLOS):
        print(
            f"::notice::O bloco `{outro}` ainda tem valores de exemplo. Não "
            f"afeta este build, que é {plataforma}, mas precisará ser "
            f"preenchido antes de compilar para {outro}."
        )

    print(f"Configuração do Firebase conferida: projeto {do_json} ({plataforma}).")
    return 0


if __name__ == "__main__":
    sys.exit(main())
