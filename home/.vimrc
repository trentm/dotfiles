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


" ???
set selectmode=key      " MS Windows style shifted-movement SELECT mode
set keymodel=startsel


" Consider '+0,...' format to be relative to 'textwidth'.
set colorcolumn=80,120

" Showing whitespace. Use 'set nolist' to disable.
" TODO: Consider 'trail:c' in listchars rather than the EOL space highlighting.
" TODO: why do I need this 'highlight' in a BufWinEnter?
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


" Sarathy's 'search' output with -n option
set errorformat-=%f:%l:%m  errorformat+=%f\\,:%l:%m,%f:%l:%m
" Intel's Win64 xcompiler (??? I think)
set errorformat+=%f(%l)\ :\ %m


"---- personal mappings

" Don't use Ex mode, use Q for formatting
map Q gq

" ripgrep in quickfix, search via ':grep ...'
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
map <C-Up> 
map <C-Down> 
map <C-j> <C-E>
map <C-k> <C-Y>

"---- fix for crontab -e problem
" http://drawohara.com/post/6344279/crontab-temp-file-must-be-edited-in-place

if $VIM_CRONTAB == "true"
    set nobackup
    set nowritebackup
endif



" https://github.com/airblade/vim-gitgutter
nmap <silent> ]h :<C-U>execute v:count1 . "GitGutterNextHunk"<CR>
nmap <silent> [h :<C-U>execute v:count1 . "GitGutterPrevHunk"<CR>



"---- some autocommands

if has("autocmd") && !exists("autocommands_loaded")
  " avoid double def'n
  let autocommands_loaded = 1

  "---- all files
  autocmd BufEnter		*		vnoremap ,filter :!linefilter
  autocmd BufLeave		*		vunmap ,filter
  autocmd BufEnter		*		vnoremap ,tab :!linefilter tabify
  autocmd BufLeave		*		vunmap ,tab
  autocmd BufEnter		*		vnoremap ,untab :!linefilter untabify
  autocmd BufLeave		*		vunmap ,untab
  autocmd BufEnter		*		vnoremap ,tounix :!linefilter tounix
  autocmd BufLeave		*		vunmap ,tounix
  autocmd BufEnter		*		vnoremap ,todos :!linefilter todos
  autocmd BufLeave		*		vunmap ,todos

  " When editing a file, always jump to the last cursor position
  autocmd BufReadPost	*		if line("'\"") | exe "'\"" | endif

  "---- text files, and structure text files
  " always limit the width of text to 77 characters
  autocmd BufEnter		*.txt,*.stx	set textwidth=77
  autocmd BufLeave		*.txt,*.stx	set textwidth=0
  autocmd BufEnter		*.txt	vnoremap ,c :!linefilter python comment
  autocmd BufLeave		*.txt	vunmap ,c
  autocmd BufEnter		*.txt	vnoremap ,unc :!linefilter python uncomment
  autocmd BufLeave		*.txt	vunmap   ,unc
  autocmd BufEnter		*.stx	set tabstop=2
  autocmd BufLeave		*.stx	set tabstop=4
  autocmd BufEnter		*.stx	set shiftwidth=2
  autocmd BufLeave		*.stx	set shiftwidth=4
  "XXX should have exit event to undo this

  "---- Makefiles files
  " One of the BufLeave's for Makefiles causes an error in Vim.
  autocmd BufEnter		Makefile*,makefile*	vnoremap ,c :!linefilter python comment
  "autocmd BufLeave		Makefile*,makefile*	vunmap ,c
  autocmd BufEnter		Makefile*,makefile*	vnoremap ,unc :!linefilter python uncomment
  "autocmd BufLeave		Makefile*,makefile*	vunmap ,unc

  "---- JavaScript files
  autocmd BufEnter		*.js	vnoremap ,c :!linefilter c comment
  autocmd BufLeave		*.js	vunmap ,c
  autocmd BufEnter		*.js	vnoremap ,unc :!linefilter c uncomment
  autocmd BufLeave		*.js	vunmap ,unc

  "---- Go files
  autocmd BufEnter		*.go	set noexpandtab
  autocmd BufLeave		*.go	set expandtab

  "---- Todo and Perforce temp form files
  autocmd BufEnter		*.todo,t*.tmp	set noexpandtab textwidth=74
  autocmd BufLeave		*.todo,t*.tmp	set expandtab textwidth=0

  "---- XML files
  "autocmd BufEnter		*.xml,*.html,*.htm,*.xhtml,*.xul,*.rdf,*.recipe,*.khr	set noexpandtab
  "autocmd BufLeave		*.xml,*.html,*.htm,*.xhtml,*.xul,*.rdf,*.recipe,*.khr	set expandtab
  "autocmd BufEnter		*.xml,*.html,*.htm,*.xhtml,*.xul,*.rdf,*.recipe,*.khr	set tabstop=2 shiftwidth=2
  "autocmd BufLeave		*.xml,*.html,*.htm,*.xhtml,*.xul,*.rdf,*.recipe,*.khr	set tabstop=4 shiftwidth=4
  autocmd BufEnter		*.xml,*.html,*.htm,*.xhtml,*.xul,*.rdf,*.recipe,*.khr	vnoremap ,c :!linefilter xml comment
  autocmd BufLeave		*.xml,*.html,*.htm,*.xhtml,*.xul,*.rdf,*.recipe,*.khr	vunmap ,c
  autocmd BufEnter		*.xml,*.html,*.htm,*.xhtml,*.xul,*.rdf,*.recipe,*.khr	vnoremap ,unc :!linefilter xml uncomment
  autocmd BufLeave		*.xml,*.html,*.htm,*.xhtml,*.xul,*.rdf,*.recipe,*.khr	vunmap ,unc

  "---- mutt temporary mail files (i.e. email I write)
  autocmd BufRead		mutt-*	set textwidth=72
  "XXX should have exit event to undo this
  autocmd BufEnter		mutt-*	vnoremap ,c :!linefilter mail comment
  autocmd BufLeave		mutt-*	vunmap   ,c
  autocmd BufEnter		mutt-*	vnoremap ,unc :!linefilter mail uncomment
  autocmd BufLeave		mutt-*	vunmap   ,unc

  "---- rc files typically use Python-style commenting
  autocmd BufEnter		muttrc,*.rc	vnoremap ,c :!linefilter python comment
  autocmd BufLeave		muttrc,*.rc	vunmap   ,c
  autocmd BufEnter		muttrc,*.rc	vnoremap ,unc :!linefilter python uncomment
  autocmd BufLeave		muttrc,*.rc	vunmap   ,unc

  "---- markdown files use email-type "commenting" for blockquotes
  autocmd BufRead       *.markdown  set textwidth=72
  autocmd BufEnter      *.markdown  vnoremap ,c :!linefilter mail comment
  autocmd BufLeave      *.markdown  vunmap   ,c
  autocmd BufEnter      *.markdown  vnoremap ,unc :!linefilter mail uncomment
  autocmd BufLeave      *.markdown  vunmap   ,unc

  "---- programming lang files files
  "need common file repository for these (maybe my own public ftp site):
  "  autocmd BufNewFile	*.py	0r ~/skel/skel.py
  " use linefilter for commenting and uncommenting
  autocmd BufEnter		*.c,*.cpp,*.cxx,*.cc,*.h,*.hpp,*.hxx,*.idl		vnoremap ,c :!linefilter c comment
  autocmd BufLeave		*.c,*.cpp,*.cxx,*.cc,*.h,*.hpp,*.hxx,*.idl		vunmap   ,c
  autocmd BufEnter		*.c,*.cpp,*.cxx,*.cc,*.h,*.hpp,*.hxx,*.idl		vnoremap ,unc :!linefilter c uncomment
  autocmd BufLeave		*.c,*.cpp,*.cxx,*.cc,*.h,*.hpp,*.hxx,*.idl		vunmap   ,unc
  autocmd BufEnter		*.c,*.cpp,*.cxx,*.cc,*.h,*.hpp,*.hxx,*.idl		set formatoptions=crql comments=sr:/*,mb:*,el:*/,b:// textwidth=72
  autocmd BufLeave		*.c,*.cpp,*.cxx,*.cc,*.h,*.hpp,*.hxx,*.idl*.c,*.h,*.cc,*.cxx,*.hxx,*.hpp,*.cpp,*.idl		set formatoptions=tcql nocindent comments& textwidth=0
  "autocmd BufEnter		*.c,*.cpp,*.cxx,*.cc,*.h,*.hpp,*.hxx	set tabstop=8 shiftwidth=4 noexpandtab
  "autocmd BufLeave		*.c,*.cpp,*.cxx,*.cc,*.h,*.hpp,*.hxx	set tabstop=4 shiftwidth=4 expandtab
  autocmd BufEnter		*.sh	vnoremap ,c :!linefilter python comment
  autocmd BufLeave		*.sh	vunmap   ,c
  autocmd BufEnter		*.sh	vnoremap ,unc :!linefilter python uncomment
  autocmd BufLeave		*.sh	vunmap   ,unc
  autocmd BufEnter		*.ptl	setf python
  autocmd BufEnter		*.py*,*.ptl	vnoremap ,c :!linefilter python comment
  autocmd BufLeave		*.py*,*.ptl	vunmap   ,c
  autocmd BufEnter		*.py*,*.ptl	vnoremap ,unc :!linefilter python uncomment
  autocmd BufLeave		*.py*,*.ptl	vunmap   ,unc
  autocmd BufEnter		*.py*,*.ptl	set tabstop=4
  autocmd BufEnter		*.pl,Construct,Conscript	vnoremap ,c   :!linefilter perl comment
  autocmd BufLeave		*.pl,Construct,Conscript	vunmap   ,c
  autocmd BufEnter		*.pl,Construct,Conscript	vnoremap ,unc :!linefilter perl uncomment
  autocmd BufLeave		*.pl,Construct,Conscript	vunmap   ,unc
  autocmd BufEnter		*.sh,*.py*,*.ptl,*.pl,Construct,Conscript	set formatoptions=crql comments=:# textwidth=72
  autocmd BufLeave		*.sh,*.py*,*.ptl,*.pl,Construct,Conscript	set formatoptions=tcql comments& textwidth=0
  " Ick. Use tabs and tabstop=8 for .sh and .pl files because this
  " is typical.
  "autocmd BufEnter		*.sh,*.pl	set tabstop=8 shiftwidth=8 noexpandtab
  "autocmd BufLeave		*.sh,*.pl	set tabstop=4 shiftwidth=4 expandtab

  autocmd BufEnter		Rakefile,Capfile,*.rb	set tabstop=2 shiftwidth=2 expandtab
endif


"---- Windows configuration

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


"---- GUI configuration

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



" ---------------------------------------------------------------------------
" Colors / Theme
" ---------------------------------------------------------------------------

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

