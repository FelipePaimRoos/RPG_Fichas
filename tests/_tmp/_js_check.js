
const PERICIAS_BASE = [
  { nome: "Acrobacia", atr: "Agilidade", carga: true, treinado: false, cat: "1. Perícias Físicas (Mobilidade e Operação)" },
  { nome: "Atletismo", atr: "Força", carga: false, treinado: false, cat: "1. Perícias Físicas (Mobilidade e Operação)" },
  { nome: "Crime", atr: "Agilidade", carga: true, treinado: true, cat: "1. Perícias Físicas (Mobilidade e Operação)" },
  { nome: "Furtividade", atr: "Agilidade", carga: true, treinado: false, cat: "1. Perícias Físicas (Mobilidade e Operação)" },
  { nome: "Pilotagem", atr: "Agilidade", carga: false, treinado: true, cat: "1. Perícias Físicas (Mobilidade e Operação)" },
  { nome: "Iniciativa", atr: "Agilidade", carga: false, treinado: false, cat: "2. Perícias de Combate (Ofensiva e Prontidão)" },
  { nome: "Luta", atr: "Força", carga: false, treinado: false, cat: "2. Perícias de Combate (Ofensiva e Prontidão)" },
  { nome: "Pontaria", atr: "Agilidade", carga: false, treinado: false, cat: "2. Perícias de Combate (Ofensiva e Prontidão)" },
  { nome: "Fortitude", atr: "Vigor", carga: false, treinado: false, cat: "3. Perícias de Resistência (Tríade Defensiva)" },
  { nome: "Reflexos", atr: "Agilidade", carga: true, treinado: false, cat: "3. Perícias de Resistência (Tríade Defensiva)" },
  { nome: "Vontade", atr: "Presença", carga: false, treinado: false, cat: "3. Perícias de Resistência (Tríade Defensiva)" },
  { nome: "Atualidades", atr: "Intelecto", carga: false, treinado: false, cat: "4. Perícias de Investigação Analítica e Técnica" },
  { nome: "Artes", atr: "Intelecto", carga: false, treinado: false, cat: "4. Perícias de Investigação Analítica e Técnica" },
  { nome: "Ciências", atr: "Intelecto", carga: false, treinado: true, cat: "4. Perícias de Investigação Analítica e Técnica" },
  { nome: "Mecânica", atr: "Intelecto", carga: false, treinado: true, cat: "4. Perícias de Investigação Analítica e Técnica" },
  { nome: "Medicina", atr: "Intelecto", carga: false, treinado: true, cat: "4. Perícias de Investigação Analítica e Técnica" },
  { nome: "Ocultismo", atr: "Intelecto", carga: false, treinado: true, cat: "4. Perícias de Investigação Analítica e Técnica" },
  { nome: "Procurar", atr: "Intelecto", carga: false, treinado: false, cat: "4. Perícias de Investigação Analítica e Técnica" },
  { nome: "Religião", atr: "Intelecto", carga: false, treinado: false, cat: "4. Perícias de Investigação Analítica e Técnica" },
  { nome: "Sobrevivência", atr: "Intelecto", carga: false, treinado: false, cat: "4. Perícias de Investigação Analítica e Técnica" },
  { nome: "Tecnologia", atr: "Intelecto", carga: false, treinado: true, cat: "4. Perícias de Investigação Analítica e Técnica" },
  { nome: "Adestramento", atr: "Presença", carga: false, treinado: false, cat: "5. Perícias de Interação e Percepção Social" },
  { nome: "Diplomacia", atr: "Presença", carga: false, treinado: false, cat: "5. Perícias de Interação e Percepção Social" },
  { nome: "Enganação", atr: "Presença", carga: false, treinado: false, cat: "5. Perícias de Interação e Percepção Social" },
  { nome: "Intimidação", atr: "Presença", carga: false, treinado: false, cat: "5. Perícias de Interação e Percepção Social" },
  { nome: "Intuição", atr: "Presença", carga: false, treinado: false, cat: "5. Perícias de Interação e Percepção Social" },
  { nome: "Percepção", atr: "Presença", carga: false, treinado: false, cat: "5. Perícias de Interação e Percepção Social" }
];

let arquetiposPorNome = {};
let origensPorNome = {};
let chaveHabilidadesArquetipo = null;


function obterArquetipoSelecionado() {
  return arquetiposPorNome[document.getElementById('arquetipo').value] || null;
}

function obterBonusArquetipo() {
  const arquetipo = obterArquetipoSelecionado();
  return arquetipo && arquetipo.bonus ? arquetipo.bonus : {};
}

function obterOrigemSelecionada() {
  return origensPorNome[document.getElementById('origem').value] || null;
}

function periciasConcedidasPelaOrigem(origem = obterOrigemSelecionada()) {
  if (!origem) return [];
  return (origem.pericias_treinadas || []).filter(nome =>
    PERICIAS_BASE.some(pericia => pericia.nome === nome)
  );
}

function sincronizarOrigem() {
  const origem = obterOrigemSelecionada();
  const periciasOrigem = new Set(periciasConcedidasPelaOrigem(origem));
  for (const [idx, pericia] of PERICIAS_BASE.entries()) {
    const select = document.getElementById(`treino_p_${idx}`);
    if (!select) continue;
    const eraAutomatica = select.dataset.automaticoOrigem === 'true';
    if (eraAutomatica && !periciasOrigem.has(pericia.nome)) {
      if (select.value === 'Treinado') select.value = 'Destreinado';
      select.dataset.automaticoOrigem = 'false';
    }
    if (periciasOrigem.has(pericia.nome) && select.value === 'Destreinado') {
      select.value = 'Treinado';
      select.dataset.automaticoOrigem = 'true';
    }
    atualizarDadoPericia(idx);
  }

  const aviso = document.getElementById('aviso-origem');
  if (!origem) {
    aviso.textContent = '';
    aviso.style.display = 'none';
  } else if (origem.pericias_treinadas.some(nome => nome.toLowerCase().includes('escolha'))) {
    aviso.textContent = 'Esta origem concede 2 perícias à escolha do Mestre.';
    aviso.style.display = 'block';
  } else {
    aviso.textContent = `Perícias treinadas pela origem: ${origem.pericias_treinadas.join(', ')}.`;
    aviso.style.display = 'block';
  }
}

function sincronizarHabilidadesArquetipo() {
  const arquetipo = obterArquetipoSelecionado();
  const origem = obterOrigemSelecionada();
  const nivel = Math.max(1, Number(document.getElementById('nivel').value) || 1);
  const chave = `${arquetipo ? arquetipo.nome : ''}|${origem ? origem.nome : ''}|${nivel}`;
  if (chave === chaveHabilidadesArquetipo) return;
  chaveHabilidadesArquetipo = chave;

  const habilidadesManuais = listas.habilidade.filter(habilidade => !habilidade.automatico);
  const habilidadesArquetipo = arquetipo
    ? (arquetipo.habilidades || [])
      .filter(habilidade => nivel >= Number(habilidade.nivel_desbloqueio))
      .map(habilidade => ({
        nome: habilidade.nome || '',
        classificacao: `Habilidade de Arquétipo (${arquetipo.nome})`,
        prereq: habilidade.prereq || '',
        custo: habilidade.custo || '',
        alcance: habilidade.alcance || '',
        efeito: [
          habilidade.gatilho ? `Gatilho: ${habilidade.gatilho}` : '',
          habilidade.acao ? `Ação: ${habilidade.acao}` : '',
          habilidade.efeito || ''
        ].filter(Boolean).join('\n'),
        automatico: true,
        nivel_desbloqueio: Number(habilidade.nivel_desbloqueio)
      }))
    : [];
  const habilidadeOrigem = origem ? [{
    nome: origem.habilidade.nome,
    classificacao: `Habilidade de Origem (${origem.nome})`,
    prereq: '',
    custo: '',
    alcance: '',
    efeito: origem.habilidade.descricao,
    automatico: true,
    nivel_desbloqueio: null
  }] : [];
  listas.habilidade = [...habilidadesManuais, ...habilidadesArquetipo, ...habilidadeOrigem];
  renderCards('habilidade');
}

async function salvarHabilidadeModal() {
    // 1. Coleta os valores preenchidos no formulário do modal
    const nome = document.getElementById('modal-nome').value.trim();
    const classificacao = document.getElementById('modal-classificacao').value.trim();
    const prereq = document.getElementById('modal-prereq').value.trim();
    const custo = document.getElementById('modal-custo').value.trim();
    const alcance = document.getElementById('modal-alcance').value.trim();
    const efeito = document.getElementById('modal-efeito').value.trim();

    if (!nome) {
        alert('Por favor, informe o nome da habilidade.');
        return;
    }

    // 2. Busca o ID do personagem aberto (currentCharacterId é a fonte confiável)
    const personagemId = typeof currentCharacterId !== 'undefined' && currentCharacterId
      ? currentCharacterId
      : (window.personagemIdAtual
        || new URLSearchParams(window.location.search).get('id')
        || localStorage.getItem('personagem_id_atual'));
    if (!personagemId) {
        alert('Abra ou salve a ficha antes de adicionar habilidades.');
        return;
    }

    // 3. Monta o payload JSON
    const payload = {
        nome: nome,
        classificacao: classificacao || 'Tier I',
        prereq: prereq,
        custo: custo,
        alcance: alcance,
        efeito: efeito,
        automatico: false,
        nivel_desbloqueio: null
    };

    // 4. Endpoint ajustado para o padrão /api/personagem/
    const endpoint = `/api/personagem/${personagemId}/habilidades`;
    console.log("Enviando requisição POST para:", endpoint);

    try {
        const response = await fetch(endpoint, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(payload)
        });

        if (response.ok) {
            const salva = await response.json().catch(() => ({}));
            // Adiciona a habilidade à lista local para não ser apagada no próximo "Salvar" da ficha
            if (typeof listas !== 'undefined' && Array.isArray(listas.habilidade)) {
                listas.habilidade.push({
                    ...payload,
                    id: salva.id
                });
                if (typeof renderCards === 'function') renderCards('habilidade');
            }
            fecharModal();
            // Recarrega a grid de habilidades na ficha
            if (typeof carregarHabilidadesDoPersonagem === 'function') {
                carregarHabilidadesDoPersonagem();
            } else if (typeof carregarPersonagem === 'function') {
                carregarPersonagem();
            }
        } else {
            const erro = await response.json().catch(() => ({ detail: response.statusText }));
            alert(`Erro ao salvar no banco: ${erro.detail || 'Rota não encontrada (404)'}`);
        }
    } catch (error) {
        console.error('Erro de conexão:', error);
        alert('Falha na comunicação com o servidor.');
    }
}

function limitePericiasTreinadas() {
  const intelecto = Number(document.getElementById('atr_intelecto').value) || 0;
  const bonusOrigem = obterOrigemSelecionada() ? 2 : 0;
  return Math.max(0, 3 + intelecto + bonusOrigem +
    (Number(obterBonusArquetipo().pericia_treinada) || 0));
}

function limitePericiasAprimoradas() {
  const intelecto = Number(document.getElementById('atr_intelecto').value) || 0;
  return Math.max(0, 3 + intelecto);
}

function contarPericiasPorGrau() {
  return PERICIAS_BASE.reduce((contagem, _, idx) => {
    const select = document.getElementById('treino_p_' + idx);
    if (!select || select.value === 'Destreinado') return contagem;
    contagem.treinadas += 1;
    if (['Veterano', 'Expert'].includes(select.value)) contagem.veteranas += 1;
    if (select.value === 'Expert') contagem.experts += 1;
    return contagem;
  }, { treinadas: 0, veteranas: 0, experts: 0 });
}

function problemasLimitePericias() {
  const nivel = Math.max(1, Number(document.getElementById('nivel').value) || 1);
  const limiteTreinadas = limitePericiasTreinadas();
  const limiteAprimoradas = limitePericiasAprimoradas();
  const contagem = contarPericiasPorGrau();
  const problemas = [];
  if (contagem.treinadas > limiteTreinadas) {
    problemas.push(`O limite de perícias treinadas é ${limiteTreinadas}.`);
  }
  if (contagem.veteranas > limiteAprimoradas) {
    problemas.push(`O limite de perícias Veteranas é ${limiteAprimoradas}.`);
  }
  if (contagem.experts > limiteAprimoradas) {
    problemas.push(`O limite de perícias Expert é ${limiteAprimoradas}.`);
  }
  if (nivel < 7 && contagem.veteranas > 0) problemas.push('Veterano só é liberado a partir do nível 7.');
  if (nivel < 14 && contagem.experts > 0) problemas.push('Expert só é liberado a partir do nível 14.');
  return problemas;
}

function atualizarContadorPericiasTreinadas() {
  const nivel = Math.max(1, Number(document.getElementById('nivel').value) || 1);
  const limiteTreinadas = limitePericiasTreinadas();
  const limiteAprimoradas = limitePericiasAprimoradas();
  const contagem = contarPericiasPorGrau();
  const vagasTreinadas = Math.max(0, limiteTreinadas - contagem.treinadas);
  const vagasVeteranas = Math.max(0, limiteAprimoradas - contagem.veteranas);
  const vagasExpert = Math.max(0, limiteAprimoradas - contagem.experts);
  const contador = document.getElementById('contador-pericias-treinadas');
  const aviso = document.getElementById('aviso-limite-pericias');
  contador.style.whiteSpace = 'pre-line';
  contador.textContent = [
    `Treinado: ${contagem.treinadas}/${limiteTreinadas} (${vagasTreinadas} não gasta${vagasTreinadas === 1 ? '' : 's'})`,
    nivel >= 7
      ? `Veterano: ${contagem.veteranas}/${limiteAprimoradas} (${vagasVeteranas} não gasta${vagasVeteranas === 1 ? '' : 's'})`
      : `Veterano: disponível no nível 7 (até ${limiteAprimoradas} perícias)`,
    nivel >= 14
      ? `Expert: ${contagem.experts}/${limiteAprimoradas} (${vagasExpert} não gasta${vagasExpert === 1 ? '' : 's'})`
      : `Expert: disponível no nível 14 (até ${limiteAprimoradas} perícias)`
  ].join('\n');
  const problemas = problemasLimitePericias();
  aviso.style.display = problemas.length ? 'block' : 'none';
  aviso.textContent = problemas.join(' ');
}

