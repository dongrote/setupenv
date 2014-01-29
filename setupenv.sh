#!/bin/bash
cat << EOF > $HOME/.vimrc
execute pathogen#infect()
au FileType python set ofu=jedi#complete
let g:SuperTabDefaultCompletionType = "context"


" vimrc file for following the coding standards specified in PEP 7 & 8.
"
" To use this file, source it in your own personal .vimrc file (``source
" <filename>``) or, if you don't have a .vimrc file, you can just symlink to it
" (``ln -s <this file> ~/.vimrc``).  All options are protected by autocmds
" (read below for an explanation of the command) so blind sourcing of this file
" is safe and will not affect your settings for non-Python or non-C files.
"
"
" All setting are protected by 'au' ('autocmd') statements.  Only files ending
" in .py or .pyw will trigger the Python settings while files ending in *.c or
" *.h will trigger the C settings.  This makes the file "safe" in terms of only
" adjusting settings for Python and C files.
"
" Only basic settings needed to enforce the style guidelines are set.
" Some suggested options are listed but commented out at the end of this file.

" Number of spaces that a pre-existing tab is equal to.
" For the amount of space used for a new tab use shiftwidth.
au BufRead,BufNewFile *py,*pyw,*.c,*.h set tabstop=4

" What to use for an indent.
" This will affect Ctrl-T and 'autoindent'.
" Python: 4 spaces
" C: tabs (pre-existing files) or 4 spaces (new files)
au BufRead,BufNewFile *.py,*pyw set shiftwidth=4
au BufRead,BufNewFile *.py,*.pyw set expandtab
fu Select_c_style()
    if search('^\t', 'n', 150)
        set shiftwidth=4
        set noexpandtab
    el 
        set shiftwidth=4
        set expandtab
    en
endf
au BufRead,BufNewFile *.c,*.h call Select_c_style()
au BufRead,BufNewFile Makefile* set noexpandtab

" Use the below highlight group when displaying bad whitespace is desired.
highlight BadWhitespace ctermbg=red guibg=red

" Display tabs at the beginning of a line in Python mode as bad.
au BufRead,BufNewFile *.py,*.pyw match BadWhitespace /^\t\+/
" Make trailing whitespace be flagged as bad.
au BufRead,BufNewFile *.py,*.pyw,*.c,*.h match BadWhitespace /\s\+$/

" Wrap text after a certain number of characters
" Python: 79 
" C: 79
" au BufRead,BufNewFile *.py,*.pyw,*.c,*.h set textwidth=79

" Turn off settings in 'formatoptions' relating to comment formatting.
" - c : do not automatically insert the comment leader when wrapping based on
"    'textwidth'
" - o : do not insert the comment leader when using 'o' or 'O' from command mode
" - r : do not insert the comment leader when hitting <Enter> in insert mode
" Python: not needed
" C: prevents insertion of '*' at the beginning of every line in a comment
au BufRead,BufNewFile *.c,*.h set formatoptions-=c formatoptions-=o formatoptions-=r

" Use UNIX (\n) line endings.
" Only used for new files so as to not force existing files to change their
" line endings.
" Python: yes
" C: yes
au BufNewFile *.py,*.pyw,*.c,*.h set fileformat=unix


" ----------------------------------------------------------------------------
" The following section contains suggested settings.  While in no way required
" to meet coding standards, they are helpful.

" Set the default file encoding to UTF-8: ``set encoding=utf-8``

" Puts a marker at the beginning of the file to differentiate between UTF and
" UCS encoding (WARNING: can trick shells into thinking a text file is actually
" a binary file when executing the text file): ``set bomb``

" For full syntax highlighting:
let python_highlight_all=1
syntax on

" Automatically indent based on file type: ``filetype indent on``
" Keep indentation level from previous line: ``set autoindent``
filetype indent on
set autoindent
" Folding based on indentation: ``set foldmethod=indent``

" Turn on "dark background" mode
set bg=dark

