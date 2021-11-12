# Navigation functions & bindings for vim-flog

Vim-flog is a graphical git client for vim. Check it out [here](www.github.com/rbong/vim-flog).

This plugin for vim-flog adds navigation functions and bindings.

# Install

Use your favourite plugin manager.

```
Plug 'rbong/vim-flog'
Plug 'TamaMcGlinn/flog-navigate'
```

I have more plugins that extend vim-flog.
For a full list, see the install instructions for [vim-flogmenu](www.github.com/TamaMcGlinn/vim-flogmenu).

This started out as [a PR to vim-flog](https://github.com/rbong/vim-flog/pull/48).
I will accept PR's to this plugin if they are navigation
commands / keybindings for vim-flog. All keybindings must be overridable. 
Otherwise, make your own plugin in the same style.

# Features

## Cycle checked out commits

This cycles between the commits that HEAD previously pointed to, i.e. HEAD@{N} for N >= 0.

Especially useful when you just amended
several times, to distinguish between commits in the reflog with the same commit message. If the previously
checked out commit is not visible, vim-flog's reflog option is turned on and it is retried.

```
[h - cycle backwards through checkouts
]h - cycle forwards through checkouts
```

## Move up/down/left/right

Fast navigation maps to jump to the parent/child, or next/previous commit.

```
j - down
k - up
h - parent
l - child
```

Vim-flog contains a list of commits, but those of different branches may be
juxtapositioned. Instead of parsing that in your head and using the relative line numbers to jump where
you want to go, use `h` and `l` to stay on the same branch while moving back and forth through the history.

`j/k` goes to the next/previous commit unless a count is specified - so that
you can still use 5j to go down 5 lines, in order to not break that
usage of relative line numbers.

## Reference jumping

Every commit that has some branch pointing to it is a reference, and you can quickly
jump between them with these.

```
]r - next ref
[r - previous ref
```

# Remapping

You can remap all the commands with, for example, this in your vimrc:

```
let g:flognavigate_no_hjkl_mappings=1
let g:flognavigate_no_head_mappings=1
let g:flognavigate_no_ref_mappings=1

augroup my_custom_flognavigate_mappings
  autocmd FileType floggraph nno <buffer> <silent> h :<C-U>call flognavigate#jump_to_parent()<CR>
  autocmd FileType floggraph nno <buffer> <silent> j :<C-U>call flognavigate#down()<CR>
  autocmd FileType floggraph nno <buffer> <silent> k :<C-U>call flognavigate#up()<CR>
  autocmd FileType floggraph nno <buffer> <silent> l :<C-U>call flognavigate#jump_to_child()<CR>

  autocmd FileType floggraph nno <buffer> <silent> ]h :<C-U>call flognavigate#jump_to_next_head()<CR>
  autocmd FileType floggraph nno <buffer> <silent> [h :<C-U>call flognavigate#jump_to_previous_head()<CR>

  autocmd FileType floggraph nno <buffer> <silent> ]r :<C-U>call flog#next_ref()<CR>
  autocmd FileType floggraph nno <buffer> <silent> [r :<C-U>call flog#previous_ref()<CR>
augroup END
```
