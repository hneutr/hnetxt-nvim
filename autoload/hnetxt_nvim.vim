function! hnetxt_nvim#foldtext() abort
	  return luaeval(printf('require"hnetxt-nvim.ui.fold".get_text(%d)', v:foldstart - 1))
endfunction

function! hnetxt_nvim#foldexpr() abort
	return luaeval(printf('require"hnetxt-nvim.ui.fold".get_indic(%d)', v:lnum))
endfunction
