#!/usr/bin/env bash
# lib/config.sh - Configuration directories setup

setup_config_dirs() {
  local config_home="${XDG_CONFIG_HOME:-$HOME/.config}"

  # Just ensure parent ~/.config exists (stow will create package directories)
  if [[ ! -d "$config_home" ]]; then
    log_info "Creating config directory..."
    mkdir -p "$config_home" || {
      log_error "Failed to create config directory: $config_home"
      return 1
    }
    log_success "Config directory created successfully"
  else
    log_success "Config directory already exists"
  fi

  return 0
}

# Store the toolbox installation path in config directory
# This allows shell functions to find the toolbox repo regardless of installation location
store_install_path() {
  local config_home="${XDG_CONFIG_HOME:-$HOME/.config}"
  local toolbox_config_dir="$config_home/toolbox"
  local install_path_file="$toolbox_config_dir/install-path"

  # Create parent directory if needed (in case toolbox wasn't stowed)
  if [[ ! -d "$toolbox_config_dir" ]]; then
    mkdir -p "$toolbox_config_dir" || {
      log_error "Failed to create toolbox config directory: $toolbox_config_dir"
      return 1
    }
  fi

  # Write current REPO_ROOT to install-path file
  echo "$REPO_ROOT" > "$install_path_file" || {
    log_error "Failed to write installation path to $install_path_file"
    return 1
  }

  return 0
}

register_check "~/.config/toolbox directory" "[[ -d \"\${XDG_CONFIG_HOME:-\$HOME/.config}/toolbox\" ]]"
