#!/usr/bin/env bash
# ============================================================
# AtlasAta DotFiles Backup — GitHub
# Çalıştır: cd ~ && bash dotfiles-backup.sh
# ============================================================

BRANCH="main"
COMMIT_MSG="backup: $(date '+%Y-%m-%d %H:%M')"

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
info()    { echo -e "${GREEN}[✓]${NC} $1"; }
warning() { echo -e "${YELLOW}[!]${NC} $1"; }
error()   { echo -e "${RED}[✗]${NC} $1"; exit 1; }

cd "$HOME" || error "HOME dizinine gidilemedi"

# ── 1. Git repo kontrolü ─────────────────────────────────────
if [ ! -d ".git" ]; then
    error "Git repo bulunamadı. Önce 'git init' çalıştır."
fi

if ! git remote get-url origin &>/dev/null; then
    error "Remote 'origin' ayarlı değil. Çalıştır: git remote add origin git@github.com:atlasatakahraman/AtlasAta-DotFiles.git"
fi

info "Remote: $(git remote get-url origin)"

# ── 2. .gitattributes (LFS YOK) ──────────────────────────────
# Sadece yoksa yaz
if [ ! -f ".gitattributes" ]; then
    cat > .gitattributes << 'EOF'
# AtlasAta DotFiles — LFS kullanılmıyor, sade git
* text=auto eol=lf
*.png binary
*.jpg binary
*.jpeg binary
*.webp binary
*.gif binary
*.ico binary
*.ttf binary
*.otf binary
*.woff binary
*.woff2 binary
*.mp3 binary
*.ogg binary
*.zip binary
*.tar binary
*.gz binary
*.zst binary
*.psd binary
EOF
    info ".gitattributes oluşturuldu"
fi

# ── 3. .gitignore kontrolü ───────────────────────────────────
if [ ! -f ".gitignore" ]; then
    error ".gitignore bulunamadı! Önce ~/.gitignore dosyasını oluştur."
fi
info ".gitignore mevcut ($(wc -l < .gitignore) satır)"

# ── 4. Pre-flight: token/secret scan ─────────────────────────
info "Token taraması yapılıyor..."
DANGER=$(git diff --cached --name-only 2>/dev/null; git ls-files --others --exclude-standard 2>/dev/null) 

# Check staged/new files for dangerous patterns
HITS=$(git add -A --dry-run 2>&1 | awk '{print $2}' | while read f; do
  [ -f "$f" ] && grep -lqiE "(access_token|refresh_token|client_secret|Bearer [a-zA-Z0-9])" "$f" 2>/dev/null && echo "$f"
done)

if [ -n "$HITS" ]; then
  error "⛔ Potansiyel token bulundu:\n$HITS\n\n.gitignore güncelle, sonra tekrar çalıştır."
fi

# ── 4. Stage & Commit ────────────────────────────────────────
info "Dosyalar stage ediliyor..."
git add -A 2>&1 | grep -v "^warning"

STAGED=$(git diff --cached --name-only | wc -l)
if [ "$STAGED" -eq 0 ]; then
    warning "Değişiklik yok, zaten güncel."
    exit 0
fi
info "$STAGED dosya stage edildi"

git commit -m "$COMMIT_MSG" || {
    warning "Commit yapılamadı"
    exit 0
}
info "Commit: $COMMIT_MSG"

# ── 5. Push ──────────────────────────────────────────────────
info "GitHub'a push ediliyor..."
if git ls-remote --exit-code origin "$BRANCH" &>/dev/null; then
    git push origin "$BRANCH" || {
        warning "Normal push başarısız, force-with-lease deneniyor..."
        git push origin "$BRANCH" --force-with-lease
    }
else
    git push -u origin "$BRANCH" || error "Push başarısız."
fi

info "✅ Dotfiles backup tamamlandı → github.com/atlasatakahraman/AtlasAta-DotFiles"
