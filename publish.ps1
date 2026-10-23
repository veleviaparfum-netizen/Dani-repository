param(
    [string]$Message = "Update portfolio",
    [string]$RepositoryUrl = ""
)

$ErrorActionPreference = "Stop"

if ($RepositoryUrl) {
    $remotes = @(git remote)
    if ($remotes -contains "origin") {
        git remote set-url origin $RepositoryUrl
    }
    else {
        git remote add origin $RepositoryUrl
    }
}

$remotes = @(git remote)
if ($remotes -notcontains "origin") {
    throw "Remote origin belum ada. Jalankan dengan URL repository GitHub."
}

$gitIdentity = git config user.name
if (-not $gitIdentity) {
    throw "Git identity belum diatur. Jalankan: git config --global user.name 'Nama Kamu'"
}

$gitEmail = git config user.email
if (-not $gitEmail) {
    throw "Git email belum diatur. Jalankan: git config --global user.email 'email@contoh.com'"
}

git add --all
git diff --cached --quiet
$hasStagedChanges = $LASTEXITCODE -ne 0

if ($hasStagedChanges) {
    git commit -m $Message
}
else {
    Write-Host "Tidak ada perubahan baru untuk dibuat commit."
}

$currentBranch = (git branch --show-current).Trim()
if (-not $currentBranch) {
    git branch --show-current
}
if ($currentBranch -ne "main") {
    git branch -M main
}

git push -u origin main
if ($LASTEXITCODE -ne 0) {
    throw "Push ke GitHub gagal. Periksa login Git, akses repository, dan pesan error GitHub di atas."
}
Write-Host "Website berhasil diperbarui ke GitHub."
