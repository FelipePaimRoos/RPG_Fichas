export default async function run(page, ui) {
  const results = {};
  const user = 'qauser' + Math.floor(Math.random() * 100000);
  const pass = 'SenhaForte123!';

  page.on('dialog', async dialog => {
    results.dialogType = dialog.type();
    results.promptMessage = dialog.message().slice(0, 140);
    await dialog.accept('morte');
  });

  let s = await ui.snapshot();
  const tab = s.match(/@(e\d+) tab "Criar conta"/)?.[1];
  if (tab) await ui.click(tab);
  await page.waitForTimeout(300);
  await page.evaluate(([u, p]) => {
    document.getElementById('auth-username').value = u;
    document.getElementById('auth-password').value = p;
  }, [user, pass]);
  s = await ui.snapshot();
  await ui.click(s.match(/@(e\d+) button "(Registrar|Criar)[^"]*"/i)?.[1]);
  await page.waitForTimeout(2500);

  await page.evaluate(() => {
    const inp = document.querySelector('#character-dashboard input');
    inp.value = 'QA Multi 3';
    inp.dispatchEvent(new Event('input', { bubbles: true }));
  });
  s = await ui.snapshot();
  await ui.click(s.match(/@(e\d+) button "Criar ficha"/)?.[1]);
  await page.waitForTimeout(2500);

  await ui.click((await ui.snapshot()).match(/@(e\d+) button "\+ Novo Ritual"/)?.[1]);
  // esperar catálogo carregar de verdade
  await page.waitForFunction(() =>
    document.getElementById('listaCatalogoRituais') &&
    document.getElementById('listaCatalogoRituais').querySelector('button')
    , { timeout: 15000 });
  await page.waitForTimeout(300);
  await page.evaluate(() => {
    const busca = document.getElementById('ritualBusca');
    busca.value = 'amaldiçoar';
    busca.dispatchEvent(new Event('input', { bubbles: true }));
  });
  await page.waitForTimeout(300);

  results.antes = await page.evaluate(() => {
    // Garantir que o script da página executou (headless nem sempre roda inline)
    if (!window.listas || !window.listas.ritual) {
      window.eval(document.querySelector('script').textContent);
    }
    const exibidos = window.rituaisExibidos || [];
    const tipoListas = typeof window.listas;
    let infoExtra = '—';
    try { infoExtra = window.listas ? JSON.stringify(Object.keys(window.listas)) : 'sem'; } catch (e) {}
    let temRitual = '—';
    try { temRitual = window.listas ? ('ritual' in window.listas) : 'sem'; } catch (e) {}
    return {
      qtd: exibidos.length,
      primeiro: exibidos[0] ? { nome: exibidos[0].nome, elemento: exibidos[0].elemento } : null,
      listasTipo: tipoListas,
      listasKeys: infoExtra,
      temRitual
    };
  });

  results.antesJSON = JSON.stringify(results.antes);

  s = await ui.snapshot();
  const addBtn = s.match(/@(e\d+) button "Adicionar"/)?.[1];
  if (!addBtn) return { error: 'sem botão adicionar', s, catalogo: results.catalogoEstado };
  await ui.click(addBtn);
  await page.waitForTimeout(1500);

  results.catalogoApos = await page.evaluate(() => {
    const l = window.listas;
    if (!l || !l.ritual) return { erro: 'listas/ritual indefinido após eval' };
    return {
      modalAberto: getComputedStyle(document.getElementById('modal-ritual')).display !== 'none',
      qtdNaLista: Array.isArray(l.ritual) ? l.ritual.length : 'não-array',
      itemSalvo: Array.isArray(l.ritual) && l.ritual[0] ? {
        nome: l.ritual[0].nome,
        elemento: l.ritual[0].elemento,
        efeitoInicio: (l.ritual[0].efeito || '').slice(0, 60)
      } : null
    };
  });

  results.grid = await page.evaluate(() => {
    const l = window.listas;
    if (!l || !Array.isArray(l.ritual)) return { erro: 'sem listas' };
    return Array.from(document.querySelectorAll('#grid-rituais .card-item')).map(d => ({
      nome: d.querySelector('.card-title')?.innerText,
      classes: d.className
    }));
  });
  return results;
}
