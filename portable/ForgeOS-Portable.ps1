# Forge OS Portable V1
# Runs the Forge OS Linux image inside a lightweight QEMU VM from Windows.
# Usage: right-click -> Run with PowerShell, or launch through ForgeOS-Portable.bat

$ErrorActionPreference = 'Stop'
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$Qemu = Join-Path $Root 'qemu\qemu-system-x86_64.exe'
$Disk = Join-Path $Root 'ForgeOS.vhdx'
$Iso = Join-Path $Root 'ForgeOS-V1-x64.iso'
$Ram = if ((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory -ge 8GB) { '4096' } else { '2048' }

if (-not (Test-Path $Qemu)) {
    Write-Host 'QEMU nao encontrado em portable\qemu.' -ForegroundColor Yellow
    Write-Host 'Coloque o pacote QEMU para Windows nessa pasta antes de executar.'
    Read-Host 'Pressione Enter para sair'
    exit 1
}

if (-not (Test-Path $Disk)) {
    Write-Host 'Criando disco virtual ForgeOS.vhdx...' -ForegroundColor Cyan
    & $Qemu -drive "file=$Disk,if=none,format=vpc,id=drive0" -device virtio-blk-pci,drive=drive0 -qmp stdio -S 2>$null | Out-Null
    if (-not (Test-Path $Disk)) {
        Write-Host 'Nao foi possivel criar o disco virtual automaticamente.' -ForegroundColor Red
        Read-Host 'Pressione Enter para sair'
        exit 1
    }
}

$args = @(
    '-machine','q35,accel=whpx',
    '-cpu','host',
    '-m',$Ram,
    '-smp','4',
    '-drive',"file=$Disk,if=virtio,format=vpc",
    '-nic','user,model=virtio',
    '-device','virtio-vga',
    '-display','default,window-close=on',
    '-usb',
    '-device','usb-tablet'
)

if (Test-Path $Iso) {
    $args += @('-cdrom',$Iso)
}

Write-Host 'Iniciando Forge OS Portable...' -ForegroundColor Cyan
& $Qemu @args
