" https://github.com/m00qek/plugin-template.nvim/tree/main/test

set rtp^=./vendor/plenary.nvim/
set rtp^=../

runtime plugin/plenary.vim

lua require('plenary.busted')
lua require('setup')

"--------------------------------[ additions ]---------------------------------"
lua require('start')

" set rtp^=/usr/local/lib/luarocks/rocks-5.1
" set rtp^=./vendor/lextest.nvim/

lua rawset(_G, 'eq', assert.are.same)
