" Quick navigate operations {{{

" If you bind these to j and k,
" you can more naturally go up and down one commit,
" while still being able to use your relative
" line numbers as expected
function! flognavigate#up() abort
  if v:count1 == 1
    call flog#previous_commit()
  else
    execute 'normal! ' . v:count1 . 'k'
  endif
endfunction

function! flognavigate#down() abort
  if v:count1 == 1
    call flog#next_commit()
  else
    execute 'normal! ' . v:count1 . 'j'
  endif
endfunction

" See https://vi.stackexchange.com/questions/29062/how-to-check-if-a-string-starts-with-another-string-in-vimscript/29063#29063
function! flognavigate#starts_with(longer, shorter) abort
  return a:longer[0:len(a:shorter)-1] ==# a:shorter
endfunction

function! flognavigate#find_all_predicate(haystack, predicate) abort
  return filter(copy(a:haystack), 'a:predicate(v:val)')
endfunction

" See https://vi.stackexchange.com/questions/29056/how-to-find-first-item-that-satisfies-predicate/29059#29059
function! flognavigate#find_predicate(haystack, predicate) abort
  return get(flognavigate#find_all_predicate(a:haystack, a:predicate), 0, v:null)
endfunction

function! flognavigate#find_commit(state, commit_hash) abort
  return flognavigate#find_predicate(a:state.commits, {item -> flognavigate#starts_with(a:commit_hash, item.short_commit_hash)})
endfunction

function! flognavigate#jump_to_commit(commit_hash) abort
  let l:state = flog#get_state()
  let l:commit = flognavigate#find_commit(l:state, a:commit_hash)
  if type(l:commit) != v:t_dict
    let l:state.reflog = v:true
    call flog#populate_graph_buffer()
    let l:commit = flognavigate#find_commit(l:state, a:commit_hash)
  endif
  let l:index = index(l:state.commits, l:commit)
  let l:index = min([max([l:index, 0]), len(l:state.commits) - 1])
  let l:line = index(l:state.line_commits, l:state.commits[l:index]) + 1
  if l:line >= 0
    exec l:line
  endif
endfunction

function! flognavigate#get_short_commit_hash() abort
  let l:state = flog#get_state()
  let l:current_commit = flog#get_commit_at_line()
  if type(l:current_commit) != v:t_dict
    return
  endif
  return l:current_commit.short_commit_hash
endfunction

function! flognavigate#get_full_commit_hash() abort
  let l:short = flognavigate#get_short_commit_hash()
  if type(l:short) != v:t_string
    return v:null
  endif
  return fugitive#RevParse(flognavigate#get_short_commit_hash())
endfunction

function! flognavigate#offset_head_hash() abort
  return fugitive#RevParse('HEAD@{' . g:flog_head_offset . '}')
endfunction

function! flognavigate#jump_to_offset_head(offset) abort
  let l:current_commit = flognavigate#get_full_commit_hash()
  if type(l:current_commit) != v:t_string
    return v:null
  endif
  let l:current_head_commit = flognavigate#offset_head_hash()
  if g:flog_head_offset == 0 || l:current_commit == l:current_head_commit
    let l:reflog_lines = systemlist(flog#get_fugitive_git_command() . ' reflog')
    let l:reflog_size = len(l:reflog_lines)
    let g:flog_head_offset = min([max([0, g:flog_head_offset + a:offset]), l:reflog_size - 1])
  else
    let g:flog_head_offset = 0
  endif
  let l:head_commit = flognavigate#offset_head_hash()
  call flog#jump_to_commit(l:head_commit)
  echom 'HEAD@{' . g:flog_head_offset . '}'
endfunction

" For example, bind to [h
" these are for jumping through the previously checked out commits
function! flognavigate#jump_to_previous_head() abort
  call flog#jump_to_offset_head(1)
endfunction

" For example, bind to ]h
function! flognavigate#jump_to_next_head() abort
  call flog#jump_to_offset_head(-1)
endfunction

" }}}
" Returns one of the elements of the list.
" If it has been called before with a commit
" present in the list, or has previously returned
" an element of the current list, *that* element will be
" returned. In addition, if the current commit is
" not in the list of prior inputs and outputs,
" that list is cleared. Hence there can only be one
" matching element.
" Use this as a replacement for just doing commit_list[0],
" giving the current commit as an additional input. 
" In the base case, it just returns
" the first element. But the most recent inputs and outputs 
" of this function are given priority before any others,
" giving the function 'stability' when navigating up/down
" a directed acyclic graph
function! flognavigate#stable_select(commit_list, current_commit) abort
  let l:visited_commits = get(b:, 'flog_visited_commits', [])
  if index(l:visited_commits, a:current_commit) == -1
    " When current commit is new, refresh the list to only contain
    " this commit (this of course also applies when b:flog_visited_commits
    " didn't exist yet
    let b:flog_visited_commits = [a:current_commit]
  endif
  let pick = flognavigate#find_predicate(a:commit_list, {target_commit -> index(b:flog_visited_commits, target_commit) != -1})
  if pick == v:null
    let pick = a:commit_list[0]
  endif
  if index(b:flog_visited_commits, l:pick) == -1
    call add(b:flog_visited_commits, l:pick)
  endif
  return pick
endfunction

function! flognavigate#jump_up_N_parents(amount) abort
  let l:current_commit = flognavigate#get_full_commit_hash()
  if type(l:current_commit) != v:t_string
    return
  endif
  let c = 0
  while c < a:amount
    let l:git_parent_command = flog#get_fugitive_git_command() . ' rev-list --parents -n 1 ' . l:current_commit
    let l:parent_commit = system(l:git_parent_command)
    let l:parents = split(l:parent_commit)[1:]
    if len(l:parents) == 0
      return
    endif
    let l:current_commit = flognavigate#stable_select(l:parents, l:current_commit)
    call flog#jump_to_commit(l:current_commit)
    let c += 1
  endwhile
endfunction

function! flognavigate#jump_to_parent() abort
  call flognavigate#jump_up_N_parents(v:count1)
endfunction

function! flognavigate#jump_down_N_children(amount) abort
  let l:current_commit = flognavigate#get_full_commit_hash()
  if type(l:current_commit) != v:t_string
    return
  endif
  let c = 0
  let l:git_log_command = flog#get_fugitive_git_command() . " log --format='%H %P' --all --reflog"
  let l:parent_log = systemlist(l:git_log_command)
  while c < a:amount
    let l:children = flognavigate#find_all_predicate(l:parent_log, {log_line -> match(log_line, ' ' . l:current_commit) != -1})
    call map(l:children, "substitute(v:val, ' [^ ]*$', '', '')")
    if len(l:children) == 0
      return
    endif
    let l:current_commit = flognavigate#stable_select(l:children, l:current_commit)
    call flog#jump_to_commit(l:current_commit)
    let c += 1
  endwhile
endfunction

function! flognavigate#jump_to_child() abort
  call flognavigate#jump_down_N_children(v:count1)
endfunction
