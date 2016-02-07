@echo off
nasm -f win32 xo.asm -o xo.obj
golink /files /console xo.obj kernel32.dll msvcr120.dll