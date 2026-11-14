// Funções compartilhadas por todos os jogos.
(function () {
  "use strict";

  const CHAVE = "forge-jogos-progresso";

  function lerProgresso() {
    try {
      return JSON.parse(localStorage.getItem(CHAVE)) || {};
    } catch (e) {
      return {};
    }
  }

  // Guarda apenas o melhor número de estrelas (0 a 3) de cada jogo.
  function salvarEstrelas(jogo, estrelas) {
    const p = lerProgresso();
    if (!p[jogo] || estrelas > p[jogo]) {
      p[jogo] = estrelas;
      try { localStorage.setItem(CHAVE, JSON.stringify(p)); } catch (e) { /* modo privado */ }
    }
  }

  function textoEstrelas(n) {
    return "★".repeat(n) + "☆".repeat(3 - n);
  }

  // Converte uma proporção de acertos (0 a 1) em estrelas.
  function calcularEstrelas(proporcao) {
    if (proporcao >= 0.9) return 3;
    if (proporcao >= 0.6) return 2;
    if (proporcao >= 0.3) return 1;
    return 0;
  }

  function embaralhar(lista) {
    const a = lista.slice();
    for (let i = a.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      [a[i], a[j]] = [a[j], a[i]];
    }
    return a;
  }

  function sortear(lista, n) {
    return embaralhar(lista).slice(0, n);
  }

  function aleatorio(min, max) {
    return Math.floor(Math.random() * (max - min + 1)) + min;
  }

  // Remove acentos para comparar letras (ex.: "ã" vale como "a").
  function semAcento(texto) {
    return texto.normalize("NFD").replace(/[̀-ͯ]/g, "");
  }

  // Sons simples gerados pelo navegador, sem arquivos de áudio.
  let ctx = null;
  let somLigado = true;
  function tocar(notas) {
    if (!somLigado) return;
    try {
      ctx = ctx || new (window.AudioContext || window.webkitAudioContext)();
      let t = ctx.currentTime;
      notas.forEach(([freq, dur]) => {
        const osc = ctx.createOscillator();
        const ganho = ctx.createGain();
        osc.type = "sine";
        osc.frequency.value = freq;
        ganho.gain.setValueAtTime(0.18, t);
        ganho.gain.exponentialRampToValueAtTime(0.001, t + dur);
        osc.connect(ganho).connect(ctx.destination);
        osc.start(t);
        osc.stop(t + dur);
        t += dur * 0.8;
      });
    } catch (e) { /* áudio indisponível */ }
  }

  const som = {
    acerto: () => tocar([[660, 0.12], [880, 0.18]]),
    erro: () => tocar([[220, 0.25]]),
    vitoria: () => tocar([[523, 0.15], [659, 0.15], [784, 0.15], [1046, 0.3]]),
    alternar: () => { somLigado = !somLigado; return somLigado; },
  };

  // Monta a tela de resultado padrão dentro de um elemento.
  function mostrarResultado(el, { jogo, acertos, total, titulo, aoReiniciar }) {
    const estrelas = calcularEstrelas(total ? acertos / total : 0);
    salvarEstrelas(jogo, estrelas);
    const frases = [
      "Continue praticando, você vai conseguir!",
      "Bom começo! Tente de novo para melhorar.",
      "Muito bem! Falta pouco para a perfeição.",
      "Incrível! Você é fera!",
    ];
    el.innerHTML = `
      <div class="resultado centro">
        <h2>${titulo || "Fim de jogo!"}</h2>
        <div class="grande-estrela" aria-label="${estrelas} de 3 estrelas">${textoEstrelas(estrelas)}</div>
        <p class="pergunta">${acertos} / ${total}</p>
        <p>${frases[estrelas]}</p>
        <div class="linha-botoes">
          <button class="btn" data-acao="reiniciar">Jogar de novo</button>
          <a class="btn secundario" href="../index.html">Outros jogos</a>
        </div>
      </div>`;
    if (estrelas >= 2) som.vitoria();
    el.querySelector('[data-acao="reiniciar"]').addEventListener("click", aoReiniciar);
  }

  window.Jogos = {
    lerProgresso, salvarEstrelas, textoEstrelas, calcularEstrelas,
    embaralhar, sortear, aleatorio, semAcento, som, mostrarResultado,
  };
})();
