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
- `ui`:
  - `fold.lua`
  - `statusline.lua`

----------------------------------------
> [todo]()
----------------------------------------
- `project`:
  - `scratch`
  - `sync`
- `ui`:
  - `opener.lua`
  - `snippet`:
    - `divider.lua`
    - `header.lua`
    - `link_header.lua`

=-----------------------------------------------------------
= [migrating nvim/lua/lex/config into hnetxt-lua]()
=-----------------------------------------------------------
- `Location`:
  - overwrite `Location:__tostring` to: relativize `path`
  - overwrite `Location:from_str` to: relativize `path`
  - test `Location.goto`
  - implement `Location.update`
    - figure out what to do; should this only be done from within vim?