function atualizarTreinamentoPericia(idx) {
  const select = document.getElementById('treino_p_' + idx);
  const nivel = Math.max(1, Number(document.getElementById('nivel').value) || 1);
  if (select.value === 'Expert' && nivel < 14) {
    select.value = nivel >= 7 ? 'Veterano' : 'Treinado';
  } else if (select.value === 'Veterano' && nivel < 7) {
    select.value = 'Treinado';
  }
  const contagem = contarPericiasPorGrau();
  if (contagem.treinadas > limitePericiasTreinadas()) {
    select.value = 'Destreinado';
  } else if (contagem.veteranas > limitePericiasAprimoradas()) {
    select.value = 'Treinado';
  } else if (contagem.experts > limitePericiasAprimoradas()) {
    select.value = 'Veterano';
  }
  atualizarDadoPericia(idx);
  atualizarCalculos();
}

function aplicarBonusArquetipoCampo(id, bonus, valorCalculado, valorEditado) {
  const input = document.getElementById(id);
  const bonusAnterior = Number(input.dataset.bonusArquetipo) || 0;
  const base = valorEditado
    ? Number(input.value) || 0
    : (Number(input.value) || 0) - bonusAnterior;
  input.value = valorCalculado === null ? base + bonus : valorCalculado + bonus;
  input.dataset.bonusArquetipo = String(bonus);
}

function valorBaseArquetipo(id) {
  const input = document.getElementById(id);
  return (Number(input.value) || 0) - (Number(input.dataset.bonusArquetipo) || 0);
}

function atualizarResumoArquetipo(arquetipo) {
  const painel = document.getElementById('arquetipo-beneficios');
  const temBonus = Boolean(arquetipo && arquetipo.buffs);
  painel.style.display = temBonus ? 'block' : 'none';
  document.getElementById('arquetipo-buffs-texto').textContent =
    temBonus ? `Bônus ativos: ${arquetipo.buffs}` : '';
  document.getElementById('aviso-arquetipo-nivel').style.display =
    arquetipo && Number(document.getElementById('nivel').value) === 1 ? 'block' : 'none';
  atualizarContadorPericiasTreinadas();
}

function initPericias() {
  const container = document.getElementById('container-pericias');
  container.innerHTML = '';
  let catAtual = "";
  PERICIAS_BASE.forEach((p, idx) => {
    if (p.cat !== catAtual) {
      catAtual = p.cat;
      const tituloCat = document.createElement('div');
      tituloCat.className = 'pericias-categoria-titulo';
      tituloCat.innerText = catAtual;
      container.appendChild(tituloCat);
    }
    const row = document.createElement('div');
    row.className = 'pericia-row';
    let tags = `<span class="pericia-badge">${p.atr}</span>`;
    if (p.carga) tags += `<span class="pericia-badge badge-warn">Penalidade Carga</span>`;
    if (p.treinado) tags += `<span class="pericia-badge">Somente Treinado</span>`;
    row.innerHTML = `
      <div><strong>${p.nome}</strong> ${tags}</div>
      <div style="display: flex; align-items: center; gap: 8px;">
        <select id="treino_p_${idx}" onchange="atualizarTreinamentoPericia(${idx})">
          <option value="Destreinado">Destreinado</option>
          <option value="Treinado">Treinado</option>
          <option value="Veterano">Veterano</option>
          <option value="Expert">Expert</option>
        </select>
        <div id="dado_p_${idx}" class="pericia-dado-badge">d4</div>
      </div>
      <div class="pericia-bonus">
        <span>Bônus:</span><input type="number" id="bonus_p_${idx}" value="0" oninput="atualizarCalculos()">
      </div>
      <label class="pericia-ajudado"><input type="checkbox" id="ajudado_p_${idx}" onchange="atualizarDadoPericia(${idx})"> Ajudado</label>
      <div id="warn_${idx}" style="font-size: 0.75rem; color: #ff9999;"></div>
    `;
    container.appendChild(row);
  });
}

function atualizarDadoPericia(idx) {
  const select = document.getElementById('treino_p_' + idx);
  const badge = document.getElementById('dado_p_' + idx);
  if(!select || !badge) return;
  const dados = ['d4', 'd6', 'd8', 'd10', 'd12', 'd20'];
  const dadoBase = {
    Destreinado: 'd4',
    Treinado: 'd4',
    Veterano: 'd8',
    Expert: 'd10'
  }[select.value] || 'd4';
  const ajudado = document.getElementById('ajudado_p_' + idx)?.checked;
  const indiceDado = dados.indexOf(dadoBase);
  badge.innerText = dados[Math.min(indiceDado + (ajudado ? 1 : 0), dados.length - 1)];
}

function getDT(atrValor) {
  const nivel = Number(document.getElementById('nivel').value) || 1;
  return 5 + Number(atrValor) + nivel;
}

function atualizarDadoAtributo(atr) {
  const val = Number(document.getElementById('atr_' + atr).value);
  const container = document.getElementById('dice_bg_' + atr);
  container.className = 'dice-container'; // reset
  
  if (val === 1) container.classList.add('d4');
  else if (val === 2) container.classList.add('d6');
  else if (val === 3) container.classList.add('d8');
  else if (val === 4) container.classList.add('d10');
  else if (val === 5) container.classList.add('d12');
  else if (val >= 6) container.classList.add('d20');
  else container.classList.add('d-none');
}

function initDados() {
  ['forca', 'agilidade', 'intelecto', 'presenca', 'vigor'].forEach(atr => {
    atualizarDadoAtributo(atr);
  });
}

function atualizarCalculos(valorEditado = false) {
  const nivel = Math.max(1, Number(document.getElementById('nivel').value) || 1);
  const pontosDisponiveis = 4 + [4, 10, 16, 19].filter(nivelMarco => nivel >= nivelMarco).length;
  const pontosDistribuidos = ['forca', 'agilidade', 'intelecto', 'presenca', 'vigor']
    .reduce((total, atributo) => total + Math.max(0, (Number(document.getElementById(`atr_${atributo}`).value) || 1) - 1), 0);
  const pontosRestantes = pontosDisponiveis - pontosDistribuidos;
  const statusPontos = document.getElementById('pontos-atributos-status');
  if (pontosRestantes > 0) {
    statusPontos.textContent = `Você tem ${pontosRestantes} ponto${pontosRestantes === 1 ? '' : 's'} de atributo não gasto${pontosRestantes === 1 ? '' : 's'}.`;
    statusPontos.style.color = 'var(--accent-cyan)';
  } else if (pontosRestantes < 0) {
    statusPontos.textContent = `Atributos excedem o limite em ${Math.abs(pontosRestantes)} ponto${pontosRestantes === -1 ? '' : 's'}.`;
    statusPontos.style.color = 'var(--accent-red)';
  } else {
    statusPontos.textContent = 'Todos os pontos de atributo foram distribuídos.';
    statusPontos.style.color = 'var(--text-muted)';
  }
  const arquetipo = obterArquetipoSelecionado();
  const bonusArquetipo = obterBonusArquetipo();
  const bonusVida = (Number(bonusArquetipo.vida_inicial) || 0) +
    Math.max(0, nivel - 1) * (Number(bonusArquetipo.vida_por_nivel) || 0);
  const bonusSanidade = (Number(bonusArquetipo.sanidade_inicial) || 0) +
    Math.max(0, nivel - 1) * (Number(bonusArquetipo.sanidade_por_nivel) || 0);
  const bonusDefesa = Number(bonusArquetipo.defesa) || 0;
  atualizarResumoArquetipo(arquetipo);
  const forca = Number(document.getElementById('atr_forca').value) || 0;
  const agilidade = Number(document.getElementById('atr_agilidade').value) || 0;
  const intelecto = Number(document.getElementById('atr_intelecto').value) || 0;
  const presenca = Number(document.getElementById('atr_presenca').value) || 0;
  const vigor = Number(document.getElementById('atr_vigor').value) || 0;
  const bonusProt = Number(document.getElementById('bonusProtecoes').value) || 0;

  document.getElementById('dt_forca').innerText = getDT(forca);
  document.getElementById('dt_agilidade').innerText = getDT(agilidade);
  document.getElementById('dt_intelecto').innerText = getDT(intelecto);
  document.getElementById('dt_presenca').innerText = getDT(presenca);
  document.getElementById('dt_vigor').innerText = getDT(vigor);

  const vidaCalculada = document.getElementById('autoVida').checked
    ? 10 + vigor + Math.max(0, nivel - 1) * 2
    : null;
  const sanidadeCalculada = document.getElementById('autoSanidade').checked
    ? 10 + presenca + Math.max(0, nivel - 1) * 2
    : null;
  const defesaCalculada = document.getElementById('autoDefesa').checked
    ? 5 + agilidade + bonusProt
    : null;
  aplicarBonusArquetipoCampo('vidaMax', bonusVida, vidaCalculada, valorEditado);
  aplicarBonusArquetipoCampo('sanidadeMax', bonusSanidade, sanidadeCalculada, valorEditado);
  aplicarBonusArquetipoCampo('defesaAtual', bonusDefesa, defesaCalculada, valorEditado);
  document.getElementById('cargaMaxima').value = forca * 5;
  PERICIAS_BASE.forEach((_, idx) => atualizarDadoPericia(idx));
  renderBarras();

  const defAtual = Number(document.getElementById('defesaAtual').value) || 10;
  
  const idxReflexos = PERICIAS_BASE.findIndex(p => p.nome === "Reflexos");
  const idxFortitude = PERICIAS_BASE.findIndex(p => p.nome === "Fortitude");
  
  const bonusReflexos = document.getElementById('bonus_p_' + idxReflexos) ? Number(document.getElementById('bonus_p_' + idxReflexos).value) : 0;
  const bonusFortitude = document.getElementById('bonus_p_' + idxFortitude) ? Number(document.getElementById('bonus_p_' + idxFortitude).value) : 0;

  const treinoReflexos = document.getElementById('treino_p_' + idxReflexos).value;
  const treinoFortitude = document.getElementById('treino_p_' + idxFortitude).value;
  
  const getDadoTreino = (t) => t === 'Expert' ? 10 : t === 'Veterano' ? 8 : 4;
  
  // Média matemática de um dado é (Faces / 2) + 0.5. Arredondamos para baixo por padrão em RPGs.
  const valorMedioDadoReflexos = Math.floor((getDadoTreino(treinoReflexos) / 2) + 0.5) + bonusReflexos; 
  const valorMedioDadoFortitude = Math.floor((getDadoTreino(treinoFortitude) / 2) + 0.5) + bonusFortitude;

  document.getElementById('bloqueio').value = valorMedioDadoFortitude;
  document.getElementById('esquiva').value = defAtual + valorMedioDadoReflexos;
  
  atualizarDeslocamentoBase();
}


function atualizarBolinhasMorte(marcada) {
  const m3 = document.getElementById('morte_3');
  const statusTxt = document.getElementById('status-morte-txt');

  if (m3.checked) {
    statusTxt.innerText = "PERSONAGEM MORTO (3ª Rodada Expirada)";
    statusTxt.style.color = "#ff4d4d";
  } else {
    statusTxt.innerText = "Morrendo (0 de Vida - Contagem de Rodadas)";
    statusTxt.style.color = "#ff9999";
  }
}

function reviverPersonagem() {
  document.getElementById('vidaAtual').value = 1;
  document.getElementById('morte_1').checked = false;
  document.getElementById('morte_2').checked = false;
  document.getElementById('morte_3').checked = false;
  renderBarras();
}

function atualizarBolinhasLoucura(marcada) {
  const l3 = document.getElementById('loucura_3');
  const statusTxt = document.getElementById('status-loucura-txt');

  if (l3.checked) {
    statusTxt.innerText = "ENLOUQUECEU COMPLETAMENTE (3ª Rodada Expirada)";
    statusTxt.style.color = "#ff4d4d";
  } else {
    statusTxt.innerText = "Enlouquecendo (0 de Sanidade - Contagem de Rodadas)";
    statusTxt.style.color = "#99ffff";
  }
}

function curarSanidade() {
  document.getElementById('sanidadeAtual').value = 1;
  document.getElementById('loucura_1').checked = false;
  document.getElementById('loucura_2').checked = false;
  document.getElementById('loucura_3').checked = false;
  renderBarras();
}

function renderBarras() {
  const vAtual = Number(document.getElementById('vidaAtual').value) || 0;
  const vMax = Number(document.getElementById('vidaMax').value) || 1;
  const pctVida = Math.min(100, Math.max(0, (vAtual / vMax) * 100));
  document.getElementById('barFillVida').style.width = pctVida + '%';

  const containerBarraVida = document.getElementById('container-barra-vida');
  const containerBolinhasVida = document.getElementById('container-bolinhas-vida');

  if (vAtual <= 0) {
    containerBarraVida.style.display = 'none';
    containerBolinhasVida.style.display = 'block';
  } else {
    containerBarraVida.style.display = 'block';
    containerBolinhasVida.style.display = 'none';
    document.getElementById('morte_1').checked = false;
    document.getElementById('morte_2').checked = false;
    document.getElementById('morte_3').checked = false;
    document.getElementById('status-morte-txt').innerText = "Inconsciente (0 de Vida - 3 Rodadas)";
    document.getElementById('status-morte-txt').style.color = "#ff9999";
  }

  const sAtual = Number(document.getElementById('sanidadeAtual').value) || 0;
  const sMax = Number(document.getElementById('sanidadeMax').value) || 1;
  const pctSan = Math.min(100, Math.max(0, (sAtual / sMax) * 100));
  document.getElementById('barFillSanidade').style.width = pctSan + '%';

  const containerBarraSan = document.getElementById('container-barra-sanidade');
  const containerBolinhasSan = document.getElementById('container-bolinhas-sanidade');

  if (sAtual <= 0) {
    containerBarraSan.style.display = 'none';
    containerBolinhasSan.style.display = 'block';
  } else {
    containerBarraSan.style.display = 'block';
    containerBolinhasSan.style.display = 'none';
    document.getElementById('loucura_1').checked = false;
    document.getElementById('loucura_2').checked = false;
    document.getElementById('loucura_3').checked = false;
    document.getElementById('status-loucura-txt').innerText = "Enlouquecendo (0 de Sanidade - 3 Rodadas)";
    document.getElementById('status-loucura-txt').style.color = "#99ffff";
  }
}













