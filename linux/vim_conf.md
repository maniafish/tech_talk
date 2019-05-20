#### <font color="blue">vim的插件及配置</font>

---

# 我的vim配置

```js
" Uncomment the next line to make Vim more Vi-compatible
" NOTE: debian.vim sets 'nocompatible'.  Setting 'compatible' changes numerous
" options, so any other options should be set AFTER setting 'compatible'.
set nocompatible
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" 4 vundle
" let Vundle manage Vundle
Plugin 'gmarik/Vundle.vim'
" 4 background color vim主题设置
Plugin 'altercation/vim-colors-solarized'
" 4 file tree init input :NERDTree in vim 目录管理
Plugin 'scrooloose/nerdtree'
" 4 search file 文件检索(ctrl-p)
Plugin 'kien/ctrlp.vim'
" 4 minibufexpl 文件缓冲区(顶端显示最近打开的文件)
Plugin 'fholgado/minibufexpl.vim'
" 4 the syntax checking when saving 语法检查
Plugin 'scrooloose/syntastic'
" 4 pep8 style checking python格式检查
Plugin 'nvie/vim-flake8'
" 4 vim-python-pep8-indent python代码按照pep8规范自动缩进
Plugin 'hynek/vim-python-pep8-indent'
" 4 vim-go golang代码相关插件，要求已经安装了golang环境
Plugin 'fatih/vim-go'
" 4 YouCompleteMe 2 complete the code 代码补全器
Plugin 'Valloric/YouCompleteMe'
" 4 markdown .md文件编辑
Plugin 'godlygeek/tabular'
Plugin 'plasticboy/vim-markdown'
" 4 mark 颜色标记插件
Plugin 'inkarkat/vim-ingo-library'
Plugin 'inkarkat/vim-mark'
call vundle#end()
" required
" To ignore plugin indent changes, instead use:
"filetype plugin on
filetype on
filetype plugin on
filetype indent on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line

" 设置了自动缩进的情况下，通过以下配置使退格键生效
set backspace=indent,eol,start

" Vim5 and later versions support syntax highlighting. Uncommenting the next
" line enables syntax highlighting by default. 语法高亮
syntax enable
syntax on

" colorscheme darkblue
" 设置vim主题为molokai，显示原色；将主题molokai.vim放到~/.vim/color目录下方可使用
" https://github.com/tomasr/molokai
let g:molokai_original = 1
let g:rehash256 = 1
colorscheme molokai

" 设置tab为4个空格
set tabstop=4
set softtabstop=4
set expandtab
" 设置缩进为4个空格
set shiftwidth=4
" 设置自动缩进
set autoindent
set cindent
set smartindent

" 设置行号
set nu
" 高亮游标所在行
set cursorline
" 设置倒数第二行位置显示当前游标行列信息
set statusline=%f%r%m%*%=[Line:%l/%L,Col:%c]
set laststatus=2
set ruler

" 搜索不区分大小写
set ic
" 搜索匹配时立刻反应
set incsearch
" 搜索高亮，这里不开启
" set hlsearch

" 设置文件为unix系统格式
set fileformat=unix
" 设置文件解码方式，以下任意一种方式匹配则使用该方式解码
set fileencodings=utf-8,gb18030,gbk,gb2312,big5
" 设置终端显示编码和实际编码一致
let &termencoding=&encoding

" 不生成备份文件.un~
set nobackup
set nowritebackup

" 4 code fold 代码折叠
set foldmethod=indent
" 设高默认代码折叠级别，即默认不折叠
set foldlevelstart=99
" normal模式下非递归映射: 空格键->代码折叠
nnoremap<space> za

" 粘贴模式开关
nnoremap<leader>c :set paste<CR>
nnoremap<leader>v :set nopaste<CR>

" 水平分屏
nnoremap<leader>d :sp<CR>
" 垂直分屏
nnoremap<leader>f :vs<CR>

" 4 yaml 设置yaml文件的缩进为两个空格
autocmd FileType yaml,html setlocal ts=2 sts=2 sw=2 expandtab

" 4 vim-flake8
let g:flake8_cmd="/usr/local/bin/flake8"
" 4 syntastic
let g:syntastic_python_checkers = ['flake8']
" 4 vim-go
let g:go_highlight_functions = 1
let g:go_highlight_methods = 1
let g:go_highlight_fields = 1
let g:go_highlight_types = 1
let g:go_highlight_operators = 1
let g:go_highlight_build_constraints = 1
let g:go_fmt_command = "goimports"
nnoremap<leader>g :GoMetaLinter<CR>
nnoremap<leader>w :GoDef<CR>

" 4 NERDTree
silent! nnoremap<leader>A :NERDTree<CR>
silent! nnoremap<leader>a :NERDTreeFind<CR>
silent! nnoremap<leader>s :NERDTreeClose<CR>

" 4 ycm
nnoremap <leader>q :YcmCompleter GoToDefinitionElseDeclaration<CR>
set completeopt=menu,menuone

" 4 mark
let g:mwDefaultHighlightingPalette = 'maximum'
let g:mwDefaultHighlightingNum = 9
nnoremap<leader>N :MarkClear<CR>
nmap <Plug>IgnoreMarkSearchNext <Plug>MarkSearchNext
nmap <Plug>IgnoreMarkSearchPrev <Plug>MarkSearchPrev
```

# 使用Vundle进行插件管理

* 安装流程见：[官方github](https://github.com/VundleVim/Vundle.vim)中的"Quick Start"
* 通过Vundle安装的插件在"~/.vim/bundle"目录下

# YouCompleteMe代码补全插件安装

1. 安装7.5+版本的vim，添加python3支持(以下`with-python-xxx`和`with-python3-xxx`配置对应的是机器上实际的python目录，没有安装python的需要安装后再指定)

	```js
	$ git clone https://github.com/vim/vim.git
	$ cd vim
	$ ./configure --with-features=huge \
	--enable-multibyte \
	--enable-rubyinterp=yes \
	--enable-pythoninterp=yes \
	--with-python-config-dir=/usr/lib/python2.7/config \
	--enable-python3interp=yes \
	--with-python3-config-dir=/usr/lib/python3.4/config \
	--enable-perlinterp=yes \
	--enable-luainterp=yes \
	--enable-gui=gtk2 \
	--enable-cscope \
	--prefix=$HOME/runtime
	$ make && make install
	```

2. 安装YouCompleteMe：[官网github](https://github.com/Valloric/YouCompleteMe)，通过vundle安装即可
