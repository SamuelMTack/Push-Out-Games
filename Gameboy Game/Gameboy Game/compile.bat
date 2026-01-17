@echo off
REM Compile script for simple Gameboy RPG

SET GBDK_HOME=..\Gameboy Compiler
SET LCC=%GBDK_HOME%\bin\lcc.exe

echo Compiling...
"%LCC%" -o game.gb main.c

if errorlevel 1 (
    echo Compilation Failed!
    exit /b 1
)

echo Compilation Successful!
echo Run game.gb in your emulator.
pause