function alterarStatus(tipo, val) {
  const input = document.getElementById(tipo + 'Atual');
  const max = Number(document.getElementById(tipo + 'Max').value) || 100;
  let valEfetivo = val;

  // Se for vida e for cura (val > 0), verifica se Vigor está debilitado
  if (tipo === 'vida' && val > 0) {
    const debVigor = document.getElementById('deb_vigor') && document.getElementById('deb_vigor').checked;
    if (debVigor) {
      valEfetivo = Math.floor(val / 2); // Recupera apenas metade da cura
    }
  }

  let novoVal = (Number(input.value) || 0) + valEfetivo;
  if (novoVal < 0) novoVal = 0;
  if (novoVal > max) novoVal = max;
  input.value = novoVal;
  renderBarras();
}

function atualizarQuadrados() {
  const m = Number(document.getElementById('deslocamentoMetros').value) || 0;
  document.getElementById('deslocamentoQuadrados').value = Math.floor(m / 1.5);
}

function atualizarMetros() {
  const q = Number(document.getElementById('deslocamentoQuadrados').value) || 0;
  document.getElementById('deslocamentoMetros').value = q * 1.5;
}

function calcularVantagens() {
  const vantagens = Number(document.getElementById('qtdVantagens').value) || 0;
  const desvantagens = Number(document.getElementById('qtdDesvantagens').value) || 0;
  const saldo = vantagens - desvantagens;
  const divResultado = document.getElementById('resultadoVantagem');

  if (saldo === 0) {
    divResultado.innerText = "Nenhum";
    divResultado.style.color = "var(--text-color)";
    return;
  }
  const saldoAbsoluto = Math.min(Math.abs(saldo), 5);
  const dados = ["", "1d4", "1d6", "1d8", "1d10", "1d12"];
  const tipoDado = dados[saldoAbsoluto];
  if (saldo > 0) {
    divResultado.innerText = "+ " + tipoDado;
    divResultado.style.color = "var(--primary)";
  } else {
    divResultado.innerText = "- " + tipoDado;
    divResultado.style.color = "#ff4d4d";
  }
}

function atualizarOpcoesArmas() {
  // Pega os itens do inventário para preencher os selects de armas
  const inputsItens = document.querySelectorAll('#tabela-itens tr');
  let optionsHtml = '<option value="">(Nenhuma / Desarmado)</option>';
  inputsItens.forEach(tr => {
    const nomeItem = tr.querySelector('td:nth-child(1) input');
    if (nomeItem && nomeItem.value.trim() !== '') {
      optionsHtml += `<option value="${nomeItem.value}">${nomeItem.value}</option>`;
    }
  });
  
  // Atualiza todos os selects de armas ativos na tabela de combate
  document.querySelectorAll('.select-arma-combate').forEach(sel => {
    const valorAtual = sel.value;
    sel.innerHTML = optionsHtml;
    sel.value = valorAtual;
  });
}

function adicionarAtaque() {
  const container = document.getElementById('container-combate');
  const card = document.createElement('div');
  card.style.cssText = "background: #16161a; border: 1px solid var(--card-border); border-radius: 6px; padding: 12px; display: flex; flex-direction: column; gap: 10px;";

  // Monta opções de perícias
  let optionsPericias = '<option value="">(Nenhuma / Perícia)</option>';
  PERICIAS_BASE.forEach(p => {
    optionsPericias += `<option value="${p.nome}">${p.nome} (${p.atr})</option>`;
  });

  // Monta opções de armas do inventário
  let optionsArmas = '<option value="">(Nenhuma / Desarmado)</option>';
  const inputsItens = document.querySelectorAll('#tabela-itens tr');
  inputsItens.forEach(trItem => {
    const nomeItem = trItem.querySelector('td:nth-child(1) input');
    if (nomeItem && nomeItem.value.trim() !== '') {
      optionsArmas += `<option value="${nomeItem.value}">${nomeItem.value}</option>`;
    }
  });

  card.innerHTML = `
    <!-- Linha 1: Nome, Arma, Atributo/Perícia, Ação Arriscada, Crítico, Ação Excluir -->
    <div style="display: flex; gap: 10px; align-items: center; flex-wrap: wrap;">
      <label style="flex: 2; min-width: 140px;">Nome do Ataque
        <input type="text" placeholder="Ex: Corte Rápido" class="input-nome-ataque">
      </label>
      <label style="flex: 2; min-width: 140px;">Arma (Inventário)
        <select class="select-arma-combate">${optionsArmas}</select>
      </label>
      <label style="flex: 2; min-width: 160px;">Atributo / Perícia
        <div style="display:flex; gap:4px;">
          <select class="select-atr-combate" style="flex:1;" onchange="calcularAtaqueCard(this)">
            <option value="forca">Força</option>
            <option value="agilidade">Agilidade</option>
            <option value="intelecto">Intelecto</option>
            <option value="presenca">Presença</option>
            <option value="vigor">Vigor</option>
          </select>
          <select class="select-per-combate" style="flex:1.2;" onchange="calcularAtaqueCard(this)">${optionsPericias}</select>
        </div>
      </label>
      <label style="flex: 2; min-width: 170px;">Ação Arriscada
        <select class="select-arriscada-combate" onchange="calcularAtaqueCard(this)">
          <option value="normal">Normal</option>
          <option value="2v_dobrar">2 Desv. (Dobrar Dano)</option>
          <option value="3v_triplicar">3 Desv. (Triplicar Dano)</option>
        </select>
      </label>
      <label style="flex: 1; min-width: 80px;">Crítico
        <input type="text" value="x2" class="crit-combate" style="text-align: center;">
      </label>
      <button class="btn-danger" style="height: 38px; align-self: flex-end;" onclick="this.closest('div').parentElement.remove()">X</button>
    </div>

    <!-- Linha 2: Bônus, Dado de Ataque Calculado, Dano Calculado, Crítico Calculado -->
    <div style="display: flex; gap: 15px; align-items: center; background: #121214; padding: 10px; border-radius: 4px; border: 1px solid #23232f; flex-wrap: wrap;">
      <div style="display: flex; gap: 8px; align-items: center;">
        <label>Bônus Dado <input type="text" placeholder="+d6" class="bonus-dado-combate" style="width: 65px;" oninput="calcularAtaqueCard(this)"></label>
        <label>Bônus Fixo <input type="number" placeholder="+3" class="bonus-fixo-combate" style="width: 65px;" oninput="calcularAtaqueCard(this)"></label>
      </div>
      <div style="flex: 1; min-width: 200px;">
        <span style="font-size: 0.8rem; color: var(--text-muted);">Dado de Ataque:</span>
        <div class="res-dado-ataque" style="font-size: 1rem; font-weight: bold; color: var(--primary);">d4 + d4</div>
      </div>
      <div style="flex: 1; min-width: 150px;">
        <span style="font-size: 0.8rem; color: var(--text-muted);">Dano Base:</span>
        <div class="res-dano" style="font-size: 1rem; font-weight: bold; color: #fff;">1d6</div>
      </div>
      <div style="flex: 1; min-width: 150px;">
        <span style="font-size: 0.8rem; color: var(--text-muted);">Dano Crítico:</span>
        <div class="res-crit" style="font-size: 1rem; font-weight: bold; color: #ff4d4d;">2d6</div>
      </div>
    </div>
  `;
  container.appendChild(card);
  calcularAtaqueCard(card.querySelector('.select-atr-combate'));
}

function calcularAtaqueCard(el) {
  const card = el.closest('div[style*="background: #16161a"]');
  const atr = card.querySelector('.select-atr-combate').value;
  const nomePericia = card.querySelector('.select-per-combate').value;
  const acaoArriscada = card.querySelector('.select-arriscada-combate').value;
  
  // Descobre o dado do atributo base
  const valAtr = Number(document.getElementById('atr_' + atr).value) || 1;
  const dadosAtrMap = { 1: 'd4', 2: 'd6', 3: 'd8', 4: 'd10', 5: 'd12' };
  let dadoBaseStr = valAtr >= 6 ? 'd20' : (dadosAtrMap[valAtr] || 'd4');
  
  // Descobre o dado da perícia escolhida
  let dadoPericiaStr = 'd4';
  if (nomePericia) {
    const idxPer = PERICIAS_BASE.findIndex(p => p.nome === nomePericia);
    if (idxPer !== -1) {
      const selectTreino = document.getElementById('treino_p_' + idxPer);
      const treinoVal = selectTreino ? selectTreino.value : 'Destreinado';
      if (treinoVal === 'Treinado') dadoPericiaStr = 'd4';
      else if (treinoVal === 'Veterano') dadoPericiaStr = 'd8';
      else if (treinoVal === 'Expert') dadoPericiaStr = 'd10';
      else dadoPericiaStr = 'd4';
    }
  }

  // Bônus de dado extra inserido pelo utilizador
  const bonusDadoInput = card.querySelector('.bonus-dado-combate').value.trim();
  let dadoFinalStr = dadoBaseStr + ' + ' + dadoPericiaStr;
  if (bonusDadoInput) {
    dadoFinalStr += ' + ' + bonusDadoInput;
  }

  // Aplica as desvantagens automáticas já calculadas no Dado de Ataque
  if (acaoArriscada === '2v_dobrar') {
    dadoFinalStr += ' - 1d6';
  } else if (acaoArriscada === '3v_triplicar') {
    dadoFinalStr += ' - 1d8';
  }
  card.querySelector('.res-dado-ataque').innerText = dadoFinalStr;

  // Cálculo do Dano base e modificadores de Ação Arriscada
  const bonusFixo = Number(card.querySelector('.bonus-fixo-combate').value) || 0;
  
  let multDano = 1;
  if (acaoArriscada === '2v_dobrar') multDano = 2;
  else if (acaoArriscada === '3v_triplicar') multDano = 3;

  const facesDado = dadoBaseStr; // ex: d6
  const numDanoTotal = multDano; 
  let danoStr = (numDanoTotal > 1 ? numDanoTotal : '') + facesDado;
  if (bonusFixo !== 0) {
    const bonusAjustado = bonusFixo * multDano;
    danoStr += (bonusAjustado > 0 ? ' + ' + bonusAjustado : ' - ' + Math.abs(bonusAjustado));
  }
  
  // Crítico multiplica por 2 o multiplicador base do ataque
  const multCrit = multDano * 2;
  let critStr = multCrit + facesDado;
  if (bonusFixo !== 0) {
    const bonusCritAjustado = bonusFixo * multCrit;
    critStr += (bonusCritAjustado > 0 ? ' + ' + bonusCritAjustado : '');
  }

  card.querySelector('.res-dano').innerText = danoStr;
  card.querySelector('.res-crit').innerText = critStr;
}

// Alias para compatibilidade caso alguma outra função chame calcularAtaqueRow
function calcularAtaqueRow(el) {
  calcularAtaqueCard(el);
}


let listas = {
  habilidade: [],
  ritual: []
};
window.listas = listas; // expõe para acesso externo (QA/debug)
let estadoModal = { tipo: null, index: null };

function escaparHTML(texto) {
  return String(texto || '')
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');
}

function renderCards(tipo) {
  const container = document.getElementById(tipo === 'habilidade' ? 'grid-habilidades' : 'grid-rituais');
  container.innerHTML = '';
  listas[tipo].forEach((item, idx) => {
    const div = document.createElement('div');
    const classes = ['card-item'];
    if (tipo === 'ritual' && !item.automatico) {
      const elementoRitual = detectarElementoRitual(item);
      if (elementoRitual) classes.push('power-card', `ritual-${elementoRitual}`);
    }
    div.className = classes.join(' ');
    div.onclick = (e) => {
      if (e.target.tagName !== 'BUTTON') abrirModalEdicao(tipo, idx);
    };
    const subtitulo = [
      item.automatico
        ? item.classificacao.startsWith('Habilidade de Origem')
          ? 'Origem'
          : `Arquétipo · Nível ${item.nivel_desbloqueio}`
        : '',
      item.custo ? `Custo: ${item.custo}` : ''
    ].filter(Boolean).join(' · ');
    div.innerHTML = `
      ${item.automatico ? '' : `<button class="btn-delete-card" onclick="removerItem('${tipo}', ${idx}, event)">X</button>`}
      <div class="card-title">${item.nome || '(Sem Nome)'}</div>
      <div class="card-subtitle">${subtitulo}</div>
      ${tipo === 'ritual' && item.efeito ? `<div class="power-card-description">${escaparHTML(item.efeito)}</div>` : ''}
    `;
    container.appendChild(div);
  });
}

function abrirModalEdicao(tipo, index) {
  estadoModal = { tipo, index };
  const titulo = document.getElementById('modal-titulo');
  titulo.innerText = index === null ? `Nova ${tipo === 'habilidade' ? 'Habilidade' : 'Ritual'}` : `Editar ${tipo === 'habilidade' ? 'Habilidade' : 'Ritual'}`;
  
  const item = index !== null ? listas[tipo][index] : { nome: '', classificacao: '', prereq: '', custo: '', alcance: '', efeito: '' };
  const somenteLeitura = Boolean(item.automatico);
  if (somenteLeitura) {
    titulo.innerText = item.classificacao.startsWith('Habilidade de Origem')
      ? `${item.nome} · Origem`
      : `${item.nome} · Arquétipo · Nível ${item.nivel_desbloqueio}`;
  }
  ['modal-nome', 'modal-classificacao', 'modal-prereq', 'modal-custo', 'modal-alcance', 'modal-efeito']
    .forEach(id => { document.getElementById(id).readOnly = somenteLeitura; });
  document.getElementById('modal-salvar').style.display = somenteLeitura ? 'none' : '';
  
  document.getElementById('modal-nome').value = item.nome || '';
  document.getElementById('modal-classificacao').value = item.classificacao || '';
  document.getElementById('modal-prereq').value = item.prereq || '';
  document.getElementById('modal-custo').value = item.custo || '';
  document.getElementById('modal-alcance').value = item.alcance || '';
  document.getElementById('modal-efeito').value = item.efeito || '';
  
  document.getElementById('modal-item').style.display = 'flex';
}

