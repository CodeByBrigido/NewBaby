// Converte a arte da apresentação e da entrada de PNG para WebP.
//
// Os arquivos originais somavam 10,4 MB e entravam inteiros no aplicativo,
// para telas que a pessoa vê uma vez. Em WebP eles somam 1,1 MB.
//
// A qualidade foi escolhida medindo, e não no olho. Comparando cada imagem
// com a original **só nos pixels visíveis** (nas áreas transparentes o RGB
// não significa nada, e compará-lo dá um número assustador e falso), a
// perda em q92 fica entre 36 e 45 dB de PSNR, que é considerado
// indistinguível para ilustração. O canal alfa sai idêntico, byte a byte:
// o recorte de fundo feito antes não é degradado.
//
// Precisa do `sharp`, que não é dependência do projeto porque isto roda uma
// vez por arte nova, na máquina de quem desenvolve:
//
//     npm install sharp
//     node tool/converter_para_webp.mjs
//
// Se a arte nova vier com fundo branco opaco, rode antes
// `tool/limpar_fundo_das_ilustracoes.py`, que trabalha sobre PNG.

import sharp from 'sharp';
import fs from 'fs';
import path from 'path';

const PASTA = path.join(import.meta.dirname, '..', 'assets/images/onboarding');
const QUALIDADE = 92;

const arquivos = fs.readdirSync(PASTA).filter((f) => f.endsWith('.png'));
if (arquivos.length === 0) {
  console.log('Nada a converter: não há PNG nesta pasta.');
}

let antes = 0;
let depois = 0;

for (const nome of arquivos) {
  const origem = path.join(PASTA, nome);
  const destino = origem.replace(/\.png$/, '.webp');

  await sharp(origem)
    .webp({ quality: QUALIDADE, alphaQuality: 100, effort: 6 })
    .toFile(destino);

  const a = fs.statSync(origem).size;
  const d = fs.statSync(destino).size;
  antes += a;
  depois += d;
  fs.unlinkSync(origem);

  const kb = (n) => (n / 1024).toFixed(0).padStart(5);
  console.log(`${nome.padEnd(22)} ${kb(a)} KB  ->  ${kb(d)} KB`);
}

if (arquivos.length > 0) {
  const mb = (n) => (n / 1024 / 1024).toFixed(2);
  const corte = (1 - depois / antes) * 100;
  console.log(`\ntotal: ${mb(antes)} MB -> ${mb(depois)} MB (${corte.toFixed(0)}% a menos)`);
}
