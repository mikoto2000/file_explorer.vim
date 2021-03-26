let s:cursor_position = {}

function! file_explorer#OpenFileExplorer(path)
    let s:file_browser_pwd = file_explorer#NormalizePath(a:path)

    " 呼び出し元のウィンドウ ID を記憶
    let s:caller_window_id = win_getid()

    " 新しいバッファを作成
    let browser_bufnr = bufnr('__FILE_BROWSER_FILE_LIST__')
    let current_tabpage_buf_list = tabpagebuflist()
    " カレントタブページに映っているか確認
    if match(current_tabpage_buf_list, '^' . browser_bufnr . '$') >= 0
        " 映っていればそのバッファに移動
        " タブに映っているのだから必ずヒットするはず
        let winid = win_findbuf(browser_bufnr)[0]
        call win_gotoid(winid)
    else
        " 映っていなかったら wipeout して作り直し
        " __FILE_BROWSER_FILE_LIST__ しか表示していないタブがあった場合
        " タブ自体が削除されてしまうけれど仕方がないとしよう。
        if bufexists(browser_bufnr)
            bwipeout! __FILE_BROWSER_FILE_LIST__
        endif
        silent hide noswap enew
        silent file `='__FILE_BROWSER_FILE_LIST__'`
    endif

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
    ownsyntax netrw
endfunction

function! file_explorer#UpdateBuffer(dir)
    setlocal modifiable
    silent normal ggVG"_d
    if a:dir != ''
        let s:file_browser_pwd = file_explorer#NormalizePath(s:file_browser_pwd . a:dir)
    endif
    let fullpath_files = join(map(
            \ glob(s:file_browser_pwd . '/.*', 1, 1) + glob(s:file_browser_pwd . '/*', 1, 1),
            \ {i,p -> isdirectory(p) ? p . '/' : p }), "\n")
    let files = substitute(fullpath_files, '\', '/', 'g')
    let files = substitute(files, s:file_browser_pwd . '/', '', 'g')
    silent put! = files
    normal gg
    setlocal nomodifiable

    if has_key(s:cursor_position, s:file_browser_pwd)
        " 以前いたカーソル位置へ移動
        let position = search(s:cursor_position[s:file_browser_pwd])
        call cursor(position, 0)
    endif
endfunction

function! file_explorer#MoveUpperDirectory()
    " カーソル位置を更新
    let s:cursor_position[s:file_browser_pwd] = getline('.')

    call file_explorer#UpdateBuffer('..')
endfunction

function! file_explorer#OpenFileOrDirectory()
    " カーソル位置を更新
    let target = getline('.')
    let s:cursor_position[s:file_browser_pwd] = target
    if isdirectory(s:file_browser_pwd . target)
        call file_explorer#OpenDirectory(target)
    else
        call file_explorer#OpenFile(target)
    endif
endfunction

function! file_explorer#OpenDirectory(target)
    call file_explorer#UpdateBuffer(a:target[0:-2])
endfunction

function! file_explorer#OpenFile(target)
    execute 'e ' . substitute(s:file_browser_pwd . a:target, '%', '\\%', 'g')
endfunction

function! file_explorer#GetPath()
    return file_explorer#NormalizePath(s:file_browser_pwd . getline('.'))
endfunction

function! file_explorer#LcdCurrent()
    execute ":lcd " . s:file_browser_pwd
endfunction

function! file_explorer#CreateFile()
    let file_name = input("File Name: ")
    execute ":e " . substitute(s:file_browser_pwd . file_name, '%', '\\%', 'g')
endfunction

function! file_explorer#CreateDirectory()
    if exists("*mkdir")
        let directory_name = input("Directory Name: ")
        call mkdir(s:file_browser_pwd .  directory_name)
        call file_explorer#UpdateBuffer('')
    else
        echo "This system is not supported mkdir."
    endif
endfunction

function! file_explorer#ToWindowsPath(path)
    return substitute(a:path, '/', '\', 'g')
endfunction

function! file_explorer#Copy(sources, dest)
    if a:dest == ''
        echo 'file_explorer: dest is empty.'
        return
    endif

    for source in a:sources
        call s:copy(source, a:dest)
    endfor
endfunction

function! s:copy(source, dest)
    let source = a:source
    let dest = a:dest
    if has('win32') || has('win64')
        let source = file_explorer#ToWindowsPath(source)
        let dest = file_explorer#ToWindowsPath(dest)
        if isdirectory(source)
            let execute_command = 'xcopy /s /e /q /i /y'
            let source = source[0:-2]
            let dest = dest . fnamemodify(source, ':t')
        else
            let execute_command = 'xcopy /y /q'
        endif
    else
        let execute_command = 'cp -rf'
    endif

    call job_start("cmd /c " . execute_command . ' "' . source . '" "' . dest . '" > nul', {'out_io': 'null', 'exit_cb': 'file_explorer#copy_cb'})
endfunction

function! file_explorer#copy_cb(job, status)
    call file_explorer#UpdateBuffer('')
endfunction

function! file_explorer#Move(sources, dest)
    if a:dest == ''
        echo 'file_explorer: dest is empty.'
        return
    endif

    let user_input = input("Move these files : \n- " . join(a:sources, "\n- ") . "\nTo : \n- " . a:dest . "\nReally move? y/n > ")

    for source in a:sources
        call s:move(source, a:dest)
    endfor
endfunction

function! s:move(source, dest)
    let source = a:source
    let dest = a:dest
    if has('win32') || has('win64')
        let source = file_explorer#ToWindowsPath(source)
        let dest = file_explorer#ToWindowsPath(dest)
        let execute_command = 'move /y'
        if isdirectory(source)
            let source = source[0:-2]
            let dest = dest . fnamemodify(source, ':t')
        endif
    else
        let execute_command = 'mv -f'
    endif

    call job_start("cmd /c " . execute_command . ' "' . source . '" "' . dest . '" > nul', {'out_io': 'null', 'exit_cb': 'file_explorer#move_cb'})
endfunction

function! file_explorer#move_cb(job, status)
    call file_explorer#UpdateBuffer('')
endfunction

function! file_explorer#Delete(sources)
    let user_input = input("Delete these files : \n- " . join(a:sources, "\n- ") . "\nReallydelete? y/n > ")

    if user_input == "y"
        for source in a:sources
            call s:delete(source)
        endfor
    endif
endfunction

function! s:delete(target)
    let target = a:target
    if has('win32') || has('win64')
        let target = file_explorer#ToWindowsPath(target)
        if isdirectory(target)
            let execute_command = 'rmdir /s /q'
        else
            let execute_command = 'del /q'
        endif
    else
        let execute_command = 'rm -rf'
    endif

    call job_start("cmd /c " . execute_command . ' "' . target . '" > nul', {'out_io': 'null', 'exit_cb': 'file_explorer#delete_cb'})
endfunction

function! file_explorer#delete_cb(job, status)
    call file_explorer#UpdateBuffer('')
endfunction

function! file_explorer#ExecuteFile()
    let target = file_explorer#GetPath()
    if has('win32') || has('win64')
        let execute_command = 'start'
        let target = file_explorer#ToWindowsPath(target)
    elseif has('mac')
        let execute_command = 'open'
    else
        let execute_command = 'xdg-open'
    endif

    silent execute '!' . execute_command . ' ' . target
endfunction

function! file_explorer#NormalizePath(path)
    return substitute(fnamemodify(a:path, ':p'), '\', '/', 'g')
endfunction