function fecharModal() {
  document.getElementById('modal-item').style.display = 'none';
}

function salvarModal() {
  if (
    estadoModal.index !== null &&
    listas[estadoModal.tipo][estadoModal.index].automatico
  ) return;
  const novoItem = {
    nome: document.getElementById('modal-nome').value,
    classificacao: document.getElementById('modal-classificacao').value,
    prereq: document.getElementById('modal-prereq').value,
    custo: document.getElementById('modal-custo').value,
    alcance: document.getElementById('modal-alcance').value,
    efeito: document.getElementById('modal-efeito').value
  };
  
  if (estadoModal.index === null) {
    listas[estadoModal.tipo].push(novoItem);
  } else {
    listas[estadoModal.tipo][estadoModal.index] = novoItem;
  }
  
  renderCards(estadoModal.tipo);
  fecharModal();
}

function removerItem(tipo, index, event) {
  if (event) event.stopPropagation();
  listas[tipo].splice(index, 1);
  renderCards(tipo);
}

function adicionarItem() {
  const tbody = document.getElementById('tabela-itens');
  const tr = document.createElement('tr');
  tr.innerHTML = `
    <td><input type="text" placeholder="Item" oninput="atualizarOpcoesArmas()"></td>
    <td><input type="number" value="1" style="width: 60px;" oninput="calcularCarga()"></td>
    <td><input type="text" placeholder="Descrição"></td>
    <td><button class="btn-danger" onclick="this.closest('tr').remove(); calcularCarga(); atualizarOpcoesArmas();">X</button></td>
  `;
  tbody.appendChild(tr);
  calcularCarga();
  atualizarOpcoesArmas();
}

function calcularCarga() {
  const inputs = document.querySelectorAll('#tabela-itens input[type="number"]');
  let total = 0;
  inputs.forEach(i => total += Number(i.value) || 0);
  document.getElementById('cargaAtual').innerText = total;
  
  atualizarDeslocamentoBase();
}

function atualizarDeslocamentoBase() {
  const baseM = Number(document.getElementById('deslocamentoBaseMetros').value) || 9;
  let baseQ = Math.floor(baseM / 1.5);
  const cargaAtual = Number(document.getElementById('cargaAtual').innerText) || 0;
  
  // Verifica se Força está debilitada para reduzir a carga máxima pela metade
  const debForca = document.getElementById('deb_forca') && document.getElementById('deb_forca').checked;
  const cargaMaxInputVal = Number(document.getElementById('cargaMaxima').value);
  const bonusCarga = Number(obterBonusArquetipo().carga) || 0;
  const cargaMaxEfetiva = debForca
    ? Math.floor((cargaMaxInputVal + bonusCarga) / 2)
    : cargaMaxInputVal + bonusCarga;

  // Exibe a carga máxima efetiva ao lado ou atualiza o span se necessário
  const spanCargaMax = document.getElementById('cargaMaxEfetivaTxt');
  if(spanCargaMax) {
    spanCargaMax.innerText = debForca
      ? `(Máx.: ${cargaMaxEfetiva} [metade por Força])`
      : `(Máx.: ${cargaMaxEfetiva})`;
  }

  let excesso = cargaAtual - cargaMaxEfetiva;
  let penalidadeM = 0;
  let penalidadeQ = 0;
  
  if (excesso > 0) {
    const paresExtras = Math.floor(excesso / 2);
    penalidadeM = paresExtras * 3;
    penalidadeQ = paresExtras * 2;
  }
  
  let efetivoM = Math.max(0, baseM - penalidadeM);
  let efetivoQ = Math.max(0, baseQ - penalidadeQ);

  // Se Agilidade estiver debilitada: -3 metros e -2 quadrados obrigatoriamente
  const debAgilidade = document.getElementById('deb_agilidade') && document.getElementById('deb_agilidade').checked;
  if (debAgilidade) {
    efetivoM = Math.max(0, efetivoM - 3);
    efetivoQ = Math.max(0, efetivoQ - 2);
  }

  document.getElementById('deslocamentoMetros').value = efetivoM;
  document.getElementById('deslocamentoQuadrados').value = efetivoQ;
}

function atualizarQuadrados() {
  // Mantido para compatibilidade se necessário
}

function atualizarMetros() {
  // Mantido para compatibilidade se necessário
}


// --- TRILHA DO PARANORMAL ---
const niveisParanormal = [5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80, 85, 90, 95, 99];
let indiceParanormalAtual = 0; // Começa em 5% (índice 0)
let dadosParanormalSeq = ['d4', 'd6', 'd8', 'd12', 'd20'];
let indiceDadoParanormal = 0; // Começa em d4
let contadorCrisesTotal = 0;

function initTrilhaParanormal() {
  const container = document.getElementById('container-trilha-botoes');
  if(!container) return;
  container.innerHTML = '';
  
  niveisParanormal.forEach((val, idx) => {
    const btn = document.createElement('button');
    btn.type = 'button';
    btn.innerText = val + '%';
    btn.style.cssText = `
      flex: 1; min-width: 45px; padding: 6px 2px; font-size: 0.75rem; font-weight: bold;
      background: ${idx <= indiceParanormalAtual ? 'var(--accent-cyan)' : '#252530'};
      color: ${idx <= indiceParanormalAtual ? '#000' : '#fff'};
      border: 1px solid var(--card-border); border-radius: 4px; cursor: pointer; text-align: center;
    `;
    btn.onclick = () => {
      indiceParanormalAtual = idx;
      atualizarTrilhaUI();
    };
    container.appendChild(btn);
  });
  atualizarTrilhaUI();
}

function atualizarTrilhaUI() {
  const porcentagemAtual = niveisParanormal[indiceParanormalAtual];
  document.getElementById('par_porcentagem_atual').innerText = porcentagemAtual + '%';
  
  // Atualiza cores dos botões
  const botoes = document.querySelectorAll('#container-trilha-botoes button');
  botoes.forEach((btn, idx) => {
    if (idx <= indiceParanormalAtual) {
      btn.style.background = 'var(--accent-cyan)';
      btn.style.color = '#000';
    } else {
      btn.style.background = '#252530';
      btn.style.color = '#fff';
    }
  });

  // Atualiza o crachá do dado paranormal
  document.getElementById('dado-paranormal-badge').innerText = dadosParanormalSeq[indiceDadoParanormal];
  document.getElementById('contador-crises').innerText = contadorCrisesTotal;

  // Verifica se atingiu 50% ou mais (niveisParanormal[9] = 50%)
  const wrapperAfinidade = document.getElementById('container-afinidade-wrapper');
  if (porcentagemAtual >= 50) {
    wrapperAfinidade.style.display = 'block';
  } else {
    wrapperAfinidade.style.display = 'none';
    // Se abaixou de 50%, limpa a afinidade se necessário ou mantém desativada
    document.getElementById('selectAfinidade').value = '';
    mudarAfinidadeTema();
  }
}

function mudarAfinidadeTema() {
  const elemento = document.getElementById('selectAfinidade').value;
  const root = document.documentElement;
  const descTxt = document.getElementById('desc-afinidade-txt');

  // Cores primárias para cada elemento mantendo o tema escuro
  // Sangue: Vermelho (#b83232)
  // Morte: Branco/Prata (#e0e0e0)
  // Energia: Roxo/Magenta (#9b51e0)
  // Conhecimento: Dourado/Âmbar (#f2c94c)
  // Padrão: Azul (#7289da)

  if (elemento === 'sangue') {
    root.style.setProperty('--primary', '#b83232');
    descTxt.innerHTML = "<strong>Afinidade com Sangue:</strong> Sua sintonia é marcada pelo vermelho vivo da carne e da paixão visceral.";
  } else if (elemento === 'morte') {
    root.style.setProperty('--primary', '#d0d0d0');
    descTxt.innerHTML = "<strong>Afinidade com Morte:</strong> Sua sintonia é marcada pelo silêncio gélido e pelo cinza da entropia.";
  } else if (elemento === 'energia') {
    root.style.setProperty('--primary', '#9b51e0');
    descTxt.innerHTML = "<strong>Afinidade com Energia:</strong> Sua sintonia vibra com o caos colorido e imprevisível das descargas paranormais.";
  } else if (elemento === 'conhecimento') {
    root.style.setProperty('--primary', '#f2c94c');
    descTxt.innerHTML = "<strong>Afinidade com Conhecimento:</strong> Sua sintonia brilha com o fulgor dourado da verdade absoluta e ocultada.";
  } else {
    root.style.setProperty('--primary', '#7289da');
    descTxt.innerHTML = "Ao atingir 50% ou mais de exposição, você pode escolher uma afinidade elemental para sintonizar a sua ficha.";
  }
  renderPoderes();
}

function rolarParanormal(vitoria) {
  contadorCrisesTotal++;
  const txtResultado = document.getElementById('resultado-paranormal-txt');
  const dadoAtual = dadosParanormalSeq[indiceDadoParanormal];

  if (vitoria) {
    // Se for VITÓRIA: o dado atual sobe um passo
    if (indiceDadoParanormal < dadosParanormalSeq.length - 1) {
      indiceDadoParanormal++;
    }
    const novoDado = dadosParanormalSeq[indiceDadoParanormal];
    txtResultado.innerHTML = `Vitória no teste com <strong>${dadoAtual}</strong>! O dado avançou para <strong>${novoDado}</strong>.`;
    txtResultado.style.color = "#4effb0";
  } else {
    // Se for DERROTA (perde para o paranormal): sobe 5% na barra e o dado reseta para d4
    if (indiceParanormalAtual < niveisParanormal.length - 1) {
      indiceParanormalAtual++;
    }
    indiceDadoParanormal = 0; // Reseta para d4
    txtResultado.innerHTML = `Derrota contra o Paranormal com <strong>${dadoAtual}</strong>. A exposição subiu para <strong>${niveisParanormal[indiceParanormalAtual]}%</strong> e o dado resetou para <strong>d4</strong>!`;
    txtResultado.style.color = "#ff9999";
  }
  atualizarTrilhaUI();
}



// --- PODERES PARANORMAIS ---
let listaPoderes = [];
let estadoModalPoderIndex = null;
let catalogoPoderes = [];
let modoModalPoder = 'selecao';

function normalizarElementoPoder(elemento) {
  return String(elemento || '').trim().toLowerCase();
}

function detectarElementoRitual(item) {
  // 1. Elemento armazenado explicitamente (campo próprio do ritual)
  if (item.elemento) {
    const armazenado = normalizarElementoPoder(item.elemento);
    if (['sangue', 'morte', 'energia', 'conhecimento'].includes(armazenado)) return armazenado;
  }
  // 2. Elemento declarado dentro do efeito ("Elemento: Sangue ...")
  const efeito = (item.efeito || '').toLowerCase();
  const declarado = efeito.match(/elemento:\s*(sangue|morte|energia|conhecimento)/);
  if (declarado) return declarado[1];
  // 3. Inferência por palavras-chave (fallback para rituais antigos/manuais)
  const texto = `${item.nome || ''} ${item.classificacao || ''} ${efeito}`;
  const mapa = [
    ['sangue', ['sangue', 'hemoglobina', 'hemat', 'vitílico', 'vitilico']],
    ['morte', ['morte', 'mortal', 'cinzas', 'cadáver', 'cadaver', 'necro', 'óssua', 'ossua']],
    ['energia', ['energia', 'elétric', 'eletric', 'chama', 'fogo', 'raio', 'tempestade']],
    ['conhecimento', ['conhecimento', 'mental', 'mente', 'ilusão', 'ilusao', 'percepção', 'percepcao', 'intelecto']]
  ];
  for (const [elemento, palavras] of mapa) {
    if (palavras.some(palavra => texto.toLowerCase().includes(palavra))) return elemento;
  }
  return '';
}

function renderPoderes() {
  const container = document.getElementById('grid-poderes');
  if(!container) return;
  container.innerHTML = '';
  listaPoderes
    .map((poder, index) => ({ poder, index }))
    .sort((a, b) => a.poder.nome.localeCompare(b.poder.nome, 'pt-BR', { sensitivity: 'base' }))
    .forEach(({ poder, index: idx }) => {
    const div = document.createElement('div');
    const elemento = normalizarElementoPoder(poder.elemento);
    div.className = `card-item power-card poder-${elemento}`;
    div.onclick = (e) => {
      if (e.target.tagName !== 'BUTTON') abrirModalPoder(idx);
    };
    const remove = document.createElement('button');
    remove.className = 'btn-delete-card';
    remove.type = 'button';
    remove.textContent = 'X';
    remove.addEventListener('click', event => removerPoder(idx, event));
    const title = document.createElement('div');
    title.className = 'card-title';
    title.textContent = poder.nome || '(Sem Nome)';
    const subtitle = document.createElement('div');
    subtitle.className = 'card-subtitle';
    subtitle.textContent = [poder.elemento, poder.prereq].filter(Boolean).join(' · ');
    div.append(remove, title, subtitle);
    if (poder.efeito) {
      const effect = document.createElement('div');
      effect.className = 'power-card-description';
      effect.textContent = poder.efeito;
      div.appendChild(effect);
    }
    if (poder.afinidade) {
      const affinity = document.createElement('div');
      affinity.className = 'power-affinity-bonus';
      if (normalizarElementoPoder(poder.elemento) ===
          normalizarElementoPoder(document.getElementById('selectAfinidade')?.value)) {
        affinity.classList.add('aligned');
      }
      affinity.textContent = `Bônus de Afinidade: ${poder.afinidade}`;
      div.appendChild(affinity);
    }
    container.appendChild(div);
    });
}

