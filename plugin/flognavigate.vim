" mappings {{{

if !exists("g:flognavigate_no_hjkl_mappings")
  augroup flog_hjkl
    autocmd FileType floggraph nno <buffer> <silent> h :<C-U>call flognavigate#jump_to_parent()<CR>
    autocmd FileType floggraph nno <buffer> <silent> j :<C-U>call flognavigate#down()<CR>
    autocmd FileType floggraph nno <buffer> <silent> k :<C-U>call flognavigate#up()<CR>
    autocmd FileType floggraph nno <buffer> <silent> l :<C-U>call flognavigate#jump_to_child()<CR>
  augroup END
endif

if !exists("g:flognavigate_no_head_mappings")
  augroup flog_head
    autocmd FileType floggraph nno <buffer> <silent> ]h :<C-U>call flognavigate#jump_to_next_head()<CR>
    autocmd FileType floggraph nno <buffer> <silent> [h :<C-U>call flognavigate#jump_to_previous_head()<CR>
  augroup END
endif

if !exists("g:flognavigate_no_ref_mappings")
  augroup flog_ref
    autocmd FileType floggraph nno <buffer> <silent> ]r :<C-U>call flog#next_ref()<CR>
    autocmd FileType floggraph nno <buffer> <silent> [r :<C-U>call flog#previous_ref()<CR>
  augroup END
endif

" }}}
