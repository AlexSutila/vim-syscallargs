# vim-syscallargs
By default in vim, the Shift-K keybind will pull up a man page for what ever the cursor is hovering over. I like this feature but never found myself using it much 
when writing x86 assembly. However, I did often kill my workflow having to pull up a website to reference syscall arguments when writing x86 assembly. This repo provides
a way to remap this keybind, specifically when working in ASM files, to pull up syscall numbers/arguments within vim rather then having to pull up a browser and reference some
website.

Note this does use the python interpreter in the background, the bash script just does a pip install for the only
dependency needed.

## Screenshots
***NOTE: this demo assembly does not actually do anything useful***
![image](https://user-images.githubusercontent.com/96510931/210197944-798c142e-26db-48fe-8c85-f9d2fe994891.png)
![image](https://user-images.githubusercontent.com/96510931/210197992-95689794-594b-4a7d-b2d0-095babe787ae.png)

## Usage
Use exactly the same way you would the default man page key bind, hover cursor and Shift-K. 

If you are looking at
assembly and are not immediately aware of what the corresponding syscall is by looking at what value is being
moved into ***rax*** you can find out by doing Shift-K over the value itself:
![image](https://user-images.githubusercontent.com/96510931/210198209-317a0188-20a4-4c4c-a6c3-32f658c3a97c.png)

Or, if you are writing assembly yourself and need to put together a syscall you can hover over a name or
a substring of the syscall you need and it will display a similar table:
![image](https://user-images.githubusercontent.com/96510931/210198315-6938891e-eaab-4037-a3b4-e9a6eae7bd39.png)
There will likely be more entries this way, note that mbind is included in this case because bind is a substring.

## Todo
I was lazy and currently have this hardcoded to work with the only architecture I have ever needed to write
assembly for so I may expand on that in the future.

credit to:
https://chromium.googlesource.com/chromiumos/docs/+/master/constants/syscalls.md