function abrirModalPoder(index) {
  estadoModalPoderIndex = index;
  const modal = document.getElementById('modal-poder');
  modal.style.display = 'flex';
  if (index === null) {
    modoModalPoder = 'selecao';
    document.getElementById('power-picker-view').style.display = 'block';
    document.getElementById('power-manual-view').style.display = 'none';
    carregarCatalogoPoderes().then(renderCatalogoPoderes).catch(error => {
      document.getElementById('power-picker-status').textContent = error.message;
    });
    renderCatalogoPoderes();
    return;
  }

  modoModalPoder = 'edicao';
  document.getElementById('power-picker-view').style.display = 'none';
  document.getElementById('power-manual-view').style.display = 'block';
  document.getElementById('modal-poder-manual-titulo').textContent = 'Editar Poder Paranormal';
  document.getElementById('poder-voltar-catalogo').style.display = 'none';
  document.getElementById('poder-cancelar-edicao').style.display = '';
  document.getElementById('poder-salvar-manual').textContent = 'Salvar alterações';
  const p = listaPoderes[index];
  document.getElementById('mod_poder_nome').value = p.nome || '';
  document.getElementById('mod_poder_elemento').value = p.elemento || 'sangue';
  document.getElementById('mod_poder_prereq').value = p.prereq || '';
  document.getElementById('mod_poder_custo').value = p.custo || '';
  document.getElementById('mod_poder_alcance').value = p.alcance || '';
  document.getElementById('mod_poder_efeito').value = p.efeito || '';
  document.getElementById('mod_poder_afinidade').value = p.afinidade || '';
}

function fecharModalPoder() {
  document.getElementById('modal-poder').style.display = 'none';
  modoModalPoder = 'selecao';
  estadoModalPoderIndex = null;
  document.getElementById('poder-cancelar-edicao').style.display = 'none';
}

async function carregarCatalogoPoderes() {
  if (catalogoPoderes.length) return;
  const { response, data } = await apiRequest('/api/poderes-paranormais');
  if (!response.ok) throw new Error(data.detail || 'Não foi possível carregar os poderes.');
  catalogoPoderes = data;
}

function obterElementoPoderCatalogo(poder, elementoFiltro) {
  return poder.elemento.startsWith('Variável')
    ? elementoFiltro
    : normalizarElementoPoder(poder.elemento);
}

function obterGrauMinimoPoder(prereq) {
  const match = /(?:Conhecimento|Energia|Morte|Sangue|Elemento)\s+(\d+)/i.exec(prereq || '');
  return match ? Number(match[1]) : 1;
}

function requisitoPoderEspecial(poder) {
  const prereq = poder.prereq || '';
  const match = /(?:Conhecimento|Energia|Morte|Sangue|Elemento)\s+\d+/i.exec(prereq);
  return !match || Boolean(prereq.slice(match.index + match[0].length).trim());
}

function textoAvisoPrerequisito(poder, elemento) {
  if (requisitoPoderEspecial(poder)) return `Pré-requisito: ${poder.prereq}`;
  const grau = obterGrauMinimoPoder(poder.prereq);
  const nomeElemento = poder.prereq.startsWith('Elemento ')
    ? (elemento ? elemento[0].toUpperCase() + elemento.slice(1) : 'Elemento')
    : poder.prereq.replace(/\s+\d+.*$/, '');
  return `Pré-requisito: ${nomeElemento} ${grau}`;
}

function verificarRequisitoPoder(poder, elemento) {
  const grau = obterGrauMinimoPoder(poder.prereq);
  const adquiridos = listaPoderes.filter(item =>
    normalizarElementoPoder(item.elemento) === elemento
  ).length;
  return adquiridos >= grau - 1;
}

function poderJaAdquirido(poder, elemento) {
  const existentes = listaPoderes.filter(item =>
    item.nome.toLocaleLowerCase() === poder.nome.toLocaleLowerCase()
  );
  if (!existentes.length) return false;
  const podeRepetir = /pode ser escolhido m[uú]ltiplas vezes/i.test(poder.efeito || '');
  if (!podeRepetir) return true;
  const exigeElementosDiferentes = /desde que para elementos diferentes/i.test(poder.efeito || '');
  return exigeElementosDiferentes && existentes.some(item =>
    normalizarElementoPoder(item.elemento) === elemento
  );
}

function renderCatalogoPoderes() {
  const container = document.getElementById('power-catalog-list');
  if (!container) return;
  container.replaceChildren();
  const filtro = document.getElementById('power-element-filter').value;
  const filtroPrerequisito = document.getElementById('power-prereq-filter').value;
  const status = document.getElementById('power-picker-status');
  const nexAtual = niveisParanormal[indiceParanormalAtual] || 5;
  const sanidadeAtual = Number(document.getElementById('sanidadeAtual').value) || 0;
  status.textContent = nexAtual >= 99
    ? 'NEX máximo atingido; não há espaço para adquirir outro poder.'
    : sanidadeAtual < 1
      ? 'É necessário ter pelo menos 1 SAN atual para adquirir um poder.'
    : `Cada poder custa 1 SAN atual e aumenta o NEX em 5%. Poderes do mesmo elemento exigem ${'um poder a menos que o grau indicado'} já adquirido.`;

  catalogoPoderes
    .filter(poder => {
      const elemento = normalizarElementoPoder(poder.elemento);
      const combinaElemento = !filtro || elemento === filtro || poder.elemento.startsWith('Variável');
      if (!combinaElemento) return false;
      if (!filtroPrerequisito) return true;
      if (filtroPrerequisito === 'special') return requisitoPoderEspecial(poder);
      return !requisitoPoderEspecial(poder) &&
        obterGrauMinimoPoder(poder.prereq) === Number(filtroPrerequisito);
    })
    .forEach(poder => {
      const elemento = obterElementoPoderCatalogo(poder, filtro);
      const variavelSemEscolha = poder.elemento.startsWith('Variável') && !filtro;
      const duplicado = elemento && poderJaAdquirido(poder, elemento);
      const requisitoAtendido = elemento && verificarRequisitoPoder(poder, elemento);
      const row = document.createElement('div');
      row.className = 'power-catalog-row';
      const name = document.createElement('strong');
      name.textContent = poder.nome;
      const info = document.createElement('div');
      info.className = 'power-catalog-info';
      info.appendChild(name);
      if (requisitoPoderEspecial(poder) || !requisitoAtendido) {
        const warning = document.createElement('span');
        warning.className = 'power-prereq-warning';
        warning.textContent = textoAvisoPrerequisito(poder, elemento);
        info.appendChild(warning);
      }
      const add = document.createElement('button');
      add.type = 'button';
      add.className = 'power-add-button';
      add.textContent = '+';
      add.setAttribute('aria-label', `Adicionar ${poder.nome}`);
      add.disabled = nexAtual >= 99 || sanidadeAtual < 1 || duplicado || variavelSemEscolha;
      add.title = duplicado
        ? 'Este poder já está na ficha.'
        : variavelSemEscolha
          ? 'Escolha o elemento no filtro para adicionar este poder.'
          : `Adicionar ${poder.nome}`;
      add.addEventListener('click', () => adicionarPoderCatalogo(poder, elemento));
      row.append(info, add);
      container.appendChild(row);
    });
}

function aplicarCustoPoder() {
  const nexAtual = niveisParanormal[indiceParanormalAtual] || 5;
  const proximoNex = Math.min(99, nexAtual + 5);
  indiceParanormalAtual = niveisParanormal.findIndex(valor => valor >= proximoNex);
  if (indiceParanormalAtual < 0) indiceParanormalAtual = niveisParanormal.length - 1;
  const sanidadeAtual = Number(document.getElementById('sanidadeAtual').value) || 0;
  document.getElementById('sanidadeAtual').value = Math.max(0, sanidadeAtual - 1);
  atualizarTrilhaUI();
  renderBarras();
}

function adicionarPoderCatalogo(poder, elemento) {
  if (!elemento) {
    document.getElementById('power-picker-status').textContent =
      'Escolha o elemento no filtro para adicionar este poder variável.';
    return;
  }
  if (poderJaAdquirido(poder, elemento)) return;
  if ((Number(document.getElementById('sanidadeAtual').value) || 0) < 1) {
    document.getElementById('power-picker-status').textContent =
      'É necessário ter pelo menos 1 SAN atual para adquirir um poder.';
    return;
  }
  listaPoderes.push({
    nome: poder.nome,
    elemento,
    prereq: poder.prereq || '',
    custo: poder.custo || '',
    alcance: poder.alcance || '',
    efeito: poder.efeito || '',
    afinidade: poder.afinidade || ''
  });
  aplicarCustoPoder();
  renderPoderes();
  document.getElementById('power-picker-view').style.display = 'block';
  document.getElementById('power-manual-view').style.display = 'none';
  document.getElementById('modal-poder').style.display = 'flex';
  renderCatalogoPoderes();
  programarAutosave(0);
}

function abrirFormPoderManual() {
  modoModalPoder = 'novo-manual';
  estadoModalPoderIndex = null;
  document.getElementById('power-picker-view').style.display = 'none';
  document.getElementById('power-manual-view').style.display = 'block';
  document.getElementById('modal-poder-manual-titulo').textContent = 'Criar Novo Poder Paranormal';
  document.getElementById('poder-voltar-catalogo').style.display = '';
  document.getElementById('poder-cancelar-edicao').style.display = 'none';
  document.getElementById('poder-salvar-manual').textContent = 'Adicionar poder';
  ['nome', 'prereq', 'custo', 'alcance', 'efeito', 'afinidade'].forEach(campo => {
    document.getElementById(`mod_poder_${campo}`).value = '';
  });
  document.getElementById('mod_poder_elemento').value = 'sangue';
}

function voltarAoCatalogoPoderes() {
  modoModalPoder = 'selecao';
  document.getElementById('power-picker-view').style.display = 'block';
  document.getElementById('power-manual-view').style.display = 'none';
  renderCatalogoPoderes();
}

function salvarModalPoder() {
  const novoPoder = {
    nome: document.getElementById('mod_poder_nome').value.trim(),
    elemento: document.getElementById('mod_poder_elemento').value,
    prereq: document.getElementById('mod_poder_prereq').value.trim(),
    custo: document.getElementById('mod_poder_custo').value.trim(),
    alcance: document.getElementById('mod_poder_alcance').value.trim(),
    efeito: document.getElementById('mod_poder_efeito').value.trim(),
    afinidade: document.getElementById('mod_poder_afinidade').value.trim()
  };
  if (!novoPoder.nome || !novoPoder.efeito) {
    document.getElementById('modal-poder-manual-titulo').textContent =
      'Informe o nome e o efeito do poder.';
    return;
  }

  if (modoModalPoder === 'edicao' && estadoModalPoderIndex !== null) {
    listaPoderes[estadoModalPoderIndex] = novoPoder;
    renderPoderes();
    fecharModalPoder();
    programarAutosave(0);
    return;
  }

  if (listaPoderes.some(item => item.nome.toLocaleLowerCase() === novoPoder.nome.toLocaleLowerCase())) {
    document.getElementById('modal-poder-manual-titulo').textContent =
      'Esse poder já está na ficha.';
    return;
  }
  if ((niveisParanormal[indiceParanormalAtual] || 5) >= 99) {
    document.getElementById('modal-poder-manual-titulo').textContent =
      'NEX máximo atingido; não é possível adicionar outro poder.';
    return;
  }
  if ((Number(document.getElementById('sanidadeAtual').value) || 0) < 1) {
    document.getElementById('modal-poder-manual-titulo').textContent =
      'É necessário ter pelo menos 1 SAN atual para adquirir um poder.';
    return;
  }
  if (modoModalPoder === 'novo-manual') {
    listaPoderes.push(novoPoder);
    aplicarCustoPoder();
    renderPoderes();
    programarAutosave(0);
    voltarAoCatalogoPoderes();
  }
}

function removerPoder(index, event) {
  if (event) event.stopPropagation();
  listaPoderes.splice(index, 1);
  renderPoderes();
  programarAutosave(0);
}



function atualizarFerimentos() {
  atualizarCalculos();
  calcularCarga();
  atualizarDeslocamentoBase();
}



function filtrarSecao(idSecao) {
  const secoes = document.querySelectorAll('.secao-ficha');
  const links = document.querySelectorAll('.sumario-lateral a');

  // Atualiza classe ativa nos links do sumário
  links.forEach(l => l.classList.remove('ativo'));

  if (idSecao === 'todos') {
    secoes.forEach(s => s.style.display = 'block');
    document.getElementById('btn-sum-todos').classList.add('ativo');
  } else {
    secoes.forEach(s => {
      // Verifica se a seção contém o ID ou se o ID está no próprio h2/section
      const h2 = s.querySelector('h2');
      if (h2 && h2.id === idSecao) {
        s.style.display = 'block';
      } else {
        s.style.display = 'none';
      }
    });
    // Destaca o botão correspondente no sumário
    // Mapeia idSecao para o id do botão
    const btnId = 'btn-sum-' + idSecao.replace('sec-', '');
    const btn = document.getElementById(btnId);
    if (btn) btn.classList.add('ativo');
  }
  document.querySelector('.sumario-lateral').classList.remove('sumario-fixo-aberto');
  if (document.activeElement instanceof HTMLElement) document.activeElement.blur();
  atualizarEstadoSumario();
  window.scrollTo({ top: 0, behavior: 'smooth' });
}

const sumario = document.querySelector('.sumario-lateral');
const sumarioToggle = document.getElementById('sumario-toggle');

function atualizarEstadoSumario() {
  const hover = window.matchMedia('(hover: hover)').matches && sumario.matches(':hover');
  const aberto = sumario.classList.contains('sumario-fixo-aberto') ||
    hover || sumario.contains(document.activeElement);
  sumarioToggle.setAttribute('aria-expanded', String(aberto));
  sumarioToggle.setAttribute('aria-label', aberto ? 'Fechar sumário' : 'Abrir sumário');
}

sumarioToggle.addEventListener('click', () => {
  const aberto = sumario.classList.toggle('sumario-fixo-aberto');
  if (!aberto) sumarioToggle.blur();
  atualizarEstadoSumario();
});
sumario.addEventListener('pointerenter', atualizarEstadoSumario);
sumario.addEventListener('pointerleave', atualizarEstadoSumario);
sumario.addEventListener('focusin', atualizarEstadoSumario);
sumario.addEventListener('focusout', () => setTimeout(atualizarEstadoSumario, 0));



