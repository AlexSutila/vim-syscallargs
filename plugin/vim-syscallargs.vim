
" PYTHON CODE ------------------------------------------------------------ {{{

python3 << _EOF_

from bs4 import BeautifulSoup
from vim import eval
import requests

def do_syscall_lookup():

    archdict = {
        "x86_64 (64-bit)"   : 1,
        "arm (32-bit/EBAI)" : 2,
        "arm64 (64-bit)"    : 3,
        "x86 (32-bit)"      : 4,
    }

    indicesdict = {
        "syscall name" : 1,
        "%rax"         : 3,
        "arg0 (%rdi)"  : 4,
        "arg1 (%rsi)"  : 5,
        "arg2 (%rdx)"  : 6,
        "arg3 (%r10)"  : 7,
        "arg4 (%r8)"   : 8,
        "arg5 (%r9)"   : 9,
    }

    link = 'https://chromium.googlesource.com/chromiumos/docs/+/master/constants/syscalls.md'
    argument = eval("expand('<cword>')") # Word underneath cursor

    parsed_html = BeautifulSoup(requests.get(link).text)
    tables = parsed_html.body.find_all('table')

    # If hovering over a numerical value, do a lookup around that numerical value for the specific
    #   syscall denoted by it
    if argument.replace('0x', '').isnumeric():

        argument = int(argument, 16) if '0x' in argument else int(argument, 10)

        # TODO: Change architecture here, might add a setting to change this instead of having
        #       to go into the script to change it if ur working with a different architecture
        arch = archdict["x86_64 (64-bit)"]
        row_entries = tables[arch].find_all('tr')[argument + 1].find_all('td')

        print(" SYSCALL FOUND | ", end="")
        for field in indicesdict:
            index, entry_text = indicesdict[field], row_entries[indicesdict[field]].text
            if entry_text != '-': # Not necessary to print unused arguments
                print(f"{field}:{row_entries[index].text}", end=" | ")

    else:
        print("Text under cursor is non-numeric")

_EOF_

" }}}

" For assembly files - replace man page keybind with syscall table viewer
autocmd FileType asm nnoremap <S-k> :python3 do_syscall_lookup() <cr>

