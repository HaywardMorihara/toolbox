#!/usr/bin/env bash
# lib/config.sh - Configuration directories setup

setup_config_dirs() {
  local component_name="Config directories (~/.config/toolbox)"

  # Use XDG Base Directory standard
  local config_home="${XDG_CONFIG_HOME:-$HOME/.config}"
  local toolbox_config_dir="$config_home/toolbox"

  local dir_exists=false
  if [[ -d "$toolbox_config_dir" ]]; then
    log_success "$component_name already exists"
    dir_exists=true
  else
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
  fi

  # Always store the installation path (even if directory already existed)
  store_install_path || {
    log_warn "Failed to store installation path"
  }

  return 0
}

# Store the toolbox installation path in config directory
# This allows shell functions to find the toolbox repo regardless of installation location
store_install_path() {
  local config_home="${XDG_CONFIG_HOME:-$HOME/.config}"
  local toolbox_config_dir="$config_home/toolbox"
  local install_path_file="$toolbox_config_dir/install-path"

  # Write current REPO_ROOT to install-path file
  echo "$REPO_ROOT" > "$install_path_file" || {
    log_error "Failed to write installation path to $install_path_file"
    return 1
  }

  return 0
}

register_check "~/.config/toolbox directory" "[[ -d \"\${XDG_CONFIG_HOME:-\$HOME/.config}/toolbox\" ]]"
