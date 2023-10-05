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

# install.
@('tmp/virt-fw-vars') | ForEach-Object {
    if (Test-Path $_) {
        Remove-Item -Recurse -Force $_
    }
}
mkdir tmp/virt-fw-vars | Out-Null
Expand-Archive `
    -Path dist/virt-fw-vars.zip `
    -DestinationPath tmp/virt-fw-vars

# wrap virt-fw-vars.
function virt-fw-vars {
    ./tmp/virt-fw-vars/virt-fw-vars.exe @Args
    if ($LASTEXITCODE) {
        throw "failed with exit code $LASTEXITCODE"
    }
}

# test.
Write-Output 'Setting the firmware variables...'
virt-fw-vars `
    --input RPI_EFI.fd `
    --output tmp/RPI_EFI.fd `
    --set-json RPI_EFI.vars.json

Write-Output 'Listing the firmware variables...'
virt-fw-vars `
    --input tmp/RPI_EFI.fd `
    --print
