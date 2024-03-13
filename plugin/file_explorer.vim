" デフォルトキーマッピングの設定
augroup file_explorer
    autocmd!
    autocmd FileType file_explorer nnoremap <buffer> l :call file_explorer#OpenFileOrDirectory()<Enter>
    autocmd FileType file_explorer nnoremap <buffer> <Enter> :call file_explorer#OpenFileOrDirectory()<Enter>
    autocmd FileType file_explorer nnoremap <buffer> h :call file_explorer#MoveUpperDirectory()<Enter>
    autocmd FileType file_explorer nnoremap <buffer> c :call file_explorer#LcdCurrent()<Enter>
    autocmd FileType file_explorer nnoremap <buffer> D :call file_explorer#Delete([file_explorer#GetPath()])<Enter>
    autocmd FileType file_explorer nnoremap <buffer> % :call file_explorer#CreateFile()<Enter>
    autocmd FileType file_explorer nnoremap <buffer> d :call file_explorer#CreateDirectory()<Enter>
    autocmd FileType file_explorer nnoremap <buffer> x :call file_explorer#ExecuteFile()<Enter>
    autocmd FileType file_explorer nnoremap <buffer> <C-L> :call file_explorer#UpdateBuffer('')<Enter>
    autocmd FileType file_explorer let b:file_explorer_source = []
    autocmd FileType file_explorer let b:file_explorer_dest = ''
    autocmd FileType file_explorer nnoremap <buffer> mt :let b:file_explorer_dest = file_explorer#GetPath()<Enter>
            \:echo b:file_explorer_dest<Enter>
    autocmd FileType file_explorer nnoremap <buffer> mf :call uniq(add(b:file_explorer_source, file_explorer#GetPath()))<Enter>
            \:echo b:file_explorer_source<Enter>
    autocmd FileType file_explorer nnoremap <buffer> mu :let b:file_explorer_source = []<Enter>
            \:echo b:file_explorer_source<Enter>
    autocmd FileType file_explorer nnoremap <buffer> mc :call file_explorer#Copy(b:file_explorer_source, b:file_explorer_dest)<Enter>
    autocmd FileType file_explorer nnoremap <buffer> mm :call file_explorer#Move(b:file_explorer_source, b:file_explorer_dest)<Enter>
    autocmd FileType file_explorer nnoremap <buffer> md :call file_explorer#Delete(b:file_explorer_source)<Enter>
augroup END

if has('nvim')
  function! file_explorer#job_start(cmd, cb)
    let Callback = function(a:cb)
    call jobstart(a:cmd, {'on_exit': {j,d,e->Callback(v:null,v:null)}})
  endfunction
else
  function! file_explorer#job_start(cmd, cb)
    call job_start(a:cmd, {'out_io': 'null', 'exit_cb': a:cb})
  endfunction
endif
