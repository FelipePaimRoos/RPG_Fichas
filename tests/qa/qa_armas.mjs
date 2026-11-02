export default async function run(page, ui) {
  const results = {};
  const user = 'qauser' + Math.floor(Math.random() * 100000);
  const pass = 'SenhaForte123!';

  page.on('dialog', async dialog => { await dialog.accept(); });

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
    inp.value = 'QA Armas 2';
    inp.dispatchEvent(new Event('input', { bubbles: true }));
  });
  s = await ui.snapshot();
  await ui.click(s.match(/@(e\d+) button "Criar ficha"/)?.[1]);
  await page.waitForTimeout(2500);

  // Abrir modal de armas
  await ui.click((await ui.snapshot()).match(/@(e\d+) button "\+ Adicionar Arma"/)?.[1]);
  await page.waitForTimeout(500);
  await page.evaluate(() => {
    if (typeof filtrarArmas !== 'function') {
      window.eval(document.querySelector('script').textContent);
      abrirModalArmas();
    }
  });
  await page.waitForFunction(() =>
    document.getElementById('listaCatalogoArmas') &&
    document.getElementById('listaCatalogoArmas').querySelector('button')
    , { timeout: 15000 });

  // Filtrar por proficiência "Simples"
  await ui.click((await ui.snapshot()).match(/@(e\d+) button "Simples"/)?.[1]);
  await page.waitForTimeout(300);
  results.simples = await page.evaluate(() => (window.armasExibidas || []).length);
  results.exemplosSimples = await page.evaluate(() => (window.armasExibidas || []).slice(0, 5).map(a => a.nome));
  results.total = await page.evaluate(() => (window.todasArmas || []).length);
  results.exemplosSimples = await page.evaluate(() => (window.armasExibidas || []).slice(0, 5).map(a => a.nome));

  // Filtrar por tipo "corpo a corpo"
  await page.evaluate(() => {
    const sel = document.getElementById('arma-tipo-filter');
    sel.value = 'corpo a corpo';
    sel.dispatchEvent(new Event('change', { bubbles: true }));
  });
  await page.waitForTimeout(300);
  results.qtdSimplesCorpoACorpo = await page.evaluate(() => (window.armasExibidas || []).length);

  // Limpar filtros e adicionar a primeira arma
  await ui.click((await ui.snapshot()).match(/@(e\d+) button "Todas"/)?.[1]);
  await page.evaluate(() => {
    const sel = document.getElementById('arma-tipo-filter');
    sel.value = '';
    const busca = document.getElementById('armaBusca');
    busca.value = '';
    filtrarArmas();
  });
  await page.waitForTimeout(300);
  await ui.click((await ui.snapshot()).match(/@(e\d+) button "Adicionar"/)?.[1]);
  await page.waitForTimeout(500);

  results.inventario = await page.evaluate(() => {
    const tr = document.querySelector('#tabela-itens tr');
    if (!tr) return null;
    const desc = tr.querySelector('td:nth-child(3) textarea')?.value || '';
    return {
      nome: tr.querySelector('td:nth-child(1) input')?.value,
      espaco: tr.querySelector('td:nth-child(2) input')?.value,
      descInicio: desc.slice(0, 130),
      temHabilidades: desc.includes('Ágil')
    };
  });
  results.modalFechado = await page.evaluate(() =>
    getComputedStyle(document.getElementById('modal-arma')).display === 'none'
  );

  return results;
}
