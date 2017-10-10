function! file_explorer#OpenFileExplorer(path)
    let s:file_browser_pwd = a:path

    " 呼び出し元のウィンドウ ID を記憶
    let s:caller_window_id = win_getid()

    " 新しいバッファを作成
    if bufexists(bufnr('__FILE_BROWSER_FILE_LIST__'))
        bwipeout! __FILE_BROWSER_FILE_LIST__
    endif
    silent hide noswap enew
    silent file `='__FILE_BROWSER_FILE_LIST__'`

    " ファイルリスト取得
    call file_explorer#UpdateBuffer('')

    " リスト用バッファの設定
    setlocal noshowcmd
    setlocal noswapfile
    setlocal buftype=nofile
    setlocal nobuflisted
    setlocal nomodifiable
    setlocal wrap
    setlocal nonumber
    setlocal filetype=file_explorer
endfunction

function! file_explorer#UpdateBuffer(dir)
    setlocal modifiable
    silent normal ggVGd
    if a:dir != ''
        let s:file_browser_pwd = fnamemodify(s:file_browser_pwd . '\\' . a:dir, ':p')
    endif
    let fullpath_files = glob(s:file_browser_pwd . '/.*') . "\n" . glob(s:file_browser_pwd . '/*')
    let files = substitute(fullpath_files, substitute(s:file_browser_pwd . '\', '\\', '\\\\', 'g'), '', 'g')
    silent put! = files
    normal gg
    setlocal nomodifiable
endfunction

function! file_explorer#MoveUpperDirectory()
    call file_explorer#UpdateBuffer('..')
endfunction

function! file_explorer#OpenFileOrDirectory()
    let target = getline('.')
    if isdirectory(s:file_browser_pwd . '\\' . target)
        call file_explorer#OpenDirectory(target)
    else
        call file_explorer#OpenFile(target)
    endif
endfunction

function! file_explorer#OpenDirectory(target)
    call file_explorer#UpdateBuffer(a:target)
endfunction

function! file_explorer#OpenFile(target)
    execute 'e ' . s:file_browser_pwd . '/' . a:target
endfunction

function! file_explorer#GetPath()
    return substitute(s:file_browser_pwd . getline('.'), '\\', '\\\\', 'g')
endfunction

function! file_explorer#LcdCurrent()
    execute ":lcd " . s:file_browser_pwd
endfunction

