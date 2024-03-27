" Global state {{{

let g:flognavigate_head_offset = 0

let s:path = expand('<sfile>:h:h')
execute("source " .. s:path .. "/flog/floggraph/buf.vim")

" }}}
