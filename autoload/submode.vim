"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Configuration
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

let s:console_name = 'term://.//console'
let s:layout = {'position': 'bottom', 'height': 0.3}

" filetype: [rpl-shell-command, paste-pre-command, paste-end-command]
let s:repls = {
    \ 'python': ["ipython\n", "%cpaste -q\n", "--\n"],
    \ 'sh': ["shell\n", "", ""],
    \ }
let s:repl = []

" cover default config
if exists("g:console_name")
    let s:console_name = g:console_name
endif


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Terminal Console
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! s:enter_mode(name)
    g:submodes[a:nmae] = 1
endfunction

function! s:leave_mode(name)
    g:submodes[a:nmae] = 0
endfunction

let g:submodes = {}
function! submode#add(config, enter_maps, leave_maps, maps)
    let g:submodes[a:name] = 0

    let l:map = a:mode[0]."noremap "
    for key in a:enter_maps
        execute l:map.key." :call s:enter_mode(".a:name.")<CR>"
    endfor

    for key in a:leave_maps
        execute l:map.key." :call s:leave_mode(".a:name.")<CR>"
    endfor

    for [key, action] in items(a:maps)
        execute l:map."<silent> <expr>".key." g:submodes[".a:name."] ? ".string(action)." : ".string(key).""
    endfor
endfunction