async function salvarNaApi() {
  const statusEl = document.getElementById('api_status_msg');
  if (!currentCharacterId) {
    statusEl.innerText = "Nenhuma ficha está aberta.";
    statusEl.style.color = "#ff4d4d";
    return false;
  }
  if (problemasLimitePericias().length) {
    statusEl.innerText = "Ajuste a quantidade e os graus das perícias para respeitar os limites do nível.";
    statusEl.style.color = "#ff4d4d";
    return false;
  }
  statusEl.innerText = "Salvando...";
  statusEl.style.color = "#ffd700";

  // Coleta dados gerais
  const dados = {
    nome: document.getElementById('nomePersonagem').value || 'Sem Nome',
    jogador: document.getElementById('jogador').value || '',
    nivel: Number(document.getElementById('nivel').value) || 1,
    conceito: document.getElementById('conceito').value || '',
    origem: document.getElementById('origem').value || '',
    arquetipo: document.getElementById('arquetipo').value || '',
    vida_atual: Number(document.getElementById('vidaAtual').value) || 10,
    vida_max: valorBaseArquetipo('vidaMax') || 10,
    sanidade_atual: Number(document.getElementById('sanidadeAtual').value) || 10,
    sanidade_max: valorBaseArquetipo('sanidadeMax') || 10,
    defesa_atual: valorBaseArquetipo('defesaAtual') || 10,
    bonus_protecoes: Number(document.getElementById('bonusProtecoes').value) || 0,
    deslocamento_base: Number(document.getElementById('deslocamentoBaseMetros').value) || 9,
    carga_maxima: Number(document.getElementById('cargaMaxima').value),
    resistencias: document.getElementById('resistencias').value || '',
    proficiencias: document.getElementById('proficiencias').value || '',
    exposicao_paranormal: niveisParanormal[indiceParanormalAtual] || 5,
    afinidade_elemento: document.getElementById('selectAfinidade') ? document.getElementById('selectAfinidade').value : '',
    crises_contador: contadorCrisesTotal || 0,
    dado_paranormal_idx: indiceDadoParanormal || 0,
    desc_aparencia: document.getElementById('desc_aparencia').value || '',
    desc_personalidade: document.getElementById('desc_personalidade').value || '',
    desc_historico: document.getElementById('desc_historico').value || '',
    desc_objetivo: document.getElementById('desc_objetivo').value || '',
    desc_anotacoes: document.getElementById('desc_anotacoes').value || '',
    
    atributos: [
      { nome: 'forca', valor: Number(document.getElementById('atr_forca').value) || 1, debilitado: document.getElementById('deb_forca').checked },
      { nome: 'agilidade', valor: Number(document.getElementById('atr_agilidade').value) || 1, debilitado: document.getElementById('deb_agilidade').checked },
      { nome: 'intelecto', valor: Number(document.getElementById('atr_intelecto').value) || 1, debilitado: document.getElementById('deb_intelecto').checked },
      { nome: 'presenca', valor: Number(document.getElementById('atr_presenca').value) || 1, debilitado: document.getElementById('deb_presenca').checked },
      { nome: 'vigor', valor: Number(document.getElementById('atr_vigor').value) || 1, debilitado: document.getElementById('deb_vigor').checked }
    ],
    
    pericias: PERICIAS_BASE.map((p, idx) => ({
      nome: p.nome,
      treinamento: document.getElementById('treino_p_' + idx) ? document.getElementById('treino_p_' + idx).value : 'Destreinado',
      bonus: document.getElementById('bonus_p_' + idx) ? Number(document.getElementById('bonus_p_' + idx).value) || 0 : 0,
      automatico_origem: document.getElementById('treino_p_' + idx)?.dataset.automaticoOrigem === 'true'
    })),
    
    inventario: Array.from(document.querySelectorAll('#tabela-itens tr')).map(tr => {
      const inputs = tr.querySelectorAll('input');
      return {
        nome: inputs[0] ? inputs[0].value : '',
        espaco: inputs[1] ? Number(inputs[1].value) || 1 : 1,
        descricao: inputs[2] ? inputs[2].value : ''
      };
    }).filter(i => i.nome.trim() !== ''),
    
    habilidades: listas.habilidade,
    rituais: listas.ritual,
    poderes: listaPoderes
  };

  try {
    const url = `/api/personagem?char_id=${encodeURIComponent(currentCharacterId)}`;
    const { response, data: resJson } = await apiRequest(url, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(dados)
    });
    if (response.ok) {
      statusEl.innerText = "Salvo automaticamente";
      statusEl.style.color = "#4effb0";
      return true;
    } else {
      statusEl.innerText = resJson.detail || "Erro ao salvar!";
      statusEl.style.color = "#ff4d4d";
      return false;
    }
  } catch (err) {
    console.error(err);
    statusEl.innerText = "Erro de conexão!";
    statusEl.style.color = "#ff4d4d";
    return false;
  }
}

async function carregarDaApi() {
  const statusEl = document.getElementById('api_status_msg');
  if (!currentCharacterId) {
    statusEl.innerText = "Nenhuma ficha está aberta.";
    statusEl.style.color = "#ffd700";
    return false;
  }
  ['vidaMax', 'sanidadeMax', 'defesaAtual'].forEach(id => {
    document.getElementById(id).dataset.bonusArquetipo = '0';
  });
  statusEl.innerText = "Carregando...";
  statusEl.style.color = "#ffd700";

  try {
    const { response, data: d } = await apiRequest(`/api/personagem/${encodeURIComponent(currentCharacterId)}`);
    if (!response.ok) {
      statusEl.innerText = d.detail || "Não encontrado!";
      statusEl.style.color = "#ff4d4d";
      return false;
    }

    document.getElementById('nomePersonagem').value = d.nome || '';
    document.getElementById('jogador').value = d.jogador || '';
    document.getElementById('nivel').value = d.nivel || 1;
    document.getElementById('conceito').value = d.conceito || '';
    const originSelect = document.getElementById('origem');
    const savedOrigin = d.origem || '';
    if (savedOrigin && !Array.from(originSelect.options).some(
      option => option.value === savedOrigin
    )) {
      originSelect.add(new Option(`${savedOrigin} (legado)`, savedOrigin));
    }
    originSelect.value = savedOrigin;
    const archetypeSelect = document.getElementById('arquetipo');
    const savedArchetype = d.arquetipo || '';
    if (savedArchetype && !Array.from(archetypeSelect.options).some(
      (option) => option.value === savedArchetype
    )) {
      archetypeSelect.add(new Option(`${savedArchetype} (legado)`, savedArchetype));
    }
    archetypeSelect.value = savedArchetype;
    document.getElementById('vidaAtual').value = d.vida_atual || 10;
    document.getElementById('vidaMax').value = d.vida_max || 10;
    document.getElementById('sanidadeAtual').value = d.sanidade_atual || 10;
    document.getElementById('sanidadeMax').value = d.sanidade_max || 10;
    document.getElementById('defesaAtual').value = d.defesa_atual || 10;
    document.getElementById('bonusProtecoes').value = d.bonus_protecoes || 0;
    document.getElementById('deslocamentoBaseMetros').value = d.deslocamento_base || 9;
    document.getElementById('cargaMaxima').value = d.carga_maxima || 10;
    document.getElementById('resistencias').value = d.resistencias || '';
    document.getElementById('proficiencias').value = d.proficiencias || '';
    document.getElementById('desc_aparencia').value = d.desc_aparencia || '';
    document.getElementById('desc_personalidade').value = d.desc_personalidade || '';
    document.getElementById('desc_historico').value = d.desc_historico || '';
    document.getElementById('desc_objetivo').value = d.desc_objetivo || '';
    document.getElementById('desc_anotacoes').value = d.desc_anotacoes || '';

    // Atributos
    if (d.atributos) {
      d.atributos.forEach(attr => {
        const inputVal = document.getElementById('atr_' + attr.nome);
        const checkDeb = document.getElementById('deb_' + attr.nome);
        if (inputVal) inputVal.value = attr.valor;
        if (checkDeb) checkDeb.checked = attr.debilitado;
        atualizarDadoAtributo(attr.nome);
      });
    }

    // Perícias
    if (d.pericias) {
      d.pericias.forEach(per => {
        const idx = PERICIAS_BASE.findIndex(p => p.nome === per.nome);
        if (idx !== -1) {
          const selTreino = document.getElementById('treino_p_' + idx);
          const inputBonus = document.getElementById('bonus_p_' + idx);
          if (selTreino) {
            selTreino.value = per.treinamento;
            selTreino.dataset.automaticoOrigem = String(per.automatico_origem || false);
          }
          if (inputBonus) inputBonus.value = per.bonus;
          atualizarDadoPericia(idx);
        }
      });
    }

    // Inventário
    const tbody = document.getElementById('tabela-itens');
    tbody.innerHTML = '';
    if (d.inventario) {
      d.inventario.forEach(item => {
        const tr = document.createElement('tr');
        tr.innerHTML = `
          <td><input type="text" value="${item.nome}" oninput="atualizarOpcoesArmas()"></td>
          <td><input type="number" value="${item.espaco}" style="width: 60px;" oninput="calcularCarga()"></td>
          <td><input type="text" value="${item.descricao || ''}"></td>
          <td><button class="btn-danger" onclick="this.closest('tr').remove(); calcularCarga(); atualizarOpcoesArmas();">X</button></td>
        `;
        tbody.appendChild(tr);
      });
    }

    // Trilha Paranormal
    if (d.exposicao_paranormal) {
      const idxTrilha = niveisParanormal.indexOf(d.exposicao_paranormal);
      if (idxTrilha !== -1) indiceParanormalAtual = idxTrilha;
    }
    if (d.afinidade_elemento) {
      const selAfinidade = document.getElementById('selectAfinidade');
      if (selAfinidade) {
        selAfinidade.value = d.afinidade_elemento;
        mudarAfinidadeTema();
      }
    }
    contadorCrisesTotal = d.crises_contador || 0;
    indiceDadoParanormal = d.dado_paranormal_idx || 0;
    atualizarTrilhaUI();

    // Habilidades, Rituais, Poderes
    listas.habilidade = d.habilidades || [];
    listas.ritual = d.rituais || [];
    listaPoderes = d.poderes || [];
    renderCards('habilidade');
    renderCards('ritual');
    renderPoderes();

    atualizarCalculos();
    sincronizarOrigem();
    chaveHabilidadesArquetipo = null;
    sincronizarHabilidadesArquetipo();
    calcularCarga();
    atualizarDeslocamentoBase();
    atualizarOpcoesArmas();

    statusEl.innerText = "Carregado com sucesso!";
    statusEl.style.color = "#4effb0";
    lastSaveSuccessful = true;
    return true;
  } catch (err) {
    console.error(err);
    statusEl.innerText = "Erro ao conectar!";
    statusEl.style.color = "#ff4d4d";
    return false;
  }
}


window.onload = function() {
  renderPoderes();
  initPericias();
  initTrilhaParanormal();
  initDados();
  atualizarCalculos();
  calcularVantagens();
};

let csrfToken = "";
let authMode = "login";
let currentCharacterId = null;
let autosaveTimer = null;
let autosavePending = false;
let autosaveRunning = null;
let lastSaveSuccessful = true;
let hasEditedCurrentSheet = false;

async function apiRequest(path, options = {}) {
  const headers = { ...(options.headers || {}) };
  if (csrfToken && options.method && options.method !== "GET") {
    headers["X-CSRF-Token"] = csrfToken;
  }
  const response = await fetch(path, {
    ...options,
    headers,
    credentials: "same-origin"
  });
  const data = await response.json().catch(() => ({}));
  if (response.status === 401 && document.body.classList.contains("authenticated")) {
    showLoginScreen();
  }
  return { response, data };
}

function showLoginScreen(message = "") {
  csrfToken = "";
  document.body.classList.remove("authenticated");
  document.getElementById("auth-message").textContent = message;
  document.getElementById("auth-username").focus();
}

async function carregarListaPersonagens() {
  const { response, data } = await apiRequest("/api/personagens");
  if (!response.ok) {
    throw new Error(data.detail || "Não foi possível carregar suas fichas.");
  }
  const list = document.getElementById("character-list");
  list.replaceChildren();
  document.getElementById("dashboard-message").textContent =
    data.length ? "" : "Você ainda não tem fichas. Crie uma para começar.";
  for (const character of data) {
    const card = document.createElement("article");
    card.className = "character-card";
    const info = document.createElement("div");
    info.className = "character-info";
    const name = document.createElement("h3");
    name.textContent = character.nome || "Sem nome";
    const details = document.createElement("p");
    details.textContent = `Nível ${character.nivel}` +
      (character.conceito ? ` · ${character.conceito}` : "");
    info.append(name, details);

    const actions = document.createElement("div");
    actions.className = "character-actions";
    const access = document.createElement("button");
    access.type = "button";
    access.textContent = "Acessar";
    access.addEventListener("click", () => abrirFicha(character.id));
    const remove = document.createElement("button");
    remove.type = "button";
    remove.className = "btn-danger";
    remove.textContent = "Excluir";
    remove.addEventListener("click", () => excluirFicha(character.id, character.nome));
    actions.append(access, remove);
    card.append(info, actions);
    list.append(card);
  }
}

async function carregarArquetipos() {
  const { response, data } = await apiRequest("/api/arquetipos");
  if (!response.ok) {
    throw new Error(data.detail || "Não foi possível carregar os arquétipos.");
  }
  const select = document.getElementById("arquetipo");
  select.replaceChildren(new Option("Selecione um arquétipo", ""));
  for (const archetype of data) {
    arquetiposPorNome[archetype.nome] = archetype;
    select.add(new Option(archetype.nome, archetype.nome));
  }
}

async function carregarOrigens() {
  const { response, data } = await apiRequest('/api/origens');
  if (!response.ok) {
    throw new Error(data.detail || 'Não foi possível carregar as origens.');
  }
  const select = document.getElementById('origem');
  select.replaceChildren(new Option('Selecione uma origem', ''));
  origensPorNome = {};
  for (const origem of data) {
    origensPorNome[origem.nome] = origem;
    select.add(new Option(origem.nome, origem.nome));
  }
}

