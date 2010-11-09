" File: recipe.vim
" Author: Trent Mick (trentm AT gmail DOT com)
" Version: 1.0
" Last Modified: July 5, 2005
"
" TODO: document this plugin
"
if exists('loaded_recipes') || &compatible
    finish
endif
let loaded_recipes = 1

" Find 'recipe' command-line tool.
if !exists('Recipe_Tool')
    if executable('recipe')
        let Recipe_Tool = 'recipe'
    elseif executable('recipe.bat')
        let Recipe_Tool = 'recipe.bat'
    elseif executable('recipe.exe')
        let Recipe_Tool = 'recipe.exe'
    else
        echomsg 'recipe: the "recipe" tool (http://trentm.com/projects/recipe) '
            \ 'was not found on your PATH: not loading plugin'
        finish
    endif
endif

" Insert the given recipe into the buffer at the current position.
function! s:Recipe_Insert(name)
    let recipe_cmd = g:Recipe_Tool . ' dump ' . a:name
    let cmd_output = system(recipe_cmd)
    if v:shell_error
        echohl WarningMsg
        echo cmd_output
        echohl None
    else
        set paste
        execute "normal o".cmd_output."\<Esc>"
        set nopaste
    endif

endfunction

command! -nargs=1 Recipe call s:Recipe_Insert(<q-args>)

