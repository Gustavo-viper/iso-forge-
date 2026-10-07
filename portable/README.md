# Forge OS Portable V1

A primeira camada do modo portátil para Windows.

## Estrutura

- `ForgeOS-Portable.bat` — iniciador com duplo clique.
- `ForgeOS-Portable.ps1` — configura e inicia a VM.
- `ForgeOS-V1-x64.iso` — ISO do Forge OS, quando o build da ISO estiver concluído.
- `ForgeOS.vhdx` — disco virtual persistente do Forge OS.
- `qemu/` — QEMU para Windows.

## Objetivo

Executar o Forge OS dentro do Windows sem reiniciar o computador e manter os dados no HD externo.

## Próximas etapas

1. Empacotar uma versão portátil do QEMU.
2. Gerar/criar o disco VHDX persistente.
3. Conectar a ISO Forge OS ao primeiro boot.
4. Criar inicialização automática da instalação para o VHDX.
5. Otimizar CPU/RAM, rede, vídeo, áudio e compartilhamento de área de transferência.
6. Criar um lançador gráfico Forge OS Portable.
