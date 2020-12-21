" Trent's VIM configuration file.

set nocompatible

syntax on
filetype on
filetype plugin indent on

set hlsearch
set hidden              " allow modified and not forefront buffers
set backspace=2         " allow backspacing over all in insert mode
set ai                  " always set autoindenting on
set backup              " keep a backup file
set history=50          " keep 50 lines of command line history
set ruler               " show the cursor position all the time
set laststatus=2        " always display a status line
set showmatch           " show matching parentheses
set noic                " case-sensitive searching
set scrolloff=10        " keep a number of lines above/below cursor
set clipboard=unnamed   " yank to the system clipboard

set tabstop=4           " default tabstop of 4 spaces
set shiftwidth=4        " default shiftwidth of 4 spaces
set expandtab           " use spaces instead of tabs
set smarttab

" Set modelines back to default 5 after being set to 0 by the "commentary"
" plugin. See https://github.com/tpope/vim-commentary/issues/26
set modelines=5


" TODO: regrok this
set selectmode=key      " MS Windows style shifted-movement SELECT mode
set keymodel=startsel


" Consider '+0,...' format to be relative to 'textwidth'.
set colorcolumn=80,120

" Showing whitespace. 'set list' to enable, 'set nolist' to disable.
" Disabled by default because cut 'n paste from terminal includes these chars.
"autocmd BufWinEnter * highlight SpecialKey ctermfg=grey
set listchars=tab:│\ ,nbsp:⎵

" Highlight subtle whitespace:
" 1. Whitespace at end of lines, and spaces before tabs => red
" 2. TODO: Make tabs LightGrey, but only in langs I don't typically use
"    tabs. E.g. not in Go. Perhaps highlight leading spaces in Go.
"       highlight TabWhitespace term=reverse ctermbg=7 guibg=LightGrey
"       autocmd BufWinEnter * 2match TabWhitespace /\t/
highlight BadWhitespace ctermbg=red guibg=red
autocmd BufWinEnter * match BadWhitespace /\s\+$\| \+\ze\t/
autocmd InsertEnter * match BadWhitespace /\s\+\%#\@<!$/
autocmd InsertLeave * match BadWhitespace /\s\+$\| \+\ze\t/
if version >= 702
  autocmd BufWinLeave * call clearmatches()
endif


" TODO: review/grok this
" Sarathy's 'search' output with -n option
set errorformat-=%f:%l:%m  errorformat+=%f\\,:%l:%m,%f:%l:%m
" Intel's Win64 xcompiler (??? I think)
set errorformat+=%f(%l)\ :\ %m

" Don't use Ex mode, use Q for formatting
map Q gq

" ripgrep in quickfix, search via ':grep ...'
" TODO: grok using :grep again
set grepprg=rg\ --vimgrep
set grepformat^=%f:%l:%c:%m

" Mapping for navigating through 'quickfix' lists (i.e. make and grep results)
" Examples:
"   vi -q <(./node_modules/.bin/eslint --format unix .)
"   vi -q <(./node_modules/.bin/eslint --format unix --no-eslintrc --rule eqeqeq:error .)
"   vi -q <(rg --vimgrep foo)
map <F5> :cp<CR>
map <F6> :cc<CR>
map <F7> :cl<CR>
map <F8> :cn<CR>
map m :cn<CR>

" navigating through open files
map <F10> :bprevious
map <F11> :buffers
map <F12> :bnext
" scroll with Ctrl-arrow-keys
" TODO: review/grok this
map <C-Up> 
map <C-Down> 
map <C-j> <C-E>
map <C-k> <C-Y>

" Fix for 'crontab -e' problem.
" http://drawohara.com/post/6344279/crontab-temp-file-must-be-edited-in-place
if $VIM_CRONTAB == "true"
    set nobackup
    set nowritebackup
endif


