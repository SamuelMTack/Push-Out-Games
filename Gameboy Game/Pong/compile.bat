@echo off
if not exist "gbdk\bin\lcc.exe" (
    echo Error: GBDK compiler not found at gbdk\bin\lcc.exe
    exit /b 1
)

echo Compiling game...
gbdk\bin\lcc -o game.gb main.c

if %errorlevel% neq 0 (
    echo Compilation failed!
    exit /b %errorlevel%
)

echo Compilation successful! game.gb created.
