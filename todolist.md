# Todolist

## Tasks
- Browser extension for darkmode for upside website
    - Maybe use something like matugen for a color pallete generator
- Interactive Keywords to Tech map
    - Keywords to learn
        - Touchpoints
        - Company
        - Ontology
        - Accounts
- Fix lazyvim configurations following https://www.lazyvim.org/configuration/lazy.nvim to use core.lua
    - Add options.lua
- Organize my pacman packages in a logical structure and understand ALL of them, trim down if I don't need anything.
- Todo App
    - Profiles (personal, work, dev)
    - Notifications
    - Shareable (view, edit, etc)
    - wxWidget (cross platform)
    - websockets
    - draft mode (if offline)
        - git-like?
- Learn regex
    - Regex-generator CLI
    - Writing man page for this!??? My first tackle at man pages?
- xargs uv add
    - what is xargs? Why is is useful? Is it worth trying to understand and write my own for learning purposes?
- presentation (line-by-line) plugin for neovim (vim?)

- Need to fix mainmod to alt because I'm so used to mac now.
- Waybar fix
- rofi fix
- wofi fix

## Completed

- [x] Create todolist.md file
- [x] Add nvim keybind Alt+Enter that behaves like VSCode's go to definition (F12) - opens file with definition and places cursor at definition
- [x] Fix Alt+Enter keybind for macOS - use Cmd+Enter instead
- [x] Add OS detection to automatically map Alt keybinds to Cmd on macOS
- [x] Update all existing Alt keybinds to use the OS-adaptive mapping
- [x] Create MDC file for cursor-agent CLI to manage todolist.md
- [x] Add cursor-agent function with .cursor/rules/*.mdc detection to .bashrc
- [x] True color for mac terminal tmux apparently
    - This was a Makefile issue where echo needed the -e flag to properly interprety the macOSX escape sequence.
