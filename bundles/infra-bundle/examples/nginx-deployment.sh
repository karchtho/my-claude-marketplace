#!/usr/bin/env bash
# nginx-deployment.sh - Complete Nginx deployment automation using bash best practices
# Demonstrates integration of bash-scripting and nginx-configuration skills
# Usage: ./nginx-deployment.sh [options] <config-dir>

set -euo pipefail
IFS=$'\n\t'

# =============================================================================
# Configuration
# =============================================================================

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"
readonly NGINX_CONFIG_DIR="${NGINX_CONFIG_DIR:-/etc/nginx}"
readonly NGINX_BIN="${NGINX_BIN:-$(command -v nginx || echo nginx)}"
readonly BACKUP_DIR="/var/backups/nginx"
readonly LOG_FILE="/var/log/nginx-deployment.log"

# Exit codes
readonly EXIT_SUCCESS=0
readonly EXIT_FAILURE=1
readonly EXIT_INVALID_ARGS=2
readonly EXIT_NGINX_ERROR=3

# Flags
VERBOSE="${VERBOSE:-false}"
DRY_RUN="${DRY_RUN:-false}"
BACKUP="${BACKUP:-true}"

# =============================================================================
# Logging & Error Handling
# =============================================================================

log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    echo "[$timestamp] [$level] $message" | tee -a "$LOG_FILE"
}

log_info() { log "INFO" "$@"; }
log_warn() { log "WARN" "$@" >&2; }
log_error() { log "ERROR" "$@" >&2; }

debug() {
    if [[ "$VERBOSE" == "true" ]]; then
        log "DEBUG" "$@"
    fi
}

die() {
    log_error "$@"
    exit "$EXIT_FAILURE"
}

# Cleanup on exit
cleanup() {
    local exit_code=$?
    if [[ $exit_code -ne 0 ]]; then
        log_error "Deployment failed with exit code $exit_code"
    fi
    exit "$exit_code"
}

trap cleanup EXIT

# =============================================================================
# Validation Functions
# =============================================================================

check_prerequisites() {
    log_info "Checking prerequisites..."

    # Check if running as root
    if [[ $EUID -ne 0 ]]; then
        die "This script must be run as root"
    fi

    # Check if nginx is installed
    if ! command -v "$NGINX_BIN" &>/dev/null; then
        die "Nginx not found. Install with: apt-get install nginx"
    fi

    # Check required directories
    if [[ ! -d "$NGINX_CONFIG_DIR" ]]; then
        die "Nginx config directory not found: $NGINX_CONFIG_DIR"
    fi

    log_info "All prerequisites met"
}

validate_nginx_syntax() {
    local config_dir="$1"

    log_info "Validating Nginx configuration syntax..."

    # Test main config
    if ! "$NGINX_BIN" -c "$config_dir/nginx.conf" -t 2>&1 | tee -a "$LOG_FILE"; then
        die "Nginx configuration validation failed"
    fi

    log_info "Nginx configuration is valid"
}

# =============================================================================
# Backup Functions
# =============================================================================

backup_current_config() {
    local config_dir="$1"

    if [[ "$BACKUP" != "true" ]]; then
        debug "Backup disabled, skipping"
        return
    fi

    log_info "Backing up current Nginx configuration..."

    # Create backup directory
    mkdir -p "$BACKUP_DIR" || die "Failed to create backup directory"

    # Create timestamped backup
    local backup_name
    backup_name=$(date +"%Y%m%d_%H%M%S")
    local backup_file="$BACKUP_DIR/nginx_${backup_name}.tar.gz"

    if tar -czf "$backup_file" -C "$config_dir" . 2>/dev/null; then
        log_info "Configuration backed up to: $backup_file"
        debug "Backup size: $(du -h "$backup_file" | cut -f1)"
    else
        log_warn "Failed to create backup"
    fi
}

