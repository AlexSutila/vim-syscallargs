
function! DoSyscallLookup()

python3 << _EOF_

from bs4 import BeautifulSoup
import requests, vim

archdict = {
    "x86_64 (64-bit)"   : 1,
    "arm (32-bit/EBAI)" : 2,
    "arm64 (64-bit)"    : 3,
    "x86 (32-bit)"      : 4,
}

indicesdict = {
    "NR"           : 0,
    "syscall name" : 1,
    "references"   : 2,
    "%rax"         : 3,
    "arg0 (%rdi)"  : 4,
    "arg1 (%rsi)"  : 5,
    "arg2 (%rdx)"  : 6,
    "arg3 (%r10)"  : 7,
    "arg4 (%r8)"   : 8,
    "arg5 (%r9)"   : 9,
}

# TODO: Change architecture here, might add a setting to change this instead of having
#       to go into the script to change it if ur working with a different architecture
arch = archdict["x86_64 (64-bit)"]

link = 'https://chromium.googlesource.com/chromiumos/docs/+/master/constants/syscalls.md'
argument = vim.eval("expand('<cword>')") # Word underneath cursor

max_lengths, bar_length = [len(i) for i in indicesdict], -1
parsed_html = BeautifulSoup(requests.get(link).text)
tables = parsed_html.body.find_all('table')


# If hovering over a numerical value, do a lookup around that numerical value for the specific
#   syscall denoted by it
try:
    argument = int(argument, 16) if '0x' in argument else int(argument, 10)
    row_entries = tables[arch].find_all('tr')[argument + 1].find_all('td')

    for index, field in enumerate(row_entries):
        max_lengths[index] = max(max_lengths[index], len(field.text))

    for index, field in enumerate(indicesdict):
        bar_length += max_lengths[index] + 3
        print(f"{field.ljust(max_lengths[index])}", end=" | ")
    print('\n' + '=' * bar_length)

    for field in indicesdict:
        index, entry_text = indicesdict[field], row_entries[indicesdict[field]].text
        print(f"{row_entries[index].text.ljust(max_lengths[index])}", end=" | ")


# If hovering over a non-numerical value, do a lookup around the actual word for the specific
#   syscall by name. It's slightly messy because I want the resulting table to look nice
except ValueError:

    argument = argument.lower()
    table_rows = [i.find_all('td') for i in tables[arch].find_all('tr')][1:]

    # Remove irrelevant entries, if the argument is not contained within the syscall name
    table_rows = [i for i in table_rows if argument in i[indicesdict["syscall name"]].text]

    # This is really just for looks
    for row_num, row_entries in enumerate(table_rows):
        for i, entry in enumerate(row_entries):
            max_lengths[i] = max(max_lengths[i], len(entry.text))

    # Print everything spaced cleanly
    for index, field in enumerate(indicesdict):
        bar_length += max_lengths[index] + 3
        print(f"{field.ljust(max_lengths[index])}", end=" | ")
    print('\n' + '=' * bar_length)

    for row_entries in table_rows:
        for field in indicesdict:
            index, entry_text = indicesdict[field], row_entries[indicesdict[field]].text
            print(f"{row_entries[index].text.ljust(max_lengths[index])}", end=" | ")
        print()

_EOF_

endfunction


" For assembly files - replace man page binding with the execution of a python script that will
"   scrape a syscall table online and look up the byte under the cursor and list any relevant info
autocmd FileType asm nnoremap <S-k> :call DoSyscallLookup() <cr>

