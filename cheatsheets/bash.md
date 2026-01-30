╔════════════════════════════════════════════════════════════════╗
║                  BASH/TERMINAL CHEAT SHEET                      ║
╚════════════════════════════════════════════════════════════════╝

═══ DIRECTORY STRUCTURE & EXPLORATION ══════════════════════════════

find - Recursively search and list files/directories
  find /path/to/dir -type f                  Only files
  find /path/to/dir -name "*.txt"            Find files matching pattern

which - Locate an executable in PATH
  which command_name                         Show path to command/binary

═══ TEXT PROCESSING ═══════════════════════════════════════════════

grep - Search for patterns
  grep "pattern" file                    Search in file
  grep -r "pattern" .                    Recursive search in directory

sed - Stream editor (find/replace, line manipulation)
  sed 's/old/new/g' file                 Replace all occurrences per line
  sed -i 's/old/new/g' file              In-place edit

awk - Text processing & column extraction
  awk '{print $1}' file                  Print first column
  awk -F: '{print $1}' /etc/passwd       Use : as field delimiter

cut - Extract columns/fields
  cut -d: -f1 /etc/passwd                Get first field (delimiter :)
  cut -c1-5 file                         Extract characters 1-5

head/tail - First and last lines
  head -n 5 file                         First 5 lines
  tail -f file                           Follow file (live updates)

sort - Sort lines
  sort file                               Sort alphabetically
  sort -n file                           Sort numerically

uniq - Remove/count duplicates
  uniq file                              Remove consecutive duplicates
  sort file | uniq                       Remove all duplicates (common pattern)

wc - Count lines, words, characters
  wc -l file                             Count lines
  wc -w file                             Count words

tr - Translate/delete characters
  tr 'a-z' 'A-Z' < file                  Convert lowercase to uppercase
  tr -d ':' < file                       Delete colons

═══ PIPES & REDIRECTION ═════════════════════════════════════════

|  - Pipe stdout to next command
  cat file | grep "pattern"              Search in file contents

> - Redirect stdout (overwrite file)
  echo "text" > file                     Write to file (create/overwrite)

>> - Redirect stdout (append to file)
  echo "text" >> file                    Append to file

< - Redirect stdin (read from file)
  grep "pattern" < file                  Use file as input

2> - Redirect stderr (error messages)
  command 2> errors.txt                  Save errors to file

2>&1 - Redirect stderr to stdout
  command > output.txt 2>&1              Save both output and errors

&> - Redirect both stdout and stderr
  command &> output.txt                  Save everything to file

|& - Pipe both stdout and stderr
  command1 |& command2                   Pipe errors and output

tee - Write to file AND stdout
  command | tee output.txt               Display output AND save to file

pbcopy - Copy to clipboard (macOS)
  cat file | pbcopy                      Copy file contents to clipboard

Combining redirects:
  command > out.txt 2> err.txt           Separate stdout and stderr
  command1 | tee temp.txt | command2     Pipe through tee for intermediate save

═══ COMMON PATTERNS ═════════════════════════════════════════════

Multiple pipes (left to right):
  cat file | grep "pattern" | sort | uniq | wc -l
  Count unique matching lines

Conditional execution:
  command1 && command2                   Run command2 only if command1 succeeds

Combine with find:
  find . -name "*.txt" | xargs grep "pattern"
  Search for pattern in all .txt files

═══ BASIC NAVIGATION & FILES ══════════════════════════════════════

cd /path                                 Change directory
ls -la                                   List files (long format, hidden)
mkdir dirname                            Create directory
cp source dest                           Copy file
rm file                                  Delete file

═══ PERMISSIONS & OWNERSHIP ════════════════════════════════════════

chmod u+x file                           Add execute permission for user
chown user:group file                    Change ownership

═══ USEFUL KEYBOARD SHORTCUTS ══════════════════════════════════════

Ctrl+C                                   Cancel current command
Ctrl+R                                   Search command history
!!                                       Repeat last command

═══ CUSTOM TOOLS ══════════════════════════════════════════════════

rg - Ripgrep (faster grep replacement)
  rg "pattern" .                         Recursive search in directory
  rg -l "pattern" .                      List files containing pattern only

fzf - Fuzzy finder for interactive selection
  fzf                                    Open interactive fuzzy finder

tree - Display directory tree structure
  tree -L 2                              Show directory tree up to 2 levels deep

uc_search - Tool for searching for and opening a file in the urbancompass repo with vim