restore_from_backup() {
    local backup_file="$1"
    local config_dir="$2"

    if [[ ! -f "$backup_file" ]]; then
        die "Backup file not found: $backup_file"
    fi

    log_warn "Restoring from backup: $backup_file"

    # Create temporary directory for extraction
    local temp_dir
    temp_dir=$(mktemp -d) || die "Failed to create temp directory"
    trap "rm -rf '$temp_dir'" RETURN

    # Extract backup
    if ! tar -xzf "$backup_file" -C "$temp_dir"; then
        die "Failed to extract backup"
    fi

    # Restore files
    cp -r "$temp_dir"/* "$config_dir/" || die "Failed to restore configuration"
    log_info "Restore completed"
}

# =============================================================================
# Deployment Functions
# =============================================================================

deploy_config() {
    local source_dir="$1"
    local target_dir="$2"

    if [[ ! -d "$source_dir" ]]; then
        die "Source configuration directory not found: $source_dir"
    fi

    log_info "Deploying configuration from: $source_dir"

    # Create temporary working directory
    local temp_dir
    temp_dir=$(mktemp -d) || die "Failed to create temp directory"
    trap "rm -rf '$temp_dir'" RETURN

    # Copy configuration
    cp -r "$source_dir"/* "$temp_dir/" || die "Failed to copy configuration"

    # Validate syntax in temp location
    if ! "$NGINX_BIN" -c "$temp_dir/nginx.conf" -t 2>&1 | tee -a "$LOG_FILE"; then
        die "Configuration validation failed"
    fi

    # Backup current config
    backup_current_config "$target_dir"

    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "DRY RUN: Would deploy $(find "$temp_dir" -type f | wc -l) files"
        return
    fi

    # Deploy configuration
    log_info "Deploying files..."
    cp -r "$temp_dir"/* "$target_dir/" || die "Failed to deploy configuration"

    # Fix permissions
    chown -R root:root "$target_dir" 2>/dev/null || true
    chmod -R 755 "$target_dir" 2>/dev/null || true
    find "$target_dir" -type f -exec chmod 644 {} \; 2>/dev/null || true

    log_info "Configuration deployed successfully"
}

# =============================================================================
# Nginx Service Management
# =============================================================================

reload_nginx() {
    log_info "Reloading Nginx..."

    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "DRY RUN: Would reload Nginx"
        return
    fi

    # Ensure nginx is running
    if systemctl is-active --quiet nginx; then
        if systemctl reload nginx 2>&1 | tee -a "$LOG_FILE"; then
            log_info "Nginx reloaded successfully"
            sleep 1
        else
            die "Failed to reload Nginx"
        fi
    else
        log_info "Nginx not running, starting..."
        if systemctl start nginx 2>&1 | tee -a "$LOG_FILE"; then
            log_info "Nginx started successfully"
            sleep 2
        else
            die "Failed to start Nginx"
        fi
    fi
}

verify_deployment() {
    log_info "Verifying deployment..."

    # Check if Nginx is running
    if ! systemctl is-active --quiet nginx; then
        log_error "Nginx is not running"
        return 1
    fi

    # Check port 80
    if netstat -tuln 2>/dev/null | grep -q ":80 " || ss -tuln 2>/dev/null | grep -q ":80 "; then
        log_info "Port 80 is open"
    else
        log_warn "Port 80 is not open"
    fi

    # Check port 443 if using HTTPS
    if grep -r "listen.*443" "$NGINX_CONFIG_DIR" 2>/dev/null | grep -qv "^\s*#"; then
        if netstat -tuln 2>/dev/null | grep -q ":443 " || ss -tuln 2>/dev/null | grep -q ":443 "; then
            log_info "Port 443 is open"
        else
            log_warn "Port 443 is configured but not open"
        fi
    fi

    # Test health endpoint if it exists
    if grep -r "location /health" "$NGINX_CONFIG_DIR" 2>/dev/null | grep -qv "^\s*#"; then
        log_info "Testing health endpoint..."
        if curl -sf http://localhost/health >/dev/null 2>&1; then
            log_info "Health endpoint is responding"
        else
            log_warn "Health endpoint not responding"
        fi
    fi

    log_info "Verification completed"
}

# =============================================================================
# Main Workflow
# =============================================================================

usage() {
    cat <<EOF
Usage: $SCRIPT_NAME [OPTIONS] <config-dir>

Deploy and manage Nginx configuration changes with validation and rollback.

OPTIONS:
    -h, --help          Show this help message
    -v, --verbose       Enable verbose output
    -d, --dry-run       Show what would be done without making changes
    --no-backup         Skip backup creation
    --restore <file>    Restore configuration from backup file
    --verify-only       Only verify current configuration

EXAMPLES:
    # Deploy new configuration
    $SCRIPT_NAME /path/to/new/config

    # Dry run deployment
    $SCRIPT_NAME -d /path/to/new/config

    # Restore from backup
    $SCRIPT_NAME --restore /var/backups/nginx/nginx_20240108_101530.tar.gz

    # Verify current configuration
    $SCRIPT_NAME --verify-only

ENVIRONMENT VARIABLES:
    VERBOSE             Set to 'true' for verbose output
    DRY_RUN             Set to 'true' for dry-run mode
    BACKUP              Set to 'false' to skip backups
    NGINX_CONFIG_DIR    Nginx config directory (default: /etc/nginx)

EOF
}

parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                usage
                exit "$EXIT_SUCCESS"
                ;;
            -v|--verbose)
                VERBOSE="true"
                shift
                ;;
            -d|--dry-run)
                DRY_RUN="true"
                shift
                ;;
            --no-backup)
                BACKUP="false"
                shift
                ;;
            --restore)
                shift
                if [[ -z "${1:-}" ]]; then
                    die "Option --restore requires an argument"
                fi
                restore_from_backup "$1" "$NGINX_CONFIG_DIR"
                exit "$EXIT_SUCCESS"
                ;;
            --verify-only)
                validate_nginx_syntax "$NGINX_CONFIG_DIR"
                exit "$EXIT_SUCCESS"
                ;;
            -*)
                die "Unknown option: $1"
                ;;
            *)
                CONFIG_DIR="$1"
                shift
                ;;
        esac
    done

    if [[ -z "${CONFIG_DIR:-}" ]]; then
        usage
        exit "$EXIT_INVALID_ARGS"
    fi
}

main() {
    log_info "Starting Nginx deployment..."
    debug "Script: $SCRIPT_NAME"
    debug "Verbose: $VERBOSE"
    debug "Dry run: $DRY_RUN"
    debug "Backup: $BACKUP"

    check_prerequisites
    validate_nginx_syntax "$CONFIG_DIR"
    deploy_config "$CONFIG_DIR" "$NGINX_CONFIG_DIR"
    reload_nginx
    verify_deployment

    log_info "Nginx deployment completed successfully"
}

# Parse arguments and run main
parse_args "$@"
main
