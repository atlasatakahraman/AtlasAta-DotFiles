#!/usr/bin/env bash
# ============================================================
# AtlasAta Google Drive Sync — rclone tabanlı
#
# Kurulum (bir kere):
#   rclone config   → "gdrive" adıyla Google Drive ekle
#
# Çalıştır:
#   cd ~ && bash gdrive-sync.sh
#   bash gdrive-sync.sh --dry-run    (ne yapacağını görmek için)
# ============================================================

REMOTE="gdrive:AtlasAta-Backup"
HOME_DIR="$HOME"
DRY_RUN=false
LOG_FILE="$HOME/.cache/gdrive-sync.log"

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; CYAN='\033[0;36m'; NC='\033[0m'
info()    { echo -e "${GREEN}[✓]${NC} $1" | tee -a "$LOG_FILE"; }
warning() { echo -e "${YELLOW}[!]${NC} $1" | tee -a "$LOG_FILE"; }
error()   { echo -e "${RED}[✗]${NC} $1" | tee -a "$LOG_FILE"; }
section() { echo -e "\n${CYAN}══ $1 ══${NC}" | tee -a "$LOG_FILE"; }

# Argüman parse
for arg in "$@"; do
    case $arg in
        --dry-run) DRY_RUN=true; warning "DRY-RUN modu: hiçbir şey yüklenmeyecek" ;;
    esac
done

# rclone kurulu mu?
if ! command -v rclone &>/dev/null; then
    error "rclone bulunamadı. Kur: sudo pacman -S rclone"
    exit 1
fi

# gdrive remote ayarlı mı?
if ! rclone listremotes | grep -q "^gdrive:"; then
    error "gdrive remote'u bulunamadı. Çalıştır: rclone config"
    exit 1
fi

mkdir -p "$(dirname "$LOG_FILE")"
echo "=== Sync başladı: $(date '+%Y-%m-%d %H:%M:%S') ===" >> "$LOG_FILE"

# rclone copy parametreleri
RCLONE_OPTS=(
    --copy-links           # symlink'leri takip et
    --transfers 8          # paralel transfer
    --checkers 16          # paralel kontrol
    --progress             # ilerleme göster
    --stats 10s            # 10 saniyede bir istatistik
    --log-file "$LOG_FILE"
    --log-level INFO
)

[[ "$DRY_RUN" == true ]] && RCLONE_OPTS+=(--dry-run)

# ── Yardımcı fonksiyon ───────────────────────────────────────
sync_dir() {
    local src="$1"
    local dest="$2"
    shift 2
    local extra_opts=("$@")

    if [ ! -d "$src" ]; then
        warning "Dizin yok, atlanıyor: $src"
        return
    fi

    local size
    size=$(du -sh "$src" 2>/dev/null | cut -f1)
    info "Sync: $src → $REMOTE/$dest ($size)"

    rclone copy "$src" "$REMOTE/$dest" "${RCLONE_OPTS[@]}" "${extra_opts[@]}"
    local exit_code=$?

    if [ $exit_code -eq 0 ]; then
        info "✓ Tamamlandı: $dest"
    else
        warning "Hatalar var: $dest (exit: $exit_code)"
    fi
}

# ════════════════════════════════════════════════════════════
# 1. STREAM — medya, wallpaper, ses
# ════════════════════════════════════════════════════════════
section "Stream (medya)"
sync_dir "$HOME_DIR/stream" "stream"

# ════════════════════════════════════════════════════════════
# 2. KOD PROJELERİ — target ve node_modules hariç
# ════════════════════════════════════════════════════════════
section "Code (kaynak kod)"
sync_dir "$HOME_DIR/code" "code" \
    --exclude "node_modules/**" \
    --exclude "**/target/**" \
    --exclude "**/.next/**" \
    --exclude "**/out/**" \
    --exclude "**/dist/**" \
    --exclude "**/build/**" \
    --exclude "**/.turbo/**" \
    --exclude "**/.vercel/**" \
    --exclude "**/src-tauri/WixTools/**" \
    --exclude "**/__pycache__/**" \
    --exclude "**/.pytest_cache/**" \
    --exclude "**/*.pyc" \
    --exclude "**/venv/**" \
    --exclude "**/.venv/**" \
    --exclude "**/.gradle/**" \
    --exclude "**/captures/**" \
    --exclude "**/intermediates/**" \
    --exclude "**/exploded-aar/**" \
    --exclude "code/translate/input_jars/**" \
    --exclude "code/translate/jars/**" \
    --exclude "code/translate/build/**"

# ════════════════════════════════════════════════════════════
# 3. MİNECRAFT — instances + config
# ════════════════════════════════════════════════════════════
section "Minecraft"
sync_dir "$HOME_DIR/minecraft" "minecraft"

# PrismLauncher instances (büyük, ayrı hedef)
sync_dir "$HOME_DIR/.local/share/PrismLauncher/instances" "minecraft/PrismLauncher-instances"
sync_dir "$HOME_DIR/.local/share/multimc/instances" "minecraft/MultiMC-instances"

# ════════════════════════════════════════════════════════════
# 4. PICTURES & MEDIA
# ════════════════════════════════════════════════════════════
section "Pictures & Media"
sync_dir "$HOME_DIR/Pictures" "Pictures"
sync_dir "$HOME_DIR/Videos" "Videos"
sync_dir "$HOME_DIR/Music" "Music"

# ════════════════════════════════════════════════════════════
# 5. GITHUB (klonlanmış repolar)
# ════════════════════════════════════════════════════════════
section "GitHub klonları"
sync_dir "$HOME_DIR/github" "github" \
    --exclude "node_modules/**" \
    --exclude "**/target/**" \
    --exclude "**/.next/**" \
    --exclude "**/__pycache__/**"

# ════════════════════════════════════════════════════════════
# 6. ASEPRITE (pixel art projeleri)
# ════════════════════════════════════════════════════════════
section "Aseprite projeleri"
sync_dir "$HOME_DIR/aseprite" "aseprite"

# ════════════════════════════════════════════════════════════
# 7. MASAUSTU_KURTARMA & FIX
# ════════════════════════════════════════════════════════════
section "Diğer"
sync_dir "$HOME_DIR/MASAUSTU_KURTARMA" "MASAUSTU_KURTARMA"
sync_dir "$HOME_DIR/fix" "fix"
sync_dir "$HOME_DIR/Documents" "Documents"

# ════════════════════════════════════════════════════════════
# Özet
# ════════════════════════════════════════════════════════════
echo ""
info "✅ Drive sync tamamlandı: $(date '+%H:%M:%S')"
info "Log: $LOG_FILE"
info "Drive'ı görüntüle: rclone ls $REMOTE | head -20"
