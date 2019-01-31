#### <font color="blue">vim的插件及配置</font>

---

# 我的vim配置

```javascript
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
" 4 the syntax checking when saving
Plugin 'scrooloose/syntastic'
" 4 pep8 style checking
Plugin 'nvie/vim-flake8'
" 4 background color
Plugin 'altercation/vim-colors-solarized'
" 4 file tree init input :NERDTree in vim
Plugin 'scrooloose/nerdtree'
" 4 search file
Plugin 'kien/ctrlp.vim'
" 4 vim-go
Plugin 'fatih/vim-go'
" 4 YouCompleteMe 2 complete the code
Plugin 'Valloric/YouCompleteMe'
" 4 vim-python-pep8-indent
Plugin 'hynek/vim-python-pep8-indent'
" 4 minibufexpl
Plugin 'fholgado/minibufexpl.vim'
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
set backspace=indent,eol,start
" Vim5 and later versions support syntax highlighting. Uncommenting the next
" line enables syntax highlighting by default.
syntax enable
syntax on
" colorscheme darkblue
let g:molokai_original = 1
let g:rehash256 = 1
colorscheme molokai
set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab
set autoindent
set cindent
set smartindent
set nu
set ic
set statusline=%f%r%m%*%=[Line:%l/%L,Col:%c]
set laststatus=2
set ruler
set incsearch
"set hlsearch
set cursorline
"set textwidth=79
set fileformat=unix
let &termencoding=&encoding
set fileencodings=utf-8,gb18030,gbk,gb2312,big5
set nobackup
set nowritebackup
" 4 code fold
set foldmethod=indent
set foldlevelstart=99
map<space> za
map<leader>c :set paste<CR>
map<leader>v :set nopaste<CR>
map<leader>d :sp<CR>
map<leader>f :vs<CR>
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
map<leader>g :GoMetaLinter<CR>
map<leader>w :GoDef<CR>

" 4 NERDTree
silent! map<leader>A :NERDTree<CR>
silent! map<leader>a :NERDTreeFind<CR>
silent! map<leader>s :NERDTreeClose<CR>

" 4 ycm
nnoremap <leader>q :YcmCompleter GoToDefinitionElseDeclaration<CR>
set completeopt=menu,menuone
```

# TODO: 注释说明, vundle及部分插件安装
