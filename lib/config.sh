#!/usr/bin/env bash
# lib/config.sh - Configuration directories setup

setup_config_dirs() {
  local component_name="Config directories (~/.config/toolbox)"

  # Use XDG Base Directory standard
  local config_home="${XDG_CONFIG_HOME:-$HOME/.config}"
  local toolbox_config_dir="$config_home/toolbox"

  if [[ -d "$toolbox_config_dir" ]]; then
    log_success "$component_name already exists"
    return 0
  fi

  if ! should_install "INSTALL_CONFIG" "$component_name"; then
    return 1
  fi

  log_info "Creating config directories..."

  # Create parent ~/.config if needed
  if [[ ! -d "$config_home" ]]; then
    mkdir -p "$config_home" || {
      log_error "Failed to create config home: $config_home"
      log_error "Make sure you have write permissions in $HOME"
      return 1
    }
  fi

  # Create ~/.config/toolbox
  mkdir -p "$toolbox_config_dir" || {
    log_error "Failed to create toolbox config directory: $toolbox_config_dir"
    return 1
  }

  log_success "$component_name created successfully"
  return 0
}

register_check "~/.config/toolbox directory" "[[ -d \"\${XDG_CONFIG_HOME:-\$HOME/.config}/toolbox\" ]]"
