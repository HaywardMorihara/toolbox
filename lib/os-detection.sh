#!/usr/bin/env bash
# lib/os-detection.sh - Platform identification

detect_os() {
  case "$(uname -s)" in
    Darwin*)
      OS="Darwin"
      PACKAGE_MANAGER="brew"
      ;;
    Linux*)
      OS="Linux"
      if command -v apt-get &> /dev/null; then
        PACKAGE_MANAGER="apt"
      elif command -v yum &> /dev/null; then
        PACKAGE_MANAGER="yum"
      elif command -v dnf &> /dev/null; then
        PACKAGE_MANAGER="dnf"
      else
        log_error "No supported package manager found"
        exit 1
      fi
      ;;
    *)
      log_error "Unsupported OS: $(uname -s)"
      exit 1
      ;;
  esac

  export OS PACKAGE_MANAGER
  log_info "Detected OS: $OS, Package Manager: $PACKAGE_MANAGER"
}
