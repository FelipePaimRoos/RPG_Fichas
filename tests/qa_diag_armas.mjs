w2export default async function run(page, ui) {
  await page.goto('http://localhost:8123', { waitUntil: 'domcontentloaded' });
  await page.waitForTimeout(1000);
  const res = await page.evaluate(async () => {
    window.eval(document.querySelector('script').textContent);
    abrirModalArmas();
    await new Promise(r => setTimeout(r, 1500));

    // Depois de mudar o select, chamar filtrarArmas DIRETAMENTE (sem dispatch)
    const sel = document.getElementById('arma-tipo-filter');
    sel.value = 'disparo';
    filtrarArmas(); // chamada direta
    const qtdDireta = (window.armasExibidas || []).length;
    const primeiroDireta = window.armasExibidas[0]?.nome;

    // E agora via dispatchEvent
    sel.value = 'corpo a corpo';
    sel.dispatchEvent(new Event('change', { bubbles: true }));
    await new Promise(r => setTimeout(r, 200));
    const qtdDispatch = (window.armasExibidas || []).length;
    const primeiroDispatch = window.armasExibidas[0]?.nome;

    return { qtdDireta, primeiroDireta, qtdDispatch, primeiroDispatch };
  });
  return { res };
}