async function abrirFicha(characterId) {
  const status = document.getElementById("dashboard-message");
  status.textContent = "";
  currentCharacterId = String(characterId);
  hasEditedCurrentSheet = false;
  lastSaveSuccessful = true;
  document.body.classList.add("editing");
  const loaded = await carregarDaApi();
  if (!loaded) {
    document.body.classList.remove("editing");
    status.textContent = document.getElementById("api_status_msg").textContent;
  }
}

async function excluirFicha(characterId, characterName) {
  if (!window.confirm(`Excluir a ficha "${characterName}"? Essa ação não pode ser desfeita.`)) {
    return;
  }
  const status = document.getElementById("dashboard-message");
  status.textContent = "Excluindo ficha...";
  try {
    const { response, data } = await apiRequest(
      `/api/personagem/${encodeURIComponent(characterId)}`,
      { method: "DELETE" }
    );
    if (!response.ok) {
      throw new Error(data.detail || "Não foi possível excluir a ficha.");
    }
    if (String(characterId) === currentCharacterId) {
      currentCharacterId = null;
    }
    document.getElementById("api_status_msg").textContent = "";
    await carregarListaPersonagens();
  } catch (error) {
    status.textContent = error.message;
  }
}

document.getElementById("login-tab").addEventListener("click", () => {
  authMode = "login";
  document.getElementById("login-tab").classList.add("active");
  document.getElementById("register-tab").classList.remove("active");
  document.getElementById("login-tab").setAttribute("aria-selected", "true");
  document.getElementById("register-tab").setAttribute("aria-selected", "false");
  document.getElementById("auth-submit").textContent = "Entrar";
  document.getElementById("auth-password").setAttribute("autocomplete", "current-password");
  document.getElementById("auth-message").textContent = "";
});

document.getElementById("register-tab").addEventListener("click", () => {
  authMode = "register";
  document.getElementById("register-tab").classList.add("active");
  document.getElementById("login-tab").classList.remove("active");
  document.getElementById("register-tab").setAttribute("aria-selected", "true");
  document.getElementById("login-tab").setAttribute("aria-selected", "false");
  document.getElementById("auth-submit").textContent = "Criar conta";
  document.getElementById("auth-password").setAttribute("autocomplete", "new-password");
  document.getElementById("auth-message").textContent = "A senha deve ter pelo menos 8 caracteres.";
});

document.getElementById("auth-form").addEventListener("submit", async (event) => {
  event.preventDefault();
  const submitButton = document.getElementById("auth-submit");
  submitButton.disabled = true;
  document.getElementById("auth-message").textContent = "Aguarde...";
  try {
    const { response, data } = await apiRequest(`/api/auth/${authMode}`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        username: document.getElementById("auth-username").value,
        password: document.getElementById("auth-password").value
      })
    });
    if (!response.ok) {
      throw new Error(data.detail || "Não foi possível entrar.");
    }
    csrfToken = data.csrf_token;
    document.getElementById("auth-password").value = "";
    document.getElementById("account_username").textContent = data.username;
    document.getElementById("dashboard-username").textContent = data.username;
    document.getElementById("editor-account-username").textContent = data.username;
    await carregarArquetipos();
    await carregarOrigens();
    await carregarListaPersonagens();
    document.body.classList.add("authenticated");
    document.body.classList.remove("editing");
    document.getElementById("api_status_msg").textContent = "";
  } catch (error) {
    document.getElementById("auth-message").textContent = error.message;
  } finally {
    submitButton.disabled = false;
  }
});

document.getElementById("new-character-form").addEventListener("submit", async (event) => {
  event.preventDefault();
  const nameInput = document.getElementById("new-character-name");
  const button = document.getElementById("create-character-button");
  const status = document.getElementById("dashboard-message");
  button.disabled = true;
  status.textContent = "Criando ficha...";
  try {
    const { response, data } = await apiRequest("/api/personagem", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ nome: nameInput.value.trim() })
    });
    if (!response.ok) {
      throw new Error(data.detail || "Não foi possível criar a ficha.");
    }
    nameInput.value = "";
    currentCharacterId = String(data.id);
    await carregarListaPersonagens();
    status.textContent = "";
    await abrirFicha(data.id);
    if (document.body.classList.contains("editing") && currentCharacterId === String(data.id)) {
      document.getElementById("vidaAtual").value = document.getElementById("vidaMax").value;
      document.getElementById("sanidadeAtual").value = document.getElementById("sanidadeMax").value;
      renderBarras();
      programarAutosave(0);
      await flushAutosave();
    }
  } catch (error) {
    status.textContent = error.message;
  } finally {
    button.disabled = false;
  }
});

document.getElementById("back-to-dashboard").addEventListener("click", async () => {
  if (hasEditedCurrentSheet && !lastSaveSuccessful && !autosavePending && !autosaveRunning) {
    autosavePending = true;
  }
  if (autosavePending || autosaveRunning) {
    const saved = await flushAutosave();
    if (!saved) {
      document.getElementById("api_status_msg").textContent =
        "Não foi possível salvar. Verifique a conexão e tente novamente.";
      return;
    }
  }
  hasEditedCurrentSheet = false;
  document.body.classList.remove("editing");
  document.getElementById("api_status_msg").textContent = "";
  try {
    await carregarListaPersonagens();
  } catch (error) {
    document.getElementById("dashboard-message").textContent = error.message;
  }
});

function programarAutosave(delay = 600) {
  if (!document.body.classList.contains("authenticated") ||
      !document.body.classList.contains("editing") ||
      !currentCharacterId) {
    return;
  }
  hasEditedCurrentSheet = true;
  lastSaveSuccessful = false;
  autosavePending = true;
  document.getElementById("api_status_msg").textContent = "Alterações pendentes...";
  document.getElementById("api_status_msg").style.color = "#ffd700";
  clearTimeout(autosaveTimer);
  autosaveTimer = setTimeout(() => {
    flushAutosave();
  }, delay);
}

function flushAutosave() {
  clearTimeout(autosaveTimer);
  autosaveTimer = null;
  if (autosaveRunning) {
    return autosaveRunning;
  }
  autosaveRunning = (async () => {
    while (autosavePending) {
      autosavePending = false;
      const saved = await salvarNaApi();
      if (!saved) {
        return false;
      }
      if (!autosavePending) {
        lastSaveSuccessful = true;
      }
    }
    return lastSaveSuccessful;
  })();
  const running = autosaveRunning;
  running.finally(() => {
    if (autosaveRunning === running) {
      autosaveRunning = null;
    }
    if (autosavePending && document.body.classList.contains("editing")) {
      autosaveTimer = setTimeout(() => flushAutosave(), 0);
    }
  });
  return running;
}

const fichaContainer = document.querySelector(".ficha-container");
fichaContainer.addEventListener("input", (event) => {
  if (event.target.matches("input, select, textarea")) {
    programarAutosave();
  }
});
fichaContainer.addEventListener("change", (event) => {
  if (event.target.matches("input, select, textarea")) {
    programarAutosave(50);
  }
});
fichaContainer.addEventListener("focusout", (event) => {
  if (event.target.matches("input, select, textarea") && hasEditedCurrentSheet) {
    programarAutosave(0);
  }
});
fichaContainer.addEventListener("click", (event) => {
  if (event.target.closest("#back-to-dashboard")) {
    return;
  }
  if (event.target.closest("button")) {
    programarAutosave();
  }
});

async function sairDaConta() {
  const buttons = [
    document.getElementById("logout-button"),
    document.getElementById("dashboard-logout")
  ];
  buttons.forEach((button) => { button.disabled = true; });
  try {
    const { response, data } = await apiRequest("/api/auth/logout", { method: "POST" });
    if (!response.ok) {
      throw new Error(data.detail || "Não foi possível sair.");
    }
    window.location.reload();
  } catch (error) {
    document.getElementById("api_status_msg").textContent = error.message;
  } finally {
    buttons.forEach((button) => { button.disabled = false; });
  }
}
let todasHabilidades = [];
let tierAtivo = 'Tier I';

async function abrirModalNovaHabilidade() {
    limparFormularioModal();
    
    document.getElementById('modal-item').style.display = 'flex';
    document.getElementById('modal-titulo').innerText = 'Nova Habilidade';

    const container = document.getElementById('listaCatalogoHabilidades');

    if (todasHabilidades.length === 0) {
        container.innerHTML = '<p style="color: #aaa; margin: 0;">A carregar habilidades...</p>';
        
        try {
            const response = await fetch('/api/catalogo/habilidades');
            if (!response.ok) {
                throw new Error(`Status ${response.status}: Não foi possível aceder a /api/catalogo/habilidades`);
            }
            todasHabilidades = await response.json();
        } catch (error) {
            console.error('Erro ao carregar habilidades:', error);
            container.innerHTML = `<p style="color:#ff5555; margin: 0; font-size: 0.85em;">
                Erro ao carregar o catálogo (${error.message}). Verifique se o caminho apontado por ABILITIES_PATH existe.
            </p>`;
            return;
        }
    }

    filtrarEExibirHabilidades('Tier I');
}

function normalizarTier(texto) {
    if (!texto) return '';
    return texto.toString().toLowerCase().replace(/\s+/g, '');
}

function filtrarEExibirHabilidades(tier) {
    if (tier) tierAtivo = tier;

    const inputBusca = document.getElementById('buscaHabilidade');
    const termo = inputBusca ? inputBusca.value.toLowerCase().trim() : '';
    const tierAlvoNormalizado = normalizarTier(tierAtivo);

    const filtradas = todasHabilidades.filter(h => {
        const tierItem = normalizarTier(h.tier || h.classificacao);
        
        const bateTier = (tierItem === tierAlvoNormalizado) ||
                         (tierAlvoNormalizado === 'tier1' && tierItem === 'tieri') ||
                         (tierAlvoNormalizado === 'tieri' && tierItem === 'tier1') ||
                         (tierAlvoNormalizado === 'tier2' && tierItem === 'tierii') ||
                         (tierAlvoNormalizado === 'tierii' && tierItem === 'tier2') ||
                         (tierAlvoNormalizado === 'tier3' && tierItem === 'tieriii') ||
                         (tierAlvoNormalizado === 'tieriii' && tierItem === 'tier3') ||
                         (tierAlvoNormalizado === 'tier4' && tierItem === 'tieriv') ||
                         (tierAlvoNormalizado === 'tieriv' && tierItem === 'tier4');

        const bateTexto = h.nome.toLowerCase().includes(termo) || 
                          (h.prereq && h.prereq.toLowerCase().includes(termo));

        return bateTier && bateTexto;
    });

    renderizarCardsCatalogo(filtradas);
}

function renderizarCardsCatalogo(lista) {
    const container = document.getElementById('listaCatalogoHabilidades');

    if (!lista || lista.length === 0) {
        container.innerHTML = '<p style="color: #aaa; margin: 0; padding: 5px;">Nenhuma habilidade encontrada para este Tier.</p>';
        return;
    }

    window.habilidadesExibidas = lista;

    container.innerHTML = lista.map((item, index) => `
        <div style="background: #181818; border: 1px solid #333; padding: 10px; margin-bottom: 8px; border-radius: 5px; display: flex; justify-content: space-between; align-items: center; gap: 10px;">
            <div style="flex: 1;">
                <strong style="color: #fff; font-size: 0.95em;">${item.nome}</strong> 
                <span style="font-size: 0.75em; color: #aaa; background: #2a2a2a; padding: 2px 6px; border-radius: 3px; margin-left: 6px;">${item.tier || item.classificacao}</span>
                <p style="margin: 3px 0 0 0; font-size: 0.8em; color: #888;">
                    <strong>Pré-req:</strong> ${item.prereq || 'Nenhum'} | <strong>Custo:</strong> ${item.custo || 'Nenhum'}
                </p>
            </div>
            <button type="button" class="btn btn-sm btn-success" onclick="selecionarHabilidadePorIndice(${index})" style="white-space: nowrap; padding: 4px 10px; font-size: 0.85em;">
                Selecionar
            </button>
        </div>
    `).join('');
}

function selecionarHabilidadePorIndice(index) {
    const item = window.habilidadesExibidas[index];
    if (!item) return;

    document.getElementById('modal-nome').value = item.nome || '';
    document.getElementById('modal-classificacao').value = item.tier || item.classificacao || '';
    document.getElementById('modal-prereq').value = item.prereq || '';
    document.getElementById('modal-custo').value = item.custo || '';
    document.getElementById('modal-alcance').value = item.alcance || '';
    document.getElementById('modal-efeito').value = item.efeito || '';
}

function limparFormularioModal() {
    document.getElementById('modal-nome').value = '';
    document.getElementById('modal-classificacao').value = '';
    document.getElementById('modal-prereq').value = '';
    document.getElementById('modal-custo').value = '';
    document.getElementById('modal-alcance').value = '';
    document.getElementById('modal-efeito').value = '';
    const busca = document.getElementById('buscaHabilidade');
    if (busca) busca.value = '';
}

function fecharModal() {
    document.getElementById('modal-item').style.display = 'none';
}

// ===== CATÁLOGO DE RITUAIS =====
let todosRituais = [];
let circuloAtivoRitual = '';

function abrirModalNovoRitual() {
    limparFiltrosRitual();
    document.getElementById('modal-ritual').style.display = 'flex';
    document.getElementById('modal-ritual-titulo').innerText = 'Adicionar Ritual';
    document.getElementById('ritual-catalogo-view').style.display = '';
    document.getElementById('ritual-manual-view').style.display = 'none';

    const container = document.getElementById('listaCatalogoRituais');
    if (todosRituais.length === 0) {
        container.innerHTML = '<p style="color: #aaa; margin: 0;">Carregando rituais...</p>';
        fetch('/api/catalogo/rituais')
            .then(r => {
                if (!r.ok) throw new Error('Status ' + r.status);
                return r.json();
            })
            .then(data => {
                todosRituais = data;
                filtrarRituais();
            })
            .catch(error => {
                console.error('Erro ao carregar rituais:', error);
                container.innerHTML = '<p style="color:#ff5555; margin: 0;">Erro ao carregar o catálogo de rituais.</p>';
            });
    } else {
        filtrarRituais();
    }
}

function fecharModalRitual() {
    document.getElementById('modal-ritual').style.display = 'none';
}

