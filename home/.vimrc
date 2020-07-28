" Trent's VIM configuration file.

set nocompatible

" ???
" Vim bundles in ~/.vim/bundles
" https://github.com/tpope/vim-pathogen
execute pathogen#infect()

" TODO: tpope/vim-commentary

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

set tabstop=4           " default tabstop of 4 spaces
set shiftwidth=4        " default shiftwidth of 4 spaces
set expandtab           " use spaces instead of tabs
set smarttab

" TODO: regrok this
set selectmode=key      " MS Windows style shifted-movement SELECT mode
set keymodel=startsel


" Consider '+0,...' format to be relative to 'textwidth'.
set colorcolumn=80,120

" Showing whitespace. Use 'set nolist' to disable.
" TODO: Consider 'trail:c' in listchars rather than the EOL space highlighting.
" TODO: why do I need this 'highlight' in a BufWinEnter?
" TODO: want the autocmd guard below?
autocmd BufWinEnter * highlight SpecialKey ctermfg=grey
set listchars=tab:│\ ,nbsp:⎵
set list

" Highlight spaces at end of lines.
" see: http://vim.wikia.com/wiki/Highlight_unwanted_spaces
highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/
autocmd BufWinEnter * match ExtraWhitespace /\s\+$/
autocmd InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
autocmd InsertLeave * match ExtraWhitespace /\s\+$/
autocmd BufWinLeave * call clearmatches()


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
