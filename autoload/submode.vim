"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Configuration
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:submodes = {}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Terminal Console
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! s:EchoWarning(msg)  " echo highlight msg
    echohl WarningMsg
    echo a:msg
    echohl None
endfunction
command! -nargs=1 EchoWarning call s:EchoWarning(<args>)

function! s:GetConfig(name)
    let config = g:submodes[a:name]

    let mode = get(config, 'mode', 'normal')[0]
    let scope = get(config, 'scope', 'buffer')[0]  " can be 'buffer' or 'global'
    let maps = get(config, 'maps', [])
    let var = scope.':submode'

    return [mode, scope, maps, var, config]
endfunction

function! submode#EnterMode(name, key)
    let [mode, scope, maps, var, config] = s:GetConfig(a:name)
    " check current mode, if enabled, return
    if exists(var)
        execute 'let tmp = '.var
        if tmp ==# a:name
            return ''
        endif
    endif

    call s:EchoWarning('Enter '.a:name)

    " enable mode
    execute 'let '.var.' = "'.a:name.'"'

    " map submode keymaps
    let map = scope ==? 'b' ? '<buffer> ' : ''
    let map = mode.'noremap <silent> '.map
    for [key, action] in items(maps)
        execute map.key.' '.action
    endfor

    call s:MapKeys(a:name, config.leave_keys, 'Leave', scope)

    " callback
    let func = get(config, 'enter_func', '')
    if len(func)
        execute 'call '.func.'()'
    endif

    " if a:key in maps, execute the action
    " TODO
    return ''
endfunction

function! submode#LeaveMode(name, key)
    let [mode, scope, maps, var, config] = s:GetConfig(a:name)
    " check current mode, if disabled, return
    if exists(var)
        execute 'let tmp = '.var
        if tmp ==# ''
            return ''
        endif
    else
        return ''
    endif

    call s:EchoWarning('Leave '.a:name)

    " disable mode
    execute 'let '.var.' = ""'

    " unmap submode keymaps
    let map = scope ==? 'b' ? '<buffer> ' : ''
    let map = mode.'unmap '.map
    for key in keys(maps) + config.leave_keys
        try
            execute map.key
        endtry
    endfor

    " callback
    let func = get(config, 'leave_func', '')
    if len(func)
        execute 'call '.func.'()'
    endif
    return ''
endfunction

function! s:MapKeys(name, keys, type, scope)
    " name: str, new mode name
    " keys: list, e.g., ['<M-CR>', 'CR']
    " type: str, 'Enter' or 'Leave'
    if has_key(g:submodes, a:name)
        let mode = get(g:submodes[a:name], 'mode', 'normal')
        let map = a:scope[0] ==? 'b' ? '<buffer> ' : ''
        let map = mode[0].'noremap <expr> '.map
        for key in a:keys
            let args = '("'.a:name.'", "'.key.'")'
            execute map.key.' submode#'.a:type.'Mode'.args
        endfor
    else
        call s:EchoWarning('No mode named: '.a:name)
    endif
endfunction

function! submode#MapEnterKeys(name, keys)
    call s:MapKeys(a:name, a:keys, 'Enter', 'global')
endfunction

function! submode#MapLeaveKeys(name, keys)
    let g:submodes[a:name]['leave_keys'] = a:keys
endfunction

function! submode#SetMaps(name, maps)
    if has_key(g:submodes, a:name)
        let g:submodes[a:name]['maps'] = a:maps
    else
        call s:EchoWarning('No mode named: '.a:name)
    endif
endfunction

function! submode#AddMode(name, config)  " add a submode
    " name: str, e.g. 'newmode'
    " config: dict, e.g. {
    "   mode: 'normal',
    "   scope: 'buffer',
    "   enter_keys: ['<CR>'],
    "   leave_keys: ['<Esc>'],
    "   enter_func: 'cell#NextCell',
    "   leave_func: 'cell#PrevCell',
    "   maps: {
    "       'j': ':NextCell<CR>',
    "       'k': ':PrevCell<CR>',
    "       ...
    "   },
    " }
    let g:submodes[a:name] = a:config
    call submode#MapEnterKeys(a:name, get(a:config, 'enter_keys', []))
    call submode#MapLeaveKeys(a:name, get(a:config, 'leave_keys', ['q']))
endfunction