function limparFiltrosRitual() {
    circuloAtivoRitual = '';
    const sel = document.getElementById('ritual-elemento-filter');
    if (sel) sel.value = '';
    const busca = document.getElementById('ritualBusca');
    if (busca) busca.value = '';
}

function elementoIncluiTexto(elementoRitual, filtro) {
    if (!filtro) return true;
    if (!elementoRitual) return false;
    return elementoRitual.toLowerCase().includes(filtro.toLowerCase());
}

function filtrarRituais(circulo) {
    if (circulo !== undefined) circuloAtivoRitual = circulo || '';

    // destaque no botão ativo
    document.querySelectorAll('#modal-ritual [data-circulo]').forEach(btn => {
        btn.style.fontWeight = btn.dataset.circulo === circuloAtivoRitual ? 'bold' : 'normal';
        btn.style.outline = btn.dataset.circulo === circuloAtivoRitual ? '1px solid #ffd700' : 'none';
    });

    const filtroElemento = document.getElementById('ritual-elemento-filter')?.value || '';
    const termo = document.getElementById('ritualBusca')?.value.toLowerCase().trim() || '';

    const filtrados = todosRituais.filter(r => {
        const bateCirculo = !circuloAtivoRitual
            || normalizarTier(r.circulo || r.classificacao) === normalizarTier(circuloAtivoRitual);
        const bateElemento = elementoIncluiTexto(r.elemento, filtroElemento);
        const bateTexto = !termo || (r.nome || '').toLowerCase().includes(termo);
        return bateCirculo && bateElemento && bateTexto;
    });

    renderizarRituaisCatalogo(filtrados);
}

function renderizarRituaisCatalogo(lista) {
    const container = document.getElementById('listaCatalogoRituais');
    if (!lista || lista.length === 0) {
        container.innerHTML = '<p style="color: #aaa; margin: 0; padding: 5px;">Nenhum ritual encontrado com esses filtros.</p>';
        return;
    }
    window.rituaisExibidos = lista;
    container.innerHTML = lista.map((item, index) => `
        <div style="background: #181818; border: 1px solid #333; padding: 10px; margin-bottom: 8px; border-radius: 5px;">
            <div style="display: flex; justify-content: space-between; align-items: center; gap: 10px;">
                <div style="flex: 1;">
                    <strong style="color: #fff; font-size: 0.95em;">${item.nome}</strong>
                    <span style="font-size: 0.75em; color: #aaa; background: #2a2a2a; padding: 2px 6px; border-radius: 3px; margin-left: 6px;">${item.circulo || item.classificacao}</span>
                    <span style="font-size: 0.75em; color: #9cf; background: #1a2733; padding: 2px 6px; border-radius: 3px; margin-left: 4px;">${item.elemento || ''}</span>
                    <p style="margin: 3px 0 0 0; font-size: 0.8em; color: #888;">
                        <strong>Custo:</strong> ${item.custo || 'Nenhum'} | <strong>Alcance:</strong> ${item.alcance || 'N/A'} | <strong>Execução:</strong> ${item.execucao || '—'}
                    </p>
                </div>
                <button type="button" class="btn btn-sm btn-success" onclick="selecionarRitualPorIndice(${index})" style="white-space: nowrap; padding: 4px 10px; font-size: 0.85em;">Adicionar</button>
            </div>
        </div>
    `).join('');
}

const ELEMENTOS_RITUAL = ['sangue', 'morte', 'energia', 'conhecimento'];

function ritualEhMultiElemento(item) {
    if (!item.elemento) return false;
    const mencionados = ELEMENTOS_RITUAL.filter(el =>
        item.elemento.toLowerCase().includes(el)
    );
    return mencionados.length > 1;
}

function selecionarRitualPorIndice(index, elementoEscolhido) {
    const item = window.rituaisExibidos[index];
    if (!item) return;

    // Guardas defensivas (página ainda não inicializada)
    if (typeof listas === 'undefined' || !Array.isArray(listas.ritual) || typeof renderCards !== 'function') {
        alert('A ficha ainda está carregando. Tente novamente em instantes.');
        return;
    }

    // Rituais multi-elemento (ex.: Amaldiçoar Arma): pedir escolha antes de salvar
    if (!elementoEscolhido && ritualEhMultiElemento(item)) {
        const escolha = prompt(
            `Este ritual pode ser de vários elementos. Qual deseja usar?\n\n${ELEMENTOS_RITUAL.map(el => '• ' + el.charAt(0).toUpperCase() + el.slice(1)).join('\n')}`
        );
        if (!escolha) return; // cancelado
        const normalizado = escolha.trim().toLowerCase();
        if (!ELEMENTOS_RITUAL.includes(normalizado)) {
            alert('Elemento inválido. Use: Sangue, Morte, Energia ou Conhecimento.');
            return;
        }
        selecionarRitualPorIndice(index, normalizado);
        return;
    }

    const novoRitual = {
        nome: item.nome || '',
        classificacao: item.circulo || item.classificacao || '',
        prereq: '',
        custo: item.custo || '',
        alcance: item.alcance || '',
        elemento: elementoEscolhido || normalizarElementoPoder(item.elemento) || '',
        efeito: [
            item.elemento ? `Elemento: ${item.elemento}` : '',
            item.execucao ? `Execução: ${item.execucao}` : '',
            item.resistencia && item.resistencia !== 'Nenhuma' ? `Resistência: ${item.resistencia}` : '',
            item.efeito || ''
        ].filter(Boolean).join('\n')
    };
    // Ritual multi-elemento: refletir a escolha no efeito
    if (elementoEscolhido && ritualEhMultiElemento(item)) {
        novoRitual.efeito = novoRitual.efeito.replace(
            /Elemento: .*?(?=\n|$)/,
            `Elemento: ${elementoEscolhido.charAt(0).toUpperCase() + elementoEscolhido.slice(1)}`
        );
    }

    listas.ritual.push(novoRitual);
    renderCards('ritual');
    fecharModalRitual();
    if (typeof programarAutosave === 'function') programarAutosave(0);
}

function abrirFormRitualManual() {
    ['rit-man-nome', 'rit-man-custo', 'rit-man-alcance', 'rit-man-efeito'].forEach(id => {
        const el = document.getElementById(id);
        if (el) el.value = '';
    });
    document.getElementById('ritual-catalogo-view').style.display = 'none';
    document.getElementById('ritual-manual-view').style.display = '';
    document.getElementById('modal-ritual-titulo').innerText = 'Criar Novo Ritual';
}

function voltarAoCatalogoRituais() {
    document.getElementById('ritual-catalogo-view').style.display = '';
    document.getElementById('ritual-manual-view').style.display = 'none';
    document.getElementById('modal-ritual-titulo').innerText = 'Adicionar Ritual';
}

// ===== CATÁLOGO DE ARMAS =====
let todasArmas = [];
let profAtivaArma = '';

function abrirModalArmas() {
    profAtivaArma = '';
    const sel = document.getElementById('arma-tipo-filter');
    if (sel) sel.value = '';
    const busca = document.getElementById('armaBusca');
    if (busca) busca.value = '';
    document.getElementById('modal-arma').style.display = 'flex';

    const container = document.getElementById('listaCatalogoArmas');
    if (todasArmas.length === 0) {
        container.innerHTML = '<p style="color: #aaa; margin: 0;">Carregando armas...</p>';
        fetch('/api/catalogo/armas')
            .then(r => {
                if (!r.ok) throw new Error('Status ' + r.status);
                return r.json();
            })
            .then(data => {
                todasArmas = data;
                filtrarArmas();
            })
            .catch(error => {
                console.error('Erro ao carregar armas:', error);
                container.innerHTML = '<p style="color:#ff5555; margin: 0;">Erro ao carregar o catálogo de armas.</p>';
            });
    } else {
        filtrarArmas();
    }
}

function fecharModalArma() {
    document.getElementById('modal-arma').style.display = 'none';
}

function filtrarArmas(proficiencia) {
    if (proficiencia !== undefined) profAtivaArma = proficiencia || '';

    document.querySelectorAll('#modal-arma [data-prof]').forEach(btn => {
        btn.style.fontWeight = btn.dataset.prof === profAtivaArma ? 'bold' : 'normal';
        btn.style.outline = btn.dataset.prof === profAtivaArma ? '1px solid #ffd700' : 'none';
    });

    const filtroTipo = (document.getElementById('arma-tipo-filter')?.value || '').toLowerCase();
    const termo = document.getElementById('armaBusca')?.value.toLowerCase().trim() || '';

    const filtradas = todasArmas.filter(a => {
        const bateProf = !profAtivaArma
            || (a.proficiencia || '').toLowerCase().includes(profAtivaArma.toLowerCase());
        const bateTipo = !filtroTipo || (a.tipo || '').toLowerCase().includes(filtroTipo);
        const bateTexto = !termo || (a.nome || '').toLowerCase().includes(termo);
        return bateProf && bateTipo && bateTexto;
    });

    renderizarArmasCatalogo(filtradas);
}

function renderizarArmasCatalogo(lista) {
    const container = document.getElementById('listaCatalogoArmas');
    if (!lista || lista.length === 0) {
        container.innerHTML = '<p style="color: #aaa; margin: 0; padding: 5px;">Nenhuma arma encontrada com esses filtros.</p>';
        return;
    }
    window.armasExibidas = lista;
    container.innerHTML = lista.map((item, index) => `
        <div style="background: #181818; border: 1px solid #333; padding: 10px; margin-bottom: 8px; border-radius: 5px;">
            <div style="display: flex; justify-content: space-between; align-items: center; gap: 10px;">
                <div style="flex: 1;">
                    <strong style="color: #fff; font-size: 0.95em;">${escaparHTML(item.nome)}</strong>
                    <span style="font-size: 0.75em; color: #aaa; background: #2a2a2a; padding: 2px 6px; border-radius: 3px; margin-left: 6px;">${escaparHTML(item.proficiencia)}</span>
                    <span style="font-size: 0.75em; color: #f88; background: #331a1a; padding: 2px 6px; border-radius: 3px; margin-left: 4px;">${escaparHTML(item.dano_base)}</span>
                    <span style="font-size: 0.75em; color: #9cf; background: #1a2733; padding: 2px 6px; border-radius: 3px; margin-left: 4px;">${escaparHTML(item.tipo_dano)}</span>
                    <p style="margin: 3px 0 0 0; font-size: 0.8em; color: #888;">
                        <strong>Crítico:</strong> ${escaparHTML(item.critico)} | <strong>Alcance:</strong> ${escaparHTML(item.alcance)} | <strong>Espaço:</strong> ${item.espaco}
                    </p>
                </div>
                <button type="button" class="btn btn-sm btn-success" onclick="selecionarArmaPorIndice(${index})" style="white-space: nowrap; padding: 4px 10px; font-size: 0.85em;">Adicionar</button>
            </div>
        </div>
    `).join('');
}

function selecionarArmaPorIndice(index) {
    const item = window.armasExibidas[index];
    if (!item) return;

    if (typeof listas === 'undefined' || typeof renderCards !== 'function') {
        alert('A ficha ainda está carregando. Tente novamente em instantes.');
        return;
    }

    // Monta a descrição com todos os atributos da arma
    const descricao = [
        `Proficiência: ${item.proficiencia}`,
        `Tipo: ${item.tipo}`,
        `Empunhadura: ${item.empunhadura}`,
        `Dano: ${item.dano_base} (crítico ${item.critico}, ${item.tipo_dano})`,
        `Alcance: ${item.alcance}`,
        item.habilidades ? `\n${item.habilidades}` : ''
    ].filter(Boolean).join('\n');

    // Adiciona como linha na tabela do inventário
    const tbody = document.getElementById('tabela-itens');
    const tr = document.createElement('tr');
    tr.innerHTML = `
      <td><input type="text" value="${escaparHTML(item.nome)}" oninput="atualizarOpcoesArmas()"></td>
      <td><input type="number" value="${item.espaco}" style="width: 60px;" oninput="calcularCarga()"></td>
      <td><textarea rows="3" style="width: 100%; font-size: 0.75rem;" placeholder="Descrição">${escaparHTML(descricao)}</textarea></td>
      <td><button class="btn-danger" onclick="this.closest('tr').remove(); calcularCarga(); atualizarOpcoesArmas();">X</button></td>
    `;
    tbody.appendChild(tr);

    calcularCarga();
    atualizarOpcoesArmas();
    fecharModalArma();
    if (typeof programarAutosave === 'function') programarAutosave(0);
}

function salvarRitualModal() {
    const nome = document.getElementById('rit-man-nome').value.trim();
    if (!nome) {
        alert('Por favor, informe o nome do ritual.');
        return;
    }
    if (typeof listas === 'undefined' || !Array.isArray(listas.ritual) || typeof renderCards !== 'function') {
        alert('A ficha ainda está carregando. Tente novamente em instantes.');
        return;
    }

    listas.ritual.push({
        nome: nome,
        classificacao: document.getElementById('rit-man-circulo').value,
        prereq: '',
        custo: document.getElementById('rit-man-custo').value.trim(),
        alcance: document.getElementById('rit-man-alcance').value.trim(),
        elemento: normalizarElementoPoder(document.getElementById('rit-man-elemento').value),
        efeito: document.getElementById('rit-man-efeito').value.trim()
    });
    renderCards('ritual');
    fecharModalRitual();
    if (typeof programarAutosave === 'function') programarAutosave(0);
}

document.getElementById("logout-button").addEventListener("click", sairDaConta);
document.getElementById("dashboard-logout").addEventListener("click", sairDaConta);

(async () => {
  try {
    const { response, data } = await apiRequest("/api/auth/me");
    if (!response.ok) {
      showLoginScreen();
      return;
    }
    csrfToken = data.csrf_token;
    document.getElementById("account_username").textContent = data.username;
    document.getElementById("dashboard-username").textContent = data.username;
    document.getElementById("editor-account-username").textContent = data.username;
    await carregarArquetipos();
    await carregarOrigens();
    await carregarListaPersonagens();
    document.body.classList.add("authenticated");
  } catch (error) {
    showLoginScreen(error.message || "Não foi possível conectar ao servidor.");
  }
})();
