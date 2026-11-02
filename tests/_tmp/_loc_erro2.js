let acorn;
try { acorn = require('acorn'); }
catch (e) { console.log('NO_ACORN'); process.exit(2); }
const fs = require('fs');
const s = fs.readFileSync('ficha_rpg_completa.html', 'utf8');
const code = s.match(/<script[^>]*>([\s\S]*?)<\/script>/)[1];
const lines = code.split('\n');
// varredura incremental: tenta parsear cada trecho, detecta profundidade de chaves
// usa acorn loose para tolerância
let depthReport = [];
for (let n = 50; n <= lines.length; n += 50) {
  const chunk = lines.slice(0, n).join('\n');
  let depth = 0, inStr = null, inTpl = false, inCmt = false, inLineCmt = false;
  // fallback: conta bruta com acorn walk? Simples: contagem via tokens do acorn
  try { acorn.parse(chunk, { ecmaVersion: 2022 }); depthReport.push([n, 'OK']); }
  catch (e) { depthReport.push([n, e.message.slice(0, 40)]); }
}
depthReport.forEach(([n, msg]) => console.log(n, msg));
