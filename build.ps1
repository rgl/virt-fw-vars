# enable strict mode.
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
trap {
    Write-Host
    Write-Host "ERROR: $_"
    ($_.ScriptStackTrace -split '\r?\n') -replace '^(.*)$','ERROR: $1' | Write-Host
    ($_.Exception.ToString() -split '\r?\n') -replace '^(.*)$','ERROR EXCEPTION: $1' | Write-Host
    Exit 1
}

# install os level dependencies.
$pythonPath = "$env:ChocolateyInstall\bin\python3.12.exe"
$qemuImgPath = "$env:ProgramFiles\qemu\qemu-img.exe"
if (!(Test-Path $pythonPath)) {
    choco install -y python3 --version 3.12.0
}
if (!(Test-Path $pythonPath)) {
    throw "$pythonPath not found"
}
if (!(Test-Path $qemuImgPath)) {
    choco install -y qemu --version 2023.8.22
}
if (!(Test-Path $qemuImgPath)) {
    throw "$qemuImgPath not found"
}

# wrap os level dependencies.
function python {
    &$pythonPath @Args
    if ($LASTEXITCODE) {
        throw "failed with exit code $LASTEXITCODE"
    }
}
function pyinstaller {
    pyinstaller.exe @Args
    if ($LASTEXITCODE) {
        throw "failed with exit code $LASTEXITCODE"
    }
}

# create and enter the venv.
python -m venv .venv
. .venv/Scripts/Activate.ps1
$pythonPath = "$PWD/.venv/Scripts/python.exe"

# install dependencies.
python -m pip install -r requirements.txt

# build the dist.
@('build', 'dist') | ForEach-Object {
    if (Test-Path $_) {
        Remove-Item -Recurse -Force $_
    }
}
pyinstaller `
    --add-binary "${qemuImgPath}:." `
    virt-fw-vars.py

# bundle.
Push-Location dist/virt-fw-vars
Compress-Archive `
    -CompressionLevel Optimal `
    -DestinationPath ../virt-fw-vars.zip `
    -Path *
Pop-Location
