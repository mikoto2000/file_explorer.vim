file_explorer.vim
=================

シンプルなファイルエクスプローラーです。

Usage:
------

`file_explorer#OpenFileExplorer()` を、お好みのキーにマッピングしてください。

設定例 :

```vim
noremap <Leader>e <Esc>:call file_explorer#OpenFileExplorer(getcwd())<Enter>
```

`file_explorer#OpenFileExplorer()` を実行すると、ファイルエクスプローラー用のバッファーが開きます。


### ファイルエクスプローラーの操作

表示されたファイルエクスプローラーバッファーでは、下記の操作が行えます。

- `<Return>`, `l` : カーソル下のファイルまたはフォルダを開きます
- `h` : 一つ上のフォルダへ移動します
- `c` : ファイルエクスプローラーで表示しているディレクトリをカレントディレクトリに設定します
- '%' : ファイルエクスプローラーで表示中のディレクトリに新規ファイルを作成し、編集を開始します。


License:
--------

Copyright (C) 2017 mikoto2000

This software is released under the MIT License, see LICENSE

このソフトウェアは MIT ライセンスの下で公開されています。 LICENSE を参照してください。


Author:
-------

mikoto2000 <mikoto2000@gmail.com>
