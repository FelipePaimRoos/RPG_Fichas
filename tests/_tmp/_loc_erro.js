const fs = require('fs');
const vm = require('vm');
const s = fs.readFileSync('ficha_rpg_completa.html', 'utf8');
const code = s.match(/<script[^>]*>([\s\S]*?)<\/script>/)[1];
const lines = code.split('\n');
console.log('total linhas do bloco:', lines.length);
// prefixos que compilam
function compila(n) {
  try { new vm.Script(lines.slice(0, n).join('\n') + '\n'); return true; }
  catch (e) { return false; }
}
// último prefixo que compila e depois o que falha com EOF:
let ultimaOK = 0;
for (let n = 10; n <= lines.length; n++) {
  if (compila(n)) ultimaOK = n;
}
console.log('último prefixo que compila:', ultimaOK);
// tentar compilar do fim para trás, variando início: encontra região problemática
console.log('--- linhas após', ultimaOK, '---');
for (let i = ultimaOK; i < Math.min(lines.length, ultimaOK + 15); i++)
  console.log((i + 1).toString().padStart(5), lines[i]);
// mensagem do erro no código completo
try { new vm.Script(code); }
catch (e) { console.log('ERRO COMPLETO:', e.message); }
