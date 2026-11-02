export default async function run(page, ui) {
  const erros = [];
  page.on('pageerror', e => erros.push(String(e)));
  await page.reload({ waitUntil: 'load' });
  await page.fill('#auth-username', 'testeqa');
  await page.fill('#auth-password', 'senhateste123');
  const [resp] = await Promise.all([
    page.waitForResponse(r => r.url().includes('/api/auth/login'), { timeout: 8000 }).catch(() => null),
    page.click('#auth-submit'),
  ]);
  await page.waitForTimeout(1500);
  return {
    loginStatus: resp ? resp.status() : 'sem requisição',
    authenticated: await page.evaluate(() => document.body.classList.contains('authenticated')),
    authMessage: await page.evaluate(() => document.getElementById('auth-message')?.textContent),
    errosPagina: erros,
  };
}