set tabstop=4
set softtabstop=4
set cursorline
set number

" Formats the statusline
set statusline=%f                           " file name
"set statusline+=[%{strlen(&fenc)?&fenc:'none'}, "file encoding
"set statusline+=%{&ff}] "file format
"set statusline+=%y      "filetype
"set statusline+=%h      "help file flag
set statusline+=%m      "modified flag
set statusline+=%r      "read only flag

" Puts in the current git status
set statusline+=\ %{fugitive#statusline()}

set statusline+=\ %=                        " align left
"set statusline+=Line:%l/%L[%p%%]            " line X of Y [percent of file]
set statusline+=Line:%l/%L                  " line X of Y
set statusline+=\ Col:%c                    " current column
set statusline+=\ Buf:%n                    " Buffer number
"set statusline+=\ [%b][0x%B]\               " ASCII and byte code under cursor

" create F5, F6 mappings to replace current position with ✓ or ✗ respectively
map <F5> r<C-v>U2713<ESC>
map <F6> r<C-v>U2717<ESC>
EOF

# bash aliases
cat << EOF > $HOME/.bash_aliases
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias sl='ls'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'
alias .......='cd ../../../../../..'
alias ........='cd ../../../../../../..'
alias .........='cd ../../../../../../../..'
alias objdbin_x86='objdump -D -b binary -mi386'
alias idlecp='ionice -c 3 cp'
todo(){ cd ~/.todo||return 1&& l=$(ls -1t|head -n1)&&t=$(date +%Y%m%d);[[ "$1" == "last" ]]&&cp $l $t; ${EDITOR:-vim} $t;cd -;} # Todo list.
EOF


# setup python tab-completion
cat << EOF > $HOME/.pythonrc
#!/usr/bin/python
import os
import sys

try:
    import readline
except ImportError:
    print "Module readline not available."
else:
    import rlcompleter
	readline.parse_and_bind("tab: complete")
EOF

cat << EOF >> $HOME/.bashrc
export PYTHONSTARTUP=~/.pythonrc
export PATH=$PATH:$HOME/bin
EOF

# git configuration; I hate forgetting these things
git config --global user.name 'Don Grote'
git config --global user.email 'don.grote@gmail.com'
git config --global color.diff auto
git config --global color.status auto
git config --global color.branch auto

# install virtualenv for python dev
sudo pip install virtualenv || sudo easy_install virtualenv
sudo pip install mitmproxy

# create home directory for todo list command in $HOME/.bash_aliases
mkdir $HOME/.todo

mkdir $HOME/bin
cat << EOF > $HOME/bin/dircmp
#!/bin/bash
comm -3 <(ls -1 $1) <(ls -1 $2)
EOF
chmod +x $HOME/bin/dircmp

cat <<EOF > $HOME/bin/hex2dec
#!/bin/bash
cmd="ibase=16"
for num in $@
do
	cmd="$cmd; $num"
done
echo $cmd | bc
EOF

cat <<EOF > $HOME/bin/dec2hex
#!/bin/bash
cmd="obase=16"
for num in $@
do
	cmd="$cmd; $num"
done
echo $cmd | bc
EOF

cat <<EOF > $HOME/bin/dec2bin
#!/bin/bash
cmd="obase=2"
for num in $@
do
	cmd="$cmd; $num"
done
echo $cmd | bc
EOF

cat <<EOF > $HOME/bin/bin2dec
#!/bin/bash
cmd="ibase=2"
for num in $@
do
	cmd="$cmd; $num"
done
echo $cmd | bc
EOF

# install fugitive.vim
mkdir -p ~/.vim/autoload ~/.vim/bundle; 
curl -Sso ~/.vim/autoload/pathogen.vim https://raw.github.com/tpope/vim-pathogen/master/autoload/pathogen.vim
git clone git://github.com/tpope/vim-fugitive.git ~/.vim/bundle/vim-fugitive
echo "execute pathogen#infect()" >> ~/.vimrc
