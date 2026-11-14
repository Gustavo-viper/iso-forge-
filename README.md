# Forge Jogos Educativos

Coleção de jogos educativos em português para crianças do ensino fundamental.
Funciona direto no navegador, no computador, tablet ou celular: sem instalação, sem internet e sem dependências.

## Como jogar

Abra o arquivo `index.html` no navegador e escolha um jogo.

Para publicar na internet, basta hospedar a pasta como site estático (por exemplo, GitHub Pages: *Settings → Pages → Deploy from a branch → `main` / raiz*).

## Jogos

| Jogo | Matéria | O que ensina |
| --- | --- | --- |
| ➗ Desafio da Matemática | Matemática | As quatro operações, com 3 níveis e tempo para responder |
| 🔤 Adivinhe a Palavra | Português | Ortografia e vocabulário, com dicas por categoria |
| 🧠 Memória em Inglês | Inglês | Vocabulário de animais, comidas e objetos |
| 🗺️ Capitais do Brasil | Geografia | Os 26 estados, o Distrito Federal e suas capitais, por região |
| ♻️ Coleta Seletiva | Ciências | As cores das lixeiras e o descarte correto dos resíduos |
| 🕒 Que Horas São? | Matemática | Leitura de relógio de ponteiros, das horas cheias aos 5 minutos |

Cada partida vale de 0 a 3 estrelas. A melhor pontuação de cada jogo fica salva no navegador (`localStorage`).

## Estrutura

```
index.html        Página inicial com todos os jogos
css/style.css     Estilo compartilhado
js/comum.js       Sons, estrelas, embaralhar e tela de resultado
jogos/*.html      Um arquivo por jogo
```

Para criar um novo jogo, copie um dos arquivos de `jogos/`, use as funções de `window.Jogos` (de `js/comum.js`) e adicione o jogo à lista em `index.html`.
