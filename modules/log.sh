# =========================
# FILE: modules/log.sh
# =========================
init_log() {
    exec > >(tee -a install.log) 2>&1
}
