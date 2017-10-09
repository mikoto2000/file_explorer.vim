" デフォルトキーマッピングの設定
augroup file_explorer
    autocmd!
    autocmd FileType file_explorer nnoremap <buffer> l :call file_explorer#OpenFileOrDirectory()<Enter>
    autocmd FileType file_explorer nnoremap <buffer> <Enter> :call file_explorer#OpenFileOrDirectory()<Enter>
    autocmd FileType file_explorer nnoremap <buffer> h :call file_explorer#MoveUpperDirectory()<Enter>
    autocmd FileType file_explorer nnoremap <buffer> c :call file_explorer#LcdCurrent()<Enter>
augroup END
