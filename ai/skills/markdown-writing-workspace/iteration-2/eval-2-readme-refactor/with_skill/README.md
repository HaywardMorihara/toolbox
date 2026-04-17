# DataTool

DataTool is a CLI for processing and transforming data files. It supports CSV, JSON, and XML formats.

## Requirements

- Python 3.9 or higher
- macOS or Linux

## Installation

```bash
pip install datatool
```

## Usage

Run DataTool with a command and any associated flags:

```bash
datatool <command> [options]
```

### Commands

| Command | Description |
|---------|-------------|
| `transform` | Convert data between formats. Specify input and output formats. |
| `validate` | Check data quality and identify common issues. |
| `export` | Export data in various formats for use with other tools. |
| `merge` | Combine multiple data files into one. |

For detailed options and parameters for each command, run `datatool <command> --help`.