" https://github.com/airblade/vim-gitgutter
" TODO: review/grok this
nmap <silent> ]h :<C-U>execute v:count1 . "GitGutterNextHunk"<CR>
nmap <silent> [h :<C-U>execute v:count1 . "GitGutterPrevHunk"<CR>

" https://github.com/tpope/vim-commentary
" - `gc<motion>` to toggle commenting
" - `gcc` to for current line
" - `g/foo/Commentary` for lines matching foo, for example
" TODO: ,c shortcut for gc for commenting? Or get used to gc?


" autocommands
"
" Like this:
"   autocmd BufEnter <glob> vnoremap <keybinding> <cmd>
"   autocmd BufLeave <glob> vunmap   <keybinding>
" E.g.:
"   autocmd BufEnter *      vnoremap ,filter :!linefilter
"   autocmd BufLeave *      vunmap ,filter
"
if has("autocmd") && !exists("autocommands_loaded")
  " Avoid double definition
  let autocommands_loaded = 1

  " When editing a file, always jump to the last cursor position
  autocmd BufReadPost   *       if line("'\"") | exe "'\"" | endif

  " Text files.
  " Always limit the width of text to 77 characters for one-level of
  " blockquote in email.
  autocmd BufEnter      *.txt   set textwidth=77
  autocmd BufLeave      *.txt   set textwidth=0

  " Go files use tabs. Boo.
  autocmd BufEnter      *.go    set noexpandtab
  autocmd BufLeave      *.go    set expandtab

  " Programming lang files files
  "need common file repository for these
  "  autocmd BufNewFile *.py    0r ~/skel/skel.py
  autocmd BufEnter      *.c,*.cpp,*.cxx,*.cc,*.h,*.hpp,*.hxx,*.idl      set formatoptions=crql comments=sr:/*,mb:*,el:*/,b:// textwidth=72
  autocmd BufLeave      *.c,*.cpp,*.cxx,*.cc,*.h,*.hpp,*.hxx,*.idl*.c,*.h,*.cc,*.cxx,*.hxx,*.hpp,*.cpp,*.idl        set formatoptions=tcql nocindent comments& textwidth=0
  autocmd BufEnter      *.sh,*.py*,*.pl set formatoptions=crql comments=:# textwidth=72
  autocmd BufLeave      *.sh,*.py*,*.pl set formatoptions=tcql comments& textwidth=0
endif


" Windows configuration
if has("win32")
  " set the make program
  "set makeprg=nmake

  set mousehide
  set guifont=Courier_New:h10,Lucida_Console:h10
  set backupdir=~/.vimtmp,~/tmp
  set dir=~/.vimtmp,~/tmp
else
  set backupdir=~/.vimtmp,~/tmp,/tmp
  set dir=~/.vimtmp,~/tmp,/tmp
endif


" GUI configuration (ancient gvim)
if has("gui")
  " set the gui options to:
  "   g: grey inactive menu items
  "   m: display menu bar
  "   r: display scrollbar on right side of window
  "   b: display scrollbar at bottom of window
  "   t: enable tearoff menus on Win32
  "   T: enable toolbar on Win32
  set go=gmrbT
"  set lines=46  " number of display lines
"  set columns=90
endif


"---- http://vim.sourceforge.net/tips/tip.php?tip_id=102
" Note: I reversed the mappings because IMO <tab> should search _backwards_ by
" default.
" TODO: review/grok this
function! InsertTabWrapper(direction)
    let col = col('.') - 1
    if !col || getline('.')[col - 1] !~ '\k'
        return "\<tab>"
    elseif "backward" == a:direction
        return "\<c-p>"
    else
        return "\<c-n>"
    endif
endfunction

inoremap <tab> <c-r>=InsertTabWrapper ("backward")<cr>
inoremap <s-tab> <c-r>=InsertTabWrapper ("forward")<cr>


" Colors / Theme
" TODO: review/grok this
if &t_Co > 2 || has("gui_running")
  if has("terminfo")
    set t_Co=16
    set t_AB=[%?%p1%{8}%<%t%p1%{40}%+%e%p1%{92}%+%;%dm
    set t_AF=[%?%p1%{8}%<%t%p1%{30}%+%e%p1%{82}%+%;%dm
  else
    set t_Co=16
    set t_Sf=[3%dm
    set t_Sb=[4%dm
  endif
endif
