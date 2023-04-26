#-------------------------------------------------------------------------------
# [architecture]()
#-------------------------------------------------------------------------------
- `text`:
  - `divider.lua`
  - `flag.lua`
  - `header.lua`
  - `list.lua`
  - `location.lua`
  - `mark.lua`
- `project`:
  - `init.lua`
  - `mirror.lua`
  - `scratch.lua`
- `ui`:
  - `fold.lua`
  - `fuzzy.lua`
  - `opener.lua`
  - `statusline.lua`

----------------------------------------
> [todo]()
----------------------------------------
- `project`:
  - `sync`
- `ui`:
  - `snippet`:
    - `divider.lua`
    - `header.lua`
    - `link_header.lua`

=-----------------------------------------------------------
= [migrating nvim/lua/lex/config into hnetxt-lua]()
=-----------------------------------------------------------
- `Location`:
  - implement `Location.update`
    - figure out what to do; should this only be done from within vim?
  - figure out whether/where we should be using relative/absolute locations (in `lex.sync` and `lex.move`)
- `Reference`: figure out whether/where we should be using relative/absolute references (in `lex.move` nd `lex.sync`)
