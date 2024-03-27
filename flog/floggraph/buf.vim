" override flog's update function to parse the parent commits

if !exists("g:floggraph_navigate_update_override_defined")

  let g:floggraph_navigate_update_override_defined = v:true

  try
    call flog#floggraph#buf#Update()
  catch
    " ignore exception, this is just to force autoloading flog's buf.vim
  endtry

  let g:Floggraph_update_function = funcref("flog#floggraph#buf#Update")

  function! flog#floggraph#buf#Update() abort
    call g:Floggraph_update_function()
    " refresh list of commits
    let l:git_log_command = flog#fugitive#GetGitCommand() . " log --format='%H %P' --all --reflog"
    let b:parent_log = systemlist(l:git_log_command)
  endfunction

endif
