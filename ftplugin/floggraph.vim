" mappings {{{

if !exists("g:flognavigate_no_hjkl_mappings")
  nnoremap <buffer> <silent> h :<C-U>call flognavigate#jump_to_parent()<CR>
  nnoremap <buffer> <silent> j :<C-U>call flognavigate#down()<CR>
  nnoremap <buffer> <silent> k :<C-U>call flognavigate#up()<CR>
  nnoremap <buffer> <silent> l :<C-U>call flognavigate#jump_to_child()<CR>
endif

if !exists("g:flognavigate_no_head_mappings")
  nnoremap <buffer> <silent> ]h :<C-U>call flognavigate#jump_to_next_head()<CR>
  nnoremap <buffer> <silent> [h :<C-U>call flognavigate#jump_to_previous_head()<CR>
endif

if !exists("g:flognavigate_no_ref_mappings")
  nnoremap <buffer> <silent> ]r :<C-U>call flog#next_ref()<CR>
  nnoremap <buffer> <silent> [r :<C-U>call flog#previous_ref()<CR>
endif

" }}}
