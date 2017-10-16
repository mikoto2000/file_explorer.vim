" デフォルトキーマッピングの設定
augroup file_explorer
    autocmd!
    autocmd FileType file_explorer nnoremap <buffer> l :call file_explorer#OpenFileOrDirectory()<Enter>
    autocmd FileType file_explorer nnoremap <buffer> <Enter> :call file_explorer#OpenFileOrDirectory()<Enter>
    autocmd FileType file_explorer nnoremap <buffer> h :call file_explorer#MoveUpperDirectory()<Enter>
    autocmd FileType file_explorer nnoremap <buffer> c :call file_explorer#LcdCurrent()<Enter>
    autocmd FileType file_explorer nnoremap <buffer> % :call file_explorer#CreateFile()<Enter>
    autocmd FileType file_explorer nnoremap <buffer> x :call file_explorer#ExecuteFile()<Enter>
augroup END

