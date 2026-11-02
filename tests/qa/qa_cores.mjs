export default async function run(page, ui) {
  const results = {};
  const user = 'qauser' + Math.floor(Math.random() * 100000);
  const pass = 'SenhaForte123!';

  // Register + create sheet (defensive regex on all clicks)
  let s = await ui.snapshot();
  const tab = s.match(/@(e\d+) tab "Criar conta"/)?.[1];
  if (tab) await ui.click(tab);
  await page.waitForTimeout(300);
  await page.evaluate(([u, p]) => {
    document.getElementById('auth-username').value = u;
    document.getElementById('auth-password').value = p;
  }, [user, pass]);
  s = await ui.snapshot();
  const btnAuth = s.match(/@(e\d+) button "(Registrar|Criar)[^"]*"/i)?.[1];
  if (btnAuth) await ui.click(btnAuth);
  await page.waitForTimeout(2500);

  await page.evaluate(() => {
    const inp = document.querySelector('#character-dashboard input');
    inp.value = 'QA Cores Ritual';
    inp.dispatchEvent(new Event('input', { bubbles: true }));
  });
  s = await ui.snapshot();
  const btnCriar = s.match(/@(e\d+) button "Criar ficha"/)?.[1];
  if (!btnCriar) return { error: 'no criar ficha', s };
  await ui.click(btnCriar);
  await page.waitForTimeout(2500);

  // Open ritual modal
  s = await ui.snapshot();
  const btnRitual = s.match(/@(e\d+) button "\+ Novo Ritual"/)?.[1];
  if (!btnRitual) return { error: 'no novo ritual', s };
  await ui.click(btnRitual);
  await page.waitForTimeout(2000);

  // Add first two rituals
  for (let i = 0; i < 2; i++) {
    s = await ui.snapshot();
    const add = s.match(/@(e\d+) button "Adicionar"/)?.[1];
    if (!add) break;
    await ui.click(add);
    await page.waitForTimeout(400);
  }

  results.grid = await page.evaluate(() =>
    Array.from(document.querySelectorAll('#grid-rituais .card-item')).map(d => ({
      nome: d.querySelector('.card-title')?.innerText,
      classes: d.className
    }))
  );

  const sec = await page.locator('#grid-rituais').boundingBox();
  if (sec) {
    await page.screenshot({ path: 'rituais_cores.png', clip: { x: 0, y: Math.max(0, sec.y - 60), width: 1280, height: Math.min(sec.height + 120, 800) } });
  }
  return results;
}
