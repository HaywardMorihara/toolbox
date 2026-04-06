#!/usr/bin/env bash
# lib/cache.sh - Cache directories setup

setup_cache_dirs() {
  local cache_home="${XDG_CACHE_HOME:-$HOME/.cache}"
  local toolbox_cache_dir="$cache_home/toolbox"

  # Ensure ~/.cache exists
  if [[ ! -d "$cache_home" ]]; then
    log_info "Creating cache directory..."
    mkdir -p "$cache_home" || {
      log_error "Failed to create cache directory: $cache_home"
      return 1
    }
    log_success "Cache directory created successfully"
  else
    log_success "Cache directory already exists"
  fi

  # Create toolbox cache directory if needed
  if [[ ! -d "$toolbox_cache_dir" ]]; then
    mkdir -p "$toolbox_cache_dir" || {
      log_error "Failed to create toolbox cache directory: $toolbox_cache_dir"
      return 1
    }
  fi

  return 0
}

register_check "~/.cache/toolbox directory" "[[ -d \"\${XDG_CACHE_HOME:-\$HOME/.cache}/toolbox\" ]]"
