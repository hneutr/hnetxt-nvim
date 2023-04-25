#-------------------------------------------------------------------------------
# [architecture]()
#-------------------------------------------------------------------------------
- `text`:
  - `list.lua`
  - `divider.lua`
  - `header.lua`
  - `flag.lua`
- `ui`:
  - `fold.lua`

----------------------------------------
> [todo]()
----------------------------------------
- `project`:
  - `scratch`
  - `sync`
- `ui`:
  - `opener.lua`
  - `statusline.lua`
  - `snippet`:
    - `divider.lua`
    - `header.lua`
    - `link_header.lua`

=-----------------------------------------------------------
= [migrating nvim/lua/lex/config into hnetxt-lua]()
=-----------------------------------------------------------
- `Link`:
  - overwrite `Link.get_nearest` so that:
    - `str` defaults to the current line 
    - `path` defaults to the current file
  - overwrite `Link.from_str` so that `str` defaults to the current line
- `Location`:
  - overwrite `Location:new` so that `path` defaults to the current file
  - overwrite `Location:__tostring` to: relativize `path`
  - overwrite `Location:from_str` to:
    - relativize `path`
    - default `str` to the current line
  - implement `Location.goto`
- `Mark`:
  - overwrite `Mark.from_str` so that `str` defaults to the current line
  - overwrite `Mark.str_is_a` so that `str` defaults to the current line
  - implement `Mark.goto`
- `Reference`:
  - overwrite `Reference.from_str` so that `str` defaults to the current line
  - `Reference.list` → `Reference.get_referenced_mark_locations`
  - `Reference.list_by_file` → `Reference.get_reference_locations`
- `Flag`:
  - overwrite `Flag.from_str` so that `str` defaults to the current line
