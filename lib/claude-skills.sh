#!/usr/bin/env bash
# lib/claude-skills.sh - Symlink local skills to Claude Code's skills directory

setup_claude_skills() {
  local component_name="Claude Skills"
  local skills_source="$REPO_ROOT/config/skills"
  local skills_target="$HOME/.claude/skills"

  # Check if source skills directory exists
  if [[ ! -d "$skills_source" ]]; then
    log_warn "No skills directory found at $skills_source"
    return 0
  fi

  # Check if there are any skills to install
  local skill_count=0
  for skill_dir in "$skills_source"/*/; do
    if [[ -f "${skill_dir}SKILL.md" ]]; then
      ((skill_count++))
    fi
  done

  if [[ $skill_count -eq 0 ]]; then
    log_info "No skills found to install"
    return 0
  fi

  # Check if should install
  if ! should_install "INSTALL_SKILLS" "$component_name"; then
    return 1
  fi

  log_info "Installing $component_name..."

  # Create target directory if it doesn't exist
  mkdir -p "$skills_target" || {
    log_error "Failed to create $skills_target"
    return 1
  }

  local installed=0
  local skipped=0

  # Iterate through each skill directory
  for skill_dir in "$skills_source"/*/; do
    local skill_name=$(basename "$skill_dir")
    local source_path="${skill_dir%/}"
    local target_path="$skills_target/$skill_name"

    # Verify SKILL.md exists
    if [[ ! -f "$source_path/SKILL.md" ]]; then
      log_warn "Skipping $skill_name: missing SKILL.md"
      continue
    fi

    # Check if symlink already exists and points to correct location
    if [[ -L "$target_path" ]]; then
      local current_target=$(readlink "$target_path")
      if [[ "$current_target" == "$source_path" ]]; then
        ((skipped++))
        continue
      else
        # Remove incorrect symlink
        rm "$target_path"
      fi
    elif [[ -e "$target_path" ]]; then
      # Something exists but isn't a symlink - back it up
      backup_file "$target_path"
      rm -rf "$target_path"
    fi

    # Create symlink
    if ln -s "$source_path" "$target_path"; then
      ((installed++))
    else
      log_error "Failed to symlink $skill_name"
    fi
  done

  if [[ $installed -gt 0 ]]; then
    log_success "$component_name: $installed installed, $skipped already linked"
  else
    log_success "$component_name: $skipped already linked"
  fi

  return 0
}

# Register check for each skill in config/skills/
_register_skill_checks() {
  local skills_source="${REPO_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}/config/skills"

  if [[ -d "$skills_source" ]]; then
    for skill_dir in "$skills_source"/*/; do
      if [[ -f "${skill_dir}SKILL.md" ]]; then
        local skill_name=$(basename "$skill_dir")
        register_check "Skill: $skill_name" "[[ -L \$HOME/.claude/skills/$skill_name ]]"
      fi
    done
  fi
}

_register_skill_checks
